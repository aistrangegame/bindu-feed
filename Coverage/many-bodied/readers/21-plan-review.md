# 21 · Adversarial review of GAMEPLAN.md (12 Oct 2026)

**Read in full:** GAMEPLAN.md, BRIEF.md, reports 01, 02, 03 (all 290 ledger items, sections A–E), 04, 05.
**Read in part:** the EMERGENT sections and the mechanics and rooms sections of reports 06–20, as listed in the reply.
**Also checked:** the live schema in `tables.json` (field types on The Feed and App Activity) and `appact.json`.

The findings are ranked most important first. Each one gives what is wrong, the evidence, and the fix, with the plan section it belongs in.

---

## 1. The plan adds new hidden-until mechanics, which the ruling forbids

The plan forbids locks in §2 law 2 ("every story, room and register is enterable from the first day"). Then it designs several surfaces that do not exist until a condition holds. Each is a "hidden-until" lock, the same shape as the rhyme gate.

- **Faces that only appear after progress (§3.5.3).** Lalita's drops "start finding him in that room", Gaia's night drop and the Higher Self's letters all begin only after K-W-A circuits close in a room. Before that, those faces do not exist in that room.
  - *Fix (§3.5):* every face is present in every room from day one, at low light. Closed circuits change which face speaks first, and how warmly. They never change whether it speaks.
- **"There is one more" (§3.6.3).** The extra story exists only "when a body's stories are all present". That is a completion gate. Report 12 #10 has the same idea, also gated.
  - *Fix:* the story exists and is readable from the start, at the end of its Book chapter, dim. "All present" only warms it. Report 18 M6, the deferral, already has the right shape: it "exists and is readable from day one".
- **"Seasons later, the second pass" (§3.5.4).** This is a time gate on content.
  - *Fix:* the woven second voice is readable on demand through Turn. Seasons only bring it forward unasked.
- **Good Morning letter (§3.4).** It appears only on "porous" days, such as the Codex anniversary or his birthday. This is the same Holi-only shape the plan removes from Khelo in W0.
  - *Fix:* once a letter has arrived it lives in the Book and the Present forever. Before then it sits faint in the Present as "a letter left before the forgetting", openable by a long hold. Apply the same rule to every arrival kind in §3.4. The house precedent is TSF 182: "once surfaced a drop stays in the archive". The plan does not state this rule for the new arrival kinds.
- **The five light tiers (§2 law 2).** The plan does not say which content gets the "ahead" and "veiled" tiers. Report 14 §3b says outright that "other-suit stories sit at 'Ahead' until their host is received", which is the rhyme gate reborn as dimness. The tier opacities in report 14 (ahead 0.30, veiled 0.16) make text unreadable, and report 13 §2 says dim marks must clear 3:1.
  - *Fix (§2 law 2 and §5):* tiers apply only to glyphs and stars on the map faces, never to story text. Rhyme status never sets a tier. A story opened from any tier renders at full ink.
- **The Unwritten room (§4.2).** "The body fills in only while he is completely still, and returns to one line when he moves." There is no touch path and no "read it plainly". A VoiceOver user cannot reach the body at all.
  - *Fix:* add "read it plainly" plus a hold-to-read touch twin. Apply the same check to the Wash ("only staying softens"), the Ground (dwell only), the Stack (hold only) and the Old Light.
- **Heavy days (§2 law 4).** "On a heavy day the game offers only stillness and the smallest form, the Swatch." As written, this hides the rest of the house. Report 15 #9 has it right: "a full story is there if wanted."
  - *Fix:* reword to "leads with stillness and the Swatch; everything else stays where it was."
- **The Return and the Floor (§6 Story page).** The plan calls them "always open" but never designs what they show on a story he has never sealed. ReturnRoute shows "nothing has returned yet", and restriction 02 #6 says the Return needs a sealed self.
  - *Fix:* either design an unsealed Return, for example the fall's strata of the field's voices with a ring he may add, or keep the condition and say plainly that it is a condition that lights, with the Floor reachable from MirrorView too.

## 2. Restrictions from reports 01 and 02 that W0 does not undo or even mention

| Restriction | Source | Status in plan |
|---|---|---|
| The `#seam` (outward/inward) shows only when `todayMet` | 02 #11 (C, hidden-until) | Absent |
| The Old Story ring appears only after the Light gate has opened, plus 10 s still. A hidden gesture is the only way in | 02 #14; ledger D22 and item 174 | W6 adds fruits but keeps the gate. Fix: add a visible twin (a Turn row "the old story", or a rail rung) |
| `echo`, `nextThread` and `seekClue` pull only from unopened or unmet stories | 01 §3 #4; 02 #24 | Absent. After W0 they should also draw rhymes and met stories |
| Gift (3-day cooldown, 1 in 6), Field notice (7-day cooldown, shown once ever), Lalita play (5-day cooldown, 1 in 20) | 01 #20; 02 #25 | Only Leela is fixed. The plan should state that the arrival engine *replaces* these counting-based random gates, and that a shown notice stays reachable afterwards |
| Grace and Teacher once per story; App Activity `Surfaced` means "a moment returns once, then rests" (schema description) | 01 #21; ledger 151/152/262 | Absent. Fix: once *surfaced*, keep it findable in the story's margin |
| PointReturn has at most 4 laps per star, and Deep Time arrives once after 4 laps in total. Both are session-static | 02 #18; 02 §5.4 | W5 relies on Deep Time to deliver kathas but does not lift either limit |
| A one-paragraph story skips reception entirely | 01 #17 | Breaks the Swatch, Unwritten cards, One-Line and title-only forms. Fix: a one-paragraph grammar variant in W2 |
| The thirteenth room shows only if `sortOrder == 13`, in a 12 + 1 layout | 01 #13 | A 21-room house breaks it. See §5 |
| Forward letters stay sealed until their date or condition | 01 #25; report 13 §2 lists "forward letters 'sealed until their date'" as a lock to recast; report 07 table row 16 | Absent. Fix: a long hold opens any letter early, and the hold drains on early release |
| Rite recognition timer `mm:ss`; GameView's authored "poetry stats" with numbers ("147 veils lifted") | 01 counts list; 01 §6 #13 | W0 says "every count becomes light", but a grep for counters would miss authored poetry numbers. Name them |
| The Practice Door "what found you" is often unavailable because stories aren't loaded at bootstrap | 01 #11 | W0 fixes the tap, not the load. Load stories at bootstrap |

