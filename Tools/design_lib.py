"""The design corpus as a haystack, for the FORWARD check.

Mirrors authored_lib.load_app(): the same normalisation, run the other way. Comments are
NOT stripped here — a string the design mentions anywhere, including in its own commentary,
is a string someone had a source for. The forward check asks "did we make this up?", and a
design comment is a sufficient answer to that. (The backward check is the strict one,
because there a comment creates a false presence.)

THE ONE THING IN THE CORPUS THAT IS NOT EVIDENCE OF AUTHORSHIP: struck text.
`comps/The Chrome.html:100-108` is a "silence sweep" — six strings in `<s>` tags under
*"None of the six exists in the 6,081 lines of the design"* (`:109`), and `:29` /
`:444` label the block *"what the built app invented. Only ever visible in AS BUILT."*
So the corpus contains a LABELLED INVENTORY OF THE APP'S OWN INVENTIONS, and it was
inside the haystack that proves the app invents nothing.

`<s>` is struck-through by definition — removed text — so this is handled structurally
rather than by naming strings: struck spans are cut from the haystack, and what they
contain becomes the INVENTED set the forward check denies. Deriving the set from the
markup means it cannot go stale the way a hand-kept denylist would, and it extends to
any comp that documents a fault the same way.
"""
import re, pathlib
from authored_lib import ROOT, norm

# **THE CORPUS OMITTED THE SOURCE 106 AUDIT FINDINGS ARE BUILT FROM.** `Claude Design Round
# 1` — its comps, and the four register files at its root — was never in the haystack, so
# every string on the screens it specifies was unverifiable in both directions: `check_authored`
# never enumerated them, and `check_rendered` could only call them untriaged and wait for a
# hand verdict. Found when three authored stat labels on Ash's Voice came up as inventions.
SOURCES = [ROOT/"canon",
           ROOT/"Claude Design Round 2"/"design-source", ROOT/"Claude Design Round 2"/"comps",
           ROOT/"Claude Design Round 1"]

STRUCK = re.compile(r'<s>(.*?)</s>', re.S | re.I)

def _decode(t):
    t = re.sub(r'\\u([0-9a-fA-F]{4})', lambda m: chr(int(m.group(1), 16)), t)
    # **AN ESCAPED LINE BREAK IS A LINE BREAK.** `The Mirror.html:70` writes a koan as
    # `'If no one is watching,\nwhat is the watching?'` — two characters in the file, one
    # break on the screen. Left literal, the haystack held `watching,\nwhat` and the app's
    # rendered form could never match, so a TRUE authored string read as unauthored. Same
    # class as the `Or\u{00ED}` miss: the corpus is compared after both sides are decoded.
    return re.sub(r'\\[nt]', ' ', t)

def load_design(with_struck=False):
    """The haystack, with struck spans removed. `with_struck` also returns what they held."""
    per_file, struck = {}, []            # struck: (value, the file that struck it)
    for base in SOURCES:
        if not base.exists(): continue
        for p in sorted(base.rglob("*")):
            if p.suffix.lower() not in (".js", ".html", ".md"): continue
            t = _decode(p.read_text(encoding="utf-8", errors="replace"))
            for m in STRUCK.finditer(t):
                v = norm(re.sub(r'<[^>]+>', ' ', m.group(1))).strip().lower()
                if v: struck.append((v, str(p)))
            t = STRUCK.sub(' ', t)          # struck text is not evidence of authorship
            per_file[str(p)] = norm(t).lower()
    hay = "\n".join(per_file.values())
    if not with_struck: return hay

    # THE FILE THAT STRUCK A STRING CANNOT BE THE WITNESS THAT AUTHORS IT. `The Chrome.html`
    # both strikes the six AND renders them, because demonstrating the fault is the comp's
    # whole purpose — `paintInvented()` at `:446` assigns them to `#invTop`/`#invBot` so a
    # reader can flip to AS BUILT and see them reappear. Testing "does it occur elsewhere in
    # the haystack" against the WHOLE corpus therefore cleared five of the six on the
    # strength of the demonstration itself. Excluding the striking file is what separates a
    # comp showing an invention from the design authoring the same words for a real surface.
    invented, placement = set(), set()
    for v, src in struck:
        elsewhere = any(v in body for f, body in per_file.items() if f != src)
        (placement if elsewhere else invented).add(v)
    return hay, sorted(invented), sorted(placement)

SENT = re.compile(r'(?<=[.!?])\s+')

def in_design(s, hay):
    n = norm(s).lower().strip()
    if len(n) < 4: return True
    if n in hay: return True
    parts = [p.strip() for p in SENT.split(n) if len(p.strip()) >= 12]
    return len(parts) > 1 and all(p in hay for p in parts)
