# Plan für Opus: UX und GUI des Reisetagebuchs nach 0.4.0 verbessern

## Context

0.4.0 hat das Buch zum "Reisetisch" umgebaut (Fenster mit Register, Suche, Ansichten in `UI/Views`). Die großen Punkte aus `UX-Review.md` und `UX-Umbau-Plan.md` sind damit erledigt. Eine Durchsicht des jetzigen Codes (Shell, Designsystem, alle Ansichten) zeigt, wo es für Nutzer noch hakt:

- **Sackgassen:** Namen und Zahlen stehen da, lassen sich aber nicht anklicken (Tagesfakten, Gruppenmitglieder, Bosse, "Gesichtet in", Questgeber).
- **Uneinheitliche Klicks:** Eine Zeile öffnet mal eine Karte, mal einen Bericht, mal springt sie ins Tagebuch, mal passiert nichts.
- **Zustand geht verloren:** Filter, Auswahl und letzter Ort überleben weder Zurück noch `/reload`. "Neu"-Zähler verschwinden beim Schließen statt beim Ansehen.
- **Fehlende Rückmeldung:** Kein Gedrückt-Zustand, Löschen ohne Rückfrage oder Rückgängig, Meldungen nur im Chat.
- **Enge Fenster und 120 % Schrift:** Tagebuch verliert Register und "Gehe zu Tag", Lesezeichen verschwinden, feste Größen laufen über, Karten werden bis 0.4 verkleinert.
- **Ruckler:** Suchindex und Listen bauen bei jedem Tastendruck neu, Weltkarte rechnet bei jedem Klick alles neu.
- **Zwei Designschichten:** alte Palette `UI.c` und alte Bausteine (vor allem `Cards.lua`) neben `UI.T` und `Kit`.

Ziel: Das Fenster fühlt sich überall gleich an, alles Sichtbare führt weiter, nichts geht verloren, und es bleibt auch klein und mit großer Schrift gut bedienbar. Die gespeicherten Daten (SavedVariables) bleiben, wie sie sind; neu sind höchstens kleine Einstellungsfelder.

## Regeln für jede Phase (verbindlich)

- Mit dem Nutzer auf Deutsch sprechen. Commit-Texte deutsch im bisherigen Stil, **ohne** Co-Authored-By oder andere KI-Hinweise (der Hook `tools/install_hooks.sh` lehnt sie ab).
- In Addon-Texten nur "-", nie "–" oder "—". Wortwahl nach `Lektorat.md` (Ehrung, erlegen, Klickhinweise "Klicken: ...").
- Neue oder geänderte Texte in **allen** Dateien unter `WoWForeverDiary/Locales/`. Hilfen: `tools/loc_add.py`, `tools/check_locales.py`, `tools/check_usage.py`.
- Vor jedem Commit: `bash tools/check_all.sh` (luac, Sprachprüfungen, `lua tools/ui_sim.lua WoWForeverDiary`). Nach Farbänderungen `py tools/contrast.py`. Python heißt hier `py`.
- Eine Phase ist ein Commit (bei großen Phasen ein Commit je Unterpunkt). Nicht pushen, kein Release ohne Auftrag.
- Im Spiel prüft der Nutzer: `ReloadUI()` ist gesperrt, **nie** WoW per `open_application` starten. Am Ende jeder Phase eine kurze Prüfliste für den Nutzer nennen (`/reload`, was ansehen).
- Unklares zur WoW-API erst nachforschen (Doku, `/run` im Spiel, SavedVariables), nicht raten. In Instanzen sind Kreatur-ID und Modell geheim.
- Neue Bausteine gehören ins Kit (`UI/Design/Kit.lua`) und nutzen `UI.T`, `UI.TYPE`, `UI.FS`. Keine neuen festen Farben oder Schriftgrößen in Ansichten.
- `tools/ui_sim.lua` mit erweitern, wenn eine Phase neues Verhalten bringt (neue Routenfelder, Tasten, Rückgängig).

