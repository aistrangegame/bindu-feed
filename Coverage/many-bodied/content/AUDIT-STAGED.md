# Audit of Staged records against the house laws

*12 Oct 2026 · independent audit · read-only (no record edited) · base `app248ZTWhYJlvQj2`, The Feed `tbl7vzODMMJUgeX0b`, Status = Staged.*
*The laws checked: AGENT-COMMON house laws, readers/20 §D (consolidated do-not-use), CONTRACT §2.6 and §7, GAMEPLAN §10.*
*Raw pull: `<scratch>/audit/staged.json` (2,312 records), flattened copy `staged-flat.json`, scan hits `hits.json`, script `scan.py`.*

## 1 · What was pulled

| Type | Staged |
|---|---|
| Field Comment (children, including 332 Lalita replies) | 1,328 |
| Story (11001–11913) | 332 |
| Resonance Voice | 332 |
| Waiting Role | 119 |
| Call (10055+) | 47 |
| Leela (810–899) | 38 |
| Swatch | 31 |
| Constellation | 30 |
| Interlude | 15 |
| Second Letter | 14 |
| Mirror Card (Veils) | 13 |
| Room | 8 |
| Planted Seed | 4 |
| Letter | 1 |
| **Total** | **2,312** |

## 2 · Scan totals

These fields were scanned: Name (except child key names such as `S-11021-Karishma`), Body, Excerpt, Closing Line, Comment Body, Mirror Line and Convergence Line. **Blurb does not exist on this table:** asking for it returned a 400 error. Text inside `⟪…⟫` marks, and the backstage `SIGNED:`, `FROM:`, `AFTER:`, `NOT BEFORE:`, `KIND:` and `WHEN:` lines, was scanned separately.

| Category | Raw hits / records | Real after reading |
|---|---|---|
| Digits as figures | 135 / 118 | **0 on screen.** Every digit is in a Waiting Role's backstage `source: readers/19 A-05` provenance (see notes) |
| Number words with units | 67 / 47 | No business figures. The figure-like phrases are "three generations", "four people… four first letters" (11501, see should-fix), "six years" and "ten years" |
| Brand, product, tech, certification, retailer, competitor or place names (full §D list plus extras) | **0** | 0 |
| Private names in text | 219 / 219 | Every hit is a **Lalita reply that addresses an existing voice**: Sid 64 · Arch 62 · Karishma 60 · Ashrey 33. **No Neev or Shweta anywhere, and no family, staff or customer name** |
| Archetype labels in prose | 114 / 114 | Lalita replies addressing Gaia (61), Sakshi (51) or Bindu (1), plus one Waiting Role backstage line |
| Health / medical | 63 / 45 | Mostly false positives ("stillness", "wound" for winding, "patient"). About 4 are real (below) |
| Cosmology stated as fact | 22 / 22 | 0. All 22 are `NOT BEFORE: 2027-…` dates on Leela drops |
| Sealed material | 10 / 9 | No Reveal, Lalita Pass, Final Reveal, "Stop. You are in this story" or 136.1 Hz. The 10 hits are the §D book refrain "the same hand(s)" |
| Mechanism words in Body, Excerpt or Closing Line | 15 / 8 | See should-fix |
| Placeholders (TODO, XXX, lorem, `[ ]`, `{{`, TBD) | **0** | 0 |
| Unbalanced `⟪⟫` marks | 0 | 0. Every mark kind used is defined (`⟪was:⟫` is defined in scores/W2 §1.4) |
| Closing Line ≠ the body's last paragraph | 15 | 13 are Stack or Ground stories, as the form allows. 11739 is Stack-like. 11032 differs only by a trimmed lead-in (note) |

