# ENGLISH

> **Work in progress:** This addon is still being actively built. Things can change between versions, and now and then something may not work as it should. Your diary is kept safe across updates. If you notice anything, please leave a comment, it helps a lot.

**WoW Forever Diary** keeps a diary for your character, and you don't have to do anything for it. Log in, play, and the addon writes down what happened. At the end of the day there's an entry in plain sentences, like "Today I helped three people in Elwynn Forest, lost 40 copper to a vendor and died once to a Defias Pillager", instead of a table of numbers.

I made it because I never remember later where I first met someone, which quest took forever, or how long it's actually been since I started this character. Now it's all in a book I can flip through.

## What it records

- Every NPC you talk to and every quest you accept or hand in, including a line of what the quest giver said
- Kills, rare creatures, bosses, and deaths (plus the creature that keeps killing you)
- Gold, split by where it came from and where it went
- Loot, levels, zones, professions, flight paths, and your first time doing things (first mount, first dungeon, first gold coin ...)
- Dungeon runs: who came along, which bosses fell, what dropped
- Gathering spots for herbs, ore, skinning and fishing, shown on a map
- Your footsteps on the world map, which you can replay day by day
- Distance travelled and time online
- Group members, trade partners, and a place for the hardcore obituary if it comes to that

## What's in the book

- **Today:** the book opens on today: your figures so far, how the day began, what happened on this day a year ago (or two, or three), what's new since you last read, and your next goals
- **Diary:** a double page per day, written as a short story
- **World map:** where you've been, with a time slider. On the continent maps of the atlas, a play button lets your journey grow day by day, at 1x, 4x or 16x, and keeps the picture as a screenshot if you like
- **Bestiary and people:** pinned cards for creatures (like a wanted poster) and for NPCs. Creatures you've only seen so far, or that your other characters know, are listed per area with a hint where to look. Click one and it puts a marker on your map
- **Collector's album:** every creature card starts as a sketch, turns to colour after 10 kills and gets a gold frame once you're a connoisseur (50 kills). Cards show their rarity, the best loot it dropped, whether it ever killed you and a short note in your own words. There's a page sorted by creature type, an "Almost there" page with the creatures closest to their next stage, and a map of your hunting grounds that shows where you stand
- **Fate:** every death on the way: the graves on the map area by area, where and to whom you fall most, deaths by level, and the full list with day, place, foe and level
- **Angler's log:** everything the line brings up, collected on cards by water, with a page for your waters and tackle
- **Treasures:** every notable find, sorted by kind (head, chest, legs, weapons, recipes ...), with a doll showing your best find for every slot and a tick on what you're wearing
- **Quest book and statistics:** including the gold flow
- **Honours:** a collection with bronze to legend tiers, some of them secret, including fishing, first aid and cooking. There are small daily tasks, a bigger weekly one and a task of the month, all on one page
- **Time capsules:** write a letter to yourself that stays sealed until a certain day or level
- **Family book:** an overview of all your characters on the account and who got where first
- **Search** across everything in the book (Ctrl + F)
- **Export** as text or JSON if you want your diary somewhere else
- **Moving to a new PC:** a moving code takes the whole diary of a character to another computer ("/wfd export" and "/wfd import")

The parts of the book are grouped by theme. Each group has one tab in its own colour, which opens an overview of its parts. Point at a tab and a list of its parts opens beside it, so you can jump straight to one.

Small notes slide in when something worth remembering happens (a right-click puts them away), and you get a look back at the week. When you log in, a quiet note may remind you of this day in an earlier year, or of an anniversary: the diary's birthday, 100, 500 or 1000 hours in the world, a year since level 10, 20 ... 60. If you like, a small companion window beside the game (the introduction offers it) shows today's figures, your tasks and the honours and creatures closest to their next step.

The book comes in four styles (leather and gold, parchment, modern, strong contrast) and the writing can be made larger. The parchment style uses the light paper of the game's own quest frames, with torn edges and the stains of a hard life in its margins.

## Usage

"/wfd" (or "/diary", or the minimap button) opens and closes the book. You can also set a key for it in the key bindings under AddOns.

