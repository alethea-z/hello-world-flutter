import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world_flutter/main.dart' as app;

void main() {
  testWidgets('Zählen erhöht den Zähler', (tester) async {
    await tester.pumpWidget(const app.HalloWelt());
    expect(find.text('Zähler: 0'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('zaehlen')));
    await tester.pumpAndSettle();
    await expectLater(find.byType(app.HalloWelt), matchesGoldenFile('goldens/zaehlen.png'));
    expect(find.text('Zähler: 1'), findsOneWidget);
  });
}
