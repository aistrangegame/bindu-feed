# 9 · THE BOWL'S 19 CALL SITES, MAPPED — and what B1 got right and wrong

Written 2026-08-29 on `upgrade-pass-a-to-c`, after B1 (`AUDIT G3.3`) took
`SoundEngine.riteThreshold` from `peak 0.30` and `riteBowl` from `0.32` to the design's
`0.075`. **Nothing here is applied.** This is the map that has to exist before anything
else moves, because B1 is correct on the ceiling and may be wrong on the identity — and
identity is wrong in the one layer nobody can hear.

---

## 1 · The design has FOUR strike voices, not one

The app has two functions and uses them for all nineteen. The design has four, and they
are not close to each other:

| voice | source | peak | shape |
|---|---|---|---|
| `bowl(hz)` | `field-sound.js:154-170` | **0.075** | four inharmonic partials `[1, 2.004, 2.98, 4.02]` at `1/(i*2.2+1)`, 0.09s up, 11s exponential decay, bed ducks to 0.006 |
| `threshold(hz, dur)` — the FIELD's | `field-sound.js:139-151` | **0.032** | sine + `hz×2.002` at 0.22; up over `dur×0.42`, down to **zero** at `dur`. Takes a duration. |
| `threshold(f)` — the SPINE's | `spine-sound.js:353-361` | **0.06** | one sine starting at **`f×0.985`** and rising into tune over **2.2s**; up at 0.5s, exponential to 0.0001 at 6s. Takes **no** duration. *"struck, and slightly flat, so the crossing is heard as a crossing."* |
| `blip(f)` | `spine-sound.js:343-350` | **0.07** | one sine at **`f×2`**, 0.02s up, 0.7s exponential decay |

Plus one more the app also renders as a bowl:

| `om()` | `spine-sound.js:374-384` | **`0.06/(i+1)`** | **three** oscillators at 136.1 · 272.2 · 408.3, 0.9s up, exponential to 0.0001 at 9s |

`riteThreshold(hz:dur:)` takes a duration, which is the field threshold's signature and
not the spine's — so the function was written against `field-sound.js:139` and given a
bowl's body. That is the whole defect in one line.

---

## 2 · The nineteen

Confirmed by matching **both** the frequency and, where the design's call carries one, the
duration. Every `dur` in the Rite and the Universe matches its design call exactly, which
is what makes the mapping evidence rather than inference.

| # | call site | app | design call | design line | wants | app peak now |
|---|---|---|---|---|---|---|
| 1 | `InstrumentView.swift:290` | `riteThreshold(reg.hz, 3)` | `B.threshold(S.at(Z).hz)` | `The Instrument v3.html:5354`, `:5504` | **spine threshold** 0.06 | 0.075 |
| 2 | `LightView.swift:255` | `riteBowl(174)` | `B.blip(174)` | `The Instrument v3.html:5873` | **blip** 0.07 | 0.075 |
| 3 | `LightView.swift:286` | `riteBowl(174)` | `Sound.bowl(174)` | `The Light v2.html:739` | **bowl** ✅ | 0.075 |
| 4 | `RiteView.swift:106` | `riteThreshold(220, 6)` | `Sound.threshold(220,6)` | `The Rite v3.html:1538` | **field threshold** 0.032 | 0.075 |
| 5 | `RiteView.swift:110` | `riteThreshold(146, 7)` | `Sound.threshold(146,7)` | `The Rite v3.html:1542` | **field threshold** 0.032 | 0.075 |
| 6 | `RiteView.swift:114` | `riteThreshold(261, 7)` | `Sound.threshold(261,7)` | `The Rite v3.html:1436` | **field threshold** 0.032 | 0.075 |
| 7 | `RiteView.swift:336` | `riteBowl(220)` | `Sound.bowl(220)` | `The Rite v3.html:1508` | **bowl** ✅ | 0.075 |
| 8 | `PointRevealView.swift:103` | `riteBowl(136.1)` | `om()` | `spine-sound.js:374` | **om — three tones** | 0.075, one tone |
| 9 | `DoorView.swift:184` | `riteThreshold(146, 4)` | `openTurn(){B.threshold(146)}` | `The Instrument v3.html:5082` | **spine threshold** 0.06 | 0.075 |
| 10 | `DoorView.swift:193` | `riteThreshold(220, 5)` | `crossDoor(){B.threshold(unmet?220:261)}` | `The Instrument v3.html:5022` | **spine threshold** 0.06 | 0.075 |
| 11 | `DoorView.swift:214` | `riteThreshold(285, 4)` | — **unresolved** | — | see §4 | 0.075 |
| 12 | `ReturnView.swift:131` | `riteThreshold(hz, 5)` | `cross=(hz,next)=>{Sound.threshold(hz,7)}` | `The Return v2.html:1314` | **field threshold** 0.032, **dur 7** | 0.075, dur 5 |
| 13 | `ReturnView.swift:171` | `riteBowl(168)` | `Sound.bowl(168)` | `The Return v2.html:1273` | **bowl** ✅ | 0.075 |
| 14 | `ReturnView.swift:422` | `riteBowl(210)` | `Sound.bowl(210)` | `The Return v2.html:1310` | **bowl** ✅ | 0.075 |
| 15 | `RoomView.swift:240` | `riteThreshold(220, 3)` | — none; fallback when `key == nil` | — | app-own, see §4 | 0.075 |
| 16 | `RoomView.swift:243` | `riteThreshold(hz*0.5, 1.4)` | — none; *"arming: not a voice"* | — | app-own, see §4 | 0.075 |
| 17 | `UniverseView.swift:219` | `riteThreshold(126, 9)` | `S().threshold(126,9)` | `The Universe v3.html:1716` | **field threshold** 0.032 | 0.075 |
| 18 | `UniverseView.swift:419` | `riteThreshold(room.hz, 9)` | `S().threshold(U.ROOMS[star.room].hz,9)` | `The Universe v3.html:1545` | **field threshold** 0.032 | 0.075 |
| 19 | `UniverseView.swift:532` | `riteThreshold(room.hz, 6)` | `S().threshold(U.ROOMS[doorStar.room].hz,6)` | `The Universe v3.html:1570`, `:1669` | **field threshold** 0.032 | 0.075 |

