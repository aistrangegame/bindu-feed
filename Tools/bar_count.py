#!/usr/bin/env python3
"""Counts one run of the bar, by TARGET, from the result bundle rather than from stdout.

Two things it will not do, both for reasons §10 records:
  · trust the `** TEST SUCCEEDED **` banner — a filter matching nothing prints it
  · trust a FAILED verdict without a duration and a recorded issue — a simulator clone that
    could not launch marks every test on it failed, at 0.000s, with nothing recorded
"""
import json, os, sys

run = os.environ.get("RUN", "?")
try:
    d = json.load(sys.stdin)
except Exception as e:
    print(f"run {run}: UNREADABLE RESULT BUNDLE ({e})"); sys.exit(1)

rows = []
def walk(n, suite, target):
    t = n["name"] if n.get("nodeType") == "Unit test bundle" else target
    t = n["name"] if n.get("nodeType") == "UI test bundle" else t
    s = n["name"] if n.get("nodeType") == "Test Suite" else suite
    for c in n.get("children") or []:
        walk(c, s, t)
    if n.get("nodeType") == "Test Case":
        rows.append({"target": t or "?", "suite": s, "name": n["name"],
                     "result": n.get("result"), "dur": n.get("duration") or ""})
for n in d.get("testNodes", []):
    walk(n, None, None)

if not rows:
    print(f"run {run}: ZERO TEST CASES — an empty run, whatever the banner said"); sys.exit(1)

by = {}
for r in rows:
    b = by.setdefault(r["target"], {"pass": 0, "fail": 0})
    b["pass" if r["result"] == "Passed" else "fail"] += 1

parts = " · ".join(f"{t} {v['pass']}/{v['pass'] + v['fail']}" for t, v in sorted(by.items()))
bad = [r for r in rows if r["result"] != "Passed"]
print(f"run {run}: passed {len(rows) - len(bad)} failed {len(bad)} total {len(rows)}   [{parts}]")

# The clone-death signature: everything failed instantly and nothing was recorded.
if bad and all((r["dur"] or "0").startswith("0.00") for r in bad) and len(bad) > 5:
    print(f"   ⚠ {len(bad)} failures all at ~0s — this is the dead-simulator-clone signature,")
    print("     not a regression. Re-run before believing it. See Tools/bar.sh's header.")
for r in bad[:25]:
    print(f"   FAIL [{r['target']}] {r['suite']} · {r['name']}  ({r['dur']})")
sys.exit(1 if bad else 0)
