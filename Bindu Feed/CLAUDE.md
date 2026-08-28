# Bindu Feed — Claude Code Memory

> **Standing instruction: Never reduce. Always emerge. If you see a better way, take it.**

This file is the persistent, in-repo memory for Bindu Feed — the one document a fresh reader (human or AI) should read **first**. It is authoritative on the **build state** and routes you to the authoritative **design canon** below. (§4–§15 describe the Phase-9 layer in detail and remain accurate for it; the Instrument era, Aug 2026, sits on top — see the precedence section and §3.)

## ⚠️ SOURCE OF TRUTH & CANON PRECEDENCE — read this before building anything

The most expensive mistake on this project is **building to the wrong source** — e.g. rendering the Instrument from *prose descriptions* of the design instead of the actual *rendered* design file, which produced a "pale comparison" that had to be torn out and rebuilt (Aug 2026). To avoid repeating it, resolve every design question in **this order**, and never build from anything below the line:

1. **`canon/`** — frozen, verbatim, non-paraphrasable: exact wording, Hz / number tables, the 66 Point stars (`spine-light.js`, `spine-sound.js`, `point-content.js`). Wins on literal text and numbers.
2. **`Claude Design Round 1/The Instrument v3.html`** — the blessed, **shader-driven, unified** design: the whole app as one continuous 15-register axis. Wins on feel, geometry, interaction. It is a *rendered artifact* — **open it and read the actual shader / JS; do not build from a prose summary of it.** Governed by `Claude Design Round 1/docs/` (the UNIFIED-MASTER-DESIGN-BRIEF wins on feel; the BUILD-LEDGER wins on mechanics; AMENDMENT-01 + FINAL-DESIGN-INSTRUCTIONS layer in). Where a number appears, it **is** the number.
3. **`Claude Design Round 1/comps/`** and the CDR1 per-register HTML — single-register detail only, always **subordinate** to the unified Instrument.

— **do not build from anything below this line** —

4. **`archive/`** (incl. `archive/bindu-feed-phase9-handoff/`, `BINDU_FEED_CLAUDE_CODE.md`, `A Strange Feed/`) — retired history. The handoff still *reads* like a live build spec; it is **not**. See `archive/README.md`.

