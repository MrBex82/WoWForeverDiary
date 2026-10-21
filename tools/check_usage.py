"""Checks that every text the code asks for is translated.

Usage: python tools/check_usage.py

- keys used in the code as L["..."] that some language file lacks (they would show in English)
Names of places, items and creatures come from the game and are not looked at here.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_locales as cl  # noqa: E402

ROOT = cl.LOCALES.parent
USED = re.compile(r'\bL\[\s*"((?:[^"\\]|\\.)*)"\s*\]')


def main():
    used = {}
    files = list(ROOT.glob("UI/*.lua")) + list(ROOT.glob("Modules/*.lua")) + [ROOT / "Core.lua"]
    for f in files:
        for m in USED.finditer(f.read_text(encoding="utf-8")):
            used.setdefault(cl.unescape(m.group(1)), f.name)
    data = {lang: dict(cl.entries(lang)) for lang in cl.LANGS}
    problems = 0
    for key, src in sorted(used.items()):
        absent = [lang for lang in cl.LANGS if key not in data[lang]]
        if absent:
            print(f"missing in {','.join(absent)}: {key!r} ({src})")
            problems += 1
    print(f"{len(used)} keys used, {problems} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
