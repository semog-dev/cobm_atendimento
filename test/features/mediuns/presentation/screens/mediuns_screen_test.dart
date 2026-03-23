import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/mediuns/data/mediuns_repository.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/providers/mediuns_provider.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/screens/mediuns_screen.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/screens/medium_form_screen.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockMediunsRepository extends Mock implements MediunsRepository {}

Widget _buildWidget(MockMediunsRepository mockRepository) {
  final router = GoRouter(
    initialLocation: '/gestor/mediuns',
    routes: [
      GoRoute(
        path: '/gestor/mediuns',
        builder: (context, state) => const MediunsScreen(),
        routes: [
          GoRoute(
            path: 'novo',
            builder: (context, state) => const MediumFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => MediumFormScreen(
              medium: state.extra as Medium?,
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      mediunsRepositoryProvider.overrideWithValue(mockRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late MockMediunsRepository mockRepository;

  setUp(() {
    mockRepository = MockMediunsRepository();
  });

  group('MediunsScreen', () {
    testWidgets('deve exibir indicador de carregamento enquanto carrega',
        (tester) async {
      final completer = Completer<List<Medium>>();
      when(() => mockRepository.listar()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('deve exibir lista de médiuns quando carregamento é concluído',
        (tester) async {
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [mediumFake]);

      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('mediuns_list')), findsOneWidget);
      expect(find.text('José da Silva'), findsOneWidget);
    });

    testWidgets('deve exibir mensagem quando não há médiuns', (tester) async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty_message')), findsOneWidget);
    });

    testWidgets('deve exibir FAB para adicionar médium', (tester) async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_adicionar')), findsOneWidget);
    });

    testWidgets('deve navegar para formulário ao tocar no FAB', (tester) async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_adicionar')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('nome_field')), findsOneWidget);
    });

    testWidgets('deve exibir switch de ativo para cada médium', (tester) async {
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [mediumFake]);

      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(Key('switch_ativo_${mediumFake.id}')),
        findsOneWidget,
      );
    });

    testWidgets('deve navegar para formulário de edição ao tocar em editar',
        (tester) async {
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [mediumFake]);

      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('btn_editar_${mediumFake.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('nome_field')), findsOneWidget);
    });
  });
}