- Arrow keys and Page up/down turn the pages while the mouse is over the book; Home goes to the contents, End to today, Backspace back
- Ctrl + mouse wheel changes the size of the book, and it remembers where you put it
- Click a page number to jump to any page; click the folded corner of a page to set your own bookmark (twelve, each with a name)
- A line at the top of each page shows where you are; the steps before are links. "Continue reading" on the Today page leads back to where you stopped
- Ctrl + F searches the book; arrow keys and Enter pick a result
- The tabs show a red dot with what's new since you last read, and their names when you point at them
- Notifications can be set to all, important only, or quiet. All settings are also under Options > AddOns

- "/wfd bestiary", "/wfd honour", "/wfd ledger", "/wfd settings" and so on open the book at that part, "/wfd 12" at day 12
- "/wfd demo" fills the book with sample data, only in memory, so you can look around before you have a real diary
- "/wfd shot" turns screenshots at milestones on or off
- "/wfd minimap" shows or hides the minimap button
- "/wfd restore" brings back a diary that was put aside (for example after reading a moving code)

## Good to know

- Made for **WoW Forever**. It should also run on WoW Classic Era, but it has been played there much less. Data is stored per character in your SavedVariables and nothing leaves your computer.
- Characters you already play will start their diary from the moment you install it. Some "firsts" are filled in from what the addon can still work out, but it can't know the past.
- Available in English, German, French, Spanish, Portuguese, Russian, Korean and Traditional Chinese. The diary entries themselves are written in your game language too.
- It's still an early version. If something looks wrong or you have an idea, leave a comment or open a ticket. Translation fixes are welcome as well, I'm not a native speaker in most of these.

---

# DEUTSCH

> **Work in Progress:** Dieses Addon wird noch aktiv weiterentwickelt. Zwischen den Versionen kann sich einiges ändern, und hin und wieder funktioniert vielleicht etwas noch nicht wie gedacht. Dein Tagebuch bleibt bei Updates erhalten. Wenn dir etwas auffällt, schreib gern einen Kommentar, das hilft sehr.

**WoW Forever Diary** führt ein Tagebuch für deinen Charakter, ohne dass du etwas dafür tun musst. Einloggen, spielen, und das Addon schreibt mit. Am Ende des Tages steht ein Eintrag in ganz normalen Sätzen da, zum Beispiel "Heute habe ich drei Leuten im Wald von Elwynn geholfen, 40 Kupfer an einen Händler verloren und bin einmal an einem Defias-Räuber gestorben", statt einer Tabelle voller Zahlen.

Ich habe es gebaut, weil ich mir später nie merke, wo ich jemanden zum ersten Mal getroffen habe, welche Quest ewig gedauert hat oder wie lange ich diesen Charakter eigentlich schon spiele. Jetzt steht das alles in einem Buch, in dem man blättern kann.

## Was aufgezeichnet wird

- Jeder NPC, mit dem du sprichst, jede angenommene und abgegebene Quest, samt einer Zeile davon, was der Questgeber gesagt hat
- Kills, seltene Gegner, Bosse und Tode (und der Gegner, der dich immer wieder erwischt)
- Gold, aufgeteilt nach Herkunft und Verwendung
- Beute, Stufenaufstiege, Zonen, Berufe, Flugrouten und deine ersten Male (erstes Reittier, erste Instanz, erstes Goldstück ...)
- Dungeon-Durchgänge: wer dabei war, welche Bosse gefallen sind, was gedroppt ist
- Sammelstellen für Kräuter, Erze, Häute und Fische, auf einer Karte dargestellt (die „Fundorte“)
- Deine Fußspuren auf der Weltkarte, die du Tag für Tag abspielen kannst
- Zurückgelegte Strecke und Online-Zeit
- Gruppenmitglieder, Handelspartner und, falls es dazu kommt, der Nachruf im Hardcore-Modus

## Was im Buch steht

