# A Strange Feed — Design Handoff
*Picking up from the previous chat. June 14, 2026.*

---

## ⟶ FOR THE BUILD (read this first)

The real app is **`bindu-feed`** (SwiftUI + Airtable), already built through Phase 7. Its source of truth is **`BINDU_FEED_CLAUDE_CODE.md`** + **`Bindu Feed/CLAUDE.md`** in that repo — schema, phases, tokens, wording canon.

Everything *this* design project added (Mirror, Signal Space, Players View, The Turning, hub nav, full-screen Compose, Practice Door) is **net-new and not yet in the app**. It is specced for Claude Code in **`BINDU_FEED_PHASE_9_NEW_LAYER.md`** (this project) — drop it into the repo's master doc and build it as Phase 9.

**Decisions made (overridable):**
1. **Airtable:** Mirror = new `Type` "Reflection" (register in `Flairs` Vow/Koan); Signal Space = new `Type` "Signal". Add Neev & Shweta as Archetype rows.
2. **Wording:** respect canon — Compose confirmation "The room has changed."; prompt fixed "What arrived for you?".
3. **Field-gathering:** ambient via Make.com; route 2–3 lenses per post using each archetype's `Operating Principle` as its persona; generate-once-persist.

---

## What exists in this project (all locked)

| File | Status | Notes |
|---|---|---|
| **Home Feed.html** | ✅ Locked | Story cards (→ Story Detail), game filter, live pulse. **Hub nav** (top-left) + Ash mark → Voice. Self-contained shell. |
| **Story Detail.html** | ✅ Locked | Full story body, sequential field gathering, Ash compose point |
| **Room Selection.html** | ✅ Locked | 13 living portals + the two turns of the field (Mirror & Signal Space) below a divider; back → Home Feed |
| **Game View.html** | ✅ Locked | Per-room feed, all 13 rooms, arrow nav, room hero with gradient |
| **Archetype Profile.html** | ✅ Locked (superseded) | Old Sakshi hold-to-witness screen — kept as reference, replaced by The Turning |
| **Ash's Voice.html** | ✅ Locked | Ash's comment history, terra palette, thread replies |
| **Settings.html** | ✅ Locked | HOW YOU ARRIVE, live avatar preview, mood selector |
| **Players View.html** | ✅ Locked | 8 lenses + 2 substrates + Ashram. All card → Turning wired |
| **Player Detail — The Turning.html** | ✅ Locked | The canonical Player Detail screen — all 11 presences routed via #hash |
| **Practice Door.html** | ✅ Locked | 5 kinds rotating, tap-to-cross, pre-dawn atmospheric, door↔feed loop |
| **The Mirror.html** | ✅ Locked | 14th portal · 1st person. Held reflection-of-the-day in terra, seeded by date (no tracking). Vow/koan registers. One Bindu Draw per day. State persists; date line passes a day (prototype). |
| **The Signal Space.html** | ✅ Locked | 15th portal · 2nd person. Ceremonial single transmission from the field — arrives, resolves line-by-line, "— the field", one clean leave. One a day. |

---

## Design system

**Type:** Lora (body, italic, 400/500) + Space Mono (labels, mono, caps)  
**Background:** `#0E0C12` (deep near-black)  
**Card:** `#171420`  
**Hairline borders:** `rgba(255,255,255,0.06)`  
**Ink:** `#EDE8E3` / `--ink60` / `--ink35`  
**Transitions:** dissolve only — no slides, no scale bounces  
**Interaction grammar:** hold-to-witness / trace-to-witness (the Turning ritual)  
**No emoji.** No gradients except atmospheric radial washes.

**Archetype colours (canonical):**
| Name | Role | Color | Glyph |
|---|---|---|---|
| Bindu | Zeroth · the point | `#E5533C` | · |
| Gaia | Need | `#4A9E6B` | ◆ |
| Sid | Hold | `#C4923A` | △ |
| Arch | Voice | `#D4607A` | ◯ |
| Sakshi | Witness | `#7B82D4` | ◇ |
| Karishma | Grace | `#D4AE4A` | ✦ |
| Ashrey | Synthesis | `#3AADA8` | ⬡ |
| Lalita | Meta · the play | `#9B6BD6` | ∞ |
| Neev | Root | `#7A8899` | ▽ |
| Shweta | Space | `#ABA7A2` | ◌ |
| Ashram | Physical Synthesis | `#C47A52` | ◉ |

---

## The Turning ritual (Player Detail)

- **Hash routing:** `Player Detail — The Turning.html#lalita` etc. All 11 IDs work.
- **Mechanic:** trace the ∞ path → dawn light rises → words resolve from dark
- **Glyph animations per presence:**
  - Lalita: `lTurn 30s linear infinite` (the only rotation)
  - Bindu: `glyphEmber 3.2s` (most alive)
  - Sakshi: `glyphBreath 13.5s` (stillest lens)
  - Neev: `glyphBreathSlow 18s`
  - Shweta: `glyphBreathSlow 22s` (nearly imperceptible)
  - Ashram: `glyphPulse 2.8s` (heartbeat)
  - Others: `glyphBreath` at individual rates
- **Ashram only:** "All of Ashram's words in the field →" link to `Ash's Voice.html`
- **Bindu only:** empty-body word card renders as a glowing ember dot, not text

---

## Practice Door

- **5 kinds:** threshold sentence / practice invitation / Gaia seed / story that found you / Bindu dot
- **Crossing:** tap anywhere, you choose when. No countdown, no auto-dissolve.
- **Frequency:** every open (in the real app)
- **Atmosphere:** pre-dawn warm gold (`#C9A07A`) breathing glow — its own light, not the Turning's violet
- **The loop (for prototype):** tap door → field glimpse → tap field → next door kind
- **Weighting logic (NOT yet designed):** in production, mostly threshold sentences, occasionally a story, rarely the dot. Needs a product decision before Claude Code.

