#!/usr/bin/env python3
"""check_wired — THE ELEVENTH SHAPE: built, asserted, and driven by nothing.

A symbol whose only caller is a test looks alive to a grep and to a reviewer, and proves only
that it COMPUTES. This build generates that class deliberately: every extraction-for-
testability creates a symbol whose first caller is a test, and the wiring is a separate act
that can simply not happen.

THE RULE: an app-target symbol the app never reaches, with one or more test references, must
carry an explicit marker at its declaration saying why. Wire it, or say what it waits for:

    WIRED-BY(where)   driven from somewhere this grep cannot see (a closure, a KVO key path)
    UNWIRED(row)      built and correct; its audit row is OPEN and names the wiring as owed
    E-BLOCKED(why)    built, correct, and awaiting a state that does not exist yet
    TEST-ONLY(why)    a deliberate test hook, e.g. `resetForTesting`

The marker lives at the declaration, so the exemption is visible to the next reader of the
code rather than buried in a tool.

── WHAT THE FIRST VERSION COULD NOT SEE, AND WHAT IT COST ───────────────────────────────

**1 · IT ONLY SAW THINGS THAT ARE CALLED.** The match was `name(`. A built-but-unread VALUE is
invisible to that, and one was sitting in the tree the whole time: `ReturnRecord.gathering` —
the Return's ten condensed Record lines, extracted from the design, held by ten passing
assertions, read by nothing in the app — while the Record on screen rendered `RiteVoices.all`.
Every checker was green and the row was filed as *"the corpus does not exist"*, which was the
one thing that was not wrong with it.

**2 · A REFERENCE COUNT IS NOT REACHABILITY.** `ReturnTally.standings` has exactly one app
caller: `ReturnTally.spokeTwice`, whose only callers are tests. Counting says *someone reads
it*; nothing the app runs ever does. So a symbol is UNWIRED when every app-side reference to
it sits inside another symbol that is itself unwired — a fixed point, not a count. A reference
from anywhere that is NOT a candidate (a `body`, an `init`, a structural member, plain type
scope) means the app reaches it, which is deliberately the conservative direction.

FRAMEWORK CALLBACKS ARE EXCLUDED BY CONFORMANCE, NEVER BY NAME. `audioPlayerDidFinishPlaying`
is not special because of what it is called — it is a requirement of `AVAudioPlayerDelegate`,
invoked by the framework. Excluding it by name would also excuse an app method that happened
to be named similarly, so the exclusion keys on the enclosing type's conformance list.

A MARKER EXEMPTS THE SYMBOL IT SITS ON, NOT WHAT THAT SYMBOL READS. Marking something
`UNWIRED` says *the app does not reach this yet*, so anything reached only through it is not
reached either, and it is reported the moment its own reader is exempted. That cascade is the
useful direction: `ReturnTally.standings` surfaced exactly this way, one link below a
`spokeTwice` marked in an earlier pass.

**THE FIXED POINT PROPAGATES A FALSE POSITIVE DOWNWARD.** If one symbol is wrongly judged
unreachable, everything reached only through it follows. That is contained here by reporting
only what a test also touches — the signal is far stronger there — but a bare sweep over
unreachable symbols is noisy for exactly this reason, and reading such a list rather than
trusting it is what turned up the method-reference gap above.

LIMITS, NAMED SO THEY ARE NOT REDISCOVERED AS BUGS. Function references are matched by name,
so a same-named method on another type masks an unwired one; value references are matched as
`Owner.member`, so a reference through a typealias or an instance is missed. Both directions
are MISSES, never false reds — and the fourth quadrant is the one that walks you backwards.
"""
import re, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP  = ROOT / "Bindu Feed" / "Bindu Feed"
TEST = ROOT / "Bindu Feed" / "Bindu FeedTests"

CALLBACK_PROTOCOLS = {
    "AVAudioPlayerDelegate", "AVAudioRecorderDelegate", "UIApplicationDelegate",
    "UNUserNotificationCenterDelegate", "URLSessionDelegate", "URLSessionDataDelegate",
    "UIViewRepresentable", "UIViewControllerRepresentable", "ObservableObject",
    "UITextViewDelegate", "UITextFieldDelegate", "UIScrollViewDelegate", "CAAnimationDelegate",
}
STRUCTURAL = {"body", "makeUIView", "updateUIView", "makeCoordinator", "makeUIViewController",
              "updateUIViewController", "hash", "encode", "main", "==", "<", "id"}

