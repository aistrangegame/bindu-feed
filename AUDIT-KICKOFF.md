# Audit Kickoff — Bindu Feed vs. the rendered Claude Design

**Paste this into a fresh Claude Code session. Recommended model: Opus 5 (or Opus 4.8). Do NOT use Fable 5 — it is a creative/narrative model, wrong for architecture work.**

## Your job
Produce a **surface-by-surface differential audit** of the shipped app against the *rendered* Claude Design. For each surface: **design intent (rendered source, file:line) → code reality (file:line) → the gap → severity → is it a data/content-model divergence or a visual/interaction one.** This is an **audit, not a rebuild** — the differential map is the deliverable. Do not change code in this pass.

## The cardinal rule (this is why the app went wrong)
The original build followed **prose** (`archive/bindu-feed-phase9-handoff/…`, the Amendment docs) instead of the **rendered** design, and diverged badly. So:
- **Read the RENDERED design files — open and read the actual HTML / JS / shader source inside them:** `Claude Design Round 1/The Instrument v3.html`, everything in `Claude Design Round 1/comps/` (esp. `The Universe v2/v3.html`, `uni-*.js`, `point-*.js`), and `canon/` (frozen wording/numbers/the 66 stars). Follow the precedence in `Bindu Feed/CLAUDE.md` → "SOURCE OF TRUTH & CANON PRECEDENCE."
- **Do NOT audit against the prose docs** in `archive/` — they are superseded and are the source of the original mistake. Use them only to *recognise* where the code was mistakenly built to prose.

## Scope — audit every surface, not just the Universe
Walk each and write the differential:
1. **The Universe** (biggest known divergence — see "known findings" below). Design = `comps/The Universe v3.html` (a free 2-D flight camera). Code = `Universe/UniverseView.swift`, `Universe/UniverseCamera.swift`, `Universe/UniRegions.swift`, `Instrument/AxisTravel.swift`, `Instrument/InstrumentView.swift`.
2. **The Instrument axis / shell shader** — `Instrument/InstrumentField.metal` vs. `The Instrument v3.html`'s `spine-field.js`; the axis physics vs. `spine-travel.js`.
3. **The seven Point worlds** — `Point/PointWorlds.swift`, `Point/PointWorldView.swift` vs. `comps/The Point v9.html` + `point-content.js` (the 66 stars).
4. **The Light / Rite / Return** — `Light/`, `Rite/`, `Return/` + their `Screens/*View.swift` vs. the rendered comps + `canon/spine-light.js`, `canon/spine-sound.js`.
5. **The Mirror + the field surfaces (Signal, Practice Door)** — **the user specifically flagged the Mirror: "the way information was set up from the beginning, not how Claude Design created it."** Audit the *data/content model* here, not just the visuals — how Airtable records map to what the design intended. This may be a foundational divergence.
6. **Players / the archetype homes**, Story Detail, Room Selection, the Turning, Compose, the Feed — vs. their rendered comps.
7. **The data model itself** — how `The Feed` Airtable table (CLAUDE.md §6) is interpreted vs. the design's intent. If the *interpretation* of the content diverged early, everything downstream inherits it.

## Known findings — START from these, do not re-discover them
- **The Universe was built to the wrong paradigm.** The design is a free 2-D flight camera (`comps/The Universe v3.html`: `cam{x,y,z,vx,vy,vz}`, ZMIN 0.22 / ZMAX 34, pan+pinch+tap, the four scales sky→region→world→fall derived from zoom ALONE). The code originally welded those scales onto the 1-D axis drag. A *partial* free-camera rebuild now exists on `main` (`Universe/UniverseCamera.swift`) but the **axis ↔ camera ↔ Light seam is fragile** and broke on device. Three confirmed root causes:
  1. `axisLocked` + `travel.setUniverseMode(...)` are armed only in `.onChange(of: here.key)` — which SwiftUI does NOT fire on first appearance. Entering **directly at the sky register** (`TurnOverlay` "The Universe" → `instrument(-4)`) arrives un-armed → the stillness gate auto-ejects to the Light after 4.6s, and the axis drag competes with the camera. (`InstrumentView.swift` ~:173-180; `AxisTravel.swift` ~:153-160.)
  2. The sky↔Light membrane (surface 0, GATE) is a deliberate **one-way valve** — drag cannot reopen it, so you get trapped in the Light. (`AxisTravel.swift` ~:192-199.)
  3. The camera has **dead momentum** — no velocity tracking, friction too high (0.92/frame), pinch sets no zoom inertia, entry snaps with no ease. (`UniverseCamera.swift` ~:61-107.)
  - **Recommendation:** the Universe most likely wants either a clean from-scratch rebuild to the rendered camera, or a **full decouple from the axis** (the Universe as its own full-screen mode, with the Light reachable explicitly — not via an auto stillness-gate that fires while you look around).
- **Build:** needs the Metal Toolchain component — if `xcodebuild` fails with `cannot execute tool 'metal'`, run `xcodebuild -downloadComponent MetalToolchain` (no sudo). SourceKit "cannot find type" cross-file errors are **false positives** — trust `xcodebuild`, not the IDE squiggles.
- **Build command:** `cd "Bindu Feed/Bindu Feed" && xcodebuild -project "Bindu Feed.xcodeproj" -scheme "Bindu Feed" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build`.
- **Verify entry paths, plural.** A prior session "verified on the sim" but only tested ONE entry path (dragging into the Universe from the Feed) and missed the device path (entering *directly at* the sky via the menu). When you rebuild, reproduce **every** entry path on the sim — the DEBUG "⟿ walk the Instrument" door on `TokenEntryView` (`#if DEBUG`) can be pointed at any `startZ`.

## Output
A single `AUDIT.md` (repo root): the per-surface differential + a **prioritized rebuild list** (what to rebuild from scratch, what to fix, what already matches). Flag anything that is a *data/content-model* divergence separately — those are foundational and must be settled with the user / Claude Design before rebuilding on top of them. **Then stop** — the rebuild is a separate, approved phase.
