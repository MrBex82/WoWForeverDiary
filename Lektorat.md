# Lektorat: Texte im Reisetagebuch (deDE)

Grundlage: `Locales/deDE.lua` (alle Einträge) und die Stellen im Code, an denen die Texte zusammengesetzt werden.
Sortiert nach Wirkung: zuerst Fehler, die man im Spiel sieht, dann Uneinheitliches, dann Stil.

## 1. Echte Fehler

| Wo | Jetzt | Problem | Vorschlag |
|---|---|---|---|
| Kapitel-Untertitel, Diary | `Tag %d-%d` (für „Days %d-%d“) | Mehrzahl fehlt: „Tag 3-7“ | `Tage %d–%d` |
| Anglerbuch, verdeckte Karte | `%s kennt diese Kreatur schon` | Steht auch auf Fisch- und Schatzkarten: „Mirelle kennt diese Kreatur schon“ | `%s kennt das schon` |
| Ehrenbuch, Untertitel | `%d von %d Ehren errungen` | Gezählt werden **Stufen**, nicht Ehrungen (z. B. „37 von 140“) | `%d von %d Stufen erreicht` |
| Bestiarium, „Fast geschafft“ | `Wer als Nächstes eine Stufe aufsteigt` | „Stufe“ heißt im Spiel Level. Gemeint ist Skizze → Farbe → Kenner | `Wer bald in Farbe kommt` |
| Jagdgründe | `… wo das erste Tier seiner Art fiel` | Auch Humanoide, Untote usw. | `… wo die erste Kreatur ihrer Art fiel` |
| Tagebuch, Rückblick | `Du warst %s.` | Das Tagebuch schreibt sonst in der Ich-Form | `Da war ich %s.` |
| Tagebuch, „Nicht vergessen …“ | `Mutter Fang (Seltene Kreatur erlegt)` | Großes Adjektiv mitten im Satz. `loc.nounCase` lässt jedes erste Wort groß | Im Code: für Deutsch nur Wörter großlassen, die mit einem Nomen beginnen. Einfacher: die Momente umformulieren, sodass sie mit einem Nomen anfangen („Seltene Kreatur erlegt“ → „Rarität erlegt“) |
| Tagesaufgabe | `Betritt %s.` | „Betritt Sümpfe des Elends“, „Betritt Östliche Pestländer“ | Im Code `WFD:Place(name, "to")` nutzen, Text `Reise %s.` → „Reise in die Sümpfe des Elends“, „Reise nach Westfall“ |
| Nachruf | `Gefallen: %s` | „Gefallen: Goldhain, Wald von Elwynn“ wirkt wie ein Formularfeld | `Gefallen in %s` |
| Suche, Tooltip | `Tage, Personen, Kreaturen, Quests und Orte.` | Schätze und Fänge fehlen (die Einführung nennt sie schon) | `Tage, Personen, Kreaturen, Quests, Orte, Schätze und Fänge.` (englischer Schlüssel ebenso) |

## 2. Uneinheitliche Begriffe

**Ehre / Ehren / Ehrung.** „Ehre“ ist im Deutschen nicht zählbar. „%d Ehren“ und „Nächste Ehren“ klingen falsch.
Vorschlag: durchgehend **Ehrung / Ehrungen** (so steht es auch schon im CurseForge-Changelog).

| Jetzt | Vorschlag |
|---|---|
| Ehre errungen: %s | Ehrung erhalten: %s |
| Ehre errungen (Pop-up) | Neue Ehrung |
| Erste Ehre | Erste Ehrung |
| Nächste Ehren | Nächste Ehrungen |
| Manche Ehren bleiben verborgen … | Manche Ehrungen bleiben verborgen … |
| Wichtig: … Dungeons, Ehren und Briefe. | … Dungeons, Ehrungen und Briefe. |
| … den Ehren, die ihrer nächsten Stufe am nächsten sind | … den Ehrungen, die kurz vor der nächsten Stufe stehen |
| errungen (in der Stufenliste) | erreicht |
| %d Stufen errungen | %d Stufen erreicht |

**Töten.** Durcheinander stehen „erschlagen“, „erlegt“, „besiegt“ und „Kills“. „Erschlagen“ passt nicht zu Magiern und Jägern.
Vorschlag: In Sätzen immer **erlegen**, Bosse **besiegen**, in kurzen Zahlenfeldern darf „Kills“ bleiben.

| Jetzt | Vorschlag |
|---|---|
| Insgesamt %d Kreaturen erschlagen | Insgesamt %d Kreaturen erlegt |
| Erschlage %d Kreaturen. / … derselben Art. / … Elitekreaturen. / … an einem einzigen Tag. | Erlege … |
| Erschlagen (Kachel) | Erlegt |
| %d-mal erschlagen | %d-mal erlegt |
| Hier erschlagen | Hier erlegt |
| Von dir erschlagen | Von dir erlegt |
| Du hast sie %d-mal erschlagen. | Du hast sie %d-mal erlegt. |
| Gegner besiegt (Export) | Gegner erlegt |

**Laufen/Wandern, Fliegen.**

| Jetzt | Vorschlag |
|---|---|
| Wandere heute %d Kilometer. / Wandere %d Kilometer. / Wandere diese Woche … | Lauf heute %d Kilometer. / Lauf %d Kilometer. / Lauf diese Woche … (wie „Lauf heute einen Kilometer.“) |
| Unternimm %d Flüge. / Nimm einen Flug. | Flieg %d-mal. / Flieg einmal. (kein „Greif“: die Horde fliegt Windreiter) |

