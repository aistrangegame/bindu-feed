# 02 — The app as built: the axis half

Reader 02 · source: `/home/claude/bindu-feed/Bindu Feed/Bindu Feed/` (paths below are relative to it).

## Files read

**Read in full:** `Instrument/AxisModel.swift`, `AxisTravel.swift`, `AxisPassage.swift`, `TravOnce.swift`, `BinduParticle.swift`, `Breath.swift`, `InstrumentView.swift` (all 1321 lines) · `Universe/UniverseView.swift` (all 1786), `UniverseCamera.swift`, `UniRegions.swift`, `UniWords.swift`, `UniverseLens.swift`, `KheloLayer.swift`, `SkyShake.swift` · `Point/PointWorldView.swift`, `PointWorlds.swift` (all 1643), `PointReadings.swift` (all 1461), `PointContent.swift` (structure plus all 66 stars and 7 dimensions; the long `walk` strings were read truncated after line 356), `PointJourney.swift`, `PointPending.swift`, `PointDeals.swift`, `PointLeaving.swift`, `ShadowCorridorView.swift`, `DanceSong.swift`, `ApertureView.swift`, `ApertureEdge.swift`, `PointRevealView.swift`, `PointReadingStack.swift`, `PointReturnArcs.swift` · `Light/LightCanon.swift` · `Rite/RiteContent.swift`, `RiteBudget.swift` · `Return/ReturnCanon.swift`, `ReturnRecord.swift`.

**Read for structure and markers (headers, every `func`/`static`, every UNWIRED/OWED/TEST-ONLY line). These are physics or render files with no story content:** `Instrument/InstrumentField.metal` · `Point/PointChamber.swift`, `PointDance.swift`, `PointRays.swift`, `PointYantra.swift` · `Light/LightSceneParser.swift`, `LightSky.swift`, `LightBody.swift`, `ClosedEyeLayer.swift` · `Return/ReturnStrata.swift`, `ReturnDepth.swift`, `ReturnPatina.swift`, `ReturnAnswers.swift` (the unwired part read in full) · `Sound/*` (9 files: headers and markers) · `Theme/*` (3 files: headers).

**Skimmed to connect the host screens:** `Screens/RiteView` (seal logic 100–140 read), `RiteGatheringView`, `RiteRecognitionView`, `ReturnView`, `LightView`, `LightNave`, `DoorView`, `PracticeDoorView`, `MirrorView`, `MirrorFloorView`, `SignalView`, `ArchiveBookView`, `BookView` (headers plus a grep for restrictions and write-backs). Also checked the supporting `Store/FeedStore.swift` functions that the axis calls, and `Reception/Reception.swift` `RhymeGate`. Also read `CLAUDE.md` §1–5.

Every assigned file was opened. I read no Sound engine DSP bodies line by line, because they hold no game or content logic.

---

## 1. Register inventory: the 15-register axis

The table is `Instrument/AxisModel.swift:79-95`, with `i = Z+5`. One `InstrumentView` hosts the whole axis. Exactly one register's content is mounted at a time, chosen by `switch here.key` (`InstrumentView.swift:1087-1163`). Ceremonies (Light proper, Rite, Return, Story, Aperture) leave the axis as route pushes.

