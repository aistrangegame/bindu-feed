"""The design corpus as a haystack, for the FORWARD check.

Mirrors authored_lib.load_app(): the same normalisation, run the other way. Comments are
NOT stripped here — a string the design mentions anywhere, including in its own commentary,
is a string someone had a source for. The forward check asks "did we make this up?", and a
design comment is a sufficient answer to that. (The backward check is the strict one,
because there a comment creates a false presence.)
"""
import re, pathlib
from authored_lib import ROOT, norm

SOURCES = [ROOT/"canon", ROOT/"Claude Design Round 2"/"design-source", ROOT/"Claude Design Round 2"/"comps"]

def load_design():
    parts = []
    for base in SOURCES:
        if not base.exists(): continue
        for p in sorted(base.rglob("*")):
            if p.suffix.lower() not in (".js", ".html", ".md"): continue
            t = p.read_text(encoding="utf-8", errors="replace")
            t = re.sub(r'\\u([0-9a-fA-F]{4})', lambda m: chr(int(m.group(1), 16)), t)
            parts.append(norm(t))
    return "\n".join(parts).lower()

SENT = re.compile(r'(?<=[.!?])\s+')

def in_design(s, hay):
    n = norm(s).lower().strip()
    if len(n) < 4: return True
    if n in hay: return True
    parts = [p.strip() for p in SENT.split(n) if len(p.strip()) >= 12]
    return len(parts) > 1 and all(p in hay for p in parts)
