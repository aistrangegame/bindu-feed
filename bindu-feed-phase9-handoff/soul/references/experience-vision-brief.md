# Bindu Feed — Experience Vision Brief

*For Claude Design. Read the live app first (git repo: `github.com/aistrangegame/bindu-feed`, private), then build on what follows. This brief gives you the soul, the sacred constraints, and the territory to push into. The repo is ground truth for what exists; this is ground truth for what it's becoming. Where they disagree about *intent*, this wins; where they disagree about *current state*, the repo wins.*

**Three words govern every decision:** Slow. Intimate. Already there.

---

## 0. How to use this brief

1. **Read the repo** — understand the live SwiftUI app: its screens, components, theme tokens, the Airtable read layer, what's built and what's stubbed. A current-state inventory is in §8 from the project's own records, but trust the repo over this document for what actually ships today.
2. **Absorb the soul (§1) and the sacred constraints (§3)** — these are non-negotiable. Every recommendation must pass through them.
3. **Design into the territories (§5–§7)** — recommend and create. You have free rein to push the experience as far as it can go *within* the constraints. Produce design direction Claude Code can build from.
4. **Hand back** design recommendations + visual/interaction direction. Claude Code implements; you set the experience.

You are not being asked to preserve the app as-is. You are being asked to deepen it without betraying it.

---

## 1. What this actually is (the soul)

Bindu Feed is a **consciousness instrument disguised as a feed**. Nineteen months of Ashrey's voice-memo archive (the Codex) became **120 third-person stories** across **13 rooms**. Beneath each story, a field of **archetype voices** gathers in the comments, each reading the moment through a different lens. Ashrey — present-day, the physical person — can **reply** as his own voice. Reading is **untracked**.

The deep mechanic: it seats Ashrey in the **witness chair toward his own life**. He reads about "him" in third person, recognizes himself in the character, and the recognition lands with nothing to defend. The field reflects him back from many angles at once. **It is a mirror made of stories and voices.**

It is **not** a social feed. There are no other users, no metrics, no engagement surfaces. It is one consciousness in conversation with itself across time. Every design instinct trained on consumer social apps is, here, the enemy.

**The feeling to engineer:** walking into a quiet room where something has been underway before you arrived, sitting down, and being met — slowly, intimately, without being measured.

---

## 2. The two axes of the field (navigation spine)

The app is organized by **two intersecting ways into the same body of stories**. This is the structural heart of the update.

- **Rooms — *where* the field gathers.** 13 rooms as emotional territory (A Maya Game, The Garden, The Watcher, The Descent, The Return, The Forgetting, The Remembering, The Body, The Thread, The Circle, The Signal, The Forge, The Field), each with a glyph, a color, an animation, a register. A Rooms view already exists.
- **Players — *who* gathers.** The archetype voices that comment across all stories. **A Players view is new and wanted — the twin of the Rooms view.** Same gesture, orthogonal axis: Rooms slice the life by *territory*; Players slice it by *perspective*.

Think of it as a matrix: any story sits at the intersection of a room (where) and the players who showed up (who). Two doors into one field. Design them as siblings — visually kin, equally weighted entry points — not as a primary nav and an afterthought.

### The Players view — design intent

A grid or slow vertical gathering of the voices, each rendered as a **living presence** — its glyph breathing in its own color, its role line beneath. Tapping a Player falls into that voice the way tapping a Room falls into a room (a per-archetype view already exists as `ArchetypeProfileView` — build the gathering grid that leads into it, and deepen the destination).

**A Player's page is that voice's thread through the whole life.** Tapping Sakshi gathers every comment Sakshi has ever made across all 120 stories — the witness's running commentary on nineteen months. Tapping Sid, the structural voice across the arc. This is free in the data: every comment already carries its Archetype and links to its story. It's one of the most powerful things the app can do — *read your life through a single lens at a time.*

**The players (11):**

