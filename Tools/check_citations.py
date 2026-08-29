#!/usr/bin/env python3
"""THE THIRD DRIFT CHECK — citations, which nothing else greps.

The registries catch a drifted STRING. Neither catches a drifted CITATION: prose that
names `file.html:1084` for something that moved, or was never there. Three of those got
through this build — a stale §6 note, a stale LightView comment, and §10's own miscitation
of the instructional ban.

A line number alone cannot be verified. A line number PLUS its words can. So where a doc
cites a line and quotes it, this confirms the quote is really at (or near) that line.

  ./Tools/check_citations.py            check every doc
  ./Tools/check_citations.py --list     also show what was checked

Recognised form, anywhere in a Markdown file:
    `<source>:<line>` ... *"quoted text"*   (or "quoted text", or `quoted text`)
The quote may appear up to WINDOW lines either side, since prose cites a block, not a byte.
"""
import re, sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from authored_lib import ROOT, norm

WINDOW = 12
# THE LEDGERS ARE DOCS TOO, and were outside this checker's reach for the whole build.
#
# A ledger row's VERDICT can be right while its REASON is wrong, and nothing checked reasons.
# `Coverage/10-OWED.md` row E-V was correctly blocked and incorrectly explained: it said
# `reflect(-1)` needed a pane past 90 degrees, when `world-five.js:120-123` runs the partner
# at `PI - a` and the sign comes from the PAIRING. Caught by re-reading the constants, not by
# any tool. Reasons in ledgers drift exactly as citations in prose do — this build has found
# four instances of documentation drift and had zero mechanisms aimed at the ledgers.
#
# So: **every E-BLOCKED and OWED row cites the design line its reason rests on**, in this
# checker's own checkable form — one `source:line` and one verbatim *"quote"* on the line —
# and the row is only as trustworthy as that citation.
DOCS = [ROOT/"Bindu Feed"/"CLAUDE.md", ROOT/"HANDOFF-NOTE.md", ROOT/"OPEN-ITEMS.md",
        ROOT/"Coverage"/"10-OWED.md", ROOT/"Coverage"/"9-BOWL-CALL-SITE-MAP.md",
        ROOT/"Coverage"/"8-ACTION-PLAN.md"]
# The ledgers cite the AUDIT and the design's own checklist, so both are reachable now. They
# were not, and three citations in `Coverage/9` resolved to nothing the moment the ledgers
# came into scope — which is the checker doing its job on its first run against them.
SEARCH = [ROOT/"canon", ROOT/"Claude Design Round 2"/"design-source",
          ROOT/"Claude Design Round 2"/"comps", ROOT/"Claude Design Round 2",
          ROOT/"Bindu Feed"/"Bindu Feed", ROOT]

CITE = re.compile(r'`([A-Za-z0-9 _./-]+\.(?:html|js|swift|md)):(\d+)(?:-\d+)?`')
# ONLY a real quotation counts. Backticked spans are code and identifiers — treating them
# as quotations produced 28 false drifts on the first run, which is the same calibration
# failure as the two registries: point the tool at things known to be right, first.
# ONLY the italic-quote form `*"..."*`, and only on the SAME line as the citation.
# Two calibration passes got here. Backticked spans are code, not quotations (28 false
# drifts). Quotes on the NEXT line belong to the next sentence (10 more). And a quote
# containing an ellipsis is a paraphrase the author elided, which cannot be matched
# verbatim by construction — those are skipped rather than reported.
QUOTE = re.compile(r'\*"([^"]{8,240})"\*')

def resolve(name):
    hits = []
    for base in SEARCH:
        if not base.exists(): continue
        hits += [p for p in base.rglob("*") if p.is_file() and p.name == pathlib.Path(name).name]
    return hits

def main():
    checked = unverified = missing = uncheckable = 0
    for doc in DOCS:
        if not doc.exists(): continue
        lines = doc.read_text(encoding="utf-8").splitlines()
        for i, line in enumerate(lines, 1):
            cites = CITE.findall(line)
            # ONE citation and ONE quotation on a line, or the pairing is a guess. A line
            # that cites two sources and quotes one of them cannot be resolved by position,
            # and guessing produced a false OK for the second citation on the first run.
            for name, ln_s in cites:
                ln = int(ln_s)
                files = resolve(name)
                if not files:
                    print(f"  UNRESOLVED  {doc.name}:{i}  no file named {name!r}")
                    missing += 1
                    continue
                # a quote on the same line or the next one belongs to this citation
                qs = [q for q in QUOTE.findall(line) if len(q) >= 8]
                if len(cites) != 1 or len(qs) != 1:
                    uncheckable += 1
                    if "--gaps" in sys.argv:
                        print(f"  no quote   {doc.name}:{i}  {name}:{ln}")
                    continue
                qs = [q for q in qs if not re.match(r'^[A-Za-z0-9 _./-]+\.(html|js|swift|md):', q)]
                # prose, not a fragment: needs a space and some letters
                qs = [q for q in qs if " " in q.strip() and len(re.findall(r"[A-Za-z]", q)) >= 6]
                qs = [q for q in qs if "\u2026" not in q and "..." not in q]
                if not qs: continue
                checked += 1
                ok = False
                for f in files:
                    # THE DESIGN FILES STORE NON-ASCII AS LITERAL `\uXXXX` ESCAPES, so a
                    # verbatim quote spanning an em-dash or a curly apostrophe could never
                    # match and every such citation was silently UNCHECKABLE — coverage lost
                    # exactly where the design's own prose is most quotable. Decoded here, the
                    # same way `extract_rendered.py` decodes Swift literals.
                    raw = f.read_text(encoding="utf-8", errors="replace")
                    raw = re.sub(r'\\u([0-9a-fA-F]{4})',
                                 lambda m: chr(int(m.group(1), 16)), raw)
                    src = raw.splitlines()
                    lo, hi = max(0, ln - 1 - WINDOW), min(len(src), ln + WINDOW)
                    hay = norm(" ".join(src[lo:hi])).lower()
                    if any(norm(q).lower()[:60] in hay for q in qs): ok = True; break
                if not ok:
                    print(f"  DRIFTED     {doc.name}:{i}  {name}:{ln}")
                    print(f"              quoted: {qs[0][:70]!r}  — not within ±{WINDOW} lines")
                    unverified += 1
                elif "--list" in sys.argv:
                    print(f"  ok          {name}:{ln}  {qs[0][:56]!r}")
    print(f"citations {checked + uncheckable} · checkable {checked} · drifted {unverified} · "
          f"uncheckable {uncheckable} · unresolved files {missing}")
    print("  a citation is checkable when its line carries exactly one citation and one")
    print("  verbatim *\"quote\"*. Uncheckable ones are not failures — they are coverage.")
    return 1 if (unverified or missing) else 0

sys.exit(main())
