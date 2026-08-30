#!/usr/bin/env python3
"""check_wired — THE ELEVENTH SHAPE: built, asserted, and driven by nothing.

A symbol whose only caller is a test looks alive to a grep and to a reviewer, and proves
only that it COMPUTES. This build generates that class deliberately: every
extraction-for-testability creates a symbol whose first caller is a test, and the wiring is
a separate act that can simply not happen. Ten were found by hand on 2026-08-30
(`bow`, `easesOnRelease`, `niches`, `emit`, `spanda`, `splitAmount`, `homeFlash`, `keeping`,
`goldChannel`, `stackFrom`) — this makes the list standing instead of one-time.

THE RULE: an app-target function with ZERO call sites in the app and ONE OR MORE in the
tests must carry an explicit marker at its declaration saying why. Wire it, or say what it
is waiting for:

    WIRED-BY(where)   driven from somewhere this grep cannot see (a closure, a KVO key path)
    UNWIRED(row)      built and correct; its audit row is OPEN and names the wiring as owed
    E-BLOCKED(why)    built, correct, and awaiting a state that does not exist yet
    TEST-ONLY(why)    a deliberate test hook, e.g. `resetForTesting`

The marker lives at the declaration, not in this file, so the exemption is visible to the
next reader of the code rather than buried in a tool.

FRAMEWORK CALLBACKS ARE EXCLUDED BY CONFORMANCE, NEVER BY NAME. `audioPlayerDidFinishPlaying`
is not special because of what it is called — it is a requirement of `AVAudioPlayerDelegate`,
invoked by the framework. Excluding it by name would also excuse an app method that happened
to be named similarly, so the exclusion keys on the enclosing type's conformance list.
"""
import re, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP  = ROOT / "Bindu Feed" / "Bindu Feed"
TEST = ROOT / "Bindu Feed" / "Bindu FeedTests"

# Protocols whose requirements are invoked BY THE FRAMEWORK. A func declared inside a type or
# extension conforming to one of these has a caller no grep can see.
CALLBACK_PROTOCOLS = {
    "AVAudioPlayerDelegate", "AVAudioRecorderDelegate", "UIApplicationDelegate",
    "UNUserNotificationCenterDelegate", "URLSessionDelegate", "URLSessionDataDelegate",
    "UIViewRepresentable", "UIViewControllerRepresentable", "ObservableObject",
    "UITextViewDelegate", "UITextFieldDelegate", "UIScrollViewDelegate", "CAAnimationDelegate",
}
# SwiftUI / Swift structural members the compiler or framework calls.
STRUCTURAL = {"body", "makeUIView", "updateUIView", "makeCoordinator", "makeUIViewController",
              "updateUIViewController", "hash", "encode", "main", "==", "<", "id"}

MARKER = re.compile(r"\b(WIRED-BY|UNWIRED|E-BLOCKED|TEST-ONLY)\s*\(")

def strip_code(t):
    """Comments and string literals removed — for COUNTING USES only."""
    t = re.sub(r"/\*.*?\*/", "", t, flags=re.S)
    t = re.sub(r"^\s*///?.*$", "", t, flags=re.M)
    return re.sub(r'"(?:[^"\\]|\\.)*"', '""', t)

def load(d):
    return {p: p.read_text(encoding="utf-8", errors="ignore") for p in d.rglob("*.swift")}

app_raw, test_raw = load(APP), load(TEST)
app  = {p: strip_code(t) for p, t in app_raw.items()}
test = {p: strip_code(t) for p, t in test_raw.items()}

def conformances_at(raw, line_idx):
    """The conformance list of the innermost type/extension enclosing this line.
    Keyed on the DECLARATION, which is what makes the exclusion conformance-based."""
    lines = raw.split("\n")
    best = set()
    for i in range(line_idx, -1, -1):
        m = re.match(r"\s*(?:public |private |internal |final |@\w+\s+)*"
                     r"(?:extension|struct|class|enum|actor)\s+\w+\s*:\s*([^{]+)\{", lines[i])
        if m:
            best = {c.strip() for c in m.group(1).split(",")}
            break
    return best

def uses(name, corpus):
    n = 0
    pat = re.compile(r"(?<!\w)" + re.escape(name) + r"\s*\(")
    for p, t in corpus.items():
        for mm in pat.finditer(t):
            if re.search(r"\bfunc\s+$", t[max(0, mm.start() - 40):mm.start()]):
                continue
            n += 1
    return n

findings = []
checked = 0
for p, raw in app_raw.items():
    lines = raw.split("\n")
    for i, ln in enumerate(lines):
        m = re.search(r"\bfunc\s+([A-Za-z_]\w*)\s*[\(<]", ln)
        if not m:
            continue
        name = m.group(1)
        if name in STRUCTURAL or name.startswith("test"):
            continue
        if conformances_at(raw, i) & CALLBACK_PROTOCOLS:
            continue
        checked += 1
        # the marker may sit on the declaration or in the doc block just above it
        window = "\n".join(lines[max(0, i - 14):i + 1])
        if MARKER.search(window):
            continue
        a, t = uses(name, app), uses(name, test)
        if a == 0 and t > 0:
            findings.append((name, p.relative_to(APP).as_posix(), i + 1, t))

print(f"  check_wired: {checked} app functions considered")
if findings:
    print(f"  {len(findings)} BUILT-BUT-UNWIRED (app call sites 0, test call sites > 0):")
    for name, f, ln, t in sorted(findings):
        print(f"      {name:28s} {f}:{ln}   tests={t}")
    print("  Wire it, or mark the declaration WIRED-BY / UNWIRED / E-BLOCKED / TEST-ONLY.")
    sys.exit(1)
print("  check_wired: none — every tested app function has an app caller")
sys.exit(0)
