# 8 · ACTION PLAN — from here to a finished app

Read `7-STATE-OF-THE-BUILD.md` first. This is the sequence, with dependencies, and an
honest word about size.

---

## The shape of it

Roughly **180–200 unique work items in ~25 workstreams**. That is many sessions, not one.
Anyone who tells you otherwise is doing the thing this whole exercise exists to stop.

The sequence below is ordered by **dependency first, then by what a first reader meets**.
Two workstreams (A and B) unblock large parts of everything after them, so they go first
even though neither is glamorous.

---

## STAGE A · Structural prerequisites — nothing else in the sound layer can start without these

**A1 · Give `BreathVoice` its three missing nodes.** `spine-sound.js:63` `_voice` builds
every register voice with a peaking filter (`pk`), a null gain (`nul`) and an echo send
(`ech`). `Sound/BreathVoice.swift:95-193` has the L/R pair, the LFO, the octave and the
lowpass — and none of those three. **Four of the seven register laws move exactly these
nodes**, so no call site can be written until they exist.

**A2 · Add the delay line.** `spine-sound.js:52-57` — `AVAudioUnitDelay`, 3.0s max, 0.42s
time, feedback 0.44, 2400 Hz lowpass, returning into both master and reverb. The app has
exactly one audio unit. World VI's entire premise — *"the room IS the distance it
travelled"* — has nothing to stand on, and `distance`/`send`/`arrive`/`arriveAll` all route
through it.

**A3 · Build the offline-render test target.** `Bindu FeedTests` exists with `TEST_HOST`
wired and is a `PBXFileSystemSynchronizedRootGroup`, so a new file needs no project
surgery. Every voice is a standalone `final class` exposing an `AVAudioSourceNode` at 48 kHz
deinterleaved stereo — construct one, attach it to a private `AVAudioEngine` in
`enableManualRenderingMode(.offline,…)`, pull frames, assert. This is what makes the whole
sound layer verifiable without ears, and it should exist **before** A1/A2 land so their
correctness is provable.

---

## STAGE B · Ships badly — fix before anyone opens the app

**B1 · The bowl at 4× its ceiling.** `SoundEngine.riteThreshold` `peak: 0.30` and
`riteBowl` `0.32` → `0.075`; partials `[1, 2.756, 5.404]` → `[1, 2.004, 2.98, 4.02]` at
`1/(i*2.2+1)`; add the bed-duck to 0.006 (`duckBreath()` is an empty stub at
`SoundEngine.swift:812`). 19 call sites inherit the fix. *Audit G3.3.*

> **CORRECTION, 2026-08-29 — `Coverage/9-BOWL-CALL-SITE-MAP.md`.** The ceiling fix was right
> and necessary, and is applied. The IDENTITY was wrong for **10 of the 19**:
> `riteThreshold(hz:dur:)` carries the FIELD threshold's signature, and those ten wanted three
> *different* voices at 0.032, 0.06 and 0.07 — not one at 0.075. *"19 call sites inherit the
> fix"* is the sentence that hid it: they inherited the ceiling and the wrong identity
> together. Mapped and repointed; **C4 closed with it**.

**B2 · Add a mute.** No `setMuted`, no `setOn`, no sound control anywhere. This is a
shipping defect independent of everything else.

**B3 · `darkReturns`.** `LightView.swift:540` renders "walk back out" and calls no sound;
nothing restores the field bed after `lightVeilLift` drained it. Bed filter back to 900, LFO
back to 0.1, level back to 0.030 over 7s. *Audit E4.1 / G3.1.*

**B4 · `ReturnStrata` draws zero rings at `rings == 1`.** `stride(from: n-1, through: 1,
by: -1)` is empty when `n == 1`, so **the very first return anyone seals renders nothing**.
`ringAges`' last element is provably never read, confirming the off-by-one. One-line fix,
BLOCKER severity. *Audit E3.1.*

**B5 · The register-0 overlap, all eleven rooms.** Ashrey's own reported bug. The rule needs
two inputs where it has one:
- measure the **whole** register-0 stack (disc y≈96 → principle bottom), not just the principle — extend `RoomSaysBottom` at `RoomView.swift:429-442`;
- give it each figure's **real** vertical extent instead of a constant `cy = 358`. The numbers come from the figures' own drawing constants, not invention: ash −34, ashrey 137, sakshi 140, karishma 162 (light source −85), bindu 185, lalita 216, gaia 220, neev 221, arch 249, shweta 260, sid 359.
- recompute `over` (`RoomView.swift:302`) as box overlap. Verify by measurement on all eleven, with Neev and Gaia as the regression check.