## Phase 1: Spürbare Bedienung (Kit und Shell)

Kleine Eingriffe mit Wirkung auf jeder Seite.

1. **Gedrückt-Zustand** für `K.Button` und `K.IconButton` (`Kit.lua:234, 274`), deaktiviert klar erkennbar (nicht nur blasser). Tote Hover-Felder bei primary/danger aufräumen (`Kit.lua:181-212`), Glanzkante aus dem Stil statt fester Farbe (`Kit.lua:210`).
2. **Dropdown** (`Kit.lua:424-467`): schließt bei Klick daneben, bekommt Höchsthöhe mit Scrollen, Zeilenhöhe folgt der Schrift.
3. **Suchfenster** (`Shell.lua:288-478`): schließt bei Klick daneben, öffnet wieder beim Fokus mit Text, Treffer nach Art gruppiert mit Zwischenzeile, Chip für "Teile", Filter wie `z:` wählen den Chip sichtbar um statt ihn still zu übergehen (`Search.lua:160`), leere Suche mit Vorschlag statt nur "Nichts gefunden".
4. **Tasten** (`Comfort.lua:70-133`): Tasten gelten, solange das Fenster offen und kein Eingabefeld aktiv ist, nicht nur bei Maus über dem Fenster. Escape schließt immer zuerst die oberste Ebene. Neu: Alt+Links/Rechts und Maustasten 4/5 für Zurück/Vor, Hoch/Runter und Bild auf/ab scrollen die Ansicht. Im Kampf weiter keine Tastatur. Erst prüfen, wie sich `EnableKeyboard` und `SetPropagateKeyboardInput` mit Bewegungstasten vertragen: Spielertasten (WASD usw.) müssen immer durchgereicht werden.
5. **Rückmeldung im Fenster:** ein kleiner Hinweisstreifen `UI:Notice(text, undoFn)` in der Shell (unten, 4 s, optional "Rückgängig"). Erste Nutzer: Lesezeichen gesetzt/entfernt (Rechtsklick in `Shell.lua:144` wird rückgängig machbar), "alle 12 Lesezeichen belegt" (`Diary.lua:210`) statt Chat, unbekanntes `/wfd`-Wort (`Toast.lua:22`).
6. **Tooltips für Abgeschnittenes:** eine Hilfsfunktion im Kit, die einen Tooltip mit dem vollen Text zeigt, wenn ein Text gekürzt ist (`IsTruncated`). Einsetzen in `UI.ListRow` (`Registers.lua:59-83`), Berichtszeilen (`Report.lua:51, 85`), Suchtreffer, Gruppenkarten (`Group.lua:47`), eigene Ziele (`Goals.lua:278`). Register-Einträge bekommen auch in breiter Form einen Tooltip.
7. **Hilfe stimmt wieder:** `Help.lua` zeigt alle Befehle aus `Core.lua:801-812`, die echten Tasten (nur Links/Rechts blättern) und die Mausgesten (Strg+Mausrad, Mausrad auf Begleiter und Meldung).

## Phase 2: Zustand merken

