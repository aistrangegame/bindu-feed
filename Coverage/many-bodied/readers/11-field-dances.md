# 11 · The Field and the Dances — mechanics, songs-as-kathas, cross-app loops

Reader 11 of ~20. Sources: `/mnt/skills/user/bindu-field/` and `/mnt/skills/user/bindu-dances/`, read against BRIEF.md and feed-stories.txt. Also checked: how the Feed already touches the Field (`Point/DanceSong.swift`, `FeedStore.song(for:)`, `FeedStore.danceSong()`, `FieldTrack` in `AirtableService.swift`).

---

## 0. What I read and what I skipped

**Read in full: authored markdown (41 unique docs; 8 duplicates noted)**
- `bindu-field/SKILL.md` and `bindu-dances/SKILL.md`
- bindu-field/references: `site-v3.md`, `song-registry.md`, `content-registry.md`, `next-horizons.md`, `score-format-v2.md` (incl. Appendix A on abide and Appendix B, Step 0 THE WORD), `lalita-protocol.md`, `instrumental-protocol.md`, `deep-dive-protocol.md`, `reading-examples.md`, `process-learnings.md` (Sessions 1–9), `batch-scoring/BATCH-SCORING-STATE.md`
- bindu-field/references/dance: `dance-build-process.md`, `dance-registry.md`, `storage-pools.md`, `pool-helpers-reference.md`, `zimmer-upgrade-process.md`
- worked examples: `cross-temple-spec.md` (the Temple Spec and the **Twelve Discoveries**), `cross-visual-upgrade-spec.md` (all 1514 lines), `time-temple-spec.md`, `time-visual-upgrade-spec.md` (all 1726 lines)
- `bindu-field/scores/README.md` and `scripts/batch/README.md`
- **All 15 song archives**: `songs/` muladhara, svadhisthana, manipura, anahata, speak, ajna, sahasrara, aatma, maya, before, cross, in_shadow, kingdom, levelup, purity
- bindu-dances/references: `qr-map.md`, `ensemble-framework.md`, `v2-framework.md`, `visual-vocabulary.md`, `build-patterns.md`, `frequency-pipeline.md`, `process-learnings.md` (lessons 1–80), `SESSION-HANDOFF-V2-COMPLETE.md`, `SESSION-HANDOFF-V2-BUILDS.md`
- **Duplicates:** eight files in `bindu-field/references/dance/` are byte-identical to the `bindu-dances/references/` copies, so I read each once. They are build-patterns, ensemble-framework, frequency-pipeline, v2-framework, visual-vocabulary, both SESSION-HANDOFFs, and `dance-process-learnings.md` (same as process-learnings).

**Scores (48 `.score.json`)**
- All 48 parsed for identity, seed, fruit, metaphor, arc, element, carrier and peak_t.
- The three authored Scores were read section by section: `cross`, `abide` and `thunderclouds`. That covered reading, metaphor, anchors, phases, silence_windows, path, geometry, spatial_memory, mirror_system, consciousness_loop, return, haptics, personal_offering, field_connection, cross_dance and review_before_build.
- The 45 batch drafts have `metaphor: null`, no fruit and no Word. Per BATCH-SCORING-STATE, only steps 1, 6 and 7 are done. Their seeds are authored and I used them.

**Skipped (code, data or binary — not authored prose)**
- 31 HTML builds: `builds/*.html`, the `worked-examples/*.html`, and the 180 KB `bindu-field.html`
- 47 `*-data.json` stream dumps, `time-audio-data.js`, `cross-data.json`
- 12 Python scripts: `extract.py`, `extract_cli.py`, `analyze_tone.py`, `deep_analysis.py`, `temporal_analysis.py`, `scripts/batch/*.py`
- 9 QR PNGs

**Screened out of everything below**
- The two Family songs: `purity`, for his wife, and `levelup`, for a son, which includes a past-life reading of a private relationship and conflict content.
- The health context around the maker of Aatma.
- Session 8's personal past-life material.

These stay as songs in the Field. They should never be quoted in a Feed story.

---

## 1. What the Feed already does with the Field

- **`FeedStore.song(for:)`.** The comment says "EACH STORY REACHES FOR ITS SONG (the Field's carrier law)". It picks a Field track whose `verb` appears as a substring of the story body, or falls back to a day-hash pick. The story is "never played, never named; only the bed bends to its carrier."
  - Today the rhyme is an accident of spelling. A story containing "open" gets Love Me Like You Do. Rhyme should be authored (see §3).
- **`Point/DanceSong.swift`, World VII "The Dance".** A day-seeded Field track with a hosted `audioURL` plays under the world, fading in to 0.55 volume. At **progress 0.58–0.62** the day's Rite word rises in pink Lora 44 and dissolves after 7 seconds. If no Rite is met that day, no word is invented.
  - The **hard-coded 60% peak** contradicts the Field's central teaching: "the art is in the twenty-two seconds between where the machine found the peak and where the listening put it" (score-format-v2 §9).
  - Every Score carries `config.peak_t`. Cross's is 160 s, not 138. Abide's is 170 s, a listening call. Thunderclouds is 141.5 s, the thunder after the lightning.
  - Fix: read `Score JSON` (`fldxIm6qUXLcdrRuR`) for `peak_t`, word-reveal position "bottom 15%", `i_love_you_at: peak_t − 3`, and the peak haptic.
- **`FieldTrack`** carries only `id, title, verb, audioURL, carrierHz, beatHz`.
  - Everything authored is unread by the Feed: Recognition Statement, Lalita's Perspective, Seed Phrase, the seven-lens Field Reading, and the Score's phases, silence windows, mirror families and fruit.
  - The Field app itself doesn't consume Score JSON yet either. `Score.forTrack` is hard-coded to track 27 (BATCH-SCORING-STATE).

