import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:hello_world_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('hello world screen renders in the emulator', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Flutter app foundation ready for Android and iOS.'), findsOneWidget);
  });
}
