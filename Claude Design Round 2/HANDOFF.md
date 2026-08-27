# HANDOFF — Bindu Feed · Claude Design → Claude Code

**Rev 1 · 27 Aug 2026.** Against `AUDIT.md` (2026-08-25 @ `1ef88da`) and `CLAUDE-DESIGN-BRIEF.md`.

Read all five handoff files before writing any code:

| File | What it holds |
|---|---|
| **`HANDOFF.md`** (this) | Prime directive · the scope-note decoder · precedence · reading order · sequence · the comps |
| `HANDOFF-BUILD-LIST.md` | Everything in scope that is **not yet designed** — build these |
| `HANDOFF-RULINGS.md` | Rulings settled here · rulings still open (do not guess) |
| `HANDOFF-VERIFICATION.md` | Behavioural acceptance checks, per pass |
| `HANDOFF-AIRTABLE.md` | The parallel data track — no code, gates code |

---

## §1 · PRIME DIRECTIVE

### Rule 1 — nothing in this package is a prohibition on building

Every sentence of the form *"this comp is not X"* / *"X is out of scope"* / *"placement here is schematic"* is a **provenance statement**. It says *which file to read for X*. It never means X should not exist.

§2 decodes every such sentence in all seven comps, individually, with a ruling. **If you find a scope note that is not in that table, treat it as provenance and ask.**

### Rule 2 — rendered beats prose

The seven comps are the specification; **this document is subordinate to them**. Where this document and a comp disagree, the comp wins and this document has a bug — report it.

Where a comp and the audit disagree on **a number**, the design file both cite wins. Where they disagree on **a behaviour**, the comp wins: it was built by running the design, not by reading it.

### Rule 3 — do not resolve a new conflict silently

§6 is a register of every known contradiction, each already resolved. It is not a list of open questions. If you hit a contradiction **not** in §6: stop, name it, ask. Picking a side silently is exactly how the yantra was lost.

---

## §2 · WHY THE LAST HANDOFF DERAILED — AND THE DECODER

### The failure, in one sentence

A scoping note was read as a prohibition and **the yantra was never built**. `point-yantra.js` is 188 lines — nine triangles, three squares, two petal rings, the `BAND` camera, the annulus of attention — with no counterpart anywhere in the app. The audit calls it *"the largest single absence on the surface."* Star `r-geometry` tells the reader *"You are inside one right now"*, pointing at something that does not exist.

The mechanism matters more than the instance. A design package necessarily says *"this file is not authoritative for X."* That has two readings — *"read elsewhere for X"* and *"X is not wanted"* — and a build session under pressure takes the second, because the second is actionable and the first is work.

### The decoder — every scope note in all seven comps, ruled

