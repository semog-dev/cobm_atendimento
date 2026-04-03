import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/profile_screen.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget buildWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (ctx, state) => const ProfileScreen()),
        GoRoute(
          path: '/login',
          builder: (ctx, state) =>
              const Scaffold(body: Text('Login')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        authProvider.overrideWith(() => _FakeAuthNotifier()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  group('ProfileScreen', () {
    testWidgets('should exibir nome do usuário logado', (tester) async {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockAuthRepository.usuarioAtual).thenReturn(null);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text(gestorFake.nome), findsOneWidget);
    });

    testWidgets('should exibir telefone do usuário logado', (tester) async {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockAuthRepository.usuarioAtual).thenReturn(null);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text(gestorFake.telefone), findsOneWidget);
    });

    testWidgets('should exibir btn_logout', (tester) async {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockAuthRepository.usuarioAtual).thenReturn(null);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_logout')), findsOneWidget);
    });

    testWidgets('should navegar para login ao fazer logout', (tester) async {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockAuthRepository.usuarioAtual).thenReturn(null);
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_logout')));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  build() => gestorFake;
}
