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

  ./Tools/check_audit_ids.py            enforce (unknown ID, or an OPEN finding cited as settled)
  ./Tools/check_audit_ids.py --list     print every reference with the finding it names

AND THE SECOND CHECK, ADDED 2026-08-29: **AGREEMENT, NOT ONLY EXISTENCE.**

A ledger paragraph and an OPEN audit row asserted opposite things for a full stage, and the
ledger won because it was the more recent document. `Coverage/10-OWED.md` §7 said the design
plays a threshold at every register; `AUDIT C7.11` said that tone is INVENTED and was open the
whole time. Nothing compared them, so the wrong one survived long enough to become the premise
of a ruling.

An ID resolving is not agreement. So every reference now carries its finding's CURRENT status
from `Coverage/1-AUDIT-254.md`, and **citing a still-OPEN finding as though it were settled is
a failure**: a doc may cite an open row to say *it is open*, and may not cite one as evidence
for how the app behaves. The status word must appear near the citation — OPEN, PARTIAL,
CLOSED, or an explicit `still open` / `unfixed` — or the reference is unqualified and fails.

Semantic contradiction is not mechanically decidable and this does not pretend otherwise; what
IS decidable is whether a doc noticed the row was open, and that is the half that failed here.
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

STATUS = re.compile(r'^\|\s*([A-Z]+[0-9]+\.[0-9]+)\s*\|[^|]*\|[^|]*\|[^|]*\|\s*([^|]+?)\s*\|')

def statuses():
    """Each finding's CURRENT verdict, from the register that tracks it."""
    out = {}
    led = ROOT/"Coverage"/"1-AUDIT-254.md"
    if not led.exists(): return out
    for line in led.read_text(encoding="utf-8", errors="replace").splitlines():
        m = STATUS.match(line)
        if not m: continue
        v = m.group(2).strip().strip("*").upper()
        out[m.group(1)] = ("OPEN" if v == "OPEN"
                           else "PARTIAL" if "PARTIAL" in v
                           else "CLOSED" if "CLOSED" in v else v)
    return out

# Words that show the citing text KNOWS the row is unresolved. A doc may cite an open finding
# to say it is open; it may not cite one as evidence for how the app behaves.
QUALIFIED = re.compile(r'open|unfixed|not fixed|still|absent|missing|blocked|owed|remains|'
                       r'to do|outstanding|unresolved|partial|unbuilt|never built',
                       re.I)

def main():
    known = findings()
    state = statuses()
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

    # A PLAN CITES OPEN ROWS BY DEFINITION — that is what a plan is for, and flagging it is
    # noise that would train the reader to ignore this check. First run flagged 8 and 4 were
    # `8-ACTION-PLAN.md` doing its job. The target is a document asserting how the app
    # BEHAVES while a live finding says otherwise; a worklist naming its work is not that.
    PLANS = {"8-ACTION-PLAN.md"}
    # `where` is "path:line", so the line number comes off before the name is compared —
    # the first attempt matched "8-ACTION-PLAN.md:48" against "8-ACTION-PLAN.md" and silently
    # filtered nothing, which looked exactly like a filter that had found nothing to filter.
    refs = [r for r in refs
            if pathlib.Path(r[0].rsplit(":", 1)[0]).name not in PLANS]

    # An OPEN finding cited without acknowledging that it is open.
    unqualified = [(w, fid, ln) for (w, fid, ln) in refs
                   if state.get(fid) in ("OPEN", "PARTIAL") and not QUALIFIED.search(ln)]

    print(f"audit refs {len(refs) + len(missing)} · resolved {len(refs)} · "
          f"UNKNOWN {len(missing)} · OPEN-cited-as-settled {len(unqualified)}")
    for where, fid, line in unqualified:
        print(f"  UNQUALIFIED {fid} is {state.get(fid)}  {where}")
        print(f"              claim:   {line}")
        print(f"              finding: {known.get(fid, '?')}")
        print(f"              cite an open row AS open, or do not cite it as evidence.")
    for where, fid, line in missing:
        print(f"  UNKNOWN ID  {fid}  {where}\n              {line}")
    if "--list" in sys.argv:
        print("\n── every reference, beside the finding it names ──")
        for where, fid, line in refs:
            print(f"  {fid}  {where}\n      claim:   {line}\n      finding: {known[fid]}")
    # An ID that does not exist is a hard failure. An ID that exists but names the wrong
    # thing cannot be decided mechanically — `--list` puts the two side by side so a person
    # can, which is the same bargain `check_citations` makes with its uncheckable rows.
    return 1 if (missing or unqualified) else 0

sys.exit(main())
