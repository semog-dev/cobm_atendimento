import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';

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
    test('should retornar AuthResponse when credenciais válidas', () async {
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _fakeAuthResponse());

      final result = await repository.login(
        email: 'joao@email.com',
        password: '123456',
      );

      expect(result.user, isNotNull);
      expect(result.user!.id, 'uuid-123');
    });

    test(
      'should chamar signInWithPassword com email e senha corretos',
      () async {
        when(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => _fakeAuthResponse());

        await repository.login(email: 'joao@email.com', password: '123456');

        verify(
          () => mockAuth.signInWithPassword(
            email: 'joao@email.com',
            password: '123456',
          ),
        ).called(1);
      },
    );

    test('should lançar AuthException when credenciais inválidas', () {
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(AuthException('Invalid login credentials'));

      expect(
        () => repository.login(email: 'errado@email.com', password: 'errado'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthRepository.cadastrar', () {
    test('should retornar AuthResponse when cadastro bem-sucedido', () async {
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _fakeAuthResponse());

      final result = await repository.cadastrar(
        email: 'novo@email.com',
        password: '123456',
      );

      expect(result.user, isNotNull);
      expect(result.user!.id, 'uuid-123');
    });

    test('should chamar signUp com email e senha corretos', () async {
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _fakeAuthResponse());

      await repository.cadastrar(email: 'novo@email.com', password: '123456');

      verify(
        () => mockAuth.signUp(email: 'novo@email.com', password: '123456'),
      ).called(1);
    });

    test('should lançar AuthException when email já cadastrado', () {
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(AuthException('User already registered'));

      expect(
        () => repository.cadastrar(
          email: 'existente@email.com',
          password: '123456',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthRepository.logout', () {
    test('should chamar signOut no Supabase', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('should lançar AuthException when signOut falha', () {
      when(() => mockAuth.signOut()).thenThrow(AuthException('Logout failed'));

      expect(() => repository.logout(), throwsA(isA<AuthException>()));
    });
  });

  group('AuthRepository.usuarioAtual', () {
    test('should retornar null when não há usuário autenticado', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(repository.usuarioAtual, isNull);
    });

    test('should retornar User when há usuário autenticado', () {
      when(() => mockAuth.currentUser).thenReturn(_fakeUser());

      expect(repository.usuarioAtual, isNotNull);
      expect(repository.usuarioAtual!.id, 'uuid-123');
    });
  });

  // buscarPerfil e salvarPerfil usam a cadeia PostgREST do Supabase,
  // cujos tipos genéricos tornam o mock de unidade inviável sem um wrapper.
  // Esses métodos são cobertos nos testes de provider (auth_provider_test.dart),
  // onde o AuthRepository inteiro é mockado.
}
