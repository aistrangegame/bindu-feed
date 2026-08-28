#!/usr/bin/env python3
"""Seed Tools/rendered-strings.tsv — the FORWARD half's verdicts.

Auto-grants only AUTHORED (traceable to the design). Everything else needs a human
verdict, because "the app made this up" is exactly the judgement a matcher cannot make.
Hand verdicts survive regeneration.
"""
import json, collections, re, sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from authored_lib import ROOT, norm
from design_lib import load_design, in_design

REG = ROOT/"Tools"/"rendered-strings.tsv"
KEEP = {"APP-OWN", "APP-OWN-INSTRUCTIONAL", "DIVERGENCE", "NON-UI", "INVENTION"}

# Rule 4's forbidden CATEGORY: a string that tells the hand what to do.
# `The Instrument v3.html:1084` forbids it outright, so APP-OWN is NOT an available
# verdict here — an instructional string is either the design's or it is invented.
INSTRUCTIONAL = re.compile(r"""(?ix)
    \b(touch|tap|press|hold|drag|pull|push|swipe|pinch|zoom|turn|part|send|catch|
       settle|move|travel|draw|scrub|flick|rotate|aim|offer|walk|stay|let\s+go)\b
    .{0,40}\b(it|one|a\s+\w+|the\s+\w+|here|there|down|up|out|in|along|across|again)\b
""")

def load_reg():
    rows = {}
    if REG.exists():
        for line in REG.read_text(encoding="utf-8").splitlines():
            if not line.strip() or line.startswith("#"): continue
            f = line.split("\t")
            if len(f) >= 3: rows[norm(f[1]).lower()] = (f[0].strip(), f[2])
    return rows

hay = load_design()
prior = load_reg()
cands = json.load(open(ROOT/"Tools"/"rendered-candidates.json"))

rows = []
for c in cands:
    k = norm(c["s"]).lower()
    site = c["sites"][0]
    if k in prior and prior[k][0] in KEEP:
        status, note = prior[k]
    elif in_design(c["s"], hay):
        status, note = "AUTHORED", site
    else:
        status = "UNTRIAGED-INSTRUCTIONAL" if INSTRUCTIONAL.search(c["s"]) else "UNTRIAGED"
        note = site
    rows.append((status, norm(c["s"]), note))

rows.sort(key=lambda r: (r[0], r[1].lower()))
HDR = """# RENDERED-STRING REGISTRY - the FORWARD half of Rule 4, inverted.
#
# Both halves of the Rule 4 check were built from memory. The backward list had three
# ad-hoc entries and missed `touch to read`; the forward list had eight and missed six
# invented world cues. You cannot enumerate inventions from the design, because inventions
# are exactly what is NOT in it. So this file enumerates the other side: every string the
# app renders. Each must be AUTHORED, a recorded DIVERGENCE, or deliberate APP-OWN copy.
# Anything else is an INVENTION by construction - nothing to remember.
#
# STATUS<TAB>STRING<TAB>SITE
#   AUTHORED     traceable to canon/ or a design source. Auto-granted; the only one that is.
#   DIVERGENCE   deliberately not the design's wording; the reason is in CLAUDE.md section 10.
#   APP-OWN      the app's own copy for a surface the design never drew (token entry,
#                settings, error states). Deliberate and named. NOT available for an
#                INSTRUCTIONAL string - see below.
#   NON-UI       a literal that never reaches a screen.
#   INVENTION    the violation. Must go to zero or be reclassified with a reason.
#   UNTRIAGED*   not yet judged. check_rendered.py fails on these too: an unjudged string
#                is indistinguishable from an invented one, which is how six of them lived
#                in the Point for the whole build.
#
# UNTRIAGED-INSTRUCTIONAL is called out separately because Rule 4 forbids the CATEGORY.
# `The Instrument v3.html:1084`: an instructional string is either the design's or it is
# invented. APP-OWN cannot be granted to one.
#
# Regenerate: python3 Tools/extract_rendered.py && python3 Tools/seed_rendered.py
# Enforce:    python3 Tools/check_rendered.py [--triage]
"""
with open(REG, "w", encoding="utf-8") as f:
    f.write(HDR)
    for st, s, note in rows: f.write(f"{st}\t{s}\t{note}\n")
print(collections.Counter(r[0] for r in rows))
