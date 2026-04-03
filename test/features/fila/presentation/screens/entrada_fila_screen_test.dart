import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/data/fila_repository.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/entrada_fila_screen.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockFilaRepository extends Mock implements FilaRepository {}

class MockSessaoRepository extends Mock implements SessaoRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockFilaRepository mockFilaRepository;
  late MockSessaoRepository mockSessaoRepository;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockFilaRepository = MockFilaRepository();
    mockSessaoRepository = MockSessaoRepository();
    mockAuthRepository = MockAuthRepository();
  });

  Widget buildWidget() {
    final router = GoRouter(
      initialLocation: '/entrar-fila',
      routes: [
        GoRoute(
          path: '/entrar-fila',
          builder: (ctx, state) =>
              EntradaFilaScreen(sessaoId: sessaoFake.id),
        ),
        GoRoute(
          path: '/cliente/fila',
          builder: (ctx, state) =>
              const Scaffold(body: Text('Minha Posição na Fila')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        filaRepositoryProvider.overrideWithValue(mockFilaRepository),
        sessaoRepositoryProvider.overrideWithValue(mockSessaoRepository),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        authProvider.overrideWith(() {
          final notifier = _FakeAuthNotifier();
          return notifier;
        }),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  group('EntradaFilaScreen', () {
    testWidgets('should mostrar opções de médium/entidade da sessão',
        (tester) async {
      when(() => mockSessaoRepository.listarMediumEntidadesDaSessao(any()))
          .thenAnswer((_) async => [mediumEntidadeFake]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(Key('me_tile_${mediumEntidadeFake.id}')),
          findsOneWidget);
    });

    testWidgets('should btn_entrar_fila desabilitado quando nada selecionado',
        (tester) async {
      when(() => mockSessaoRepository.listarMediumEntidadesDaSessao(any()))
          .thenAnswer((_) async => [mediumEntidadeFake]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
          find.byKey(const Key('btn_entrar_fila')));
      expect(btn.onPressed, isNull);
    });

    testWidgets('should entrar na fila ao confirmar seleção', (tester) async {
      when(() => mockSessaoRepository.listarMediumEntidadesDaSessao(any()))
          .thenAnswer((_) async => [mediumEntidadeFake]);
      when(() => mockFilaRepository.ultimaPosicao(
            sessaoId: any(named: 'sessaoId'),
            mediumEntidadeId: any(named: 'mediumEntidadeId'),
          )).thenAnswer((_) async => 0);
      when(() => mockFilaRepository.entrarNaFila(
            sessaoId: any(named: 'sessaoId'),
            clienteId: any(named: 'clienteId'),
            mediumEntidadeId: any(named: 'mediumEntidadeId'),
            posicao: any(named: 'posicao'),
          )).thenAnswer((_) async => entradaFilaFake);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('me_tile_${mediumEntidadeFake.id}')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_entrar_fila')));
      await tester.pumpAndSettle();

      verify(() => mockFilaRepository.entrarNaFila(
            sessaoId: sessaoFake.id,
            clienteId: any(named: 'clienteId'),
            mediumEntidadeId: mediumEntidadeFake.id,
            posicao: 1,
          )).called(1);
    });
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  build() => usuarioFake;
}
