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
| Pass 4.1 | *"selected cleanly at 101, first tap"* | **void** — it selected something; landing read as correctness |
| Pass 6 | opened a sub-depth from a lit mark | **void** — same |
| `Linked Story` sweep | the mark→story hit path | **void** — read, never walked |

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
