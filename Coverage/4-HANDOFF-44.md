# 4 · HANDOFF-VERIFICATION.md — all 44 lines, status and METHOD

Generated 2026-08-28 17:33.

**How** a line was verified matters as much as whether. The file's own rule is
*"If a check cannot be run, the mechanism is not observable — and that is itself the finding."*

- `ON DEVICE` — walked on the simulator with a screenshot or a measured value.
- `MEASURED` — a number read off the device in pixels/points.
- `READING` — verified in source only. Correct for values; **not** sufficient for positions or behaviour.
- `NONE` — never checked.
- `INVALIDATED` — walked in an earlier pass, then code changed underneath it. Not a pass.

Status and method below are my own record and are exactly what Claude Chat should rule on.


## THE TRAPS

| # | line | status | method / evidence |
|---:|---|---|---|
| 1 | No instructional string has come back. | **PASS** | READING — and now stronger than the line asks: `check_rendered.py` proves it BY CONSTRUCTION (992 rendered strings, 0 inventions), not against a remembered list of eight. |
| 2 | No fixed reference is shrink-wrapped. | **PASS** | READING — `InstrumentView.swift:427` `step = 21.0`, `railH = (n-1)*step`. Explicit, not content-sized. |
| 3 | Every interactive constant swept to both limits. | **PARTIAL** | NONE for most. The axis and Rooms verticals were exercised incidentally during walks; no constant was deliberately driven to min AND max. This is a genuine gap. |
| 4 | No age derived from an index. | **PASS** | READING — `Ring Index` commented POSITION ONLY at model and service; per-ring age flows `FeedStore:781 → ReturnView:55 → ReturnStrata:88` from each ring's own days. |
| 5 | The protect list is untouched. | **PASS** | READING — re-diffed this session. Four of twelve changed, all sanctioned adds; metal deletions are all signature/comment lines with 14 motif bodies intact. |

## PASS 1 · THE SEAM

| # | line | status | method / evidence |
|---:|---|---|---|
| 6 | A star grows into the planet you land on. | **PASS** | ON DEVICE — walked sky → structure → world; the star grew continuously into a disc. No early-return observed. |
| 7 | All four Universe registers are reachable, on a cold first launch. | **PARTIAL** | READING — `axisLocked` is gone (all 5 remaining refs are comments recording its deletion). Not walked on a COLD launch, which is what the line specifically asks. |
| 8 | No dead band at the Feed edge. | **NONE** | NONE — never walked. Listed in the handoff's own re-walk set. |
| 9 | The shader's `uZ` is live. | **PARTIAL** | READING — `InstrumentView.swift:531` passes live `z`. Never confirmed visually that the field responds as you travel. |
| 10 | A world offers its story, and the story opens. | **PASS** | ON DEVICE — the three-face turn was built this session and walked: terminator, three seams, third face, `TURN IT` at H−186. |
| 11 | The fall reaches layer four. | **NONE** | NONE — and the earlier diagnosis was WRONG. Not a momentum problem: `desc` only moves while the fall is open, and `UniverseView.swift:417` opens it only on `R > 34 && depth > 0`, where `depth` = sealed Return rings. The fall opens only on a story that already carries a ring. |
| 12 | The Return never fires without consent, and never arrives empty. | **PASS** | ON DEVICE — walked in Pass 6; the ring closes only while pulling. |
| 13 | The Light is escapable. | **PASS** | ON DEVICE — `‹ leave` present at every Light stage this session. |

## PASS 2–3 · SWEEPS AND CONSTANTS

| # | line | status | method / evidence |
|---:|---|---|---|
| 14 | The four hand-feel constants are the runtime preset. | **PASS** | READING — `AxisTravel.swift:77` DRAG 0.00018, DAMP 0.956, span 0.42; glideDur 5.4. |
| 15 | Hex alphas read as hex. | **PASS** | READING — the four converted values present. |
| 16 | Tracking is em, not points. | **PASS** | READING — `Theme.swift:127` `spaceMonoTracked(_:em:)` exists and is used throughout. |
| 17 | `#where` is the design's object. | **PASS** | ON DEVICE — roman + `n of 7` + sub-line seen rendering (`I · 1 OF 7`, `II · 2 OF 7`). |
| 18 | A gesture means the same on every screen size. | **PARTIAL** | READING — `InstrumentView.swift:201` sets `designScale = 393/width`. Only ever run on one simulator size; never tested on a second. |

## PASS 4 · THE ROOMS

| # | line | status | method / evidence |
|---:|---|---|---|
| 19 | One gesture is one register. | **PASS** | MEASURED — a 360pt swipe advanced exactly one register, never two. |
| 20 | The horizontal is bounded and is the voice's own. | **PARTIAL** | READING — Bindu's strain verified against `The Rooms v4.html:203`. Shweta's non-springing range and Ashrey's 36 edges never walked. |
| 21 | Register 2 has three depths, indexed by the figure. | **PASS** | ON DEVICE — sub-depth 2 reached in Lalita, Karishma and Sakshi; the vertical resets it. |
| 22 | The map shows the gap honestly. | **PASS** | ON DEVICE — dim marks at real positions against lit ones; `101 stories · none twice`. |
| 23 | All eleven rooms exist. | **PASS** | ON DEVICE — counted on screen: eight ways of reading, two roots, one who replies. |
| 24 | The Mirror reads one cohort. | **NONE** | NONE — never checked in either direction. |

