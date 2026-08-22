# A STRANGE FEED — THE BUILD LEDGER
### The Claude Code companion to the Unified Master Design Brief
*Sealed August 14, 2026 · Repo: `aistrangegame/bindu-feed@main`, tree `394a60f3` · Pairs with `a-strange-feed-UNIFIED-MASTER-DESIGN-BRIEF.md` — that document holds the experience; this one holds the reality of making it. Where the two conflict, the Brief wins on feel and this ledger wins on mechanics.*

---

## 0 · Ground truth (verified, August 14 2026)

- The repo is at **Phases 1–7 complete, Phase 8 (signing + on-device to iPhone "Neev") in progress.** 2 commits on `main`, no other branches. 9 screens, 11 components, 6 `FeedRoute` cases.
- **There is no sound layer on the repo. None.** Not partial. `field-sound.js` is a from-zero Swift build.
- **Everything designed since June 14, 2026 is unbuilt** — three-plus eras of locked design.
- The repo's `A Strange Feed/` folder is a stale June copy of the comps; the design project is the source of truth.
- Design outputs will arrive from Claude Design against the Master Brief; this ledger sequences the build regardless of when those land — most mechanics are already fully specced by the prototypes.

## 0.1 · Carried defects (fix in the first session)

1. **`AirtableService.postAshComment` hardcodes `"Archetype": "Ash"`** — Ash comments do not persist. Fix: take `archetypeName: String`; `FeedStore.postComment` resolves it from the live `archetypes` array.
2. **`Theme.swift` holds 9 archetype colors; canon is 11.** Add Neev `#7A8899` and Shweta `#ABA7A2` (Airtable rows are provisioned in Wave A below; views must read `Hex Color` live per the standing decision).
3. Delete or refresh the stale `A Strange Feed/` comps folder on the repo.

## 0.2 · Repo decisions that must not be undone

Bulk comment fetch (never N+1) · the Story Detail flood-transition anchor and stagger order are load-bearing · hold gestures run on `CADisplayLink`, never `withAnimation` · cross-dissolve everywhere, never a slide · archetype color reads from Airtable `Hex Color` · no local persistence beyond in-memory `FeedStore` (+ the sanctioned `UserDefaults` uses: Settings identity, Mirror draw-per-day) · single `CodingKeys` enum in `Models.swift` · exact wording is load-bearing · review-pace toggles and sound on/off dev buttons never ship.

---

## 1 · Build order — six waves

Each wave is shippable to Neev on its own. Sound comes first because five surfaces depend on it and nothing blocks it.

### Wave 1 · The Sound layer *(the highest-leverage unbuilt thing)*
Port `field-sound.js` (335 lines) to a Swift `Sound/` layer on `AVAudioEngine`. The naming map is already 1:1:

| JS | Swift |
|---|---|
| `startBed(rootHz, breathSecs)` | `SonicContext` |
| `agedBed(...)` | `SonicContext.aged` |
| `voice(key, hz, dur)` | `BreathVoice` |
| `threshold(hz, dur)` | `ThresholdTone` |
| `bowl(hz)` | `BowlTone` |
| `ring(step)` | `RingTone` |
| `inkOn / inkTouch / inkOff` | `InkVoice` |
| `openTheRoom / closeTheRoom / breathIn / veilLift / lightBed / lightOff / darkReturns` | the nave set |

Port the numbers verbatim: the CHAR timbre table (partials, gains, attacks, releases, vibrato/flicker/gliss/shimmer/air), the HZ table, pans, ceiling 0.55, mute-as-1.4s-fade, bed step-back 0.030→0.018, the aged-bed patina (900→430 lowpass, −0.4%/−0.6% detune, ×1.35 breath, 0.07Hz wobble), the ring series [2,3,4,4.5,6,8] with the 1.5%-flat settle, the bowl's 11s decay and bed-duck, the runtime-generated convolution impulses (3.6s air; 8.5s cathedral for the nave). The Point's ladder (174…963→136.1, beat 8.0→4.0) joins the same layer as a second register — one engine, not two. Timbre constants live as a Swift constant table (decided — they are the instrument, not content). `AVAudioSession` activates on the first user gesture, never on load. Reduced-motion: transient voices silenced, the bed never. Precedent: the Bindu Field app's DSP layer.

