# Bindu Feed — Claude Code Memory

> **Standing instruction: Never reduce. Always emerge. If you see a better way, take it.**

This file is the persistent memory for Bindu Feed. A fresh Claude Code session reading this should know what the app is, where it lives, what's already decided, and what cannot be undone.

The master spec — the source of truth for wording, screens, and phase audits — lives at:
`/Users/ashrey/Bindu Feed/BINDU_FEED_CLAUDE_CODE.md`

---

## 1. What this app is

Bindu Feed is a living consciousness feed — an iOS SwiftUI app that renders a man's Codex entries as stories and lets eight archetype voices gather in the comments around each one. There is no local data; every story, voice, room, and threshold sentence is read live from a single Airtable table. The aesthetic mantra is **Slow. Intimate. Already there.** — the app is meant to feel like a field that was already alive when you arrived, not a product you opened.

---

## 2. Current build state

- **Phases 1–7 complete** as of 2026-05-21
- **Phase 8 in progress** — Xcode signing + on-device deploy to iPhone "Neev"
- iOS 16+, iPhone-only, portrait, dark mode only

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
- `ContentCoordinator.swift` — decides Launch vs. TokenEntry vs. Root
- `Navigation.swift` — `FeedRoute` enum (rooms/room/story/archetype/ash/settings) used by `NavigationPath`

### `Services/`
- `AirtableService.swift` — single source for all network calls. Key helpers:
  - `fetch(filter:sort:)` — paginated GET (handles `offset` token)
  - `fetchStoriesByIds([String])` and `fetchFieldCommentsByIds([String])` — bulk RECORD_ID() lookups used by Archetype Profile and Ash's Voice
- `KeychainService.swift` — stores the Airtable Personal Access Token

### `Models/`
- `Models.swift` — all wire types + domain models + `CommentNode` tree. Single `CodingKeys` enum maps every Airtable field name to its Swift property (see §4).

### `Store/`
- `FeedStore.swift` — `@MainActor` `ObservableObject`. Owns rooms, archetypes, stories, comments cache.

### `Theme/`
- `Theme.swift` — `BinduTheme` enum + `Color` and `Font` extensions. Lora and Space Mono are registered by PostScript name — do not silently fall back to `.system`.
- `GlyphAnimation.swift` — `GlyphView` + all 13 room animations.

### `Components/`
- `StoryCard`, `CommunityPill`, `CommunityFilterBar`, `CommentCard`, `ReplyRow`, `AshComposer`, `AshEntryRow`, `BinduSilenceCard`, `FieldGathersMarker`, `RoomPortalCard`, `VoiceAvatar`

### `Screens/` (one file per screen)
- `LaunchView` — Threshold Sentence
- `RootView` — owns the `NavigationPath`
- `GameView` — Home Feed / single-room feed
- `RoomSelectionView` — 13 living portals; also defines the shared `BackChevron`
- `StoryDetailView` — immersive read + the field gathering
- `ArchetypeProfileView` — voice identity + Hold-to-Witness
- `AshVoiceView` — physical user's comment history
- `SettingsView` — "HOW YOU ARRIVE"
- `TokenEntryView` — first-run Airtable PAT entry

Every screen takes `@Binding var path: NavigationPath` and uses cross-dissolve transitions — **never slides**.

---

## 4. Airtable connection

```
Base ID:    app248ZTWhYJlvQj2
Table ID:   tbl7vzODMMJUgeX0b
Table Name: The Feed
API root:   https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b
Auth:       Bearer <PAT>, stored in Keychain via KeychainService
Page size:  100 records max; follow `offset` token for pagination
```

### The Feed table — purpose

One table holds everything. The `Type` singleSelect discriminates the row.

### Nine record types (the `Type` field)

1. **Story** — a Codex entry rendered as a narrative
2. **Field Comment** — an archetype voice commenting on a Story
3. **Ash Comment** — the physical user (Ash) commenting on a Story
4. **Room** — one of 13 portals
5. **Archetype** — one of the 8 field voices + Ash
6. **Threshold Sentence** — single sentence shown at launch
7. **Codex Entry** — raw source (pre-Story)
8. **Seed** — generative prompt / sentence source
9. **Bindu** — the dot; weight-1 sentence atoms

(The `Status` singleSelect — Draft | Live | Archived — gates every fetch with `{Status}='Live'`.)

### Field name → CodingKey mapping (Models.swift)

