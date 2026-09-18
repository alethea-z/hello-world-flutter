# BDD Test Protocol Report

| Feature | Scenario | Status | Steps | Screenshot Path |
|---------|----------|--------|-------|-----------------|
| begruessung | App zeigt Begrüßung an | PASSED | `Gegeben ist, dass die App frisch gestartet ist, dann wird der Titel "Hallo Welt, Flutter" angezeigt, und der Untertitel "Eine Cross-Plattform-Funktionalität" ist sichtbar, und der Zähler zeigt 0` | `goldens/begruessung.png` |
| begruessung | App startet ohne Fehlerdialog | PASSED | `Gegeben ist, dass die App frisch gestartet ist, dann wird keine Android-Fehlermeldung angezeigt, und die App ist im Vordergrund` | `goldens/begruessung.png` |

| zaehlen | Zähler wird durch Tippen erhöht | PASSED | `Gegeben ist, dass der Zähler bei 0 steht, dann zeigt der Zähler 1, dann zeigt der Zähler 2, und der Untertitel "Eine Cross-Plattform-Funktionalität" bleibt sichtbar` | `goldens/zaehlen.png` |

| zuruecksetzen | Zurücksetzen setzt Zähler auf 0 zurück | PASSED | `Gegeben ist, dass der Zähler bei 2 steht, dann zeigt der Zähler 0` | `goldens/zuruecksetzen.png` |
| zuruecksetzen | Zurücksetzen ist deaktiviert, wenn Zähler 0 ist | PASSED | `Gegeben ist, dass der Zähler bei 0 steht, dann zeigt der Zähler weiterhin 0` | `goldens/zuruecksetzen.png` |

