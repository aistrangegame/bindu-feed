# The Many-Bodied Game — the shared contract

*Written 12 Oct 2026. Binding on both build tracks. When this file and GAMEPLAN.md disagree, this file wins; when either disagrees with a house law in `Bindu Feed/CLAUDE.md` §10, the house law wins and the conflict is written into `DECISIONS.md`.*

The plan is `GAMEPLAN.md` (this folder). The 20 reader reports and the adversarial review it was built from are in `readers/`. The 137 existing stories are in `content/feed-stories-137.txt`.

---

## 1 · Two tracks, one game

| | Track 1 — the cloud session (Claude, claude.ai) | Track 2 — Claude Code on the Mac (`~/Bindu Feed`) |
|---|---|---|
| Owns | Airtable **data and schema**; every story and child; `scores/`; `content/` manifests; review of Track 2's commits | All **Swift**; `Tools/`; `canon/`; `Bindu Feed/CLAUDE.md`; `rendered-strings.tsv`; Simulator walks; the single install on Neev |
| Writes in git | only under `Coverage/many-bodied/` (never Swift) | everything else, plus `Coverage/many-bodied/STATUS.md` and `DECISIONS.md` |
| Never | edits Swift; installs | writes story text or Airtable records by hand (except the W0 write-proof rows, §6); asks Ashrey anything |

- Both push to `main`. Always `git pull --rebase` before pushing. No force pushes.
- **Ashrey is the experiencer, not the reviewer.** Nobody asks him questions, sends him builds, screenshots or progress. He receives the whole piece once, on Neev, with one line and no spoilers (GAMEPLAN §9 "Delivery").
- Track 2 does **not** install on Neev until W8's final walk is green. The current install (main @ 275eabd) stays on his phone until then.
- A question Track 2 cannot answer from the plan, the score or the readers: decide by the house laws, write the call and the reason in `DECISIONS.md`, and keep going. Track 1 reviews `DECISIONS.md` and either agrees or writes a correction into the next score.

### The rhythm
1. Track 1 writes `scores/W<n>.md` (five tracks: scene · sound · gesture · motion · logic, plus "Done means") **before** Track 2 starts that wave.
2. Track 2 builds the wave as Slices, each slice its own commit(s) with the slice number in the message, runs `Tools/verify.sh` (seven checkers green) and the wave's Simulator walk.
3. At the end of each wave Track 2 appends to `STATUS.md`: wave, commits, what the walk showed, every "Done means" line with its evidence (grep output, Simulator screenshot path under `Coverage/many-bodied/evidence/W<n>/`), and anything left owed.
4. Track 1 reviews, writes fixes into the next score's "Carried from W<n-1>" section.
5. Content waves (C0–C6) land in Airtable on their own clock. The app must render gracefully whatever is or isn't there yet.

---

## 2 · Airtable — base `app248ZTWhYJlvQj2`

Write rules (unchanged): field IDs in code, `typecast: true`, batches of ≤15, `Status` = `Live` for anything meant to be seen (the blank-Status lesson, CLAUDE.md §6). **Never delete anything** — retire by marking OLD.

### 2.1 The Feed `tbl7vzODMMJUgeX0b` — new fields (created 12 Oct 2026)

