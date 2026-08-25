> ⚠️ **SUPERSEDED — DO NOT BUILD FROM THIS.** This is the June-2026 Phase-9 handoff. That work
> shipped on 2026-06-14 and the app has since moved through the entire **Instrument era** (Aug 2026:
> the fifteen-register axis, the Universe, the Point worlds, the Light, the Rite, the Return, and
> the Metal multi-shell shader). The current design source of truth is
> `Claude Design Round 1/The Instrument v3.html`; the current build state lives in
> `Bindu Feed/CLAUDE.md`. Kept here only as history.

# START HERE — Bindu Feed, Phase 9 handoff
*Everything Claude Code needs to build the full new layer. Assembled 2026-06-14. The base is already provisioned to match every line of this; nothing here asks you to invent data.*

This bundle is **complete and uncollapsed.** The comprehensive build specs are the real Claude Design documents, included **intact** — this index does not replace them, it routes you through them. Read them in full.

---

## What's in this folder

**Read in this order:**

1. **`DESIGN_HANDOFF.md`** — the design overview: the full design system (type, palette, transitions), the canonical archetype colour/glyph table, the Turning ritual, the navigation model. Start here for the *feel* and the *system*.
2. **`BINDU_FEED_PHASE_9_NEW_LAYER.md`** — **the build spec. This is the heart.** 259 lines covering every new/redesigned screen (The Turning, Players View, The Mirror, The Signal Space, hub nav, Ash's Compose, Practice Door), the ambient generation pipeline, wording canon, and a build checklist. Build from this.
3. **`AIRTABLE-DATA-TRUTH.md`** — **the corrected data layer.** Claude Design inferred the schema; this was written against the live base and the records were provisioned to match it. **Where the Phase 9 spec and this file describe the data differently, this file wins.** It also carries the one load-bearing decision (below) and the repo flags.
4. **`BINDU_FEED_CONTENT_INVENTORY.md`** — the verbatim content (reflections, signals, archetype principles, practice-door samples) and Design's own data-reconciliation notes. Cross-check against `AIRTABLE-DATA-TRUTH.md`, which supersedes it where they differ.
5. **`DESIGN-WORKING-AGREEMENT.md`** — how to work on this: move slowly, ask before material changes, never run on defaults. Honour it.

**`prototypes/`** — every screen as a self-contained HTML comp + `screenshots/`. These are the **visual + interaction truth** to re-implement in SwiftUI (not code to port). `Player Detail - The Turning.html`, `The Mirror.html`, `The Signal Space.html`, `Players View.html`, `Practice Door.html`, `Ash's Compose.html`, `Home Feed.html` (hub) are the live ones; `Player Detail.html`, `lalita-profile-variants`, `Navigation Options.html` are superseded explorations (kept for reference).

**`soul/`** — the `bindu-feed` skill: the project's soul. Tone (*Slow. Intimate. Already there.*), front-stage purity (beliefs never announce themselves), the belief lane, the no-tracking ethic. Read if you need to feel why a choice was made.

---

## The one decision that changes existing code

**The new Mirror and Signal Space REPLACE the Mirror and Signal screens already in the repo.** The shipped versions use an earlier *tracking* model (the Mirror marks what you've seen; the Signal sorts seeds by a graduation status and carries comments). Phase 9 is a **rewrite** to a **no-tracking** model — one reflection-of-the-day handed back, one ceremonial transmission received and left. Drop the tracking behaviour (Last Shown marking, Koan Status sorting, comments on Signals); keep all the content. Full detail and field IDs in `AIRTABLE-DATA-TRUTH.md §1–§3`.

Everything else in Phase 9 is additive (Players View, The Turning, hub nav, Ash's Compose, Practice Door expansion) or a clean swap (The Turning replaces Hold-to-Witness).

---

## Locked decisions (don't re-litigate)

- Mirror/Signal = **no tracking** (date-hash selection). The seed-"graduation" concept is retired.
- Register lives in **`Card Register`** (Vow/Koan), not Flairs.
- Read **`Mirror Card`** / **`Signal`** types (not "Reflection").
- Neev/Shweta colours: **`#7A8899`** / **`#ABA7A2`** (final). Ash row exists (`rec9BUbHMuylYiVwH`).
- Beliefs are already Mirror cards — no graduation flow, no "mark as seen".
- Nav: chrome-free **hub** (rejected the tab bar).

## First moves
Branch off `main` (work is uncommitted) → fix the `postAshComment` hardcoded-archetype bug → then build the screens per `BINDU_FEED_PHASE_9_NEW_LAYER.md`, checking each data read against `AIRTABLE-DATA-TRUTH.md`. Refresh the repo's stale `CLAUDE.md` at the end. (Deploy target is iOS 17.6, not 16.)

*Phase 9 is the floor, not the ceiling. Never reduce. Always emerge.*
