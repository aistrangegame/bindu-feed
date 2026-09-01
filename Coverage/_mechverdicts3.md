COUNTS-M3: PORTED 72 · PARTIAL 45 · ABSENT 37 · N-A 7  (161 rows, uni-fall/uni-field/uni-rooms/uni-sky/walk-continuity/world-one..seven)

| symbol | source | verdict | evidence |
|---|---|---|---|
| `seat` | uni-fall.js:31 | PARTIAL | Fan + Ash's seat exact. Missing `out = 1+(idx%2)*0.24` stagger; `f` counts Ash where design counts non-Ash only. |
| `render` | uni-fall.js:44 | PORTED | `UniverseView.swift:1181-1332` all four layers, halo, strata, mouth, layer name at H-172. |
| `hitTest` | uni-fall.js:163 | PORTED | `UniverseView.swift:370` back-to-front, first hit wins. |
| `company` | uni-field.js:50 | PARTIAL | Missing ceremony-order sort `BY[a].order`, the `thread` flag, and `prefix(6)` has no design counterpart. |
| `motes` | uni-field.js:87 | PARTIAL | Missing lens fade `(1-lens*0.94)`, `dim` arg, and Ash's patina ring — his own returns leave no mark on his mote. |
| `shimmer` | uni-field.js:112 | ABSENT | **At far zoom a well-attended star has no trace of its company — the sky's only far-zoom sign of who sat there.** |
| `hash` `mix` `rgba` `ring` `breath` | uni-rooms.js:14-19 | PORTED | `UniRegions.swift:18-44`, `Breath.swift:20`. |
| `place` | uni-rooms.js:25 | PORTED | `UniRegions.swift:74-120` all thirteen armatures. |
| `arm` | uni-rooms.js:28 | PORTED | `UniRegions.swift:184-201` + thirteen renderers. |
| `field` | uni-rooms.js:38 | PARTIAL | Missing the caller's law: design weights ALL rooms by `inside = clamp((r*1.6-d)/(r*0.9))` so two weathers overlap at a border; app draws only the nearest at flat `bands.region*0.85`. |
| `depthOf` | uni-rooms.js:281 | PORTED | `UniverseView.swift:596-599` verbatim. |
| `bands` | uni-sky.js:18 | PORTED | `UniverseCamera.swift:148-155` verbatim, overlapping. |
| `planet` `proj` `GOLDLESS` `render` | uni-sky.js:26-166 | PORTED | `UniverseView.swift:1006-1177`, `:1017-1022`, `:1067`, `:641-736`. |
| `phase` | walk-continuity.js:41 | PORTED | `Breath.swift:17-20` launch-anchored; no document boundary to lose it across. |
| `home` | walk-continuity.js:49 | PORTED | `FeedStore.swift:862-869` departureZ + 90-min TTL; consumed `ReturnView.swift:453-457`. |
| `setTimeout` | walk-continuity.js:69 | PORTED | `Navigation.swift:17-27` cross-dissolve replaces the 340ms opacity ramp. |
| `reset` `held` `turned` `given` | world-five.js:109-111 | PORTED | `PointWorldView.swift:126`; `PointReadings.swift:769,773,157`. |
| `settling` | world-five.js:111 | PARTIAL | Bool drives the unflip. **Missing the decay `-dt*0.55` and its consequence: when settling expires, `given` RESETS. The app's `revealed` never falls.** |
| `rate` | world-five.js:111 | ABSENT | **No angular velocity — the turn is a quantised half-turn per 40pt swipe, so no speed for sound or glint to read.** |
| `sendBack` `mute` | world-five.js:112 | PORTED | `PointReadings.swift:872`; `PointWorldView.swift:143` the one deliberate silence. |
| `angleOf` | world-five.js:120 | PARTIAL | **Missing the law: no per-group angle, no `pi - a` coupling — turning one pane does not turn its reflection; a pair can show the same face.** |
| `facing` `settled` `grab` | world-five.js:124-128 | PORTED | `PointReadings.swift:796,797`; `PointWorlds.swift:516-519`. |
| `side` | world-five.js:137 | PARTIAL | Alternation exists but not the derivation from `cos(angleOf) >= 0` — a section can arrive "from the other side" of a pane that is facing him. |
| `through` | world-five.js:137 | ABSENT | **The reading never names the mirror it was seen through.** |
| `spin` | world-five.js:145 | PARTIAL | Missing `dx/(rim*0.75)*pi` continuous angle and the sign; app quantises, so carrying a face through edge-on is no longer an act of the hand. |
| `turn` | world-five.js:152 | PARTIAL | Missing `GATES=[0,pi,2pi,3pi]`; `faced[]` never written for pane or partner. |
| `backAt` `release` | world-five.js:161-181 | PORTED | `PointReadings.swift:754-767` MirrorHall wall clock verbatim. |
| `update` | world-five.js:183 | PARTIAL | **Missing the per-frame loop entirely — `ga` easing to rest, `rate` decay, `settling` decay, and the `given` reset.** |
| `displaced` | world-five.js:194 | PORTED | `PointReadings.swift:104,116` k=0.46. |
| `spot` | world-five.js:197 | PARTIAL | Guard's 1.16 loom ported. Missing the corridor `sc = 0.60+(qy+0.62)*0.74` — every pane one size, nothing for the guard to loom against. |
| `draw` | world-five.js:206 | PARTIAL | Missing the corridor's dark ends, perspective recession, and `(1-bk*0.86)` on the hall. |
| `hits` | world-five.js:211 | N-A | SwiftUI hit-testing serves. |
| `build` | world-four.js:51 | PARTIAL | **Missing the room: no `wall: left/floor/back` — the Vessel is not the left wall, the Rules not the floor underfoot, the Others not the wall you cannot walk around.** |
| `reset` `press` `given` | world-four.js:75-76 | PORTED | `PointReadings.swift:606-607,157`. |
| `easing` | world-four.js:76 | ABSENT | **After release the wall relaxes and the world says so for a beat. No term to hang it on.** |
| `load` | world-four.js:80 | PARTIAL | Words present; the NUMBER absent — `clamp((Z+4)/9)` never read, so shell depth does not change how the room bears. |
| `proj` | world-four.js:87 | PARTIAL | Missing deformation under load (`bow`, vault descending, stress hairlines); niches in flat screen coords not projected onto walls. |
| `set` | world-four.js:105 | PORTED | `PointWorlds.swift:439`. |
| `bear` | world-four.js:116 | PARTIAL | Gates verbatim. **Missing `struck[id]` — what was pressed into this wall is not remembered.** |
| `release` | world-four.js:129 | PARTIAL | Missing the `press>0.1 -> easing=1` half; nothing lingers. |
| `update` | world-four.js:130 | PARTIAL | `press -= dt*0.52` verbatim. Missing the close-and-reset clause and the easing decay. |
| `displaced` `draw` | world-four.js:137-140 | PORTED | k=0.46; stone, ember, deboss, impression at `press*2.4`, nothing below 0.05. |
| `hits` | world-four.js:145 | N-A | SwiftUI hit-testing. |
| `place` | world-one.js:42 | ABSENT | **The authored still figure is gone — five statements settled in a row, three questions below and apart, two laboratories at the edge. The world whose subject is stillness is laid out at random (hash ring).** |
| `reset` `near` `still` `given` | world-one.js:68-69 | PORTED | `PointReadings.swift:288,369-371` build/decay verbatim. |
| `leaving` | world-one.js:69 | ABSENT | **The reading does not linger and fade; the world never says "IT CLOSED. IT DOES NOT MIND." — the line that makes a penalty-free close legible.** |
| `pick` | world-one.js:77 | PARTIAL | Touch/release inversion exact. Missing: a different star does not reset `given`; leaving does not raise `leaving`. |
| `update` | world-one.js:88 | PARTIAL | Gates and rates verbatim. **Missing the `moving` argument — motion does not cancel, only touching suspends.** |
| `displaced` | world-one.js:106 | PORTED | k=0.62, the deepest recede. |
| `draw` | world-one.js:109 | PARTIAL | Missing the Recognition's hairline through the five, the stay-only halo, and the three universes named at their region edges. |
| `hits` | world-one.js:113 | N-A | SwiftUI hit-testing. |
| `reset` | world-seven.js:132 | PORTED | Vacuous here; nothing dances. |
| `hand` | world-seven.js:133 | ABSENT | **No hand on the floor — nothing has a place to be offered to.** |
| `joinedQ` | world-seven.js:133 | ABSENT | **No join queue — several bodies taking his hand in one frame, none lost.** |
| `chain` | world-seven.js:135 | ABSENT | **The caption prints `\(revealed) hands` — it counts hands that do not exist.** |
| `carry` | world-seven.js:135 | PARTIAL | Accumulator exists. Missing `dt*(0.52 + chain.length*0.46)` — driven by his own hand speed, so *"it goes quicker in company"* is not mechanically true. |
| `given` | world-seven.js:135 | PORTED | `revealed`. |
| `reading` | world-seven.js:137 | PARTIAL | Missing `resolved>0 ? MAP : chain[0]`. |
| `displaced` | world-seven.js:138 | PARTIAL | The -1 inversion and 0.54 exact. Missing the gate: design inverts while `hand && !resolved`; app inverts while `revealed<4`. |
| `offer` | world-seven.js:145 | ABSENT | **The cue says "offer a hand" and nothing can take one.** |
| `moveHand` | world-seven.js:150 | ABSENT | **No leading the chain across the floor.** |
| `letGo` | world-seven.js:154 | ABSENT | **Letting go drops the chain, un-chains everyone, zeroes carry and given.** |
| `update` | world-seven.js:166 | ABSENT | **THE ENTIRE FIGURE: cohesion, separation, alignment, shared swirl, spring to the held hand, trails, soft floor edge, Kuramoto phase coupling, who joins and when, d-map's unasked arrival. The world named THE DANCE has no coupled bodies.** |
| `joinedNow` | world-seven.js:168 | ABSENT | Nothing joins. |
| `gaveNow` | world-seven.js:168 | PORTED | `PointReadings.swift:1051`. |
| `lock` | world-seven.js:251 | ABSENT | **How in time the chain is — the one number sound and shader are meant to read — and its decay once he lets go.** |
| `resolved` | world-seven.js:295 | PARTIAL | Two closing lines verbatim. Missing d-map joining unasked, `given=4` at once, and `damp = 1-res*1.6`. |
| `_join` | world-seven.js:301 | ABSENT | **No `danced` record, no `order` — which the world's ending depends on.** |
| `tookHand` | world-seven.js:308 | ABSENT | No queue to drain. |
| `danceCount` | world-seven.js:309 | PARTIAL | Read as a two-state Bool for the cue. Missing the count and the per-body `danced` flags. |
| `draw` | world-seven.js:312 | PARTIAL | Missing warm level floor, trails, held hands as a chain, per-body upbeat pulse, soft edge, resolved architecture. |
| `hits` | world-seven.js:317 | N-A | SwiftUI hit-testing. |
| `reset` | world-six.js:103 | PARTIAL | **Missing *"it does not cancel a lap."* The arc lives in `@State` + a DispatchQueue chain, so leaving the register kills the flight.** |
| `holding` | world-six.js:103 | ABSENT | **No taking a star into the hand before it goes.** |
| `lift` | world-six.js:103 | ABSENT | **No drawing it up, and no `lift<0.14` threshold that makes a touch a touch.** |
| `reading` | world-six.js:103 | PORTED | The open star. |
| `grab` | world-six.js:106 | ABSENT | **All three refusals missing: hand passes through Deep Time; a star in flight is not there to take; one home cannot be sent again.** |
| `aim` `aimTo` | world-six.js:117-120 | ABSENT | **No aim, -1..1, that shapes the arc.** |
| `release` | world-six.js:128 | PARTIAL | Send cannot be recalled — the core claim holds. Missing aim, lift threshold, lap number, and `DUR=[3.2,5.4,8.0,11.2]`; app uses a flat 2.4s out / 2.4s back for every lap. |
| `flying` | world-six.js:138 | ABSENT | **No arc registry — several out at once, returning in their own order, not his.** |
| `tick` | world-six.js:144 | ABSENT | **No wall clock. *"If he leaves the register, they still come back"* is not true in the app.** |
| `home` | world-six.js:152 | ABSENT | **Every return comes through the particle and the centre flashes. Monroe's I-There — the image the world was built to draw — is not drawn.** |
| `arcs` | world-six.js:161 | ABSENT | **Everything in flight as a list. The app carries exactly one.** |
| `deepSent` | world-six.js:166 | ABSENT | **Deep Time letting itself go once he knows what a return looks like, already mid-flight when it appears.** |
| `take` | world-six.js:172 | ABSENT | **`pend` — arrivals that waited lit at their post while he was away. *"Nothing gathered is lost — including by wandering off."*** |
| `update` | world-six.js:173 | ABSENT | No per-frame loop; no `home` flash decay. |
| `outbound` | world-six.js:177 | ABSENT | **How much of the world is out there, which the voice is meant to wear.** |
| `displaced` | world-six.js:185 | PARTIAL | -1 inversion and 0.54 exact. Missing the gate `!reading \|\| holding`. |
| `quiet` | world-six.js:191 | PORTED | `PointReadings.swift:895`. |
| `spot` | world-six.js:195 | PARTIAL | Depth-as-age ported. Missing the authored qx/qy bands and the depth scale. |
| `path` | world-six.js:201 | PARTIAL | Missing three of four segments: the visible slow turn at the far point, the dimming beyond the line, and the return through the centre. |
| `draw` | world-six.js:236 | PARTIAL | Missing BEYOND's thinning gradient and the kept arcs — *"every completed lap leaves its curve in the sky, permanently — the only score this world keeps."* |
| `hits` | world-six.js:240 | N-A | SwiftUI hit-testing. |
| `place` | world-three.js:45 | PARTIAL | Shadow flag kept. Missing the three rings by universe and `COVER=[0.72,0.94,0.44]` — the Inheritance is not the deepest-buried, the Old Maps do not lie shallow. |
| `reset` `hand` `reading` `given` | world-three.js:70-71 | PORTED | `PointReadings.swift:485-486,571,157`. |
| `open` | world-three.js:71 | PARTIAL | The FIELD has an open scalar; the READING does not — `part` is a point or nil. Missing `+0.34` on place and `+dt*0.42` while held. |
| `closing` | world-three.js:71 | ABSENT | **The veil closing behind his hand leaves nothing; the closed line has nothing to fade on.** |
| `move` | world-three.js:87 | PARTIAL | Missing: moving over a different star re-picks it and resets `given`. |
| `hold` | world-three.js:97 | PARTIAL | **INVERTED. Design gives on gates of `open` WHILE HE HOLDS; app gives on `onEnded` — on RELEASE. The exact opposite of *"read THROUGH a parting he is actively holding."*** |
| `handBack` | world-three.js:110 | PARTIAL | Thin zones cut permanently within the reading. Missing per-star keying, growing radius, and survival across readings. |
| `isBack` | world-three.js:116 | PARTIAL | `partedOnce` two-state ported. Missing the per-star radius query. |
| `release` | world-three.js:120 | PARTIAL | Hand drops. Missing `closing = 1`. |
| `update` | world-three.js:124 | ABSENT | **No per-frame loop: `open -= dt*0.70` never runs, so the veil does not close behind him, and what was read through a parting survives the parting.** |
| `displaced` `uHand` `uBack` | world-three.js:132-136 | PORTED | k=0.50; hand and thin-zone list fed to the veil renderer. |
| `draw` | world-three.js:145 | PARTIAL | Four curtains, parting, thin zones, v-shadow line. Missing the per-star `lift` — a star occluded by exactly the veil visibly over it. |
| `hits` | world-three.js:149 | N-A | SwiftUI hit-testing. |
| `toS` | world-three.js:151 | PORTED | `PointWorlds.swift:367-368`. |
| `emit` | world-two.js:45 | ABSENT | **The nine authored rays with per-universe curl, reach and drift. *Nothing is placed, everything is emitted* is not built. The Longing does not reach furthest; the Mechanics do not leave in a bundle; the Choice does not leave nearly straight.** |
| `reset` `out` `given` | world-two.js:73-74 | PORTED | `PointReadings.swift:389,157`. |
| `following` | world-two.js:74 | PARTIAL | `drawingId` exists but is the star drawn INWARD — the opposite motion. The reading has no ray identity, only a scalar. |
| `reeling` | world-two.js:74 | ABSENT | **The reel-back's lingering term and the line that fades on it.** |
| `take` | world-two.js:87 | PARTIAL | Missing the nearest-arm search and `out = max(out, f*0.55)`. |
| `drag` | world-two.js:104 | PARTIAL | Missing: `out` as the hand's actual distance in the arm's geometry; gates are quartiles not `[0.20,0.44,0.68,0.90]`. |
| `release` | world-two.js:116 | ABSENT | **`ReadFollowing` has an `.onChanged` and no `.onEnded`. Letting go is not an event in this world at all.** |
| `update` | world-two.js:117 | ABSENT | **`out -= dt*0.30` never runs. *"Stop, and the arm reels him gently back; the Return is always where he started"* does not happen.** |
| `displaced` | world-two.js:126 | PORTED | k=0.54. |
| `draw` | world-two.js:129 | PARTIAL | Missing the nine curling arms, spanda (one pulse per breath down all nine at once), the 108 continuously-born motes, and the followed arm brightening while the rest hurry on. |
| `hits` | world-two.js:133 | N-A | SwiftUI hit-testing. |
| `split` | world-two.js:238 | ABSENT | **One light becoming many, drawn literally — white and unified at the origin, separating into its own hue further out. This is the sentence the world exists to perform.** |
| `lerp` `rgba` `mix` | world-two/three/five/six/seven | PORTED | `Theme.swift:3`, `UniRegions.swift:22`, `RoomArchive.swift:224-229`. |