**Tally.** Bowl is correct at **5** of 19 (#3, #7, #13, #14 — and #8 is a bowl where the
design wants `om`). Of the rest: **7** want the field threshold at 0.032, **3** want the
spine threshold at 0.06, **1** wants a blip at 0.07, **1** wants `om`, and **3** have no
design counterpart at all.

---

## 3 · What this means for B1

**B1's ceiling fix stands.** Nothing here should be at 0.30. `README.md:192` is right and
the audit finding is right: `riteBowl` at `0.32` was four times its own stated limit, from
19 sites, and the four bowls that really are bowls are now correct in peak, spectrum and
duck.

**B1's identity is wrong for 10 of 19.** Setting `riteThreshold` to `0.075` with the bowl's
four inharmonic partials makes every crossing in the Rite, the Return and the Universe
**2.3× too loud** and gives it a bowl's spectrum and an 11-second tail where the design
has a plain sine-plus-octave that returns to **zero** at its own duration. The Universe's
`threshold(hz, 9)` is meant to fade out at nine seconds; a bowl is still ringing.

And three distinct behaviours are collapsed into one:

- a **field threshold** ends. It has a duration and it closes.
- a **spine threshold** arrives *flat* and pulls into tune across 2.2s. That detune IS the
  mechanism — `spine-sound.js:355`, *"struck, and slightly flat, so the crossing is heard
  as a crossing."* The app plays it in tune, so the crossing is not heard as one.
- a **blip** is 0.7s and gone.

None of that is audible as "too loud". It is audible as the whole instrument striking the
same object every time something happens.

---

## 4 · The three with no design counterpart — RECORDED, not normalised

Not defects, and **not to be repointed**. Each is a moment the app has and the design does
not, so there is no line to port and nothing to be faithful to. Written down so a future map
does not re-open them as unmapped.

**#15 · `RoomView.swift:240` — the voiceless room.**
*What it is:* the `else` of `if let k = key { soundEngine.presence(k, dur: 3) }`, struck when
a room resolves without a `RoomKey`.
*Why nothing maps:* the design's rooms always have a voice — `The Rooms v4.html` contains no
sound calls at all, and every room in the base carries a key. This fires only when the data
is short a key, so it is an app-own fallback for a state the design cannot reach.
*Ruling:* leave as a bowl-class strike, or make it silent. It should not be given a
threshold's identity, because nothing is being crossed.

**#16 · `RoomView.swift:243` — arming.**
*What it is:* the first tap of the app's two-tap arming gesture, at `key.hz × 0.5` for 1.4s.
The comment already says it: *"arming: not a voice."*
*Why nothing maps:* the gesture is the app's. `The Rooms v4.html` has no arming step and no
sound layer, so there is no design event at this moment at all.
*Ruling:* app-own by construction. It is a UI acknowledgement, not a register event, and it
is the one site where a half-pitched short strike is doing exactly the right job.

