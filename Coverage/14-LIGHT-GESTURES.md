# 14 · THE LIGHT'S SEVENTY GESTURES — the Wave 2 ruling

*Written 2026-09-21, against the base as it stands after the arrival pass.*

**This is a ruling, not a build list.** It says, for each of the seventy scenes, whether its
`GESTURE:` can be built on primitives this app already has — and where it cannot, what exactly
is missing and whether the missing thing is a sensor, a ruling, or authored content. Design
draws nothing until this is settled, and nothing here is implemented by it.

---

## The two axes, and why this document exists at all

The authoring pass wrote one axis and not the other, which cost a whole release cycle:

| | |
|---|---|
| **`ARRIVAL:`** | the VISUAL WASH — a closed set of seven, reused across many scenes. Added by the arrival pass; the app reads it. E1.15. |
| **`GESTURE:`** | the PHYSICAL INTERACTION — what the hand or body does. **Unique per scene by design**, and therefore never capable of satisfying a closed vocabulary. **This document's subject.** |

Reading the wash off `GESTURE:` parsed 0 of 70 and every scene fell back to `.stillness`. That
is recorded at `Coverage/1-AUDIT-254.md` E1.15 and in `LightSceneParser`. The lesson that
matters here: **`GESTURE:` is prose describing an interaction, not a token.** Nothing mechanical
will ever consume it. It is consumed by a person making a ruling, which is this file.

---

## The method — THE VERB TEST

§10 already carries it, from the seven Point worlds: **name what the surface's gesture IS — a
verb — and ask whether the app can perform it.** That sweep found four of seven worlds opening
on `.onTapGesture` when their subject was duration, direction or release, and it was one default
applied where no default fits rather than four separate lapses.

Applied here the same way, with one addition: where the verb cannot be performed, this file says
**which of four things is missing** — a sensor, a ruling, authored content, or another wave.

---

## What the app can already sense

Measured, with sites, so a reader can check rather than trust:

| primitive | where |
|---|---|
| touch-absence / idle accumulation | `LightView:661` — `Date().timeIntervalSince(lastInput)` |
| the 16ms / 60Hz hold loop | `LightView.startSceneTick`; §9 records it as the idiom for hold gestures |
| breath phase and breath-cycle gating | `LightView:672-674`; `Breath` is launch-anchored and app-wide |
| **the ungrip** | `LightView:648-650` + `ungrips` at `:50,750` — **the only place in the app that senses a hand OPENING** |
| two-stage arm-then-commit | `LightView.choosingBody`; §10 records it as the affordance for choosing among unlabelled things |
| drag direction, distance, velocity | `DragGesture` throughout; `simultaneousGesture` composed at 3 sites |
| hour-of-day, in six bands | `InstrumentView:1113-1116` — `hourWarm` |
| local day-keys | `AirtableService.dayFormatter(timeZone:)`, §9, §10 |
| days-since age | `ReturnRing.days(since:)` — age from days, never rank |

## What it has never had — measured 2026-09-21, zero files each

`CoreMotion` · `CMMotionManager` · `UIDeviceOrientation` · `userDidTakeScreenshot` ·
`isProximityMonitoringEnabled` · `SFSpeechRecognizer` · `MagnificationGesture` ·
`RotationGesture` · `isMeteringEnabled`.

**AND ONE CORRECTION TO A CLAIM THIS PROJECT HAS BEEN REPEATING.** The earlier planning note
said orientation is unavailable because the app is portrait-pinned and *"events are not
delivered"*. `Info.plist:35-38` does pin the interface to `UIInterfaceOrientationPortrait`, and
that is worth keeping — **but it pins the INTERFACE, not the READING.** Device attitude comes
from Core Motion and is entirely unaffected by the orientation lock. The scenes below do not
want the screen to rotate; they want to know how the phone is being held, which is a different
question and an available one.

**Nor does it cost a permission prompt.** Accelerometer, gyroscope and device-motion through
`CMMotionManager` are not privacy-gated on iOS; `NSMotionUsageDescription` is required for
`CMMotionActivityManager` and `CMPedometer` — motion *activity*, not motion. **That distinction
decides two rows below** (725 · 729), and it should be confirmed once on device rather than
taken from this paragraph.

---

## THE RULING — all seventy, by what they need

