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

### The convention every row keeps

**EVERY E-BLOCKED AND OWED ROW CITES THE DESIGN LINE ITS REASON RESTS ON**, in
`Tools/check_citations.py`'s own checkable form: one `` `source:line` `` and one verbatim
*"quote"* on the same line, so the checker can reach it. The ledgers are in its `DOCS` list
as of 2026-08-29 and were outside its reach for the whole build before that.

**WHY, and it is not tidiness.** A row's VERDICT can be right while its REASON is wrong, and
nothing checked reasons. Row **E-V** was correctly blocked and incorrectly explained: it said
`reflect(−1)` needed a pane turned past 90°, when `world-five.js:120` runs the partner at
`π − a` — *"its partner across the line is its reflection, and a reflection never shows the
same face"* — so the sign comes from the PAIRING and no turn was ever required. That was
caught by re-reading the constants, not by any tool. **Reasons in ledgers drift exactly as
citations in prose do**, and this build has now found four instances of documentation drift
and had zero mechanisms aimed at the ledgers themselves.

A row whose reason cannot be cited is a row whose reason has not been checked.

### VOID · the third verdict, and it is not the same property as null-shapedness

**A row can be failed by a mis-run.** Ashrey gets ONE walk, so a run whose precondition was
never established, recorded as FAILED, sends the next session after a bug that is not there —
or worse, to "fix" correct code. So every row whose close depends on a precondition the walker
might not establish carries **VOID** as a third verdict, with what must be evidenced to tell a
void run from a real failure.

**THIS IS A DIFFERENT PROPERTY FROM ⚠ NULL-SHAPED, and is audited separately.** Null-shaped is
about the OBSERVATION being ambiguous — a defect and its fix look the same. VOID is about the
SETUP being unverifiable — the observation is clear, and it is an observation of the wrong
run. A row can carry both, one, or neither. Rows carrying VOID are marked **⊘**.

---

# ⊘⊘ THE WALK GATE — evidence these BEFORE row one is judged

**Nothing below is a valid observation until this gate is passed.** It is not a property of
any row and does not belong distributed among them: if the walk simply begins, a dozen rows
fail correctly-but-falsely, and by the time anyone notices the pattern **the walk is spent.**
Ashrey gets one.

| # | Must be true | Evidence | What a correct app does if it is not |
|---|---|---|---|
| **G1** | **Reduce Motion is OFF** | Settings → Accessibility → Motion, seen off | `SoundEngine.swift:1285` `eventsSuppressed` gates `playCeremony`, `playAxis`, `carryTone` and `duckBreath`. **Every one-shot in the app is silent** — the bowl, all three thresholds, the blip, `om`, `glide`, `shimmer`, `arrive`, `send`, the Light's eight, the bed-duck. Only the bed remains, by design. |
| **G2** | **The sound is ON** | the Settings control reads `◉ sound`, not `⊙ sound` | `mainMixerNode.outputVolume` is 0. Total silence, correctly, and it persists across launches. |
| **G3** | **The silent switch is OFF** | the ring/silent switch seen unmuted | `configureSession` sets `.ambient` deliberately — *"silent-switch honored; the field never imposes."* A silenced phone silences the whole layer, correctly. |
| **G4** | **No other audio is playing** | nothing else sounding | the session is `.mixWithOthers`, also deliberate. Another app's audio masks a 0.032 threshold entirely. |
| **G5** | **Headphones, if used, are DETECTED** | `isOnHeadphones` observed true — the binaural pair audibly wide | the pair collapses to a centred tone, correctly. A pair that connects without being recognised looks exactly like a broken binaural pair. |
| **G6** | **Display Zoom is STANDARD** | Settings → Display → View, seen as Standard | the logical point size changes, so **B5's eleven-row Karishma table is measured against different numbers** and reads as wrong while being right. §5's table is specified at W 393 · H 852. |
| **G7** | **Low Power Mode is OFF** | the battery indicator not yellow | timers and animation throttle. Every gate in this build is time-based — world III's 0.42/s, IV's press, VI's `DUR`, VII's `GATE` — so a throttled run reaches fewer gates in the same wall-clock hold and looks like a build that gives too slowly. |
| **G8** | **The app was NOT cold-launched mid-walk** | one continuous session, and it is stated | every static registry starts empty: `PointReturn`, `PointDance`, `PointChamber.struck`, `PointGoodnight.shown`, `MirrorHall.backAt`. A relaunch legitimately voids O9, O19 and O22 at once. |