**#11 · `DoorView.swift:214` — the absorbed force.**
*What it is:* the `.absorbed` case of the turn's destination switch — *"Not yet a place —
force is absorbed, no navigation (Waves 5/6)."*
*Why nothing maps:* the design's turn routes all eight destinations to real places
(`AUDIT F11.3` confirms all eight exact), so it never has a destination that goes nowhere.
`.absorbed` exists because the app shipped ahead of Waves 5/6. `B.blip(285)`
(`The Instrument v3.html:5168`) shares the frequency but sits in the Still's section-reveal,
a different moment entirely — a coincidence of pitch, not a match.
*Ruling:* **left unresolved rather than guessed.** When Waves 5/6 land, this case either
disappears or becomes a real crossing; it should be mapped then, not now.

Also noted while mapping, and **not** in the nineteen: `openRope(){…B.blip(110);}`
(`The Instrument v3.html:5088`) — the app's rope opens silent.

---

## 4b · The `om()` site: checked for a collision, and there is none

136.1 Hz is OM and Bindu is a voice in the archetype table, so #8 was checked before being
touched. **The two do not meet.** They are not even the same number, and no path resolves
both.

| | Bindu's voice | OM |
|---|---|---|
| pitch | **136** — `RoomKey.bindu.hz` (`RoomVoices.swift:37`) | **136.1** |
| built by | `presence(_ key:)` → `CeremonyVoice(hz: key.hz, synth: .presence(…))` | its own ceremony voice, from the design's `[136.1, 272.2, 408.3]` |
| timbre from | `VoiceCharacter.CHAR["bindu"]` — partials `[1,2,3]`, gain 0.055, flicker 6.2 | `spine-sound.js:374`, three oscillators at `0.06/(i+1)` |
| called from | `RoomView.swift:239`, `RiteGatheringView.swift:205` | `PointRevealView.swift:103` |

