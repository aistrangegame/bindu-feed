COUNTS-M1: PORTED 111 · PARTIAL 14 · ABSENT 17 · N-A 20  (162 rows: The Aperture / Chrome / Reading / Return / Rooms v4 / Seam / Sound comps, room-figures.js, field-sound.js)

| symbol | source | verdict | evidence |
|---|---|---|---|
| `fit` (x5) | Aperture:108, Chrome:118, Reading:97, Return:83, Rooms:681, Seam:77, Sound:383 | N-A | Canvas backing-store DPR sizing; SwiftUI Canvas is resolution-independent. |
| `setMode` `drawRegister` `standard` `show` `hide` `live` `openAperture` `frame` | The Aperture.html:117-198 | PORTED | `ApertureView.swift:148-155,272-278,298-317,300,283,319-382,280-296,107-113`. |
| `rgba` `mix` `mixc` `clamp` `ring` `qbez` `rrect` `rnd` `lerp` | all comps | PORTED | `RoomArchive.swift:218-244`, `UniRegions.swift:22-44`, `ReturnStrata.swift:43-44`, `Theme.swift:3`. |
| `applyMode` | The Chrome.html:56 | PARTIAL | `immense` values applied literally (`AxisTravel.swift:70`) but no runtime preset switch, and `DUR` is not a preset value — `glideDur` fixed 5.4. |
| `surfaceAt` `update` `frame` `nearest` `paintWhere` `paintRail` `draw` | The Chrome.html:59-279 | PORTED | `AxisTravel.swift:271-306,184-268`; `AxisModel.swift:110`; `InstrumentView.swift:374-467,560-573`. |
| `swift` | The Chrome.html:88 | ABSENT | **No slip-through. Re-crossing a surface you already meant costs the same full 5.4s ceremony as the first time — the reward for having meant it is invisible.** |
| `dur` | The Chrome.html:89 | PARTIAL | Duration exists but constant; neither the `swift?0.85` branch nor per-distance `TR.DUR` feeds it. |
| `hit` | The Chrome.html:89 | ABSENT | **The passage has no middle — no gate flares at t=0.34 and 0.68. `AxisTravel` publishes only `passageT`.** |
| `after` | The Chrome.html:98 | PARTIAL | `#where` fades back, but no post-landing latch and no shared `dom()` recession across rail + where + shells; the rail snaps. |
| `sayGate` | The Chrome.html:106 | PARTIAL | Line is canon and rendered. Missing the once-ever latch (`gateSaid`), the 700ms trigger, and the 8500ms revert to *"It holds until you mean it."* |
| `paintGauge` `paintGlide` `carried` `paintInvented` `setAB` (x2) `built` `flash` `frame`(Sound) `bad` `figFail` `placeStar` `floorY` | Chrome/Seam/Sound/Reading/Rooms comp rigs | N-A | Comp instrumentation outside the phone frame, A/B demo toggles, JS try/catch placeholders, DOM measurement. |
| `rayPt` | The Reading.html:85 | PARTIAL | One slowly-rotating ray with four passed rings. **Missing the nine arms with `TWIST=[2.30,1.55,0.72]`, BASE, SPREAD, per-universe reach, the spanda pulse, and the followed-arm-brightens behaviour.** |
| `chrome` | The Reading.html:164 | PARTIAL | State word and pressure readout present. Missing the four `given` dots as a progress row, and voice/verb lines fading to 0 on first give. |
| `starMark` `hideSections` `wII` `wIII` `wIV` `wVII` `loc` `frame` | The Reading.html:141-526 | PORTED | `PointWorlds.swift:62-85`; `PointReadings.swift:328,385-471,481-583,602-704,967-1064`. |
| `stackFrom` | The Reading.html:206 | ABSENT | **The reading does not displace the world. Sections stack DOWNWARD in a ScrollView instead of carrying themselves upward against the field. `PointReadings.swift:62-67` already records the matching recede as unimplemented.** |
| `age` `arrive` `rebuild` `draw` `ringPath` `craquelure` | The Return.html:19-334 | PORTED | `ReturnCanon.swift:168-178`; `FeedStore.swift:687,754-782`; `ReturnStrata.swift:47-175`. |
| `renderRings` | The Return.html:123 | PARTIAL | **Missing the LIST of prior returns — each with the words you left and "N voices answered". `ReturnRing` carries no body text at all, so the words cannot be shown.** |
| `renderAnswers` | The Return.html:139 | ABSENT | **THE REGISTER-2 WRITE-BACK ANSWER. A return you seal is never answered by a voice. `sealReturn` writes the ring and your body and nothing else. Searched `answering your return`, `where this lands`, `NEW_ANSWERS` — nothing.** |
| `frame` `paint` | The Return.html:187-344 | PARTIAL | Missing the four-movement continuous drag (`PER=240px`, camera settling 0.46/0.30/0.24/0.20) — app uses nine tap-advanced stages; and the ring's `_in` grow / `_true` settle over 4s. |
| `FLOWER` `archiveOf` `enter` `card` `renderWords` `setLegend` `drawMap` `tap` `leave` `frame` `paint` | The Rooms v4.html:24-886 | PORTED | `RoomArchive.swift:68-115,123-173,244`; `RoomView.swift:121-142,196-250,275-321,342-385,388-461,544-603`. |
| `branch` | The Rooms v4.html:153 | ABSENT | **Gaia's four recursive branching trees rising from the floor — "what it grows out of" (5 levels, `len*0.74`, sway). `RoomFigures.swift:190-238` draws the phyllotaxis and stops. A whole named sub-figure with no string, which no text check could ever catch.** |
| `doorField` | The Rooms v4.html:877 | ABSENT | **The eleven coloured glows orbiting behind the door, so it reads as a field the voices are in rather than a grid of cards. `PlayersView.swift:47` paints a flat colour.** |
| `bands` `say` `frame` `arrive` `draw` `deepSky` `point` `company` `planet` `proj` `doorway` `theFall` `seg` `tap` `openFall` `back` | The Seam.html:84-420 | PORTED | `UniverseCamera.swift:148-155,223-267`; `UniverseView.swift:157-159,214-216,365-450,516-537,655-740,839-1005`. |
| `bandRail` | The Seam.html:352 | PARTIAL | Served by the fifteen-register ladder. Missing the three band-strength gradient bars reading `bands()` directly. |
| `ctx` `master` `bus` `verb` `bed` `bedF` `bedLfo` `ink` `thinNode` `startBedFor` | The Sound.html:55-394 | PORTED | `SoundEngine.swift:80-108,186-220,358-380,680-703,796`; `BreathVoice.swift:56-146,254`; `AxisTones.swift:161-205`. |
| `ana` | The Sound.html:57 | ABSENT | **No read of the real audio output. The comp's AnalyserNode is what lets visuals ride the signal; the app's visuals read a separate `Breath` clock, so visual/audio agreement is ASSERTED, never measured.** |
| `muted` | The Sound.html:70 | ABSENT | **NO USER MUTE ANYWHERE.** grep `mute` → prose only; SettingsView has no sound control. |
| `lalita` `arch` `shweta` | room-figures.js:30-159 | PORTED | `RoomFigures.swift:284-352,353-409,548-631`. |
| `init` `ctx` `master` `bus` `_air` `_pan` `startBed` `bed` `bedFilter` `bedLfo` `apply` `threshold` `inkOn` `inkNode` `inkOff` `openTheRoom` `nave` `closeTheRoom` `breathIn` `veilLift` `lightBed` `start` `startBreath` `tone` `seal` | field-sound.js:32-329 | PORTED | `SoundEngine.swift:80-108,133-220,323,358-380,500,576-642,680-703`; `RiteTones.swift:71-72,120-158`; `SoundSnapshot.swift:16-24`; `BreathVoice.swift:56-146`. |
| `agedBed` | field-sound.js:74 | ABSENT | **The Return's own bed — filter→430, root x0.996, fifth x0.994, breath 1.35x slower, 0.07Hz tape wobble. `SonicContext` has only base/room/point, so the Return opens on the ordinary field bed.** |
| `aged` | field-sound.js:77 | ABSENT | The once-only latch; moot while `agedBed` is absent. |
| `setMuted` `muted` `setOn` | field-sound.js:89,327 | ABSENT | **No mute API, no caller, no sound on/off. Every guard tests `isRunning` and reduce-motion, never a user preference.** |
| `voice` | field-sound.js:92 | PARTIAL | Voice fully ported with partials/vib/gliss/flicker/air/shimmer/pan. **Missing: the bed steps back while a voice speaks (0.030→0.018→0.030); `duckBreath()` is an empty stub at `SoundEngine.swift:812`.** |
| `bowl` | field-sound.js:154 | PARTIAL | Strike ported. **Missing the bed holding its breath under it (to 0.006, back over 9s) — `duckBreath()` empty again.** |
| `ring` | field-sound.js:173 | ABSENT | **The Return's ring tone — `R=[2,3,4,4.5,6,8]` above the root, entering 1.5% flat and coming into tune over 4s: the audible twin of the eccentric ring settling into true. `ReturnView.swift:422` plays a generic bowl instead.** |
| `inkTouch` | field-sound.js:203 | ABSENT | **The field leaning in on each keystroke (0.014→0.022 over 0.12s) while he writes. The ink turns on once, off once, and never responds to the writing.** |
| `_held` | field-sound.js:270 | PARTIAL | The rise exists but is fire-and-forget with its own release; no retained handle, so *"does not release until the veil lifts"* is approximated by a timed envelope. |
| `lightNode` | field-sound.js:305 | PARTIAL | The tone plays but nothing is retained; the light bed cannot be stopped early or held. |
| `lightOff` | field-sound.js:307 | ABSENT | **No way to fade the Light's room tone out. It runs to its own 40s release wherever the user goes.** |
| `darkReturns` | field-sound.js:315 | ABSENT | **Walking back out of the Light — bed filter back to 900, LFO back to 0.1, bed back to 0.030 over 7s. `LightView.swift:540` renders "walk back out" and calls NO sound. Nothing restores the field bed after `lightVeilLift` drained it: the user leaves the app quieter than they found it.** |
