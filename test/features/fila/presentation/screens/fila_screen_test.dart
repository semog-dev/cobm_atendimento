import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/data/fila_repository.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/fila_screen.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockFilaRepository extends Mock implements FilaRepository {}

class MockSessaoRepository extends Mock implements SessaoRepository {}

void main() {
  late MockFilaRepository mockFilaRepository;
  late MockSessaoRepository mockSessaoRepository;

  setUp(() {
    mockFilaRepository = MockFilaRepository();
    mockSessaoRepository = MockSessaoRepository();
  });

  Widget buildWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (ctx, state) => const FilaScreen()),
        GoRoute(
          path: '/gestor/fila/detalhe',
          builder: (ctx, state) => const Scaffold(
            key: Key('fila_detalhe_screen'),
            body: Text('Detalhe'),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        filaRepositoryProvider.overrideWithValue(mockFilaRepository),
        sessaoRepositoryProvider.overrideWithValue(mockSessaoRepository),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  group('FilaScreen', () {
    testWidgets('should mostrar mensagem quando não há sessão aberta', (
      tester,
    ) async {
      when(
        () => mockSessaoRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma sessão aberta'), findsOneWidget);
    });

    testWidgets(
      'should mostrar cards de medium_entidade quando sessão está aberta',
      (tester) async {
        when(
          () => mockSessaoRepository.buscarSessaoAberta(),
        ).thenAnswer((_) async => sessaoFake);
        when(
          () => mockSessaoRepository.listarMediumEntidadesDaSessao(any()),
        ).thenAnswer((_) async => [mediumEntidadeFake]);
        when(
          () => mockFilaRepository.listarPorSessaoStream(any()),
        ).thenAnswer((_) => Stream.value([entradaFilaFake]));

        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text(mediumEntidadeFake.entidadeNome), findsOneWidget);
        expect(find.text(mediumEntidadeFake.mediumNome), findsOneWidget);
      },
    );

    testWidgets('should navegar para detalhe ao tocar no card', (tester) async {
      when(
        () => mockSessaoRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => sessaoFake);
      when(
        () => mockSessaoRepository.listarMediumEntidadesDaSessao(any()),
      ).thenAnswer((_) async => [mediumEntidadeFake]);
      when(
        () => mockFilaRepository.listarPorSessaoStream(any()),
      ).thenAnswer((_) => Stream.value([entradaFilaFake]));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('fila_card_${mediumEntidadeFake.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fila_detalhe_screen')), findsOneWidget);
    });
  });
}
