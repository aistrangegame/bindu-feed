# 10 · OWED — every claim that needs the walk, and what the walk must show

**Ashrey walks only the final version.** Nothing is held for him mid-build, nothing is
staged for his approval, and no session ends by asking him to look at something. Every
device-provable claim is **OWED** and stays open until one batch at the very end.

That makes this file the thing that must not drift. It is read **as a batch**, once, by
someone who was not present for any of the work — so it has to be complete rather than
remembered. `7-STATE-OF-THE-BUILD.md` §1 is the whole reason: the category that went
invisible for two weeks was exactly this one, *flagged, not fixed*, living in prose nobody
reconciled.

**The rule:** the moment a pass produces a claim it cannot assert offline, it adds a row
here in the same commit. A pass that produces an OWED claim and does not record it here has
not finished.

---

## How to read a row

Each row carries four things, and the third is the one that stops a row rotting:

| field | why |
|---|---|
| **What must be true** | stated as a thing to observe, not as a feature name |
| **Why offline cannot reach it** | if this is ever answerable, the row leaves and becomes a test |
| **What the walk must show** | the evidence that closes it — never *"looks right"* |
| **Stage** | which pass produced it, so the walk can be ordered by surface |

`Bindu FeedTests/VerificationBoundary.swift` is the code-side form of the same distinction:
**MEASURED** · **ARITHMETIC** · **OWED** · **E-BLOCKED**.

### The two rules that decide whether a row belongs here at all

**RULE 1 · OWED MEANS A WALK CAN CLOSE IT. If the blocker is code, it is not OWED.**
Anything waiting on a build cannot be closed by any walk, so filing it here would spend the
one walk Ashrey gets on a row that was never closable — and would return from that walk with
the row still open and no way to tell it apart from a row that failed. E-BLOCKED lives in §4
and never in the tables above it. The test in reverse is the same test: *ask what would have
to change for this row to pass. If the answer is a commit, it is not OWED.*

**RULE 2 · A ROW THAT CAN BE SATISFIED BY NOTHING APPEARING TO CHANGE CANNOT BE CLOSED.**
This is §10's **EIGHTH SHAPE** written into acceptance rather than into documentation. Where a
defect and its fix produce *indistinguishable observations*, "I walked it and it was fine" is
not evidence — it is the exact report a broken build would also produce. **Every such row's
close condition must name something POSITIVE to observe**, and the rows below that carry the
property are marked **⚠ NULL-SHAPED** with the positive condition spelled out. A row that
cannot be given one does not belong in this file; it needs a different verification route.

Audited across all sixteen rows: **five** carry the property. They are O9, O11, O12, O14 and
O16 — and the reason four of the five are in the sound layer is that silence is the medium's
own null. **A visual defect usually looks like something; an audio one usually looks like
nothing.**

---

## 1 · The three that need ears, and only ears

`7-STATE-OF-THE-BUILD.md` §5 names these as the only judgement calls in the sound layer.
Everything else about the sound is a number and is measured.

| # | What must be true | Why offline cannot reach it | What the walk must show | Stage |
|---|---|---|---|---|
| O1 | **Mix balance.** Every event sits under the bed without disappearing into it. | A rendered peak is a number; whether 0.032 is audible under a 0.12 bed at listening volume is a judgement. | Each of the four strike voices identified by ear on its own surface — bowl, field threshold, spine threshold, blip — and none of them either startling or inaudible. | A/B1 |
| O2 | **Reverb character.** The field's 3.6s room and the Point's 7.5s cathedral read as two different spaces. | `AVAudioUnitReverb` presets cannot be compared to a WebAudio convolver by rendering; the tail is the thing and it is subjective. | Crossing from a Room into the Point and back, and hearing the room change. | A2 |
| O3 | **Headphone routing.** The binaural pair reads as width on headphones and collapses honestly on speakers. | The simulator reports no headphones, so `routeState` is false by construction and the pair never renders. | Both routes walked, and the Point's beat heard narrowing on headphones only. | A1 |

---

## 2 · Gestures — a drag no render can perform

Every one of these is a range a law assumes. The **law** is measured; the **arithmetic** is
measured; that a real finger reaches the range is not.

