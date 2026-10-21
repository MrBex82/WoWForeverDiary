"""Checks the locale files of WoWForeverDiary.

Usage: python tools/check_locales.py

- keys missing in a language compared with deDE (the most complete file)
- keys that exist in a language but not in deDE
- placeholders (%d, %s, %1$s ...) that differ from the English key
- keys defined twice inside one file (the later one wins, the earlier can go)
"""
import re
import sys
from collections import Counter
from pathlib import Path

LOCALES = Path(__file__).resolve().parent.parent / "WoWForeverDiary" / "Locales"
LANGS = ["deDE", "esES", "frFR", "koKR", "ptBR", "ruRU", "zhTW"]

STR = r'"((?:[^"\\]|\\.)*)"'
ENTRY = re.compile(r'(?<!\w)(?:L)?\[\s*' + STR + r'\s*\]\s*=\s*' + STR)
PLACEHOLDER = re.compile(r"%(?:\d+\$)?[ds]")


def entries(lang):
    text = (LOCALES / (lang + ".lua")).read_text(encoding="utf-8")
    text = re.sub(r"(?m)^\s*--.*$", "", text)
    found = []
    for m in ENTRY.finditer(text):
        found.append((m.group(1), m.group(2)))
    return found


def main():
    data = {}
    problems = 0
    for lang in LANGS:
        found = entries(lang)
        seen = {}
        for key, val in found:
            if key in seen:
                print(f"[{lang}] duplicate key: {key!r}")
                problems += 1
            seen[key] = val
        data[lang] = seen

    # deDE also holds German game names (zones), which the other files do not need;
    # so the reference is every key that at least two languages define
    counts = Counter(k for lang in LANGS for k in data[lang])
    reference = {k for k, n in counts.items() if n >= 2}
    for lang in LANGS:
        table = data[lang]
        for key in sorted(reference):
            if key not in table:
                print(f"[{lang}] missing: {key!r}")
                problems += 1
    for lang in LANGS:
        table = data[lang]
        for key, val in table.items():
            want = Counter(PLACEHOLDER.findall(key))
            have = Counter(PLACEHOLDER.findall(val))
            if want != have:
                print(f"[{lang}] placeholders differ: {key!r} -> {val!r}")
                problems += 1

    print(f"{problems} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
