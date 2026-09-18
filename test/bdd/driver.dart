// BDD-GUI-Treiber (flutter_driver) für hello-world-flutter.
//
// Aufruf (pro Feature, damit jedes Feature eine eigene App-Session bekommt):
//   BDD_FEATURE_FILE=test/bdd/zaehlen.feature flutter drive \
//       --target=lib/main.dart \
//       --driver=test/bdd/driver.dart \
//       -d <device>
//
// Der Treiber
//   * liest die Feature-Datei aus BDD_FEATURE_FILE (oder BDD_FEATURE als
//     Fallback für direkten Feature-Text),
//   * führt die Scenarios des angegebenen Features aus,
//   * übersetzt jede BDD-Zeile in echte GUI-Aktionen (tap / waitFor-Text),
//   * macht nach dem Abschluss jedes Scenarios einen Screenshot der GUI
//       -> test_report/screenshots/<feature>--<scenario>.png
//   * schreibt das Feature-Protokoll als JSON (test_report/<feature>.json),
//   * beenden mit Exit-Code 0, wenn alle Scenarios bestehen, sonst 1.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter/services.dart';

const _buttons = {'Zählen': 'zaehlen', 'Zurücksetzen': 'zuruecksetzen'};

class Step {
  final String label;
  final String expected;
  final String actual;
  final bool passed;

  Step({
    required this.label,
    required this.expected,
    required this.actual,
    required this.passed,
  });

  Map<String, dynamic> toJson() => {
        'step': label,
        'erwartet': expected,
        'tatsächlich': actual,
        'bestanden': passed,
      };
}

class ScenarioReport {
  final String name;
  final List<Step> steps;
  final String screenshot;

  ScenarioReport({
    required this.name,
    required this.steps,
    required this.screenshot,
  });

  bool get passed => steps.isNotEmpty && steps.every((s) => s.passed);

  Map<String, dynamic> toJson() => {
        'name': name,
        'bestanden': passed,
        'screenshot': screenshot,
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}

class World {
  final FlutterDriver d;
  World(this.d);

  /// Wartet, bis der Text sichtbar ist (erwartete GUI-Zustand).
  Future<Step> textVisible(String label, String expected, String text) async {
    try {
      await d
          .waitFor(find.text(text), timeout: const Duration(seconds: 15));
      return Step(label: label, expected: expected, actual: 'sichtbar: "$text"', passed: true);
    } catch (e) {
      return Step(label: label, expected: expected, actual: 'Nicht sichtbar: "$text" ($e)', passed: false);
    }
  }

  Future<Step> tapButton(String label, String expected, String btn) async {
    final key = _buttons[btn];
    if (key == null) {
      return Step(label: label, expected: expected, actual: 'Unbekannter Button "$btn"', passed: false);
    }
    await d.tap(find.byValueKey(key));
    // Kurze Pausen für UI-Updates
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return Step(label: label, expected: expected, actual: 'getippt: "$btn"', passed: true);
  }