- **Heute:** Das Buch öffnet bei heute: deine Zahlen bis jetzt, wie der Tag angefangen hat, was heute vor einem Jahr (oder zwei, drei) passiert ist, was seit dem letzten Lesen neu ist und deine nächsten Ziele
- **Tagebuch:** pro Tag eine Doppelseite, als kleine Geschichte geschrieben
- **Weltkarte:** wo du schon warst, mit Zeitregler. Auf den Kontinentkarten des Atlas lässt ein Abspielknopf deine Reise Tag für Tag wachsen, in 1x, 4x oder 16x, und hält das Bild auf Wunsch als Screenshot fest
- **Bestiarium und Personen:** angeheftete Karten für Kreaturen (wie ein Steckbrief) und für NPCs. Kreaturen, die du bisher nur gesehen hast oder die deine anderen Charaktere kennen, stehen pro Gebiet in einer Liste mit einem Hinweis, wo du suchen solltest. Ein Klick setzt eine Markierung auf deiner Karte
- **Sammelalbum:** Jede Kreaturenkarte beginnt als Skizze, wird nach 10 Kills farbig und bekommt einen Goldrahmen, sobald du Kenner bist (50 Kills). Die Karten zeigen ihre Seltenheit, die beste Beute, ob dich das Tier schon einmal erwischt hat, und eine kurze Notiz in deinen eigenen Worten. Dazu gibt es eine Seite nach Kreaturentypen, eine Seite „Fast geschafft“ mit den Kreaturen, die ihrer nächsten Stufe am nächsten sind, und eine Karte deiner Jagdgründe, die auch zeigt, wo du stehst
- **Schicksal:** jeder Tod unterwegs: die Gräber auf der Karte, Gebiet für Gebiet, wo und gegen wen du am häufigsten fällst, Tode nach Stufe und die ganze Liste mit Tag, Ort, Gegner und Stufe
- **Anglerbuch:** alles, was die Angel heraufholt, auf Karten gesammelt und nach Gewässern sortiert, mit einer Seite für Gewässer und Angelzeug
- **Schätze:** jeder bemerkenswerte Fund, nach Art sortiert (Kopf, Brust, Beine, Waffen, Rezepte ...), mit einer Ausrüstungspuppe, die deinen besten Fund für jeden Platz zeigt, und einem Häkchen an dem, was du gerade trägst
- **Questbuch und Statistik:** inklusive Gold-Fluss
- **Ehrungen:** eine Sammlung mit Stufen von Bronze bis Legende, einige davon geheim, auch für Angeln, Erste Hilfe und Kochen. Dazu kleine Tagesaufgaben, eine größere Wochenaufgabe und eine Monatsaufgabe, alle auf einer Seite
- **Zeitkapseln:** schreib dir selbst einen Brief, der bis zu einem bestimmten Tag oder Level versiegelt bleibt
- **Familienbuch:** alle Charaktere deines Accounts im Überblick, und wer was zuerst geschafft hat
- **Suche** durch alles, was im Buch steht (Strg + F)
- **Export** als Text oder JSON, falls du dein Tagebuch woanders haben willst
- **Umzug auf einen neuen PC:** ein Umzugs-Code nimmt das ganze Tagebuch eines Charakters auf einen anderen Rechner mit („/wfd export“ und „/wfd import“)

Die Teile des Buches sind nach Themen gruppiert. Jede Gruppe hat einen Reiter in ihrer eigenen Farbe, der eine Übersicht ihrer Teile öffnet. Zeigst du auf einen Reiter, klappt daneben eine Liste seiner Teile auf, und ein Klick führt dich direkt hin.

Wenn etwas Erinnerungswürdiges passiert, rutscht eine kleine Notiz ins Bild (ein Rechtsklick legt sie weg), und einmal pro Woche gibt es einen Rückblick. Beim Einloggen erinnert dich eine stille Notiz an diesen Tag in einem früheren Jahr oder an ein Jubiläum: den Geburtstag des Tagebuchs, 100, 500 oder 1000 Stunden in der Welt, ein Jahr seit Stufe 10, 20 ... 60. Wenn du magst, zeigt ein kleines Begleitfenster neben dem Spiel (die Einführung bietet es an) die Zahlen von heute, deine Aufgaben und die Ehrungen und Kreaturen, die ihrem nächsten Schritt am nächsten sind.

Das Buch gibt es in vier Stilen (Leder und Gold, Pergament, Modern, starker Kontrast), und die Schrift lässt sich vergrößern. Der Stil Pergament nutzt das helle Papier der Questfenster des Spiels, mit zerrissenen Rändern und den Flecken eines harten Lebens in den Rändern.

## Bedienung

„/wfd“ (oder „/tagebuch“, „/diary“ oder der Minimap-Button) öffnet und schließt das Buch. In der Tastaturbelegung unter AddOns kannst du dafür auch eine Taste festlegen.