**If any of G1–G8 cannot be evidenced, the affected rows are VOID, not FAILED.**

### What made each of these a gate — for whoever adds the next one

A setting is not a gate because it is a setting. **It is a gate when it changes what a
CORRECT app does, globally, in a way the observation itself cannot reveal.** Each of the eight
qualified for a different reason, and the reasons are the useful part:

- **G1, G2, G3, G4** — a single switch silences a WHOLE LAYER. One cause, a dozen failures.
- **G5** — the failure is *indistinguishable from the defect*: an undetected pair collapses
  the binaural exactly as a broken pair would.
- **G6** — it moves the RULER. B5 is closed by a measured table, and Display Zoom changes the
  numbers that table is written in.
- **G7 · the one that was not obvious, and the reason it matters most.** **Every gate in this
  build is TIME-based** — world III's `open += dt·0.42`, IV's `press += dt·(0.30 + load·0.26)`,
  VI's `DUR [3.2, 5.4, 8.0, 11.2]`, VII's `GATE [1.5, 3.3, 5.5, 8.1]`, D's five decay rates.
  Low Power Mode throttles timers and animation, so **it does not spoil one row: it mis-reads
  the entire gesture layer as too slow.** Every hold appears to give fewer sections than it
  should, in every world at once — and *"the gates are too slow"* is a plausible, wrong, and
  very expensive conclusion. **The property to look for: does this change the RATE at which
  anything progresses? If so it is a gate, because this build measures in seconds
  everywhere.**
- **G8** — it resets state the row depends on having accumulated.

---

## 0b · The category this gate belongs to: **a defect in the ABILITY TO OBSERVE**

Everything the audit has found so far — all ten shapes in `CLAUDE.md` §10 — is a defect **in
the code**. This is a different kind: a defect **in the walk**. The build is correct, the
observation is clear, and the observation is of a run that could never have shown the thing.

It has its own tell, and it is the one that makes it dangerous: **it produces a PATTERN of
failures rather than one.** A dozen sound rows failing together is not a dozen bugs; it is one
switch. So the standing rule is: **when several unrelated rows fail the same way, suspect the
gate before the code** — and audit for anything global that changes what a correct app does
before the walk is designed, not after it is spent.

Audited 2026-08-29; G1–G8 above are the result. Anything added to this build that reads an
accessibility setting, a session category, a power state or a display scale earns a row here.

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

Audited across all sixteen rows: **five** carried the property at the time of writing, and
**O19 later made six** — found in a new place, where the ambiguity is not between a defect and
its fix but between a defect and **correct behaviour under a different precondition**. A row
like that can be *failed by a correct build*, which is worse than being unclosable: it needs a
precondition the walk establishes before the observation counts, and a **VOID** verdict for
when it cannot. They are O9, O11, O12, O14, O16 and O19 — and the reason four of the five are in the sound layer is that silence is the medium's
own null. **A visual defect usually looks like something; an audio one usually looks like
nothing.**

---

## 1 · The three that need ears, and only ears

`7-STATE-OF-THE-BUILD.md` §5 names these as the only judgement calls in the sound layer.
Everything else about the sound is a number and is measured.

| # | What must be true | Why offline cannot reach it | What the walk must show | Stage |
|---|---|---|---|---|
| O1 | **Mix balance.** Every event sits under the bed without disappearing into it. | A rendered peak is a number; whether 0.032 is audible under a 0.12 bed at listening volume is a judgement. | Each of the four strike voices identified by ear on its own surface — bowl, field threshold, spine threshold, blip — and none of them either startling or inaudible. **⊘ VOID** on the walk gate — G1, G2, G3, G4. | A/B1 |
| O2 | **Reverb character.** The field's 3.6s room and the Point's 7.5s cathedral read as two different spaces. | `AVAudioUnitReverb` presets cannot be compared to a WebAudio convolver by rendering; the tail is the thing and it is subjective. | Crossing from a Room into the Point and back, and hearing the room change. | A2 |
| O3 ⊘ | **Headphone routing.** The binaural pair reads as width on headphones and collapses honestly on speakers. | The simulator reports no headphones, so `routeState` is false by construction and the pair never renders. | Both routes walked, and the Point's beat heard narrowing on headphones only. **⊘ VOID** on gate G5 — a pair that connects without being recognised collapses the binaural pair correctly, which is the same observation as the pair being broken. | A1 |

---

## 2 · Gestures — a drag no render can perform

