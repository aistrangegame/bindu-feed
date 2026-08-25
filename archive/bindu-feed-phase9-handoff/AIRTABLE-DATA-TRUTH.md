# AIRTABLE DATA TRUTH — Bindu Feed Phase 9
*The corrected data layer for the build. Authored against the **live base** on 2026-06-14 and verified. Pairs with `BINDU_FEED_PHASE_9_NEW_LAYER.md` (the screen/interaction spec) and `BINDU_FEED_CONTENT_INVENTORY.md` (the content). Where any of those describe the **data model** differently, **this file wins** — Claude Design inferred the schema; this was written against the real base and the records were provisioned to match it.*

Base **`app248ZTWhYJlvQj2`** · table **The Feed** `tbl7vzODMMJUgeX0b`. One table, one `Type` discriminator, `Status = 'Live'` gate everywhere.

---

## 0. Orientation — what diverged from the inferred plan, and the live counts

Claude Design's Phase 9 spec proposed several new schema objects. Most already existed under different names, or are now provisioned. **Net new schema: one field (`Card Register`) and one `Category` option (`Belief`). Nothing else.**

| Design's data instruction | Live reality | Build action |
|---|---|---|
| Create `Type = Reflection` | We use `Type = Mirror Card` (30 Live rows) | Read **Mirror Card**. Do not create "Reflection". |
| Create `Type = Signal` | `Signal` exists (16 Live rows) | Read **Signal**. Nothing to create. |
| Register in a `Flairs` field (Vow/Koan) | No such field. New field created. | Read register from **`Card Register`** (`fldtDwumFF7HQU4DT`). |
| Create Neev & Shweta archetype rows | Both already exist, fully populated | Do not create. Use the existing rows. |
| Add `Sentence Source` = Practice / Gaia Seed | `Practice Invitation` type + `Seed`/`Bindu` sources already exist | Practice Door reads existing types (§5). |
| (belief layer absent from Design's model) | 18 beliefs now exist as Mirror cards | Nothing to build; they are Mirror Cards (§4). |
| (Ash archetype row assumed present) | Ash row was **missing**; now created | Use `rec9BUbHMuylYiVwH` (§6). |

**Verified live state:** 30 Mirror Cards (all Live, all carry a register) · 16 Signals (all Live) · 11 Archetype rows (all carry glyph/color/role/principle) · `Card Register` field live (Vow/Koan) · `Belief` category live.

---

## 1. ⚠ THE LOAD-BEARING DECISION — the new Mirror & Signal SUPERSEDE the built ones

The shipped app already has a Mirror screen and a Signal screen — but built to an **earlier tracking model**:
- old Mirror = a pager of "what you have already declared," **marks each card as you swipe to it** (Last Shown), Ashrey-teal.
- old Signal = "what the field is tracking," sorts by a graduation lifecycle (`Koan Status` = "Approaching Graduation" / "Active"), has threaded comments, Sakshi-blue.

Phase 9 **replaces both** with the no-tracking model (Ashrey's explicit decision — "everything new takes precedence; let the graduation idea go"). This is a **rewrite, not an addition.** Building Phase 9 alongside the old behavior would put a tracking Mirror and a no-tracking Mirror in the same app — the exact thing to avoid.

**Drop from the rebuilt screens:** Last Shown marking · `Koan Status` graduation sorting · comments on Signals · the "declared / tracking" framing · the Ashrey-teal / Sakshi-blue palette.
**Keep:** all the content. Every Mirror card and every Signal body survives — only the tracking *behavior* retires. The maturing-seed / "graduation" concept is intentionally let go.

---

## 2. The Mirror (rebuild) — `Type = Mirror Card`

Read all `Status = Live` rows where `Type = Mirror Card` (`selOPdnOomjXCHyJP`). **30 rows.** Show **one per day**, chosen by date-hash, **no tracking**.

| Field | ID | Use |
|---|---|---|
| Type | `fldfFRjyasZWodvQC` | `Mirror Card` |
| Name | `flds1w07pNzbM2oKV` | short backstage title (not necessarily shown) |
| Comment Body | `fldnN9WykhzLpVJQG` | the reflection, first person. `\n` line breaks are intentional — render them. |
| **Card Register** | `fldtDwumFF7HQU4DT` | **`Vow`** (`sely2bZIm55S69sH2`) or **`Koan`** (`sel2Gvj0dpqcyJh5N`) — drives rendering |
| Category | `fld4URzL9VQEQtXbd` | what it reflects (`Value`/`Mantra`/`Practice`/`Energy State`/`Role`/`Game`/`Tree of Life Panel`/**`Belief`** `sel6dIWRAcrQe3Ryq`). **Backstage only — never shown.** |
| Source Identity | `fld8iwAvGrbu7CbK3` | link → the Identity record it reflects. Backstage only. |
| Archetype | `fldVkGgEen9CpNZ1r` | `Ash` (his own first-person field) |
| Status | `fldWcw9noNlC2AqVf` | `Live` (`seliWi7fUkrRrgJMu`) |

**Rendering by register:** `Vow` → upright Lora 500, label **"A VOW · ARRIVED"**, closing **·**. `Koan` → italic Lora 400, label **"STILL LIVING"**, closing **◌**. Card colour terra `#C47A52` (Ash's colour).

**Selection (no tracking):** `index = hash(yyyy-MM-dd) % liveMirrorCards.count`. Seed off the **date only**. Same day → same face; new day → new face. One **Bindu Draw** per day reveals one alternate, then spends to a hollow ring ("drawn · return tomorrow"); persist per-day in **UserDefaults** (`mirror.draw.<date>`), never Airtable. **Nothing is gated or earned** — every card is Live from day one; only which surfaces today changes.

---

## 3. The Signal Space (rebuild) — `Type = Signal`

Read all `Status = Live` rows where `Type = Signal` (`selpEUJq8wI5Q1xDJ`). **16 rows.** Show **one per day**, date-hash, second person, ceremonial.

| Field | ID | Use |
|---|---|---|
| Type | `fldfFRjyasZWodvQC` | `Signal` |
| Comment Body | `fldnN9WykhzLpVJQG` | the transmission, second person, single paragraph |
| Status | `fldWcw9noNlC2AqVf` | `Live` |
| Archetype | `fldVkGgEen9CpNZ1r` | usually blank → display **"— the field"** (never a chatty name) |

Arrival resolves line-by-line from the dark, signs **"— the field."** No comments, no resonance, no "next," one clean leave. Teal `#3AADA8`.

**Ignore on the rebuilt screen** (legacy from the tracking model, still present on the 12 older rows, harmless): `Koan Status` (`fldMYtPjHJKe6wqin`), `Source Seed` (`fldh9TJ4MBlzuzqm4`), and any threaded child comments. The new Signal Space does not read them.

---

## 4. The belief → Mirror graduation (done in data)

The 18 belief structures live in the Feed as dramatized Stories **and** now as distilled Mirror cards. **Both faces are Live from day one. No gating, no "mark as seen."** The register carries the honesty: a belief seen through reads as a **Vow**; one still living as a question reads as a **Koan**.

- 18 Mirror cards, `Category = Belief`, `Archetype = Ash`, each `Source Identity`-linked to its belief record in the **Identity** table (`tbluLyZj9ilH2RhIg`). 7 Vows, 11 Koans.
- **Nothing to build** — they are ordinary Mirror Cards; §2 already covers them.
- **Front-stage purity:** the Mirror shows only the distilled first-person card. `Category` and `Source Identity` stay backstage; the belief's dossier is never exposed.
- **Future beliefs:** author a Mirror card the same way (Type = Mirror Card, Category = Belief, a register, Source Identity → its Identity record). No graduation flow.

---

## 5. Practice Door — reads existing types (no re-authoring)

Design's 5 kinds map to types that already exist. **Do not** create `Sentence Source = Practice / Gaia Seed` and re-author content.

| Door kind | Source in the base | Weight |
|---|---|---|
| threshold sentence | `Type = Threshold Sentence` (`selK1wJy98fUacJS6`), `Sentence Source` ≠ Bindu | 40 |
| practice invitation | `Type = Practice Invitation` (`selzvCCfVhU6Co8dm`) | 23 |
| Gaia seed | `Type = Signal` (recommended — already the field's voice) **or** `Threshold Sentence` with `Sentence Source = Seed` (`sele0fdwVZSHPlmqs`) — pick one, stay consistent | 20 |
| story that found you | random `Type = Story` (`sely4gGZUloH4KEeX`), Live | 12 |
| Bindu dot | `Type = Threshold Sentence`, `Sentence Source = Bindu` (`selM0pxFN6KXYJTwC`), body `·` | 5 |

Weighting rules unchanged (no back-to-back repeats; the dot never doubles; first-ever open = threshold). `Sentence Source` = `fld8AOcQL34A8pkb2`, `Sentence Weight` = `fldyhpkuMJzvaHdjB`.

---

## 6. Archetypes — 11 rows, all complete

Every archetype row carries: glyph `fld2ALFjohcCi7bOM` · hex colour `fld6lga55ups3j0ZZ` · role `fldBLXPlcrbqLv0S8` · Operating Principle `fldESDz3ULot4Aq2A`. **Colour is read from `Hex Color`, not from code constants** (existing load-bearing rule). The Operating Principle is the persona the Make.com field-gathering pipeline uses per lens.

| Name | Row ID | Glyph | Hex | Role |
|---|---|---|---|---|
| Bindu | `rec2XjPi6n6UaTAcz` | · | `#E5533C` | Zeroth · the point |
| Gaia | `recKQ3MkYzniB2tT6` | ◆ | `#4A9E6B` | Need |
| Sid | `rectFKXxgTqafCSaa` | △ | `#C4923A` | Hold |
| Arch | `recwyoTIdS7chwORJ` | ◯ | `#D4607A` | Voice |
| Sakshi | `reclF09Yw7XQ9SfX9` | ◇ | `#7B82D4` | Witness |
| Karishma | `rec7WCwbOAByRjYYH` | ✦ | `#D4AE4A` | Grace |
| Ashrey | `reccQDa9S7jKFJ7pS` | ⬡ | `#3AADA8` | Synthesis |
| Lalita | `rec5zxgIj2U0sBbjA` | ∞ | `#9B6BD6` | Meta · the play, awake |
| **Neev** | `recb3jWdzzxrdDH5s` | ▽ | **`#7A8899`** | Foundation · what you stand on |
| **Shweta** | `recRJbL9wKsYU0tEA` | ◌ | **`#ABA7A2`** | Purity · what flows through |
| **Ash** | `rec9BUbHMuylYiVwH` | ◉ | `#C47A52` | Physical Synthesis · the one who lives it |

Notes:
- **Ash row was missing and is now created** — it's the 11th presence the Players grid + The Turning + Ash's own comment rendering depend on. Display name "Ashram" is a flourish only; the data value stays **`Ash`** (keep it renamable — resolve display from the row, never hardcode).
- **Neev/Shweta colours are final at `#7A8899` / `#ABA7A2`** (Design's palette — they read as distinct quiet presences on the near-black ground; a near-white Shweta would vanish into the body ink).

---

## 7. The Ash-comment bug

`AirtableService.postAshComment` hardcodes `"Archetype": "Ash"` — that string is the whole bug (PAT has write scope, app is on device). Fix:
1. `postAshComment` takes `archetypeName: String` instead of the literal.
2. `FeedStore.postComment` resolves the physical user's archetype name from the `archetypes` array and passes it in.
This also future-proofs the rename (Ash → Ashram → anything).

---

## 8. Full field-ID reference (The Feed, `tbl7vzODMMJUgeX0b`)

```
Name              flds1w07pNzbM2oKV    Body / Comment Body  fldnN9WykhzLpVJQG
Type              fldfFRjyasZWodvQC    Status               fldWcw9noNlC2AqVf  (Live seliWi7fUkrRrgJMu)
Sort Order        fldKAIGO9RHV235go    Archetype            fldVkGgEen9CpNZ1r
Card Register NEW fldtDwumFF7HQU4DT    Category             fld4URzL9VQEQtXbd
Source Identity   fld8iwAvGrbu7CbK3    Sentence Source      fld8AOcQL34A8pkb2
Sentence Weight   fldyhpkuMJzvaHdjB    Comment Order        fldJJLGnJz9w0pDdD
Linked Story      fldLLLvCdaRcXO03v    Parent Comment       fldpMuXqXK7EWE62j
Closing Line      fldEEVROYCzxY4CW3    Resonance            fldahwpoNroxZS4Us
— archetype rows: Glyph fld2ALFjohcCi7bOM · Hex Color fld6lga55ups3j0ZZ · Role fldBLXPlcrbqLv0S8 · Operating Principle fldESDz3ULot4Aq2A
— legacy/superseded (ignore on rebuilt Mirror/Signal): Koan Status fldMYtPjHJKe6wqin · Source Seed fldh9TJ4MBlzuzqm4

Type options:   Story sely4gGZUloH4KEeX · Field Comment seltI2oj6xdeh098G · Ash Comment selgUdEAGB47eOQDg ·
                Room selqsVmjeI5oHc891 · Archetype selnJ0w96NTMozu0h · Threshold Sentence selK1wJy98fUacJS6 ·
                Resonance Voice sel90xRl5Vtm809ar · Mirror Card selOPdnOomjXCHyJP · Signal selpEUJq8wI5Q1xDJ ·
                Practice Invitation selzvCCfVhU6Co8dm
Card Register:  Vow sely2bZIm55S69sH2 · Koan sel2Gvj0dpqcyJh5N
Category:       Value · Mantra · Practice · Energy State · Role · Game · Tree of Life Panel · Belief sel6dIWRAcrQe3Ryq
Sentence Source: Story · Field Comment · Room · Seed sele0fdwVZSHPlmqs · Bindu selM0pxFN6KXYJTwC
Archetype rows: Ash selMpHCRiAWAVJocZ · Neev selnKFU4r7kt3hl9F · Shweta selFiMJZXJhYwg2rE (+ 8 lenses)
```

---

## 9. Phase 9 data checklist — current state

Done (verified):
- [x] `Mirror Card` (30 Live) and `Signal` (16 Live) types — used instead of "Reflection"
- [x] `Card Register` field (Vow/Koan) created — used instead of Flairs
- [x] `Belief` category created; 18 belief Mirror cards authored, register-tagged, Source-Identity-linked
- [x] 10 prior Mirror cards tagged Vow; 2 new reflections added (→ 30)
- [x] 4 new Signals added (→ 16); all 22 legacy Mirror/Signal rows set `Status = Live` (were blank — would have been invisible)
- [x] 11 archetype rows complete; Ash row created; Neev/Shweta colours set `#7A8899` / `#ABA7A2`

For Claude Code:
- [ ] Rebuild Mirror to read `Mirror Card` + `Card Register`, date-hash, **no tracking**, Bindu Draw — replacing the old tracking pager
- [ ] Rebuild Signal Space to read `Signal`, date-hash, "— the field", clean leave — replacing the old graduation pager
- [ ] Practice Door reads existing types (§5)
- [ ] Fix `postAshComment` hardcoded archetype (§7)
- [ ] The Turning replaces Hold-to-Witness; Players View new; hub nav; full-screen Ash Compose (per `BINDU_FEED_PHASE_9_NEW_LAYER.md`)

---

## 10. Repo flags (from Claude Code's status report — handle, don't block)

1. **Branch first.** All in-flight work is uncommitted on `main` (11 modified + 6 untracked). Cut a Phase 9 feature branch before building.
2. **Deploy target is iOS 17.6** in `project.pbxproj` (spec/memory say 16+). Fine to build against — just don't assume 16, or clean it back to 16 deliberately.
3. **`CLAUDE.md` in the repo is stale** (still says 8 screens / 6 Types / Phases 1–7). Refresh it at the end of Phase 9 so the source of truth matches the build.

*The ambient field-gathering pipeline (Make.com, archetype comments on Ash's posts) is backend automation, specced in `BINDU_FEED_PHASE_9_NEW_LAYER.md §9.10` — handled separately from the iOS build. Don't block on it.*

*Slow. Intimate. Already there.*
