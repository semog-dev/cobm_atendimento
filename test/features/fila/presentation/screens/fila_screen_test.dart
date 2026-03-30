import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/data/fila_repository.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
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

  Widget buildWidget({String initialLocation = '/'}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (ctx, state) => const FilaScreen()),
        GoRoute(
          path: '/gestor/atendimento',
          builder: (ctx, state) => const Scaffold(
            key: Key('atendimento_screen'),
            body: Text('Atendimento em curso'),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        filaRepositoryProvider.overrideWithValue(mockFilaRepository),
        sessaoRepositoryProvider.overrideWithValue(mockSessaoRepository),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  group('FilaScreen', () {
    testWidgets('should mostrar mensagem quando não há sessão aberta',
        (tester) async {
      when(() => mockSessaoRepository.buscarSessaoAberta())
          .thenAnswer((_) async => null);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma sessão aberta'), findsOneWidget);
    });

    testWidgets('should mostrar lista da fila quando sessão está aberta',
        (tester) async {
      when(() => mockSessaoRepository.buscarSessaoAberta())
          .thenAnswer((_) async => sessaoFake);
      when(() => mockFilaRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => Stream.value([entradaFilaFake]));
      when(() => mockFilaRepository.listarPorSessao(any()))
          .thenAnswer((_) async => [entradaFilaFake]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Posição 1'), findsOneWidget);
    });

    testWidgets('should chamar proximo ao pressionar btn_chamar_proximo',
        (tester) async {
      when(() => mockSessaoRepository.buscarSessaoAberta())
          .thenAnswer((_) async => sessaoFake);
      when(() => mockFilaRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => Stream.value([entradaFilaFake]));
      when(() => mockFilaRepository.listarPorSessao(any()))
          .thenAnswer((_) async => [entradaFilaFake]);
      when(() => mockFilaRepository.chamarProximo(any()))
          .thenAnswer((_) async => entradaFilaFake.copyWith(
                status: StatusFila.emAtendimento,
                chamadoEm: DateTime(2024, 1, 1, 9, 5),
              ));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_chamar_proximo')));
      await tester.pumpAndSettle();

      verify(() => mockFilaRepository.chamarProximo(entradaFilaFake.id))
          .called(1);
    });

    testWidgets(
        'should navegar para atendimento ao pressionar entrada em atendimento',
        (tester) async {
      final entradaEmAtendimento = entradaFilaFake.copyWith(
        status: StatusFila.emAtendimento,
        chamadoEm: DateTime(2024, 1, 1, 9, 5),
      );

      when(() => mockSessaoRepository.buscarSessaoAberta())
          .thenAnswer((_) async => sessaoFake);
      when(() => mockFilaRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => Stream.value([entradaEmAtendimento]));
      when(() => mockFilaRepository.listarPorSessao(any()))
          .thenAnswer((_) async => [entradaEmAtendimento]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(
          find.byKey(Key('btn_atendimento_${entradaEmAtendimento.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('atendimento_screen')), findsOneWidget);
    });
  });
}