Every one of these is a range a law assumes. The **law** is measured; the **arithmetic** is
measured; that a real finger reaches the range is not.

| # | What must be true | Why offline cannot reach it | What the walk must show | Stage |
|---|---|---|---|---|
| O4 ⊘ | World III's `part` reaches 1 under a real drag. | `unveil`'s cutoff is `340·58^f`; at `f = 0.6` the veil is still shut. A test can assert the curve, not the finger. | The veil fully parted, and the register audibly opening as it does. **⊘ VOID unless** the veil is seen FULLY open first — at `f = 0.6` the cutoff is still shut, so a short drag correctly sounds like nothing happened. | C1 |
| O5 ⊘ | World IV's `panX` spans its `W·1.7` spread. | `bear(f)` is `f·13` dB; a half-travel pan is 6 dB and reads as nothing. | The wall pressed to its limit, and the room ringing under it. **⊘ VOID unless** the pan is seen at its travel limit — a half-travel press is 6 dB and correctly reads as nothing. | C1 |
| O6 ⊘ | World VI's `settle` bottoms out at `H·0.7`. | `distance(f)` drives the delay to `0.30 + f·1.35`; a partial settle never lengthens the room. | Settling to the floor of the strata, and the room getting longer as it happens. **⊘ VOID unless** the strata are seen bottomed out — a partial settle correctly never lengthens the room. | C1 |
| O7 | World I's `dwell` and world II's `drawingId` release when the hand comes off. | SwiftUI gesture lifecycle; `onEnded` does not fire under a synthetic drag. §10's own **CLAIM IS RELEASED BY EVERY PATH** entry is about exactly this failure mode. | Each world left by every exit — completing, dismissing, backing out mid-gesture — and the close running each time. | D |
| O8 | The four closing words appear, at the right moment, for their own duration. | The scalar is asserted; that `WorldCue` renders it at `H−150` and fades over `1/rate` is a view claim. | All four read on screen: I 1.11s, III 1.25s, IV 1.25s, and V's now that world V holds its panes. **⊘ VOID unless** something was actually HELD before releasing — `release(held:)` correctly closes nothing that was never held, so a tap produces no closing word and that is right. | D |

---

## 3 · Behaviour that only a running engine has

