# Data owed by Track 1 — one ledger across W0–W8

*Compiled 12 Oct 2026 (DATA-A) from every score's "Data owed by Track 1" section and every other "Track 1 must / owes" line. Bands and Types are CONTRACT §2.4 / §2.4a / §2.4b — where a score names another band or Type, the contract value is shown and the score's value noted.*

**Who:** `DATA-A` = this agent (done below) · `DATA-B` = the parallel data agent · `C2…C6` = the content waves · `delivery` = delivery day (see `DELIVERY-DAY.md`) · `app` = created by typecast on the app's first write · `coord` = the Track 1 coordinator (contract / review).
**Status refresh (12 Oct, readiness S16):** the status column was re-read from the base; "written" counts are live reads. Every line still `owed` is `OWED-TO-TRACK-1` for Track 2 — never blocking; the build walks on harness fixtures. New stories with Sort ≥ 11001, Type Story: 332 read live.
**Activity Type choices:** the Airtable MCP cannot add select choices by schema. Every new `Activity Type` is created **by typecast on the app's first write** (CONTRACT §2.4b). Where a score asked for creation "by schema" (W4 D1, W7 D1), that is not possible from here; the AirtableWriter queue (W0 15.2) keeps a 422 write queued and retried, so the type lands on its first successful write.