1. **Route trägt den Zustand:** `chip`, `sort`, `q` (Suchtext) und `sel` (gewählter Eintrag) kommen in die Route. `same()` (`Router.lua:67-70`) vergleicht sie mit; Wechsel von Chip/Sortierung/Auswahl ersetzen den aktuellen Verlaufseintrag, statt neue anzulegen. `CollectionView.Show` (`Collection.lua:444-454`) stellt alles wieder her und leert den Suchtext, wenn die Route keinen hat. `Reports.lua:300` (Erzfeind-Link) geht über eine Route.
2. **Filter sichtbar und lösbar:** "Filter zurücksetzen" in der Leiste, sobald etwas gewählt ist, und als Knopf in der Meldung "Nichts passt". Leertext unterscheidet "noch nichts da" von "Filter trifft nichts" (`Trophies.lua:330`, Erste Male).
3. **Letzter Ort bleibt:** letzte Route und Verlauf überleben Schließen und `/reload` (in `WFDiaryChar`, mit Prüfung, dass die Ansicht noch existiert). Einstellung "Beim Öffnen: Start / letzter Ort" (Standard: Start beim ersten Öffnen nach dem Einloggen, sonst letzter Ort).
4. **"Neu" je Teil:** Zähler eines Teils verschwinden, wenn der Teil angesehen wurde, nicht mehr alle beim Schließen (`Comfort.lua:219-221`, das ungenutzte `UI.visited` in `Shell.lua:731` dafür fertig bauen: `seenAt` je Teil). `Diary:Show` löscht `WFD.dirty` nicht mehr für alle (`Diary.lua:435`).
5. **Sammelmeldung hält ihr Versprechen:** "Neu seit dem letzten Lesen" auf Start (`Comfort.lua:183-199`) zählt auch Sehenswürdigkeiten, Stufen, Dungeons und Aufgaben, also alles, was die Sammelmeldung (`Toast.lua:291`) bündelt.
6. **Einband:** Standard wird "nur beim allerersten Öffnen" statt bei jeder Sitzung (`Shell.lua:764`, `Core.lua:171`); die Einstellung bietet nie / einmal / jede Sitzung.
7. **Einstellungen ordnen** (`Settings.lua:62-156`): alles zum Fenster in einen Abschnitt (Größe, Sperre, Zurücksetzen, Beim Öffnen), die vier Meldungsschalter als eine Gruppe mit klarer Rangfolge, Begleiter eigener Block. Sicherung/Wiederherstellen/Aufräumen als Knöpfe unter Daten (bisher nur Befehle). Zahnrad verlässt die Einstellungen in einem Schritt (Abschnittswechsel ohne Verlauf, `Settings.lua:397`, `Shell.lua:576`).

## Phase 3: Alles führt weiter

1. **Ein Klickmodell:** Ein Klick auf eine Zeile öffnet immer das Detail in der rechten Spalte; "Diesen Tag lesen" ist ein Link darin. Kleine Detailberichte über `def.detail` (wie in `Reports.lua:167`) für Quests, Schätze, Gefährten, Reittiere, Ruf, Meilensteine, Erste Male, Sehenswürdigkeiten, Familienbuch (`Registers.lua`, `Trophies.lua`, `People.lua`, `Chronicle.lua`, `Keepsakes.lua`). Rechtsklick-Abkürzungen (`Trophies.lua:63`, `PagesAppendix.lua:341`) bleiben, stehen aber zusätzlich als sichtbarer Link im Detail.
2. **Querverweise** (über `rp:Line` mit `click` und die Routen aus Phase 2):
   - Tagebuch: Faktenchips öffnen Bestiarium/Questbuch/Weltkarte für den Tag, Gebietsname öffnet die Karte, Boss- und Dungeon-Momente öffnen Steckbrief bzw. Bericht (`Diary.lua:45-58, 345`).
   - Weltkarte: Kennzahlen eines Gebiets öffnen die gefilterten Listen (`World.lua:404-413`), entdeckte Orte und Fundorte verlinkt.
   - Dungeon-Bericht: Mitglieder zu Gefährten, Bosse und "Getötet von" zum Bestiarium (`Reports.lua:108-132`).
   - Karten: "Gesichtet in" und "Wo er biss" zur Karte, "Hat dich getötet" zu Schicksal, alle Quests einer Person statt "+N" (`Cards.lua:471-503, 573`).
   - Questbuch: Questgeber zu Leute. Sammelalbum: Zeilen tragen ihren Chip (`Goals.lua:415-417`). Jahrbuch-Monate öffnen den ersten Tag des Monats.
   - Verdeckte Fangkarten klickbar wie im Bestiarium (`PagesFishing.lua:121`).
