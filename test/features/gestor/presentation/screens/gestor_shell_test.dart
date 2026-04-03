import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/core/config/router.dart';
import 'package:cobm_atendimento/core/theme/app_theme.dart';

class _GestorAuthNotifier extends AuthNotifier {
  @override
  Usuario? build() => Usuario(
        id: 'gestor-1',
        nome: 'Gestor',
        telefone: '11999999999',
        role: Role.gestor,
        createdAt: DateTime(2024),
      );
}

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _GestorAuthNotifier()),
    ],
    child: Builder(builder: (context) {
      return Consumer(builder: (context, ref, _) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        );
      });
    }),
  );
}

void main() {
  group('GestorShell', () {
    testWidgets('deve exibir barra de navegação com cinco destinos', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Médiuns'), findsAtLeastNWidgets(1));
      expect(find.text('Entidades'), findsOneWidget);
      expect(find.text('Sessão'), findsOneWidget);
      expect(find.text('Fila'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('deve exibir tela de médiuns como destino inicial', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('mediuns_screen')), findsOneWidget);
    });

    testWidgets('deve navegar para tela de sessão ao tocar no destino', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sessão'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sessao_screen')), findsOneWidget);
    });

    testWidgets('deve navegar para tela de fila ao tocar no destino', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fila'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fila_screen')), findsOneWidget);
    });
  });
}
