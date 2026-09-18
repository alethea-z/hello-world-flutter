Feature: Begrüßung
  Als: Endnutzer, der die Hello-World-App frisch startet
  um: sofort zu erkennen, dass die App funktioniert

  Scenario: App zeigt Begrüßung an
    Gegeben ist, dass die App frisch gestartet ist
    dann wird der Titel "Hallo Welt, Flutter" angezeigt
    und der Untertitel "Eine Cross-Plattform-Funktionalität" ist sichtbar
    und der Zähler zeigt 0

  Scenario: App startet ohne Fehlerdialog
    Gegeben ist, dass die App frisch gestartet ist
    dann wird keine Android-Fehlermeldung angezeigt
    und die App ist im Vordergrund

Feature: Zählen
  Als: Endnutzer
  um: den Zähler über die GUI zu steuern

  Scenario: Zähler wird durch Tippen erhöht
    Gegeben ist, dass der Zähler bei 0 steht
    wenn ich auf den Button "Zählen" tippe
    dann zeigt der Zähler 1
    wenn ich erneut auf den Button "Zählen" tippe
    dann zeigt der Zähler 2
    und der Untertitel "Eine Cross-Plattform-Funktionalität" bleibt sichtbar

Feature: Zurücksetzen
  Als: Endnutzer
  um: den Zähler auf den Ausgangszustand zurückzusetzen

  Scenario: Zurücksetzen setzt Zähler auf 0 zurück
    Gegeben ist, dass der Zähler bei 2 steht
    wenn ich auf den Button "Zurücksetzen" tippe
    dann zeigt der Zähler 0

  Scenario: Zurücksetzen ist deaktiviert, wenn Zähler 0 ist
    Gegeben ist, dass der Zähler bei 0 steht
    wenn ich auf den Button "Zurücksetzen" tippe
    dann zeigt der Zähler weiterhin 0
