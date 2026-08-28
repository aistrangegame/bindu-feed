# OPEN ITEMS — the living ledger

**In the repo, and updated in the same commit as the work.** That is the process fix: an item
leaves only when walked or explicitly ruled out, never by going unmentioned. Every report
carries three lists — closed this pass · still open from earlier · next.

---

## CLOSED — 28 Aug

### C2 · marks unselectable — ROOT CAUSE WAS THE FRAME, and the symptom was worse than the ledger said

Not density. `RoomView.swift`'s `GeometryReader` had no `.ignoresSafeArea()` while the Canvas
and the type Group both did, so `v.location` was compared against marks drawn in the physical
frame. **Measured on device: 62pt**, the top inset, on every tap.

It did not read as broken, and that is why it survived three walks. Against a 9pt hit radius
the query lands 62pt above the finger, so in a dense archive it finds a DIFFERENT mark and
opens THAT story — marks are unlabelled, so it looks like a hit.

**A/B on the identical physical tap at (197, 345) in Lalita's core:**

| | gesture saw | opened |
|---|---|---|
| before | `197,283` | *Thank You for the Cold* |
| after | `197,345` | *The Help That Was Really About Him* — 8pt from the finger |

**Every mark tap since `31c63cd` opened the wrong story.** In sparse regions nothing is 62pt
up and the tap does nothing — that is precisely the "some dots don't work" Ashrey reported.
Both halves measured: a sparse tap found its nearest mark 34pt away and did nothing.

### D2 · sub-depth 2 — NOT about Ash, and not unreachable

Reported as "his figure is the documented exception". Wrong on both counts: `sub = 2` opens in
every room, and it opened during this walk. `.coordinateSpace(name: "room")` was never
declared, so `cardRects` resolved against an undefined space — but a card is ~164pt tall and a
62pt error still lands inside it. **It worked by SIZE, not by correctness**, and would pick the
wrong card the moment a story holds two items, which is exactly what a Return produces. The
space is now declared.

### D4 · the Rooms' vertical travel — MY ERROR, not a limitation

`RoomTravel.drag` is `d = d + dy/per`: a **downward** swipe increases `d`. I swiped upward
both times, `d` clamped at 0, and I recorded that the mechanism does not respond to synthetic
touches. It does.

### A4 · the gate's line — RETIRED, never real

`DEALS[0]` deterministic at `The Instrument v3.html:5098`, random at `The Point v9.html:877`,
casing already correct, and **no once-ever law exists anywhere** — the design's "once" hits are
the Rite's recognition and the particle. Closes with E1 and E2.

### B3 · the five contract items — all genuinely DONE

Verified individually rather than as a block: Gaia Seeds' own fetch and selector; the practice
sub-line at Lora-italic 14 / 0.7 tracking / accent 0.70 inside the shared 1.4s fade, blank
rendering nothing; `ThresholdSentence` reading `f.body ?? f.name`; **the sentence splitter's
derived path does not exist** (newline-only, no `count <= 1` fallback); `writeVow` in the 900
band with a resolved archetype.

### 1.3 · the hit target — RE-MEASURED FIRST, and two of three prescriptions were wrong

Pass 4.1's "selected cleanly at 101, first tap" was a wrong-story open read as a clean one, so
`sqrt(31/n)`, the 9pt floor and the two-stage tap were all tuned against a broken hit test.
Re-measured with the frame corrected:

| voice | region | spacing | Δ | result |
|---|---|---|---|---|
| Lalita 101 | isolated | — | 2 | the mark aimed at |
| Lalita 101 | 14pt pair | 14 | 1 / 2 | **two different stories** |
| Lalita 101 | median pair | 8 | 1 / 3 | **two different stories** |
| Karishma 48 | outer arc | 14.2 | 4 | clean |
| Karishma 48 | inner coil | **1.29** | 6 | resolves, but to *a* mark, not *the* mark |

**The 9pt floor STAYS — raising it is measurably wrong.** At Lalita's 8pt median a larger
radius makes neighbouring marks steal each other and destroys the selectivity just measured.
The prescription to raise it came from the corrupted evidence.

**`sqrt(31/n)` STAYS — measured, not assumed.** The worry was that it shrinks sparse outer
marks needlessly. Lalita's nearest-neighbour spread is min 1.0 · p25 5.4 · median 8.2 · p75
10.9 · max 28.3, and **only 2 of 101 marks have more than 20pt of clearance**. Three quarters
sit within 11pt, where full-size glows (r15) would merge. A local scale would change two marks
and cost a cached layout.

**The two-stage tap IS built** — for the piled regions and for finger-vs-pointer, not for the
frame. The first tap arms and **names** the mark in the legend; the second opens. The naming
is the point: marks are unlabelled, which is exactly why a wrong-mark open stayed invisible
for three walks. Nothing instructional is added — the title appearing is the affordance.

