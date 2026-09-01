#!/usr/bin/env python3
"""Enumerate every named function, method and state variable the DESIGN declares.

The gap this fills: check_authored/check_rendered key on STRINGS, reconcile_audit keys
on AUDIT findings, check_citations keys on doc citations. A behaviour with no string and
no audit finding is invisible to all four — which is how TURN IT's three-face turn and
#carry stayed hidden. This keys on DECLARATIONS instead.
"""
import re, json, pathlib, collections
ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = [ROOT/"Claude Design Round 2"/"design-source", ROOT/"Claude Design Round 2"/"comps", ROOT/"canon"]

PATS = [
 ("function",  re.compile(r'\bfunction\s+([A-Za-z_$][\w$]*)\s*\(')),
 ("method",    re.compile(r'^\s*([A-Za-z_$][\w$]*)\s*:\s*function\s*\(', re.M)),
 ("assigned",  re.compile(r'\b([A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*)*)\s*=\s*function\s*\(')),
 ("arrow",     re.compile(r'\b(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:async\s*)?\([^)]*\)\s*=>')),
 ("state",     re.compile(r'^\s*(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=', re.M)),
 ("thisprop",  re.compile(r'\bthis\.([A-Za-z_$][\w$]*)\s*=')),
 ("shorthand", re.compile(r'^\s{2,}([A-Za-z_$][\w$]*)\s*\([^)]*\)\s*\{', re.M)),
]
NOISE = {"if","for","while","switch","catch","return","function","else","do","try",
         "typeof","new","var","let","const","this","true","false","null","undefined"}

out = {}
for base in SRC:
    if not base.exists(): continue
    for p in sorted(base.rglob("*")):
        if p.suffix.lower() not in (".js", ".html"): continue
        text = p.read_text(encoding="utf-8", errors="replace")
        if p.suffix.lower() == ".html":
            text = " ".join(re.findall(r'<script\b[^>]*>(.*?)</script>', text, flags=re.S|re.I)) or text
        rel = str(p.relative_to(ROOT))
        lines = text.splitlines()
        for kind, pat in PATS:
            for m in pat.finditer(text):
                name = m.group(1)
                short = name.split(".")[-1]
                if short in NOISE or len(short) < 3: continue
                ln = text[:m.start()].count("\n") + 1
                key = (rel, name)
                if key not in out:
                    out[key] = {"file": rel, "name": name, "short": short,
                                "kind": kind, "line": ln,
                                "ctx": lines[ln-1].strip()[:110] if ln-1 < len(lines) else ""}
rows = sorted(out.values(), key=lambda r: (r["file"], r["line"]))
json.dump(rows, open(ROOT/"Tools"/"design-mechanisms.json", "w"), indent=0)
print(f"declarations: {len(rows)}  across {len({r['file'] for r in rows})} files")
print(" by kind:", dict(collections.Counter(r["kind"] for r in rows)))
for f, n in collections.Counter(r["file"] for r in rows).most_common(10):
    print(f"   {n:4d}  {f.split('/')[-1]}")
