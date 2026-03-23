import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

User _fakeUser() => User(
      id: 'uuid-123',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2024-01-01T00:00:00.000',
    );

AuthResponse _fakeAuthResponse() => AuthResponse(
      session: Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: _fakeUser(),
      ),
    );

void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AuthProvider estado inicial', () {
    test('deve iniciar com usuário nulo quando não há sessão ativa', () async {
      when(() => mockRepository.usuarioAtual).thenReturn(null);
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());

      container.read(authProvider);
      await Future.microtask(() {});

      expect(container.read(authProvider), isNull);
    });

    test('deve restaurar sessão quando há usuário autenticado no Supabase',
        () async {
      when(() => mockRepository.usuarioAtual).thenReturn(_fakeUser());
      when(() => mockRepository.buscarPerfil(any()))
          .thenAnswer((_) async => usuarioMapFake);
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());

      container.read(authProvider);
      await Future.microtask(() {});
      await Future.delayed(Duration.zero);

      expect(container.read(authProvider), isA<Usuario>());
    });
  });

  group('AuthProvider.login', () {
    test('deve atualizar estado com usuario quando login é bem-sucedido',
        () async {
      when(() => mockRepository.usuarioAtual).thenReturn(null);
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _fakeAuthResponse());
      when(() => mockRepository.buscarPerfil(any()))
          .thenAnswer((_) async => usuarioMapFake);

      await container
          .read(authProvider.notifier)
          .login(email: 'joao@email.com', password: '123456');

      expect(container.read(authProvider), isA<Usuario>());
      expect(container.read(authProvider)!.id, 'uuid-123');
    });

    test('deve lançar exceção quando login falha', () async {
      when(() => mockRepository.usuarioAtual).thenReturn(null);
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException('Invalid login credentials'));

      expect(
        () => container
            .read(authProvider.notifier)
            .login(email: 'errado@email.com', password: 'errado'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthProvider.logout', () {
    test('deve limpar estado quando logout é chamado', () async {
      when(() => mockRepository.usuarioAtual).thenReturn(null);
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider), isNull);
    });
  });

  group('AuthProvider sessão persistente', () {
    test('deve deslogar quando authStateChanges emite signedOut', () async {
      final controller = StreamController<AuthState>.broadcast();

      when(() => mockRepository.usuarioAtual).thenReturn(null);
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => controller.stream);

      container.read(authProvider);
      await Future.microtask(() {});

      controller.add(AuthState(AuthChangeEvent.signedOut, null));
      await Future.delayed(Duration.zero);

      expect(container.read(authProvider), isNull);
      await controller.close();
    });
  });
}