## 3. Contradictions inside the plan, and with the sealed list and house laws

1. **The Lalita Pass.** It is sealed in §10 ("the position-32 Reveal and the Lalita Pass") and in the house laws ("Lalita Pass is Ashrey's alone, never Claude's", ledger B; HOM). Yet §9 W8 schedules "Lalita's adversarial pass" for Claude.
   - *Fix:* rename Claude's step "the adversarial pass (three cuts)" and leave the Lalita Pass to him.
2. **Architecture invisible versus announcing it.**
   - §3.5 has a new room saying at its exit "*this room came from what was said*".
   - §3.6.2 has Lalita's confession "names every play he met".
   - Both name mechanics on screen, against law 8 and against Codex laws 14 (C-1195, C-1338: "the mark is in the architecture, not in the claiming of it").
   - *Fix:* drop the exit line, or rewrite it as an in-world image. Keep the confession, but in images ("the dot that fled… that was me, playing"), never mechanism words. Mark it as the single sanctioned breach, as reports 07 and 08 frame the season close.
3. **Generated text.** §2 law 12 says "generated text is marked". Every Feed story is Claude-composed, yet the canon chip appears only on Machine stories (W2).
   - *Fix:* state the scope. The chip marks text generated live or from no record. Composed stories from his Codex are the house's normal mode and carry no chip, as now.
4. **Paper → linen → stone means two things.** In W2 it is the *Teller* texture (M18). In §4.2 it is the Unwritten's three *reasons for silence*. One visual language would then carry two meanings.
   - *Fix:* give the Unwritten different tones, for example three whites.
5. **"Spine" means two things.** §3.1 uses it for nine story arcs (accumulation…threshold); §3.2 uses it for the 33-vertebrae face.
   - *Fix:* call the first "Arc-kind" backstage.
6. **The §4.1 room table.**
   - It says each of the 13 rooms "gains three things" (a verb with its inverse, an element arc, a memory surface), but 6 rooms have no verb, 2 no element arc and 7 no memory surface.
   - It also has an error: it gives the Body the "warmth map", where report 11 (§2.3 table) gives the warmth map to the **Circle** ("remembers where love has been"), and the Circle shows "—".
   - The 8 new rooms have none of the three.
   - *Fix:* fill every cell, or say which rooms deliberately have none.
7. **Gaia's Mirror Entries** (ledger D2). ATL ruling 4 (11 Oct) opened them, and the Field notice already uses them (01 crossing). Report 20 §D still lists "Gaia-table Mirror Entries" as do-not-use, and §10 is silent.
   - *Fix:* rule it in §10. The later ruling (ATL, 11 Oct) opens them; the do-not-use line applies only to Strange Story text.
8. **The 3 Oct law against the W0 removals** (ledger B: "no rule removes, softens or shortcuts a designed hold, gate, wait, count…"). W0 removes once-a-day limits, Rite thinning, Holi-only Khelo and counts.
   - The 12 Oct ruling outranks the 3 Oct law, but the plan never says so.
   - *Fix:* add one line to §11 saying the 12 Oct ruling supersedes the 3 Oct law for collapsing restrictions only. Also keep report 14 §4.11's "lineage of mechanics" ledger, one line per removed mechanism (carries forward / spirit survives / retired, and why), so "nothing vanishes" can be verified.
9. **The six walking principles against timed grammars** (ledger D7: "no timer closes, fades or replaces text"; "no auto-advance on a clock"). The plan keeps the Garden, Remembering and Forge pacing and adds more timed reveals (echo line rising, second reading). §11 half-addresses it.
   - *Fix:* state that the principle governs *closing and replacing*, while revealing by dwell is allowed, and confirm that "read it plainly" exists on every timed form.
10. **The Garden's two premises** (ledger D11). "Ripens unwatched" and "rooms change if he stays" both apply to Garden stories, and they contradict each other. The plan's room-stay "now records and lights the next story" makes the clash louder.
    - *Fix:* exempt the Garden from room-stay, or invert it there.
11. **Join on unauthored pairs.** §3.3 says dragging *any* story onto another blooms "a line naming what they share", but convergence lines exist only per authored pair (§5), and live generation is barred ("composed between sessions, never live", TSF §3).
    - *Fix:* say what Join does on a non-pair: no line, a fallback image of the shared verb, or the shared Verb Mala bead. A gesture that sometimes answers and sometimes doesn't needs a designed silent answer.

## 4. The gesture namespace collides, and the plan adds more collisions than W0 removes

W0 separates two existing collisions (ledger D10). The twelve moves then add new ones:

