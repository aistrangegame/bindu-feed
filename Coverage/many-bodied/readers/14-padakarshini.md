# 14 · Padakarshini, read as a library of game moves

*Reader 14 of ~20. Source: `/mnt/skills/user/padakarshini/`. Frame: Ashrey's ruling of 12 Oct. The Feed is reality meeting itself, and the whole app is one game across registers. Conditions light things up and never lock. Nothing on screen is counted. There are no notifications.*

---

## 0 · What I read

**Read in full:**
- `SKILL.md`
- `references/gestures.md` (G0–G50 and the input adapters)
- `references/forms.md` (the 12 forms, A1–A14, B1–B4, C sub-templates and moves, D ceremony grammar, E seven forms of time, F the walk form)
- `references/process.md`, `references/site-v3.md`, `references/lineage-2026-09-22.md`, `references/lineage-2026-09-30-design-corpus.md`
- `references/elements-2026-09-30.md`, all 1,966 lines (6.1–6.13 and the 140-prototype ledger 6.14)
- `references/design-brief-template.md`, `references/claude-code-handoff-template.md`
- `references/design-pass/`: `REVIEW.md`, `ROADMAP.md`, `FALLBACKS.md`, `HANDOFF-CODE.md`, `HANDOFF-CHAT.md`, `CONTRACT-DELTA.md`, `_template_table.md`
- `engine/`: `MOVES.md`, `GRACE.md`, `CORRIDOR.js`, `compose.js`

**Read for structure** (data files and code, not prose):
- `references/forms-contract.json` (all 26 contracts read)
- `design-pass/contracts.json`, `glyphs.json`, `manifest.json`, `_fit_moves.json`, `content-example-5-empathic-listening.json`
- `design-pass/routing.json` (916 instances), `doors.json` (its note, url_scheme and door lines read), `_instances.json`, `references/asg-learning-register.json` (511 topics)
- `references/asg-topic-field.md` (topic lists per form; long lines truncated)
- `engine/identity.js` (header and pools), `engine/gate.js` (function index), `engine/BASE.css` (header), `engine/FIGURES.css` (index of the 15+ `@FIG` blocks), `engine/DOORS.css` (header)
- All 15 `generators/*.py` (docstrings and function index)
- All 34 exemplars in `exemplars/`: the authored step sequence of each, extracted step by step (forms ×10, learning ×2, teachings ×1, variants ×21). `forms/index.html` has no steps.

**Not read line by line:**
- The bodies of the four large data JSONs (routing, doors, `_instances`, register), which are topic routing for the Learning Register and outside the Feed.
- The full CSS of `FIGURES.css` and `engine/DOORS.css`.
- Python generator bodies past their function index.

Nothing was unreadable.

**Context used:** `plan/feed-stories.txt`, so that moves could be tied to real story titles.

**One finding up front.** About a third of this library is already the Feed. The gestures G2–G8, G11–G13, G15, G16, G30–G32, G36, G43, G44 and G50 were all extracted from *A Strange Feed* exports: The Reading, The Rite v3, The Door, The Instrument v3, The Seam, The Turning, Compose, The Light v2, Game View, The Universe v3 and `uni-deep.js`. So padakarshini is the Feed's own grammar, generalised and given exact numbers. The build waves can therefore port behaviour straight back from it, to the numbers.

---

## 1 · Every gesture and form, as a game move

### 1a · Gestures G0–G50

"Already" means the gesture was taken from a Feed export and has a live or prototype form there. Room names are the 13 Feed rooms. "Register" means the surrounding axis: Light, Universe, Point, Practice Door, Mirror, Signal, Rite, Return, Call, Present/Codex river, letters, Archive.

