# Handoff: Bindu Feed — The Upgrade Pass

**Claude Design → Claude Code · 27 Aug 2026**

---

## What to do first

**Read `HANDOFF.md` before anything else — including before reading the rest of this README.** It contains a prime directive that exists because the last handoff derailed on it, and a decoder table that prevents the same failure. Nothing in this bundle should be acted on until §1 and §2 of that file are read.

Reading order:

| Order | File | What it is |
|---|---|---|
| 1 | **`HANDOFF.md`** | Prime directive · the scope-note decoder · precedence ladder · reading order · the sequence · the seven comps · conflict register · protect list · recurring bug classes |
| 2 | `audit/AUDIT.md` §H | The prioritized rebuild list. The shape of the whole gap in ten minutes. |
| 3 | **`comps/*.html` — run them in a browser** | Not read. *Run.* Each has an *as built* toggle or an A/B; the delta is meant to be felt. |
| 4 | `audit/AUDIT.md` §A | The data/content model. Gates everything downstream. |
| 5 | `HANDOFF-BUILD-LIST.md` | Everything in scope that is not yet designed. |
| 6 | `HANDOFF-RULINGS.md` | Settled rulings; open rulings that must not be guessed. |
| 7 | `HANDOFF-VERIFICATION.md` | Behavioural acceptance checks, per pass. |
| 8 | `HANDOFF-AIRTABLE.md` | The parallel data track. No code; gates code. |

Then **write a gameplan before writing code.** `HANDOFF.md` §4 states what it must name.

---

## Overview

Bindu Feed is a shipped SwiftUI iOS app — a consciousness instrument built as **one continuous space**: fifteen registers on a single axis, with the Feed at life-size, the Universe pulling out into the many, the Point pulling in into the one, and the Light past the sky.

The app was built in Claude Code from a Claude Design package, but parts were built from **prose** rather than from the **rendered** design files, and it diverged. A read-only differential audit (`audit/AUDIT.md`, produced against `main` @ `1ef88da`) found 28 blockers, ~95 major findings, and 12 open data/content-model questions.

The audit's headline is the important part:

> *"Every authored data table that was ported, was ported perfectly… What was lost is **mechanism**."*

Nothing needs re-deriving. Every number the design specifies is still in the design files. What was consistently lost is behaviour over time — continuity of scale, gesture-carries-the-reading, per-exhale accumulation, a passage having a middle, sound answering the absence of a hand — each replaced with the nearest static or one-shot equivalent.

**This bundle is the design response.** Seven rendered comps re-specify the lost mechanisms, plus a build list for what was never designed, plus rulings, verification and the data track.

---

## About the design files

The files in `comps/` are **design references created in HTML** — working prototypes showing intended behaviour, not production code to copy.

**The target codebase already exists**: a SwiftUI iOS app (`Bindu Feed/Bindu Feed/`, repo `aistrangegame/bindu-feed`, branch `main`). The task is **not** to recreate these HTML files in a new environment. It is to **port the mechanisms they specify into the existing SwiftUI app**, using its established patterns — `Instrument/`, `Universe/`, `Point/`, `Light/`, `Return/`, `Rite/`, `Sound/`, `Screens/`, `Theme/`, and the Metal shader `InstrumentField.metal`.

Each comp carries its constants **with design-file line references** in an on-screen notes panel. Those citations are the actual specification; the comp is the demonstration that they produce the intended behaviour.

**Read `HANDOFF.md` §3 for the precedence ladder.** In short: `canon/` wins on literal text and numbers → these comps win on mechanism for the seven areas they cover → `The Instrument v3.html` wins everywhere else → `AUDIT.md` is authoritative on *which delta exists*, not on what the design is.

---

## Fidelity

**High-fidelity, and mechanism-first.**

Every comp is a working instrument with real physics, real gesture handling and real per-frame drawing. Colors, typography, timing constants, easing and gesture gearing are all final and all cited. Where a value is *not* final, the comp says so on screen and in code — see the four provenance states in `HANDOFF-RULINGS.md` (canon · authored · reconstructed · approximate).

