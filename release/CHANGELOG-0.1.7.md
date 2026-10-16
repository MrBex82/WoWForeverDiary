# 0.1.7

## English

**Fixes**
- Uncommon (green), rare (blue) and epic items were not recognised on newer game clients, so every item counted as white. Items are now read correctly, and older diaries are corrected once when you log in: the first green/blue item, the "Rare find" entries and the honours are filled in quietly.
- Repeatable quests were counted twice when accepted again, and giving them up was not noticed.
- Gathering spots stopped being recorded after 3000 gathers. Each map now keeps its latest 500 spots, and the totals per kind keep counting. Fish are now counted reliably.
- Today's entry no longer says "Time for a break" or "Not much happened" while the day has only just begun.
- Kills that were first noted only by name are merged with the creature once it is seen.

**Safety**
- A diary is never thrown away any more: if it belongs to an earlier character of the same name, or is replaced by a moving code, it is put aside. "/wfd restore" brings it back.
- Moving codes are checked before they are read, so a damaged or foreign code can no longer freeze the game or break the diary.

**Smaller things**
- Smoother play in groups and raids, and the open book is laid out less often.
- Screenshot file names follow the format set in the game; the JSON export writes large numbers correctly; the 3D portrait no longer keeps turning after the page is turned; characters that already had gold no longer get all wealth milestones at once.

## Deutsch

**Fehlerbehebungen**
- Ungewöhnliche (grüne), seltene (blaue) und epische Gegenstände wurden in neueren Spielclients nicht erkannt, alles zählte als weiß. Jetzt wird die Qualität richtig gelesen, und ältere Tagebücher werden beim Einloggen einmal korrigiert: das erste grüne/blaue Item, die Einträge „Seltener Fund“ und die Ehrungen werden still nachgetragen.
- Wiederholbare Quests wurden beim erneuten Annehmen doppelt gezählt, und ein Abbruch wurde nicht erkannt.
- Sammelstellen wurden nach 3000 Sammelvorgängen nicht mehr aufgezeichnet. Jede Karte behält jetzt ihre letzten 500 Stellen, die Zählung pro Art läuft weiter. Fische werden jetzt zuverlässig gezählt.
- Der Eintrag des heutigen Tages sagt nicht mehr „Jetzt erst mal Pause“ oder „Heute ist nicht viel passiert“, wenn der Tag gerade erst begonnen hat.
- Kills, die zuerst nur mit Namen erfasst wurden, werden mit der Kreatur zusammengeführt, sobald sie gesehen wird.

**Sicherheit**
- Ein Tagebuch wird nie mehr verworfen: Gehört es einem früheren Charakter mit gleichem Namen oder wird es durch einen Umzugs-Code ersetzt, wird es beiseitegelegt. „/wfd restore“ holt es zurück.
- Umzugs-Codes werden vor dem Einlesen geprüft, ein beschädigter oder fremder Code kann das Spiel nicht mehr einfrieren oder das Tagebuch kaputt machen.

**Kleinigkeiten**
- Flüssiger in Gruppen und Raids, und das offene Buch wird seltener neu aufgebaut.
- Screenshot-Dateinamen folgen dem im Spiel eingestellten Format; der JSON-Export schreibt große Zahlen richtig; das 3D-Porträt dreht nach dem Umblättern nicht mehr weiter; Charaktere mit vorhandenem Gold bekommen nicht mehr alle Wohlstands-Meilensteine auf einmal.
