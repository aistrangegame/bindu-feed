# Bindu Feed — Phase 9 Structural Audit
*Authored 2026-06-14 against branch `phase-9` (HEAD post-step-9, pre-CLAUDE.md refresh). Build: green. Audit method: full code-read + grep + live Airtable schema pull. No code changes in this pass — surface only.*

---

## 0. Punch list (TL;DR)

**Real issues — functional or correctness:**
1. `fetchStoriesByIds` and `fetchFieldCommentsByIds` have **no `Status='Live'` gate** (filters only by Type and `RECORD_ID()`). Could return Draft / Archived records. Used by AshVoiceView and TheTurningView. Likely benign today (no Draft data referenced) but a silent-blank pattern in the same shape as the four we just caught.
2. **Six orphan properties in `RecordFields`** (CodingKey + declared, zero readers anywhere): `triggerCodexEntry`, `sourceIdentity`, `sourceSeed`, `koanStatus`, `lastShown`, `typeWeight`. Legacy scaffolding from the tracking model + earlier features. Safe to remove from Swift; Airtable fields stay parked.
3. **`Story.lastDepthDate`** — written by `init(from:)`, never read. Airtable field IS written via `updateStoryLastDepthDate` on Resonance Depth dissolve, but the iOS model never surfaces it. Could be removed from the struct (PATCH still works without the model property).
4. **Two orphan `@Published` properties on FeedStore**: `currentRoomFilter` and `currentSort`. Set in `loadStories` for "remember last filter" but no one reads them. Can be removed.
5. **Two orphaned UserDefaults keys** still sitting in storage from the retired tracking model: `bindu.practice.lastShownDate`, `bindu.practice.lastShownId`. No reader, no writer in current code. Harmless but residue.

