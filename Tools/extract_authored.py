#!/usr/bin/env python3
"""Discovery half of the authored-string registry.

Extracts candidate authored strings from canon/ and the design sources, tagging each
with its PROVENANCE, which is what separates app copy from design-document prose:

  js-literal  a quoted string inside JS — how the comps render their own chrome
  markup      a text node in HTML/JSX markup — app copy when it sits in the phone,
              annotation when it sits in the document around it
  doc         a text node inside a documentation container (p/h2/code/em/strong/
              s/li/.law/.rule/.sub/.hd) — the design explaining itself, never app copy

Writes Tools/authored-candidates.json. The registry file carries the verdicts.
"""
import re, json, pathlib, unicodedata

ROOT = pathlib.Path(__file__).resolve().parent.parent
# **THE DELETION HALF OF RULE 4 WAS BLIND ON `Claude Design Round 1`.** 106 audit findings
# cite it — the whole of Ash's Voice, the Return, the Rite, Home Feed, Settings and the
# Instrument's own file — and none of its authored strings were ever enumerated here, so
# `check_authored` could not fail when one was deleted. This build has deleted authored copy
# on a false premise before (world VII's offer cues, the Light's beat cues), and both times
# the registry is what caught it. `design_lib.SOURCES` was widened 2026-08-30 for the FORWARD
# half; this is the backwards half catching up. Ruled 2026-08-31.
SOURCES = [ROOT/"canon",
           ROOT/"Claude Design Round 2"/"design-source", ROOT/"Claude Design Round 2"/"comps",
           ROOT/"Claude Design Round 1"]
DOC_TAGS = {"p","h1","h2","h3","h4","code","em","strong","s","li","blockquote","td","th","title","summary"}
DOC_CLASSES = {"law","rule","sub","hd","k","note","legend","doc","caption"}

CODEY = re.compile(r'^(?:[#.][\w-]+|https?:|data:|[\d.\s,%-]+|[\w-]+\.(?:js|html|css|png|svg)|rgba?\(|#[0-9a-fA-F]{3,8})', re.I)
CSSISH = re.compile(r'[{};]\s*$|^\s*[-\w]+\s*:\s*[-\d.]|(?<![A-Za-z])\d+(?:px|em|rem|vh|vw|ms)\b|@keyframes|translate\(|var\(--')
IDENTY = re.compile(r'^[a-zA-Z][a-zA-Z0-9_$]*$')
HASWORD = re.compile(r'[A-Za-z]{2,}')

def decode_escapes(s):
    def sub(m):
        try: return chr(int(m.group(1), 16))
        except ValueError: return m.group(0)
    s = re.sub(r'\\u([0-9a-fA-F]{4})', sub, s)
    return s.replace("\\'", "'").replace('\\"', '"').replace("\\n", " ").replace("\\t", " ")

def norm(s):
    s = decode_escapes(s)
    s = unicodedata.normalize("NFKC", s)
    s = s.replace("’","'").replace("‘","'").replace("“",'"').replace("”",'"')
    s = s.replace("—","--").replace("–","-").replace(" "," ")
    return re.sub(r'\s+', ' ', s).strip()

def plausible(s):
    if not (4 <= len(s) <= 400): return False
    if not HASWORD.search(s): return False
    if CODEY.match(s) or CSSISH.search(s): return False
    if IDENTY.match(s): return False
    if '<' in s or '>' in s or s.count('=') > 1: return False
    if re.match(r'^[A-Za-z_$][\w$]*\s*\(', s): return False        # fn calls
    return (' ' in s) or s.isupper()

def js_literals(text):
    for m in re.finditer(r"""(?<![\\])(['"`])((?:\\.|(?!\1)[^\\\n]){4,400})\1""", text):
        yield m.group(2)

def markup_nodes(text):
    text = re.sub(r'<(script|style)\b.*?</\1>', ' ', text, flags=re.S|re.I)
    for m in re.finditer(r'<(\w+)([^>]*)>([^<>{}]{4,400})<', text):
        tag, attrs, txt = m.group(1).lower(), m.group(2), m.group(3)
        cls = re.search(r'class="([^"]*)"', attrs)
        classes = set((cls.group(1) if cls else "").split())
        isdoc = tag in DOC_TAGS or bool(classes & DOC_CLASSES)
        yield txt, ("doc" if isdoc else "markup")

def main():
    seen = {}
    for base in SOURCES:
        if not base.exists(): continue
        for p in sorted(base.rglob("*")):
            if p.suffix.lower() not in (".js", ".html"): continue
            rel, text = str(p.relative_to(ROOT)), p.read_text(encoding="utf-8", errors="replace")
            items = [(r, "js-literal") for r in js_literals(text)]
            if p.suffix.lower() == ".html":
                scripts = " ".join(re.findall(r'<script\b[^>]*>(.*?)</script>', text, flags=re.S|re.I))
                items = [(r, "js-literal") for r in js_literals(scripts)] + list(markup_nodes(text))
            for raw, prov in items:
                s = norm(raw)
                if not plausible(s): continue
                e = seen.setdefault(s.lower(), {"s": s, "src": set(), "prov": set()})
                e["src"].add(rel); e["prov"].add(prov)
    out = [{"s": v["s"], "src": sorted(v["src"]), "prov": sorted(v["prov"])} for v in seen.values()]
    out.sort(key=lambda d: d["s"].lower())
    json.dump(out, open(ROOT/"Tools"/"authored-candidates.json","w"), indent=0)
    import collections
    c = collections.Counter(p for d in out for p in d["prov"])
    print(f"candidates: {len(out)}   by provenance: {dict(c)}")

main()