| # | What must be true | Why offline cannot reach it | What the walk must show | Stage |
|---|---|---|---|---|
| O9 ⚠⊘ | **`darkReturns` restores the bed over 7s.** You do not leave the Light quieter than you found it. | `field-sound.js:314` — *"walking back out — the dark returns, and with it the breathing"*. The ramp lives on `AVAudioEngine` state with no source node to render; there is no assertion for it at all. **Verified BY READING only.** | **NULL-SHAPED:** a working restore and a broken one both sound like "the field is there." Positive condition: enter and leave the Light **three times in one session** and the field is *the same loudness on the third pass as on the first*. The defect was cumulative, so a single trip cannot distinguish them. **⊘ VOID unless all three trips are in ONE uninterrupted session** — a relaunch between them restores the bed legitimately and hides exactly the defect being looked for. | B3 |
| O10 | **The mute is a 1.4s fade, and a muted launch is silent from the first buffer.** | `mainMixerNode.outputVolume` on a live graph. The state and its persistence are measured; the fade is not. | `⊙ sound` toggled and the field riding down rather than cutting; the app relaunched muted and silent before anything appears. | B2 |
| O11 ⚠ | **The guard star's `nul` is heard as cancellation, not as omission.** | `spine-sound.js:167` — *"the voice summed against itself, which is exact"*. The §10 EIGHTH SHAPE in its purest form: defect and fix both render as silence. | **NULL-SHAPED, and the archetype.** Positive condition: the guard star opened in world V and **the bed heard STOPPING** — a drop into nothing while the room's reverb tail keeps decaying over it — and then **the bed heard COMING BACK** after ~4.4s. Two transitions, both audible. **"Nothing happened" is the failure report, not the pass.** | C1 |
| O12 ⚠⊘ | **The bed-duck under the bowl.** `duckBreath` takes the bed to a fifth and returns it over 9s. | `crossfadeLevel` on a live voice; the ratio is MEASURED, the ramp is not. | **NULL-SHAPED:** a duck that never fires and a duck that works both leave "a bowl over a bed." Positive condition: with the bed clearly audible first, strike a bowl and hear the bed **step back within 1.2s** and **come home by 9s** — the return is the half that proves it fired, since a missing duck also has no return. **⊘ VOID unless the bed is audible BEFORE the strike** — over an inaudible bed there is nothing to duck and nothing to hear return. | B1 |
| O13 ⊘ | **The twelve repointed sites sound like four different things.** | The voices are measured apart; that the *right* voice is at the *right* moment is a walk. | The Rite's three movements, the Return's cross, the Universe's three, the axis crossing, the two Door crossings, the Light's blip, and the Point's OM — each identified as its own event. **⊘ VOID** on the walk gate — G1 alone would record twelve failures here against a correct build, which is the pattern the gate exists to prevent. | Coverage/9 |
| ~~O15~~ | ~~`resolve` is heard as nine becoming one~~ | **WITHDRAWN — it has no caller, so no walk can reach it.** Rule 1: if the blocker is code, it is not OWED. `resolve` is built and MEASURED and fires from nowhere; §7 refiles it as an axis row awaiting a decision. It returns to this band the day something calls it. | Stage G |
| O17 ⊘ | **World III gives while the hand is held.** | `world-three.js:95` — *"he is holding it open. Sections arrive while he holds, and only while."* The gate arithmetic is ARITHMETIC and the timings are asserted; that a real finger holds past 1.43s, and that `onChanged` fires continuously under a stationary finger rather than only on movement, is a walk. | The veil parted and **held without moving**, and all four sections arriving in one contact — at roughly 0s, 0.43s, 0.95s and 1.43s. A single give under a long hold means `onChanged` is not firing while still, and the reversal is back by another route. **⊘ VOID unless the hand stayed down for at least 1.5s** — releasing early correctly gives fewer than four, which is the design, not the bug. | E3 |
| O20 | **World VII's hand reaches the floor.** | `world-seven.js:262` — *"The nearest free body takes his offered hand."* The figure, the join radii and the dissolve are ARITHMETIC; that a real touch lands inside 0.19 of a body in the app's own coordinates, and that a drag reads as one continuous hold rather than a series, is a walk. | A hand offered and **held still** while a body crosses to it; then **four more joining** over about eight seconds; then letting go and **hearing the chord come apart** — the dancers fading, not cutting. | E1 |
| O21 | **World II's spanda travels down all nine arms at once, and the split is visible.** | `world-two.js:26` — *"every pulse travels visibly down all nine arms at once."* The shared clock and the split's curve are ARITHMETIC; that nine arms are drawn, that a pulse is seen moving out along all of them together, and that white-at-the-centre reads as white are a walk. | Watch one breath: **the pulse leaves the centre on every arm simultaneously**, and the light is white where they meet and each arm's own colour at the rim. If a pulse runs down one arm ahead of another, the one clock has become nine. | E4 |
| O22 | **World IV's impression is visible on the wall after leaving.** | `world-four.js:72` — *"what has already been struck into the wall — it stays"* That `struck` survives is ARITHMETIC; that the wall DRAWS what it carries, and that the drawing survives a leave, is a walk. | Press a niche to its second gate, **leave the register entirely**, come back, and find the impression still cut at the same depth while the reading has restarted from nothing. | E5 |
| O23 ⚠⊘ | **The room lengthens while something is away, and dries when it is home.** | `spine-sound.js:179` — *"the same note, arriving late"*. `distance`'s range and the delay's parameters are MEASURED; that the room is heard changing is a judgement, and it is the only audible proof the delay line A2 built is in the signal path at all. | **NULL-SHAPED:** a delay that never opens and one that is not wired both sound dry. Positive condition: send a lap and hear **the room get longer**, then hear it **dry again** as the lap comes home — both transitions, not the end state. **⊘ VOID** on gate G1: `send` and `arrive` are one-shots and Reduce Motion silences them. | E2 |
| O24 | **A sealed return is answered by a voice, and the tally says so.** | `The Return.html:277` — *"one on the story, "*. The tally is ARITHMETIC; that the base actually HOLDS `Return Answer` rows for a ring is content, not code — and answers are `authored · for approval`, so an unanswered story is a correct state, not a defect. | Seal a return on a story the base has answers for, and read **"where this lands · the room, register 2"** naming at least one voice with a total above one. On a story with no authored answers the correct reading is *"no voice has spoken twice here yet"* — **that is a PASS, not a failure**, and the two must not be confused. | F1 |
| O25 ⚠ | **The Return opens on the aged bed, and a ring forms rather than strikes.** | `field-sound.js:74` — *"patina — the same bed, aged. The Return opens here."* The pitches and the envelope are MEASURED; that the crossfade from the field's bed is heard as the same room grown older, rather than as a different room, is a judgement. | **NULL-SHAPED:** an aged bed that never crossfades and one that does both sound like "a bed". Positive condition: enter the Return **from the Feed** and hear the ground **drop and settle** as it opens; then seal, and hear the ring **grow over three seconds** with the bowl landing inside it — not a strike followed by nothing. | F2 |
| O19 ⚠ | **A lap really does survive leaving the register on a device.** | `world-six.js:101` — *"leaving the register closes the reading. It does not cancel a lap"*. The registry is ARITHMETIC and proves the arithmetic cannot lose a lap; that the APP was **alive across the interval** — not relaunched, not purged, not jetsammed — is a walk. | **NULL-SHAPED, AND IN A NEW PLACE: a correct cold-launch empty and a broken registry produce the SAME observation — an arc that did not come home.** So the walk must establish liveness FIRST, or the row can be failed by correct behaviour, which is worse than being unclosable. Close condition, in this order: **(1)** send a lap and note the time; **(2)** leave the Point but **stay inside the app** — the Feed, a Room, anywhere with a visible surface — and **do something that proves the process lived**, e.g. scroll a feed that was not loaded before, so the evidence is a state change only a running app could make; **(3)** return after the duration and find it home. **If step 2 cannot be evidenced, the run is VOID, not failed.** A relaunch, a backgrounded eviction or an OS kill all legitimately empty the registry and none of them says anything about E2. | E2 |
| O18 | **World V's pane turns under a real drag, and carries through edge-on.** | `world-five.js:142` — *"far enough that carrying a face through edge-on is a real act of the hand"*. The angle arithmetic is ARITHMETIC; that a drag across three quarters of the shell reaches π, and that `onChanged` tracks a continuous carry rather than jumping, is a walk. | A pane **held and carried a half turn**, and the second tone heard going to nothing at edge-on and coming back inverted on the other side — three states in one gesture, not two. | E |
| O16 ⚠⊘ | **The descent and the ascent glide, and the aperture shimmers.** | The curves are MEASURED; that each fires at the right transition, at the right enclosure, is a walk. | **NULL-SHAPED in one direction:** the ascent's glide ends where the descent began, so a glide that never fires and one that fires twice both leave you "back where you started." Positive condition: **descend and ascend from two DIFFERENT enclosures** and hear two different pitches fall and rise — one pair alone cannot show the enclosure is being read. **⊘ VOID unless the two enclosures are confirmed DIFFERENT** — `PointYantra.shared.focus` decides the pitch, and two descents at the same focus correctly sound identical. | C3 |
| O14 ⚠ | **The delay line is inaudible until something is away.** | `spine-sound.js:52` — *"It is built once and sits silent until something is actually away."* That nothing leaks in before `distance` opens is a graph claim on a running engine. | **NULL-SHAPED — and it is the one row here whose pass condition IS an absence**, which is why it needs its opposite attached. Positive condition: world VI entered and **the room dry**, then `settle` taken to the floor and **the room heard lengthening**, then released and **heard drying again**. A delay that never opens and a delay that is not wired both sound dry; only the lengthening tells them apart. | A2 |