| # | Name | What the hand does | What it means | Feed room, register or move it could serve |
|---|---|---|---|---|
| G0 | The hold (engine) | Press, or hold Enter/Space. Progress rises at UP_MS and drains at DOWN_MS. The visual commits at the threshold; the act runs on release. | A hold is the hold it was designed to be. An early release drains and never fails. | **Already** the house law ("holds drain on early release"). Every hold in every room runs on this engine. Port it to native on CADisplayLink. Durations by meaning: commit 0.7–1.3 s; ceremonial hold 1.1–2.9 s with a drain; over 3 s only when the hold *is* the act. |
| G1 | Hold to read (the Voice) | Hold and words assemble one at a time; release and they stop. A pause leaves an ember whose brightness grows with time away. | A chapter read by hand. The speaker is withheld until "Where you stayed". | **The key move for "reality meeting itself."** Read an other-suit story with the teller unnamed, then name the body last (the cloth, the land, the machine). Candidate grammar for **The Remembering** or **The Signal**. It is also the "passed between tellers" reveal (§3). |
| G2 | Stillness | Come to rest. After 4,600 ms of no input the door opens. A touch pauses the count and never resets it. One line, once ever. | Absence of input is an input. | **Already** in The Instrument and The Light. Grammar for **The Watcher** ("What No Hammer Reaches", "You Can't Measure the Light"). It is also the "equal path for stillness" that every gesture owes. |
| G3 | Following | Take hold of one of nine rays and drag outward; four bands of reading lie along the ray. | Travel along a line to its end. | **Already** in The Reading (world II). Fits **The Thread** ("The Wisdom Only the Journey Gives") and lineage stories. |
| G4 | Parting | Press, and a 104 px opening parts a drifting veil. The text is readable only through the opening, and each section given leaves the veil permanently thinner. | Read through a veil you hold open. | **Already** world III. Grammar for **The Forgetting** ("The Forgetting Was Built In", "The Red He Couldn't See"). The thinning that stays doubles as a "layers on return by dwell" signature. |
| G5 | Bearing | Press harder to strike deeper, letterpress style. Below 0.12 no impression is made. "Nothing here is a tap." | Pressure leaves an impression. | **Already** world IV. Grammar for **The Forge** ("Don't Belittle What You Built", "The Line Stopped" [Machine]). |
| G6 | Keeping pace | Catch a star in orbit and keep your finger within 84 px. Sections land every 1.15 s; let go and they scatter. | Keep up with something moving. | **Already** world VII and the Point Portal dance. Fits **The Circle** ("The Universe Does the Sorting") and the dance registers. |
| G7 | Turning panes | Drag sideways and paired panes turn. Every other section arrives mirror-written and unflips. The lone pane gives nothing back. | Half of each reading comes from the other side. | **Already** Instrument v1. This is the two-sided page: **A Maya Game** ("The Two Who Were One", "The Cloth With No Wrong Side" [Cloth]). The lone pane is a natural "third door". |
| G8 | Send and wait | Aim a star and let go. It flies out and comes back on its own time with one section. Laps lengthen (3.2 / 5.4 / 8.0 / 11.2 s). Whatever returns while you are away waits at its post, lit. | The interval is the reading. | Instrument v1. Grammar for **The Garden** ("ripens unwatched"), and a core **surprise-of-arrival** engine because it runs on the wall clock (§3). |
| G9 | Carried light | A soft light follows the finger; only what lies within 92 px is revealed, and you can only name what the light has reached. | Only what is near is known. | Fits **The Remembering** (memory as a carried lamp) and lineage stories ("What the Hands Put Back" [Lineage]). |
| G10 | Still Point | Seven stages, one ~1.3 s hold each. Words fall away and type grows until only the ember breathes. "Surface" is always there. | Each hold takes something away. | Fits **The Return** ("You Can't Find the Center Because You Are It") and the empty-summit signature. Never put a gate on it. |
| G11 | Received as a Rite | Every paragraph is already on the page, unlit. Each tap lights one more, then the voices gather one line per tap. | A reading received, not read. | **Already** the daily Rite. It is also the general "receive" move for any room. |
| G12 | Pull to turn | A slow pull down past 84 px opens the hidden list (the 2×2 dot mark is its button twin). | Navigation hidden until asked for. | **Already** the Door's turn ("WHERE TO"). This is how new rooms and registers enter the list (§3). |
| G13 | The rope | A 1.1 s long press anywhere opens a black room. Two breaths pass before any words, then one line of reassurance and two ways out. | Grace before it is earned. | **Already** the Door and Instrument rope. This is the "never on a low day" valve and must be present in every register. |
| G14 | The Descent | Hold 1,250 ms. A veil rises; release early and it is refused without comment. The passage takes 2.35 s and an ember stays. | A hold that resists, then gives. | Grammar for **The Descent** ("The Crossroads That Repeated", "The Ground That Held" [Land]). It is also the crossing from paper (reading) to dark (reflection). |
| G15 | Membrane push | A surface between two registers tightens under a push and gives only to continued intent. Stop and it hands you back. | Surfaces resist until meant. | **Already** Instrument v3. This is the axis of registers itself (§2). |
| G16 | Consent pull | At the mouth, consent rises only while the hand keeps pulling (about 2.2 s). It never fires on its own. | Crossing happens only while the hand keeps asking. | **Already** The Seam. Use it for the last step into any story from the Universe. |
| G17 | Two holds of the centre | Holding falls inward forever (a Shepard tone; recognition after 6.5 s) or blooms the figure outward, which dissolves on release. | Fall inward or bloom outward. | Fits **The Field** ("Creation, Preservation, Expansion") and the Point's two holds. |
| G18 | Trace | Follow a spiral or a figure's lines with a finger. "Wherever your finger goes is right." | Walk the path with the body. | Fits **The Thread** (tracing the weave: "What the Cloth Believes") and the Practice Door. |
| G19 | Shake | Shaking (device motion over 18) scatters drifting thought-phrases; a tap is the fallback. | Clear by agitation. | Fits **The Forgetting** ("The Fire and the Illusory Relief"). Use sparingly. |
| G20 | Tilt | Steady a drop in the centre for 7 s; dragging is the fallback. | Balance held. | Fits **The Body** and the Watcher. |
| G21 | Microphone loudness | Your voice loosens a compression; "tap to loosen" is the fallback. Nothing is recorded. | Voice as force. | Fits **The Signal** and Call/voice registers. |
| G22 | Front camera | Sixty seconds of your own face inside a filling ring. Nothing is recorded. | Sixty seconds with your own eyes. | The **Mirror** register. |
| G23 | Tempo | Tap in time: drum, corridor, coherence, tuner. Scores are never shown. | Rhythm as presence. | Fits **The Body** ("The Songs That Played Him Home") and **The Circle**. |
| G24 | Turn rings into alignment | Turn three rings until each snaps true with its own bell; when all align the centre lights. | Alignment discovered. | A **rhyme reveal**: turn two stories' rings until they align (§3). Also fits The Circle's widening rings. |
| G25 | Drag two things together | Two tiles overlap, fade to the midpoint, and a third tile blooms naming what appeared. | Union births a third. | **The rhyme move:** drag a host story and its other-suit twin together and a third line blooms (§3). Fits "Twins Across Time" (The Field) and "One Roll, Both Ends" [Maker]. |
| G26 | Set down or keep | Draw a card down past 90 px to set it down, or up to keep it. Both are allowed. | Release or carry, as equals. | Fits **The Return** and The Descent ("Suffering, and the Door It Points To"). |
| G27 | Seal by wax | Write, choose a day, and drag the seal on. The letter waits and opens on its day. | Time opens it. | The **letters** register. In the Feed the seal is the reader's own act, never a gate the app imposes. |
| G28 | Rewind by a held spiral | Hold 1,400 ms, turn back 540°, and the choice is offered again. A journal keeps every branch. | Every path is walkable. | **A Maya Game** ("Every Path, Already Walked", "Dreams Within Dreams"). This is also the "every path" signature. |
| G29 | The hold is the move | Hold the die (2.2 s), the deck (1.9 s) or the breath (4 s). "One breath is a whole practice." | Chance by holding. | Feed-wide play: **the Draw**, a card of the day from the stories (§2 board). |
| G30 | Colour through staying | Hold the ∞ for 2,900 ms; the page rises from grey into the voice's colour. Words are legible past 55%. | Meeting one voice. | **Already** Player Detail (The Turning). Use it for meeting each **archetype voice** (Bindu, Gaia, Sid, Arch, Sakshi…) and each suit-voice: the Cloth, the Land, the Machine. |
| G31 | Hold to release | Write, then hold the ring for 2,300 ms. It is armed only when there are words. | Writing sent by a hold. | **Already** Ash's Compose. Use it for the reader's reply under any story. |
| G32 | Carve | A line is offered as "you"; a hold (900–4,200 ms) carves it in as "I". | A vow taken on by an act. | **Already** The Light. Use it for **the Light** register (futures) and for "I already did". |
| G33 | Hold to lay down | Name what you carry and hold 2,600 ms; the words sink. Nothing of them is stored. | Let go. | Fits **The Descent** and **The Forgetting**. |
| G34 | Hold to become small | Hold 2,800 ms while the words shrink toward 55%; a small door opens. | Child space. | Fits **The Remembering** (lineage, childhood) and the Garden. |
| G35 | Touch beats | Three self-paced beats; each writes itself, then waits for a touch. | Come nearer in steps. | Entry to any room. *In the Feed, never shorten beats by visit count (house law: dwell only). Use G49 dwell instead.* |
| G36 | Ask; the exhale answers | Each touch adds a "want" (at most two queued); each want is answered at the next exhale. The breath cycle is 10 s. | Words arrive at the breath's pace. | **Already** The Light. Use it for **The Signal** ("Solutions That Arrived Before the Problems": the answer comes before the asking is finished). |
| G37 | Breath as navigation | The field nears on the inhale and recedes on the exhale. | A concept only. | Score it before building (law 17). Possible Light register. |
| G38 | Leave by the edge | Drag from the left edge or press Esc. Never punished. | Leaving is one gesture everywhere. | Every register. |
| G39 | Long-press catch; recognition ceremony | Long-press anywhere to catch. The "I feel her" pill opens a staged recognition: name, phrase, "felt here", "and felt you back". | Recognition is mutual. | **The Call**, and the moment an archetype is recognised inside a story. |
| G40 | Touch the body where it speaks | Touch a region of a one-line figure, then name the quality you find. | The body is the menu. | **Already** in effect as "entered by the body", the grammar of **The Body**. Use this exact mechanic for it. |
| G41 | Tap to mark | Tap a paragraph to mark it; a second tap unmarks by parity. | Marking is the keeping. | The **Archive book** and a commonplace book across stories. |
| G42 | The Veil | Draw a dark veil up over the image; places sit in a column by depth, each lit by where you stand. | The way in, ordered by depth. | **Already** Navigation Options / the Door's turn. This is the whole-app room list (§2, §3). |
| G43 | Arrows step a ring | ← → step through the 13 rooms and wrap around. | A ring of equal places. | **Already** Game View. *Drop its "n · 13" label (nothing counted).* |
| G44 | Continuous zoom | One camera from z 0.22 to 34. A star grows into the world you land on; there are no cuts. | Whole to one piece. | **Already** Universe v3. This is **the Universe** register (sky, regions, world, fall). |
| G45 | Turn a world | Drag sideways and it turns with inertia (×0.90); tapping a node raises a card. | Turn a world, a sphere, a body. | **Already** The Seam. Use it for the Universe, and a sphere of stories chosen by feel. |
| G46 | Speak | Press once and speak; four sentence-cards rise asking where it goes. Typing sits beside it. | Capture placed by grammar. | **The Codex river.** A new memo enters here (§3, new stories). |
| G47 | Finger play | Plants, rain and colour grow under fingers. No goal, no ending. | Pure play. | Fits **The Garden** ("The Energy That Comes From Nowhere"), as a resting room. |
| G48 | "Let the field choose" | Tap a value and type it; or let the digits cycle and lock like a slot machine. | Chance with a visible landing. | The die or Draw inside the Universe, and the **Aperture** draw (§3). |
| G49 | Dwell | A measure, not a gesture. A phrase counts as held at 2.5 s; embers appear at 1.5, 4.5 and 12 s; a room you stood in opens further on return. | Memory felt, never shown. | **Already** the house law "layers appear by dwell" and the signature "layers on return by dwell". This is the condition-lights-up engine (§3). |
| G50 | Sweep | Draw one line across the whole field. Items within 0.055 of it answer, and the three deepest are named in their own words. | Draw a line across everything and it answers. | **Already** in the Universe outward side (`uni-deep.js`). **The best rhyme-revealer:** sweep across the sky of stories and the ones on the line, from different suits, answer together (§3). |
| Adapters | Stillness, microphone, shake, tilt, trace, camera | Each is opt-in, records nothing, has a fallback, and switches off when the page is hidden. | | One shared adapter layer for every room. |