| Note, verbatim | Where | Wrong reading | **Ruling** |
|---|---|---|---|
| *"Not the yantra (`point-yantra.js`, D3.1)"* | `The Reading.html:73` *(now corrected in-file)* | the yantra is out of scope | **BUILD IT.** The Reading specifies reading gestures, not the yantra. Highest-priority absence in the app. All 188 lines. → build-list §1 |
| *"Not the staged descent (D4.1)"* | `The Reading.html:73` | skip the descent choreography | **BUILD IT.** `point-levels.js:198` `descend()`. 5 stages × 3400ms, tap-to-skip, `‹ ascend`, light shaft, world-dimming. → build-list §2 |
| *"Not V or VI, which have no bespoke module in the design either"* | `The Reading.html:73` | V and VI get the generic reading | **THIS NOTE WAS FACTUALLY WRONG AND IS CORRECTED.** `world-five.js` (463 lines) and `world-six.js` (468 lines) are fully authored. V is *turning*; VI is *send and wait*. → build-list §4 |
| *"Region armatures are already verbatim in `UniRegions.swift`… placement here is schematic… Do not port this file over those."* | `The Seam.html:58,124` | the Seam's placement is wrong / the Universe draw path is fine | **KEEP + FIX.** Keep `UniRegions`'s 13 `place()` armatures and `drawPlanet` — verbatim. Fix the star radius to `R = pr · z` (B4.1). The Seam owns *continuity, the door, consent*; `UniRegions` owns *where a star sits*. No conflict. |
| *"The fifteen register shells are schematic here — `InstrumentField.metal` already owns that layer."* | `The Chrome.html:112` | the shader needs no work | **KEEP + FIX.** The 15 motifs are verbatim and protected. Three additions still required: `uBack[9]` in `mVeil`; `ROOMS[13]` + `HUES[2..4]` as live uniforms; drive the six pinned uniforms. |
| *"Not the other eight rooms"* | `The Rooms v4.html` | three rooms ship, eight do not | **BUILD ALL ELEVEN.** Framework is general; three are exemplars. Figures exist verbatim in `rite-scenes.js`; `MAPGEO` covers all eleven. → build-list §7 |
| *"Not sound — belongs to the sound pass"* | Rooms v4, Seam, Aperture, Reading | these surfaces are silent | **DESIGNED.** The sound pass happened: `The Sound.html`. No surface is silent by design. |
| *"The story surface itself is out of scope here"* | `The Seam.html:55` | a world's name need not open anything | **WIRE IT.** B6.1 is a BLOCKER — there is currently no route from a world to its story. The door opens `StoryDetailView` (protected, bit-exact). |
| *"APPROXIMATE… Do not treat as canon"* (World I Laboratories) | `The Reading.html:149` | World I's layout is undefined | **SOURCE IT.** Recognition/Enquiry coords *are* canon (`ux=(f−.5)·1.34, uy=−.10` / `·0.86, uy=.40`). Only the two Laboratories are approximate — read the real coords from `world-one.js`, do not ship mine. |
| *"RECONSTRUCTED from the audit's description, not verbatim"* | `The Sound.html:388` | the stillness tone is optional | **REQUIRED — E4.2.** The one place sound answers the *absence* of a hand. Read the real envelope from `spine-sound.js`; keep the mechanism (4.6s swell, fifth→octave, kill on touch). |

**The general form:** a scope note answers *"which file do I read?"* — never *"should this exist?"* For everything the audit names as absent, the answer to the second question is **yes, build it**.

---

## §3 · PRECEDENCE — one ladder

| | Source | Wins on |
|---|---|---|
| 1 | `canon/` | **Literal text and numbers.** 66 stars, 67 Light lines, 87 Rite strings. Non-paraphrasable. If a comp's wording differs from canon, canon wins and the comp is my error. |
| 2 | **The seven comps** (this package) | **Mechanism, feel, geometry, interaction** — for the seven areas in §5. They supersede `The Instrument v3.html` only where they explicitly re-specify it, and every such case is named in §6 or the rulings file. |
| 3 | `The Instrument v3.html` | Feel, geometry, interaction everywhere else. 6,081 lines — still the largest single authority in the project. |
| 4 | `comps/*.js` | Single-register detail: `point-yantra.js`, `point-levels.js`, `world-one.js`…`world-seven.js`, `rite-scenes.js`, `return-strata.js`, `spine-*.js`, `uni-*.js`, `walk-continuity.js`. |
| 5 | `AUDIT.md` | **Which delta exists, and its severity.** Authoritative as a map of the gap. *Not* authoritative on what the design is — it quotes the design; read the quoted line. |
| 6 | This package's `.md` files | Sequencing, provenance, conflict resolution, verification. Nothing else. |
| ✗ | `archive/` · Amendment-01 · Phase-9 handoff | **Nothing.** Retired prose. The original divergence came from building against these. |

---

## §4 · READING ORDER, AND THE GAMEPLAN

1. **This file, §1–§3.** Directive, decoder, precedence.
2. **`AUDIT.md` §H** — H0 through H7. The shape of the whole gap in ten minutes.
3. **The seven comps — *run* them in a browser, not read them.** Every one has an *as built* toggle or an A/B; the delta is meant to be felt. This is the step most likely to be skipped and the one carrying the most information.
4. **`AUDIT.md` §A** — the data/content model. Gates everything downstream; mostly Airtable work.
5. **The other four handoff files.**
6. **The design files each comp cites**, as you reach that subsystem.

### Then write a gameplan naming, per pass

