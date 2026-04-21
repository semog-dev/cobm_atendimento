import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/login_screen.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/cadastro_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Widget _buildWidget(MockAuthRepository mockRepository) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/cadastro', builder: (context, state) => const CadastroScreen()),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockRepository),
      authInicializandoProvider.overrideWith((ref) => false),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    when(() => mockRepository.usuarioAtual).thenReturn(null);
  });

  group('LoginScreen', () {
    testWidgets('deve exibir campos de email e senha', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('senha_field')), findsOneWidget);
    });

    testWidgets('deve exibir botão de entrar', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      expect(find.byKey(const Key('btn_entrar')), findsOneWidget);
    });

    testWidgets('deve exibir erro quando email está vazio', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      await tester.tap(find.byKey(const Key('btn_entrar')));
      await tester.pump();

      expect(find.text('Informe o e-mail'), findsOneWidget);
    });

    testWidgets('deve exibir erro quando senha está vazia', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      await tester.enterText(
          find.byKey(const Key('email_field')), 'teste@email.com');
      await tester.tap(find.byKey(const Key('btn_entrar')));
      await tester.pump();

      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('deve chamar login quando formulário é válido', (tester) async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('erro simulado'));

      await tester.pumpWidget(_buildWidget(mockRepository));

      await tester.enterText(
          find.byKey(const Key('email_field')), 'teste@email.com');
      await tester.enterText(
          find.byKey(const Key('senha_field')), '123456');
      await tester.tap(find.byKey(const Key('btn_entrar')));
      await tester.pump();

      verify(() => mockRepository.login(
            email: 'teste@email.com',
            password: '123456',
          )).called(1);
    });
  });
}
