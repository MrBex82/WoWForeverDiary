# Plan: Große Schrift (bis 150 %) und größere Meldungen

Anlass: Feedback eines Spielers mit Keratokonus. 120 % Schrift reichen nicht, die Meldung in der Bildschirmmitte ist zu klein.
Ziel: Schrift 130, 140 und 150 % ohne Überlappungen, eine Größenwahl für die Meldungen, in **0.3.x** (Buch) und in **0.4.x** (Fenster).

## Ausgangslage

| | 0.3.x (Branch `release-0.3.5`, ab `v0.3.4`) | 0.4.x (`main`) |
|---|---|---|
| Oberfläche | Buch mit festen Seiten 420x560, Seitenumbruch mit festen Höhen | Fenster mit Shell, Views, Kit; Größe frei |
| Schrift | `UI.FS` vergrößert nur die Schrift, Abstände bleiben fest (rund 380 Stellen) | `UI.FS` und `UI.FK()`; viele feste Größen folgen schon der Schrift (Phase 4 des UX-Plans) |
| Wechsel der Schrift | `ReloadUI()` direkt, vom Client geblockt | live über `UI.SetFontScale`, kein Neuladen |
| Stufen | 100 bis 150 % (schon eingebaut, nicht committet) | 100, 110, 120 % |
| Meldung | Größe per Mausrad, neu: Wahl 100 bis 200 % unter Bedienung | Größe per Mausrad, keine Einstellung |
| Prüfen | nur im Spiel | `tools/ui_sim.lua` (Schrift 1, 1.1, 1.2; misst nichts vom Aussehen) |

Befund im Spiel bei 150 % in 0.3.x: Einstellungen laufen über den Fuß und unter das Buch, Inhalt und Übersichten überlappen
(Untertitel), Sehenswürdigkeiten laufen in die Nachbarspalte, Heute rechts (Reiseziel, Fast geschafft) überlappt.

## Gemeinsame Teile (einmal bauen, in beide Linien)

1. **Prüfbefehl `/wfd layoutcheck`** (im Spiel, misst echt): läuft durch alle Seiten bzw. alle Ansichten und meldet jeden
   sichtbaren Text, der über den Rand seines Bereichs ragt (Seite, Spalte, Kasten, Scrollbereich) oder einen anderen Text
   überdeckt, mit Seite/Ansicht und Textanfang. Gekürzte Texte mit "..." zählen nicht als Fehler.
   Kern (Rahmenbaum ablaufen, Rechtecke vergleichen) ist für beide Linien gleich, nur der Rundgang ist verschieden
   (0.3.x: Seiten blättern; 0.4.x: Register, Berichte, Einstellungen wie in `ui_sim`).
2. **Größenwahl der Meldungen** 100, 125, 150, 175, 200 % (`WFD.S.toastSize`, gleiches Feld in beiden Linien,
   daher kein Umbau der gespeicherten Daten). `UI:ToastSize()` und `UI:SetToastSize(k)` in `Toast.lua`.
3. **Stufen der Schrift** 100, 110, 120, 130, 140, 150 %. Mehr nicht: bei 150 % passen auf eine Buchseite noch etwa
   25 Zeichen je Zeile in zwei Spalten, darüber wird es unbrauchbar.
4. **Texte**: neu nur "Size of the notes" (alle Sprachen, schon angelegt) und für den Prüfbefehl ein Hilfetext.
5. **Wochenrückblick und Begleiter** wachsen mit der Schrift, in beiden Linien gleich geprüft.

## 0.3.x: das Buch

1. **Grundlage** (`Themes.lua`): `UI.LH(n)` = Abstand/Zeilenhöhe, die mit der Schrift wächst (`n * max(1, FONT_SCALE)`),
   `UI.BIG` = Schrift ab 130 %. Schriftwechsel über einen sicheren Neuladen-Knopf (SecureActionButton mit `/reload`) statt
   `ReloadUI()`; dasselbe für Stil und Sprache (`Comfort.lua:895`, `Core.lua:705/728`, `Moving.lua:165`, `PagesAppendix.lua:2063`).
2. **Abstände und Seitenumbruch**: feste `y = y - n` und Zeilenhöhen auf `UI.LH` umstellen, und die Höhen in `UI:Paginate`
   (`Book.lua`) mit denselben Werten rechnen, damit große Schrift mehr Seiten ergibt statt überzulaufen.
   Reihenfolge: Heute, Inhalt und Übersichten, Tagebuch, Einstellungen, Welt, Bestiarium und Schicksal, Anhang,
   Angeln, Andenken, Jahrbuch. Ein Commit je Bereich, danach `/wfd layoutcheck` bei 150 %.
3. **Breiten**: bei `UI.BIG` zweispaltige Raster einspaltig (Sehenswürdigkeiten, Vitrine, Kacheln 4 zu 2);
   Untertitel und Daten brechen um und die Zeile wächst mit; `FitText` nur für kurze Beschriftungen.
