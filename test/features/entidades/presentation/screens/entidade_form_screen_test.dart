import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/entidades/data/entidades_repository.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';
import 'package:cobm_atendimento/features/entidades/presentation/providers/entidades_provider.dart';
import 'package:cobm_atendimento/features/entidades/presentation/screens/entidade_form_screen.dart';
import 'package:cobm_atendimento/features/mediuns/data/mediuns_repository.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/providers/mediuns_provider.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockEntidadesRepository extends Mock implements EntidadesRepository {}
class MockMediunsRepository extends Mock implements MediunsRepository {}

void main() {
  late MockEntidadesRepository mockEntidadesRepo;
  late MockMediunsRepository mockMediunsRepo;

  setUpAll(() {
    registerFallbackValue(entidadeFake);
    registerFallbackValue(mediumFake);
  });

  setUp(() {
    mockEntidadesRepo = MockEntidadesRepository();
    mockMediunsRepo = MockMediunsRepository();
    when(() => mockMediunsRepo.listar())
        .thenAnswer((_) async => [mediumFake]);
  });

  Widget buildWidget({Entidade? entidade}) {
    final router = GoRouter(
      initialLocation: '/lista/form',
      routes: [
        GoRoute(
          path: '/lista',
          builder: (ctx, state) => const Scaffold(),
          routes: [
            GoRoute(
              path: 'form',
              builder: (ctx, state) => EntidadeFormScreen(entidade: entidade),
            ),
          ],
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        entidadesRepositoryProvider.overrideWithValue(mockEntidadesRepo),
        mediunsRepositoryProvider.overrideWithValue(mockMediunsRepo),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  group('EntidadeFormScreen', () {
    testWidgets('deve exibir campo de nome', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byKey(const Key('nome_field')), findsOneWidget);
    });

    testWidgets('deve exibir campo de descrição', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byKey(const Key('descricao_field')), findsOneWidget);
    });

    testWidgets('deve exibir lista de médiuns ativos', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text(mediumFake.nome), findsOneWidget);
    });

    testWidgets('deve exibir erro quando nome está vazio', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byKey(const Key('btn_salvar')));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome'), findsOneWidget);
    });

    testWidgets('deve chamar criar quando formulário é válido sem entidade existente',
        (tester) async {
      when(() => mockEntidadesRepo.listar())
          .thenAnswer((_) async => [entidadeFake]);
      when(() => mockEntidadesRepo.criar(
            nome: any(named: 'nome'),
            descricao: any(named: 'descricao'),
          )).thenAnswer((_) async => entidadeFake);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('nome_field')), 'Exu');
      await tester.tap(find.byKey(const Key('btn_salvar')));
      await tester.pumpAndSettle();

      verify(() => mockEntidadesRepo.criar(
            nome: 'Exu',
            descricao: any(named: 'descricao'),
          )).called(1);
    });

    testWidgets('deve chamar atualizar quando formulário é válido com entidade existente',
        (tester) async {
      when(() => mockEntidadesRepo.listar())
          .thenAnswer((_) async => [entidadeFake]);
      when(() => mockEntidadesRepo.salvar(any())).thenAnswer((_) async {});
      when(() => mockEntidadesRepo.listarMediuns(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget(entidade: entidadeFake));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('nome_field')), 'Exu Atualizado');
      await tester.tap(find.byKey(const Key('btn_salvar')));
      await tester.pumpAndSettle();

      verify(() => mockEntidadesRepo.salvar(any())).called(1);
    });

    testWidgets('deve marcar médium como selecionado ao tocar no checkbox',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('medium_check_${mediumFake.id}')));
      await tester.pumpAndSettle();

      final checkbox = tester.widget<CheckboxListTile>(
        find.byKey(Key('medium_check_${mediumFake.id}')),
      );
      expect(checkbox.value, isTrue);
    });

    testWidgets('deve voltar para tela anterior após criar com sucesso',
        (tester) async {
      when(() => mockEntidadesRepo.listar())
          .thenAnswer((_) async => [entidadeFake]);
      when(() => mockEntidadesRepo.criar(
            nome: any(named: 'nome'),
            descricao: any(named: 'descricao'),
          )).thenAnswer((_) async => entidadeFake);

      final router = GoRouter(
        initialLocation: '/lista/form',
        routes: [
          GoRoute(
            path: '/lista',
            builder: (ctx, state) =>
                const Scaffold(body: Text('Lista de Entidades')),
            routes: [
              GoRoute(
                path: 'form',
                builder: (ctx, state) => const EntidadeFormScreen(),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          entidadesRepositoryProvider.overrideWithValue(mockEntidadesRepo),
          mediunsRepositoryProvider.overrideWithValue(mockMediunsRepo),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('nome_field')), 'Exu');
      await tester.tap(find.byKey(const Key('btn_salvar')));
      await tester.pumpAndSettle();

      expect(find.text('Lista de Entidades'), findsOneWidget);
    });
  });
}
