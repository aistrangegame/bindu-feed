> ⚠️ **SUPERSEDED — DO NOT BUILD FROM THIS.** This Phase-9 build spec was fully implemented on
> 2026-06-14 and has since been superseded by the Instrument era (Aug 2026). Current design source
> of truth: `Claude Design Round 1/The Instrument v3.html`. Current build state: `Bindu Feed/CLAUDE.md`.
> Kept as history only.

# BINDU FEED — PHASE 9: THE NEW LAYER
*Addendum to `BINDU_FEED_CLAUDE_CODE.md`. Authored from the design prototype (the "A Strange Feed" HTML comps, newer set). Phases 1–8 built the base app; Phase 9 adds the new screens, redesigns two shipped ones, and introduces the navigation hub. Same rules apply: **Slow. Intimate. Already there. Never reduce. Always emerge.***

> **Read this whole file before touching code.** Several items here *replace* shipped screens — they are not additive. Where this conflicts with an earlier phase, **Phase 9 wins** (it is later and intentional).

---

## 9.0 — What Phase 9 changes (orientation)

| Item | Status vs. built app | Action |
|---|---|---|
| **The Turning** | **Replaces** `ArchetypeProfileView` | Rebuild the mechanic: trace-the-∞ + dawn light (was: hold-to-witness press+ring) |
| **Players View** | **New screen** | The grid of all presences. App currently reaches a voice only via a comment avatar. |
| **The Mirror** (14th portal) | **New screen + new data** | 1st-person reflection-of-the-day. New `Type` = Reflection. |
| **The Signal Space** (15th portal) | **New screen + new data** | 2nd-person transmission. New `Type` = Signal. |
| **Hub navigation** | **Replaces** Home Feed header (eye + gear) | Dot-hub (top-left) + Ash mark → Voice (top-right). Settings moves into the hub. |
| **Ash's Compose** | **Redesigns** the inline `AshComposer` | Full-screen hold-to-release ritual, launched from Story Detail's Ash entry. |
| **Practice Door** | **Expands** `LaunchView` | 5 threshold kinds, weighted. Crossing → Home Feed. |
| **Neev, Shweta** | **New Archetype rows** | Two roots, needed by Players View + The Turning. |

The prototype that defines all of this visually lives in the repo design folder as: `The Mirror.html`, `The Signal Space.html`, `Player Detail - The Turning.html`, `Players View.html`, `Ash's Compose.html`, `Practice Door.html`, `Home Feed.html` (hub version), `Navigation Options.html` (nav exploration — decision was the hub). Treat these as **visual + interaction specs to re-implement in SwiftUI**, not code to port.

---

## 9.1 — Airtable additions

All additions stay inside the single **The Feed** table (`tbl7vzODMMJUgeX0b`). No new tables. Same `Status='Live'` gate everywhere.