**The other eleven are not null-shaped**, and the reason is worth stating: each has a
positive observable that a broken build cannot produce. O1 names four distinct voices; O2 is
two rooms that must differ; O4–O7 are ranges a gesture must reach; O8 is four sentences that
must appear on screen; O10 is a fade with a direction; O13 is twelve events that must be
distinguishable from each other; O15 is a chord collapsing. None of them can be satisfied by
nothing changing.

---

## 3b · NOT OWED, NOT BROKEN — **MECHANISM WHOLE, CONTENT A SEPARATE ACT**

A third thing that is neither MEASURED nor OWED nor E-BLOCKED, and it has now been mistaken
for incompleteness **twice** — both times it was the design being honest.

**The app can be complete and show nothing**, because the content is an authoring act that has
not happened. A walk that meets one of these reads a working surface as a broken one, and
"fixes" it by inventing what the design deliberately left for a person to write.

| # | The mechanism | Why an empty surface is CORRECT |
|---|---|---|
| **M1** | **`renderAnswers` · a sealed return is answered** | `The Return.html:264` marks every answer *"authored · for approval"*. They are written by a person and held in the base as `Return Answer` rows. **The app renders what the base holds and invents nothing.** A story with no authored answers correctly reads *"no voice has spoken twice here yet"* — which is also, exactly, what a broken Return would show. **On the walk that is a PASS.** The mechanism is proven by `ReturnAnswerTests`, not by the screen. |
| **M2** | **The Light's six scenes** | `canon/spine-light.js:97` — *"Six scenes, one family."* Six is the canon's NUMBER, not a shortfall; `7-STATE-OF-THE-BUILD.md` §4 already records this after it was read as a gap once. A seventh would be invented content. |