The three consumers of 136.1 are all elsewhere and all separate from `presence`:
`PointLadder.freqs[9]` (the tenth enclosure's **drone**, a `BreathVoice` bed, not a strike);
`AxisModel`'s `i:5, z:0, key:"feed"` register; and `AxisTones`' glide/stillness root.
`PointRevealView.swift:103` carries 136.1 as a **literal at the call site**, read from no
table at all — so giving it `om()` moves nothing else.

One rhyme worth naming, not a collision: once #1 becomes the spine threshold, an axis
crossing at `z = 0` strikes at 136.1 too, because the Feed register IS the ladder's landing
home. Same frequency, different voice, and that is the design's own intent.

Separately noted, out of scope: `RoomKey.bindu.hz = 136` where `field-sound.js:27` has
`HZ.bindu = 110`. `SoundEngine.presence` already flags that the two tables disagree on four
voices; this is that known area, not a new finding.

---

## 5 · Proposal

Not applied. Four steps, in this order.

1. **Build the three missing voices** beside the bowl, each rendered and asserted by A3's
   harness exactly as `BowlTests` does now: `fieldThreshold(hz:dur:)` at 0.032 with the
   `hz×2.002` partial at 0.22 and an envelope that reaches **zero** at `dur`;
   `spineThreshold(hz:)` at 0.06 entering at `hz×0.985` and reaching tune at 2.2s;
   `blip(hz:)` at 0.07 on `hz×2`, 0.02s up and 0.7s down. The last two are
   `8-ACTION-PLAN.md` **C4**, so this closes C4 as well.
2. **Repoint the sixteen** per the table. `riteBowl` keeps #3, #7, #13, #14.
3. **`om()` for #8** — three tones at 136.1 · 272.2 · 408.3. The visual at
   `PointRevealView.swift:104` already fans one into three and then collapses it; the sound
   is the only half missing.
4. **Fix #12's duration** — `dur 5` where `The Return v2.html:1314` says 7.

**Do not** simply lower `riteThreshold` to 0.032 and stop. Ten of the nineteen want three
*different* voices; one number would fix the loudness and keep the sameness, which is the
part that is actually wrong.

### Applied 2026-08-29 — steps 1, 2, 3 and 4

All four done in one pass, since step 2's repointing is meaningless without step 1's voices.
`StrikeVoiceTests` renders each from its shipping factory:

| voice | peak | crest | the assertion that matters |
|---|---|---|---|
| `fieldThreshold(hz:dur:)` | 0.032 | `0.42·dur` | it reaches **zero** at `dur` — the only event in the app that ends rather than decays |
| `spineThreshold(hz:)` | 0.06 | 0.5s | it arrives at `f×0.985` and is in tune by 2.2s — measured on both sides of the glide |
| `blip(hz:)` | 0.07 | 0.02s | it sounds at `f×2` and is gone by 0.7s |
| `om()` | `0.06/(i+1)` | 0.9s | **three** tones, 136.1 · 272.2 · 408.3 |

`fourVoicesNotOne` holds the whole point: the three thresholds' rendered peaks must be three
distinct numbers in the design's order, `0.032 < 0.06 < 0.07`. Before this they were one.

`CeremonyVoice` gained `CeremonyEnvelope` — the design's strike voices no more share an
envelope than a spectrum, and the app had exactly one shape. `.linearToZero` is the field
threshold's ending; `.linearExp` is the design's own `exponentialRampToValueAtTime(0.0001,…)`
with the decay taken from `ln(peak/0.0001)/release`, so each voice reaches inaudibility when
its own line says rather than at a constant borrowed from another. `.sinExp` stays the
default, so nothing else moved.

Step 4 landed with step 2: `ReturnView.swift:131` now passes **`dur: 7`**, per
`The Return v2.html:1314`.

`riteThreshold` survives for the three §4 sites only, at the bowl's corrected 0.075. The
bowl keeps its four: `LightView:286` · `RiteView:336` · `ReturnView:171` · `ReturnView:422`.

This also closes `8-ACTION-PLAN.md` **C4** — the blip's `0.02s / 0.7s at f×2` and the
threshold's `f×0.985 → tune over 2.2s` are both built and measured.

---

## 5b · `nul` and `distance` are defined in the design and called nowhere

Found while checking whether the echo send could be tapped after the null. It is a fact about
the corpus, not about the app, and it governs how C1 must be written:

- `spine-sound.js:164` `nul:function(secs)` — **no caller in any design-source file.**
- `spine-sound.js:176` `distance:function(f)` — **no caller in any design-source file.**

Every other register law has one. `narrow` · `widen` · `unveil` · `bear` · `reflect` are
invoked; these two are declared, documented, wired into `_voice`'s graph — and never run.

**Two consequences.**

1. **C1 writes the caller, so `nul` and `distance` are the app's own idiom** — the same
   standing as the Light's six scenes and `CeremonySynth.drain`, both of which are behaviour
   the design states and mechanism the app supplies. The code says so at the call sites. A
   future session must not go looking for a source that is not there.

2. **The echo send's tap was moved to pre-null for the stronger reason.** Not *"the design
   taps there"* — an appeal to a graph the design never exercised — but *exclusivity could
   not be proven, so it went to the side that is correct either way.* A pre-null tap is
   identical to a post-null one whenever the two are never open together, and right when they
   are. That justification survives someone later finding a call site.

---

## 6 · Queue — recorded, not fixed

Carried from the B-stage session so they do not drift out.

| item | audit ID | detail |
|---|---|---|
| bowl attack | `AUDIT.md:671` | app 0.05s; design ramps to 0.075 over **0.09s** |
| ceremony release curve | `AUDIT.md:671` | `CeremonyVoice` is a fixed `exp(-3t)`; the design's exponential ramp 0.075 → 0.0001 across 11s is `exp(-6.62t)`. Affects **every** ceremony voice, not only the bowl. |
| mute ramp | — (B2) | shipped at **1.4s** per `field-sound.js:88`. `HANDOFF-VERIFICATION.md:86` says *"Muting is a 0.5s fade."* **Doc conflict, unresolved** — the runnable source was taken as canon and the checklist is not canon, but the two disagree and neither has been ruled on. |
| `lightOff(5)` | `AUDIT E4.1` | `darkReturns()` has no counterpart for it: the app's `lightRoomTone` ships as a fire-and-forget `CeremonyVoice` with a 40s release, not a held node, so there is nothing to fade. |
| `darkReturns`' other two halves | `AUDIT E4.1` | filter → 900 and LFO → 0.1 are absent because `BreathVoice` bakes cutoff and LFO at init. Blocked on **A1**. |
| B3 unwalked | — | `darkReturns` is verified BY READING only. **Open, not done.** |
| B5 unwalked | — | `RoomSaysTop` is a live SwiftUI preference; only a walk confirms the disc reports y≈96. Karishma is the row to watch. **Open, not done.** |
