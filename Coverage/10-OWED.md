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
**MEASURED** · **ARITHMETIC** · **OWED** · **E-BLOCKED**. E-BLOCKED rows are NOT here — they
are in §4 below, because they are not waiting on a walk. They are waiting on a build.

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
| O9 | **`darkReturns` restores the bed over 7s.** You do not leave the Light quieter than you found it. | The ramp lives on `AVAudioEngine` state with no source node to render; there is no assertion for it at all. **Verified BY READING only.** | The Light entered and walked back out **twice in one session**, and the field as loud the second time as the first. The defect was cumulative, so one trip cannot show it. | B3 |
| O10 | **The mute is a 1.4s fade, and a muted launch is silent from the first buffer.** | `mainMixerNode.outputVolume` on a live graph. The state and its persistence are measured; the fade is not. | `⊙ sound` toggled and the field riding down rather than cutting; the app relaunched muted and silent before anything appears. | B2 |
| O11 | **The guard star's `nul` is heard as cancellation, not as omission.** | This is the §10 EIGHTH SHAPE, and it is the one thing in the layer whose defect and whose fix both render as silence. | The guard star opened in world V and the *hall dying away* — the bed cancelling while the room's tail keeps decaying — not simply nothing happening. **If it sounds like nothing happened, it is still broken.** | C1 |
| O12 | **The bed-duck under the bowl.** `duckBreath` takes the bed to a fifth and returns it over 9s. | `crossfadeLevel` on a live voice; the ratio is measured, the ramp is not. | A bowl struck with the bed audible underneath, and the bed stepping back and coming home. | B1 |
| O13 | **The twelve repointed sites sound like four different things.** | The voices are measured apart; that the *right* voice is at the *right* moment is a walk. | The Rite's three movements, the Return's cross, the Universe's three, the axis crossing, the two Door crossings, the Light's blip, and the Point's OM — each identified as its own event. | Coverage/9 |
| O14 | **The delay line is inaudible until something is away.** | It is built silent; that nothing leaks into it before `distance` opens is a graph claim on a running engine. | World VI entered with nothing sent, and the room dry. | A2 |

---

## 4 · NOT OWED — E-BLOCKED

Built, measured, and with nothing to drive them. **These are not waiting on a walk. They are
waiting on a build**, and carrying them in the OWED band would mean a final walk that cannot
close them.

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