MARKER = re.compile(r"\b(WIRED-BY|UNWIRED|E-BLOCKED|TEST-ONLY)\s*\(")
DECL_FUNC = re.compile(r"\bfunc\s+([A-Za-z_]\w*)\s*[\(<]")
DECL_VALUE = re.compile(r"^\s*(?:public |internal |nonisolated |static )*static\s+(?:let|var)\s+([A-Za-z_]\w*)")
PRIVATE = re.compile(r"^\s*(?:public |internal |nonisolated )*(?:private|fileprivate)\b")
TYPE_DECL = re.compile(r"^\s*(?:public |private |internal |final |@\w+\s+)*"
                       r"(?:extension|struct|class|enum|actor)\s+(\w+)")

def strip_code(t):
    """Comments and string literals removed — for COUNTING USES only.

    **LINE NUMBERS ARE PRESERVED, AND THEY HAVE TO BE**, because spans come from the raw text
    and references from this one. Three separate leaks were found here, each silent: block
    comments dropped their newlines, multi-line string literals dropped theirs, and `^\\s*//`
    swallowed the line break BEFORE a comment because `\\s` matches a newline. Every one
    produced plausible output with the attribution quietly wrong — which is why the invariant
    below is asserted rather than trusted.
    """
    t = re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), t, flags=re.S)
    t = re.sub(r"^[ \t]*///?.*$", "", t, flags=re.M)
    return re.sub(r'"(?:[^"\\]|\\.)*"',
                  lambda m: '"' + "\n" * m.group(0).count("\n") + '"', t)

def load(d):
    return {p: p.read_text(encoding="utf-8", errors="ignore") for p in d.rglob("*.swift")}

app_raw, test_raw = load(APP), load(TEST)
app  = {p: strip_code(t) for p, t in app_raw.items()}
test = {p: strip_code(t) for p, t in test_raw.items()}

for _p, _raw in app_raw.items():
    if _raw.count("\n") != app[_p].count("\n"):
        print(f"  check_wired: INTERNAL — line drift in {_p.name}")
        sys.exit(2)

def conformances_at(raw, line_idx):
    lines = raw.split("\n")
    for i in range(line_idx, -1, -1):
        m = re.match(r"\s*(?:public |private |internal |final |@\w+\s+)*"
                     r"(?:extension|struct|class|enum|actor)\s+\w+\s*:\s*([^{]+)\{", lines[i])
        if m:
            return {c.strip() for c in m.group(1).split(",")}
    return set()

def owner_of(raw, decl_line):
    """The type a declaration belongs to — the nearest header INDENTED LESS than it.

    **Not simply the nearest header above.** `ReturnRecord` declares `struct Entry` and then
    `static let gathering`; taking the nearest header made the owner `Entry`, so the qualified
    pattern hunted for `Entry.gathering`, found none anywhere including the tests, and the
    check stayed quiet about the one value it was written to find.
    """
    lines = raw.split("\n")
    decl = lines[decl_line - 1]
    indent = len(decl) - len(decl.lstrip())
    for i in range(decl_line - 2, -1, -1):
        m = TYPE_DECL.match(lines[i])
        if m and (len(lines[i]) - len(lines[i].lstrip())) < indent:
            return m.group(1)
    return None

def span_of(text, decl_line):
    """Lines [start, end] of the declaration, by BRACKET balance — `{`, `[` and `(` alike.

    Braces alone were not enough: `static let star = "the star lens"` has none, so its span
    never closed and ran on to swallow the next declaration and the function below it. Its
    real reader then appeared to sit inside it, and two correct values were reported unread —
    a false red on working code.
    """
    lines = text.split("\n")
    depth = 0
    for j in range(decl_line - 1, len(lines)):
        for ch in lines[j]:
            if ch in "{[(":
                depth += 1
            elif ch in "}])":
                depth -= 1
        if depth <= 0:
            return (decl_line, j + 1)
    return (decl_line, len(lines))

# ── the candidates ───────────────────────────────────────────────────────────────────────
candidates = []
for p, raw in app_raw.items():
    lines = raw.split("\n")
    for i, ln in enumerate(lines):
        name = kind = None
        m = DECL_FUNC.search(ln)
        if m and not ln.lstrip().startswith("//"):
            name, kind = m.group(1), "func"
            if name in STRUCTURAL or name.startswith("test"):
                continue
            if conformances_at(raw, i) & CALLBACK_PROTOCOLS:
                continue
        else:
            m = DECL_VALUE.match(ln)
            if not m or PRIVATE.match(ln):
                continue
            name, kind = m.group(1), "value"
            if name in STRUCTURAL:
                continue
        window = "\n".join(lines[max(0, i - 14):i + 1])
        candidates.append({"name": name, "kind": kind, "path": p, "line": i + 1,
                           "owner": owner_of(raw, i + 1), "span": span_of(raw, i + 1),
                           "marked": bool(MARKER.search(window))})

