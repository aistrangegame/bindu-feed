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
import hashlib, re, sys, pathlib, hashlib
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
        ROOT/"Coverage"/"8-ACTION-PLAN.md", ROOT/"Coverage"/"7-STATE-OF-THE-BUILD.md",
        ROOT/"Coverage"/"0-INDEX.md"] + sorted((ROOT/"Bindu Feed"/"Bindu FeedTests").glob("*.swift"))
# THE TEST SUITE IS IN SCOPE, ADDED 2026-08-29. A test that cites a design line is making the
# same kind of claim a ledger row makes, and nothing checked it — `theRootIs1361` pinned a
# constant read out of the file under test, dressed it in a reason, and defended the defect
# `AUDIT C7.9` names for a whole stage. A citation the checker can resolve is a citation
# someone traced; run it on first inclusion and expect finds.
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

# ``EX:`` inside a backtick — an example of the syntax, not a use of it.
EXAMPLE = re.compile(r"`EX:[^`]*`")

def resolve(name):
    """Every file the citation could mean. A BARE name that means more than one is an error.

    **AMBIGUITY IS NOT SOMETHING TO RESOLVE.** This used to return every file with a matching
    basename and the caller passed if ANY of them contained the quote — so a citation could
    verify against a file its author had never opened. `README.md:192` is
    `Claude Design Round 2/README.md`, and there is another `README.md` in scope; the quote
    was checked against both, and the only reason it failed was an unrelated backtick.

    That is the false-drift mechanism arriving through a new door, and it is worse here: the
    natural repair to a citation that "does not resolve" is to CHANGE THE CITATION, so a true
    reference gets edited into a false one to make a checker quiet. A path is cheap; guessing
    is not. If a bare name is ambiguous the checker says so and demands a qualified path.
    """
    want = pathlib.Path(name)
    hits = []
    for base in SEARCH:
        if not base.exists(): continue
        for p in base.rglob("*"):
            if not p.is_file() or p.name != want.name: continue
            # A citation carrying any directory part must match that tail exactly, so
            # `Claude Design Round 2/README.md` and a bare `README.md` are different claims.
            if len(want.parts) > 1 and not str(p).endswith(str(want)): continue
            hits.append(p)
    # rglob over overlapping SEARCH roots returns the same file more than once.
    seen, uniq = set(), []
    for h in hits:
        r = h.resolve()
        if r in seen: continue
        seen.add(r); uniq.append(h)
    return uniq

def main():
    checked = unverified = missing = uncheckable = 0
    for doc in DOCS:
        if not doc.exists(): continue
        lines = doc.read_text(encoding="utf-8").splitlines()
        for i, line in enumerate(lines, 1):
            # **THE ESCAPE, AND WHY §10 NEEDS ONE.** CLAUDE.md is the one document whose
            # SUBJECT is the syntax these checkers parse, so an example of a citation IS a
            # citation and an example of a calibration plant IS a plant. Three instances in
            # one section, none of them errors — and the alternative is rephrasing an example
            # until a parser ignores it, which degrades the explanation to protect the tool.
            #
            # `EX:` immediately inside the backtick marks ONE citation as an example.
            # Deliberately per-citation rather than per-block: a real citation elsewhere on
            # the same line still flags, so the escape cannot be used to silence a genuine one
            # by fencing the region around it.
            line_for_cites = EXAMPLE.sub("`", line)
            cites = CITE.findall(line_for_cites)
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
                # AMBIGUITY ONLY MATTERS WHEN THE COPIES DIFFER. Most duplicate names in
                # this repo are the same bytes in two design rounds, and a line-based
                # citation against identical text cannot land anywhere unintended — failing
                # those would demand 86 edits that change nothing and would train the reader
                # to qualify paths by rote. Measured: of 18 duplicated names, 15 are
                # byte-identical and 3 are not. The three are where a citation can silently
                # verify against a file its author never opened, so those are the errors.
                if len(files) > 1 and len({hashlib.md5(f.read_bytes()).hexdigest()
                                           for f in files}) == 1:
                    files = files[:1]
                if len(files) > 1:
                    print(f"  AMBIGUOUS   {doc.name}:{i}  {name!r} matches {len(files)} DIFFERING files:")
                    for f in files[:4]:
                        print(f"                {f.relative_to(ROOT)}")
                    print(f"              qualify it — a bare filename is not a citation when")
                    print(f"              more than one file has that name.")
                    missing += 1
                    continue
                # **A CITATION WHOSE LINE EXCEEDS ITS FILE IS NOT A CITATION.** Cheap, and
                # it catches the one shape ambiguity cannot: a name that resolves to a REAL
                # file, at a line that file does not have. Added 2026-08-30 after a bulk
                # qualification of `AUDIT.md` redirected `spine-axis.js:1084` to a 143-line
                # file and `spine-field.js:2112` to a 241-line one — `AUDIT.md:238` declares
                # those names as LINE RANGES WITHIN `The Instrument v3.html`, section labels
                # rather than files. All three redirects were entirely plausible on their
                # face; what exposed them was `spine-passage.js`, which resolves to nothing
                # at all. **An unresolvable reference announces itself; a resolvable-but-wrong
                # one does not** — so the impossible one is worth a check of its whole class.
                nlines = len(files[0].read_text(errors="ignore").split("\n"))
                if ln > nlines:
                    print(f"  PAST-EOF    {doc.name}:{i}  {name}:{ln} — that file has {nlines} lines")
                    print(f"              a citation whose line exceeds its file is not a citation:")
                    print(f"              either the path is wrong, or the name is a SECTION LABEL")
                    print(f"              rather than a file (see AUDIT.md:238).")
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
                    # **A KNOWN AND DELIBERATE LIMIT, STATED BECAUSE IT IS A SEARCH ON A
                    # SHORTENED COPY.** Only a quote's first 60 characters are matched, so a
                    # citation whose opening 60 chars are right and which then DRIFTS is
                    # verified. That is not the display truncation `check_audit_ids` had — it
                    # is a chosen tolerance, because a long quote wraps in the source and
                    # `norm` cannot always rejoin it the same way. The trade is real: short
                    # quotes are checked whole, long ones are checked by their opening.
                    # **Quote short and exactly, and the check is total.**
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
