"""Shared normalisation and matching for the authored-string registry.

MATCHING. Three false-negative classes were calibrated out by measurement; without
them the report cries wolf and stops being read, which is how a checklist dies:
  1. Swift \\u{XXXX} escapes         "Or\\u{00ED}"  ==  "Orí"   (the Aperture's traditions)
  2. a design string the app splits  canon holds a scene's pair as one string; LightCanon
                                     stores them as separate anchors
  3. curly/straight quotes, em/en dashes, NBSP
"""
import re, pathlib, unicodedata

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP = ROOT/"Bindu Feed"/"Bindu Feed"
REGISTRY = ROOT/"Tools"/"authored-strings.tsv"
CANDIDATES = ROOT/"Tools"/"authored-candidates.json"
SENT = re.compile(r'(?<=[.!?])\s+')

def norm(s):
    s = unicodedata.normalize("NFKC", s)
    s = s.replace("\u2019","'").replace("\u2018","'").replace("\u201c",'"').replace("\u201d",'"')
    s = s.replace("\u2014","--").replace("\u2013","-").replace("\u00a0"," ")
    return re.sub(r'\s+', ' ', s).strip()

# Swift string literals only. Matching the whole file text is WRONG and silently
# defeats the check: this codebase quotes design source in comments constantly, so
# `/// `<span class="go">touch to read</span>` at :1434` kept the check green after the
# rendered string had been deleted. A user-visible string lives in a string literal.
TRIPLE = re.compile(r'"""(.*?)"""', re.S)
SINGLE = re.compile(r'"((?:\\.|[^"\\\n])*)"')

def swift_literals(text):
    out = []
    def take_triple(m):
        out.append(m.group(1)); return " "
    text = TRIPLE.sub(take_triple, text)
    text = re.sub(r'^\s*(///?|//).*$', ' ', text, flags=re.M)      # line comments
    text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.S)             # block comments
    out += [m.group(1) for m in SINGLE.finditer(text)]
    return out

def load_app():
    parts = []
    for p in sorted(APP.rglob("*.swift")):
        t = p.read_text(encoding="utf-8", errors="replace")
        for lit in swift_literals(t):
            lit = re.sub(r'\\u\{([0-9a-fA-F]{1,8})\}', lambda m: chr(int(m.group(1), 16)), lit)
            lit = re.sub(r'\\\((?:[^()]|\([^()]*\))*\)', ' ', lit)   # \(interpolation) -> gap
            parts.append(norm(lit))
    return "\n".join(parts).lower()

def present(s, hay):
    n = norm(s).lower()
    if n in hay: return True
    parts = [p.strip() for p in SENT.split(n) if len(p.strip()) >= 12]
    return len(parts) > 1 and all(p in hay for p in parts)

def load_registry():
    rows = []
    if REGISTRY.exists():
        for i, line in enumerate(REGISTRY.read_text(encoding="utf-8").splitlines(), 1):
            if not line.strip() or line.startswith("#"): continue
            f = line.split("\t")
            if len(f) >= 3: rows.append({"status": f[0].strip(), "s": f[1], "src": f[2], "line": i})
    return rows
