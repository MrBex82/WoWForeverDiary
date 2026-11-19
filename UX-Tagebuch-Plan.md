# Plan: Im Tagebuch bleiben (UX und GUI, Teil für Teil)

Stand 19.11.2026, `main` ab `8280c5d`. Grundlage: der Code aller Ansichten (`UI/Views`, `UI/Design`, `UI/Shell`), die
Aufnahmen aus dem Spiel von heute (Start, Tagebuch, Listen, Einstellungen, Rekorde, Weltkarte, Gruppen, Notizbuch,
Meldungen) und die früheren Pläne (`UX-Review.md`, `UX-Umbau-Plan.md`, `UX-Plan-Opus.md`, `Buch-und-Fenster-Plan.md`).

## Ausgangslage

Seit heute liegt alles in einem aufgeschlagenen Buch (Falz, Blätter, Umblättern, rote Tinte im Pergament).
Der **Rahmen** ist also ein Buch. Der **Inhalt** fühlt sich an vielen Stellen aber noch wie eine App an:

- **Kennzahl-Kacheln** oben auf Start und in jeder Liste (Kills, Quests, km, Gold, "144", "15/49", ...).
- **Filterknöpfe, Sortier-Menü und Suchfeld** über jeder Liste, wie in einer Datenbank.
- **Kopfzeile wie ein Browser** mit Zurück, Vor, Pfad, Suchfeld und runden Symbolknöpfen.
- **Register wie eine Seitenleiste** einer App (Symbole, Zähler, Einklappknopf).
- **Karten auf Karten**: Start und Gruppenseiten sind Raster aus Kästen, die auf der Buchseite liegen.
- **Sprache der Daten**: "Kills", "Quests", "0,1 / 2", "Selten und Bosse", Sortiernamen.
- **Einstellungen** wie ein Systemdialog (Abschnitte, Schalter, Segmentknöpfe).

Das Tagebuch selbst (ein Tag als Seite mit großem Anfangsbuchstaben und erzähltem Text) zeigt, wie es überall sein könnte.

## Leitsätze (gelten für jeden Teil)

1. **Erzählen vor Zählen.** Jede Seite beginnt mit ein, zwei Sätzen in der Stimme des Tagebuchs (der Erzähler in
   `Modules/Narrator.lua` kann das schon). Zahlen stehen danach oder am Rand, nie als Erstes.
2. **Zahlen gehören an den Rand.** Kennzahlen werden zu **Randnotizen** (kleine Schrift in der Marginalie neben dem
   Text) oder zu einer Zeile "in Zahlen" am Seitenfuß. Keine Kachelreihen mehr.
3. **Bedienelemente sehen aus wie Buchelemente.**
   - Filter werden zu **Registerzungen**: Wörter in roter Tinte über der Liste, das gewählte unterstrichen.
   - Knöpfe werden zu **Tintenlinks** ("weiterlesen", "alle Aufgaben").
   - Nur wo etwas geändert wird, bleibt ein Knopf.
4. **Seiten haben Kopf und Fuß wie ein gedrucktes Buch.** Oben ein **Kolumnentitel**: links die Gruppe, rechts der
   Teil. Unten die **Seitenzahl** oder Stelle im Teil, dazu der Zierstrich.
5. **Daten sind Tagebuchdaten.** "Tag 15, Donnerstag, 19. November", nicht "19.11.". Uhrzeiten nur, wo sie erzählen
   ("am Vormittag").
6. **Leere Seiten sind Vorfreude.** Ein Satz, was hier einmal stehen wird, kein "0 / 0".
7. **Nichts geht verloren.** Jede Funktion (Filter, Sortierung, Suche, Lesezeichen, Zurück) bleibt erreichbar, nur im
   Gewand des Buches. Barrierefreiheit bleibt: Schrift bis 150 %, Kontrast, `/wfd layoutcheck` ohne Funde.

## Was es dafür braucht (Bausteine im Kit)