**The fidelity that matters most here is not pixel fidelity — it is behavioural fidelity.** A screenshot of any of these comps carries almost none of the specification. The gearing of a gesture, the fact that a ring closes only while a hand keeps asking, the fact that a star's radius is `R = pr · z` rather than a fixed size — these are the deliverable.

---

## Screens / views — the seven comps

Full mechanism detail per comp is in `HANDOFF.md` §5 and in each comp's own notes panel. Summary:

### 1 · `comps/The Seam.html` — the Universe, one continuous descent
Closes `B0.1–B0.4` `B2.1` `B2.2` `B4.1` `B5.1–B5.4` `B6.1`.

- **Continuity.** One camera, `z 0.22 → 34`. A star's radius is `R = pr · z` — the point of light at the sky *grows into* the planet you land on. Overlapping `bands()`, never a switch. This one line is why the built app needed hard `scale == 2/3` early-returns that cut one descent into three screens.
- **The door.** A world offers its story by turning its name into the light: the name rides the sphere, its position always visible as a bright point, legible only on the day side. Drag sideways and the world turns, with inertia, keeping the turn — the design's own law (*vertical walks the axis, horizontal is the register's own gesture*) at the scale where the register is one body.
- **Consent.** In the fall, pulling up descends. The mouth's ring closes only *while the hand keeps asking*, stops the instant you stop, and holds on release. It never fires by itself, and it carries the story with it.
- Constants: `ZMIN .22 · ZMAX 34 · z₀ .30` · pan friction `.945` · zoom `.90` · live velocity `dx/z · .55` on every move · span clamp `520/max(.3,z)` · door at `R > 36` and offset `< W·.42` · fall opens at `z > ZMAX·.93`.

### 2 · `comps/The Chrome.html` — hand-feel and the silence sweep
Closes `C2.1` `C5.2` `F0.1` `F0.2` and the `H0` string finding.

- The four `immense`-preset constants: `DRAG 0.00018 · DAMP 0.956 · span 0.42 · glideDur 5.4`. The build read module defaults instead. **One line; changes the feel of every register in the app.**
- `#where` as the design's object: serif 23 in its own casing at `top:100px`, with the roman + `n of 7` line above and the canon sub-line below. The `sub` strings must be *added to the model* — they do not exist there.
- The tracking helper (`em` was applied as `pt` — ~20 labels 55–85% too wide), the hex-alpha correction (`0D` is 5.1%, not 0.08 — this is why the app reads brighter than the comps), and the deletion of all six invented instruction strings.

### 3 · `comps/The Rooms v4.html` — the archetype rooms
Closes `§A1–A3` and delivers the brief's expansion. **v4 only — v1–v3 are superseded.**

- **The law:** *a room is a voice's own mathematics at four registers — and the way the figure answers your hand is that voice's own gesture.*
- All eleven figures ported from `rite-scenes.js`, raised from a 30%-height Rite panel to the room's full body.
- Eleven distinct gestures: Bindu's room *cannot* be changed (she is undivided) · Neev's hand moves the world, not the monolith · Gaia's hand pulls the divergence angle off 137.507° and the spiral families break into arms · Sid's hand loads the arch · Arch's widens her vibrato (the only voice that sings) · Shweta's slides the circles until there is nothing between them · Karishma's tilts the rectangles and the spiral stays true · Sakshi's pupil follows your hand and cannot be made to blink · Lalita's turns the loom · Ashrey's pull moves all 36 edges of K₉ · Ashram's scrubs his 117 days, because he is the only one whose axis is time.
- **Register 2 has its own depth:** map → story → comment, and *the index is the figure* — every comment sits where that voice's mathematics puts it. A tap descends, a tap on the ground rises, and the vertical always wins and resets the sub-depth.
- Gearing: `240px = one register`, one gesture never carries more than one; `|lat| ≤ 1` is each voice's full range, rubber-banded at the ends.
- **Why this answers §A:** the Mirror holds two cohorts because nobody decided whose room it was. It is Lalita's. Once a surface belongs to a voice, its content model *is* that voice's rule — a foreign row cannot enter, because there is no union to read.

