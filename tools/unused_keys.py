"""Lists (and with --remove deletes) translation keys that no code mentions any more.

A key counts as used when it appears anywhere in the code as a string literal - also in a table of labels that is
looked up later (L[def.label]) - so only keys that are truly gone are listed.

Usage: python tools/unused_keys.py [--remove]
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_locales as cl  # noqa: E402

ROOT = cl.LOCALES.parent
LIT = re.compile(r'"((?:[^"\\]|\\.)*)"')


def main():
    remove = "--remove" in sys.argv
    literals = set()
    for f in list(ROOT.glob("UI/**/*.lua")) + list(ROOT.glob("Modules/*.lua")) + [ROOT / "Core.lua"]:
        for m in LIT.finditer(f.read_text(encoding="utf-8")):
            literals.add(cl.unescape(m.group(1)))
    keys = set(k for k, _ in cl.entries("deDE"))
    unused = sorted(k for k in keys if k not in literals)
    for k in unused:
        print(repr(k))
    print(f"{len(unused)} unused of {len(keys)}")
    if remove and unused:
        gone = set(unused)
        entry = re.compile(r'^L\[\s*"((?:[^"\\]|\\.)*)"\s*\]\s*=')
        for path in sorted(cl.LOCALES.glob("*.lua")):
            lines = path.read_text(encoding="utf-8").split("\n")
            kept = []
            for line in lines:
                m = entry.match(line)
                if m and cl.unescape(m.group(1)) in gone:
                    continue
                kept.append(line)
            path.write_text("\n".join(kept), encoding="utf-8", newline="\n")
        print("removed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