| Baustein | Zweck | Ersetzt |
|---|---|---|
| `K.RunningHead` | Kolumnentitel oben auf beiden Seiten | Titel in der Kopfzeile, doppelte Überschriften |
| `K.Folio` | Seitenzahl oder "12 von 340" unten, mit Zierstrich | den Zierstrich allein |
| `K.Margin` | Randnotiz: kleine Zahl mit Wort neben einer Zeile oder einem Absatz | Kennzahl-Kacheln |
| `K.InkLink` | Tintenlink, unterstrichen beim Darüberfahren | `K.Button "ghost"` in Texten |
| `K.Tabs` (Registerzungen) | Filter als Wörter in roter Tinte, Überlauf in ein Menü | Chip-Reihen |
| `K.Lead` | Einleitungssatz einer Seite aus dem Erzähler, mit Initiale | Untertitel und Zahlenreihen |

**Recherche zur Schrift:** Ein Addon darf eigene TTF-Dateien mitbringen und über
`SetFont("Interface\\AddOns\\WoWForeverDiary\\Media\\...")` nutzen. EB Garamond (OFL-Lizenz) hat Latein und
Kyrillisch, passt also zu Deutsch, Englisch, Französisch, Spanisch, Portugiesisch und Russisch. Koreanisch und
Chinesisch bleiben bei den Schriften des Spiels. Die Lizenzdatei muss mitgeliefert werden, das Addon wird dadurch
etwa 0,5 MB größer. Entschieden: keine eigene Schrift (siehe Entscheidungen).

## Teil für Teil

### Rahmen: Kopfzeile und Register
- **Befund:** Die Kopfzeile ist ein Browser (Zurück, Vor, Pfad, Suchfeld, vier Symbolknöpfe). Das Register ist eine
  App-Seitenleiste mit Zählern, die Reiter am Buchrand waren deplatziert und sind wieder weg.
- **Vorschlag:**
  - Die Kopfzeile wird zum oberen Buchrand: links Zurück und Vor als Pfeile im Stil des Buchrands, in der Mitte
    nichts, weil der Kolumnentitel auf der Seite steht.
  - Rechts kleiner Platz für Stichwort (Suche), Lesezeichen und Einstellungen.
  - Das Register wird ein **Inhaltsverzeichnis auf dem Vorsatz**: Gruppennamen in MORPHEUS, Teile darunter mit
    Leaderpunkten ("Bestiarium ........ 34"). "Neu" steht als kleines rotes Wort statt als Zahl im Kasten.
  - Schmal bleibt es das Zeichenregister.

### Start ("Heute")
- **Befund:** Vier Kennzahl-Kacheln, ein Raster aus acht Kästen, die "Sammlungen" als Zahlenwand.
- **Vorschlag:** Start wird **die heutige Doppelseite des Tagebuchs**.
  - **Links:** der Tag, wie er bisher erzählt ist (Initiale, Text), darunter "weiterlesen".
  - **Rechts:**
    - "Vorgenommen für heute" (Aufgaben mit Ringen) und "Neu, seit ich zuletzt las" als Liste mit Tintenlinks.
    - "Reiseziel" als ein Satz.
    - "Fast geschafft" als zwei Zeilen mit dünnem Strich.
  - **Am Rand:** Kills, Quests, Weg und Gold als Randnotizen.
  - Die Sammlungen ziehen auf die Gruppenseiten.

### Tagebuch
- **Befund:** Schon nah am Ziel. Die Chips unter dem Datum ("Sturmwind", "+2", "3") und die Knopfleiste unten wirken
  wie eine App.
- **Vorschlag:**
  - Die Chips werden zu einer Randnotiz-Spalte.
  - Fuß mit "Tag davor" und "Tag danach" als Tintenlinks links und rechts, Seitenzahl "Tag 9 von 15" in der Mitte.
  - Kapitelverzeichnis links mit Leaderpunkten.
  - Andenken und Bilder als "eingeklebt", zum Beispiel mit leichter Drehung und Klebeecken in den Stilen des Buches.

### Notizbuch
- **Befund:** Neu und funktional. Die Seitenliste ist ein App-Listenfeld.
- **Vorschlag:**
  - Linke Seite als **Inhaltsverzeichnis** des Notizbuchs (Titel, Leaderpunkte, Datum).
  - Rechte Seite mit **Linien** wie liniertes Papier, die Zeilennummern bleiben in der Randspalte.
  - "Neue Seite" als Tintenlink.

