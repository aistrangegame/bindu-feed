COUNTS-1: 42 CLOSED · 34 OPEN · 9 NEEDS-JUDGMENT · 0 NOT-YET-EXAMINED

| ID | SEV | KIND | short title | VERDICT | evidence |
|---|---|---|---|---|---|
| A1.1 | MAJOR | DATA | authored line breaks flattened on ingestion | NEEDS-JUDGMENT | `MirrorView.swift:274-279` honours `\n` if present. Whether the 24 Live Mirror Card rows carry `\n` is a base fact. |
| A1.2 | MAJOR | DATA | cohort A is not Mirror content at all | NEEDS-JUDGMENT | Code never reads `Category`. Cohort membership is a base fact. |
| A1.3 | MAJOR | DATA | register back-filled uniformly, Koan under-represented | NEEDS-JUDGMENT | 12/12 split claimed in CLAUDE.md §8 but is a base fact. |
| A1.4 | MINOR | DATA | one design reflection paraphrased, not stored | NEEDS-JUDGMENT | Base fact; app carries no copy either way. |
| A1.5 | MAJOR | DATA | `Card Register` optional; nil silently renders as Vow | OPEN | `Models.swift:333` optional; `MirrorView.swift:265-266` nil falls to "A VOW · ARRIVED". |
| A1.6 | MAJOR | DATA | day-hash and draw index a mutable, growing pool | OPEN | `MirrorView.swift:181,208-209` modulus is still the live record count. |
| A2.1 | MAJOR | DATA | display-lines replaced by runtime sentence-splitter | CLOSED | `SignalView.swift:285-290` now splits on `\n` only. |
| A2.2 | MAJOR | DATA | Signal pool carries 12 Codex/business rows | NEEDS-JUDGMENT | Pool composition is a base fact. |
| A2.3 | MAJOR | DATA | same cohort leaks into the launch threshold | CLOSED | `FeedStore.swift:439-441` gaiaSeeds has its own pool. |
| A2.4 | MAJOR | DATA | two design Signals absent in designed form | NEEDS-JUDGMENT | Base read required. |
| A3.1 | MAJOR | DATA | Practice Invitations duplicate ontology rows | NEEDS-JUDGMENT | `Models.swift:375,387` now carries `subLine`; row content is a base fact. |
| A3.2 | MINOR | DATA | canonical threshold sentence absent; bare seed titles | NEEDS-JUDGMENT | `Models.swift:316` reads the multiline field; rest is a base read. |
| A4.1 | MAJOR | DATA | met-ness derived from a proxy, not `Story Met` | CLOSED | `UniverseView.swift:608` + `AirtableService.swift:651` `{Activity Type}='Story Met'`. |
| A4.2 | none | none | depth-from-resonance is correct | CLOSED | `UniverseView.swift:596-599` verbatim. |
| A4.3 | MAJOR | DATA | the Point's descent write-back never built | OPEN | grep `Point Descent` → 1 comment only, `PointWorldView.swift:5`. No write path. |
| A4.4 | MAJOR | DATA | the 66 stars live in two places at once | CLOSED | Ruling recorded, CLAUDE.md:353 — canon ships as a Swift copy, never read from base. |
| A4.5 | MINOR | DATA | the Audio Anchor's kept voice is device-local only | OPEN | `AirtableService.swift:450-451` writes a filename; `AudioAnchorPlayer.swift:43-46` gates on a local file. |
| B0.1 | BLOCKER | VISUAL | arming happens only on a key CHANGE | CLOSED | `axisLocked` gone; only comments remain. |
| B0.2 | BLOCKER | VISUAL | lock makes four Universe registers unreachable | CLOSED | Zoom derived from Z at `UniverseCamera.swift:137-140`. |
| B0.3 | BLOCKER | VISUAL | dead band at the Feed edge is a total deadlock | CLOSED | `InstrumentView.swift:86-91` band is a floor; `:132` hit-testing no longer opacity-gated. |
| B0.4 | BLOCKER | VISUAL | surface 0 one-way valve; the Light has a refused door | CLOSED | `AxisTravel.swift:111` opens `mem[GATE]` at `z <= -4.5`. |
| B0.5 | MAJOR | VISUAL | stillness at the sky has no reward, only punishment | OPEN | `InstrumentView.swift:536` `uDwell` hard-zeroed; the light-bend and its line are absent. |
| B0.6 | MAJOR | DATA | the particle is not the sky's light source | OPEN | `InstrumentView.swift:501` suppresses the self-name across the whole Universe band. |
| B1.1 | MAJOR | VISUAL | velocity only sampled at drag END | CLOSED | `UniverseCamera.swift:189-197` samples every move. |
| B1.2 | MAJOR | VISUAL | friction wrong and frame-rate dependent | CLOSED | `UniverseCamera.swift:242` `pow(0.945, f)`, dt capped. |
| B1.3 | MAJOR | VISUAL | zoom momentum machinery is dead code | CLOSED | `nudgeZoom`/`flyTo` gone; tap impulse routes to the axis. |
| B1.4 | MAJOR | VISUAL | ZMIN/ZMAX span 12x where design is 154x | CLOSED | `UniverseCamera.swift:64-65` 0.22 / 34.0. |
| B1.5 | MAJOR | VISUAL | tap-to-fly snaps to a fixed zoom | CLOSED | `UniverseView.swift:401,423` recentre by fraction, no zoom-to-fit. |
| B1.6 | MINOR | VISUAL | the projection is anisotropic | OPEN | `UniverseView.swift:622-628` 0.401 vs 0.4415 px/unit at 393x852. |
| B1.7 | MINOR | VISUAL | pan bounds ~1.7x where design gives ~2.9x | CLOSED | `UniverseCamera.swift:218`. |
| B1.8 | MINOR | VISUAL | entry snaps | CLOSED | `reset()` touches focus only. |
| B2.1 | BLOCKER | VISUAL | design uses continuous bands; code hard-switches | CLOSED | `UniverseCamera.swift:148-155 bands()`. |
| B2.2 | BLOCKER | VISUAL | world teleported to frame centre at fixed radius | CLOSED | `UniverseView.swift:888-891` drawn at the star's own projected position. |
| B2.3 | MAJOR | DATA | eleven authored wayfinding strings absent | OPEN | grep "long lived on"/"newly alive"/"still waiting" → 0 hits each. |
| B3.1 | none | none | geometry, colours, counts: EXACT MATCH | CLOSED | `UniRegions.swift:122-134` unchanged. |
| B3.2 | MAJOR | DATA | `hz` dropped from the room record | CLOSED | `UniRegions.swift:69` + all 13 values. |
| B3.3 | MAJOR | DATA | nebula brightness not derived from region contents | OPEN | `UniverseView.swift:675,677` no `litN`, no falloff. |
| B3.4 | MAJOR | DATA | per-room WEATHER table and DENS absent | CLOSED | `UniRegions.swift:540-573` + fed at `InstrumentView.swift:543,556`. |
| B3.5 | MAJOR | VISUAL | region weather is binary and single-region | OPEN | `UniverseView.swift:661-663` one nearest region, no distance term, no frame tint. |
| B3.6 | MAJOR | DATA | stars collide when a room holds more than `n` stories | OPEN | `UniverseView.swift:633` `i % rm.n` — story 8 lands on slot 0. |
| B3.7 | none | none | structures: exact match | CLOSED | `UniRegions.swift:146-180`. |
| B3.8 | MINOR | COSMETIC | region arms don't fade; labels wrong size/side | CLOSED | `UniverseView.swift:670,685-689`. |
| B4.1 | BLOCKER | VISUAL | stars never grow; continuity mechanism missing | CLOSED | `UniverseView.swift:857` `R = st.pr * zoom`; planet handoff at `R >= 6`. |
| B4.2 | MAJOR | VISUAL | dust is screen-space, no depth parallax | OPEN | `UniverseView.swift:789-791` x-only, y never moves, no z clamp. |
| B4.3 | MAJOR | VISUAL | company motes: physics and rendering thinned | OPEN | `UniverseView.swift:914` wobble still radial not angular; no ceremony sort; fixed sizes; no halo; no Ash patina. |
| B4.4 | MINOR | DATA | `shimmer()` absent | OPEN | grep in `Universe/` → 0 hits. |
| B4.5 | MINOR | VISUAL | lanes: visibility binary | CLOSED | `UniverseView.swift:757` design formula verbatim. |
| B4.6 | MINOR | VISUAL | planet renderer — two deltas | CLOSED | `UniverseView.swift:1009,1012`. |
| B5.1 | BLOCKER | VISUAL | the fall has no gesture of its own | CLOSED | `UniverseCamera.swift:98-103 descendBy`. |
| B5.2 | BLOCKER | VISUAL | the mouth (layer 4) can never render | CLOSED | `UniverseCamera.swift:253` desc reaches 1; `:90 atMouth`. |
| B5.3 | BLOCKER | DATA | the Return is auto-fired, unconfirmed, loses the story | CLOSED | `UniverseView.swift:212-222` fires only on `mouthMeant`, story never nil. |
| B5.4 | BLOCKER | DATA | nothing in the fall is touchable | CLOSED | `UniverseView.swift:365-388` hit-tests presences and rings. |
| B5.5 | MAJOR | DATA | the four layer-names are missing | CLOSED | `UniverseView.swift:1325,1331` at `H-172`. |
| B5.6 | MINOR | VISUAL | the seating fan is flattened | OPEN | `UniverseView.swift:1266` counts Ash in `f`; no `out` stagger. |
| B5.7 | MINOR | VISUAL | the pre-settle orbit is synchronised | OPEN | `UniverseView.swift:1269` evenly spaced, phase-locked. |
| B5.8 | MAJOR | VISUAL | `enter` derived from the wrong quantity | OPEN | `UniverseView.swift:1193` off the descent, not a camera flight. |
| B6.1 | BLOCKER | DATA | the world scale is a dead end: there is no door | CLOSED | `UniverseView.swift:516-565` doorway + TOUCH TO READ + route. |
| B7.1 | MAJOR | VISUAL | THE SWEEP (the sky's own gesture) | OPEN | `InstrumentView.swift:537` `uSweep` hard-zeroed; no implementation. |
| B7.2 | MAJOR | VISUAL | THE DWELL (the region's gesture) | OPEN | grep `dwell` in `Universe/` → 0 hits. |
| B7.3 | MAJOR | DATA | THE TURN (the world's gesture) | CLOSED | `UniverseCamera.swift:45-53` + `UniverseView.swift:944-1004` three faces + TURN IT. |
| B7.4 | MINOR | VISUAL | the lens is a text button, not the rail | OPEN | `UniverseView.swift:139-148` a Button; no 30px rail, no knob, no toggle voice. |
| B7.5 | MINOR | VISUAL | back is one jump, not one scale at a time | OPEN | `InstrumentView.swift:188` leaves the whole Universe; no ladder. |
| B7.6 | MINOR | VISUAL | inventions the design never had | OPEN | 2 of 4 remain: focus ring `:879`, corner exclusion `:363`. |
| B8.1 | MAJOR | DATA | the Universe is silent | OPEN | 5 sound sites exist, but region-entry tone and scale-change tone have no call site; `layerCross` → 0 hits. |
| C1.1 | none | none | names, z, order and Hz: MATCH | CLOSED | `AxisModel.swift:79-95` all 15 identical. |
| C1.2 | MAJOR | DATA | `the centre` has no colour; renders error hue | CLOSED | `AxisModel.swift:65`. |
| C1.3 | MAJOR | VISUAL | Feed / gate hues swapped | CLOSED | `AxisModel.swift:63-64`. |
| C1.4 | MAJOR | DATA | four Universe registers collapsed to one grey | OPEN | `:61-62` region/world/fall share one resting hue; `Axis.roomHue` never assigned (3 hits, no writer). |
| C1.5 | MAJOR | DATA | `sub`/`roman`/`dim` dropped from the model | CLOSED | `AxisModel.swift:28-32,42-47,80-94`. |
| C1.6 | MAJOR | DATA | the three ceremony DOORS were never ported | OPEN | z:0 rite door, the table and the 0.42 proximity ramp absent (two doors hand-placed). |
| C1.7 | MINOR | DATA | `clampZ` wrong ceiling and dead code | OPEN | Ceiling fixed at `:106`; still zero call sites. |
| C1.8 | MAJOR | VISUAL | `rim()` / `weight()` never ported | OPEN | No `Axis.rim`/`Axis.weight`; content still mounts full-frame. |
| C2.1 | BLOCKER | VISUAL | four hand-feel constants from the wrong design layer | CLOSED | `AxisTravel.swift:77` + `:318` glideDur 5.4. |
| C2.2 | none | none | membrane `update()` is a faithful port | CLOSED | `AxisTravel.swift:258-306`. |
| C2.3 | MAJOR | VISUAL | no swift slip-through | OPEN | `AxisTravel.swift:318` unconditional; no re-crossing event, no `zv *= 0.45`. |
| C2.4 | MAJOR | VISUAL | the two passage gates (waypoints) are absent | OPEN | grep `0.34`/`0.68` in AxisTravel → 0 hits. |
| C2.5 | MINOR | VISUAL | cannot lean into a passage | OPEN | `AxisTravel.swift:170` guards drag while crossing; no boost. |
| C2.6 | MINOR | VISUAL | no passage afterglow / `dom()` | OPEN | `crossing` flips instantly; no `after` ramp. |
| C2.7 | MINOR | VISUAL | wheel / pinch inputs absent | OPEN | single DragGesture, height only. |
| C2.8 | MINOR | VISUAL | design-pixel normalisation of the drag missing | CLOSED | `InstrumentView.swift:204-205,322`. |
| C2.9 | none | none | frame-rate independence is a correct improvement | CLOSED | `AxisTravel.swift:191-192,211`. |
| C3.1 | none | none | count, placement, one-way law: MATCH | CLOSED | `AxisTravel.swift:40,50,258-261,272,297`. |
| C3.2 | none | none | stillness-gate accumulator: MATCH on numbers | NEEDS-JUDGMENT | Mechanism REPLACED by the `DP.dwell` law; divergence argued at `:216-235` but never entered in §10. Needs a ruling. |
| C3.3 | MAJOR | DATA | the gate's line is not "once, ever", wrong medium | OPEN | `InstrumentView.swift:589-593` shown every time; `gateSaid` → 0 hits. |
| C3.4 | MAJOR | DATA | the other once-ever line is missing entirely | OPEN | Only a comment at `LightCanon.swift:26`; no `sayOnce` trigger. |
