import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/data/fila_repository.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/atendimento_screen.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockFilaRepository extends Mock implements FilaRepository {}

void main() {
  late MockFilaRepository mockFilaRepository;

  setUp(() {
    mockFilaRepository = MockFilaRepository();
  });

  final entradaEmAtendimento = entradaFilaFake.copyWith(
    status: StatusFila.emAtendimento,
    chamadoEm: DateTime(2024, 1, 1, 9, 5),
  );

  Widget buildWidget() {
    final router = GoRouter(
      initialLocation: '/atendimento',
      routes: [
        GoRoute(
          path: '/atendimento',
          builder: (ctx, state) =>
              AtendimentoScreen(entrada: entradaEmAtendimento),
        ),
        GoRoute(
          path: '/',
          builder: (ctx, state) => const Scaffold(body: Text('Fila')),
        ),
        GoRoute(
          path: '/gestor/fila',
          builder: (ctx, state) => const Scaffold(body: Text('Fila')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        filaRepositoryProvider.overrideWithValue(mockFilaRepository),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  group('AtendimentoScreen', () {
    testWidgets('should mostrar tela de atendimento com cronômetro',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byKey(const Key('atendimento_screen')), findsOneWidget);
      expect(find.text('Atendimento em curso'), findsOneWidget);
    });

    testWidgets('should encerrar atendimento ao pressionar btn_encerrar',
        (tester) async {
      final encerrada = entradaEmAtendimento.copyWith(
        status: StatusFila.concluido,
        encerradoEm: DateTime(2024, 1, 1, 9, 30),
        duracaoSegundos: 1500,
      );
      when(() => mockFilaRepository.encerrarAtendimento(any()))
          .thenAnswer((_) async => encerrada);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_encerrar_atendimento')));
      await tester.pumpAndSettle();

      verify(() =>
              mockFilaRepository.encerrarAtendimento(entradaEmAtendimento.id))
          .called(1);
    });

    testWidgets('should navegar para tela de fila após encerrar atendimento',
        (tester) async {
      final encerrada = entradaEmAtendimento.copyWith(
        status: StatusFila.concluido,
        encerradoEm: DateTime(2024, 1, 1, 9, 30),
        duracaoSegundos: 1500,
      );
      when(() => mockFilaRepository.encerrarAtendimento(any()))
          .thenAnswer((_) async => encerrada);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_encerrar_atendimento')));
      await tester.pumpAndSettle();

      expect(find.text('Fila'), findsOneWidget);
    });
  });
}
