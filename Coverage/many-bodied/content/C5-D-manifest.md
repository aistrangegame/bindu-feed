# C5 · D — Call answers from bodies · Leela round 2 (manifest)

*12 Oct 2026 · Track 1 · writer C5-D · GAMEPLAN §8 C5, §6 Call row ("answers from any body"), W5 D5. Base `app248ZTWhYJlvQj2`, The Feed `tbl7vzODMMJUgeX0b`. 77 records, all **Status Staged**, typecast, batches ≤15, nothing deleted, no existing record edited. Read-back: 85 Staged Call/Leela rows in the base = 8 W4 rises (810–817) + 47 Call (10055–10101) + 30 Leela (818–847).*

## 1 · Call answers from bodies — Type `Call`, 10055–10101 (47 rows)

**Shape matched to 10001–10054** (`CallAnswer.init`, Models.swift:531): `Name` = `Call — <state> — <Teller> · <source title>` · `Body` = one passage, 25–55 words, single paragraph, **lifted verbatim from the source story** (sentences may be skipped between, never reworded; two sentence-initial capitals adjusted; no `⟪…⟫` marks carried) · `Excerpt` = `STATE: <word>` (one of the 18 `CallStates.all`), plus two new lines · `Archetype` = the voice that signs first (Bindu · Gaia · Sid · Arch · Sakshi · Karishma · Lalita — no Neev/Shweta/Ashrey) · `Source Date` = the source story's date · `Codex ID` **empty** (not his words) · `Teller` (backstage) = the source story's teller. Every state now has 2–4 body answers beside its 3 memo answers.