### New `Type` singleSelect values
Extend the `Type` field with two values:
- **`Reflection`** — a Mirror card (Ash's own crystallized first-person words)
- **`Signal`** — a Signal Space transmission (the field, second person)

### Field usage for the new types

**Reflection** rows:
| Field | Use |
|---|---|
| `Comment Body` | the reflection text, first person ("Trust is the variable. Not effort. Not control. Trust.") |
| `Flairs` | register — **`Vow`** (arrived, upright) or **`Koan`** (living question, italic). Exactly one. |
| `Archetype` | `Ash` (it is his own field) |
| `Status` | `Live` |

**Signal** rows:
| Field | Use |
|---|---|
| `Comment Body` | the transmission, second person, single paragraph ("The fear is the doorway…") |
| `Archetype` | `Gaia` (field-attributed) or blank — displayed as "— the field", never a chatty name |
| `Status` | `Live` |

> Add `Vow` and `Koan` to the `Flairs` multipleSelect options. No new *fields* are required — only two `Type` options and two `Flairs` options. This keeps the single-`CodingKeys` rule intact.

### Two new Archetype rows
Add to The Feed as `Type=Archetype, Status=Live`:

| Name | Glyph | Hex Color | Archetype Role | Operating Principle (seed) |
|---|---|---|---|---|
| **Neev** | ▽ | `#7A8899` | Root · what holds still | "He is the earth that doesn't explain itself. Not patient — simply still… He makes things real by landing in them." |
| **Shweta** | ◌ | `#ABA7A2` | Space · what contains | "She is the gap the words move through. Not silence — the capacity for sound… She names the shape of what's absent." |

(Full principle text is in `Player Detail - The Turning.html` → `ARCHES.neev` / `ARCHES.shweta`. Use it verbatim.)

> **"Ashram" = "Ash."** The design prototype calls the Physical-Synthesis presence **Ashram** (◉ terra); the app's data calls it **Ash**. Same entity. Keep `Ash` as the Airtable value; "Ashram" is only a display flourish in the Players grid if desired — but prefer **Ash** for consistency.

### Practice Door kinds (LaunchView expansion data)
The Door shows one of 5 kinds per open (see 9.7). Map to data:
- **threshold sentence** → existing `Type=Threshold Sentence`
- **Bindu dot** → existing (`Sentence Weight`=1, body `·`)
- **story that found you** → a random Live `Story`
- **practice invitation** & **Gaia seed** → add `Practice` and `Gaia Seed` to the `Sentence Source` singleSelect, authored as `Threshold Sentence` rows tagged with that source.

---

## 9.2 — Navigation model: the chrome-free hub

**Replaces** the Home Feed header's eye-icon + settings-gear. **Decided** over a bottom tab bar (explored, rejected — a tab bar breaks "Slow. Intimate."). The "no tab bar" canon still holds.

- **Home Feed header, left:** a quiet **2×2 dot mark** (the hub trigger), beside the wordmark.
- **Home Feed header, right:** the **Ash mark** (◉ terra) → **Ash's Voice**.
- **Hub overlay** (tap the dots): a dim, blurred "WHERE TO" sheet with four calm rows, each a colored dot + Lora name + italic descriptor + ›. Tap a row to go; tap anywhere else to dismiss. Dissolve in/out.
  - **The Rooms** (`#9B6BD6`) → Room Selection
  - **The Players** (`#7B82D4`) → Players View
  - **The Practice Door** (`#C9A07A`) → Practice Door
  - **How You Arrive** (`#ABA7A2`) → Settings
- **Back** everywhere stays the frosted ‹ chevron, top-left (canon unchanged).

**`Navigation.swift` — extend `FeedRoute`:** add `.players`, `.mirror`, `.signal`, `.compose(storyId:)`. The Turning replaces the destination of the existing archetype route. Settings keeps its route (now reached from the hub). Practice Door is the launch surface (see 9.7) and can also be a route from the hub.

*Prototype scope note:* in the HTML the hub lives only on Home Feed. In SwiftUI, the hub trigger can sit on every top-level screen's header for free — recommended, but Home Feed is the required minimum.

---

## 9.3 — The Turning (rebuild of `ArchetypeProfileView`)

The shipped Archetype Profile uses **Hold-to-Witness** (1.5s long-press, progress ring, then comments reveal). **Replace** that mechanic with **The Turning**:

- **Gesture:** the user **traces the ∞ path** (press-and-hold on an infinity glyph). Progress 0→1 over ~2.9s up / ~0.75s decay. Keep it `CADisplayLink`-paced (the existing 60fps loop — do **not** use `withAnimation`).
- **Dawn light:** as progress rises, the whole screen warms — a radial wash in the archetype color rises, and the content's `saturate`/`brightness` lifts from desaturated-dark to full. Words become legible past ~55% and "resolve from the dark."
- **At full trace:** the archetype's words (their Field Comments) are gathered below, each rising in.
- **Per-presence glyph animations** (already specced in `GlyphAnimation`): Lalita `lTurn` (only rotation), Bindu `glyphEmber` (most alive), Sakshi `glyphBreath 13.5s` (stillest), Neev/Shweta `glyphBreathSlow` (18s/22s), Ash `glyphPulse 2.8s` (heartbeat).
- **Bindu's words:** an empty/`·` body renders as a glowing ember dot, not text (canon — already in Phase 5).
- **Ash only:** a row "All of Ashram's words in the field →" links to Ash's Voice.
- **Routing:** by archetype id (was `#hash` in the prototype) → SwiftUI value route.

Visual spec: `Player Detail - The Turning.html`. Keep the file `ArchetypeProfileView.swift` (or rename to `TheTurningView.swift` and update the route) — your call, but update all avatar-tap destinations to it.

---

## 9.4 — Players View (new screen)

A grid of every presence, reached from the hub. The app currently has no such screen.

- **Header:** "THE PLAYERS" (Space Mono), italic subtitle "Eight ways of reading. Two roots. One who replies."
- **Grid:** the 8 lenses (Bindu, Gaia, Sid, Arch, Sakshi, Karishma, Ashrey, Lalita) as 2-col cards (glyph + name + role), then the **2 roots** (Neev, Shweta), then **Ash** (Ashram) as a wider card at the bottom.
- **Each card → The Turning** for that presence.
- Reads Archetypes from Airtable (now 10 + Ash, after 9.1). Colors from `Hex Color`.

Visual spec: `Players View.html`. New file `PlayersView.swift`. Add `.players` route + hub entry.

---

## 9.5 — The Mirror (new, 14th portal)

The field turns to face **you** — your own crystallized first-person words, handed back. One reflection holds for the whole day.

- **Container:** a single card held alone in the dark, **terra** (`#C47A52`, Ash's color). Not scrolled. One thing lands.
- **Register (from `Flairs`):** `Vow` → upright Lora 500, label "A VOW · ARRIVED", closing `·`. `Koan` → italic Lora 400, label "STILL LIVING", closing `◌`.
- **Reflection-of-the-day:** deterministic by date. `index = hash(yyyy-MM-dd) % liveReflections.count`. **No behavior tracking** — seed off the date only. Same day → same face; new day → new face.
- **One Bindu Draw per day:** a single ember (Bindu `#E5533C`) below. Tapping reveals **one** alternate reflection, then spends (becomes a hollow ring, "drawn · return tomorrow"). Persist per-day in **UserDefaults** (`mirror.draw.<date>`), not Airtable.
- **Nothing is gated/earned.** Every Reflection is Live from day one; only *which surfaces today* changes.

Visual + content spec: `The Mirror.html`. New file `MirrorView.swift`. Opens from Room Selection's "two turns" tier (9.8). Reads `Type=Reflection` Live rows.

---

## 9.6 — The Signal Space (new, 15th portal)

The inverse of the Mirror — the field transmits to **you** (second person), once. You receive, then leave.

- **Color:** teal `#3AADA8`.
- **Arrival (ceremonial, never a push):** crossing the threshold = a faint teal point, "a signal is arriving"; after a beat it resolves **line by line** from the dark, then signs **"— the field."**
- **One per day**, deterministic by date over Live `Signal` rows. No comments, no resonance, no "next."
- **Leave:** one clean exit (→ back / Home Feed).

Visual + content spec: `The Signal Space.html`. New file `SignalSpaceView.swift`. Reads `Type=Signal` Live rows.

---

## 9.7 — Practice Door (expansion of `LaunchView`)

The launch threshold becomes the **Practice Door** — still one screen on every open, now with 5 kinds.

- **5 kinds:** threshold sentence (most common) · practice invitation · Gaia seed · story that found you · Bindu dot (rare).
- **Weighting (per open):** weighted-random; **nothing repeats back-to-back**; the dot never doubles; the very first open ever is a threshold.

  | kind | weight |
  |---|---|
  | threshold | 40 |
  | practice | 23 |
  | Gaia seed | 20 |
  | story that found you | 12 |
  | Bindu dot | 5 (~1 in 16) |

- **Atmosphere:** pre-dawn warm gold (`#C9A07A`) breathing glow — its own light, *not* the Turning's violet.
- **Crossing:** tap anywhere, you choose when (no countdown). The screen settles to dark, then **Home Feed** dissolves up. (Prototype confirms: cross → Home Feed.)
- Bindu dot kind keeps its canon rendering (glowing ember, not text).

Visual spec: `Practice Door.html`. Generalize `LaunchView.swift` (or `PracticeDoorView.swift`). Data per 9.1.

---

## 9.8 — Room Selection: the two turns

Below the 13 living portals (unchanged), add a divider **"AND THE FIELD TURNS TO YOU"** and two wider horizontal cards — a distinct tier from the story-rooms:
- **The Mirror** (terra ◐, "first person", "What you have already seen, handed back.") → MirrorView
- **The Signal Space** (teal ⊙, "second person", "One transmission, received whole — then you leave.") → SignalSpaceView

These are **not** `Type=Room` records (they have no story feed); render them as two fixed portals in `RoomSelectionView`. The *content* they open is data-driven (9.5/9.6).

Visual spec: `Room Selection.html` (the two-turns section).

---

## 9.9 — Ash's Compose (redesign of `AshComposer`)

The inline compose in Story Detail becomes a **full-screen writing ritual** — the compose-side mirror of the Turning.

- **Launch:** Story Detail's Ash entry ("What arrived for you?") now **navigates** to the full-screen compose (was: inline expand).
- **Lit by the user's arrival colour** — read name/glyph/color from **UserDefaults** (the Settings identity; the app already stores Settings there). Falls back to terra.
- **The field asks:** "What arrived for you?" (canon — keep fixed. *Optional future:* rotate prompts seeded by day+story.)
- **Hold to release:** write, then **press-and-hold an ember** (your glyph, your color); a ring fills over ~2.3s and your light rises; only a full hold releases. `CADisplayLink`-paced, like the Turning.
- **Settle & confirm:** your words settle as your entry, then **"The room has changed."** (canon) fades in; a quiet way back to the story.
- **Post = write an `Ash Comment`** to Airtable per Appendix A. **No synchronous archetype responses** — the field gathers later (9.10).

Visual spec: `Ash's Compose.html`. New `AshComposeView.swift`; keep `AshComposer.swift` only if you fold it in. Add `.compose(storyId:)` route.

---

## 9.10 — The field gathers: the ambient generation pipeline (Make.com)

This is the **"what comes next"** from `CLAUDE.md` ("Make.com pipeline" + "backward ripple"), now specced. It is **backend automation, not iOS code** — the app already reveals Field Comments from Airtable (Phase 5). Decided model: **ambient** (not synchronous).

**Flow:**
1. User posts an **Ash Comment** (Status=Live) → the iOS app's job ends. No "is reading…" state.
2. **Make.com** watches The Feed for new Ash Comments (or new Stories) lacking a `processed` marker.
3. **Route:** classify the comment text and pick the **2–3 archetypes** whose stance fits (not all 8 — routing keeps each voice *earned*).
4. **Generate:** for each chosen archetype, call Claude with its **`Operating Principle`** (already on the Archetype row) as the system/persona prompt, plus the Ash comment + parent Story as context.
5. **Write:** create `Field Comment` rows (Type=Field Comment, Linked Story, Archetype, Comment Order after existing, Status=Live). **Generate once per entry; mark processed (idempotent)** so a post's field is fresh & specific, then stable forever.
6. **Backward ripple** (on new Story): re-read adjacent older Stories, optionally add a Field Comment from an archetype who "remembered," and bump their `Last Activity Date`.

**Experience:** you post, you leave; minutes/hours later the field has gathered; you return and Story Detail's existing sequential reveal shows the new voices. (Optional: a gentle local notification when a post's field has gathered.)

> **Open knob (safe to defer):** synchronous-feel could be added later (one immediate lens + the rest ambient). Start ambient.

---

## 9.11 — Wording reconciliations (canon is load-bearing)

| Place | Use this (canon) | Not |
|---|---|---|
| Compose prompt | **"What arrived for you?"** | rotating prompts (optional future) |
| Post-release confirmation | **"The room has changed."** | "It is in the field now." (prototype line — drop) |
| Field threshold marker | **"The field gathers"** | — |
| Room Selection tagline | **"Each one already alive when you arrive."** | — |
| Settings label | **"HOW YOU ARRIVE"** | — |

New screens (Mirror/Signal/Players/Practice Door) have no prior canon — their prototype wording becomes canon (e.g., "AND THE FIELD TURNS TO YOU", "— the field", "STILL LIVING").

---

## 9.12 — Phase 9 audit check

**Data:**
- [ ] `Reflection` and `Signal` Types added; `Vow`/`Koan` Flairs added; Neev & Shweta Archetype rows Live
- [ ] Practice Door `Sentence Source` values (`Practice`, `Gaia Seed`) added & authored
- [ ] Mirror picks today's Reflection by date-hash; Bindu Draw spends once/day (UserDefaults)
- [ ] Signal picks today's transmission by date-hash; one per day

**Screens:**
- [ ] The Turning replaces Hold-to-Witness with trace-∞ + dawn (60fps, `CADisplayLink`)
- [ ] Players View grid → The Turning for all presences (incl. Neev/Shweta/Ash)
- [ ] The Mirror: vow/koan registers correct; held, not scrolled
- [ ] The Signal Space: line-by-line arrival, "— the field", clean leave
- [ ] Practice Door: 5 kinds weighted, no back-to-back, cross → Home Feed
- [ ] Ash's Compose: full-screen, hold-to-release, lit by Settings color, "The room has changed."

**Navigation:**
- [ ] Hub (dots top-left) opens overlay → Rooms/Players/Practice Door/Settings
- [ ] Ash mark (top-right) → Ash's Voice
- [ ] Room Selection shows the two turns below the 13; both open their screens
- [ ] All transitions are dissolves; back is the frosted ‹ chevron

**Pipeline (separate from app build):**
- [ ] Make.com routes 2–3 lenses per Ash Comment using `Operating Principle`; writes Field Comments; idempotent
- [ ] Backward ripple on new Story (optional, can defer)

---

*Phase 9 is the floor, not the ceiling. If a more elegant SwiftUI pattern presents itself, take it. Never reduce. Always emerge. Slow. Intimate. Already there.*
