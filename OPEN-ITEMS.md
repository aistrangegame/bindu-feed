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

### 2.1 · `VoiceCharacter` — WIRED. Pass 7 had shipped without its content.

Eleven `CHAR` timbres, zero consumers: the bed split landed and the voices never did, so every
presence sounded identical — a sine-plus-octave at whatever Hz the caller passed.

`CeremonySynth.presence(VoiceCharacter)` now renders the body term for term: partials summed
and normalised on the voice's own wave, `vib` bending pitch, `gliss` sliding it, `flicker`
breathing the amplitude, `air` adding Shweta's band of breath, `shimmer` beating Karishma's
third partial, and eleven pan positions. Phase buffers allocated once outside the render
block — §15's discipline holds.

Pitch from VOICES, body from CHAR, and the two disagree on four voices. Routed at the Rite's
gathering (each presence in its own body) and at the Rooms' descent (the voice whose archive
he is opening). Walked: Shweta — the quietest at `gain 0.012`, `atk 4.0` — opens without a
graph fault.

### 2.2 · Ash by string, nine sites — CLOSED

All routed through `ashArchetype` / `rec9BUbHMuylYiVwH`. Three of note:

- **`sealReturn`'s comment said `§7: resolved, never hardcoded` while calling
  `archetype(named:)` — a name lookup. Deleted.** A comment describing code it does not match
  is the empty-body fault in prose: it reads as a guarantee and is an assertion.
- **`AirtableService:372`** decided which `Type` to query from `archetypeName == "Ash"`, so the
  voice's identity chose the query shape — rename the row and it silently reads the wrong kind.
  `isAsh` is now decided by the caller from the record.
- **`FieldComment.isAsh`** tested `archetype == "Ash"`; now tests the ACT
  (`Ash Comment` or `Return Answer`), per §10's Type-encodes-the-act rule.

Verified: no identity is resolved by string anywhere in the app.

### 2.4 · the recede + the overlay (B4 + A5 + V's doubled whiteout) — CLOSED

Four things landed together, because they are one structural change.

**The world is drawn behind the reading, not replaced by it.** `PointWorldView` was a
mutually-exclusive `if / else if` chain, so at level 2 the world was unmounted and there was
nothing to recede — which is why the seven coefficients sat read-but-unimplemented since
Pass 5. `A = p·(1 − dsp·k)` needs a `p` to multiply.

**The negative test, computed before walking** — and it discriminates:

| world | no reading | revealed 1 | revealed 2 | revealed 4 |
|---|---|---|---|---|
| I | 1.00 | 0.84 | 0.69 | **0.38** |
| II | 1.00 | 0.86 | 0.73 | 0.46 |
| III | 1.00 | 0.88 | 0.75 | 0.50 |
| IV · V | 1.00 | 0.89 | 0.77 | 0.54 |
| **VI · VII** | 1.00 | **1.44** | **1.44** | **0.76** |

No reading open → **1.00 for every world**, so it is not a rule that always fires. The seven
do not resolve to one visible dim: at full reveal they span 0.38 → 0.76, a factor of two.

**Walked VI and VII first**, as the two carrying least protection. Both show their material
visibly brighter behind the reading while he acts, and the type stays legible.

**A5 · the world keeps its material and loses its captions.** The recede dims what is behind,
but a dimmed WORD is still a word — VI's star names ran through the sentences ("You
volunteered" mid-paragraph). Type competing with type is not ground competing with type, and
no alpha fixes it; the same reason `#where` and `#pname` HIDE while the yantra only dims.
`StarMark.compact` already existed — raised for the whole world as `quiet`.

**V's doubled whiteout collapsed.** `PointReadings` and `PointWorldView` both drew `bk × 0.86`
over the same frames, compositing to **0.98**. The enclosure draws it (it outlives the
reading); the reading keeps only the hit-blocking.

**And I created an empty body while removing debug hooks.** The hook-stripper left
`parkDebugStarIfRequested() { }` — a correct name with a live call site and nothing inside,
the fourth shape, made by the tool meant to clean up. The earlier empty-body sweep found only
`duckBreath` because it ran before this existed: **a sweep is a snapshot, not a guarantee.**

### 2.3 · per-ring age — CLOSED, and the design's own `rel` was the rank fault

`return-strata.js:100` derives `rel` from the INDEX — `(n−1−i)/(n−2)` — then hangs the colour,
the bloom and the craquelure on it. That is a proxy for age which holds only if returns are
evenly spaced in time. **It is `age = returnCount/5` one layer in**, and §10 is explicit: age
comes from days, never from rank.

Split: **position keeps what position means** (radius, rotation rate, what sits on top);
**days decide what age means** (bone → amber → deep gold, bloom, craquelure).

**Craquelure was never ported at all** — `return-strata.js:50-60` exists and the app's strata
had no cracks. Added, gated on age.

