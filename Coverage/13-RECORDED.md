# Coverage/13 — RECORDED, NOT CLOSED

**Ashrey's stop condition, 2026-08-31.** *The goal from here is a whole experience he can
walk, not a fully-corrected build. Those diverged some time ago.*

> **Build only what changes what a surface SAYS or DOES. Record everything that changes a
> number.** Does this alter the sentence the surface makes, or its value? If a walker could
> not perceive it as a different claim, it is recorded, not built.

**These 134 items are RECORDED. They are not closed, not lost, and buildable later.**
Each carries its finding intact — the design source, the app site, and what moves — so
picking one up later costs a read, not a re-derivation.

## The split

| | triaged | BUILD | RECORD |
|---|---:|---:|---:|
| sibling-constant findings (`Coverage/12`) | 106 | 19 | 87 |
| audit rows — OPEN · PARTIAL · NEEDS-JUDGMENT | 72 | 25 | 47 |
| **total** | **178** | **44** | **134** |

44 raw BUILD entries dedup to **37 distinct builds** — six collapses plus one refutation
(F3.2 already ships).

## Why a recorded item is not a closed one

A CLOSED row asserts the app matches the design. None of these do. They assert something
narrower and true: **the app makes the design's claim on this surface, at a different
value.** The distinction matters because `check_audit_ids` treats a CLOSED row as evidence
of behaviour, and a value-divergence recorded as CLOSED would be exactly the false
assertion that put a transposed constant under two closed rows for four passes.

## Sibling-constant findings — 87 recorded

### `asf-keyframe-troughs` · cost M

**What moves** — Five keyframe floors (.34 / .5 / .55 / .20 / .44) become one 0.55→0.95 band across all eight turn rows. Every member still breathes; the amplitude a walker would have to read against a sibling's is what moves. The ember's scale swell (.96→1.07) is absent from TurnMark, but the opacity breath already says the mark is alive.

**Where** — The Door — the turn marks, the rope's ring and ember, the base hint

**Files** — Components/TurnOverlay.swift:76, :95, :106-157 (TurnMark, shape-only Canvas, no scale); Screens/DoorView.swift:304 (SlowBreathe 0.5→0.95), :311 (EmberBreathe10 0.6→1.0 + scale 0.95→1.10), :154-167 (dot mark, static)

### `asf-mark-breath-periods` · cost L

**What moves** — Seven authored periods (13/17/19/21/26/10/15s) render on one 10s clock. The `i * 0.09` phase offsets hold the eight marks permanently out of step, so the claim they carry — each surface breathing in its own hand — still lands; only the rates move.

**Where** — The Door — the turn overlay ("WHERE TO"), the eight marks

**Files** — Components/TurnOverlay.swift:76 (`.opacity(0.55 + 0.4 * breath.eased(offset: Double(i) * 0.09))`), :23-32 (TurnRow has no period field); Instrument/Breath.swift:19 (`period = 10.0`, global), :118-121 (`eased(offset:)` shifts phase only). Building it needs a per-row clock, not a constant.

### `asf-turn-caption-tracking` · cost S

**What moves** — The turn's foot caption is tracked 2.0pt where the design authors 1.8pt (em 2/9 instead of 0.2) — +0.2pt per gap, ~4pt across a 20-character centred line. Same words, same weight, same place; only the metric moves. This is Ashrey's own 0.18em-vs-0.16em case.

**Where** — The turn overlay · 'tap anywhere to stay', under WHERE TO

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:93-94 (member A at :63-64 is exact)

### `bottom-hint-caption-offset` · cost S

**What moves** — Bottom offsets: 40 against 44 on the turn's foot, 34 against 36 on the met Door's hint, and none at all on the unmet Door's hint — which floats ≈83pt up only because an APP-OWN escape line sits beneath it (a separate finding, not this constant's). The captions read the same words in the same voice at the same moment; only their distance from the bottom edge moves.

**Where** — The turn overlay's foot ("tap anywhere to stay") from every top-level surface · the Door's bottom hint in both weathers

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:93-96 (.padding(.bottom, 40)) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:132 (space24 + 10 = 34) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:131-143 (no bottom offset; the app-own escape at :135-143 sets the distance)

### `bottom-hint-caption-tracking` · cost S

**What moves** — The door's base line wants .18em and the turn's foot .2em; both render 2.0pt. Unlike the ground captions these do track — `em: 2 / 9` reaches the helper and is applied — so the chrome voice is present and only the number is off by 0.2-0.4pt on a 9px caption. This is verbatim his record example.

**Where** — The breathing hint at the foot of the Door ("touch to receive") and of the Turn overlay ("tap anywhere to stay").

**Files** — Screens/DoorView.swift:132 `.spaceMonoTracked(9, em: 2 / 9)`; Components/TurnOverlay.swift:94, character-identical; Theme/Theme.swift:151-152 resolves both to 2.00pt. Design: The Instrument v3.html:4379-4380 (1.62pt) and :4407-4408 (1.80pt).

### `canon-light-hex-vs-pool` · cost S