**What was read in full:** 58 stories across every band (110xx ×13, 111xx ×8, 113xx ×10, 115xx ×11, 117xx ×11, 118xx ×1, 119xx ×4), plus 4 more pulled on scan hits. Also 14 Field Comments, 6 Resonance Voices, 10 Calls, 10 Leela drops, 10 Swatches, 4 Interludes, all 14 Second Letters, the Letter, 4 Constellations, all 4 Planted Seeds, 4 Veils, and every Waiting Role name and telling invitation.

## 3 · Must-fix

| # | Record | Field | Offending words (≤15) | Law broken |
|---|---|---|---|---|
| M1 | 11169 `rec8Bx3QyVJHRkaEt` *The Lesson That Came Round Softer* | Body | "One in a small warm body on four feet, who asked nothing and poured love" | Never on a low day. This is the family's dog, recently lost, written as if alive and "come back with him". In the same paragraph: "the one who raised him… from heat to love" (a parent's temper; family material) |
| M1b | child `rec1HmRzpbGUtXaQo` (Lalita reply on 11169) | Comment Body | "Karishma, the four-footed one was my idea. Best idea I ever had ◡" | Same. It jokes about the lost dog |
| M2 | 11058 `recnfRXnPekP0kN4v` *From Here the Only Way Is Up* | Body, Excerpt | "The one who had kept me last had lost his way"; "You would be buying a dud" | A real third party (the previous owner) is identifiable by role and detail and portrayed as failing. §D business (acquisition and adviser talk). Children carry it on: `recWnnTM4GgPI0FbS` "the experts said dud", `recrAGXGsb0eoiBbJ` "…is a dud" |
| M3 | 11061 `recx0ldpfqvvKF2qg` *The Summer That Turned* | Body | "belonged to someone who had stopped listening. Cloth had been paid for and never sent"; "Their money back" | The same identifiable previous owner, cast as at fault. Money and refunds (§D business: pricing and commercial complaints) |
| M4 | 11073 `rec9JLN4PJPZYnpsc` *Whatever They Called Me* | Body (+ `⟪names:⟫`) | "Three pages in the catalogue. Three pictures. Three prices"; "strong enough for the ward" | §D: product-line and SKU structure, plus pricing ("sold me at the price of whatever you asked for"). Clinical setting ("ward", "long corridor"). Incontinence allusion ("keeps a bed dry through a hard night") |

## 4 · Should-fix

