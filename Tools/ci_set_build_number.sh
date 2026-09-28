#!/bin/bash
# ci_set_build_number.sh — give every Xcode Cloud archive a build number nobody has used.
#
# ── WHY THIS EXISTS ──────────────────────────────────────────────────────────────────────
#
# `CURRENT_PROJECT_VERSION` was set to 1 in `83c8b70` (Phase 7) and never touched again, and
# `Info.plist` reads `CFBundleVersion` from it (`$(CURRENT_PROJECT_VERSION)`). So every archive
# built after the first was **1.0 (1)** — the same build string already uploaded. App Store
# Connect rejects a duplicate `CFBundleVersion` at the TestFlight delivery step, so the cloud
# build could succeed and TestFlight would still show nothing new. Measured 2026-09-28: the
# `.xcodeproj` had not changed since `5aeef7a`, the last TestFlight tag.
#
# The bump is done HERE rather than by hand because a number a human has to remember to raise
# is a number that will be forgotten exactly once, on the release that matters.
#
# ── WHAT IT DOES ─────────────────────────────────────────────────────────────────────────
#
# Rewrites `CURRENT_PROJECT_VERSION` in the project file to `CI_BUILD_NUMBER + BASE`, for all
# three targets (app, tests, UI tests — they must agree or the bundles mismatch). Xcode Cloud
# increments `CI_BUILD_NUMBER` per build of a workflow and starts a NEW workflow at 1, which is
# the one number already spent — hence BASE, which puts the first cloud build at 101 and keeps
# the sequence strictly increasing forever after.
#
# `MARKETING_VERSION` is deliberately NOT touched. The version a person reads is an authoring
# decision; the build number is bookkeeping. Raise 1.0 by hand when 1.0 stops being true.
#
# ── THE GUARD THAT MATTERS ───────────────────────────────────────────────────────────────
#
# With no `CI_BUILD_NUMBER` in the environment this script CHANGES NOTHING and exits 0. It is
# reachable from a normal checkout, and a version-stamping script that mutates a developer's
# project file on a local run is worse than the problem it solves.

set -euo pipefail

BASE=100

if [ -z "${CI_BUILD_NUMBER:-}" ]; then
  echo "ci_set_build_number: CI_BUILD_NUMBER is unset — not in Xcode Cloud, changing nothing."
  exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PBX="$ROOT/Bindu Feed/Bindu Feed.xcodeproj/project.pbxproj"

if [ ! -f "$PBX" ]; then
  echo "ci_set_build_number: FATAL — no project file at $PBX" >&2
  exit 1
fi

NEW=$(( CI_BUILD_NUMBER + BASE ))

# Match any current value, so running twice is idempotent rather than cumulative.
/usr/bin/sed -i '' -E "s/CURRENT_PROJECT_VERSION = [^;]*;/CURRENT_PROJECT_VERSION = ${NEW};/g" "$PBX"

# Verify rather than trust: count what the file now says, and fail loudly on 0.
COUNT=$(/usr/bin/grep -c "CURRENT_PROJECT_VERSION = ${NEW};" "$PBX" || true)
if [ "$COUNT" -eq 0 ]; then
  echo "ci_set_build_number: FATAL — wrote nothing; the build would ship a stale number." >&2
  exit 1
fi

echo "ci_set_build_number: CFBundleVersion → ${NEW} (CI_BUILD_NUMBER=${CI_BUILD_NUMBER} + ${BASE}) on ${COUNT} configurations."
