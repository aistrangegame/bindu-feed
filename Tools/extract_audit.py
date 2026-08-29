#!/usr/bin/env python3
"""Extract every AUDIT.md finding into a machine-readable row.

Coverage, not status: this only pulls what the audit SAYS. Verdicts are added by
reconcile_audit.py (mechanical) and by hand (the residue).
"""
import re, json, pathlib
ROOT = pathlib.Path(__file__).resolve().parent.parent
t = ROOT.joinpath("AUDIT.md").read_text(encoding="utf-8")
lines = t.splitlines()

HEAD = re.compile(r'^\*\*([A-Z]\d+\.\d+)\s*—\s*(.+?)\*\*\s*(.*)$')
rows = []
for i, L in enumerate(lines):
    m = HEAD.match(L)
    if not m: continue
    fid, title, rest = m.group(1), m.group(2), m.group(3)
    # the body runs to the next blank-line-separated finding or heading
    body = [L]
    for nxt in lines[i+1:]:
        if HEAD.match(nxt) or nxt.startswith("#"): break
        body.append(nxt)
    blob = " ".join(body)
    sev = (re.search(r'SEV:\s*\**([A-Z]+)', blob) or [None, ""])[1]
    kind = (re.search(r'KIND:\s*([A-Z/\-]+)', blob) or [None, ""])[1]
    design = (re.search(r'DESIGN[:\s]+(.+?)(?:\s*\|\s*CODE|\s*\|\s*\*\*SEV|$)', blob) or [None, ""])[1]
    code = (re.search(r'CODE[:\s]+(.+?)(?:\s*\|\s*\*\*SEV|$)', blob) or [None, ""])[1]
    cites = re.findall(r'`([A-Za-z0-9 _/.\-]+\.(?:swift|metal|js|html)):(\d+)', blob)
    rows.append({"id": fid, "line": i+1, "sev": sev, "kind": kind,
                 "title": re.sub(r'\s+', ' ', title).strip(),
                 "design": re.sub(r'\s+', ' ', design).strip()[:400],
                 "code": re.sub(r'\s+', ' ', code).strip()[:400],
                 "cites": [f"{a}:{b}" for a, b in cites][:6]})
json.dump(rows, open(ROOT/"Tools"/"audit-findings.json", "w"), indent=0)
import collections
print(f"findings: {len(rows)}")
print(" by sev :", dict(collections.Counter(r['sev'] or '(none)' for r in rows)))
print(" by sect:", dict(collections.Counter(r['id'][0] for r in rows)))
print(" with a swift/metal citation:", sum(1 for r in rows if any('.swift' in c or '.metal' in c for c in r['cites'])))