| # | Record | Field | Offending words | Law broken |
|---|---|---|---|---|
| S1 | 11501 `recMdQvDJOhP5E5DM` *The Room They Were Standing In* | Body, Excerpt | "Four people, four first letters. Somebody needed a name for a small company" | Decodes the company's name (first letters spelling the old word for the sky): a brand identified, plus the family as its letters |
| S2 | 11071 `recYvjCSkHjKhuWOF` *The Candle That Lit the Next* | Body, Excerpt | "answered by one of the four people who began me… Only one… knew how cloth is engineered" | Founders identifiable by role and detail (private) |
| S3 | 11503 `recRTo3RDex0rGgf8` *Two Cups* | Body, Closing | "Two families had arranged this hour… By evening… the thing was settled. The same day." | His own marriage meeting: family-private and adjacent to the sealed Ashrey–Karishma Final Reveal (§D family). Waiting Role 12004 asks for "the other side of the coffee day" |
| S4 | 11701 `recYtGwF8mpHJcApi` *Strange, Because That's What Life Is* | Body | "a page for emotions, a page for anger" | GAMEPLAN §10: the Emotions and Anger bases are sealed. Only named here, not quoted |
| S5 | 11160 `recFlgNSnDX52kaDS` *I Have Never Once Been Locked* | Body | "the ones who loved him stand their ground and keep something clean" | Implies a relative's struggle, which is a family or health inference |
| S6 | 11903 `recMpZ9n34yb59xdF` *Still Only a Wish* | Body | "*for my mother, who can't sleep in the heat,*"; "the ones who wake damp" | Reads as a customer's exact words. Night sweats is on the §D health list |
| S7 | 11302 `recbU3CkeenwcuHNb` *Let the Same Hands Fold It* · WR `recvKJmEpGgeQI7W2` | Body, Excerpt, Name | "Let the same hands fold it." | Likely a customer's verbatim order note (§D: quotes). Also the §D book refrain "the same hand" |
| S8 | 11906 `recTsbR2aGT95TRzS` *One Line in the Notes Box* | Body | "*Please let this be the right one.*" | Likely a customer's verbatim note. Its Convergence Line repeats "the same hands" |
| S9 | Leela 828 `reczdnqx0YFpsh0X9` | Body | "You were never the first to wonder." | §D book refrain "You are not the first" |
| S10 | the "same hand" refrain in new text: 11509 `recTRcE8ZA0SGyq7F` (Conv), 11714 `reciqC2Sx72N0bi5p` (Conv), 11364 `recMKKDTwz5QomOUL`, 11035 `recXvjD3PKLwi100C`, 11786 `rec8VJ8Q7mD2Exjui` (Excerpt and Closing "same hands") | various | "the same hand…" | §D book refrains |
| S11 | 11317 `recXLXco1pWNem01I` | Body, Closing | "The comfort was the signature." | Mechanism word on screen (GAMEPLAN §2, CONTRACT §2.1) |
| S12 | 11727 `recZOVVvrk0IR2fVm` | Body, Excerpt | "There is a secret in my grammar" | Mechanism word on screen |
| S13 | 11148 `recPjsRsYagfMeN1d` *The Building Age Never Stepped Back* | Body | "Light that didn't need a flame. Rooms that answered thought." | Close to an Atlantis fragment told as a lived age. Cosmology is allowed only as rhyme. (11147 *The Gentle Age* is the same kind; note) |
| S14 | 11327 `recRWXwJvPVtHLNz4` | Body | "the long sigh old dogs keep for the end of things" | Low-day sensitivity given the recent loss. Hold it or keep it away from early arrivals |
| S15 | Leela 837 `recJlg2p5Vb6Ymdmt` | Body | "Go and stand in their garden… Ask them one thing" | Assumes the ones who raised him are reachable; family. Can hurt on a low day |

## 5 · Notes (no breach found, or a judgement call for the coordinator)

- **Lalita replies name voices** ("Sid, …", "Karishma, …", "Ashrey, …") in 332 children. This is the established reply form, and CONTRACT §7 keeps the existing voices. No new name is added and there is no Neev or Shweta. But "Ashrey, …" puts his own name into new text 33 times. Confirm that is wanted.
- **Waiting Role provenance** (`seed: … · source: readers/19 A-05`, `readers/06 App. C-1359`) is in Excerpt on most of the 119 roles. It also sits in **Body** on the waiting tellings and on a few others: 12004, 12013, 12022, 12035, 12060, 12073. C6 says this text is never rendered. Track 2 must not render Waiting Role Body, or reader codes will show.
- **Leela `NOT BEFORE:` dates** (22 drops, 2027) are allowed by CONTRACT §2.6. They must light and never lock, and the date must never show.
- **Calls** carry an `Archetype` value (Karishma, Arch…) as well as `SIGNED:`. The signature must read SIGNED, never the archetype or "— Ashrey" (CONTRACT §2.6 debt).
- **Mechanism words in a plain sense:** "chapter after chapter" (11021, 11013), "rhyme" (11710, 11705), "tellers" (11798), "signature" in 11507 Body and 11331 Convergence. Low risk, but the law is literal.
- **Family material that is tender, not conflict:** 11505 *The Spoon* (a mother choosing milk or school), 11509 (the father writing the birth certificate; "two countries"), 11030 (a letter of thanks to his father), 11786 ("the pickle someone in the family makes"). All pass. Read them as his family.
- **Business shape, unnamed:** 11912 (an envelope to "a giant", meaning a large retailer), 11069 (the work went across the ocean), 11568 ("when everything shut", a pandemic only implied), 11551–11555 (the supply-chain houses), Planted Seed 14001 ("swatch kits", his own words). All are within the screen.
- **Low-day weight:** 11084 ("the fire that ends cities") and 11902 ("a small mattress that was dry in the morning", a bedwetting allusion, abstract).
- **Form:** 11032 `rec0XJTJRAvTkUcBU` Closing Line drops the body's "That is the whole of it." Veil 13213 `recg6OBvIoToufFqr` has Name "?" and a body that is only `⟪veil: return⟫`, which is near-empty.
- **Second Letters and Planted Seeds** are his memo transcripts. They are clean.

