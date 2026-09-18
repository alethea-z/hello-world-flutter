Feature: Zurücksetzen
  Als Endnutzer
  will ich den Zähler zurücksetzen
  damit ich wieder beim Ausgangszustand beginne

  Scenario: Zurücksetzen setzt Zähler auf 0 zurück
    Gegeben ist, dass der Zähler bei 2 steht
    wenn ich auf den Button "Zurücksetzen" tippe
    dann zeigt der Zähler 0

  Scenario: Zurücksetzen ist deaktiviert, wenn Zähler 0 ist
    Gegeben ist, dass der Zähler bei 0 steht
    wenn ich auf den Button "Zurücksetzen" tippe
    dann zeigt der Zähler weiterhin 0
