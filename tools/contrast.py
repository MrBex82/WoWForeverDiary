"""Contrast of every kind of writing on every surface, in every style (WCAG ratio; 4.5 is the aim for text,
3 for large headings and figures). Reads the tokens from UI/Design/Tokens.lua.

Usage: python tools/contrast.py
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "WoWForeverDiary"
src = (ROOT / "UI" / "Design" / "Tokens.lua").read_text(encoding="utf-8")


def themes():
    out = {}
    body = src[src.index("local TOKENS = {"):src.index("UI.TOKENS = TOKENS")]
    for m in re.finditer(r"(\w+) = \{\n(.*?)\n    \},", body, re.S):
        vals = {}
        for k, a, b, c in re.findall(r"(\w+) = \{ ([\d.]+), ([\d.]+), ([\d.]+)", m.group(2)):
            vals[k] = (float(a), float(b), float(c))
        out[m.group(1)] = vals
    return out


def lum(c):
    def ch(v):
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = (ch(x) for x in c)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def ratio(a, b):
    la, lb = lum(a), lum(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


# text token, surfaces it stands on, the ratio it needs
PAIRS = [
    ("ink", ["shell", "card", "inset", "hover"], 4.5), ("soft", ["shell", "card", "inset"], 4.5),
    ("muted", ["card", "inset"], 4.5), ("title", ["card", "shell"], 3.0), ("gold", ["card", "inset"], 3.0),
    ("pos", ["card", "inset"], 3.0), ("neg", ["card", "inset"], 3.0), ("onGold", ["gold"], 4.5),
]
LEATHER_PARCHMENT = {"rail": (0.93, 0.87, 0.75), "railSoft": (0.84, 0.76, 0.62), "railMuted": (0.70, 0.62, 0.50),
                     "railGold": (0.88, 0.68, 0.30)}


def main():
    bad = 0
    for name, t in themes().items():
        for text, surfaces, need in PAIRS:
            for s in surfaces:
                r = ratio(t[text], t[s])
                flag = "" if r >= need else "   <-- too low"
                if flag:
                    bad += 1
                print(f"{name:10} {text:7} on {s:6} {r:5.2f} (needs {need}){flag}")
        # writing on the leather (register, head bar, side columns): dark leather, about the frame colour
        rails = LEATHER_PARCHMENT if name == "parchment" else {"rail": t["ink"], "railSoft": t["soft"],
                                                             "railMuted": t["muted"], "railGold": t["gold"]}
        leather = (0.20, 0.13, 0.08) if name in ("parchment", "codex") else t["panel"]
        for k, c in rails.items():
            need = 3.0 if k == "railGold" else 4.5
            r = ratio(c, leather)
            flag = "" if r >= need else "   <-- too low"
            if flag:
                bad += 1
            print(f"{name:10} {k:9} on leather {r:5.2f} (needs {need}){flag}")
    print(f"{bad} pair(s) below the aim")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