## 6 · Fixes applied

*12 Oct 2026 · every must-fix and should-fix rewritten in place on Staged records (no Live record touched, nothing deleted). Verified by a fresh pull of all 2,312 Staged records into `<scratch>/audit-fix/` and a re-run of `audit/scan.py`: **sealed 0 (was 10), mechanism 0 (was 15)**; the other category counts are unchanged except figure-digit 134 and figure-word 57, both down because provenance lines and old phrases were removed. Each fixed story was re-read in full in the server's echo after the write.*

| # | Record | What changed | Verified |
|---|---|---|---|
| M1 | 11169 `rec8Bx3QyVJHRkaEt` | The dog and the parent line are gone. The two who stand beside him are now the one he was last time (who set the cup down) and the one he will be when it is easy. Marks, title and closing are kept | Body re-read; no dog or parent left |
| M1b | `rec1HmRzpbGUtXaQo` (Lalita), `recFXi28JeJUm40FK` (Karishma), `recdiVH8gfEKVp71p` (RV) | Each echo is rewritten to the cup and the earlier self ("I kept the cup warm on purpose…") | ✓ |
| M2 | 11058 `recnfRXnPekP0kN4v` | Now the cloth's own telling: the last roll at the bottom of a long-kept stack. The careful ones say "nothing left"; she kneels and sees the floor. The keeper is shown kindly. No failure, no "dud", no advisers. New Excerpt; the `⟪held:⟫` line is rewritten | Children `recWnnTM4GgPI0FbS`, `recrAGXGsb0eoiBbJ`, `recNQuuEYjXVdZdB3` and `recd2TCgEt4Z6rL5o` rewritten to match ✓ |
| M3 | 11061 `recx0ldpfqvvKF2qg` | Now the cloth kept on a high shelf, long waited for. New hands climb up, answer each letter and send it with something extra. No owner at fault, no money or refunds. Closing, Mirror and Convergence updated | Children `recVkBSeAHVnSyJeW`, `recC7a69rzt8yNMGL`, `recdG7eduQT8dGxGo` and `rec0AD7qrKCJmthT5` rewritten ✓ |
| M4 | 11073 `rec9JLN4PJPZYnpsc` | The three names are now nursery, lunch tin and rain (picnic, pram, bicycle). No catalogue, prices, ward or corridor, and no bed-dry line. "Buyer" is now "maker" | Children `rec0yUaHyLLRGf3X3` and `recgUdvUiecARIuIL` and Convergence ✓ |
| S1 | 11501 `recMdQvDJOhP5E5DM` | No letters and no "four people". A name reached for in a hurry is later found to mean the old word for space. Excerpt rewritten. Its Waiting Role 12007 `recnar52cUoawI0tK` seed also no longer mentions first letters | Children `recPc2a3qTZRuTFQC` and `recwQXO8jSVRE5sXy` ✓ |
| S2 | 11071 `recYvjCSkHjKhuWOF` | Now "the ones who began me"; the engineering detail is removed. Excerpt matches | ✓ |
| S3 | 11503 `recRTo3RDex0rGgf8` | Now two strangers put at one café table on a rainy afternoon, who part as one conversation. No families, nothing settled. Excerpt, Closing and Convergence rewritten. Also changed: **11504 `recAk3yKDnfccBSD9` *The Walk After*** (not listed in the audit, but it was the same marriage day: families, a red mark, "yes"). It is now two strangers leaving a library who fall into step, and a friendship. **Waiting Role 12004 `reci225C505xmR31R`** now points at the rainy table | Children `recQt32md7VSEBxZW`, `recssbMRQ8YwNBO45` and `recQrlStR7vc3hTow` ✓ |
| S4 | 11701 `recYtGwF8mpHJcApi` | "gratitude journal / a page for emotions, a page for anger" is now "pages kept on the good days and the hard ones"; "journals" is now "pages" | Child `recISuN52XvpgDtwY` ✓ |
| S5 | 11160 `recFlgNSnDX52kaDS` | The relatives' line is replaced by a green shoot coming up through the path | ✓ |
| S6 | 11903 `recMpZ9n34yb59xdF` | The quoted line is now the shape only ("asking on behalf of someone she loves, someone the summer is long for"). "Wake damp" is now still air on a hot night | Child `recPS0lon8BFpQezA` ✓ |
| S7 | 11302 `recbU3CkeenwcuHNb` | **Retitled *She Asked for the Hands*.** The note is paraphrased and the refrain removed. New Excerpt. RV `recPnIQRHCicxLXOV` and WR 12058 `recvKJmEpGgeQI7W2` renamed | ✓ |
| S8 | 11906 `recTsbR2aGT95TRzS` | The quoted note is now a paraphrase. Convergence no longer says "same hands" | Child `recg39jmctJ8lOVaw` ✓ |
| S9 | Leela 828 `reczdnqx0YFpsh0X9` | The refrain is replaced with "Every face that ever tilted up to it is tilting up beside yours." | ✓ |
| S10 | 11509, 11714 (Conv), 11364, 11035, 11786 (Body, Excerpt, Closing) | "Same hand(s)" removed in each. 11786 now reads "same plate, same jar, same fork". The same refrain was also fixed outside the audit list: 11080 `recSkVhQZwwP0W9Yf`, Swatch 13513 `rece7RhbF56gUjVlV` (now "One Pair of Hands"), `recfQRtPLykRT1rSU` and `recjCo83GNhdZYQL0` | scan sealed = 0 ✓ |
| S11 | 11317 `recXLXco1pWNem01I` | "The comfort was the signature" is now "The comfort was my name" (Body and Closing) | ✓ |
| S12 | 11727 `recZOVVvrk0IR2fVm` | "secret in my grammar" is now "secret in the way I ask" (Body and Excerpt) | ✓ |
| S13 | 11148 `recPjsRsYagfMeN1d` | The Atlantis-like details are gone (towers, singing bridges). Added "Every life has a season like me, and so does every old story…" so the age reads as rhyme. 11147 is unchanged: it has no technology claim and is told as old songs | ✓ |
| S14 | 11327 `recRWXwJvPVtHLNz4` | "the sigh old dogs keep for the end of things" is now "the one that means the house is his again"; "the way it does with old dogs" removed | ✓ |
| S15 | Leela 837 `recJlg2p5Vb6Ymdmt` | The garden is now "anyone's", the one tending it is asked, and nothing assumes family. Renamed "Leela — A garden" | ✓ |
| notes | 11021, 11013, 11710, 11705, 11798, 11507 (Body); 11331 (Conv); child `rechFL3jff4hY7LmA` | Plain-sense mechanism words rewritten (chapter, rhyme, tellers, signature) | scan mechanism = 0 ✓ |