### 4 · `comps/The Reading.html` — the Point's reading gestures
Closes `D5.1` `D5.5` `D5.8` — the largest structural divergence in the app.

- **The seven worlds are not seven ways of picking a star. They are seven ways of reading one.** Same four sections everywhere (`SAY · WALK · HAND · OPEN`); how they arrive *is* the world.
- I stillness (the reading *displaces* the field) · II following the ray (`SAY` at the origin to `OPEN` at the rim) · III parting the veil (read *through* a parting you hold; each section leaves that zone thinner) · IV letterpress under pressure (below `0.12`, no impression) · VII keeping pace.
- **There is no generic star reading** — not anywhere, not as a fallback.
- V and VI are authored in `design-source/world-five.js` and `world-six.js`: V is *turning*, VI is *send and wait*. See `HANDOFF-BUILD-LIST.md` §4.

### 5 · `comps/The Return.html` — any story, and the ring that answers
Closes `E3.1` `E3.2` `E3.4` `A4.3`.

- **The Return carries the story you descended into.** `The Return v2.html:949` hardcodes one story — that was the design's own limit, not a build defect.
- **The rings model:** four movements (strata · the rings · the return · the answering). Age always from **days**, never from rank — including per ring. Bloom and craquelure gate on `rel × trueness`: nothing wears age it has not served.
- **The write-back.** A sealed ring enters *eccentric and settles into true over four seconds*; then voices answer, and each answer binds to the ring it replies to. **This is what fills register 2.** A voice's second comment on a story is not a repeat — it answers what you left there.
- Four arrivals, deliberately unlike, including one story **never returned to** — the state the build never renders and the one every story starts in.

### 6 · `comps/The Aperture.html` — whole without a key
Closes `D6.1–D6.7`.

- The insight: **the model was never supplying the unpredictability.** A random draw from 37 unwalked registers *is* "something you cannot predict."
- Four slots fill locally, and the fourth is a claim about the library rather than the tradition — *"this library has nothing beside it."* Those are the better cards.
- Toggle **a key is present** and the frame does not change; the live call fills two slots and the honest line stays.
- Restored: the eye (two counter-facing triangles verbatim, `42s → 2.4s` busy, with the circle and centre dot), the Arch-register prompt instruction, the four-key JSON shape, both non-repetition guards, all six authored strings.

### 7 · `comps/The Sound.html` — the whole layer as one instrument
Closes `D7.2` `E4.1` `E4.2` `E4.3` `G1.1` `G3.1`. **Both disputed rulings settled and A/B-able in place.**

- Eight places, each with its own bed; moving between them is always a crossfade.
- The waveform shown is the real output on an `AnalyserNode` — you see what you hear.
- **The stillness gate** (axis, third row): press *be still*, then stop touching. A two-oscillator drone swells over 4.6s, the fifth opening toward the octave; touch anything and it is gone in 0.22s. `E4.2` — the one place in the app where sound answers the **absence** of a hand, and it currently ships as silence.

---

## Interactions & behaviour

**Two laws govern every gesture in the app.** Both are the design's, both were lost, both are restored across the comps:

1. **Vertical walks the axis; horizontal is the register's own gesture.** `The Instrument v3.html:5908-5926`. The built app's `axisLocked` contradicts this and makes four Universe registers mutually unreachable (`B0.1–B0.3`).
2. **The hand, made long: a full swipe is one register, not four.** `240px = one register`, clamped to ±1 per gesture, with velocity set live on every move rather than accumulated.

Other behavioural specifications, per comp: continuity of scale under zoom; a world that turns under the hand with inertia; consent-as-continuation at the fall's mouth; four registers per room with the voice's own horizontal; three sub-depths at register 2 with the vertical always winning; five reading gestures at the Point; a ring that settles from eccentric into true over 4s; the Aperture's eye accelerating while busy; eleven sound events with crossfades and no cuts.