- Pfeiltasten und Bild auf/ab blättern, solange die Maus über dem Buch ist; Pos1 führt zum Inhalt, Ende zum heutigen Tag, die Rücktaste zurück
- Strg + Mausrad ändert die Größe des Buches, und es merkt sich, wo du es hingeschoben hast
- Ein Klick auf die Seitenzahl springt zu jeder beliebigen Seite, ein Klick auf das Eselsohr einer Seite setzt ein eigenes Lesezeichen (zwölf, jedes mit Namen)
- Eine Zeile oben auf jeder Seite zeigt, wo du bist, die Schritte davor sind Links. „Weiterlesen“ auf der Heute-Seite führt dahin zurück, wo du aufgehört hast
- Strg + F durchsucht das Buch; Pfeiltasten und Enter wählen einen Treffer
- Die Reiter zeigen mit einem roten Punkt, was seit dem letzten Lesen neu ist, und ihre Namen, wenn du auf sie zeigst
- Meldungen lassen sich auf alle, nur Wichtiges oder still stellen. Alle Einstellungen gibt es auch unter Optionen > AddOns

- „/wfd bestiarium“, „/wfd ehrenbuch“, „/wfd kassenbuch“, „/wfd einstellungen“ und so weiter öffnen das Buch gleich an dem Teil, „/wfd 12“ am Tag 12
- „/wfd demo“ füllt das Buch mit Beispieldaten, nur im Speicher, damit du dich umsehen kannst, bevor du ein echtes Tagebuch hast
- „/wfd shot“ schaltet Screenshots bei Meilensteinen an oder aus
- „/wfd minimap“ blendet den Minimap-Button ein oder aus
- „/wfd restore“ holt ein beiseitegelegtes Tagebuch zurück (zum Beispiel nach dem Einlesen eines Umzugs-Codes)

## Gut zu wissen

- Gemacht für **WoW Forever**. Unter WoW Classic Era sollte es auch laufen, wurde dort aber deutlich weniger gespielt. Die Daten liegen pro Charakter in den SavedVariables, nichts verlässt deinen Rechner.
- Bei Charakteren, die du schon spielst, beginnt das Tagebuch ab der Installation. Einige "Erste Male" werden aus dem nachgetragen, was das Addon noch herausfinden kann, die Vergangenheit kennt es aber nicht.
- Verfügbar auf Deutsch, Englisch, Französisch, Spanisch, Portugiesisch, Russisch, Koreanisch und Traditionell Chinesisch. Auch die Tagebucheinträge selbst erscheinen in deiner Spielsprache.
- Es ist noch eine frühe Version. Wenn etwas komisch aussieht oder du eine Idee hast, schreib einen Kommentar oder ein Ticket. Korrekturen an den Übersetzungen sind ebenfalls willkommen, in den meisten dieser Sprachen bin ich kein Muttersprachler.

---

# TEASER (EN)

**WoW Forever Diary** writes a diary for your character while you play. Every NPC, quest, kill, coin and footstep is recorded, and each day ends up as a short entry in plain sentences. Flip through it in a book with a world map you can replay day by day, a bestiary, honours to collect, and time capsules for your future self. Made for WoW Forever. Everything stays on your computer. Type "/wfd" to open it.

# TEASER (DE)

**WoW Forever Diary** schreibt ein Tagebuch für deinen Charakter, während du spielst. Jeder NPC, jede Quest, jeder Kill, jede Münze und jeder Schritt wird festgehalten, und aus jedem Tag wird ein kurzer Eintrag in normalen Sätzen. Du blätterst in einem Buch mit Weltkarte, die du Tag für Tag abspielen kannst, mit Bestiarium, Ehrungen zum Sammeln und Zeitkapseln für dein späteres Ich. Gemacht für WoW Forever. Alles bleibt auf deinem Rechner. Mit „/wfd“ öffnest du es.

---

# DISCLAIMER

WoW Forever Diary is an unofficial fan-made addon. It is not affiliated with or endorsed by Blizzard Entertainment. World of Warcraft is a trademark of Blizzard Entertainment, Inc. Names of group members and trade partners are saved, but only in your own saved variables and in the moving code you create yourself.