- The findings it closes, by audit id (`B4.1`, `D5.1`, …).
- The comp or design file authoritative for it.
- The `HANDOFF-VERIFICATION.md` checks that will prove it — **written before the code**.
- Anything it touches on the protect list (§7), and why that is safe.

### The sequence

Folds the build-list into the audit's own §H6 order. Otherwise the audit's order is right.

| Pass | Work | Authority |
|---|---|---|
| **0** | **No code.** Airtable + open rulings. Start immediately, in parallel. | `HANDOFF-AIRTABLE.md` · `HANDOFF-RULINGS.md` |
| **1** | **The seam.** Universe/axis `B0.1–B0.4` · continuity `B4.1→B2.1→B2.2` · the door `B6.1` · the fall `B5.1–B5.4`. Largest unlock per diff in the project. | `The Seam.html` |
| **2** | **The three sweeps.** Tracking helper · hex alphas · delete the instructional strings. Cheap; lifts every surface. | `The Chrome.html` |
| **3** | **The four constants.** `C2.1`. One line; changes the feel of every register. | `The Chrome.html` |
| **4** | **The rooms.** All eleven + register-2 depth. Rebuilds the Mirror as the framework's first instance. | `The Rooms v4.html` · `room-figures.js` |
| **5** | **The Point.** Reading gestures → **the yantra** → staged descent → gate's deals → Aperture. | `The Reading.html` · `The Aperture.html` · `world-*.js` |
| **6** | **The ceremonies.** Return → Light. | `The Return.html` |
| **7** | **The sound.** Last, once, and only once. | `The Sound.html` |

---

## §5 · THE SEVEN COMPS

Each is a working HTML instrument carrying its constants with design line-refs in its own notes panel. **Run them.**

