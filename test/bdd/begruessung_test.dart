import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world_flutter/main.dart' as app;

void main() {
  testWidgets('Begrüßung zeigt Titel und Subtitel', (tester) async {
    await tester.pumpWidget(const app.HalloWelt());
    await expectLater(find.byType(app.HalloWelt), matchesGoldenFile('goldens/begruessung.png'));
    expect(find.text('Hallo Welt, Flutter'), findsOneWidget);
    expect(find.text('Eine Cross-Plattform-Funktionalität'), findsOneWidget);
  });
}