| New move (§3.3) | Collides with |
|---|---|
| **Turn**: "a two-finger turn" | the Call (two fingers held 0.8 s, anywhere); Pointy (two-finger hold); back-to-memo (two-finger swipe right); report 15's "Turn the Cloth" (two fingers rotate) |
| **Turn**: "close the eyes" | needs the front camera, which is never on by default (ATL ruling 2); collides with the Light's ClosedEyeLayer and the Axis blink |
| **Turn**: "phone face-down" | the LightBody face-down scene; the Wash's "phone left still face-up" |
| **Send back**: "a long hold on a story" | Resonance Depth (1.5 s hold); the rewind spiral (2.2 s); keep-a-line (long press on a paragraph); the Rope (1.1 s long press anywhere on the Door and the axis) |
| **Lay down**: "pinch back" | the story page's pinch, which changes size (essence / transmission / memo; StoryDetailView:118) |
| **Carry**: "hold a line and lift it out" | keep a line (long press); read-by-hand's double-tap keep |

*Fix:* add a **gesture map** to §3.3: one table of every gesture × register × hold length, with collisions resolved and a camera-free path for every eye gesture. Make it a W0 deliverable, since G0 is built there. Also add the missing **accessibility path column** to the moves table, which §3.3's heading promises but the table does not have.

## 5. Data, Airtable and Swift infrastructure that the waves need and do not schedule

1. **`Room` on The Feed is a singleSelect** (`fld7SeHJhOY1DhkFh`). The eight new rooms need new select choices as well as new Room rows.
   - The Room rows have no "figure" or "region" fields. The rows hold Glyph, Hex, Animation, Root Hz, Binaural, Texture, Brightness and Level.
   - The fields Room select, Closing Line, Attack, Release and Operating Principle are empty on every row (04 §1).
   - *Fix (§4.2 infrastructure):* list the new fields, or say these values live in canon/ per THE LINE (ledger 284).