**Doppelte Schlüssel** (der spätere Eintrag gewinnt; der frühere kann weg):
- `Ledger` = „Bilanz“, später „Kassenbuch“
- `Richest day` = „Reichster Tag“, später „Einträglichster Tag“. **„Reichster Tag“ ist besser**, „einträglich“ klingt nach Steuerberater.
- `Defeat a boss.`, `Enter a dungeon.` doppelt mit gleichem Text

## 3. Typografie

- **Gedankenstrich statt Bindestrich** bei Einschüben und Spannen: „Stufe 5–9“, „Tage 3–7“, „Bis dahin bleibt der Brief zu – nicht mal du kannst ihn lesen.“. Das betrifft alle ` - ` in deDE (Sprüche, Hinweise, Tooltips, „Demo-Modus ist an …“).
- **Deutsche Anführungszeichen.** Ein Teil der Texte nutzt schon „ “, andere noch `"…"` (Nachruf-Spruch, Randnotizen der Kreaturen, Zitate im Tagebuch). Vorschlag: `loc.quotes = { "„", "“" }` in deDE setzen, dann stimmen auch die O-Töne der Questgeber; die festen Texte direkt umstellen.
- **Auslassungspunkte**: „…“ statt „...“ (Platzhalter in der Suche, Briefanfang, geheime Ehrungen).

## 4. Erzähler (Tagebuchtext)

| Jetzt | Anmerkung | Vorschlag |
|---|---|---|
| Tag 1. Ich bin %s und %s, und heute bin ich %s aufgewacht. | „Ich bin Mensch und Kriegerin“ holpert | Tag 1. %s, %s, heute %s aufgewacht. Was jetzt kommt? Keine Ahnung. |
| Tag 1. %s, %s, gerade erst angekommen %s. | Wortstellung | Tag 1. %s, %s, gerade erst %s angekommen. |
| {Ein Gegner ist\|%d Gegner sind} durch meine Hand gefallen. | Pathos, widerspricht dem lockeren Ton | {Einen Gegner\|%d Gegner} erledigt. |
| Nicht vergessen will ich: %s. | gestelzt | Das merke ich mir: %s. |
| Die meisten Einnahmen: %s (%s). | „Die meisten Einnahmen: Beute“ | Am meisten brachte %s ein (%s). |
| %s unterwegs gewesen. Jetzt reicht's. | „3 Std. 20 Min. unterwegs gewesen“: Abkürzungen im Fließtext | Text ok; im Code für den Erzähler ausgeschriebene Dauer („gut drei Stunden“) |
| Ein Brief aus der Vergangenheit ist aufgegangen. | „aufgegangen“ klingt nach Naht | Ein Brief aus der Vergangenheit hat sich geöffnet. |

## 5. Oberfläche, einzelne Stellen

| Jetzt | Vorschlag | Warum |
|---|---|---|
| In Gedenken | In memoriam | Üblich auf Grabsteinen und Nachrufen; „In Gedenken“ wirkt abgebrochen |
| Gefallen durch %s | Getötet von %s | „gefallen durch“ ist kein Deutsch |
| kennengelernt %s | kennengelernt am %s | Es folgt ein Datum |
| Zuerst erlegt an Tag %d | Zum ersten Mal erlegt an Tag %d | |
| Wer deiner Klinge erlag, nach Art | Was du erlegt hast, nach Typ | Pathos; Magier haben keine Klinge |
| Erlege 50 einer Art. | Erlege 50 Kreaturen einer Art. | |
| Aller Fänge (Kachel unter „12 %“) | Anteil aller Fänge | |
| Meist gefangen in %s | Meist gefangen %s (mit `WFD:Place`) | „in Sümpfe des Elends“ |
| Längste Zeit ohne Tod | Längste Serie ohne Tod | Es sind Tage am Stück |
| Brief versiegeln und öffnen ... | Versiegeln und öffnen … | Darunter stehen „in einer Woche / in einem Monat / auf Stufe 20“ |
| Gesprochen mit (Export: „People spoken to“) | Gesprächspartner | „Gesprochen mit: 5“ |
| Wo die guten Sachen wachsen (Fundorte) | Wo es was zu holen gibt | Erz und Felle wachsen nicht |
| Plündere %d Gegenstände. | Sammle %d Gegenstände ein. | „Plündern“ klingt nach Überfall |
| Klicken für den Steckbrief. / Klicken zeigt nur diese. / Klicken schlägt auf … | einheitlich: „Klicken: Steckbrief“, „Klicken: nur diese zeigen“ … | Drei verschiedene Satzbaumuster für dasselbe |

## 6. Englisch (Quelltexte), kurz

- `{One enemy|%d enemies} fell by my hand.` – gleiches Pathos-Problem. → `Took down {one enemy|%d enemies}.`
- `Who fell to your blade, by kind` → `What you've slain, by type`.
- `Fell to %s` → `Killed by %s`.
- `Days, people, creatures, quests and places.` → Schätze und Fänge ergänzen.
- Ungenutzte Schlüssel aus der alten Oberfläche (`The bookmarks …`, `The spyglass … quests and places.`, Statistik-Reiter) können aus allen Sprachdateien raus.

## Was ich bei Umsetzung beachten würde

- Jede Änderung an einem **englischen** Schlüssel muss in alle 7 Sprachdateien.
- Die Tagebuchsätze werden beim Sprachwechsel nacherzählt (`Retell.lua`). Ändert sich ein gespeicherter Satz (z. B. „Ehre errungen: %s“), gehört die alte deutsche Fassung in `LEGACY.deDE`, sonst erkennt das Addon alte Einträge nicht mehr.
