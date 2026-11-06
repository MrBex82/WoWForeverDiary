# 0.3.2

Fixes: "New land" once per land, no more errors from protected game texts, no strangers from battlegrounds among the companions.

## English

**Fixed**
- The note "New land" came again and again after a start (for example Dun Morogh when leaving the starting building). A land is now announced once, even when its stored name is changed afterwards.
- Error messages "attempt to ... a secret string value": the game protects some chat lines and unit details in certain situations. The diary now skips them instead of failing (chat lines, creatures under the mouse).

**Companions**
- In battlegrounds and arenas no companions are recorded any more, and nobody there is credited with kills.
- "/wfd cleanup" shows which companions would be removed (strangers met once in a group, without a kill, or last seen in a battleground). "/wfd cleanup yes" removes them. There is no way back, so look at the names first.

## Deutsch

**Behoben**
- Die Meldung „Neues Land“ kam nach dem Start immer wieder (zum Beispiel Dun Morogh beim Verlassen des Startgebäudes). Ein Gebiet wird jetzt nur einmal gemeldet, auch wenn sein gespeicherter Name später geändert wird.
- Fehlermeldungen „attempt to ... a secret string value“: Das Spiel schützt manche Chatzeilen und Angaben zu Einheiten in bestimmten Lagen. Das Tagebuch überspringt sie jetzt, statt zu scheitern (Chatzeilen, Kreaturen unter der Maus).

**Gefährten**
- In Schlachtfeldern und Arenen werden keine Gefährten mehr erfasst, und dort bekommt niemand Kills gutgeschrieben.
- „/wfd cleanup“ zeigt, welche Gefährten entfernt würden (Fremde, die du einmal in einer Gruppe ohne Kill getroffen hast, oder zuletzt im Schlachtfeld gesehen). „/wfd cleanup yes“ entfernt sie. Es gibt kein Zurück, schau dir deshalb zuerst die Namen an.