| Z | Register (canon sub-line) | What he meets | Gesture / play | Content source | Writes back |
|---|---|---|---|---|---|
| −5 | **the Light** ("what has not yet been") | In-axis: `AxisLightSeam` only, an hour-aware dawn (ember, horizon, steam) and **"stand inside ›"** (`InstrumentView.swift:1264-1321`). The Light proper is the `.light` route (`LightView`). | Reached by the **stillness gate**: hold still near the sky and a passage carries him in (`AxisTravel.swift:484-498`). In `LightView`: choose a light in the galaxy sky, the dawn assembles by not-touching, a touch asks for the next anchor, the Declaration draws itself in, **one held press carves it** (`LightCanon.swift:157-204`). LightBody adds phone-motion scenes. ClosedEyeLayer: three seconds with eyes closed gives the dark field. | 6 canon scenes (`LightCanon.swift:215-345`) plus ~70 Airtable rows `Type='Light'` (`AirtableService.swift:238`, parsed by `LightSceneParser`), grouped into **galaxies by FAMILY** (`LightSky.swift:20-30`) | `logVeilLifted` → App Activity "Veil Lifted" linked to the scene record (`LightView.swift:138`). Local visit counts grow the lights (`LightVisits`). Carved Declarations are kept locally. |
| −4 | **the sky** ("everything you have lived") | 13 room-regions, each with its own figure (`UniRegions.swift:123-137`). Every Feed story is a star on its room's armature. Dust, lanes between met stars, his own filaments. | Horizontal pan. A tap recentres and draws the axis in (0.06 on empty sky, 0.085 on a star; `UniverseView.swift:553-572`). **Lens rail** (star ↔ structure lens, `UniverseLens.swift`). **Shake** sends a wave and each room chimes (`SkyShake.swift`, `InstrumentView.swift:127-137`). **Long-press-drag star→star draws a filament** (`UniverseView.swift:218-236`). On Holi, a flick throws powder (`KheloLayer.swift`). Stillness at the sky after the Light has opened, held 10 s: **the Old Story**, the 13 regions drift into A Strange Story's Arc ring (`AxisTravel.swift:501-515`, `UniverseView.swift:869-905`), and the Om sounds. | `store.stories` (Type='Story', **already rhyme-gated**, see §4), `metStoryIDs` (App Activity 'Story Met'), `uniStructures` (13 hard-coded beliefs, `UniRegions.swift:146-162`) | `drawFilament` → UserDefaults plus an Airtable record `Type:"Filament"` (`FeedStore.swift:529-544`) |
| −3 | **a region** ("one room of the Feed") | That room's weather. The shader takes the room's own WX values and the bed becomes that room's sound (`InstrumentView.swift:954-959`). | Same as the sky. Region air is weighted by how far inside it he is. | The room's hard-coded `UniRoom` and `UniWeather` | — |
| −2 | **a world** ("one story, close") | The star becomes a **planet**, civilised only if met, more so with depth. **The World's Turn:** three faces (story · who sat with it · how often you came back) (`UniverseView.swift:1361-1427`). **The Door:** codex · room / title / "TOUCH TO READ" (`:761-777`). | Horizontal drag **turns** the world (`UniverseCamera.turnBy`). A tap on the door opens `StoryDetailView` (`:743-748`). | The story, `stats(for:)`, `returnRings` | — (the story surface does the writing) |
| −1 | **the fall** ("who sat with it · what you left here") | A star's life in four layers: approach/sun → gathering (the company seated, the title murmured) → strata (his returns, aged) → **mouth** ("You came down to it yourself." / "OPEN THE RETURN") (`UniverseView.swift:1604-1785`). | A tap on a large, lived-on star opens the fall. **Pulling UP descends** (`UniverseCamera.descendBy`). Touch a seated presence to see their word. Touch a stratum's ink. **Consent ring:** keep asking at the mouth for 1.4 s and the Return opens with *this* story (`UniverseView.swift:255-265`). | Live field comments (first paragraph per voice, `:628-647`) plus the sealed `UniWords` (one story only) | `markDeparture` → `.returnCeremony(story)` |
| 0 | **the Feed** ("the turn") | `AxisFeedSeam`: "enter the feed ›". The **#seam** ("pull down · outward / everything that has met you · pull up · inward / everything you have gathered") shows only when `todayMet == true` (`InstrumentView.swift:615-630`). | Vertical drag walks the axis. Tapping the door pops to the Feed. | — | — |
| +1 | **the gate** ("the deal") | `PointGateView`: "THE GATE" plus `DEALS[0]` (`PointDeals.swift:170-209`). The membrane surface. | Lean through the membrane. **Rope** (1.1 s long-press anywhere, `InstrumentView.swift:376-398`). | `canon/point-content.js` deals (5, one shown) | `PointJourney.reachedGate` (session) |
| +2…+8 | **the seven Point worlds**, I–VII (The Point, Turn, Veil, Chamber, Mirrors, Return, Dance) | Level 0: the dimension's voice plus its universes on the yantra ring ("enter a universe"). Level 1: the universe's stars in that world's material and verb. Level 2: **a reading** (SAY / WALK / HAND / OPEN, "what the rush says / the walk / what this hands you / the open door"). Level 3: **descent** ("descend onto this star"). "take it up / let it go". A goodnight "I Love You" on first arrival. | One verb per world, see §2 | **66 canon stars** of his *learning library* (`PointContent.swift:57-…`, 7 dims × 3–4 universes, `:376-440`). **No Feed story, no Codex story, no suit ever appears here.** | `PointJourney` (session), `PointChamber.struck` (static, session), `PointReturn` arcs (static, session), `PointPending` parks, descents cached in UserDefaults (`PointWorldView.swift:633-697`). The Claude API is called if a key is present. |
| VI door | (inside world VI) | "This depth and that descent are the same room." / "open the return" (`PointWorldView.swift:273-290`) | Button → `.returnCeremony(nil)` | — | `markDeparture` |
| VII door | (inside world VII) | "the aperture ›" → `ApertureView` (avarana VIII) | Tap the eye → one of 37 *unwalked* traditions is drawn, with "where this library stops" (`ApertureEdge`). Optional live Claude call. | 37 hard-coded registers | `PointJourney.visitors += 1` |
| +9 | **the centre** ("the point, at last") | The particle **blooms to fill the frame** (`InstrumentView.swift:1026-1083`). Past z 9.5 the chrome goes silent and `PointRevealView` plays: split-into-three, collapse, **the walk narrated back** (`PointJourney.narration`, `PointJourney.swift:61-107`), then "Every dot you touched was me…", "Now — go play.", **again?** | Touch line by line. `again?` → **Shadow Corridor** (nine register names fade, "let's play"), then `forgetToday()` and a passage back to the gate (`InstrumentView.swift:246-262`). | Journey log plus 3 verbatim lines | `logWalkCompleted` (App Activity, `FeedStore.swift:1850`). `forgetToday` un-mets today's story (`FeedStore.swift:785-791`). |