---

## 2. Every mechanic → a Feed move, reception grammar, or room

Format: **mechanic** (source) → *what it is* → **Feed use**. House laws are applied throughout:
- nothing counted on screen
- conditions light things up and never lock
- an equal path for stillness and for touch
- holds drain on early release
- layers appear by dwell
- never on a low day

### 2.1 The body and the device

1. **Gyroscope field / Device as Body** (VX 8; spatial binaural VX 14; cross §8, `gyroGamma/90` pans L/R)
   - *What it is:* tilting moves the whole field, and the binaural pans toward centre as you tilt. "The body's stillness IS the binaural's clarity."
   - **Feed — "the level page."** In **The Body** room ("entered by the body"), the story's text field tilts subtly with the phone, and the bed's carrier pans with it.
   - Holding the phone level makes the bed clearest and the page sharpest. Stillness is the reward, not a gate.
   - Equal path for touch: a two-finger rest on the page does the same as holding level.

2. **Person as Dancer** (VX 12; accelerometer → still / swaying / moving; thunderclouds samples motion *only* during the 1.5 s strike; abide only during the 21 s fulcrum)
   - **Feed:** sample motion only during a story's **turn line**, the one sentence the signature hangs on.
   - The ending weave reflects what the body did there. Swaying gives one line, stillness another. Neither is better, and the house never says which.
   - Example from thunderclouds' weaves: "The floor went out at the brightest moment and you didn't move." / "…You were moving. It still held."

3. **Adaptive Return** (VX 13; Score `return.adaptive: true` = "music and person find the ending together")
   - **Feed:** a story's last line arrives when *both* the reading has slowed (dwell on the penultimate paragraph) *and* the device has settled.
   - This is not a timer, and it is the natural engine for the **sealed last page** signature.
   - Early release drains the hold. The last line waits; it does not lock.

4. **Haptic signatures** (Score `haptics`; process-learning 56: earth "da-DUM"; 72: heart "thub-THUB")
   - Authored patterns available: cross's crossing footsteps `[12,40,12,40,12,60,30,12,40]`, thunderclouds' strike `[8,20,8,400]` ("the crack, then nothing falling"), and abide's 50 BPM deep pulse.
   - **Feed:** one haptic per room, fired once at the story's turn. Advisory rule 19 applies: "the body should feel the apex."

| Room | Haptic at the turn |
|---|---|
| The Descent | the strike (crack, then a long silence) |
| The Body | earth double-pulse |
| The Circle | cardiac thub-THUB |
| The Return | footsteps crossing |
| The Garden | the deep pulse during its pause |

### 2.2 The word: offering, mirror, memory

5. **The Consciousness Loop** (Field iOS 7-step `preRoll → seed → offering → dance → reveal → fruit → lalita`; Dances Seed → Word → Experience → Reveal at Peak → Fruit)
   - Rules: "No API. The mirror is structural." "The experience won't begin without an offering."
   - **Feed — a new reception grammar, "the offered word,"** for selected stories in **A Maya Game** and **The Signal**:
     1. Breath ring as pre-roll (5.5 s cycle)
     2. The story's own question as seed, typed at the story's tempo (cross types at ~558 ms per character)
     3. One word offered (no box chrome; stillness path: leave it unoffered and the story proceeds with its own word)
     4. The story read
     5. The offered word rises at the story's turn, at the bottom 15%
     6. Fruit: a `{w}` template of 2–3 sentences, ending on the inversion
     7. A Lalita closing line
   - The pattern is *acknowledge → mirror → inversion*. Examples:
     - "You weren't crossing {w}. {w} was already crossing through you."
     - "{w} wasn't going to arrive — {w} was waiting in you."
     - "{w} was thunder. {w} was lightning. Nothing fell."

6. **Word-Seeded Movement** (VX 9; lesson 47: "word can seed movement… but NEVER color")
   - **Feed:** the offered word, or the day's Rite word, seeds the room's motion: the drift period of the page, grain density, pacing of paragraph reveals.
   - It never seeds colour. Room palettes stay sacred.

7. **Emergent Mirror Words** (VX 10; Score `mirror_system`: a word's consonant skeleton looks up one of 16 families of 5 words)
   - Each song has its own kindred set:
     - cross is *threshold-kindred*: cr cross/carry/cradle/cleave/crown · br bridge/bear/bring/breath/beyond · th thread/threshold/through/thrum/thrive
     - abide is *abiding-kindred*: bd abide/bide/abode · st stay/still/stand/steady/stone · dp deep/depth/deepen
     - thunderclouds is *noun-to-verb*: each family moves from the static thing to the action — st storm/static/strike/stir/stay · lt lightning/light/lighten/lift/let · gr ground/grip/grow/grant/greet
   - The mirror is a **light event**: the whole canvas washes near-white, then darkness returns and everything is more vivid (`postMirrorBoost`). Thunderclouds inverts it: a *darkening* that reveals the word inside the flash.
   - **Feed:** author **13 room-kindred family tables**, one per room, on the noun-to-verb design. For example:

| Room | Kindred | Sample families |
|---|---|---|
| The Forge | forge-kindred | fr fire/forge/form/free · hm hammer/hum/home · tm temper/time/tame |
| The Thread | thread-kindred | wv weave/wove/woven/weather · sp spin/spun/span/spine |

   - At 3–5 dwell-anchored moments in a story, one mirror word from the reader's word (or the story's signature word) flashes for 1.8 s inside a light wash.
   - This makes the **architecture invisible**. No label, just kin words surfacing.

