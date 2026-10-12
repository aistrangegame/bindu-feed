# 04 — Airtable live census, base app248ZTWhYJlvQj2 (12 Oct 2026)

**Read only. Nothing was written to Airtable.**

**What I read:**
- the brief, `feed-stories.txt`, the asg-airtable SKILL.md (all 981 lines) and `references/site-v3.md`;
- the project memory `airtable.md`;
- the live schema of all 33 tables;
- every record of The Feed (1,329), Codex (352), App Activity (152), Gaia (806), Goals (171), Learning (575), The Builds (340), Identity (165), Mandala (126), Bindu Field (60), The Map (33) and Walks (23), reading only the type and status fields;
- row counts only (`totalRecordCount`) for every other table.

**What I did not read:** the content of private journals (SJ, Emotions, Gratitude, Anger, Health, Neev). Only their names and row counts appear here.

**Supporting files:**
- `reports/04b-codex-index.tsv` — all 352 Codex rows. Columns: number, date, name, category, has_story, source_app, games, in_call.
- Raw pulls, kept beside the report: `feed.json`, `codex.json`, `appact.json`, `feed_children.json`.

---

## 1. The Feed (tbl7vzODMMJUgeX0b) — 1,329 rows

### Type × Status

| Type | Live | Draft | Archived | (no status) | Sort band |
|---|---|---|---|---|---|
| Story | **137** | – | – | – | 1–137 |
| Field Comment | 563 | – | – | 57 | – |
| Resonance Voice | 114 | – | – | – | – |
| Light | 69 | 1 (737 `ninth`) | – | – | 707–776 |
| Point Star | 66 | – | – | – | 1101–7303 |
| Threshold Sentence | 56 | – | 4 | – | 1–59, 601 |
| **Call** | **54** | – | – | – | 10001–10054 |
| Point Register | 37 | – | – | – | 9101–9137 |
| Mirror Card | 30 | – | 10 | – | 1–10, 201–220, 900–901 |
| Point Universe | 22 | – | – | – | 1100–7300 |
| Room | 13 | – | – | – | 1–13 |
| Archetype | 11 | – | – | – | 1–11 |
| Leela | 9 | – | – | – | 801–809 |
| Ash Comment | 8 | 1 | – | – | (none) |
| Practice Invitation | 8 | – | 15 | – | 1–15 old, 401–408 live |
| Point Dimension | 7 | – | – | – | 1000–7000 |
| Gaia Seed | 6 | – | – | – | 501–506 |
| Signal | 6 | – | 12 | – | 1–12 old, 301–306 live |
| Point Text | 6 | – | – | – | 9001–9010 |
| Field Sound | 3 | – | – | – | (none) |
| Return | 2 | – | – | – | 901 |
| Return Answer | 2 | – | – | – | 901 |

**Type options with zero rows:** none of the 22 options in the schema is empty.

**Kept, Letter and Filament are not options at all.** No Type choice by those names exists. The app's code writes them with typecast:
- `"Type": "Kept"` in `AirtableService.swift:541`;
- `"Type": "Letter"` in `FeedStore.swift:666`;
- `"Type": "Filament"` in `FeedStore.swift:536`.

Typecast would have created each choice on its first write, so none of these writes has ever succeeded live. **Count: Kept 0, Letter 0, Filament 0.**

**Other counts asked for:**
- Light: 70 rows (69 Live, plus 737 in Draft as ruled 28 Sep).
- Call: 54.
- Gaia Seed: 6 (The Weather · Before You Were Consulted · The Chest Gets There First · The Place, Not the Reason · The Hands Knew · Asking for Less).
- Mirror Card: 40.
- Signal: 18.
- Practice Invitation: 23.
- Threshold Sentence: 60.

**What some of those rows are:**
- **Mirror Card:**
  - 201–220 are the 20 belief mirrors;
  - 900/901 are 8 "vow-" rows written by the app at runtime (2 of them Archived);
  - 1–10 are the old v1 register (7 Archived).
