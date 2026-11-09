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
| `/wfd backup` | Die Kopie von vor dem letzten Update zurückholen (wird beim ersten Start nach einer neuen Version angelegt und nach 30 Tagen verworfen) |
| `/wfd cleanup` | Zeigt, welche Gefährten aus Schlachtfeldern oder Einmal-Gruppen entfernt würden. Mit `/wfd cleanup yes` werden sie entfernt |

Das Tagebuch öffnet sich in einem Fenster, dessen Größe du an der Ecke unten rechts ziehen kannst (Strg + Mausrad ändert die Größe von allem). Oben stehen Zurück und Vor, wo du gerade bist, die Suche, das „?“ mit allen Tasten und Befehlen und das Zahnrad für die Einstellungen. Links steht das Register mit den Gruppen; ein Klick zeigt ihre Teile, Neues hat eine kleine Zahl. Darunter stehen deine Lesezeichen. Ist das Fenster schmal, zeigt das Register nur die Symbole.

- **Start:** der Tag bis jetzt in Zahlen und ein paar Zeilen, die Aufgaben, Neues seit dem letzten Lesen, eine Erinnerung an diesen Tag in einem früheren Jahr, das Reiseziel des Tages, die Ehrung, die du fast hast, und wie weit deine Sammlungen sind
- **Tagebuch:** die Tage mit Kapiteln, Questbuch (offen, erledigt, abgebrochen; nach Gebiet oder neueste zuerst)
- **Chronik:** Meilensteine, Premieren, Rekorde, Stufen-Zeitstrahl, Jahrbuch, Galerie
- **Ziele & Ruhm:** Aufgaben (Tag, Woche, Monat, eigene Ziele zum Abhaken), Sammlung, Ehrenbuch (Titel und Vitrine über eigene Knöpfe)
- **Die Welt:** eine Weltkarte für die ganze Reise: Kontinent und Gebiet, mit Ebenen zum Zuschalten (Route, Kampfplätze, Personen, Gräber, Rastplätze, Fundorte, Kreaturen), dem Zeitraffer und daneben der Gebietschronik; Sehenswürdigkeiten; Dungeon-Berichte als Liste mit dem ganzen Bericht daneben (die ganze Gruppe, jeder Boss, jede Beute)
- **Jagd & Beute:** Bestiarium und Anglerbuch als Sammelkarten-Alben (nach Gebiet, Art oder Menge, mit Filtern wie Selten, Kenner oder Noch zu finden; der Steckbrief liegt rechts daneben), Gewässer und Angelzeug, Schätze (nach Platz, Qualität, Bestes je Platz, gerade getragen), Schicksal (jeder Tod nach Zeit, Gebiet, Gegner oder Stufe, die Erzfeinde mit Rache-Stand)
- **Leute & Geld:** Personen (nach A bis Z, Gebiet oder Gesprächen, Filter nach Rolle; die Visitenkarte liegt rechts daneben), Gefährten und Handelspartner, Reittiere (erster Ritt, Anzahl der Ritte), Ruf (wann welche Stufe erreicht wurde), Kassenbuch als Übersicht (Einnahmen, Ausgaben, Sparziel, Herkunft und Verbleib des Geldes, Geldbeutel über die Tage, jeder Tag)
- **Andenken:** Bibliothek, Familienbuch, Zeitkapsel
- **Einstellungen** (Zahnrad): Allgemein, Aussehen, Bedienung, Daten. Stil und Schriftgröße wechseln sofort; das Fenster lässt sich sperren.

Die Suche oben (oder Strg + F) durchsucht alles, mit Filtern nach Art (Tage, Personen, Kreaturen, Orte ...). Tage lassen sich zusätzlich eingrenzen: `z:Elwynn` (Gebiet), `lv:20-30` (Stufe), `d:30` (die letzten 30 Tage), auch zusammen mit Suchtext. Im Wochenrückblick schreibt „In den Chat“ eine Zeile ins Eingabefeld, abgeschickt wird sie erst mit Enter. Ein Klick auf das Eselsohr einer Buchseite setzt ein eigenes Lesezeichen (bis zu zwölf). Solange die Maus über dem Fenster ist, blättern Pfeiltasten und Mausrad im Buch; Pos1 führt zu Start, Ende zum heutigen Eintrag, die Rücktaste zurück.

Stile: Leder und Gold, Pergament, Modern, Starker Kontrast. Sprachen: Deutsch, Englisch, Französisch, Spanisch, Portugiesisch, Russisch, Koreanisch und Traditionelles Chinesisch.

## Daten

Gespeichert werden auch die Namen von Gruppenmitgliedern und Handelspartnern. Sie stehen nur in deinen eigenen Dateien und im Umzugs-Code, den du selbst erzeugst.

Alles bleibt auf deinem Rechner, in den SavedVariables des Spiels:
`WTF\Account\<Account>\<Server>\<Charakter>\SavedVariables\WoWForeverDiary.lua` (pro Charakter) und
`WTF\Account\<Account>\SavedVariables\WoWForeverDiary.lua` (Einstellungen, Familienbuch).

## Hinweis

WoW Forever Diary ist ein inoffizielles Addon von Fans. Es steht in keiner Verbindung zu Blizzard Entertainment und wird von dort nicht unterstützt. World of Warcraft ist eine Marke von Blizzard Entertainment, Inc.