### Listen (Bestiarium, Leute, Questbuch, Anglerbuch, Schätze, Sehenswürdigkeiten, Gewässer, Bibliothek, Familienbuch, Ruf, Reittiere, Gefährten)
- **Befund:** Kachelreihe, Chip-Reihe, Suchfeld, Sortiermenü, dann eine Tabelle. Der Bericht rechts ist schon eine
  Buchseite.
- **Vorschlag:**
  - Oben ein Einleitungssatz ("34 Arten habe ich bisher erlegt, die meisten im Wald von Elwynn.").
  - Darunter Registerzungen statt Chips.
  - Suche und Sortierung als ein Tintenlink "ordnen und suchen", der eine kleine Zeile aufklappt.
  - Die Einträge als **Verzeichnis** mit Leaderpunkten statt Tabellenzeilen.
  - Die Kennzahlen als Randnotizen im Bericht.
- **Reihenfolge:** zuerst `Collection.lua`, weil davon alle Listen profitieren. Danach je Liste nur noch Texte.

### Chronik (Meilensteine, Premieren, Rekorde, Stufen-Zeitstrahl, Jahrbuch, Wochenrückblick, Galerie)
- **Befund:** Die Rekorde sind eine Liste mit Symbolen wie eine Statistikseite. Die anderen Teile sind schon
  Berichte auf einer Seite.
- **Vorschlag:**
  - Rekorde als **"Bestenliste meines Lebens"** in Sätzen ("Der reichste Tag war Tag 15, mit 2 Gold.").
  - Zeitstrahl als handgezeichnete Linie mit Daten am Rand.
  - Galerie als **Album** mit eingeklebten Bildern und Bildunterschriften.

### Ziele und Ruhm (Aufgaben, Sammelalbum, Ehrenbuch)
- **Befund:** Fortschrittsbalken, Stufen-Rauten, Zahlen.
- **Vorschlag:**
  - Aufgaben als **Vorsätze** ("Was ich mir vorgenommen habe"), mit Ringen.
  - Ehrenbuch als Urkunden, die nach Stufe gesiegelt werden.
  - Balken bleiben, aber dünn wie ein Tintenstrich.

### Welt (Weltkarte, Sehenswürdigkeiten, Dungeonberichte)
- **Befund:** Die Karte auf der linken Seite ist schon ein Atlas. Die Entdecker-Liste rechts ist eine Checkliste.
- **Vorschlag:**
  - Rechts ein **Reisebericht** des Gebiets (erster Besuch, Zeit dort, was ich fand).
  - Darunter die Orte als Verzeichnis, unentdeckte grau.

### Jagd und Beute, Leute und Geld, Andenken
- Gleich wie bei den Listen. Dazu:
  - **Kassenbuch** als echtes Kassenbuch (Spalten "Einnahmen" und "Ausgaben" mit Linien und roter Summe).
  - **Schicksal** als Nachruf-Seite (passend zu "In Memoriam").

### Einstellungen und Hilfe
- **Befund:** Systemdialog.
- **Vorschlag:**
  - Einstellungen als **Vorsatzblatt** "Dieses Buch gehört ..." mit den Wahlmöglichkeiten als Sätze, zum Beispiel
    "Ich schreibe in [mittlerer] Schrift".
  - Die Schalter bleiben, sehen aber aus wie Ankreuzringe.
  - Hilfe als **Gebrauchsanweisung** am Ende des Buches.

### Meldungen und Begleiter
- **Befund:** Meldungen sind kleine Karten auf dem Spielbildschirm, der Begleiter ein Fenster.
- **Vorschlag:**
  - Meldungen als **Zettel**, der kurz ins Bild gesteckt wird, mit einem Satz in Tagebuchstimme.
  - Der Begleiter als **aufgeklapptes Notizheft** im kleinen Format.
  - Beides ist Feinschliff am Schluss.

## Rundgang 19.11.2026 (Phase 0, Leder, Cylinsis, 100 %)

28 Aufnahmen liegen außerhalb des Repos (sie zeigen Charakter- und Realmnamen) in
`D:/Git/WoW_Forever_Diary_Backup/aufnahmen-vor-tagebuch-20261119/`. Pergament und Modern fehlen noch.