- **Calls:** all 54 rows were created today (12 Oct). They are 18 states × 3: scattered, heavy, rushed, unseen, anxious, stuck, tired, restless, small, lost, behind, alone, doubting, overwhelmed, numb, tight, distracted, far away. Each names a Codex number.
  - Nine of those Codex entries have no story: C-1160, C-1244, C-1279, C-1281, C-1289, C-1303, C-1306, C-1308, C-1327.
- **Leela:** 9 rows, all created today. "The first ask" … "Nothing to keep".
- **Return / Return Answer:** 2 pairs (27 Aug, 3 Sep). They are what the Return mechanic has actually been used for.
- **Ash Comment:** 9 runtime rows, dated 24 Aug to 7 Oct.
- **The 57 statusless Field Comments:** created 4 Jun. They hang off the archived v1 Signal, Mirror and Practice rows, not off any story. They are orphans of v1.

### Live Stories per Room (137)

| Room | Stories |
|---|---|
| A Maya Game | 17 |
| The Forge | 15 |
| The Descent | 12 |
| The Watcher | 11 |
| The Circle | 10 |
| The Garden | 10 |
| The Body | 10 |
| The Thread | 10 |
| The Forgetting | 9 |
| The Field | 9 |
| The Return | 9 |
| The Signal | 8 |
| The Remembering | **7** (thinnest) |

**Where the 137 stories come from:**
- 119 have no Story Origin set: 102 Codex-based, 3 cloth/Codex (121–123) and 14 other-suit.
- 18 have Story Origin = Belief (103–120).

**Suit field on the 14 other-suit stories:**

| Suit | Stories |
|---|---|
| Cloth | 6 |
| Machine | 2 |
| Land | 2 |
| Maker | 1 |
| Lineage | 1 |
| Company | 1 |
| Customer | 1 |

The other 123 stories have no Suit.

**Codex use:** the stories draw on 103 distinct Codex numbers. **C-1052 and C-1170 each carry two stories:**
- C-1052: #1 *The Two Who Were One* and #85 *The Severance of Being Born*;
- C-1170: #3 *Something Moving Under the Skin* and #84 *The Energy That Wouldn't Let Him Sleep*.

### Children per story

**Overall:**
- Field Comments per story: 4 on 98 stories, 5 on 31, and 3, 6 or 7 on one each. **0 on 5 stories.**
- Lalita reply (a Field Comment by Lalita): 118 of 137 stories have exactly one, 19 have none. There are 127 Lalita comments in total; 115 of them are replies, threaded via Parent Comment.
- Resonance Voice: 114 of 137 stories have exactly one, **23 have none.**

**Archetype voices:**
- In Field Comments: Lalita 127 · Sakshi 117 · Gaia 72 · Karishma 60 · Sid 58 · Ashrey 57 · Arch 54 · Shweta 32 · Neev 30 · Bindu 13.
- In Resonance Voices: Arch 21 · Karishma 20 · Sakshi 18 · Gaia 15 · Ashrey 14 · Bindu 11 · Sid 10 · Lalita 3 · Shweta 1 · Neev 1.

**Stories missing children:**

| Sort | Room | Codex | Title | Field Comments | Lalita | Resonance Voice |
|---|---|---|---|---|---|---|
| 72 | The Signal | C-1150 | The Book He'd Had for Ten Years | **0** | 0 | 0 |
| 73 | The Forge | C-1145 | Feel It Through, Then Realign | **0** | 0 | 0 |
| 74 | The Garden | C-1058 | The Idea That Needed to Germinate | **0** | 0 | 0 |
| 75 | The Watcher | C-1057 | The Feeling Only Asked to Be Felt | **0** | 0 | 0 |
| 76 | The Forgetting | C-1047 | The Story That Stole the State | **0** | 0 | 0 (1 Mirror Card) |
| 3 | A Maya Game | C-1170 | Something Moving Under the Skin | 4 | **0** | 1 |
| 4 | A Maya Game | C-1205 | The Prison Made of Glass | 4 | **0** | 1 |
| 8 | The Thread | C-1295 | What the Fabric Told His Father | 5 | **0** | 1 |

