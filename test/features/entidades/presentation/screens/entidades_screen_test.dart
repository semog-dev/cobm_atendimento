import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/entidades/data/entidades_repository.dart';
import 'package:cobm_atendimento/features/entidades/presentation/providers/entidades_provider.dart';
import 'package:cobm_atendimento/features/entidades/presentation/screens/entidades_screen.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockEntidadesRepository extends Mock implements EntidadesRepository {}

void main() {
  late MockEntidadesRepository mockRepository;

  setUpAll(() => registerFallbackValue(entidadeFake));

  setUp(() => mockRepository = MockEntidadesRepository());

  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        entidadesRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const EntidadesScreen(),
      ),
    );
  }

  group('EntidadesScreen', () {
    testWidgets('deve exibir indicador de carregamento enquanto carrega',
        (tester) async {
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [entidadeFake]);

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve exibir lista de entidades quando carregamento é concluído',
        (tester) async {
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [entidadeFake]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text(entidadeFake.nome), findsOneWidget);
    });

    testWidgets('deve exibir FAB para adicionar entidade', (tester) async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fab_nova_entidade')), findsOneWidget);
    });

    testWidgets('deve exibir switch de ativa para cada entidade',
        (tester) async {
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [entidadeFake]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