Verified by computing the curve, not by looking — one real ring at one day old cannot show it:

| days | a | colour | bloom | craquelure |
|---|---|---|---|---|
| 0 | 0.000 | rgb(228,220,205) bone | no | no |
| 30 | 0.138 | rgb(223,205,173) | no | no |
| 365 | 0.546 | rgb(215,180,119) | yes | yes |
| 730 | 0.800 | rgb(173,128,63) | yes | yes |
| 1095 | 1.000 | rgb(164,112,38) deep gold | yes | yes |

Bloom crosses at ~208 days, craquelure at ~305. **Nothing wears age it has not served.**

The discriminating case — two returns a day apart and a third two years later — now reads
**0.031 / 0.021 / 0.800**. Under the position-derived `rel` it read 0.0 / 0.5 / 1.0: evenly
aged, which is the whole fault.

### 2.5 · `WX[13]` + `DENS[]` — CLOSED (real work, not a port)

The second of the two adds §7 sanctions on `UniRegions`, absent since the port. The shader was
fed `(0.4, 0.02, 0.2)` — the design's **fallback** literal from `uni-deep.js:91`'s `|| [...]` —
for every register in every room. The Forge churns at 0.92 turbulence; the Watcher is nearly
still at 0.12; the Forgetting is 0.86 grain. `DENS` is derived from met-ness, not authored;
the shader had all thirteen pinned at a flat 0.6.

`mSky` now reads a 39-float `uRm`. **First attempt failed at link time** — I passed the array
length as a separate `.float`, but `.floatArray` supplies both pointer and length: *"Function
stitching failed: instrumentField"*, which is a link error and would have shown as a black
field, not a wrong one.

**Protect list re-diffed:** the metal change is a rename, two data-source lines in `mSky`, and
signature threading. **No motif body differs** — all fifteen verbatim, `mSky`'s own formula
included. Walked: the sky renders all thirteen rooms.

### 2.6 · the mote orbit — CLOSED, and my first description of it was wrong

The base was `sz` (the 2–3pt core dot) where `uni-sky.js:316` passes `max(R, 3.2 + z·1.1)` —
the planet's projected radius. The `tip` tilt, the `oy × 0.42` ellipse and the behind/in-front
term were all missing too: four things on one line.

**But "the company sank into the planet" — which I wrote in the commit — is too strong.**
Computed across the real parameter range, the old orbit as a multiple of planet radius:

| pr | orbitMul 4.6 | 5.8 | 7.0 |
|---|---|---|---|
| 7 | 1.39 | 1.76 | 2.12 |
| 9 | **1.08** | 1.37 | 1.65 |
| 11 | **0.89** | 1.12 | 1.35 |

Inside the limb only for the largest planets at the lowest `orbitMul` (0.89, and 0.81 at high
zoom). Elsewhere it merely hugged the disc at ~1.1–1.4 radii against the design's 1.62–2.34.

**The systematic fault is subtler and worse:** the ratio was a function of `pr` AND zoom, where
the design fixes it at `rr` — a constant per mote. The company's distance from its own planet
varied by which star it was and by how close he had come. That is what `rr` means, and the
name `orbitMul` had quietly stopped meaning it.

### E1.1 · the Light chooses — CLOSED

`LightView.swift` read *"One scene per visit, deterministic by local-day hash"*, so a date
chose his future for him in the one register whose whole subject is what has not happened yet.
A ruling from the conflict document that never reached a pass plan — which is exactly how an
item survives seven passes: **nothing disagreed with it, because nothing asked.**

The geometry is canon (`spine-light.js:104-121`): five drifting in the open sky at
`x = W(0.50 + cos(a)·0.29)`, `y = H(0.245 + sin(a·0.62 + i·1.1)·0.055 + i·0.058)`, the Far one
low at `H·0.845` where a floor would be, hit radius 30, `ORDER` verbatim. **The look is not
canon** — no comp draws these; `The Light v2.html` goes straight to `SCENES[which]`. So it is
the register's own idiom and said so rather than implied to be ported.

**The stillness gate is untouched.** The choosing sits AFTER it: the way opens by stillness —
accumulate and keep, force only pauses, *"this is not a test he can fail"* — and what he walks
toward is then his. The worn rings are likewise unchanged: one per exhale, kept, capped at 14,
session-scoped.

**One correction mid-build.** I hung all six titles under their points and three collided —
`place()` spaces *lights* by 0.058·H, ample for a point and nowhere near enough for a two-line
title. The titles were my addition, so the collision was mine. Fixed with the two stages the
Rooms' marks already use: the first touch arms and NAMES, the second enters. It suits this
register especially — he approaches one of six futures and it tells him what it is before he
commits — and it adds a name, never an instruction.