## PASS 5 · THE POINT

| # | line | status | method / evidence |
|---:|---|---|---|
| 25 | The yantra exists. | **PASS** | MEASURED — enclosure radius 291px confirmed across two enclosures; nodes re-project through `anchors()`. |
| 26 | No world routes to a generic reading. | **PASS** | READING — seven distinct `Read*` structs, no shared fallback. |
| 27 | The reading is carried by the hand. | **PASS** | READING + PARTIAL DEVICE — all seven worlds now say the design's own cue at the design's own moment (18 of 25 authored cues present, up from 2). Worlds I and II walked; III–VII by reading. |
| 28 | World V's guard pane behaves. | **INVALIDATED** | Walked in Pass 5, then the per-world recede and the cue port both changed code beneath it. Not re-walked. |
| 29 | The staged descent plays. | **PASS** | ON DEVICE — walked this session; tap-to-skip works. |
| 30 | The gate has its five canon deals. | **PASS** | READING — `PointDeals.swift` verbatim from `canon/point-content.js:422-428`. |
| 31 | The Aperture is whole with no key. | **PARTIAL** | READING — `ApertureView.swift:57` `static var drawn: Set<String>` gives the session never-repeat. The no-key path was never walked. |

## PASS 6 · THE CEREMONIES

| # | line | status | method / evidence |
|---:|---|---|---|
| 32 | The Return carries the story you descended into. | **PARTIAL** | READING — no hardcoded `C-1052` in the Return path. Three different stories never actually fallen into. |
| 33 | A story never returned to renders correctly. | **NONE** | NONE — the zero-ring default was never rendered on device. |
| 34 | Age is from days, per ring. | **PASS** | READING — wired end to end `FeedStore:781 → ReturnView:55 → ReturnStrata:88`; craquelure gated at `rel > 0.5`. |
| 35 | A return writes back, and voices answer the return. | **PARTIAL** | ON DEVICE + BASE — the write-back was verified against Airtable (two rows, four laws). The room's `one on the story, N answering returns` line was never confirmed. |
| 36 | The ceremony returns him to the depth he left from. | **PARTIAL** | READING — `Breath.originSeconds` is launch-anchored so the clock cannot restart; the depth carry is `pendingLaunchRoute`. Never walked as a round trip. |
| 37 | The Light's column lifts and masks. | **PASS** | MEASURED — five anchors arrived, column lifted ~146pt, top masked, nothing overflowed. |
| 38 | The Light's six presences exist and you choose. | **PASS** | ON DEVICE — six presences, only the armed one named, scene entered. |

## PASS 7 · THE SOUND

| # | line | status | method / evidence |
|---:|---|---|---|
| 39 | Be still, and the app answers your stillness. | **READING-ONLY** | READING — and `AxisTones.swift:158` records that the swell is 3.33s where the design says 4.6s. NEVER HEARD. |
| 40 | The beats narrow. | **READING-ONLY** | READING — `VoiceCharacter.swift:72` matches `point-sound.js:11` exactly. NEVER HEARD. |
| 41 | Two beds, by surface. | **READING-ONLY** | READING — `BedMode { field, climbing }`, room mapping at `SoundEngine:368`. NEVER HEARD. |
| 42 | Pitch and timbre come from different tables. | **READING-ONLY** | READING — eleven CHAR timbres present and distinct. NEVER HEARD. |
| 43 | The Light is not silent. | **READING-ONLY** | READING — the four Light calls exist. NEVER HEARD. |
| 44 | Nothing cuts. | **FAIL** | READING — and this one is a demonstrable FAIL, not merely unheard. The line says *no event exceeds 0.075*; `SoundEngine.riteThreshold` uses `peak: 0.30` and `riteBowl` `0.32`, fired from 19 call sites across the whole app. Documented as `AUDIT.md:944` G3.3 and never fixed. |


---

## Counts

- **PASS** — 24
- **PARTIAL** — 9
- **READING-ONLY** — 5
- **NONE** — 4
- **INVALIDATED** — 1
- **FAIL** — 1

Total: 44 of 44.

### The shape of it

- **Only 12 of 44 were walked on a device or measured.**
- **6 of 44 are the sound, and not one has been heard.** One of them (#44) is a demonstrable fail.
- **4 are NONE** — never checked at all: the Feed-edge dead band, the fall's layer four, the Mirror's cohort, and the zero-ring Return default.
- **1 is INVALIDATED** — world V's guard pane was walked, then changed underneath.
- **9 are PARTIAL** — the value is right by reading but the behaviour the line actually asks about was never observed.
