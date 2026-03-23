import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/app.dart';

void main() {
  testWidgets('should render app without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    expect(find.text('Cobm Atendimento'), findsOneWidget);
  });
}
