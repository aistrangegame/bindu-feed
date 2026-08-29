COUNTS-M2: PORTED 105 · PARTIAL 15 · ABSENT 29 · N-A 13  (162 rows: point-levels/point-sound/point-yantra/return-strata/rite-scenes/spine-axis/spine-field/spine-sound/uni-deep/uni-fall, field-sound tail)

PREMISE CORRECTIONS FROM THIS BATCH:
- The app DOES cite `spine-sound.js` — once, at `Sound/AxisTones.swift:5`, a file-level nod with no line reference covering only the nine axis-travel tones. Nothing else references it.
- `PointReadings.swift` and `PointWorlds.swift` contain **ZERO** `soundEngine` calls. Grep for `soundEngine|SoundEngine` in both files returns nothing.

| symbol | source | verdict | evidence |
|---|---|---|---|
| `hzFor` | field-sound.js:330 | PORTED | `RiteContent.swift:72-173` HZ map verbatim; `\|\|220` default at `RoomView.swift:236`. |
| `constellation` `openUniverse` `openSheet` `closeSheet` `clearT` `generate` `descend` `openAperture` `closeRope` `nameList` | point-levels.js:131-283 | PORTED | `PointWorlds.swift:117-119`; `PointWorldView.swift:126,170-175,352-419,409-417,433`; `ApertureView.swift:277-318`; `DoorView.swift:268-271`; `PointJourney.swift:44-49`. |
| `openRope` | point-levels.js:260 | PARTIAL | Overlay, breathing dot, verbatim line, both exits. Missing the alternating `breathe in`/`breathe out` cue words on the 5s cadence, and `Journey.rope` is never set. |
| `speak` | point-levels.js:284 | PARTIAL | Missing the rope line *"You reached for the rope. I was the dot you breathed with."* and the flag that fires it; the design's `shimmer()`+`om()` at the split is one `riteBowl(136.1)`. |
| `phase` `breath` `ensure` `verb` `drone` `world` `curIdx` `cur` `step` | point-sound.js:19-73 | PORTED | `Breath.swift`; `BreathVoice.swift:104-121,147-168`; `SoundEngine.swift:80-109,227-247,290-313`; `AxisTones.swift:129-131`. |
| `_stone` `ctx` `master` `bus` | point-sound.js:21-39 | N-A | WebAudio node graph → `AVAudioEngine` + `AVAudioUnitReverb`. |
| `blip` | point-sound.js:83 | PARTIAL | One-shots fire at the design's blip sites. **Missing the blip ENVELOPE — 0.02s attack / 0.7s exponential decay at fx2; the app substitutes a bowl or a 1.5s-attack choir voice.** |
| `glide` | point-sound.js:91 | ABSENT | **The descent and the ascent are SILENT. `descend()` plays no tone; `ascend()` only zeroes the glide voice. No f→f/2 2.2s ramp anywhere.** |
| `shimmer` | point-sound.js:101 | ABSENT | **The aperture's arrival and the reveal have no shimmer.** |
| `toggle` | point-sound.js:124 | PARTIAL | Start/stop and scene fades exist. **Missing any user-facing sound on/off, and the master ramp that re-seeds the enclosure.** |
| `lerp` `clamp` `rgba` `init` `sky` `loop` `hue` `setHue` `focus` `setFocus` `flare` `mode` `setMode` `scale` `band` `toScreen` `anchors` `_petals` `_tri` `_square` `_figure` `draw` `flares` | point-yantra.js:11-151 | PORTED | `PointYantra.swift:22-334` — the whole yantra, including the `idx % 2 ? 0.16` anchor stagger and the eased `0.22` dim (recorded divergence). |
| `cvs` `dpr` `fit` `raf` | point-yantra.js:32-38 | N-A | Canvas/DPR/rAF plumbing; SwiftUI `Canvas` + `TimelineView`. |
| `rgba` `mix` `mixc` `clamp` `age` `ringPath` `craquelure` | return-strata.js:7-51 | PORTED | `ReturnStrata.swift:43-113`; `ReturnCanon.swift:168-179`. |
| `grainURL` | return-strata.js:27 | ABSENT | **`Materials.grain` is computed and read by nothing — the Return's surface never coarsens with age.** (Mitigating: the comp drops it too and the design never calls it.) |
| `drawField` | return-strata.js:64 | PARTIAL | Arrived state ported whole. **Missing the `z`-driven approach — `s = 0.013 + (1-0.013)z`, the fall streaks below 0.88, the ring `pass` sweep-out, the `camTarget` easing. App pins `s = 1.0`.** |
| `rnd` `rgba` `breath` `mix` `ring` `dust` `rrect` `qbez` `bindu` `neev` `gaia` `branch` `sid` `arch` `shweta` `karishma` `sakshi` `lalita` `ashrey` | rite-scenes.js:19-383 | PORTED | `GatheringScene.swift:47-727` — all ten geometries. **NOTE: `branch` IS ported here (`:108-125` gaiaBranch); it is the ROOM-scale Gaia at `RoomFigures.swift:255` that drops it.** |
| `rim` `weight` `presence` `clamp` `fill` `name` `where` | spine-axis.js:75-118 | PORTED | `InstrumentField.metal:199,204`; `AxisModel.swift:42-47,102-117`; `InstrumentView.swift:471-484,597,610`. |
| `touch` | spine-axis.js:114 | ABSENT | **The particle keeps no record of having been touched — no `born`, no `touches`. The one object that says "every dot you touched was me" counts nothing.** |
| `doorsAt` | spine-axis.js:123 | PARTIAL | Two of three doors carry label AND line. Missing the z=0 rite door and the generic `near = 1-\|Z-d.z\|/0.42` proximity fade; doors are hardcoded per register. |
| `init` `sky` `base` `setSky` `setWeather` `draw` | spine-field.js:175-217 | PORTED | `InstrumentField.metal:12-28,187-188`; `UniRegions.swift:540-571`; `InstrumentView.swift:520-554`. |
| `hand` | spine-field.js:199 | PARTIAL | Shader accepts it. **Fed `float3(0,0,0)` — the atmosphere never parts under the hand; the Veil's parting lives only in the reading layer.** |
| `back` | spine-field.js:199 | PARTIAL | Handed-back memory exists in the reading. **The shader's `uBack[9]` — nine permanent thin places in the atmosphere — has no Metal counterpart.** |
| `setRoom` | spine-field.js:211 | PARTIAL | `Axis.roomHue` recolours the CHROME. **The shader's slots 1-3 stay compile-time `#8A93A6` — the atmosphere itself is still generic on the Universe side.** |
| `phase` `breath` `ensure` `ready` `stop` `axis` `curKey` `cur` `slide` | spine-sound.js:30-333 | PORTED | `SoundEngine.swift:23,39,48,80-109,227-232,290-313`; `AxisTones.swift:129`; `InstrumentView.swift:252-262`. |
| `_stone` `ctx` `master` `bus` `setTimeout` | spine-sound.js:32-100 | N-A | Node graph → AVAudioEngine. |
| `echoIn` | spine-sound.js:52 | ABSENT | **The send into the delay line — VI's whole physics.** |
| `dly` | spine-sound.js:53 | ABSENT | **The delay itself (3.0s max, 0.42s time, feedback 0.44, 2400Hz lowpass). Nothing in the app can make the room longer. The app has exactly ONE audio unit: a reverb.** |
| `dlyOut` | spine-sound.js:57 | ABSENT | **The delay return into master and reverb.** |
| `_voice` | spine-sound.js:63 | PARTIAL | L/R pair, 0.1Hz LFO, octave 0.06, one-pole lowpass, 0.055 target all present. **Missing the peaking resonance (`pk`), the null gain (`nul`) and the echo send (`ech`) — FOUR of the seven register laws hang off exactly those three nodes.** |
| `narrow` | spine-sound.js:106 | ABSENT | **I · THE POINT — the beat never converges toward unison as a reading is given up. The reading arriving is inaudible.** |
| `widen` | spine-sound.js:116 | ABSENT | **II · THE TURN — the second tone never departs as he travels out. The One becoming the many is not heard.** |
| `unveil` | spine-sound.js:126 | ABSENT | **III · THE VEIL — the register never arrives muffled and opens 340 → 19.7kHz, and there is no floor from what was handed back.** |
| `bear` | spine-sound.js:138 | ABSENT | **IV · THE CHAMBER — no resonance swelling at the register's own frequency, no 2% pitch sag under load.** |
| `reflect` | spine-sound.js:156 | ABSENT | **V · THE MIRRORS — the pane's angle never signs the second tone; edge-on-is-nothing and turned-away-is-hollow are silent.** |
| `nul` | spine-sound.js:164 | ABSENT | **The one deliberate silence in the Point — the voice summed against itself at −1. (The r-guard mute suppresses an EVENT; it does not cancel the bed.)** |
| `distance` `send` `arrive` `arriveAll` | spine-sound.js:176-224 | ABSENT | **VI · THE RETURN — the room never lengthens while something of his is away; nothing bends down and away as it goes; the four returns each later/quieter/one interval up do not swell in backwards; Deep Time's all-four-at-once is absent.** |
| `join` `ensemble` `leaveAll` `dancers` | spine-sound.js:236-267 | ABSENT | **VII · THE DANCE — each body joining is not a real voice at a harmonic of 852; the chord never tunes itself as lock rises; there is no polyphonic voice pool. The instrument's only polyphonic register is monophonic.** |
| `resolve` | spine-sound.js:271 | ABSENT | **The close of the Point: nine tones at 852x[1,9/8,5/4,4/3,3/2,5/3,15/8,2,3] pulling to one, and the 852 → 963 rise. The app plays a single bowl.** |
| `strike` | spine-sound.js:294 | ABSENT | **The impression taken — a triangle at f0x0.5 through a bandpass at f0x1.5. The visual struck title exists; no sound.** |
| `many` | spine-sound.js:308 | ABSENT | **The many arriving as a chord once he is far out. (`carryTone` is `B.carry`, a different call.)** |
| `blip` | spine-sound.js:343 | PARTIAL | Same as point-sound: sites fire, envelope wrong. |
| `threshold` | spine-sound.js:353 | PARTIAL | Bowl bloom at every crossing. **Missing the FLAT — the design strikes at fx0.985 and rises into tune over 2.2s so the crossing is HEARD as a crossing. Nothing in the app rises into tune.** |
| `shimmer` | spine-sound.js:363 | ABSENT | **The five-tone stagger at [285,396,528,639,852]x2.** |
| `toggle` | spine-sound.js:385 | PARTIAL | No user-facing on/off; no master re-seed ramp. |
| `init` `star` `room` `weather` `drawWorldLayer` `drawFallLayer` `hits` `ringLit` `openSeat` `hit` `rgba` `mix` | uni-deep.js:84-362 | PORTED | `UniverseView.swift:83-87,370-386,646-651,944-1004,1181-1332`; `UniRegions.swift:22-27,540-558`. **`drawWorldLayer` — the mechanic that had gone missing — is built.** |
| `drawSweep` `gather` `said` `fade` | uni-deep.js:97-114 | ABSENT | **The sky's sweep: the line drawn across everything he has lived, what it crosses answering with its own title, the timestamp, the 0.30/s decay. `uSweep` is fed `float2(0,0)`.** |
| `drawSkyLayer` | uni-deep.js:123 | PARTIAL | Thirteen regions at true coordinates with arms, settlements, names, civ. **Missing the dwell recognition — rooms bending light toward the centre — and the line *"This is what you look like from outside."*** |
| `drawRegionLayer` | uni-deep.js:188 | PARTIAL | Region field + arm + stars. **Missing the dwell panel *"WHAT BUILT THIS PLACE"* / *"WHAT THIS ROOM HOLDS"* with up to three belief-structures and the looseness-wobbled underline; and the met/unmet settlement distinction.** |
| `layers` `seg` | uni-fall.js:21-22 | PORTED | `UniverseView.swift:1184-1190`; `ReturnView.swift:184-187`. |
