# UX-Review: Reisetagebuch

Grundlage: der ganze UI-Code (Book, Seiten, Karten, Toasts, Begleiter, Suche, Komfort) und die Bilder in `screenshots/`.
Die Bilder sind teils älter als 0.1.10 (damals mehr Reiter); was sich seitdem geändert hat, habe ich im Code nachgesehen.

**Gesamteindruck:** Das Buch ist liebevoll gemacht und hat eine starke Identität: Leder, Gold, Siegel, Sammelkarten. Die Schwächen liegen nicht in der Optik, sondern in **Orientierung** und **Lesbarkeit**. Es gibt sehr viele Teile, viele Funktionen sind versteckt (Strg-Klick, Rechtsklick), und viel kleine, blasse Schrift.

Prioritäten: **P1** = großer Nutzen, **P2** = spürbar besser, **P3** = Feinschliff.

---

## P1 – Die fünf wichtigsten Punkte

### 1. Ein „Heute“-Einstieg statt Deckblatt → Besitzerseite
**Problem:** Wer das Buch öffnet, will meist wissen: Was ist heute passiert, was steht an, was ist neu? Das steht verstreut:
- der Tagebucheintrag im Diary
- die Aufgaben unter „Sammelalbum → Nächste Ziele“
- neue Dinge als rote Punkte an den Reitern
- das Reiseziel des Tages ebenfalls unter „Nächste Ziele“

Beim ersten Öffnen der Sitzung kommt außerdem das Deckblatt (ein Klick mehr).

**Vorschlag:** Eine Doppelseite **„Heute“** als Standard-Einstieg:
- links der heutige Eintrag (gekürzt) mit den Andenken
- rechts Tages- und Wochenaufgaben, „Neu seit dem letzten Lesen“ (als anklickbare Liste statt nur Punkte an den Reitern) und das Reiseziel des Tages

Das Deckblatt nur beim ersten Öffnen nach dem Einloggen zeigen und optional abschaltbar machen. Der Begleiter zeigt schon fast diese Inhalte; die Seite wäre seine große Fassung.

### 2. Weniger Reiter, klarere Gruppen
**Problem:** 17 Reiter, nur Icons, Namen erst beim Darüberfahren. Die Farbgruppen helfen, aber Icons wie Zahnrad, Feder und Edelstein sagen ohne Text wenig. Einige Teile haben gar keinen Reiter und sind nur über Inhalt oder Suche erreichbar:
- Erzfeinde
- Rekordbuch
- Galerie
- Sehenswürdigkeiten
- Gefährten
- Fundorte

**Vorschlag:**
- **Ein Reiter pro Gruppe** (7 statt 17): Heute, Ziele & Ruhm, Chronik, Welt, Jagd & Beute, Menschen, Andenken.
- Jede Gruppe beginnt mit einer **Übersichtsseite**: kleine Kacheln für ihre Teile mit Kennzahl und „neu“-Markierung, z. B. „Bestiarium – 34 Arten · 2 neu“.
- Der aktive Reiter zeigt seinen Namen dauerhaft, nicht nur beim Darüberfahren.

So findet man alles in zwei Klicks, und die versteckten Teile tauchen wieder auf.

### 3. Lesbarkeit: Mindestgröße und Kontrast
**Problem:** Sehr viel Text steht in 8–10 pt, oft in Großbuchstaben mit Sperrung und in `inkFaint`/`inkSoft` auf dunklem Leder. Betroffen sind unter anderem:
- Kachel-Beschriftungen
- Unterzeilen
- Seitenköpfe
- „Lv“, „#001“
- Legenden
- Zeitstempel

Großbuchstaben in 9 pt sind die am schwersten lesbare Kombination. Dazu kommt Rauschen hinter dem Text (Fleckenmuster, Kaffeeringe, Abnutzung).

**Vorschlag:**
- Untergrenze **11 pt** für alles, was man lesen muss. Nur Dekoration darf kleiner sein.
- Großbuchstaben nur für kurze Überschriften (1–3 Wörter), nicht für Sätze. Ein Beispiel ist „SOME HONORS STAY HIDDEN UNTIL YOU FIND THEM.“.
- `inkFaint` heller machen oder nur für Nebensächliches nutzen.
- Abnutzungsspuren nie unter Textblöcke legen (nur Ränder).