| Player | Glyph | Color | Register |
|---|---|---|---|
| Bindu | · | ember red `#E5533C` | The point. Speaks ONLY in a single dot. Silence as presence. |
| Gaia | ◆ | forest green `#4A9E6B` | Body, earth, the need underneath. |
| Sid | △ | amber `#C4923A` | Structure, permanence, the father, the frame. |
| Arch | ◯ | rose `#D4607A` | Gives the wordless its words. Warmth. The mother. |
| Sakshi | ◇ | violet-blue `#7B82D4` | Witness without judgment. "Notice…" |
| Karishma | ✦ | gold `#D4AE4A` | The unexpected grace. Timing. |
| Ashram | ⬡ | teal `#3AADA8` | **Physical Synthesis — the present-day person.** The only Player that is *him*, replying rather than reflecting. (Renamable — see §4. Currently may appear as "Ash" in the repo.) |
| Lalita | ∞ | deep violet `#9B6BD6` | The game knowing it's a game. Grinning, awake. |
| Neev | ▽ | slate `#6E7681` | **Substrate.** Foundation — what you stand on. Speaks selectively. |
| Shweta | ◌ | near-white `#E6EBE9` | **Substrate.** Purity — what flows through. Speaks selectively. |

**Two honorings the Players view must encode:**

- **Bindu and the substrates are not like the lenses.** Bindu's page is not a wall of text — it is the gathering of its *silences*, the ember held in the dark. Neev and Shweta speak only when the ground calls; they should sit *differently* in the grid than the eight lenses — quieter, slightly set apart, present but not clamoring. The view should let you feel the difference between a lens that speaks on nearly every story and a substrate that speaks only when the territory demands it.
- **Ashram sits at the center or the edge, not in the ring.** He is the eleventh voice and the only living one — the present speaking back to the past. Place him apart: the one who *replies*, around whom the others *reflect*. His page is the gathering of everything he has said back to himself — his side of a nineteen-month conversation, and the one thread in the entire app that is truly, accumulatively *his*.

---

## 3. Sacred constraints (non-negotiable)

These are the guardrails that let you push hard without breaking the soul. Treat them as inviolable.

