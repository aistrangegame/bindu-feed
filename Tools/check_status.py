#!/usr/bin/env python3
"""THE FIFTH CHECKER · a Swift comment that asserts the app's own current state.

`check_citations` verifies a comment's quotation of a DESIGN line. Nothing verified a
comment's claim about THE APP — *"not yet implemented"*, *"there is no way to"*, *"never
built"* — and those are the ones that rot fastest, because the code moves under them while
the prose sits still.

WHY IT NEEDED A TOOL RATHER THAN CARE. 2026-08-29, three layers deep:

    `PointReadings.swift:58-66`   said the reading REPLACED the world, so the recede could
                                  not be wired.  It had been wired at `0e37d39`.
    `Coverage/10-OWED.md` §10     filed `stackFrom` as blocked, CITING those lines.
    the next instruction          was to close that blocker as "the last structural change".

Each step was honest and each rested on the one before. **A stale comment does not merely
mislead a reader; it becomes the premise of the next decision.** Two more were found in the
same sweep: `BinduFeedApp` said no view read the breath and the audio fold was "deliberately
not done", when both had been true for a long time and the fold had since been MEASURED; and
`UniverseCamera` said the world's turn "was never built" while `UniverseView`'s own comment
said "never built until now" — two comments in one build disagreeing about one mechanism.

THE RULE THIS ENFORCES. A comment asserting current implementation state carries a
`STATUS(YYYY-MM-DD)` marker naming the day it was last verified against the code. The
checker cannot know whether the claim is TRUE — that needs a person reading both — so it
enforces the thing a machine can: that every such claim is dated, findable, and re-read.
Undated claims fail. Old ones are reported so a sweep has a worklist.

Run: python3 Tools/check_status.py [--days N]
"""
import re, sys, pathlib, datetime

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP = ROOT / "Bindu Feed" / "Bindu Feed"

# Phrases that assert the app's CURRENT state. Deliberately narrow: each one is a claim a
# reader would act on, not a description of a runtime condition.
CLAIM = re.compile(
    r"\b(not yet implemented|unimplemented|never built|not built|is absent|are absent|"
    r"no way to|cannot yet|blocked on|deliberately not done|does not exist|"
    r"is an empty stub|held unimplemented|still hardcod)", re.I)

# Past-tense framings: the comment is describing what WAS, usually beside the fix. These are
# the healthy form and must not be demanded to carry a marker — flagging them would train
# people to delete the history, which is the opposite of what this build wants.
PAST = re.compile(
    r"\b(this was|it was|there was|was an|previously|used to|had been|had it|had no|"
    r"before this|until now|read \"|read `|corrected|CORRECTED|no longer|"
    r"changes that|so they land|is now|are now|now carries|BUILT\.|since been)", re.I)

# `is absent` / `are absent` also describe DATA at runtime — "when there is none, the stat is
# absent, not invented" is a rendering rule, not an implementation status. A claim about the
# BUILD names a mechanism; a claim about data names what is shown. Distinguished by the words
# that only appear around content.
DATA = re.compile(r"\b(the stat|a stat|the row|a row|the field|a field|the value|"
                  r"not invented|the entry|an entry)\b", re.I)

MARKER = re.compile(r"STATUS\((\d{4})-(\d{2})-(\d{2})\)")

def main():
    days = 120
    if "--days" in sys.argv:
        days = int(sys.argv[sys.argv.index("--days") + 1])
    today = datetime.date.today()

    unmarked, stale, marked = [], [], 0
    for p in sorted(APP.rglob("*.swift")):
        lines = p.read_text(encoding="utf-8", errors="replace").split("\n")
        for i, line in enumerate(lines, 1):
            st = line.strip()
            if not (st.startswith("//") or st.startswith("///")):
                continue
            if not CLAIM.search(line):
                continue
            # The claim's own block: look a few lines either way for a marker or a past
            # framing, because a paragraph carries one marker, not one per line.
            lo, hi = max(0, i - 12), min(len(lines), i + 4)
            block = "\n".join(lines[lo:hi])
            if MARKER.search(block):
                marked += 1
                m = MARKER.search(block)
                d = datetime.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
                if (today - d).days > days:
                    stale.append((p, i, (today - d).days, st[:96]))
                continue
            if PAST.search(block):
                continue                      # describing what was, beside what is
            if DATA.search(line):
                continue                      # a rendering rule about absent content
            unmarked.append((p, i, st[:96]))

    for p, i, txt in unmarked:
        print(f"  UNDATED    {p.relative_to(ROOT)}:{i}\n             {txt}")
    for p, i, age, txt in stale:
        print(f"  STALE({age}d) {p.relative_to(ROOT)}:{i}\n             {txt}")

    print(f"status claims: marked {marked} · undated {len(unmarked)} · "
          f"older than {days}d {len(stale)}")
    if unmarked or stale:
        print("  a comment asserting what the app does NOT do must carry STATUS(YYYY-MM-DD),")
        print("  naming the day it was last read against the code. See CLAUDE.md §10.")
        return 1
    return 0

if __name__ == "__main__":
    sys.exit(main())