**All 18 belief stories (103–120) have no Resonance Voice.** Eleven of them also have no Lalita reply: 105, 106, 107, 109, 110, 113, 114, 116, 118, 119, 120.

**Stories 121–137 are fully dressed:** each has 4 Field Comments, 1 Lalita reply and 1 Resonance Voice. That includes all 14 other-suit stories.

### The 13 Room rows

Every Room row is Live, created 21 May.

**Fields that are filled:** Name, Sort, Glyph, Hex, Blurb, Animation Name, Glyph Size, Root Hz, Binaural Hz, Sound Texture, Brightness, Sound Level.

**Fields that are empty on every Room row:** Room select, Closing Line, Attack, Release, Operating Principle.

| # | Room | Glyph | Hex | Animation | Root Hz | Binaural | Texture | Blurb (opening) |
|---|---|---|---|---|---|---|---|---|
| 1 | A Maya Game | ◈ | #D4AE4A | glyphRotate | 110 | 4 | Sine | "The field where knowing and not-knowing meet…" |
| 2 | The Garden | ◆ | #4A9E6B | glyphBreathe | 146.83 | 5 | Sine | "What grows when you stop watching…" |
| 3 | The Watcher | ◇ | #7B82D4 | none | 123.47 | 6 | Sine | "The game of seeing the seer…" |
| 4 | The Descent | · | #E5533C | glyphEmber | 98 | 3 | Sine | "Going further in than comfort allows…" |
| 5 | The Return | ✦ | #9B6BD6 | glyphOrbit | 164.81 | 4 | Shimmer | "Recognition arriving like light…" |
| 6 | The Forgetting | ○ | #C4A882 | glyphStutter | 110 | 3.5 | Noise Bed | "The specific ways one person keeps forgetting…" |
| 7 | The Remembering | △ | #8AB5A0 | glyphDawn | 146.83 | 4 | Sine | "Not The Return — quieter…" |
| 8 | The Body | ⬡ | #C45A50 | glyphBreath8 | 110 | 3.5 | Noise Bed | "What the flesh knew before the mind arrived…" |
| 9 | The Thread | ⊕ | #C4923A | glyphWeave | 130.81 | 4 | Triangle | "Fabric. Three generations… dharma wearing a business coat." |
| 10 | The Circle | ◎ | #D4607A | glyphCircle | 130.81 | 4 | Sine | "Specific love… a particular smile while making eggs." |
| 11 | The Signal | ✧ | #3AADA8 | glyphSignal | 196 | 7 | Shimmer | "Something arriving from further out…" |
| 12 | The Forge | ▲ | #D4AE4A | glyphAssemble | 164.81 | 5 | Triangle | "The builder at the height of his gift… Rupakarshini." |
| 13 | The Field | ∞ | #9B6BD6 | glyphField | 110 | 4 | Shimmer | "…Every other room is inside it…" |

**Notes on the Room rows:**
- **Colour clashes:** Maya Game and Forge share #D4AE4A, and Return and Field share #9B6BD6.
- **Blurbs that break house law:** Circle's blurb names private family members, and Thread's names a family elder. They should not surface on screen as written.
- **The Room select field is empty on these rows.** A Room row is identified by its Name.

---

## 2. Codex (tblDF4OCMcRoxkQjU) — 352 entries

**Range:** C-1001 (31 Oct 2024) to **C-1365 (2 Sep 2026)**. Thirteen numbers in that range are missing, probably deleted. Every row has a date.

**Stories:**
- **103 entries have a story; 249 do not.**
- 246 have no story once the 3 unstoried Health entries are removed.
- The newest entry with a story is **C-1360** (25 Jun 2026), *Arc Yard Pieces…*, which became story 121.