**How a passage resolves to its teller (new Excerpt lines; ignored by today's parser, which reads only `STATE`):**
- `SIGNED: <role words>` — the resolved signature, lowercase, roles only (e.g. `the ground`, `the ribbed edge`, `the one who nearly sent it back`).
- `FROM: <record id>` — the source story (11001+), so the answer can open/rhyme to it.
- **Owed to Track 2 (next score, carry it):** `CallView.answerLayer` (`CallView.swift` ~:176) hard-codes the resolved line as `— Ashrey · <spokenOn>`. For a row with `Codex ID` empty and a `SIGNED:` line it must resolve to `— <SIGNED> · <spokenOn>` instead (and may offer the `FROM` story). Until that lands, a Staged-reading build would sign these passages with his name — wrong. Rows are Staged, so his installed phone is unaffected.
- **Why not a link field:** `Linked Story` is a symmetric pair with `Parent Comment` (it would write the Call row into the story's `Parent Comment`), and `Rhymes` would put Call rows into `Rhymed By` and so into RhymeIndex's pairs. The id lives in `FROM:` instead. Call made here.

| Sort | Record | State | Teller | Signs · resolves to | From (sort · title) | words |
|---|---|---|---|---|---|---|
| 10055 | `recy1yDrYnrhomTRY` | scattered | Cosmos | Lalita · the point | `rec0XJTJRAvTkUcBU` The Point at E | 49 |
| 10056 | `rec85ys5rKmr6MAxg` | scattered | Object | Arch · the scissors, before the first cut | `recFcbCfMdWNdw8p1` Before the First Cut | 43 |
| 10057 | `reckmVMtxTOkpEF5c` | heavy | Land | Gaia · the ground | `recOP37hnfbp31kRJ` The Floor Under Every Falling | 47 |
| 10058 | `rec7N6T5pufWOwvlH` | heavy | Silence | Sakshi · the long quiet | `rechkSruMucoYzxT4` A Curtain Around a Cot | 44 |
| 10059 | `recF1kKeYDwk5NwDt` | heavy | Company | Karishma · the small company | `recnfRXnPekP0kN4v` From Here the Only Way Is Up | 26 |
| 10060 | `recUqxqAsAMxirlJz` | rushed | Maker | Arch · the maker at the machine | `recpr2S6OSHWqqTgx` Slow Down and It Goes All the Way | 38 |
| 10061 | `recmD07sIY4CjISYj` | rushed | Lineage | Sakshi · the pattern in the border | `rec5qWgmT9zCz3cCo` The Pattern Hidden in a Lullaby | 47 |
| 10062 | `reckj9LF9toRt9Snh` | rushed | Land | Gaia · the ground | `recYcE2A3ZuH4JC6u` One Word a Breath | 42 |
| 10063 | `recOZpz87vdz3YH50` | unseen | Silence | Bindu · the air between the cloth and the skin | `recKz28WyPmSlKSpB` The Space Between the Cloth and the Skin | 45 |
| 10064 | `recHXJ4KKBrxj3cDv` | unseen | Object | Sid · the chair | `recCFpEUqHBSbdcoc` The Chair in the Meeting | 28 |
| 10065 | `recHgWpRuneXHaTiY` | unseen | Object | Arch · the review still being read | `recoa22AshGpmiGXi` The Review Still Being Read | 25 |
| 10066 | `reczAs215kLcoFXTI` | unseen | Land | Gaia · the roots | `recXq19xzzW9J9q0r` Nobody Thanks the Roots | 35 |
| 10067 | `rec4d0fsYQFKnr3vB` | anxious | Time | Lalita · the evening before | `recuTbRh1aSDOsAYt` The Evening Before | 36 |
| 10068 | `reczKynVqaOwDswEl` | anxious | Cloth | Bindu · the cloth that breathes | `recyrdkvyxrjZPD4h` If I Held My Breath | 35 |
| 10069 | `rec4s7QTuLpRFNatQ` | stuck | Machine | Sid · the knitting frame | `rec9NUecZKAvte7SS` The Morning Nobody Switched Me Off | 32 |
| 10070 | `recmvlZe33TVXRQAT` | stuck | House | Arch · the door | `recFlgNSnDX52kaDS` I Have Never Once Been Locked | 41 |
| 10071 | `reccDIiGda9fH1AdC` | stuck | Machine | Karishma · the machine that doesn't know | `recsdYAyWqgxVaTLG` Help, I Don't Know | 51 |
| 10072 | `recxNxW7IP9Cx3eJR` | tired | Body | Bindu · the skill asleep in the hands | `recaVfetRzbcYYVuU` Something Worth Waking For | 55 |
| 10073 | `rec2XB70Wym9MoY2r` | tired | Time | Sakshi · the held breath | `reckfh19azvQGV8hC` The Breath at the Top of the Building | 28 |
| 10074 | `recTl0gVtGwCaNATO` | restless | Body | Lalita · the body | `recK6VVlB5JmlqLq1` I Lean Before You Decide | 46 |
| 10075 | `recp1zHV8zpISw7BU` | restless | Song | Karishma · the two hums | `recJqX1Gi3v7hILnX` Two Tones Leaning Into One | 38 |
| 10076 | `recuDSxmilf4dqpBa` | small | Cloth | Sid · a piece of the one roll | `reclp1izG4mrXmVWk` Look What My Maker Made Me Into | 40 |
| 10077 | `recYgvLfErllDH471` | small | Cloth | Arch · the cloth under the tap | `recoj1rsPyp8ajk4C` The Day I Found Out I Was Waterproof | 24 |
| 10078 | `recN7St2S8O8sgFAP` | small | Object | Sakshi · the folded shirt | `recLxx0rWhSNwR2AE` Still Good, Still Folded | 31 |
| 10079 | `recYL5xYB4D8zbq07` | lost | Time | Bindu · the past | `recCzxWKeTXH6ZaPO` Every Road I Ever Was | 52 |
| 10080 | `rec6NfdLPLoNzxoPb` | lost | Cloth | Karishma · the cloth cut from the roll | `rec48shNKBu7ZYpNC` The Cord I Was Cut From | 41 |
| 10081 | `recFkfTpiSzr8RtkP` | lost | Machine | Sid · the machine that wanders | `recg1JzZ97YEb4AZv` A Room Nobody Furnished | 43 |
| 10082 | `recXTyerPdLbO9JMI` | behind | Cloth | Lalita · the cloth on the shelf | `recEDAzEjmFvwmkGb` Only You Arrived | 44 |
| 10083 | `recvXZDbNB67HGTST` | behind | Time | Arch · the present | `recbsewcXjSKB8YCv` The Only Page Still Being Written | 40 |
| 10084 | `recPGobaFtZ1Ucb0Q` | behind | Company | Karishma · the company, the week it moved | `rec2R70PfEv8c4lnG` One Yard at a Time | 33 |
| 10085 | `recFF6uryfCBZlzvM` | alone | Body | Arch · the gold thread | `rec6UomPbxcZYQQDT` The Gold Thread Came Hand to Hand | 45 |
| 10086 | `recqsKQFtTY7scN2J` | alone | Maker | Sid · the one who teaches the fold | `reccj8kgu4o9fOL5C` The Evening It Passed Through | 45 |
| 10087 | `recCWIBId7v8QQxSC` | alone | Cosmos | Sakshi · the telling | `rec5UFo4tNJsRwgC2` I Don't End, I Change Hands | 30 |
| 10088 | `recKJULrnkr4DqnpL` | alone | Land | Gaia · the ground | `recu0akNdIWCVwZAf` When the Light Arrived | 37 |
| 10089 | `recCzKq00LgxPMPMB` | doubting | Cloth | Bindu · the roll with the pale line | `recWgpVm1ZHc6uqTz` The Roll With Its Reason Written Down | 45 |
| 10090 | `recp9B3ZCCrN9aA9T` | doubting | Customer | Lalita · the one who nearly sent it back | `recXspGCBnk3MDhKQ` Too Stiff | 45 |
| 10091 | `rectzIATnPWBVluem` | overwhelmed | Company | Arch · the house of many hands | `recWZCsEtgMe52JpM` Everyone Was Holding Me | 36 |
| 10092 | `rectioOLjiCy83ET7` | overwhelmed | Cloth | Sid · the soft mat in the lane of wheels | `recxOPEVqYicEQUSl` Every Weight That Crossed Me | 39 |
| 10093 | `recgPgX78hNoiahPc` | numb | Land | Karishma · the water in the wash | `rectb6pFEsiLxnwck` I Don't Make Anything Soft | 37 |
| 10094 | `recOMi7QXsHDwh4pN` | numb | Shakti | Lalita · the current at the root | `recgvbyHQYKKSAS0C` The Garden Was a Body | 38 |
| 10095 | `recspv5I46a8JWcoG` | tight | Cloth | Arch · the ribbed edge | `recz10LaddyD5h8hO` The Edge That Lets It End | 52 |
| 10096 | `recuhbraXHjlMK3Cd` | tight | Body | Sakshi · the floor of the body | `rec8n45K7KI6RMaWO` The Breath I Gave Him | 53 |
| 10097 | `recWHyQX2pquMAAP9` | distracted | Cloth | Bindu · the soft jersey | `rec02gByBc8CRUOg6` I Find the Shape You Are | 48 |
| 10098 | `recxD4T0s8HZqDf79` | distracted | Song | Karishma · the rhythm | `recqZHaAKuzhX5Z7S` A Heartbeat Heard Through a Wall | 43 |
| 10099 | `recSIO6Ftasjn5Iea` | far away | Lineage | Sakshi · the first family | `recCGpWd0i8anzvgU` Two Coals From the Same Fire | 31 |
| 10100 | `recj6f2itPuBwqM17` | far away | Lineage | Sid · the path left open | `recs6aZCQ32xEkUhZ` The Path Left Open | 37 |
| 10101 | `recLpJgHYLwUUrIJ2` | far away | House | Lalita · the round house | `recUT8aEbfzp12osS` First a Place, Then a Feeling | 32 |

Teller spread: Cloth 9 · Land 5 · Object 4 · Time 4 · Body 4 · Company 3 · Lineage 3 · Machine 3 · Cosmos 2 · Silence 2 · Maker 2 · House 2 · Song 2 · Customer 1 · Shakti 1. Signers per state never repeat inside the state.

## 2 · Leela round 2 — Type `Leela`, 818–847 (30 drops)

**Shape matched to 801–817:** `Name` = `Leela — <title>` · `Body` = 2 short passage paragraphs, blank line, the act as the last paragraph (`LeelaDrop.init`: last `\n\n` paragraph = act) · 53–69 words · `Excerpt` = conditions as today (`AFTER:` only types that exist — Story Met, Walk Completed, Veil Lifted, Return; `NOT BEFORE:` every ~2 weeks from 2026-12-06 to 2027-10-28, each drop's season matching its date) or `KIND: rise` alone (6 giving acts, undated, for the board, as 810–817). Backstage: `Teller` = the body the drop comes from, `Face` = Lalita. Two drops from each of 15 bodies; no two adjacent sorts share a body.

Voice law kept (leela-architecture; readers/07 §1.11): second person about his real life (the sweater, frozen ground, the machine he talks to, the training floor, the small players on the field, the parents' garden, the phone, the pause before the car door), never names him or the builder, never foreshadows or mentions other drops, no chakras, no numbers or counting, no streaks, nothing urgent; every act is small, real-world, and the app supplies its silent twin. Nothing about loss, health, family conflict, money, names or brands.

| Sort | Record | Title | Teller | Excerpt |
|---|---|---|---|---|
| 818 | `recWPUWUre73n9a6v` | The sweater knows | Cloth | AFTER: Story Met · NOT BEFORE: 2026-12-06 |
| 819 | `rech3YktL0AbiLCoz` | Frozen ground | Land | AFTER: Walk Completed · NOT BEFORE: 2026-12-18 |
| 820 | `rec9HVlqadoHmvsMU` | The one you talk to | Machine | AFTER: Story Met · NOT BEFORE: 2026-12-30 |
| 821 | `rec32uiU3z0zRoMk7` | The hands before yours | Lineage | AFTER: Story Met · NOT BEFORE: 2027-01-11 |
| 822 | `recAJTONePkjMA81g` | Someone is sewing | Maker | AFTER: Veil Lifted · NOT BEFORE: 2027-01-23 |
| 823 | `reci3PCYsOaX2RzVm` | The thank-you you never answered | Customer | KIND: rise |
| 824 | `reclVyKBjUzVvorYT` | The desk without you | Company | AFTER: Story Met · NOT BEFORE: 2027-02-04 |
| 825 | `recRu3tXpD0ISlib4` | The song that keeps returning | Song | AFTER: Story Met · NOT BEFORE: 2027-02-16 |
| 826 | `rec1AnWEb4hT9JknJ` | Before the alarm | Shakti | AFTER: Story Met · NOT BEFORE: 2027-03-04 |
| 827 | `recM11XqFqLwFh7jQ` | The form your feet know | Body | AFTER: Walk Completed · NOT BEFORE: 2027-03-18 |
| 828 | `reczdnqx0YFpsh0X9` | The same light | Cosmos | AFTER: Veil Lifted · NOT BEFORE: 2027-04-01 |
| 829 | `recA8FmGtPalDBGOT` | The hour that is already here | Time | AFTER: Story Met · NOT BEFORE: 2027-04-15 |
| 830 | `recnCYRnesAfHNVsQ` | The house in daylight | House | AFTER: Return · NOT BEFORE: 2027-04-29 |
| 831 | `recXHfdvXTG7x23ql` | Face down | Object | AFTER: Story Met · NOT BEFORE: 2027-05-13 |
| 832 | `recfjRWOEdja0nB0F` | Before you open the car door | Silence | AFTER: Story Met · NOT BEFORE: 2027-05-27 |
| 833 | `rec5PqDU6OMQBewAO` | Bare feet | Land | AFTER: Walk Completed · NOT BEFORE: 2027-06-10 |
| 834 | `recuvKXUfY9WnNxqY` | The shirt on your back | Cloth | AFTER: Story Met · NOT BEFORE: 2027-06-24 |
| 835 | `recvH0dYTytrCGRNJ` | The empty hour | Silence | AFTER: Veil Lifted · NOT BEFORE: 2027-07-08 |
| 836 | `recd6idx16x8sGPcE` | Switched off | Machine | AFTER: Story Met · NOT BEFORE: 2027-07-22 |
| 837 | `recJlg2p5Vb6Ymdmt` | Their garden | Lineage | AFTER: Return · NOT BEFORE: 2027-08-05 |
| 838 | `recPRXmQZpXQJGthX` | Your hands are waiting | Maker | AFTER: Story Met · NOT BEFORE: 2027-08-19 |
| 839 | `recBSzOkQcmKI4JOu` | A stranger's patience | Customer | KIND: rise |
| 840 | `recf4HrhpPF3nWj9q` | The one who answers | Company | AFTER: Story Met · NOT BEFORE: 2027-09-02 |
| 841 | `recQfZyIa97vG0eae` | A song for someone else | Song | KIND: rise |
| 842 | `recg76hm4ZBWwP2ff` | The current in the kitchen | Shakti | KIND: rise |
| 843 | `rec1AXeOZ5Bl8kHoN` | Small red lights | Cosmos | AFTER: Story Met · NOT BEFORE: 2027-09-16 |
| 844 | `rec7hCcl9KOgYtC5W` | The same slant of light | Time | AFTER: Story Met · NOT BEFORE: 2027-09-30 |
| 845 | `recZKMT3o34s0Jq76` | The smallest players | Body | AFTER: Walk Completed · NOT BEFORE: 2027-10-14 |
| 846 | `recmnxhWuxi6KTqUu` | An open door | House | KIND: rise |
| 847 | `recEU0uj78sV2a1pc` | The knot before practice | Object | AFTER: Story Met · NOT BEFORE: 2027-10-28 |

## Calls made
1. Call rows carry the source story as `FROM: <id>` and the resolved signature as `SIGNED:` in Excerpt — no link field (symmetric-link and RhymeIndex side effects). Track 2 owes the resolution change above.
2. `Codex ID` left empty on body rows: emptiness marks "not his words", as Story Origin does for stories (CONTRACT §2.6).
3. Passages are verbatim lifts from the body stories (Shabdakarshini already passed them); joining skips sentences but never rewrites. Lines carrying private or health detail in the sources (the faces in the fear of 11028, the dog and parent of 11169) were not lifted.
4. Leela `NOT BEFORE` dates spread over a year (W5 D5: "eligible across a year of cycles") and match the season the drop speaks of; they make a drop eligible, never lock one. Six giving drops are `KIND: rise` and undated, so the board always has fresh rises.
5. Band use: Call 10055–10101 (10102–10199 free); Leela 818–847 (848–899 free).
