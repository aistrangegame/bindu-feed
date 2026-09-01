# Bindu Feed — handoff

**Branch `upgrade-pass-a-to-c`, 2026-08-31.** Everything below is measured, not remembered.

---

## ⛔ 1 · YOUR PHONE MUST BE ON iOS 18.0 OR LATER

The deployment target is **18.0** in all six build configurations. **TestFlight will not
offer the build to a device below 18.0** — it will not appear, and there is nothing to
diagnose. Check Settings → General → About → iOS Version before you deploy.

This repo documented 17.6 in two places until today. The first Release archive's
`MinimumOSVersion` is what corrected it: the docs were wrong and the project was not.

---

## 2 · The sound has never been heard by anyone. Your first walk is its first hearing.

Not a gap in the work — the one class of thing the harness cannot observe.

**What is established:** every value in the sound layer verifies by reading and by offline
render. Pitches against `VOICES` and `canon/spine-light.js`; peak gains, ramps and intervals
against `canon/spine-sound.js`; the bed's filter, the beat frequencies, the delay's
parameters. `OfflineRender` measures signed differences — a peak before and after a law fires
— and those numbers are real.

**What cannot be:**

- whether **0.032 is audible under a 0.12 bed** at your listening volume — a rendered peak is
  a number, audibility is a judgement
- **the binaural pair.** The Simulator reports as built-in/no-headphones *by construction*, so
  every run to date has taken the single-centred-tone fallback. The dual-oscillator path has
  never rendered on a machine that could produce it.
- whether the **four strike voices sound like four things** — they are measured apart
- **mix balance across a session.** Every level is individually correct and nobody has heard
  them together.

**Expect to tune levels. That is the expected outcome, not a defect report.** Note which voice
and roughly how far off; don't chase it mid-walk.

---

## 3 · Before you open the app

`Coverage/10-OWED.md` opens with a nine-item gate. Eight of them change what a **correct** app
does, globally, in ways the walk itself cannot reveal — Reduce Motion silences every one-shot
in the app; Low Power throttles every time-based gate; Display Zoom moves the geometry one
whole section is measured against. **A walk begun without them records a dozen failures
against a build that is fine**, and by the time the pattern shows, the walk is spent.

Read that box first. It is the script.

---

## 4 · What state the build is in, honestly

**It is walkable and it is not finished, and those are now different things on purpose.**

On 2026-08-31 the goal changed from *a fully-corrected build* to *a whole experience you can
walk*. The line: **build only what changes what a surface SAYS or DOES; record everything that
changes a number.** 178 open items were triaged against it.

| | triaged | built | recorded |
|---|---:|---:|---|
| sibling-constant findings | 106 | 19 | 87 |
| audit rows (OPEN · PARTIAL · NEEDS-JUDGMENT) | 72 | 25 | 47 |
| **total** | **178** | **44 raw → 37 distinct** | **134** |

The 134 are in `Coverage/13-RECORDED.md` **with their findings intact** — design source, app
site, and what moves. They are **not closed**: a closed row asserts the app matches the design,
and these assert something narrower and true — *the app makes the design's claim on this
surface, at a different value.* Any of them is a read away from being built.

**Verification, as of this commit:** seven checkers green (`Tools/verify.sh`, run by the
pre-commit hook) · **541 tests, three consecutive clean runs** (`Tools/bar.sh`, which counts by
target and refuses to print a number it cannot substantiate).

---

## 5 · The archive works

`xcodebuild archive -configuration Release` succeeds. Verified in the product rather than
trusted from the banner: **arm64** device slice, `default.metallib` (the Metal shader compiles
for hardware — no simulator build had ever proven that), `Assets.car` with the App Icon, the
three fonts, the microphone usage string, and Xcode's own validation utility. **5.6 MB.**

It was done early, deliberately, because nothing in this project had ever exercised Release
codegen or a device slice. It passed first time and surfaced the iOS 18 fact above.

---

## 6 · What is deliberately absent — do not "fix" these

Two surfaces are **correct while empty**, and both have been misread as broken before:

- **A sealed return with no answers** reads *"no voice has spoken twice here yet."* Answers are
  authored by a person and held in the base; the app renders what is there and invents
  nothing. **On the walk that is a PASS.**
- **The Light has six scenes.** Six is the canon's number. A seventh would be invented content.

`Coverage/10-OWED.md` §3b carries both with the reasoning. Where the design names the content
as somebody's act, an empty surface is the mechanism working.

---

## 7 · Where to start reading

| | |
|---|---|
| `Coverage/10-OWED.md` | **the walk script.** Gates first, then every row with its close condition |
| `Coverage/13-RECORDED.md` | the 134 recorded items, buildable later |
| `Coverage/12-SIBLING-CONSTANTS.md` | the sweep that produced them |
| `Bindu Feed/CLAUDE.md` §10 | the load-bearing decisions, and the fourteen shapes of fault this build has met |
| `Coverage/0-INDEX.md` | everything else, in order |
