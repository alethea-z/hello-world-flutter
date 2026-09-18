import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() async {
    final font = rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final fontLoader = FontLoader('Roboto')..addFont(font);
    await fontLoader.load();
  });

  await testMain();
}