**Querschnitt (gilt für viele Teile):**
- **Kachelreihe oben:** in 17 von 28 Teilen (Start, Questbuch, Meilensteine, Premieren, Stufen, Jahrbuch,
  Wochenrückblick, Aufgaben, Ehrenbuch, Dungeons, Bestiarium, Anglerbuch, Schätze, Schicksal, Personen, Ruf, Bibliothek).
- **Filterknöpfe:** in 12 Teilen, oft fünf bis sieben Stück. Dazu überall ein Namensfilter und ein Sortiermenü.
- **Noch nicht im Buch:** Aufgaben, Sammelalbum und Kassenbuch liegen direkt auf dem Leder, ohne Buchseite.
- **Stimme gemischt:** Das Tagebuch spricht in der Ich-Form ("Das merke ich mir"), andere Teile mit "du".
  Beispiele: In Memoriam "Noch hat dich niemand erwischt", Ruf "hilf ihr", Familienbuch "(du)".
  Die Zeitkapsel schreibt "Liebes Ich". Für ein Tagebuch gehört alles in die Ich-Form.
- **Verzeichnisse als Tabellen:** Symbol, Titel, graue Unterzeile, rechts Zahl oder "Tag 3". So sehen Questbuch,
  Meilensteine, Premieren, Schätze, Schicksal, Personen, Bibliothek und Dungeons aus.
- **Leere Seiten:** In Memoriam ist eine ganze Seite mit einem Satz, Ruf ein Hinweis mitten auf leerer Fläche,
  die Aufgaben-Seite zur Hälfte leer.

**Je Teil (zusätzlich zu "Teil für Teil" oben):**

| Teil | Befund | Idee |
|---|---|---|
| Start | 4 Kacheln, Raster aus 8 Kästen | heutige Doppelseite (siehe oben) |
| Tagebuch | gut; Chips unter dem Datum, Knopffuß | Randnotizen, Tintenlinks |
| Questbuch | Kacheln, 4 Filter, Tabelle mit XP | "Meine Aufträge" nach Gebiet als Verzeichnis, XP an den Rand |
| In Memoriam | leere Seite, "dich" | Ich-Form, Gedenkseite mit Linie für die Namen |
| Meilensteine | Protokoll mit Uhrzeiten, viele "Getötet von" | pro Tag als kleine Liste in Sätzen, Tode gebündelt |
| Premieren | Tabelle | "Zum ersten Mal ..." als Satzliste |
| Rekordbuch | Zahlenliste | Sätze ("Der reichste Tag war Tag 3.") |
| Stufen-Zeitstrahl | Balken | Linie mit Daten am Rand, wie gezeichnet |
| Jahrbuch | "Ein Reisejahr in Zahlen", 6 Kacheln | Jahresbrief mit Zahlen am Rand |
| Wochenrückblick | Kacheln und Listen | Wochenbrief, Listen als Fließtext |
| Aufgaben | nicht im Buch, Karten, halb leer | Vorsätze auf einer Seite im Buch |
| Sammelalbum | nicht im Buch, Fortschrittsbalken | Inhaltsverzeichnis der Sammlungen mit Strichen |
| Ehrenbuch | 7 Kacheln, Knöpfe "Titel" und "Vitrine" je Zeile | Urkunden, Aktionen im Bericht rechts statt in jeder Zeile |
| Weltkarte | gut (Atlas) | Reisebericht rechts statt Checkliste |
| Sehenswürdigkeiten | Tabelle mit Datum und Uhrzeit | Verzeichnis nach Gebiet, Datum als Tagebuchdatum |
| Dungeon-Berichte | Tabelle; **Fehler:** "Halle der Thanen" sechsmal mit 176 Stunden und 0 Bossen | Fehler zuerst beheben, dann Berichte als Einträge |
| Bestiarium | Sammelkarten mit "#001 St. 2" | Karten bleiben (passt zum Sammelalbum), Nummern kleiner, Kacheln weg |
| Anglerbuch | Sammelkarten | wie Bestiarium |
| Schätze | Tabelle nach Platz | "Was ich trage und fand" nach Platz, Farbe der Seltenheit bleibt |
| Schicksal | Liste der Tode | Nachrufseite, gebündelt nach Feind |
| Personen | Kacheln, 5 Filter, Tabelle | Adressbuch: Buchstaben als Registerzungen am Rand |
| Ruf | leer: Hinweis in der Mitte | Ich-Form, Satz oben auf der Seite |
| Kassenbuch | nicht im Buch, Kacheln und Diagramm | Kassenbuch mit Spalten und Linien, Kurve als Skizze |
| Bibliothek | Tabelle | Bücherregal als Verzeichnis |
| Familienbuch | schon Buchseite | Stammbaum-Optik, Ich-Form |
| Zeitkapsel | schon Buchseite, Knopf "Brief schreiben" | Brief als Tintenlink, Briefe als Umschläge |
| Einstellungen | Schalter wie im System | Vorsatzblatt, Ankreuzringe (in Leder und Pergament) |
| Hilfe | Tabelle der Tasten | Gebrauchsanweisung mit Leaderpunkten |

