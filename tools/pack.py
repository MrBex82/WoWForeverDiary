import zipfile, os
os.chdir(r"D:\Git\WoW_Forever_Diary")
old = set(zipfile.ZipFile("release/WoWForeverDiary-0.2.5.zip").namelist())
out = "release/WoWForeverDiary-0.3.0.zip"
names = []
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for root, d, files in os.walk("WoWForeverDiary"):
        for f in sorted(files):
            p = os.path.join(root, f).replace(os.sep, "/")
            z.write(p, p)
            names.append(p)
new = set(names)
print(len(old), len(new))
print("only old:", sorted(x for x in old if not x.endswith("/") and x not in new))
print("only new:", sorted(new - old))
print(os.path.getsize(out))
