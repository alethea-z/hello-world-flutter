import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world_flutter/main.dart' as app;

void main() {
  testWidgets('Zurücksetzen setzt den Zähler zurück', (tester) async {
    await tester.pumpWidget(const app.HalloWelt());
    await tester.tap(find.byKey(const ValueKey('zaehlen')));
    await tester.pumpAndSettle();
    expect(find.text('Zähler: 1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('zuruecksetzen')));
    await tester.pumpAndSettle();
    await expectLater(find.byType(app.HalloWelt), matchesGoldenFile('goldens/zuruecksetzen.png'));
    expect(find.text('Zähler: 0'), findsOneWidget);
  });
}