| # | What must be true | Why offline cannot reach it | What the walk must show | Stage |
|---|---|---|---|---|
| O4 | World III's `part` reaches 1 under a real drag. | `unveil`'s cutoff is `340·58^f`; at `f = 0.6` the veil is still shut. A test can assert the curve, not the finger. | The veil fully parted, and the register audibly opening as it does. | C1 |
| O5 | World IV's `panX` spans its `W·1.7` spread. | `bear(f)` is `f·13` dB; a half-travel pan is 6 dB and reads as nothing. | The wall pressed to its limit, and the room ringing under it. | C1 |
| O6 | World VI's `settle` bottoms out at `H·0.7`. | `distance(f)` drives the delay to `0.30 + f·1.35`; a partial settle never lengthens the room. | Settling to the floor of the strata, and the room getting longer as it happens. | C1 |
| O7 | World I's `dwell` and world II's `drawingId` release when the hand comes off. | SwiftUI gesture lifecycle; `onEnded` does not fire under a synthetic drag. §10's own **CLAIM IS RELEASED BY EVERY PATH** entry is about exactly this failure mode. | Each world left by every exit — completing, dismissing, backing out mid-gesture — and the close running each time. | D |
| O8 | The four closing words appear, at the right moment, for their own duration. | The scalar is asserted; that `WorldCue` renders it at `H−150` and fades over `1/rate` is a view claim. | All four read on screen: I 1.11s, III 1.25s, IV 1.25s, V — *E-blocked, see §4*. | D |

---

## 3 · Behaviour that only a running engine has

| # | What must be true | Why offline cannot reach it | What the walk must show | Stage |
|---|---|---|---|---|
| O9 ⚠ | **`darkReturns` restores the bed over 7s.** You do not leave the Light quieter than you found it. | The ramp lives on `AVAudioEngine` state with no source node to render; there is no assertion for it at all. **Verified BY READING only.** | **NULL-SHAPED:** a working restore and a broken one both sound like "the field is there." Positive condition: enter and leave the Light **three times in one session** and the field is *the same loudness on the third pass as on the first*. The defect was cumulative, so a single trip cannot distinguish them — and "it sounded fine" after one trip is what a broken build reports too. | B3 |
| O10 | **The mute is a 1.4s fade, and a muted launch is silent from the first buffer.** | `mainMixerNode.outputVolume` on a live graph. The state and its persistence are measured; the fade is not. | `⊙ sound` toggled and the field riding down rather than cutting; the app relaunched muted and silent before anything appears. | B2 |
| O11 ⚠ | **The guard star's `nul` is heard as cancellation, not as omission.** | The §10 EIGHTH SHAPE in its purest form: defect and fix both render as silence. | **NULL-SHAPED, and the archetype.** Positive condition: the guard star opened in world V and **the bed heard STOPPING** — a drop into nothing while the room's reverb tail keeps decaying over it — and then **the bed heard COMING BACK** after ~4.4s. Two transitions, both audible. **"Nothing happened" is the failure report, not the pass.** | C1 |
| O12 ⚠ | **The bed-duck under the bowl.** `duckBreath` takes the bed to a fifth and returns it over 9s. | `crossfadeLevel` on a live voice; the ratio is MEASURED, the ramp is not. | **NULL-SHAPED:** a duck that never fires and a duck that works both leave "a bowl over a bed." Positive condition: with the bed clearly audible first, strike a bowl and hear the bed **step back within 1.2s** and **come home by 9s** — the return is the half that proves it fired, since a missing duck also has no return. | B1 |
| O13 | **The twelve repointed sites sound like four different things.** | The voices are measured apart; that the *right* voice is at the *right* moment is a walk. | The Rite's three movements, the Return's cross, the Universe's three, the axis crossing, the two Door crossings, the Light's blip, and the Point's OM — each identified as its own event. | Coverage/9 |
| O15 | **`resolve` is heard as nine becoming one, then rising.** | The nine bends and the tenth's rise are MEASURED; that a 12-second event reads as one gesture rather than nine notes is a judgement, and it has no caller yet (see §7). | The close of the Point walked, and the chord collapsing to a unison before the last step lifts out of it. | C2 |
| O16 ⚠ | **The descent and the ascent glide, and the aperture shimmers.** | The curves are MEASURED; that each fires at the right transition, at the right enclosure, is a walk. | **NULL-SHAPED in one direction:** the ascent's glide ends where the descent began, so a glide that never fires and one that fires twice both leave you "back where you started." Positive condition: **descend and ascend from two DIFFERENT enclosures** and hear two different pitches fall and rise — one pair alone cannot show the enclosure is being read. | C3 |
| O14 ⚠ | **The delay line is inaudible until something is away.** | Built silent; that nothing leaks in before `distance` opens is a graph claim on a running engine. | **NULL-SHAPED — and it is the one row here whose pass condition IS an absence**, which is why it needs its opposite attached. Positive condition: world VI entered and **the room dry**, then `settle` taken to the floor and **the room heard lengthening**, then released and **heard drying again**. A delay that never opens and a delay that is not wired both sound dry; only the lengthening tells them apart. | A2 |

