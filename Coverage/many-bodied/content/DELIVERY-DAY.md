# Delivery day — changes to Live records that must not land before the W8 install

*DATA-A, 12 Oct 2026. Neev runs `275eabd`, which reads every `Live` record and decodes by field **name**. Anything below, done early, would change his phone before the one delivery. Everything here waits for `READY FOR THE FLIP · <sha> · <time>` as the first line of STATUS.md (W8 §7 step 6, written by Track 2 after the install) **and** Ashrey's word to flip. Base `app248ZTWhYJlvQj2`, The Feed `tbl7vzODMMJUgeX0b`; every write `typecast: true`, batches ≤10, field IDs only. Values read live on 12 Oct; re-read each record before writing and stop if the "old" value has drifted.*

Fields: Blurb `fldDwqivsnQ8M7ijA` · Hex Color `fld6lga55ups3j0ZZ` · Body `fldnN9WykhzLpVJQG` · Excerpt `fld6rcsZCkfFSyFvM` · Status `fldWcw9noNlC2AqVf`.

---

## 0 · Before the day (allowed early, because the installed build cannot see it)
- [ ] **737 Light — ninth** (`reczh2lA8S5Ingm4G`) is `Draft`, so the installed build never reads it. Its rewrite (§4 row 5) and `Status Draft → Staged` may be applied any time before delivery; the flip (§5) then makes it Live with everything else.
- [ ] `content/W6-light-content.md` exists and is screened (W6 D6). **On 12 Oct it does not exist.** It is owed by DATA-B. Without it, §4 is skipped and the Light rows stay as they are, which is complete but not upgraded.
- [ ] The full list of `Staged` record IDs is exported to `content/STAGED-LIST.md` the evening before, so §5 can be checked against it.

## 1 · Gate
- [ ] STATUS.md's first line is `READY FOR THE FLIP · <sha> · <time>`, Ashrey has said to flip, and no App Activity row from the new build on Neev is older than his word (the app was not opened by anyone else). If any is missing, stop.

## 2 · Room blurbs: private names and a trade name come off the screen (W0 15.7; W2 §1.3)
The two scores drafted different wording. **W2's wording is used** because it is the later draft, it counts nothing, and it implies no family roles. W0's alternatives are kept in the last column for the record.

| # | Record | Room | Old `Blurb` | New `Blurb` | W0's alternative (not used) |
|---|---|---|---|---|---|
| 2.1 | `recSL10H2LSuICWno` | The Circle | Specific love. Sid. Arch. Shweta. Neev. Karishma. The people who hold the field by being in it. Love not as philosophy but as a particular smile while making eggs. | Specific love. The people who hold the field by being in it. Love not as philosophy but as a particular smile while making eggs. | "…by being in it — the one who answers, the one who laughs first, the small one at the table. …" |
| 2.2 | `rec8vLCCsxapaaMgk` | The Thread | Fabric. Three generations. Sid's hands. The sacred inside the invoice. Not business — dharma wearing a business coat. | Fabric. Generations of hands. The sacred inside the invoice. Not business — dharma wearing a business coat. | "Fabric. Hands passing a craft down the line. …" |
| 2.3 | `recymZhTna7gJKVC2` | The Forge | The builder at the height of his gift. The pure dharmic pleasure of giving form to what was formless. Making as spiritual practice. Rupakarshini. | The builder at the height of his gift. The pure dharmic pleasure of giving form to what was formless. Making as spiritual practice. | (identical) |

## 3 · Colour pairs (W2 §1.2) — field `Hex Color`
| # | Record | Room | Old | New |
|---|---|---|---|---|
| 3.1 | `recymZhTna7gJKVC2` | The Forge | `#D4AE4A` (= Maya) | `#E8793A` |
| 3.2 | `recz8Iwbj0TvxnQHh` | The Return | `#9B6BD6` (= Field) | `#B9A3EC` |

## 4 · The Light's held content (W6 D6, §8.2) — from `content/W6-light-content.md`
Keep each row's existing Excerpt lines (FAMILY / BELIEF DISSOLVED / GESTURE / ARRIVAL / MATERIAL / NOTE) exactly as they are, and **append** the new line(s). Never rewrite the authored lines.