**B6 · The gate's once-ever line.** `InstrumentView.swift:589-593` shows it every time;
design guards it with `gateSaid` and reverts after 8500ms. *Audit C3.3 / C3.4.*

---

## STAGE C · The Point's silence — the largest single gap

Depends on A1 + A2. Thirteen mechanisms, currently zero.

**C1 · Wire the seven register laws.** `narrow` (I) · `widen` (II) · `unveil` (III) ·
`bear` (IV) · `reflect` (V) · `nul` (the one deliberate silence) · `distance`/`send`/
`arrive`/`arriveAll` (VI) · `join`/`ensemble`/`leaveAll`/`dancers` (VII).
`PointReadings.swift` and `PointWorlds.swift` currently make no sound calls at all.

**C2 · `resolve` — the close of the Point.** Nine tones at
`852 × [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2, 3]` pulling to one, then 852 → 963. The app
plays a single bowl.

**C3 · `glide` and `shimmer`.** The descent, the ascent and the aperture's arrival are all
completely silent where the design marks each as an event.

**C4 · `blip` and `threshold` envelopes.** The blip is 0.02s attack / 0.7s exponential decay
at f×2 — the app substitutes a bowl or a 1.5s choir. The threshold should strike at
f×0.985 and rise into tune over 2.2s, so a crossing is *heard* as a crossing.

---

## STAGE D · The leaving decay — one mechanic, ~~seven instances, eight cues~~ **five and four**

> **CORRECTION, 2026-08-29 — `Coverage/10-OWED.md` §6.** *"Seven instances, eight cues"* was
> taken from the cue list rather than from the world files. The design declares **five** decay
> scalars (I `leaving` 0.9 · II `reeling` 0.7 · III `closing` 0.8 · IV `easing` 0.8 ·
> V `settling` 0.55) and **four** closing lines — II decays and says nothing, deliberately,
> because *"far out, and still leaving"* is a world that never closes. VI's `home` and VII's
> `resolved` are different mechanics. Built to five and four; building the missing two would
> have been inventing the mechanic to fit the plan.

`ReadTurning` already has the shape: `withdrawing`, on its own wall clock, finishing whether
he is there or not. Generalise it into a shared closing state, then attach the ~~seven~~
**four** authored closing lines.

**BUILT 2026-08-29** as `LeavingDecay` + `PointLeaving`, wall-clocked so it finishes whether
he is there or not. Wired in I, II, III and IV. **World V is E-BLOCKED**, and for the same
missing state as `reflect(−1)`: `world-five.js:182` is `release(){if(this.held)this.settling=1}`
and the app's panes are TAPPED, not held. One Stage E item, two consequences —
`Coverage/10-OWED.md` §4 row **E-V**.

Note: the plan's *"world V needs a rename first — the app already uses `settling` for which
face is toward you"* is correct and is why V's decay is named from `PointLeaving` rather than
from a `@State` on the world.

---

## STAGE E · World mechanics — the biggest behavioural gap after the sound

**E1 · World VII has no dance.** 11 of 23 mechanisms absent — `hand`, `offer`, `moveHand`,
`letGo`, `chain`, `joinedQ`, `_join`, `tookHand`, `lock`, `joinedNow`, and the whole
`update` figure (cohesion, separation, alignment, Kuramoto coupling). The caption prints
`\(revealed) hands` — it counts hands that do not exist. *Audit D5.8, BLOCKER.*

**E2 · World VI's wall clock and arc registry.** The arc lives in a `DispatchQueue` chain
inside the view, so leaving the register kills the flight. *"If he leaves the register, they
still come back"* is not true. Plus `holding`/`lift`/`aim`, `pend`, and `home` (every return
passing through the particle, which flashes as it does).

**E3 · World III's `hold` is reversed.** It gives on **release** where the design gives
**while the parting is held** — the exact inversion of the world's own sentence. Not a gap;
a reversal. Fix before adding anything else to that world.

**E4 · World II's rays.** No `emit`, no nine arms with per-universe curl/reach/drift, no
spanda pulse, no `split` — the one-light-becoming-many the world exists to perform.

