# Form 03 · Gesture, motion, time and sound-in-motion — the padakarshini lens

*Form pass, 12 Oct 2026, evening. One of five lenses (FORM-BRIEF). The whole house after W0–W8 as scored, read through padakarshini: G0–G50, forms A1–A14 and B1–B4, the ceremony grammar (forms.md §D), the seven forms of time (§E), GRACE, MOVES, CORRIDOR, the elements and both lineage files. Read against: CONTRACT, GAMEPLAN, the nine scores, `Bindu Feed/CLAUDE.md` §1–§9 (§10 headings and the rules on instruction strings and the two-stage touch), the Swift tree at `b120115`, readers 01/02/13/14/21, READINESS-REVIEW, DECISIONS, STATUS.*

*Swift paths are relative to `Bindu Feed/Bindu Feed/`. "§" means a score section unless stated otherwise. Durations are in seconds unless marked ms. "G0 a/b" means a G0 hold: up a s, drain b s.*

---

## 0 · In one breath

The nine scores each build their own pieces well. Put together, the house gains about **45 new gesture placements**, about **15 new physical gesture forms** and about **30 new stillness twins**. Today it has about **22 different hold lengths** and **16 different stillness thresholds**, and nothing yet decides between them.

Five problems need fixing before the build starts:

1. **Collisions inside one zone.** These are not collisions between registers. The space below a story's last line now holds eleven stillness clocks, two holds and the rope. The river's two gutters each hold two gestures that cannot share the space. The Book's trailing 18 pt holds three.
2. **One gesture, two behaviours.** The rope opens while the finger is still down on the Door and the axis, but acts on release in the story page and the river. "Keep" names four different acts. Rising-and-fading means *kept* in the Gates and *let go* in the Unwinding.
3. **Stillness chains that write.** A phone left face-up on a table can cross the Door, run the Rite, seal it wordlessly and write `Story Met`. That breaks the truth floor and padakarshini law 15: *readiness may be sensed; crossing is chosen*.
4. **The Turn breaks.** "WHERE TO" was designed for 8 rows that close on any pointerdown. It grows to 24 rows that have to scroll. Its only one-handed opener on the river, the pull-down, is taken by W6's edge-lean.
5. **No discovery design.** The house forbids tutorials, and only W3's GuideVoice addresses how a gesture reveals itself. Most new gestures have no visible affordance and no first hint.

**Three emergent proposals** carry the rest of this file:

- **The exhale queue.** Every stillness twin on a surface resolves one per exhale, on the house's own breath clock (`Breath.exhaleDelay`).
- **The lean.** Every gesture's stillness twin begins by performing a fifth of the gesture itself, so the house teaches by playing slowly. The lean withdraws once his hand has done the gesture, and comes back after FORGET ME.
- **One motion system.** Four durations by meaning, five easing curves with named owners, one dissolve and two camera moves, with Reduce Motion built into the tokens so no view can forget it.

---

## 1 · First principles (the laws the whole house's motion should obey)

| # | Law | Why (source) |
|---|---|---|
| P1 | **How you touch a thing is the teaching.** Each place has one gesture whose shape is its meaning. | padakarshini law 1; GAMEPLAN §2 law 9. A gesture chosen for convenience teaches nothing. |
| P2 | **A press means what the thing pressed is.** The object owns its press: text → keep, a card → lift, a star → thread, empty ground → rest (the rope). | W0 §4.1 collision 3 generalised; `PressClaim`. Collisions resolve by target, never by timing alone. |
| P3 | **A hold is the hold it was designed to be, on one engine.** It rises while held and drains on early release. It never fails. The *visual* and the haptic latch commit at the threshold; **sound, writes and navigation wait for the lift**. | G0; W0 §3; GAMEPLAN law 8. "Act on release" includes audio. |
| P4 | **Durations come from meaning, not taste.** A new hold takes the length of its meaning's family. An existing designed hold keeps its own length. | G0 "choose by meaning"; the 3 Oct law. |
| P5 | **One gesture carries one register.** Vertical walks the axis, sideways is the place's own gesture, a full swipe is one step. | padakarshini law 8; G15 gearing. |
| P6 | **Stillness is an input, and it speaks on the exhale.** Words and completions that stillness brings arrive on the breath's out-phase, one at a time. | Law 10 ("a touch asks; the next exhale answers"); G36; `Breath.exhaleDelay`. |
| P7 | **Readiness may be sensed; crossing is chosen. Stillness never completes a write he did not touch.** Stillness may reveal, lean and carry *inside* a ceremony he has touched. It may not start one and seal it. | Law 15; law 13 ("nothing is staged to show that something happened"); the truth floor; G2's Approach ("after one touch"). |
| P8 | **Discovered, not instructed. The thing shows its hand.** No tutorial. One authored hint, once, then silence. Each gesture-only act shows a visible affordance at rest, and a lean while he is still. | Law 9; CLAUDE.md §10 ("the app says what the design says, where the design says it, once"); elements "No on-screen instructions". |
| P9 | **Every gesture has an equal path:** stillness, a VoiceOver action and a visible twin (a row or a control). A hidden gesture is never the only way. | GAMEPLAN law 7; CONTRACT §4; elements "Three gestures on one surface". |
| P10 | **Leaving is one gesture everywhere, never punished, and within one thumb's reach.** | Law 14; G38. Today, leaving lives only at the top-left, the hardest reach. |
| P11 | **Nothing slides. A change of place dissolves. Movement within one continuous place is a camera.** These are three idioms, never mixed except at a named hinge. | CLAUDE.md §4/§9; G44; G15; elements "the blink crossing". |
| P12 | **Reduce Motion keeps order, duration and holds. Only travel becomes opacity.** It is a property of the motion token, never of a view. | G0 reduced motion; CONTRACT §7; GAMEPLAN §9. |
| P13 | **Every place moves as what it is, and no two endings are alike.** A room is known by its tempo. Siblings, rhyme pairs and consecutive forms never end in the same gesture. | Law 16; GRACE rules 1–2; GAMEPLAN law 13. |
| P14 | **Sound answers the hand.** Each gesture has at most one answering sound, on the 110/136.1 roots for new sound. A falling-short is silence, never a failure tone. | Elements "Sounds that answer the hand"; CONTRACT §7. |
| P15 | **Haptics fire on acts of will, recede with depth, and come from one family:** a tick, or a ramp and a latch. | Elements "One haptic family"; G0 haptics. |

---

## 2 · The app today (main @ b120115), through this lens

### 2.1 What exists, by register (the gestures he already knows)

| Register | Gestures today | Source |
|---|---|---|
| Waking | none; the ember gathers over 1.65 s and leaves in 0.55 s | `Components/WakingView.swift` |
| Door (unmet / met) | tap anywhere crosses (unmet → Rite, met → the blink, `ContentCoordinator` lids 0.66 s) · long press 1.1 s fires the rope **at the threshold, finger still down** · slow pull ≥ 84 pt opens the Turn · the 2×2 dot mark (top-left) opens the Turn | `DoorView.swift:178-195`; elements "Three gestures on one surface" |
| Practice Door | tap anywhere to cross; Leela offer / hold in silence (taps) | `PracticeDoorView.swift` |
| River | scroll · card tap · pull-to-refresh · filter chips · sort switch · HubTrigger (top-left) | `RootView.swift` |
| Rooms | RoomSelection tap · GameView chevrons (0.28 s dissolve) · RoomView: vertical drag 240 pt = register, sideways = the voice's own gesture (11 kinds), tap a mark to arm | `Rooms/RoomView.swift:180`, `RoomFigures.swift:9-20` |
| Reception (13 grammars) | 13 hands, including peel `HoldPress 1.25`, tratak `HoldPress 2.6`, trace-in-the-dark, touch the seam, widen, pass on | `Reception/ReceptionView.swift`; `Reception.swift` |
| Story page | pinch / spread (essence ↔ memo) · rewind spiral 2.2 s · keep a line (long press 0.6 s) · resonance tap or 1.5 s hold · avatar tap → Turning · ∞ tap · signatures (cordCut drag, empty summit `onLongPress 1.2` firing at threshold) · Floor door 1.25 · Compose 2.3/0.62 · Hall `HoldEmber 1.4` · Read by hand (rest a finger, double-tap keeps) | `StoryDetailView.swift:118,393,522,790`; `SignatureViews.swift:251`; `HallView.swift:134`; `ReadByHandView.swift:106` |
| Turning | hold ∞ 2.9/0.75; words hidden until 55% (hold-only, no twin) | `TheTurningView.swift:304-392` |
| Ceremonies | Rite: tap per paragraph and per line, swipe right steps back, seal forward 1.6 · Return: consent, rings · Call: two fingers held 0.8 s; lay 2.6; go down 1.3 · Floor: go down `HoldEmber 1.25` ×3, carve 1.6 · Codex: hold to speak (capture while held), give `HoldEmber 1.4` · Present seal 1.6 · Gift appreciate 1.2 · Unwinding: lift > 160 pt / pinch < 0.42 / turn back 1.6π | `RiteGatheringView.swift:116`; `CallView.swift:153,237`; `MirrorFloorView.swift:78,174`; `CodexView.swift:108-116`; `UnwindingView.swift:100-120` |
| Axis | vertical lean through the membranes (G15) · rail rungs (tap) · stillness gate (4.6 s) into the Light · rope 1.1 s · Old Story (10 s still, after the Light gate only) | `InstrumentView.swift:377,558,578`; `AxisTravel.swift:484-515` |
| Sky / world / fall | pan · tap recentre or travel · pinch zoom · long press 0.6 s then drag = filament · shake · Khelo drag ≥ 20 pt (Holi) · fall: pull up, presences, mouth consent | `UniverseView.swift:195-236` |
| Point worlds | the seven reading verbs (stillness, follow, part, bear, mirrors, send-and-wait, dance) | `Point/PointReadings.swift`, `PointWorlds.swift` |
| Light | stillness gate · touch asks (exhale answers) · carve (scene length 0.9–4.2) · seal forward `HoldEmber 1.6` · eyes closed / face down · 14 `LightBody` scenes | `LightView.swift:357,547,654`; `Light/LightBody.swift` |
| Book / Weave | ArchiveBook horizontal drag turns a leaf (50 pt, 0.45 s per half) · BookView margin word 0.6 s · Weave drag to flip | `ArchiveBookView.swift:39`; `BookView.swift:83`; `WeaveView.swift:32` |

### 2.2 What works

- **The Door's single surface** (tap, slow pull, long press, plus a visible dot mark) is the house's best gesture design. It is the model for every crowded surface in §4.
- **Every hold already drains instead of failing**, even on three engines. The feel of "never a miss" is already in his hand.
- **Cross-dissolve everywhere, nothing slides.** The push and pop dissolve is 0.5 s `easeInOut` (`App/Navigation.swift:29-45`). Only the Door blinks.
- **One breath clock** (`Instrument/Breath.swift`): 0.1 Hz, launch-anchored, never restarted. It already has `exhaleDelay(fromPhase:)`, the primitive the exhale queue needs.
- **The Light's hands** are the richest place-by-gesture work in the house. W6 §8.2 completes all 55 remaining scenes.
- **The rope** is grace before it is earned, and it opens where the hand already is.

