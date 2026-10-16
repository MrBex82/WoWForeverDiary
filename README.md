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
| `/wfd demo` | Beispieldaten nur im Speicher, zum Anschauen der Oberfläche |
| `/wfd shot` | Screenshots bei Meilensteinen an oder aus |
| `/wfd minimap` | Minimap-Button ein- oder ausblenden |
| `/wfd recap` | Wochenrückblick anzeigen |
| `/wfd help` | Befehle im Chat auflisten |
| `/wfd companion` | Begleitfenster neben dem Spiel ein- oder ausblenden |
| `/wfd export`, `/wfd import` | Umzugs-Code für einen anderen Rechner erstellen oder einlesen |
| `/wfd restore` | Ein beiseitegelegtes Tagebuch zurückholen |

Im Buch, in Gruppen mit eigener Reiterfarbe:

- **Vorne:** Inhalt, Tagebuch mit Kapiteln, Questbuch
- **Ziele & Ruhm:** Sammelalbum mit nächsten Zielen, Ehrenbuch
- **Chronik:** Meilensteine, Erste Male, Rekorde, Stufen-Zeitstrahl, Galerie
- **Die Welt:** Atlas, Karten mit Gebietschronik, Sehenswürdigkeiten, Fundorte, Dungeon-Berichte
- **Jagd & Beute:** Bestiarium mit Steckbriefen, „Fast geschafft“ und Jagdkarte, Erzfeinde, Schätze mit Ausrüstungspuppe
- **Menschen & Haushalt:** Personen, Gefährten, Kassenbuch
- **Andenken:** Familienbuch, Zeitkapsel, Notizen des Schreibers (Einstellungen)

Die Lupe oben am Buchrücken (oder Strg + F) durchsucht alles. Strg-Klick auf eine Seitenzahl setzt ein eigenes
Lesezeichen. Solange die Maus über dem Buch ist, blättern Pfeiltasten und Mausrad; Pos1 führt zum Inhalt, Ende zu heute,
die Rücktaste zurück.

Sprachen: Deutsch, Englisch, Französisch, Spanisch, Portugiesisch, Russisch, Koreanisch und Traditionelles Chinesisch.

## Daten

Alles bleibt auf deinem Rechner, in den SavedVariables des Spiels:
`WTF\Account\<Account>\<Server>\<Charakter>\SavedVariables\WoWForeverDiary.lua` (pro Charakter) und
`WTF\Account\<Account>\SavedVariables\WoWForeverDiary.lua` (Einstellungen, Familienbuch).
