#!/usr/bin/env python3
"""Gather mechanical evidence per audit finding. No verdicts — evidence only."""
import json, re, pathlib
ROOT = pathlib.Path(__file__).resolve().parent.parent
APP = ROOT/"Bindu Feed"/"Bindu Feed"
rows = json.load(open(ROOT/"Tools"/"audit-findings.json"))

files = {}
for p in APP.rglob("*"):
    if p.suffix in (".swift", ".metal"):
        files.setdefault(p.name, []).append(p)
appblob = "\n".join(p.read_text(encoding="utf-8", errors="replace")
                    for n in files for p in files[n]).lower()

def at(cite):
    name, ln = cite.rsplit(":", 1)
    name = pathlib.Path(name).name
    for p in files.get(name, []):
        L = p.read_text(encoding="utf-8", errors="replace").splitlines()
        i = int(ln) - 1
        if 0 <= i < len(L):
            return f"{p.relative_to(ROOT)}:{ln} → {L[i].strip()[:120]}"
        return f"{p.relative_to(ROOT)}:{ln} → (file has {len(L)} lines; cite out of range)"
    return f"{name}:{ln} → FILE NOT FOUND in app"

# identifiers/strings the finding names, tested against the app
TOK = re.compile(r'`([A-Za-z_][A-Za-z0-9_]{3,40})`')
for r in rows:
    ev = []
    for c in r["cites"]:
        if c.endswith(tuple(str(i) for i in range(10))) and (".swift" in c or ".metal" in c):
            ev.append(at(c))
    toks = set(TOK.findall(r["design"] + " " + r["code"] + " " + r["title"]))
    toks = {t for t in toks if not t.endswith(("swift","metal","js","html"))}
    present = sorted(t for t in toks if t.lower() in appblob)
    absent  = sorted(t for t in toks if t.lower() not in appblob)
    r["evidence"] = ev[:4]
    r["symbols_present"] = present[:8]
    r["symbols_absent"] = absent[:8]
json.dump(rows, open(ROOT/"Tools"/"audit-findings.json", "w"), indent=0)
n_abs = sum(1 for r in rows if r["symbols_absent"] and not r["symbols_present"])
print(f"evidence gathered for {len(rows)} findings")
print(f"  findings where EVERY named symbol is absent from the app: {n_abs}")
print(f"  findings with a resolvable code citation: {sum(1 for r in rows if r['evidence'])}")