| Field | ID | Type | Holds |
|---|---|---|---|
| Rhymes | `fldAFBBdsItsIvJVY` | link → The Feed | the stories this one rhymes with |
| Rhymed By | `fldzjmIBqnx1sgAOR` | link (inverse of Rhymes, automatic) | read both; a pair is linked on one side only |
| Teller | `fldlweZWL4uAr9ZTB` | singleSelect | His Memo · Cloth · Company · Land · Machine · Lineage · Maker · Customer · Cosmos · Song · Shakti · Body · House · Object · Time · Silence |
| Face | `fldfT6sD1gYJ1typL` | singleSelect | Bindu · Sakshi · Lalita · Gaia · Higher Self |
| Verb | `fldiOePQsVg2qyKFs` | text | one present-tense verb, lowercase |
| Rhyme Family | `fldksnbOZZ5IBhqjx` | text | lowercase-hyphen key, e.g. `ready-before` |
| Convergence Line | `fld89bY7r1MS9OcLZ` | long text | on the **host** of a pair (and on a story whose Mirror Line has one) |
| Mirror Line | `fld9y2IDeMHM3rYjp` | long text | the second-person Mirror face; "you", never his name |
| Song | `fldcEhY09Ni9Tao7o` | link → Bindu Field `tblv3WvMZ90Sfhun6` | inverse on Bindu Field: `fldbLpx57LJoYXlwu` |
| Vertebra | `fldPBvnxPKN0gZLT6` | number 0dp | 1–33 |
| Chapter | `fldjt8Z3tV89yItWq` | singleSelect | Great Split · Stepping Stones · Architects · Lemuria · Atlantis · Diaspora · Long Forgetting · Mirror Race · Awakening · Splitting Prism · Introduction · Reunion · Centre (= UniverseView `arcOrder`) |
| Arc-kind | `fldnyhqTvijcMUIgg` | singleSelect | Accumulation · Rhyme · Activation · Inversion · Cartography · Recognition · Return · Synthesis · Threshold |
| Codex Game | `fldvTKgKZF63ySyxy` | singleSelect | System · Learning · Work · Maya · Family · Health · Social · Seva · Fire |
| Shakti | `fldsjkiGt4vG3kjSu` | link → Mandala `tblrRwXJD0uP8HU8G` | the Shakti this katha is (Teller = Shakti); inverse on Mandala `fldFvmoomlj53BiiM` |

All of these are **backstage**. None of their names or values ever appears on screen (GAMEPLAN §2: no suit, grammar, signature, chakra, chapter, position or mechanism words). Every one may be empty on any record; the app treats empty as "unknown" and falls back, never hides the story.

### 2.2 Retiring (not deleting)

| Field | ID | Now | When Slice 16 ships |
|---|---|---|---|
| Suit | `fldROWFIDFHyfdOxp` | still read by the installed app **by name** (Models.swift CodingKeys) — so its name must not change yet. Description says TO BE OLD | the app reads `Teller` (falls back to `Suit`). Track 1 renames the field `Suit OLD` only **after the W8 build is installed on Neev** |
| Rhymes With | `fldCpLf91KeWoYpJH` | same | the app reads `Rhymes` ∪ `Rhymed By` (falls back to `Rhymes With`). Renamed `Rhymes With OLD` only after the W8 install |

**Lesson recorded:** the Feed fetch decodes by field *name* (no `returnFieldsByFieldId`). Renaming any field the shipped app decodes breaks his phone silently. Track 1 never renames a field the current install reads. Track 2: in W0, move the main fetch to decode by field **ID** (`returnFieldsByFieldId=true`) so names become free to change; record it in CLAUDE.md §6.

