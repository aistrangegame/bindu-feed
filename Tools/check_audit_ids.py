#!/usr/bin/env python3
"""THE FOURTH DRIFT CHECK — audit-ID attribution, which nothing else greps.

`check_authored` catches a drifted authored string, `check_rendered` an invented rendered
one, `check_citations` a drifted `file:line` quote. **None of them can see a doc that names
the WRONG FINDING**, because an audit ID is not a citation and not a quote — it is a
cross-reference, and a wrong one reads exactly like a right one.

That failed three times in `8-ACTION-PLAN.md`, and only the third was ever caught by a person:

  · Stage D said *"seven instances, eight cues"*; the design has five and four.
  · B1 said *"19 call sites inherit the fix"* — true, and it hid that 10 of them inherited
    the WRONG VOICE along with the right ceiling.
  · F1 attributed `renderAnswers` to **E3.2**, which is the RINGS LIST. `renderAnswers` is in
    a comp and is a different mechanism entirely.

Only the third is mechanically checkable, and this is the tool for it: every `Audit X.Y` in
every doc must resolve to a real finding in `AUDIT.md`, and the finding's own opening words
are printed beside the claim so a mis-attribution is visible rather than plausible.

  ./Tools/check_audit_ids.py            enforce (exit 1 on an ID that does not exist)
  ./Tools/check_audit_ids.py --list     print every reference with the finding it names
"""
import re, sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from authored_lib import ROOT

DOCS = [ROOT/"Bindu Feed"/"CLAUDE.md", ROOT/"HANDOFF-NOTE.md", ROOT/"OPEN-ITEMS.md",
        ROOT/"Coverage"/"7-STATE-OF-THE-BUILD.md", ROOT/"Coverage"/"8-ACTION-PLAN.md",
        ROOT/"Coverage"/"9-BOWL-CALL-SITE-MAP.md", ROOT/"Coverage"/"10-OWED.md"]
SRC = [ROOT/"Bindu Feed"/"Bindu Feed"]

AUDIT = ROOT/"AUDIT.md"
# `**E3.2 — the Rings movement has no rings list** — DESIGN: …`
FINDING = re.compile(r'^\*\*([A-Z]+[0-9]+\.[0-9]+)\s*[—-]\s*(.{0,90})', re.M)
# "Audit E3.2", "AUDIT G3.3", "*Audit D5.8*", "`AUDIT D5.8`"
REF = re.compile(r'\b[Aa][Uu][Dd][Ii][Tt]\.?[a-z]*\s+([A-Z]+[0-9]+\.[0-9]+)')

def findings():
    out = {}
    if not AUDIT.exists(): return out
    for m in FINDING.finditer(AUDIT.read_text(encoding="utf-8", errors="replace")):
        out.setdefault(m.group(1), m.group(2).strip())
    return out

def main():
    known = findings()
    if not known:
        print("AUDIT.md has no findings — cannot check attribution"); return 1
    refs, missing = [], []
    for base in DOCS + SRC:
        files = [base] if base.is_file() else sorted(
            p for p in base.rglob("*") if p.suffix in (".swift", ".md"))
        for f in files:
            if not f.exists(): continue
            for i, line in enumerate(f.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
                for m in REF.finditer(line):
                    fid = m.group(1)
                    where = f"{f.relative_to(ROOT)}:{i}"
                    (refs if fid in known else missing).append((where, fid, line.strip()[:78]))

    print(f"audit refs {len(refs) + len(missing)} · resolved {len(refs)} · UNKNOWN {len(missing)}")
    for where, fid, line in missing:
        print(f"  UNKNOWN ID  {fid}  {where}\n              {line}")
    if "--list" in sys.argv:
        print("\n── every reference, beside the finding it names ──")
        for where, fid, line in refs:
            print(f"  {fid}  {where}\n      claim:   {line}\n      finding: {known[fid]}")
    # An ID that does not exist is a hard failure. An ID that exists but names the wrong
    # thing cannot be decided mechanically — `--list` puts the two side by side so a person
    # can, which is the same bargain `check_citations` makes with its uncheckable rows.
    return 1 if missing else 0

sys.exit(main())
