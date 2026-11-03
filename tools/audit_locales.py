import re, subprocess
ROOT = r"D:\Git\WoW_Forever_Diary"
LOC = ROOT + r"\WoWForeverDiary\Locales"
LANGS = ["deDE", "esES", "frFR", "koKR", "ptBR", "ruRU", "zhTW"]
DQ = r'"((?:[^"\\]|\\.)*)"'
ENTRY = re.compile(r'(?<!\w)(?:L)?\[\s*' + DQ + r'\s*\]\s*=\s*' + DQ)

def entries(path_text):
    text = re.sub(r"(?m)^\s*--.*$", "", path_text)
    return {m.group(1): m.group(2) for m in ENTRY.finditer(text)}

def at(rev, lang):
    out = subprocess.run(["git", "-C", ROOT, "show", f"{rev}:WoWForeverDiary/Locales/{lang}.lua"],
                         capture_output=True, text=True, encoding="utf-8")
    return out.stdout

base = "backup-vor-ux-umbau"
newkeys = None
data = {}
for lang in LANGS:
    now = entries(open(f"{LOC}\\{lang}.lua", encoding="utf-8").read())
    old = entries(at(base, lang))
    data[lang] = (now, old)
keys_new = set(data["deDE"][0]) - set(data["deDE"][1])
print("new keys in deDE since the UX backup:", len(keys_new))
for lang in LANGS:
    now, old = data[lang]
    missing = sorted(k for k in keys_new if k not in now)
    same = sorted(k for k in keys_new if k in now and now[k] == k)
    print(lang, "missing:", len(missing), "same as English:", len(same))
    for k in missing + same:
        print("   ", k[:90])
