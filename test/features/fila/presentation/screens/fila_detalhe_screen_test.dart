import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/data/fila_repository.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/fila_detalhe_screen.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';
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

  Widget buildWidget({List<EntradaFila> fila = const []}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (ctx, state) =>
              FilaDetalheScreen(mediumEntidade: mediumEntidadeFake),
        ),
        GoRoute(
          path: '/gestor/atendimento',
          builder: (ctx, state) => const Scaffold(
            key: Key('atendimento_screen'),
            body: Text('Atendimento em curso'),
          ),
        ),
        GoRoute(
          path: '/gestor/fila/registrar-cliente',
          builder: (ctx, state) => const Scaffold(
            key: Key('registrar_cliente_screen'),
            body: Text('Registrar'),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        filaRepositoryProvider.overrideWithValue(mockFilaRepository),
        sessaoRepositoryProvider.overrideWithValue(mockSessaoRepository),
        filaNotifierProvider.overrideWith(() => _FakeFilaNotifier(fila)),
        sessaoNotifierProvider.overrideWith(() => _FakeSessaoNotifier()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  group('FilaDetalheScreen', () {
    testWidgets('should mostrar entradas da fila do medium_entidade',
        (tester) async {
      await tester.pumpWidget(buildWidget(fila: [entradaFilaFake]));
      await tester.pumpAndSettle();

      expect(find.text('Posição 1'), findsOneWidget);
      expect(find.text(entradaFilaFake.clienteNome), findsOneWidget);
    });

    testWidgets('should exibir btn_chamar_proximo quando há entradas aguardando',
        (tester) async {
      await tester.pumpWidget(buildWidget(fila: [entradaFilaFake]));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_chamar_proximo')), findsOneWidget);
    });

    testWidgets('should exibir btn_adicionar_cliente', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_adicionar_cliente')), findsOneWidget);
    });

    testWidgets('should chamar proximo ao pressionar btn_chamar_proximo',
        (tester) async {
      when(() => mockFilaRepository.chamarProximo(any()))
          .thenAnswer((_) async => entradaFilaFake.copyWith(
                status: StatusFila.emAtendimento,
                chamadoEm: DateTime(2024, 1, 1, 9, 5),
              ));

      await tester.pumpWidget(buildWidget(fila: [entradaFilaFake]));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_chamar_proximo')));
      await tester.pumpAndSettle();

      verify(() => mockFilaRepository.chamarProximo(entradaFilaFake.id))
          .called(1);
    });

    testWidgets('should navegar para atendimento ao pressionar btn_atendimento',
        (tester) async {
      final entradaEmAtendimento = entradaFilaFake.copyWith(
        status: StatusFila.emAtendimento,
        chamadoEm: DateTime(2024, 1, 1, 9, 5),
      );

      await tester.pumpWidget(buildWidget(fila: [entradaEmAtendimento]));
      await tester.pumpAndSettle();

      await tester
          .tap(find.byKey(Key('btn_atendimento_${entradaEmAtendimento.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('atendimento_screen')), findsOneWidget);
    });
  });
}

class _FakeFilaNotifier extends FilaNotifier {
  _FakeFilaNotifier(this._fila);
  final List<EntradaFila> _fila;

  @override
  List<EntradaFila> build() => _fila;
}

class _FakeSessaoNotifier extends SessaoNotifier {
  @override
  Future<Sessao?> build() async => sessaoFake;
}