### 2.6 Content conventions settled during C0–C3
- **Story Origin** has only `Codex` and `Belief`. Every new story uses `Codex`; a story told from a memo carries its `Codex ID`, a story told from the skills/readers leaves `Codex ID` empty. That emptiness is how the two are told apart — no new choice.
- **Closing Line** repeats the body's last paragraph (house convention), except where the room's form forbids a fifth paragraph (the Stack's four bands): there it is stored but not repeated. Grammars that move the landing line (the Ground's *before the drain*) must not show it twice.
- **Swatches link to their host through `Rhymes`.** `RhymeIndex` (W1) excludes `Type = Swatch` partners from rhyme pairs; the Swatch arrival (W5) reads them.
- **Marks in use** (scores/W2.md §1.4 plus): `⟪watch: …⟫` (W4 wager's watch-for) · `⟪one more⟫` (W3; one per teller with ≥3 stories — already on His Memo, Cloth, Company, Machine, Land, Object) · `⟪will: …⟫` / `⟪act: …⟫` (W3 circuit) · `⟪ask: …⟫` (W7, stories with a Song) · `⟪telling⟫` (W6 waiting tellings) · `⟪then: …⟫` · `⟪held: …⟫`.
- **Letter seals:** the Good Morning letter carries `WHEN: before` (W5).
- **Existing stories with screen flags** (story 81 title names a city, 44 a retailer, 106/109 family crisis, 74 a relative, 72 substances/teachers, 76 a soul-name, 3 a host family and a comment naming a city; backstage fields of 118 and 120; stories 20 and 25 hold family material) — recorded, not edited. They are Live; any edit waits for delivery day (content/DELIVERY-DAY.md) and only with Ashrey's word, because they are his.

### 2.3 Staged — the single-delivery law in the data
The build on his phone loads every `Live` record. So **every new record this game creates that is meant to be seen — new Room rows, new stories and their children, Waiting Roles, Interludes, Leela drops — is written with `Status` = `Staged`**, not Live. The installed app ignores Staged; Track 2's builds read `Live` ∪ `Staged` (DEBUG and the W8 release alike). On delivery day, after the W8 build is installed on Neev, Track 1 flips every Staged record to Live in one pass. Staged is a delivery hold, not a gate: nothing in the new game ever reads Status to hide a story from him.
- The eight new Room rows (record IDs in `scores/W2.md` appendix) are Staged.
- C0's dressing of existing stories (children, Lalita replies, Resonance Voices) was written Live on purpose: it completes stories he already has, in the form he already knows.
- Backstage coordinate fields (C0b) are invisible to the installed app and need no hold.

### 2.3a Select choices
- **Room** (`fld7SeHJhOY1DhkFh`) gains eight choices, created by typecast when Track 1 writes the eight Room rows (before W2): `The Ground` · `The Unwritten` · `The Stack` · `The Counter` · `The Wash` · `The Name` · `The Old Light` · `The Fold`. These exact strings are the **canon keys** for the rooms in Swift and in `canon/`.
- **Type** (`fldfFRjyasZWodvQC`) gains, by typecast when first written: `Waiting Role` (C6), `Leela` already exists, `Swatch` (three-line arrival stories, C3+), `Interlude` (W0's crossing interlude lines). No other new Types without a line in this file.
- **App Activity · Activity Type** (`fldXNRBZy6QvIP8yz`) currently has: Chapter Completed · Ceremony Sealed · Wager Resolved · Shakti Recognized · Letter Written · Ash Replied · Story Resonated · Story Met · Walk Completed · Veil Lifted · Silence Held · Ring Crossed · Reach · Return · Been Here · Share With · Note · First Dwelling.
  - **Coded but never landed** (no choice exists, no row exists): `Called` · `Read by Hand` · `Kept` · `Letter Sealed` · `Letter Opened` · `Codex Written` · `Released`. Diagnosis (12 Oct): these paths were added 11–12 Oct (a805cc2, 85d5c48, 6579bef, 9690eaa) and **never exercised** — not a proven failure. W0 proves each one (§6).
  - **New in this game** (W3/W7): `Received` · `Joined` · `Carried` · `Circuit Closed` · `Sent Back` · `Drawn` · `Asked` · `Wager` (the wager *made*; `Wager Resolved` is the return). `Released` is shared with the Unwinding.
  - All rows from the Feed carry `Source App` = `Feed` and, where there is one, `Link to Feed` (`fldAgxERs4MnPvuGJ`).

### 2.4 Sort bands (`Sort Order` `fldKAIGO9RHV235go`)

| Band | Holds | Owner |
|---|---|---|
| 1–40 | Room rows (13 existing = 1–13; the eight new = 14–21, Old Light last closing the ring onto A Maya Game; 22–40 only for rooms that ripen from the Lalita loop, W3) | Track 1 |
| 1–137 | the existing stories (unchanged) | — |
| 801–809 | existing Leela rows (unchanged) | — |
| **810–899** | new Leela drops (W4 board rises 810–817 with Excerpt line `KIND: rise`; C5 round 2 after) | Track 1 |
| 1000–7303, 9001–9137 | the Point (unchanged) | — |
| 10001–10999 | Call rows (existing 10001–10054; C5 body answers continue from 10055) | Track 1 |
| **11001–11999** | **new stories** (C1 = 11001–11085; C2 from 11101, C3 from 11301, C4 from 11501, C5 from 11701, C6 from 11901) | Track 1 |
| **12001–12999** | **Waiting Roles** (Type `Waiting Role`) | Track 1 |
| 13001–13099 | the new Room rows' children, if any need a band | Track 1 |
| 13101–13199 | Interludes (Type `Interlude`, W0) | Track 1 |
| 13201–13299 | Veil rows — the Mirror's year of veils (`Card Register` = `Veil`, W6) | Track 1 |
| 13301–13499 | Second Letters (Type `Second Letter`, W4) | Track 1 |
| 13501–13699 | Swatches (Type `Swatch`, W5) | Track 1 |
| 13701–13799 | authored Letters (Type `Letter`; the Good Morning letter = 13701, seal `WHEN: before`, W5) | Track 1 |
| 13801–13999 | Constellations (Type `Constellation`, Gaia-seed constellations, W6) | Track 1 |
| 14001–14999 | Planted Seeds (Type `Planted Seed` — one Type for W6's planted seeds and W8's pipeline plantings) | Track 1 / pipeline |
| 15001–15999 | pipeline overflow and set-aside records (W8) | pipeline |

**Reconciliation (12 Oct, after W3–W8 were scored in parallel):** W4, W5, W6 and W8 each proposed overlapping 13xxx/14xxx bands and W8 named its seed Type `Planted`. The table above is the one truth: Second Letters moved to 13301–13499, Swatches to 13501–13699, the Good Morning letter to 13701, Constellations to 13801–13999, and `Planted` is `Planted Seed`. Where a score says otherwise, this table wins.

### 2.4a Types this game adds (all written Staged; choices created by typecast on first write)
`Interlude` · `Swatch` · `Waiting Role` · `Second Letter` · `Constellation` · `Planted Seed` · (`Letter` already exists — the app writes it). `Card Register` gains `Veil`.

### 2.4b Activity Types still to be created (by typecast, on the app's first write)
`Called` · `Read by Hand` · `Kept` · `Letter Sealed` · `Letter Opened` · `Codex Written` · `Released` (W0 proves) · `Circuit Closed` (W3) · `Wager` (W4; `Wager Resolved` exists) · `Received` · `Joined` · `Carried` · `Sent Back` · `Drawn` · `Asked` (W7, or earlier where a wave writes them). Every read of `Walk Completed` also checks `Source App` (the Feed's own Point walks use that type too).

Children (Field Comment / Resonance Voice) keep using `Comment Order` under their parent, not Sort Order.

### 2.5 Content each new story carries
`Name` (title, last) · `Body` (may carry the `⟪…⟫` content marks defined in `scores/W2.md` §1.4 — the only place structure inside a story lives) · `Source Date` (the Book needs one) · `Excerpt` · `Room` · `Type`=Story · `Status`=Live · `Sort Order` (band) · `Teller` · `Face` · `Verb` · `Rhyme Family` · `Rhymes` (if paired) · `Convergence Line` (host) · `Mirror Line` · `Vertebra` · `Chapter` · `Arc-kind` · `Codex Game` · `Codex ID` / `Trigger Codex Entry` where it came from a memo · `Story Origin` · five children (Field Comment rows linked by `Linked Story`, with `Archetype`, authored line breaks). `Song` is filled in C5.

---

## 3 · The rooms — 21, one ring around the dot

Canon key = the `Room` choice string. Identity (name, glyph, hex, Hz, blurb) lives in the base on the Room row; grammar, figure and sky region are authored once in canon/Swift keyed by name (THE LINE). **An unknown room string renders with a neutral fallback grammar** (one-paragraph grammar + read-it-plainly), never crashes, never hides.

| # | Canon key | Verb · inverse | Root | New? |
|---|---|---|---|---|
| 1 | A Maya Game | dissolve · appear | own Hz | |
| 2 | The Garden | follow · stop chasing | own | |
| 3 | The Watcher | still · move | own | |
| 4 | The Descent | look · arrive | own | |
| 5 | The Return | receive · offer | own | |
| 6 | The Forgetting | shed · wear | own | |
| 7 | The Remembering | hold · release | own | |
| 8 | The Body | press · lift | own | |
| 9 | The Thread | trace · tie | own | |
| 10 | The Circle | open · fold back | own | |
| 11 | The Signal | speak · silence | own | |
| 12 | The Forge | build · be still | own | |
| 13 | The Field | pass · receive | own | |
| 14 | The Ground | fall · rise | 110 | ✓ |
| 15 | The Unwritten | still · move | 110 | ✓ |
| 16 | The Stack | press down · rise | 110 | ✓ |
| 17 | The Counter | cut · hand back | 110 | ✓ |
| 18 | The Wash | wash · wring | 110 | ✓ |
| 19 | The Name | say · trace | 110 | ✓ |
| 20 | The Old Light | watch · let pass | 110 | ✓ |
| 21 | The Fold | turn over · leave folded | 110 | ✓ |

Grammars, memory surfaces, haptics, arc placement: GAMEPLAN §4.1–4.2. Everywhere "13" is hard-coded becomes data-driven (§4.2 "Infrastructure" lists the sites).

---

## 4 · The gesture map (W0 deliverable — Track 2 writes `GESTURES.md` here)

Fixed inputs from GAMEPLAN §3.3 that the map must honour:
- The Call = two fingers **held**. Pointy = two-finger **tap**.
- The Rope = long-press on **empty ground** only; a hold on an object belongs to the object.
- Sky Join = the existing filament gesture (long-press a star, drag to a star).
- River/Book Join = long-press a card, drag onto another card.
- Eagle-eye = Turn row "the whole house", or pinch out past the sky's widest zoom. The story page's pinch keeps text sizes; the Weave and Unwinding keep their pinch.
- Back-to-memo = the rewind spiral only. The Gathering keeps its swipe. Turn = page curl from the corner.
- Eyes-closed and face-down = the Light's alone; camera never on by default.
- Send back = Book only. Lay down = Unwinding and Gates only.
- Every gesture has a stillness twin and a VoiceOver action (the Accessibility column of §3.3).
- Holds run on one G0 hold engine: progress rises while held, drains on early release, never fails; commit 0.7–1.3 s, ceremonial 1.1–2.9 s.

`GESTURES.md` = one table: gesture × register × hold length × what answers × stillness twin × VoiceOver action, plus a "collisions resolved" list.

## 5 · The state map (W0 deliverable — Track 2 writes `STATE.md` here)

One row per piece of persistent state (UserDefaults key, file, Airtable field): where it lives · who writes · who reads · what FORGET ME does (clears) · what CARRY YOUR ROAD does (exports) · offline behaviour. Every piece of state that is written must have a reader (W0 gives `forgotToday` and `stays` theirs). CLAUDE.md's persistence law is updated to match.

**FORGET ME scope (fixed):** clears every on-device trace of his walk (met set, kept lines, carried motes, dwell maps, letters not yet sealed, Leela state, circuit state, verb beads' brightness). It does **not** delete Airtable rows (never delete) — App Activity rows stay as the house's ledger.

## 6 · W0's write proof

For each Activity Type the app codes (the seven never-landed plus every new one added in W0), Track 2 triggers it once in the Simulator against the real base and confirms the row lands (`Source App`=Feed, correct type, link where expected). Proof rows are marked so they never surface on his phone: App Activity `Detail` and Feed `Name` start with `BUILD PROOF · `, Feed proof rows carry Status `Archived`, and every read that turns activity into a condition skips them (scores/W0.md §15). Never delete them; list their record IDs in `STATUS.md`. If a write fails, the HTTP status and body go in `STATUS.md` and the fix goes in the same wave. Same for the Feed-table writes: Filament (FeedStore ~:536), Letter (~:666), Kept (AirtableService ~:541), Codex (~:1132).

## 7 · House laws every wave is checked against

- Nothing counted on screen. Nothing locked. Nothing "hidden until". Conditions **light**, never gate. Once surfaced, always findable.
- No notifications, ever. The composing pipeline (W8) is created with notifications off.
- Never on a low day: the arrival engine stands down; the Rite opens gently; the Rope is everywhere.
- Business figures, family conflict, health details and private names never enter a story or a screen. Roles, not names.
- The sealed list stays sealed (GAMEPLAN §10): the position-32 Reveal; **the Lalita Pass is Ashrey's alone**; Voice II Act 5; the Final Reveal.
- Light tiers apply to map glyphs and stars, never to story text.
- Sound: two voices at most, ceiling 0.55, sound on first touch never on load, new sound on the 110 / 136.1 roots; the Om under the house at near-zero gain.
- Accessibility: every story text reachable by VoiceOver even mid-reveal; Reduce Motion keeps order and hold duration; Dynamic Type; dim marks ≥ 3:1.
- Archetype voices that already exist (including the ones named for family) stay as they are — they were established by Ashrey; no wave renames or removes a voice. New text never *adds* a private name.
- Lineage: nothing from an earlier build vanishes. Track 2 keeps `LINEAGE.md` (here) — one line per existing feature touched, and where it lives now.
