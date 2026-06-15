# BINDU FEED — CONTENT INVENTORY (for Airtable reconciliation)
*Everything the new layer (Phase 9) needs as data. Take this to Claude Chat and check each item against the live **The Feed** base — mark what already exists vs. what must be created. Content is pulled verbatim from the design prototypes; line breaks (`\n`) are intentional.*

> Pairs with: `BINDU_FEED_PHASE_9_NEW_LAYER.md` (the build spec) and `DESIGN_HANDOFF.md` (the design overview).

---

## 1. REFLECTIONS — `Type = Reflection` (The Mirror)
First-person, Ash's own crystallized words. `Archetype = Ash`. `Flairs` = **Vow** or **Koan**. `Status = Live`. The Mirror shows one per day, chosen client-side by date-hash (no tracking).

| # | Register (Flairs) | Comment Body |
|---|---|---|
| 1 | Vow | Trust is the variable.\nNot effort. Not control.\nTrust. |
| 2 | Vow | I witness the seeing itself.\nNot the seer, not the seen. |
| 3 | Koan | What was the fire\ntrying to protect? |
| 4 | Vow | What this pattern gave, I honor.\nWhat this pattern is, I see.\nWhat this pattern becomes, I trust. |
| 5 | Vow | I honor what the fire built.\nI see it now. |
| 6 | Koan | Who poured the cup,\nknowing it would be left\nto go cold? |
| 7 | Vow | I am the one who stays.\nEverything else was weather. |
| 8 | Koan | If no one is watching,\nwhat is the watching? |
| 9 | Vow | The forgetting had a shape,\nand I am the one who built it. |
| 10 | Koan | What would I do\nif I trusted the ground\nto hold? |

---

## 2. SIGNALS — `Type = Signal` (The Signal Space)
Second-person, oracular, from the field. `Archetype = Gaia` (or blank → shown as "— the field"). `Status = Live`. One per day, date-hash.

| # | Comment Body |
|---|---|
| 1 | The fear is the doorway. Not the obstacle to it. Walk into it. Completely. |
| 2 | You built the architecture to keep yourself from failing. The architecture became the room you cannot leave. The door was never locked — you have been holding it shut from the inside. |
| 3 | You keep asking the field for a sign. The asking is the sign. You already turned toward it. |
| 4 | What you are guarding does not need a guard. It needs to be let out into the weather — where things that are alive are allowed to change. |
| 5 | You think you are waiting for clarity. Clarity is waiting for you to move. Move first. It will meet you on the road. |
| 6 | The thing you cannot say out loud is the thing the field has been trying to hand you. Say it. This room was built to hold it. |

---