Walked: six lights standing clean, and *"The one who was watching all of them"* naming itself
alone when armed.

### The Light's sound · 7 of 8 events — CLOSED

*"The Gathering FILLS… The Light REMOVES. So the sound does the opposite of everything above:
it draws in, holds, drains, strikes once, and leaves silence."* The register built on
subtraction had only generic engine calls, so it sounded like every other one.

| event | what it does | fired at |
|---|---|---|
| `openTheRoom(8.5)` | the long stone tail, wet → 0.85 | the way opens |
| `breathIn(6)` | breathing STOPS, brightens, swells and **holds — does not release**; a rise slides root → root×1.5 | the way opens |
| `veilLift(3)` | everything drains downward and out; cutoff 3000 → 90 | the aperture opens |
| `bowl(174)` | struck once into the space that leaves | the aperture opens |
| `breathIn(4.2)` | the same gesture, shorter — holding the line, not entering | the Declaration's draw-in |
| `lightBed` | 528 + 792 at 0.012 over 6s — *"so the silence has an edge to it"* | the scene stands |

Two engine additions were needed: a **pitch ramp** on `CeremonyVoice` (a held tone that MOVES —
the fifth opening) and a **`.drain`** synth, filtered noise whose cutoff falls across the
gesture. The bed stays the FIELD's room; the Light's nave is a reverb raised on it, not the
Point's cathedral. Nothing here speaks, so nothing routes through CHAR.

### E4.2 · the stillness drone — CLOSED. The last genuinely new mechanic.

The one place in the app where sound answers the **absence** of a hand. It was `axisThin`: a
0.6s one-shot at `f²·0.026` — **0.00026 at the threshold where it fired**, below hearing on any
device — and it fired ONCE at `thin > 0.1` and never again, so it could not follow the fill it
was made of.

Now continuous, two oscillators, the fifth opening toward the octave as the way thins
(`1.5 → 2.0`), ceiling 0.062 at full fill — under the 0.075 event limit.

**It rides the axis's own accumulator, never a timer.** `dwell` builds at 0.30/s only while
`still && Z < −2.3` and decays at 1.30/s under any action, so the drone can only swell for
someone who has actually stopped — not for someone merely looking at a still screen. A timer
would sound for both, and that difference is the entire mechanic. Cut in ~0.2s on `travel.down`,
which is the touch itself rather than the accumulator's decay.

(The app's accumulator fills in 3.33s where the design's gate is 4.6s — a divergence recorded
when the dwell was ported. The drone follows the accumulator that exists rather than starting a
second clock beside it.)

### Group 3's last five — CLOSED

**E1.2 · the column lifts and masks.** A five-anchor scene grew from the vertical centre and
ran onto dim stone. Two different things: it LIFTS (rises as it fills, so its foot stays in the
light) and it MASKS (what passes the boundary **fades** — a hard edge on stone reads as a crop,
a fade reads as the edge of the light). Driven by how much has surfaced, not a measured height,
so it cannot fight the layout.

**walk-continuity · the remaining half.** The depth he left from is carried, so a ceremony
returns him there and not to a cold Door. **The other half was already better than the design:**
it carries `breath` because its clock restarts per page — *"He left mid-breath; he arrives
mid-breath"* — and `Breath.originSeconds` is launch-anchored, so the 0.1 Hz clock cannot
restart inside a session. There is nothing to carry. `carry`/`carved`/`crossed` are deliberately
NOT stored: E5 rules they may colour a ceremony and never be rendered, nothing reads them today,
and an unused field would be the unwired-slot fault.

**reduced-motion.** Suppresses EVENTS, keeps the BED — the asymmetry is the rule: the bed is
not motion, it is the room being there, and silencing it would make reduced-motion mean "off".
Enforced at the two choke points every one-shot already passes through, rather than eleven call
sites to forget one.

**The fall's four layer names.** `uni-fall.js:25`'s layer index `n` (thresholds 0.20 / 0.50 /
0.88) was never ported, so the caption it feeds never appeared — the four layers were reachable
and unnamed. *the story, close · who sat with it · what you left here · the mouth of the return*,
at `H−172`, mono 8.5, the mouth's fade `L.mouth` and the others breathing.

**The rail.** Pitch **21 → 22** (`1 + 9 + 3 + 9`), span 294 → 309, and the ticks now grow
**toward** the screen edge from a shared left edge rather than away from it — same silhouette at
rest, opposite motion as he travels, and the motion is the half that reads. Dot centre corrected
to `W − 17.5`.

**Labelled as the app's, not ported:** `CeremonyVoice`'s pitch ramp and the `.drain` synth. The
design builds both on the WebAudio graph and this engine has no equivalent, so the BEHAVIOUR is
canon and the means are the register's own idiom — there is nothing upstream to check them
against, and a future session should not go looking.

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