Counts are computed from `Coverage/14-LIGHT-GESTURES.tsv`, not asserted.

| verdict | n | meaning |
|---|---|---|
| **NOW** | **43** | buildable on primitives that already exist |
| **RULE** | **8** | a decision is owed before anyone can build it |
| **MOTION** | **4** | Core Motion attitude; no permission prompt |
| **API** | **3** | a system API the app has not used; no permission prompt |
| **BREATH** | **2** | needs the breath ruling below |
| **PRESSURE** | **2** | wants a force the SwiftUI touch pipeline does not carry |
| **CONTENT** | **2** | the mechanism is easy; the writing is owed |
| **WAVE3** | **2** | needs the typed surface Wave 3 builds |
| **WAVE5** | **2** | needs derived accretion |
| **MOTION+** | **1** | Core Motion *and* an audio-session ruling |
| **RULED** | **1** | `hours`, settled 2026-09-20 |

**Sixty-one of seventy need no new sensing at all** (NOW + RULE + CONTENT + WAVE3 + WAVE5 +
BREATH + RULED), and the single largest group is buildable today. **The Light is not blocked on
hardware.** It is blocked on eight rulings and two later waves.

### NOW · 43 scenes

707 reach · 708 before · 710 agreement · 715 forgetting · 716 inception · 719 insight ·
720 intuition · 721 invention · 723 innocence · 726 pulse · 727 hands · 728 echo ·
731 vishuddha · 733 wrong · 735 three · 736 two · 738 regression · 739 correspondence ·
741 wound · 742 son · 745 seva · 746 flow · 747 absence · 748 repair · 749 gate ·
750 doorway · 751 ledger · 752 unsent · 753 projection · 756 shadow · 757 armin · 758 maya ·
759 aatma · 760 gaia · 761 hole · 762 descend · 763 lit · 766 accomplished · 767 hold ·
768 paradox · 773 dissolution · 774 visible · 775 we

**Eleven of these are mechanisms implemented as their own ABSENCE**, which §10 records as the
EIGHTH SHAPE and the hardest class to verify — *it renders as restraint*: 721 · 723 · 726 · 731 ·
741 · 749 · 751 · 752 · 758 · 766, and 710 in part. **The test §10 demands is "nothing instead
of WHAT", and every one of them must answer it.** 741 `wound` — *"the scene never responds to
him"* — is the sharpest: nothing instead of the acknowledgement every other scene gives, and
**the scene must still progress on its own**, or a correct build is indistinguishable from a
broken one. 726 `pulse` says so in its own words: *"the only scene wholly indifferent to him,
and that is its kindness."*

**And 751 ledger is the deliberate counter-example to 737 ninth** — *"no memory of him at all…
nothing accumulates, ever"* against *"differs depending on how often he has stood in it."* They
are one claim stated twice, opposite ways, and building either without the other loses it.

### RULE · 8 scenes — the decisions owed

| | scene | the question |
|---|---|---|
| **713** | uncertainty | *"never the same twice — its anchors are drawn fresh at each visit."* **This collides head-on with the standing law that the remembering is never generated and exact wording is load-bearing.** It can only mean SELECTION from an authored pool, never generation — and that makes it a CONTENT row too: one scene's worth of anchors is not enough to be unrepeatable. **Rule the reading, then commission the pool.** |
| **714** | origin | *"the gyroscope is read and deliberately ignored: every direction shows the same thing."* If every direction shows the same thing, reading-then-ignoring and never-reading are **observationally identical** — so implementing it as absence is either exactly right or the eighth shape at its worst. The question is whether the scene acknowledges the ATTEMPT. |
| **725** | soles | *"grounds when he is upright and still; sitting or lying, it stays distant."* Standing-versus-sitting is activity classification, which prompts. Attitude-plus-stillness approximates it without prompting. **Approximate and record the divergence, or show the app's first-ever permission prompt.** |
| **729** | crow | *"lift the phone and the view widens… altitude is given by the arm."* True relative altitude is `CMAltimeter`, which prompts. Pitch is free and is not altitude. Same shape as 725. |
| **732** | lalita | *"it responds to the moment he realises it is responding, and it happens exactly once."* **Not knowable.** The nearest honest proxy is the moment his behaviour changes in answer to the scene's — he stops, right after it moves. That is a guess about an interior state and must be ruled, not assumed. |
| **734** | enough | *"requires him to physically leave… standing over it, watching, stops it."* Needs to distinguish *left* from *watching*, which is a face or a proximity question, not a motion one. |
| **770** | cost | *"two weights — felt rather than shown."* **Felt means haptics, and this app has deliberately never tapped his wrist** — `Coverage/10-OWED.md` N9 is an acceptance row asserting the Gathering does not. Giving the Light haptics is a change to the instrument's manners, not a scene detail. |
| **771** | red | *"opens only while nothing has been verified; any attempt to check first closes it."* What counts as checking — leaving the app, backgrounding, a screenshot? Each is buildable; they are different scenes. |