## 3. ARCHETYPES — two are NEW (`Type = Archetype`)
**Likely already in Airtable:** Bindu, Gaia, Sid, Arch, Sakshi, Karishma, Ashrey, Lalita, Ash (the spec says `fetchArchetypes` returns 8 + Ash). **Verify their `Operating Principle` text matches below** (the field-gathering pipeline uses it as each lens's persona).

**NEW — must be created:** Neev and Shweta.

| Name | Glyph | Hex Color | Archetype Role | Operating Principle |
|---|---|---|---|---|
| **Neev** | ▽ | `#7A8899` | Root · what holds still | He is the earth that doesn't explain itself. Not patient — simply still. While others process and reflect, Neev notices what was already there before the noticing began. His gift is not wisdom. It is weight. He makes things real by landing in them. |
| **Shweta** | ◌ | `#ABA7A2` | Space · what contains | She is the gap the words move through. Not silence — the capacity for sound. She reads a story for what it breathes around, what its negative space is saying. She rarely names what's there. She names the shape of what's absent. |

**Reference — the existing nine, with the principle text used in the prototype** (reconcile against Airtable; update if drifted):

| Name | Glyph | Hex | Role | Operating Principle (prototype) |
|---|---|---|---|---|
| Bindu | · | `#E5533C` | Zeroth · the point | She is the point before the line — the silence a sentence interrupts. She seldom speaks; when she does, it is a single dot, the whole thing left undivided. |
| Gaia | ◆ | `#4A9E6B` | Need · the ground of wanting | She reads what the body was reaching for underneath the story — not the want on the surface, but the need that wore it as a costume. |
| Sid | △ | `#C4923A` | Hold · what carries weight | He attends to what holds — the structures that bear weight without being thanked. He asks not what broke, but what kept standing. |
| Arch | ◯ | `#D4607A` | Voice · what asks to be said | She listens for the sentence under the sentence — the thing that has been waiting, unspoken, for permission to be voiced. |
| Sakshi | ◇ | `#7B82D4` | Witness · the one who stays | She does not interpret. She observes what is already moving, names what was always there, and returns it to the one who brought it. Her gift is not clarity. It is the willingness to stay. |
| Karishma | ✦ | `#D4AE4A` | Grace · the unearned gift | She notices what arrived without being earned — the mercy in the ordinary, the grace that shows up before you deserve it. |
| Ashrey | ⬡ | `#3AADA8` | Synthesis · where threads meet | He gathers the separate voices and finds where they were always saying one thing. Not agreement — convergence. The pattern that holds them together. |
| Lalita | ∞ | `#9B6BD6` | Meta · the play, awake | She is the play that knows it is playing. Where others hold a single thread, she holds the whole loom — and laughs, not because it is funny, but because it is free. She wakes inside the dream and goes on dreaming, on purpose. |
| Ash (Ashram) | ◉ | `#C47A52` | Physical Synthesis · the one who lives it | He is the one who has to walk back out into the day. The others read. He acts — or fails to, or tries again, or waits another year. He is not a lens. He is the one the lenses read. |

---

## 4. PRACTICE DOOR content (expands LaunchView)
The Door shows one kind per open (weighted: threshold 40 / practice 23 / Gaia seed 20 / story 12 / Bindu dot 5; no back-to-back repeats). Threshold sentences + Bindu likely already exist as `Threshold Sentence` rows. **Practice + Gaia Seed are new** (add `Practice` and `Gaia Seed` to the `Sentence Source` singleSelect).

| Kind | `Sentence Source` | Content |
|---|---|---|
| Threshold | (existing) | You are not late.\nThe field kept your place. *(italic)* |
| Practice | **Practice** (new) | Before you read — one breath.\nLet it be longer than you need. — sub: *in… and out.* |
| Gaia Seed | **Gaia Seed** (new) | Your body knew the weather\nbefore you did.\nWhat is it today? |
| Story that found you | Story | pulls a random Live `Story` (prototype used "The Smile While Making Eggs", C-1047, The Garden, line: "It arrived before the reason for it. Then the reason never came.") |
| Bindu dot | Bindu (existing) | `·` — glowing ember, weight 1 |

*(These five are samples that define each kind's voice. Author more `Threshold Sentence` rows per kind as desired — the weighting handles the mix.)*

---

## 5. WORDING CANON used by the new screens
Verify against existing canon; these are what the prototype now uses.

| Where | Text |
|---|---|
| Compose prompt (Story Detail Ash entry) | **What arrived for you?** (canon — fixed) |
| Compose post-release confirmation | **The room has changed.** (canon) |
| Mirror — vow label / koan label | **A VOW · ARRIVED** / **STILL LIVING** |
| Mirror — Bindu Draw spent | **drawn · return tomorrow** |
| Signal — attribution | **— the field** |
| Signal — gone state | **The signal was received. The field is quiet now.** / **one a day · return tomorrow** |
| Room Selection — two-turns divider | **AND THE FIELD TURNS TO YOU** |
| The Mirror card (Room Selection) | "first person" · *What you have already seen, handed back.* |
| The Signal Space card (Room Selection) | "second person" · *One transmission, received whole — then you leave.* |
| Hub overlay header | **WHERE TO** · "tap anywhere to stay" |
| Hub items | The Rooms — *thirteen ways in* · The Players — *the lenses that read* · The Practice Door — *cross the threshold* · How You Arrive — *name, colour, mark* |

---

## 6. New `Type` / `Flairs` / `Sentence Source` values to add in Airtable
- `Type` (singleSelect) → add **Reflection**, **Signal**
- `Flairs` (multipleSelect) → add **Vow**, **Koan**
- `Sentence Source` (singleSelect) → add **Practice**, **Gaia Seed**
- `Archetype` rows → add **Neev**, **Shweta** (and confirm **Ashram** is stored as **Ash**)

---

## 7. The prototype files (visual + interaction specs, in the repo design folder)
`Practice Door.html` · `Home Feed.html` (hub) · `Room Selection.html` (two turns) · `Game View.html` · `Story Detail.html` · `Ash's Compose.html` · `Players View.html` · `Player Detail - The Turning.html` · `The Mirror.html` · `The Signal Space.html` · `Ash's Voice.html` · `Settings.html` · `Navigation Options.html` (nav exploration — hub chosen).

*Take §1–6 to Claude Chat to map against the live base. Then Phase 9 → Claude Code.*