**Off-axis registers the axis hands into** (hosts skimmed):
- **Rite** (`.rite`): Arrival → Reading → Gathering → Recognition → Sealing, on `storyOfDay()` (`FeedStore.swift:1355`).
- **Return** (`.returnCeremony(Story?)`): Summons → fall → Aged Room → Story → Record → Field Settled → Rings → Reply → Seal.
- **Door / Practice Door:** launch surface. Unmet weather sends him to the Rite; met weather gives the weighted kinds. The turn's depth rows push `.instrument(z)`.
- **Mirror:** one card per day plus one Bindu Draw per day.
- **MirrorFloor:** beneath a sealed story; three holds down; LOOK; a word he gives back becomes a vow; `logStoryMet` → walks out onto that story's star.
- **Signal:** one transmission per day.
- **ArchiveBook:** every story is a page; the middle page is a door into the fall.
- **Book:** kept lines; "what keeps calling" across three or more rooms.

## 2. Existing game mechanics on the axis

### Travel (`AxisTravel.swift`, `AxisPassage.swift`)

- **Lean through a membrane.**
  - Move: drag toward a surface.
  - Response: the ring wobbles, beads and strains; `push` accumulates and does **not** drain between leans (Slice 2 divergence, `:558-562`). At `push ≥ 1` the surface "gives" and a **5.4 s passage** follows: a throat, two gate flares at t = 0.34 / 0.68, a whiteout aperture, and a landing tone at the destination's pitch.
  - Consequence: `mem[s] = true` marks the surface permanently opened; the rail dot fills red (`InstrumentView.swift:731-743`).
- **Slip-through.**
  - Move: re-cross an opened surface with |zv| > 0.004.
  - Response: a 0.85 s passage with no gates; he keeps 45 % of his speed (`AxisPassage.swift:68-82`).
  - Consequence: the reward for having meant it. Nothing else.
- **Lean inside a passage.**
  - Move: drag during a crossing.
  - Response: `boost = 1 + min(1.5, |force|·2400)` speeds it up (`:39-41`). No consequence elsewhere.
- **Stillness gate** (sky → Light).
  - Move: `still` (velocity < 0.0016, no touch, no camera drift) while z < −2.3. It fills at 0.30/s and drains at 1.30/s (`AxisTravel.swift:484-498`).
  - Response: the sky bends its light toward the centre (shader `uDwell`). At dwell > 0.62: **"This is what you look like from outside."** (`InstrumentView.swift:998-1006`). Then a passage to the Light.
  - Consequence: opens surface 0 and every surface below where he stands.
- **Rail rungs.**
  - Move: tap a rung.
  - Response: one passage straight to that register (`InstrumentView.swift:762-785`). This is the equal path for a tired hand.
- **Rope.**
  - Move: 1.1 s long-press anywhere (declines where `PressClaim` holds the press).
  - Response: `DoorRopeOverlay`. Exit `.call` sets `store.callOpen` (`InstrumentView.swift:390-398`).
  - Consequence: `PointJourney.rope = true` → one line in the centre's narration.