**What moves** — L.hex (#EDE3CE, sky) and L.pool (#FBF9F4, stone) collapse to one app-invented #F5F0E8 — three near-white warm tones a hair apart. The discriminator itself is ported and still speaks: `far` drives the alpha (0.55 vs 0.85) and the radius (17 vs 13), so the Far one already reads as a different kind of thing.

**Where** — The Light — choosing among the six presences

**Files** — Screens/LightView.swift:231 (`let far = sc.material == .nave`, ported), :245-247 (both branches #F5F0E8); the correct pairing exists at :790. The missing far seam stroke (spine-light.js:202) is a separate omission, not this constant.

### `canon-light-scene-wash-alphas` · cost S

**What moves** — Four of six arrival washes carry their own alphas verbatim; the floor's rgba(#FBF9F4, A*0.18*p) has no case in the switch — but it could never fire, because the floor is the one .nave scene and .nave renders LightNave instead: a full stone interior with a shaft, a pool, worn rings and settling dust, flooding dark-to-lit as the scene opens. The missing branch is one vertical wash superseded by a richer arrival, not an unlit register.

**Where** — The Light · 'The floor', the Far scene

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:722-782 (LightDawnArrival, switch at :738 — four cases + default, no floor), :156-165 (case .nave → LightNave(flooding:)), :140-154 (the material switch that keeps LightDawnArrival inside case .dawn); Light/LightCanon.swift:225

### `canon-travel-attack-ramps` · cost S

**What moves** — Three attack ramps move — trail 0.5s→0.4s, gate 0.05s→0.1s, ungrip 0.45s→0.3s — while all four release tails (7.5 / 6.5 / 1.6 / 3.4) are exact. These are envelope values of the '1.1s fade against 1.0s' kind; each voice still enters as the same kind of event, only slightly softer or sharper at its edge.

**Where** — The Instrument · the axis — the leading edge of the trail, the gate, and the ungrip

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1506 (trail `attackSeconds: 0.4`), :1551 (gate `attackSeconds: 0.1`), :1563 (ungrip `attackSeconds: 0.3`). Carry alongside the same lines' peak entry. Design: canon/spine-sound.js:63, :135, :165.

### `canon-travel-node-smoothing-constants` · cost S

**What moves** — Two per-sample smoothing coefficients move: pitch τ≈0.035s against the design's 0.07, level τ≈0.023s against 0.11 — and their order inverts, so loudness settles before pitch instead of after. At 23–35ms both are effectively instant to a listener riding a continuous glide; nothing announces itself differently. (Members 4–5 — the travel voice's noise half and its bandpass at hz×2.4 — have no port at all; that absence is a separate NOT-PORTED finding, not this constant pair.)

**Where** — The Instrument · the axis — the continuous travel voice under every register change

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/AxisTones.swift:129 (`curHz += (goal.hz - curHz) * 0.0006`) and :130 (`curLevel += (goal.level - curLevel) * 0.0009`), in `AxisGlideVoice` :106-142. Design: canon/spine-sound.js:47-51.

### `canon-travel-register-peak-gains` · cost S

**What moves** — Peak gains move: gate 0.048 and ungrip 0.024 both render at 0.03 (−4dB and +2dB), and trail's 1.625:1 partial taper splits evenly. The two events stay distinct in every other respect the ear uses — gate is hz×3→hz×1.5 over 0.9s, ungrip 174→232 over 1.2s with a 3.4s tail — so no voice is mistaken for another; only the mix balance shifts. Already carried as OPEN rows C7.7 (MAJOR) and C7.10 (COSMETIC).

**Where** — The Instrument · the axis register — a gate passing over him, and the field answering an opened hand

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1551 (gate `peak: 0.03`), :1563 (ungrip `peak: 0.03`), :1506 (trail `peak: 0.026, mode: .twin` — the `/(i+1.6)` ladder absent). Design: canon/spine-sound.js:135, :165, :63.

### `chrome-caption-fade-durations` · cost S

**What moves** — #where (1.1) and #pname (1.0) each carry their own constant. The rail carries its child's 0.5 instead of its own 0.9, so the one step-shaped input — hush jumping 0→0.42 the moment a reading opens — lands unanimated; but the refutation showed the comp that authors .9s has no hush term at all, so the severity argument does not hold, and the rail's other two inputs (immA, dom) are frame-continuous and already smooth. #once's 2.4-vs-1.4 is the same Round-1/Round-2 precedence question, not a wrong number.

**Where** — The chrome · the fifteen-register ladder rail, at the instant a reading opens in registers 2–5

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:625-626 (opacity + the 0.5 keyed on here.i), :821-828 (stillnessGate at y:178, 2.4 driven from :374/:384); Instrument/AxisTravel.swift:70-73 (hush's step guard); Instrument/AxisModel.swift:585-605

### `chrome-layer-fade-duration` · cost L

**What moves** — Five chrome layers graded 1.1/1.2/1.2/1.4/1.5s; the seam keeps its own 1.2, and ground and gate carry no duration at all because the app fades all content on one z-driven presence ramp. Tenths of a second between layers is a value. The genuinely different claim inside this group is not a duration — it is the ceremony door, which has no port anywhere — and that is an omission belonging to a door-layer finding, at L, not to this constant.

**Where** — The instrument's chrome as you travel the axis — the Feed seam, the gate, the ground.

**Files** — Instrument/InstrumentView.swift:179 `.opacity(contentOpacity * worldLayer)` (the shared ramp, :132-138) over Instrument/AxisModel.swift:177-179 `1.30 - |(z+5) - i| * 1.30`; the seam's own constant at InstrumentView.swift:507; PointGateView at Point/PointDeals.swift:30-53 carries no animation; no ceremony-door layer exists (0 hits for paintDoors/curDoor). Design: The Instrument v3.html:4358/4387/4423/4429/4623.

### `chrome-where-vs-pname-dominance-fade` · cost S

**What moves** — `(1 - dom)` where the design writes `(1 - dom*0.9)`, on two captions: at a full crossing they reach 0 instead of 0.1 of an already hush- and immersion-dimmed value. Both render as "the chrome goes away while he moves", and the residue is below the floor at which a small caption is visible. (The rail — the structural member where the same defect did read — is already fixed and tested.)

**Where** — The Instrument — the register caption and the particle name, during a crossing

**Files** — Instrument/InstrumentView.swift:568 (#where), :682 (#pname); the correct form lives at Instrument/AxisModel.swift:590-592 (`Immersion.railOpacity`)

### `compose-breath-keyframe-opacities` · cost S

**What moves** — An opacity range (0.34→0.62 over 12s) on a background radial wash never runs. The claim it would carry — "the room is waiting for you and stills once you have spoken" — is already carried on the same screen by two ported breaths under the identical gate: the ember (EmberWake, :242) and the hint caption (HintFade, :254, its own 0.26→0.55 exact). The wash also already answers state by brightening with progress.

**Where** — Ash's Compose — the arrival glow above the ember, while the field is still empty

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshComposeView.swift:112-131 (arrivalLight, inserted bare at :70, no modifier, no breath read) · :439-444 and :449-454 (the two breaths that are ported, applied at :242 and :254)

### `compose-ready-fade-delay` · cost M

**What moves** — The comp raises the writing space, then the ember 0.2s behind it; the app nests the ember inside the writing space so both arrive on one 1.4s curve. The duration is correct on the member that has a site, and what is lost is a 200ms stagger — a fifth of a second between two halves of one screen. His delay-is-a-claim case turned 2400ms into a change of speaker; 200ms does not change who is speaking.

**Where** — Ash's Compose, on arrival — the page appears and the ember to hold appears with it.

**Files** — Screens/AshComposeView.swift:200-201 `.opacity(ready ? 1 : 0)` + `.animation(.easeOut(duration: 1.4), value: ready)` closing writingSurface (:164-198); emberControl (:211-256) is reached at :196 from inside that VStack and so has no gate of its own; `ready` flips once at :100-101. Cost is M because the fix is structural — the control must leave the parent's stack to take a delay. Design: comps/Ash's Compose.html:191 and :227.

### `fieldsound-bed-duck` · cost M

**What moves** — The bed does not step back while a presence speaks (design 0.030 → 0.018 for the duration of the voice). It is a 4dB dip on an already-quiet bed under a voice that is louder than it; the strike's duck — the one that is genuinely audible, 0.030 → 0.006 held nine seconds — is ported exactly. A voice speaks in a room either way. DUPLICATE of `fieldsound-bed-duck-depths`.

**Where** — The Rite / the Field / the Return — any moment a presence speaks over the bed

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1155-1163 (`presence(_:dur:)`, touches the bed nowhere); the mechanism to reuse at :1582-1607 (`duckBreath()`); its constants at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/RiteTones.swift:45-49 (a voice depth/in/out would be added alongside)

### `fieldsound-bed-duck-depths` · cost M

**What moves** — Same absence as `fieldsound-bed-duck`, carrying the voice's times as well as its depth (in at t+atk, out at t+life+1.6). Depth and timing are both values on a bed that is quiet under the voice ducking it; the bowl's three-times-deeper floor and nine-second return are already exact. Recorded as one entry with its twin.

**Where** — The Rite / the Field / the Return — any moment a presence speaks over the bed

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1155-1163, :1373-1395 (`playCeremony`, no bed handling); :1582-1607; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/RiteTones.swift:45-49

### `fieldsound-default-durations` · cost S

**What moves** — On the leave path the app passes 6 to `lightOff`, whose own design constant is 5 (the 6 belongs to `closeTheRoom`), and `lightOpenTheRoom` defaults to 8.5 where the design says 5. The sentence survives intact: the nave IS closed on leave — `darkReturns()` ramps the reverb 85 → 50 at SoundEngine.swift:1338-1345 — so this is one second on a fade and 3.5 on a swell, not a room left open behind him.

**Where** — The Light · 'walk back out', and the opening of the nave on arrival

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1180 (`lightOpenTheRoom(dur: Double = 8.5)` → 5), :1258 (`lightOff(dur: Double = 5)`, correct and never reached); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:412 (`lightOff(dur: 6)` → 5)

### `fieldsound-open-vs-close-the-room` · cost M

**What moves** — Leaving the Light fades the room tone over 6s and returns the reverb to its base air over 7s, where the design fades the tone over 5 and drains the nave over 6. The room does close — the app collapses the design's additive nave onto one reverb whose 50 baseline IS the design's rest state — so only the two durations move.

**Where** — The Light · the walk back out, and the open on arrival

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:412-413 (`lightOff(dur: 6)` then `darkReturns()`); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1180-1192 (lightOpenTheRoom default 8.5 — call site LightView.swift:573 passes 8.5, matching the design's own call site), :1331-1350 (darkReturns ramps wetDryMix back to 50 over 7), :429-435 (the single reverb, baseline 50)

### `gameview-crossfade-out-vs-in` · cost S

**What moves** — The room-to-room cross-dissolve fades in over 0.28s instead of 0.4s, so departure and arrival take the same time rather than leaving fast and settling slow. Same motion, same sentence — only the second half's speed moves, by 120ms. The out-half and the swap timer are both correct.

**Where** — Game View · stepping from one room to the next

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift:437-439 (the fade-in, carries 0.28 where the design's false ternary half is 0.4); correct siblings :431-433 (out) and :434 (swap timer); four scoped repeats at :45, :55, :61, :81

### `gameview-navbar-two-captions` · cost M

**What moves** — The nav-bar room name is Lora 12 at ink60 restyled per room where the design has one uniform 9pt tracked uppercase mono at ink35, and the counter below took the tracking and case that belonged to it — a font, a tier and a case on a wayfinding label that names the same room in the same slot, whose identity is already carried in the room's own bespoke hero type directly beneath it.

**Where** — Any of the thirteen rooms · the floating nav bar's centre column

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift:193-211 (navBarRoomLabel), :141, :143-145 (the counter)

### `gameview-per-room-glow` · cost M

**What moves** — Every hero glyph's halo resolves through one formula (heroGlyph × 0.30) at two fixed alphas instead of each room's authored blur+alpha, so radii and alphas all move — descent loses most (30→13.2), watcher and forgetting land byte-identical. A glow radius and an alpha; the rooms still read as distinct places through thirteen hand-ported gradients, their own colours and their own glyphs.

**Where** — Game View · the hero glyph at the top of each of the thirteen rooms

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift:167 (`glow: style.heroGlyph * 0.30`); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:60 (`glow ?? size * 0.20`), :67-68 (fixed 0.55 / 0.35); RoomStyle has no glow field — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/RoomStyle.swift:8-15

### `glsl-parting-hand-vs-back` · cost L

**What moves** — The shader's `uBack[9]` term is absent, but the claim it carries — a veil once parted never closes all the way again — is already spoken three ways on the surface: `partedOnce` latches mid-drag, the cue turns from "PART IT WITH YOUR HAND" to "PART IT AGAIN, SOMEWHERE ELSE", the 0.06 floor reaches the sound, and `part` latches at 1 after a real parting so the veil visibly stays open. What is missing is the per-zone geography — which patches stay thin — and the .86/.30/.05 that shape it. The app's scalar-instead-of-zone-list is a divergence its own comment records.

**Where** — The Point, world III — the veil, after parting and letting go

**Files** — Instrument/InstrumentField.metal:125-130 (mVeil: `p` written once, no loop, no max), :186-188 (entry point declares `float3 uHand` and no back buffer); Point/PointWorlds.swift:495-498 (uHand feed, honest), :512-518 (`veilFloor`, the recorded divergence), :625-626 (`.parted(_, floor:)` → Point/PointWorldView.swift:72, sound only)

### `gold-caption-opacity` · cost M

**What moves** — Opacity .66 rendered as 0.7 on the section label; and the sheet's gold eyebrow is absent, but the register's roman-and-name is already spoken to the walker twice over — by the reading's own footer (PointReadings.swift:226-235) and by the universes header that renders the identical words (PointWorlds.swift:202). No naming is lost, only a repetition of it at a different gold.

**Where** — Any Point reading — the small gold label above each section; the Dance reading's missing eyebrow

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:214-215 (hue.opacity(0.7), one definition, seven call sites) · :237-251 (ReadingHead — no slot for `#sheet .st`) · :226-235 (ReadingFooter, which already names the field)

### `ground-headline-sizes` · cost S

**What moves** — The door's prose voice wants 26 and the story title 25; both render 22. Four points short and a one-point descent erased — the same two voices, in the same order, in the same faces, with the design's own italic/weight-500 fork correctly ported. His stated record case is a font-size two points off; this is that, twice. (The third member, the 27px h1, the refutation already withdrew — the app's unmet line follows a ruled instruction from The Rite.)

**Where** — The Practice Door, met weather — the prose the door speaks, and the story title beneath it.

**Files** — Screens/PracticeDoorView.swift:204 `.font(italic ? .loraItalic(22) : .lora(22, weight: .medium))` (proseBody, called :175/:182/:194) and :227 `.font(.lora(22, weight: .medium))` (storyDoor). Design: The Instrument v3.html:4370 (26) and :4376 (25).

### `ground-italic-sizes` · cost S

**What moves** — Two sizes and an ink: the unmet Door's italic line renders 13/ink .35 where the design says 16/ink .60 (the app ported the Rite's arrival treatment of the same sentence), and the story pull-quote renders 14 where the design says 15. Same words, same place, same italic voice, same moment — the letters are smaller and fainter.

**Where** — The Door, unmet — "It is not complete until you meet it." under the head · the Practice Door, met — the story pull-quote and the practice sub-line

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:127-129 (.lora(13).italic(), inkTertiary) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:234-241 (.loraItalic(14) against 15; :183-188 the sub-line is correct at 14) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteView.swift:179-181 (the same treatment repeated)

### `ground-measures` · cost S

**What moves** — Four max-widths: 320 where the design says 300, 313 where it says 300 and 280, 290 correct. Nothing is said differently — the lines wrap at slightly different points, and the design's narrower-italic-under-a-wider-head relation flattens by 13 and 20 points.

**Where** — The Door, unmet — the head and its italic line · the Practice Door — the body and the story line

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:209 and :233 (.frame(maxWidth: 320); :241 is correct at 290) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:120-129 (no maxWidth on head or under-line) and :145 (.padding(.horizontal, 40) governing both)

### `ground-stanza-lead` · cost S

**What moves** — The glyph's 40px lead is replaced by the VStack's uniform 18pt — but the refutation broke the pairing: the app's Door stanza is not #ground's unmet stanza at all. The design's has three members (glyph → 27px meeting line → italic under); the app's has five, with the title and room name coming from The Rite v3's Movement I. The 40 would be applied to a composition the design never drew. A gutter moves; the stanza's voices do not change rank.

**Where** — The Door · the unmet stanza, glyph above the meeting line

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:117-129 (VStack spacing: 18, glyph at :119). Member B is correct with its own 36 at Screens/PracticeDoorView.swift:120-125.

### `ground-weather-primary-glow` · cost S

**What moves** — The unmet door's sky is the design's gradient, at the design's centre (0.5, −0.08), in the day's own room colour — at 0.16/0.03 instead of 0.34/0.10, and static where the design multiplies by the breath. Same sky, half lit. (Member B was refuted in the report as a false pairing; only A stands, and the horizon hairline and bottom cap are separate omissions, not this constant.)

**Where** — The Door, unmet — the sky above the story that has not been received

**Files** — Screens/DoorView.swift:111-112 (`RadialGradient(colors: [room.opacity(0.16), room.opacity(0.03), .clear], center: UnitPoint(x: 0.5, y: -0.08), … endRadius: 520)`)

### `immersion-body-leading` · cost M

**What moves** — Type sizes and leading: the reading body sits at a flat 15.5/1.39 where the design runs 14.5/1.76 rising to 16.5/1.86 on immersion, the fall at 15/1.74 against 18/1.78, the Light anchor at 16.5/1.70 against 16.5/1.86. The sentences and their order are identical; only the measure of the letters moves — and the app's reading is already full-screen, so nothing about entering is being withheld from the walker except a 1pt lift.

**Where** — Any Point reading as it is given (immA is live — InstrumentView.swift:921 raises it, and the chrome, rail and world layer already recede by it) · the Universe's fall panel · the Light's anchors

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:214-217 (SectionBlock, flat 15.5/lineSpacing 6, no immersed branch) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:574 · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightType.swift:30-31 (consumed at LightView.swift:361)

### `immersion-body-size` · cost L

**What moves** — The design swells reading body 14.5→16.5 on entering and the app holds a flat 15.5 (and sets #word p at 15 against 18) — a value on one channel of a claim the app already makes on others: the field dims, blurs and recedes when he goes in, so "you are inside this now" is said, just not by the type.

**Where** — The Point · a reading panel when entered; The Universe · the fall's word

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:217; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:574; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightType.swift:30 (correct)

### `immersion-padding` · cost L

**What moves** — Padding: `.imm`'s 104/34/148 full-bleed override has nothing to release in the app because the app's readings are already full-bleed ScrollViews over an ignoresSafeArea ground (PointReadings.swift:358-380), and the Light's horizontal 38 is ported exactly — only its 104 top and 150 bottom are absent, replaced by bare Spacers and a fade mask. Column position moves; no surface says anything different.

**Where** — The Light's scene column · any reading once three sections are given

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:343-345, 438-440 (Spacer / .padding(.horizontal, 38) / Spacer; no 104, no 150) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisTravel.swift:77 (`immersed` — live but read by no view) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:358-380 (the reading container that would have been the `.imm` target)

### `letterpress-shadow-alpha` · cost M

**What moves** — A 1px emboss (.9 dark below / .14 light above) is absent from the chamber's title; the words, size, position and register are unchanged, and the app already makes the chamber's "struck into the wall" claim in its own idiom — the 1.5pt strike rule down each section's leading edge (PointReadings.swift:734-736), the deepening impression bar, and the molten floor gradient. The missing shadow is texture on a claim already made.

**Where** — The Chamber (register IV, ReadPressing) — the reading's head and body after a section is struck

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:237-251 (ReadingHead, shared by all seven readings at :360,467,562,728,935,1084,1261 — no site can carry the wall's shadow without giving it to the six panes the design leaves flat), :206-223 (SectionBlock, the body the design also inscribes at The Instrument v3.html:4550) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:101-103, 377-378 (member B's light half, 0.16 against .10)

### `levels-constellation-star-opacity` · cost S

**What moves** — Both label opacities are exact and correctly polarised (0.56 seeded / 0.86 walked); the missing member is the 6px status word ('walked' / 'in progress' / 'seeded') nested inside the label at 0.42. The star already states its status twice — by glyph (●◐○) and by that label alpha — so the word restates a claim the surface is already making.

**Where** — The Point · a world's constellation, each star mark and its label

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:62-84 (`StarMark`; the word would join the HStack at :69-71), with the word table already present at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointDeals.swift:58-65

### `light-mono-chrome-opacity` · cost S

**What moves** — Same two members as `lightv2-mono-chrome-opacities` and the same single fix: 'touch once' at 0.6 against the authored 0.55 (a value), and the 0.5 mono kicker 'The Light' never ported. Recording both under one entry so the file batch does not touch LightView.swift:196-198 twice.

**Where** — The Light · I the Approach, the bottom-anchored caption column

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:196-198; column at :180-203

### `light-scene-wash-alpha` · cost M

**What moves** — Five of six arrival washes are exact — own constant, own colour triple, own gradient geometry, both secondary constants included. The sixth (`floor`, A*0.18*p over the pool) has no site because the floor is the nave, and the nave arrives by its own complete mechanism instead: LightNave flooding dark→lit as the scene opens. "Each scene arrives its own way" is spoken on all six; one gradient layer's alpha is what is absent.

**Where** — The Light — the arrival of each Future scene, and of the floor

**Files** — Screens/LightView.swift:722-783 (LightDawnArrival, the five), :154 (its mount, dawn-only), :157-163 (`case .nave:` → `LightNave(breath:still:flooding:)`); Light/LightCanon.swift:225 (`key: "floor", material: .nave`)

### `lightv2-mono-chrome-opacities` · cost S

**What moves** — 'touch once' renders at 0.6 where the comp authors 0.55 — same base token (#EDE8E3 @0.35), same words, same moment. The pair's other half, the mono kicker 'The Light' at 0.5, is absent, but its content is the register name the walker just tapped in the Turn overlay to get here, so its absence subtracts a restatement rather than a claim. DUPLICATE of `light-mono-chrome-opacity` — same two design lines, one fix.

**Where** — The Light · I the Approach, the bottom-anchored caption column

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:196-198 (0.6 → 0.55); the absent kicker would go above :183 in the column at :180-203

### `lightv2-risefade-durations` · cost S

**What moves** — The rise takes 1.4s and 0.6s where the design writes 2.4s and 2.6s, and the pair's order inverts — but the same lines arrive in the same order in the same place; only the speed of the fade moves, which the ruling files as a value.

**Where** — The Light · anchors and the Declaration, as each line arrives

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:607 (anchors, 1.4), :660-661 (Declaration, 0.6)

### `lite-block-rhythm` · cost S

**What moves** — Four block gaps (26 · 34 · 32 · 24) render at roughly half (14 · 20 · 12 · 8) and one is a gap below rather than above — the page is tighter, but the same blocks arrive in the same order with the same weights, and no block changes what it is.

**Where** — The Light · the lite reading — anchors, Declaration, its cue, the landing

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:363, :392, :421, :435; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightType.swift:33

### `lite-caption-tracking` · cost S

**What moves** — The surviving cue is tracked at the house default 2.0pt (em 2/9) where v3 says 8.5px/.26em (2.21) and the comp the app actually built from says 9px/.30em (2.7). Under either source it is a metric, not a claim. The real residue in this group — .vec, the 'FUTURE · FORCE → SURRENDER' opener, with no kind/vector on LightScene at all — is a missing caption, not a missing constant, and it is exactly the precedence question this group was marked UNCLEAR on: the per-register comp governing the app's Light has no .vec.

**Where** — The Light · the reading's mono cue under the beat

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:431-434; helper Theme/Theme.swift:151-153. The .vec residue would be L: Light/LightCanon.swift:12-22 has no kind/vector field on any of the six scenes.

### `lite-text-sizes` · cost S

**What moves** — Three of four sizes differ from The Instrument v3 — but the refutation showed the app is a faithful member-for-member port of The Light v2.html, including that comp's authored travel (the whole falls 21→15 as the reading settles). Nothing is permuted. What is in dispute is which design file governs a register that has no Round-2 comp, and the answer changes four font sizes by 2–5pt. Deciding it is a precedence ruling, not a build.

**Where** — The Light · the type ladder inside a reading — whole, anchors, beat, landing

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightType.swift:19 (wholeSize 21/15), :30 (anchorSize 16.5), :37 (beatSize 21), :43 (landingSize 18); applied Screens/LightView.swift:350, :361, :375, :383, :397

### `mirror-caption-tracking` · cost S

**What moves** — The Mirror's three mono captions render at 0.250 / 0.236 / 0.200em against the design's 0.26 / 0.30 / 0.18 — two are inside noise and the title is 21% short. Tracking on a caption: the register mark, the title and the hint stay recognisably the same Space Mono uppercase chrome, saying the same thing.

**Where** — The Mirror · the STILL LIVING register mark, the THE MIRROR portal title, the draw hint

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:74-76 (`.spaceMonoTracked(11).tracking(2.6)` — should be 3.3), :145-147 (`.tracking(1.8)` at 9 — 1.62), :299-301 (`.tracking(2.5)` at 10 — 2.6). All three chain an absolute `.tracking()` past the helper's `em:` door at Theme/Theme.swift:151

### `mirror-leaving-timeouts` · cost S

**What moves** — The draw's window is exact at 620ms; its fade is 0.62 where the design says 0.55, which closes the ~70ms of held emptiness between the old face going dark and the new one mounting. Four frames of black. (The pair's other member, passDay/480, is an absent affordance — the day is not offsettable at all — which is a feature question, not a constant.)

**Where** — The Mirror · drawing an alternate reflection

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:242 (`.easeInOut(duration: 0.62)` → 0.55; the 0.62 at :243 is correct and stays), the flag's visual at :123-124

### `passage-throat-rings-vs-walls` · cost L

**What moves** — The walls — 52 radial streaks under a lighter blend, and the spin that exists only for them — are unported, so the crossing's tunnel does not rotate and has no streaked skin; the build envelope is missing too, so the throat inserts and cuts at full alpha. But the rings, the acceleration, the aperture flood and both gates are there, and the surface still says the same thing: a throat you are falling through. What is missing is depth of drawing, not a different claim, and it costs a whole new draw loop.

**Where** — The passage · the crossing between registers, both directions

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:955-981 (ThroatView — rings + aperture only; the 0.5 at :968 is 0.52 rounded), mounted at :212-215 with a bare `if travel.crossing`. Design: Claude Design Round 1/The Instrument v3.html:3636-3667.

### `players-glow-radius` · cost S

**What moves** — Eleven halo radii (9…28) become five (7…18) with six presences sharing `default: 10`. The ordering that carries the claim survives — Bindu still burns most, Shweta least — and only the amounts move. The one rank inversion is the Ashram (design 18, third-brightest → app 9, dimmest), and it sits on a full-width card of its own below the grid, with nothing beside it to be ranked against.

**Where** — Players — the ten presence cards and the Ashram card

**Files** — Screens/PlayersView.swift:340-348 (glowRadius switch), :325 (its consumer), :433 (`.shadow(color: archetype.color.opacity(0.5), radius: 9)` in AshramCard)

### `point-dim-vs-faint-tokens` · cost M

**What moves** — The Point's own --dim/--faint (.56/.22 on #EDE6D6) render through the global ink tiers (.60/.35 on #EDE8E3), so hints sit brighter than authored — two tiers still, in the design's order, with every element in its own role.

**Where** — The Point · voices, sub-heads, hints, counts, the rope's labels

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:34-35; consumers /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:205, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:224, :508

### `point-ink-tokens` · cost M

**What moves** — Two alpha tiers move and keep their order: --dim .56 renders at 0.60, --faint .22 at 0.35, because both roles were pointed at the Feed's global ink pair (which are the Feed's OWN correct numbers). The faint tier is 1.6× more present than designed and the ratio between tiers compresses 2.55× → 1.71×, but dim is still dim, faint is still faint, and no surface says anything new.

**Where** — The Point · every world — hints, back links, minor stage text, the 'enter a universe' line

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:34-35 cannot simply move (they are A Strange Feed's own correct tokens, commit 83c8b70); a Point-local pair would be needed, then repointed at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:205,215 · PointWorldView.swift:224,234,258,508 · PointReadings.swift:244 · PointRevealView.swift:81. Design: Claude Design Round 1/comps/The Point v9.html:11.

### `pointsound-voice-peak-gains` · cost L

**What moves** — Five of six peak gains are exact on their own members; the sixth, step()'s 0.035, has no port because the mechanism it belongs to has none — moving between enclosures is an equal-power crossfade of beds rather than a tone swept from one world's pitch to the next. The move still sounds like a change of place; it is the travel between them that is unbuilt, and D7.4 is already OPEN over exactly that.

**Where** — The Point · crossing from one world/enclosure to the next

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:284-313 (`setContext(.point(...))` → `crossfadeTo`, the level crossfade that stands in for the sweep); the five correct siblings at :302, :753, :768, :1034, :1098

### `practice-door-animation-durations` · cost M

**What moves** — Ember 4s, door 10s and hint 4.5s all render at 10s in exact phase — but every one of the four amplitudes is exact, and the shared period is the same one-master-breath doctrine as the Signal pair, asserted in place three times over. The door's own 10s is right; the other two move on the doctrine's axis, and the doctrine is Ashrey's, documented, and already recorded as open.

**Where** — The Practice Door · the ember, the atmosphere and the tap hint, breathing together

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:149 (door), :257 (hint), :334-342 (EmberBreathe, applied :217); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/Breath.swift:20 (period 10.0), :23-47

### `practice-door-breath-keyframe-bounds` · cost S

**What moves** — All three opacity floor/peak pairs land on their own animations exactly, despite the numbers aliasing across the set. The single miss is doorBreath's transform half — a scale(1)→scale(1.04) on the pre-dawn radial gradient behind everything. A 4% swell on a soft background wash, under an opacity breath that is already correct: the value moves, the room says the same thing.

**Where** — The Practice Door · the breathing pre-dawn atmosphere behind the ember

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:141-149 (atmosphere; opacity 0.34+0.44·v correct, no scaleEffect). The ember's scale sibling is ported in full at :340.

### `rail-i-vs-u-transition` · cost S

**What moves** — The surface-dot's 0.8s settle was never carried across — the Canvas animates only on `here.i`, so a 3px dot at the screen edge snaps from hollow to filled instead of easing. The sentence it makes — this surface is now open, and stays open — is identical either way, and it is made at a moment when the walker has just done the meaningful thing somewhere else on the screen.

**Where** — The Instrument — the rail's surface-dot, at the instant a surface is meant

**Files** — Instrument/InstrumentView.swift:612-616 (the `opened[s]` branch, nothing animates on it), :626 (`.animation(.easeInOut(duration: 0.5), value: here.i)` — the tick's own 0.5s, correctly ported)

### `reading-panel-body-alpha` · cost S

**What moves** — Design body ink is .90 in four panels and .92 in the wall, over three near-identical bases (#F0ECE7 / #F0EEF6 / #F6ECE4); the app renders #EDE8E3 at 1.0 everywhere, and thins III to 0.72. Alphas and two-point hue shifts on body text that stays in the same place, at the same size, saying the same words. The one entry worth recording first is III's 0.72 against .90 — the veil's reading is fainter than the design makes it — but it is still an alpha, which is his stated fail case.

**Where** — The body text of every Point reading.

**Files** — Point/PointReadings.swift:219 `.foregroundStyle(BinduTheme.inkPrimary.opacity(thinned ? 0.72 : 1))` in the shared SectionBlock (:206-224); `thinned: true` only at :564-565 (III · THE VEIL); Theme/Theme.swift:33 inkPrimary = #EDE8E3. Design: The Instrument v3.html:4450/4477/4500/4523/4549. (The wall's letterpress text-shadow at :4550 is a separate absence, not this constant.)

### `reading-panel-fade-duration` · cost S

**What moves** — Seven panel-root fades of .9/1.4/1.1/1.2/1.1/1.2/1.3s are served by one 0.8s at the presentation site. The spread is half a second on an opacity ramp with no design prose attached to any member; the reading still arrives, at the same moment, the same way. Ashrey's own record example (1.1s against 1.0s) is this case at nearly this size. Distinct from sec-arrival, which is a 4.4x spread the design annotates per movement.

**Where** — Opening any Point reading from the world — the panel's own arrival, before any section is given.

**Files** — Point/PointWorldView.swift:218 `withAnimation(.easeInOut(duration: 0.8)) { openStar = s }`, flipping the ZStack branch at :171-184; the reverse path is a bare `withAnimation { openStar = nil }`. Design: The Instrument v3.html:4438/4467/4487/4511/4536/4591/4603.

### `reading-panel-h2-size` · cost S

**What moves** — The sheet's title wants 25px against the four movements' 24 and all five render 24; the weight is 500 where the design says 400. One point of size and one step of weight on a serif title — it is the same title, in the same place, saying the same thing. Ashrey names a font-size two points off as a value, and this is one.

**Where** — The title line at the head of every Point reading.

**Files** — Point/PointReadings.swift:246 `Text(star.t).font(.lora(24, weight: .medium))` — the single expression serving all seven readings. Design: The Instrument v3.html:4445 (25px/400/1.24) vs :4470/:4492/:4516/:4540 (24px/400/1.26).

### `reading-panel-lab-alpha` · cost S

**What moves** — Four section-label alphas (.60 / .64 / .74 / .78) collapse onto 0.7. The hue half of every one is byte-exact per world — the label still takes its own panel's colour, which is the part that carries the claim — so what moves is only how bright that colour is, within four hundredths of the design on two of the four.

**Where** — The Point · the reading panel — the small mono section labels inside each world's reading

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:215 (`.foregroundStyle(hue.opacity(0.7))` in `SectionBlock` :206-216), shared by all seven call sites :362, :469, :564, :730, :941, :1086, :1263. Design: Claude Design Round 1/The Instrument v3.html:4476, 4498, 4522, 4547.

### `reading-panel-quote-alpha` · cost S

**What moves** — Quoted sections want .66-.70 against the body's .90 — a step back in ink — and the app renders quote and body at the same alpha. The distinction is not lost, only its depth: PointReadings.swift:217 still sets the quote in italic, so a walker still meets the say/open sections as a different voice. Ashrey's hierarchy case is a reply that stops being a reply; here the relation survives and only the recession is flat.

**Where** — The `say` and `open` sections inside any Point reading, set against the surrounding body.

**Files** — Point/PointReadings.swift:217 (the italic fork, correct) and :219 (one alpha for both) in SectionBlock. Design: The Instrument v3.html:4451 (.66), :4478/:4501/:4524 (.68), :4551 (.70 on a warm 240,222,206).

### `reading-panel-sec-margin` · cost S

**What moves** — Design 19/17/18/17/17px between sections; app writes VStack spacing 22 at every site. A 3-5pt gap on a reading stack — the sections sit where they sit, in the same order, at the same weight. Same sentence, looser leading.

**Where** — The gap between sections inside a Point reading, all seven worlds.

**Files** — Point/PointReadings.swift:359, :466, :561, :727 (and :934, :1083, :1260) — `VStack(alignment: .leading, spacing: 22)`. Design: The Instrument v3.html:4447/4472/4494/4518/4543.

### `reading-panel-side-padding` · cost S

**What moves** — One measure where the design has five: 28 / 34 / 30 / 32 / 30 all written as 32 (top 20, bottom 90 for 22/96 on I). A 2–4pt inset difference between panels a walker never sees side by side — the reading still sets the same width of line and says the same thing.

**Where** — The Point · the reading panel of each world — I THE POINT, II THE TURN, III THE VEIL, IV THE CHAMBER, VII THE DANCE

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:382, :485, :571, :772, :961, :1109, :1293 (each `.padding(.horizontal, 32).padding(.top, 20)` with a `Color.clear.frame(height: 90)` spacer above). Design: Claude Design Round 1/The Instrument v3.html:4435, 4466, 4484, 4508, 4533.

### `reading-panel-ti-margin` · cost S

**What moves** — The subtitle-to-first-section gap wants 18/16/16/15/15px per panel and instead inherits the enclosing stack's uniform 22. A 4-7pt gap under an italic subtitle; the subtitle still sits under the title and above the first section, in the same relation. Value, not hierarchy — nothing changes rank.

**Where** — Directly under the italic subtitle at the head of any Point reading.

**Files** — Point/PointReadings.swift:242 `VStack(alignment: .leading, spacing: 4)` inside ReadingHead (:237-251), whose trailing gap is the parent stacks' `spacing: 22` at :359/:466/:561/:727. Design: The Instrument v3.html:4446/4471/4493/4517/4542.

### `return-ink-tokens` · cost S

**What moves** — The app's ink ladder stops at two rungs, so the design's faintest rung (0.2) has no home: the Anew counter and the Sealing's plain line come up at 0.35 and 0.60 instead of 0.2, and the Record's role label at 0.22. Chrome captions get louder; every caption still says the same thing in the same place, and the loudest single move (sealPlain 0.2 → 0.60) sits under an ash marker on a screen whose other elements are unchanged.

**Where** — The Return · IV the Record (role label), V Anew (the counter), VIII the Sealing (the plain line)

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:33-35 (the two-rung ladder; a third rung would be added here); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:309 (0.22 → 0.2), :389 (inkTertiary 0.35 → 0.2), :603 (inkSecondary 0.60 → 0.2, and font 14 → 12)

### `return-past-self-rendered-twice` · cost S

**What moves** — The design's second copy of the block never mounts, so rendering it once is right; what is left is metrics on the same words — 15 against 16/16.5, leading ~1.4 against 1.78, the trailing sentence's gap 6 against 18, and a missing 0.94 opacity.

**Where** — The Return · IV The Record, the sealed self behind its ash rail

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:322-326, :332

### `return-seal-label-tracking` · cost S

**What moves** — Three of the Return's ◉ mono labels track at 0.056em where the design says 0.18–0.2em, inherited from a pre-existing flat 0.5pt house default that a case-sweep laundered into em notation. Letterspacing only — the labels are still Space Mono uppercase 9pt in ash, in the right slot, saying the right words.

**Where** — The Return · the ◉ labels above the Record's sealed self, the Reply, and the Sealing

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:321, :499-500, :601 (all three `em: 0.5 / 9`). Correct siblings on the same screens, for the target value: :247 and :361 (`em: 0.18`)

### `return-threshold-tones-per-crossing` · cost S

**What moves** — The fourth threshold tone (field → rings) sounds for 7s instead of 8. All four frequencies are exact and on the right crossings; the collapse was performed by the design itself — The Return v2, the document the app cites, refactored the four calls into one helper with 7 hardcoded — so this is a lineage precedence question about one second, not a port fault.

**Where** — The Return · the tone struck at each of the four crossings between movements

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:192-193 (the shared `cross(_:_:)` helper, `dur: 7`, correctly citing The Return v2.html:1314); call sites :254, :268, :333, :400. The 8 exists only at comps/The Return.html:706

### `returnv2-patina-saturation` · cost S

**What moves** — The .pressed filter (saturate .5 / sepia .14 / brightness .92) over the Record's six gathered voices was ported correctly at Wave 5 and then deliberately deleted, with the reason written in place: one flat treatment over six materials made age read as dimmer rather than older, and per-voice ReturnPatina.towardGold hues now carry the same claim better. Re-adding it moves saturation on a block that already says 'aged' — the sentence does not change.

**Where** — The Return · Movement III, the Record's six gathered voices

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:292-319 (the block, now carrying towardGold), :285-291 (the comment stating the deletion and its reason). The .dried sibling is intact at :325 and :504.

### `rite-breath-keyframes` · cost M

**What moves** — The Rite's two named breaths are one modifier at 0.28→0.70. Two of its three sites are breatheSoft elements whose design range is 0.30→0.62 — a value away; only `finding the words…` is in the wrong register, and its consequence is that one line breathes dimmer than authored. The heartbeat sibling is ported exactly, breakpoint for breakpoint.

**Where** — The Rite · `touch to receive` (Door), `received at the pace of breath` (Reading), `finding the words…` (Recognition)

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteView.swift:20-24 (`RiteBreathe` — `content.opacity(0.28 + 0.42 * breath.value)`); sites RiteView.swift:256, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:134, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteRecognitionView.swift:116. MATCHED sibling: RiteGatheringView.swift:165-173

### `rite-keyframe-troughs` · cost M

**What moves** — Same collapse as rite-breath-keyframes seen from the trough side; its one non-value residue — the Recognition's speak/stop buttons carry no breath where the design's 74pt rings pulse — falls inside a movement the app deliberately re-authored, with the ruling written at RiteRecognitionView.swift:92-95 that on this screen the man is the thing that is alive, not the chrome. Everything else here is an opacity floor.

**Where** — The Rite · the Arrival glyph, and the Recognition's touch-to-speak ring

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteView.swift:20-24, :161 (Arrival glyph resolves to a 0.65 floor via GlyphAnimation.swift:92-95, design 0.55); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteRecognitionView.swift:67-73 and :101-107 (the two buttons, no breath), :113-116, :77-95 (the APP-OWN ruling); MATCHED: RiteGatheringView.swift:165-173

### `rite-voice-label-tracking` · cost S

**What moves** — Tracking moves — 0.18em → 0.125em on 'answering X', 0.16em → none on 'name · verb' (which also renders Lora italic rather than tracked mono), and 'answering X' sits after the role instead of above the name. Ashrey's own stated non-example is 0.18em against 0.16em; and the reorder happens inside a single header block that surfaces all at once, so the reading order shifts emphasis, not the claim — the header says the same sentence about who speaks and whom she answers.

**Where** — The Rite · the Gathering — a voice surfacing, its header above the spoken lines

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:274-276 (name · verb) and :280-284 (answering label), inside `VoiceText` :258-286. Design: Claude Design Round 1/comps/The Rite v3.html:1390-1391, Mono base 0.14em at :1261.

### `rite-voice-reveal-durations` · cost S

**What moves** — The voice's closing glyph resolves over 1.2s, borrowed from the tap handler twenty lines away, where the design gives it 2.2s — the slowest thing in a deliberate 1.6 < 1.9 < 2.2 ordering. The glyph appears at the same moment on the same tap; it settles faster. A fade duration, and the words' own 1.9 is exact.

**Where** — The Rite · the Gathering, a voice's closing mark after its last line

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:304-311 (`.transition(.opacity)` with no timing of its own); the borrowed clock at :222 (`withAnimation(.easeInOut(duration: 1.2)) { shown += 1 }`); the correct sibling at :301

### `rooms-per-room-glow-radius` · cost M

**What moves** — None of the fifteen portal cards carries its own glow radius; all fall through `size * 0.20`, so the design's independent glow column collapses onto glyph size (descent 24→6.8, maya 20→9.6). Radii only — the two-layer halo mechanism and its 65-alpha are on screen, and each card is still told apart by glyph, colour and name.

**Where** — Room Selection · the halo behind every portal card's glyph

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:50, :60, :67-68; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/RoomPortalCard.swift:22-27 (no `glow:` argument); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/FieldSurfacePortalCard.swift:48-53 (same); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/RoomStyle.swift:8-15, 24-36

### `rooms-per-room-glyph-size` · cost S

**What moves** — Mirror and Signal Space share one glyph-size literal of 38 where the design gives them 30 and 31 in a 50pt box. Eight points and a 1-point sibling distinction nobody perceives; the turns still read smaller and quieter than the rooms around them, so their rank against the room cards is unchanged.

**Where** — Room Selection · the two turn cards (◐ Mirror, ⊙ Signal Space) at the foot of the list

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/FieldSurfacePortalCard.swift:50 (`size: 38`, one line serving both configs), :54 (`.frame(width: 56)` vs the design's 50×50 box); configs at :10-37. The four ROOMS in this group are already exact — Theme/RoomStyle.swift:24, :27, :28, :36

### `rooms-turncard-two-captions` · cost S

**What moves** — The person-label loses the card's hue for ink35 and gains a point of size, and the baseline pair became a stack — the colour tier is a value and the stack is a written app decision (the card header states the wider stacked layout); the door's identity is already spoken by the coloured glyph and the coloured name above it.

**Where** — The Field · the turn cards, The Mirror and The Signal Space

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/FieldSurfacePortalCard.swift:57-60 (name), :62-67 (person-label), :56 (the stack)

### `rope-durations` · cost S

**What moves** — The ceremony's ritardando — 1.1 to 1.6 to 2.6s — runs as 1.1 (or 0.8 from the axis), then 1.0, then 1.0, so the ring's lift and the words' arrival finish together instead of a second apart. After a 20s hold the same words arrive in the same order at the same moment; only the tempo of the last beat moves. A staging gap of one second inside a single fade is nearer his 1.1-against-1.0 than his 2400ms-changes-the-speaker.

**Where** — The rope overlay, at the end of the two guided breaths (or on tap) — the ring rises and the line comes.

**Files** — Screens/DoorView.swift:246 `VStack(spacing: phase >= 2 ? 40 : 0)`, :265 and :276 bare `.transition(.opacity)`, both inheriting :282 and :289 `withAnimation(.easeInOut(duration: 1.0)) { phase = 2 }`; the raise at :176 is 1.1 but Instrument/InstrumentView.swift:315 raises the same overlay at 0.8 (dismissal :324). Design: The Instrument v3.html:4411/4413/4417.

### `rope-ring-sizes` · cost S

**What moves** — A container size: the 120×120 box around the 110 ring was never written, so SwiftUI sizes the ZStack to the 110 circle and the design's 5pt of clearance is gone. The ring, its 1px border at .16 and the 9pt particle are all exact, and the box's one consequence — the ring rising once the rope has spoken — IS built, as VStack(spacing: 40) against the design's 46pt margin.

**Where** — The rope — the particle in its ring, raised by a threshold long-press at the Door or from the axis

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:246-255 (bare ZStack, no .frame; the ring at :249-250 and the dot at :252-253 are correct) and :246 (spacing: phase >= 2 ? 40 : 0, the `#rope.said .ring` 46pt shift)

### `settings-caption-tracking` · cost S

**What moves** — Two of four Settings captions render at 0 tracking instead of 0.14em and 0.1em — `spaceMonoTracked`'s inner `.tracking(0)` sits closer to the Text than the `.tracking(1.54)`/`.tracking(0.9)` written on the line below, so the inner wins. The words, size, case, weight and colour are untouched; only the letterfit moves.

**Where** — Settings — the "HOW YOU ARRIVE" header and every section label

**Files** — Screens/SettingsView.swift:94-96 (A), :423-426 (C, `sectionLabel`, used at :155, :199, :227), :240-241 (D, 0.0333em vs 0.03em); Theme/Theme.swift:151 (the helper whose default `em: 0` plants the winning tracking)

### `signal-hintfade-duration-split` · cost M

**What moves** — The same two members and the same two call sites as signal-hintfade-durations — the sweep enumerated this pair twice. Verdict follows: the split (3.4s vs 5s) is lost to the one-master-breath doctrine, the amplitude both share is exact, and the period is a documented class divergence rather than a dropped constant.

**Where** — The Signal Space · 'A SIGNAL IS ARRIVING' and LEAVE (duplicate of #169)

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:381-385, :136-140, :196-203; Instrument/Breath.swift:20-21

### `signal-hintfade-durations` · cost M

**What moves** — Both hints breathe at the app-wide 10s instead of 3.4s and 5s — but the amplitude is exact (0.24 + 0.28·v reproduces the keyframe stop for stop), and the period is not an accident: BreathingOpacityHint is parameterless by design, reading the one master Breath whose doctrine block rules phase universal. This is a recorded, deliberate, still-open class divergence, and reversing it is a doctrine decision that cascades to every surface, not a constant to repair.

**Where** — The Signal Space · 'A SIGNAL IS ARRIVING' and LEAVE

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:381-385 (the parameterless modifier), applied :140 and :203; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/Breath.swift:20-21 (period 10.0), :23-47 (the one-breath contract)

### `sound-voice-peak-gain` · cost S

**What moves** — Same gate/ungrip collapse onto 0.03 seen from the ten-voice mix instead of the travel register, plus the glide's noise half (s²·0.022) having no port. A gain sitting 4dB under its designed level is the 'peak gain slightly low' case by name; the events still punctuate, and no surface says anything it did not say.

**Where** — The Instrument · the whole axis mix — give, gate, rush, carry, glide, thin, ungrip sounding together

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1551, :1563 (both `peak: 0.03`); glide noise absent from `AxisGlideVoice`, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/AxisTones.swift:106-142. Design: canon/spine-sound.js:135, :165, :51.

### `spine-sound-named-strike-peaks` · cost M

**What moves** — Five of six named strikes carry their own peaks exactly; only B.slide (peak 0.032, a 2.6s discrete glide between register pitches) has no port. But the design's own sentence for it — 'the step between registers is heard, never cut' — is already made by a different and continuous mechanism: the app holds one glide voice whose pitch tracks hzAt(travel.z) the whole time the axis is on screen. The voice is absent; the claim is not.

**Where** — The axis · moving between the fifteen registers

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1436-1459 (startAxisGlide / setAxisGlide — the continuous carrier), driven from Instrument/InstrumentView.swift:340 and :442. Design site: Claude Design Round 2/design-source/spine-sound.js:333-341.

### `story-ash-question-two-renderings` · cost S

**What moves** — The entry row's prompt renders at terra 0.70 where the comp authors the hex byte 70 — 0.4392 — so the invitation is ~59% brighter than drawn. Right digits, wrong unit, and worth recording as that class; but it is the same four words in the same button in the same place, saying the same thing at a different volume. (The compose sibling was superseded by AshComposeView and is an exact port of its own Phase 9 comp.)

**Where** — Story Detail · the Ash entry row's 'What arrived for you?' prompt

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/AshEntryRow.swift:33-36 (0.70 → 0.4392; `.tracking(0.2)` → 0.14 is the same slip one line down), and the same conversion fault at :117 (0.22 vs the comp's hex 24 → 0.141)

### `story-avatar-derived-ratios` · cost S

**What moves** — The glyph sits at 0.52 of the disc against the design's 0.38 (~1.37× on every avatar) and the glow is a fixed 4pt blur instead of a size-derived 0.44 radius pair — a font size and a glow radius, both named as values in the ruling; the disc still reads as its archetype in its own colour.

**Where** — Every comment, reply and feed card carrying a voice avatar

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/VoiceAvatar.swift:9-13 (glow), :22 (glyph ratio)

### `story-avatar-glow-hex-alphas` · cost S

**What moves** — The avatar disc wears one glow layer at α 0.22 with a constant 4pt blur instead of two layers at 0.314 and 0.157 scaled off the face's size, so the 22pt stack face and the 36pt comment face carry the same absolute halo. An alpha and a blur on a decorative bloom — the disc, its colour and its identity are unchanged.

**Where** — Story Detail · the comment and reply avatars, and the stacked faces on the story card

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/VoiceAvatar.swift:9-13 (`Circle().fill(archetype.color.opacity(0.22)).blur(radius: 4).frame(width: size * 1.6, …)`); consumers Components/CommentCard.swift:122, Components/ReplyRow.swift:107, Components/StoryCard.swift:95. Design: Story Detail.html:465, :470

### `travel-damp-by-mode` · cost S

**What moves** — Nothing to build. Four of the five DAMP presets have no app site because they have no app reachability: `near` and `long` are selected by nothing in the design either, the module default at :3429 is overwritten by `Object.assign` at boot, and `continuous` is the SHORT mode the app deliberately does not have (no tweak panel, AxisModel.swift:518). The single live site carries `immense`'s own DRAG · DAMP · span · DUR.

**Where** — The Instrument — travelling the axis (there is one mode, and it is the design's default)

**Files** — Instrument/AxisTravel.swift:198 (`DRAG = 0.00018, DAMP = 0.956, … span = 0.42`), :178 (`glideDur = 5.4`), :187-189 (the comment that already refuses the `long` row); Instrument/AxisPassage.swift:20-22

### `turn-hd-vs-foot-tracking` · cost S

**What moves** — Tracking 2.0 against 1.8 on one caption (`em: 2 / 9`, a fraction contrived to land on a whole point rather than an em fraction). The header's 3.4 is exact, the pair's direction survives, and the two captions still read as header and foot.

**Where** — The turn overlay — "tap anywhere to stay" beneath "WHERE TO", at the Door and every hub

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:93-94 (should read em: 0.2; :63-64 is correct at em: 0.34) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151-153

### `turn-panel-vs-row-duration` · cost S

**What moves** — A fade duration: the turn's scrim opens at 0.5 from the pull and at SwiftUI's implicit default from the three other presenters, where the design says .42 everywhere. The rows' .62 and the design's stagger formula are ported verbatim, and the rope's 1.1 is exact — what moves is a tenth of a second on a scrim, in the same direction, on the same gesture.

**Where** — The turn overlay opening — from the Door's pull, from the dot mark, from any hub

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:185 (0.5), :155 and :57 (bare withAnimation), :55-59 (the presented overlay) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/HubOverlay.swift:18, 22, 45 · TurnOverlay.swift:87 (the row's .62, correct)

### `turning-link-hex-alpha-triple` · cost S

**What moves** — Two alphas move because hex suffixes were re-read as decimals: border 28 (0.157) → 0.28, chevron 70 (0.439) → 0.70. The hierarchy holds in the same order — label 0.82 > chevron > border > ground 0.05 — so the block still reads as a faint tinted card with a quiet chevron; it is louder, not different. Worth recording precisely because the conversion fault is mechanical and the correct form (`0.051 // ${color}0D`) already exists in the house.

**Where** — The Turning · a player's detail page — the link out to all of that voice's words in the field

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/TheTurningView.swift:440 (`strokeBorder(...opacity(0.28)`) and :430 (`Text("›")...opacity(0.7)`), in `ashramVoiceLink` :419-444. Design: Claude Design Round 1/comps/Player Detail - The Turning.html:393, :395.

### `voice-identity-caption-tracking` · cost S

**What moves** — Letterspacing only: the name loses −0.3 (present at four other Lora identity heads), and the role caption's 1.32 is shadowed to 0 because `spaceMonoTracked(11)` defaults em to 0 and applies the inner `.tracking(0)` closest to the Text. Worth recording large — the same shadowing pattern sits at 39 sites (Signal, Settings, Turning, Compose, Players, Game), so a whole family of mono captions renders untracked — but every one of them says the same words in the same face and case.

**Where** — Ash's Voice — the name and "PHYSICAL SYNTHESIS" under the sphere; and 38 other mono captions app-wide

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshVoiceView.swift:139-141 (no tracking) and :143-146 (`.spaceMonoTracked(11)` then `.tracking(1.32)`) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151-153 (the helper; em defaults to 0) · the same pattern at SignalView.swift:74-75,137-138,172-173,188-189,199-200 · SettingsView.swift:95-96,306-307,363-364,425-426 · TheTurningView.swift:156-157,211-212,276-277,370-371 · AshComposeView.swift:144-145,251-252,377-378,409-410 · PlayersView.swift:215-216,260-261,369-370 · GameView.swift:202-203,301-302

### `world-farewell-line-alpha` · cost M

**What moves** — Three farewell alphas (0.28 · 0.30 · 0.30 of raw p) collapse onto the invitation's shared 0.38·(0.7+br·0.4), so the lines are ~35% brighter and gain the house breath the design withholds — but the same words stand in the same slot at the same moment, and every other cue in the app pulses the same way, so the pulse reads as ambient behaviour, not as a statement about the closed world.

**Where** — The Point · worlds I / III / IV, the line while the world closes

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:255 (the shared WorldCue alpha), call sites :310, :568, :1071


## Audit rows — 47 recorded

### `A1.1` · cost S

**What moves** — Nothing moves — the three flattened canon reflections were re-broken in the base on 2026-08-27 (recn5ECOiniQzlrFt · reccijAuVSic4EK4I · rec6QeSCFULO8BIQF) and the rest of the flattened set was retired with cohort A; the render already honours \n and CLAUDE.md:296 records 'every card carrying authored \n' as the pool contract.

**Where** — The Mirror — the held card of the day, reached from Room Selection's ◐ portal

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:304-309 (renders card.body, honours \n, invents none) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Models/Models.swift:342 — no change; closure is base-side, Pass 0 §1

### `A1.2` · cost S

**What moves** — Nothing moves — the ten Value/Mantra/Practice/Game/Tree-of-Life rows left the pool on 2026-08-27 (7 archived, 3 canon reflections kept and repaired); the pool is one cohort at 24 Live, so the 'one day in three' this row measures is now zero days and no app-side Category filter is needed.

**Where** — The Mirror — the reflection-of-the-day, formerly ~1 day in 3

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Services/AirtableService.swift:198-204 (fetchMirrorCards — the pool filter, unchanged and sufficient) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:185

### `A1.3` · cost S

**What moves** — A ratio moves, not a claim: 19/12 became 12/12, and it was not forced — no card was re-registered, the 50/50 fell out of A1.2's cohort removal. The three rows that were labelled a vow and were not vows left with that cohort, so the mislabelling half is gone too.

**Where** — The Mirror — the register fork (upright/'A VOW · ARRIVED'/· vs italic/'STILL LIVING'/◌)

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:293-296 (register label + closing glyph fork) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Models/Models.swift:344 — no change

### `A1.4` · cost S

**What moves** — Nothing moves — recw4bU300qQ8KWh4 ('The Roof Beam') was restored from the two-line paraphrase to canon on 2026-08-27: 'What would I do / if I trusted the ground / to hold?', verb and three-line break both.

**Where** — The Mirror — one koan card in a 24-card pool

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:304 — no change; the record itself was the fix

### `A2.2` · cost S

**What moves** — Nothing moves — all twelve Codex/business rows including 'Customer as Hero' (the Wazoodle armorer line) were archived on 2026-08-27; the Signal pool is the design's six, and SignalView's derived splitter was deleted rather than kept precisely because all six now carry authored breaks — code that would render one unbroken line if the flat cohort were still live.

**Where** — The Signal Space — the day's ceremonial transmission, formerly ~75% of days

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Services/AirtableService.swift:209-215 (fetchSignals) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:285-290 (splits on \n only — the fallback is gone)

### `A2.4` · cost S

**What moves** — Nothing moves — the two distillations were authored on 2026-08-27 (recIUkpf6BXZnxjqW and recOD7ewDEQnLnEpn), and 'The door was never locked — you have been holding it shut from the inside.' is now in the base; their undistilled ancestors went out with A2.2's twelve. Even standing, this was pool depth (4 of 6 vs 6 of 6), not a wrong claim met.

**Where** — The Signal Space — signals #1 and #2 of six

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:285-290 — no change; the two records were the fix

### `A3.1` · cost S

**What moves** — Nothing moves — all fifteen duplicated first-person rows were archived and eight practices authored (1 canon + 7), each carrying a Practice Sub-line; the field fldWcHyZDGcytIdJg was created for it and BOTH code halves have landed, so the second-person instruction with its 'in… and out.' sub-line now exists in data and renders. The Mirror/Practice duplication is gone at the source: neither pool contains the other's rows.

**Where** — The Practice Door — weight 23 of every app open

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:177-188 (body + sub-line in the shared 22pt stack) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Models/Models.swift:373-388 · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Store/FeedStore.swift:443-445

### `A3.2` · cost S

**What moves** — Nothing moves — the four bare-title Seed thresholds ('The System Paradox.', 'Solution Before Problem.', 'Observer-Information Collapse.') were archived on 2026-08-27 and the canon threshold receVnWTzpyV39mUW added; ThresholdSentence now reads Body before Name, which is the change written expressly so 'You are not late. / The field kept your place.' keeps its break past singleLineText.

**Where** — The Practice Door — the threshold kind, weight 40 of every app open

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Models/Models.swift:310-317 (f.body ?? f.name) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Store/FeedStore.swift:459-463 (pickThreshold, Sentence Source ≠ Bindu) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:168-175

### `A4.5` · cost L

**What moves** — Nothing a walker meets changes — on the device where he spoke it, the kept voice plays exactly as designed (raw, no chrome, silence held). What moves is durability: reinstall or a new device and `AudioAnchorPlayer.fileURL` finds nothing, so the affordance is absent rather than broken. That is a storage value, not a sentence.

**Where** — Story Detail / Ash entry rows / the Return's sealed self — the ◉ play affordance, which only ever appears when a real local file exists

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/AudioAnchorPlayer.swift:36-47 (filename → recordings dir, exists() gate); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Services/AirtableService.swift:461,487-488 (writes a filename, not an attachment); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Models/Models.swift:37,87; consumers at Components/AshEntryRow.swift:92, Screens/StoryDetailView.swift:329, Screens/ReturnView.swift:329

### `B2.3` · cost M

**What moves** — ROW IS HALF-STALE. The invented tutorial line is gone (UniverseView.swift:163-165 now carries the deleted-by-design note), the region's name is drawn at far zoom, and all four fall-stratum names are drawn at H-172. What is still absent — `say()` itself, the world-state triple ('a world, long lived on / newly alive / still waiting') and the stratum pair ('the newest self' / 'a self, further back') — names in words what the sky already draws: met-ness, depth rings and company already split those three worlds visually, and the strata are already ordered by age. Same sentence, said twice.

**Where** — the sky and the fall — the transient `.where` caption slot, which the app has no surface for at all

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:163-165 (no say surface), :847-853 (region name built), :1533-1543 (four layer names built), :1038-1062 (met/unmet/depth drawn), :476-478 (ring lit, unnamed); design /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Universe v3.html:1470-1474,1526,1531-1534,1650

### `B4.4` · cost S

**What moves** — `shimmer()` adds `0.06·min(4,n)·(0.5+0.5·Σsin/n)` to a met star's twinkle at far zoom — an amplitude term on a glow that already breathes with `tw`. A walker cannot read 'four voices sat here' out of a slightly stronger flicker; the company is legible the moment the motes resolve, which the app builds. Colourless by Amendment §8.7, so it does not even shift hue. A value.

**Where** — the sky at far zoom — the met star's core and halo

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:1029 (tw), :1047-1049 (glow, no shimmer term), :1077-1080 (motes resolve from R>3.4); design /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/uni-field.js shimmer(), consumed at The Universe v3.html:1323

### `B7.2` · cost M

**What moves** — The dwell already exists and already does something a walker sees — `travel.dwell` fills at 0.30/s below Z −2.3 and feeds `uDwell`, which bends every room's light toward the centre. The missing half is a SECOND rendering of content already reachable: the belief names are drawn by the structure lens, and looseness is already spoken there — the strand wanders by `1 + loose·2.6`, greys by `loose·0.5` and dims by `0.46 − loose·0.24`. The design says it with an underline; the app says it with the strand itself.

**Where** — a region, held still — the roster at H−236 under WHAT BUILT THIS PLACE

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:968-1008 (structures, looseness, names at the head node); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisTravel.swift:170,463-478 (dwell live); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:736 (uDwell fed); design The Instrument v3.html:1333-1368

### `B7.6` · cost S

**What moves** — Two inventions remain and neither changes a sentence. The focus ring is a redundant second mark on a star the app ALSO marks by offering its door — the design's own way — so it over-says rather than mis-says. The `loc.y < 78` band is a full-width dead zone where the design delegates to `closest('#back')`: a tap near the top does nothing and he taps again lower. Both are deletions worth making; neither is a claim.

**Where** — the sky — the ring around the approached star, and the top 78pt of the tap surface

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:1051-1053 (focus ring — no counterpart in uni-sky.js:282-333 or The Universe v3.html:1307-1358), :458-460 (`if loc.y < 78 { return }`); the door that already marks focus is at :613-624, :646-664

### `C1.6` · cost S

**What moves** — ROW IS LARGELY STALE. Both doors the design actually surfaces exist with verbatim label and line, and the third — the z:0 rite door — is filtered out of `paintDoors` by the design itself (`.filter(x=>x.d.z!==0)`), so it is dead data, not a gap. The `deep>0.72` gate exists because the design's door lives in persistent axis chrome that would otherwise show to anyone merely passing Z 7; the app puts the door inside world VI's own surface, where only someone standing in VI can see it, so the claim is preserved by construction. What is left is the 126 Hz crossing tone on that one door — one missing call, where its twin at the fall's mouth already plays it.

**Where** — world VI's middle tier (the return door) and the fall's mouth (its twin)

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:249-266 (label + line verbatim; no tone on `onReturn`); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:664-690 (the z:−1 door, verbatim), :225 (its 126 Hz crossing, built); design The Instrument v3.html:1026-1035 (DOORS), :1090-1099 (doorsAt), :5104 (the rite door filtered out), :5112-5118 (cross → B.threshold(d.tone))

### `C1.8` · cost S

**What moves** — Nothing on any surface changes — `Axis.rim` is ported and consumed, `Axis.weight` is ported, tested and correct, and its only missing piece is a caller that lives in two other rows.

**Where** — None. No walker meets anything here: `weight` is a pure function with zero readers, so building against it would be building C4.7's presence-weighted CPU layer or C4.2's `uBack` normalisation, not this row.

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisModel.swift:130 (`rim`, consumed) and :157 (`weight`, unread); the one consumer is /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointChamber.swift:202-207. The row's own text is right and I confirmed it against the tree: this PARTIAL closes when C4.7 or C4.2 lands and is not a third open item. Reading it as independent work sends someone to build a consumer for its own sake.

### `C2.4` · cost S

**What moves** — STALE ROW — the gates are built. `AxisPassage.gates = [0.34, 0.68]`, `gatesCrossing(from:to:swift:)` fires each once and never on a slip-through, and the flare draws at `here.color.opacity(0.22 * gateFlare)` decaying at 2.2/s. The crossing already has a middle, and the middle already says the swift way has none. What is left is the two `B.gate` audio strikes and the fact that `soundEngine.axisGate` is still bound to arriving at the register NAMED "the gate" (:407) — a mis-wire that adds a tone where the design has none, but not a sentence a walker could read as false.

**Where** — any earned crossing on the axis — the two flares mid-passage

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisPassage.swift:43-53; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisTravel.swift:377-387; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:216-231, 406-409

### `C2.7` · cost S

**What moves** — A second input to a journey the first already completes. The vertical drag reaches every one of the fifteen registers and every membrane; pinch adds no destination, no affordance and no word. A walker who never pinches never learns anything is missing.

**Where** — the axis drag, everywhere

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:457

### `C3.7` · cost M

**What moves** — The sentence "you are moving, and fast" is already made — C3.8's `FieldBlur.radius(zv:)` (min(8, |zv|·300)) softens the whole field on the axis and is wired at the draw. The 64 hash-placed streaks and the `sp*0.60` edge vignette raise the intensity of a statement the surface already makes; they do not change its subject. Recorded, not lost: the direction term (`dir = zv>0?1:-1`) is the one part that carries information the blur does not, and the rail carries that already.

**Where** — free travel between registers, under the hand and on the glide

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:768; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisModel.swift:429

### `C4.2` · cost M

**What moves** — STALE ROW — the ledger-in-the-material is built, on the surface where he meets it. `ReadParting` appends the hand's point to `thinned` at every `handBack` (:669) and cuts every one of them permanently out of all four gauze layers (:583-592), so a zone he has handed back stays thin and the forgetting IS the entry fee. World III's own field carries the compressed form as `partedOnce`/`veilFloor = 0.06`. The shader's nine-slot `uBack` would say the same sentence a second time in the background atmosphere, and has no source to read from — the world stores one scalar, not a zone list.

**Where** — III · The Veil — the reading, holding the parting open

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:519, 576-592, 665-672; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:704-713; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentField.metal:125-127

### `C4.6` · cost S

**What moves** — Grain hashed in points rather than device pixels is 2–3× coarser on Retina. It is a texture density and says nothing about who is speaking — the row's own D5.11 pass already ruled the size tell a false positive and held the severity at COSMETIC.

**Where** — the field, everywhere

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentField.metal:213

### `C5.1` · cost S

**What moves** — The row's one real claim — the fade law — was built on 2026-08-31 (`Immersion.railOpacity` = (1−hush·0.85)(1−immA)(1−dom·0.9), wired at :626), so the ladder now stays faintly there through a crossing instead of hard-zeroing. What is left is a pitch of 21 against 22 (a value, and the dot still lands at the exact midpoint rather than 10/11) and the `.kept` glow, which would say a second time what the CARRY motes already say — C5.12 is CLOSED, so what he took up is already in orbit around the particle at every scale. Location-of-keeping vs count-of-keeping is a real difference, but it is a 7px unlabelled glow whose meaning is only legible to someone told what it means.

**Where** — the right-edge rail, always on screen

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:582-628; /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:127-137

### `C5.9` · cost S

**What moves** — Same sentence, different rendering. The particle already says "you, one point, dead centre, breathing, in this much company" — it is positioned right (C5.8 closed), sized right (C5.7 closed), carries the CARRY motes (C5.12 closed) and still becomes the world at the centre via the fill rect. The halo's 8×/26px extent, its four stops and the near-white core disc change how brightly that same object renders, not what it claims.

**Where** — The particle, everywhere on the axis.

**Files** — `Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:864-873` — one RadialGradient core→deep.opacity(0) at radius r, plus a `.shadow` at `min(r,40)*(1+carried*0.05)`. The company term is already there; the `(1+fill*2.4)` swell and the `rgba(255,243,236,.94)` core are not. Design `Claude Design Round 1/The Instrument v3.html:5742-5750`.

### `C6.2` · cost S

**What moves** — A quarter-cycle phase anchor. (1−cos)/2 and (sin+1)/2 are the same curve, the same 0…1 range, the same 10s period — only the value at app-launch differs, and nothing outside the app references launch. The one claim that DID ride on it — "image and sound are the same event" — was already closed 2026-08-29 when the audio LFO was re-phased to `1 − cos φ · 0.12` so both media crest at mid-cycle.

**Where** — Every breathing surface — the shader's uBr, the ember, the magma, the hint cues.

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/Breath.swift:22-47 (the ONE-BREATH CONTRACT, ruled at Pass 0 and re-ruled 2026-08-29), :95 (`value = (1 - cos(p*2π))/2`). Design: The Instrument v3.html:1687.

### `C7.10` · cost S

**What moves** — Peak 0.03 against 0.024, attack 0.3 against 0.45. Frequencies, glide and release are already right and the call site is already right (off-axis only, as the design has it). This is the peak-gain example verbatim.

**Where** — The Light, on an opened hand.

**Files** — `Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1561-1564`. Called from `Bindu Feed/Bindu Feed/Screens/LightView.swift:358,402`. Design `canon/spine-sound.js:159-168`.

### `C7.2` · cost M

**What moves** — Right kind of voice, right pitch law, right driver. `AxisGlideVoice` is continuous, two-oscillator at hz / hz·1.006, level following speed — it already says "you are moving, and this is where you are on the axis." The missing 2400Hz lowpass (which barely touches two sines anyway), the `s²·0.022` bandpass noise bed and the smoothing τ 23ms-vs-110ms are timbre and hand-feel values, of a piece with the peak-gain example.

**Where** — The glide, continuously while travelling the axis.

**Files** — `Bindu Feed/Bindu Feed/Sound/AxisTones.swift:103-142` (the two sines and the per-sample 0.0006/0.0009 smoothing); `Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1459` (`setAxisGlide`, level clamped at 0.03). Design `canon/spine-sound.js:29-52`.

### `D2.2` · cost S

**What moves** — THE ROW IS STALE — its premise is false against the tree now. The three words are rendered verbatim: `PointReadings.swift:180-182` gives `WALKED ●` / `IN PROGRESS ◐` / `SEEDED ○ — NOT YET WALKED` at every reading's footer, and `PointStatus.word` also feeds the descent prompt. And the design surface the app's star tier actually ports is symbol-only — `The Instrument v3.html:2188` is `STATUS={w:'●',p:'◐',s:'○'}`, drawn as a glyph above each star at `:2325,:2526,:2760,:3017,:3323`, which is exactly what StarMark draws. `SM`'s words belong to `point-levels.js`'s constellation. What is left is a gloss beside the marker on the universe ring — a legend on a state the app already names.

**Where** — The universe ring inside a dimension, and the star labels inside a world.

**Files** — `Bindu Feed/Bindu Feed/Point/PointWorlds.swift:62-84` (StarMark), `:226-233` (universeMark). Already saying it: `Bindu Feed/Bindu Feed/Point/PointReadings.swift:180-182`; `Bindu Feed/Bindu Feed/Point/PointWorldView.swift:609`. Design `Claude Design Round 1/comps/point-levels.js:139` vs `Claude Design Round 1/The Instrument v3.html:2188`.

### `D2.8` · cost S

**What moves** — GLOWS is dead data in the DESIGN too — `The Point v9.html:89,525,866` and `point-content.js:6,442` declare it, export it and destructure it, and no line ever reads it. The authored non-uniformity (m7 .11 vs m1 .07) is never rendered anywhere, so no walker has ever met it. Porting a table nobody draws changes one number in a struct.

**Where** — nowhere — the atmosphere behind every Point world; the value is unread in both trees

**Files** — design: canon/point-content.js:14-15 (and Claude Design Round 2/design-source/point-content.js:6, The Point v9.html:89) · app counterpart: Bindu Feed/Bindu Feed/Point/PointContent.swift:44 (PointDimension carries `hue` only)

### `D4.2` · cost M

**What moves** — The row's cited code no longer exists. `PointWorldView.swift:139-184`'s full-screen generic ScrollView, its one-section-per-tap and the invented "touch to walk further" are all gone, superseded by seven bespoke readings; the world is drawn BEHIND each reading and recedes by its own coefficient, so "a reading opens over the receding world" is already the sentence. What remains — the 26px rounded top, the 38×3 grip, the rgba(4,5,10,.6) scrim, the .8s slide transform, italic `say`/`open` — is the sheet's dress, and every reading already carries a working `‹` exit, so he can always get out.

**Where** — A star's reading in any of the seven worlds (level 2).

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:237-251 (ReadingHead, the shared `‹`), :255-292 (the seven-way dispatcher), :358+ (each reading's own ScrollView) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:170-186 (world behind, PointRecede.worldAlpha). Design: comps/point-levels.js:37-51,161-175.

### `D5.12` · cost L

**What moves** — Settled in code, not open. PointYantra already builds all TEN enclosures (gate · I–VII · aperture VIII · bindu IX) and maps nine axis registers onto them, treating BAND[8] as a band he PASSES THROUGH rather than stands in — which is the literal truth of a walk that reaches the aperture off world VII. Restoring an eighth on-axis enclosure would re-add a register the governing source (Instrument v3, 15 registers) deliberately dropped; that is a design decision, not a repair, and the aperture is reachable either way.

**Where** — The axis from z 7 → 9, and the aperture reached from world VII's level 0.

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointYantra.swift:115-131 (the ten-enclosure map, `focus(forAxisZ:)`, DIMHUE all ten) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:269 (the `the aperture ›` route) · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/App/Navigation.swift:47. Note separately: D6.7's live complaint — ApertureView routing to `.instrument(9)` as a PUSH so the axis stacks twice — is a navigation defect that belongs to D6.7, not to this row.

### `D5.6` · cost S

**What moves** — The row's two named gaps do not reach a surface. (1) The four-universe complaint is stale against Round 2: `world-five.js` stores `uname` on every pane and NEVER DRAWS IT, and the authored PAIRS deliberately cross universes — "the hall is not a filing system" — so the design also makes the four indistinguishable. (2) The flat-index pairing gets 2 of 5 wrong (ritual↔labs and ai↔slips where the design pairs ritual↔ai, labs↔slips), but the app's panes are `StarMark(compact: true)` — no name is drawn in the hall at all, and neither the reversed partner title on the back of the glass (`world-five.js:411-419`) nor `through` exists, so nothing on screen ever says who faces whom. Correcting the table today changes no sentence; it becomes claim-bearing only once the partner is named, which is a different (unfiled) piece of work. The one real find in this row — the `settling` ternary that should have been a cosine — is already corrected.

**Where** — V · The Mirrors, the hall — turning a pane; the partner is never identified on screen

**Files** — Bindu Feed/Bindu Feed/Point/PointWorlds.swift:1170-1176 (`pairs`, two-by-two by flat index), :1261-1268 (`mirrorStar`, always compact — no name) · design: Claude Design Round 2/design-source/world-five.js:60-66 (PAIRS), :67 (ROWS, the corridor), :411-419 (the partner's title, mirror-written)

### `D5.9` · cost S

**What moves** — The umbrella has no residue of its own. Its named instances are I (carried by D5.2, BUILD), III (carried by D5.4, BUILD) and VII (D5.8's world, closed on the GRAB model). The fourth, VI, turns out to place correctly by accident: the design's authored table runs x-window · volunteer · choose · death · evidence · graduation · cycles with qy descending 0.34 → −0.36, and the content's flat order is identical, so the app's `strat = i/(n−1)` already puts them at the right depths with Deep Time furthest. What differs there is the x coordinate (alternating ±0.22 against authored qx) and the exact spacing — values. Returning this as a third BUILD would hand the same two rewrites to the parent twice.

**Where** — the world bodies of I, III, VI, VII — no surface unique to this row

**Files** — Bindu Feed/Bindu Feed/Point/PointWorlds.swift:54-58 (`hash`), :1282-1288 (VI's index-linear `spot`) · design: Claude Design Round 2/design-source/world-six.js:68-78 (the authored table, in content order)

### `D6.5` · cost S

**What moves** — Stale — the arrival already sounds on the path a walker reaches. `ApertureView.standard(_:)` fires `PointJourney.visitors += 1`, `soundEngine.shimmer()` and `PointYantra.shared.flare()` together, exactly as `The Point v9.html:1286` does. The residue is one line: the keyed `live(_:)` branch increments and flares but never calls `shimmer()` — and that branch requires a personal Anthropic key in the Keychain, without which `live` falls straight through to `standard`. A one-call parity fix on a branch behind a credential gate, not a claim the walk meets.

**Where** — the aperture — a visitor arriving from a register the library never walked

**Files** — Bindu Feed/Bindu Feed/Point/ApertureView.swift:318-327 (complete) vs :388-390 (keyed branch, shimmer missing)

### `D7.4` · cost S

**What moves** — Stale — the interval between registers is heard, and continuously rather than as a fixed ramp. `InstrumentView.hzAt(z)` interpolates exponentially in log-frequency between the two adjacent registers' tones and feeds it every frame to a held `AxisGlideVoice` whose level tracks `travel.speed`, so the pitch actually travels from the register he is leaving to the one he is arriving at as he moves. The design's `slide(a,b)` is a 2.6s one-shot at a·2 → b·2 with its own envelope; the app's is the fundamental, tied to his motion. "The step up the ladder is heard, never cut" is made — what differs is the octave, the envelope and whether it is an event or a continuum.

**Where** — the axis, travelling between enclosures

**Files** — Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:94-102 (`hzAt`), :339-340 (driven by travel.z), :442 (`startAxisGlide`) · Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1437-1459 · design: Claude Design Round 2/design-source/spine-sound.js:332-342

### `D7.5` · cost S

**What moves** — Three of the row's four are built AND wired — the row is stale. `glide(enclosure:down:)` runs on descend and ascend (`PointWorldView:568,583`), `shimmer()` on the aperture and the reveal, and `om()` is the triad 136.1 · 272.2 · 408.3 at 0.06/(i+1), not a single fundamental. The fourth stands: universe-open and star-open still play `riteVoice(hz: ladder[…], dur: 5/6)` where the design plays `blip(f·2)` — 0.02s attack, exponential to 0.7s. `SoundEngine.blip(hz:)` already exists and is wired at exactly one site (the Light's 174). That is the same event sounded at a different length and octave, and it keeps r-guard's `nul()` silence intact either way — a substitution of what the mark sounds like, not of what it says.

**Where** — opening a universe or a star, in every register

**Files** — built + wired: Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:751-773 (glide, shimmer), :1032-1040 (om triad); Bindu Feed/Bindu Feed/Point/PointWorldView.swift:568,583; ApertureView.swift:323; PointRevealView.swift:108-109 · residue: PointWorldView.swift:200 and :243 (riteVoice where blip belongs), SoundEngine.swift:1021-1023

### `E1.10` · cost S

**What moves** — Nothing moves — the row is stale and triages against the wrong source. `The Light v2.html` is a TWO-scene prototype that draws one interior and mounts `<Nave>` for both (:677,705,807,867) because it has no dawn to draw. Canon is #1 on the ladder and is explicit — `canon/spine-light.js:15-16`: *the sixth, the Far scene, is the nave: enclosed stone, the carved floor. Two materials for two kinds of scene, exactly as ruled* — and `The Instrument v3.html:5296-5298` repeats it (*its material is the dawn — or, for the Far one, the nave*). The app's 5 dawn / 1 nave split IS the design. Building the nave into all six would BREAK the two-material claim, not restore it.

**Where** — The Light — the material behind every scene (five dawn, one nave)

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:135-165 (material switch); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Light/LightCanon.swift:117-240 (the six scenes' materials). Sources: canon/spine-light.js:15-16; Claude Design Round 1/The Instrument v3.html:5296-5298

### `E1.9` · cost S

**What moves** — Moves a value: the nave Bindu's core alpha never dips to 0.88 under a finger (design `warm = touching ? 0.88 : 1+calm*0.30`), and the halo ring holds a flat 0.8 instead of 1.1/0.6. No claim rides on it because the ABSORPTION LAW already has three live expressions a walker meets: the gate visibly STOPS advancing under his finger (`LightView.swift:521` `if !touching && idle > idleMs`), the stillness drone audibly cuts (`:537` `setStillness(fill:touching:)`), and the scene's arrival slows 6x (`:553`, `LightArrival.step(touching:)`). 'Force is absorbed, not rewarded' is spoken three ways; the softening is a fourth voice for the same sentence.

**Where** — The Light (Z=-5) — the stillness gate on approach, and the nave interior during the floor scene

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightNave.swift:132-141 (warm/halo/guide/core, no `touching` term); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:170-175 (approach Bindu), :521, :537, :553 (where `touching` IS already honoured). Design: Claude Design Round 1/comps/The Light v2.html:541,548,616-622

### `E2.6` · cost S

**What moves** — The Recognition already says the right sentence — Ash asks, a control waits, it becomes a stop control while it listens; what is left is fill opacity, border opacity, a 26px glow and a breathe animation on a vessel that already reads as one.

**Where** — IV · The Recognition, prompt and listening stages. Both of the row's held items resolve without a build: the vessel deltas are values, and the other half is already ruled.

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteRecognitionView.swift:55 (avatar), :67-73 (prompt vessel), :101-107 (listening vessel) vs Claude Design Round 1/The Rite v3.html:1477-1483. Measured: the design's 74×74 is what the app already renders (34pt glyph + 20pt padding = 74); what differs is `ASH.color14`/`20` fill, `45`/`70` border against a flat 0.4, `boxShadow 0 0 26px`, the breathe animation, and a 12pt dot / 16pt rounded square inside a hollow ring against a `◉` glyph. The state change the design signals with the glow, the app already signals with dot→stop-square. The nearest thing to a claim is that `RiteAsh.glyph` IS `◉` (/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Rite/RiteContent.swift:183), so the same mark appears twice in Ash's colour — but the ring and the size already read it as a control, and the audit's own severity for this is MINOR/COSMETIC. SECOND HALF ALREADY SETTLED, NOT HELD: `"nothing to leave · seal ›"` was ruled 2026-08-31 and the reasoning is written at RiteRecognitionView.swift:76-89 — it is kept because the app has a spoken anchor the design has no notion of, and removing it strands a man who spoke and typed nothing. The row's status line is stale on that point.

### `F0.3` · cost M

**What moves** — A period value. 3.4s/3.6s/4.8s against the 10s master clock — same element, same words, same opacity and scale ranges (HintPulse 0.4→0.85, HintFade 0.26→0.55, EmberWake 0.97→1.045), never dipping to invisible, so nothing is omitted and no cue disappears. "One breath under everything" is locked doctrine in the codebase; the fix here is to give prompts back their short periods without breaking the phase-lock, which is a tuning job.

**Where** — The Turning's pre-start hint; Ash's compose ember and hint.

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/TheTurningView.swift:279,487-493 · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshComposeView.swift:242,254,439-455 · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/Breath.swift:22-47.

### `F10.4` · cost S

**What moves** — Three literal values, and the sentence is the same either way: "until you say who you are, this mark is you." The NAME already resolves to the design's "Ash" (ArrivalSettings.displayName, §7 and Settings.html:448 agree). The colour is not another archetype's private hue — `#9B6BD6` IS `BinduTheme.accent`, the app's own accent, so the unconfigured walker arrives in the app's mark and the app's dot rather than in a stranger's identity. CLAUDE.md §7 declares this deliberately; flipping it hard-codes one named person as everyone's default.

**Where** — His own mark — the header AshMark, the compose accent, Ash's Voice, the Story Detail entry.

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SettingsView.swift:512-516 (the three defaults), :527 (displayName → "Ash") · consumers at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/AshMark.swift:9, Screens/AshComposeView.swift:46,51, Screens/AshVoiceView.swift:22-28, Screens/StoryDetailView.swift:40 · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:49 (accent = colorLalita). SEPARATE and worth its own row: AshVoiceView renders the arrival colour and the fixed `AshVoice.terra` on the SAME screen (:43,81,146 against :116,121,132,181,300,344), so his cards and his glow are two different colours whatever the default is.

### `F2.2` · cost S

**What moves** — Moves a manner, not a claim: the 280ms hold and the 0.28s-out / 0.4s-in opacity gate on the card set are missing, so the stories cut instead of dissolving. The surface already says the same sentence on either side of the swap — the filter changed, these are that room's stories — and it says it with a cut. No walker reads a cut as a different statement about the feed.

**Where** — Home Feed — the moment a room pill is tapped

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RootView.swift:39-41 (onChange reload, no gate), :61 (filter bar), :66 (cards). Design: Claude Design Round 1/Home Feed.html:215-219,256

### `F2.3` · cost S

**What moves** — Two additive affordances, neither contradicting an authored sentence. The AllChip's real consequence is that the feed opens UNFILTERED (`RootView.swift:7` `selectedRoom = nil`) where the comp always has exactly one room lit in its own colour — but the comp settles that for FIVE games, and choosing a default among THIRTEEN rooms is a decision no source makes, so default-to-all is the defensible read and removing it would be a new design decision, not a port. The sort toggle adds an ordering the field never offers, in two mono words. If Ashrey later rules the feed must always stand IN a room, this becomes a claim — it is not one the sources decide.

**Where** — Home Feed — the filter bar and the line beneath it, on arrival

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/CommunityFilterBar.swift:10-12 (AllChip mount), :24-47 (AllChip), :119-145 (FeedSortToggle); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RootView.swift:7 (nil default), :64 (sort toggle mount). Design: Claude Design Round 1/Home Feed.html:249-251 (GAMES.map only), :211-214 (tapping the active pill is a no-op)

### `F2.6` · cost S

**What moves** — Already resolved and correctly halved. The render is built — the 1.2s lead-in, 4.5s duration, the 45% peak and the outer glow all present. The only remaining divergence is the TRIGGER: the design's authored per-story `pulse:true` against the app's derived 7-day window, and the base carries no such field. Adding one would invent content the design never asks for.

**Where** — A story card in the Home Feed river.

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/StoryCard.swift:27-29 (border + shadow), :102-124 (1.2s lead-in, 4.5s split 45/55), :133-147 (isRecent). Design: Home Feed.html:30-34,70-82,110.

### `F3.1` · cost S

**What moves** — Moves a size: 160pt (150 full-width) against an intrinsic ~120pt, with two `Spacer(minLength:0)` opening ~19pt above the glyph and ~19pt between glyph and name where the comp has a flat gap of 12. The card still says the same thing — this room, its living mark, its name — at a larger size, and both comp and app scroll, so no 'all thirteen at once' claim is lost. SEPARATELY WORTH RECORDING, and NOT in this row's two lines: the thirteenth room is mounted `fullWidth: true` where the comp gives the odd-one-out `width: calc(50% - 5.5px)` CENTRED — a full-bleed banner among twelve half-width cards is a hierarchy claim (a featured room vs the thirteenth of thirteen), and that one would pass the test if raised as its own row.

**Where** — Room Selection — the thirteen portal cards, and the thirteenth alone on its row

**Files** — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/RoomPortalCard.swift:18 (`let h: CGFloat = fullWidth ? 150 : 160`), :20 & :29 (the two Spacers), :40 (minHeight/maxHeight); /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RoomSelectionView.swift:32 (the fullWidth thirteenth). Design: Claude Design Round 1/comps/Room Selection.html:600-604 (padding 22/8/16, gap 12, 56pt glyph box), :728-733 (the odd one at 50% width, centred)

### `F3.3` · cost S

**What moves** — The divider already says 'a division here, and this is what it is called'; the flanking rules and centring move the label from inside the seam to under it — typographic structure, not a different statement. Type is already at 9pt/1.62; only the ink tier (ink60 vs ink35) still differs, a value.

**Where** — Room Selection — the seam between the thirteen rooms and the two turns of the field

**Files** — Bindu Feed/Bindu Feed/Screens/RoomSelectionView.swift:93-117

### `F5.1` · cost S

**What moves** — The back chevron already reads as back; the missing 'A STRANGE FEED' is a breadcrumb naming a masthead the walker meets at RootView.swift:85, and its absence is the app-wide floatingBackHub chrome pattern rather than a Story Detail decision.

**Where** — Story Detail — the top-left floating nav strip

**Files** — Bindu Feed/Bindu Feed/Components/HubOverlay.swift:54-64; Bindu Feed/Bindu Feed/Screens/StoryDetailView.swift:135; masthead already present at Bindu Feed/Bindu Feed/Screens/RootView.swift:85

### `F7.2` · cost S

**What moves** — Ten authored glow radii compressed to five; the rank order (Bindu brightest, Lalita next, the middle six, the two roots dimmest) survives, and the design's own middle six span only 13-17. Glow radius is named in the do-not-inflate list. The triple-stacked shadow is loudness.

**Where** — The Players — the eight lens cards and two root cards

**Files** — Bindu Feed/Bindu Feed/Screens/PlayersView.swift:325,340-348; Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:60,67-68

### `G1.3` · cost S

**What moves** — THE ROW IS STALE — the 1.4s master ramp is built (applyMute), and CEIL has no constant by a documented decision: mainMixerNode.outputVolume IS the master and 0.55 is already folded into every per-voice level, so adding CEIL would quieten the whole app. The grep-for-CEIL evidence measured a name, not a behaviour.

**Where** — Sound — mute/unmute across every surface; nothing a walker hears changes

**Files** — Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:242-276 (setMuted + applyMute, dur 1.4); Bindu Feed/Bindu Feed/Sound/AxisTones.swift:12; Bindu Feed/Bindu Feed/Sound/RiteTones.swift:23,31


---

# ADDENDUM · 2026-09-01 — the Xcode Cloud build log's warnings

Surfaced by the first Xcode Cloud build, triaged against the same line. **The build succeeds,
archives and ships; none of these is an error in the current language mode.**

## Fixed on the spot — 8 warnings

| | |
|---|---|
| 4 dead values | `BreathVoice.rightFreq`, `UniverseView.m`, `PointWorlds.H`, `InstrumentView.R0` |
| `Breath.period` → `nonisolated static let` | **the only warning the compiler said outright becomes an ERROR in Swift 6 language mode.** An immutable `Double`; the isolation it inherited from `@MainActor final class Breath` was never protecting anything. |
| `BowlVoicing.peak` → `nonisolated static let` | same shape — read by the two `nonisolated` bowl factories that exist so the tests render what SHIPS. |

**`rightFreq` was worth reading rather than deleting on sight.** It is the binaural offset, in
the voice that produces the binaural pair — the one thing in this app nobody has heard. Had it
been the live path, an unused-value warning would have meant **no binaural offset at all**. It
is not: `BreathVoice.swift:287` uses `snap.rootHz + curBeat`, the LIVE beat that C1's laws
converge toward their target, which is the correct and better version. The snapshot copy was
left behind when the beat became dynamic. *A dead-value warning inside a mechanism nobody has
verified by ear is worth one read before it is worth one deletion.*

## Recorded — 13 concurrency warnings, one deprecation

**All 14 are pre-existing** (sampled sites date to 28–30 Aug, before the stop-condition work)
and **none is a data race.** They are Swift 6 strict-concurrency being unable to prove what is
true at runtime:

- **The Timer closures** (`LightView:588`, `ReturnView:175`) run on the main run loop —
  `Timer.scheduledTimer`'s closure parameter simply is not annotated `@MainActor`.
- **`CeremonyVoice.init` ×5** is reached from `nonisolated static` factories that exist so the
  tests can build the shipping voices without hopping actors. The app calls them from the main
  actor.
- **`FeedStore:828-829`, `RoomFigures:178-179`, `PointLeaving:96`** are the same shape.

**Not fixed before the deploy, deliberately.** Each needs its `nonisolated` boundary audited
individually, and doing that in the hour before a walk is the wrong trade: the risk of the fix
exceeds the risk of the warning. **The hazard is a FUTURE one** — if the project is ever moved
to the Swift 6 language mode these become errors and it stops building. That is a day's work
with the app in front of you, not a deploy-eve change.

**`allowBluetooth` (deprecated) is deliberate and documented at the call site.** It is the
RITE'S RECORDING session, not headphone detection — walk gate **G5** reads
`SoundEngine.isOnHeadphones`, which matches on the `.bluetoothHFP` PORT TYPE
(`SoundEngine.swift:935`) and is untouched by this option. The replacement symbol requires
iOS 26; this app deploys to 18.0.