4. **Einstellungen**: Inhalt auf beide Seiten verteilen (Allgemein: links Meldungen und Meilensteine, rechts Sprache);
   reicht das nicht, fallen Erklärtexte weg (wie heute `small()`).
5. **Buchgröße** bis 120 % (eingebaut); Strg+Mausrad geht schon bis 140 %.

## 0.4.x: das Fenster

1. **Stufen** in `Settings.lua:135` um 1.3, 1.4, 1.5 ergänzen; `UI.SetFontScale` wirkt live.
2. **Messen statt raten**: `/wfd layoutcheck` bei 150 % und Fenster 760x520 sowie groß, alle Stile.
   `ui_sim.lua`: Schriftstufen um 1.5 ergänzen und eine grobe Prüfung auf Überlauf (geschätzte Textbreiten) einbauen,
   damit es auch ohne Spiel auffällt.
3. **Rest fester Größen** an `UI.FK()` binden, wo der Prüfbefehl etwas findet (Kandidaten: Zeilenhöhen in Listen,
   Kacheln und Chips in Berichten, Register-Einträge, Kopfzeile, Hinweisstreifen, Menüs).
4. **Mindestgröße des Fensters** mit der Schrift wachsen lassen (sonst bei 150 % in 760x520 zu eng), schmales Register
   schon ab mehr Breite.
5. **Meldung**: Größenwahl unter Einstellungen > Meldungen (`type = "choice"`).

## Reihenfolge und Versionen

1. **0.3.5 schnell**: Meldungsgröße, sicherer Neuladen-Knopf, Schrift bis 130 % (nur, wenn `/wfd layoutcheck` bei 130 % sauber ist,
   sonst 120 % lassen). Damit hat der Spieler sofort größere Meldungen.
2. **Prüfbefehl** zuerst in 0.3.x bauen, dann nach `main` übernehmen.
3. **0.4.x**: Stufen bis 150 %, Meldungsgröße, Funde des Prüfbefehls beheben. Hier ist am wenigsten zu tun, weil die Grundlage steht.
4. **0.3.6**: das Buch bis 150 % (Schritte 2 bis 4 oben), der größte Teil der Arbeit.

Abschluss jeder Linie: Prüfbefehl ohne Treffer bei 100, 120, 150 % in allen Stilen, Spieltest mit Screenshots,
Changelog in einfacher Sprache, Version erhöhen.

## Offene Fragen

- Bekommt 0.3.x überhaupt noch die volle 150-%-Arbeit, oder reicht 0.3.5 mit 130 % und der Verweis auf 0.4.x?
- Soll die Meldung zusätzlich mit der Schriftgröße wachsen (bei 150 % Schrift automatisch größer), oder nur über die eigene Wahl?

## Stand 19.11.2026 (Branch release-0.3.5, nicht committet)

- Neuer Ansatz im Buch: die ganze Seite wird skaliert (`UI.SetPageGeometry`, Leinwand mit `SetScale(k)`, `UI.AsPage`, `pool.raw`).
- Fortsetzungsseiten für feste Seiten: `UI.FlowKind(kind)` / `UI.SplitFlowPage` in `Book.lua`; aktiv für die vier Einstellungsseiten.
- `/wfd layoutcheck` funktioniert; Lauf 1 bei 150 %: 786 Funde, Liste in `layoutcheck-150-run1.txt`.
- Nächste Schritte: Seitenart in jeden Fund schreiben, Treffer mit einem Zeichen (Initiale, "?") ignorieren, Lauf bei 100 % als Vergleich;
  FlowKind für owner, today, nextgoals, groupindex, groupglance, ledgersum, yearbook, fatestats, Intro-Seiten;
  Album- und Fangkarten-Raster (PER_PAGE, CARD_W in `PagesAppendix.lua:487`, `PagesFishing.lua:9`) aus `UI.TextW()` und `UI.AREA_H` rechnen;
  Tagesköpfe im Tagebuch ("Freitag, 6. November 2026 (...)") kürzen; Momente im Tagebuch laufen unten über.

## Stand 19.11.2026, Nachmittag

- 0.3.x im Spiel geprüft: `/wfd layoutcheck` bei 150 % noch 1 Fund, derselbe wie bei 100 % (abgeschnittener Kartenname im Bestiarium).
- Fortsetzungsseiten: Fußbereich bleibt auf Teil 1 (Erkennung über Höhenänderung), Diagramme als Gruppe, Überschriften gehen mit der Folgezeile weiter, erster Aufbau zweimal.
- Neuladen über den sicheren Knopf (`UI/Reload.lua`, `WFD:Reload`), im Spiel getestet.
- Offen: Lauf bei 130/140 %, Prüfung der Überschriften-Regel im Spiel, Bestiarium-Karten bei 150 % nur 2 je Seite, 0.4.x.