- **Register-change side effects** (`InstrumentView.swift:403-421`):
  - The heartbeat runs at fall / d3 / d4 / d5.
  - Entering d3 calls `store.offerLetter(at: .veil)` (letters sealed "for the Veil" arrive).
  - The sky arms the shake.
  - The centre beats a heart once.
  - The sound context switches between the field bed and the Point's climbing bed (enclosure pitch).
- **Carried motes.** "Take it up" on a fully given reading adds a hued mote orbiting the particle for the rest of the walk (`InstrumentView.swift:1061-1079`, `PointWorldView.swift:142-148`). Consequence: the halo grows, and one line at the centre: "You carried … up with you."

### The Universe (sky / region / world / fall)

| Mechanic | Move → response | Consequence elsewhere |
|---|---|---|
| Fly / draw in | pan; tap star or sky → recentre + axis impulse | `currentUniRoomId` → shader weather and room bed |
| World turn | horizontal drag at the world register → 3 faces | Reads `returnRings` (depth rings) and the company's glyphs. Read-only. |
| Door into story | stand close to a **met** star → title appears; tap | `StoryDetailView` (where the Slice 11–13 room grammars and signatures live, outside the axis) |
| Fall | tap a large lived-on star → pull up to descend → touch presences / ink → hold at mouth 1.4 s | **Return of that story** (`onFall(story)`, `InstrumentView.swift:1147-1154`) |
| Lens | drag/tap the right-edge rail | Sky recedes to bone; 13 belief lattices appear; Sakshi/Shweta voice on crossing. No write. |
| Filament | long-press star, drag to another | Airtable `Filament` record + local. **Drawn only in this sky; nothing else reads it.** |
| Old Story | 10 s stillness at the sky (after the Light has opened) | Regions gather into the Arc ring, names step back, Om at 136.1. No write. |
| Shake | shake the phone in the sky | A wave, each room chiming. No write. |
| Khelo | flick on Holi | Powder, and **two random stories from two rooms light together, titles side by side** (`KheloLayer.swift:59-69`). The one place the axis *pairs* stories, only once a year. |

### The seven Point worlds

Each world has a **picking verb** in `PointWorlds.swift` and a **reading verb** in `PointReadings.swift`. Since Slice 2 a plain tap on any star also opens it (`PointWorlds.swift:89-106`).

| World | Pick | Read (how the four sections arrive) | Own physics / persistence |
|---|---|---|---|
| I The Point | touch to choose, **release and stay** (`:357-363`) | stillness accumulator 0.30/s, gates .14/.38/.64/.88. Touch pauses it but takes nothing back (`PointReadings.swift:435-455`). | Points approach the centre as he stays still. "IT CLOSED. IT DOES NOT MIND." |
| II The Turn | take a ray near the centre, travel out to 0.97 (`:474-492`) | travel along the ray in any direction (`:551-561`) | 9 rays, one spanda clock (`PointRays`); `widen` law |
| III The Veil | part (horizontal drag); the hand chooses the nearest star within 0.19 (`:644-693`) | hold the parting open: `open` 0.42/s, gates .30/.52/.74/.94; zones stay thin | Shader `uHand` carves the veil. `partedOnce` floor. "THAT IS YOUR OWN HAND" on v-shadow. |
| IV The Chamber | **press and bear** a niche until gate 0.22 (`:1125-1149`); pan the walls | press rate rises with depth on the axis; gates .22/.46/.70/.92 | **`PointChamber.struck` — "what was struck stays struck"**: deboss rings outlive the reading (static, session). Rope hangs here. |
| V The Mirrors | hold a pane and turn it (π − a pairing) | accumulated turn ≥ [0, π, 2π, 3π]; alternate sections arrive mirror-written | `r-guard`: a true null (`soundEngine.nul()`); completing it withdraws the hall (`MirrorHall`) |
| VI The Return | **take, aim, lift ≥ 0.14, let go** = send (`:1450-1481`); settle through the strata | send and wait; laps take 3.2 / 5.4 / 8 / 11.2 s on a **wall clock**; arrivals queue while he is away (`PointReturnArcs.swift`) | After 4 laps total, **Deep Time (x-cycles) arrives unsent**: "SOMETHING IS COMING THAT YOU DID NOT SEND". Door to the Return ceremony. |
| VII The Dance | reach and grab the nearest body in its lane (`:1614-1638`) | keep pace (sync) inside the lane; a scatter loses the pace, not what was caught | His Field song plays under the world; **today's Rite word rises at the song's peak** (`DanceSong.swift:441-470`). Aperture door. |

