import 'package:flutter/material.dart';

void main() {
  runApp(const HalloWelt());
}

/// Root state of the hello-world-flutter app.
///
/// UI-Regeln (BDD):
/// * Feature 1: Begrüßung — Titel "Hallo Welt, Flutter" ist ab
///   App-Start sichtbar; Subtitel "Eine Cross-Plattform-Funktionalität" ist
///   ebenfalls sichtbar.
/// * Feature 2: Zählen — der Hauptzähler-Button inkrementiert bei
///   jedem Klick um eins. Der Counter-Text spiegelt den aktuellen Wert.
/// * Feature 3: Zurücksetzen — der Zurücksetzen-Button ist nur aktiv,
///   wenn Zähler > 0; ein Klick setzt ihn auf null zurück.
class HalloWelt extends StatefulWidget {
  const HalloWelt({super.key});

  @override
  State<HalloWelt> createState() => _HalloWeltState();
}

class _HalloWeltState extends State<HalloWelt> {
  int _zaehler = 0;

  void _inkrement() {
    setState(() => _zaehler += 1);
  }

  void _zuruecksetzen() {
    setState(() => _zaehler = 0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: const ValueKey('root'),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blue.shade100,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hallo Welt, Flutter',
                  key: ValueKey('titel'),
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Eine Cross-Plattform-Funktionalität',
                  key: ValueKey('subtitel'),
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  'Zähler: $_zaehler',
                  key: const ValueKey('zaehler'),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      key: const ValueKey('zaehlen'),
                      onPressed: _inkrement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(160, 56),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Zählen'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      key: const ValueKey('zuruecksetzen'),
                      onPressed: _zaehler > 0 ? _zuruecksetzen : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _zaehler > 0
                                ? Colors.red
                                : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(160, 56),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Zurücksetzen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