def patterns_for(c):
    if c["kind"] == "func":
        # **A METHOD REFERENCE IS A CALLER.** `Button(action: dismiss)` and `perform: handle`
        # pass the function without ever writing `(`, so matching only `name(` would report a
        # correctly-wired method as unreachable the moment anyone wrote a test for it — a
        # false red on working code, in the one quadrant that walks you backwards. Found by
        # sweeping for unreachable symbols and reading the list rather than trusting it:
        # `HubOverlay.dismiss`, `DoorView.handleRope` and six others are exactly this shape.
        # **THE LOOKBEHIND IS `\w`, NOT `[\w.]`.** Tightening it to exclude a preceding dot
        # also excluded every QUALIFIED call — `Axis.clampZ(z)`, `store.logStoryMet(...)` —
        # and the checker promptly reported four correct values as unread because the only
        # function that reads them stopped counting as a caller. Six false reds, from one
        # character, in the direction that walks you backwards.
        # The second form is a method REFERENCE in an argument position — `Button(action:
        # dismiss)`, `perform: handle`, `map(transform)`. **It is deliberately narrow.** A
        # bare `name` anywhere was tried first and cost more than it bought: `label` occurs as
        # a word throughout SwiftUI, so `LensRail.label` read as reachable from everywhere and
        # the chain case stopped firing. The trailing `(?![\w(:])` keeps a PARAMETER label —
        # `label:` — from counting as a reference to a function of the same name.
        return [re.compile(r"(?<!\w)" + re.escape(c["name"]) + r"\s*\("),
                re.compile(r"[:,(]\s*(?:self\s*\.\s*)?" + re.escape(c["name"]) + r"(?![\w(:])")], None
    qual = (re.compile(r"(?<!\w)" + re.escape(c["owner"]) + r"\s*\.\s*" + re.escape(c["name"]) + r"(?!\w)")
            if c["owner"] else None)
    local = re.compile(r"(?<![\w.])(?:Self\s*\.\s*)?" + re.escape(c["name"]) + r"(?!\w)")
    return ([qual] if qual else []), local

def homes_for(c):
    pats, local = patterns_for(c)
    out = []
    for p, t in app.items():
        spots = []
        for pat in pats:
            for mm in pat.finditer(t):
                if c["kind"] == "func" and re.search(r"\bfunc\s+$", t[max(0, mm.start() - 40):mm.start()]):
                    continue
                spots.append(mm.start())
        if local is not None and p is c["path"]:
            spots += [mm.start() for mm in local.finditer(t)]
        for pos in spots:
            ln = t[:pos].count("\n") + 1
            if p is c["path"] and ln == c["line"]:
                continue
            home = None
            for d in candidates:
                if d["path"] is p and d["span"][0] <= ln <= d["span"][1]:
                    if home is None or d["span"][0] > home["span"][0]:
                        home = d
            out.append(home)
    return out

def test_refs(c):
    pats, _ = patterns_for(c)
    n = 0
    for t in test.values():
        for pat in pats:
            n += len(pat.findall(t))
    return n

for c in candidates:
    c["refs"] = homes_for(c)
    c["tests"] = test_refs(c)

# ── the fixed point ──────────────────────────────────────────────────────────────────────
unwired = {id(c) for c in candidates}
changed = True
while changed:
    changed = False
    for c in candidates:
        if id(c) not in unwired:
            continue
        for home in c["refs"]:
            if home is None or id(home) not in unwired:
                unwired.discard(id(c)); changed = True; break

funcs = [c for c in candidates if c["kind"] == "func"]
values = [c for c in candidates if c["kind"] == "value"]
found = [c for c in candidates if id(c) in unwired and not c["marked"] and c["tests"] > 0]

print(f"  check_wired: {len(funcs)} app functions · {len(values)} static values considered")
for kind, label in (("func", "BUILT-BUT-UNCALLED"), ("value", "BUILT-BUT-UNREAD VALUES")):
    rows = [c for c in found if c["kind"] == kind]
    if not rows:
        continue
    print(f"  {len(rows)} {label} (nothing the app runs reaches them; tests do):")
    for c in sorted(rows, key=lambda r: (r["path"].name, r["line"])):
        owner = (c["owner"] + ".") if c["owner"] else ""
        print(f"      {owner}{c['name']:24s} {c['path'].relative_to(APP).as_posix()}:{c['line']}   tests={c['tests']}")
if found:
    print("  Wire it, or mark the declaration WIRED-BY / UNWIRED / E-BLOCKED / TEST-ONLY.")
    sys.exit(1)
print("  check_wired: none — everything the tests touch, the app reaches")
sys.exit(0)