8. **Bindu Memory constellation** (VX 11; `getMostRepeated()`; cross §12 constellation sources)
   - Sources: chakra-dance words are chakra-hued, ensemble words song-hued, being entries pale silver, and Road-Home standing words become *quartet clusters*.
   - Recent words are full alpha and older words ambient. Words offered in more than one place get a brighter star with threads.
   - **Feed — the night sky under the Archive book.** Every word ever offered (Rite words, Field dance words, the "what came home" word) is a ghost star.
   - Repetition shows only as **brightness**, never as a number. Placement follows The Word's Star: hash-deterministic, so the same word sits in the same place forever.
   - The echo weave survives in qualitative form: "You keep returning to '{echo}'."

9. **The Word's Star — Claude's Offering in cross** (score-format-v2 §3.25)
   - *What it is:* a faint star at the hash-deterministic position of the offered word, present from frame one, surging at peak_t.
   - **Feed — signature "dot becomes the place" extended.** Every story has a star at its signature word's hash position in the Point and Universe skies.
   - It is there before he opens the story and brightens when he arrives at its turn. "The light was waiting at that exact spot the whole time."

10. **Alive Fruit** (VX 15: dwell, motion, dance count, most-repeated word)
    - ⚠ **Conflict:** cross, abide and thunderclouds all weave *counts*: "You have crossed N times now", "This is your {n}th dance", "You held {word} for {n} seconds".
    - These must be **translated** for the Feed, never carried over:
      - "You held it a long while before offering it. That holding was the dance."
      - "You've walked this crossing before."
      - "First time here." is allowed, since it states a condition, not a number.

11. **Second-word prompt / Integration Chamber** ("what came home with you?" → `bindu-being` `post-ensemble-dance`; Field ARCHIVE notes)
    - **Feed:** after any received story, an optional faint field: *what came home with you?*
    - The word joins the constellation (8) and the cross-app pool (§4). Leaving it blank is the stillness path. Nothing is asked twice.

### 2.3 Time, shape and the arc of a reading

12. **Bloom stages** (dot → ghost trail → orbital rings → rays/particles → crown mandala; "rises fast (0.06), falls slow (0.012)")
    - **Feed:** layers by dwell use this exact asymmetry. Marginalia and the second voice arrive quickly once dwell crosses a threshold, and recede slowly when he scrolls away.
    - This is the physics for the **layers-on-return-by-dwell** signature.