Der Stil „Starker Kontrast“ zeigt, dass es geht; der Standard sollte näher dran sein.

### 4. Versteckte Bedienung sichtbar machen
**Problem:** Wichtige Funktionen hängen an Gesten, die man nur aus der Einführung kennt:
- Strg-Klick auf die Seitenzahl = Lesezeichen
- Rechtsklick auf die Seitenzahl = Seite anspringen
- Rechtsklick auf verdeckte Karten = Karte der Region
- Strg+Mausrad = Größe
- Rücktaste = zurück

Wer die Einführung wegklickt, findet das nie.

**Vorschlag:**
- Ein kleines **Eselsohr oben an jeder Seite**, das man anklickt, um ein Lesezeichen zu setzen. Gesetzt ist es golden.
- Eine **sichtbare Seitenzahl-Eingabe**: Klick auf „~ 32 ~“ öffnet das Feld, statt Rechtsklick.
- Den Zurück-Knopf größer machen und neben die Blätterpfeile setzen statt in die linke obere Ecke.
- Ein **„?“-Knopf** am Buchrücken neben der Lupe, der die Einführung wieder startet.

### 5. Das Buch springt nicht unter dem Lesenden weg
**Problem:** Während das Buch offen ist, wird alle 10 s (bzw. 60 s) neu gesetzt (`Reflow`). Liest man den heutigen Tag, wandert der Text weiter, Seiten verschieben sich, und im Anhang ändern sich Seitenzahlen. Das stört besonders beim Lesen langer Einträge.

**Vorschlag:**
- Nur neu setzen, wenn die Maus nicht über dem Buch ist oder wenn geblättert wird.
- Sonst ein kleiner Hinweis „Neues im Tagebuch – Klick zum Aktualisieren“.

---

## P2 – Spürbar besser

### Tagebuchseiten
- **Geld im Fließtext** („23S 47K heavier“) ist schwer lesbar. In der Erzählung ausgeschrieben („gut 23 Silber“) oder mit Münz-Icons wie im Kassenbuch.
- **Lange Tage** füllen mehrere Seiten Fließtext. Oben eine **Kurzzeile** mit den Fakten des Tages einfügen, darunter die Erzählung:
  - Stufe
  - Kills
  - Quests
  - km
  - Gold
  - Tode

  Die Randnotizen zeigen das schon, aber klein am Rand.
- „+ Notiz“ ist winzig. Ein deutlicher Stift-Knopf beim Datum.
- Das **Gemälde** ist oft eine kleine Figur vor leerem Himmel. Die Figur muss größer ins Bild, und es braucht einen Hintergrund passend zur Zone (Wald, Wüste, Schnee) oder eine Vignette, die das Bild füllt.

### Karten und Karten-Seiten
- Die **Legende** sagt „Route“ und „Kill sites“, aber Kampfplätze sind dunkle Rauten auf dunkler Karte, kaum sichtbar. Die Farbe muss sich klar abheben, und die Legende muss genau das Kartensymbol zeigen.
- **Gräber** unterscheiden sich von Personen nur durch Rot statt Orange. Ein Totenkopf-Symbol statt Zahl ist auch für Farbenblinde lesbar.
- Bedienhinweise („Mausrad: zoomen …“) stehen nur im Atlas. Besser als kleine Symbole in die Kartenecke, auf allen Karten gleich.
- **„Reiseziel des Tages“** ist eine Sackgasse: Man erfährt, wohin, aber nicht wie. Ein Klick sollte eine Kartenmarkierung setzen (wie bei gesichteten Kreaturen) oder die Atlas-Karte mit dem Ziel öffnen.

### Steckbriefe und Fangkarten (Overlay)
- **Blättern innerhalb der Karte:** Pfeile links und rechts zur vorigen und nächsten Kreatur des Albums. Heute heißt es: Overlay schließen, nächste Karte suchen, öffnen.
- Ein Klick neben die Karte sollte sie schließen (heute nur das X oder Escape).

