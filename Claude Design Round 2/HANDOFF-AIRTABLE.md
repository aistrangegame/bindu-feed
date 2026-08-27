> # ⛔ SUPERSEDED — DO NOT EXECUTE THIS FILE
>
> **All work in this file was completed on 27 Aug 2026 and verified by live read-back.**
> See `00-PASS-0-DONE-AND-CODE-CONTRACT.md` for what the base actually looks like now.
>
> **Two instructions below would have caused damage and were NOT followed as written:**
>
> 1. **§A says retire rows by `Category`.** Three of the design's own ten canon reflections
>    (`Trust`, `YES Witness`, `YES Honor What Was Before Dissolving`) carry `Category = Value/Mantra`.
>    A Category-based retire **deletes canon**. Retirement was done by **Sort band**, and those three
>    were kept and repaired.
> 2. **§A's Category filter does not select the Signal cohort at all** — all twelve carry no `Category`.
>    The worst-affected pool would have been left untouched.
>
> Also corrected: "make `Card Register` required" is **not possible in Airtable** (no required-field
> constraint on base tables) — it is a Swift change, listed in the code contract. And §B says store
> `days`; a stored integer is stale the next morning — **`Sealed At` stores the date and `days` is
> computed at read time.**
>
> Kept below only as a record of what was intended. **The data track is closed.**

---

# HANDOFF · AIRTABLE — the parallel track

**None of this is code. All of it gates code. It can start immediately, in parallel, by someone else.**

Base `app248ZTWhYJlvQj2` · Feed table `tbl7vzODMMJUgeX0b`. Evidence read live 2026-08-25 (`AUDIT.md` §A).

---

## A · Retire the foreign cohort — do first

The design authored a small, curated, hand-broken pool per surface. The live base carries those records as a **second cohort layered on top of a pre-existing ontology** — the ASG *Value / Mantra / Practice / Energy State / Role / Game / Tree of Life Panel / Belief* system — which was never retired. **The app reads the union.** One provisioning decision, showing up on five surfaces at once.

- [ ] **Retire ~26 rows** carrying `Category` = Value · Mantra · Practice · Game · Tree of Life Panel · Codex across the Mirror, Signal and Practice pools. **Ashrey's ruling: retire, not re-Type.** They are a different ontology surfacing as reflection-of-the-day roughly **one day in three** — e.g. *"I sit before the Yantra. The dot becomes the doorway."* (a practice instruction) and *"Every other game is played inside this one."* (a game rule).
- [ ] **Restore the authored `\n` line breaks** on the four flattened reflections — `Trust`, `YES Witness`, `YES Honor What Was Before Dissolving`, and the Practice/Game/ToL rows. Source `The Mirror.html:62-73`, rendered under `whiteSpace: 'pre-line'`. Canon example, verified: `'Trust is the variable.\nNot effort. Not control.\nTrust.'` — three lines. Base rec `recn5ECOiniQzlrFt` currently holds it as one. **The break is the form on this surface**, and `ReflectionCard` will honour `\n` but cannot invent it.
- [ ] **Restore canon wording** on rec `recw4bU300qQ8KWh4` ("The Roof Beam"). Canon is *"What would I do / if I trusted the ground / to hold?"* — three lines. Stored is a two-line paraphrase with a different verb. Canon wording is non-paraphrasable.
- [ ] **Re-balance the register** to the design's deliberate **5 vow / 5 koan**. Currently ≈19/12 because cohort A was back-filled uniformly as `Vow` — including the practice, the game and the ToL panel, three rows that are not vows. The two registers are the surface's whole typographic fork (upright Lora 500 + `·` vs italic Lora 400 + `◌`).
- [ ] **Author the 2 missing Signals.** Outstanding since `REVIEW-AND-WIRING.md:86-89`. Ashrey's ruling: *I author them in the voice of the existing set, for approval* — so this one comes back to Claude Design or Chat, not to the base directly.
- [ ] **Make `Card Register` required.** A blank silently renders a koan **upright, weight-500, labelled "A VOW · ARRIVED", closing `·`** — a koan presented as an arrived vow. This is the blank-`Status` lesson repeating on a new field, and it fails *loud-looking but wrong* rather than blank.
- [ ] **Fix the draw's ordering.** Three compounding problems: (a) the modulus is the **live record count**, so authoring one new card re-maps every past and future day; (b) `writeVow` writes with **no `Sort Order`**, so every carved Declaration sorts to the front and shifts every index; (c) the Bindu Draw persists an **integer index, not a record id**, so the drawn card can silently become a different card. Persist a record id; give `writeVow` a `Sort Order`.

---

## B · The write-back schema — this is what fills register 2

Ashrey's description of the mechanism: a comment left in the Rite or the Return goes back, and in that session voices may answer — so **a story can carry more than one comment from the same archetype.**

That is not duplication. It is a conversation across time, and it is exactly what register 2's depth-1 cluster displays.

> **A voice's second comment on a story is not a repeat. It answers what you left there.**

It also explains the finding rather than patching it: **no voice has returned to a story twice because the loop has never run.** Nothing is missing from the record — the record is exactly one pass old.

- [ ] **A `Returns` record per return:** `{ story, when, days, words, ringIndex }`.
  **`days` matters** — age is computed from days and never from rank (bug class 3 · `E3.4`). `The Return.html` computes `rel = age(ring.days).a / age(story.days).a`.
- [ ] **An answer shape bound to the ring it replies to:** `{ voice, ringId, story, lines[] }`.
  The binding is what makes a second comment meaningful rather than a repeat — and what lets a room state *"one on the story, two answering returns."*
- [ ] **`lines[]`, never prose.** Same unit as everywhere else: an ordered array of display lines, or prose with authored `\n`. Never re-split.
- [ ] **Met-ness from the specified source.** `App Activity 'Story Met'`, which already carries `Link to Feed`. The code uses `commentCount > 0 || resonance > 0`, which lights almost every star. Tier 0 #3 — low effort, high meaning.
- [ ] **Decide the Point's home.** Authored-and-frozen (my recommendation) or read from the base. Tier 0 #5 — the 66 stars currently live in three places with no reconciliation path.

---

## C · Rulings to bring back — blocking

Full detail in `HANDOFF-RULINGS.md`. Short list:

| Ruling | Blocks |
|---|---|
| **Ashram or Ash** — name, hex, glyph, role, Hz | The eleven rooms; the default arrival identity (Tier 0 #8) |
| **Neev's words** — approve, replace, or leave honestly empty | His room ships with authored content otherwise |
| **The breath curve** — Tier 0 #9 | Shader-wide; every `uBr` term was authored against the other curve |
| **The Aperture's 37 origins** | Factual claims about living traditions, authored to fill a slot |
| **The 37 adjacency claims** | Needs the full 66-star list to complete |
| **The Audio Anchor** — should a kept voice survive a device? | Tier 0 #11 |

---

## D · What to write back into the design files

Two text updates, so the next session does not rediscover a resolved conflict as an open one:

- [ ] **`The Return v2.html:359-360`** and **`walk-continuity.js:22`** both state *"It writes nothing back — a ceremony is not a place that keeps score."* Amend both to distinguish **a return** from **a score**: return-depth appears only as strata, patina and cluster thickness. *Nothing counts; everything deepens.* Note that `walk-continuity.js:44-46` already permits this — *"never rendered as a count — a ceremony may colour itself by it, nothing more."*
- [ ] **`The Reading.html`** originally claimed Worlds V and VI have no bespoke module. **Corrected in-file** — `world-five.js` and `world-six.js` are fully authored. Kept here as a record of the correction.