### Wave 2 · The Rite + the Gathering *(spec is now `The Rite v3.html` + `rite-scenes.js`, Aug 13 2026)*
`RiteView` — four movements as one flow (spec: `The Rite v3.html` + Brief §4). The surfacing reveal (opacity + translateY + blur-as-mask). **Both middle movements advance on touch, never on a timer** — one law: *nothing surfaces until he asks for it.* In the Reading, each touch lets the light reach one more paragraph (and scrolls it to the reading line); in the Gathering, each touch brings the next line, and when a voice has finished, the next touch lets the next presence take the field. A voice's tone re-sounds if he dwells past ~7s, so a presence is audible for exactly as long as it is present. **The budget law survives with its clock changed hands:** the same arithmetic still decides DENSITY (who is full · passing · silent at a given depth), but duration is his. Depth still crowds the field and the field still thins itself to make room for him. The Gathering: SwiftUI `Canvas`/Metal scenes per archetype (the ten behaviours from Rite v2 / Gathering v3), voice tone duration = `holdFor` (1.4 + lines×1.4 + close 1.4 + 2.8, seconds), heartbeat haptic via `CHHapticEngine` (a pulse, not a buzz). **The budget law** (Brief §4): `GATHERING_BUDGET 97.6` · `PAST_SELF_COST 9.0` · `PAST_SELF_SHARE 0.55` · passing 4.2 · three grades · Bindu never silent, not in ROTA · full voices derived from the previous Ash Comment (never hardcoded) + one from ROTA · always leave room for at least one passing voice. Movement IV: speech transcription + **audio capture kept** (`AVAudioRecorder`; see Wave A for where the file reference lives), `inkOn(174)` during listening, the Sealing sequence. Log the pulse: App Activity `Story Met`.

