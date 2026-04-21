import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/mediuns/data/mediuns_repository.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/providers/mediuns_provider.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/screens/medium_form_screen.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockMediunsRepository extends Mock implements MediunsRepository {}

Widget _buildWidget(MockMediunsRepository mockRepository, {Medium? medium}) {
  final router = GoRouter(
    initialLocation: medium == null ? '/novo' : '/editar',
    routes: [
      GoRoute(
        path: '/novo',
        builder: (context, state) => const MediumFormScreen(),
      ),
      GoRoute(
        path: '/editar',
        builder: (context, state) => MediumFormScreen(medium: medium),
      ),
    ],
  );

  return ProviderScope(
    overrides: [mediunsRepositoryProvider.overrideWithValue(mockRepository)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late MockMediunsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(mediumFake);
  });

  setUp(() {
    mockRepository = MockMediunsRepository();
    when(() => mockRepository.listar()).thenAnswer((_) async => []);
  });

  group('MediumFormScreen', () {
    testWidgets('deve exibir campo de nome', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pump();

      expect(find.byKey(const Key('nome_field')), findsOneWidget);
    });

    testWidgets('deve exibir campo de URL da foto', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pump();

      expect(find.byKey(const Key('foto_url_field')), findsOneWidget);
    });

    testWidgets('deve exibir botão de salvar', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pump();

      expect(find.byKey(const Key('btn_salvar')), findsOneWidget);
    });

    testWidgets('deve exibir erro quando nome está vazio', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_salvar')));
      await tester.pump();

      expect(find.text('Informe o nome'), findsOneWidget);
    });

    testWidgets(
      'deve chamar criar quando formulário é válido sem médium existente',
      (tester) async {
        when(
          () => mockRepository.criar(
            nome: any(named: 'nome'),
            fotoUrl: any(named: 'fotoUrl'),
          ),
        ).thenAnswer((_) async => mediumFake);
        when(
          () => mockRepository.listar(),
        ).thenAnswer((_) async => [mediumFake]);

        await tester.pumpWidget(_buildWidget(mockRepository));
        await tester.pump();

        await tester.enterText(
          find.byKey(const Key('nome_field')),
          'José da Silva',
        );
        await tester.tap(find.byKey(const Key('btn_salvar')));
        await tester.pumpAndSettle();

        verify(
          () => mockRepository.criar(nome: 'José da Silva', fotoUrl: null),
        ).called(1);
      },
    );

    testWidgets('deve preencher campos quando médium existente é passado', (
      tester,
    ) async {
      await tester.pumpWidget(_buildWidget(mockRepository, medium: mediumFake));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('nome_field')),
          matching: find.text('José da Silva'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'deve chamar atualizar quando formulário é válido com médium existente',
      (tester) async {
        when(() => mockRepository.salvar(any())).thenAnswer((_) async {});
        when(
          () => mockRepository.listar(),
        ).thenAnswer((_) async => [mediumFake]);

        await tester.pumpWidget(
          _buildWidget(mockRepository, medium: mediumFake),
        );
        await tester.pump();

        await tester.tap(find.byKey(const Key('btn_salvar')));
        await tester.pumpAndSettle();

        verify(() => mockRepository.salvar(any())).called(1);
      },
    );

    testWidgets('deve voltar para tela anterior após criar com sucesso', (
      tester,
    ) async {
      when(
        () => mockRepository.criar(
          nome: any(named: 'nome'),
          fotoUrl: any(named: 'fotoUrl'),
        ),
      ).thenAnswer((_) async => mediumFake);
      when(() => mockRepository.listar()).thenAnswer((_) async => [mediumFake]);

      final router = GoRouter(
        initialLocation: '/lista/novo',
        routes: [
          GoRoute(
            path: '/lista',
            builder: (ctx, state) =>
                const Scaffold(body: Text('Lista de Médiuns')),
            routes: [
              GoRoute(
                path: 'novo',
                builder: (ctx, state) => const MediumFormScreen(),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediunsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('nome_field')),
        'José da Silva',
      );
      await tester.tap(find.byKey(const Key('btn_salvar')));
      await tester.pumpAndSettle();

      expect(find.text('Lista de Médiuns'), findsOneWidget);
    });
  });
}
