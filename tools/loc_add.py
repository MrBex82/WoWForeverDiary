import sys, json
ROOT = r"D:\Git\WoW_Forever_Diary\WoWForeverDiary\Locales"
data = json.load(open(sys.argv[1], encoding="utf-8"))
keys = data["keys"]
for lang, vals in data["tr"].items():
    assert len(vals) == len(keys), lang
    p = ROOT + "\\" + lang + ".lua"
    s = open(p, encoding="utf-8").read()
    if not s.endswith("\n"):
        s += "\n"
    for k, v in zip(keys, vals):
        s += 'L["%s"] = "%s"\n' % (k, v.replace('"', '\\"'))
    open(p, "w", encoding="utf-8", newline="\n").write(s)
print("ok")
