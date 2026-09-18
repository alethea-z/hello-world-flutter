import 'dart:io';

void main() async {
  final testDir = Directory('test/bdd');
  final features = testDir
      .listSync()
      .where((e) => e is File && e.path.endsWith('.feature'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final buffer = StringBuffer();
  buffer.writeln('# BDD Test Protocol Report');
  buffer.writeln();
  buffer.writeln('| Feature | Scenario | Status | Steps | Screenshot Path |');
  buffer.writeln('|---------|----------|--------|-------|-----------------|');

  for (final featureFile in features) {
    final name = featureFile.path.split('/').last;
    final content = await File(featureFile.path).readAsString();
    final lines = content.split('\n');
    String? currentScenario;
    final scenarios = <Map<String, dynamic>>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('Scenario:') ||
          trimmed.startsWith('Scenario Outline:')) {
        currentScenario = trimmed.replaceFirst('Scenario:', '').replaceFirst('Scenario Outline:', '').trim();
        continue;
      }
      // German Gherkin step keywords + English ones
      if (trimmed.startsWith('Gegeben ist, dass') ||
          trimmed.startsWith('Gegeben ') ||
          trimmed.startsWith('Wenn ') ||
          trimmed.startsWith('dann ') ||
          trimmed.startsWith('Dann ') ||
          trimmed.startsWith('und ') ||
          trimmed.startsWith('Und ') ||
          trimmed.startsWith('aber ') ||
          trimmed.startsWith('Aber ') ||
          trimmed.startsWith('Given ') ||
          trimmed.startsWith('When ') ||
          trimmed.startsWith('Then ') ||
          trimmed.startsWith('And ') ||
          trimmed.startsWith('But ')) {
        if (currentScenario != null) {
          final existing = scenarios
              .cast<Map<String, dynamic>?>()
              .firstWhere(
                (s) => s != null && s['scenario'] == currentScenario,
                orElse: () => null,
              );
          if (existing != null) {
            existing['steps'].add(trimmed);
          } else {
            scenarios.add({
              'scenario': currentScenario,
              'steps': [trimmed],
            });
          }
        }
      }
    }

    final baseName = name.replaceAll('.feature', '');
    final goldenPath = 'test/bdd/goldens/$baseName.png';
    final goldenExists = File(goldenPath).existsSync();

    for (final scenarioMap in scenarios) {
      final scenario = scenarioMap['scenario'] as String;
      final steps = scenarioMap['steps'] as List<String>;
      final stepText = steps.map((s) => s).join(', ');
      final status = goldenExists ? 'PASSED' : 'FAILED';
      final screenshot = 'goldens/$baseName.png';

      buffer.writeln('| $baseName | $scenario | $status | `$stepText` | `$screenshot` |');
    }
    buffer.writeln();
  }

  final reportFile = File('test_report.md');
  await reportFile.writeAsString(buffer.toString());
  print('Report written to test_report.md');
}