# WoW Forever Diary

Ein Reisetagebuch-Addon für WoW Classic Era. Ab dem ersten Login schreibt es mit, was deinem Charakter passiert:
Gespräche, Quests, Kills, Seltene und Bosse, Tode, Gold nach Herkunft, Beute, Stufen, Zonen, Dungeons, Berufe,
Flüge, Fußspuren, Strecke und Spielzeit. Aus jedem Tag wird ein kurzer Eintrag in ganz normalen Sätzen.

## Installation

Den Ordner `WoWForeverDiary` nach `World of Warcraft\_classic_era_\Interface\AddOns\` kopieren und das Spiel starten
(oder im Spiel `/reload`, falls es schon läuft).

## Bedienung

| Befehl | Wirkung |
|---|---|
| `/wfd` (oder `/diary`, `/tagebuch`) | Tagebuch öffnen oder schließen, auch über den Minimap-Button |
| `/wfd bestiarium`, `/wfd ehrenbuch`, `/wfd kassenbuch`, `/wfd einstellungen` ... | Das Buch gleich an diesem Teil öffnen (englisch geht auch: `bestiary`, `honour`, `ledger`, `settings`; `/wfd schicksal` oder `fate` für die Tode) |
| `/wfd 12` | Das Buch am Tag 12 öffnen |
| `/wfd demo` | Beispieldaten nur im Speicher, zum Anschauen der Oberfläche |
| `/wfd shot` | Screenshots bei Meilensteinen an oder aus |
| `/wfd minimap` | Minimap-Button ein- oder ausblenden |
| `/wfd recap` | Wochenrückblick anzeigen |
| `/wfd help` | Befehle im Chat auflisten |
| `/wfd companion` | Begleitfenster neben dem Spiel ein- oder ausblenden |
| `/wfd erinnerung` (oder `memory`) | Die Erinnerung von heute noch einmal als Notiz zeigen |
| `/wfd export`, `/wfd import` | Umzugs-Code für einen anderen Rechner erstellen oder einlesen |
| `/wfd restore` | Ein beiseitegelegtes Tagebuch zurückholen |

Im Buch, in Gruppen; jede Gruppe hat einen Reiter, der eine Übersicht ihrer Teile öffnet. Zeigst du auf den Reiter, klappt eine Liste seiner Teile auf:

- **Vorne:** Inhalt, Heute (der Tag bis jetzt, eine Erinnerung an diesen Tag in einem früheren Jahr, Neues seit dem letzten Lesen, nächste Ziele), Tagebuch mit Kapiteln, Questbuch
- **Ziele & Ruhm:** Aufgaben (Tag, Woche, Monat, eigene Ziele), Sammelalbum mit nächsten Zielen, Ehrenbuch
- **Chronik:** Meilensteine, Premieren, Rekorde, Stufen-Zeitstrahl, Galerie, Jahrbuch
- **Die Welt:** Atlas (mit Zeitraffer: der Abspielknopf unter dem „?“ der Kontinentkarte lässt die Reise Tag für Tag wachsen), Karten mit Gebietschronik, Sehenswürdigkeiten, Fundorte, Dungeon-Berichte
- **Jagd & Beute:** Bestiarium mit Steckbriefen, „Fast geschafft“ und Jagdkarte, Schicksal (jeder Tod auf der Karte, wo und gegen wen am häufigsten), Erzfeinde, Anglerbuch, Schätze mit Ausrüstungspuppe
- **Leute & Geld:** Personen, Gefährten, Kassenbuch mit Sparziel
- **Andenken:** Bibliothek, Familienbuch, Zeitkapsel
- **Einstellungen:** eigener Reiter ganz unten, in vier Seiten (Allgemein, Aussehen, Bedienung mit den Tasten, Daten) mit Stil, Schriftgröße und Sprache

Die Lupe oben am Buchrücken (oder Strg + F) durchsucht alles, das „?“ darunter zeigt die Einführung. Ein Klick auf
die Seitenzahl springt zu einer Seite, ein Klick auf das Eselsohr setzt ein eigenes Lesezeichen (bis zu zwölf). Eine Zeile oben auf jeder Seite zeigt, wo du bist. Solange die Maus über dem Buch ist, blättern Pfeiltasten und Mausrad; Pos1 führt zum Inhalt, Ende zu heute,
die Rücktaste zurück.

Stile: Leder und Gold, Pergament, Modern, Starker Kontrast. Sprachen: Deutsch, Englisch, Französisch, Spanisch, Portugiesisch, Russisch, Koreanisch und Traditionelles Chinesisch.

## Daten

Gespeichert werden auch die Namen von Gruppenmitgliedern und Handelspartnern. Sie stehen nur in deinen eigenen Dateien und im Umzugs-Code, den du selbst erzeugst.

Alles bleibt auf deinem Rechner, in den SavedVariables des Spiels:
`WTF\Account\<Account>\<Server>\<Charakter>\SavedVariables\WoWForeverDiary.lua` (pro Charakter) und
`WTF\Account\<Account>\SavedVariables\WoWForeverDiary.lua` (Einstellungen, Familienbuch).

## Hinweis

WoW Forever Diary ist ein inoffizielles Addon von Fans. Es steht in keiner Verbindung zu Blizzard Entertainment und wird von dort nicht unterstützt. World of Warcraft ist eine Marke von Blizzard Entertainment, Inc.