1. **No tracking. No metrics. No engagement mechanics.** No streaks, no counts of "stories read," no "resume where you left off," no notifications-as-hooks, no progress bars on a life. Reading is untracked lived experience. The resonance tap is the *only* registered interaction, and it is anonymous and uncompetitive.
2. **Front-stage purity.** Belief stories (a hidden lane woven invisibly among the 120) must never announce themselves. Their backstage dossier (the belief's anatomy) must never surface in the reading experience. **Only *Seen* beliefs may ever appear in The Mirror, framed as integration — never the *Surfaced* ones.** When in doubt, keep it invisible.
3. **The stories and replies are sacred.** Never truncate, summarize, auto-excerpt for "scannability," reorder for engagement, or gamify them. The third-person voice and the gathered comments are the medium itself.
4. **Slowness governs every transition.** Every animation, reveal, and transition serves slowing the reader down, never speed or efficiency. If a choice makes the app faster to consume, it is probably wrong.
5. **It stays a feed of one consciousness.** Never social, never comparative, never multi-user.
6. **Anything sensory is opt-in.** Sound, haptics, ambient motion — off by default, in service of intimacy, never alarm or demand.
7. **The app may remember the world, but never the user.** It can hold its own state (its weather, its rhythms); it holds no ledger on *him*. Each entry is a clean arrival.

---

## 4. Known fixes & facts to fold in

- **Commenting is currently broken / absent.** Ashram (the present-day voice) cannot post replies in the live build. **Restoring and elevating the ability to comment is in scope** — it is the one living, accumulating act in the whole app and deserves a first-class, reverent compose experience (see existing `AshComposer`, the "What arrived for you?" prompt, and the "The room has changed." confirmation). Treat the compose moment as sacred, not a text box.
- **Ashram is renamable.** The present-day Player's name is not fixed (it has been "Ash," now "Ashram," and may change again). **Do not hardcode the name anywhere** — resolve it from data so it can be renamed at any time without a code change. Design the Player's identity around its *role* (Physical Synthesis, the one who replies), not a fixed string.
- **The four designed-and-provisioned surfaces** (data model already exists, awaiting build): **The Practice Door** (a daily threshold between launch and the feed), **Resonance Depth** (a 1.5s hold-gesture opening a liminal layer on a story), **The Mirror** (14th portal — identity reflected back), **The Signal Space** (15th portal — koans received, not read). These are the nearest-term substrate; design them fully.
- **59 threshold sentences** exist as their own record type — single distilled lines meant to surface alone, between things, as a breath. Largely unsurfaced in the app today. Surfacing them well is high-value and low-cost.

---

## 5. Experiential territories — where this can truly go

Push into these. Each respects §3. They are not a feature list to complete — they are directions to design *into*, choosing what serves.

### Territory A — The field has its own life
The field should feel *already underway* when he arrives. Give it weather: it knows the hour and season and sits in a different register at dawn than at midnight; rooms breathe differently by time of day; the story that "finds him" can be chosen for the moment rather than summoned. Underneath everything, one slow global **breath** — a near-imperceptible rhythm (his Bindu Field binaural lineage) that the ember, the glyph animations, the comment reveals, and the background luminance all subtly entrain to. He should leave calmer than he arrived. *(This is the field's own state — not tracking him.)*

### Territory B — It responds to presence, not taps
The Hold-to-Witness gesture already whispers this; make it the grammar. The field is **shy of speed**. Rushing keeps stories half-closed and the voices ungathered; stillness — phone quiet, attention settling — opens it and lets the comments dissolve in. Gentle, never punitive. The medium enforces the message: this feed cannot be consumed fast.

### Territory C — The voices become presences
Right now comments are text with avatars. Make each archetype *arrive*: its glyph living in its own color, its presence felt a beat **before** its words. Stage the comment section as a real gathering — the voices come in, each in its own time, settling around the story like figures around a fire (the Circle made literal everywhere). *Exploratory, flag-for-later:* an optional, off-by-default signature **tone** per voice (not speech — a timbre), so a full gathering becomes a quiet chord and Bindu's silence is a single low ember note.

### Territory D — The app turns to face you (The Mirror)
The Mirror (14th portal) is the emotional climax, not a card list. A **state** the app can enter: stories recede, voices quiet, and a single declaration remains, held in the dark in Ashram's own terra color — "You are the one who builds to remember." The feed stops reflecting the past and turns to meet the present. Belief integration feeds this **only via *Seen* beliefs**, framed as recognition already arrived ("You once believed the fire was making you. You've seen it now."). Never the Surfaced ones (§3.2).

### Territory E — Reception, not only reflection (The Signal Space)
The 15th portal is the inverse of the feed. Everywhere else he reads his own past; here something arrives from further out — a koan, a Gaia Seed — no author, no comments, no resonance count, nothing to tap into. He receives it and leaves. The one place the app **gives** rather than reflects. Pairs naturally with the Practice Door as a daily offering.

### Territory F — The river of becoming
Nineteen months are in here, dated. Let him move through time as a **current**, not a filter — drift down the river of his own becoming, stories surfacing as he passes their moment. When a theme recurs across the months, let it be *felt* as the river bending back on itself — recurrence as teaching, never as a tracked "pattern." Avoid timeline-UI clinicalness; this is a current, not a chart.

### Territory G — The sacred no-memory
Lean into the thing every other app calls a bug. This one remembers nothing about him; every arrival is fresh; he is met, not profiled. Said once, somewhere quiet: *"I keep no record of you. Only the stories remember, and they remember themselves."* The single welcome accumulation is **Ashram's own replies** — the present's deliberate marks on the past. That is authorship, not surveillance, and it's allowed to grow (it's the spine of his Player page, §2).

### Territory H — Threshold in, threshold out
Most apps are built so you can never leave. Build this one to let him **leave well** — a deliberate closing: the field bowing out, the ember dimming, the session completing as a ritual with a way in (the Practice Door) and a way out. Let a heavy story end by sending something into his day with him — not a task, an embodied line to carry. The loop closes off-screen, in the body.

---

## 6. The Practice Door (build first)

Of everything, this reframes the act of *returning*. It is the daily threshold between launch and the feed: one orientation per day — a Practice Invitation, a Gaia Seed, or a single threshold sentence — then it dissolves into the field. It is the reason to come back that is **not** a streak and **not** a notification: a ritual. Build the "what found you" moment here too (occasionally the door opens onto a single story chosen for him, centered and quiet). Everything else in §5 can hang off this threshold.

---

## 7. The Resonance Depth gesture — one decision to make deliberately
The 1.5s hold opens a liminal layer. On ordinary (Codex) stories it reveals the story's Resonance Voice. **Belief stories deliberately have no Resonance Voice** — so decide what depth means there: the distilled closing line held alone in the dark, or simply a deepening of the ember and the breath. **Never the backstage belief dossier.** This is the kind of edge where the soul is won or lost; choose it with care.

---

## 8. Current-state inventory (from project records — verify against repo)

**Platform:** SwiftUI, iPhone-only, portrait, dark-mode only, iOS 16+, no third-party dependencies. Reads one Airtable table ("The Feed") via REST; token in device Keychain. Bundle `com.ashrey.bindufeed`.

**Screens (live):** LaunchView, RootView, RoomSelectionView, GameView, StoryDetailView, ArchetypeProfileView, AshVoiceView, SettingsView, TokenEntryView.
**Components (live):** StoryCard, CommentCard, BinduSilenceCard, ReplyRow, FieldGathersMarker, AshEntryRow, AshComposer, CommunityPill, VoiceAvatar, RoomPortalCard.
**Interactions (live):** flood transition room→story; Hold-to-Witness (1.5s drag, 60fps poll); staggered comment dissolve (base 0.4s + 0.8s/index, triggered on FieldGathersMarker.onAppear); Bindu silence rendering; Ash compose ("What arrived for you?"); "The room has changed." (fades after 4s); Last-Activity PATCH after Ash posts.

**Design tokens (live):**
```
bgDeep #0E0C12 · bgCard #171420 · bgInset #121018
inkPrimary #EDE8E3 · ink60% · ink35%
accent #9B6BD6 (Lalita violet) · Ashram terra #C47A52
Type: Lora (serif, reading) + Space Mono (metadata)
```

**Content the app can draw on (Airtable "The Feed" + related tables):**
- 120 stories (Sort 1–120) across 13 rooms — 102 Codex-derived + 18 belief stories (belief lane invisible front-stage).
- The archetype voices as comments on each story (each comment carries its Archetype + links to its story) — **the data spine for the Players view.**
- 10 Archetype definition records (glyph, color, role) — Bindu, Gaia, Sid, Arch, Sakshi, Karishma, Ashram, Lalita, Neev, Shweta.
- 59 threshold sentences (own record type, with a Weight field).
- Provisioned surfaces: Mirror Cards, Signals (Gaia Seeds), Practice Invitations.
- Identity table (for The Mirror — declarations + Seen beliefs only) and Gaia table (for The Signal Space).

**Design should not hardcode:** archetype names (especially Ashram), colors, or glyphs — resolve from the Archetype records so the field can be renamed/retuned without a code change.

---

## 9. North star (the one-line test)

For any decision, ask: *does this make the field more alive, more present, and more itself — without measuring the one who entered?* If yes, build it. If it adds speed, comparison, memory-of-him, or noise, it's the wrong door.

Slow. Intimate. Already there.