3. **Aufgaben, die man angehen kann:** jede Aufgabe mit Hinweis oder Link (`Goals.lua`, `Start.lua:56`). Tagesaufgaben nur noch auf Start ausführlich; "Aufgaben" zeigt Woche, Monat, Serien und eigene Ziele. Eigene Ziele: abhaken nur am Kästchen, bearbeiten möglich, Löschen mit "Rückgängig" (`Goals.lua:279-290`). Gleiches für Sparziel entfernen (`People.lua:500`).
4. **Leere Zustände:** neuer Kit-Baustein `K.Empty(parent, icon, titel, hinweis, knopf)` mit einem Satz, **wie** sich der Teil füllt, und wo sinnvoll einem Knopf (z. B. "Zur Weltkarte"). Ersetzt den Einheitssatz und die "-"-Zeilen in Bestiarium, Anglerbuch, Ruf, Rekorde, Kassenbuch, Tagebuch (`Albums.lua:153, 236`, `People.lua:221, 576`, `Chronicle.lua:224`, `Diary.lua:259`). Erste Male: offene Einträge als eine dichte Liste statt je einer "?"-Zeile (`Chronicle.lua:122`).
5. **Lesezeichen für jede Ansicht:** Knopf in der Kopfzeile (`MarkList` kann Routen schon), nicht nur für Tage.

## Phase 4: Kleine Fenster und große Schrift

1. **Tagebuch schmal:** unter 760 px Inhalt wird das Register ein aufklappbares Feld, "Gehe zu Tag" wandert in die Fußleiste (`Diary.lua:149, 383`).
2. **Schmales Register:** Gruppe anklicken zeigt ihre Teile und die Lesezeichen als Aufklappmenü (`Shell.lua:201, 229`).
3. **Karten in Spaltenbreite:** Steckbrief, Visitenkarte, Fangkarte und Buchkarte werden in der Spalte fließend gesetzt statt von 384x540 herunterskaliert (`Cards.lua:9, 690-698`). Weg: die Karten auf `K.Report`-Blöcke umbauen (Bild, Kennzahlen, Zeilen), dabei `UI.c` und `pool:Text(8..)` loswerden. Das ist der größte Einzelposten; je Kartenart ein Commit.
4. **Feste Größen an die Schrift binden:** Einstellungs-Reiter (`Settings.lua:376-394`), Start-Karten und Kachelzahl (`Start.lua:160, 234-620`), Begleiter (`Companion.lua:9, 144, 215`), Meldung (`Toast.lua:69, 197`), Suchfenster (`Shell.lua:434`), Suchfeld der Listen (`Collection.lua:167`), Galerie (`Chronicle.lua:374`), Gebietskennzahlen 2 statt 4 je Reihe in schmaler Spalte (`World.lua:404`). Kein Text unter 11 pt: `UI.Unclip` und die festen 8/9 pt (`Components.lua:49, 772, 936`) entfernen.
5. **Fenster:** Größe nach Skalierung neu begrenzen, Strg+Mausrad ruft `LayoutShell` (`Comfort.lua:140-156`), Layout beim Ziehen gedrosselt (`Shell.lua:645`), Leiste mit Chips klappt bei wenig Platz zu einem "Filter"-Knopf zusammen.
6. `ui_sim.lua` prüft zusätzlich 760x520 bei 120 % in allen Stilen.

## Phase 5: Flüssig und lebendig

1. **Suche:** Eingabe verzögert auswerten (0.2 s) in Shell und `Collection.lua:179`; Suchindex nur für geänderte Tage nachführen statt alles neu zu erzählen (`Search.lua:107-162`).
2. **Rechenlast:** `summary()` einmal je Aktualisierung statt je Layout (`Collection.lua:305`, `Albums.lua:137`); `worldState`, `regionStats`, `chronicle` zwischenspeichern, bis sich Daten ändern (`World.lua:61-157`); `NewCounts` zwischenspeichern (`Comfort.lua:183`); Kassenbuch "alle Tage" über `K.Virtual` (`People.lua:692`); `K.Virtual.Update` nur den sichtbaren Bereich durchgehen (`Collection.lua:58`).
3. **Gezielt aktualisieren:** `WFD.dirty` bekommt Themen (z. B. `kills`, `money`, `path`), eine offene Ansicht aktualisiert sich nur, wenn ihr Thema betroffen ist (`Shell.lua:653-663`). Weltkarte bekommt ein `Refresh`; ein offener Detailbericht wird mit aktualisiert (`Collection.lua:423`). Begleiter-Takt stoppt, wenn er aus ist (`Companion.lua:305`).
4. **Ruhige Bewegung:** eine Hilfsfunktion `K.Fade` ersetzt die kopierten OnUpdate-Blenden (`Book.lua:98`, `Cards.lua:735`); kurzer Übergang beim Ansichtswechsel und beim Öffnen der Detailspalte. Einstellungen "Bewegung reduzieren" und "Töne" (für `UI.Sound`, `Book.lua:92`).