**The other eleven are not null-shaped**, and the reason is worth stating: each has a
positive observable that a broken build cannot produce. O1 names four distinct voices; O2 is
two rooms that must differ; O4–O7 are ranges a gesture must reach; O8 is four sentences that
must appear on screen; O10 is a fade with a direction; O13 is twelve events that must be
distinguishable from each other; O15 is a chord collapsing. None of them can be satisfied by
nothing changing.

---

## 4 · NOT OWED — E-BLOCKED

Built, measured, and with nothing to drive them. **These are not waiting on a walk. They are
waiting on a build**, and carrying them in the OWED band would mean a final walk that cannot
close them.

**RULE 1 applied:** every row here fails the *"what would have to change"* test with the
answer *a commit*. None can be closed by any walk, and none may migrate into the tables above
until the build that unblocks it lands — at which point it becomes an ordinary OWED row.

| # | The sound | What is missing | Stage |
|---|---|---|---|
| E-V | `reflect(−1)` — the inverted tone — **and** world V's `settling` close, *"THE GLASS LET GO. WHAT FACED YOU, FACED YOU."* | **ONE missing state, two consequences.** `world-five.js` panes are HELD: `facing()` reads `cos(angleOf(held))` and `release(){if(this.held)this.settling=1}`. The app's panes are TAPPED. The same `held` that would let a pane turn past 90° into the inverted tone is the one that would let it be let go into the close. **One Stage E item, not two.** | E |
| E1 | `join` · `ensemble` · `leaveAll` · `DancerVoice` | World VII has no chain. `WorldDance` holds `offeredOnce` and nothing else — no bodies, no lock. `AUDIT D5.8`, BLOCKER. | E1 |
| E2 | `send` · `arrive` · `arriveAll` | World VI's arc registry lives in a `DispatchQueue` chain inside the view, so leaving the register kills the flight. Nothing tracks what is away. | E2 |

---

## 5 · B5 · KARISHMA — the one row that needs more than a walk

**This is the item Ashrey personally reported.** It was declared fixed once already, against
Neev and Gaia — *the only two voices whose shape the old rule happened to fit*. It is the
sixth shape in §10: a rule that always fires reads as working, and a rule fixed against the
cases it already suited reads as fixed.

So a screenshot that looks fine is not evidence, and neither is "I checked Karishma." The
close condition is a **measured table of all eleven**, because the failure was never visible
on the voice being looked at — it was visible in the *spread*.

### What the walk must produce

For each of the eleven, in one pass, on one device, at one size:

| voice | register-0 stack bottom (measured Y) | figure top (measured Y) | overlap |
|---|---|---|---|
| ash · ashrey · sakshi · karishma · bindu · lalita · gaia · neev · arch · shweta · sid | from `RoomSaysBottom` | from `RoomFigures.extent` | computed |

**Why measured and not observed:** `RoomSaysTop` is a live SwiftUI preference. Its value is
produced by layout at runtime and no offline render can produce it — the whole rule depends
on the disc reporting y≈96, and that number has never been read on a device. The extents are
MEASURED (`RoomFigureExtentTests` pins all eleven); the *stack* is not.

### The four conditions, all of which must hold

1. **`RoomSaysTop` reports ≈96** on every one of the eleven. If it reports 0 the preference
   never fired and the rule is running on its `.greatestFiniteMagnitude` sentinel.
2. **Karishma does not overlap** — she has the joint-shortest principle of the eleven and her
   spiral climbs to y 162, so she is the case the old rule gave the *weakest* recede.
3. **The longest principle does not overlap** — Neev, 248 characters, six lines.
4. **Neev and Gaia have not moved much.** They are the regression: the two the old rule fit.
   If the fix has changed them substantially, it has traded one wrong answer for another.

`RoomFigureExtentTests.neevAndGaiaAgree` asserts 2, 3 and 4 *arithmetically* — on assumed
stack bounds of 96 and 405. **The walk replaces the assumption with the measurement.** That
is the entire difference between this row and the rest of the OWED band.