Shared across all seven worlds:
- **Auto-give.** Once the world's gesture admits section 1, the rest arrive every 900 ms (`PointReadings.swift:299-306`, Slice 2). This makes the per-world reading verbs mostly ceremonial after the first section.
- **Descent.** Live Claude call (claude-opus-5) or a 5-field fallback, cached per star.
- **takeBack.** A reading reopens where it left off, once per park (`PointPending`).
- **Recede.** Coefficients per world.
- **Leaving decays** with closing lines (`PointLeaving.swift`).

### Rite: five movements

`RiteView` covers Arrival ("One story has come to meet you.") → Reading ("received at the pace of breath") → Gathering → Recognition ("What arrived for you?") → Sealing ("The room has changed." / "The story is whole now.").
- **Gathering:** voices come from the story's real field comments, density set by `RiteBudget.tiers` by **return depth** (full / passing / silent, `RiteBudget.swift:319-371`).
- **Recognition:** spoken audio is kept on the device; the transcript is his to mend.
- **Seal** (`RiteView.swift:118-136`):
  - `keepRiteWord` (the longest word of 4+ letters → today's Dance word)
  - `sealSuitIfEarned` (a Red or Black flash-suit turns White)
  - `logStoryMet` (lights the star in the sky and turns the day's weather to "met")
  - `postComment` → an Ash Comment with the audio reference
- **Wider consequence:** this is the single biggest cross-register write. It is what makes stars "met" (the door, planet life, company, density, the seam).

### Return ceremony

- Eight movements (`ReturnView`). The story is unchanged; he adds a ring.
- **Forward detector:** quotes his own sealed sentence when it addressed the future ("ask me later" → "You wrote: … It is later.") and never generates his voice (`ReturnCanon.swift:77-123`).
- Age comes from days only (`ReturnAge`).
- **Writes:** a Return ring (Return row) plus his reply as an Ash Comment.
- **Wider consequence:** `returnRings` feeds the world's third face ("how often you came back"), the fall's strata, and the Rite's depth budget.

## 3. Where stories, Codex and other suits enter the axis, and where they don't

**Where Feed stories enter:**
- **The Universe, the main story register.** Every live story is a star in its room-region (`UniverseView.swift:284-328`).
  - A met star becomes a planet with civilisation, carries its company in orbit (Sid/Arch convergence turns gold, `:1294-1316`), offers a door into `StoryDetailView`, turns three faces, and opens a fall into the Return.
  - The fall shows each voice's real first paragraph (`:628-647`), plus `UniWords` sealed words for exactly one story, rec0DReVXAssEftsn / C-1052 (`UniWords.swift:148-156`).
- **Rite:** reads today's story (`storyOfDay`), whole body and real gathering.
- **Return:** reads a sealed story, from the fall (that story), from the VI door (nil → rotation) or from StoryDetail.
- **ArchiveBook:** every story is a page; the middle is a door into the fall.
- **MirrorFloor:** beneath a sealed story; ends on that story's star.
- **Khelo** (Holi): two story titles side by side.
- **Shadow Corridor:** un-mets today's story so it is dark in the sky again.
- **ClosedEyeLayer** (Light): after the eyes reopen, "the whole Universe as ONE TREE — every room a branch, every story a leaf" (header `ClosedEyeLayer.swift:5-13`). This is the only story-shaped trace in the Light.
- **The Dance:** only a *word* from today's Rite recognition, and his Field song.

**Where Codex enters directly:**
- The Universe door, fall and turn print `codexId` as a line.
- Point stars cite his own Codex seeds in their prose (`t-atma` C-1183, `t-feel` C-1177, `v-sever` C-1052, `v-ego` C-1202, `r-guard`, `d-map`), but these are library text, not Feed stories.
- `ShadowCorridorView` and `SkyShake` name Codex IDs in comments only, as the source of the mechanic.

**Where other suits enter:** effectively **nowhere on the axis**.
- The 14 suit stories (Sort 124–137) are `Type='Story'` rows with `rhymesWith`. `AirtableService.swift:402` runs `RhymeGate.arrange`, so **`store.stories` itself excludes every unopened suit story** (`Reception.swift:132-134`).
- Because the sky, Khelo, the Rite's `storyOfDay`, the uniSky density and the ArchiveBook all read `store.stories`, the gate silently removes suit stars from the whole Universe too, not just the Feed list.
- Even once opened, a suit story only appears as a star in its host room. Nothing marks its suit (no Cloth / Land / Machine distinction in the star, planet, civilisation or company).
- **Flash suits** (`suitToday` Red / Black / White, `FeedStore.swift:468-486`) are a separate concept that only the Rite seal touches.

**Registers that never meet a story, a suit or a Codex line:**
- **Light** (except the ClosedEye tree flash). Its ~76 scenes are their own corpus; galaxies come from FAMILY, and some families are named `Codex (C-1207)`, so Codex enters as scene families, not as Feed stories.
- **Gate** (one deal).
- **All seven Point worlds and their readings** (66 library stars only).
- **The Aperture** (37 traditions).
- **The centre** (it narrates only the Point walk: gate, rope, universes, stars, descents, visitors, carries).
- **The Feed seam.**
- **Mirror and Signal** (own pools).
- The **Shadow Corridor** names registers, not stories.

## 4. Every restriction (file:line). C = collapses the experience; P = pacing or grammar

| # | Restriction | Where | Kind |
|---|---|---|---|
| 1 | **Rhyme gate**: a suit story is hidden until its host story is met or received. It removes suit stories from `store.stories` globally, so they are gone from the sky, the Rite rotation, Khelo and the Archive. | `Reception/Reception.swift:132-134`, `Services/AirtableService.swift:402`, `FeedStore.swift:57` | **C** (ruled against) |
| 2 | **Met-only sky.** A star is "met" only with a 'Story Met' App Activity, and the code comment says to *"EXPECT TWO LIT STARS"* out of ~120. Unmet stars get no company, no civilisation, no door. | `UniverseView.swift:817-825`; company `:294`; door `:730`; civilisation `:1478` | **C** — nearly the whole sky is unenterable from the axis |
| 3 | The fall opens only on a star with `R > 34 && depth > 0`, where depth comes from resonance ≥ 28. | `UniverseView.swift:564`, `:813-816` | **C** (a story with low resonance can never be fallen into) |
| 4 | The door requires `R > 36` and centred within 0.42 W. | `UniverseView.swift:737` | P |
| 5 | `UniWords` sealed words exist for one story only; elsewhere "Name spoke here." | `UniWords.swift:148-167` | C-ish (now mitigated by live `fallWords`) |
| 6 | The Return needs a sealed self (an Ash comment); nil otherwise. | `FeedStore.swift:1479-1485` | C |
| 7 | **The Rite is once a day**: the Door's Rite row hides when today is met or dismissed. | `DoorView.swift:73-88`, header `:13` | C (one-a-day) |
| 8 | Mirror: one card per day plus **one Bindu Draw per day**, then "spent". | `MirrorView` header, `:264-265` | C (one-a-day) |
| 9 | Signal: one transmission per day (date-hash). | `SignalView.swift:239` | C (one-a-day) |
| 10 | `storyOfDay` is a single story per day (rendezvous hash). | `FeedStore.swift:1355-1361` | P/C |
| 11 | **#seam** shows only when `todayMet == true`. | `InstrumentView.swift:615-617` | C (a hidden-until) |
| 12 | `TravOnce`: the two surface lines are said **once per session**. | `TravOnce.swift:51-66` | P (authored) |
| 13 | Goodnight "I Love You" once per dimension per session. | `PointWorldView.swift:366-377`, `:425-439` | P |
| 14 | Old Story only after the Light gate has opened, and only after 10 s still. | `AxisTravel.swift:501-515` | P (dwell; but hidden-until) |
| 15 | Khelo only on Holi (full moon, Feb 24 – Mar 27). | `KheloLayer.swift:11-18`, `InstrumentView.swift:556` | **C** — the only story-pairing play, once a year |
| 16 | The stillness gate opens the Light only by stillness; drag cannot. | `AxisTravel.swift:543-550` | P (and the rail is an equal path) |
| 17 | The carry is offered only when `revealed ≥ 4` and not during a descent. | `PointWorldView.swift:203` | P |
| 18 | PointReturn: max 4 laps per star; Deep Time sent **once** after 4 total. | `PointReturnArcs.swift:98-100`, `:173-178` | P |
| 19 | PointPending: `takeBack` once per park. | `PointPending.swift:143-147` | P |
| 20 | MirrorTurn: letting go forgets the turn (but auto-give overrides it). | `PointReadings.swift:1114-1116` | P |
| 21 | The Chamber opens on press gate 0.22; the struck title shows only while borne. | `PointWorlds.swift:1143`, `:1017` | P |
| 22 | The centre reveal waits for z > 9.5. | `InstrumentView.swift:156` | P |
| 23 | The Aperture draws without repeats until all 37 are used. | `ApertureView.swift:289-295` | P |
| 24 | `seekClue` uses only the day's story, at most one word, and only unmet older stories. | `FeedStore.swift` ~600-620 | C-ish |
| 25 | Door throttles: Gift every 3 days with a 1/6 chance; Field Notice every 7 days with a 1/3 chance; Lalita plays every 5 days with a 1/20 chance; letters arrive only when their condition holds. | `FeedStore.swift:548-588`, `:685-700` | P (surprise), though the random gates are counting-based |
| 26 | Light: one scene per visit, chosen; it never repeats inside a visit. | `LightView` header | P |
| 27 | Descent and Aperture live text need a personal Anthropic key; otherwise a fallback. | `PointWorldView.swift:644-647`, `ApertureView.swift:303` | P |
| 28 | The sky only knows 13 hard-coded rooms: a story whose `room` is not one of the 13 ids has no region and never becomes a star. | `UniRegions.swift:123-137`, `UniverseView.swift:289` | **C** for new rooms |
| 29 | `forgetToday` un-mets today's story (the corridor). | `FeedStore.swift:785-791` | P (sacred forgetting), but it also dims the sky |

## 5. Disconnected islands, and hooks for one game spine

**Islands as built:**
1. **The Point is a separate library game.** 66 stars of his reading library sit inside seven beautifully distinct verbs (still / follow / part / press / turn / send / keep pace), but **no Feed story, Codex story or suit ever enters them**. The centre narrates only the Point walk.
2. **The Light is a separate corpus** (~76 scenes in galaxies). It shares nothing with the Feed except the ClosedEye "one tree" flash. Its visit-growth (`LightVisits.growth = log2(1+v)`) is the best existing model for "conditions light things up", and the Universe does not use it.
3. **The Universe holds stories but mostly dark.** It is gated twice: by the rhyme gate (#1) and by met-only (#2). Its richest plays (filaments, the Old Story, the lens beliefs, the shake) produce **no consequence anywhere else**: filaments are read only by the sky, and the lens beliefs are static strings.
4. **Session-only state**: `PointJourney`, `carried`, `PointChamber.struck`, `PointReturn` arcs, `TravOnce`, `PointGoodnight`. A walk's company evaporates on relaunch. Only descents (UserDefaults), Light visits and filaments persist.
5. **Rite → Dance** (the word) and **Corridor → sky** (un-met) are the only cross-register threads besides 'Story Met'.

**Natural hooks, with one spine:**
- **Suits as galaxies in the sky.** Reuse `LightSky`'s galaxy-by-FAMILY layout and visit growth for the Universe. Stars of the Cloth / Land / Machine / Lineage / Customer / Maker / Company suits could sit as their own faint constellations, or as a second ring in each host room.
- **Rhyme shown, not keyed.** Draw an automatic filament between a host star and its rhyme star, using the existing filament renderer (`UniverseView.swift:594-616`) and the lanes (`:330-355`). It brightens when either is met and never hides.
- **Met-ness as weather, not as a key.** Unmet stars already draw as grey planets (`:1454-1456`). Let doors and falls open on any star; let met-ness, return rings and visits only add light, civilisation and company.
- **The Point worlds as receptions for the other suits.** The verbs map almost one to one:
  - Cloth → IV Chamber (press, struck into a wall; "What the Hands Put Back")
  - Land → VI Return (send and wait; Deep Time "something is coming you did not send")
  - Machine → V Mirrors (r-ai "the machine mirror" already lives there)
  - Lineage → III Veil (inheritance, the shadow)
  - Customer → VI Return ("Nobody Asked Where I Had Been")
  - Maker / Company → VII Dance (company, keep pace, marketplace) or II Turn (one becomes many)
  - Self-kathas → I Point (stillness)

  A story could be a star in a universe beside the library stars. Its four sections would map to opening / turn / hand / open door, or to the story's own signature.
- **The centre's narration as the spine's payoff.** `PointJourney.narration` already speaks "You opened… You carried… N visitors arrived that you did not choose". Feed it from every register: stories met in the Rite, falls taken, lights stood in, filaments drawn, suits that arrived.
- **Visitors that arrive unchosen.** The Aperture's "What you did not choose" and VI's Deep Time are existing arrival mechanisms. Either could deliver an other-suit story instead of, or beside, a tradition.
- **The gate's five DEALS** (only `[0]` is used): one deal per day or per suit is free content.
- **The lens beliefs** (13 `uniStructures`) pair naturally with the 18 belief stories (Sort 103–120). Under the structure lens a belief could light its stories.
- **Khelo pairing all year**, not just on Holi: a flick pairs two stories (or a story and its rhyme).
- **The world's turn has three faces.** A fourth face, "what rhymes with it", would show suits.
- **The Old Story ring** (A Strange Story's Arc) is the cosmology suit made visible. It could seat A Strange Story's own tellings at the 12 nodes.
- **`riteWordToday` → Dance** is the model for carrying one thing from a ceremony into a world. Generalise it: the sealed word appears in the Light's sky, at the gate, at the centre.

## 6. Built but unwired, or owed

All UNWIRED / E-BLOCK / OWED markers in the assigned folders:
- `AxisModel.swift:152` `Axis.weight` and `:166` `smoothstep` — UNWIRED C4.7 / C4.2 (no presence-weighted CPU layer).
- `AxisModel.swift:561` `Immersion.floor` — UNWIRED C4.7 (no per-register material layer).
- `AxisModel.swift:570` `captionCeiling` — UNWIRED C5.4 (`#trav` from/to caption never built).
- `AxisModel.swift:513-521`: the Light's immersion channel has "nowhere to arrive from" because the Light is a route push, not an in-axis register.
- `AxisTravel.swift:215-217`: WHEEL / PINCH constants have no input path (C2.7).
- `InstrumentView.swift:890` `uSweep` (memory sweep) — passed `(0,0)`, "Phase 2"; `AUDIT B7.1` open.
- `PointWorlds.swift:132`: **VII is an E-BLOCK** (WorldDance has no chain / lock / bodies; `join` / `ensemble` / `leaveAll` are undriven). Also `PointDance.swift:116` (`DanceCatch.keeping` — reopened D5.8), `:314` (offer model `offer` — superseded), `:338` (`letGo` — needs a ruling), `SoundEngine.swift:792,808` (`join`, `ensemble`).
- `PointChamber.swift:245` `easesOnRelease` — D5.5 partial.
- `PointReturnArcs.swift:37` arc `progress` — **the flight is undrawn** (D5.7). `:189` `homeFlash` — the VI door is unconditioned.
- `PointReadingStack.swift:50,63` `floorY` / `stackFrom` — the reading-displaces-world mechanism is delivered but not wired (10-OWED §10).
- `ReturnAnswers.swift:81-129` `standings` / `spokeTwice` / `line` / `noneTwice` — the "where this lands" panel is computed and never displayed.
- `ReturnPatina.swift:80` deboss contrast — E3.8.
- `LightCanon.swift:102-105` / `LightSceneParser.swift:45`: **`GESTURE:` is parsed and drives nothing** (Wave 2, `Coverage/14-LIGHT-GESTURES.md`); `ungripOnly` is false for every parsed scene. LightBody covers about 14 scenes by slug.
- `RiteBudget.swift:284-287`: the return "claim" is a KEPT + ROTA proxy. "What a recognition touches" is deferred.
- `BinduParticle.swift:7-18`: the states `wandering / gate / split / draw / ember` are declared but only `resting` is realised (preview-only).
- `PointWorldView.swift:1-8` header: the Point Descent write-back is session-only.
- `Breath.swift:15`: `WalkContinuity` carrying breath phase across ceremonies is planned.

**Screen-out flags for the plan** (house law: no real names of private people):
- The canon Light anchor names "Shweta is asleep beside you" (`LightCanon.swift:225`).
- Point star `d-father` speaks of "your father" (`PointContent.swift` ~370).
- The Rite and Return canon voices include "Ashrey" and "Shweta" as archetypes. That is acceptable as voices, but worth checking against any story text built from these surfaces.