## Phase 6: Ein Gesicht

1. **Alte Palette ablösen:** `UI.c` wird auf `UI.T` abgebildet und Stück für Stück ersetzt (`Widgets.lua`, `Book.lua`, `Toast.lua`, `PagesFront.lua`, `Components.lua`; `Cards.lua` fällt mit Phase 4.3 weg). Feste Farben in `World.lua:27-41`, `Chronicle.lua:123`, `Report.lua:72`, `Trophies.lua:141` werden Rollen in `Tokens.lua`.
2. **Abstände als Konstanten** (`UI.SPACE` in `Tokens.lua:97`), `PAD` in Collection und Report darauf umstellen.
3. **Ein Tooltip-Stil:** `K.ShowTip` kennt Klickhinweise (blaue Zeile aus `Components.lua:231-305`); die 17 direkten `GameTooltip:SetOwner`-Aufrufe darauf umstellen, ein Anker-Schema.
4. **Eine Überschriften-Regel:** Kopfzeile nennt den Teil, Berichte wiederholen ihn nicht (`Chronicle.lua:219, 250, 323, 465`, `People.lua:475`).
5. **Auswahl nicht nur über Farbe:** gewählte Chips und Kartenebenen (`World.lua:289`) bekommen ein Häkchen; Seltenheit auf der Karte ein Zeichen.
6. **Prüfwerkzeuge:** `tools/contrast.py` prüft auch Gruppenfarben, Weiß auf `danger`, `onGold` auf `title`; ein kleines Skript meldet neue feste Farben und Schriftgrößen in `UI/Views`. Veralteten Kommentar `Themes.lua:3` und toten Code aus der Durchsicht entfernen (`Book.lua:11-15`, `Shell.lua:641`, ungenutzte Exporte in `Widgets.lua`).

## Reihenfolge und Umfang

1 → 2 → 3 → 4 → 5 → 6. Phase 1 und 2 sind klein bis mittel und bringen sofort spürbaren Nutzen; Phase 3 ist der größte Gewinn für Nutzer; Phase 4.3 (Karten) ist der größte Einzelaufwand. Nach jeder Phase kann eine Version erscheinen (Changelog unter `release/` im Stil von `CHANGELOG-0.4.0.md`, englisch und deutsch, nur auf Auftrag).

## Verification

Je Phase:
1. `bash tools/check_all.sh` läuft ohne Fehler; `py tools/contrast.py` zeigt 0 Paare unter dem Ziel.
2. `ui_sim.lua` deckt das Neue ab (Routen mit Chip/Suchtext/Auswahl, Zurück stellt Filter wieder her, Rückgängig, schmale Fenster bei 120 %).
3. Prüfliste für den Nutzer im Spiel: `/reload`, dann frischer Charakter **und** `/wfd demo`; alle vier Stile; Schrift 100 und 120 %; Fenster 760x520 und groß; Sprache Englisch und Deutsch; im Kampf öffnen und Tasten prüfen; `/wfd blocked` zeigt nichts Neues.
4. Für Phase 3: jede Ansicht einmal durchklicken und prüfen, dass jeder Name und jede Kennzahl weiterführt und Zurück an dieselbe Stelle mit demselben Filter zurückkommt.