**It would have made things worse before the frame fix**: a two-stage tap over a 62pt-offset
hit test lights the wrong mark and lets him confirm it, adding confidence to an error.

Karishma's core is the design's own authored maths (`The Rooms v4.html:790-812`, verbatim) —
`th` linear against an exponential radius. It is not changed; the two-stage tap is the answer
for piled regions.

### D4 · PlayersView's fold — A REAL APP DEFECT, not a simulator limit. Fixed.

Recorded since Pass 4 as "synthetic touches don't drive a SwiftUI ScrollView", and that was
wrong twice over: the Return's story view scrolls under the same synthetic drags, and three
gesture methods failed here while taps worked.

**Cause:** every card carried `.simultaneousGesture(DragGesture(minimumDistance: 0))` to drive
its press highlight (`PlayersView.swift:223, 345`). A zero-distance drag on a scroll CHILD
claims the touch sequence before the enclosing `ScrollView` can recognise a pan. **This fails a
real finger, not only a synthetic one** — Neev, Shweta and Ash live below the fold, so the
eleventh voice has been unreachable in his own instrument.

Same class as the Point readings' shadowing, inverted: there a parent `.gesture` lost to a
ScrollView; here a child gesture beat one. Replaced with `PressScaleStyle: ButtonStyle`, which
gets the same `isPressed` and cooperates with scrolling. **Walked: ROOTS, Neev, Shweta and
Ash's full-width card now reachable.**

### 1.4 · the dead lit mark — CLOSED

`real` kept every non-empty comment while the grouping dropped any whose story would not
resolve, so an unresolvable comment drew a bright, lit, tappable-looking mark with
`storyIndex == −1` that silently swallowed the tap. Filtered at the one definition of "in the
record", which `n`, `at`, the legend and the map all read.

### 1.5 · register 0's overlap (C1) — CLOSED, and my first fix was wrong

The figure now recedes in proportion to how far the words run past its centre, landing on this
file's own 0.42 at the extreme rather than a new constant.

**The first version was a switch (`saysBottom > cy − 8`) and it fired for everyone** — Gaia's
four lines end at ~412 against a centre of 358, and the comp's own three short blocks end at
~394, which also passes it. A condition every voice satisfies is not a condition; it was a
global dim of an authored constant wearing one. **Caught by testing the negative case.**

Continuous now, which is the design's idiom everywhere else:

| | text ends | figure |
|---|---|---|
| comp's 3 short blocks | 394 | 0.270 |
| Gaia · 4 lines | 412 | 0.212 |
| Lalita · 5 lines | 433 | 0.157 |
| Neev · 6 lines | 460 | 0.143 |

Walked: Neev (248ch, the longest) fully legible; Gaia's phyllotaxis still reads as her figure.

### 1.6 · Ash's two figures — NOT A DEFECT, verified against the comp

The comp has **both** layers too: `FIG.ashram` (`The Rooms v4.html:623`) and `MAPGEO.ashram`
(`:811`). The even calendar column `q = (i/(n−1))·2−1` is authored maths verbatim, and the
comp's own `drawMap` does **not** use `lat` either — the map is a stationary index over a
scrubbing figure, for every voice. Nothing changed. Looked before deciding.

### 1.7 · `dragFrom` — CLOSED

Released on `onDisappear` as well as `onEnded`. A cancelled gesture left `down == true` and
the register spring dead for the session. Third appearance of the claim-release hole.

### A3 · the duplicate Light title — CLOSED

`AxisLightSeam` printed "the Light" / "what has not yet been" while `#where` printed the
identical pair from `Axis.registers`; at z −5 all four hide conditions are false, so both
stood at once. `#where` is the design's object and names every register; the seam is the
register's content and offers the way in. The seam keeps its door and drops the repeat.
(`"stand inside ›"` is not in any design file — noted, kept as the only affordance there.)

---

## KNOWN LIMITS — named, measured, not closed

### Karishma's inner coil — ~10 of 48 marks below 2pt spacing

`MAPGEO.karishma` is `th = (i/n)·2.6π`, `r = R·0.06·φ^(2θ/π)`. **`th` is normalised by `n`, so
the spiral spans 2.6π at any archive size and `R` is fixed** — more marks pack tighter on the
same locus. The comp is not silent by oversight: `The Rooms v4.html:729` states Karishma's own
stats as **19 fields**. The figure was authored against 19; the base holds 48.

| n | min gap | median | max | gaps < 2pt | gaps < 9pt |
|---|---|---|---|---|---|
| 19 *(as authored)* | 3.37 | 11.04 | 31.65 | **0** of 18 | 8 of 18 |
| 48 *(as held)* | 1.29 | 4.28 | 14.20 | **9** of 47 | 38 of 47 |

