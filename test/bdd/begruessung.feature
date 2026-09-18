Feature: Begrüßung
  Als Endnutzer
  will ich die Hello-World-App direkt erkennen
  damit ich sehe, dass die App funktioniert

  Scenario: App zeigt Begrüßung an
    Gegeben ist, dass die App frisch gestartet ist
    dann wird der Titel "Hallo Welt, Flutter" angezeigt
    und der Untertitel "Eine Cross-Plattform-Funktionalität" ist sichtbar
    und der Zähler zeigt 0

  Scenario: App startet ohne Fehlerdialog
    Gegeben ist, dass die App frisch gestartet ist
    dann wird keine Android-Fehlermeldung angezeigt
    und die App ist im Vordergrund