| id | what | score § | band / Type (CONTRACT) | who | status |
|---|---|---|---|---|---|
| W0-1 | Interlude lines, one short line in the dot's voice (≥12 per W5 D4) | W0 15.6; W5 D4 | Type `Interlude` · 13101–13199 | DATA-A | **Staged · written** 15 rows 13101–13115 (list below) |
| W0-2 | Room blurb rewrites: Circle, Thread, Forge (names / trade name off screen) | W0 15.7; W2 §1.3, App. B | Room rows, `Blurb` | delivery | held — Live rows; see DELIVERY-DAY §2 |
| W0-3 | Activity Types never landed: `Called` `Read by Hand` `Kept` `Letter Sealed` `Letter Opened` `Codex Written` `Released` | W0 15.2, §6 | App Activity `fldXNRBZy6QvIP8yz` | app (typecast) | owed by W0 write proof; on 422 Track 2 writes DECISIONS and the write stays queued |
| W0-4 | Feed Types `Kept` `Letter` `Filament` (proof) | W0 §6 | Feed `Type` | app (typecast) | `Letter` **now exists** (created by DATA-A's Good Morning write); `Kept`, `Filament` on first app write |
| W0-5 | Codex proof row: rename `Codex Name` → `OLD · build proof` | W0 §6 step 6 | Codex | Track 2 at W8 (`-HarnessMarkWindow`'s Codex rule) or Track 1 after delivery | owed after W0 proof (row id in STATUS.md); not blocking |
| W0-6 | Freeze the "names a formula reads" list (never rename those fields) | W0 15.1 (5) | — | coord | standing rule |
| W0-7 | Rename `Suit` / `Rhymes With` → `… OLD` | W0 15.1; W1 §2.3; CONTRACT §2.2 | fields `fldROWFIDFHyfdOxp`, `fldCpLf91KeWoYpJH` | delivery (after install) | held — DELIVERY-DAY §6 |
| W1-1 | Mark `Suit` / `Rhymes With` OLD in their *descriptions* | W1 §2.3 | — | coord | done per CONTRACT §2.2 ("TO BE OLD") |
| W1-2 | Copy the 14 legacy `Rhymes With` links into `Rhymes` | W1 contr. 6 | `fldAFBBdsItsIvJVY` | C0b | done (STATUS: 14 migrated + 23 new pairs) |
| W1-3 | `Source Date` in CONTRACT §2.5 | W1 contr. 5; W4 D6; W6 D7; W8 E2 | — | coord | done (§2.5 lists it) |
| W2-1 | Eight new Room rows, sort 14–21 | W2 §1.1, App. A | Type `Room` · 1–40 | done earlier | **Staged** (verified: Ground, Old Light read Staged) |
| W2-2 | Colour pairs: Forge `#E8793A`, Return `#B9A3EC` | W2 §1.2, App. B | Room rows `Hex Color` | delivery | held — DELIVERY-DAY §3 |
| W2-3 | `⟪…⟫` marks line in CONTRACT §2.5 | W2 §16.2 | — | coord | done (§2.5 points to W2 §1.4) |
| W2-4 | Waiting Roles (Name = role, `Linked Story` when told) | W2 §1.5 | `Waiting Role` · 12001–12999 · **Staged** (not Live as W2 says) | C6 | **Staged · written** (read 12 Oct, readiness S16): 119 rows 12001–12119 |
| W3-1 | Activity Type `Circuit Closed` | W3 D1 | App Activity | app (typecast) | owed by Slice 21 proof |
| W3-2 | `⟪one more⟫` first line, one per body with ≥3 stories (new stories only) | W3 D2 | Story · 11001–11999 | C2–C4 | **written** (read 12 Oct, readiness S16): 14 stories carry `⟪one more⟫` |
| W3-3 | `⟪will: …⟫` / `⟪act: …⟫` (optional) | W3 D3 | Story body | C-waves | optional |
| W3-4 | Room rows for rooms that ripen (only when ≥2 stories carry the string) | W3 D5, §12 | `Room` · 22–40 · Staged | C-waves / W8 pipeline | when ripe |
| W3-5 | CONTRACT: `⟪will:⟫ ⟪act:⟫ ⟪one more⟫` in §2.5 | W3 D6 | — | coord | §2.4/§2.4b done; §2.5 mark list owed |
| W4-1 | Activity Type `Wager` | W4 D1 | App Activity | app (typecast) — score asked "by schema"; not possible via MCP | owed by W4 proof |
| W4-2 | Feed Type choice `Second Letter` | W4 D2 | Type `Second Letter` | DATA-A | **created** (typecast, first write) |
| W4-3 | Second Letters ≥12: two verbatim lines from a later memo, linked to the older story | W4 D3, §3.9 A | `Second Letter` · **13301–13499** (score said 13201–13599) | DATA-A | **Staged · written** 14 rows 13301–13314 |
| W4-4 | Leela board rises ≥8, Excerpt `KIND: rise` | W4 D4, §3.2 | `Leela` · 810–817 | DATA-A | **Staged · written** 8 rows 810–817 |
| W4-5 | `⟪watch: …⟫` on ≥12 new stories across 8+ rooms | W4 D5 | Story body, first line | C2–C6 | **written** (read 12 Oct, readiness S16): 19 stories carry `⟪watch:` (≥ 12 met; rooms not re-counted) |
| W4-6 | CONTRACT: Second Letter band; `⟪watch:⟫` in §2.5 | W4 D6 | — | coord | band done; mark owed |
| W5-1 | Swatches ≥24 (three lines, Teller ≠ His Memo, Face Bindu; ≥8 with `Rhymes`) | W5 D1 | `Swatch` · **13501–13699** (score said 13201–13399) | DATA-B / C3+ | **Staged · written** (read 12 Oct, readiness S16): 31 rows 13501–13531 |
| W5-2 | The Good Morning letter | W5 D2, §4.9 | `Letter` · **13701** (score said 13401) · Excerpt `WHEN: before` | DATA-A | **Staged · written** |
| W5-3 | Waiting Roles that have left: ≥6 with `Linked Story` before delivery | W5 D3 | `Waiting Role` · 12001–12999 | C6 | **written** (read 12 Oct, readiness S16): 22 roles carry `Linked Story` |
| W5-4 | Leela round 2, ≥12 | W5 D5 | `Leela` · 818–899 | C5 | **Staged · written** (read 12 Oct, readiness S16): 30 rows 818–847 |
| W5-5 | Gifts / notices / Deep Time kathas | W5 D6–D8 | reads only | C2/C4/C5 | nothing new |
| W5-6 | CONTRACT: `WHEN: before` seal named in §2.3a; Swatch field list (§2.6) | W5 D10 | — | coord | bands done; seal + §2.6 owed |
| W6-1 | Year of veils, 13 rows (row 13 = `?`) | W6 §0.3 D1, §9.1 | Type `Mirror Card`, `Card Register` = `Veil` · 13201–13213 | DATA-A | **Staged · written** 13 rows |
| W6-2 | Gaia seeds as constellations (screened; no family/health/relationship seeds) | W6 D2 | `Constellation` · **13801–13999** (score said 13301–13399) | DATA-B | **Staged · written** (read 12 Oct, readiness S16): 30 rows 13801–13830 |
| W6-3 | Waiting tellings ≥6, `⟪telling⟫` first line | W6 D3 | `Waiting Role` · 12001–12999 | C6 / DATA-B | **Staged · written** (read 12 Oct, readiness S16): 7 Waiting Roles carry `⟪telling⟫` |
| W6-4 | Planted Seeds 3–5 from the newest unstoried memos | W6 D4 | `Planted Seed` · 14001–14999 | DATA-B | **Staged · written** (read 12 Oct, readiness S16): 4 rows 14001–14004 |
| W6-5 | One journey, one chain of houses, one machine mid-sentence, one lantern | W6 D5 | Story marks · 11001+ | C4 | **written** (read 12 Oct, readiness S16): 11 stories carry `⟪journey` (C4-B: travelling sentence 11556–11561, chain of houses 11551–11555) |
| W6-6 | Light content for 713 / 754 / 765 / 776 / 737 → `content/W6-light-content.md` | W6 D6, §8.2 | Light rows 707–776 | DATA-B (draft) → delivery (apply) | **absent** (read 12 Oct, readiness S16) — the build must handle both states (with and without the upgrade); W6 walks on fixtures. DELIVERY-DAY §4 applies only if the file appears |
| W6-7 | CONTRACT: Types, `Veil`, bands, seven marks | W6 D7 | — | coord | Types/bands done; marks list owed |
| W7-1 | Activity Types `Received` `Joined` `Carried` `Circuit Closed` `Sent Back` `Drawn` `Asked` `Wager` (+`Released`) | W7 D1 | App Activity | app (typecast) — score asked "by schema"; not possible via MCP | owed by Slice 28 proof |
| W7-2 | Backstage field `Shakti` → Mandala `tblrRwXJD0uP8HU8G`; ID into CONTRACT §2.1 | W7 D2 | new field | DATA-B | **done** — `Shakti` `fldsjkiGt4vG3kjSu` (CONTRACT §2.1) |
| W7-3 | `Song` links on the 137 (readers/11 §3.1–3.2) and C1–C5; never `purity` / `levelup` | W7 D3 | `fldcEhY09Ni9Tao7o` | DATA-B / C5 | **written** (read 12 Oct, readiness S16): 143 records carry a `Song` link |
| W7-4 | `Shakti` filled on Shakti kathas | W7 D4 | `Shakti` | C5 | **written** (read 12 Oct, readiness S16): 20 records carry `Shakti` |
| W7-5 | `⟪ask: …⟫` where a story has its own question | W7 D5 | Story body | C-waves | optional |
| W7-6 | Sibling contracts written into sibling skills | W7 D6 | skills | DATA-B / coord | owed |
| W8-1 | C6: Unwritten silence stories ≥12 + Waiting Roles for every untold seed | W8 E1 | Story 11901+ · Waiting Role 12001+ | C6 | **Staged · written** (read 12 Oct, readiness S16): 13 Unwritten stories 11901–11913; 119 Waiting Roles |
| W8-2 | CONTRACT last pass (`Planted` → `Planted Seed` already reconciled; overflow band; `Shakti`; `⟪ask:⟫`; W7 types as landed) | W8 E2 | — | coord | partly done |
| W8-3 | The composing pipeline (`create_trigger`, notifications off) | W8 E3, App. B | — | delivery step 10 (W8 §7) | held |
| W8-4 | bindu-feed skill brought current | W8 E4, §3.1 | — | delivery, after step 10 | held |
| W8-5 | GAMEPLAN as built; DECISIONS verdicts | W8 E5 | — | coord (Slice 30) | owed |
| W8-6 | Mark the device walk's rows (`BUILD PROOF · `, Feed rows `Archived`) | W8 §6 | App Activity / Feed | **Track 2**, at once after the walk (`-HarnessMarkWindow`, W8 §6) | owed at W8; not Track 1's |
| W8-8 | Confirm that no Airtable automation on the Codex table fires on record **creation** (proof and walk Codex rows are created, dated 2000-01-01, then marked; re-review R9) | W0 15.2 (d); W8 §6 | Codex | Track 1 | owed — before W0's Codex proof; until confirmed, W0 defers the Codex proof |
| W8-7 | Flip, renames, the one line | W8 E6, §7 | — | delivery | DELIVERY-DAY |

---

## What DATA-A wrote (all `Status = Staged`, The Feed `tbl7vzODMMJUgeX0b`, typecast)

### Interludes — Type `Interlude` (choice created by this write), 13101–13115
| sort | record | line |
|---|---|---|
| 13101 | recoUU42YNaphDDLi | Same dot. Different room. |
| 13102 | rechX4PGNf9VE9JmI | I came along. I always do. |
| 13103 | recjo9UugWcuuiWC9 | Nothing behind you closed. |
| 13104 | recySr4VitqIHmKd8 | Breathe once. I'll wait. |
| 13105 | recG9JBZUMl7v7ZrT | You carried a little of that colour in with you. |
| 13106 | recPRf9EZqay2tjDz | Between two stories, I am the pause. |
| 13107 | recQ0bf47XXBycXt3 | Still here. Still small. Still everything. |
| 13108 | recSG5P2roxKEgRTb | You don't have to remember it. I will. |
| 13109 | reccI7XZhuitmNER5 | One room ends exactly where the next one starts. |
| 13110 | recWC8ffo6aSQgplJ | I was in that story too. Did you see me? |
| 13111 | recXJEAxD8yyrUDjC | Every door in this house opens onto me. |
| 13112 | reccHJ4qHdwODGV72 | Rest here. The next one isn't going anywhere. |
| 13113 | recVYa5RGWuOl1vUb | I am where the threads cross. |
| 13114 | recIdJhkhUgK5uZc3 | What you just read is still reading you. |
| 13115 | recGB4KkDnJCxiXC9 | I was here before you crossed. |

`Name` = `Interlude · <two words>` (backstage); `Body` = the line.

### The year of veils — Type `Mirror Card`, `Card Register` = `Veil` (choice created), 13201–13213
Body = `⟪veil: <arc>⟫` + one truth; Excerpt = the question. Written new — no story-book inscription, Perspective or Mirror-card wording is quoted (readers/18 §5; the existing Vow card "I am the one who stays" was deliberately not echoed).
| sort | record | arc | Name (role) |
|---|---|---|---|
| 13201 | reclxLJ0oiMIQyO2Q | permanence | the one who keeps it all standing? |
| 13202 | recnDmMR0xgx0U02s | release | the one who carries everything? |
| 13203 | recEvhdNdYP88mMU8 | identity | the one with the name? |
| 13204 | rec5CwxBc7HytRhBv | integration | the one who is two people? |
| 13205 | rec69qTZP0ds04H6m | awakening | the one who was asleep? |
| 13206 | recfcuCpeqvI2rke0 | origin | the one who began it? |
| 13207 | rece0vJ0XhGOQt30f | center | the one in the middle? |
| 13208 | recbnut7gpNGFugHj | self | the one who is looking? |
| 13209 | recRJpdECE1WXptIQ | service | the one who gives? |
| 13210 | recePo7m3bPfEXNHw | recognition | the one who was found? |
| 13211 | recST64RydPBvMXyd | home | the one looking for home? |
| 13212 | recixMJux9QikISkO | return | the one who comes back? |
| 13213 | recg6OBvIoToufFqr | return | `?` (Body `⟪veil: return⟫` only, Excerpt empty) |

### Second Letters — Type `Second Letter` (choice created), 13301–13314
Two lines verbatim from a later Codex transcript (`fld459YeVBZBgB8zh`, checked by exact substring match), joined by `\n`; `Linked Story` = the older story; `Codex ID` / `Source Date` = the later memo. Screened: no names, figures, health, family conflict. Memos rejected at the screen: C-1115 (habits/health), C-1206 (family conflict), C-1114 (garbled), C-1252 (a video summary, not his words).
| sort | record | older story (record) | later memo |
|---|---|---|---|
| 13301 | recRDPRWQaM1NvCkB | Working Backward From Who He Wanted to Be (recAQ2m8lqYYCjecb, C-1025) | C-1244 · 2026-02-01 |
| 13302 | recnjksQmK1ddKYkV | The Choice Inside the Feeling (rec2vHd353nXfXrMB, C-1117) | C-1120 · 2025-06-09 |
| 13303 | rec3nIDbZ54BLReEC | Feel It Through, Then Realign (recvLel1exNsLDWSO, C-1145) | C-1160 · 2025-10-03 |
| 13304 | recXxITiKGANjyILI | Gratitude Was the Doorway (recMBJSR5id2qBpuI, C-1159) | C-1257 · 2026-02-15 |
| 13305 | recSnsDzwZCAMOmiA | The Interface He Mistook for Himself (rec3WCox4tZonQnbm, C-1219) | C-1227 · 2026-01-05 |
| 13306 | recmgB2wE0y7UEFBa | The Universe's Native Tongue (recZXGXhbHmDGtipo, C-1177) | C-1351 · 2026-05-20 |
| 13307 | rechi7ZeOIOJJQDpJ | Suffering, and the Door It Points To (recvyPfN5u0jc9XF3, C-1242) | C-1308 · 2026-04-07 |
| 13308 | recQXlsuRvNCGR6xl | Every Path, Already Walked (reczadlhHIX8IBhXX, C-1253) | C-1258 · 2026-02-16 |
| 13309 | rectaAbEKGYQ1Haet | What the Whole Game Was For (recTWFZ823phjVous, C-1069) | C-1279 · 2026-03-05 |
| 13310 | recFc9ldttALf95FT | The Observer Was the Information (recgf7bG6gwUUYj1F, C-1274) | C-1281 · 2026-03-06 |
| 13311 | recb9Nw0quXC5DoeL | The White Light Behind the Red Dot (recAA3myCZpVr7Hmc, C-1222) | C-1306 · 2026-04-02 |
| 13312 | reczfNQUYlgTep01e | The Songs That Played Him Home (receZdRz33KQBl1Bj, C-1311) | C-1347 · 2026-05-19 |
| 13313 | recrNtTyQJlsJpKVA | Everyone Was Both Teacher and Student (recKjnY1OgfEUaV7a, C-1152) | C-1363 · 2026-08-10 |
| 13314 | recFJ6viYS4pXpcZO | The Lack He Made the Center (recPCgczXI4S4xToP, C-1230) | C-1364 · 2026-08-16 |
One letter per older story (W4 allows two). None of the older stories is on the C0c truth-flag list (3, 44, 72, 74, 76, 81, 106, 109).

### Leela board rises — Type `Leela`, 810–817, Excerpt `KIND: rise`
Shape matched to 801–809: `Name` = `Leela — <title>`; Body = passage paragraphs, blank line, one act of giving last; no AFTER / NOT BEFORE lines.
| sort | record | title |
|---|---|---|
| 810 | recl8RIq2N1HJi82H | The open hand |
| 811 | recEHu3MO7TbdvPFE | Finished for someone |
| 812 | recVpyxKhghaGtv0x | The thank-you you owe |
| 813 | recVtE3ETwryNDFB6 | Room for one more |
| 814 | recGPE2SjDuxXYhQS | Unbroken attention |
| 815 | reczGE3nh7PEhZJBs | The long way, given |
| 816 | recOnFUumQtq4LoSV | No name on it |
| 817 | rec55YgdXrhBVnUAY | What the ground gives |

### The Good Morning letter — Type `Letter`, 13701 — `rec8RoUQsC885coCN`
`Name` = `good morning` · `Excerpt` = `WHEN: before` · `Source Date` = 2024-10-31 (the Codex's first day) · `Codex ID` = C-1003 · `Trigger Codex Entry` = C-1003 `recetowz4J0q4AHvA`, C-1007 `recJRfyTCwkphBfSY`, C-1010 `recGw3qxGMf0CulMf`.
Body = the Practice Book's page-1 frame (`chakra-maps/references/practice-book/master-plan-v2.md`), then his words verbatim from the Codex Notes of the first day.
**Calls (recorded here, per W5 D2):**
- The earliest day's entries C-1001, C-1002, C-1004, C-1005 fail the screen (a named condition; a private conversation with names; family; private names). C-1003, C-1007, C-1010 pass and are used.
- C-1003's list numbering (`1\.`–`4\.`) was dropped so no numeral shows; the words are unchanged.
- The book's "Here's what you said: *Remind me of the names.*" gives way to his own words; the book's last line becomes the house's: **"This house is that reminder."**
- `Letter` Type choice did not exist; this write created it by typecast (the W0 diagnosis listed it as never landed).