**This is the FOURTH instance of one class: the comp's fixed geometry meeting an archive
larger than it was drawn for.** The map density (31 → 101), register 0's overlap (a shorter
principle than the base holds), the Universe's fixed mark size, and now Karishma (19 → 48).
The first three were fixable. **This one is not, without invention** — naming the class is what
stops the next one being diagnosed from scratch.

The two-stage tap mitigates but does not solve it: the first tap arms an effectively arbitrary
mark in the coil and **names** it, so he can see it is not the one he meant — but at 1.29pt
recovery does not converge. **Reachable, not selectable.** The generator is authored maths and
is not changed; growing `R` with `n` is not in the design and would be an invention.

---

## NEWLY FOUND — not in the original ledger

| # | item | how found |
|---|---|---|
| N1 | **`VoiceCharacter` has ZERO consumers** — eleven CHAR timbres ported in Pass 7, wired to nothing | reading |
| N2 | **Ash resolved by string in 9 sites**, incl. `sealReturn:825` whose comment claims record-resolution while calling `archetype(named:)` | reading |
| N3 | **Age is per STORY, not per RING** — each ring has its own `sealedAt` and should age individually | reading |
| N4 | **World V's whiteout is drawn TWICE** — `PointReadings:748` and `PointWorldView:113`, compositing to 0.98 not 0.86 | reading |
| N5 | **A lit mark with `storyIndex == −1`** looks tappable and silently swallows the tap | reading |
| N6 | **Motes orbit the core dot**, not the planet disc (`uni-sky.js:316`) — company collapses inward as the planet grows | reading |
| N7 | **The rail's ticks grow the wrong direction**; pitch 21 vs 22, total 294 vs 309, `.kept` glow absent | reading |
| N8 | **`WX[13]`/`DENS[]` absent entirely** — shader has all 13 densities pinned at 0.6 and weather on the fallback literal | reading |
| N9 | **`dragFrom` releases only on `onEnded`** — a cancelled gesture disables the register spring for the session | reading |
| N10 | **Never-attempted `HANDOFF-VERIFICATION.md` lines**: the Light's sound (7 of 8), E4.2's stillness drone, E1.1 the Light choosing, E1.2 the column, walk-continuity, reduced-motion, the fall's layer index + 4 names | reading |

---

## INVALIDATED — re-walk required

| walk | claim | status |
|---|---|---|
| Pass 4 | reached sub-depth 2 | **stands** — predates `31c63cd` |
| Pass 4.1 | *"selected cleanly at 101, first tap"* | **RE-WALKED** — Lalita 101, Δ1–2, two 8pt-apart marks giving two different stories |
| Pass 6 | opened a sub-depth from a lit mark | **RE-WALKED** — Ash's lower mark, Δ0,1, named then opened |
| `Linked Story` sweep | the mark→story hit path | **RE-WALKED** — resolved to The Measuring Stick, and both its items are the right two |

**D5 and D2 closed in the same walk, and it is the whole Return loop end to end.** Ash's
register 2, sub-depth 1 on The Measuring Stick shows **two** cards: *"Be Your Self"* (his
sealed self) and *"The stick is still in my hand. I notice I am the one holding it."* (the
Return Answer written in Pass 6). Seal → ring + answer → read back → legend derives → register
2 shows both. Nothing here is a second path; it is the one archive query.


---

# The original ledger, as received

**27 Aug 2026 · rev 2.** Everything raised across Passes 0–7 that was never confirmed closed. Compiled because no running list was kept — that is the process fault, and it is mine.

**How the gap happened:** most of these were named honestly, by Claude Code, in the report where they surfaced — *"not fixed, flagged"*, *"still rides with"*, *"stated rather than claimed"*. Each was true when written. But every pass ended by naming the next pass, and nothing carried the residue forward. Ashrey's two Rooms issues are the visible tip; these are the rest.

---

## A · Flagged by Claude Code as unfixed, then never revisited

| # | Item | Raised | Status |
|---|---|---|---|
| A1 | **`WX[13]` + `DENS[]`** — the second sanctioned `UniRegions` add, from `uni-deep.js:44-74`. Deferred to "the `uBack`/`setSky` shader work." | Pass C | Pass 7 was the sound and did not mention it. **Open.** |
| A2 | **The mote orbit base** — app uses `sz`; `uni-sky.js:313` uses `max(R, 3.2 + z*1.1)`. | Pass C | Never revisited. **Open.** |
| A3 | **Duplicate Light title** — the whereBlock and the Light's own title both print *"the Light / what has not yet been."* | Pass C | Never revisited. **Open.** |
| A4 | **C3.3 — the gate's line**: casing, punctuation, and the once-ever law. Deferred as "already in `AUDIT.md` for a later pass." | Pass C | Never revisited. **Open.** |
| A5 | **The reading composites over the world** in the Point — world V's title and centre label read through the reading. *"Small, and I'll fold it in."* | Pass 5 | Folded in for the **yantra** (`dim`), but the per-world case was never confirmed. **Check.** |