### 1b · Forms, ways in, grammars

| Form | Mechanism | What it means | Feed room, register or move |
|---|---|---|---|
| Icebreaker | Questions, five things, words, voices, one line. One tap copies the questions. | Open a conversation. | Hand-over-ability. *Move:* "voices gather after you finish". This is **already** the Feed's Story Detail. |
| Storybook | A fable in ten pages (title, affirmation, text). Sub-templates: `held-beats` (three holds: kindle, part, spread), `return-pass` (inward, then a threshold, then outward), `tradition` (a silsila chain; "the last lamp is yours"). | The fable does the work. | The basic story page. `return-pass` suits **The Descent ↔ The Return** pairs. The `tradition` chain suits **The Thread** and lineage. |
| Teaching | Laws in three registers, with a picker. *Moves:* one reading gesture (G2–G8); the descent reveal; the Still Point at the foot; received as a Rite. | What a thing knows. | Each story's "teaching" layer; the Still Point at its foot. |
| Practice card | Do it now. A breathing circle around a timer that waits. | Act, not read. | The **Practice Door** register. |
| Walk | Gated days with a cooldown. Can become a descent, a growing figure, or a river of letters. | A sequence over days. | *In the Feed, use only as a suggested pace, never a cooldown (Ashrey's no-lock ruling).* The growing figure is useful. |
| Field guide | When → do → because. A picker first. `fieldguide--when` names the state you are in. | A hand on the shoulder. | A way into stories by state ("When the mind won't land"). Needs care: never on a low day. |
| Portrait | A person in five moments on a life-line. `portrait--voice`: words earned by staying. | A life. | Archetype and suit-voice pages (the Cloth's life: "Before I Was Cloth"). |
| Map | The structure drawn, current node lit. Sub-templates: `yantra-walk`, `veil`, `sky`, `climb`, `circulation`; arrows step a ring. | Position is the content. | The **Point**, the Universe, the room ring (§2). |
| Two chairs | A debate in rounds; the last screen refuses to pick. *Move:* authorship by colour. | A question held open. | Two tellers of one moment: a host story and its other-suit twin side by side (§3). |
| Recipe | Need, do, watch for, keep. The process drawn above. | Plain how-to. | Little Feed use. Its COVER ending ("leave it be") suits The Garden. |
| Calendar | One day, hour by hour; the sun crosses. `calendar--day`, `calendar--sky`; breathing on the wall clock. | The day as the unit. | The **daily Rite**, Present, and the day composed by hour (§2). |
| Verse | Original line above, gloss beneath. *Moves:* focus not fade; written by an unseen hand; inversion; words from particles. | Said aloud. | The Codex memo's own spoken line glossed beneath the story. Inversion suits A Maya Game. |
| Guide | One sentence, a Tuesday, why I made it, what it refuses, how to enter. | What a thing is. | "What is this?" at every level (`ASG.sheet`). |
| Door | The register with a die. | Chance as a way in. | A die over all 137 stories, scoped by room or suit (§2, §3). |
| **A1 Rite** | Touch-paced light on text already there. Voices gather one line per touch. Who speaks in full comes from a date rota; the zeroth voice is never silent. | Received, not read. | **Already** the daily Rite. The rota by date is how archetype voices take turns without being tiered by returns. |
| **A2 Mirror walk** | A G14 door, three teachings walked by holding, your word returned, a vow carved (G32), a sky of walks. | A walk under the floor. | The **Mirror** register, and how **new rooms appear from the reader's own words** (§3). |
| **A3 Letter** | A NOW line; letters go back to an age or forward to a day, sealed. | Time opens it. | The **letters** register. A Codex memo can be answered by a letter forward. No generated replies. |
| **A4 Gates of release** | Descend through gates and set things down (G33) or keep them (G26); rise and receive a gift at each. Never locked. | Release, then receive. | **The Descent → The Return** as one arc. |
| **A5 Breath session** | Chosen by intention; the circle is the timer; cue words are written as sounds. | Breath by intention. | The Practice Door. |
| **A6 Play-it piece** | One object, one gesture, one line. No score. May grow in real time. | Play. | Small play inside rooms ("The Seed": 2 h, 8 h, 24 h, 72 h). |
| **A7 Four-section reading** | SAY, WALK, HAND, OPEN, each arriving by the world's own gesture (G2–G8). "No generic reading." | One star, one gesture. | **Already** the Feed's Reading, and the pattern behind the 13 room grammars. |
| **A8 Voice** | G1. The speaker is withheld, then named. | Read by hand. | The passed-between-tellers reveal (§3). |
| **A9 Still Point** | G10, seven stages. | Depth strips away. | The Return; the empty summit. |
| **A10 Day's line** | Three persons: *to* you (signed "— the field"), *back* to you (from what you sealed), *about* the world. Picked by local date. | One line a day. | **Already** the Signal Space and the Mirror; the "persons tier". This is the **Signal** register. |
| **A11 Answerable reflection** | A line arrives clause by clause with its sources; then "Does this land?" (lands, say more, leave my own word). | The reader has the last word. | Under any story: the reader can answer the transmission. |
| **A12 Wager** | One thing to watch for; days later, on first open: "Did it appear?" | Carry it into life. | A story hands the reader a watch-for that comes back on its own (§3). |
| **A13 Scored performance** | A Score as data, played by a separate player. | A timed piece. | A long story as a scored session, with voices entering at their own seconds. |
| **A14 Board** | Positions played by chance; every landing opens a room with a practice first. A care line. | A game of positions. | **The whole-app game shape** (§2). Its "what you bring" toggle (my life / what I'm building) can read a landing for a suit. |
| **B1 Threshold card** | One small thing each visit, weighted 40/23/20/12/5, never the same kind twice. "What Found You" must be a real item. | Something different every time. | **Already** the Practice Door. The core **surprise-of-arrival** engine (§3). |
| **B2 Two-door station** | Walk it or read it, as equals. Flames read "half" or "whole". | Two halves of one place. | Each story as "received" and "read", or as host and twin (§3). |
| **B3 The Veil** | Five tiers of light: You are here, Open, Ground, Ahead, Veiled. A dashed line, never a lock. | Light, never locks. | **The conditions-light-up canon** (§3). |
| **B4 Home by how far you have walked** | One address, three homes; "return. / the road remembers" only after days away. | Home is the record of the walk. | The app's launch (§2). |
| **D Ceremony grammar** | 1 open with one breath · 2 beats · 3 the act · 4 the answer in the world's own material · 5 close with a hold that carves or lays down · 6 a whisper and one warmer light, never a checkmark · 7 a bowl · 8 return to the depth and breath you left · 9 proof. | Every ceremony has one shape. | Every reception in every register. |
| **E Seven forms of time** | Aperture, Pace, Trail, Hold, Bloom, Orbit, Night. | A timer that breathes. | Any timed register (Practice Door, Light, Rite). |
| **GRACE endings** | Every page ends in a gesture rather than a sentence; no two forms end alike; a topic's two pages never end the same way. | A quieter ending. | Thirteen rooms means thirteen distinct endings, and a host story and its twin must never end alike. |

---

## 2 · Structures that can make the whole app one game (no counting, no locking)

1. **One axis, surfaces that resist until meant** (elements 6.2; G15).
   - The whole product is one vertical axis of registers. Between every two, a membrane gives only to meant force and hands you back if you stop.
   - The register ahead is always visible, forming inside the one you are in. A thin rail shows one tick per register, one tick lit, "never a number".
   - A LONG / SHORT switch gives one free scroll as the accessible path.
   - Ceremonies open from doors on the axis and return you to the depth and breath you left; `walk-continuity.js` carries depth, breath phase and what you carried for 90 minutes.
   - This is the closest existing skeleton for Light → Universe → Feed rooms → Point → Mirror → Signal → Return as one continuous game. It is already the Feed's Instrument v3.

2. **The Board (A14)** as the meta-game.
   - Positions are the 13 rooms plus the registers. Chance moves you (a held die, G29). Every landing opens a room with a practice first ("I did it" / "Let it be"), then a reading, one move for today, and a seed.
   - Rises and returns are drawn as "a lesson, not a fall". A care line sits under the board: "If today is heavy, the board can wait. Three breaths is a whole game."
   - **Adaptation for the Feed:** no exact-landing gate and no six to enter. Landing lights a room; it does not unlock it. The "what you bring" toggle can choose which body the field reads through (my life, the cloth, the land, the machine).

3. **Arcs.**
   - **The Point walk (`map--yantra-walk`).** A nested structure walked inward at constant size. Only your ring is lit. Stars are marked walked ●, in progress ◐ or seeded ○, from your own walk. At the centre, *the visit is told back*: where you entered, what you opened, one closing line, nothing counted. This is a natural "end of a session" for the whole app.
   - **The climb (`map--climb`).** The body as altitude, with bands of weather, each band its own tempo (full speed at the feet, 0.28× at the top). Doors lead sideways to neighbours.
   - **`storybook--return-pass`.** Seven screens inward, a threshold ("the same movement seen from both ends"), seven outward. The chime climbs a scale going in and descends it coming out. This is the shape of **The Descent ↔ The Return**, and a frame for a host story read inward and its twin read outward.
   - **Gates of release (A4).** Descend and set down; rise and receive a gift at each gate. Never locked; it can be walked over different days.

4. **The day as the structure** (`calendar--day`, The Eight Modes, The Shell, Living Rite).
   - First open of the day, before noon: "what came through in the night". Beholding by stillness. A long-press catch through the day. In the evening, the day's catches gathered, named once, and released into the point by a hold.
   - The day's presence opens on one being, laid out by its element and relit at dawn, noon, dusk and night. It is worded as a daily turn, never as "she presides today".
   - This is a round, not a streak: the daily Rite, the Present, the Return.

5. **Two weathers of one door, plus no lobby.**
   - The front screen shows whether today has been met, by light alone: pre-dawn when unmet, after-light when met. The met state is read from the real activity record.
   - On an unmet day, opening the app *is* the first movement of the ceremony. On a met day the same surface holds a threshold kind.
   - Three gestures share one surface: a tap crosses, a slow pull opens the turn, a long press opens the rope.

6. **B4 home by how far you have walked, and the home that grows as you walk.**
   - The layout of home is the record of what has been walked; only the next door is lit; the rest wait as dots counted in words ("three more, after this").
   - Use the words-not-numbers form, or drop the count entirely under the house law.
   - Once everything is walked, home becomes a dwelling, with *carry your road* (export) and *forget me*.

7. **The persons tier.** The third-person story rooms sit above a divider, "and the field turns to you", with first person (your own lines handed back) and second person (one transmission) below. The three persons work as three registers of one game: about, back, to.

8. **There is no menu.** A handful of gestures is the whole grammar: tap a ring to go in, tap the centre for silence, long-press a ring to remember, pinch outward to recite, swipe up from the edge for today. A visible list stays beside the gestures (G42).

9. **One camera, no cuts (G44 / G45 / G16).** The sky, then a region in its own weather, then a turning world, then the fall, where the mouth crosses only while the hand keeps asking. Travellers move along lanes **only between places you have already been**, so the sky becomes a map of your own walk.

10. **The ceremony grammar (D) plus the seven forms of time (E) plus GRACE** as the shared rules every room obeys, so that 13 different grammars still feel like one game.

**Laws to carry** (SKILL laws 1–19, ruled 11 Oct as "moves, not walls"; two floors: truth and access):
- Law 1: how you touch a thing is the teaching.
- Law 5: staying opens things; nothing new is locked.
- Law 8: one gesture per register. Vertical walks the axis, sideways is the place's own gesture, one swipe is one step.
- Law 11: the page may know the day; it does not count the reader.
- Law 12: memory is felt, not shown; *forget me* is always offered.
- Law 13: nothing is staged.
- Law 16: every place moves as what it is. A tempo per room (Lalita: 600 / 350 / 120 / 150 / 1,200 ms) lets you know a room by its tempo before its name.
- Law 19: two sides meet at one shared structure, each keeping its home, with "play it" / "read it" doors between them.

---

## 3 · Patterns for the five asks

### 3a · Surprise of arrival, inside the app (no notifications)
- **A piece that returns on its own, aged** (The Return v2). "A story has returned to you." / "You did not go looking for it."
  - Age comes from days alone: `a=(days/1095)^0.55`. Saturation, breath, grain and warmth shift; colour moves from bone to amber to deep gold.
  - A new ring enters off-centre and settles true over 4 s while its tone comes into tune from 1.5% flat.
  - **The best fit for old Codex stories resurfacing.** The returns are never counted.
- **Threshold kinds, weighted, never doubling (B1).**
  - "What Found You" (12%) shows *a real story*: room pill, title, one quoted line.
  - "The dot alone" comes about 1 in 16 opens.
  - The very first open ever is a threshold.
- **An event that enters any piece and gives it back** (Bindu Lalita). Rarely and unannounced, the ground warms to cream, a line dances one of six curves for 16–25 s, then spirals out and returns the page. Never counted, never predictable, skipped under reduced motion. This is a rare visitor in any room (an archetype or another suit passing through).
- **A page opened by catching what wanders.** A 9 px point drifts and warms over time; catching it opens "This is what it was carrying." It is never the only way in.
- **Send and wait (G8)** and **the dawn that keeps moving** (wall clock). What returned while you were away waits, lit. A scene's light keeps moving between visits.
- **The field gathers later** (ambient answering). After the reader writes, nothing waits on screen. Later, 2–3 voices whose stance fits have answered, and the reading's own reveal shows them on return.
  - Generate once and keep (idempotent). Label it as generated.
  - Optional backward ripple: *a new item may wake one remembered answer on an older one.* That ripple is exactly "a new Codex entry lights an old story".
- **The Wager (A12).** Days later, on the first open, "Did it appear?" comes back with no "Day n of N".
- **Resume, and a welcome back to something that rested.** "It rested while you lived. Welcome back — meet it new."
- **B4.** "return. / the road remembers" only after days away, one overlay per arrival.
- **The world left you something.** Once a day a small gift is placed in the world built from everything you did.

### 3b · Conditions that light up (never lock)
- **Light, never locks: five tiers** (B3, Mandala Legend).
  - Glyph, text and sub opacities per tier: You are here 0.95/0.95/0.60 · Open 0.82/0.84/0.50 · Ground 0.62/0.66/0.40 · Ahead 0.30/0.34/0.22 behind a dashed line (veil 0.55) · Veiled 0.16/0.20/0.13 (veil 0.72).
  - Every tier is reachable. **This is the direct replacement for the rejected rhyme gate**: other-suit stories sit at "Ahead" until their host is received, then brighten. They are always enterable.
- **Readiness sensed, crossing chosen.** Status is shown as light (22 / 44 / 76 / 100% opacity, the last with a glow). "Hold to cross into…" appears only when ready, and only the reader's hold crosses.
- **Staying opens a deeper turn.** A room changes at about 62 s, holds until 227 s, and reverses its own premise by 347 s. Nothing needed is behind the clock, and the reader is never told to wait.
- **Memory felt (G49).** A room's head start comes from dwell, not visits: `min(dwell·0.55, 221 s)`, or 0 below 12 s. A met place's light is already burning. "You have stood here before" appears once.
- **The colour of the room on the Door, by the day's state.** Unmet versus met light.
- **A map with the unmade places visible.** Unmade stories are small cream dots that say "this has not yet been composed". Never "locked".
- **A gentle door toward what has gone quiet.** When one part has gone quiet, one dismissible card appears, once. The whole is measured as a field whose halo strengthens only as the *darkest* light rises.
- **The figure remembers the return.** The point is gold from the first frame on a later visit.
- **Breath slows toward the centre.** Depth is felt as slowing (outer ring 3.5 s, inner 18 s).
- **The interface thins as you go deeper.** Chrome falls 100, 80, 60, 25, 0%.

### 3c · Revealing rhymes between two stories (shown, not used as a key)
- **Recognition across topics** (Learning App, "the Field / A life").
  - When one theme recurs across at least three separate topics, a **dashed ember line wires those stars** and one hand-written line per theme appears, naming the pull without a number. Tap it for the arc. Silence when nothing spans.
  - This applies directly to the Feed: host story ↔ cloth ↔ land ↔ machine.
- **G50 Sweep.** Draw one line across the sky of stories; the ones near it answer together, the three deepest named in their own words. The rhyme is found by the reader's hand.
- **G25 Join.** Drag two story-tiles together; they merge and a third blooms with one line naming what appeared. For example, "The Two Who Were One" × "One Roll, Both Ends".
- **G24 Turn rings into alignment.** When both rings align, the centre lights.
- **The sideways door** (DOORS.css, doors.json).
  - Every page ends with a door to its sibling, drawn as *the other page's figure in miniature, in the other page's accent, ringed in this page's accent*. "The same subject · another way."
  - On click, the world tints toward the next accent before the page changes.
  - In the Feed: "The same moment · through the cloth."
- **Topic identity (identity.js).** An FNV-1a hash of the name gives an accent and seed, so one subject carries one signature across forms. For the Feed: a **rhyme family** (host plus its suit twins) shares a seed, and the reader sees kinship before reading.
- **Two chairs with authorship by colour; `storybook--return-pass` (mirror around a threshold); G7 mirror-written panes.** Two tellers of one moment side by side, neither chosen. The last screen refuses to pick.
- **GRACE's rule.** A topic's two pages never end alike (406 pairs checked, 0 clashes). Apply it to every host/twin pair.

### 3d · A story passed between tellers
- **One sentence, all the way round** (`map--circulation`, the Instrument Room).
  - Stations sit on a ring; *one dot carries one sentence* from station to station (a full turn in 64 s). Each station says what it **takes in, gives out, keeps**.
  - A numbered chain of hops follows, each one sentence in the colour of the station it lands on.
  - **This is the baton made literal:** one Codex moment travelling Ashrey → cloth → maker → customer → land → machine.
- **The silsila chain** (`storybook--tradition`). "Every teacher had a teacher." The lamps light along the chain, and the ending HANDOVER reads "the last lamp on the chain is not lit. It is yours."
- **G1 Voice.** Hold to read, with the teller withheld. "Where you stayed" comes first, *then* the speaker is named. Reality meets itself, and you learn whose body it was only at the end.
- **The Rite's gathering and the procession of voices.**
  - Each voice is a full-screen scene in its own colour, one line per touch. The finale is a rose window of all the voices turning round the zeroth voice's ember.
  - Who speaks in full comes from a date rota, never from tiering by returns.
- **A room per voice: the figure is the index** (Rooms v4). Everything a voice has said is placed on its own figure: knots on a loom, seeds on a spiral, days on a spine. Positions with no words stay dim. This gives each suit (Cloth, Land, Machine, Lineage, Company, Customer, Maker) a room drawn from its own mathematics.
- **One point alone, or the whole room** (singular / ensemble). One teller, or all of them at once.

### 3e · New rooms appearing
- **A sky of walks, and a room that came from what you said** (Lalita Mirror Universe, "the Loop").
  - A pass is run by hand, on the reader's word, never on a schedule. It reads what was captured and looks for a shape: a behaviour described differently each time; something honoured and resented at once; a gap between intention and landing; a sentence written more than twice in different words.
  - *Only material that surfaced more than once becomes a walk.* It is marked proposed, it lights like any waiting walk, and its trace ("this room came from what you said") appears only at its exit.
  - **This is the exact pattern for "new rooms if the stories ask" and "new Codex entries become stories".**
- **Rooms made by rule, not by hand.** Eight hand-authored mechanisms; every other room takes its archetype from its ring and is tuned by its card: physics from its quality, altitude from its body location. One held attribute is the room's one moving actor. New Feed rooms can be grown this way.
- **The room test.** "Could this room belong to any other?" If yes, it is wrong.
- **The turn's unbuilt row.** A row at 0.42 opacity says in text that it is not yet open; touching it sounds 285 Hz and nothing opens. A room arriving shows as a row brightening.
- **The frontier opened by stillness.** Beyond the one stillness-door is "everything not yet written or walked". Codex memos not yet made into stories live here.
- **A draw from outside the library, with an honest edge** (The Aperture). "this library has nothing beside it." Other suits enter as draws from beyond.

---

## 4 · The method the build waves should follow

1. **Score before building, on five tracks**: scene, sound, gesture, motion, logic, with exact timings and what is stored (the Bindu Experience Score). Its four standing laws: sound learns to sound from zero; one protagonist (one point, never replaced); nothing arrives in under a breath; leaving is never punished.
2. **Build to the numbers, not the frames.** "A screenshot carries almost none of the specification." For example, damping of 0.956 versus 0.945 doubles the glide. Port every Feed gesture from the G-table values.
3. **Compare mechanics side by side.** Build the candidates on the same content and walk them. Keep the winner; record the losers as fallbacks, never deleted (the three earning mechanics; compare two answers on one device).
4. **The room test (law 17).** "Could this belong to any other place?" Every room grammar and signature must fail that test.
5. **The parity pass** (Learning App fidelity protocol, rupakarshini). A port is done when it is indistinguishable from its design, checked screen by screen against 3–5 feel anchors.
   - Failure modes: phase drift, range compression, detail erosion.
   - **The running prototype outranks prose.**
   - This is the AS DESIGNED vs AS BUILT check. The 3 Oct law sits alongside it: "the experience as designed is the law… a rule may add, never subtract. Before changing an existing experience, compare it with what was served before and with its design."
6. **Ship with proof, verified backwards** (Homes Verification V3: 66 checks across nine registers). Every claim is traced to its source. There are detectors for any number about the walker ("3 of 9", percentages, streaks). No two siblings alike. *Nothing from an earlier build has vanished.*
7. **The adversarial pass** (Lalita's Pass).
   - A prohibitions audit (instance, ruling, verdict).
   - Register integrity: is there *anything that could make the reader feel behind*?
   - **Three cuts rather than additions.**
   - A gameplan naming which tool does what.
8. **The silence sweep.** Delete every instruction string no design file contains. One hint, once, then silence.
9. **The wording canon.** One table per product (prompt "What arrived for you?", "The room has changed.", "The field gathers", "AND THE FIELD TURNS TO YOU", "WHERE TO" / "tap anywhere to stay"). Every surface reads from one source, and prototype lines that drift are dropped.
10. **One identity per entity, gated.** The same id never resolves to two glyphs or hexes; the "one voice record, one page for all voices" open conflict needs a ruling. Persona text used for generation is labelled.
11. **The lineage of mechanics, and "left behind, by intention".** Every earlier piece is paired to its new home with one mark: carries forward, design-floor candidate, spirit survives, or sealed/held. Anything not carried gets a written why. This ledger is the "nothing vanishes" record. Use it when undoing the rhyme gate.
12. **The bench and the harness.** Review controls live outside the device and never ship. States are forced from the harness (clock, seeded storage), never from a URL parameter.
13. **Gates on every build.**
    - Walk every step in a real mobile viewport: zero unlit steps, zero JS errors, nothing taller than a screen. Scroll to the last step and assert the end state.
    - Every hold completes by a real hold and by a held key; an early release does nothing; the act waits for the release.
    - Under reduced motion each gesture shows its end state and a hold keeps its duration.
    - Every adapter keeps its fallback.
    - Contrast is gated by script, never by eye (the `--ac` / `--acp` / `--actext` rule).
14. **Process order** (`process.md`):
    - Register round one: every item gets lake, primary form, secondary form and why. Rules first, then hand overrides, then a flagged default (never silent). A hold list.
    - Round two: the ruling ("trust is a ruling").
    - Round three, depth-first: one form, three items, walked by the person, then the rest.
    - Then Design (sub-templates, hooks intact), fold back and re-walk, Code, Git as the spine, write-back to the Builds table.
    - Three layers: form (fixed hooks) → sub-template (family) → move (five bounded slots: figure, direction, ground, density, one play, with "none" a real answer).
15. **Learned the hard way**, to carry:
    - "Landing is transformation of what was read, not another reading" (the third extraction pass was stopped).
    - "Unflatten first" (twice collapsed into one form).
    - Holds run on the display link natively, never `withAnimation`.
    - Safari wipes a site's data after 7 days without a visit, so persistence or *carry your road* is needed.
    - Never Babel or a CDN at runtime.

### Tensions with the Feed's house law (flag for the plan)
In each case the Feed law wins.
- **Counts the library itself shows:**
  - corridor `#count` "n / N", the Game View "n · 13 · all rooms", the Chrome's "n of 7", Blink's "01 / 16";
  - the Feed's house law says nothing counted. Drop them in Feed builds; the dash row is optional by law 9.
- **Waits and gates:**
  - the walk form's cooldown and the board's exact-landing gate;
  - Ashrey's 12 Oct ruling outranks the 11 Oct "a real gate stays where locking is the meaning". Use B3 light tiers instead.
- **Beats shortened by visit count** (G35, G49's entry shortening, kept-as-designed in the skill) conflict with the house law "layers appear by dwell, never by visit-count". Use dwell only.
- **Time-sealed letters (A3) and the wager (A12)** are reader-initiated acts, not app locks, and fit. Never make a story wait on them.