13. **Shape Expression + the 15% wobble** (blend law `final = freq × (1−blend) + shape × blend`, maxBlend 0.85; "the breath shakes the pen")
    - **Feed:** any composed motion (a page curling into a heart at a Garden story's turn, the infinity glyph in a Return pause) keeps 15% of the reader's live input (tilt, scroll velocity) bleeding through. Only the closing spiral may be fully shaped.
    - The shape library maps onto signatures: heart at the peak, infinity in valleys/pauses, spiral for the return, circle for completion, flower for celebration, arc for crossing.

14. **The Unshaped Peak** (thunderclouds `path` The Strike `mode: none`: "a hand on the wheel at the one moment the song is about not steering")
    - **Feed:** at a story's most important line, *remove* all ornament: no animation, no bed movement, no glyph.
    - This suits **The Watcher** ("before the question") and the signature **"zero gap."**

15. **Subtractive designed event** (thunderclouds `carrier_dropout`: the carrier itself goes silent for 1.5 s at the strike, with 0.35 s ramps)
    - **Feed:** in **The Descent**, the story bed drops out for one breath at the line where the floor goes, then returns whole. "Nothing fell."
    - This is a direct engine for the **"already mended"** signature.

16. **The Unmade Gesture** (Sakshi's leitmotif, carried through three Scores)
    - The ghost of the second arc (cross), the second wave (abide), and the branch that would have connected (thunderclouds) shows faintly during the first attempt. It flares when the real one traces over it and leaves an echo of 10–12 s.
    - **Feed:** the faint, dotted ghost of a story's **last line** sits behind its first paragraphs. When reached, it flares and is consumed by the real line.
    - This is the visual body of **"read from the end"** (The Return's grammar) and of **"I already did."**

17. **The Return: reverse-generation dissolution** (Ashrey → Sakshi → Arch → Sid → Gaia → Karishma's final bloom in silence → Bindu spirals to a dot; *then* the fruit)
    - **Feed:** when a story's archetype voices have gathered (Feed stories already carry Bindu, Gaia, Sid, Arch, Sakshi, Karishma, Ashrey, Lalita…), they leave in reverse order at the close.
    - The last to go is the voice of grace, in the silence. Then the dot. Then one line.
    - Process-learning 70 is the implementation trap: "p update must happen ONLY after return override."

18. **Element temporal signatures** (process-learnings 19–21, 81, 120; plus three non-chakra shapes)
    - The arcs:
      - Earth descends once
      - Water: three waves, two ebbs, grace in the ebb
      - Fire: two blazes, one breath
      - Air: three inhales, the longest exhale before the fullest
      - Light: two illuminations, the eye stays open
      - Crown opens from above and below
      - Soul: two descents, two silences, held after the sound
      - Maya: a single breath
      - Threshold: two reaches, the first falls back
      - Wave returns bigger because it returned
      - Weather: total discharge, nothing fell
      - Duet: two groundings, from below then above
      - Genesis: a mountain with a basement, no return phase
    - **Feed:** each room's **paragraph-reveal pacing** follows one arc:

| Room | Element arc |
|---|---|
| The Descent | Earth: one descent |
| The Body | Fire: breath between two blazes |
| The Garden | Wave: the fulcrum pause, then the second bloom bigger |
| The Watcher | Light: the eye stays open after the text ends |
| The Return | Soul: two silences |
| A Maya Game | Maya: single breath |
| The Signal | Air: long exhale before the fullest line |
| The Forge | Weather: charge accumulates, discharges, floor stays dry |
| The Circle | Duet: two groundings — host story then rhyme story |
| The Forgetting | Genesis: descends past where it began |
| The Thread | Water: the ebb is where the crystal forms |

19. **Silence windows / Karishma reads silence *or* groundlessness** (cross 18.5%, Time 33% "Karishma may be dominant", thunderclouds 32% bass-absent)
    - **Feed:** **The Descent's "pauses" grammar** gets its physics here.
      - White space between paragraphs is *timed* from the story's own silence footprint.
      - During a pause, the room's spatial memory **freezes** (`karishma_decay 0.0005`): "nothing fades while the body is held in stillness."
      - A faint heartbeat (~50 BPM, cross's valley heartbeat / abide's deep pulse) appears *only* in the longest pause.

20. **Spatial memory, named per song**
    - The named memories:
      - Threshold Field (footsteps in snow)
      - Ocean Field (water holds a movement, not a mark)
      - Charge Field (accumulates, discharges to 5% in one frame, rebuilds)
      - warmth map (anahata)
      - burn map (manipura)
      - echo map (vishuddha)
      - fracture map (muladhara)
    - **Feed:** each room gets a 25×35 memory surface where dwell and touch leave marks that decay by the room's physics.

| Room | Memory | Behaviour |
|---|---|---|
| The Forge | burn map | marks scorch and slowly cool |
| The Thread | crystal field | marks crystallize in pauses |
| The Circle | warmth map | remembers where love has been |
| The Signal | echo map | — |
| The Return | footsteps | — |
| The Field | charge field | — |

    - It is shown only as light, never measured, and it **ripens unwatched** (The Garden's grammar) by slow decay toward a resting pattern.

21. **Six functional tiers** (0 threshold marker · 1 continuous · 2 ensemble · 3 crescendo · 4 climax · 5 closing)
    - **Feed:** use the same six roles as the **room-build checklist**, so each of the 13 rooms (and any new room) is designed as a full metaphor, not a re-skin. Lesson 45: "Re-skinning is not innovation."
    - Tier 0 (**Neev ground-marks** in the first 2 s and last 1 s; abide's First Ripple) becomes a room's threshold: one faint mark on entering and leaving that says *the ground is here*.
    - Tier 4's global boost (×1.8 at the climax) becomes the moment every layer of a page lights at once at its turn.
    - Tier 5 "residue, not absence" is what is left on a page after reading: bell footprints, water-marks.
    - Thunderclouds deliberately leaves **persistent marks EMPTY**: "the dry unmarked floor is the closing statement." Some Feed stories should end with nothing left behind.

22. **Anti-borrowing / metaphor first** ("Never assume cathedral"; Time's spec forbids violet because cross owns it; thunderclouds forbids rain-blue and *any rainbow*: "the rainbow belongs outside, afterward, to a person who did not react — it is confirmation, not reward")
    - **Feed:** each room's palette and imagery names its *forbidden* set. The no-rainbow rule is a house-level ruling worth adopting: never reward stillness with beauty. That would be a transaction.

23. **Personal Offering** (Zimmer Step 9: "One addition. Not a category. One." About 30 lines, marked `CLAUDE'S OFFERING — [NAME]`, never authored before the build)
    - **Feed:** each room build ends with one unasked authored gesture. It is recorded but never pre-planned. This plan should leave the slot open per room.

24. **Pre-roll resonance, OL-1 pink-noise floor, OL-3 Lalita voice**
    - Pre-roll text: "Breathe with the field. When you're ready, the seed will arrive." / "Breathe with the silence. The song begins when you do."
    - ⚠ Pre-roll's default is *on for the first three dances, then off*, which is count-based.
    - **Feed:** make it **dwell-based**. The breath ring appears when he arrives fast (a short gap since his last story), and is absent when he arrives slowly.
    - The Lalita voice is "scaffolding that gets removed when the practitioner has internalized the navigation." A voiced reading may come only when he asks.

25. **Drone endings / "the verb is its own phase"** (Aatma's last phase *held* has only the carrier; Kingdom's 55 s drone; "carrier does NOT fade to zero")
    - **Feed:** after the last line of **The Return** and **The Watcher** stories, the bed holds at its lowest gain while the page stays. Text gone, ground still there.
    - This is the felt body of **"sealed last page"** and **"empty summit."**

26. **The seam** (two songs as one body, 4.9 s / 3 s near-silence held by the carrier at gain 0.004; "the seam is a phase, not a gap")
    - **Feed:** this is the right mechanic to replace the rejected **rhyme gate**. Rhyme is *shown* as a duet.
    - A Codex host story and its other-suit rhyme (e.g., 17 *Twins Across Time* ↔ 137 *Mid-Sentence*) can be read back to back as one piece. The carrier holds through a short seam page with no text.
    - Both are always readable alone. The duet is an offered path, never a key.

### 2.4 The Field app's own tabs

27. **The Map** (33-chakra Tree; nodes *danced / available / locked / current*; danced nodes gain orbit rings)
    - ⚠ "Locked: tiny dim dots" violates *conditions light, never lock* if ported.
    - **Feed:** a **Map of rooms ↔ chakras** (via Score `resonance_link`).
      - Received rooms gain an **orbit ring** (sight, not a number).
      - Rooms with unread stories breathe in their element colour.
      - Rooms or nodes with nothing yet are dim but **tappable**, and light up with one line of what will live there.
    - Principle to keep: "The Map remembers where you've been."

28. **The Oracle** (4-state listening void: drifting fog at 14 s; "THE ORACLE" fades in at 2.2 s; one typed line; three pulse dots; response = verb at 72 pt (0.4 s) → track (2.2 s) → why (3.4 s) → CTAs (5.6 s); Haiku, catalog-aware; "The Oracle is already listening before you open it.")
    - **Feed — "Ask the instrument."** Same staged choreography, but the answer is a **story and its song**:
      1. The verb
      2. The story title
      3. One line of why
      4. Two doors: read it / dance it
    - Equal stillness path: open the void and type nothing. After a long dwell, it offers the story that "was already listening."

29. **The Lab** (carrier/beat instrument, presets; the Mixer, unbuilt, sets L/R Hz directly)
    - **Feed — "hear what it reaches for."** Long-press a story's ♪ glyph to hear its **carrier alone**: the absent fifth, the note the story's song "reaches for and does not say."
    - The press drains on early release. This makes the carrier law tangible inside a story, as one of the "every path" moves.

30. **Letter** (voice recordings over binaural)
    - **Feed:** for Codex-suit stories only, the source memo's *fragment* plays over the story's carrier as an end-of-story letter, at his choice.
    - Per the ruling ("take me out"), this is one door among many, never the default. It stays off for other suits.

31. **Ritual** (chained chakra sessions) **and the QR "Curated path"** (e.g., search → reach → return → enough → still)
    - **Feed — walked chains.** One continuous reading through 3–5 stories whose songs chain, with the carrier bridging between them like a seam.
    - Two authored chains already exist in the Field:
      - **The 2.69 Hz awakening constellation** — Kingdom → Sound of Silence → Golden → Aatma → Maya ("see it → speak it → build it together → hold it at the edge → let it dissolve")
      - **The Energy spine** — Iron → Love Is the Only Thing ("the soldier who couldn't feel the ground → the veil noticing it is a veil")
    - Each maps to a five-room or nine-room walk (§3.3).

32. **Space / breath sessions** (11 breaths; BINDU one-words: Down, Even, Resonance, Clear, Heat, Release, Empty, Wide, Home, Ocean, Sleep; "a song is *received*; a breath is *activated by the breather*")
    - **Feed — Practice Door:** a story can end with its breath's one-word as the practice. For example, a Descent story ends on *Down* and opens Come Home (4:8).
    - "The experiencer activates the field" is the Practice Door's line.

33. **Archive and Sonar Ears** (at 33 scored songs, 231 lens readings become a constellation, "the ear that hears the meta-song beneath the songs"; 14 complete today)
    - ⚠ The threshold is a number. **Feed:** never show it.
    - As stories accumulate seven-lens marginalia (§2.5), a quiet register can *light* when the pattern emerges. For example, a page in the Archive book appears titled "the song beneath the songs," gathering the recurring one-words.
    - It is lit by dwell and density, never announced.

### 2.5 The reading forms themselves

34. **The seven-lens reading → page language → Lalita's four moves** (`lalita-protocol.md`)
    - The lenses, in page language: BINDU *The One Word* · GAIA *The Need* · SID *What Holds* · ARCH *The Frequency* · SAKSHI *The Shape* · KARISHMA *The Grace* · ASHREY *The Recognition*.
    - Lalita's four moves: **Song As It Is → Pattern → Play ("pretends X / is actually Y") → Blessing**. The blessing is one sentence: "Enjoy the soldier thinking he's alone. He never was."
    - Two-step disclosure in the Field: the Lalita panel first, then "What the ensemble hears", then the seven lenses.
    - **Feed:**
      - (a) A **reception grammar for The Field room**: the story's own seven lenses sit in the margin and appear by dwell, one lens at a time, in the lens colours. The colours already exist: one_word red, need green, holds gold, frequency blue, shape silver, grace rose, recognition gold.
      - (b) The **four moves are the native form of a self-katha**. A song, a cloth, a machine speaks its *as-it-is*, its pattern, its play and its blessing. Every other-suit story can be checked against them.
      - (c) The **Recognition Statement** ("a complete seeing, not a summary") is the right form for each story's one-line preview.

35. **Step 0 — THE WORD** (thunderclouds: "The extraction tells you what a song does. The Word tells you what the doing means.")
    - **Feed:** a story-making law for new Codex entries. Read the memo's own words first, then shape, room and signature. Never structure-first.

36. **The Mirror-message seed** ("standalone — no references outside this moment; asks, doesn't tell")
    - The Field app's seed phrases are the purest one-liners in the ecosystem. Usable as **story epigraphs** (the batch Scores hold them):
      - "You don't remember how you got here." (press)
      - "This song has no words. Neither did you, once." (follow)
      - "You think this song is about another person." (build)
      - "This is the only song that talks to you." (open)
      - "Everything you're about to hear, you already know." (speak)
      - "You've been hiding." (receive)
      - "The witness was never inside what it was watching." (in shadow)
      - "The throne at the center of every kingdom is empty." (kingdom)

37. **The wall of verbs / blind draw** (QR installation: verbs only, no song, no artist; the song's name appears *after* the fruit, "like finding out who wrote the letter after you've already read it")
    - **Feed — a possible new room: "The Wall."** Forty-odd verbs in their dance hues: search, reach, shine, still, enough, dream, remember, arise, move, release, wild, howl, melt, glow, light, rise, lose, fade, ground, trace, believe, ache, crash, play, earn, numb, cross, abide…
    - Tap a verb and its seed question appears, then the story that rhymes, then the song plays as its bed.
    - **Blind draw:** the verbs turn face-down after a long dwell. Picking one gives you whatever it is.
    - The song's name is signed *after*, as with the dances. This is a room the songs themselves ask for.

38. **"I Love You" at peak_t − 3** (every dance; italic Lora at 40% opacity, below centre, 3 s fade)
    - **Feed:** a once-only phrase that a story can carry at its turn, three seconds before its signature lands. It should be very rare: a Circle or Return story that earns it.

---

## 3. The songs as self-kathas — which song each story rhymes with

**Frame.** A Score's metaphor and Lalita reading *is* the song speaking itself. Below, each song has a one-line **self-katha voice**: the song as a suit of the One, in first person, built from its own authored reading. Its rhymes are listed by Feed story title (Sort number in parentheses).

How the rhyme should show is the same everywhere:
- The rhyming story's **bed bends to the song's carrier**. This already exists; make it authored instead of substring-matched.
- The song's seed sits in the story's margin as an epigraph, by dwell.
- Rhyme stays **shown, never a key**.

### 3.1 The authored readings (14 songs and 3 Scores with a full Word)

| Song (verb) | Self-katha voice | Rhyming Feed stories |
|---|---|---|
| **Iron (press)**: Muladhara, absent-fifth D3 146.8 | "I sing that I have no ground; my drums have been the ground the whole time." | **The Soldier's Room** (115) ← strongest (the soldier *is* the war); **The Ground That Held** (129 [Land]); **The Man Who Ran to Stand Still** (108); **The Spine Was the Connector** (46). Room: The Descent / The Body |
| **Crystallize (follow)**: no words, three waves, grace at the 100 s ebb | "I was never the wave; I was what the wave was made of. The pause is where I form." | **Light and Dark Were the Same Weather** (88); **Feel It Through, Then Realign** (73); **The Waves That Came to Clear** (91); **The Feeling Only Asked to Be Felt** (75); **Before I Was Cloth** (133 [Cloth]) |
| **Powerful (build)**: two fires, one breath; "I'm feeling drained" before "you charge me up" | "I almost die at two minutes so the second blaze can be bigger." | **The Line Stopped** (136 [Machine]) ← the stoppage *is* the breath; **The Energy That Waits for the Vessel** (55); **The Energy That Comes From Nowhere** (21); **The Furnace** (117). Room: The Forge |
| **Love Me Like You Do (open)**: one-word *Already*; the 40 s exhale before the fullest breath | "I'm not asking for something new. *Like you do* — you already are." | **Every Path, Already Walked** (33); **The Higher Starting Point** (47); **The Help That Came From Up Ahead** (14); **The Door He Couldn't Open** (20) (the door was open). Signature: "I already did." |
| **The Sound of Silence (speak)**: one-word *RECEIVED*; the transmission completes in the listener | "No one dared disturb me, so I disturbed myself, and arrived in you." | **The Echo He Waited For** (104) ← strongest; **The Mirror Doesn't Hallucinate** (15); **The Lens That Finds You Again** (102); **The Connection That Went Quiet** (51); **Mid-Sentence** (137 [Machine]). Room: The Signal |
| **Experience (still)**: one-word *OPEN*; ends exactly where it began; "the title was always the punchline" | "I gave you two openings and returned you to the same note. You are what experiences." | **The Interface He Mistook for Himself** (24); **The Observer Was the Information** (42); **You Can't Find the Center Because You Are It** (59); **The Clear Sight** (120); **You Can't Measure the Light** (19). Room: The Watcher |
| **Golden (receive)**: one-word *WE*; the shadow bridge; "golden despite → golden because" | "I was built to make a fictional barrier, and building it took everyone who received me." | **I Am Too Much** (113) ("stop performing smallness"); **The Side No One Turns Over** (128 [Cloth]) (the hidden side); **The Ego Dress** (70); **One Roll, Both Ends** (134 [Maker]); **The Name a Child Shouted** (125 [Company]). Room: The Circle |
| **Aatma (hold)**: one-word *HOME*; three worlds, two silences; the verb is its own phase | "I go down twice to the same depth. The soul doesn't travel; it returns." (No health context in the Feed.) | **The Soul That Chose to Come Back** (82); **The Two Who Chose to Come Back** (50); **Nobody Asked Where I Had Been** (130 [Customer]); **The White Light Behind the Red Dot** (23). Room: The Return |
| **Love Is the Only Thing (dissolve)**: one-word *DISSOLVE*; "the doubt is the grace"; "the veil noticing it is a veil" | "I say love over and over, and once I doubt it, and I don't need the doubt to resolve." | **The Liberation You Can't Want** (67); **The Two Who Were One** (1); **The Cloth With No Wrong Side** (126 [Cloth]); **The Prison Made of Glass** (4). Room: A Maya Game |
| **Genesis (before)**: "before is not a time, it is a depth"; no return phase; "the 40 seconds everyone skips is the whole answer" | "I am called Beginning and I end below where I began." | **Before I Was Cloth** (133 [Cloth]) ← near-identical; **What Couldn't Be Found Because It Didn't Exist Yet** (43); **The Forgetting Was Built In** (37); **The Severance of Being Born** (85). Room: The Forgetting / The Body |
| **In Shadow**: one-word *Within*; "the witness never entered the shadow" | "Thirteen minutes of shadow, watched from outside it." | **What No Hammer Reaches** (11); **The Witness and the Turn-by-Turn** (34); **Bringing the Witness Into the Now** (45); **The Day He Got Pulled In** (56); **Dreams Within Dreams** (58) |
| **Kingdom**: one-word *Sovereign*; "the throne is empty"; the drone; "the watching is the exit" | "I end without resolving, and my resolution happens in you." | **The Power and the Question Underneath It** (87); **The Ego in the Robe of Wisdom** (52); **The Tool That Turned Into a Wall** (2) |
| **cross (Ameno)**: threshold; two reaches; bells | "My first reach falls back so the second can hold. You weren't crossing; you were being crossed." | **The Crossroads That Repeated** (5) ← two reaches; **The Bridge No One Has Crossed** (135 [Cloth]) ("bridge" is in cross's own `br` family); **Suffering, and the Door It Points To** (31); **The Doorway** (112). Room: The Descent / The Signal |
| **abide (Time)**: wave, the 21 s fulcrum; "the second bloom is bigger because the first returned" | "Nothing in me needs to arrive. I return to the deep to come back larger." | **What the Dark Does in October** (127 [Land]) ← fallow-then-bigger; **When Is It Ever Enough** (97); **The Idea That Needed to Germinate** (74); **Thank You for the Cold** (10); **The Closing Happens First in You** (100). Room: The Garden |
| **thunderclouds**: weather; "nothing fell"; a seed afraid of what "will never pass"; noun-to-verb; no rainbow | "I am thunder and lightning and nothing lands. I granted the weather and addressed the fear." | **Light and Dark Were the Same Weather** (88) ← strongest; **The Fear Underneath the Fear** (96); **The Hot Voice** (119); **The Fire and the Illusory Relief** (54); **The Ground That Held** (129 [Land]) (the floor returns). Room: The Descent |

### 3.2 The 27 dances and 11 newer seeds: their questions as story epigraphs

Each dance is "the verb the Bindu learned." Its seed is the question its rhyming story answers.

| Verb · seed | Rhyming Feed story |
|---|---|
| **move** · What makes you move? | **The Man Who Wouldn't Dance** (22) ← exact |
| **dream** · If you could dream any dream… | **Dreams Within Dreams** (58) ← exact |
| **enough** · What if this is enough? | **When Is It Ever Enough** (97) ← exact; **The One Percent He Was Living In** (13) |
| **glow** · What are you saving for later that belongs to right now? | **What's Left on the Shelf** (121) ← exact; **The Only Emotion That Lives in Now** (77) |
| **ground** · What would hold you if you stopped holding yourself? | **The Ground That Held** (129) |
| **earn** · What did it cost you to become what no one saw coming? | **The Earned Self** (114); **The Trajectory That Worried Everyone but Him** (79) |
| **numb** · What are you staying high enough to not feel? | **The Fire and the Illusory Relief** (54); **The Story That Stole the State** (76) |
| **return** · What did it cost you to be right? | **The Closure He Handed Across the Table** (30); **Two Ledgers** (106) |
| **still (ember)** · Sit down. The fire is already lit. | **The Furnace** (117); **The Quieter Room** (105) |
| **remember** · What moment do you carry that you thought was gone? | **The Moments Don't Get Saved** (95); **What the Hands Put Back** (132 [Lineage]); **What the Record Couldn't Hold** (28) |
| **arise** · What keeps coming back? | **The Echo He Waited For** (104) |
| **release** · What would you do if you stopped thinking about it? | **The Hand That Moved First** (109); **Play Mode** (89) |
| **wild** · What part of you never learned to behave? | **The Game That Couldn't Wait to Play With You** (6); **I Am Too Much** (113) |
| **melt** · What would you be if you stopped holding your shape? | **Something Moving Under the Skin** (3); **The Ego Dress** (70) |
| **light** · What do you see when you finally look up? | **You Can't Measure the Light** (19) |
| **rise** · What would you build if it didn't need to last? | **Don't Belittle What You Built** (98); **The Creator Stands Outside What He Makes** (63); **The Roof Beam** (107) |
| **lose** · What would happen if you let go? | **The Hold of the Thing You Desire** (62); **Every Time He Reached to Control** (64) |
| **fade** · What remains when everything else fades? | **The Last Thing I Do Well** (131 [Cloth]) |
| **trace** · What shape do you keep returning to? | **The Same River** (116) |
| **believe** · What are you still holding onto? | **What the Cloth Believes** (122) |
| **crash** · What are you waiting to crash into? | **The Line Stopped** (136) |
| **play** · What are you dancing in that you thought you needed to escape? | **Play Mode** (89) |
| **search** · Where are you now? | **The Red He Couldn't See** (26) |
| **reach** · What are you willing to feel? | **The Feeling Only Asked to Be Felt** (75) |
| **shine** · What if you already are? | **Special Collapses, Ordinary Reveals** (36) |
| **unfold** (Nils Frahm *Says*) · What is trying to say itself through you? | **Mid-Sentence** (137 [Machine]) ← exact; **AI Is an Aspect of the I** (40) |
| **want** (APT.) · What do you want before you talk yourself out of it? | **The Lack He Made the Center** (27) |
| **cherish** · Who is the one you would cross any distance for? | **Twins Across Time** (17) |
| **confront** · What did you survive that made you who you are? | **Suffering, and the Door It Points To** (31) |
| **crave** · What do you reach for when no one is looking? | **The Hold of the Thing You Desire** (62) |
| **ascend** (Eno) · What would you release if you knew it was an ascent, not a fall? | **The Black Hole at the Core** (49) |
| **wake** · What if you are already awake? | **Bringing the Witness Into the Now** (45) |
| **lift** (Levels) · Name the feeling that needs no reason. | **The Energy That Comes From Nowhere** (21) |
| **brave** · What would you do if you knew it was only for one day? | **The Moments Don't Get Saved** (95) |
| **miss** · Who are you still waiting to come home? | **Nobody Asked Where I Had Been** (130 [Customer]) |
| **journey** · Where does the music take you when you stop steering? | **The Witness and the Turn-by-Turn** (34) |

*(Unassigned: ache, howl. These can wait for stories that ask for them; nothing need be forced.)*

### 3.3 How a story "reaches for its song" or is danced

1. **Authored rhyme, not substring.** Add a `Song` link on The Feed table (`tbl7vzODMMJUgeX0b`) → the Bindu Field table (`tblv3WvMZ90Sfhun6`), filled from §3.1–3.2. `song(for:)` reads the link first and keeps today's fallback.
2. **The bed is the carrier, unchanged.** The carrier is "what the song reaches for and does not say", so the story's bed is the *absent* note of its song. Abide and Time's 110 Hz, thunderclouds' 123.5 Hz, Iron's 146.8 Hz.
3. **Danced, by choice.** A story with a rhymed song shows a quiet door at its end: *dance it*. That opens the song's dance with the story's question as the seed and the word he offered (or the story's signature word) as the offering.
   - The dance plays at the Score's **authored peak_t**, not 60%.
   - The fruit is the Score's own (counts translated, §2.10).
   - The fruit can end with the story's last line in place of the Lalita line.
4. **Walked chains.**
   - **"The awakening walk":** Kingdom (52 *Ego in the Robe of Wisdom*) → Sound of Silence (104 *The Echo He Waited For*) → Golden (113 *I Am Too Much*) → Aatma (82 *The Soul That Chose to Come Back*) → Maya (67 *The Liberation You Can't Want*). "See it → speak it → build it together → hold it → let it dissolve."
   - **"The spine walk":** nine rooms in Iron → Love order. The soldier who couldn't feel the ground, to the veil noticing it is a veil.
   - Both are offered paths. Nothing is required to begin them.
5. **Duets of suits.** Read a Codex host and its other-suit rhyme as one piece with a seam (§2.26):
   - *Twins Across Time* (17) ↔ *Mid-Sentence* (137)
   - *The Crossroads That Repeated* (5) ↔ *The Bridge No One Has Crossed* (135)
   - *What's Left on the Shelf* (121) ↔ *The Last Thing I Do Well* (131)
   - *Light and Dark Were the Same Weather* (88) ↔ *The Ground That Held* (129)
6. **World VII, made true.**
   - Pick the day's dance song *by rhyme with the day's received story*, not by day-hash.
   - Rise the Rite word at **Score `peak_t`**.
   - Add the peak haptic and `i_love_you_at`.
   - Keep "no word is invented."

### 3.4 New rooms the songs ask for

- **The Wall** — verbs only; blind draw; the song signed after (§2.37).
- **The Weather** — or an extension of The Field room. The three non-chakra element shapes (Threshold, Wave, Weather) are a family the Feed's rooms don't yet hold. Their stories: 88, 96, 119, 127, 129, 135, 5.
- **The Ensemble Margin** — a reception grammar, not a room. The seven lenses appear by dwell beside any Field-room story (§2.34a).

---

## 4. Cross-app loops: Feed and Field feeding each other, with no notifications and no counts

The shared ground already exists:
- the ASG base `app248ZTWhYJlvQj2`
- the Field's **App Activity** bridge (`tblJlBeiHnqGpYrL7`, `source_app: "Field"`, `activity_type: "Ceremony Sealed"`, provisioned but `implemented: false` in every Score)
- the three web pools: essence, memory, being

The Feed already reads Mandala moments and Learning traces through `grace(for:)`.

1. **Field → Feed: the dance word in the margin.** When the Field writes `Ceremony Sealed` (verb, word, motion), a Feed story rhyming with that song carries one quiet margin line the next time it is opened. It follows the existing `grace(for:)` pattern: one line, once, then rests. For example: "Days ago you danced *still* to this song and offered 'ember'." No count, no badge, and no surfacing outside the story.
2. **Feed → Field: the story's question becomes the seed.**
   - On receiving a story, the Feed writes `Story Received` (song link, signature word) to App Activity.
   - The Field's Consciousness Loop, when opened on that song, offers the story's question as the seed instead of its default.
   - The Field Map draws that song's node with a faint thread, a sight and not a mark of completion.
3. **One constellation, two skies.** Use the same hash for The Word's Star placement in both apps, so a word offered in either app sits in the same place in both skies. It brightens by recurrence in the Field's dances, the Feed's Rite, and "what came home." It is seen in either app's night sky with no numbers, and no app announces another.
4. **Shared mirror families.** Room-kindred families (Feed) and song-kindred families (Scores) live as data, both on the consonant-skeleton lookup. When a word offered in a Feed story is danced, its Field mirror words come from the *rhyming room's* family, and the reverse also holds. The languages interpenetrate quietly.
5. **The Oracle answers across both.** One listening void (Haiku, catalog-aware over *both* tables) returns a verb, a story and a song. Open it in either app and the answer is a pair.
6. **The Feed reads the Score, not just the track.** Extend `FieldTrack` with `scoreJSON`, `recognitionStatement`, `seedPhrase` and `lalita`. This one change makes World VII peak correctly, gives every rhymed story its epigraph and Recognition line, and lets the Feed's dance moments use the Score's fruit, haptics and mirror families.
   - It is also the "real unlock" BATCH-SCORING-STATE names for the Field app itself. Build it once and share it.
7. **Being words flow both ways.** The Field's "what came home with you?" and the Feed's identical prompt (§2.11) write to one shared being stream, read by both constellations and the Feed's Archive book. It is never shown as a list, only as stars.
8. **Never on a low day.** Both apps already know the day's state through the Rite. On a low day the Field's suggested song for a story stays unsuggested, and only the bed plays. The Feed honours this, and so does the Field.

---

## 5. Cautions carried from these sources (where Field practice collides with Feed law)

- **Counts in fruit weaves** ("You have crossed N times", "your {n}th dance", "{n} seconds") must be translated before any reuse. See §2.10.
- **The Map's "locked" state** must become *dim but tappable, lights on touch*. See §2.27.
- **Pre-roll "first three dances"** must become dwell-based. See §2.24.
- **The Sonar Ears "33" threshold** must never appear as a number. See §2.33.
- **Family songs** (purity, levelup), the Aatma maker's health context, and Session 8's past-life material stay out of stories entirely.
- **Phase names** ("Threshold Valley", Cinzel at 3.4 s) are poetic, not architectural, so they may surface. Never surface element or tier names.
- **The Feed's World VII peak at 60%** discards the composed peak. Fix it via §4.6.
