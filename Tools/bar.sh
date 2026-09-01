#!/usr/bin/env bash
# bar.sh — THE THREE-RUN BAR. The deliberate act before any claim of doneness.
#
# `Tools/verify.sh` is the commit gate: seven checkers, ~36s, run by the pre-commit hook. This
# is the other thing, and it is NOT in the hook on purpose — it needs a simulator and takes
# minutes, and a gate slow enough to be bypassed is a gate that will be.
#
# ── WHY IT COUNTS RATHER THAN READING THE BANNER ─────────────────────────────────────────
#
# §10 records both directions of the same fault, and this script exists because both bit:
#
#  · A FILTER THAT MATCHES NOTHING PRINTS `** TEST SUCCEEDED **`. Zero tests run, reported
#    green. Happened twice in this build — once diagnosing a flake, once when a new test file
#    was written one directory above the synchronized group and `-only-testing` matched
#    nothing. The banner cannot tell an empty run from a passing one; a count can.
#  · A SIMULATOR CLONE THAT FAILS TO LAUNCH REPORTS ITS TESTS AS *FAILED*. 22 suites came back
#    red, all at `(0.000 seconds)`, with zero `Issue recorded` lines — the machine was out of
#    process slots. A count catches the empty run that looks green and is blind to the empty
#    run that looks red, so the discriminator is **duration plus a recorded issue**. Hence
#    `-parallel-testing-enabled NO`: clones buy wall-clock and cost the one property the bar
#    exists to have.
#
# ── AND WHY IT REPORTS THE TARGETS SEPARATELY ────────────────────────────────────────────
#
# The bar reported 516 for most of this build and 533 once, for the same suite, because the
# unit target has ~530 Swift Testing cases and the UI target has its own — and whether the
# counter reached both depended on how it walked the result bundle. A number that changes with
# the counter is not a measurement. Both targets are named and counted here, every run.
set -uo pipefail
# Resolve the tools directory BEFORE the cd — `dirname "$0"` is relative, so reading it
# afterwards resolves against the wrong root and the counter cannot be found. The first
# version did exactly that and reported BAR FAILED, which is the right failure: a bar that
# cannot count must never print a number.
TOOLS="$(cd "$(dirname "$0")" && pwd)"
cd "$TOOLS/../Bindu Feed" || exit 2

RUNS=${1:-3}
DEST='platform=iOS Simulator,name=iPhone 17'
pass_all=1

for i in $(seq 1 "$RUNS"); do
  res="/tmp/bar-run$i.xcresult"
  rm -rf "$res"
  xcodebuild test -project "Bindu Feed.xcodeproj" -scheme "Bindu Feed" \
    -sdk iphonesimulator -destination "$DEST" \
    -parallel-testing-enabled NO -resultBundlePath "$res" > "/tmp/bar-run$i.log" 2>&1

  if [ ! -d "$res" ]; then
    echo "run $i: NO RESULT BUNDLE — xcodebuild did not get far enough to produce one"
    tail -5 "/tmp/bar-run$i.log"; pass_all=0; continue
  fi

  xcrun xcresulttool get test-results tests --path "$res" --format json 2>/dev/null \
    | RUN="$i" python3 "$TOOLS/bar_count.py" || pass_all=0
done

if [ "$pass_all" -eq 1 ]; then echo "BAR COMPLETE"; else echo "BAR FAILED"; exit 1; fi
