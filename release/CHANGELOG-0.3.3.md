# 0.3.3

Fixes: no more error messages in dungeons ("secret values"), and the weekly look back is readable and can be switched off in its window.

## English

**Fixed**
- Inside dungeons and other instances the game hides many unit details (names, IDs, health, who is dead). The diary showed error messages in the chat as soon as you pulled something ("attempt to index a secret value", "string conversion on a secret string value", "indexed assignment ... secret keys"). Every place that reads such details now checks them first and skips the event instead of failing. Messages of this kind are no longer printed in the chat at all.
- Kill tracking, group deaths and the companion list work with the hidden values; what the game hides is simply not recorded.

**Weekly look back**
- The window is taller: the buttons no longer lie on top of each other (in German the button texts are long), and the last line no longer runs into them.
- The labels of the figures may take two lines instead of being cut off. Long lists (honours, new regions) show the full text when you point at them.
- New button "Do not show again" in the window. The same switch is still in the options ("Weekly look back at login").

## Deutsch

**Behoben**
- In Dungeons und anderen Instanzen versteckt das Spiel viele Angaben zu Einheiten (Namen, Kennungen, Gesundheit, wer tot ist). Das Tagebuch zeigte im Chat Fehlermeldungen, sobald man etwas anzog („attempt to index a secret value“, „string conversion on a secret string value“, „indexed assignment ... secret keys“). Jede Stelle, die solche Angaben liest, prüft sie jetzt zuerst und überspringt das Ereignis, statt zu scheitern. Meldungen dieser Art erscheinen gar nicht mehr im Chat.
- Kill-Erkennung, Tode in der Gruppe und die Gefährtenliste kommen mit den versteckten Werten zurecht; was das Spiel versteckt, wird einfach nicht erfasst.

**Wochenrückblick**
- Das Fenster ist höher: Die Knöpfe liegen nicht mehr übereinander (im Deutschen sind die Texte lang), und die letzte Zeile läuft nicht mehr in sie hinein.
- Die Beschriftungen der Kennzahlen dürfen zwei Zeilen haben, statt abgeschnitten zu werden. Lange Listen (Ehrungen, neue Regionen) zeigen den ganzen Text, wenn man darauf zeigt.
- Neuer Knopf „Nicht mehr zeigen“ im Fenster. Derselbe Schalter steht weiter in den Optionen („Wochenrückblick beim Einloggen“).