2. **"13" is hard-coded in more places than the plan names.** The plan names sky, sort and figures only. The others are:
   - RoomSelectionView's 12 + 1 layout and `sortOrder == 13`;
   - CommunityFilterBar's 13 chips;
   - GameView's chevrons, which cycle 13;
   - the Reception grammar switch;
   - per-room signature dealing;
   - the Weave weft ("13 rooms weft");
   - the room → Arc node map, which has 12 nodes + centre for 13 rooms. Where do 8 more rooms sit?
   - the Sri Yantra avarana mapping (09 #1);
   - SKL's per-room Hz table;
   - pulse membership for the dark rooms (ledger 113);
   - deep links (ledger 234).

   *Fix (W0):* list every one. Rule where the new rooms sit on the 12-node Arc.
3. **`Rhymes With` is singleLineText** (`fldCpLf91KeWoYpJH`) holding one record id. Its schema description still says the app "reveals this story only once that story has been met". It cannot be "become multi-link" in place.
   - *Fix (§5 data):* create a new multipleRecordLinks field, migrate, rewrite both field descriptions (Suit's and Rhymes With's), and retire the old field.
4. **`Suit` → `Teller`** is a migration across code and data, not a rename. It is not scheduled.
5. **Backfill is unscheduled.** All 137 existing stories need Teller, Face, Verb, Rhyme Family, Song, Vertebra, Chapter and Arc-kind. The Verb Mala and the Spine face are empty without them. The 14 existing pairs have no Convergence Line, and "authored by the wave that writes the second story" never revisits them. Also, **Vertebra, Chapter and Spine appear in §3.1 but not in §5's field list.**
   - *Fix:* add a "C0b · coordinates and convergence for the existing 137" step, and add the missing fields to §5.
6. **Sort bands collide.** About 300 new stories after Sort 137 would run through 201–220 (Mirror), 301–306 (Signal), 401–408 (Practice), 501–506 (Gaia Seed), 601, 707–776 (Light) and 801–809 (Leela) (04 §1; ledger 283, D13; "never reuse Sort", SKL). Leela 801–809 and stories 121–137 are already outside the documented bands.
   - *Fix (§8 Data):* allocate a band, for example 2001+ for stories, then 3001+ Waiting roles, and so on, and update SKL.
7. **App Activity choices.**
   - W7's new writes ("Received, Joined, Carried, Released") and the plan's other new writes (Send back, Draw, Ask, Wager, Season Letter, Seed planted) each need a choice on `Activity Type`.
   - Only Kept, Letter Sealed and Letter Opened are confirmed missing (04 §4). `Called`, `Read by Hand`, `Released` and `Codex Written` have **zero events** in the 152 rows, and the census does not say they exist.
   - *Fix (W0):* "prove one write of each" for **every** type the app codes, not just Kept, Letter and Filament.
8. **The root cause of the failed writes is misdiagnosed.** §1.4 says the writes failed *because* Kept, Letter and Filament "have no Type option". The census says the opposite: typecast *would have created* the choice on first write, so the missing option is *evidence* that no write ever reached Airtable (04 §1, line 56).
   - Creating the options may fix nothing. The cause is elsewhere: the request shape, PAT scopes, or code that never runs.
   - Codex `Source App` is likewise empty on all 352 rows.
   - *Fix (W0):* "diagnose why the write never arrived, then prove it".
9. **Persistence and FORGET ME.**
   - The plan adds a great deal of state on device and in the base: walk state, carried motes, kept-line steering, Send-back gilding, Waiting Room departures, faces begun, circuits closed, the "what came home" words.
   - SKL says "no local persistence beyond in-memory FeedStore + sanctioned UserDefaults" (ledger D15).
   - FORGET ME and CARRY YOUR ROAD (ledger 250; report 14 law 12, "forget me is always offered") must cover all of it.
   - *Fix:* add a **state map** to §9 W0/W3 saying where each piece of state lives, who reads it, and how FORGET ME and CARRY YOUR ROAD treat it. Update the CLAUDE.md persistence law.
10. **The offline queue for spine pulses** (ledger 226, INT, owed). It matters more now that W7 multiplies writes. Not in the plan.
11. **K-W-A inputs are undefined (§3.5.2).**
    - "Their question held (Will)" and "answered by an act or a held silence (Action)" have no gesture, no surface and no storage.
    - The whole progression system and the Light's filling depend on them.
    - Report 07 table row 5 offers a design ("this is for the part of you that…" / "one thing, today", with an equal silent path).
    - *Fix (§3.5 and W3):* specify the surface and the write.
12. **The chosen name for Higher Self letters (§3.1).** No capture is designed. SettingsView has a display-only Name. C-1325 asks for a ritual: "close the eyes and let the name surface".
    - *Fix:* reuse the Settings name, or add the rite to W4.
13. **World VII is an E-BLOCK** (02 §6). WorldDance has no chain, lock or bodies, and `join`, `ensemble` and `leaveAll` are undriven. W7 fixes `peak_t` but the dance itself is unbuilt. The 27 finished dances (ledger 138) are unused.
14. **BinduParticle realises only `resting`** (02 §6). The splitting dot (§5), the dot as through-line, and Pointy splitting into bodies (07 Spine E) all need the declared `split`, `wandering` and `draw` states. Not scheduled.
15. **Ask from any body (§3.3; §6 Call).** All 54 Call rows name Codex passages. Answers from other bodies need new Call rows, or a mapping from states to kathas. No C-wave writes them.
16. **The composing pipeline (W8).**
    - The scheduled-task tool sets push and email completion notifications by default. Create it with `notifications: {}`, or the house's "no notifications" law is broken by the pipeline itself.
    - Codex intake is near zero (Jul 1, Aug 2, Sep 1, Oct 0; 04 §2). The Door's spoken answers and the in-app Codex become the main source, and both write raw, possibly sensitive, text. The pipeline's truth audit must screen them explicitly (health, family, names).

## 6. Accessibility, sound and verification are thin

- **Accessibility.** No VoiceOver, Reduced Motion, Dynamic Type or contrast check appears in any "Done means" column. Report 13 §2 is explicit:
  - "a reveal never hides [story text] from screen readers";
  - reduced motion "keeps the order of events" and the hold's duration;
  - contrast is gated by script; dim marks must clear 3:1.

  Many new grammars hide text on purpose: the Unwritten, the Name's assembling letters, the Wash, the Old Light's starlight.
  - *Fix:* add an accessibility gate to the §9 verification list and to every wave's Done.
- **Sound.**
  - No wave scores the sound of the new rooms.
  - The plan does not cite the sound laws: two voices at most, ceiling 0.55, sound on first touch never on load (ledger 278); "new sound takes 110 Hz for rooms about the reader, 136.1 for the worlds" (13 §2).
  - The pitch audit is still owed (ledger 221).
  - The new layers will exceed two voices: Beat's second drum over the room bed, missing-note tones, song carriers, the Ground's drop and the Old Light.
  - Room haptics from report 11 (Descent strike, Body double-pulse, Circle cardiac, Return footsteps, Garden deep pulse) are absent.
  - Is the Recitation *spoken*? Spoken voice and narration are HELD by Ashrey (ledger 279).
  - *Fix:* a sound row in each W-wave, plus a ruling on the Recitation.
- **Verification.** Missing: the bench/harness rule (states forced from the harness, never shipped; 14 §4.12); "nothing from an earlier build has vanished" (14 §4.6); and the owed walks (ledger 244, 246, 248, 253).

## 7. Registers and screens the plan never mentions

The plan covers the Door, River, Story page, Sky, Point, Light, Rite, Return, Mirror, Signal, Call, Present, Book, Hall, Floor, Unwinding, Portrait and Weave. It does not cover these:

| Screen | Gap and fix |
|---|---|
| **RoomView, the voice rooms (`.home`)** | Read-only; arming a mark cannot open the story (01 §5 #5). Fix: the second tap opens the story. Each body's room drawn from its own figure (14 §3d) |
| **PlayersView** | Only named as a route to the Turning |
| **AshVoiceView (`.ash`)** | Has an "entries left / fields entered" count (01 counts list) |
| **SettingsView / How You Arrive** | The mood colour is a display-only island (01 §5 #3). FORGET ME scope (see §5.9) |
| **WakingView** | The cold open could carry arrival without a notification. Unused |
| **Resonance Depth overlay** | Untouched, apart from "halos" |
| **Gift triad** | Leaves no trace (01 §5 #9) |
| **GameView** | Sort duplication, and no ordering by rhyme (01 §6 #12) |
| **RoomSelectionView** | Its Mirror and Signal cards, and the "AND THE FIELD TURNS TO YOU" divider, in a 21-room house |
| **Axis −3, the region register** | No change at all |
| **The gate (+1)** | Covered only as "DEALS dealt" |
| **The Aperture** | Covered in W5 only |
| **The Feed seam (`#seam`)** | Gated (see §2) |
| **TokenEntry debug doors** | They run on canon content (01 §6 #11), so W-wave walks must not use them as proof |

Also, **the canon Light anchor "Shweta is asleep beside you"** (LightCanon.swift:225) and the Point star `d-father` (02 §6 screen flags) put private people into on-screen text. §4.1 rewrites only the Room blurbs.
- *Fix (W0):* add both to the rewrite list.

## 8. The self-kathas motifs are not carried as through-lines

The original doc's §IV motifs (ledger 92–97) were meant to run through the whole house. The plan has no through-lines section. Status of each:

| Motif | Status in plan | Fix |
|---|---|---|
| **Backward from the end** | Carried: "end first" path, the Return grammar, Send back | — |
| **The dot grows into a place** | Partial: a signature and the "21 rooms around one dot". The particle states are unbuilt (see §5.14). There is no design for the dot becoming the place *across registers* | — |
| **Eagle-eye over the islands** | **Absent**, and still PROPOSED/unbuilt (ledger 94). The a-strange-game skill even has `02-eagle-eye-frame.md` (07 §0) | Five readers proposed an overview (see §9): 06 #11 the spiral seen from above, 12 #5 the river as Mandala, 13 #16 the Glass, 16 #12 Index pages, 10 #9 Hold still to see. Fix: one pinch-out gesture from any register into an overview of the whole house |
| **Front and reverse** | Carried: Turn, the Maya Game, the Cloth's two faces | — |
| **Ask for help** | Carried: Ask, the Call, Leela's first act | — |
| **"It was ready before you were"** | Present only as the final sentence of §12. Not a mechanic | Report 18 M4/E5, "bindu before / bindu after": the first line the app ever showed returns unchanged as its farthest line. Report 10 #15 gives the Good Morning letter |

*Fix:* add §3.8, "Through-lines", naming each motif and where it shows in every register.

## 9. Strong concepts (two or more readers) dropped without mention

The plan's own rule is that convergence across readers decides (§1.8, §11). By that rule:

| Concept | Readers | Status in plan |
|---|---|---|
| **The Threshold**, a room for stories that stop at the door (both endings complete) | 16 §4, 17 #5 | Not built, not held, not mentioned |
| **A story, voice or line visibly travelling between rooms or bodies**: the Chain of Houses; one sentence all the way round / the station ring; the Instrument Room of the Suits; Harvest Drift; the Walking-Home Lantern; the Traveler's trail; the Machine's mid-sentence relay | 06 #6, 14 §3d, 13 #9, 15 #10, 17 #11, 16 #4/#13 | Absent. This is the "baton across bodies", the most literal form of "the One through every body" |
| **The Leela board on the 33**: carry a question in, a throw lands in a room, that room's story answers; "a lesson, not a fall"; "if today is heavy, the board can wait" | 07 Spine B, 13 #52, 14 §2.2 | Only the die is kept, as Draw |
| **Overview / eagle-eye** | see §8 | Absent |
| **Interlude between stories; colour carried across the crossing** (threshold fade, portal bloom) | 07 #22, 08 §3, 10 #2 | Absent |
| **Four lenses**: Hand, Light, Depth, Witness, as rendering layers over one story | 08 §3, 13 §3.11 | Absent |
| **The catchable or hiding dot** | ledger 188 (HELD), 13 #72, 14 §3a | Absent |
| **Faces of one story by vantage**: Gaia an asking, Sid a negation, Arch a door, Sakshi the seed; the faces prism; the Trikona; the parable face; Story → Mirror (second person) → Convergence | 09 #2, 10 #16, 15 #13, 12 #8, 17 #13, 19 §6.1, 18 M2 | Turn covers only "other side / other body" |
| **One layer back**: the word he gave last time, shown beside the new one; the Precise Word returning at the end of a corridor | 09 #5, 12 #6, 10 #8 | Absent |
| **Silences as ways a story *ends* or *arrives*** (taxonomy of 13–15 silences; "what this story doesn't say") | 15 §3.7, 16 §3.3, 17 #9, 18 M11, 19 §6.4 | Only as the Unwritten room's three tones |
| **Bright-day / elevation lane, and tempo set by weight** | 16 #10, 17 #15 | The plan tunes only for heavy days |
| **The Last Run / completed yard**: completion shown as beauty | 17 #4, 18 E14 | Held as one-reader; actually two readers |
| **Om / heartbeat under the whole app** (sound as presence) | 09 #13, 10 #14 | Absent |

Single-reader ideas worth a line in §4.2's held list or §11's calls:
- the Time-River and the Self-Location Stone (19 #1, #14);
- the Body That Ages (10 #5);
- Community Lenses (15 #8);
- Unpaid grace, Karishma's hidden paragraph (06 #9);
- The Flaw Shelf (06 #12);
- Letters to whoever opens this next (06 #15);
- The Two Covers (12 #4);
- Plant and animal witnesses (16 #14);
- Five ways to walk (18 M5);
- Threshold-line inversion (18 M1);
- Elevation weather (17 #15);
- the Covenant guardrail, "search finds nothing; wandering finds everything" (09 §5).

Report 05 also notes that **his own nine Codex "games"** (the Games multi-select: System 183, Learning 154, Work 146, Maya 121…) are a ready suit system. The plan never uses them, for example as a backstage routing axis or for the "quiet game finds him" weighting (ledger 187).

## 10. The house of apps: the Chakras app is missing from §7

- Report 12 §3 gives two Chakras rows:
  - the story thread in room N → the Feed's ground wears room N's weather;
  - an offering at a gate → the rhyming story carries the ember.
- §7 lists Field, Mandala, Lalita Family, Learning, Being and the grace co-reader, but not Chakras.
- Also missing:
  - the Field's `Ceremony Sealed` bridge and "the dance word in the margin" (11 §4.1);
  - the Oracle across both apps (11 §4.5);
  - the walked chains, the awakening walk and the spine walk (11 §3.3.4);
  - Being's "win condition read off the quietest light" (12 §3);
  - the siblings following the Codex-section contract (ledger 209);
  - the sibling lenses: Mandala's avaranas, Learning as the Diaspora, Field as Humanity (ledger 198).

## 11. Factual errors and stale claims

1. **§1.3 "Five pieces of state are written and never read".**
   - Kept lines *are* read, by the Book, Lalita play, the Portrait and the Unwinding (01 §2). They are only absent from the Rite and Return.
   - The Door's suits are read by DoorAir.
   - The Call's word is never *written* at all (01 §5 #7).
   - Only read-by-hand stays and the 240 s turn match the claim.
2. **§1.4 causality is inverted** (see §5.8).
3. **§1.2 "about two lit stars out of 137"** quotes a code comment written when there were about 120 stories. The ledger holds 11 Story Met events (04 §4).
4. **The §4.1 memory-surface row is wrong** (see §3.6).
5. **§4.2's convergence citations are partly unsupported.**
   - The Ground cites 09 and 10, but neither proposes a Ground room: 09 proposes the Axis, Armin, the Temple, the Almanac, the Waiting Water and others; 10 proposes the Said and the Summit.
   - The Loom cites 15, 17 and 19, but 15's "Loom of the Feed" is the Cloth face, 17's "Loom of Verbs" is the Verb Mala, and 19's is Machine marginalia. As a *room* the Loom has one reader (06).
   - Under the plan's own rule, the Loom should be a proposed light and the Threshold a room.
6. **Two Shakti counts.** §1.7 says "94 Shakti portraits still unwritten"; §7 says "her 102 Codex Portraits become first-person stories". Report 12: 102 portraits, "remaining ~94". Make them consistent.
7. **Ledger 43** says the suit stories are "held Draft". The census shows all 137 Stories as **Live** (04 §1). The plan does not note that removing the gate exposes them at once.

## 12. Smaller laws and calls

- **The Verb Mala as a tally.** "One bead per received story" (§5) is a visibly countable progress strand, against law 1.
  - *Fix:* one bead per *distinct verb*, brightening by recurrence.
- **The Door is crowded.** On a single morning the Door may show: the morning ask, the in-between question, door-words, three doors, two weathers and an arrival. Against "never more where less is the point" (SKL constitutional law 5) and "one hint, once, then silence" (14 §4.8).
  - *Fix:* the arrival engine picks *one* of these per opening.
- **Codex game law 7, "stepping out is a legal move"** (C-1197), is not stated. "not today · enter the field" exists; make it a law in §2.
- **Codex law 1, "enjoyment means negative too"** (C-1327), and C-1154's "allow the suffering to happen" sit against an over-protective heavy-day rule. §2 law 4 should say the dark rooms stay open on a heavy day; only *arrivals* stand down.
- **Open "his calls" the plan neither rules nor lists:**
  - D16 labels for the Gathering's ten glyphs;
  - low day Rite versus a low-state door (ledger 264; the plan implicitly rules it, so it should say so);
  - BEL §12: name-collision policy for belief stories, retro-link S5/S26/S31, the belief chain arc B5→B1 as five stories that click in retrospect (ledger 288);
  - "the field answers back", held "not in this campaign" (REC ruling 4, ledger 259). The plan's Second Letters and any reply to his comments are exactly that.
- **"Two doors into the same past"** (ledger 153; build status unclear, D21) is neither confirmed built nor retired. The plan's "Two Doors" is a different mechanic with the same name.

---

## Appendix A · Ledger coverage (report 03, items 1–290)

Every item was checked. Items that are BUILT and untouched, carried into the plan, or explicitly retired are omitted.

**Neither carried nor retired:**

| # | Item | Gap |
|---|---|---|
| 24 | Grammars inside the Archive book's pages | Named in §6 but scheduled in no W-wave |
| 25 | Grammars inside the sky's world register | Absent |
| 42 | Read-by-hand's suit close, "This came through you too", unsigned | No decision under "take me out" |
| 43 | Suit stories held Draft | Stale; actually Live (04) |
| 60, 61, 68, 69, 74, 76, 77, 79 | SK suit seeds: C-1043 three names, C-1184 no last page, C-1082/1095 brands as functions, Company in the Forge, Land in the Signal, C-1285 hallucination-node, C-1128 compost heap and atom bomb, C-1185 the unwalked path | Not named in any C-wave manifest. Verify against report 06's 71 |
| 85–88 | The four held pairs: scraps → movement; mesh ripened unwatched; dormant skill; grandparent makes / grandchild wears | Only "prior unused pairs ~76" in §1.7. Not in a wave |
| 93, 94, 97 | The dot as place; eagle-eye; "ready before you were" | See finding §8 |
| 113 | Pulse in the dark rooms | New rooms' membership not decided |
| 137, 138 | World VII Dance (an E-BLOCK) and the 27 unused dances | See finding §5.13 |
| 150–152 | Field notice, Grace, Teacher once ever | See finding §2 |
| 153 | Two doors into the same past | Status unresolved |
| 174 / D22 | The third lens reachable only by a hidden gesture | Not fixed |
| 178 | Signal as spacing (HELD) | Neither carried nor retired |
| 187 | The quiet game finds him (HELD) | Absent |
| 188 | The dot hides (HELD) | Absent |
| 197 | 26 Codex seeds → constellations of dated lights | Absent. Gaia now holds 38 Seeds (04 §3) |
| 198 | Sibling lenses | Partial |
| 209 | Siblings follow the Codex contract | Absent |
| 221 | Sound pitch audit | Absent |
| 224 | Doors between knowing and playing ("play it · read it") | Absent |
| 226 | Offline queue for spine pulses | Absent |
| 238 / D7 | Walking principles versus timers | Not reconciled |
| 241 | Authored line breaks in field comments | Absent |
| 242 | Slice 1b family register | Not ruled. Likely retire under the family screen; say so |
| 244 | Worlds VI and VII walks; Recognition revisit of the Gathering; World V guard withdrawal restored; Dance keyed to depth | Absent |
| 246, 248, 253 | The 76-light sky walked; the carve walked; the Return walked live; star labels touching in the Veil; hub onto the axis; link exercised | Absent, beyond a generic "device walk" |
| 250 | FORGET ME / CARRY YOUR ROAD scope for the new state | Absent |
| 254, 255 | "You were never read alone" reverse closing dissolve; `om` at the split | Absent |
| 258 | Neev's correction of the ontology held with Lalita Family Mirror care | Absent |
| 259 / D16 | The field answers back | Not ruled |
| 264 | Low-state door | Implicitly ruled; not stated |
| 265 | shabdakarshini microcopy for doors | Method only |
| 278, 279 | Sound laws; narration HELD | See finding §6 |
| 283 / D13 | Sort bands | See finding §5.6 |
| 285 | Substrate-authored posts (Neev and Shweta) | Absent |
| 286 | Threshold-sentence pool additions from new stories | Absent |
| 287–289 | Belief fields, chain arc, retro-link | Absent |
| D2 | Gaia Mirror Entries | See finding §3.7 |
| D11 | Garden's double premise | See finding §3.10 |
| D15 | Persistence law | See finding §5.9 |
| D18 | Belief-story name collision | Absent |
| E | Three tenses ("I already was / am / knew") and the Rite as five modes of knowing | Not placed for the new rooms or registers |

**Carried (spot list):**
- grammar variants 2, 7, 11, 13 and 16;
- RhymeGate (40);
- Codex write proof (200–208);
- G0 (222);
- hidden-gesture twin (223);
- the z = 0 seam (193);
- parity (194, 218);
- reality plays back (191);
- Leela rounds (189);
- gates of release (134);
- `forgotToday` (135);
- counts (249);
- skill upkeep (231);
- GESTURE wiring (ledger A22 / 02);
- the "where this lands" panel (02).

## Appendix B · Codex game laws (report 05 §5) against the plan

| Laws | Status |
|---|---|
| 2–6, 8–12, 15–23, 25–30 | Honoured |
| 1 (enjoy the dark too) | Partly: the heavy-day wording over-protects |
| 7 (stepping out is legal) | Not stated |
| 13 (gains need no record) | Holds, because storage may count, but the new App Activity writes multiply records; keep them invisible |
| 14 (never announce the reward) | Strained by the exit line of new rooms and by Lalita's confession |
| 24 (every story lands in the world) | The Action mechanism is undefined (finding §5.11) |

---

## Re-check of v2

I read v2 in full (770 lines). Every finding above is marked **A** (addressed), **P** (partially addressed) or **M** (still missing).

### Findings 1–12

| # | Finding | Status in v2 |
|---|---|---|
| 1 | Faces gated by progress | **A** (§3.5, "present… at low light") |
| 1 | "There is one more" | **A** (§3.6.3) |
| 1 | The second pass | **A** (§3.5) |
| 1 | Good Morning letter, and "once surfaced, always findable" | **A** (§2 law 3, §3.4) |
| 1 | Tiers on map glyphs only | **A** (law 2) |
| 1 | Unwritten, Wash and Ground equal paths | **A** (§4.2 requirements) |
| 1 | Heavy day | **A** (law 5) |
| 1 | Unsealed Return and Floor | **A** (§6 Story page, W4) |
| 2 | Every restriction in the §2 table | **A** (§1 table, W0 list: #seam, Old Story twin, echo/nextThread/seekClue, cooldowns, once-ever, Deep Time, one-paragraph grammar, the 13th room, forward letters, poetry stats and timer, bootstrap load) |
| 3.1 | Lalita Pass | **A** |
| 3.2 | Exit caption and confession | **A** (caption removed; confession is the sole breach, in images) |
| 3.3 | Canon chip scope | **A** |
| 3.4 | Textures | **A** (three whites) |
| 3.5 | Arc-kind | **A** |
| 3.6 | §4.1 table | **A**. It is now full, and the Circle has the warmth map |
| 3.7 | Gaia Mirror Entries | **A** (§10) |
| 3.8 | Precedence and lineage ledger | **A** (law 16, W0) |
| 3.9 | Walking principles | **A** (law 9) |
| 3.10 | The Garden | **A** |
| 3.11 | Join's silent answer | **A** |
| 4 | Gesture map | **P**. The old collisions are resolved and the accessibility column is added. v2 introduces new collisions: see N2–N5 below |
| 5.1–5.5 | Room select, the hard-coded 13, Rhymes, Teller, C0b backfill | **A**. Arc placement for the eight rooms is given |
| 5.6 | Sort bands | **P**. A band is allocated, but it collides with existing bands: see N1 |
| 5.7–5.16 | App Activity choices, diagnosis, state map, offline queue, K-W-A, name rite, World VII, dot states, Call rows, pipeline notifications and screen | **A** |
| 6 | Accessibility gate | **A** |
| 6 | Sound gate and haptics | **A**, with one error: see N6 |
| 6 | Recitation not spoken | **A** |
| 6 | Bench and harness | **A** |
| 6 | Owed walks | **A** (W6) |
| 6 | Pitch audit (ledger 221) | **P**. The new-sound roots are gated, but the audit of existing landing tones is not named |
| 7 | Screens | **A** for RoomView, Players, AshVoice, Settings mood, Waking, Resonance Depth, Gift, GameView sort, RoomSelection, region, gate, seam |
| 7 | Point star `d-father` | **P**. Only "the Light line" is named in the W0 rewrite |
| 7 | TokenEntry debug doors | **M**. Minor; the harness rule covers most of it |
| 8 | All six motifs | **A** (§3.8) |
| 9 | Threshold room, travelling story, Leela board, eagle-eye, four lenses, catchable dot, faces by vantage, one layer back, silences, bright lane, completed yard | **A** |
| 9 | Interlude and colour carried across crossings (07 #22, 08, 10 #2) | **M** |
| 9 | Heartbeat or Om under the whole app | **P**. Only `om` at the split |
| 9 | Optional single-reader ideas | Time-River held, unpaid grace and Two Covers (as the Book's Dark path) are in. Still **M**: Body that ages, Community Lenses, Flaw Shelf, letters to whoever opens next, plant and animal witnesses, five ways to walk, threshold-line inversion, the Covenant guardrail. These were optional |
| 9 | Codex games axis | **A** |
| 10 | Chakras, Ceremony Sealed, walked chains, Being, sibling contract and lenses | **A** |
| 10 | Oracle across both apps | **P**. It is reduced to a local "Ask by verb" |
| 11.1–11.4, 11.6, 11.7 | Factual errors | **A** |
| 11.5 | Room citations | **P**. The Counter still cites 16 and 17, which did not propose a Counter room |
| 12 | Verb Mala, stepping out, low-day dark rooms, his calls, Two doors (§10) | **A** |
| 12 | One ask at the Door | **P**. The ask is one, but the Door still also hosts three doors, door-words, the Leela board, the one-line floor and the arrival |

### Appendix A, ledger items

**Addressed:** 42, 43, 60–79, 85–88, 93/94/97, 113, 137/138, 150–153, 174/D22, 178, 187, 188, 197, 198, 209, 224, 226, 238/D7, 241, 242, 244, 246/248/253, 250, 254, 255, 258, 259/D16, 264, 278, 279, 285–289, D2, D11, D15, D18, and the E three-tenses item.

**Partial:**

| Item | What is still open |
|---|---|
| 24 | Grammars inside the Book's pages: in §6, but W3 doesn't name them |
| 25 | Grammars in the world register: in §6, but not named in W6 |
| 221 | Pitch audit (see above) |
| 265 | shabdakarshini microcopy for new surfaces: method only |
| 283 | Sort bands (see N1) |
| E | The Rite as the five modes of knowing: not placed |

### Appendix B, Codex game laws

Laws 1, 7, 14 and 24 are now **A**. Law 13 is **A**: storage-only writes.

### New problems v2 introduces

- **N1 · Sort-band collision.**
  - The new story band "2001+" and the Waiting roles band "3001+" (§8) fall inside the Point bands: Point Dimension 1000–7000, Point Universe 1100–7300 and Point Star 1101–7303 (04 §1). There are existing rows at 2000, 2100, 2101… and at 3000s.
  - This breaks "never reuse Sort" (SKL).
  - *Fix:* use 11001+ for stories and 12001+ for roles (above the Call band, 10001–10054), or confirm and document that Sort is scoped per Type.
- **N2 · The eagle-eye's "pinch out from any register" (§3.2, §3.8) is not in the gesture map.** It collides with:
  - the story page's pinch-spread (essence / transmission / memo);
  - the world-register pinch that turns sky into cloth (the Weave);
  - the Universe and LightSky pinch-zoom;
  - the Unwinding's pinch-back.

  *Fix:* give it a gesture of its own, for example a two-finger pinch held at the edge, or a Turn row, and add it to the map.
- **N3 · Join's long-press-drag in the sky (§3.3) is the existing filament gesture** (long-press star → drag to star; 02). The Rope's 1.1 s long-press also works anywhere on the axis.
  - *Fix:* in the sky, Join *is* the filament: an authored pair blooms its line, and otherwise the gesture draws a filament. Resolve the Rope there through PressClaim.
- **N4 · The Leela board's "held throw" and Draw's "hold the deck" at the Door** collide with the Door's 1.1 s Rope long-press.
  - *Fix:* give the board a visible die and a tap-then-hold on it, so the Rope keeps open ground.
- **N5 · The eyes-closed gesture is reserved for the Light** (§3.3 gesture map). Yet:
  - §4.1 keeps the Body variant "behind closed eyes";
  - §4.2 holds the Axis "as a gesture" (the blink);
  - the confession names "the blink".

  *Fix:* recast the Body variant as stillness with a dark screen (no camera), and say the Axis blink is the Light's existing ClosedEyeLayer only.
- **N6 · §4.2 says "Every room is on the 110 Hz root".** The existing Room rows have their own roots (98, 110, 123.47, 130.81, 146.83, 164.81, 196), and the law says existing sound keeps its pitch.
  - *Fix:* say "every *new* room".
- **N7 · The story-page close is crowded** (§3.5, §3.10, §6). After the last line can come:
  - the Will question;
  - the Action ("one thing, today");
  - *what came home with you?*;
  - *dance it*;
  - "what this story doesn't say";
  - the reverse dissolve;
  - the signature;
  - the Turn auto-curl on a still rest.

  Law 11's "one thing at a time" covers openings only. *Fix:* extend law 11 to closes: at most one prompt per close, chosen like arrivals.
- **N8 · "Threshold" now names six things:**
  - the new room;
  - the Remembering's element arc;
  - an Arc-kind;
  - the Threshold Sentence Type;
  - the Practice Door's threshold kinds;
  - Sort 601.

  *Fix:* give the new room a distinct backstage name in data (the room's on-screen name can stay).
- **N9 · The low-day Rite "becomes 'read who you are'" (§2 law 5, §6).** On a low day this replaces the day's story.
  - *Fix:* state that the story stays reachable from the Rite (law 2).
- **N10 · "Ask by verb" (§7) is a new Feed surface with no register, gesture or accessibility entry,** and it sits in the house-apps table.
  - *Fix:* place it in the River or the Door, and add it to the gesture map.