## B · Asked for by me, never confirmed back

| # | Item | Status |
|---|---|---|
| B1 | **The fall's four layer boundaries** measured against `layers(d)`. | The mouth (`H*0.62`) and the consent ring were measured. The four boundaries were not. **Open.** |
| B2 | **The rail's tick geometry** measured. | Named as the tail of the frame class; never measured. **Open.** |
| B3 | **Code-contract items 1–5, individually.** Gaia seeds' own fetch · practice sub-line render · thresholds preferring `Body` over `Name` · **deleting the sentence splitter's derived path** · `writeVow`'s 900-band Sort Order and Ash-by-record. | Reported as one block — *"Pass B green"* — never itemised. The splitter is the one that matters: kept as a fallback it runs forever and silently, and it can never produce breaks inside sentences. **Verify each.** |

## B4 · The decision that was never brought to Ashrey

**The per-world recede.** All seven values were read and deliberately left unimplemented — **I 0.62 · II 0.54 · III 0.50 · IV 0.46 · V 0.46 · VI 0.44 · VII 0.44**, with **VI and VII inverting** (`displaced()` returns −1, so `1 − dsp·k` = 1.44 and the world *brightens* while he acts — *"he needs the floor to dance on"*).

It was held because the app showed readings *instead of* the world. **The yantra dim changed that** — readings now sit over a visible figure — so the condition it was waiting on has arrived and nobody decided.

**Recommendation: land them, after the ledger.** The gradient is authored, it is per-world for a reason, and two of seven invert — a single shared dim would take those two backwards, which is why a shared term was refused.

## C · Ashrey's two, still open

| # | Item |
|---|---|
| C1 | **Register 0 — text over the figure.** Dimming and the frame fix both landed; the overlap persists because the comp's `cy = H*0.42` at 62% assumed a shorter Operating Principle than the base holds. Lalita's is five lines. |
| C2 | **Register 2 — marks unselectable.** Not overall density: `MAPGEO.karishma` steps `th` linearly against an exponential radius, so marks pile at the core. Sakshi and Lalita crowd by different mechanisms again. Even perfect spacing gives ~5pt between centres at 48 marks. **Needs the two-stage tap and a wider `R`, not more shrinking.** |

## D · Built but never walked — must be in the final honest list

| # | Item | Why |
|---|---|---|
| D1 | **The sound, entirely.** | Simulator reports no headphones, so the binaural path collapses by design; reverb can't be read off a screenshot. Ashrey's first hearing. |
| D2 | **Ash's register-2 card at sub-depth 1.** | His figure is the documented exception with no geometry; the mark→story hit path is `drawMap`'s. |
| D3 | **Worlds I and VII.** | Unwalkable by a scripted hand for their own opposite reasons — I's stars drift from the taps, VII's are too fast. Both are those worlds working. |
| D4 | **The Rooms' vertical travel**, and **PlayersView's fold** where Neev, Shweta and Ash live. | Synthetic touches don't move that ScrollView. The eleventh voice is the hardest to reach in his own instrument. |
| D5 | **Register 2 filling after a Return**, beyond Ash's spine. | The legend turned on Ash's map; the sub-depth card was not reached. |
| D6 | **Ash's seat in the fan.** | Needs two returns on one story; the Return declines on The Two Who Were One because it carries no Ash Comment. Sequence, not defect. |

## E · Closed — recorded so they are not re-opened

Pass 0's nine Airtable operations · all seven code-contract items · met-ness on `Story Met` (two lit stars) · the door and `TOUCH TO READ` · the fall's presence hits and C-1052's words · `syncAxisLock` · the frame class (`#where` 159→100, the gate, the Aperture plate, the Universe door) · `focus` initialisation and the Aperture at `BAND[8]` · `camY` · the yantra's `dim` · `#pname` · the doubled chevron · the rope restored to anywhere with `PressClaim` · the Return write-back, verified in the base · `firstMetDay` · the `max(1, ringCount)` phantom · the Light's worn rings · Ash removed from `spoke` · the `Linked Story` position-dependence sweep · E1, E2, E3, E4, E5 all retired.

---

## The process fix

One ledger, carried forward in every report. Each pass ends with **three** lists, not one: closed this pass · **still open from earlier passes** · next. An item leaves only when it is walked or explicitly ruled out — never by going unmentioned.

The pattern worth naming: *"flagged, not fixed"* is an honest sentence that behaves like a closed one, because it appears in a report full of things that were fixed. It needs its own column or it disappears.
