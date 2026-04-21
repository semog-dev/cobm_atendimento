import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/cadastro_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Widget _buildWidget(MockAuthRepository mockRepository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
    child: const MaterialApp(home: CadastroScreen()),
  );
}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    when(() => mockRepository.usuarioAtual).thenReturn(null);
  });

  group('CadastroScreen', () {
    testWidgets('deve exibir campos de nome, telefone, email e senha', (
      tester,
    ) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      expect(find.byKey(const Key('nome_field')), findsOneWidget);
      expect(find.byKey(const Key('telefone_field')), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('senha_field')), findsOneWidget);
    });

    testWidgets('deve exibir botão de cadastrar', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      expect(find.byKey(const Key('btn_cadastrar')), findsOneWidget);
    });

    testWidgets('deve exibir link para login', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      expect(find.byKey(const Key('btn_login')), findsOneWidget);
    });

    testWidgets('deve exibir erro quando nome está vazio', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      await tester.tap(find.byKey(const Key('btn_cadastrar')));
      await tester.pump();

      expect(find.text('Informe o nome'), findsOneWidget);
    });

    testWidgets('deve exibir erro quando telefone está vazio', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      await tester.enterText(find.byKey(const Key('nome_field')), 'João');
      await tester.tap(find.byKey(const Key('btn_cadastrar')));
      await tester.pump();

      expect(find.text('Informe o telefone'), findsOneWidget);
    });

    testWidgets('deve exibir erro quando e-mail está vazio', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      await tester.enterText(find.byKey(const Key('nome_field')), 'João');
      await tester.enterText(
        find.byKey(const Key('telefone_field')),
        '11999999999',
      );
      await tester.tap(find.byKey(const Key('btn_cadastrar')));
      await tester.pump();

      expect(find.text('Informe o e-mail'), findsOneWidget);
    });

    testWidgets('deve exibir erro quando senha está vazia', (tester) async {
      await tester.pumpWidget(_buildWidget(mockRepository));

      await tester.enterText(find.byKey(const Key('nome_field')), 'João');
      await tester.enterText(
        find.byKey(const Key('telefone_field')),
        '11999999999',
      );
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'joao@email.com',
      );
      await tester.tap(find.byKey(const Key('btn_cadastrar')));
      await tester.pump();

      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('deve chamar cadastrar quando formulário é válido', (
      tester,
    ) async {
      when(
        () => mockRepository.cadastrar(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('erro simulado'));

      await tester.pumpWidget(_buildWidget(mockRepository));

      await tester.enterText(find.byKey(const Key('nome_field')), 'João');
      await tester.enterText(
        find.byKey(const Key('telefone_field')),
        '11999999999',
      );
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'joao@email.com',
      );
      await tester.enterText(find.byKey(const Key('senha_field')), '123456');
      await tester.tap(find.byKey(const Key('btn_cadastrar')));
      await tester.pump();

      verify(
        () => mockRepository.cadastrar(
          email: 'joao@email.com',
          password: '123456',
        ),
      ).called(1);
    });
  });
}
