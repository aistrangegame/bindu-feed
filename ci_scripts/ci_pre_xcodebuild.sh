#!/bin/bash
# Xcode Cloud runs this after the clone and before xcodebuild.
#
# Apple documents `ci_scripts/` as living NEXT TO the Xcode project — which here is
# `Bindu Feed/`, not the repository root. An identical hook exists at the root as insurance,
# because the cost of guessing wrong is a whole deploy cycle. Both delegate to one
# implementation so they cannot drift apart.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
while [ "$D" != "/" ] && [ ! -d "$D/Tools" ]; do D="$(dirname "$D")"; done
exec "$D/Tools/ci_set_build_number.sh"