| Comp | Closes | Authoritative for |
|---|---|---|
| `The Seam.html` | `B0.1–B0.4` `B2.1` `B2.2` `B4.1` `B5.1–4` `B6.1` | **One continuous descent.** `R = pr · z` — the star at the sky *is* the planet you land on; overlapping `bands()`, never a switch. **The door:** a world's name rides the sphere, legible only in the light; drag sideways to turn the world — the design's own law (*vertical walks the axis, horizontal is the register's own gesture*) at the scale where the register is one body. **Consent:** the fall's mouth closes only while the hand keeps asking, never fires itself, and carries the story. |
| `The Chrome.html` | `C2.1` `C5.2` `F0.1` `F0.2` `H0` | **Hand-feel and chrome.** The four `immense`-preset constants (`DRAG .00018 · DAMP .956 · span .42 · glideDur 5.4`); `#where` as serif 23 at `top:100px` with roman + `n of 7` + canon sub-line; the tracking helper; the hex-alpha correction; deletion of all six invented instruction strings. |
| `The Rooms v4.html` | §A1–A3 · the brief's expansion | **The archetype rooms as a general content model.** Four registers; the voice's own mathematics as the room's body; the horizontal is that voice's own gesture. **Register 2 has its own depth** — map → story → comment, indexed *by the figure*. Answers §A: a surface belongs to a voice, so its content model is that voice's rule and a foreign row cannot enter. **v1–v3 superseded; read v4 only.** Support file: `room-figures.js`. |
| `The Reading.html` | `D5.1` `D5.5` `D5.8` | **The reading is carried by the world's gesture.** Same four sections everywhere (`SAY · WALK · HAND · OPEN`); how they arrive *is* the world. **There is no generic star reading** — not anywhere, not as a fallback. |
| `The Return.html` | `E3.1` `E3.2` `E3.4` `A4.3` | **The Return carries any story** (the design hardcoded one at `The Return v2.html:949`), **the rings model**, and **the write-back**. Age always from *days*, never from rank — including per-ring. Nothing is earned until it has come into true. The write-back is what generates register-2's depth. |
| `The Aperture.html` | `D6.1–D6.7` | **Whole without a personal key.** The register draw *is* the unpredictability; the fourth line is a claim about the library, not the tradition. Eye restored, Arch-register prompt restored, four-slot JSON restored, both non-repetition guards. |
| `The Sound.html` | `D7.2` `E4.1` `E4.2` `E4.3` `G1.1` `G3.1` | **The whole sound layer as one instrument.** Both rulings settled and A/B-able in place. Eight places, each with its bed; crossfade never cut. `BEATS` as the live L/R offset. The stillness gate audible at last. |

### The five reading gestures, in the design's own words

`world-five.js:16-22` states them, and they match `The Reading.html` exactly:

```
I    admits when he stops.
II   gives while he goes.
III  gives where he holds it open.
IV   gives when he presses back.
V    gives each time a face comes round — and half of what it
     gives arrives from the other side of the glass.
```

VI is *send and wait* (`world-six.js:14`). VII is *keeping pace*. **Read the seven `world-*.js` files as the deeper source for each world** — they are more specific than the sections in `The Instrument v3.html`.

---

## §6 · CONFLICT REGISTER — all resolved

Anything not on this list that looks like a conflict: **stop and ask** (Rule 3).

| Conflict | The two sides | Resolution |
|---|---|---|
| **The ceremony writes nothing back** | `The Return v2.html:359-360` **and** `walk-continuity.js:22` both state: *"It writes nothing back — a ceremony is not a place that keeps score."* Against `REVIEW-AND-WIRING.md:100-102` recommending a descent write-back, and Ashrey's instruction this session. | **Amended — and the rule survives read precisely.** What is written back is *a return, not a score*. **The design already permits this:** `walk-continuity.js:44-46` says the carry is *"never rendered as a count — a ceremony may colour itself by it, nothing more."* Return-depth appears only as strata, patina and cluster thickness. *Nothing counts; everything deepens.* **Update the rule's text in both files** so it is not rediscovered as a contradiction. |
| **The Rite Hz table** | `The Rite v3.html:1192-1213` vs inlined `field-sound.js:72`. Eight of ten differ. | Split by axis — **pitch** from the Rite table, **timbre** from `CHAR`. See rulings. |
| **The bed** | Phase-9's Airtable binaural pair vs the Instrument-era root+fifth with convolution. | **Both, by surface.** Neither document was wrong; they describe different rooms. |
| **Ashram vs Ash** | `Player Detail - The Turning.html` vs `The Instrument v3.html:415` — two names, hexes, glyphs, roles. | **Unresolved by design.** Escalated. Do not pick. |
| **Sequencing: foundation or rooms first** | The brief says data model first; I argued the Mirror's defect *is* a missing room framework. | **Ashrey ruled: the brief's order.** Foundation first. The framework was designed anyway, so both are available. |
| **"Register 2 has no returns"** | The framework shows *"stories it keeps returning to"*, but no voice has commented twice on one story. | **Not missing data — the loop has never run.** Returns and answers are generated by the Rite and the Return write-back. The record is exactly one pass old. |
| **D6.6 "the guard is on the wrong axis"** | Audit says the build's register-pool guard is wrong. | **Both are needed; the audit is too harsh here.** The register pool must be drawn without repeats — the only guard that works with no key. `seen` (last six lines) applies additionally when live. |
| **`spine-axis.js:1084`** | The audit cites this for *"never a number, never a progress bar."* `spine-axis.js` is 144 lines. | **Citation error in the audit.** The line is `The Instrument v3.html:1084` and `spine-axis.js:117`. Same text, both files. |
| **The Rooms v1/v2/v3/v4** | Four files, escalating. | **v4 only.** v1–v3 kept for history. Note `The Return v2.html` (design source) and `The Return.html` (this package's comp) are different files with different roles — both live. |
| **Instrument-era vs `comps/`** | `CLAUDE.md` puts the Instrument-era rebuild above `comps/`; three code subsystems have no comp. | Per the audit's own precedence note those three are **not bugs**. Absence of a comp is not a finding. |

---

## §7 · PROTECT LIST — do not "improve" these

The audit's §H5. Fifteen files are already faithful; a rebuild's biggest risk is collateral. Read the audit's table before touching any.

- `Point/PointContent.swift` — **66/66 stars byte-verbatim**, 528 strings, every diacritic intact.
- `Universe/UniRegions.swift` — 13 rooms, 13 `place()` armatures, 26 renderers, 13 structures, verbatim. **Two adds only:** restore `hz:`, add `WX[13]` + `DENS[]`.
- `Instrument/InstrumentField.metal` — all 15 motifs and hues verbatim. **Three adds only** (see decoder).
- `Components/GatheringScene.swift` — all ten Rite geometries at the design's real element counts. **The eleven room figures derive from these; do not diverge them.**
- `Rite/RiteContent.swift` · `RiteBudget.swift` — 87/87 strings, budget arithmetic exact.
- `Light/LightCanon.swift` (prose) — 67/67 lines byte-for-byte.
- `Theme/RoomStyle.swift` — 13 hero typographies + 13 portal glyph scales. Most faithful table in the codebase.
- `Screens/TheTurningView.swift` — the trace path is bit-exact.
- `Screens/AshComposeView.swift` · `StoryDetailView.swift` (body) — effectively bit-for-bit.
- `Instrument/Breath.swift` — `originSeconds` is **better than the design**. Keep it.
- `Sound/` session contract and render discipline — engineering the design never specified.
- Local-time day-keys — deliberately better than the comps' UTC.

---

## §8 · FOUR RECURRING BUG CLASSES

Each bit more than once while building these comps, including in my own work. Grep for them rather than waiting to hit them.

1. **Shrink-wrap.** A container sized by the child it is meant to be independent of. Three occurrences in one session: a fixed reference rail whose active tick grows takes width from its siblings and drags them. → *Any element serving as a fixed reference gets an explicit box.*
2. **Correct at rest.** A value that reads right at its default and goes wrong across its range — unbounded horizontals, a gesture carrying four registers, a pupil leaving its eye. Found only by sweeping end to end. → *Sweep every interactive constant to both limits.*
3. **Rank for age.** Using array position where the real datum exists. This is audit finding `E3.4` — **and I reintroduced it one level down**, drawing a one-second-old ring as the oldest thing in the archive. → *If the data carries days or a date, never derive age from an index.*
4. **Instructing.** Replacing discovery with a label. Six invented strings across five surfaces; none exists in any design file, and Brief §16 Law 4 plus `The Instrument v3.html:1084` forbid the category. → *If you are about to add a string telling the user what to do, the affordance is wrong — fix the affordance.*

---

## §9 · VERIFICATION OF THIS PACKAGE

Checked before publishing. Findings recorded rather than silently corrected.

**Confirmed present and cited correctly:** `point-yantra.js` 188 lines with `BAND[10]`, three squares `1.46/1.38/1.30`, petal rings `16 @ 0.88→1.00` and `8 @ 0.70→0.84`, nine triangles (5 `DOWN` + 4 `UP`), annulus `bandR×0.62→1.34`, `flare()` · `point-levels.js:198` `descend()` · `The Return v2.html:949` hardcoded `STORY` · `The Return v2.html:359-360` the write-nothing-back rule · `The Rite v3.html:1192` `VOICES` with `bindu hz:136` · `The Mirror.html:62-73` `REFLECTIONS` with authored `\n` · `The Instrument v3.html:931-951` 37 `REGISTERS` · `The Instrument v3.html:404-418` `VOICES` · `field-sound.js:13-25` `CHAR` · `Player Detail - The Turning.html:47-160` `ARCHES`.

**Three errors found and fixed:**

1. **`The Reading.html` claimed Worlds V and VI have no bespoke module.** False — `world-five.js` (463 lines) and `world-six.js` (468 lines) are fully authored, and `world-one.js` … `world-seven.js` all exist. The comp's note is corrected in-file and the build-list now says *build from source* rather than *needs design*. This was the most consequential error in the package: it would have sent V and VI to a generic ScrollView, which is `D5.1` reintroduced.
2. **`spine-axis.js:1084` does not exist** — that file is 144 lines. The audit's citation conflates two files; the real locations are `The Instrument v3.html:1084` and `spine-axis.js:117`. Recorded in §6.
3. **The write-nothing-back rule lives in two files, not one** — `The Return v2.html:359-360` *and* `walk-continuity.js:22`. Both need the text update, or the second one reads as an unresolved conflict later. `walk-continuity.js:44-46` also turned out to *support* the resolution (*"a ceremony may colour itself by it"*), which makes the amendment smaller and better grounded than first stated.
