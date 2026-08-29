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

def main():
    hay = load_design()
    cands = candidates()          # fresh, every run — never a snapshot
    reg = {norm(r["s"]).lower(): r for r in load_reg()}

    inventions, untriaged, authored = [], [], 0
    for c in cands:
        k = norm(c["s"]).lower()
        r = reg.get(k)
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
