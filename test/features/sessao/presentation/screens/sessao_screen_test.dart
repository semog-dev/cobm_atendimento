import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';
import 'package:cobm_atendimento/features/sessao/presentation/screens/sessao_screen.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockSessaoRepository extends Mock implements SessaoRepository {}

void main() {
  late MockSessaoRepository mockRepository;

  setUp(() => mockRepository = MockSessaoRepository());

  Widget buildWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (ctx, state) => const SessaoScreen()),
        GoRoute(
          path: '/gestor/sessao/abrir',
          builder: (ctx, state) => const Scaffold(body: Text('Abrir Sessão')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        sessaoRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  group('SessaoScreen', () {
    testWidgets('deve exibir mensagem quando não há sessão aberta',
        (tester) async {
      when(() => mockRepository.buscarSessaoAberta())
          .thenAnswer((_) async => null);
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma sessão aberta'), findsOneWidget);
    });

    testWidgets('deve exibir botão de abrir sessão quando não há sessão',
        (tester) async {
      when(() => mockRepository.buscarSessaoAberta())
          .thenAnswer((_) async => null);
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_abrir_sessao')), findsOneWidget);
    });

    testWidgets('deve exibir botão de encerrar quando há sessão aberta',
        (tester) async {
      when(() => mockRepository.buscarSessaoAberta())
          .thenAnswer((_) async => sessaoFake);
      when(() => mockRepository.listarMediumEntidadesDaSessao(any()))
          .thenAnswer((_) async => [mediumEntidadeFake]);
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_encerrar_sessao')), findsOneWidget);
    });

    testWidgets('deve exibir médiuns/entidades da sessão quando aberta',
        (tester) async {
      when(() => mockRepository.buscarSessaoAberta())
          .thenAnswer((_) async => sessaoFake);
      when(() => mockRepository.listarMediumEntidadesDaSessao(any()))
          .thenAnswer((_) async => [mediumEntidadeFake]);
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
            '${mediumEntidadeFake.mediumNome} — ${mediumEntidadeFake.entidadeNome}'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir histórico de sessões encerradas', (tester) async {
      final sessaoEncerrada = sessaoFake.copyWith(
        id: 'uuid-sess-002',
        status: StatusSessao.encerrada,
        encerradaEm: DateTime(2024, 1, 1, 12, 0),
      );

      when(() => mockRepository.buscarSessaoAberta())
          .thenAnswer((_) async => null);
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [sessaoEncerrada]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('historico_sessoes')), findsOneWidget);
    });

    testWidgets('deve exibir card da sessão encerrada no histórico',
        (tester) async {
      final sessaoEncerrada = sessaoFake.copyWith(
        id: 'uuid-sess-002',
        status: StatusSessao.encerrada,
        encerradaEm: DateTime(2024, 1, 1, 12, 0),
      );

      when(() => mockRepository.buscarSessaoAberta())
          .thenAnswer((_) async => null);
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [sessaoEncerrada]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(Key('sessao_card_${sessaoEncerrada.id}')),
          findsOneWidget);
    });
  });
}
