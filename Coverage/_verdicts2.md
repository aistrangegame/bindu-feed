COUNTS-2: 30 CLOSED · 51 OPEN · 4 NEEDS-JUDGMENT · 0 NOT-YET-EXAMINED

| ID | SEV | KIND | short title | VERDICT | evidence |
|---|---|---|---|---|---|
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
| C7.9 | BLOCKER | VISUAL | THIN: a blip, half the voice missing | OPEN | Continuity fixed, but `root = 136.1` + 1.5→2.0 ratio; design is 174 fixed + 261+f*87. The 174 partial is absent. |
| C7.10 | COSMETIC | VISUAL | UNGRIP | OPEN | peak 0.03 vs 0.024; attack 0.3 vs 0.45. |
| C7.11 | MAJOR | DATA | invented threshold tone on every boundary | OPEN | `InstrumentView.swift:289-291` every non-gate crossing strikes a bell. |
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
| D5.5 | BLOCKER | — | IV · The Chamber | OPEN | One horizontal strip + pan. No three-surface geography, no vault-on-breath, no bowing/hairlines/load/press-to-inhabit. |
| D5.6 | MAJOR | — | V · The Mirrors | OPEN | Pairs by flat index; four-universe structure discarded. Still a code invention. |
| D5.7 | MAJOR | — | VI · The Return | OPEN | Door renders whenever `dimensionN == 6`, unconditioned by settle/depth. Permanently visible, not earned. |
| D5.8 | BLOCKER | — | VII · The Dance | OPEN | Lissajous + plain tap. No three lanes, no held/sync/spin catch mechanic. |
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