---

## What still needs designing (new chat)

### Priority 1 — The new portals ✅ DONE (locked)
**The Mirror (14th portal)** — built. 1st-person reflection-of-the-day, terra, vow/koan registers, one Bindu Draw. `The Mirror.html`
**The Signal Space (15th portal)** — built. 2nd-person single transmission, receive then leave. `The Signal Space.html`
Both wired into Room Selection as "the two turns of the field."

**Open threads on the pair (small, optional):**
- *Glyph echo:* there's a stories-room called *The Signal* (✧) and now *The Signal Space* (⊙) — both teal. Distinct in concept; gut-check whether the echo reads as deliberate or confusing.
- *Tiering call:* Mirror/Signal are presented as a separate tier (horizontal cards under a divider), not two more cells in the uniform grid. Reversible if inline #14/#15 is preferred.

### Priority 2 — End-to-end wiring ✅ DONE
Every screen is now connected into one walkable prototype.

**Global navigation model: chrome-free hub.**
- **Hub (top-left of Home Feed)** — a quiet 2×2 dot mark opens a "WHERE TO" overlay: The Rooms · The Players · The Practice Door · How You Arrive (Settings). Tap anywhere to dismiss.
- **Ash mark (top-right of Home Feed)** → Ash's Voice.
- Decided against the bottom tab bar (explored in `Navigation Options.html`) — the hub keeps the contemplative tone. Tab bar remains the fallback if discoverability becomes a problem.
- Sub-screens use a back chevron → `history.back()` (falls back to Home Feed; The Turning falls back to Players View).
- *Prototype scope:* the hub lives on Home Feed only. In the Claude Code build it can sit on every top-level screen (native nav makes this trivial).

**Wired flows:**
- `Practice Door` → (cross) → `Home Feed`
- `Home Feed` → hub → `Room Selection` / `Players View` / `Practice Door` / `Settings`
- `Home Feed` → story card → `Story Detail`; Ash mark → `Ash's Voice`
- `Room Selection` → room → `Game View`; → `The Mirror` / `The Signal Space`
- `Game View` → story card → `Story Detail`; room counter → `Room Selection`
- `Story Detail` → compose point → `Ash's Compose`
- `Players View` → presence → `The Turning`; (Ashram) → `Ash's Voice`
- All story cards route to the single representative `Story Detail.html` (only C-1052 is authored there).

*Note:* `Home Feed.html` was ported from the IOSDevice frame to the self-contained phone shell (same as the other screens) so the hub overlay can layer cleanly. Content is faithful to the original.

### Priority 3 — Ash's compose experience ✅ DONE (`Ash's Compose.html`)
Full-screen writing ritual replacing the inline text field. The field asks a prompt (rotated by day + story, like the Mirror); you write; you **hold the ember to release** (the compose-side mirror of hold-to-witness, ~2.3s); your words settle as your entry, then *"It is in the field now."*

- **Lit by your Settings arrival colour** — reads `ashSettings` (`{name,color,glyph}`) and relights wash, caret, ring, ember, released entry. Falls back to Terra.
- **No fake field responses.** The lenses reading your entry is a *real-app generation behavior*, deliberately left out of the prototype (staging it the same two responses every post was misleading).
- **OPEN PRODUCT DECISION — how the field gathers (for Claude Code):**
  - *Sync* (you see "the field is reading…", responses stream in seconds) vs *Ambient* (you leave; the field gathers over minutes/hours; you return to find it — recommended, matches the tone) vs *Hybrid* (one immediate, rest ambient).
  - *Which lenses respond* — all, or a routing step that picks the 2–3 whose stance fits the entry (recommended).
  - Generate **once per entry**, persist (idempotent) — so a post's field is fresh & specific, then stable forever.

### Priority 4 — The Practice Door weighting ✅ DONE (in `Practice Door.html`)
Each open picks a weighted-random kind; nothing repeats back-to-back; the dot never doubles.

| Kind | Weight | ~Effective |
|---|---|---|
| threshold sentence | 40 | ~33% |
| practice invitation | 23 | ~25% |
| Gaia seed | 20 | ~22% |
| story that found you | 12 | ~15% |
| Bindu dot | 5 | ~6% (≈1 in 16) |

Tune `DOOR_WEIGHTS` to taste. (Prototype picks weighted on every load; production: first-ever open = threshold, then weighted.)

---

## Known technical bug (for Claude Code)

**Ash commenting doesn't persist to Airtable.** Root cause: `"Archetype": "Ash"` is hardcoded in `AirtableService.postAshComment`. The PAT has write scope, the app is on device — it's purely the hardcoded string. Fix:

1. `AirtableService.postAshComment` takes `archetypeName: String` parameter instead of `"Ash"`
2. `FeedStore.postComment` resolves the physical user's archetype name dynamically from `archetypes` array and passes it in

---

## Files to ignore / archive
- `design-canvas.jsx` — scaffold, not a deliverable
- `lalita-profile-variants.jsx` — exploration file, superseded by The Turning
- `Player Detail.html` — exploration canvas, superseded by The Turning
- `ios-frame.jsx` — still used by Room Selection / Game View / Players View / Settings / Story Detail / Ash's Voice (NOT by Home Feed anymore)
- `Navigation Options.html` — nav exploration (hub vs tab bar); decision made (hub). Keep for reference or archive.

---

*Next chat: read this file first, then open `Home Feed.html` and walk the hub. Everything is wired end-to-end.*