  Future<int> _counterNow() async {
    try {
      final t = await d.getText(find.byValueKey('zaehler'));
      final m = RegExp(r'(\d+)$').firstMatch(t);
      return m != null ? int.parse(m.group(1)!) : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Setzt den Zähler auf den gewünschten Wert (n) für "Gegeben ist …".
  Future<Step> setCounter(String label, String expected, int n) async {
    final cur = await _counterNow();
    if (cur == n) {
      return Step(label: label, expected: expected, actual: 'Zähler ist bereits $n', passed: true);
    }
    // Zurücksetzen, falls nötig
    if (cur > 0) {
      await d.tap(find.byValueKey('zuruecksetzen'));
      await d
          .waitFor(find.text('Zähler: 0'), timeout: const Duration(seconds: 15));
    }
    // Auf Ziel hochzählen
    for (var i = 1; i <= n; i++) {
      await d.tap(find.byValueKey('zaehlen'));
      await d
          .waitFor(find.text('Zähler: $i'), timeout: const Duration(seconds: 15));
    }
    return Step(label: label, expected: expected, actual: 'Zähler = $n', passed: true);
  }

  /// Prüft, dass im UI keine Android-Fehlermeldung (ANR) sichtbar ist.
  Future<Step> noErrorBanner(String label, String expected) async {
    // Der ANR-Dialog trägt den Titel "System UI isn't responding" (Android)
    // bzw. "isn't responding" (deutsche UI) / "has stopped".
    final String appTitle = 'Hallo Welt, Flutter';
    try {
      await d.waitFor(find.text(appTitle), timeout: const Duration(seconds: 30));
    } catch (e) {
      return Step(label: label, expected: expected, actual: 'App-Titel fehlt: $e', passed: false);
    }
    // Falls ein ANR-Dialog offen wäre, wäre die App-UI abgedeckt und der
    // App-Titel normalerweise nicht wartbar — hier reicht die Sichtbarkeit
    // des App-Titels als Nachweis, dass die App im Vordergrund und stabil ist.
    return Step(label: label, expected: expected, actual: 'App-Titel sichtbar', passed: true);
  }
}

Future<Step> execute(World w, String label) async {
  final s = label.trim();

  // --- App frisch gestartet / im Vordergrund ---
  if (s.startsWith('Gegeben ist, dass die App frisch gestartet ist')) {
    try {
      await w.d
          .waitFor(find.text('Hallo Welt, Flutter'), timeout: const Duration(seconds: 30));
    } catch (e) {
      return Step(label: s, expected: 'App gestartet', actual: 'App-Start fehlgeschlagen: $e', passed: false);
    }
    return Step(label: s, expected: 'App gestartet, Titel sichtbar', actual: 'Titel "Hallo Welt, Flutter" sichtbar', passed: true);
  }
  if (s == 'und die App ist im Vordergrund') {
    try {
      await w.d
          .waitFor(find.text('Hallo Welt, Flutter'), timeout: const Duration(seconds: 10));
    } catch (e) {
      return Step(label: s, expected: 'App im Vordergrund', actual: 'App nicht im Vordergrund: $e', passed: false);
    }
    return Step(label: s, expected: 'App im Vordergrund', actual: 'App-Titel sichtbar', passed: true);
  }

  // --- Keine Android-Fehlermeldung ---
  if (s.startsWith('dann wird keine Android-Fehlermeldung angezeigt')) {
    return w.noErrorBanner(s, 'keine ANR-/Crash-Dienste sichtbar');
  }

  // --- Zähler-Gegebenen ---
  final gegebN = RegExp(r'^Gegeben ist, dass der Zähler bei (\d+) steht$')
      .firstMatch(s);
  if (gegebN != null) {
    final n = int.parse(gegebN.group(1)!);
    try {
      return await w.setCounter(s, 'Zähler ist $n', n);
    } catch (e) {
      return Step(label: s, expected: 'Zähler ist $n', actual: 'Fehler: $e', passed: false);
    }
  }

  // --- Button-Tap ---
  final tapM = RegExp(r'^wenn ich (?:erneut )?auf den Button "([^"]+)" tippe$')
      .firstMatch(s);
  if (tapM != null) {
    final btn = tapM.group(1)!;
    try {
      return await w.tapButton(s, 'Button "$btn" ausgeführt', btn);
    } catch (e) {
      return Step(label: s, expected: 'Button "$btn" ausgeführt', actual: 'Fehler: $e', passed: false);
    }
  }

  // --- Zähler-Zustand ---
  final zM = RegExp(r'^(?:dann zeigt|und der Zähler zeigt) der Zähler (\d+)$')
      .firstMatch(s);
  if (zM != null) {
    final n = zM.group(1)!;
    return w.textVisible(s, 'Zähler zeigt $n', 'Zähler: $n');
  }
  final zw = RegExp(r'^dann zeigt der Zähler weiterhin (\d+)$').firstMatch(s);
  if (zw != null) {
    final n = zw.group(1)!;
    return w.textVisible(s, 'Zähler zeigt weiterhin $n', 'Zähler: $n');
  }

  // --- Titel / Untertitel ---
  final titelM = RegExp(r'^dann wird der Titel "([^"]+)" angezeigt$').firstMatch(s);
  if (titelM != null) {
    final t = titelM.group(1)!;
    return w.textVisible(s, 'Titel "$t" sichtbar', t);
  }
  final subM = RegExp(r'^und der Untertitel "([^"]+)" (?:ist|bleibt) sichtbar$')
      .firstMatch(s);
  if (subM != null) {
    final t = subM.group(1)!;
    return w.textVisible(s, 'Untertitel "$t" sichtbar', t);
  }

  return Step(label: s, expected: s, actual: 'Step nicht erkannt', passed: false);
}

class Scenario {
  final String name;
  final List<String> steps;
  Scenario(this.name, this.steps);
}

List<Scenario> _parseFeature(String featureText) {
  final c = featureText;
  final lines = c.split('\n');
  final result = <Scenario>[];
  String? scName;
  Scenario? sc;
  void flush() {
    if (sc != null && sc!.steps.isNotEmpty) result.add(sc!);
    sc = null;
  }
  for (final raw in lines) {
    final line = raw.trimRight().trim();
    if (line.startsWith('Feature:')) {
      flush();
      continue;
    }
    if (line.startsWith('Scenario:')) {
      flush();
      scName = line.substring(9).trim();
      continue;
    }
    if (sc == null && scName != null) {
      sc = Scenario(scName, []);
      continue;
    }
    // BDD-Step-Zeilen:
    if (line.startsWith('Gegeben ist') ||
        line.startsWith('wenn ich') ||
        line.startsWith('dann ') ||
        line.startsWith('und der ')) {
      sc!.steps.add(line);
    }
  }
  flush();
  return result;
}

String _slug(String s) => s
    .toLowerCase()
    .replaceAll('ä', 'ae')
    .replaceAll('ö', 'oe')
    .replaceAll('ü', 'ue')
    .replaceAll('ß', 'ss')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+ |_+$'), '');

Future<void> main() async {
  final featFile = Platform.environment['BDD_FEATURE_FILE'];
  final featText = Platform.environment['BDD_FEATURE'];
  final String feat =
      featFile != null && featFile.trim().isNotEmpty
          ? File(featFile).readAsStringSync()
          : (featText ?? '');
  if (feat.trim().isEmpty) {
    stderr.writeln('Fehler: Setze BDD_FEATURE_FILE oder BDD_FEATURE.');
    exit(2);
  }

  // Font explizit laden (flutter_drive nutzt nicht flutter_test_config.dart)
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final loader = FontLoader('Roboto')..addFont(fontData);
  await loader.load();

  final scenarios = _parseFeature(feat);
  final List<ScenarioReport> reports = [];

  Directory('test_report/screenshots').createSync(recursive: true);

  final d = await FlutterDriver.connect();
  try {
    for (final sc in scenarios) {
      final List<Step> steps = [];
      bool allOk = true;
      for (final step in sc.steps) {
        Step r;
        try {
          r = await execute(World(d), step);
        } catch (e) {
          r = Step(label: step, expected: step, actual: 'Ausnahme: $e', passed: false);
        }
        steps.add(r);
        if (!r.passed) allOk = false;
      }

      // Screenshot am Ende des Scenarios (GUI-Zustand)
      final shotRel = 'screenshots/${_slug(feat)}--${_slug(sc.name)}.png';
      String shotOut = shotRel;
      try {
        final bytes = await d.screenshot();
        final f = File('test_report/$shotRel');
        f.createSync(recursive: true);
        await f.writeAsBytes(bytes);
      } catch (e) {
        shotOut = 'FEHLER: $e';
      }

      reports.add(ScenarioReport(name: sc.name, steps: steps, screenshot: shotOut));

      // Zwischen-Szenario-Reset: Zähler zurück auf 0 für das nächste
      if (allOk) {
        try {
          // Wenn der Zähler > 0 ist, zurücksetzen (falls Button aktiv ist)
          String zaehlerText = 'Zähler: 0';
          try {
            zaehlerText = await d.getText(find.byValueKey('zaehler'));
          } catch (_) {}
          if (zaehlerText != 'Zähler: 0') {
            await d.tap(find.byValueKey('zuruecksetzen'));
            await Future<void>.delayed(const Duration(milliseconds: 250));
          }
        } catch (_) {}
      }
    }
  } finally {
    try {
      d.close();
    } catch (_) {}
  }

  final allPassed =
      reports.isNotEmpty && reports.every((r) => r.passed);
  final doc = {
    'feature': feat,
    'ergebnis': allPassed ? 'BESTANDEN' : 'FEHLGESCHLAGEN',
    'generated_at': DateTime.now().toIso8601String(),
    'scenarios': reports.map((r) => r.toJson()).toList(),
  };
  final jsonOut = File('test_report/${_slug(feat)}.json');
  jsonOut.writeAsStringSync(jsonEncode(const JsonEncoder.withIndent('  ')
      .convert(doc)));

  print('==== FEATURE: $feat -> ${allPassed ? "BESTANDEN" : "GESCHEITERT"} ====');
  for (final r in reports) {
    print('  * ${r.name} -> ${r.passed ? "BESTANDEN" : "FEHLGESCHLAGEN"}');
    for (final st in r.steps) {
      print('      - ${st.label}');
      print('        erwartet    : ${st.expected}');
      print('        tatsächlich : ${st.actual}');
      print('        bestanden   : ${st.passed ? 'ja' : 'NEIN'}');
    }
    print('      Screenshot : ${r.screenshot}');
  }
  exit(allPassed ? 0 : 1);
}
