# 1 · ALL 254 AUDIT FINDINGS — verdict and evidence

Generated 2026-08-28 17:39. Every finding in `AUDIT.md`, one row, re-verified against **current** code — not against the audit's own line numbers, which have drifted heavily since the Universe and axis were rebuilt.

## Headline

**143 of 254 findings are OPEN — but that measures THE AUDIT, not the work.** The audit
never read `comps/`, a quarter of the mechanism sweep's scope. The headline number is
**83 absent of 485** (`Coverage/2`), which read everything. See `11-COMP-BLIND-SPOT.md`.

- **CLOSED** — 96
- **OPEN** — 143
- **NEEDS-JUDGMENT** — 15
- **NOT-YET-EXAMINED** — 0

> ### 🔴 THIS REGISTER DRIFTS, AND IT DRIFTED. Re-verify a row before working it.
>
> Stage G was about to work ~90 findings **in audit-ID order** out of this file. Re-reading
> the nine open BLOCKERs first, **four were already closed** — E3.1 (B4), E4.1 and G3.1 (B3
> plus the comp lane), and D5.8's chain — and their rows still carried the original evidence,
> including phrases like *"0 hits"* for symbols that now exist. One, E4.2, was still true and
> was fixed.
>
> This is `_mechverdicts1.md`'s decay in the register Stage G would be worked FROM, and it is
> the same shape as the stale Swift comments `check_status.py` now guards: **a verdict is a
> claim with a date, and nothing marks it stale.** The rule already recorded for the mech
> sweep applies here without change — *anything worked out of this file is re-judged against
> the tree first, never quoted forward.*
>
> Line numbers drift too: `resolve`'s row in `10-OWED.md` §7 named
> `InstrumentView.swift:290` as the one line that would change; `spineThreshold` is now at
> `:307`, and `:290` is `setStillness`. Corrected there.

### THE ORDER FOR THE REMAINING ROWS — BY CHURN, NOT BY ID

**Drift concentrates in rows worked NEAR, not rows left alone.** Four of nine BLOCKERs were
stale; the MAJOR re-reads so far have almost all CONFIRMED their rows instead. The difference
is that the BLOCKERs sat on surfaces Stages A–F rebuilt, and the MAJOR rows re-read so far
did not. So the useful order is not audit-ID and not severity: it is **how much the file a
row cites has actually changed on this branch.**

Measured by commits touching each cited file (`git log --name-only main...HEAD`):

| band | rows | expectation |
|---|---|---|
| `InstrumentView.swift` — **20 commits** | B0.5 B0.6 B7.1 B7.5 C3.3 C3.5 C3.6 C3.8 C4.5 C5.6 C5.7 C7.11 | **re-read first** — the surface was rebuilt underneath them |
| `SoundEngine.swift` · `RiteTones.swift` — 19 | C7.4 C7.6 C7.8 G3.3 | re-read second — Stages A–C and F reworked this |
| `PointWorldView.swift` — 16 | A4.3 D4.5 D5.11 | third |
| `UniverseView.swift` — 14 | B7.4 … | fourth |
| **cited file untouched — 0 commits** | **55 rows** | **expect genuinely open**; read them to WORK them, not to re-verify |

**The prediction this makes is falsifiable, which is the point of writing it down.** If the
20-commit rows turn out no more stale than the 0-commit rows, the drift-concentration model is
wrong and the order should go back to severity. So far it has held twice: the four stale
BLOCKERs all cited heavily-reworked files, and B0.5/B7.1/B7.2/C3.7 — re-read and CONFIRMED —
cite `uDwell`/`uSweep`/`dwell`/`streak`, which no stage touched.

### THE MAJOR-BAND SWEEP · 2026-08-29 — a real number, and what a sweep cannot do

Run before continuing the band, because four of nine BLOCKERs had been stale and the MAJOR
band is nine times larger and older.

**Mechanical, over all 84:**

| check | result |
|---|---|
| rows whose evidence is a **zero-hit claim** | 18 — **4 now false**, closed: `E3.8` `towardGold`, `E3.9` `sealedLine`, `E4.5` + `G3.2` `agedBed` |
| rows citing a **`File.swift:NN`** | 43 — **all resolve**; none points past end of file, so no gross drift |
| rows citing **no line at all** | 37 |
| rows where **every cited symbol now exists** | 12 — the re-read-first list |

**Plus `A1.5`, `A1.6` and `B3.6` closed by fixing them.** Open now: **BLOCKER 4 · MAJOR 79 ·
MINOR 43 · COSMETIC 4 = 130**, from 143.

**AND THE LIMIT, WHICH MATTERS MORE THAN THE NUMBER.** Symbol presence decides nothing, and
it is wrong in both directions:

- **Present but still absent in substance** — `B0.5`'s `uDwell` and `B7.1`'s `uSweep` exist
  as `.float(0)` and `.float2(0,0)`: hard-zeroed uniforms, which is exactly what those rows
  say. `B7.2`'s `dwell` exists in `Instrument/` and the row's claim is scoped to `Universe/`,
  where it is still nothing. `C3.7`'s `streak` matches a comment about *"fast gold streaks"*.
- **Absent but possibly closed** — a mechanism can be built under a different name, which is
  the whole reason `check_rendered` keys on strings rather than symbols.

