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

All of these are **backstage**. None of their names or values ever appears on screen (GAMEPLAN §2: no suit, grammar, signature, chakra, chapter, position or mechanism words). Every one may be empty on any record; the app treats empty as "unknown" and falls back, never hides the story.

### 2.2 Retiring (not deleting)

| Field | ID | Now | When Slice 16 ships |
|---|---|---|---|
| Suit | `fldROWFIDFHyfdOxp` | still read by the installed app **by name** (Models.swift CodingKeys) — so its name must not change yet. Description says TO BE OLD | the app reads `Teller` (falls back to `Suit` if Teller is empty); then Track 1 renames the field `Suit OLD` |
| Rhymes With | `fldCpLf91KeWoYpJH` | same | the app reads `Rhymes` ∪ `Rhymed By` (falls back to `Rhymes With`); then Track 1 renames it `Rhymes With OLD` |

**Lesson recorded:** the Feed fetch decodes by field *name* (no `returnFieldsByFieldId`). Renaming any field the shipped app decodes breaks his phone silently. Track 1 never renames a field the current install reads. Track 2: in W0, move the main fetch to decode by field **ID** (`returnFieldsByFieldId=true`) so names become free to change; record it in CLAUDE.md §6.

### 2.3 Select choices
- **Room** (`fld7SeHJhOY1DhkFh`) gains eight choices, created by typecast when Track 1 writes the eight Room rows (before W2): `The Ground` · `The Unwritten` · `The Stack` · `The Counter` · `The Wash` · `The Name` · `The Old Light` · `The Fold`. These exact strings are the **canon keys** for the rooms in Swift and in `canon/`.
- **Type** (`fldfFRjyasZWodvQC`) gains, by typecast when first written: `Waiting Role` (C6), `Leela` already exists, `Swatch` (three-line arrival stories, C3+), `Interlude` (W0's crossing interlude lines). No other new Types without a line in this file.
- **App Activity · Activity Type** (`fldXNRBZy6QvIP8yz`) currently has: Chapter Completed · Ceremony Sealed · Wager Resolved · Shakti Recognized · Letter Written · Ash Replied · Story Resonated · Story Met · Walk Completed · Veil Lifted · Silence Held · Ring Crossed · Reach · Return · Been Here · Share With · Note · First Dwelling.
  - **Coded but never landed** (no choice exists, no row exists): `Called` · `Read by Hand` · `Kept` · `Letter Sealed` · `Letter Opened` · `Codex Written` · `Released`. Diagnosis (12 Oct): these paths were added 11–12 Oct (a805cc2, 85d5c48, 6579bef, 9690eaa) and **never exercised** — not a proven failure. W0 proves each one (§6).
  - **New in this game** (W3/W7): `Received` · `Joined` · `Carried` · `Circuit Closed` · `Sent Back` · `Drawn` · `Asked` · `Wager` (the wager *made*; `Wager Resolved` is the return). `Released` is shared with the Unwinding.
  - All rows from the Feed carry `Source App` = `Feed` and, where there is one, `Link to Feed` (`fldAgxERs4MnPvuGJ`).

### 2.4 Sort bands (`Sort Order` `fldKAIGO9RHV235go`)

| Band | Holds | Owner |
|---|---|---|
| existing story/room/sentence bands | unchanged | — |
| 810–899 | Leela drops | Track 1 |
| 1000–7303 | the Point (stars, texts, registers) | unchanged |
| **11001–11999** | **new stories** (C0–C6), assigned in wave order | Track 1 |
| **12001–12999** | **Waiting Roles** (the Unwritten's Waiting Room) | Track 1 |
| 13001–13099 | the eight new Room rows' children (blurbs, sentences) if any need a band | Track 1 |

Children (Field Comment / Resonance Voice) keep using `Comment Order` under their parent, not Sort Order.

### 2.5 Content each new story carries
`Name` (title, last) · `Body` · `Excerpt` · `Room` · `Type`=Story · `Status`=Live · `Sort Order` (band) · `Teller` · `Face` · `Verb` · `Rhyme Family` · `Rhymes` (if paired) · `Convergence Line` (host) · `Mirror Line` · `Vertebra` · `Chapter` · `Arc-kind` · `Codex Game` · `Codex ID` / `Trigger Codex Entry` where it came from a memo · `Story Origin` · five children (Field Comment rows linked by `Linked Story`, with `Archetype`, authored line breaks). `Song` is filled in C5.

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

For each Activity Type the app codes (the seven never-landed plus every new one added in W0), Track 2 triggers it once in the Simulator against the real base and confirms the row lands (`Source App`=Feed, correct type, link where expected). Those rows are real activity; leave them, and list their record IDs in `STATUS.md`. If a write fails, the HTTP status and body go in `STATUS.md` and the fix goes in the same wave. Same for the Feed-table writes: Filament (FeedStore ~:536), Letter (~:666), Kept (AirtableService ~:541), Codex (~:1132).

## 7 · House laws every wave is checked against

- Nothing counted on screen. Nothing locked. Nothing "hidden until". Conditions **light**, never gate. Once surfaced, always findable.
- No notifications, ever. The composing pipeline (W8) is created with notifications off.
- Never on a low day: the arrival engine stands down; the Rite opens gently; the Rope is everywhere.
- Business figures, family conflict, health details and private names never enter a story or a screen. Roles, not names.
- The sealed list stays sealed (GAMEPLAN §10): the position-32 Reveal; **the Lalita Pass is Ashrey's alone**; Voice II Act 5; the Final Reveal.
- Light tiers apply to map glyphs and stars, never to story text.
- Sound: two voices at most, ceiling 0.55, sound on first touch never on load, new sound on the 110 / 136.1 roots; the Om under the house at near-zero gain.
- Accessibility: every story text reachable by VoiceOver even mid-reveal; Reduce Motion keeps order and hold duration; Dynamic Type; dim marks ≥ 3:1.
- Lineage: nothing from an earlier build vanishes. Track 2 keeps `LINEAGE.md` (here) — one line per existing feature touched, and where it lives now.
