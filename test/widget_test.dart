import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/app.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('should render app without crashing', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.usuarioAtual).thenReturn(null);

    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: const App(),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('email_field')), findsOneWidget);
  });
}