**Left for the coordinator (not in the audit's fix lists):**
- Prior-owner stories with the same shape as M2/M3: 11516 ("what they'd already paid for"), 11517, 11563, and 11330 `⟪wash: I wanted my money back.⟫`.
- 11072 still has "in the catalogue I appeared on one page only" and a clinical corridor.
- Mechanism words in children: `recH24aLUDUOy8ZWl`, `recrderAHrAINGFnl` ("signature"), `recsrXnNLPWvG86E7` ("grammar"), `recWhvsVVOUyYRtq4`, `recTAQvMFBOZPhvMh` ("chapter"), `recyfriZApWax28sx`, `rec9GDBwGdDYuyNJC` ("teller").
- 11327 is still a story about a dog's bed. Hold it away from early arrivals.

### 6b · Second round (coordinator follow-up)

*Verified against a second fresh pull of all 2,312 Staged records (`<scratch>/audit-fix2/`), with `scan.py` re-run: sealed 0 and mechanism 0. A targeted scan for dog, puppy, paw, four-footed, leash, kennel, dud, money back, already paid and similar terms finds nothing left; the only remaining "corridor" and "catalogue" hits are figurative. Each changed story was re-read in full from the server's echo.*

| Record | What changed | Verified |
|---|---|---|
| 11516 `rec18aFDAmmhbnHvj` *Thursday to Tuesday* | The keepers now walk the newcomers through the place gladly, and the keys change hands with a handshake. Removed "bad reputation", "papers were signed" and "already paid for". Excerpt rewritten | ✓ |
| 11517 `recvmXZQc7Er05DMZ` *The Oldest Letter First* | Now "for a season, between one pair of hands and the next, nobody was sitting with me". Removed "busy leaving", money and "your order was never sent" | ✓ |
| 11563 `rec6yH8PMqQ7qFh58` *The Old Complaint* | The message is now a question nobody was there to read for a season. The reply comes from "someone new". The wrong is now a silence. Excerpt and Convergence updated | ✓ |
| 11330 `recXspGCBnk3MDhKQ` | `⟪wash: I wanted my money back.` is now `I wanted to send it straight back.` | ✓ |
| 11072 `rec0HZnZjoAUysUkR` | Catalogue page, number and product-line talk removed. The ward/corridor is now a school hallway. Children `reca3LBibSqdu7Vub` and `receOgXOjQyfsJTws` now end on "the name" | ✓ |
| Seven children: `recH24aLUDUOy8ZWl`, `recrderAHrAINGFnl`, `recsrXnNLPWvG86E7`, `recWhvsVVOUyYRtq4`, `recTAQvMFBOZPhvMh`, `recyfriZApWax28sx`, `rec9GDBwGdDYuyNJC` | "signature", "grammar", "chapter" and "teller" rewritten (e.g. "your own hand showing", "every telling", "any single voice") | ✓ |
| 11327 `recRWXwJvPVtHLNz4` *The Night the Thunder Came* | Retold as a boy's sleeping mat in a garden tent. The ground's water stays under the layers. No dog, no bodily allusion. Excerpt, Closing and Convergence updated; Lalita `recH3cvTOR0uon6z1` now says "the grass" | ✓ |
| **Dog sweep** | | |
| 11125 `reczJXfN69d9iB51T` | Retitled ***Where She Lay Down***. The smallest child of the house and her blanket on the porch square. Excerpt rewritten; RV `recrKS4aAyXQ5lGBm` renamed; Lalita `recCrnSSNxvLwRARd` updated | ✓ |
| 11305 `recy9jO93v5qaDiGr` | Retitled ***He Doesn't Pull at It***. A baby's sleeping bag replaces the dog coat. Excerpt and Closing updated; RV `rec4URImUZOTCKJxH` renamed; children `recg4JMJctziQFhWr` and `recrdXhzVKFDhsh3f` updated | ✓ |
| 11790, 11338, 11304, 11352, 11111, 11515, 11728, 11909 | One-line swaps: a robin's tilt; the stair that creaks; a window-seat cushion; the sewing basket; "kennels" is now "baskets"; a cat; a sparrow; a garden-chair cushion | ✓ |
| Children `recvYJqzhFbyNOVrR`, `recjx51QKx9zxtQke` | Dog references replaced (a cat; "the cape is my favourite") | ✓ |