**THE TELL THEY SHARE:** the design says, in its own words, that the content is someone's to
write — *"authored · for approval"*, *"one family"*. **Where the design names the content as an
act, an empty surface is the mechanism working.** Before filing an empty surface as a defect,
look for that sentence.

---

## 4 · NOT OWED — E-BLOCKED

Built, measured, and with nothing to drive them. **These are not waiting on a walk. They are
waiting on a build**, and carrying them in the OWED band would mean a final walk that cannot
close them.

**RULE 1 applied:** every row here fails the *"what would have to change"* test with the
answer *a commit*. None can be closed by any walk, and none may migrate into the tables above
until the build that unblocks it lands — at which point it becomes an ordinary OWED row.

| # | The sound | What is missing | Stage |
| — | *(E-V closed; struck through below, kept for the correction it carries)* | | |
|---|---|---|---|
| ~~E-V~~ | ~~`reflect(−1)` and world V's `settling` close~~ | **CLOSED 2026-08-29.** World V holds its panes: `ga[grp]`, `angleOf`, `facing()`, `spin`, `release`. One change, both consequences, as recorded. **AND THE REASON RECORDED HERE WAS WRONG** — `reflect(−1)` never needed a pane past 90°. `angleOf` runs the partner at **π − a**, so `cos(π − a) = −cos(a)` and the two panes of a pair are ALWAYS opposite; at rest one of them is already at ≈ −1. The negative half was a consequence of the pairing, not of the rotation range, and the only thing missing was `held`. See `MirrorPaneTests`. | ~~E~~ |
| ~~E1~~ | ~~`join` · `ensemble` · `leaveAll` · `DancerVoice`~~ | **CLOSED 2026-08-29.** `world-seven.js:117` — *"bodies dancing with him, in the order they joined"*. `PointDance` holds the floor, the hand, the chain and the Kuramoto lock; `ReadCompany` offers, moves and lets go. **C1's four voices were wired in the SAME pass, not filed behind it** — an undriven voice waiting on a mechanic that has just landed is exactly how the design's own four uncalled mechanisms happened. `join` per body at its own harmonic, `ensemble(lock:)` closing the detune as they come into time, `leaveAll` on letting go. | ~~E1~~ |
| ~~E2~~ | ~~`send` · `arrive` · `arriveAll`~~ | **CLOSED 2026-08-29, registry AND sounds.** `PointReturn` holds `arcs`/`trails`/`got`/`pending` on a wall clock outside every view: an arc launched and abandoned still arrives, and an hour away lands everything that was due, in order. `world-six.js:101` — *"leaving the register closes the reading. It does not cancel a lap"*. The three sounds are wired at the same call sites: `send` on the departure with the arc's own pan, `arrive(n:)` per lap and `arriveAll` for Deep Time's four at once, and `distance(f)` following what is actually away — *"when everything is home the world is dry again."* | ~~E2~~ |

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

## 7 · `resolve` — AN AXIS-SIDE ROW. Filed here so it is not looked for in the Point.

**Stage: the axis (plan Stage G), NOT Stage C.** `resolve` was found while building the
Point's sound and every instinct filed it there; the mapping put it on the axis instead, and
a row filed under the wrong surface is found in the wrong stage or not at all. The three
proofs below are why, and they are the same discipline as `riteThreshold`: **the mapping
proved the guess wrong.**

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
this here" are different claims and only the second is a caller.

**WHERE IT NOW LIVES.** An axis row, alongside the plan's Stage G axis work — the passage's
`swift`/`hit`/`dur`/`after`, the shader's pinned uniforms, `#trav`. Not a Point row, not a
Stage C row, and not OWED: it is not waiting on a walk, it is waiting on a decision about
whether the axis's z = 9 crossing takes a voice of its own. **`InstrumentView.swift:290`'s
`spineThreshold(hz: reg.hz)` is the line that would change**, and it is the only one.

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
