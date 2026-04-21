import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';
import 'package:cobm_atendimento/features/sessao/presentation/screens/abrir_sessao_screen.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockSessaoRepository extends Mock implements SessaoRepository {}

class _GestorAuthNotifier extends AuthNotifier {
  @override
  Usuario? build() => gestorFake;
}

void main() {
  late MockSessaoRepository mockRepository;

  setUpAll(() => registerFallbackValue(mediumEntidadeFake));

  setUp(() {
    mockRepository = MockSessaoRepository();
    when(
      () => mockRepository.listarMediumEntidades(),
    ).thenAnswer((_) async => [mediumEntidadeFake]);
  });

  Widget buildWidget() {
    final router = GoRouter(
      initialLocation: '/lista/abrir',
      routes: [
        GoRoute(
          path: '/lista',
          builder: (ctx, state) => const Scaffold(),
          routes: [
            GoRoute(
              path: 'abrir',
              builder: (ctx, state) => const AbrirSessaoScreen(),
            ),
          ],
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(() => _GestorAuthNotifier()),
        sessaoRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  group('AbrirSessaoScreen', () {
    testWidgets('deve exibir lista de médiuns/entidades disponíveis', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text(mediumEntidadeFake.entidadeNome), findsOneWidget);
      expect(find.text(mediumEntidadeFake.mediumNome), findsOneWidget);
    });

    testWidgets('deve exibir botão de confirmar desabilitado sem seleção', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('btn_confirmar_abertura')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('deve habilitar botão após selecionar um par', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('me_check_${mediumEntidadeFake.id}')));
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('btn_confirmar_abertura')),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('deve chamar abrirSessao ao confirmar com seleção', (
      tester,
    ) async {
      when(
        () => mockRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.abrirSessao(gestorId: any(named: 'gestorId')),
      ).thenAnswer((_) async => sessaoFake);
      when(
        () => mockRepository.vincularMediumEntidade(
          sessaoId: any(named: 'sessaoId'),
          mediumEntidadeId: any(named: 'mediumEntidadeId'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('me_check_${mediumEntidadeFake.id}')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_confirmar_abertura')));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.abrirSessao(gestorId: gestorFake.id),
      ).called(1);
    });

    testWidgets(
      'deve voltar para tela anterior após abrir sessão com sucesso',
      (tester) async {
        when(
          () => mockRepository.buscarSessaoAberta(),
        ).thenAnswer((_) async => null);
        when(
          () => mockRepository.abrirSessao(gestorId: any(named: 'gestorId')),
        ).thenAnswer((_) async => sessaoFake);
        when(
          () => mockRepository.vincularMediumEntidade(
            sessaoId: any(named: 'sessaoId'),
            mediumEntidadeId: any(named: 'mediumEntidadeId'),
          ),
        ).thenAnswer((_) async {});

        final router = GoRouter(
          initialLocation: '/lista/abrir',
          routes: [
            GoRoute(
              path: '/lista',
              builder: (ctx, state) => const Scaffold(body: Text('Sessão')),
              routes: [
                GoRoute(
                  path: 'abrir',
                  builder: (ctx, state) => const AbrirSessaoScreen(),
                ),
              ],
            ),
          ],
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(() => _GestorAuthNotifier()),
              sessaoRepositoryProvider.overrideWithValue(mockRepository),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key('me_check_${mediumEntidadeFake.id}')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('btn_confirmar_abertura')));
        await tester.pumpAndSettle();

        expect(find.text('Sessão'), findsOneWidget);
      },
    );
  });
}
