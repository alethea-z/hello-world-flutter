import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_world_flutter/main.dart';

void main() {
  testWidgets('shows hello world message', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HalloWelt()));

    expect(find.byKey(const Key('titel')), findsOneWidget);
    expect(find.text('Hallo Welt, Flutter'), findsOneWidget);
    expect(find.text('Eine Cross-Plattform-Funktionalität'), findsOneWidget);
  });
}