| Airtable field        | Swift property        |
|-----------------------|-----------------------|
| `Name`                | `name`                |
| `Type`                | `type`                |
| `Status`              | `status`              |
| `Sort Order`          | `sortOrder`           |
| `Body`                | `body`                |
| `Excerpt`             | `excerpt`             |
| `Room`                | `room`                |
| `Flairs`              | `flairs`              |
| `Codex ID`            | `codexId`             |
| `Source Date`         | `sourceDate`          |
| `Last Activity Date`  | `lastActivityDate`    |
| `Resonance`           | `resonance`           |
| `Comment Body`        | `commentBody`         |
| `Archetype`           | `archetype`           |
| `Linked Story`        | `linkedStory`         |
| `Parent Comment`      | `parentComment`       |
| `Trigger Codex Entry` | `triggerCodexEntry`   |
| `Comment Order`       | `commentOrder`        |
| `Glyph`               | `glyph`               |
| `Hex Color`           | `hexColor`            |
| `Blurb`               | `blurb`               |
| `Animation Name`      | `animationName`       |
| `Glyph Size`          | `glyphSize`           |
| `Operating Principle` | `operatingPrinciple`  |
| `Archetype Role`      | `archetypeRole`       |
| `Sentence Weight`     | `sentenceWeight`      |
| `Last Shown`          | `lastShown`           |
| `Sentence Source`     | `sentenceSource`      |

---

## 5. Key design decisions — do not undo

These are already settled. A new session that "improves" them will break what makes the app the app.

- **Bulk comment fetch.** Archetype Profile and Ash's Voice fetch comments by `Archetype` filter, collect every distinct `Linked Story` ID, then bulk-fetch those stories with `fetchStoriesByIds`. Do not regress to N+1 per-comment lookups.
- **Flood transition anchor.** The Story Detail "field gathers" reveal is anchored to a specific scroll offset and staggered one-by-one. The anchor and stagger order are load-bearing — they aren't decorative timing.
- **Hold-to-Witness at 60fps.** The Archetype Profile hold gesture runs on a `CADisplayLink`-paced loop, not a SwiftUI animation. Don't replace it with `withAnimation` — the haptic + opacity arc has to be frame-locked.
- **Cross-dissolve transitions everywhere.** Game View room switches are 0.28s dissolves. No `NavigationLink` push slides anywhere in the app.
- **Archetype color comes from Airtable `Hex Color`, not constants.** Theme has fallbacks, but views must read the live field so a color tweak in Airtable propagates without a rebuild.
- **All cross-references in `Models.swift`'s single `CodingKeys` enum.** Adding a new Airtable field means adding a new case here; don't fragment into per-type coding keys.
- **No local persistence.** No Core Data, no SwiftData, no on-disk cache beyond the in-memory `FeedStore`. The Airtable is the spine.
- **Exact wording is load-bearing.** See §6.

---

## 6. Design language — Slow. Intimate. Already there.

Three words, and each one shows up in code as constraints, not vibes.

### Slow → motion
- Every screen transition is a **cross-dissolve**, not a slide.
- Comment reveals **stagger one-by-one** in Phase 5.
- Glyph animations live in the `GlyphAnimation` enum (`Theme/GlyphAnimation.swift`); each of the 13 rooms is mapped to one. Cycles run 3–26s — built to be ignored, not noticed.
- Room cross-dissolves in Game View = **0.28s**.

### Intimate → typography & palette
- **Lora** (serif) — every reading text. Registered by PostScript name on `Font` extension in `Theme.swift`. Fallback is `Georgia`, not `.system`.
- **Space Mono** — metadata, labels, codex IDs, uppercase tags.
- Background **`#0E0C12`** (near-black warm). Card `#171420`. Comment well `#121018`. Hairline = `Color.white.opacity(0.06)`.
- Ink: `#EDE8E3` at 100/60/35% for primary/secondary/tertiary.
- Archetype colors are read from the Airtable `Hex Color` field on the Archetype row, not hard-coded into views.

### Already there → wording (do not paraphrase)
- Settings screen label: **"HOW YOU ARRIVE"** (Space Mono, uppercase). Not "Settings", not "Profile".
- Ash entry prompt in Story Detail: **"What arrived for you?"**
- Post-Ash-comment confirmation: **"The room has changed."**
- Room Selection header tagline: **"Each one already alive when you arrive."**
- Field threshold marker: **"The field gathers"** in italic Lora.

### Room name styles (also exact)
- "The Watcher" → uppercase, letter-tracked
- "The Descent" / "The Return" / "The Field" → italic Lora

When adding or renaming UI elements, check the master spec for canonical wording before inventing your own.

---

## 7. What comes next

- **117 Maya entries to process.** Raw Codex entries waiting to be transformed into Story rows in The Feed. Pipeline still being defined — likely Make.com → Airtable.
- **Make.com pipeline for new Codex entries.** Automation that watches the Codex source, drafts a Story body + excerpt, and creates the Linked Story / triggers the first Field Comments. Not yet wired.
- **Backward ripple mechanic.** When a new Codex entry lands, the field re-reads adjacent older Stories — past rooms quietly update their `Last Activity Date` and may receive a new Field Comment from an archetype who "remembered" something. Design exists; not yet implemented.
- **Phase 8 finish.** Code signing identity + provisioning profile for iPhone "Neev", then first on-device install.

---

*If you see a better way, take it. Never reduce. Always emerge.*