So the 12 are a **reading order, not a verdict**, and the 65 are *likely* open rather than
known so. **A row is judged by reading it against the tree, and the sweep's job is to say
which rows to read first, not to answer for them.** The per-row check at work time stays the
second gate; this pass only makes the count and the order honest.

**NOT-YET-EXAMINED is zero** — every one of the 254 was checked in this pass. That was the number you asked for; the answer is that none is now unexamined, and 143 are open.

Open findings by severity:

- MAJOR — 86
- MINOR — 43
- BLOCKER — 8
- COSMETIC — 4
- none — 2

### Two things to know before reading the table

1. **Only 19 of the 254 IDs appear anywhere outside `AUDIT.md`** — not in a commit, a source comment, `OPEN-ITEMS.md`, or `CLAUDE.md`. The build worked from a differently-organised list, so 235 findings have no traceable link to any work. That is not the same as unfixed — 96 turn out to be closed — but nothing recorded it.
2. **Several OPEN rows are residuals of a mostly-fixed finding.** They were not softened to CLOSED, because in each case a named, checkable piece of the audited defect is still in the tree. The evidence column says which piece.

| ID | SEV | KIND | short title | VERDICT | evidence |
|---|---|---|---|---|---|
| A1.1 | MAJOR | DATA | authored line breaks flattened on ingestion | NEEDS-JUDGMENT | `MirrorView.swift:274-279` honours `\n` if present. Whether the 24 Live Mirror Card rows carry `\n` is a base fact. |
| A1.2 | MAJOR | DATA | cohort A is not Mirror content at all | NEEDS-JUDGMENT | Code never reads `Category`. Cohort membership is a base fact. |
| A1.3 | MAJOR | DATA | register back-filled uniformly, Koan under-represented | NEEDS-JUDGMENT | 12/12 split claimed in CLAUDE.md §8 but is a base fact. |
| A1.4 | MINOR | DATA | one design reflection paraphrased, not stored | NEEDS-JUDGMENT | Base fact; app carries no copy either way. |
| A1.5 | MAJOR | DATA | `Card Register` optional; nil silently renders as Vow | **CLOSED 2026-08-29** | A card with no register is filtered from the pool rather than guessed — §6's blank-`Status` lesson in a second discriminator field. **Both** readers filter: the day-pick and the Bindu Draw. Original evidence: | `Models.swift:333` optional; `MirrorView.swift:265-266` nil falls to "A VOW · ARRIVED". |
| A1.6 | MAJOR | DATA | day-hash and draw index a mutable, growing pool | **CLOSED 2026-08-29** | `MirrorDay.pick` scores every card by `hash(day·cardID)` and takes the highest — rendezvous, so the count appears nowhere and adding or archiving a card changes only the days that card wins. The draw is second place by the same scoring and cannot collide with the base. Original:  `MirrorView.swift:181,208-209` modulus is still the live record count. |
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
| B0.5 | MAJOR | VISUAL | stillness at the sky has no reward, only punishment | **PARTIAL 2026-08-29** | **The light-bend is live.** `mSky` had computed `dwell * pow(cos(13·a2),7) * smoothstep(1.30,0.04,|q|) * 0.11` all along against a hard `.float(0)` — the shader's half was built and starved. `AxisTravel.dwell` is published and fed, and the gate's fill/drain/spend is now MEASURED through the injected clock. **STILL OPEN:** the authored line *"This is what you look like from outside."* at `dwell > 0.62`. Original:  `InstrumentView.swift:536` `uDwell` hard-zeroed; the light-bend and its line are absent. |
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
| B3.6 | MAJOR | DATA | stars collide when a room holds more than `n` stories | **CLOSED 2026-08-29** | Extra stories are strung on a second lap of the same armature (`spread = 1 + lap*0.18`) instead of wrapping onto taken slots. The armature's shape is untouched inside the first lap. Original evidence: | `UniverseView.swift:633` `i % rm.n` — story 8 lands on slot 0. |
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
| C3.5 | MAJOR | VISUAL | membrane's body not drawn | OPEN | `InstrumentView.swift:567-571` one stroke ellipse. No wobble, beads, radial fill or push term. |
| C3.6 | MINOR | VISUAL | gate thins, does not tighten | OPEN | `InstrumentView.swift:583-587` rim correct but plain stroke; no wobble/beads/gradient. |
| C3.7 | MAJOR | VISUAL | the drift (speed on the axis) missing | OPEN | grep `streak` → 0; `travel.speed` used once (`:259`). No streaks, no vignette. |
| C3.8 | MINOR | VISUAL | travel blur on the field missing | OPEN | `InstrumentView.swift:520-557` no `.blur`; speed never read there. |
| C4.1 | none | none | shader shell loop identical | CLOSED | `InstrumentField.metal:195-203` all terms match. |
| C4.2 | MAJOR | DATA | the Veil's `uBack[9]` dropped | OPEN | grep `uBack` repo-wide → 0 hits. `mVeil(q,t,hand)` takes `hand` only. |
| C4.3 | MAJOR | DATA | sky's thirteen rooms frozen constants | CLOSED | `FeedStore.swift:828-840` live via `UniWeather.sky`; `InstrumentField.metal:56-59` reads `rm[]`. |
| C4.4 | MAJOR | VISUAL | `setRoom()`: Universe never wears the room's colour | OPEN | `InstrumentField.metal:15-17` HUES[2..4] three identical hardcoded triples; kernel takes no room-hue uniform. |
| C4.5 | MAJOR | VISUAL | six of eight driven uniforms pinned to 0 | OPEN | `InstrumentView.swift:534-544` uSync/uSpin/uReveal/uDwell/uSweep/uHand all 0, "Phase 2". |
| C4.6 | COSMETIC | VISUAL | grain scale hashes points not pixels | OPEN | `InstrumentField.metal:213` `pos` never scaled by device density. |
| C4.7 | MAJOR | VISUAL | presence-weighted CPU layer absent | OPEN | grep `drawLightSide` etc → 0 hits. `shells` is one tension circle. |
| C5.1 | COSMETIC | DATA | `#rail` largely right | OPEN | pitch 21 vs 22 (`:427`); no `kept` glow; fade binary at `:465`. |
| C5.2 | BLOCKER | DATA | `#where` is a different object | CLOSED | `InstrumentView.swift:375-415` full object: top line, name Lora 23, sub, 1.1s animation. |
| C5.3 | MAJOR | DATA | "THE UNIVERSE" is invented | CLOSED | Only comment hits; name comes from `AxisModel.swift:81-84`. |
| C5.4 | MAJOR | VISUAL | `#trav` — "the between, named" — missing | OPEN | grep `paintTravel`/`#trav`/`fromName` → 0 hits. |
| C5.5 | MAJOR | DATA | invented bottom instruction line | CLOSED | Both invented strings → 0 hits; slot is now the stillnessGate. |
| C5.6 | MAJOR | DATA | `#pname` hide conditions | OPEN | `InstrumentView.swift:501-502` `inUniverse` still suppresses the four Universe names; opacity 1.0 not `0.9*(1-hush)*(1-immA)`. |
| C5.7 | MAJOR | VISUAL | particle radius wrong at the base | OPEN | `InstrumentView.swift:605` `5.0 + 4.0*breath` vs design `3.4 + br*0.9`. |
| C5.8 | MAJOR | VISUAL | particle travels to the crown with Z | OPEN | `:601,604` keyed on depth, not an immersion value. |
| C5.9 | MAJOR | VISUAL | halo and white-hot core missing | OPEN | `:612-619` one gradient + shadow. No `max(r*8,26)` halo, no four stops, no solid core disc. |
| C5.10 | MINOR | VISUAL | `centring` chrome blackout | OPEN | grep `centring` → 0 hits; rail and `‹` still draw at full fill. |
| C5.11 | MINOR | VISUAL | split threshold | OPEN | `nearest()` rounds, so the reveal fires from z ≥ 8.5 not > 9.5. |
| C5.12 | MINOR | VISUAL | CARRY motes not implemented | CLOSED | `InstrumentView.swift:626-644` golden angle, hue, core; halo widens at `:619`. |
| C6.1 | none | none | period + single-anchor law: MATCH | CLOSED | `Breath.swift:20,67-71`; idempotent, launch-anchored. |
| C6.2 | MINOR | VISUAL | curve/phase anchor differ by a quarter cycle | NEEDS-JUDGMENT | `Breath.swift:85` `(1-cos)/2` vs design `(sin+1)/2`. Documented as a Pass-0 ruling at `:22-40`. Needs a precedence ruling. |
| C7.1 | none | none | `B.hzAt`: MATCH | CLOSED | `InstrumentView.swift:48-56`. |
| C7.2 | MAJOR | VISUAL | GLIDE | OPEN | `AxisTones.swift:122-140` two sines; no lowpass, no noise bed; smoothing 35/23ms vs 70/110. |
| C7.3 | MAJOR | DATA | TRAIL trails the wrong register | OPEN | `AxisTravel.swift:325-326` passes the register just arrived at. |
| C7.4 | MAJOR | VISUAL | STRAIN is dead code | OPEN | `SoundEngine.swift:760-765` — 0 call sites. |
| C7.5 | MAJOR | VISUAL | GIVE | OPEN | peak 0.03 vs 0.055; no inner threshold; fires at passage start with the departure register. |
| C7.6 | MAJOR | VISUAL | RUSH is a one-shot | OPEN | `SoundEngine.swift:771-776` single playAxis; nothing drives it from `passageT`. |
| C7.7 | MAJOR | DATA | GATE: right synth, wrong trigger | OPEN | Bound to the register name, never to `PS.t = 0.34/0.68`. |
| C7.8 | MINOR | DATA | CARRY is dead code | OPEN | `SoundEngine.swift:781-790` flat peak; `axisCarry` 0 call sites. |
| C7.9 | BLOCKER | VISUAL | THIN: a blip, half the voice missing | **CLOSED 2026-08-29** | `StillnessVoice` now sounds `174` fixed with a twin at `261 + f·87` — The Point and The Archive, the Archive climbing to 174's octave. The app had `136.1` with a `1.5→2.0` ratio: a reasonable gesture off the wrong anchor, with 174 absent entirely. **A test of mine had pinned `136.1` as canon** (`theRootIs1361`), written from the code rather than the design — corrected, and the rule recorded in §10. Original:  Continuity fixed, but `root = 136.1` + 1.5→2.0 ratio; design is 174 fixed + 261+f*87. The 174 partial is absent. |
| C7.10 | COSMETIC | VISUAL | UNGRIP | OPEN | peak 0.03 vs 0.024; attack 0.3 vs 0.45. |
| C7.11 | MAJOR | DATA | invented threshold tone on every boundary | **CLOSED 2026-08-29** | The threshold moved from `onCross` to a new `onLand`, which fires only when a passage completes — `The Instrument v3.html:5452`, `if(ev==='land'){ … B.give(…) }`. A drift-past now leaves a trail and strikes nothing. **This row was open while `Coverage/10-OWED.md` §7 claimed the opposite**, having misread `:5354` (inside `letGo()`) as a crossing handler; corrected there. **Now MEASURED, not OWED:** `AxisTravel` takes an injected clock (`advance(dt:)`), so `AxisTravelClockTests.driftingPastDoesNotLand` drives three simulated seconds with no passage and asserts `onLand` never fires. Original:  `InstrumentView.swift:289-291` every non-gate crossing strikes a bell. |
| D2.1 | BLOCKER | DATA | the gate's five DEALS absent | CLOSED | `PointDeals.swift:13-22` verbatim; rendered by `PointGateView`. |
| D2.2 | MAJOR | DATA | SM status-word table dropped | OPEN | `PointStatus.word` exists but its only call site is the descent prompt; `StarMark` renders no status word. |
| D2.3 | MAJOR | DATA | STL footer + "THE LEARNING FIELD" dropped | CLOSED | `PointReadings.swift:144-152,197`. |
| D2.4 | MAJOR | DATA | star-reading section labels paraphrased | CLOSED | `PointReadings.swift:124-129` all four verbatim. |
| D2.5 | MAJOR | DATA | register `sub` strings dropped | CLOSED | `AxisModel.swift:80-94` all eight present. |
| D2.6 | MAJOR | DATA | reveal narration bugs | OPEN | `PointJourney.swift:56` narrates dimensions not universes; `universes` array written and never read. Rope line absent. |
| D2.7 | MAJOR | DATA | eight per-world reveal verbs not implemented | NEEDS-JUDGMENT | Recorded in §10 as a kept DIVERGENCE. Needs a precedence ruling. |
| D2.8 | MINOR | DATA | `GLOWS` table dropped | OPEN | grep → 0 hits; atmosphere derived ad-hoc. |
| D2.9 | MINOR | DATA | "gate to center" spelled both ways | OPEN | `PointJourney.swift:70` "centre" vs `PointContent.swift:361` "center". |
| D2.10 | none | none | three verbatim closing lines | CLOSED | `PointRevealView.swift:23-27`. |
| D3.2 | MAJOR | VISUAL | universe node placement | OPEN | Placement fixed via `anchors()`+`toScreen()`, but glyph is a 10pt dot not a 38px ring with seeded dots; label Lora 11 not mono 7.5; no `260+k*220`ms stagger. |
| D4.1 | BLOCKER | VISUAL | staged descent choreography missing | CLOSED | `PointWorldView.swift:352-418` full overlay, cadence, tap-advance, `‹ ascend`, shaft. |
| D4.2 | MAJOR | VISUAL | star sheet is a ScrollView, not a sheet | NEEDS-JUDGMENT | Generic sheet deliberately superseded by seven bespoke readings (E3 ruling). Whether the sheet's dress still applies is a design ruling. |
| D4.3 | MAJOR | DATA | descent prompt drops three things | CLOSED | `PointWorldView.swift:465-476` dimension name, status, seeded branch all restored. |
| D4.4 | MAJOR | DATA | descend button label rewritten | CLOSED | `PointWorldView.swift:330` `descend onto this star`; invented string → 0 hits. |
| D4.5 | COSMETIC | DATA | descent cache keyed on the title | OPEN | `PointWorldView.swift:292` keyed on `star.t` not `star.key`. |
| D4.6 | MAJOR | VISUAL | no write-back / take-back | OPEN | grep `takeBack` → 0; `revealed` reset on every close; state fresh per star. |
| D5.1 | BLOCKER | VISUAL | reading decoupled from the world | CLOSED | Seven distinct readings dispatched; world drawn behind and receded. |
| D5.2 | MAJOR | — | I · The Point | OPEN | Positions still hash-based; authored three-region figure absent. |
| D5.3 | MAJOR | — | II · The Turn | OPEN | Four concentric rings + inward spiral; no nine outward rays, no per-universe twist/spread, no spanda. |
| D5.4 | MAJOR | — | III · The Veil | OPEN | One global `part`; uniform blur; hash positions. No cover depths, no per-star occlusion, no permanent thinning. |
| D5.5 | BLOCKER | — | IV · The Chamber | **PARTIAL 2026-08-29** | **The ENTRY is fixed:** the niche is pressed, not tapped — it opens when the press reaches `PointChamber.gates[0]`, the moment the inscription is first struck, with `PressClaim` taken and released by all three exits. Same shape as D5.8's: the mechanism (`pressRate`/`strike`/`gates`) was built in Stage E and used by the READING while the world opened on a tap. **STILL OPEN:** the three-surface geography (left wall The Vessel · floor The Rules of Play · back wall The Others), the vault descending on the breath, and the bowing/hairlines. Original:  One horizontal strip + pan. No three-surface geography, no vault-on-breath, no bowing/hairlines/load/press-to-inhabit. |
| D5.6 | MAJOR | — | V · The Mirrors | OPEN | Pairs by flat index; four-universe structure discarded. Still a code invention. |
| D5.7 | MAJOR | — | VI · The Return | OPEN | Door renders whenever `dimensionN == 6`, unconditioned by settle/depth. Permanently visible, not earned. |
| D5.8 | BLOCKER | — | VII · The Dance | **CLOSED 2026-08-29** | **Three lanes built** (`DanceLanes`, `The Instrument v3.html:2176-2185`) and **the tap replaced by the offered hand** — the star that opens is the one that took it (`world-seven.js:28-31`), so the world no longer opens by picking. The chain, sync (`lock`) and dissolve landed in Stage E. **Completed:** `DanceCatch` — sections land as `sync` crosses `[0.34, 0.55, 0.74, 0.90]`, one per frame at most; the frame spins with its lane; losing the pace before the fourth **scatters** and releases the star, and losing it after takes nothing. Original:  Lissajous + plain tap. No three lanes, no held/sync/spin catch mechanic. |
| D5.9 | MAJOR | VISUAL | star placement arbitrary where design is semantic | OPEN | Shared FNV-1a hash / index-linear; nothing encodes universe membership. |
| D5.10 | none | none | ●◐○ star mark faithful | CLOSED | `PointWorlds.swift:76-83`. |
| D5.11 | MAJOR | VISUAL | "I Love You" moved to a headline | OPEN | `PointWorldView.swift:207-212` Lora italic 21 centred with shadow; not 12px at the particle. |
| D5.12 | MAJOR | — | ten enclosures vs seven worlds | NEEDS-JUDGMENT | Aperture still an off-axis pushed route. Design ruling required. |
| D6.1 | MAJOR | DATA | six authored strings replaced by five invented | CLOSED | `ApertureView.swift:122,124,127,173` all authored. |
| D6.2 | MAJOR | DATA | the response shape collapsed | CLOSED | `ApertureView.swift:336-339` keyed JSON; four slots rendered. |
| D6.3 | MAJOR | DATA | Arch register swapped out of the prompt | CLOSED | `ApertureView.swift:334-336` verbatim. |
| D6.4 | MAJOR | VISUAL | the eye is gone | CLOSED | `ApertureView.swift:200-230` triangles, circle, dot, rotation. |
| D6.5 | MAJOR | VISUAL | effects on success | OPEN | `flare()` now fires, but the five-partial `Snd.shimmer()` is still absent. |
| D6.6 | MINOR | DATA | non-repetition guards the wrong axis | CLOSED | Both `drawn` and `seen` guards exist and feed the prompt. |
| D6.7 | MAJOR | VISUAL | API-key gate makes three surfaces dead | CLOSED | `ApertureView.swift:284-319` standard path fills every slot locally; key offered not demanded. |
| D7.1 | none | none | the ladder is correct | CLOSED | `VoiceCharacter.swift:71`, `PointWorldView.swift:30`. |
| D7.2 | BLOCKER | DATA | BEATS binaural narrowing absent | CLOSED | `VoiceCharacter.swift:72` + `SoundEngine.swift:243-247` per-enclosure beat. |
| D7.3 | MAJOR | VISUAL | the stone room | CLOSED | `SoundEngine.swift:357-371` reverb, `.cathedral` 42 for climbing. |
| D7.4 | MAJOR | VISUAL | the sounded step between enclosures | OPEN | Crossfade only; no `step(from,to)` glissando. |
| D7.5 | MAJOR | VISUAL | blip / glide / shimmer / om absent | OPEN | Sustained voice not a 0.7s blip; no glide on descend/ascend; no shimmer; OM is a single fundamental not the triad. |
| D7.6 | none | none | the breath clock is correct and faithful | CLOSED | `Breath.swift:20,67-71,85,62`. |
| E1.1 | BLOCKER | DATA | six presences and choosing don't exist | CLOSED | `LightCanon.swift:185-201` place/hit; `LightView.swift:206-262` choosing stage; date-hash gone. |
| E1.2 | BLOCKER | VISUAL | text column has no lift or mask | CLOSED | `LightView.swift:306-310,375-384`. |
| E1.3 | MAJOR | VISUAL | the beat is one unit in canon, six presses in code | OPEN | `LightView.swift:62,411-412` carve runs per Declaration line; no single held press. |
| E1.4 | MAJOR | DATA | canonical beat cue declared, never used | OPEN | `LightCanon.swift:34 beatCue` — 0 call sites; `LightView.swift:365` renders invented cues. |
| E1.5 | MAJOR | VISUAL | `release`'s ungrip law wired to the wrong axis | OPEN | `LightView.swift:471-475,74` saturates after anchor 3 of 5; advance never blocked. |
| E1.6 | MAJOR | VISUAL | non-`release` arrival is not time-driven | OPEN | `LightView.swift:75-77` derived from reading progress; no dt accumulator, no decay under a hand. |
| E1.7 | MAJOR | VISUAL | exhale delivery fires on the inhale | OPEN | `LightView.swift:489-490` `breath.value > 0.9` on a `(1-cos)/2` curve = top of the INHALE. Only one anchor queued (design allows two). |
| E1.8 | MAJOR | VISUAL | landing latency 10x short | OPEN | `LightView.swift:532` 1.6s vs design `breathMs*1.6` = 16 000ms. |
| E1.9 | MAJOR | VISUAL | force never absorbed visibly | OPEN | `LightNave.swift:87` no `touching` term; `touching` never passed to the material. |
| E1.10 | MAJOR | VISUAL | two-material split confines the nave to 1 of 6 | OPEN | 5 of 6 scenes are `.dawn`; `LightNave` mounted only under `.nave`. |
| E1.11 | MAJOR | DATA | worn rings synthesised not earned | CLOSED | `LightNave.swift:33,182-194` one ring per exhale, 7s fall, cap 14. |
| E1.12 | none | — | nave geometry exact | CLOSED | `LightNave.swift:18-21` verbatim. |
| E1.13 | MINOR | VISUAL | smaller Light deltas | OPEN | `LightNave.swift:42` `calm` un-eased, camera collapses; Bindu on `ctx` not `p`, fixed radii. |
| E1.14 | MINOR | DATA | `touchOnce` was extended | CLOSED | `LightCanon.swift:32` `touch once`. |
| E1.15 | MAJOR | DATA | `vector`/`kind`/`arrival` missing from model | OPEN | `LightCanon.swift:12-22` struct lacks all three; grep → 0 hits. |
| E1.16 | MINOR | DATA | `given` world-withdrawal counter unmodelled | OPEN | 0 hits in `Light/` or `LightView.swift`. |
| E1.17 | MINOR | VISUAL | Light typography | OPEN | `LightView.swift:319,325,338-340,357,359-361` sizes/weights/inks differ throughout. |
| E1.18 | MINOR | VISUAL | every mono label renders lowercase | OPEN | One `uppercased()` in the whole ceremony set (`ReturnView.swift:251`). No case transform on mono chrome. |
| E1.19 | none | — | lineage note | CLOSED | `LightCanon.swift:162` present; S-L01 BEATS correctly absent. |
| E2.1 | none | — | rite-scenes.js ten geometries near-exact | CLOSED | `GatheringScene.swift` 783 lines; FLOWER/GOLD/phyllotaxis/karishma intact. |
| E2.2 | none | — | the budget is a faithful port | CLOSED | `RiteBudget.swift:28-43` all constants + costOf. |
| E2.3 | MAJOR | VISUAL | invented haptic heartbeat every 1.7s | OPEN | `RiteGatheringView.swift:244-252` Timer + UIImpactFeedbackGenerator. |
| E2.4 | MAJOR | VISUAL | the Sealing stacks instead of replaces | OPEN | `RiteView.swift:284,300,307` all three accumulate in one VStack. |
| E2.5 | MAJOR | DATA | Recognition's prompt and label swapped | OPEN | `RiteRecognitionView.swift:35-45` label permanent, prompt only in `.prompt`, wrong font/ink. |
| E2.6 | none | — | smaller Rite deltas | OPEN | `RiteRecognitionView.swift:57-59` invented affordance; prompt 20pt inkPrimary. |
| E3.1 | BLOCKER | DATA | strata draw ZERO rings in default case | **CLOSED 2026-08-29** | `ReturnStrata.ringIndices` is `stride(from: max(0, returns), through: 1, by: -1)`, so `rings == 1` yields `[1]`. Closed as B4; this row read OPEN for the whole stage after. |
| E3.2 | BLOCKER | DATA | Rings movement has no rings list | **CLOSED 2026-08-29** | The rings list is built and rendered: each prior return with `when`, the words he left there, and *"N voices answered"*. **Nothing was missing from the base** — his words are the ring's own `Return Answer` with `Archetype = Ash` (§10) and the Pass 6 write is proven, so this was a READ that was never built. `ReturnStoryData.ringRows` ← `FeedStore.ringRows`. Original:  `ReturnView.swift:367-377` no rows/when/fragments/seed line; model has no `returns:[{when,frag,words}]`. |
| E3.3 | MAJOR | DATA | the Record's corpus does not exist | OPEN | `ReturnView.swift:314` uses `RiteVoices.all`; the Return's ten condensed GATHERING lines absent. |
| E3.4 | MAJOR | DATA | age computed from ring count not days | CLOSED | `ReturnCanon.swift:173-198` `pow(days/1095, 0.55)`; per-ring ages passed. |
| E3.5 | MAJOR | VISUAL | the fall is a different ceremony's animation | OPEN | `ReturnView.swift:161-273` still the uni-fall port with the Universe captions; `whispers` → 0 hits. |
| E3.6 | MAJOR | VISUAL | two incompatible ring representations at once | OPEN | No active/_in/_true/grown/pass terms; `ReturnRings` widget drawn over `ReturnStrata`. |
| E3.7 | MAJOR | VISUAL | craquelure, whispers, pulses, grain absent | OPEN | Craquelure ported (`ReturnStrata.swift:102-113`); whispers/pulses/grain → 0 hits. 3 of 4 still absent. |
| E3.8 | MAJOR | VISUAL | `towardGold` is not applied | **CLOSED 2026-08-29** | `towardGold` is built at `ReturnPatina.swift:8,31` (F3). Row's evidence was a zero-hit grep. Original:  grep `towardGold`/`foxed` → 0 hits. |
| E3.9 | MAJOR | DATA | sealed line not debossed, not modelled | **CLOSED 2026-08-29** | The sealed line's deboss is built at `ReturnPatina.swift:54` (F3). Original:  grep `sealedLine` → 0 hits; every paragraph renders identically. |
| E3.10 | MAJOR | DATA | Field Settled cumulative not one-at-a-time | OPEN | `ReturnView.swift:344` accumulates; no avatar/role/exhale gate; `useExhale` → 0 hits. |
| E3.11 | MAJOR | VISUAL | the Sealing never shows him what he kept | **CLOSED 2026-08-29** | The Sealing renders `replyText` back, debossed — cut into the material rather than laid on it, which is what this surface does to a sealed line (F3). `replyText` had been read only to enable the button and to send. Same fault as E3.2 at the other end of the act: **a return you can complete and cannot re-read.** Original:  `ReturnView.swift:437-446` `replyText` never rendered back. |
| E3.12 | none | — | smaller Return deltas | OPEN | `camY` never overridden; motes fixed 24; ring N=120. |
| E3.13 | none | — | what the Return gets right | CLOSED | Stage order, wording, forward detector intact. |
| E4.1 | BLOCKER | DATA | Light functionally silent, 7 of 8 events missing | **CLOSED 2026-08-29** | All eight built and wired. `darkReturns` closed as B3; `lightOff`/`closeTheRoom(6)` closed in the comp lane and both now fire from `backOut`. |
| E4.2 | BLOCKER | DATA | the stillness gate makes no sound at all | **CLOSED 2026-08-29** | `LightView`'s gate timer now calls `setStillness(fill: still, touching:)` every tick and outside the idle branch, so the drone follows the fill in both directions. Verified OPEN by re-reading before fixing — the one BLOCKER of the five whose row was still true. |
| E4.3 | MAJOR | DATA | Rite Hz table diverges; timbres collapse | CLOSED | `RiteGatheringView.swift:204-205` + `RoomVoices.swift:35-42` exact. Residual: bed does not step back to 0.018. |
| E4.4 | none | — | the Rite's thresholds are exact | CLOSED | `RiteView.swift:106,110,114,334`. |
| E4.5 | MAJOR | DATA | Return crossings exact; two signature voices missing | **CLOSED 2026-08-29** | `agedBed` is built and called at `ReturnView.swift:174` (F2). Original:  `agedBed` → 0 hits; ring is an immediate bowl, no growth, no 3400ms delay. |
| E4.6 | MINOR | DATA | seven canon travel calls never reach these surfaces | OPEN | `axisCarry` 0 call sites; `carryTone` only in the Point. |
| E4.7 | MINOR | DATA | `ungrip` called where canon does not sanction it | OPEN | `LightView.swift:522` on every carve-lock. |
| F0.1 | MAJOR | VISUAL | `em`->`pt` tracking not converted, systemically | CLOSED | `Theme.swift:127` helper + 45 call sites; all three exemplars fixed. Residual raw sites: `SettingsView.swift:234,264`, `GameView.swift:186`. |
| F0.2 | none | — | 8-digit hex alphas read as decimals | CLOSED | Six converted sites cited. |
| F0.3 | MINOR | — | one breath clock where the design has many | NEEDS-JUDGMENT | Deliberate; the audit itself asks for a ruling. |
| F2.1 | MAJOR | VISUAL | filter bar's inactive state inverted | OPEN | `CommunityFilterBar.swift:64,72,76,86`. |
| F2.2 | MINOR | VISUAL | the filter-change dissolve is missing | OPEN | `RootView.swift:39-41` no opacity gate, no 280ms wait. |
| F2.3 | MINOR | VISUAL | two invented controls | OPEN | `AllChip` (`CommunityFilterBar.swift:10-49`), `FeedSortToggle` (`RootView.swift:62`). |
| F2.4 | MINOR | VISUAL | StoryCard footer ink tiers and glyph font | OPEN | `StoryCard.swift:70-95`. |
| F2.5 | MINOR | VISUAL | avatar-stack overlap 1.7x the design | OPEN | `VoiceAvatar.swift:34-56` overlap 0.55, invented +n chip. |
| F2.6 | MINOR | VISUAL | live pulse: different trigger, different render | OPEN | `StoryCard.swift:108-149` 7-day window, border stroke, no lead-in, no glow. |
| F2.7 | MINOR | DATA | invented write action on the feed card | OPEN | `StoryCard.swift:71,119-136` handleResonate writes to the base. |
| F2.8 | none | — | matches | CLOSED | `StoryCard.swift:19-64`. |
| F3.1 | MAJOR | VISUAL | portal cards force-height'd ~37% taller | OPEN | `RoomPortalCard.swift:18,40` fixed 150/160 with Spacers. |
| F3.2 | MAJOR | VISUAL | thirteenth room has the wrong footprint | OPEN | `RoomSelectionView.swift:31-35` full content width, no inner centring. |
| F3.3 | MINOR | VISUAL | field-turns divider lost its structure | OPEN | Type corrected; still one full-width hairline above and a left-aligned label. |
| F3.4 | none | — | matches | CLOSED | `RoomStyle.swift:24-36` thirteen glyph scales; strapline verbatim. |
| F4.1 | MAJOR | VISUAL | nav bar wrong controls, wrong places, lost escape hatch | OPEN | `GameView.swift:114-136,466-467,122-128` no `· all rooms`, no tap. |
| F4.2 | MAJOR | VISUAL | stats bar loses room colour and uppercase | OPEN | `GameView.swift:230-236` inkPrimary, no uppercase; hairline below. |
| F4.3 | none | — | matches, exemplary | CLOSED | Thirteen nameStyles + heroGlyphs; 39 authored stat pairs. |
| F5.1 | MINOR | VISUAL | nav title missing entirely | OPEN | grep `"A STRANGE FEED"` → 0 hits. |
| F5.2 | MINOR | VISUAL | reply indent less than half the design's | OPEN | `ReplyRow.swift:23,26` 20pt vs 42. |
| F5.3 | none | — | matches, essentially exact | CLOSED | `StoryDetailView.swift:213-219`. |
| F7.1 | MINOR | VISUAL | per-presence border alphas flattened | CLOSED | `PlayersView.swift:178-185,219`. |
| F7.2 | MINOR | VISUAL | ten authored glow radii all rewritten | OPEN | `PlayersView.swift:281-289` 18/14/8/7/10 vs design 28/22/11/9 and seven others. |
| F7.3 | MINOR | VISUAL | role tracking 2x authored | CLOSED | `PlayersView.swift:202-203`. |
| F7.4 | MINOR | VISUAL | arrival sequence collapses after the lenses | OPEN | rootGrid, sectionDivider and the Ash card carry no reveal modifier. |
| F7.5 | none | — | matches | CLOSED | `GlyphAnimation.swift:27-40`; circle sizes 64/52. |
| F8.1 | MAJOR | VISUAL | identity mark is a faint ring, not a lit sphere | OPEN | `AshVoiceView.swift:107-121` no radial highlight, no opaque fill, terra-on-terra glyph. |
| F8.2 | MAJOR | VISUAL | entry card wrong ground + invented spine | OPEN | `AshVoiceView.swift:302-313`. |
| F8.3 | MAJOR | VISUAL | entry order inverted, thread context gutted | OPEN | `AshVoiceView.swift:262-298` reply line after the body, no parent line, no spine. |
| F8.4 | MINOR | DATA | stats lose their terra and one label's wording | OPEN | `AshVoiceView.swift:140-160`. |
| F8.5 | none | — | matches | CLOSED | `AshVoiceView.swift:67,82`. |
| F9.1 | MINOR | VISUAL | the hold ring is 29% too large | OPEN | `AshComposeView.swift:213-221` 80pt vs design 62. |
| F10.1 | MINOR | DATA | preview shows mood name not quality phrase | OPEN | `SettingsView.swift:348-351,118-121`; `Mood.quality` never read. |
| F10.2 | MINOR | DATA | Save control is the wrong element, loses a state | OPEN | `SettingsView.swift:45-52` no third branch. |
| F10.3 | MINOR | DATA | two fallback/placeholder strings differ | OPEN | `SettingsView.swift:114,134`; no maxLength. |
| F10.4 | MINOR | DATA | default arrival identity is inverted | NEEDS-JUDGMENT | Deliberate per CLAUDE.md §7; both comps disagree. Needs a source ruling. |
| F10.5 | none | — | matches | CLOSED | `SettingsView.swift:387,397-404,41-43`. |
| F11.1 | MAJOR | VISUAL | the turn's type is undersized and monochrome | OPEN | `TurnOverlay.swift:68,78-79,90`. |
| F11.2 | MINOR | DATA | two strings render lowercase where design uppercases | OPEN | `TurnOverlay.swift:93`, `DoorView.swift:131`. |
| F11.3 | none | — | matches, a strong port | CLOSED | `TurnOverlay.swift:34-43,63-64,87`. |
| G1.1 | MAJOR | DATA | bed is root+fifth in design, binaural pair in code | CLOSED | `BreathVoice.swift:63-66,122-160` field bed is root+fifth both ears; binaural confined to climbing. |
| G1.2 | MAJOR | VISUAL | no room: both convolution layers absent | CLOSED | `SoundEngine.swift:358-361,371,578-586`. |
| G1.3 | MINOR | VISUAL | `CEIL` and the master ramp | OPEN | grep `CEIL` → 0 hits; no master ceiling; per-voice peaks absolute. |
| G3.1 | BLOCKER | DATA | Light's five-movement sound architecture absent | **CLOSED 2026-08-29** | The removal half is built: `lightOff`/`closeTheRoom` fade the room tone from a retained voice, `darkReturns` restores the bed. |
| G3.2 | MAJOR | DATA | the Return's two signature voices absent | **CLOSED 2026-08-29** | `agedBed` is built and called at `ReturnView.swift:174` (F2). Original:  `agedBed` → 0 hits; ring strikes immediately. |
| G3.3 | MAJOR | VISUAL | `bowl` 4x too loud with the wrong spectrum | **CLOSED 2026-08-29** | `BowlVoicing.peak` is `0.075` — the ceiling itself — and `partials` are `[1, 2.004, 2.98, 4.02]`; the only surviving `2.756` is a test asserting its absence. Closed as B1 at the start of this branch. **Found by `check_audit_ids`'s agreement check on its first run**: three places cited `AUDIT G3.3` as the reason the bowl was fixed while this row still read OPEN. Original:  `SoundEngine.swift:646` peak 0.32 vs 0.075; `RiteTones.swift:119` partials `[1,2.756,5.404]` vs `[1,2.004,2.98,4.02]`; no bed duck. |