| # | Record | Scene (sort) | Field | Old (12 Oct) | New |
|---|---|---|---|---|---|
| 4.1 | `reckpkF7I0RnQkiwq` | Light — uncertainty (713) | Body (the anchor list) | the current anchor pool | + 10–12 further anchors, same format as the existing list |
| 4.2 | `reckcWUwwLxDBSe7U` | Light — frequency (754) | Excerpt | FAMILY: Relational … MATERIAL: dawn | + line `DAYS: MM-DD — <anchor line> ; MM-DD — <line> …` (6–12 days; no birthdays of named people) |
| 4.3 | `recE7Dt2vm0CWd7lX` | Light — thirteenth (765) | Body | each anchor as one reading | each anchor rewritten `reading one ‖ reading two` |
| 4.4 | `rechGpsvCJYl3Ve33` | Light — hours (776) | Excerpt | FAMILY: The ending … NOTE: … | + line `AMOUNT: <words>` (per `Coverage/15-HOURS.md`) |
| 4.5 | `reczh2lA8S5Ingm4G` | Light — ninth (737) | Body + Status | two variants; Status `Draft` | variants marked `FIRST:` / `AGAIN:`; Status → `Staged` (or done early, §0) |

## 5 · The flip — Staged → Live (W8 §7 step 7)
- [ ] List The Feed with `Status = Staged` (all Types; page through all).
- [ ] Update `fldWcw9noNlC2AqVf` = `Live` in batches of ≤10, in this order: Room rows (14–21) · Stories (11001–11999) · Field Comments and Resonance Voices · Waiting Roles (12001–12999) · Interludes (13101–13115) · Leela (810–817, and C5's 818+) · Mirror Card / Veil (13201–13213) · Second Letters (13301–13314) · Swatches (13501+) · the Good Morning letter (13701, `rec8RoUQsC885coCN`) · Constellations (13801+) · Planted Seeds (14001+) · the Light 737 · anything else.
- [ ] Never touch a record that is not `Staged`. **Skip any record whose `Name` starts `BUILD PROOF`** (a proof row still Staged is archived instead, never flipped). `Archived` rows, including the BUILD PROOF rows, stay archived.
- [ ] Check: a re-list of `Status = Staged` returns zero; the number flipped equals the number listed; spot-read ten records across Types.

DATA-A's Staged rows, for the cross-check: 15 Interludes, 13 Veils, 14 Second Letters, 8 Leela rises and 1 Letter (IDs in `DATA-OWED.md`).

## 6 · Renames (W8 §7 steps 8–9; CONTRACT §2.2)
- [ ] Confirm that no formula field and no Airtable automation reads `Suit` or `Rhymes With` by name (check W0's "names a formula reads" list in CLAUDE.md §6).
- [ ] Rename `Suit` (`fldROWFIDFHyfdOxp`) to **`Suit OLD`**. Description: *"Retired <date> at the Many-Bodied delivery. Read by no build after main@<sha> (Teller replaces it). Never delete."*
- [ ] Rename `Rhymes With` (`fldCpLf91KeWoYpJH`) to **`Rhymes With OLD`**. Description: *"Retired <date> … (Rhymes ∪ Rhymed By replace it). Never delete."*
- [ ] Check: the schema shows both new names and both field IDs are unchanged.

## 7 · Close (W8 §7 steps 10–12)
- [ ] The composing pipeline: `create_trigger` with W8 Appendix B exactly (notifications `{}`). Then `fire_trigger` it once and read the run.
- [ ] The one message about the house was Track 2's (*"It's on your phone. Tell the cloud session to flip."*). Track 1's reply to his "flip" is one word, nothing with it: `Done.`
- [ ] Update the bindu-feed skill (W8 §3.1). Add one ARC Action Center line: *"Bindu Feed — new build delivered to Neev, <date>."* Commit `Coverage/many-bodied/` on `many-bodied`, merge into `main`, push `many-bodied`, and push `main` (W8 §7 step 5 merged it locally; only Track 1 pushes it).

## Also held for this day, if they happen at all
- **C0c** (the light-touch screen of existing story text: 3, 44, 72, 74, 76, 81, 106, 109, and the backstage fields of 118 and 120). Any edit to a Live story's `Body`, `Name` or `Excerpt` would show on the installed build, so it waits for this day, after §5.
- Backstage-only edits (`Song`, `Shakti`, the coordinates, `Rhymes`) are invisible to `275eabd` and need no hold.