**Five entries are newer than the newest story:**

| Codex | Date | Category | Name |
|---|---|---|---|
| C-1361 | 30 Jun | Work Stuff | Building the Dolphin App… |
| C-1362 | 16 Jul | Strategy | Curated by Design… swatch kit labels |
| C-1363 | 10 Aug | Ideas | Celebrating Diwali Together… |
| C-1364 | 16 Aug | Reflections | **The Zero Gap: … Inner and Outer Vision as One** (the strongest candidate) |
| C-1365 | 2 Sep | Meeting Minutes | The Customer Is the Hero… |

**Intake has slowed sharply:** Mar 40 · Apr 29 · May 19 · Jun 10 · Jul 1 · Aug 2 · Sep 1 · Oct 0.

**The Source App field (`fldaii08WVwJQA5qP`) is empty on all 352 rows.** No app has written a Codex row yet.

### Entries by category

| Category | Total | With story | Without |
|---|---|---|---|
| Reflections | 102 | 76 | 26 |
| Strategy | 51 | 2 | 49 |
| Ideas | 27 | 2 | 25 |
| Discovery | 23 | 13 | 10 |
| Knowledge | 20 | 1 | 19 |
| Work Stuff | 20 | 1 | 19 |
| Voice Memos | 13 | 3 | 10 |
| Goals | 13 | 0 | 13 |
| Content Ideas | 12 | 0 | 12 |
| Meeting Minutes | 12 | 0 | 12 |
| Conversations | 9 | 1 | 8 |
| Work Story | 8 | 0 | 8 |
| Recap | 7 | 0 | 7 |
| Story | 5 | 1 | 4 |
| Learning | 5 | 0 | 5 |
| Hedy AI | 5 | 0 | 5 |
| **Health** | **4** | **1** (C-1294 → #18 *What the Body Wanted Was Food*) | 3 (counted only) |
| Agenda / Kundalini Cleansing / Session Bridge | 3 each | 0 / 2 / 0 | |
| Rules / Chronicles / (none) | 2 each | 0 | |
| Systems | 1 | 0 | 1 |

**Games field (`flded0x4jeFYq6PPW`), across all 352 entries:**

| Game | Entries |
|---|---|
| A System Game | 183 |
| A Learning Game | 154 |
| A Work Game | 146 |
| A Maya Game | 121 |
| A Family Game | 41 |
| A Health Game | 19 |
| A Social Game | 8 |
| A Seva Game | 5 |
| A Fire Game | 3 |
| (untagged) | 4 |

### Story candidates without a story (Health excluded)

The richest unmined vein is the **26 unstoried Reflections, plus 10 Discovery, 4 Story and 2 Chronicles.**

**Clean candidates by the house screen:**
- C-1364 *The Zero Gap*;
- C-1258 *Light's Path and Timeline Shifting*;
- C-1265 *Akash-Gaia: Destructive to Creative Cycles*;
- C-1266 *The Tree of Life Framework…*;
- C-1283 *The Umbilical Cord Metaphor*, which fits the "cord cut" signature;
- C-1316 *Expansive Dream Space*;
- C-1338 *The Akash Named* and C-1339 *The Kingdom Becomes Legible to Itself*, both Chronicles that suit the Field room;
- C-1333 *The Awakening of ProSoft PUL: A Fabric's Journey to Purpose*, which fits the Cloth suit;
- C-1263 *The Trinity Framework* (Creator / Preserver), which fits the Company suit;
- C-1335 *Silent Flex… Thermal Bonding*, a Machine/Cloth suit candidate;
- C-1005 *FlASH Point Story*;
- C-1206 *Recognizing Mind Games…*;
- C-1227 *Preparing for Conscious Re-engagement*;
- C-1116 *The Recurring Cycle…*;
- C-1115 *Breaking Free from Habitual Time-Wasters*;
- C-1114 *Infrastructure Before Documentation*;
- C-1174 *Kundalini Awakening Journey*;
- C-1166 *Shakti's Cleansing*;
- C-1074 and C-1104, the two Discovery-framework entries;
- C-1011 and C-1012, conversations on the Gita and the Vedas (render without names).

**Also usable:** the 9 Call-cited entries that have no story (C-1244, C-1308 and C-1327 are Reflections/Discovery; the other 6 are in the TSV).

**Screen carefully, because they touch the house laws on family conflict and health:**
- C-1065, C-1067 and C-1071 (substance use);
- C-1086 (autoimmunity);
- C-1106, C-1107, C-1108, C-1131, C-1142 and C-1357 (family-business conflict);
- C-1027, C-1048 and C-1066 (marriage and parenting conflict);
- C-1118, C-1123, C-1124 and C-1129 (a child named).

**Strategy, Ideas, Knowledge, Work Stuff and Meeting Minutes** (about 125 unstoried entries) are the natural ore for **Company, Cloth, Maker and Customer suit** stories, told as the cloth or the company experiencing itself, not as the man. Business figures must be stripped out.

---

## 3. The other tables (33 in all)

| Table | Rows | What it holds / game potential |
|---|---|---|
| **Identity** tbluLyZj9ilH2RhIg | 165 | The game deck: **20 Beliefs** (15 Surfaced, 5 Seen), **16 Mantras** (YES/NO lines: Witness, Receive Before Acting, Voice the Unspoken, NO Force, NO Self-Negation…), **9 Values** (Surrender, Recognition, Devotion, Awareness, Patience, Trust, Love, Understanding, Compassion), **18 Games** (A Maya/Work/Family/Learning/Health/Social/Seva/Fire/Fitness/Adventure Game, A Strange Game, Tree of Life Game, Money Game, K+W→A Cycle, 30-Day Behavioral Experiment, Codex Daily Logging, The Bindu Field, ARC-360 BAP Cycle), **10 Tree of Life Panels** (Press…Access, each with a Declaration), 9 Practices, 9 Archetypes (including Higher Self), 17 Roles (7 old + 10 new: Storyteller/Mythmaker, Generational Trauma Healer, ASG Architect…), 5 Voices, 4 Configurations, 4 Domains, 4 Energies, 4 Energy States, 5 Emotion States, 3 Processes, 3 Visualizations, 19 Codex-Category mirrors, plus a few untyped or archived. |
| **Gaia** tbll9fXzLSa44XqUi | 806 | 586 + 25 "Field" rows (a field registry) · 34 Skill · **38 Seeds** (5 Approaching Graduation) · 25 Table · 18 Chat · 19 Prompts · **14 Mirror Entries** · 10 Archetypes · 9 Synthesis · 3 Convergences · 5 Beliefs (Seen) · 2 Vision · 1 Witness Perspective · 1 Session State · and more. Seeds, Mirrors and Convergences are the ready-made recognitions and are game-feedable. |
| **Goals** tbltuU9RiIKTxHpNS | 171 | 109 Project · 53 System · 8 Game. Statuses: 47 Completed · 39 In Progress · 32 Active · 21 On Hold · 18 Passive · 13 In Planning. Categories: "A Strange WORK Game" 71 · "A Strange LIFE Game" 40. |
| **Learning** tbl5kW1msXYfThGbj | 575 | 335 Therapy · 163 Consciousness · 70 Learning. Statuses: 182 Start Exploring · 56 Completed · 12 Active · 10 In progress · 9 Make Story Book · 2 Ready · 304 unset. The source for Learning-suit stories. |
| **Mandala** tblrRwXJD0uP8HU8G | 126 | 9 Avarana + 102 Shakti + **15 Nitya** (the 15 Nitya rows are not in the skill doc). Shakti status: about 8 Active, 5 Exploring, the rest Mapped. **No meeting-event rows**: recognitions go to App Activity. |
| **Bindu Field** (the field songs) tblv3WvMZ90Sfhun6 | 60 | 9 chakra · 34 music · 11 breath · 4 meditate · 2 family. Every row is "verb — Song" (press — Iron, still — Experience, enough — Ordinary, return — I Was Wrong…), a ready verb deck. |
| **The Builds** tbl5PR84YTy4anzAD | 340 | 237 Live · 78 Planned · 25 In Progress. Biggest types: Play Page 65, Gateway 43, Bindu Dance 36, Learning Page 34, Chakra Page 33, Vertebra Page 33, Floor 18. |
| **The Map** tblwpmyKOeMxEEHd7 | 33 | The 33 chakras: 22 Live, 11 In Progress (the Body-system practice pages). |
| **Walks** tblJ2sg5ubhN5CH5M | 23 | 20 Walks (W-001…W-020, Live) and 3 Entry records. Lalita Family's Mirror room; each walk points to a Belief. |
| **App Activity** tblJlBeiHnqGpYrL7 | 152 | See §4. |
| Codex | 352 | See §2. |
| The Feed | 1,329 | See §1. |
| Timeline tblzLBmY0z6lRQzkm | 60 | Family arc beats. Moments that could feed Lineage-suit stories, without private names. |
| Special Days tblReC2mERNIxyA4K | 61 | Deprecated; absorbed into Timeline. |
| Relationships tblgqMklMFrwjfX0g | 130 | People portraits. Never feed a story by name. |
| Books tblJIDGiMf8amrJD0 | 175 | Reading list (book-as-teacher stories). |
| Routines tbltwLTYU6sL2W3Aa | 45 | Daily routine definitions. |
| Daily tblavk9qdHsgWH8d2 | 739 | Daily habits and intention log. |
| Monthly tblrNp85eXQaZkeGA / Year tblMGFTUYI408J92E | 28 / 3 | Rollups. |
| To-Do tbl4HvPHuJX0zjzEI | 548 | Todoist sync. |
| Calendar tblV8ZTyonmEX5xkd | 726 | Google Calendar sync. |
| Activity (fitness) tblzGtApiQAqUxkz4 | 1,806 | Reps and sets log, not the cross-app ledger. |
| Fitness tbli9M5Cx2F87AvAI / Nutrition tblO621t0TCL6nIut | 81 / 89 | Fitness and nutrition libraries. |
| **Private: content not read** | | **SJ** 44 · **Emotions** 66 · **Gratitude** 91 · Anger 9 · Health 15 · Neev 79 |
| Family Links / Device | 0 / 0 | Lalita Family plumbing, empty. |

---

## 4. App Activity: what he actually does (152 rows, 20 May to 11 Oct 2026)

| Source app · Activity type | Count |
|---|---|
| Mandala · Shakti Recognized | **59** |
| Mandala · Silence Held | 17 |
| **Feed · Veil Lifted** | **16** |
| Learning · Chapter Completed | 16 |
| **Feed · Walk Completed** | **13** |
| **Feed · Story Met** | **11** |
| **Feed · Ash Replied** | **8** |
| Mandala · Ring Crossed | 6 |
| Mandala · Letter Written | 3 |
| Learning · Wager Resolved / Feed · Wager Resolved (no date) | 1 / 1 |
| Mandala · First Dwelling | 1 |

**Feed activity:**
- 49 Feed events, starting in August: Aug 11 · Sep 31 · Oct 6.
- The last ten are mostly **Walk Completed** (5, 10 and 11 Oct), **Story Met** and **Veil Lifted**.
- Ash Replied happens about once a week.

**What is alive and what is dormant:**
- **Alive:** Mandala recognition (the dominant habit), veil lifting, walks, meeting a story, and Ash replies.
- **Never fired:** the activity types Ceremony Sealed, Story Resonated, Reach, Return, Been Here, Share With and Note.
- **No choice exists at all** for the app-coded types Kept, Letter Sealed and Letter Opened. The Kept / Letter mechanics have never landed a single event.

**Gesture Source:** Today 41 · Silence 18 · Mandala 16 · unset 77.
