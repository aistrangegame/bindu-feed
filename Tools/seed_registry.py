#!/usr/bin/env python3
"""Seed Tools/authored-strings.tsv from the candidates: auto-classify what provenance
and shape can classify, and preserve every verdict already recorded by hand."""
import json, collections, re
from authored_lib import ROOT, norm, load_app, present, load_registry

SUPERSEDED_ONLY = {"Claude Design Round 2/design-source/The Point v9.html"}
KEEP = {"ANNOTATION", "CONTENT", "SUPERSEDED", "DIVERGED", "FRAGMENT", "CSSVALUE"}

# CSS / animation shorthand and font stacks: design implementation, never app copy.
CSSV = re.compile(r"""(?ix)^(
      [\w-]+\s+[\d.]+m?s\s+(ease|linear|cubic-bezier|steps|forwards|both)
    | (opacity|transform|filter|color|background|top|left|width|height)\s+[\d.]+m?s\b
    | [\w-]+\s+[\d.]+m?s\s+ease-in-out\s+infinite
    | (radial|linear)-gradient\(.*
    | \(?prefers-[\w-]+\s*:.*
    | (\d+\s*)?px\s+[\w ]+,.*
    | [\w ]+,\s*(monospace|serif|sans-serif|Georgia|Helvetica|Arial)\b.*
    | center\s+center
)$""")

# A template-literal fragment or a scrap of code, not a whole authored string: the
# extractor splits `${hz}Hz - ${pan} pan` at the interpolations, and JS source lines
# contain quoted scraps like "), ctx=cvs.getContext(".
CODE_SCRAP = re.compile(r"""(?x)
      ^[^A-Za-z]{0,3}[),;+}]                 # opens with a closing bracket / operator
    | getElementById|getContext|querySelector|classList|style\.|\.replace\(
    | ^\}?,?\s*\{\s*value:                   # object-literal scraps
    | ^\s*\w{0,2}\s*[-+*/=<>]{1,3}\s
""")

def fragment(s):
    t = s.strip()
    if len(t) < 12 and not t.isupper(): return True
    if CODE_SCRAP.search(t): return True
    if t[:1] in "·-,;:" or t[-1:] in "·→+" : return True
    if re.match(r"^[a-z]{1,2}\s", t) and not re.search(r"[.!?]", t): return True
    return False

hay = load_app()
prior = {norm(r["s"]).lower(): r["status"] for r in load_registry()}
cands = json.load(open(ROOT / "Tools" / "authored-candidates.json"))

rows = []
for c in cands:
    key = norm(c["s"]).lower()
    if prior.get(key) in KEEP:
        status = prior[key]
    elif present(c["s"], hay):
        status = "REQUIRED"
    elif CSSV.match(c["s"].strip()):
        status = "CSSVALUE"
    elif fragment(c["s"]):
        status = "FRAGMENT"
    elif set(c["prov"]) == {"doc"}:
        status = "ANNOTATION"
    elif set(c["src"]) <= SUPERSEDED_ONLY:
        status = "SUPERSEDED"
    else:
        status = "REVIEW"
    rows.append((status, norm(c["s"]), ";".join(c["src"]) + " [" + ",".join(c["prov"]) + "]"))

rows.sort(key=lambda r: (r[0], r[1].lower()))
HDR = """# AUTHORED-STRING REGISTRY - the backwards half of Rule 4, made complete.
#
# The forward grep enumerates invented strings and proves them ABSENT. This file
# enumerates AUTHORED strings and proves them PRESENT. Before it existed that half ran
# against three strings someone happened to remember: TURN IT was caught by memory, and
# catching it turned up a mechanic that had never been built and never been flagged.
#
# STATUS<TAB>STRING<TAB>SOURCE
#   REQUIRED    present in the app and traceable to an authored source. Deleting it must
#               be a decision, not a side effect. check_authored.py exits 1 on a miss.
#   REVIEW      authored, and NOT in the app. The backlog - where a never-built mechanic
#               surfaces. Each is built, or reclassified with a reason.
#   ANNOTATION  the design document explaining itself. Never app copy.
#   CONTENT     authored content that reaches the app from Airtable at runtime.
#   CSSVALUE    CSS / animation shorthand or a font stack. Implementation, never copy.
#   FRAGMENT    a template-literal fragment or code scrap the extractor split.
#   SUPERSEDED  from a generation this build does not follow (The Point v9.html).
#   DIVERGED    deliberately not used; the reason is recorded in CLAUDE.md section 10.
#
# Regenerate: python3 Tools/extract_authored.py && python3 Tools/seed_registry.py
# Enforce:    python3 Tools/check_authored.py [--discover]
# Hand verdicts (anything but REQUIRED/REVIEW) survive regeneration.
"""
with open(ROOT / "Tools" / "authored-strings.tsv", "w", encoding="utf-8") as f:
    f.write(HDR)
    for st, s, src in rows:
        f.write(f"{st}\t{s}\t{src}\n")
print(collections.Counter(r[0] for r in rows))