**Neue Punkte für die Phasen:**
- **Phase 2a (vor allem anderen):** Aufgaben, Sammelalbum und Kassenbuch ins Buch legen (`K.BookHost`).
- **Phase 2b:** Ich-Form in allen Texten, die zum Spieler sprechen (alle neun Sprachen).
- **Fehler:** doppelte Dungeon-Berichte mit 176 Stunden prüfen (`Modules`, Erfassung der Läufe), eigener Commit.

## Phasen (je ein Commit, danach Spieltest in Leder, Pergament und Modern, bei 100 und 150 %)

0. **Rundgang:**
   - Aufnahmen aller 33 Teile auf einem Charakter mit Daten (Cylinsis) in drei Stilen, abgelegt unter
     `screenshots/vor-tagebuch/`.
   - Ein Befundblatt je Teil ergänzt diesen Plan.
   - Heute nur teilweise geschafft, der Charakter wurde mitten im Rundgang ausgeloggt.
1. **Bausteine:** `K.RunningHead`, `K.Folio`, `K.Margin`, `K.InkLink`, `K.Tabs`, `K.Lead`. Keine eigene Schrift.
2. **Rahmen:** Kopfzeile und Register.
3. **Start** als heutige Doppelseite.
4. **Tagebuch und Notizbuch.**
5. **Listen** über `Collection.lua`, dann die Texte jeder Liste.
6. **Chronik.**
7. **Ziele und Ruhm.**
8. **Welt.**
9. **Kassenbuch, Schicksal, Andenken.**
10. **Einstellungen und Hilfe.**
11. **Meldungen und Begleiter.**
12. **Abschluss:**
    - `/wfd layoutcheck` bei 100, 120 und 150 % in allen Stilen.
    - `tools/contrast.py`, `ui_sim`.
    - Aufnahmen vorher und nachher, Changelog.

Jede Phase ist einzeln spielbar. Was nicht gefällt, wird vor der nächsten Phase geändert. Neue Texte kommen in allen
neun Sprachen und ohne Gedankenstriche.

## Entscheidungen (19.11.2026)

1. **Schrift:** keine eigene Buchschrift, es bleiben die Schriften des Spiels (FRIZQT, MORPHEUS, SKURRI).
   Das Buchgefühl kommt aus Satz, Kolumnentiteln, Randnotizen, Initialen und Tinte.
2. **Stile:** Leder und Pergament werden voll zum Buch (Registerzungen, Randnotizen, Tintenlinks, eingeklebte Bilder).
   Modern und Starker Kontrast bleiben **sachlicher**: Sie bekommen die neue Ordnung (Einleitungssatz, Zahlen am Rand,
   Kolumnentitel), aber Knöpfe und Filter bleiben dort als klare Knöpfe. Jeder Baustein fragt dafür `CLASSIC[THEME]`.
3. **Kennzahlen:** an den Rand, als Randnotizen. Keine Kachelreihen mehr.
4. **Zurück und Vor:** bleiben als sichtbare Pfeile, nur im Stil des Buchrands.

## Quellen der Recherche

- Eigene Schriften in Addons: https://us.forums.blizzard.com/en/wow/t/how-to-add-a-font-to-my-addon/1041281,
  https://www.curseforge.com/wow/addons/dmgfontchanger
- EB Garamond, Lizenz und Kyrillisch: https://en.wikipedia.org/wiki/EB_Garamond, https://fontsource.org/fonts/eb-garamond/about
