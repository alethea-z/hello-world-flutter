Feature: Zählen
  Als Endnutzer
  will ich den Zähler über die GUI steuern
  damit ich Eingaben visuell prüfen kann

  Scenario: Zähler wird durch Tippen erhöht
    Gegeben ist, dass der Zähler bei 0 steht
    wenn ich auf den Button "Zählen" tippe
    dann zeigt der Zähler 1
    wenn ich erneut auf den Button "Zählen" tippe
    dann zeigt der Zähler 2
    und der Untertitel "Eine Cross-Plattform-Funktionalität" bleibt sichtbar
