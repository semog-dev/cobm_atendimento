import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/app.dart';

void main() {
  testWidgets('should renderizar app sem crash', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authProvider.overrideWith(() => _FakeAuthNotifier()),
        authInicializandoProvider.overrideWith((ref) => false),
      ],
      child: const App(),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('email_field')), findsOneWidget);
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  build() => null;
}