### MOTION · 4 — Core Motion attitude, no prompt

**712** company (gravity — flat and face-up) · **717** intention (set down flat and released) ·
**730** anahata (yaw — the source behind, which moves when faced) · **740** surge (pitch — upright
along the body's axis).

One new dependency serves all four, and 725/729 too if they are ruled toward approximation.

### MOTION+ · 1

**711** unweighted — *"set the phone face down and it goes on in sound alone."* Face-down is
gravity. **The hard half is the audio:** §15 fixes `AVAudioSession` to `.ambient` +
`.mixWithOthers`, **foreground only**, and the Breath stops on backgrounding by decision. A scene
that continues in sound with the screen away needs that decision revisited, and it is a decision
about the whole app's manners rather than about this scene.

### API · 3 — available, unused, no prompt

**744** telling — `UIApplication.userDidTakeScreenshotNotification`. *"It dims when captured…
nothing scolds; it simply will not be collected."*
**755** axis — the proximity sensor. *"Only changes while the screen is covered."*
**724** integration — two touch points as far apart as the screen allows. The deployment target
is **iOS 18**, so `SpatialEventGesture` gives real multi-touch positions; `MagnificationGesture`
would give magnitude only, which is not what the scene asks for.

### PRESSURE · 2 — the one thing genuinely out of reach

**722** incarnation (*"press hard and it resists; rest the finger with no force at all and it
opens"*) and **743** marriage (*"press too hard and it stops; let go entirely and it stops"*).
The SwiftUI touch pipeline carries no force and `UITouch` has 0 hits. A stillness-of-contact
proxy is available and is **a substitution, which §10 requires be recorded as one rather than
built quietly** — these two scenes are ABOUT force, so approximating it changes what they say.

### CONTENT · 2

**754** frequency — *"reads the real calendar and is genuinely different on a day that means
something."* The day-key exists; the days that mean something are unwritten.
**765** thirteenth — *"every element carries two readings at once."* Two authored readings per
element, and the scene must never resolve which was right.

### WAVE3 · 2 — the typed surface

**769** sovereign (*"whatever he names a thing, the scene keeps"*) and **772** askfor (*"it opens
on the asking"*) both need him to put words in. That is the same surface Wave 3 builds for the
recognition, and building it twice would be building it twice.

### WAVE5 · 2 — derived accretion

**737** ninth — *"the first scene written to differ depending on how often he has stood in it."*
**This is a COUNT, and the rule is absolute: derive, never store.** `FeedStore:956` forbids
counters and §10 records that a stored counter eventually asks to be raised. The source is the
`Veil Lifted` pulses, which have carried the scene's record id since `dd8045d` — **so the
history 737 needs is already accumulating.**
**764** empty — *"an empty day rendered with exactly the same attention as a full one"* needs to
know a day was empty, which is the same derivation read the other way.

### RULED · 1

**776** hours — the stated amount. Wall-clock, nothing pauses it, expiry while away returns him
to the landing already present, each entry its own amount, and **nothing may make it solemn.**
Recorded in full at `Coverage/15-HOURS.md`. **The amount itself is still unwritten** and is the
one authored value that scene cannot be built without.

---

## What this document deliberately does not do

- **It does not design anything.** Every row says what is possible and what is owed; none says
  what it should look like.
- **It does not rank the scenes.** Sort order is the base's, not a priority.
- **It does not approximate a single gesture into buildability.** Where a scene asks for
  something the app cannot do, that is recorded as a RULE or a PRESSURE row rather than quietly
  softened into the nearest available verb — which is the fault §10 records as *words on an
  invented trigger*, one level up.
