import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import '../../../core/helpers/test_helpers.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

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
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late AuthRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repository = AuthRepository(client: mockClient);
  });

  group('AuthRepository.login', () {
    test('deve chamar signInWithPassword com email e senha corretos', () async {
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _fakeAuthResponse());

      await repository.login(email: 'joao@email.com', password: '123456');

      verify(() => mockAuth.signInWithPassword(
            email: 'joao@email.com',
            password: '123456',
          )).called(1);
    });

    test('deve lançar exceção quando credenciais são inválidas', () {
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException('Invalid login credentials'));

      expect(
        () => repository.login(email: 'errado@email.com', password: 'errado'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthRepository.cadastrar', () {
    test('deve chamar signUp com email e senha corretos', () async {
      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _fakeAuthResponse());

      await repository.cadastrar(email: 'novo@email.com', password: '123456');

      verify(() => mockAuth.signUp(
            email: 'novo@email.com',
            password: '123456',
          )).called(1);
    });
  });

  group('AuthRepository.logout', () {
    test('deve chamar signOut no Supabase', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockAuth.signOut()).called(1);
    });
  });

  group('AuthRepository.usuarioAtual', () {
    test('deve retornar null quando não há usuário autenticado', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(repository.usuarioAtual, isNull);
    });

    test('deve retornar User quando há usuário autenticado', () {
      when(() => mockAuth.currentUser).thenReturn(_fakeUser());

      expect(repository.usuarioAtual, isNotNull);
      expect(repository.usuarioAtual!.id, 'uuid-123');
    });
  });
}
