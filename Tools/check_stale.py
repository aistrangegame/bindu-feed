#!/usr/bin/env python3
"""THE REGISTRIES' OWN DRIFT — the mirror of both Rule 4 checkers.

`check_rendered` proves every string the app renders is registered. `check_authored` proves
every REQUIRED authored string is rendered. **Neither ever asks whether a REGISTRY ROW is
still true**, and the two holes are not the same shape:

  · A rendered-registry row with an EXCUSING status (DIVERGENCE / APP-OWN /
    APP-OWN-INSTRUCTIONAL / NON-UI) is a standing permission. When the code it described is
    deleted the row survives, indistinguishable from a live one — and if that string is ever
    typed again, by anyone, for any reason, the stale row EXCUSES IT SILENTLY. It is not
    backlog noise; it is a permission outliving its justification. Found 2026-08-30 when
    B7.4 replaced the lens toggle: `the structure ›` and `the light ›` sat in the registry
    pointing at `UniverseView.swift:146`, a line that no longer existed, and every checker
    was green.

  · An authored-registry row claims *the design says this*. When a design source changes the
    row survives too, and a REQUIRED one then forces the app to keep rendering a string
    nothing authors any more — the fourth quadrant at the registry level: a checker
    MANUFACTURING the fault it exists to catch.

Both are checked by asking the live corpus, never a snapshot: is this string still a Swift
literal, and is it still in the design?

  ./Tools/check_stale.py            exit 1 if any row has outlived what it describes
"""
import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from authored_lib import ROOT, norm, load_registry
from design_lib import load_design, in_design
from extract_rendered import candidates

# NOT `from check_rendered import load_reg` — that module runs its own check at import and
# the first run of this file silently executed the WRONG checker and printed its green.
RENDERED_TSV = ROOT/"Tools"/"rendered-strings.tsv"

def load_rendered_reg():
    rows = []
    if RENDERED_TSV.exists():
        for line in RENDERED_TSV.read_text(encoding="utf-8").splitlines():
            if not line.strip() or line.startswith("#"): continue
            f = line.split("\t")
            if len(f) >= 3: rows.append({"status": f[0].strip(), "s": f[1], "note": f[2]})
    return rows


# The statuses that EXCUSE a rendered string. `INVENTION` is deliberately not here: a row
# recording a removed invention is the healthy end state, and flagging it would delete the
# only record that the invention was ever found. It excuses nothing, so it cannot go stale.
EXCUSING = ("DIVERGENCE", "APP-OWN", "APP-OWN-INSTRUCTIONAL", "NON-UI")

# **MATCH THROUGH THE SAME EXTRACTOR THE REGISTRY WAS KEYED BY, NOT A SECOND ONE.** The first
# run of this check compared registry rows against `authored_lib.load_app()` and reported 34
# stale permissions, every one of them false: that extractor replaces `\(interpolation)` with
# a SPACE and `extract_rendered` replaces it with an ELLIPSIS, so `'… days ago'` could never
# match `'days ago'`. Two normalisers over one corpus is the fourth quadrant manufacturing
# work — and the obvious repair to 34 stale rows is to DELETE 34 LIVE PERMISSIONS.
#
# Statuses that make an AUTHORSHIP CLAIM. `FRAGMENT` and `CSSVALUE` are the extractor's own
# scraps — a scrap that stops matching is the extractor changing, not the design.
CLAIMING = ("REQUIRED", "REVIEW", "SUPERSEDED", "ANNOTATION")
# `RETRACTED` is the verdict this check ISSUES; re-reading it as a claim would make the
# tool permanently red at its own findings.

def main():
    live = {norm(c["s"]).lower() for c in candidates()}
    hay, struck_only, _elsewhere = load_design(with_struck=True)
    # **STRUCK IS NOT MISSING, AND CONFLATING THEM WOULD SEND THE READER LOOKING FOR A
    # DELETION THAT NEVER HAPPENED.** `<s>` in a comp is the design retracting its own words
    # — the fact to record is *withdrawn*, not *absent*, and the repair is a reclassification
    # rather than a hunt through git for who removed it.
    #
    # `load_design`'s second value is the strings struck in ONE file and found nowhere else —
    # the design's own withdrawals. (It is also how `check_rendered` inventories app
    # inventions a comp strikes to demonstrate them, so the bucket holds both kinds; the
    # difference is what the striking file was doing, and no rule reads that. Named here so
    # the next reader does not take a RETRACTED line as an accusation.)
    gone = set(struck_only)

    stale_perm = [r for r in load_rendered_reg()
                  if r["status"] in EXCUSING and norm(r["s"]).lower() not in live]
    auth = [r for r in load_registry() if r["status"] in CLAIMING]
    absent = [r for r in auth if not in_design(r["s"], hay)]
    retracted = [r for r in absent if norm(r["s"]).lower().strip() in gone]
    stale_claim = [r for r in absent if r not in retracted]

    print(f"rendered-registry {len(load_rendered_reg())} rows · standing permissions "
          f"{len([r for r in load_rendered_reg() if r['status'] in EXCUSING])} · STALE {len(stale_perm)}")
    for r in stale_perm:
        print(f"  STALE-PERMISSION  {r['status']}  {r['s'][:66]!r}\n                    was: {r['note'][:90]}")
    print(f"authored-registry {len(auth)} claiming rows · STALE {len(stale_claim)}")
    for r in stale_claim:
        print(f"  STALE-CLAIM       {r['status']}  {r['s'][:66]!r}\n                    tsv line {r['line']} cites: {r['src'][:80]}")
    for r in retracted:
        print(f"  RETRACTED         {r['status']}  {r['s'][:66]!r}\n                    struck in the design; tsv line {r['line']}")
    return 1 if (stale_perm or stale_claim or retracted) else 0

sys.exit(main())