---

## 7 · `resolve` — settled by reading. It is the axis's, not the aperture's.

`resolve()` is built and measured (`CloseOfThePointTests`) and called by nothing. The question
was whether the 852 → 963 lift and the aperture's close are the same moment. **They are not**,
and the design says so in three places without being asked.

**1 · `resolve` is not on the Point's sound facade at all.**
`The Instrument v3.html:4862-4863` — `window.Snd = {breath, blip, shimmer, world, glide, om,
threshold}`. Seven entries, and `resolve` is not among them. The Point *cannot* call it. It
lives on `B` (`spine-sound.js`, `g.BODY`), which is the INSTRUMENT's body.

**2 · 852 → 963 is the axis's own step, and it has a name.**
`The Instrument v3.html:1018` — `{z: 9, key:'centre', name:'the centre', sub:'the point, at
last', hz: 963}`, and `:982`'s ladder line reads `+9  the centre  963 → 136.1`. The lift
`resolve` performs is the axis arriving at **z = 9, the centre**. The app already has it:
`AxisModel.swift:94`, same z, same name, same 963.

**3 · Both of the aperture's moments ARE marked, and neither is `resolve`.**
`The Point v9.html:1286` — the aperture opening — is `Journey.visitors++; Snd.shimmer();
YANTRA.flare()`. `:1341` — the reveal, as `.encl[9]` goes bare at 136.1, the landing home —
is `Snd.shimmer(); Snd.om(); YANTRA.flare()`. A design that had wanted `resolve` at either
would have had nothing stopping it.

**Every sound call in `The Point v9.html`, in full:** `:943` `world(i)` · `:1011` `blip(0)`
(the gate) · `:1190` `blip(dimN)` · `:1198` `blip(cur)` · `:1236` `glide(cur, true)` ·
`:1263` `glide(cur, false)` · `:1286` `shimmer()` · `:1341` `shimmer(); om()`. Eight, and
`resolve` is not one of them.

**So the ambiguity is gone and the gap has moved.** `resolve` belongs to the axis's crossing
into z = 9 — and the axis plays `B.threshold(S.at(Z).hz)` at *every* register (`:5354`),
including that one. The design has a generic crossing where `resolve` describes a specific
one. **Still not wired**, because "the design describes this moment" and "the design fires
this here" are different claims and only the second is a caller. This is the `riteThreshold`
shape exactly: mapping first turned a plausible guess into a proof, and the proof says the
guess was wrong.

**FOUND WHILE READING, AND FIXED:** the app's reveal called `om()` alone where `:1341` calls
`shimmer()` and `om()`. One of the two moments the design *does* mark was marked incompletely.

---

## 6 · Corrections to `8-ACTION-PLAN.md`, against its own rows

The plan is a working document and two of its numbers are wrong. Recorded here so the next
reader hits the real number rather than the written one.

### STAGE D · *"one mechanic, seven instances, eight cues"* → **five and four**

Taken from the cue list rather than from the world files. The design declares **five** decay
scalars and **four** closing lines:

| world | scalar | rate | line |
|---|---|---|---|
| I | `leaving` | 0.9 | IT CLOSED. IT DOES NOT MIND. |
| II | `reeling` | 0.7 | **none — deliberately** |
| III | `closing` | 0.8 | IT CLOSED BEHIND YOU. IT ALWAYS DOES. |
| IV | `easing` | 0.8 | THE WALL EASED. WHAT WAS STRUCK STAYS STRUCK. |
| V | `settling` | 0.55 | THE GLASS LET GO. WHAT FACED YOU, FACED YOU. |
| VI | — | — | `home` (1.5) is every return passing through the particle. Plan **E2**. |
| VII | — | — | `resolved` is the d-map's permanent close, not a decay, and carries **two** lines. |

**World II decaying without a line is the design saying something, not omitting something.**
Its held words already end at *"far out, and still leaving"* — a world that never closes, so
it has no closing word to say. Building a seventh and eighth instance to match the tally
would have been inventing the mechanic to fit the plan.

### B1 · *"`riteThreshold` … → 0.075"* → correct on the ceiling, wrong on the identity

The plan's ceiling fix was right and necessary. But `riteThreshold(hz:dur:)` carries the
FIELD threshold's signature, and 10 of the 19 sites wanted three *different* voices at
0.032, 0.06 and 0.07. See `Coverage/9-BOWL-CALL-SITE-MAP.md`, applied.
