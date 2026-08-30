#!/usr/bin/env bash
# THE GATE — all six checkers, one exit code.
#
# `428c4ca` was committed with `check_citations` RED. The output was printed, and read past.
# **A gate that depends on someone noticing red is not a gate**, and this build's entire
# finding is that the reader is the unreliable part — every fault in §10 survived because a
# person looked at correct output and drew the wrong conclusion from it.
#
# So the check stops being observational. Non-zero here blocks the commit, via
# `.git/hooks/pre-commit`, and no amount of confidence substitutes for the exit code.
#
#   ./Tools/verify.sh          run all six, exit non-zero if any fails
#   ./Tools/verify.sh --quiet  only print failures
#
# The unit suite is NOT here on purpose: it needs a simulator and takes minutes, and a gate
# slow enough to be bypassed is a gate that will be. The three-run bar stays a deliberate act
# before a claim of doneness; this guards the five that run in seconds.
set -uo pipefail
cd "$(dirname "$0")/.."

CHECKS=(check_authored check_rendered check_citations check_audit_ids check_status check_wired)
failed=()

for c in "${CHECKS[@]}"; do
  out="$(python3 "Tools/$c.py" 2>&1)"
  if [ $? -eq 0 ]; then
    [ "${1:-}" = "--quiet" ] || printf '  %-18s GREEN\n' "$c"
  else
    failed+=("$c")
    printf '  %-18s RED\n' "$c"
    printf '%s\n' "$out" | sed 's/^/      /'
  fi
done

if [ ${#failed[@]} -ne 0 ]; then
  printf '\nBLOCKED — %d of %d checkers failed: %s\n' \
         "${#failed[@]}" "${#CHECKS[@]}" "${failed[*]}"
  printf 'Fix them, or state plainly in the commit why a red one is being carried.\n'
  exit 1
fi
exit 0