**Animation and timing constants are cited in each comp's notes panel** with their design line numbers. Do not re-derive them.

**A recurring failure mode to avoid** — `AUDIT.md` H0: *the app instructs where the design lets you discover.* Six invented strings (`pull to travel`, `be still — the way opens`, `drag to fly · pinch to zoom · tap to approach`, …) exist in no design file, and Brief §16 Law 4 plus `The Instrument v3.html:1084` (*"never a number, never a progress bar"*) forbid the category. Deleting them is nearly free and is the cheapest fidelity win in the audit.

---

## State management

The comps are single-file prototypes with local state; the app's real state layer already exists and mostly works. What the comps *do* specify:

- **Per-surface reading position** — each room's register + sub-depth; each world's `given` count; the Return's movement. All ephemeral except where noted below.
- **The walk handoff** — `design-source/walk-continuity.js` defines a `sessionStorage 'asf.walk'` object carrying the depth he left from, the breath mid-cycle, the particle's age and the ledger. A ceremony's exit must return him to **the depth he left from**, on **the breath he left on** — never to a cold Door, and the 0.1 Hz clock must never restart mid-walk. Check whether this is wired at all.
- **The write-back** — the one genuinely new persistent shape. `HANDOFF-AIRTABLE.md` §B specifies it: a `Returns` record `{story, when, days, words, ringIndex}` and an answer `{voice, ringId, story, lines[]}` bound to the ring it replies to. `days` matters; age is never derived from rank.
- **The content unit, everywhere** — an ordered array of display lines, or prose with authored `\n`. **Never re-split with a sentence splitter.**
- Data/content-model state is `AUDIT.md` §A plus `HANDOFF-AIRTABLE.md`. Twelve open questions, most of them Airtable work rather than code.

---

## Design tokens

### Typography
- **Serif** — `Lora` 400 / 500, for all reading text, titles and voice. Negative tracking on display sizes (`-0.01em` to `-0.016em`).
- **Mono** — `Space Mono` 400, for chrome, labels, codex ids and metadata. Uppercase, tracked `0.1em`–`0.3em`.
- **Critical:** `em` tracking must be converted, not passed through as `pt`. `RoomStyle.swift:20` already knows the conversion. `F0.1`.

### The eleven archetype voices
| Voice | Hex | Glyph | Hz |
|---|---|---|---|
| Bindu | `#E5533C` | `·` | 136 |
| Neev | `#7A8899` | `▽` | 96 |
| Gaia | `#4A9E6B` | `◆` | 174 |
| Sid | `#C4923A` | `△` | 220 |
| Arch | `#D4607A` | `◯` | 330 |
| Shweta | `#ABA7A2` | `◌` | 342 |
| Karishma | `#D4AE4A` | `✦` | 528 |
| Sakshi | `#7B82D4` | `◇` | 285 |
| Lalita | `#9B6BD6` | `∞` | 396 |
| Ashrey | `#3AADA8` | `⬡` | 432 |
| Ashram / Ash | `#C47A52` / `#C0603C` | `◉` / `●` | 198 |

**The eleventh row is an open ruling** — two names, two hexes, two glyphs, two roles. See `HANDOFF-RULINGS.md`. Do not pick.

### The seven Point dimensions
`I #EDE6D6` · `II #B9A5E8` · `III #7D74C9` · `IV #E0713F` · `V #4FC3B8` · `VI` · `VII #D4A94B`

### The thirteen Universe regions
`forge #D4AE4A` · `signal #3AADA8` · `descent #E5533C` · `garden #4A9E6B` · `maya #D4AE4A` · `watcher #7B82D4` · `field #9B6BD6` · `thread #C4923A` · `body #C45A50` · `forgetting #C4A882` · `remembering #8AB5A0` · `circle #D4607A` · `return #9B6BD6`