### Wave 3 · The Door + the turn *(the composite has landed — `A Strange Feed.html`, Aug 13 2026; mechanics are ready)*
`DoorView` replaces `LaunchView` as the launch surface: three weathers (unmet → Rite Arrival; met → weighted threshold kinds, weights 40/23/20/12/5, no back-to-back, first-ever open is a threshold; the day's met-state read from App Activity — never stored as a local flag). Rope: long-press recognizer on the whole surface (~1.1s) + `UIApplicationShortcutItem` quick action → `RopeView` (black, particle, two breaths, the line, two exits). The turn: `TurnOverlay` available from every top-level screen (dot mark trigger + slow-pull gesture), items per Brief §3.4, the Rite row hidden when today is met. `FeedRoute` grows: `.door, .rite, .returnCeremony, .universe, .light, .lightScene(id), .point, .pointStar(id), .rope, .players, .mirror, .signal, .compose(storyId), .turning(archetypeId)`.

**Two things the design added, for the port:** (1) **the crossing is a blink, the turn is a dissolve** — leaving the Door through its gateway closes and reopens like an eyelid (two shades meeting at a hairline that glints in the destination's colour, ~0.66s close / hold / open), while the turn only ever dissolves. The Door is the Axis register; the blink is its native motion, and it is used at *no other* surface. (2) **the turn's marks are drawn per surface, not from a glyph set** — thirteen dots for the Rooms, four strata for the Archive, a scattering for the Universe, the falling shaft for the Light, the particle for the Point, two overlapping lenses for the Players, ◉ for How You Arrive. No shared icon vocabulary; each is its own small composition. The Universe row is **present but unlit** until §8 is designed, and tapping it is absorbed (its threshold sounds; nothing opens).

### Wave 4 · Era A interior *(all specs final; HTML comps are the visual spec)*
The Turning (replaces `ArchetypeProfileView`; trace-∞ on the existing `CADisplayLink` loop) · Players View · The Mirror (date-hash selection `hash(yyyy-MM-dd) % live.count`; Bindu Draw in `UserDefaults` `mirror.draw.<date>`) · The Signal Space · Ash's Compose full-screen (`AshComposeView`; reads the Settings identity; hold-ember ~2.3s) · Room Selection's two-turns tier · Home Feed header swap (dot mark + Ash mark).

### Wave 5 · The Return + the Light
`ReturnView` — eight movements (spec: `The Return.html`): `agedBed(84,13)` + `bowl(168)`, the Record with the past self set apart, Field Settled voices, the rings canvas (grow 2.6s → `ring(n)` → `bowl(210)` at +3.4s), the Reply with the FORWARD detector (six patterns, tuned toward missing; verbatim quote frame). **The pacing law, app-wide (amended Aug 14 2026).** *Nothing surfaces until he asks for it.* It governs the Rite's Reading and Gathering (a touch brings the next paragraph / line / presence) and the Light's Dwelling — but in the Light it meets §6.2's older law, *text arrives on the exhale, never a bare timer*, and neither one wins: **a touch ASKS, and the next exhale answers.** Ask mid-inhale and the line still waits for the breath to turn; ask nothing and the space simply breathes. He sets the pace; the breath keeps the time. Held presses stay exactly where they were canonical — the Declaration draw-in, the ember, the gate-hold, the trace — and the Light's *door* remains stillness, not a touch.

`LightView` — the nave (spec: **`The Light v2.html`** + Brief §6): the **stillness gate** replacing the held press. **Stillness means the absence of INPUT — never the stillness of the body or the phone.** Core Motion / accelerometer detection is **cut** (tested on device, it fails; nothing is asked of the hardware). The mechanic: one touch arrives (the same touch that crossed the turn — and the only thing the door ever asks), after which a stillness accumulator fills over 4.6s of *not doing*; the nave's distance collapses as it fills, the air in the shaft settles toward stopped, the Bindu steadies, and `openTheRoom(8.5)` grows the stone tail so he hears the size before he sees it. **The absorption law:** a hand on the glass pauses the accumulator — dust picks its drift back up, the Bindu *softens* rather than warming (force is never rewarded), nothing is said — and lifting the hand resumes it. **It never resets:** every still second is kept, so a fitful arrival still arrives. Not a test he can fail. The door never instructs; he discovers it by stopping. the seven beats, `useBreath`-equivalent single-source breath clock (one `eased` value driving Bindu, dust, glow, and sound), the 268px column, carved Declarations (the one held press, 4.2s), exhale-gated text, the descending rings worn into the floor. S-L01 as the first scene: absorption of all hurrying gestures, the five phases, everything from and back to the point. **The Vow loop:** on Declaration carve, write a `Reflection` row (Flairs=Vow) so the Mirror can hand it back.

### Wave 6 · The Point + the Universe
`PointView` — vertical paging, the four levels, the particle (wander/rest/split/gate/goodnight/reveal — spec: `the-point-v8.html` §4 of its handoff), journey log → App Activity `Walk Completed`, the Aperture (live Claude API call; his Anthropic key in Keychain via Settings, same pattern as the PAT), hybrid descents (generate → write back `Point Descent` child → read children newest-first; offline falls back to WALK). `UniverseView` — per Brief §8 (design: `The Universe.html` + `universe-sky.js`, Aug 13 2026): derived read-model only (App Activity + The Feed + Identity for the structure lens), the fall-into-strata as the shared skeleton's fourth instantiation, `Veil Lifted` logging from the Light.

**The Universe's mechanics, as designed** (`The Universe v2.html` · `uni-rooms.js` · `uni-sky.js`). **One continuous descent, four scales, no screens between them:** the sky → the region → the world → the well, driven by a single camera `z` from 0.22 to 34 (exponential pinch/scroll). Scale bands cross-fade; nothing snaps and there is no zoom-to-fit.

· **Each room is a FORM, and the stories sit ON it.** Thirteen armatures, one per room, so the sky reads as thirteen figures before anything is named: the Forge a tetractys over a crucible · the Signal a beam with wavefronts · the Descent a spiral funnel · the Garden phyllotaxis with its 8-and-13 spiral families · A Maya Game sheared rhombi that swap when unwatched · the Watcher a mandorla that blinks rarely · the Field a lemniscate · the Thread a three-strand braid · the Body hex-packed tissue on one pulse · the Forgetting a ring whose missing arcs keep changing · the Remembering the same ring, a light closing it · the Circle concentric annuli · the Return an ellipse with a comet at perihelion. `place()` puts each story on the form; `arm()` draws it alive.

· **Each region has its own weather.** `field()` per room, fading in as he enters: sparks rising in the Forge, wavefronts crossing the Signal, warm rain falling in the Descent, growth rising in the Garden, tiles swapping in Maya, near-stillness in the Watcher, a weave in the Field, strands passing in the Thread, a pulse crossing the Body's tissue, motes dissolving in the Forgetting and re-gathering in the Remembering, ripples in the Circle, things sweeping back through the Return. Plus a per-region air-tint, so entering a region *is* arriving somewhere.

· **A met story is an inhabited world, and the sky IS the archive.** Met-ness is not decoration: the 26 worlds that carry light are exactly the 26 stories that exist, bound verbatim from the Archive (`Game View.html`), two per room, each with its real title and Codex ID. **Depth is read off the story's own resonance** (`res ≥ 85 → 8 · 60 → 5 · 44 → 3 · 28 → 1`), so how developed a world is *is* how often he has come back. In the app all of this reads live from The Feed + App Activity; nothing new is written and nothing counted. Planets are drawn as bodies (offset-lit sphere, fixed continents from the seed, terminator, atmosphere limb, slow rotation) and **life exists only where he has been**: unmet worlds are barren rock. Settlements = 3 + depth×4, placed by lat/lon and rotating with the world, bright on the night side; roads between them with traffic; orbital rings with ships once depth ≥ 3. Each room builds differently — `civ`: furnaces along a rift · antenna arrays · deep shafts · terraces · mirror-cities twinned across the equator · towers all facing outward · a lat/long net · one great road · districts pulsing in one rhythm · ruins going dark and relighting · relighting in sequence · city rings · orbital ports.

· **The doorway into the story.** A world offers its story only once he is standing close enough to see its lights (screen radius > 36px, within 42% of frame centre): Codex ID + room in Space Mono, the title in Lora, `touch to read` → Story Detail. **An unmet world offers nothing** — no title, no door. You do not browse into a story you have not met; that meeting happens at the Rite, and the silence of the dark worlds is load-bearing. A world with depth therefore has two doors: touch the title to read it, keep drawing in to descend the well.

· **Travel.** `LANES` join met stories — densely inside a region, and nine slow long-hauls between regions. Life only travels where he has already been. Long-hauls are visible from the sky; local lanes appear at region scale; road traffic at world scale.

· **The well** is the fourth scale, not a screen: keep drawing in on a world with depth (or tap one from close) and the fall begins; pulling up drives `desc` with inertia and each stratum crossed sounds `ring(n)`. At `desc > 0.93` the Return's door appears.

· **The lens is a held edge, not a toggle** — a 30px rail at the right frame edge moves one continuous `lens` value 0→1, so the two lenses can be *held apart* midway; a tap on the mark is the shortcut. To the structures sounds Sakshi (285), back sounds Shweta (329). Structures are chains of 5–7 nodes reading Identity, in bone and ash — `loose` widens the wander and softens the line.

· **Sound.** Region crossing sounds that room's Hz (126…315); **descending a scale sounds an octave up** (region Hz → ×2 at world scale), climbing back sounds 110. Back climbs one scale at a time. No labels over stars, no counters, nothing counted anywhere.

---

## 2 · The shared systems (build once, used everywhere)

- **`Breath`** — the single 0.1 Hz clock exposing one eased value; every surface (glyphs, ember, cosmos, light, sound LFO alignment) reads it. Port the `useBreath` single-source design.
- **`BinduParticle`** — one component, states: resting (crown, 10s breath) · wandering (9–14s relocations, untappable) · gate (hold ~1.1s, swell→burst) · split (three, merge) · draw (the Mirror's) · ember (comment-card scale). One color family `#E5533C`/`#C0392B`. Never explained.
- **`Age`** — one value; renderers per material (sound detune/lowpass · `saturate` · ink-state · strata depth) per Brief §11.
- **`WalkableHierarchy`** — the four-level skeleton (dimension → universe → star → descent) instantiated by the Point now, the Universe's fall, and later the Learning app. The Light does not use it (sealed).
- **Gesture kit** — the `CADisplayLink` hold loop (already shipped) generalized to: trace-∞, ember-hold, gate-hold, declaration draw-in; plus the **stillness detector** (touch-absence + Core Motion quiet) for the Light; plus the absorption responder (consume and ignore all touches, no visual scold).

---

## 3 · Airtable provisioning — the consolidated delta *(separate write chat, per the standing pattern)*

Base `app248ZTWhYJlvQj2` · The Feed `tbl7vzODMMJUgeX0b` · App Activity `tblJlBeiHnqGpYrL7`. All writes: field IDs, `typecast:true`, batches of 10–15, verify create responses, **`Status="Live"` on every readable record** (the blank-Status law).

### Wave A — Era A data (before Wave 4 ships)
- `Type` += `Reflection`, `Signal`
- `Flairs` += `Vow`, `Koan`
- `Sentence Source` += `Practice`, `Gaia Seed`
- Two new Archetype rows: **Neev** (▽, `#7A8899`, Operating Principle verbatim from the content inventory) · **Shweta** (◌, `#ABA7A2`, verbatim). Confirm Ashram is stored as **Ash**.
- Author the starter content: 10 Reflections, 6 Signals, the Practice/Gaia Seed threshold rows (all verbatim in `BINDU_FEED_CONTENT_INVENTORY.md`).
- Verify the existing nine archetypes' Operating Principles against the inventory's prototype text (the generation pipeline uses them as personas).

### Wave B — Next Era data (before Waves 2/5 ship)
- `Type` += `Light` · new field **Light Depth** (Near/Far) · new field **Link to Learning** → `tbl5kW1msXYfThGbj`
- New field on Ash Comment usage: an **audio reference** (Movement IV keeps the audio — no longer deferred)
- App Activity: `Activity Type` += `Story Met` (+ `Veil Lifted`, `Walk Completed`) · new field **Link to Feed** → The Feed
- **Nothing that could surface a count is provisioned, by design.**

### Wave C — The Point (one mechanical session, contract locked)
- **56 remaining Point Stars, Dimensions II–VII** (II=9 · III=9 · IV=11 · V=11 · VI=7 · VII=9), content verbatim from `the-point-content.json`: Name/Type=`Point Star`/Status=Live/Closing Line=title/Codex ID=id/Excerpt=status/Sort=d×1000+u×100+s/Body=`[SAY]…[WALK]…[HAND]…[OPEN]…`. 82 of 138 already done and verified.
- `Point Descent` Type option arrives via the app's first write-back (typecast).

### Content work remaining (crafting side, this workspace)
- **Pass 2 texts** for the five remaining Light vectors (S-L02–06), from Pass 1 + the trajectory and Relationships tables.
- The 18 belief stories → Feed + Identity wiring (already documented in its own handoff; separate write chat).
- The 117 Maya Codex entries awaiting transformation (long-horizon; the wheel of 102 does not wait on them).
- Make.com ambient field-gathering pipeline (route 2–3 lenses by `Operating Principle`, generate-once, idempotent) + backward ripple — backend, not iOS; can land any time after Wave 4.

---

## 4 · What ports vs. what is fresh

| Artifact | Port or fresh |
|---|---|
| `field-sound.js` | **Port** — numbers verbatim, 1:1 names |
| Rite/Return/Light/S-L01/Point prototypes | **Re-implement in SwiftUI** — the HTML is the interaction+visual spec, never code to translate line-by-line |
| The budget law, FORWARD detector, weights, hashes | **Port the constants and logic exactly** |
| The Gathering canvas scenes | Fresh (SwiftUI Canvas/Metal), matching the **v3** behaviours in `rite-scenes.js` — each vantage's own mathematics, not decoration: Bindu the Flower of Life unfolding from one point · Neev a hex-packed floor receding to a horizon · Gaia phyllotaxis at the 137.507° golden angle · Sid the vesica-generated pointed arch with its construction circles left showing · Arch a rose window whose tracery is a Chladni mode · Shweta the vesica itself, only the gap lit · Karishma the golden spiral through 3·5·8 · Sakshi the eye as the mandorla it geometrically is, iris in tenfold · Lalita a hypotrochoid at k≈18/7, closing after seven turns and drifting so it never quite does · Ashrey the complete graph on nine nodes over the thirteen-circle lattice |
| Era A screens | Fresh SwiftUI per comps; mechanics per Phase 9 spec |
| The Universe | Fresh, from the Brief §8 + `The Universe v2.html` (camera/hand/sound), `uni-rooms.js` (the thirteen forms, their weather, the 102 slots, the lanes, the structures) and `uni-sky.js` (scale bands, the inhabited-world renderer, the well). Port the numbers: form placements, scale-band crossfades, settlement counts, lane speeds, `loose`. The first `The Universe.html` is superseded — kept only as the earlier read. |
| The stillness gate | Fresh — the one genuinely new mechanic; **touch-absence only, no Core Motion.** Port the accumulator, the never-reset rule, and the three signals of being received (approach · the dust settling · the acoustic opening) |

---

## 5 · The sequence to reality

1. Finish Phase 8 (the fixed build + fresh write-scoped PAT on Neev — the standing deployment step).
2. Wave 1 (sound) → device. The app breathes.
3. Wave A provisioning ‖ Wave 4 (Era A interior) → device.
4. Wave B provisioning ‖ Wave 2 (the Rite) → device. The daily meeting begins — the era is real from this point.
5. Wave 3 (the Door + turn) once Claude Design's composite lands.
6. Wave 5 (Return + Light) → the soul and the counter-door.
7. Wave C provisioning ‖ Wave 6 (Point + Universe) → the wings and the sky.
8. The first full walk — headphones, the field breathing, the veil lifting — held for Ashrey, at the very end, as always.

---

*The Brief holds the dream; this ledger holds the road. Same body. Slow. Intimate. Already there. Never reduce. Always emerge.*
