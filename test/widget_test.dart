import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_world_flutter/main.dart';

void main() {
  testWidgets('shows hello world message', (WidgetTester tester) async {
    await tester.pumpWidget(const HelloWorldApp());

    expect(find.byKey(const Key('helloText')), findsOneWidget);
    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Flutter app foundation ready for Android and iOS.'), findsOneWidget);
  });
}
