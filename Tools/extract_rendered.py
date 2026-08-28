#!/usr/bin/env python3
"""FORWARD half of Rule 4, inverted so it does not depend on memory.

You cannot enumerate inventions from the design, because inventions are precisely what
is NOT in it. So enumerate the other side: every string literal the app renders, and
require each to match an authored row or carry a recorded divergence. Anything left is
an invention BY CONSTRUCTION — no list of eight, nothing to remember.

Writes Tools/rendered-candidates.json. Tools/rendered-strings.tsv carries the verdicts.
"""
import re, json, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from authored_lib import ROOT, APP, norm, swift_literals

# A literal that never reaches a screen. Shape-based and deliberately conservative:
# anything not matched here goes to the human, not to silence.
NON_UI = re.compile(r"""(?x)
      ^\#?[0-9A-Fa-f]{3,8}$                    # hex colours
    | ^rec[A-Za-z0-9]{14}$ | ^fld[A-Za-z0-9]{14}$ | ^tbl[A-Za-z0-9]{14}$ | ^app[A-Za-z0-9]{14}$
    | ^[a-z]+([.\-][a-z0-9]+)+$                # dotted/dashed keys: bindu.debug.room, r-guard
    | ^%[-\d.]*[a-zA-Z@]                       # format specifiers
    | ^[A-Za-z0-9_]+\.(json|plist|caf|m4a|wav|png|jpg|svg|html|js)$
    | ^(GET|POST|PATCH|DELETE|Bearer|application/json|Authorization|Content-Type)$
    | ^https?://
    | ^[A-Za-z][A-Za-z0-9]*$                   # single bare identifiers / field names
    | ^[\s\W\d]*$                              # punctuation / numbers only
    | ^\[[A-Za-z][A-Za-z0-9]*\]                  # "[AirtableService] ..." debug prints
    | \{Type\}\s*= | \{Status\}\s*= | ^AND\( | ^OR\( | ^NOT\(   # Airtable formulas
    | ^[A-Za-z]+(Voice|Engine|Player|Store|Service|Recorder):\s     # fatalError prefixes
    | ^(Activity|Audio|Ash|Field|Ring|Sealed|Sort|Card|Linked|Parent|Comment|Story|Room|Practice|Mirror|Signal|Return|Resonance|Threshold|Gaia|Archetype|Source|Last|Link)\s[A-Z][a-z]+( [A-Z][a-z]+)?$
    | ^(Lora|SpaceMono|Bold|Medium|SemiBold|Regular|Italic)[-A-Za-z]*$          # font faces
    | ^[yMdHmsEa]{1,4}([-/,.:\s]+[yMdHmsEa]{1,4})*$                             # date formats
    | ^en_US_POSIX$ | ^RECORD_ID\(\) | \.m4a | ^<no body>$
    | ^(Could not|Empty response|No HTTP|No Airtable|Decoding error|Airtable HTTP)  # service errors
""")

# The line the literal sits on, when it plainly is or is not UI.
RENDERS = re.compile(r'Text\(|\.accessibilityLabel|Label\(|\.navigationTitle|placeholder|'
                     r'ctx\.draw|resolve\(|Button\s*\{|\.uppercased\(\)')
NEVER_RENDERS = re.compile(r'UserDefaults|forKey:|\.rawValue|case\s+\w+\s*=|'
                           r'print\(|fatalError|assertionFailure|preconditionFailure|'
                           r'filterByFormula|queryItems|URLQueryItem|'
                           r'"[^"]+"\s*:\s|logActivity|Keychain|\.font\(|custom\(|'
                           r'dateFormat|DateFormatter|identifier:|throw |Error\(|'
                           r'URL\(|addValue|setValue|httpMethod|JSONSerialization|'
                           r'"fields"|"records"|"typecast"|Notification\.Name|'
                           r'#selector|withIdentifier|systemName:|symbolName')

def main():
    out = {}
    for p in sorted(APP.rglob("*.swift")):
        rel = str(p.relative_to(ROOT))
        text = p.read_text(encoding="utf-8", errors="replace")
        lines = text.splitlines()
        # map each literal to the first line it appears on, for context
        for lit in swift_literals(text):
            lit = re.sub(r'\\u\{([0-9a-fA-F]{1,8})\}',
                         lambda m: chr(int(m.group(1), 16)), lit)
            # Swift escapes: \" and \\ reach the screen as " and \ . Leaving them in was a
            # false-positive class -- a canon Rite line read as invented because the design
            # writes the quotes plainly and the app escapes them.
            lit = lit.replace('\\"', '"').replace("\\\\", "\\")
            s = norm(lit)
            s = re.sub(r'\\\((?:[^()]|\([^()]*\))*\)', '\u2026', s)   # \(interp) -> ellipsis
            if not s or len(s) > 400: continue
            if NON_UI.match(s): continue
            if not re.search(r'[A-Za-z]{2}', s): continue
            ctx, ln = "", 0
            for i, L in enumerate(lines, 1):
                if lit[:40] in L: ctx, ln = L.strip(), i; break
            if ctx and NEVER_RENDERS.search(ctx) and not RENDERS.search(ctx): continue
            e = out.setdefault(s.lower(), {"s": s, "sites": set()})
            e["sites"].add(f"{rel}:{ln}")
    rows = [{"s": v["s"], "sites": sorted(v["sites"])[:3]} for v in out.values()]
    rows.sort(key=lambda d: d["s"].lower())
    json.dump(rows, open(ROOT/"Tools"/"rendered-candidates.json", "w"), indent=0)
    print(f"rendered candidates: {len(rows)}")

main()