### Code ↔ design map — where the Instrument design lives in the app
- shader atmosphere (spine-field.js: the 15-shell additive multi-shell glow) → `Instrument/InstrumentField.metal` (Metal fragment shader; renders on the Simulator)
- the axis model + membrane physics → `Instrument/AxisModel.swift`, `Instrument/AxisTravel.swift`
- the host + particle + ladder rail (#rail) + particle-name (#pname) + header (#where) → `Instrument/InstrumentView.swift`
- the seven Point worlds + their universes → `Point/PointWorlds.swift`, `Point/PointWorldView.swift`
- the Universe side (sky / region / world / fall) → `Universe/UniverseView.swift`, `Universe/UniRegions.swift`
- the Light / Rite / Return registers → `Light/`, `Rite/`, `Return/` (+ their `Screens/*View.swift` hosts)
- the 66 stars / 7 dimensions content → `canon/point-content.js` (verbatim) mirrored into the `Point/` content types

**Reach the Instrument on the Simulator without a PAT:** a `#if DEBUG` "⟿ walk the Instrument" door on `TokenEntryView` opens `InstrumentView(startZ: 0)`. (The keychain token persists across app reinstall on the sim; `xcrun simctl keychain booted reset` clears it so the token gate — and the dev door — reappears.) Metal renders on the sim, so the shader IS sim-verifiable.

---

## 1. What this app is

Bindu Feed is a living consciousness feed — an iOS SwiftUI app that renders one man's Codex entries as Stories and lets eight archetype voices gather in the comments around each one, with two roots (Neev, Shweta) and Ash (the physical user) as a third register. There is no local data; every Story, voice, room, threshold sentence, mirror card, and signal is read live from a single Airtable table. The aesthetic mantra is **Slow. Intimate. Already there.** — the app is meant to feel like a field that was already alive when you arrived, not a product you opened.

---

## 2. Current build state

**Phases 1–9 complete** as of 2026-06-14. **Sound Layer landed 2026-06-15**. **The Instrument era (Aug 2026) is built and on `main`** — the whole app rebuilt as one continuous fifteen-register axis (the Universe, the seven Point worlds, the Light, the Rite, the Return, the Metal multi-shell shader, the ladder + particle-name chrome, the centre bloom). It is structure-complete and sim-verified end-to-end; the *felt* layer (drag physics, motion timing, binaural sound) is validated on Ashrey's device "Neev", not the sim. See the source-of-truth section above and §3 for where it lives.

- iOS 17.6 deployment target (project.pbxproj); spec/intent is iOS 16+ — see §11
- iPhone only, portrait only, dark mode only
- No third-party dependencies

**Build sanity check:**
```
cd "/Users/ashrey/Bindu Feed/Bindu Feed" && \
xcodebuild -project "Bindu Feed.xcodeproj" -scheme "Bindu Feed" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug build
```

**App icon generator:** `swift Tools/GenerateAppIcon.swift` (writes `Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`).

---

## 3. Architecture

The Xcode project uses `PBXFileSystemSynchronizedRootGroup` — new `.swift` files dropped under `Bindu Feed/Bindu Feed/Bindu Feed/` are auto-picked up by the target. No `project.pbxproj` editing required. SourceKit may show stale "cannot find type" errors until reindex; trust `xcodebuild`, not the IDE squiggles.

Source root: `Bindu Feed/Bindu Feed/Bindu Feed/`

### `App/`
- `BinduFeedApp.swift` — `@main` entry point
- `ContentCoordinator.swift` — Token gate → Practice Door (every open) → Root
- `Navigation.swift` — `FeedRoute` enum, **15 cases** (the Phase-9 set — note `.archetype` was renamed `.turning` — plus the Instrument era's `.rite`, `.light`, `.returnCeremony(Story?)`, `.instrument(Int)`, `.aperture`). NOT a `NavigationStack`: RootView renders a `ZStack` of `[FeedRoute]` layers with cross-dissolves (see the file header)

### `Services/`
- `AirtableService.swift` — single source for all network calls; weighted threshold-sentence picker
- `KeychainService.swift` — stores the Airtable PAT

### `Models/`
- `Models.swift` — wire types + domain models + `CommentNode` tree + `PracticeDoorKind`/`PracticeDoorContent` + `CardRegister`. **Single `CodingKeys` enum** for all Airtable fields (don't fragment).

### `Store/`
- `FeedStore.swift` — `@MainActor ObservableObject`; owns rooms / archetypes / stories / comments / cards / signals / practices; the 5-kind weighted Practice Door selector; the post-compose refresh handoff

### `Theme/`
- `Theme.swift` — `BinduTheme` enum + `Color`/`Font` extensions + `panel()` modifier. Lora and Space Mono registered by PostScript name — do not silently fall back to `.system`.
- `GlyphAnimation.swift` — 13-case enum + `GlyphView`. Each Room's Airtable `Animation Name` field maps to a case via `init(name:)`; all 13 cases reachable at runtime via that bridge.

### `Components/` (15 files)
Shared SwiftUI subviews. All reachable; nothing orphaned. Notable: `HubTrigger` + `HubOverlay` (`.hubOverlay()` modifier) on every screen except Practice Door; `FieldSurfacePortalCard` for the Mirror/Signal tier; `StaggeredReveal` for field-comment + Signal arrivals; `AshPostedCard` renders with the user's arrival identity (name/glyph/color).

### `Screens/` (the Phase-9 thirteen + the Instrument-era hosts)
The original thirteen (see the §5 screen↔route map) plus the Instrument-era full-screen hosts: `DoorView`, `RiteView`, `RiteGatheringView`, `RiteRecognitionView`, `ReturnView`, `LightView`, `LightNave`. ~20 files total.

### `Sound/` (5 files)
The audio engine — continuous Breath voice that morphs across rooms via equal-power crossfade, transient threshold blooms over the Breath, no recorded audio anywhere. `SoundEngine.swift` (control plane) · `SoundSnapshot.swift` (lock-free-in-practice holders) · `BreathVoice.swift` (Voice A — 6 textures, 0.1Hz LFO, binaural dual-osc or single centered tone) · `ThresholdTone.swift` (Voice B — Bowl bloom-and-decay) · `SonicContext.swift` (resolver + view modifier). See §15. The Instrument adds `Sound/AxisTones.swift` (the nine travel sound calls) + `Sound/AudioAnchorPlayer.swift` (Movement IV playback).

### The Instrument-era folders (Aug 2026) — the one-axis rebuild
Six folders that implement the continuous axis (see the code↔design map at the top for what each maps to):
- `Instrument/` — `AxisModel.swift` (the 15 registers), `AxisTravel.swift` (membrane physics), `InstrumentView.swift` (host + particle + `#rail` ladder + `#pname` + `#where`), **`InstrumentField.metal`** (the Metal multi-shell shader — the atmospheric background), `Breath.swift` (the one launch-anchored breath clock), `BinduParticle.swift` (the particle colours; `BinduParticleView`/`BinduState` are preview-only forward-scaffolding).
- `Point/` — the seven Point worlds + universes + the 66-star content + the live "descend one layer deeper" + the Aperture.
- `Universe/` — the outward side (sky / region / world / fall), the 13 room-regions, the structure lens.
- `Light/` · `Rite/` · `Return/` — the Light register, the daily Rite/Gathering ceremony, the Return ceremony (each with model + tones + its `Screens/*View.swift` host).

---

## 4. Navigation

`RootView` owns the route stack. **It is NOT a `NavigationStack`/`NavigationPath`** — it renders its own `ZStack` of `[FeedRoute]` layers, each pushed layer carrying `.transition(.opacity)` (see `Navigation.swift`'s header + the `pushDissolve`/`popDissolve` helpers). Every level stays mounted, so feed scroll, story scroll, in-progress compose text, and the Instrument axis all survive a push/pop. `FeedRoute` cases (15):

`rooms · room(Room) · story(Story) · turning(Archetype) · ash · settings · mirror · signal · players · compose(Story) · rite · light · returnCeremony(Story?) · instrument(Int) · aperture`

*(Note: `.archetype` was renamed `.turning`; the old `.practiceDoor` route was removed — the Practice Door is reached at launch via `ContentCoordinator` and from `DoorView`, not as a pushed route.)*

Every screen takes `@Binding var path: [FeedRoute]`. **All transitions are cross-dissolves; nothing slides.**

**Launch flow:** `BinduFeedApp` → `ContentCoordinator` → either `TokenEntryView` (first launch) or `PracticeDoorView` (every open) → `RootView`.

**Hub:** `RootView`'s header is `HubTrigger + "A Strange Feed" wordmark + AshMark`. Every other top-level + sub-flow screen also carries a `HubTrigger` (top-left, beside the back chevron). Tapping it opens the "WHERE TO" overlay with four rows: Rooms, Players, Practice Door, How You Arrive. **Practice Door is the only screen without the hub** — its tap-anywhere-to-cross gesture would conflict.

**Back chevron:** every sub-screen has a frosted `BackChevron` (‹), top-left. Cross-dissolve only, no slides.

**Practice Door has two flows:**
1. **Launch surface** — runs every open from `ContentCoordinator`, no nav chrome. Tap to cross → `doorCrossed = true` → `RootView` dissolves up.
2. **Hub-launched route** (`.practiceDoor`) — pushed from `HubOverlay`, same chrome-free body. Crossing pops the entire path to root.

---

## 5. The screens (the Phase-9 thirteen)

*This table is the Phase-9 screen set and remains accurate. The **Instrument era** adds the axis and its full-screen ceremonies on top — the Instrument itself (`.instrument(Int)`), the Rite (`.rite`), the Return (`.returnCeremony`), the Light (`.light`), and the Aperture (`.aperture`) — reached as documented in §3–§4, not listed again here.*

| Screen | Role | Reached via |
|---|---|---|
| `TokenEntryView` | First-launch PAT entry | `ContentCoordinator` if `!store.hasToken` |
| `PracticeDoorView` | Threshold every open; 5 weighted kinds (threshold 40 / practice 23 / gaiaSeed 20 / story 12 / binduDot 5); tap-anywhere-to-cross | (a) launch surface via `ContentCoordinator` (b) from `DoorView` |
| `RootView` | Home Feed — story river, room filter, sort, hub + Ash mark in header | After Practice Door |
| `RoomSelectionView` | 12 portals 2-col + The Field full-width + "AND THE FIELD TURNS TO YOU" divider + Mirror/Signal Space horizontal cards | `.rooms` (hub) |
| `GameView` | One room at a time; prev/next chevrons cycle all 13 in Sort Order; 0.28s cross-dissolve between rooms | `.room(Room)` |
| `StoryDetailView` | Story body + sequential field gathering + Ash entry; Resonance Depth ritual on hold (1.5s) of resonance affordance | `.story(Story)` |
| `TheTurningView` | Trace-the-∞ + dawn-light ritual; archetype's words resolve from dark past 55% progress | `.archetype(Archetype)` |
| `PlayersView` | 8 lenses (canonical order, not Airtable Sort) + 2 roots + Ash full-width card | `.players` (hub) |
| `MirrorView` | One reflection per day; Vow/Koan registers; one Bindu Draw per day | `.mirror` (Room Selection tier) |
| `SignalView` | One transmission per day; line-by-line arrival; signs "— THE FIELD"; clean leave | `.signal` (Room Selection tier) |
| `AshComposeView` | Full-screen writing ritual; hold-ember-to-release; lit by arrival color/glyph | `.compose(Story)` (Story Detail) |
| `AshVoiceView` | User's footprint — every Ash Comment with story + reply context | `.ash` (AshMark, Settings link, Turning's Ash link) |
| `SettingsView` | "HOW YOU ARRIVE" — name / glyph / color with live preview | `.settings` (hub) |

---

## 6. Airtable connection

```
Base ID:    app248ZTWhYJlvQj2
Table ID:   tbl7vzODMMJUgeX0b
Table Name: The Feed
API root:   https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b
Auth:       Bearer <PAT>, stored in Keychain via KeychainService
Page size:  100 records max; follow `offset` token for pagination
```

### The Feed — 10 record Types (Type singleSelect discriminates)

| Type | Choice ID | Readers |
|---|---|---|
| Story | `sely4gGZUloH4KEeX` | `fetchStories(room:sort:)`, `fetchStoriesByIds([id])` |
| Field Comment | `seltI2oj6xdeh098G` | `fetchAllFieldComments`, `fetchFieldComments(storyId:)`, `fetchArchetypeComments(name:)`, `fetchFieldCommentsByIds([id])` |
| Ash Comment | `selgUdEAGB47eOQDg` | `fetchAllAshComments`, `fetchAshComments(storyId:)` — written via `postAshComment(...)` |
| Room | `selqsVmjeI5oHc891` | `fetchRooms` |
| Archetype | `selnJ0w96NTMozu0h` | `fetchArchetypes` (11 rows: 8 lenses + Neev + Shweta + Ash) |
| Threshold Sentence | `selK1wJy98fUacJS6` | `fetchThresholdSentences` |
| Resonance Voice | `sel90xRl5Vtm809ar` | `fetchResonanceVoice(storyId:)` |
| Mirror Card | `selOPdnOomjXCHyJP` | `fetchMirrorCards` |
| Signal | `selpEUJq8wI5Q1xDJ` | `fetchSignals` |
| Practice Invitation | `selzvCCfVhU6Co8dm` | `fetchPracticeInvitations` |
| Gaia Seed | (created 2026-08-27 via typecast) | `fetchGaiaSeeds` |

**Every read gates on `{Status}='Live'`. No exceptions** (post-audit fix to `fetchStoriesByIds` and `fetchFieldCommentsByIds`). The `Status` singleSelect has Draft / Live / Archived; only Live surfaces.

### The blank-Status lesson (institutional knowledge — load-bearing)

Records created without a Status fall through the Live gate **invisibly**. This caused four silent-blank cohorts during the Phase 9 session that all rendered as empty UI before being caught:

- 30 Mirror Cards
- 16 Signals
- 15 Practice Invitations
- 97 Resonance Voices

All four cohorts have since been set to `Status='Live'`. The lesson generalizes:

> **Any new record — authored manually, seeded via script, or written by the future Make.com pipeline — must set `Status='Live'` explicitly. Records without a Status are silently invisible to the app.**

This is the single most important contract for anything that writes to The Feed.

### The two body fields (easy to confuse)

- **`Body`** (field ID `fldnN9WykhzLpVJQG`) — used by **Story**, **Mirror Card**, **Signal**, **Practice Invitation**
- **`Comment Body`** (field ID `fldCVfisHaNtZmlTg`) — used by **Field Comment** and **Ash Comment** only

`Signal` / `MirrorCard` / `PracticeInvitation` inits read defensively as `f.commentBody ?? f.body ?? ""` so the body loads regardless of which name the underlying field carries at any moment. The defensive pattern stays even now that the answer is known — it's a no-cost safety net.

### Category is backstage-only

The `Category` singleSelect (`fld4URzL9VQEQtXbd`; values Value / Mantra / Practice / Energy State / Role / Game / Tree of Life Panel / Belief) is **not read by any code**. It exists purely for data organization. The Mirror's render is driven entirely by `Card Register` (Vow / Koan).

### Important field IDs

```
Name                flds1w07pNzbM2oKV
Type                fldfFRjyasZWodvQC
Status              fldWcw9noNlC2AqVf      Live: seliWi7fUkrRrgJMu
Sort Order          fldKAIGO9RHV235go
Body                fldnN9WykhzLpVJQG      Story/Mirror/Signal/Practice content
Comment Body        fldCVfisHaNtZmlTg      Field/Ash Comments only
Excerpt             fld6rcsZCkfFSyFvM
Room                fld7SeHJhOY1DhkFh
Codex ID            fldppvzE9vMuqOWvk
Source Date         fldsN7G9zycsCyEFq
Last Activity Date  fldELGULGmdbvFbTR      PATCHed by app after Ash post
Resonance           fldahwpoNroxZS4Us      PATCHed by app on tap
Closing Line        fldEEVROYCzxY4CW3      Resonance Depth phase
Last Depth Date     ⟵ PATCHed by app on Resonance Depth dissolve (write path bypasses the Swift model)
Archetype           fldVkGgEen9CpNZ1r      singleSelect of 11
Linked Story        fldLLLvCdaRcXO03v
Parent Comment      fldpMuXqXK7EWE62j      self-link; nested replies
Comment Order       fldJJLGnJz9w0pDdD
Glyph               fld2ALFjohcCi7bOM      archetype + room
Hex Color           fld6lga55ups3j0ZZ      archetype + room
Role                fldBLXPlcrbqLv0S8      archetype
Operating Principle fldESDz3ULot4Aq2A      archetype — used by Make.com persona prompts
Sentence Source     fld8AOcQL34A8pkb2      Bindu / Seed / Story / etc.
Sentence Weight     fldyhpkuMJzvaHdjB
Card Register       fldtDwumFF7HQU4DT      singleSelect: Vow / Koan
Category            fld4URzL9VQEQtXbd      BACKSTAGE — not read by any code
```

### Linked-record filter caveat

Airtable's `filterByFormula` cannot reliably match a linked-record field by record ID — `{Linked Story}` evaluates to the linked records' primary VALUES (story names), not IDs, so `FIND('recXXX', ARRAYJOIN({Linked Story}))` never matches. **All linked-record filtering is done client-side in Swift** (fetch by Type + Status server-side, filter by linked record ID in memory). See `fetchFieldComments(storyId:)`, `fetchAshComments(storyId:)`, `fetchResonanceVoice(storyId:)`.

---

## 7. Identity — Ash, arrival, the rename-safe split

The Airtable archetype row for the physical user is **`Ash`** (`rec9BUbHMuylYiVwH`), role "Physical Synthesis · the one who lives it". This is the **canonical authorship identity** — every Ash Comment posted via the app is written with `Archetype: "Ash"` (resolved dynamically via `FeedStore.postComment` → `archetype(named: "Ash")?.name`, not hardcoded at the service layer).

The user's chosen name / glyph / color in Settings ("HOW YOU ARRIVE") is the **arrival identity** — device-local, display-only, stored as JSON in `UserDefaults` (key `bindu.arrival.settings`). It surfaces in:
- `AshComposeView` — released entry card name, ember + ring color, glyph
- `AshVoiceView` — header avatar (name, color, glyph) + comment row color
- `StoryDetailView` — AshPostedCards below field comments use the arrival name
- `SettingsView` — live preview

**The two are independent.** Renaming yourself in Settings to "Mr. Ashrey" changes the display in those four places; the Airtable `Archetype` value stays `Ash` forever. Airtable reads (filters by `Archetype='Ash'`) and writes are untouched by the rename. **Renaming is safe and fully propagated.**

**One exception remains:** `AirtableService.writeVow` (`:457`) still hardcodes `"Archetype": "Ash"` — the last surviving instance of the defect §10 says not to re-introduce. Resolve it the way `postComment` does.

The arrival-identity fallback (when Settings is empty) is the `ArrivalSettings` struct defaults: Lalita violet `#9B6BD6` + Bindu dot `·`. The display-name fallback specifically is `"Ash"` — the canonical identity, because the struct's default name is empty by intent (not a display value).

The word "Ashram" appears only in design prose (handoff docs, prototypes); it is **not in the data and not in the code**. PlayersView and TheTurningView render `archetype.name` → "Ash".

---

## 8. The field-surfaces tier

Three surfaces aren't story-rooms — they're the field facing you, not a space you enter.

### Mirror (`.mirror`)
A single held card per day, terra `#C47A52`. Reads `Type='Mirror Card'`, deterministic by date-hash (FNV-1a 32-bit) over the local-time day. The `Card Register` field drives render:
- **Vow** → upright Lora 500, label "A VOW · ARRIVED", closing `·`
- **Koan** → italic Lora 400, label "STILL LIVING", closing `◌`

One **Bindu Draw** per day reveals one alternate; spends to a hollow ring. Per-day state in `UserDefaults` (`mirror.draw.<date>.drawn` / `.idx`). No tracking, no graduation; every card is Live from day one — only which surfaces today changes.

Pool is 24 Live, **12 vow / 12 koan**, one cohort, every card carrying authored `\n`. The foreign ASG Value/Mantra/Practice/Game/Tree-of-Life cohort was retired to `Archived` on 2026-08-27. `ReflectionCard` honours `\n` but cannot invent it — **the break is the form on this surface.**

### Signal Space (`.signal`)
One ceremonial transmission per day, teal `#3AADA8`. Reads `Type='Signal'`, date-hash same as Mirror. Three phases: arriving (faint teal antenna point, "A SIGNAL IS ARRIVING") → received (lines resolve from the dark, **one per authored `\n`**) → gone ("The signal was received. The field is quiet now."). Signs **"— THE FIELD"** between lines and leave. One clean exit.

All six Signals carry authored `\n`, and their breaks fall **inside** sentences (`"You keep asking the field\nfor a sign."`). The splitter's derived path is **deleted, not kept as a fallback** — kept, it runs forever and silently, and it can never produce a break inside a sentence, which is exactly what the design authored.

The Signal room (✧ teal) and the Signal Space portal (⊙ teal) share teal **deliberately** — same current at two depths.

### Practice Door (launch surface + `.practiceDoor`)
The threshold every open. Five weighted kinds:

| Kind | Weight | Source |
|---|---|---|
| threshold sentence | 40 | `Type=Threshold Sentence`, `Sentence Source ≠ Bindu` |
| practice invitation | 23 | `Type=Practice Invitation` (8 Live) — renders `Body` + `Practice Sub-line` (`fldWcHyZDGcytIdJg`). Blank sub-line → render nothing, never a substitute. |
| Gaia seed | 20 | `Type=Gaia Seed` (6 Live, authored 2026-08-27 — its own pool, NOT Signals) |
| story that found you | 12 | random Live `Type=Story` (unavailable on cold launch — stories aren't in bootstrap) |
| Bindu dot | 5 | `Type=Threshold Sentence`, `Sentence Source = Bindu` |

Rules: no kind repeats back-to-back; first-ever open (no `bindu.door.lastKind` saved) returns threshold; Bindu never doubles. Tap anywhere to cross — no countdown. Pre-dawn warm-gold (`#C9A07A`) atmosphere shifts to the chosen kind's accent color.

The Mirror and Signal Space portals sit in `RoomSelectionView` beneath the divider **"AND THE FIELD TURNS TO YOU"** as two horizontal full-width cards (terra ◐ + teal ⊙).

---

## 9. Design language — Slow. Intimate. Already there.

### Typography
- **Lora** (serif) — every reading text. Registered by PostScript name on `Font` extension in `Theme.swift`. Fallback is `Georgia`, not `.system`.
- **Space Mono** — metadata, labels, codex IDs, uppercase tags.

### Palette
- Background **`#0E0C12`** (near-black warm). Card `#171420`. Comment well `#121018`. Hairline = `Color.white.opacity(0.06)`.
- Ink: `#EDE8E3` at 100 / 60 / 35% for primary / secondary / tertiary.
- **Archetype colors come from the Airtable `Hex Color` field on the Archetype row, not hard-coded.** Theme has fallback constants but views always read the live field.

### Motion
- Every screen transition is a **cross-dissolve**. No slides.
- Comment reveals **stagger one-by-one** in Story Detail.
- Glyph animations live in the `GlyphAnimation` enum (13 cases). Each Room's `Animation Name` field maps to one via `init(name:)`.
- Room cross-dissolves in Game View = **0.28s**.
- The Turning's dawn-light + the Compose ember + the Resonance Depth hold all run a **60fps `Task.sleep(16ms)` loop** — frame-locked, not `withAnimation`. The fine progression of saturation / colorMultiply / opacity needs the per-frame loop.

### Local time for per-day state
Every "is this still today?" check uses **local time**, not UTC. Mirror's day-key, Signal Space's day-key, any future per-day surface — all local. The user's day is the day their phone shows them. `DateFormatter` with no `timeZone` set; format `yyyy-MM-dd`.

### Wording canon (do not paraphrase)
- Settings screen label: **"HOW YOU ARRIVE"** (Space Mono, uppercase)
- Ash entry prompt in Story Detail: **"What arrived for you?"**
- Compose post-release confirmation: **"The room has changed."**
- Compose return link: **"RETURN TO THE STORY ›"**
- Room Selection header tagline: **"Each one already alive when you arrive."**
- Room Selection field-surface divider: **"AND THE FIELD TURNS TO YOU"**
- Field threshold marker (Story Detail): **"The field gathers"** in italic Lora
- Signal Space sign-off: **"— THE FIELD"**
- Signal Space gone state: **"The signal was received. The field is quiet now."** + **"ONE A DAY · RETURN TOMORROW"**
- Mirror — Vow label: **"A VOW · ARRIVED"**; Koan label: **"STILL LIVING"**; Bindu Draw spent: **"DRAWN · RETURN TOMORROW"**; pre-draw hint: **"DRAW ONCE MORE"**
- Practice Door kind labels: **"A THRESHOLD"**, **"A PRACTICE"**, **"A GAIA SEED"**, **"WHAT FOUND YOU"** (no label for Bindu dot — the dot is the whole thing). Cross hint: **"TAP TO CROSS"**.
- Hub overlay: **"WHERE TO"** at top, **"TAP ANYWHERE TO STAY"** at bottom; rows: `The Rooms — thirteen ways in` · `The Players — the lenses that read` · `The Practice Door — cross the threshold` · `How You Arrive — name, colour, mark`.
- Turning's trace captions: **"trace the loop — let the light in"** → **"stay with the turning…"** → **"witnessed · the light is up"**.

### Room name styles (exact)
- "The Watcher" → uppercase, letter-tracked (Space Mono)
- "The Descent" / "The Return" / "The Field" → italic Lora

---

## 10. Load-bearing decisions — do not undo

- **No-tracking model for Mirror + Signal Space.** The old tracking model (`Last Shown` markers, `Koan Status` graduation sorting, comments on Signals) was retired in Phase 9. Reads `Type=Mirror Card` and `Type=Signal` (not "Reflection" — the spec proposed that name but the schema uses Mirror Card). Register lives in `Card Register`, not `Flairs`. Don't re-introduce tracking.
- **Practice Door is every open, not once-per-day.** The old `bindu.practice.lastShownDate` gating was retired in step 6. Every launch surfaces a fresh kind.
- **Bulk comment fetch on feed load.** The Turning and Ash's Voice fetch comments by `Archetype` filter, collect distinct `Linked Story` IDs, then bulk-fetch with `fetchStoriesByIds`. Do not regress to N+1 per-comment lookups.
- **60fps loops, not `withAnimation`, for hold gestures.** Turning, Compose ember, Resonance Depth hold all use `Task.sleep(16ms)`. The dawn curve and the words' resolve-from-dark need the per-frame progression.
- **Cross-dissolve transitions everywhere.** Game View room switches are 0.28s dissolves. No `NavigationLink` push slides anywhere.
- **Archetype color from Airtable `Hex Color`, not constants.** Theme has fallback colors but views always read `archetype.color` (the live field).
- **Single `CodingKeys` enum in `Models.swift`.** All Airtable fields share one decoder. Adding a new field = adding a case here. Don't fragment per-type.
- **No local persistence beyond UserDefaults.** No Core Data, no SwiftData, no on-disk cache beyond `FeedStore`'s in-memory dicts + the Settings JSON + per-day Mirror/Door state in UserDefaults.
- **`postAshComment` takes `archetypeName: String` dynamically.** The service layer is entity-agnostic; `FeedStore.postComment` resolves `archetype(named: "Ash")?.name` and passes it. Don't re-hardcode "Ash" at the service layer.
- **Defensive body-field read.** `Signal` / `MirrorCard` / `PracticeInvitation` inits use `f.commentBody ?? f.body ?? ""`. Safety net against future Airtable field renames.
- **Local-time day-keys** (not UTC) for per-day state. See §9.
- **`Status='Live'` gate on every reader.** Including the two that Phase 9 added it to (`fetchStoriesByIds`, `fetchFieldCommentsByIds`). No exceptions.
- **Hub on every screen except Practice Door.** PracticeDoor's tap-anywhere-to-cross gesture would conflict.
- **Identity split.** Authorship = "Ash" (canonical, always). Display = arrival settings (device-local). See §7.
- **Airtable holds what accumulates; `canon/` holds what was authored once.** Stories, comments, resonance, App Activity, the field surfaces and the Return write-back live in the base. The 66 stars, the 67 Light lines, the 87 Rite strings, the 5 DEALS and the 37 REGISTERS live in `canon/`, ship as a verified Swift copy, and are **never read from the base**. The base's 138 Point records are the staging area they were authored in. This line did not exist before 2026-08-27 and its absence is why the Point appeared to live in three places.
- **Sort bands are a contract.** 201–220 Mirror · 301–306 Signal · 401–408 Practice · 501–506 Gaia Seed · 601 Threshold canon · **900+ runtime-written, always.** `writeVow` MUST write in the 900 band, or every carved Declaration sorts to the front and shifts the day-hash for every past and future day.
- **Age comes from days, never from rank.** `Sealed At` (`fldlg5Vmh0BbpWise`) stores the date; `days = today − Sealed At` is computed **at read time**. `Ring Index` (`fldo6gU5Q9L4XDyoX`) is position only and must never derive age. A stored `days` integer is stale the next morning.
- **An unwired slot renders absence, never an invention.** Every invented string in the app sits exactly where a content slot was never wired — the gate with no DEALS, the Light's declared-but-uncalled `beatCue`, the Universe with no `say()`. Before writing any string, grep `canon/` and the design files for the slot it would fill. **The rule cuts both ways:** deleting an authored string is the same error inverted — `touch to read` (`The Universe v3.html:1434`) is canon and ships.
- **A story is resolved by record id, never by a soft key.** `logStoryMet` used to find the row to link with `stories.first { $0.codexId == codexId }`. `Story.codexId` normalises a missing Codex ID to `""`, and **15+ Live stories carry a blank Codex ID** — so meeting any of them linked the activity row to whichever blank-Codex story sorted first, and when `stories` had not loaded (it is *not* in `bootstrap()`) the lookup returned nil and the row was written with no link at all. Both `Story Met` rows in the base were wrong, one each way. `Ash Replied` and `Story Resonated` were never affected because they pass the record id straight through. **Anything that writes `Link to Feed` — the app, or the Make.com pipeline — takes the record id. A row may be written without a link; a link may never be guessed.**
- **`WORDS` is keyed on the record id, and that is a DELIBERATE DIVERGENCE from the design.** `uni-field.js:66,71` reads `WORDS[s.codex]`, because the reference build never had two stories on one Codex ID. The live base does: **102 Codex-derived stories carry 100 distinct ids — `C-1052` and `C-1170` each name two stories, one from the 21 May batch and one from 13 June — and 18 belief stories carry none at all.** Both stories in each pair are legitimate and both hold full ensembles. Keyed on the codex, C-1052's sealed gathering would appear under *The Severance of Being Born* as well as under *The Two Who Were One*, which is the one it was sealed on (`RiteCanon.title`, `The Rite v3.html:1177-1178`). So `UniWords.byStory` keys on `rec0DReVXAssEftsn`. **A future session reading `uni-field.js` will see the mismatch — it is intentional, and reverting it re-introduces the bug.** Same root as the `logStoryMet` entry above, from the other side: that broke on the blanks, this would break on the duplicates.
- **The yantra's `dim` is EASED, and that is a DELIBERATE DIVERGENCE.** `point-yantra.js:108` is a hard ternary — `const dim = mode==='descend' ? 0.22 : 1` — and `dim` multiplies every alpha in the figure (stars `:117`, wash `:125-126`, both figure passes `:134`/`:140`, bloom `:145`, incense `:172`). The app eases it instead, over ~1s. **The reason is that the design never shows this transition and the app must.** In the design a reading is an `.ovl` at `z-index:12` over `rgba(7,8,13,.965)` — it *covers* the figure in one step, so a hard switch underneath is invisible. E3 replaced that sheet with seven bespoke readings that are **transparent over a visible figure**, so the switch is now on screen: a snap from 1.0 to 0.22 under the first section reads as a flinch. Both of the design's own recede analogues — the Rooms' `(sub > 0 ? 0.42 : 1)` and the seven worlds' `displaced()` — are continuous functions of a continuous quantity. **A future session reading `:108` will see a hard ternary; the divergence is intentional and reverting it re-introduces the flinch.** The 0.22 target itself is verbatim and must not move.
- **A caption over the words hides; only the ground recedes.** `dim` is for what is drawn *behind* the reading. Chrome drawn *on* it — `#where`, `#pname` — hides outright, because the design covers it with the opaque `.ovl` and because a mono caption crossing serif body text reads as damage at any alpha, not as ground. `#pname` sits at a fixed `height*0.5 + 22` while the reading scrolls past, so it collides with a different line every frame.
- **A CLAIM IS RELEASED BY EVERY PATH ITS OWNER CAN LEAVE BY, NOT ONLY THE POLITE ONE.** Three instances of one discipline: `handedToRegister` had the hole at the crossing; `closeFall` fixed it by routing every exit through one function; `PressClaim` leaked because the Chamber's wall strip vanished mid-press when `s.done` flipped, so `onEnded` never fired and the rope stayed dead for the session. **Every claim gets ONE release function, and every exit — completion, dismissal, the owner being unmounted mid-gesture, the register changing — is checked to call it.** The polite path is the one that always works and therefore the one that proves nothing.
- **Reinstall before any screenshot is offered as evidence.** A clean working tree is *not* evidence about what is on a device. A DEBUG probe added and removed inside one working stretch never enters a commit, so `git log -S` finds nothing — and the installed binary still shows it. This actually happened: a `hall peak at enclosure` probe was seen live on Neev while the repo had no trace of it at any commit. **Any walk that has not been preceded by a fresh install may be reading a build that no longer exists**, and that cuts both ways — it can show a defect already fixed, or hide one already introduced.
- **His return words live in a `Return Answer`, not in the ring's `Body` — a DELIBERATE DIVERGENCE from the provisioning spec.** The spec put Ash's words in the `Type='Return'` row's `Body` and reserved `Return Answer` for a voice answering *him*. The app writes the ring as pure record — `Ring Index` and `Sealed At`, no words — and puts every utterance in the thread, his included, in a `Return Answer` distinguished by `Archetype`. The premise is a FORWARD RULE, not a description of the base — **`Type` encodes the ACT, `Archetype` encodes the SPEAKER** — because the base has a counter-example and a future session will find it: `AirtableService:284` writes `archetypeName == "Ash" ? "Ash Comment" : "Field Comment"`, which is `Type` encoding the speaker, in the most-used write path there is. **That pair is the legacy exception and nothing new follows it.** So: (1) one Type per act keeps the schema readable as it grows — a second Type per speaker doubles for every act;  (2) a future voice answering him writes `Return Answer` with `Archetype='Gaia'` and collides with nothing; (3) §6 reserves `Body` for Story/Mirror/Signal/Practice and `Comment Body` for anything said — the ring holding words in `Body` would break that line. **This changes what "answer" means**, so the Make.com pipeline must read `Archetype`, never `Type`, to know who spoke.
- **`Linked Story` is not guaranteed to hold one id, and `Parent Comment` is why.** They are a SYMMETRIC PAIR on this table: writing `Parent Comment: [ringId]` on a Return Answer makes Airtable add that answer to the ring's `Linked Story`. The app writes one link; the base stores two. Verified in the base — a ring's `Linked Story` held the story AND the answer. So **no reader may take `Linked Story.first`**: `ReturnRing` keeps every id and the store resolves which one is actually a story. This is the `codexId` fault in a third place — a lookup keyed on a field that does not promise to be singular. It applies to every nested reply, not just returns.
- **`spoke` is the LENSES; Ash is never in it.** `uni-field.js:54-56` sorts `spoke` through `BY[k]` and then pushes Ash **separately** as `ASH`. With him inside `spoke` three things break at once: `BY['ash']` resolves to nothing, `spoke.length` inflates so `cmts > spoke.length + 1` needs one more return than the design intends, and he is seated twice — once as a lens and once as himself. `loadStoryStats` counts his words in `cmts` and excludes him from `archetypes`.
- **A story returns only once he has sealed his own words on it.** The Return's own gate (`returnData(for:)` requires a sealed self). It is why C-1052's Ash paragraph in `uni-field.js` is still unreachable: *The Two Who Were One* carries no Ash Comment, so the ceremony that would raise `cmts` refuses to open on it. Seating him there is a sequence — seal, then return twice — not a bug.
- **`spine-axis.js` IS STRINGS ONLY — never structure, never indices, never counts.** It is the PRE-LIGHT extraction: fourteen registers, `Z0 = −4`, `presence` reading `|(Z+4) − i|`. The live axis has fifteen, `Z0 = −5`, and `InstrumentField.metal:188` is explicit — `float zi = uZ + 5.0`. **This one file has now caused three separate errors**, each one someone mistaking a partial extraction for the authority:
  - **E1 · RETIRED, NOT FIXED.** "spine-axis.js has 14 registers and no Light" was read as a conflict. It is not: the file simply predates the Light.
  - **E2 · RETIRED, NOT FIXED — IT WAS NEVER REAL.** The audit read `B.hzAt`'s `REG[min(14, i+1)]` as an overrun. `The Instrument v3.html:1003 var REG=[` has **fifteen** entries and `:4156`'s clamp to 14 is correct against it. The audit counted `spine-axis.js`'s fourteen. **Do not re-open either, and never "fix" `hzAt` to 13**: `Axis.registers` index 13 is d7 at 852 Hz and index 14 is the centre at 963, so clamping would sound the bindu as the Dance at exactly the place the walk arrives.
  - Porting its `(Z+4)` indexing would shift every shell by one register.
- **Pitch from VOICES; timbre from CHAR. The two tables disagree and only one is the pitch.** `The Instrument v3.html:404-418` VOICES carries the ladder the instrument sings; `field-sound.js:27 HZ` carries an older per-presence tone from before the axis had one. They differ on four voices audibly — shweta 342/329, karishma 528/392, **ashrey 432/196 (an octave and a fifth apart)**, ash 198/261. `field-sound.js:13-25 CHAR` supplies wave, partials, gain, attack, release, pan and the optional bodies (bindu's flicker, arch's vib, shweta's air, karishma's shimmer, lalita's gliss) and supplies **no pitch at all**. Ash: 198 Hz from VOICES (uncontested — he is not in the Rite's table), `CHAR['ash']` for body.
- **Two beds, and only one surface climbs.** `field-sound.js:53-70` is the field bed: **root + fifth** (`×1.5` at gain 0.16) through a 900 Hz low-pass, in a 3.6s room at wet 0.5. `point-sound.js:40-58` is the Point's: the **binaural pair**, `f` left and `f + beat` right with an octave above at 0.06, in a 7.5s room at wet 0.42 — the cathedral. `BEATS = [8, 7.5, 7, 6.5, 6, 5.5, 5, 4.5, 4.2, 4]` narrows alpha into theta as he descends, and **the narrowing IS the climb made audible**. The app ran the binaural pair on every surface, which said a journey was happening on the Practice Door and the Mirror. `.climbing` is asked for by the Point band and by nothing else.
- **FIVE SHAPES OF THE SAME FAULT, and the fifth is the worst.** An *unwired* slot, an *unreachable* one, an *uncalled* one and an *empty-bodied* one all render as absence — and only the empty body lies, because a correct name with real call sites reads as a working feature. **The fifth renders as SOMEONE ELSE'S PROBLEM: a defect that produces exactly the symptom a known limitation would.** PlayersView's fold was recorded for four passes as "synthetic touches don't drive a SwiftUI ScrollView"; it was a zero-distance `DragGesture` on every card eating the ScrollView's pan, and it failed a real finger too — Neev, Shweta and Ash were unreachable in the shipped app. **Three signals contradicted the explanation and it survived anyway, because it arrived pre-approved.** The tell: *a harness limitation does not discriminate.* Taps worked and three drag methods did not; the Return's ScrollView scrolled under identical synthetic drags. **When a known limitation explains a symptom, check whether it explains ALL of the symptom.**
- **The comp's fixed geometry vs. an archive larger than it was drawn for.** Four instances: the map density (31 → 101), register 0's overlap (the comp's `says` is 2–3 short blocks; the base's Operating Principle runs five lines), the Universe's fixed mark size, and Karishma's spiral (`The Rooms v4.html:729` states 19 fields; the base holds 48, and `th` is normalised by `n` on a fixed `R`, so they pack tighter on one locus). The first three are fixable. Karishma's is not, without inventing an `R` that grows with `n` — so it is a **named limit with a measurement**, never a silent one.
- **A voice is resolved by record, never by name.** The eleventh voice is one identity: Archetype `rec9BUbHMuylYiVwH` (Ash · ◉ · `#C47A52` · *Physical Synthesis · the one who lives it*), select option `selMpHCRiAWAVJocZ`, 198 Hz from `The Instrument v3.html:415`, timbre from `field-sound.js` `CHAR['ash']`. The display string is device-local and changeable at any time; nothing in the app may key off it.

---

## 11. Known-deferred (the polish list)

Surfaced during the Phase 9 audit, intentionally postponed. None block anything; they're refinements waiting for the right moment.

| Item | Surface | Notes |
|---|---|---|
| Per-presence breath cadences | PlayersView, TheTurningView | Prototype assigns each archetype a unique duration; iOS uses `glyphBreathe` for the lens group (with `glyphEmber` for Bindu, `glyphCircle` for Lalita). Costs new enum cases or a duration param |
| Mirror body 22pt vs prototype 27pt | MirrorView | Tuned for iPhone width; judge on Neev before adjusting |
| No scroll-to-words on Turning completion | TheTurningView | Prototype scrolls content to y=360 after 700ms when done; iOS uses opacity-only reveal |
| Hub-from-hub-destination duplicate | Hub overlay | Tapping "Settings" while on Settings stacks a copy. NavigationPath has no public API for top-element comparison; refactor path to `[FeedRoute]` to fix cleanly |
| Role label format | PlayersView, TheTurningView | Renders `archetype.role.uppercased()` → "NEED ARCHITECTURE"; prototype shows shorter "NEED". Lenses are "X Architecture" while substrates use "X · descriptor" — trim first-word in code to read consistently (don't edit Airtable role text — the formal ontological names belong in data). Ashrey's aesthetic call when polishing |
| `onChange(of:perform:)` iOS 17 deprecation | ~10 sites | Widespread pre-existing pattern; modernize in one pass |
| `terra` property name in AshVoiceView | AshVoiceView | Returns user's arrival color now, not necessarily terra. Cosmetic rename |
| Resonance Depth phase timings (3s / 3s / 4s) | StoryDetailView | Hardcoded; configurable later if desired |
| **iOS deploy target 17.6 vs spec 16+** | project.pbxproj | A real decision, but for before any public release, not before now |
| Ash→Ash threading parent hint | AshVoiceView | `fetchFieldCommentsByIds` is now `Type='Field Comment'` only — Ash-as-parent chains lose the "↩ In reply to" hint. **Currently moot** (all Ash comments are top-level; no app path creates Ash-as-parent replies). If needed later, add a separate `fetchAshCommentsByIds` |

---

## 12. The one runtime truth

**Write path verified 2026-06-14**, via programmatic write-path test (MCP, exact `postAshComment` payload + parent-story PATCH) + data-side confirmation. Test artifact `recoVU4CRoUKqX3q3` retained as Draft (hidden from the Live-gated app; preserved as audit trail).

The compose loop's data write is whole: the payload's `Status='Live'` carries through (no silent-blank fall-through), the `Linked Story` association resolves against the parent record, `Archetype='Ash'` is accepted (the step-2 archetype-resolution fix is closed), and the parent-story `Last Activity Date` PATCH succeeds. Zero Live Ash Comments in the base post-cleanup — first-encounter state pristine.

**On-device walkthrough** (kept for future re-verification or first-encounter exploration; not required to validate the current build):
1. On `phase-9` branch, ⌘R in Xcode targeting Neev
2. Cross the Practice Door → Home Feed
3. Tap any story card; scroll past "The field gathers"
4. Tap "What arrived for you?" → AshComposeView opens, lit by arrival color
5. Type a short line, press-and-hold the ember (~2.3s) until the ring fills
6. Released card appears with arrival color / glyph / name, then "The room has changed." fades in
7. Tap "RETURN TO THE STORY ›"
8. Story Detail re-fetches; new card appears in the AshPostedCard section below field comments
9. Verify in Airtable web: filter `Type='Ash Comment'` + `Status='Live'`, sort by Created Time desc

---

## 13. What comes next

### The Make.com ambient field-gathering pipeline (backend, separate from iOS build)

When a new Ash Comment lands (Status=Live), Make.com:
1. Watches the Feed for new Ash Comments lacking a `processed` marker
2. **Routes** the text to 2–3 archetypes whose stance fits (not all 8 — routing keeps each voice earned)
3. **Generates** for each chosen archetype using their `Operating Principle` as the persona/system prompt, plus the Ash comment + parent Story as context
4. **Writes** new `Field Comment` records (`Type=Field Comment`, `Linked Story` set, `Archetype` set, `Comment Order` after existing, **`Status='Live'`**)
5. Marks the source Ash Comment processed (idempotent — generate once per entry, then stable forever)

**Critical contract:** every record Make.com creates **must set `Status='Live'`**. See §6's blank-Status lesson — a pipeline that creates Field Comments without Status will produce invisible cohorts.

Optional later: backward ripple (when a new Story lands, re-read adjacent older Stories and quietly add a Field Comment from an archetype who "remembered"; bump `Last Activity Date`). Designed; not built.

### Content forward edge

**117 Maya entries** to process — raw Codex entries waiting to be transformed into Story rows. Belief lane: first 18 belief stories complete (Sort 103–120); forward edge documented in the asg-airtable side notes.

---

## 14. Legacy notes

These are inert, harmless, and documented here so a future audit doesn't re-flag them.

- **57 orphan field comments** sit in the data linked only to Mirror / Signal / Practice records (residue from the retired tracking model). Inert from both ends: `fetchFieldComments(storyId:)` filters client-side by story id and excludes them; `fetchArchetypeComments` gates on Live and excludes them. No reader surfaces them. May be archived data-side; no code change needed either way.
- **Retired UserDefaults keys** (`bindu.practice.lastShownDate`, `bindu.practice.lastShownId`) are removed on every launch by `ContentCoordinator.removeRetiredUserDefaultsKeys()`. Idempotent — `removeObject` is a no-op after the first call clears them; no migration-tracking key needed.
- **Six retired `RecordFields` properties** (`triggerCodexEntry`, `sourceIdentity`, `sourceSeed`, `koanStatus`, `lastShown`, `typeWeight`) — Swift side dropped during audit reconciliation. **Airtable fields untouched.** `Source Identity` still carries the belief→Identity ledger link; `Last Depth Date` is still PATCHed by the app on Resonance Depth dissolve (the write uses the field name directly in the PATCH payload, not the now-removed Swift `Story.lastDepthDate` property).
- **Two orphan `@Published`** (`currentRoomFilter`, `currentSort`) dropped from FeedStore during the same cleanup — they were set in `loadStories` but never read.

---

## 15. The Sound Layer

Three generated audio layers (no recorded audio anywhere), all synthesized live from Airtable parameters. **Slow. Intimate. Already there.** for sound means: nothing percussive, earbud-close and quiet, fades in below conscious notice — as if it was always humming.

### The two-voice principle

This is **not** four sources playing together. It is **one continuous voice** that morphs, plus **one transient voice** that blooms occasionally over it.

- **Voice A — the Breath** (continuous). One synth voice, always running while the app is foregrounded. Room transitions = spawn a new BreathVoice with the room's parameters; equal-power crossfade between the two over 4s (sin/cos curves); old voice releases when its level reaches zero. **At most two BreathVoices coexist** — coalescing in `crossfadeTo` detaches any prior outgoing so rapid tapping through rooms never stacks.
- **Voice B — threshold tones** (transient). Bowl-tone blooms over the Breath at natural level (0.30–0.35, above Breath's 0.12 — no ducking needed). Two occasions: Practice Door crossing (every cross) and foreground resume (Arrival). Never two threshold tones stacked.

A future voice / Resonance-bloom layer would duck Voice A on hold (`SoundEngine.duckBreath()` stub is in place — currently empty, the locked scope is only the three generated layers).

### Data — 8 fields on `The Feed`

| Field | Field ID | Type | Range / values |
|---|---|---|---|
| Sound Role | `fldQKW12Hu7yFslap` | singleSelect | Breath / Arrival / Practice Door |
| Root Hz | `fldqqFJYKKaRicDQ8` | number(2) | fundamental drone (Hz) |
| Binaural Hz | `fld1evT7LZmbTawSz` | number(2) | L/R offset (Hz); 0 = none |
| Sound Texture | `fldEoXKvjHsnJGeBH` | singleSelect | Sine / Triangle / Soft Saw / Noise Bed / Bowl / Shimmer |
| Brightness | `fldZKuz38klXDPnmg` | number(2) | 0–1 (log-mapped low-pass cutoff: ~200 Hz → ~6 kHz) |
| Sound Level | `fldV2RRfX0KCLEuNV` | number(2) | 0–1 amplitude (kept low — Breath ~0.12) |
| Attack (s) | `fldGgTI7WBOeA0HcU` | number(1) | fade-in seconds |
| Release (s) | `fld0PupsmwLC7Ty4r` | number(1) | fade-out / decay seconds |

A new `Type` option `Field Sound` (`sel2RjHKVzWfBbWr9`) discriminates the audio records. Field Sound records carry all 8 fields. Room records carry the middle 5 (no Sound Role / Attack / Release — room transitions use the global 4s crossfade, not per-room timings).

**`Status='Live'` applies to sound too** — the blank-Status lesson (§6) extends here. A Field Sound record without `Status='Live'` is silent. `FieldSound.fallbackBreath` is the never-silent safety net: hard-coded values matching the seeded Breath exactly, used when fetch fails, no Live Breath exists yet, or per-field gaps in a Live record. The Breath must never go silent — this is the inverse of the gate.

### Seeded records (data-side sign-off 2026-06-15)

3 Field Sound records (`Type=Field Sound`, `Status=Live`):
- **Breath** `recH0qRgSGB9OP28c` — 110 Hz, 4 Hz binaural, Sine, brightness 0.30, level 0.12, attack 12, release 8
- **Arrival** `recCg24pJamAthNwv` — 220 Hz, 4 Hz binaural, Bowl, brightness 0.55, level 0.35, attack 0.5, release 7
- **Practice Door** `recZQzYxCHiloON4X` — 164.81 Hz, 4 Hz binaural, Bowl, brightness 0.45, level 0.30, attack 0.8, release 8

13 Room records carry their own sound coloration (G2–G3 range, consonant intervals around A2/110 Hz). Design logic: pitch maps to weight (Descent lowest 98 Hz → Signal highest 196 Hz); brightness to clarity (Forgetting darkest 0.18 → Signal brightest 0.80); texture to quality (Shimmer = luminous rooms, Noise Bed = embodied/hazy, Triangle = structured/forged, Sine = the rest); binaural sits in theta/low-alpha (3–5 Hz) for inward rooms, higher (6–7) for alert ones. All levels ~0.10–0.13 — everything barely there.

**Every value is tunable from Airtable with no rebuild.** Pickup is on next app launch (`bootstrap()` re-fetches via `loadFieldSounds`). If field values change while the app is running, `.onChange(of: store.fieldSounds)` in `ContentCoordinator` calls `engine.setBaseBreathSnapshot(...)` and the engine crossfades if the new values differ from the in-flight Breath.

### SonicContext resolver + precedence

Each surface reports its sonic context via the `.sonicContext(...)` view modifier; the engine's `setContext(_:)` resolves "context → target snapshot" and crossfades. **Single source of truth — no scattered set/restore hooks, no "leave" calls, no SwiftUI lifecycle race.** Latest report wins; coalescing absorbs rapid changes.

| Surface | Sonic context |
|---|---|
| Home feed (all rooms) | `.base` |
| Home feed (room filtered) | `.room(filtered room)` |
| RoomSelectionView | `.base` |
| GameView | `.room(currentRoom)` — morphs as arrow chevrons cycle through the 13 rooms |
| Story Detail | `.room(story's own room)` — **always**; the story carries its room's weather regardless of how the user reached it (resolved via the existing story↔room association, no new tracking) |
| Mirror, Signal Space, The Turning, Players, Ash's Voice, Settings | `.base` — places you meet the field directly, no room's weather over them |
| Practice Door | `.base` (and the Practice Door tone blooms over the Breath on cross) |
| Hub overlay | **no change** — transient overlay, leaves context underneath alone (no `.sonicContext(...)` call) |

Per-surface coloration for Mirror / Signal Space is a trivial future add (same 8 fields apply, those records already live on the same table); deliberately deferred to hold the locked three-layer scope.

### Model B — Practice Door owns the launch threshold

Two threshold-tone occasions:

1. **Practice Door crossing** — fires the Practice Door tone (0.8s attack / 8s release). Every door cross: cold launch AND hub-pushed. Wired in `PracticeDoorView.cross()`.
2. **Foreground resume** — fires the Arrival tone (0.5s / 7s) alongside the Breath fade-in (~2.5s ramp; not the full 12s cold-launch attack — a return isn't a first arrival, doesn't re-stage the ceremony). Wired in `ContentCoordinator.handleScenePhase(.active)`. **Does not fire on cold launch** — `.onChange(of: scenePhase)` doesn't trigger for the initial `.active` state, so Arrival and Practice Door can never stack.

The engine starts post-token in `ContentCoordinator.startSoundEngine()` (per the locked decision: quiet until the field is reachable). The first Breath fade-in coincides with the Practice Door tone bloom — the app's first breath is its first arrival.

### Speaker fallback

When not on headphones (built-in speaker, receiver), both BreathVoice and ThresholdTone collapse to a single centered tone at Root Hz (no binaural offset). Honest about what a speaker can deliver — no fake LFO at the binaural rate pretending to be binaural.

Route detection observes `AVAudioSession.routeChangeNotification` and publishes to a lock-free `RouteStateHolder` the audio thread reads each render. Headphone-equivalent ports: wired headphones, Bluetooth (A2DP / HFP / LE), AirPlay, USB audio. All else falls back to centered tone.

### AVAudioSession contract

`.ambient` + `.mixWithOthers`:
- **Honors the silent switch.** The field never imposes.
- **Mixes with the user's own audio.** Their music keeps playing under the Breath; we never hijack the device's audio.
- **Foreground only.** No background mode — the Breath stops on backgrounding (faded out gracefully).
- **Yields on interruption.** Calls / alarms / Siri pause the engine; resume only if the system signals `.shouldResume`.

### Render-path discipline

The AVAudioSourceNode blocks (BreathVoice, ThresholdTone) run on the audio thread and read parameters from `OSAllocatedUnfairLock`-backed holders. They never await the actor and never block on contention — writes only on room change (~once per minutes); reads per audio buffer (~few ms); lock acquisition completes in nanoseconds. Apple's recommended fast primitive for this profile.

### Verification status

**Sim-verified (2026-06-15):** app builds, installs, and launches without crash; `SoundEngine` instantiates cleanly (AVAudioSession + AVAudioEngine allocate without error); "quiet until token" gating is honored (no audio activity pre-token); TokenEntryView renders with the design language intact; SourceKit "missing type" diagnostics confirmed false positives. Deeper audio behaviors (Breath fade-in, room crossfades, threshold blooms, scene-phase fades) require a PAT in the sim keychain to exercise.

**On-device crash + fix (2026-06-15):** first on-device launch surfaced `AVAudioEngineGraph::Initialize: required condition is false: inputNode != nullptr || outputNode != nullptr` — an Obj-C runtime assert (not a Swift throw, so the existing `do/catch` couldn't catch it). Root cause: `engine.start()` was called on a graph that had no I/O node materialized yet (the post-token "quiet window" before the first BreathVoice attaches). Fix in `SoundEngine.start()`: touch `engine.mainMixerNode` before `engine.start()` — accessing it pulls the output node into the graph so the assert can't fire even when zero source nodes are attached. Also call `engine.prepare()` for good measure. The sim hid this because the iOS Simulator's audio backend is permissive about empty graphs; the device is not.

**Deploy-verified (pending):** the binaural dual-oscillator path itself. The iOS Simulator reports as built-in / no-headphones, so the sim runs the single-centered-tone fallback — the actual binaural beat is on-device-first, by design. Coincides with Ashrey's first hearing on Neev at deploy. Re-verify after the mainMixerNode fix: the crash signature to confirm gone is the absence of any `com.apple.coreaudio.avfaudio` exception at launch.

### Sound Layer deferred

| Item | Notes |
|---|---|
| Lock → true lock-free upgrade | `OSAllocatedUnfairLock` is Apple's recommended fast primitive; this profile (writes only on room change, reads per audio buffer) has effectively zero contention and the render thread never blocks. True lock-free via Swift Atomics SPM dep is the upgrade path if audio glitches ever appear at this layer |
| `onChange(of:perform:)` modernization | `SonicContextModifier` and `ContentCoordinator`'s scene-phase / fieldSounds observers use the deprecated single-param signature to match the existing codebase pattern (already ~10 sites in §11). One sweep modernizes all together |
| Binaural-on-headphones path | Deploy-first, not sim-verified. First hearing on Neev |
| Per-surface coloration for Mirror / Signal Space | Trivial future add (same 8 fields apply); deferred to hold the locked three-layer scope |
| Voice / Resonance ducking | `duckBreath()` stub is empty — the Sound Layer's scope is the three generated layers only |
| Bootstrap fetch order | If a future audio behavior needs Field Sounds *before* engine starts (rather than after, with fallback), tighten the sequencing. Not needed today because fallbackBreath values exactly match the seeded Breath |

---

## 16. Related docs

**Live design canon** (see the source-of-truth precedence at the top of this file):
- [`Claude Design Round 1/`](../Claude%20Design%20Round%201/) — the blessed design bundle; `The Instrument v3.html` at its centre, governed by its `docs/` (Brief + BUILD-LEDGER + Amendment-01). `comps/` = per-register source material, subordinate.
- [`canon/`](../canon/) — frozen verbatim wording / numbers / the 66 Point stars (`spine-light.js`, `spine-sound.js`, `point-content.js`).

**Retired / historical** (all under `archive/` — do NOT build from; see [`archive/README.md`](../archive/README.md)):
- `archive/bindu-feed-phase9-handoff/` — the June-2026 Phase-9 design handoff (still reads like a live spec; it is not — banner-marked). Its `soul/` skill (tone/ethic) and `AIRTABLE-DATA-TRUTH.md` (schema mirrored live in §6) remain worth reading.
- `archive/BINDU_FEED_CLAUDE_CODE.md` — the original May master spec (Phases 1–8).
- `archive/bindu-feed-phase9-audit.md` — the Phase-9 structural code audit (its punch list is folded into this doc).
- `archive/bindu-feed-snapshot.md` — pre-Phase-9 code dump.
- [`DEFERRED-AND-FIX-BUILD-PLAN.md`](../DEFERRED-AND-FIX-BUILD-PLAN.md) — the Aug-2026 punch list, partly-superseded (banner-marked); the still-open items are the Neev-walk feel-gated ones.

---

*If you see a better way, take it. Never reduce. Always emerge. Slow. Intimate. Already there.*