**E5 · World IV's room.** No `wall: left/floor/back` assignment, no vault-on-breath, no
bowing under load, no `struck[id]` memory. *Audit D5.5, BLOCKER.*

**E6 · World I's still figure.** Ten stars on a hash ring where the design settles five
statements in a row, three questions below and apart, two laboratories at the edge.

---

## STAGE F · The Return

**F1 · `renderAnswers`.** A sealed return is never answered by a voice. `sealReturn` writes
the ring and your words and stops. This is what makes returning generate new material rather
than a second copy of the same page. ~~*Audit E3.2, BLOCKER.*~~

> **CORRECTION, 2026-08-29 — and it has no audit ID at all.** E3.2 is *"the Rings movement has
> no rings list"*, a different mechanism; it was cited because it is the nearest Return-shaped
> BLOCKER, not because it is this. **No finding in `AUDIT.md` covers `renderAnswers`**, and the
> reason is structural: `renderAnswers` lives at `Claude Design Round 2/comps/The Return.html:139`
> and **the audit did not read the comps.**
>
> The mechanism sweep did — `Tools/mech-inscope.json` carries it, one of the 485. So this is
> exactly the gap `7-STATE-OF-THE-BUILD.md` §1 describes: *a mechanic with no string attached
> was invisible to all four checkers*, and the sweep is the one that keys on declarations.
> **The plan then cited the audit, which is the register that could not see it.**
>
> `Tools/check_audit_ids.py` exists as of this correction, and puts every `Audit X.Y` beside
> the finding it names so the next one is visible rather than plausible. Built 2026-08-29;
> resolved 21 of 21 references, and `--list` shows this one as the mismatch it was.

**F2 · `agedBed` and the `ring` tone.** The Return opens on the ordinary field bed; its ring
is a generic bowl instead of `R = [2,3,4,4.5,6,8]` entering 1.5% flat and coming into tune
over 4s — the audible twin of the eccentric ring settling into true.

**F3 · The rings list, the Record's corpus, the sealed line, `towardGold`.** *Audit E3.3,
E3.6, E3.8, E3.9, E3.10, E3.11.*

---

## STAGE G · The remaining audit backlog

The other ~90 open MAJOR/MINOR findings, worked **in audit-ID order** so the ledger tracks
them. Largest clusters: the axis passage (`swift`, `hit`, `dur`, `after` — the passage has
no middle and no fast path), the shader's six pinned uniforms, `uBack`/`uHand` never
reaching the shader, the sky's sweep and dwell, `#trav`, and the F-series surface deltas.

---

## STAGE H · Verification and deploy

**H1 · Extend `check_citations.py` to Swift comments** — 212 source citations have never
been checked, and four already point past the end of their files.

**H2 · Hand-judge the 465 REVIEW rows**, or explicitly rule the band as accepted backlog.

**H3 · Re-walk the acceptance gate**, together with **every row of `Coverage/10-OWED.md`** —
Ashrey walks only the final version, so the whole OWED band is one batch here and nowhere
earlier. `10-OWED.md` §5 (B5/Karishma) needs a measured eleven-row table, not a look.
Original text: — only 12 of 44 lines were ever walked or measured.

**H4 · Deploy.** Merge to `main` (53 commits ahead), **add a tracked shared scheme** — there
is no `.xcscheme` in git at all, which blocks any CI — confirm `Info.plist` for submission
(notably a microphone usage string, since the Rite records), then archive and validate.
Ashrey does the App Store Connect upload.

---

## Recommended first session

Not the whole of Stage A. Start with:

1. **A3** — the offline test target, so the sound work is provable.
2. **B1** — the bowl. It fails immediately under A3's peak assertion, which proves the test works.
3. **B4** — the one-line ring off-by-one.
4. **B2, B3** — mute and `darkReturns`.
5. **B5** — the register-0 fix across all eleven, measured.

That is one coherent session: it makes the loudest defect quiet, gives the first-ever
sealed return something to draw, stops the app leaking silence, fixes the bug Ashrey
actually reported, and leaves behind the test harness everything after it depends on.

---

## The rule that prevents recurrence

**No item is "done" until it names its audit ID or mechanism name in the commit, and the
five checkers are green.** 235 of 254 findings went untracked because work was described in
its own words rather than against a list. That is the whole failure, and it is cheap to
prevent.