### 2.3 What does not work (today, before any wave)

1. **Three hold engines.** `HoldPress` (Task.sleep), `HoldEmber` (acts at the threshold and restarts from 0 on every press) and private loops in CallView, the Turning, Compose and Resonance. W0 §3 fixes this.
2. **Reduce Motion is honoured nowhere in the views.** The only check in the Swift tree is the sound engine (`SoundEngine.swift:1376`). Every score promises a Reduce Motion path per element, and a per-view promise will be forgotten (§4.2 makes it structural).
3. **Accessibility actions: two in the whole app** (`Reception.swift:239`, `SignatureViews.swift:254`). Every score adds them per element. The naming needs one vocabulary (§4.6).
4. **Leaving and the Turn sit at the top-left only** (back chevron, HubTrigger, the Door's dot mark, `‹ leave`). That is the hardest reach on a 6.1–6.3" phone held in the right hand. There is no edge-leave. G38 is in padakarshini and not in the app.
5. **Motion has no system.** About 40 different `easeInOut` durations appear across the tree (1.0 ×38, 1.2 ×28, 0.8 ×23, 1.4 ×18, …). CLAUDE.md §9 says room dissolves are 0.28 s; the route dissolve is 0.5 s. The scores add six cubic-béziers by hand.
6. **Discovery is already the known weak point.** CLAUDE.md §10 records that eight invented instruction strings were deleted while eighteen authored world cues were never built: *"five of seven Point worlds never told the hand what to do."* That shortfall comes before any new gesture is added.

---

## 3 · The app after W0–W8, as scored: the complete gesture inventory

**Columns:** gesture · register · hold (up/down, or the threshold) · what answers · stillness twin · VoiceOver · how it reveals itself without instruction (*rest* = a visible affordance at rest · *press* = the press preview, §4.4 · *lean* = self-demonstration in stillness · *cue* = an authored or GuideVoice line · *acc* = found by accident in normal use · **none** = cannot be discovered) · score.

**Bold** marks a collision or inconsistency, resolved in §3.11–§3.13 and §5.

### 3.1 Everywhere

| Gesture | Register | Hold / threshold | Answers | Stillness twin | VO | Reveals by | Score |
|---|---|---|---|---|---|---|---|
| Two fingers held | all | 0.8 s (UIKit) | the Call | rope → LAY IT DOWN → the Call | magic tap | **none** (learned; existing) | W0 §4.1 |
| Two-finger tap | registers with PointyTrail | < 0.3 s | the trail draws once | it draws on entering the register | `Pointy` | **none** | W0 14.21 |
| Long press on empty ground (the rope) | Door, axis; **story page and river (W2)** | 1.1 s; **opens at the threshold on the Door and axis (G13), G0 act-on-release in W2 §12a B** | the black room, two breaths | Turn row `Rest a moment` | `rest a moment` | acc | W0 14.21; W2 §12a B |
| Tap the 2×2 dot / slow pull ≥ 84 pt | every screen / the Door | — | "WHERE TO" (the Turn) | — | button | rest | existing |
| Back chevron / hub | every pushed layer | — | dissolve back (0.5 s) | — | back | rest | existing |
| Crossing bloom | every push and pop | 1.05 s tint ×0.22 under the dissolve | — | — | — | — | W0 15.6 |
| Interlude: tap anywhere | between stories and rooms | — | the arrival dissolves in, 0.8 s | the page waits | `continue` | rest | W0 15.6 |

### 3.2 Waking, the Door, the Practice Door, arrivals

| Gesture | Hold / threshold | Answers | Stillness twin | VO | Reveals by | Score |
|---|---|---|---|---|---|---|
| Waking: tap the line / tap elsewhere (year-ago, first line) | — | the page / continue | the page waits | `open the page` / `continue` | rest | W5 §4.8; W3 §8 |
| Door: tap anywhere | — | unmet → Rite; met → blink | **24 s → crosses by itself** (§3.12 C1) | Enter | acc | W4 §3.1 |
| Door: long press (rope) | 1.1 at threshold | rope | Turn row | as above | acc | existing |
| Door: slow pull ≥ 84 / dot mark | — | the Turn | — | button | rest (dot) | existing |
| Ask ember: press and hold | capture while held | his words appear as he speaks | — (tap → write) | `speak` | rest (ember breathes) + cue? | W4 §3.1 |
| Ask ember: tap | — | a one-line field | — | `write` | acc | W4 §3.1 |
| `keep it` (sends the words to the Codex) | **G0 1.2/0.62** | "It is in the Codex now." | — | `keep it` | press | W4 §3.1 |
| Between-words / door-words / three doors / board ask: tap | — | tint / draw / room / board | silence lets it go (24 s) | each word, `let it go` | rest | W4 §3.1 |
| Leela: offer it / hold in silence | taps | thread / Silence Held | a touch elsewhere completes | existing | rest | existing; W5 §4.1 |
| Wager return: yes · a glimpse · not yet | taps | seal field / carried again | ground tap continues | the three words | rest | W5 §4.10 / **W4 §4.5** |
| Wager seal | **W5: return or the ash dot; W4: `keep it` G0 1.6** | sealed | leaving empty completes | `keep it` | rest | **two scores disagree** |
| Good Morning page: tap / `keep walking` | — | the letter / blink | the page waits | `open` | rest | W5 §4.9 |
| Unmet arrival page: ground tap | — | the weather dissolves in, 1.0 s | — | `continue` | acc | W5 §3.2 |
| `one line is enough ›` | — | the floor | — | link | rest | W4 §3.3 |
| Practice Door: tap anywhere | — | cross | — | Enter | acc | existing |

### 3.3 The river (z = 0 inside the instrument, W6)

| Gesture | Hold / threshold | Answers | Stillness twin | VO | Reveals by | Score |
|---|---|---|---|---|---|---|
| Vertical scroll | — | the river | — | — | acc | W6 §2.1 |
| **Edge-lean** (pull down at the top, up at the bottom) | G15 push ≥ 1 | membrane gives; 5.4 s passage | — | `walk outward` / `walk inward` | acc (overscroll) | W6 §2.1 |
| **Pull-to-refresh** | — | **retired; the Turn's pull has no home here** (§3.12 C9) | — | — | — | W6 §2.1 |
| Card tap | — | story (dissolve + bloom) | — | activate | acc | existing |
| Card long press, then drag onto a card (Join) | G0 0.7/0.62 (border fills) | bloom / silent answer | `join with…` sheet; Two Doors dwell 9 s | `join with…` | press | W1 §4.1 |
| **Weft: drag along the thread** | trace ≥ 70% | the next card | 8 s on a card lights the thread | `follow the thread` | **none** | **W2 §12a D vs W1 §3.2 "the weft has no gesture"** |
| Wandering dot: tap while it rests (22 pt) | — | "found me" → the quietest room's story | 12 s still → it finds you | `find the dot` | rest (it moves) | W3 §9.1 |
| **Dot rests at x = W − 9** | — | — | — | — | — | **W3 §9.1 vs W6 §2.1 (the rail at z = 0)** |
| Rope in the gutters | **G0 1.1/0.62** | rope | Turn row | `rest a moment` | acc | W2 §12a B |
| Verb bead: tap / hold | tap · G0 0.9/0.62 | lit verb / a card lifts and turns (with song, W7) | — | light · `draw one` | press | W1 §6; W7 §4.1 |
| Arrival head / Wall of Voices link / witness line | tap / — | story / the wall | — | buttons | rest | W5 §3.4; W6 §2.5 |
| Rail rungs (right edge) | tap | glide | — | buttons | rest | W6 §2.1 |
| Pointy on the header | two-finger tap | trail | — | `Pointy` | **none** | W0 14.21 |

### 3.4 Rooms, voices, the Turning

| Gesture | Hold / threshold | Answers | Stillness twin | VO | Reveals by | Score |
|---|---|---|---|---|---|---|
| Ring of 21: tap a glyph | — | flood → room | — | buttons | rest | W2 §3.3 |
| **Ring: circular drag ≥ 270° round a glyph (Trace)** | — | path to the next unreceived story | — | `follow the thread` | **none** | W2 §12a D |
| GameView chevrons | — | 0.28 out / 0.4 in | — | prev / next | rest | existing |
| RoomView vertical / sideways / tap a mark | 240 pt per register | registers / the voice's figure / arm | — | — | acc | existing |
| RoomView: second tap on an armed mark | — | the story | 8 s → `open the story ›` | `open the story` | the two-stage touch | W2 §12a A |
| Players: `the turning ›` | — | the Turning | — | link | rest | W0 14.7 |
| The Turning: hold the ∞ | G0 2.9/0.75 | dawn; the words to full ink | 6.0 s still drives the engine | `trace the loop` | rest + cue (`trace the loop — let the light in`, authored) | W0 14.7 |

### 3.5 Reception: 21 grammars, 4 openings, variants, the sky

*Every grammar: `read it plainly` (always), `read it · play it` (W2 §3.9), the `receive` action, and a step action (W2 §4.2, §5).*

| Room / form | Touch | Hold / threshold | Stillness twin | VO step | Reveals by |
|---|---|---|---|---|---|
| A Maya Game | choose a side (tap) | — | 6 s on the choosing page | `turn it over` | rest |
| · oscillation variant | hold the dot (text while held) | continuous | alternates on 5 s | — | rest (the dot) |
| The Garden | leave and come back | 10 min away | it is the stillness | — | — |
| The Watcher | tap open / pass | — | 6 s → the third door | `beneath` | rest |
| The Descent | hold to peel | G0 1.25/0.62 | dwell + 4 s | `peel` | press |
| The Return | tap backward | — | 5.5 s beats | `back` | acc |
| The Forgetting | stay | 16 s drain | it is the stillness | — | — |
| The Remembering | tap in the gaps | — | the gaps run | `next line` | acc |
| The Body | trace in the dark | — | full warmth + dwell | `next` | **none** without the cue |
| The Thread | tap pass on | — | 4 s → the crystal | `pass on` | acc |
| The Circle | tap widen | — | dwell | `widen` | acc |
| The Signal | gaze, or hold (tratak) | G0 2.6/0.62 | 3–10 s still | `gaze` | press |
| The Forge | touch the seam | — | dwell + 8 s → mend | `mend` | rest (the seam) |
| The Field | tap hand on | — | dwell | `hand on` | acc |
| **The Ground** | hold anywhere → the next unit rises | **G0 1.1/0.62** | dwell + 1.5 s | `rise` | press |
| The Unwritten | stillness fills; **any touch un-reads**; hold to read (G1, 0.22 s a word) | 3.0 s, then a sentence every 1.1 s | it *is* stillness | `fill` | rest (card) / **the inverse is undiscoverable** (by design) |
| **The Stack** | press and hold: the drop descends 38 pt/s | **G0 1.2 per band** | dwell + 2 s | `press down` | press |
| The Counter | one horizontal line across (≥ 70% of the width, ±28 pt) | — | dwell + 3 s → the line draws itself | `cut` | rest (the counter line) + lean (the self-drawing) |
| · doorway variant | touch the edge · G0 1.0 · still thumb 2.0 | 3 / 6 / 10 s | | | rest |
| The Wash | a slow thumb circle (2π = 1/6) | — | 5 s = 1/6 (30 s in all) | `wash` | **none** for the circle; the stillness does it |
| The Name | trace the letters (≥ 70%) | — | 2.5 s × 3 breaths | `say` | rest (stroke letters) |
| The Old Light | tap; a slow upward swipe lets it pass | — | dwell | `let pass` | acc |
| The Fold | drag up from the bottom edge ≥ 40% of the height | — | 12 s → left folded (an ending) | `turn it over` · `leave it folded` | rest (the flap breathes 3° on 6 s) |
| Opening · drink | press and hold: the fill spreads at 140 pt/s | continuous | 4 s | `open` | press |
| Opening · swipe | swipe down through the lines | — | 4 s | `open` | rest (compressed lines) |
| Opening · fort | tap or hold inside the square | — | 6 s | `open` | rest |
| Opening · touch | the first touch | — | 6 s | `open` | acc |
| Sky reception | `or here`, or 6 s still at the world | — | 6 s | — | rest | 

### 3.6 The received story page (body, margins, close)

| Gesture | Hold / threshold | Answers | Stillness twin | VO | Reveals by | Score |
|---|---|---|---|---|---|---|
| Pinch / spread | — | essence ↔ transmission ↔ memo | — | — | acc | existing |
| Rewind spiral | G0 2.2/0.62 | the raw memo | — | spiral action | rest | W0 14.21 |
| Keep a line (paragraph) | long press 0.6 | ember in the margin | — | keep | cue (`touch the line to keep`, withdraws) | existing; W3 §6.3 |
| Carry (the ember dragged up ≥ 40 pt) | drag | a mote that follows the dot | keeping is the still path | `carry` | **none** (a 4 pt dot) | W3 §10 |
| Resonance: tap / hold | < 0.25 s / G0 1.5 | +1, halo / Depth | — | — | cue (`hold for depth`) | existing |
| Selvedge: title tap / thread tap | — | the story / the family sheet | the titles are always there | per-title actions | rest | W1 §3.1 |
| Echo line: first tap, second tap | — | full ink / the Seam | it rises by dwell | activate | rest | W1 §3.4 |
| Header mark → Rings (G24) | drag a ring; 15° ticks | bells; the centre lights | 4 s → the rings drift true | `turn the rings` | rest + lean (the drift) | W1 §4.3 |
| Close dot: tap | — | splits into rhymes / draws a path | 16 s → draws the next path | `follow the dot` | rest | W1 §4.4; W3 §9.4 |
| **Turn (corner curl)** | drag from the bottom-right 64 × 64; commits at 38% of the diagonal or 600 pt/s | the next face | **14 s → curls 18%; + 6 s → turns** | rotor `faces`, `turn` | **none at rest**; the lean at 14 s | W2 §8 |
| Signatures: cordCut drag · empty summit G0 1.2 · alreadyMended tap · sealed last page tap · deferral tap · quiet-ones rule tap | | | | | rest | existing; W2 §7 |
| **Unpaid grace** | **G0 2.0 in the white below the last line** | the hidden paragraph | 10 s held stillness at the page end | — | **none** | **W2 §7.2 vs the rope (W2 §12a B)** |
| Second reading | — | a word re-weighted | 20 s dwell at the page end | — | — | W2 §7.2 |
| Held sentence | — | "what this story doesn't say" | 16 s still on the white space | — | — | W2 §12.2 |
| Reverse dissolve | — | voices leave in reverse order | 8 s still past the last voice | — | — | W2 §12.5 |
| Beat | three taps within ±150 ms of the pulse | a second drum; warmth | 20 s → warmth | `keep time` | **none** | W2 §12a C |
| Will line | G0 0.9/0.62 | underline fills; the line is held | 8 s | `hold it` | press | W3 §3.2 |
| Action: a word, or the silence ember | field · G0 1.6/0.62 | the circuit closes; the dot splits in three; a mote rises | 14 s drives the ember | `hold it in silence` | cue (`or hold it in silence`) | W3 §3.3 |
| Wager: `I'll carry this` ember | **G0 1.2/0.62** | the line lifts into a mote | 14 s | `carry it` | press | W4 §4.5 |
| `dance it` · offering (tap, **or ♪ held 0.6 s, then speak**) | | the dance / the word | 30 s fades | `dance it` | rest | W7 §3.3 |
| Teacher line | G0 1.2 | `this reaches backward`; a hairline | — | — | **none** | W7 §5.4 |
| Reach (Circle stories) | G0 1.6 | the point travels to the leading edge | 12 s | `a reach` | press | W7 §5.3 |
| Lantern: tap the light / hold the faint one | — / G0 2.2 | to its source / opens early | it travels by itself | read after the body | rest | W6 §10.3 |
| Machine's last word: tap | — | the next story, first word lit | 8 s rest on it | `where it continues` | rest (glow) | W6 §10.4 |
| `follow it round ›` | — | the journey ring | — | link | rest | W6 §10.1 |
| Compose ring · Hall `the eleventh` · Floor door · Floor go-down ×3 · Floor carve | G0 2.3/0.62 · 1.4 · 1.25 · 1.25 · 1.6 | release / add / down / carve | — | each `hold to …` | cue (withdraws) | existing; W3 §6.3 |
| Read by hand: rest a finger / double-tap | continuous / — | words assemble / keep | — | — | cue (`rest a finger to read`) | existing |
| **Rope in the margins and the white below** | **G0 1.1/0.62** | rope | Turn row | `rest a moment` | acc | W2 §12a B |

### 3.7 Ceremonies and the records

| Gesture | Hold / threshold | Answers | Stillness twin | VO | Score |
|---|---|---|---|---|---|
| Rite: baton (tap) · arrival · reading (tap lights, 2.6 s) · gathering (tap; swipe right steps back) · recognition (speak or type) · stitch question (tap) · `let it go and draw again` · seal forward G0 1.6 | | | 6 s · dwell per paragraph · dwell per line · **20 s → a wordless seal** · Sealing 14 s per beat | per movement | W4 §3.5 |
| Low-day Rite: tap per line | — | the next line | one per breath | the column | W4 §3.6 |
| Return: core-sample (hold the seed) | **G0 1.3/0.62** | the tellings in three inks | 12 s on Rings | `the tellings` | W4 §3.9 C |
| Return: `it answered` / `not this` | taps | decided | silence leaves it undecided | both | W4 §3.9 B |
| Call: lay · go down | 2.6 · 1.3 | | — | | existing |
| Present: seal · open early · Good Morning · season letter early · wager early | 1.6 · 2.2 · 2.2 · 2.2 · 2.2 | | the letter's own arrival | `open it now` | W0 14.12; W4 §4.1; W5 §4.9 |
| Codex: hold to speak · give | capture · **1.4** | | — | | existing |
| Gift: appreciate | 1.2 | | — | | existing |
| Unwinding: lift > 160 · pinch < 0.42 · turn back 1.6π | | **lift = let go (it rises off the top)** | three slow breaths | `lay down` | existing |
| Gates: set down / **keep** (draw up > 90 pt: rises 320 pt and fades) / gift tap | G0 2.6/0.62 / drag / tap | sink / **rise and fade** / received | 30 s → set down · 8 s → gift | `lay down` · **`keep`** · `receive` | W4 §4.4 |
| Board: carry it in / hold in silence | G0 1.2 / tap | the walk begins | 12 s → in silence | both | W4 §3.2 |
| Board: die (tap to arm, then hold) | G0 2.2/0.62, rattle | the throw | 10 s → the field throws | `throw` | W4 §3.2 |
| Board: landing card away · three breaths | drag down · hold 4.0 in / 5.2 out | | 12 s · the circle breathes by itself | `close` | W4 §3.2 |
| Draw: deck · die (tap, then hold) · card tap · let go | G0 1.9 · G0 2.2 | | 8 s → the die throws | `draw` · `throw` · `open` | W4 §3.4 |
| One-line floor | G0 1.6 | the day's whole reading | 10 s | `keep this line` | W4 §3.3 |
| Name rite: stillness, then `keep it` | 12 s · G0 1.6 | the name assembles | it is stillness | `keep it` | W4 §4.3 |
| Season letter · Recitation | tap a line | next | one per breath | whole | W4 §4.1–4.2 |
| Cloth: pinch · pan · edge drag flips · tap stitch | — | | 24 s → turns over | `turn the cloth over`, `come closer`, `step back`, `read along` | W3 §4.3 |
| Book: drag turns a leaf · cover drag turns the book · **Join: hold 0.7 lifts, turn under, drop** · **gilt band G0 1.6 = send back** · **lit-edge strip tap → Two Doors** · **three strips → triptych** · back-cover thread → Cloth | | | send back 20 s | `send back`, `turn the book over`, `join with…` | W1 §4.1, §5.4; W3 §7 |
| BookView margin word | long press 0.6 | | — | | existing |
| Confession / farthest line | dwell (1.6 s each); a tap shows all | | it is the dwell | five images | W3 §7.11 |

### 3.8 Axis, sky, world, fall, Point, Light, eagle-eye

| Gesture | Hold / threshold | Answers | Stillness twin | VO | Score |
|---|---|---|---|---|---|
| Axis lean (G15) · rail rungs | push ≥ 1 / tap | passage 5.4 s / glide | the stillness gate (4.6 s) into the Light | rungs | existing |
| Old Story: Turn row · rail mark · 10 s still at the sky | — | the regions gather | 10 s | `the old story` | W0 14.8 |
| Sky drag = **pan and Sweep** (strength `+ px × 0.010`, fades at 0.30/s) | — | three titles answer | the rhyme threads are always drawn | `what lies along` (15° a step) | W1 §4.2 (**W0 reserved Sweep as long-press-then-drag**) |
| Sky long press 0.6 s → drag to a star | 0.6 s | filament + bloom / silent answer | `join with…` | | W1 §4.1 |
| Khelo flick | 40–220 pt at ≥ 900 pt/s | colour lands where two rhyme | none needed | `throw colour` | W1 §4.5 |
| Sky taps: star · word-star (W7) · hidden dot (W3) · fourth-face title (W6) · constellation light (W6) | — | travel / lit word / found / fly | — | per item | **five tap targets on one dense field** |
| Pinch out past the sky's widest zoom | out ≥ 1.6 | the eagle-eye | Turn row | `see the whole house` | W6 §6.1 |
| World: `TOUCH TO READ` / `or here` | — | page / sky reception | 6 s | | W6 §4.1 |
| Fall: pull up · mouth consent | | | | | existing |
| Point worlds I–VII (VII becomes a real Dance) | per world | | per world | | W6 §3.5 |
| Light: stillness gate · touch asks · carve · seal forward · 55 `LightHand` scenes (including G0 2.4, G0 2.6, an 8 s hold, G0 2.2 for a calendar scene) | | | per scene | `receive` on every scene | W6 §8.2 |
| Eagle-eye: pager swipe · Glass vertical drag · lens rail · tap or spread to land · Spine bead tap or pinch-in · spiral trace · one more pinch out → the yantra | | | 10 s (Spine, yantra) | `go there` | W6 §6; W7 §7 |
| Journey ring: tap a station | — | the dot goes there (1.2 s) | it steps by itself | `follow it round` | W6 §10.1 |
| Wall of Voices: touch holds the drift · tap a line | — | the story | it drifts | list | W6 §2.5 |

### 3.9 The totals

- **About 31 physical gesture forms:**
  - tap; double-tap; two-finger tap; two-finger hold;
  - long press 0.6, 0.7 and 1.1;
  - G0 hold; capture-while-held; progressive hold; still thumb;
  - horizontal drag; vertical drag; corner drag; bottom-edge drag; circular drag; trace along a path;
  - pinch out; pinch in; flick; drag to a target; drag off an edge; swipe right;
  - shake; eyes closed; face down; pull down; edge-lean;
  - taps in time; stillness.
- **About 165 placements**: ~75 existing, ~90 new or changed.
- **22 distinct hold lengths:** 0.6 · 0.7 · 0.8 · 0.9 · 1.0 · 1.1 · 1.2 · 1.25 · 1.3 · 1.4 · 1.5 · 1.6 · 1.9 · 2.0 · 2.2 · 2.3 · 2.4 · 2.6 · 2.9 · 4.0 · 4.2 · 8.0.
- **About 16 distinct stillness thresholds for "complete this act by yourself":** 2.5 · 3 · 4 · 4.6 · 5 · 6 · 8 · 9 · 10 · 12 · 14 · 16 · 20 · 24 · 30 · 45.

### 3.10 The learning curve, for the one person who plays it

- **Who learns it.** Ashrey already knows about 75 placements. He has played the house since June, and the hold, the rope, the Call and the Door's surface are in his hand.
- **When it arrives.** He receives everything new **at once**, on delivery day (CONTRACT §1: one delivery, no drafts, "he should not be able to say what changed").
- **What has to be learned.** About 15 new physical forms in ~90 places, with no tour, in the first week.
- **The real risk is not the count; it is placement.**
  - Gestures that sit on zones he already uses for something else read as broken. A long press on the white below a story now opens the rope where he expects grace.
  - Gestures with no affordance at rest are never found: the page curl, the gilt edge, the ember lift, the circle trace, Pointy, the Wash circle, Beat, the teacher hold.
- **What sets the budget.** The equal-path law means nothing is *lost* if a gesture is never found, because stillness or a row does the act. So the budget is not "how many can he learn". It is **how many he will meet as a visible invitation, and in what order**. §4.4 designs that order.

### 3.11 Same meaning, different durations (new holds only; existing holds keep theirs, P4)

| Meaning | Existing anchor (kept) | New holds in the scores | Proposed |
|---|---|---|---|
| **Going down** (peel, a floor, a door down) | peel 1.25 · FloorDoor 1.25 · Floor go-down 1.25 · G14 1.25 · Call go-down 1.3 | Ground rise **1.1** · Stack band **1.2** · core-sample **1.3** | **1.25** for all three. The Ground and the Stack are the Descent's siblings, and 1.1 is the rope's number. |
| **Give a word to the field / the Codex** | Codex `give it` **1.4** · Hall `add it` 1.4 · Compose 2.3 (G31) | Door `keep it` **1.2** (it writes a Codex row) | **1.4**, labelled `give it`: the same act, so the same hand and the same word. |
| **Seal** (close with his word) | Present seal 1.6 · seal forward 1.6 · Floor carve 1.6 | one-line floor 1.6 · name 1.6 · wager return **1.6 vs W5's tap** · silence ember 1.6 · send back 1.6 · Reach 1.6 | 1.6 ✓. Settle the wager return by one boxless-word component (§5 #16). |
| **Commit / choose** | Gift 1.2 · empty summit 1.2 | Counter `chosen` **1.0** · board carry-in 1.2 · teacher 1.2 | **1.2** (Counter 1.0 → 1.2). |
| **Take on lightly** | G32's minimum 0.9 | Will 0.9 · Mala 0.9 | 0.9 ✓ (a matched pair). |
| **Carry into the day** | — | W3 Carry = **drag the ember up 40 pt** · W4 wager carry = **G0 1.2** · W4 Gates keep = **drag up 90 pt (rise 320, fade)** | **One gesture: lift upward 40 pt into the dot** (§3.13). |
| **Open early** (law 3) | — | letter 2.2 · Good Morning 2.2 · season 2.2 · wager 2.2 · lantern 2.2 · Light calendar 2.2 · **unpaid grace 2.0** | 2.2 everywhere. Grace 2.0 → **2.2** on its own mark. |
| **Lay down** | Call lay 2.6 · G33 2.6 | Gates 2.6 · Light weightPassed **2.4** · Light askfor 2.6 | **2.6** (2.4 → 2.6). |
| **Throw / draw (G29)** | — | die 2.2 · deck 1.9 | ✓ (padakarshini's own numbers). |
| **Speak** | Codex: capture while held from touch-down | W4 ember: capture while held ✓ · W7 ♪: **held 0.6 s, then capture** | Capture from touch-down everywhere. |
| **Hold cancel distance** | G0: > 9 px · Door 7 · Join 10 · filament 6 | W0 §3: **"movement over 24 pt releases"** | **10 pt** for a stationary hold. 24 pt (G2's still touch) only where the finger travels (Stack, drink, G1 read). |

### 3.12 Collisions and breaks of the principles (the wholes no score saw)

**C1 · Stillness chains that write (breaks P7; MUST).**
- The chain: W4 §3.1 makes the unmet Door cross by itself after **24 s**. W4 §3.5 F gives every Rite movement a stillness twin, ending in *"Recognition — 20 s still → a wordless seal"*. W4 §7.5 walks "a full day … by stillness alone".
- The arithmetic: open the app, set the phone down face-up with auto-lock off, and in about 2–4 minutes the Rite has run and sealed. `Story Met` is written, the day turns to after-light, and the sky lights a star. Nothing records that a hand was there. With auto-lock at 30 s it usually stops before the seal; that protection is an accident, not a design.
- The fix: padakarshini's own precedent is G2's Approach: *"after one touch, the same accumulator…"*. Stillness may carry everything inside a ceremony he has touched once. A stillness path that ends in a **write that says he did** (`Story Met`, `Ceremony Sealed`, `Circuit Closed`, `Wager`, `Sent Back`, `Reach`) needs **one touch since that surface opened**. The Door's 24 s draws the threshold in (the lids close to 50%, the Rite offer brightens) and **waits**. It does not cross. Silence stays a full answer once he has touched in.

**C2 · The zone below a story's last line (breaks P2, P6; MUST).**
- What it holds after W0–W8:
  - the rope (G0 1.1, W2 §12a B);
  - unpaid grace (G0 2.0 *in the same white*, W2 §7.2), whose hold is overtaken by the rope at 1.1 s every time;
  - the stillness clocks: Will 8 s · reverse dissolve 8 s · grace 10 s · Action 14 s · wager 14 s · Turn curl 14 + 6 s · held sentence 16 s · draw path 16 s · second reading 20 s · Beat warmth 20 s · Reach 12 s · teacher line at 6 s.
- The collision: at 14, 16 and 20 s, two to four things move at once on one still screen. W2 §12's CloseConductor rations **after-things** to one, but it does not own the signatures, the Turn curl, the draw path, the reverse dissolve or Beat.
- The fix: the conductor owns **every** end-of-page stillness slot, released one per exhale in a fixed ladder (§4.3). Grace's hold moves off empty ground (§5 #7).

**C3 · The rope behaves two ways (breaks P3; MUST).**
- W0 §2 says the rope is *not* a hold: G13 opens at 1.1 s while the finger is down.
- W2 §12a B draws it "with W0's HoldRing … on HoldEngine (G0 1.1 / 0.62)", which is act-on-release with a drain. The same gesture would answer differently on the Door and on the story page.
- The fix: one behaviour everywhere. It opens at the threshold while held (G13), with one shared ring as its press preview.

**C4 · Whole-stage holds in reception versus the rope (breaks P2; MUST).**
- The Ground holds anywhere for 1.1 s, which is the rope's exact length. The Stack, the drink opening, the Unwritten's G1 read and Maya's dot all take presses anywhere on the stage.
- The fix: while `ReceptionView` is mounted, the grammar owns every press (`PressClaim("reception")`). The rope there is the Turn row.

**C5 · The river's trailing gutter (MUST).**
- W3 §9.1 rests the wandering dot at x = W − 9.
- W6 §2.1 puts the river inside the instrument at z = 0 and shows the rail (`right: 13px`, ticks 17 pt wide) "lit at rest".
- The fix: the dot's rest points move to the gaps between cards and the open band above the first card, never within 30 pt of either edge.

**C6 · The river's leading gutter.**
- W1 §3.2 rules that *"the weft has no gesture"* and cites CLAUDE.md §10's PlayersView-fold warning against drags on cards.
- W2 §12a D gives the weft a Trace drag that starts within 22 pt of it, in a 16 pt gutter, which is also where an edge-leave would start (§5 #13).
- The fix: drop the weft Trace. Trace keeps the ring glyph and the spiral. The weft's twin (an 8 s rest on a card lights the thread) and `follow the thread` stay.

**C7 · The Book's trailing edge.**
- What sits there: the gilt band (outer 12 pt, G0 1.6, send back), W1's lit-edge strip (6 pt, inside it, tap → Two Doors), the three-strip triptych mark (tap), and the start of every forward page-turn drag.
- The trouble: three acts in 18 pt, no target reaches 44 pt, and every page turn starts in the same band.
- The fix: the edge keeps one gesture (send back, with a 44 pt hit width and the band still drawn at 12 pt). The lit edge and the three strips become one 44 pt mark at the page foot.

**C8 · The sky's tap density.**
- What shares one canvas of ~475 stars: star travel (existing), word-stars (W7), the hidden dot (W3), fourth-face titles (W6), constellation lights (W6), and the Sweep's named titles (W1).
- The fix: the house's own answer (CLAUDE.md §10, *"the two-stage touch is the affordance for choosing among things that cannot label themselves"*). In the sky, the first touch **names** the nearest thing within 22 pt and the second **commits**. A single unambiguous target still commits on the first touch.

**C9 · Pull-down means two things.**
- On the Door, a slow pull ≥ 84 pt opens the Turn.
- On the river after W6, pull-down at the top is the axis's outward lean, and `.refreshable` is retired.
- The cost: on the river the Turn can then be opened only by the HubTrigger at the top-left.
- The fix: the design already distinguishes the two (elements "Three gestures on one surface": *"In the Instrument, the turn needs a slow pull; a firm pull departs outward along the axis"*). A slow pull (release speed < 300 pt/s, past 84 pt) opens the Turn. A firm pull leans outward.

**C10 · The Turn overflows (breaks P10, P11; MUST).**
- W4 §3.11 lists 19 rows; W3 adds the Cloth and the Book; W6 adds `the voices`, `The Whole House` and `walk a chain`. That is **24 rows**.
- At its designed metrics (padding 13 pt top and bottom, a 16 pt gap, name and italic sub) this is about 1.6 screens.
- The overlay closes on *any* pointerdown ("tap anywhere to stay"), so it cannot scroll.
- The stagger (`0.14 + i·0.075`) leaves the last row 2.5 s late.
- The top rows are out of one-handed reach.
- The fix: §4.5, the Turn as the Veil.

**C11 · Same motion, opposite meaning (breaks P1).**
- In the Unwinding (existing), lifting a held thing upward until it leaves is **letting go**.
- In the Gates (W4 §4.4, G26), drawing the words up until they "rise 320 pt and fade" is **keeping**.
- These are the only two registers where *lay down* lives (CONTRACT §4), so the conflict sits exactly where the meaning matters most.
- The fix: §3.13.

**C12 · "Keep" names four acts.**
- keep a line (to the Book);
- `keep it` at the Door (to the Codex);
- `keep` in the Gates (carry back up);
- `keep it` at the wager return (seal) and in the name rite (stored on the device).
- A VoiceOver user hears one word with four outcomes. The fix: §4.6.

**C13 · Sound at commit (breaks P3).**
- W1 §6 plays `carryTone(hz: 110)` on the Mala hold's *commit*. W4 §3.1 plays `blip(220)` on `keep it`'s commit. W4 §3.4 plays the deck's commit tone.
- G0: *"commit on the threshold, act on release: permissions, audio, navigation … wait for the lift."*
- The fix: the tone moves to `onComplete`. The haptic latch alone marks the commit.

**C14 · A second finger on a live hold.**
- Two fingers on the Turning's ∞ (or the Compose ring) drive G0 *and* fire the Call at 0.8 s. The Call's recognizer uses `cancelsTouchesInView = false`.
- The fix: a touch count ≥ 2 releases any live G0 hold silently (it drains) and yields to the Call or Pointy.

**C15 · Leaving gets slower.**
- On the way out, W2 §6.3 plays a room exit of 0.6–1.6 s *before* the 0.5 s dissolve.
- On the way in, W2 §12.4 sets the story's entry dissolve to 2.2 / 1.4 / 0.9 s by weight.
- W0 15.6 lays a 1.05 s bloom under both.
- The result: leaving a deep story can take about 2.6 s of motion, and entering about 2.2 s before the grammar starts.
- Law 14: *leaving … never punished*. P11: one dissolve.
- The fix: §4.2.

**C16 · The cream page is spent too often (breaks P13 / GRACE).**
- The identical page (`#F3E9D8`, the 7 pt red dot at 40%, Lora italic 19) is the W0 interlude (15 rows, recurring), the W3 first line, the W3 farthest line, the W4 board read-back and the W4 Season Letter. W5's Good Morning letter is a near-white page with a gold dot.
- The power of *"same words, two recognitions"* (W3 §8) depends on that page being rare.
- The fix: §5 #20.

**C17 · Room exits that end alike (GRACE rule 1; W2 §6.3).**
- **Rise and fade:** the Descent (24 pt), the Ground (30 pt), the Body (16 pt + brighten), the Old Light (20 pt), the Stack (drop rises), the Counter (8 pt up). The Ground and the Descent are sister rooms (the floor *under* the self, the floor *of* the self) and end in nearly the same motion.
- **Contract to the centre:** the Return, the Circle, the Thread, the Field.
- **Opacity only:** the Garden (1.6 s), the Forge (0.6 s).
- The fix: a GRACE assignment, §4.7.

**C18 · Three haptic engines, and none can be switched off.**
- The engines: G0's `CHHapticEngine` (W0 §3), `RoomHaptics` (W2 §3.7, deliberately separate) and `HeartbeatService`.
- There is no `haptics off` (padakarshini: *"default on, one 'haptics off' switch beside 'sound off'"*).
- Room-turn haptics fire when the turn unit becomes visible, which includes stillness-driven reveals. Elements: *"haptics fire on acts of will, never on passive navigation"*.
- See §5 #22.

**C19 · Word fields in three shapes.**
- A placeholder `a word` (W3 §3.3), a placeholder `what you noticed` (W5 §4.10) and *no placeholder* (W4 §3.1, §3.2, §4.3, §4.4, §4.5).
- Grammar D.3 has one shape: *the question in large italic, the word large in the accent with a blinking cursor over a thin rule, "or speak it" beneath*. See §5 #16.

**C20 · Stale reservations in GESTURES.md.**
- W0 §4.1 reserves Join at 0.5 s (W1 builds 0.7) and Sweep as long-press-then-drag (W1 makes it the pan drag, citing the design).
- Track 2 writes GESTURES.md from W0. If the reservations are not corrected, the map disagrees with the code on day one.

**C21 · Missing rows in W0's migration table.**
- Missing: Hall `HoldEmber 1.4`, Codex give 1.4, Floor go-down 1.25 ×3, Floor carve 1.6, Light seal-forward 1.6, and CallView's private loop (`CallView.swift:253-279`).
- Retiring `HoldEmber` as an engine migrates these sites implicitly. GESTURES.md still needs their rows, or its "every hold" claim is false.

### 3.13 Gestures that mean different things in different places

| Motion | Meanings across the house | Ruling |
|---|---|---|
| **Upward** | carry the ember (W3) · wager carry (W4, a hold) · Gates keep (rises and fades) · Unwinding let go (rises off) · river bottom edge-lean inward (W6) · Old Light let pass · Fold turn over (from the bottom edge) · Light 738 returns to the start | **One vertical grammar.** *Up a little, into the dot* = carry (40 pt, the item becomes a mote that follows the dot). *Up and out of the frame* = given to the sky, let go (the Unwinding; existing). Reception stages and Light scenes own their verticals by design. The Gates' keep becomes the carry gesture; the wager's 1.2 s hold becomes the carry lift. |
| **Downward** | Door / river top: the Turn or lean outward · Gates set down sinks · Board card away · swipe opening · Light 762 down opens | *Sinking* = laying down. *A slow pull from the top* = the Turn. *A firm pull* = outward on the axis (C9). |
| **Rightward** | Rite gathering steps back · Book turns back · front cover turns the book to the Dark path · (proposed) edge-leave | Already coherent: **rightward = backward**. Keep it; G38 joins it. |
| **Long press** | text = keep · card = lift (Join) · star = thread · empty ground = rest · the seed = core-sample · a ring = its hold | P2: **the thing pressed decides.** Written as the first law of GESTURES.md. |
| **Pinch / spread** | story: essence ↔ memo · sky and Cloth: zoom · past the sky's widest: the eagle-eye · eagle-eye pinch-in: land · Unwinding: pinch shut = let go | Coherent: spread = closer / more source; pinch = farther / less / let go. |
| **Hold the red dot** | Maya oscillation (text while held) · Point gate (in) · Living Axis point (to the source) · Light askfor (opens) · W7 Reach (a *point*, not the bindu) | Coherent as *through the dot*. W7's Reach mark must not be drawn in `colorBindu`. |
| **Touch during stillness** | everywhere: pauses or advances · the Unwritten: **un-reads** · Light 710: withdraws | Designed inversions, each isolated to one place (room test). Keep them. GESTURES.md marks them *inverse*. |

---

## 4 · Gaps and opportunities (what the whole needs that no score holds)

### 4.1 The hold engine, final numbers (extends W0 §3)

| Parameter | Value | Why |
|---|---|---|
| Tick | CADisplayLink 60–120 Hz, `dt = min(1/15, Δ)` | W0 §3 ✓ |
| Up | by meaning (§3.11); existing holds keep their own | P4 |
| Down | **0.62** default; 0.75 for the Turning; Lalita's instant empty stays where it is designed | G0 corpus |
| **Press preview** | at touch-down the hold's view draws its track at p = 0 within one frame (ring track 0.22 · ember track 0.14) and a tick haptic (0.4 / 0.3) | P8: "press anything and see if it fills" teaches every hold in the house through one meta-gesture |
| **Cancel** | > **10 pt** movement for a stationary hold; 24 pt only for travel holds (Stack, drink, G1 read) | G0 "what cancels a hold" (9 px); W0's 24 pt is G2's still touch |
| **Second finger** | touch count ≥ 2 → `release()` (drain), then yield to the Call or Pointy | C14 |
| Commit (p ≥ 1) | visual + medium-impact latch only | G0 |
| **Complete (on lift)** | navigation, writes, **every SoundEngine call**, permissions | C13 |
| Stillness drive | `press(.stillness)` at the same up rate; a touch releases it and the hand continues from the current p | W0 §3 ✓ |
| Reduce Motion | duration and order unchanged; fill drawn in quarter steps | W0 §3 ✓ |
| Accessibility | `hold to <act>` label; `completeForAccessibility()`; value `holding` → `held`, never a percentage | W0 §3 ✓ |
| **Two views by meaning** | **ring** (`HoldRing`) = an act *on a thing*: open, go down, throw, draw, look into · **ember** (`HoldEmberView`) = an act that *gives his own*: seal, give, release, carve, add, carry, reach | Already true by history (peel and tratak are rings; seal, give and carve are embers). Writing it down lets every new hold choose correctly. |

### 4.2 The unified motion system (`Theme/Motion.swift`, new; with Reduce Motion built in)

**Durations by meaning (five words, each with its own band):**

| Token | Seconds | Meaning | Anchors in the house |
|---|---|---|---|
| `respond` | 0.12–0.28 | the hand is heard | selection tick; G43 step 0.28 out / 0.4 in; chosen object 0.25 |
| `settle` | 0.6 (drain 0.62) | the thing answers and comes to rest | G0 drain; card returns (spring 0.35 for physical returns only); chosen and others 0.6 |
| `cross` | **0.5** dissolve + 1.05 bloom beneath | a change of place | `Navigation.swift`'s 0.5; W0 15.6 bloom |
| `arrive` | 1.2–1.6 | words or a presence come into the room | lines 1.2–1.6; ask 1.6; the dot's split 0.9 + 0.6 + 0.7 |
| `breathe` | 2.4–2.6 | ceremonial light | Rite paragraph 2.6; slow lines 2.4; the Recitation's drift 2.4 |

**Clocks** (time that is not a transition): the Breath (10 s; in 40% · hold 15% · out 40% · rest 5%) · the membrane passage (5.4 s) · the Descent (2.35 s; first entry and thresholds only) · the Waking (2.85 s) · the interlude well (1.5 s) · the blink (0.66 s; the Door only).

**The easing family. Five curves, each with an owner. Nothing else may be written by hand:**

| Curve | Value | Owns |
|---|---|---|
| `ease.arrive` | `cubic-bezier(.2,.7,.2,1)` | presence: Rite paragraphs, the yard hairline, world reception, the Reach, the eagle-eye Glass swell |
| `ease.bloom` | `cubic-bezier(.16,1,.3,1)` | outward from a point: the crossing bloom, the eagle-eye landing, the lantern, any scale-up from a touch |
| `ease.well` | `cubic-bezier(.5,0,.15,1)` | something wells up from below: the interlude cream, the dark veil, read-back pages |
| `ease.pass` | `cubic-bezier(.65,0,.35,1)` (≈ SwiftUI `easeInOut`, the app's ~200 existing calls) | travel between two places: Join's slide, Two Doors opening, the token's hop |
| `ease.threshold` | the blink `(.62,.02,.4,1)` and the Descent `(.66,0,.24,1)` | **the two named crossings only** |

Linear motion only for clock-driven travel (the Seam dot's 4.9 s, Wall drift). Springs only for a physical object returning to the hand's start (curl relax, card return, die tumble).

**The dissolve and the two camera moves (P11):**

1. **The dissolve** changes *place*: a route layer pushed or popped. It is always `cross` (0.5 s, `ease.pass`) with the bloom beneath. Nothing slides.
2. **Camera I · the axis**: vertical travel inside one continuous place. The membrane push → a 5.4 s passage. Turn rows and deep links *glide* (`axisGlide`). W6 §2.1 makes `.instrument(z)` pushes into glides. ✓
3. **Camera II · the zoom**: the sky ↔ world ↔ fall (G44, `R = pr·z`), the eagle-eye pinch out and in, sky reception's planet 1 → 0.86.
4. **The hinge**, the one legal joint between a camera and a dissolve: the camera carries a mark until it fills the frame, and the destination dissolves in *under* it (W6 §6.4 is the model). Anywhere else a camera move never cuts into a dissolve mid-motion.
5. **Two corrections follow from this:**
   - W2 §12.4's weight-as-tempo stops changing the route dissolve (it stays 0.5). Weight moves to the **reception's first frame**: the title's arrival takes 0.9 / 1.4 / 2.2 s, and the grammar starts after it. Navigation stays one speed; the story's weight is felt in its arrival.
   - W2 §6.3's room exits run **concurrently with** the dissolve, capped at 0.6 s visible, and never before it. Leaving is one motion (C15).

**Reduce Motion lives in the tokens:**

| Motion | Under Reduce Motion |
|---|---|
| translate, scale, rotate | opacity over the same duration |
| continuous drift (Wall, rings, motes, breathing) | static at the mid value |
| blink, Descent, passage, landing hinge | a 0.3 s fade through black |
| holds | unchanged (quarter-step fill) |
| stillness thresholds, beats, the Breath clock | unchanged |
| the bloom | 0.3 s colour crossfade at 0.12 (W0 15.6 ✓) |

**A `Tools/house_law.sh` rule:** new code calls `Motion.<token>` and never writes `withAnimation(.easeInOut(duration:` or a hand-written `timingCurve`. Existing call sites are grandfathered and listed.

**Room tempo (law 16, LATER):**
- `RoomCanon.tempo` is one multiplier on that room's chrome and settle motions, so a room is known by its tempo before its name (elements "A tempo per room": 600 / 350 / 120 / 150 / 1200 ms).
- Proposed: the Old Light 1.4 · the Ground 1.25 · the Stack 1.15 · the Wash 1.2 · the Unwritten 1.0 with no chrome motion · the Counter 0.8 · the Fold 0.9 · the thirteen at 1.0 (their grammars already differ).

### 4.3 The exhale queue: how stillness speaks (new; owns C1 and C2)

`Store/StillnessConductor.swift`, one per surface, built on `Breath.exhaleDelay(fromPhase:)` (`Instrument/Breath.swift:118`).

1. **The two kinds of stillness:**
   - A **twin** is stillness *since the last touch*. A touch resets it. Twins are the equal-path completions.
   - An **accumulator** is stillness as the *reading itself* (the Light gate, the Unwritten's fill, Wash progress, G2). A touch **pauses** it and never resets it (G2, law 4). The Unwritten is the designed exception: its touch un-reads.
   - GESTURES.md marks every stillness row as one kind or the other.
2. **Ready, then spoken on the exhale.** A twin whose threshold is met becomes *ready*. Ready twins resolve **one per exhale**, at the next crest-to-exhale (`exhaleDelay`, floor 0.24 s), in ladder order. Two things never move at once on a still screen, and stillness is felt as breath, not as a timer.
3. **The ladder** (end of a received story page; reception has its own ladder):
   1. the grammar's last step;
   2. the close shape (Arc-kind or silence);
   3. the dealt signature's dwell event (second reading, grace, kept mistake);
   4. **the conductor's one after-thing** (Will → Action, *or* the wager, *or* dance it, *or* journey, *or* held, *or* draw path, *or* Beat warmth on pulse rooms);
   5. the reverse dissolve (only after a gathering);
   6. the Turn's lean, then the Turn.
4. **Thresholds for new twins snap to breaths.** Existing designed thresholds stay (the Watcher's 6 s, the Light's 4.6 s, the Garden's 10 min, the Forge's dwell + 8, the Signal's 3–10 s).

   | Breaths | Meaning | New twins snapped |
   |---|---|---|
   | dwell(u) | a reading step | unchanged (W2's `Katha.dwell`) |
   | ½ (5 s) | **the lean** (§4.4) | every gesture-only act |
   | 1 (10 s) | an offered act completes by itself | Will (8 → 10), board throw ✓, Draw (8 → 10), one line ✓, Reach (12 → 10), name ✓ (12 stays; the rite *is* stillness), river dot (12 → 10), hidden dot ✓, Spine ✓, yantra ✓, RoomView `open the story` (8 → 10), landing card (12 → 10) |
   | 2 (20 s) | an after-thing or a turn | Action (14 → 20), wager (14 → 20), held (16 → 20), draw path (16 → 20), Turn (14 + 6 → lean at 10, turn at 20), second reading ✓, Beat ✓, send back ✓, Recognition's wordless seal ✓ |
   | 3 (30 s) | a laying down or a crossing | Gates ✓, Door 24 → **30, and it waits** (C1), Cloth turns over (24 → 30) |

5. **The touch budget (P7).** A twin whose completion **writes** to the base is *armed* only if a touch has landed on this surface since it opened. The cold open (his tap on the icon) arms the Door's first act, so the Door may *draw in* by stillness, but it crosses on a touch. A Rite he has touched once may then be read, gathered and sealed by stillness alone. That is the honest form of W4's walk B.

### 4.4 Discovery: how the game teaches itself (no tutorials)

Six mechanisms, in the order he meets them. Together they replace instruction.

1. **At rest, the thing looks holdable or movable.**
   - An ember breathes (`emberWake 3.6 s`, ×0.97–1.045).
   - A ring shows its track.
   - The die sits as an object.
   - The Fold's flap breathes 3° on 6 s.
   - **The Turn's corner shows a 6 pt folded tip** on every received page (W2 §8 draws nothing at rest today).
   - The gilt edge is gold.
   - The kept-line ember gains a faint 1 pt upward tick when a carry is possible.
2. **The press preview (§4.1).** Any press on a holdable draws its track at once, and an early lift drains with no harm. One meta-gesture, *press and see*, teaches all ~40 holds.
3. **The lean (new).** After **½ breath** of stillness with the thing on screen, it performs about a fifth of its own gesture and returns. Leans are queued like twins (§4.3), so only one leans at a time:

   | Gesture | Its lean |
   |---|---|
   | Turn | the corner lifts 18% (W2 §8 already has this at 14 s; moved to the lean slot) |
   | Join | one rhyming card's border fills a quarter, clockwise, and drains (0.62) |
   | Carry | the kept-line ember rises 6 pt and settles |
   | Send back | the gilt band fills 20% bottom → top and drains |
   | Counter | the cut line draws 15% from the left and retracts |
   | Wash | one faint ripple circles once |
   | Stack | the drop sinks 10 pt and returns |
   | Ground | the next unit shows 12 pt above the bottom edge and sinks back |
   | Will | its underline fills 20% |
   | Die, deck | one tremble, silent |
   | Verb bead | its ring fills a quarter |
   | Sweep | a faint line crosses the sky once and fades |
   | Eagle-eye (at the sky's widest zoom) | the frame breathes outward 3% |
   | Trace (ring glyph) | a quarter-arc lights round the glyph |
   | Teacher line | a 12 pt hairline starts up the margin and fades |
   | Beat | the page ground pulses once with the heartbeat |

4. **The lean withdraws once his hand has done the act.**
   - `bindu.taught` is a set of gesture ids, binary, never counted.
   - It extends W3 §6.3 GuideVoice into one discovery mechanism: verbal cues withdraw after three completions, and leans after the first.
   - **On a rope day every lean and cue returns** (W3's rule).
   - **FORGET ME clears `bindu.taught`**, so forgetting re-opens the teaching. *The house forgets it taught you, too.*
   - The stillness *completion* stays forever. Only the demonstration withdraws.
5. **The two-stage touch where things cannot label themselves.** The sky (C8), the RoomView marks (existing), the eagle-eye seats, the verb beads when more than about 20 are on screen. The first touch names; the second commits (CLAUDE.md §10).
6. **The answer is the confirmation.** Every completed gesture answers in its own sound (P14) and one haptic. Falling short is silence. The house never says "try again"; silence *is* "not yet".

**What stays undiscoverable by design, and its twin:**

| Gesture | Twin |
|---|---|
| Pointy (two-finger tap) | the trail draws on entering the register |
| The Call (two fingers held) | rope → LAY IT DOWN |
| The Unwritten's un-read | its fill by stillness |
| The Light's eyes-closed and face-down | its stillness gate |

These are secrets, not features. The confession (W3 §7.11) names them in images, which is where secrets belong.

**Authored cues.** The 18 world hand-cues that CLAUDE.md §10 says were never built (`H-150`) are owed. They are the design's own discovery for the Point worlds. W6 §3 should port them in the slice that lets kathas into the worlds (§5 #27).

### 4.5 The Turn as the Veil (B3 / G42), for 24 places

- **The overlay.** `TurnOverlay` becomes a veil drawn up over the current screen (G42: the image dims to about 55% and never disappears). It is one **scrollable column ordered by axis depth**: the Light at the top … the river at z = 0 … the Point and the centre at the foot. Ceremonies sit beside the register they belong to (the Rite and the Return beside z = 0, the Gates beside the Descent's room, the Board and the Draw beside the Door).
- **Opening position.** It opens **scrolled so the current place is centred**, at thumb height.
- **Tiers.** Rows carry B3's tiers: You are here 0.95 · Open 0.82 · Ground 0.62 · Ahead 0.30, behind a dashed line · Veiled 0.16. Never a lock; every row opens.
- **The round lights its rows.** In the evening the Return and the Gates rows are at full (W4 already brightens them); in the morning, the Rite.
- **Closing.** A *tap* closes it (the tap test: < 9 px, < 700 ms), not any pointerdown, so it can scroll. Esc closes. `tap anywhere to stay` stays.
- **Stagger cap.** `0.14 + min(i, 8)·0.075` s. Rows past the ninth arrive together.
- **Opening one-handed.** A slow pull ≥ 84 pt anywhere (C9), the dot mark, and the river's header.
- **The Whole House** row sits at the foot as the veil's floor. The Turn is the list; the eagle-eye is the picture of the same list.

### 4.6 One VoiceOver and label vocabulary for acts

| Word | Means only | Replaces |
|---|---|---|
| **keep** | a line kept into the Book (existing) | — |
| **give** | words given to the Codex or the field | the Door's `keep it` → `give it` (G0 1.4, the Codex's own act) |
| **seal** | close a ceremony with his word | wager return `keep it` → `seal it` |
| **carry** | take into the day (the upward lift) | Gates `keep` → `carry it`; wager `I'll carry this` stays as the line, action `carry it` |
| **lay down** | let go into the ground | ✓ |
| **send back** · **join with…** · **turn** · **draw** · **throw** · **open it now** · **rest a moment** · **receive** | as scored | ✓ |
| the name rite's `keep it` | stays: the name is kept on the device, like a kept line | ✓ |

Every hold's label is `hold to <word>`, and every action name is the bare word. Mechanism words never appear (GAMEPLAN law 10).

### 4.7 Ceremony grammar (forms.md §D) and GRACE, checked

**D (the order is fixed: 1 breath · 2 beats · 3 act · 4 answer in the world's material · 5 close by carving, laying down or sending · 6 a whisper and one warmer light · 7 bowl · 8 return to where you were · 9 proof):**

| Ceremony | Steps used | Breaks / missing |
|---|---|---|
| Rite (existing + W4) | 2 (baton, arrival) · 3 · 4 (gathering) · 5 (seal forward) · 6 "The room has changed." · 7 bowl | **D9 / P7: the wordless seal by stillness with no touch (C1)** |
| Return (W4) | 3 · 4 (strata, three inks) · 5 · 6 | ✓. "Reply: stillness never adds a ring" ✓ |
| Circuit close (W3) | 3 (Will, 0.9) · 5 (word, or silence 1.6) · 4 (the dot splits; a mote) | **D6 has no whisper on screen** ("it is held" is VoiceOver only). Add `Held.` (padakarshini D6 canon), Lora italic 13, under the record, registered APP-OWN with source D6. |
| Gates (W4) | 3 · 5 (G33) · 6 `· passed ·` · after the seventh, one breath of near-black | **D1 missing:** open the first gate with one breath (the 5.5 s ring, or the bindu breathing once before any words). **C11** on keep. |
| Name rite (W4) | 1 (darkness + 12 s) · 3 · 5 (carve-like) · 4 (letters drawn the Name room's way) | **D6:** add `Kept.` after the name assembles. |
| One-line floor (W4) | 3 · 5 (1.6) · 6 "That was the whole story." | ✓ |
| Board arrival at 33 (W4) | the walk read back (elements "the visit told back") | a game, not a ceremony ✓. Mark it with its own page (C16). |
| Season Letter (W4) | grace shape; tap per line | ✓. Own page mark (C16). |
| Wager made (W4) | 3 · 5 (sending) | carry gesture (C11, §3.13) |
| Send back · Reach (W3, W7) | 5 (sending) · 4 (mote or point travels) | ✓ (tones on release, C13) |
| Join bloom / silent answer (W1) | 3 · 4 (bloom, Om) · 6 (the line, or the two verbs) | ✓. A model silent answer. |
| Floor · Compose · Hall · Codex (existing) | as designed | ✓ |

**D8, return to where you were:** layers stay mounted (`RootView`'s ZStack), so the axis depth and the never-restarted Breath carry through every ceremony ✓. Caution for W6 §2.1: only the hub's *home* uses popToRoot + glide to 0. Ceremony exits pop to the depth they came from.

**GRACE (the ending is a gesture, distinct per family; siblings never alike):**
- **Room exits (C17).** One GRACE gesture per room, inverse verb kept:

  | Room | Inverse | Exit (GRACE name) |
  |---|---|---|
  | The Descent | arrive | page rises 24 pt into place and stays still before the fade (**ARRIVE**) |
  | The Ground | rise | the text lifts and fades **while the stain mark stays** 1 s longer (**OUTLAST**) |
  | The Stack | rise | the four bands close up into one hairline (**SQUARE UP**) |
  | The Body | lift | brightness only, no travel (**FILL**) |
  | The Old Light | let pass | glyphs return to points, the reverse of their arrival (**SET**) |
  | The Counter | hand back | unchanged |
  | The Return | offer | scale toward the dot (unchanged, **RETURN**) |
  | The Circle | fold back | rings contract (unchanged) |
  | The Thread | tie | the knot forms at the **leading margin**, not the centre (**TIE**) |
  | The Field | receive | the top half rises, the bottom half sinks, mirroring its crown entry (**PART**) |
  | The Forge | be still | one ember stays at the mended seam as the page fades (**EMBER**) |
  | The Garden | stop chasing | opacity only (unchanged) |

- **Host and twin never end alike (GAMEPLAN law 13).** The CloseConductor needs a check: when a story's rhyme partner was the last story closed (`bindu.met.last`) and both would take the same close shape, the second takes the next eligible shape. Add a test to W2's `CloseConductorTests`.
- **The cream page (C16):**
  - The **dot-at-40% cream page belongs to `BinduLine` alone** (the first line and the farthest).
  - Interludes keep the cream but carry **no dot** (a 5 pt hollow ring in `#3A2A1E` at 0.4, or nothing).
  - The board read-back carries the walked path's beads in a line.
  - The Season Letter carries the season's hue as a 1 pt top edge.
  - The Good Morning letter keeps its gold dot (W5).

**Forms of time (§E).**
- The Board's three breaths (G29) is E.2 *Pace*; keep its beads drawn, never printed ✓.
- The Light's `776 hours` (W6 §8.2, "the amount stated … wall-clock") must render as E.3 *Trail* or E.1 *Aperture*, never as a clock face or a countdown (§5 #29).
- The rope's two breaths is E.1 ✓.

### 4.8 One-handed reach (right thumb, a 6.1–6.3" phone)

| Zone | What lives there after W0–W8 | Verdict |
|---|---|---|
| Bottom-right (easy) | Turn corner · the Board's die · the Draw's die · Mala (river foot) | ✓ ideal |
| Right edge, middle (easy) | axis rail · the eagle-eye lens rail · the Book's gilt edge | ✓ (C5, C7 fixed) |
| Centre (easy) | holds anywhere · the ∞ · the seed · rings · cards | ✓ |
| Top-right (hard) | selvedge titles (top of the trailing thread) · the seek ∞ | the thread's whole height opens the sheet ✓ |
| **Top-left (hardest)** | back chevron · HubTrigger · the Door's dot mark · `‹ leave` · the Turn's top rows | **add G38, the left-edge leave (24 pt in, ≥ 70 pt right; padakarshini's numbers), on every pushed layer, plus the slow-pull Turn (C9) and the Veil opening at thumb height (§4.5)** |
| Two-handed | pinch (eagle-eye, Cloth zoom) · two-finger Call and Pointy | each has a row or action twin ✓ |

### 4.9 Sound in motion and haptics

- **Every hold's tone sounds on the lift** (C13).
- **Every gesture has at most one answering sound.** The 1.2 s transient gate (W2 §3.6) is now naturally kept by the exhale queue for stillness-driven completions.
- **Direction-aware bells for the descents (LATER).** Elements "A bell lower at each step inward, silent on the way out". The Stack already descends 220 → 165 → 137.5 → 110. The Gates should do the same on the 110 root: 220 · 196 · 176 · 165 · 147 · 132 · 110 (just ratios of 110), and stay **silent on the way up**, where the gifts answer with haptics only.
- **One `HapticConductor`** owns G0, `RoomHaptics` and the pulse:
  - never two transients within 0.3 s;
  - a continuous ramp owns the channel while it runs;
  - **Settings gains `haptics off`** beside sound;
  - room-turn haptics play when the turn arrives **by his hand or his dwell**, and are suppressed when stillness auto-advances past it on an untouched surface (P15, P7).
- **The Light stays haptic-free** (W6 §8.1, its own law) ✓.

---

## 5 · Recommended changes to the scores

*Each line: target · change · priority (**MUST** before build · **SHOULD** · **LATER**).*

1. **W0 §4.1 (GESTURES.md seed):**
   - adopt §3 of this file as the seed table;
   - add the columns `stillness kind (twin / accumulator)` and `reveals by`;
   - first law: *a press means what the thing pressed is*;
   - correct the reservations: **Join = 0.7 s** (W1 §4.1) and **Sweep = the sky's pan drag** (W1 §4.2);
   - add the rows missing from the migration table: Hall 1.4, Codex give 1.4, Floor go-down 1.25 ×3, Floor carve 1.6, Light seal-forward 1.6, CallView's loop.

   **MUST**
2. **W0 §3 (HoldEngine):**
   - cancel at **> 10 pt** for stationary holds (24 pt only for travel holds: Stack, drink, G1 read);
   - **press preview** (track drawn and tick haptic at touch-down);
   - **touch count ≥ 2 → release and yield** to the Call or Pointy;
   - **every SoundEngine call in `onComplete` only**; the commit is visual plus the haptic latch.

   **MUST**
3. **W1 §6, W4 §3.1, W4 §3.4:** move the commit tones (Mala `carryTone`, `keep it` blip, deck tone) to the release. **MUST**
4. **W0 §2 + W2 §12a B (the rope):** one behaviour everywhere. It opens at 1.1 s **while held** (G13), never as a G0 act-on-release, and is drawn with one shared ring. **MUST**
5. **W2 §5 / §3.11 (reception):** while `ReceptionView` is mounted the grammar claims every press (`PressClaim("reception")`). No rope on the stage; its twin is the Turn row. **MUST**
6. **W2 §12 CloseConductor + new `Store/StillnessConductor.swift`:**
   - the conductor owns **every** end-of-page stillness slot (signatures, after-things, reverse dissolve, Turn lean and turn, draw path, Beat);
   - resolution is one per exhale (`Breath.exhaleDelay`), in the §4.3 ladder;
   - the same conductor serves reception, the Rite, the Return, the Door and the Board.

   **MUST**
7. **W2 §7.2 (unpaid grace):**
   - the hold twin leaves the white space (the rope's ground) and becomes **G0 2.2 ("open early")** on a 44 pt faint mark (◦, `inkTertiary` 0.35) at the hidden paragraph's place;
   - the 10 s held-stillness path stays (it moves to 20 s in the ladder).

   **MUST**
8. **W4 §3.1 (Door stillness):**
   - 24 s → **30 s**, and it **draws the threshold in and waits**: the lids close to 50% (the blink held at its midpoint, `ease.threshold`), and the Rite offer brightens to full;
   - a touch completes the crossing;
   - Reduce Motion: the offer brightens only.

   **MUST**
9. **W4 §3.5 F, W4 §7.5 walk B, W3 §3.3, W7 §5.3 (the touch budget):**
   - a stillness twin whose completion writes `Story Met`, `Ceremony Sealed`, `Circuit Closed`, `Wager`, `Sent Back` or `Reach` is armed only after a touch on that surface since it opened;
   - walk B becomes "one touch at each surface's threshold, then stillness alone";
   - record it in DECISIONS.md as P7 (law 15 + law 13).

   **MUST**
10. **W3 §9.1 + W6 §2.1 (the river dot):** rest points are the gaps between cards and the band above the first card, never within 30 pt of either edge (the rail owns the trailing edge at z = 0). **MUST**
11. **W2 §12a D (Trace):** remove the weft Trace (W1 §3.2's "the weft has no gesture" stands; the leading gutter stays free for #13). Trace lives on the ring glyph (W2 §3.3) and the spiral (W6 §6.2 C). The weft keeps its 8 s stillness twin and `follow the thread`. **MUST**
12. **W0 TurnOverlay / W4 §3.11 / W3 §4, §7 / W6 §2.5, §6.1, §10.5 (the Turn):**
    - becomes **the Veil** (§4.5): scrollable, ordered by axis depth, opens centred on the current place;
    - B3 tiers; closes on a *tap*, not a pointerdown;
    - stagger capped at 8 rows; `The Whole House` at the foot.

    **MUST**
13. **W6 §2.1 (river top):** a **slow pull** ≥ 84 pt (release speed < 300 pt/s) opens the Turn; a firm pull leans outward through the membrane (the design's own distinction). **MUST**
14. **W4 §3.1 (Door ember):** `keep it` → **`give it`, G0 1.4/0.62** (CodexView's own act and length; it writes the same row). **MUST**
15. **W4 §6.1 + every score's VoiceOver actions:** the §4.6 vocabulary (keep / give / seal / carry / lay down). Gates `keep` → `carry it`; wager return `keep it` → `seal it`. **SHOULD**
16. **W3 §3.3, W4 §3.1–§4.5, W5 §4.10, W7 §3.3 (word fields):**
    - one `Components/BoxlessWord.swift` (grammar D.3): the question above in large italic is the label; the word large in the accent with a blinking cursor over a 0.5 pt rule; `or speak it` with the speak ember beside it; **no placeholders**;
    - the wager return seals by return, by the ash dot or by `seal it` (G0 1.6), all three equal.

    **SHOULD**
17. **W7 §3.3, §6.1 (speak):** capture from touch-down while held (Codex / W4 pattern). Drop the 0.6 s threshold. **SHOULD**
18. **W2 §5.1, §5.3, W4 §3.9 C (going down):** the Ground's rise, the Stack's band and the core-sample all take **G0 1.25/0.62**. The Counter's `chosen` takes 1.2. The Light's weightPassed takes 2.6. **SHOULD**
19. **W3 §10, W4 §4.4, W4 §4.5 (carry):**
    - one gesture: **lift upward 40 pt into the dot** (a mote that follows it);
    - the wager's ember carries by the lift (G0 1.2 dropped; stillness twin unchanged);
    - the Gates' keep becomes this lift (not rise 320 and fade, which is the Unwinding's let-go).

    **SHOULD**
20. **W0 15.6, W3 §8, W4 §3.2, W4 §4.1 (the cream page):**
    - the dot-at-40% cream page belongs to `BinduLine` alone;
    - interludes: cream, no dot (or a 5 pt hollow ring);
    - the board read-back: cream with the walked beads;
    - the Season Letter: cream with a 1 pt hue edge.

    **SHOULD**
21. **W2 §6.3 (room exits):** reassign per the §4.7 GRACE table. Exits run **concurrently with** the 0.5 s dissolve, capped at 0.6 s visible. **SHOULD**
22. **W2 §3.7 + W0 §3 + HeartbeatService:**
    - one `HapticConductor` (no two transients within 0.3 s);
    - Settings `haptics off`;
    - room-turn haptics suppressed on untouched stillness auto-advance.

    **SHOULD**
23. **W2 §12.4 (weight as tempo):** the route dissolve stays 0.5 s; weight sets the reception's first frame (title arrival 2.2 / 1.4 / 0.9 s). **SHOULD**
24. **New `Theme/Motion.swift` (W0, Slice 15):**
    - the five durations, five curves, clocks and Reduce Motion map of §4.2;
    - a `Tools/house_law.sh` rule against hand-written durations and curves in new code;
    - every later score cites a token instead of a curve.

    **SHOULD**
25. **W0 §4.1 + W3 §6.3 (discovery):**
    - GuideVoice becomes `Discovery`: verbal cues (withdraw after 3) **and leans** (withdraw after 1), in `bindu.taught`;
    - rope days restore both; FORGET ME clears `bindu.taught`;
    - the §4.4 lean table is added to GESTURES.md.

    **SHOULD**
26. **W2 §8 (Turn):** a **6 pt folded tip** at the bottom-right corner of every received page at rest (`c` 0.16, the curl mask in miniature). Lean at 10 s; turn at 20 s. **SHOULD**
27. **W6 §3 (Point worlds):** port the 18 authored world hand-cues (`H-150`, CLAUDE.md §10) in the slice that seats kathas in the worlds. They are the design's own discovery for those worlds. **SHOULD**
28. **W1 §4.2 / W3 §9.2 / W6 §5, §7.6 / W7 §6 (sky taps):** the two-stage touch where two or more targets lie within 22 pt (the first names, the second commits). **SHOULD**
29. **W6 §8.2 (`776 hours`):** render the stated amount as E.3 Trail or E.1 Aperture, never as a clock or a countdown. **SHOULD**
30. **W1 §5.4, W3 §7.9 (the Book's trailing edge):**
    - the edge keeps only send back (44 pt hit width, 12 pt drawn);
    - the lit-edge strip and the triptych strips become one 44 pt mark at the page foot.

    **SHOULD**
31. **G38 · the left-edge leave (W0, Slice 14):** on every pushed layer, pointer-down within 24 pt of the left edge and released more than 70 pt to the right dissolves back (never "are you sure?"). Esc does the same. The chevron stays. **SHOULD**
32. **W3 §3.4, W4 §4.3 (whispers, D6):** `Held.` under a closed circuit; `Kept.` after the name assembles. Both registered APP-OWN with source padakarshini D6. **SHOULD**
33. **W4 §4.4 (Gates):** open with one breath (the bindu breathes once, 10 s, before the first gate's words; a touch skips it). **LATER**
34. **W4 §4.4 (Gates sound):** a descending bell on the 110 root inward (220 · 196 · 176 · 165 · 147 · 132 · 110), silent on the way up. **LATER**
35. **W2 §2 RoomCanon:** add `tempo` (law 16, §4.2). **LATER**
36. **W2 CloseConductorTests:** host and twin never close alike back to back (GRACE rule 2, GAMEPLAN law 13). **SHOULD**
37. **W6 §6.1 (eagle-eye):** the lean at the sky's widest zoom (the frame breathes outward 3%, once), so the pinch-out teaches itself. **SHOULD**
38. **W0 §4.1 collisions list:** add C1–C21 of this file (numbered 10 onward, after W4's 10–14), each with its rule. **MUST**
39. **W8 §6 device walk:** add a *real-finger* pass over every collision zone: the end-of-page white, both river gutters, the Book's edges, the dense sky, the Door's four gestures with an ask up, the river top's slow and firm pulls, two fingers on a live hold. **MUST**

---

## Top findings (for the synthesizer)

1. **Stillness can write his day.** The Door's 24 s auto-cross plus the Rite's stillness twins plus the wordless seal can log `Story Met` with no hand. Fix: the touch budget, and the Door draws in and waits (#8, #9).
2. **The space below a story's last line is the most crowded in the house:** the rope, a grace hold that the rope pre-empts, and about eleven stillness clocks that fire together at 14, 16 and 20 s (#6, #7).
3. **The exhale queue:** every stillness completion resolves one per exhale on `Breath.exhaleDelay`, in a fixed ladder. Thresholds for new twins snap to ½ / 1 / 2 / 3 breaths (#6).
4. **The rope behaves two ways** (opens while held on the Door and axis, acts on release in W2), and whole-stage reception holds sit on its 1.1 s (#4, #5).
5. **The Turn breaks at 24 rows.** It cannot scroll (any pointerdown closes it), and W6 takes its one-handed pull. Rebuild it as the Veil, with a slow pull to open (#12, #13).
6. **22 hold lengths and 16 stillness thresholds.** Holds by meaning: going down 1.25 · commit 1.2 · give 1.4 · seal 1.6 · open early 2.2 · lay down 2.6. Speech captures from touch-down (#14, #17, #18).
7. **Same motion, opposite meaning:** rising-and-fading is *keep* in the Gates and *let go* in the Unwinding. "Keep" names four acts. One vertical grammar and one act vocabulary (#15, #19).
8. **Sound and hold timing:** commit tones in W1 and W4 break G0 (sound waits for the lift). A second finger on a live hold also fires the Call. Cancel distance is inconsistent (24 pt vs 9–10) (#2, #3).
9. **Discovery design:** press preview plus the lean (each gesture performs a fifth of itself at ½ breath), withdrawn once learned, restored on rope days and by FORGET ME. Plus visible affordances at rest (the Turn's folded tip) and the 18 owed world cues (#25–#27).
10. **One motion system with Reduce Motion inside it.** Today the app honours Reduce Motion in no view. Five durations, five owned curves, one 0.5 s dissolve, two camera moves joined only at the hinge. Room exits run concurrently with the dissolve, never before it. GRACE reassignments end the six "rise and fade" room exits and the over-used cream page (#20, #21, #23, #24).
