COUNTS-3: 24 CLOSED · 58 OPEN · 2 NEEDS-JUDGMENT · 0 NOT-YET-EXAMINED

| ID | SEV | KIND | short title | VERDICT | evidence |
|---|---|---|---|---|---|
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
| E3.1 | BLOCKER | DATA | strata draw ZERO rings in default case | OPEN | `ReturnStrata.swift:65,81` stride still `n-1 … 1`; at `rings == 1` the stride is empty. `ringAges` last element provably never read. |
| E3.2 | BLOCKER | DATA | Rings movement has no rings list | OPEN | `ReturnView.swift:367-377` no rows/when/fragments/seed line; model has no `returns:[{when,frag,words}]`. |
| E3.3 | MAJOR | DATA | the Record's corpus does not exist | OPEN | `ReturnView.swift:314` uses `RiteVoices.all`; the Return's ten condensed GATHERING lines absent. |
| E3.4 | MAJOR | DATA | age computed from ring count not days | CLOSED | `ReturnCanon.swift:173-198` `pow(days/1095, 0.55)`; per-ring ages passed. |
| E3.5 | MAJOR | VISUAL | the fall is a different ceremony's animation | OPEN | `ReturnView.swift:161-273` still the uni-fall port with the Universe captions; `whispers` → 0 hits. |
| E3.6 | MAJOR | VISUAL | two incompatible ring representations at once | OPEN | No active/_in/_true/grown/pass terms; `ReturnRings` widget drawn over `ReturnStrata`. |
| E3.7 | MAJOR | VISUAL | craquelure, whispers, pulses, grain absent | OPEN | Craquelure ported (`ReturnStrata.swift:102-113`); whispers/pulses/grain → 0 hits. 3 of 4 still absent. |
| E3.8 | MAJOR | VISUAL | `towardGold` is not applied | OPEN | grep `towardGold`/`foxed` → 0 hits. |
| E3.9 | MAJOR | DATA | sealed line not debossed, not modelled | OPEN | grep `sealedLine` → 0 hits; every paragraph renders identically. |
| E3.10 | MAJOR | DATA | Field Settled cumulative not one-at-a-time | OPEN | `ReturnView.swift:344` accumulates; no avatar/role/exhale gate; `useExhale` → 0 hits. |
| E3.11 | MAJOR | VISUAL | the Sealing never shows him what he kept | OPEN | `ReturnView.swift:437-446` `replyText` never rendered back. |
| E3.12 | none | — | smaller Return deltas | OPEN | `camY` never overridden; motes fixed 24; ring N=120. |
| E3.13 | none | — | what the Return gets right | CLOSED | Stage order, wording, forward detector intact. |
| E4.1 | BLOCKER | DATA | Light functionally silent, 7 of 8 events missing | OPEN | 6 of 8 now built and wired. Still missing `closeTheRoom`/`darkReturns` (0 hits); `backOut` fires no sound. |
| E4.2 | BLOCKER | DATA | the stillness gate makes no sound at all | OPEN | `setStillness` has ONE call site, in InstrumentView. `LightView` never calls it — the 4600ms gate is silent. |
| E4.3 | MAJOR | DATA | Rite Hz table diverges; timbres collapse | CLOSED | `RiteGatheringView.swift:204-205` + `RoomVoices.swift:35-42` exact. Residual: bed does not step back to 0.018. |
| E4.4 | none | — | the Rite's thresholds are exact | CLOSED | `RiteView.swift:106,110,114,334`. |
| E4.5 | MAJOR | DATA | Return crossings exact; two signature voices missing | OPEN | `agedBed` → 0 hits; ring is an immediate bowl, no growth, no 3400ms delay. |
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
| G3.1 | BLOCKER | DATA | Light's five-movement sound architecture absent | OPEN | 4 built; `lightOff`/`closeTheRoom`/`darkReturns` → 0 hits. The removal half is unbuilt. |
| G3.2 | MAJOR | DATA | the Return's two signature voices absent | OPEN | `agedBed` → 0 hits; ring strikes immediately. |
| G3.3 | MAJOR | VISUAL | `bowl` 4x too loud with the wrong spectrum | OPEN | `SoundEngine.swift:646` peak 0.32 vs 0.075; `RiteTones.swift:119` partials `[1,2.756,5.404]` vs `[1,2.004,2.98,4.02]`; no bed duck. |