### Rückmeldungen
- **Toasts stapeln sich** nach einem großen Kampf oder Dungeon: jede Ehrung, jedes erste Mal und jeder Fang einzeln, je 6 Sekunden. Kommen mehrere innerhalb weniger Sekunden, eine Sammelnotiz zeigen: „3 neue Ehrungen – Klick zeigt alle“.
- Der **Begleiter ist ab Werk an.** Für neue Spieler ist ein unbekanntes Fenster am Bildschirmrand eher störend. Besser beim ersten Öffnen des Buchs anbieten: „Soll ich dir ein kleines Fenster mit den Tagesaufgaben zeigen?“

### Leere Teile
Ein neuer Charakter sieht viele leere Abschnitte („Noch keine …“), etwa Erzfeinde, Galerie, Dungeon-Berichte und Zeitkapsel. Das wirkt wie ein halbleeres Buch. Vorschlag:
- Im Inhaltsverzeichnis leere Teile **gedimmt mit Hinweis** zeigen: „Galerie – füllt sich mit deinem ersten großen Moment“.
- Die leeren Seiten selbst als **„Was dich hier erwartet“** gestalten: ein Beispielbild aus dem Demo-Buch, halbtransparent.

### Suche
- Die Ergebnisse vermischen Tage, Personen, Kreaturen und Orte. **Filter-Chips** oben (Alle · Tage · Personen · Kreaturen · Orte · Schätze · Fänge) machen große Bücher übersichtlich.
- Tagestreffer zeigen den Textausschnitt, aber den Suchbegriff nicht hervorgehoben. **Hervorheben** (Gold) hilft beim Überfliegen.

---

## P3 – Feinschliff

- **Doppelte Titel:** Auf ersten Seiten steht der Teil zweimal (kleiner Seitenkopf „BESTIARY“ und großer Titel „Bestiary“). Auf Seiten mit großem Titel den Seitenkopf weglassen; das spart Platz und Unruhe.
- **Kacheln mit zweizeiligen Beschriftungen** („Creatures slain here“, „Quests completed here“) wirken gequetscht. Kürzere Begriffe („Erlegt“, „Quests“) oder eine Kachel weniger pro Reihe.
- **Fortschrittsbalken** haben überall dieselbe Goldfarbe. Ehrungen könnten in der Farbe ihres nächsten Metalls füllen (Bronze, Silber …); dann sieht man sofort, worum es geht.
- **Ehrenbuch:** Die Rauten rechts (Stufen) sind 6–8 px groß. Die Metallstufen größer zeigen oder als kleine Medaillen.
- **Kassenbuch:** Die Münz-Icons in 10 px sind kaum zu unterscheiden (Silber/Kupfer). Mindestens 12 px, oder die Kupferspalte weglassen, sobald Gold im Spiel ist.
- **Schätze filtern** springt an den Anfang des Teils; der Filter sollte die aktuelle Seite halten oder sichtbar anzeigen, dass neu sortiert wurde.
- **Einstellungen** liegen an vier Orten: drei Seiten hinten im Buch, Spieloptionen, Rechtsklick auf den Minimap-Knopf, Slash-Befehle. Die drei Buchseiten könnten eine einzige Seite mit klaren Abschnitten sein.
- **Mischsprache:** Zonen- und Kreaturennamen kommen aus dem Spielclient. Bei Tagebuchsprache ≠ Spielsprache steht dann „Unexplored regions: Alteracgebirge“. Kurzer Hinweis in den Einstellungen, dass Namen aus dem Spiel nicht übersetzt werden können.
- **Barrierefreiheit:** Viele Unterschiede laufen nur über Farbe:
  - Gewinn grün / Verlust rot
  - Seltenheit der Kreaturen
  - gesichtet / erlegt

  Wo möglich, zusätzlich Form oder Symbol nutzen (Pfeil hoch/runter, Rahmenform, Hohlring hat es schon).

---

## Wenn nur Zeit für drei Dinge ist

1. **Lesbarkeit** (P1.3): Mindestgröße und Kontrast. Kleine Änderung an `UI.c` und den `pool:Text(9, …)`-Aufrufen, große Wirkung auf jeder Seite.
2. **Kein Wegspringen beim Lesen** (P1.5): kleine Änderung in `UI:Reflow`, beseitigt ein echtes Ärgernis.
3. **„Heute“-Seite** (P1.1): größerer Umbau, aber der Teil, den man jeden Tag sieht.
