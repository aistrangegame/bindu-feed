#!/usr/bin/env python3
"""Enforcement + discovery half of the authored-string registry — Rule 4, backwards.

The forward grep proves invented strings are ABSENT. This proves authored strings are
PRESENT. `TURN IT` was caught by memory, not by method; this is the method.

  ./tools/check_authored.py             enforce (exit 1 on a REQUIRED miss)
  ./tools/check_authored.py --clusters  group the REVIEW backlog by source
  ./tools/check_authored.py --discover  also report candidates not yet triaged
"""
import sys, json
from authored_lib import norm, load_app, present, load_registry, CANDIDATES

def main():
    hay = load_app()
    rows = load_registry()
    if not rows:
        print("registry is empty — run Tools/seed_registry.py first"); return 1
    required = [r for r in rows if r["status"] == "REQUIRED"]
    missing = [r for r in required if not present(r["s"], hay)]

    print(f"registry {len(rows)} rows · REQUIRED {len(required)} · missing {len(missing)}")
    for r in missing:
        print(f"  MISSING  {r['s'][:90]!r}\n           ← {r['src']}")

    if "--clusters" in sys.argv:
        import collections
        rev = [r for r in rows if r["status"] == "REVIEW"]
        by = collections.defaultdict(list)
        for r in rev:
            by[r["src"].split(" [")[0].split(";")[0].split("/")[-1]].append(r["s"])
        print(f"\nREVIEW backlog: {len(rev)} authored strings not in the app")
        for f, ss in sorted(by.items(), key=lambda kv: -len(kv[1])):
            print(f"  {len(ss):4d}  {f}")
            for x in sorted(ss, key=len)[:3]:
                print(f"          e.g. {x[:72]!r}")

    if "--discover" in sys.argv and CANDIDATES.exists():
        known = {norm(r["s"]).lower() for r in rows}
        new = [c for c in json.load(open(CANDIDATES)) if norm(c["s"]).lower() not in known]
        print(f"\nun-triaged candidates: {len(new)}")
        for c in new[:40]:
            print(f"  NEW  {c['s'][:86]!r}  [{','.join(c['prov'])}]  ← {c['src'][0]}")
        if len(new) > 40: print(f"  … and {len(new)-40} more")
    return 1 if missing else 0

sys.exit(main())