**Deferred polish (intentionally not-now):**
- Per-presence breath cadences in Players/Turning are uniform within categories; prototype gives each its own
- Mirror body 22pt vs prototype 27pt — tuned for iPhone width, judge on Neev
- No scroll-to-words animation on Turning completion
- Hub-from-hub destination duplication (tap Settings while on Settings stacks a copy)
- `onChange(of:perform:)` iOS 17 deprecation warnings (widespread, modernize later)
- `terra` property name in AshVoiceView is slightly misleading now (returns user's arrival color, not necessarily terra)
- Resonance Depth's auto-advance timings (3s/3s/4s) are hardcoded — fine
- iOS deploy target is 17.6 in `project.pbxproj`, spec/memory say 16+

**Confirmed whole:**
- Every Swift file is reachable from `@main`
- Every navigation route has at least one push site
- Every screen reachable from launch
- Every Airtable Type the app reads exists in the live schema, with options that match the code's expectations
- All 12 of 14 readers gate on `Status='Live'` (the 2 exceptions are flagged above)
- Build green; no compiler errors
- The step-2 `postAshComment` fix is in code path (but unverified on device — see §12)

**Identity / naming:**
- The Airtable archetype row is `Ash` with role "Physical Synthesis · the one who lives it" — `PlayersView` and `TheTurningView` render `archetype.name` so they show "Ash". The word "Ashram" appears only in design prose and the old SKILL.md; no code references it. **Coherent on the iOS side.**

---

## 1. File inventory

37 Swift files. All reachable from `BinduFeedApp.swift` (the `@main` entry point). Folder structure intact.

### `App/` (3)
| File | Role | Reachable |
|---|---|---|
| `BinduFeedApp.swift` | `@main` entry; wraps in `WindowGroup` with `ContentCoordinator` and `.preferredColorScheme(.dark)` | ✓ root |
| `ContentCoordinator.swift` | Token → PracticeDoor → Root state machine | ✓ |
| `Navigation.swift` | `FeedRoute` enum (11 cases) | ✓ |

### `Services/` (2)
| File | Role | Reachable |
|---|---|---|
| `AirtableService.swift` | All HTTP + threshold-sentence weighted picker | ✓ |
| `KeychainService.swift` | PAT storage | ✓ |

### `Models/` (1)
| File | Role | Reachable |
|---|---|---|
| `Models.swift` | All wire + domain types; `PracticeDoorKind`/`PracticeDoorContent` enums; `CardRegister` enum; `CommentNode` | ✓ |

### `Store/` (1)
| File | Role | Reachable |
|---|---|---|
| `FeedStore.swift` | `@MainActor ObservableObject` with 14 `@Published`; `selectPracticeDoorContent` + helpers; refresh handoff | ✓ |

### `Theme/` (2)
| File | Role | Reachable |
|---|---|---|
| `Theme.swift` | `BinduTheme` colors/spacing, `Font` extensions, `panel()` modifier | ✓ heavy use |
| `GlyphAnimation.swift` | 13-case enum + `GlyphView` | ✓ (see §8 for case-level coverage) |

### `Components/` (15)
| File | Defines | References elsewhere |
|---|---|---|
| `AshEntryRow.swift` | `AshEntryRow` + `AshPostedCard` | 1 each |
| `AshMark.swift` | `AshMark` | 1 (RootView) |
| `BinduSilenceCard.swift` | `BinduSilenceCard` | 2 (MirrorView, SignalView) |
| `CommentCard.swift` | `CommentCard` | 2 |
| `CommunityFilterBar.swift` | `CommunityFilterBar` + `FeedSortToggle` | 1 each |
| `CommunityPill.swift` | `CommunityPill` | 4 |
| `FieldGathersMarker.swift` | `FieldGathersMarker` | 1 (StoryDetailView) |
| `FieldSurfacePortalCard.swift` | `FieldSurfaceConfig` + `FieldSurfacePortalCard` | 4 / 2 |
| `HubOverlay.swift` | `HubOverlay` + `.hubOverlay` View extension | 1 / **10** |
| `HubTrigger.swift` | `HubTrigger` | **10** (every top-level + sub-flow screen except PracticeDoor) |
| `ReplyRow.swift` | `ReplyRow` | 1 (CommentCard) |
| `RoomPortalCard.swift` | `RoomPortalCard` + `FloodOverlay` + `PortalFramePreferenceKey` | 2 / 2 / 3 |
| `StaggeredReveal.swift` | `StaggeredReveal` | 4 (SignalView×2, StoryDetailView×2) |
| `StoryCard.swift` | `StoryCard` | 4 (RootView×2, GameView×1, prototype paths) |
| `VoiceAvatar.swift` | `VoiceAvatar` + `VoiceAvatarStack` | 2 / 1 |

**No orphaned component files.** Every component has at least one external caller. `HubTrigger` (10) and `.hubOverlay` (10) confirm the hub spans every screen except PracticeDoor by design.

### `Screens/` (13)
All reachable from `RootView.destination(for:)` or as the launch surface in `ContentCoordinator`:

| File | Reached as |
|---|---|
| `TokenEntryView.swift` | ContentCoordinator initial when `!store.hasToken` |
| `PracticeDoorView.swift` | (a) launch surface in ContentCoordinator (every open), (b) `.practiceDoor` route from hub |
| `RootView.swift` | ContentCoordinator after `doorCrossed = true` |
| `RoomSelectionView.swift` | `.rooms` route (hub) |
| `PlayersView.swift` | `.players` route (hub) |
| `SettingsView.swift` | `.settings` route (hub) |
| `MirrorView.swift` | `.mirror` route (Room Selection's lower tier) |
| `SignalView.swift` | `.signal` route (Room Selection's lower tier) |
| `GameView.swift` | `.room(Room)` route (Room Selection portal tap) |
| `StoryDetailView.swift` | `.story(Story)` route (story card tap in RootView/GameView/etc.) |
| `TheTurningView.swift` | `.archetype(Archetype)` route (Players card + StoryDetail avatar tap) |
| `AshVoiceView.swift` | `.ash` route (AshMark + Settings link + Turning's Ash link) |
| `AshComposeView.swift` | `.compose(Story)` route (Story Detail's "What arrived for you?" tap) |

**No orphaned screens.** Deleted in Phase 9: `LaunchView.swift`, `ArchetypeProfileView.swift`, `AshComposer.swift` — all retirement confirmed.

---

## 2. Navigation graph

Start: `BinduFeedApp` → `ContentCoordinator`.

```
ContentCoordinator
├─ (no token)  → TokenEntryView ──onSaved──→ bootstrap → PracticeDoorView
└─ (has token) → bootstrap → PracticeDoorView (every open)
                                   ↓ (tap anywhere)
                              RootView (home feed)
                                   │
       ┌───────────────────────────┼────────────────────────────────┐
       │ (HubTrigger top-left)     │ (Ash mark top-right)            │ (story card)
       ↓                            ↓                                 ↓
   HubOverlay                   .ash → AshVoiceView           .story(Story) → StoryDetailView
       │                                                              │
   ┌───┼─────┬──────────────┐                                        │
   ↓   ↓     ↓              ↓                                         ├─ tap avatar → .archetype(Archetype) → TheTurningView
.rooms .players .practiceDoor .settings                                ├─ tap "What arrived for you?" → .compose(Story) → AshComposeView
   │       │                                                          │
   ↓       ↓                                                          │
RoomSelectionView                                                     │
   │       └──→ PlayersView                                           │
   ├─ (portal tap) → .room(Room) → GameView                          │
   │                                  └─ (story card tap) → .story(Story) ┘
   ├─ (Mirror portal) → .mirror → MirrorView
   └─ (Signal portal) → .signal → SignalView

PlayersView
   └─ (any card tap) → .archetype(Archetype) → TheTurningView
                                                   │
                                                   ├─ (story link in word card) → .story(Story)
                                                   └─ (Ash card only) → "All of Ash's words" → .ash

SettingsView
   └─ "Your voice" link → .ash

AshComposeView
   ├─ Hold ember to release → POST → fade → "RETURN TO THE STORY ›" → onPosted → pop one
   └─ Back chevron → onPosted (same path)
```

**Every route has at least one push site:**
| Route | Pushed from |
|---|---|
| `.rooms` | HubOverlay |
| `.room(Room)` | RoomSelectionView (room portal tap) |
| `.story(Story)` | RootView, GameView, TheTurningView (word cards), AshVoiceView |
| `.archetype(Archetype)` | PlayersView (×3 — lenses, roots, Ash), StoryDetailView (avatar tap) |
| `.ash` | RootView (AshMark), SettingsView (voice link), TheTurningView (Ash only) |
| `.settings` | HubOverlay |
| `.mirror` | RoomSelectionView |
| `.signal` | RoomSelectionView |
| `.players` | HubOverlay |
| `.practiceDoor` | HubOverlay |
| `.compose(Story)` | StoryDetailView (Ash entry row) |

**Back-paths:**
- Every sub-screen has a `BackChevron` (top-left) that pops the path.
- `RootView` is the root — no back.
- `PracticeDoorView` (launch context) has no back (tap-anywhere-to-cross is the only gesture).
- `PracticeDoorView` (hub-launched route) — same chrome (no chevron, no hub). Crossing clears the entire path to root. **Worth knowing:** if you hub→Practice Door from a sub-screen, crossing pops you back to home feed, not to the sub-screen you came from. By spec — door = threshold = home.

**No dead ends, no orphan controls.** Hub overlay items dismiss-on-tap-outside; the routed Practice Door's "tap to cross" handles its own exit; back chevron everywhere else.

---

## 3. Airtable read ↔ Type matching (schema-grounded)

### Live schema (pulled 2026-06-14)

**`Type` singleSelect — 10 options, all present:**
| Name | Choice ID | Code references? |
|---|---|---|
| Story | `sely4gGZUloH4KEeX` | ✓ (fetchStories, fetchStoriesByIds) |
| Field Comment | `seltI2oj6xdeh098G` | ✓ (fetchFieldComments, fetchAllFieldComments, fetchArchetypeComments) |
| Ash Comment | `selgUdEAGB47eOQDg` | ✓ (fetchAshComments, fetchAllAshComments, postAshComment writes this) |
| Room | `selqsVmjeI5oHc891` | ✓ (fetchRooms) |
| Archetype | `selnJ0w96NTMozu0h` | ✓ (fetchArchetypes) |
| Threshold Sentence | `selK1wJy98fUacJS6` | ✓ (fetchThresholdSentences) |
| Resonance Voice | `sel90xRl5Vtm809ar` | ✓ (fetchResonanceVoice → fetchAllResonanceVoices) |
| Mirror Card | `selOPdnOomjXCHyJP` | ✓ (fetchMirrorCards) |
| Signal | `selpEUJq8wI5Q1xDJ` | ✓ (fetchSignals) |
| Practice Invitation | `selzvCCfVhU6Co8dm` | ✓ (fetchPracticeInvitations) |

**Every Type has a reader. No reader points at a Type that doesn't exist.**

**`Status` singleSelect** — `Draft` / `Live` (`seliWi7fUkrRrgJMu`) / `Archived`. Code only ever reads Live.

**`Archetype` singleSelect — 11 options, all populated** (Bindu, Gaia, Sid, Arch, Sakshi, Karishma, Ashrey, Lalita, Ash, Neev, Shweta). PlayersView's hardcoded canonical order is `[Bindu, Gaia, Sid, Arch, Sakshi, Karishma, Ashrey, Lalita]`; roots and Ash resolved separately. All 11 surface somewhere.

**`Card Register` singleSelect — `Vow` / `Koan`.** Code's `CardRegister` enum matches exactly. Mirror render branches on this.

**`Category` singleSelect — 8 options** (Value, Mantra, Practice, Energy State, Role, Game, Tree of Life Panel, Belief). **No code references Category** — confirmed backstage-only per data truth. Mirror cards' Category field isn't read; the Vow/Koan register on `Card Register` is what surfaces.

**`Sentence Source` singleSelect — 5 options** (Story, Field Comment, Room, Seed, Bindu). Code reads:
- `Bindu` source → identifies the Bindu dot kind in Practice Door (`hasContent(for: .binduDot)` filters by `source == "Bindu"`)
- Non-Bindu sources → treated as regular threshold sentences (`pickThreshold` filters `source != "Bindu"`)
- Other source values (`Story`, `Field Comment`, `Room`, `Seed`) are not surfaced as distinct kinds — they all roll into the threshold pool. Per data truth this is intentional (we did NOT create "Practice" or "Gaia Seed" options; we reuse `Type=Signal` for Gaia seeds).

### Reader inventory + Status gate

| AirtableService method | Filter | `Status='Live'` gate? |
|---|---|---|
| `fetchRooms` | `Type='Room'` | ✓ |
| `fetchArchetypes` | `Type='Archetype'` | ✓ |
| `fetchThresholdSentences` | `Type='Threshold Sentence'` | ✓ |
| `fetchMirrorCards` | `Type='Mirror Card'` | ✓ |
| `fetchSignals` | `Type='Signal'` | ✓ |
| `fetchPracticeInvitations` | `Type='Practice Invitation'` | ✓ |
| `fetchStories(room:sort:)` | `Type='Story'` (+ Room if set) | ✓ |
| `fetchAllFieldComments` | `Type='Field Comment'` | ✓ |
| `fetchAllAshComments` | `Type='Ash Comment'` | ✓ |
| `fetchArchetypeComments(archetypeName:)` | `Type='Field Comment'` + `Archetype=X` | ✓ |
| `fetchAllResonanceVoices` (private) | `Type='Resonance Voice'` | ✓ |
| `fetchFieldComments(storyId:)` | wraps `fetchAllFieldComments` then filters client-side | ✓ (via wrapper) |
| `fetchAshComments(storyId:)` | wraps `fetchAllAshComments` then filters client-side | ✓ (via wrapper) |
| `fetchResonanceVoice(storyId:)` | wraps `fetchAllResonanceVoices` then filters client-side | ✓ (via wrapper) |
| **`fetchStoriesByIds(_ ids:)`** | `Type='Story'` + `OR(RECORD_ID()='X',…)` | ✗ **NO gate** |
| **`fetchFieldCommentsByIds(_ ids:)`** | `OR(RECORD_ID()='X',…)` only — no Type filter either | ✗ **NO gate** |

**Two readers without Status gate.** Callers:
- `fetchStoriesByIds` ← `TheTurningView` (word cards' linked stories), `AshVoiceView` (linked-story lookup for comment rows)
- `fetchFieldCommentsByIds` ← `AshVoiceView` (parent-comment lookup for "↩ In reply to X" hint)

Practical risk today: low (no Draft Stories or Comments currently being authored that those screens would surface). Same shape as the four silent-blank bugs though — worth gating.

### Field-ID read inventory (for context)
Code reads these Airtable fields via CodingKeys:
`Name`, `Type`, `Status`, `Sort Order`, `Body`, `Excerpt`, `Room`, `Flairs`, `Codex ID`, `Source Date`, `Last Activity Date`, `Resonance`, `Comment Body`, `Archetype`, `Linked Story`, `Parent Comment`, `Trigger Codex Entry`, `Comment Order`, `Glyph`, `Hex Color`, `Blurb`, `Animation Name`, `Glyph Size`, `Operating Principle`, `Archetype Role`, `Sentence Weight`, `Last Shown`, `Sentence Source`, `Closing Line`, `Last Depth Date`, `Source Type`, `Source Identity`, `Koan Status`, `Source Seed`, `Type Weight`, `Card Register`.

36 fields total in RecordFields. Of these, **6 are declared but no Swift struct surfaces them** (orphans — see §4 punch-list).

---

## 4. Model property tracing

### `RecordFields` (the wire decoder)
All 36 fields declared. Mapped to CodingKeys with their Airtable name. Status of each:

| Field | Wire-decoded? | Surfaced by any domain struct? | Status |
|---|---|---|---|
| `name`, `type`, `status`, `sortOrder` | ✓ | ✓ (all structs) | live |
| `body` | ✓ | ✓ (Story, MirrorCard, Signal, PracticeInvitation via `commentBody ?? body`) | live |
| `excerpt` | ✓ | ✓ (Story) | live |
| `room` | ✓ | ✓ (Story) | live |
| `flairs` | ✓ | ✓ (Story) | live |
| `codexId` | ✓ | ✓ (Story) | live |
| `sourceDate` | ✓ | ✓ (Story, FieldComment) | live |
| `lastActivityDate` | ✓ | ✓ (Story) | live |
| `resonance` | ✓ | ✓ (Story, FieldComment) | live |
| `commentBody` | ✓ | ✓ (FieldComment, MirrorCard, Signal, PracticeInvitation) | live |
| `archetype` | ✓ | ✓ (FieldComment) | live |
| `linkedStory` | ✓ | ✓ (FieldComment.linkedStoryId) | live |
| `parentComment` | ✓ | ✓ (FieldComment.parentCommentId) | live |
| `triggerCodexEntry` | ✓ | ✗ | **orphan** |
| `commentOrder` | ✓ | ✓ (FieldComment) | live |
| `glyph`, `hexColor`, `blurb`, `animationName`, `glyphSize` | ✓ | ✓ (Room) | live |
| `operatingPrinciple`, `archetypeRole` | ✓ | ✓ (Archetype) | live |
| `sentenceWeight`, `sentenceSource` | ✓ | ✓ (ThresholdSentence.weight, .source) | live |
| `lastShown` | ✓ | ✗ (was in MirrorCard/Signal/PracticeInvitation; removed Phase 9) | **orphan** |
| `closingLine` | ✓ | ✓ (Story; used by Resonance Depth) | live |
| `lastDepthDate` | ✓ | ✓ written into `Story.lastDepthDate` — **but `Story.lastDepthDate` itself has no reader** (only `AirtableService.updateStoryLastDepthDate` writes the field) | **orphan reader** |
| `sourceType` | ✓ | ✓ (MirrorCard, PracticeInvitation) | live |
| `sourceIdentity` | ✓ | ✗ (was for backstage belief→Identity link) | **orphan** |
| `koanStatus` | ✓ | ✗ (was in Signal; removed Phase 9 step 5) | **orphan** |
| `sourceSeed` | ✓ | ✗ (was in Signal tracking model; removed) | **orphan** |
| `typeWeight` | ✓ | ✗ (was in PracticeInvitation; removed Phase 9 step 6) | **orphan** |
| `cardRegister` | ✓ | ✓ (MirrorCard.register) | live |

### Domain struct properties
- `Story.lastDepthDate` — written, never read. Could be dropped from struct.
- All other struct properties are read by at least one view.
- `StoryStats.commentCount` — read once in `StoryCard`. Reachable.
- `StoryStats.archetypes` — read in `StoryCard`, `RootView` (avatar lookup), `GameView` (avatar lookup). Reachable.

### `CommentNode` tree
`comment`, `children`, `depth`, `id` — all referenced by StoryDetailView's nested rendering via `CommentCard.replies` and tree walks. Live.

### `PracticeDoorKind` / `PracticeDoorContent`
Both enums + helpers (`weight`, `kind`) used by `FeedStore.selectPracticeDoorContent` and `PracticeDoorView.contentScreen(for:)`. All cases exhaustively switched in both. Live.

---

## 5. UserDefaults inventory

### Active keys (written and read)
| Key | Writer | Reader | Notes |
|---|---|---|---|
| `bindu.arrival.settings` (JSON-encoded `ArrivalSettings`) | `SettingsView.saveSettings` | `ArrivalSettings.load()` — called by SettingsView, AshComposeView, AshVoiceView, StoryDetailView | Active |
| `bindu.threshold.lastShownId` | `AirtableService.selectThresholdSentence` | Same function (excludes last-shown to prevent immediate repeat) | Active. Used by Practice Door's threshold kind via `pickThreshold` → `selectThresholdSentence` |
| `bindu.door.lastKind` | `FeedStore.commitDoorKind` | `FeedStore.selectPracticeDoorContent` | Active. Phase 9 step 3. |
| `mirror.draw.<yyyy-MM-dd>.drawn` (Bool) | `MirrorView.persist` | `MirrorView.loadIfNeeded` | Active. Per-day. |
| `mirror.draw.<yyyy-MM-dd>.idx` (Int) | `MirrorView.persist` | `MirrorView.loadIfNeeded` | Active. Per-day. |

### Orphaned keys (residue from retired tracking model)
| Key | Last writer | Last reader | Status |
|---|---|---|---|
| `bindu.practice.lastShownDate` | retired in Phase 9 step 6 (was `ContentCoordinator.todayUTC`) | retired (was `RootView.todayPractice`) | **orphan in storage** — no current code reads or writes; values from past sessions still sit there |
| `bindu.practice.lastShownId` | retired step 6 (was `FeedStore.selectPracticeInvitation`) | retired (was `RootView.todayPractice`) | **orphan in storage** |

**Recommendation:** add a one-shot migration that removes these on next launch, or leave alone (~32 bytes total, harmless).

### Not yet implemented (called out for awareness)
- No "first-ever launch" tracking. `selectPracticeDoorContent`'s "first open = threshold" rule is implemented as "no `bindu.door.lastKind` saved yet" — so a fresh install always gets threshold first. ✓ works as spec'd.

---

## 6. `@Published` audit on `FeedStore`

14 published properties:

| Property | Writers | Readers | Status |
|---|---|---|---|
| `rooms` | `loadFoundation` | 5 (RootView, RoomSelectionView, MirrorView.flood color via room lookup, GameView, StoryDetailView) | live |
| `archetypes` | `loadFoundation` | 4 (PlayersView, TheTurningView lookup, StoryDetailView avatars, FeedStore.archetype()) | live |
| `thresholdSentences` | `loadFoundation` | 3 (PracticeDoor selector, StoryDetailView Resonance Depth, FeedStore.selectThresholdSentence) | live |
| `stories` | `loadStories` | 3 (RootView, FeedStore.selectPracticeDoorContent for "story" kind, GameView indirectly) | live |
| `storyStats` | `loadStoryStats` | 1 (FeedStore.stats() which is then read by StoryCard, RootView, GameView) | live |
| `currentRoomFilter` | `loadStories` | **0** | **orphan write** |
| `currentSort` | `loadStories` | **0** | **orphan write** |
| `mirrorCards` | `loadMirrorCards` | 5 (MirrorView selection + render) | live |
| `signals` | `loadSignals` | 2 (SignalView, FeedStore.selectPracticeDoorContent for gaiaSeed kind) | live |
| `practiceInvitations` | `loadPracticeInvitations` | 1 (FeedStore.selectPracticeDoorContent for practice kind) | live |
| `isLoading` | `loadFoundation` | 1 (RootView empty-state) | live |
| `foundationLoaded` | `loadFoundation` | 8 (every screen that waits before fetching) | live |
| `error` | many | 19 (most screens, error states) | live |
| `pendingStoryRefreshes` | `flagStoryRefresh` (AshComposeView) | `consumeStoryRefresh` (StoryDetailView.onAppear) | live (Phase 9 step 9) |

**Two orphan writes** (`currentRoomFilter`, `currentSort`) — set in `loadStories` for "remember the last filter" but no UI ever reads them back. Could be plain `var` if needed at all, or removed entirely.

---

## 7. Components reachability

Already inventoried in §1. **Summary:** every Component struct is invoked by at least one Screen or another Component. No orphans. Top usage: `HubTrigger` and `.hubOverlay` (each on 10 screens — every screen except PracticeDoorView).

---

## 8. GlyphAnimation enum coverage

13 enum cases. Explicit `.caseName` references in code (excluding the enum file itself):

| Case | Explicit `.case` refs | Reachable via `init(name:)` from Airtable? |
|---|---|---|
| `glyphRotate` | 0 | ✓ — Airtable Room "A Maya Game" Animation Name="glyphRotate" |
| `glyphBreathe` | 7 (PlayersView, TheTurningView, FieldSurfacePortalCard, MirrorView atmosphere) | ✓ — "The Garden" |
| `none` | 0 | ✓ — "The Watcher" + default for unknown values |
| `glyphEmber` | 2 (PlayersView Bindu, TheTurningView Bindu) | ✓ — "The Descent" |
| `glyphOrbit` | 0 | ✓ — "The Return" |
| `glyphStutter` | 0 | ✓ — "The Forgetting" |
| `glyphDawn` | 0 | ✓ — "The Remembering" |
| `glyphBreath8` | 0 | ✓ — "The Body" |
| `glyphWeave` | 0 | ✓ — "The Thread" |
| `glyphCircle` | 2 (PlayersView Lalita, TheTurningView Lalita) | ✓ — "The Circle" |
| `glyphSignal` | 1 (FieldSurfacePortalCard Signal Space) | ✓ — "The Signal" |
| `glyphAssemble` | 0 | ✓ — "The Forge" |
| `glyphField` | 1 (PracticeDoorView pre-foundation glyph) | ✓ — "The Field" |

**All 13 cases are runtime-reachable** via `GlyphAnimation(name:)` mapping from Airtable's `Animation Name` field. The 8 cases with zero explicit refs are all bound to a specific Room — they only fire when that Room renders (in Room Selection portals and GameView heros). Not orphans, just string-driven.

`none` is also the fallback for any unrecognized animation name (defensive default in `init(name:)`).

---

## 9. Stubs, TODOs, dead branches

**Single code-comment hit across the entire codebase:**
- `AirtableService.swift:174` — multi-line comment explaining why `fetchFieldComments(storyId:)` filters client-side instead of server-side (Airtable limitation). Intentional documentation, not a TODO.

**No `TODO`, `FIXME`, `XXX`, `HACK`, `// removed`, `// deprecated` markers anywhere.** Clean.

**Half-built / partially-implemented:**
- None found. Every method that's declared has a body that runs end-to-end.

**Commented-out code:**
- None found.

The codebase is unusually clean of scaffolding residue. The Phase 9 cleanups (LaunchView delete, AshComposer delete, ArchetypeProfileView delete) all left no comment tombstones behind.

---

## 10. Intention check (surface by surface)

### TokenEntryView
Intent: collect Airtable PAT once on first launch, store to Keychain. Functional, hub-less by design (no app to hub into until token exists).
**Coherent.**

### PracticeDoorView (launch surface + hub-route)
Intent: every-open threshold; tap anywhere to cross; one of 5 weighted kinds (threshold 40 / practice 23 / gaiaSeed 20 / story 12 / binduDot 5); first-ever open = threshold; no kind repeats back-to-back.
- Selector logic ✓ (`FeedStore.selectPracticeDoorContent`)
- Render branches for all 5 kinds ✓
- Pre-foundation gathering glyph + error state ✓
- Atmosphere shifts per accent ✓
**Coherent.** Two intentional gaps: (1) `story` kind is unavailable on cold launch — stories aren't in bootstrap by design (avoids ~100-record fetch at launch); (2) Practice invitations have no `sub`-line model field, prototype's "in… and out." accepted as authored into body.

### RootView (Home Feed)
Intent: river of stories filterable by room, sortable Most Active / Most Recent. Header: hub-dots left, wordmark middle, Ash mark right.
- Header ✓ (Phase 9 step 7 rewrite landed clean; old gear/grid icons retired)
- `todayPractice` strip removed ✓
- Story cards with pull-to-refresh ✓
**Coherent.**

### RoomSelectionView
Intent: 12 portals 2-col + The Field full-width + "AND THE FIELD TURNS TO YOU" divider + 2 horizontal field-surface cards (Mirror terra ◐, Signal Space teal ⊙).
- 13 rooms render with their glyph animations ✓
- Flood transition to GameView ✓
- Divider copy correct ✓
- Field-surface tier with horizontal cards ✓
**Coherent.**

### GameView
Intent: one room at a time, floating nav with prev/next chevrons cycling all 13 rooms in Sort Order. Per-room story feed.
- Arrow nav cycles correctly ✓
- Cross-dissolve between rooms (0.28s) ✓
- Hub + Back chevron both in floating bar ✓
**Coherent.**

### StoryDetailView
Intent: story body + sequential field gathering + Ash entry. Resonance Depth ritual (1.5s hold to open) ON TOP of this.
- Story header + body ✓
- Sequential comment reveal via `StaggeredReveal` + `FieldGathersMarker` ✓
- Ash entry now navigates to AshComposeView (Phase 9 step 9) ✓
- Ash comments below field comments via `AshPostedCard` ✓
- `.onAppear` consumes refresh flag after compose return ✓
- Resonance Depth overlay: 6-phase state machine (dim → closingLine → thresholdSentence → archetypeVoice → hold → dissolve), reads `Story.closingLine` + `fetchResonanceVoice` + selects from `thresholdSentences`. Calls `markStoryDepth` on dissolve. **End-to-end intact; reads from live data now that 97 Resonance Voices are Live.**
- **Naming consistency:** posted Ash cards display `arrivalName` (Settings.name → "Ash" fallback) per the just-landed fix.
**Coherent.**

### TheTurningView (replaced ArchetypeProfileView in Phase 9 step 8)
Intent: trace-the-∞ gesture (2.9s up / 0.75s decay, 60fps), dawn light rises (saturation + colorMultiply), words resolve from dark past 55% progress, "witnessed" locks the state.
- ∞ Shape with `.trim(from: 0, to: progress)` ✓
- 60fps Task.sleep loop ✓
- Saturation + colorMultiply for dawn ramp ✓
- Bindu's `·` body renders as glowing ember (canon) ✓
- Ash-only "All of Ash's words in the field →" link ✓
**Coherent.** Deferred: scroll-to-words on completion; per-presence breath cadences.

### MirrorView
Intent: single held card per day, date-hash selection, Vow/Koan registers drive render, one Bindu Draw per day → spends to hollow ring.
- FNV-1a hash → index ✓
- Register-driven render (Vow upright + `·`; Koan italic + `◌`) ✓
- Bindu Draw alternate-index formula + UserDefaults persistence ✓
- Local-time day-key (per standing instruction) ✓
**Coherent.**

### SignalView
Intent: ceremonial single transmission per day. Arriving → received (line-by-line via sentence/em-dash split) → "— THE FIELD" → tap LEAVE → gone state.
- 3-phase state machine ✓
- Line splitter handles prose with em-dashes ✓
- One per day via date-hash ✓
- Local-time day-key ✓
**Coherent.** Slight pacing trade-off accepted (4-6 lines vs prototype's 6-7).

### PlayersView (new in Phase 9 step 7)
Intent: 8 lenses in canonical order (Bindu, Gaia, Sid, Arch, Sakshi, Karishma, Ashrey, Lalita) 2-col grid + Roots divider + 2 substrates 2-col + Ashram divider + Ash full-width card. Every card → Turning.
- Canonical lens order hardcoded ✓ (deliberate — story arc, not at mercy of Airtable Sort)
- All 11 archetypes surface (after Neev/Shweta added to Airtable) ✓
- Press feedback ✓
**Coherent.** **Naming:** Ash card displays `archetype.name` = "Ash" (correct against data; the word "Ashram" is design prose, not in the row).

### AshComposeView (new in Phase 9 step 9)
Intent: full-screen writing ritual lit by user's arrival color/glyph; hold ember to release (2.3s up / 0.62s decay 60fps); words settle as user's entry card; "The room has changed." fades in; "RETURN TO THE STORY ›" pops back.
- All states ✓
- Arrival-identity fallback corrected (Lalita violet + Bindu dot, not terra/◉) ✓
- Posts to Airtable via FeedStore.postComment (which uses the step-2 fix) ✓
- Flags `pendingStoryRefreshes` on success ✓
- Visual ceremony does not block on network ✓
**Coherent.**

### AshVoiceView
Intent: user's footprint — every Ash Comment in reverse chronological order with story + reply context.
- Loads all Ash Comments + bulk-fetches linked stories + parent comments ✓
- Renders with arrival color/glyph (per just-landed mirror fix) ✓
- displayName falls back to "Ash" ✓
**Coherent.** Property name `terra` is now slightly misleading (could be Lalita violet for default-user); accepted as known-deferred (cosmetic refactor).

### SettingsView ("HOW YOU ARRIVE")
Intent: edit name/glyph/color; live preview at top.
- All present ✓
- "Your voice" link to Ash's Voice ✓
- Persists to UserDefaults JSON ✓
**Coherent.**

### Hub overlay
Intent: "WHERE TO" sheet — 4 rows (Rooms violet, Players blue, Practice Door dawn, How You Arrive grey). Tap row to go, tap anywhere else to stay. On every screen except PracticeDoor.
- All 4 rows route correctly ✓
- Dim/blur backdrop ✓
- Tap-outside-to-dismiss ✓
- Trigger on 10 screens; PracticeDoor exempt ✓
**Coherent.** Known minor: tapping a hub row while already on that route stacks a duplicate.

---

## 11. Deferred polish — consolidated list

| Item | Surface | Why deferred |
|---|---|---|
| Per-presence breath cadences | PlayersView, TheTurningView | Prototype gives each archetype its own duration; iOS uses `glyphBreathe` for the lens-group + `glyphEmber`/`glyphCircle` for Bindu/Lalita. Costs new enum cases or a duration param; better judged on Neev |
| Mirror body 22pt vs prototype 27pt | MirrorView | iPhone width tuning; trust on-device before adjusting |
| No scroll-to-words on Turning completion | TheTurningView | Prototype scrolls to y=360; adds ScrollViewReader complexity |
| Hub-from-hub-destination duplicate | Hub overlay | Tap Settings while on Settings stacks a copy. NavigationPath opaque API. Refactor path to `[FeedRoute]` to fix cleanly |
| Per-card stagger on Turning words | TheTurningView | Prototype's stagger doesn't actually fire on `isDone` flip (cards mount once); removed dead staggering |
| `onChange(of:perform:)` iOS 17 deprecation | ~10 sites | Widespread pre-existing; modernize in one pass later |
| `terra` property name in AshVoiceView | AshVoiceView | Returns user's arrival color now, not terra. Rename = small refactor |
| Role label format (`"Need Architecture"` vs `"NEED"`) | PlayersView, TheTurningView | Display uses `archetype.role.uppercased()` so "NEED ARCHITECTURE" appears. Prototype showed shorter form. Settle by editing Airtable role text or by trimming in code |
| Resonance Depth phase timings (3s/3s/4s) | StoryDetailView | Hardcoded; could be configurable. Fine for now |
| iOS deploy target 17.6 vs spec 16+ | project.pbxproj | Will need to decide before any public release |
| Story.lastDepthDate orphan | Models.swift | Written into struct, never read. PATCH still works without it. Drop or wire to a "last witnessed" display somewhere |
| `currentRoomFilter` / `currentSort` orphan @Published | FeedStore | Set but never read. Remove |
| `bindu.practice.lastShown*` UserDefaults residue | UserDefaults | Old keys still sit in storage; ~32 bytes; no code reads them |
| 6 orphan RecordFields properties | Models.swift | `triggerCodexEntry`, `sourceIdentity`, `sourceSeed`, `koanStatus`, `lastShown`, `typeWeight`. Decoded, never surfaced. Safe to drop |
| `fetchStoriesByIds` + `fetchFieldCommentsByIds` Status gate | AirtableService | No `{Status}='Live'` filter. Same shape as the four silent-blank bugs we caught; flag for fix |

---

## 12. The one runtime truth

**Code path is correct.** End-to-end trace:
1. User holds ember in `AshComposeView` (2.3s up)
2. `release()` calls `store.postComment(storyId: story.id, body: trimmedBody, parentId: nil)`
3. `FeedStore.postComment`: resolves `archetype(named: "Ash")?.name ?? "Ash"` → `"Ash"` (the loaded Ash archetype row's name)
4. Calls `service.postAshComment(storyId:, body:, parentCommentId: nil, archetypeName: "Ash")`
5. `AirtableService.postAshComment` constructs the POST payload with `"Archetype": archetypeName` (no longer hardcoded "Ash" — Phase 9 step 2 fix)
6. POSTs to `tbl7vzODMMJUgeX0b`, validates response, then PATCHes the parent story's `Last Activity Date`

**Not verified:** that the actual HTTP write reaches Airtable from a running app. Build green doesn't prove this; the device hasn't yet exercised the path.

**Single-device check (~60 seconds, your hands):**
1. `git status` → confirm on `phase-9` branch
2. In Xcode, target Neev (USB or wireless), ⌘R
3. App opens → Practice Door (every open now, not gated)
4. Cross → Home Feed
5. Tap any story card
6. Scroll past "The field gathers" so comments load
7. Tap "What arrived for you?" → AshComposeView opens, lit by your arrival color
8. Type a short line ("test 2026-06-14" or anything)
9. Press-and-hold the ember (~2.3s) until ring fills
10. Released card appears with your color/glyph/name, then "The room has changed." fades in
11. Tap "RETURN TO THE STORY ›"
12. Story Detail re-fetches; new card should appear in the AshPostedCard section below field comments
13. **Verify via Airtable web:** open the Feed table, filter `Type='Ash Comment'` + `Status='Live'`, sort by `Created Time` desc. The new record should appear with `Archetype='Ash'`, your body text, `Linked Story` pointing at the story you posted into, and the parent story's `Last Activity Date` updated to today.

If the row appears: the step-2 fix is closed, the whole compose loop is whole, and the foundation is solid for everything Phase 10+ might do. If it doesn't: we have a concrete failure to debug, not a theoretical concern.

---

## 13. Files outside the Swift audit scope (for completeness)

- `Bindu Feed/CLAUDE.md` — repo-side source of truth, **stale** (still describes 8 screens / 6 record types / Phases 1-7). Refresh is task #10.
- `BINDU_FEED_CLAUDE_CODE.md` — original master spec, Phases 1-8. Historical; Phase 9 spec is in handoff folder.
- `bindu-feed-snapshot.md` — point-in-time code dump from 2026-06-04, pre-Phase-9. Historical reference.
- `bindu-feed-phase9-handoff/` — design handoff bundle. Will be archived after CLAUDE.md refresh.
- `bindu-feed-phase9-audit.md` — this file.
- `Tools/GenerateAppIcon.swift` — outside the target; standalone Swift script for icon generation. Not part of the audit.
- `Bindu Feed/Bindu Feed/Bindu Feed/Fonts/` — Lora + SpaceMono TTFs. Registered via PostScript names in `Theme.swift`. ✓
- `Bindu Feed/Bindu Feed/Bindu Feed/Assets.xcassets/` — `AccentColor`, `AppIcon`. ✓

---

## Reconciliation

This is the code-side map. Reconcile against the data-side inventory you're running in parallel. Three matches I'd expect:
1. Every `Type` in your data list appears in §3's table (10 reads ↔ 10 Types).
2. Every singleSelect option you have in the data (Card Register Vow/Koan, Sentence Source Bindu, etc.) is one the code recognizes.
3. The four blank-Status fixes you ran on Mirror/Signal/Practice/Resonance Voice this session are reflected in the live schema and reachable from §3's reader inventory.

Anything in your data inventory that **isn't** mentioned in §3 = either a Type the app doesn't read (intentional or not), or a drift to surface.

After reconciliation, the punch list in §0 becomes the work that lands before CLAUDE.md is written — so CLAUDE.md describes a coherent whole, not a snapshot in motion.

*Slow. Intimate. Already there.*
