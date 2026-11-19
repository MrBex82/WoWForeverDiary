# Plan: Das Buch kommt zurück, mit der Bedienung des Fensters

Stand 19.11.2026. Ausgang: 0.3.5 (Buch, veröffentlicht) und `main` (Fenster "Reisetisch", Tag `v0.4.0` nur lokal,
nie veröffentlicht). Spieler kennen also nur das Buch. Das ist die Chance: 0.4.0 erscheint erst, wenn es wieder ein Buch ist.

## Grundidee

**Das Fenster wird ein aufgeschlagenes Buch.** Nicht zwei Modi, sondern eine Oberfläche: außen Einband, Falz und
Blätter wie in 0.3.x, innen die Technik von 0.4.0 (Router, Views, Kit, Listen, Berichte, Suche, Live-Schrift).

```
 ┌─ Einband (Leder) ─────────────────────────────────────────────────────────┐
 │  ‹ ›   Bestiarium · Wölfe                        [ Stichwort suchen ]  ☰ ✕ │  <- Kopf auf dem Einband
 │ ┌─────────────────────────────┐┃┌─────────────────────────────┐ ┌──┐       │
 │ │ BESTIARIUM          (rot)   │┃│  Grauwolf                   │ │He│ Reiter │
 │ │ [Alle][Selten][Bosse] ⇅     │┃│  [Portrait]  Stufe 7        │ ├──┤ (Daumen│
 │ │ ▸ Grauwolf            12    │┃│  Kills 12 · zuletzt Tag 4   │ │Ta│ register│
 │ │   Waldwolf             3    │┃│  Nächste Marke ▓▓▓░ 25      │ ├──┤ je    │
 │ │   Prärieläufer         1    │┃│  Elwynn [Karte]             │ │Ja│ Gruppe)│
 │ │   ...                       │┃│  Beste Beute ...            │ ├──┤       │
 │ │                     - 12 -  │┃│                     - 13 -  │ │Ch│       │
 │ └─────────────────────────────┘┃└─────────────────────────────┘ └──┘       │
 └──────────────────────────── Lesebändchen = Lesezeichen ───────────────────┘
```

## Das Beste aus beiden

| Aus dem Buch (0.3.x) | Aus dem Fenster (0.4.0) |
|---|---|
| Einband, Deckblatt, das sich öffnet | Größe frei, Strg+Mausrad, Mindestgröße wächst mit der Schrift |
| Doppelseite mit Falz, Blätter aus `page.tga` | Router mit Zurück/Vor, Suche (Strg+F), Lesezeichen |
| Umblättern mit Bewegung und Ton | Listen mit Chips, Sortierung, Filter, Bericht daneben |
| Reiter am Buchrand, Inhaltsverzeichnis | Register mit Gruppen und Neu-Zählern |
| Rote Tinte für Überschriften, Initialen, Randnotizen, Seitenzahlen | Kit, Tokens, vier Stile live, Schrift bis 150 % live |
| Das Gefühl, in einem Tagebuch zu lesen | `ui_sim`, `/wfd layoutcheck`, Kontrastprüfung |

## Wie die Ansichten auf die Doppelseite passen

Fast alles hat schon zwei Spalten, es wird nur zu zwei Seiten:

- **Listen** (Bestiarium, Leute, Questbuch, Anglerbuch, Schätze ...): links die Liste, rechts der Bericht (heute Berichtsspalte in `Collection.lua`). Ohne Auswahl rechts die Übersicht des Teils (Kennzahlen, Neues).
- **Tagebuch**: links der Tag, rechts Momente, Karte des Tages, Randnotizen; Blättern = Tag vor/zurück mit Umblättern. Das Kapitelregister wird das Inhaltsverzeichnis (eigene Seite, über Reiter oder Bändchen).
- **Start**: links Heute (Tag, Reiseziel, Fast geschafft), rechts Neues seit dem letzten Mal.
- **Gruppenseite**: links Inhaltsverzeichnis der Gruppe, rechts Auf einen Blick.
- **Weltkarte**: über beide Seiten wie ein Atlas (Falz bleibt als Schatten sichtbar).
- **Einstellungen**: links die Abschnitte als Inhaltsverzeichnis, rechts die Schalter. **Hilfe** ebenso.

Schmales Fenster (unter etwa 900 Punkten mal Schrift): **eine Seite**, Bericht öffnet als umgeblätterte Seite,
Reiter werden ein Bändchen mit Menü (heute schmales Register).

## Was das für den Code heißt

Kein Neubau, sondern ein neuer Rahmen um das Bestehende:

1. **`K.Spread`** (Kit): Einband, zwei Seiten, Falz, Seitenzahlen; liefert `left`, `right` oder `single`.
   `Shell.lua` baut ihn statt Register + Schreibtisch; `View:Layout(w, h)` bekommt die Seiten statt einer Fläche.
2. **Reiter** statt Register: dieselben Daten (`UI.NAV`, Neu-Zähler), gezeichnet am Buchrand, Farbe je Gruppe plus Zeichen.
3. **Umblättern** (`K.Turn`): beim Wechsel der Ansicht und im Tagebuch; Einstellung "Bewegung reduzieren" (Phase 5 des UX-Plans).
4. **Buchtypografie** in Tokens: rote Tinte, Initiale, Seitenfuß; die alten Helfer aus `PagesDiary.lua`, `Widgets.lua` wiederverwenden.
5. Stile: Leder und Gold, Pergament = Buch mit voller Textur; Modern und Starker Kontrast = flaches Buch (Form bleibt, Textur weg).

Die Datenstruktur (SavedVariables) bleibt unverändert. 0.3.x bekommt nur noch Fehlerbehebungen.

## Phasen (je ein Commit, danach Spieltest)

1. **Rahmen**: `K.Spread`, Einband, Falz, Seiten; alle Ansichten laufen erst einmal auf der rechten Seite + Übersicht links. `ui_sim` und `layoutcheck` kennen beide Seiten.
2. **Listen auf zwei Seiten** (Collection und Report), damit sind die meisten Teile fertig.
3. **Tagebuch, Start, Gruppen, Einstellungen, Hilfe** auf zwei Seiten; Weltkarte über beide.
4. **Reiter und Bändchen** statt Register; Lesezeichen als Bändchen.
5. **Umblättern**, Ton, Deckblatt öffnet sich in das Buch.
6. **Buchdetails**: rote Tinte, Initialen, Seitenzahlen, Randnotizen; flaches Buch für Modern und Kontrast.
7. **Abschluss**: `layoutcheck` bei 100, 120, 150 % in allen Stilen, 760x520 bis groß; Screenshots; Changelog 0.4.0 neu
   ("Das Buch bleibt. Es lässt sich jetzt so leicht bedienen wie ein Fenster.").

Danach die Phasen aus `UX-Plan-Opus.md`, soweit sie nicht schon hier erledigt sind.

## Offene Fragen

- Reiter rechts am Buchrand (wie 0.3.x) oder links? Vorschlag: rechts, wie ein echtes Daumenregister.
- Seitenzahlen: echte Nummern über das ganze Buch (wie 0.3.x) oder Stelle im Teil ("12 von 340")? Vorschlag: Stelle im Teil, weil Listen wachsen.
- Soll das Tagebuch beim Blättern auch zwei Tage nebeneinander zeigen (links gestern, rechts heute) statt Tag + Momente?
