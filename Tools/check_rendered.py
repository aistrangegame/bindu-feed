#!/usr/bin/env python3
"""FORWARD half of Rule 4 — enforcement.

Every string the app renders must be AUTHORED (traceable to the design), a recorded
DIVERGENCE, or deliberate APP-OWN copy. Anything else is an INVENTION by construction.

  ./Tools/check_rendered.py             extract, then enforce (exit 1 on any INVENTION)
  ./Tools/check_rendered.py --triage    show untriaged rendered strings not in the design

EXTRACTION IS UNCONDITIONAL. This read Tools/rendered-candidates.json — a cached snapshot
written by a separate script that nothing forced anyone to run — so it reported green on a
build that no longer existed, and any string added since the last manual extraction was
invisible to it, invented or not. One command now: extract, then check.
"""
import sys, json, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from authored_lib import ROOT, norm
from design_lib import load_design, in_design
from extract_rendered import candidates

REG = ROOT/"Tools"/"rendered-strings.tsv"

def load_reg():
    rows = []
    if REG.exists():
        for line in REG.read_text(encoding="utf-8").splitlines():
            if not line.strip() or line.startswith("#"): continue
            f = line.split("\t")
            if len(f) >= 3: rows.append({"status": f[0].strip(), "s": f[1], "note": f[2]})
    return rows

# ── THE CORPUS CONTAINS AN INVENTORY OF THE APP'S OWN INVENTIONS ────────────────────────
# `comps/The Chrome.html:29` — *"what the built app invented. Only ever visible in AS
# BUILT"* — and `:100-108`, a "silence sweep" of six strings in `<s>` tags under *"None of
# the six exists in the 6,081 lines of the design"* (`:109`). Those strings were inside the
# haystack that proves the app invents nothing, so any one of them resolved as AUTHORED.
#
# Measured before it was fixed: with `PULL TO TRAVEL` planted in `TurnOverlay.swift`, this
# checker reported `authored 882 · INVENTION 0 · exit 0`.
#
# HANDLED STRUCTURALLY, NOT STRING BY STRING. `design_lib` cuts `<s>` spans from the
# haystack — struck text is removed text, by definition, in any file — and hands back what
# they held. Denying two strings by name would have been a fix for two strings; the hole is
# that a comp documenting a fault lives in the corpus that certifies the absence of faults,
# and any future comp doing the same is now covered without an edit here.
#
# ── LIMITS · WHAT THIS TOOL CANNOT SEE, BY CONSTRUCTION ─────────────────────────────────
# A THIRD CLASS EXISTS AND IS OUT OF REACH: strings whose AUTHORSHIP IS REAL AND WHOSE
# PLACEMENT IS INVENTED. Two of the six are these:
#
#   `THE UNIVERSE`                  authored at `uni-deep.js:28` and `The Instrument
#                                   v3.html:1501` as a turn-row destination; the app renders
#                                   one at `Components/TurnOverlay.swift:38`, correctly. The
#                                   invention is those words as AXIS CHROME at `top:56px`
#                                   (`The Chrome.html:32`).
#   `touch once, then do nothing`   authored at `The Light v2.html:914` as the door's own
#                                   description. The invention is showing it as an on-screen
#                                   instruction.
#
# This checker keys on WORDS. Placement is a property of the surface, not the string, so no
# string-matching rule can reach it — and forcing them in manufactures the fourth quadrant:
# adding `THE UNIVERSE` to the denial set turned a CORRECT string red on the first run here.
# **Do not try to close this by matching harder.** It closes, if ever, by a check that knows
# which surface renders a string, which is a different tool. Named here so the next reader
# does not rediscover it as a bug.
def main():
    hay, INVENTED, _PLACEMENT = load_design(with_struck=True)
    cands = candidates()          # fresh, every run — never a snapshot
    reg = {norm(r["s"]).lower(): r for r in load_reg()}

    inventions, untriaged, authored = [], [], 0
    for c in cands:
        k = norm(c["s"]).lower()
        r = reg.get(k)
        # An inventoried invention is an INVENTION however it resolves, and no registry row
        # may excuse it — the whole point is that the design NAMES it as one.
        if norm(c["s"]).strip().lower() in INVENTED:
            inventions.append(c); continue
        if r and r["status"] in ("DIVERGENCE", "APP-OWN", "APP-OWN-INSTRUCTIONAL", "NON-UI"): continue
        if in_design(c["s"], hay): authored += 1; continue
        (inventions if (r and r["status"] == "INVENTION") else untriaged).append(c)

    print(f"rendered {len(cands)} · authored {authored} · "
          f"recorded {len([r for r in reg.values() if r['status'] in ('DIVERGENCE','APP-OWN','APP-OWN-INSTRUCTIONAL','NON-UI')])} · "
          f"INVENTION {len(inventions)} · untriaged {len(untriaged)}")
    for c in inventions:
        print(f"  INVENTION  {c['s'][:78]!r}\n             {c['sites'][0]}")
    if "--triage" in sys.argv:
        print(f"\n── untriaged: rendered, not in the design ──")
        for c in untriaged:
            print(f"  {c['s'][:74]!r}\n     {c['sites'][0]}")
    # An UNTRIAGED string is indistinguishable from an invented one — which is exactly how
    # six invented world cues lived in the Point for the whole build. Fail on both.
    for c in untriaged:
        print(f"  UNTRIAGED  {c['s'][:78]!r}\n             {c['sites'][0]}")
    return 1 if (inventions or untriaged) else 0

sys.exit(main())