### The Return's patina palette
`BONE 228,220,205` → `AMBER 208,158,72` → `DEEP 164,112,38`, with `CREAM 255,248,232`.
Age: `a = (days/1095)^0.55` · `sat = 1−0.30a` · `breathMul = 1+0.45a` · `grain = 0.05+0.14a` · `warm = 0.30+0.70a`. **From days, never from ring count.**

### Sound
- Ladder: `FREQS = [174, 285, 396, 417, 528, 639, 741, 852, 963, 136.1]`
- Narrowing: `BEATS = [8, 7.5, 7, 6.5, 6, 5.5, 5, 4.5, 4.2, 4]` — **Point only**
- Master ceiling: no event exceeds `0.075`. *Felt, not heard.*

### Hand-feel
`DRAG 0.00018` · `DAMP 0.956` · `span 0.42` · `glideDur 5.4` · `WHEEL 0.00008` · `PINCH 0.0020` · `K = 393/frameWidth` applied before `DRAG`.

### Breath
Master `10s`, phase `(sin+1)/2` **or** `(1−cos)/2` — **open ruling**, 90° apart, and every `uBr` term in the shader was authored against one of them. Short prompt cadences `3.4 / 3.6 / 4.8 / 6 / 14 / 26s` must be restored alongside the master clock.

### Hex alphas
Eight-digit hex alphas are **hex**: `0D` → 0.051 · `1E` → 0.118 · `22` → 0.133 · `32` → 0.196. Reading them as decimals makes every tinted surface 1.5–1.7× too strong. `F0.2`.

---

## Assets

**None.** Every figure, field, planet, yantra, strata ring and waveform in this package is **drawn procedurally** — canvas or Metal, from the mathematics cited. There are no images, no icons and no fonts to ship beyond the two Google fonts named above.

That is a design property, not a convenience: `rite-scenes.js` states it as *"not decoration laid over a colour, but the mathematics the vantage IS."*

---

## Files

### The handoff (read first)
- `HANDOFF.md` — **start here**
- `HANDOFF-BUILD-LIST.md` · `HANDOFF-RULINGS.md` · `HANDOFF-VERIFICATION.md` · `HANDOFF-AIRTABLE.md`

### `comps/` — the seven new comps. **Run these.**
`The Seam.html` · `The Chrome.html` · `The Rooms v4.html` · `The Reading.html` · `The Return.html` · `The Aperture.html` · `The Sound.html` · `room-figures.js` (extracted module for three room figures)

All are self-contained: open directly in a browser, no server, no build step.

### `design-source/` — what the comps cite, and what the build list builds from
- **The instrument** — `The Instrument v3.html` (6,081 lines, the largest single authority) · `spine-axis.js` · `spine-field.js` · `spine-sound.js`
- **The Point** — `The Point v9.html` · `point-yantra.js` (**188 lines, unbuilt — build-list §1**) · `point-levels.js` · `point-content.js` · `point-sound.js` · `world-one.js` … `world-seven.js` (**all seven authored; V and VI unbuilt — build-list §4**)
- **The Universe** — `The Universe v3.html` · `uni-sky.js` · `uni-rooms.js` · `uni-field.js` · `uni-fall.js` · `uni-deep.js`
- **The ceremonies** — `The Rite v3.html` · `rite-scenes.js` · `The Return v2.html` · `return-strata.js` · `The Light v2.html` · `walk-continuity.js`
- **The field surfaces** — `The Mirror.html` · `The Signal Space.html` · `Practice Door.html` · `Player Detail - The Turning.html` · `Players View.html`
- **Sound** — `field-sound.js`

### `audit/`
- `AUDIT.md` — the read-only differential, 1,130 lines. Authoritative on *which delta exists*.
- `CLAUDE-DESIGN-BRIEF.md` — the brief this package answers.

---

## One last thing

`HANDOFF.md` §9 records the verification of this package, including **three errors found in it and corrected** — one of them a false claim in a comp that would have sent two of the Point's worlds to a generic ScrollView, reintroducing the largest structural divergence in the app.

They are recorded rather than quietly fixed, because the point of this package is that a handoff can be checked. **If you find a fourth, say so.**
