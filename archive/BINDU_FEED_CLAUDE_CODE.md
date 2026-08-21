# BINDU FEED — Claude Code Master Build Document

**App name:** Bindu Feed  
**Platform:** iOS 16+, iPhone only, portrait only, dark mode only  
**Architecture:** SwiftUI + MVVM + Airtable REST API  
**Purpose:** A living consciousness feed. A man's Codex entries transformed into stories. Eight field voices gathering in the comments. The field reads the Codex back.

---

## MASTER CONTEXT BLOCK
*Paste this block at the top of every new Claude Code session to orient a fresh terminal.*

```
You are building Bindu Feed — an iOS SwiftUI app that reads entirely from
Airtable. There is no local data. Every screen, every story, every archetype
voice, every room is fetched live from a single Airtable table called
"The Feed" in the ASG base.

The app has eight screens:
  1. Launch (Threshold Sentence) — one sentence arrives before everything else
  2. Home Feed — the river of stories, filterable by Room
  3. Room Selection — thirteen living portals, each animated
  4. Game View — one room's story feed with its own character
  5. Story Detail — the immersive reading + the field gathering
  6. Archetype Profile — a voice's identity + hold-to-witness their words
  7. Ash's Voice — the physical user's comment history
  8. Settings (How You Arrive) — name, glyph, color

Design language: Slow. Intimate. Already there.
- Lora serif for all reading text
- Space Mono for metadata, labels, identifiers
- Near-black warm background (#0E0C12)
- Dissolve transitions — nothing slides
- Dark mode only. No light mode.
- Never reduce. Always emerge. If you see a better way, take it.
```

---

## AIRTABLE SPECIFICATION
*Reference this in every phase that touches data.*

```
Base ID:   app248ZTWhYJlvQj2
Table ID:  tbl7vzODMMJUgeX0b
Table Name: The Feed
API Base:  https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b
Auth:      Bearer [AIRTABLE_PERSONAL_ACCESS_TOKEN] — stored in Keychain
Max per request: 100 records
Pagination: use offset parameter when response includes "offset" key
```

**Field names (as they appear in API responses):**
```
Name                  → primary field, string
Type                  → singleSelect: Story | Field Comment | Ash Comment |
                         Room | Archetype | Threshold Sentence
Status                → singleSelect: Draft | Live | Archived
Sort Order            → number (integer)
Body                  → long text (story narrative)
Excerpt               → long text (2-line feed preview)
Room                  → singleSelect (one of 13 room names)
Flairs                → multipleSelects (array of strings)
Codex ID              → string (e.g. "C-1052")
Source Date           → date string "YYYY-MM-DD"
Last Activity Date    → date string "YYYY-MM-DD"
Resonance             → number (integer)
Comment Body          → long text (archetype or Ash comment text)
Archetype             → singleSelect: Bindu|Gaia|Sid|Arch|Sakshi|
                         Karishma|Ashrey|Lalita|Ash
Linked Story          → array of record IDs ["recXXX"] (linked field)
Parent Comment        → array of record IDs ["recXXX"] (self-link, nil = top-level)
Trigger Codex Entry   → array of record IDs ["recXXX"]
Comment Order         → number (integer, sequence within story)
Glyph                 → string (Unicode character)
Hex Color             → string (e.g. "#9B6BD6")
Blurb                 → long text (room soul sentence)
Animation Name        → string (animation identifier)
Glyph Size            → number (integer, display size)
Operating Principle   → long text (archetype's core principle)
Archetype Role        → string (e.g. "Witness Architecture")
Sentence Weight       → number (1–5, Bindu dot = 1)
Last Shown            → date string (for repeat prevention)
Sentence Source       → singleSelect: Story|Field Comment|Room|Seed|Bindu
```

**Common API filter patterns:**
```swift
// Rooms
"AND({Type}='Room',{Status}='Live')"
// sort: Sort Order asc

// Archetypes
"AND({Type}='Archetype',{Status}='Live')"
// sort: Sort Order asc

// Threshold Sentences
"AND({Type}='Threshold Sentence',{Status}='Live')"

// Stories (home feed)
"AND({Type}='Story',{Status}='Live')"
// sort: Last Activity Date desc (MOST ACTIVE) or Source Date desc (MOST RECENT)

// Stories by Room
"AND({Type}='Story',{Status}='Live',{Room}='\(roomName)')"

// Field Comments for a story
"AND({Type}='Field Comment',{Status}='Live',FIND('\(storyRecordId)',ARRAYJOIN({Linked Story})))"
// sort: Comment Order asc

// Ash Comments for a story
"AND({Type}='Ash Comment',{Status}='Live',FIND('\(storyRecordId)',ARRAYJOIN({Linked Story})))"
// sort: Comment Order asc

// All comments by archetype (for Archetype Profile)
"AND({Type}='Field Comment',{Status}='Live',{Archetype}='\(archetypeName)')"
// sort: Source Date desc — read from Linked Story's Source Date... 
// simplification: sort by Comment Order desc or just fetch all and sort client-side
```

---

## DESIGN TOKENS

```swift
// Surfaces
let bgDeep    = Color(hex: "#0E0C12")   // app background
let bgCard    = Color(hex: "#171420")   // story cards
let bgInset   = Color(hex: "#121018")   // comment wells
let hairline  = Color.white.opacity(0.06)

// Ink
let inkPrimary  = Color(hex: "#EDE8E3") // body text
let inkSecondary = Color(hex: "#EDE8E3").opacity(0.60)
let inkTertiary  = Color(hex: "#EDE8E3").opacity(0.35)

// Archetype colors (also stored in Airtable Hex Color field)
let colorBindu    = Color(hex: "#E5533C")
let colorGaia     = Color(hex: "#4A9E6B")
let colorSid      = Color(hex: "#C4923A")
let colorArch     = Color(hex: "#D4607A")
let colorSakshi   = Color(hex: "#7B82D4")
let colorKarishma = Color(hex: "#D4AE4A")
let colorAshrey   = Color(hex: "#3AADA8")
let colorLalita   = Color(hex: "#9B6BD6")
let colorAsh      = Color(hex: "#C47A52")   // physical Ashrey

// App accent
let accentApp = Color(hex: "#9B6BD6")   // Lalita violet

// Typography
// Primary reading: Lora (Google Font — embed via .ttf or use system serif fallback)
// Metadata/labels: Space Mono (monospaced)
// If Lora unavailable: "Georgia" is the fallback

// Spacing rhythm
let space4:  CGFloat = 4
let space8:  CGFloat = 8
let space12: CGFloat = 12
let space16: CGFloat = 16
let space20: CGFloat = 20
let space24: CGFloat = 24
```

---

## GLYPH ANIMATION SPEC
*Map the Airtable `Animation Name` field to SwiftUI animations.*

```swift
// Each room card in Room Selection has a living glyph.
// These are the SwiftUI equivalents of the CSS animations from Design.

enum GlyphAnimation {
    // A Maya Game — slow 26s rotation
    case glyphRotate   // .rotationEffect repeating, 26s linear
    
    // The Garden — breathing opacity
    case glyphBreathe  // opacity 0.65 ↔ 1.0, 4.5s ease-in-out, repeat
    
    // The Watcher — completely still
    case none          // no animation at all
    
    // The Descent — ember pulse
    case glyphEmber    // opacity pulse 0.4 ↔ 1.0, 2.8s ease-in-out, repeat
    
    // The Return — gentle orbit (scale + subtle rotation)
    case glyphOrbit    // scale 0.9 ↔ 1.05 + slight rotation, 7s, repeat
    
    // The Forgetting — stutter rotation (normal rotation with occasional pause)
    case glyphStutter  // rotation with random micro-pauses, ~20s full cycle
    
    // The Remembering — dawn brightening
    case glyphDawn     // opacity 0.35 → 1.0 → 0.35, very slow, 9s, ease-in-out
    
    // The Body — biological breathing (8s per breath)
    case glyphBreath8  // scale 0.92 ↔ 1.08, 8s ease-in-out, repeat
    
    // The Thread — weaving oscillation
    case glyphWeave    // horizontal offset -4 ↔ +4, 3.5s ease-in-out, repeat
    
    // The Circle — very slow rotation (42s, nearly imperceptible)
    case glyphCircle   // rotation 42s linear, repeat forever
    
    // The Signal — mostly still, occasional burst
    case glyphSignal   // opacity 0.4 (resting) → 1.0 burst → back, ~7s, irregular
    
    // The Forge — assembling (opacity building)
    case glyphAssemble // opacity 0.2 → 1.0 → hold → dissolve, 5.5s, repeat
    
    // The Field — Möbius-like (rotation through itself)
    case glyphField    // continuous rotation 10s linear, scale slight pulse overlay
}

// Implementation note: use @State var animationPhase + onAppear to trigger.
// For glyphStutter: use a timer that occasionally pauses the rotation.
// For glyphSignal: use a combination of a low base opacity + 
//   random timer-triggered burst animation.
// Claude Code: if you find a more elegant SwiftUI approach, use it.
```

---

## NAVIGATION MODEL

```
LaunchView (threshold sentence)
    ↓ auto-dissolve after 4–5 seconds (or tap anywhere)
RootView (home feed + tab-less navigation hub)
    ├── RoomSelectionView (from "Rooms" button or gesture)
    │       ↓ tap portal
    │   GameView (one room, arrow prev/next between rooms)
    │       ↓ tap story card
    │   StoryDetailView
    │       ↓ tap archetype avatar
    │   ArchetypeProfileView
    │
    ├── StoryDetailView (tap story card in home feed)
    │       ↓ tap archetype avatar
    │   ArchetypeProfileView
    │
    ├── AshVoiceView (tap Ash avatar or navigate from profile)
    │
    └── SettingsView (accessible from home feed header icon)

Navigation style: NavigationStack with value-based routing
Transitions: cross-dissolve on all screen changes (not slide)
No tab bar. No bottom navigation bar.
Back navigation: always a ‹ chevron, top-left, circular frosted button.
```

---

## THE THIRTEEN ROOMS
*Reference for Game View navigation and Room Selection.*

```
Order | Name               | Glyph | Hex       | Animation
------+--------------------+-------+-----------+---------------
  1   | A Maya Game        |   ◈   | #D4AE4A   | glyphRotate
  2   | The Garden         |   ◆   | #4A9E6B   | glyphBreathe
  3   | The Watcher        |   ◇   | #7B82D4   | none
  4   | The Descent        |   ·   | #E5533C   | glyphEmber
  5   | The Return         |   ✦   | #9B6BD6   | glyphOrbit
  6   | The Forgetting     |   ○   | #C4A882   | glyphStutter
  7   | The Remembering    |   △   | #8AB5A0   | glyphDawn
  8   | The Body           |   ⬡   | #C45A50   | glyphBreath8
  9   | The Thread         |   ⊕   | #C4923A   | glyphWeave
 10   | The Circle         |   ◎   | #D4607A   | glyphCircle
 11   | The Signal         |   ✧   | #3AADA8   | glyphSignal
 12   | The Forge          |   ▲   | #D4AE4A   | glyphAssemble
 13   | The Field          |   ∞   | #9B6BD6   | glyphField

Special name styles:
  The Watcher → uppercase, letter-spaced (UPPERCASE TRACKED)
  The Descent → italic
  The Return → italic
  The Field → italic
```

---

## THE EIGHT ARCHETYPES
*Reference for avatars, colors, roles.*

```
Archetype | Glyph | Hex     | Role
----------+-------+---------+-------------------
Bindu     |   ·   | #E5533C | Zeroth · the point
Gaia      |   ◆   | #4A9E6B | Need Architecture
Sid       |   △   | #C4923A | Hold Architecture
Arch      |   ◯   | #D4607A | Voice Architecture
Sakshi    |   ◇   | #7B82D4 | Witness Architecture
Karishma  |   ✦   | #D4AE4A | Grace Architecture
Ashrey    |   ⬡   | #3AADA8 | Synthesis Architecture
Lalita    |   ∞   | #9B6BD6 | Meta · the play, awake
Ash       |   ◉   | #C47A52 | Physical Synthesis (the user)
```

---

## APP ICON SPEC
*The golden Bindu dot with matrix code.*

```
Background: #0E0C12 (near-black)

Matrix layer (behind the dot):
  - Falling Unicode glyphs from the 13 rooms:
    ◈ ◆ ◇ · ✦ ○ △ ⬡ ⊕ ◎ ✧ ▲ ∞
  - Color: warm amber-gold at very low opacity (~8–12%)
  - Multiple columns, random speeds, endless fall
  - This is a still PNG for the icon — use a single 
    captured frame of the animation, or render it 
    procedurally and export as PNG at required sizes

The Bindu dot:
  - Large centered ·  (or a filled circle)
  - Color: warm gold #D4A853
  - Soft glow: radial gradient from #D4A853 at center 
    fading to transparent
  - No border. No shadow. Just the glow.

Sizes required by Xcode:
  - 1024×1024 (App Store)
  - 60×60 @2x, @3x
  - 20×20 @2x, @3x
  - 29×29 @2x, @3x
  - 40×40 @2x, @3x
  - 76×76 @2x (iPad, if needed)

Generate using a Swift script or SwiftUI Canvas export.
The icon should feel: alive, warm, minimal, mysterious.
```

---

---

# PHASE 1 — Foundation
*Fresh terminal. Start here. Creates the project structure and all foundational files.*

---

## Phase 1 Context
```
Building Bindu Feed — Phase 1: Foundation.
Goal: Create the Xcode project structure, folder organization, 
design tokens, color helpers, font setup, and Keychain wrapper.
No screens yet. No network calls yet. Just the bones.
```

## Phase 1 Instructions

**1.1 Create the Xcode project**
```bash
# In your terminal, navigate to your projects directory, then:
# Open Xcode → File → New → Project
# iOS → App
# Product Name: BinduFeed
# Bundle ID: com.ashrey.bindufeed
# Interface: SwiftUI
# Language: Swift
# Minimum deployment: iOS 16.0
# NO CoreData, NO tests for now
```

**1.2 Project folder structure**
Create these groups inside the BinduFeed target:
```
BinduFeed/
├── App/
│   └── BinduFeedApp.swift
├── Services/
│   ├── AirtableService.swift
│   └── KeychainService.swift
├── Models/
│   └── Models.swift
├── Store/
│   └── FeedStore.swift
├── Theme/
│   ├── Theme.swift
│   └── GlyphAnimation.swift
├── Components/
│   ├── ArchetypeAvatar.swift
│   ├── StoryCard.swift
│   ├── CommentRow.swift
│   ├── CommunityPill.swift
│   └── ResonanceLabel.swift
├── Screens/
│   ├── LaunchView.swift
│   ├── RootView.swift
│   ├── RoomSelectionView.swift
│   ├── GameView.swift
│   ├── StoryDetailView.swift
│   ├── ArchetypeProfileView.swift
│   ├── AshVoiceView.swift
│   └── SettingsView.swift
└── Assets.xcassets/
    ├── AppIcon.appiconset/
    └── Colors/ (optional — use programmatic colors)
```

**1.3 Write Theme.swift**

Include:
- All color definitions (hex → Color extension)
- Typography helpers (custom font application)
- Spacing constants
- `panel()` ViewModifier for card backgrounds with hairline border
- The `Color(hex:)` initializer

**1.4 Write GlyphAnimation.swift**

Include:
- The `GlyphAnimation` enum (all 13 cases from spec above)
- A `GlyphView` component: takes a glyph String, size, color, animation name, and renders the glyph with the correct SwiftUI animation applied
- Implement all 13 animation behaviors using SwiftUI's animation system
- For `glyphStutter`: use a `Timer` or `Task` with `sleep` to create the pause effect
- For `glyphSignal`: use an irregular timer-driven opacity burst
- The Watcher (`none`): literally no animation modifier applied

**1.5 Write KeychainService.swift**

Simple wrapper:
```swift
// Store: KeychainService.save("airtable_token", value: token)
// Read:  KeychainService.load("airtable_token") → String?
```
Standard Keychain API. No third-party dependencies.

**1.6 Write BinduFeedApp.swift**

```swift
@main
struct BinduFeedApp: App {
    @StateObject private var store = FeedStore()
    
    var body: some Scene {
        WindowGroup {
            ContentCoordinator()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
```

`ContentCoordinator` will handle the launch → home transition. Build it as a placeholder now.

**1.7 Font setup**

Download Lora and Space Mono from Google Fonts.
Add the .ttf files to the project and register them in Info.plist under `UIAppFonts`.
Create font helpers:
```swift
extension Font {
    static func lora(_ size: CGFloat, weight: Font.Weight = .regular) -> Font
    static func loraItalic(_ size: CGFloat) -> Font
    static func spaceMono(_ size: CGFloat) -> Font
}
```
If custom fonts fail in testing, fallback to `.system(.body, design: .serif)` — but try the custom fonts first.

**Phase 1 Audit Check:**
- [ ] Project builds with no errors
- [ ] All folders created
- [ ] Theme.swift compiles with all colors and modifiers
- [ ] GlyphAnimation.swift compiles with all 13 animations
- [ ] KeychainService reads and writes without crashing
- [ ] Fonts load (test with a simple Text view)

---

---

# PHASE 2 — Data Layer
*Fresh terminal. Phase 1 must be complete. Creates all models, the Airtable service, and the FeedStore.*

---

## Phase 2 Context
```
Building Bindu Feed — Phase 2: Data Layer.
The app reads entirely from one Airtable table (The Feed).
This phase builds the network layer, data models, and store.
No UI yet — but by end of this phase, we can fetch real data.

Airtable Base:   app248ZTWhYJlvQj2
Airtable Table:  tbl7vzODMMJUgeX0b (The Feed)
API Base URL:    https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b
```

## Phase 2 Instructions

**2.1 Write Models.swift**

Define these structs:

```swift
// Airtable API response wrapper
struct AirtableResponse: Codable {
    let records: [AirtableRecord]
    let offset: String?
}

struct AirtableRecord: Codable, Identifiable {
    let id: String           // Airtable record ID (e.g. "recXXX")
    let createdTime: String
    let fields: RecordFields
}

// All fields from The Feed table
struct RecordFields: Codable {
    // Core
    var name: String?
    var type: String?         // "Story", "Room", "Archetype", etc.
    var status: String?
    var sortOrder: Int?
    
    // Story
    var body: String?
    var excerpt: String?
    var room: String?
    var flairs: [String]?
    var codexId: String?
    var sourceDate: String?
    var lastActivityDate: String?
    var resonance: Int?
    
    // Comments
    var commentBody: String?
    var archetype: String?
    var linkedStory: [String]?       // record ID array
    var parentComment: [String]?     // record ID array
    var triggerCodexEntry: [String]?
    var commentOrder: Int?
    
    // Rooms & Archetypes
    var glyph: String?
    var hexColor: String?
    var blurb: String?
    var animationName: String?
    var glyphSize: Int?
    var operatingPrinciple: String?
    var archetypeRole: String?
    
    // Threshold Sentences
    var sentenceWeight: Int?
    var lastShown: String?
    var sentenceSource: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case type = "Type"
        case status = "Status"
        case sortOrder = "Sort Order"
        case body = "Body"
        case excerpt = "Excerpt"
        case room = "Room"
        case flairs = "Flairs"
        case codexId = "Codex ID"
        case sourceDate = "Source Date"
        case lastActivityDate = "Last Activity Date"
        case resonance = "Resonance"
        case commentBody = "Comment Body"
        case archetype = "Archetype"
        case linkedStory = "Linked Story"
        case parentComment = "Parent Comment"
        case triggerCodexEntry = "Trigger Codex Entry"
        case commentOrder = "Comment Order"
        case glyph = "Glyph"
        case hexColor = "Hex Color"
        case blurb = "Blurb"
        case animationName = "Animation Name"
        case glyphSize = "Glyph Size"
        case operatingPrinciple = "Operating Principle"
        case archetypeRole = "Archetype Role"
        case sentenceWeight = "Sentence Weight"
        case lastShown = "Last Shown"
        case sentenceSource = "Sentence Source"
    }
}
```

Also define convenient typed models that map from `AirtableRecord`:

```swift
struct Story: Identifiable {
    let id: String
    let title: String
    let body: String
    let excerpt: String
    let room: String
    let flairs: [String]
    let codexId: String
    let sourceDate: String
    let lastActivityDate: String
    let resonance: Int
    
    init(from record: AirtableRecord) { ... }
}

struct FieldComment: Identifiable {
    let id: String
    let body: String
    let archetype: String
    let linkedStoryId: String?  // first element of linkedStory array
    let parentCommentId: String? // first element of parentComment array
    let commentOrder: Int
    let resonance: Int
    
    var isBinduSilence: Bool { body.trimmingCharacters(in: .whitespaces) == "·" }
    
    init(from record: AirtableRecord) { ... }
}

struct Room: Identifiable {
    let id: String
    let name: String
    let glyph: String
    let hexColor: String
    let blurb: String
    let animationName: String
    let glyphSize: CGFloat
    let sortOrder: Int
    
    var color: Color { Color(hex: hexColor) }
    
    init(from record: AirtableRecord) { ... }
}

struct Archetype: Identifiable {
    let id: String
    let name: String
    let glyph: String
    let hexColor: String
    let role: String
    let principle: String
    let sortOrder: Int
    
    var color: Color { Color(hex: hexColor) }
    
    init(from record: AirtableRecord) { ... }
}

struct ThresholdSentence: Identifiable {
    let id: String
    let text: String
    let weight: Int
    let source: String
    
    var isBinduDot: Bool { text.trimmingCharacters(in: .whitespaces) == "·" }
}
```

**2.2 Write AirtableService.swift**

```swift
final class AirtableService {
    static let shared = AirtableService()
    
    private let baseURL = "https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b"
    private var token: String { KeychainService.load("airtable_token") ?? "" }
    
    // MARK: — Core fetch (handles pagination)
    func fetch(filter: String, sort: [(field: String, direction: String)] = []) async throws -> [AirtableRecord]
    
    // MARK: — Typed fetches
    func fetchRooms() async throws -> [Room]
    func fetchArchetypes() async throws -> [Archetype]
    func fetchThresholdSentences() async throws -> [ThresholdSentence]
    func fetchStories(room: String? = nil, sort: StorySort = .mostActive) async throws -> [Story]
    func fetchFieldComments(storyId: String) async throws -> [FieldComment]
    func fetchAshComments(storyId: String) async throws -> [FieldComment]
    func fetchAllAshComments() async throws -> [FieldComment]
    func fetchArchetypeComments(archetypeName: String) async throws -> [FieldComment]
    
    // MARK: — Writes
    func postAshComment(storyId: String, body: String, parentCommentId: String?) async throws -> AirtableRecord
    func updateResonance(recordId: String, newResonance: Int) async throws
    
    // MARK: — Threshold sentence selection
    // Weighted random selection. Bindu dot (weight 1) appears ~1 in 25 times.
    // Tracks last shown to prevent consecutive repeats.
    func selectThresholdSentence(from sentences: [ThresholdSentence]) -> ThresholdSentence
}

enum StorySort { case mostActive, mostRecent }
```

Implement `fetch` with proper URL encoding of the filterByFormula parameter.
Handle pagination by recursively fetching with the offset parameter until no more offset is returned.
For writes, POST/PATCH to the same base URL with JSON body.

**2.3 Write FeedStore.swift**

```swift
@MainActor
final class FeedStore: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var archetypes: [Archetype] = []
    @Published var thresholdSentences: [ThresholdSentence] = []
    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var error: Error? = nil
    
    // Token management
    var hasToken: Bool { KeychainService.load("airtable_token") != nil }
    func saveToken(_ token: String) { KeychainService.save("airtable_token", value: token) }
    
    // Load all foundational data on app start
    func loadFoundation() async
    
    // Stories
    func loadStories(room: String? = nil, sort: StorySort = .mostActive) async
    
    // Comments
    func loadComments(for storyId: String) async -> (field: [FieldComment], ash: [FieldComment])
    
    // Threaded comment tree builder
    func buildCommentTree(_ comments: [FieldComment]) -> [CommentNode]
    
    // Archetype lookup
    func archetype(named: String) -> Archetype?
    func room(named: String) -> Room?
    
    // Ash comment post
    func postComment(storyId: String, body: String, parentId: String?) async throws
    
    // Resonance
    func incrementResonance(recordId: String, current: Int) async
}

struct CommentNode: Identifiable {
    let comment: FieldComment
    var children: [CommentNode]
    var depth: Int
    var id: String { comment.id }
}
```

**2.4 Token setup view**

If `hasToken` is false on launch, show a simple token entry screen:
- Dark background, centered
- "Enter your Airtable Personal Access Token"
- A secure text field
- A "Begin" button in Lalita violet
- On submit, save to Keychain and proceed to launch

**Phase 2 Audit Check:**
- [ ] All models decode from real Airtable JSON without crashing
- [ ] `fetch()` handles pagination correctly
- [ ] `fetchRooms()` returns 13 rooms
- [ ] `fetchThresholdSentences()` returns 41 sentences
- [ ] `fetchStories()` returns 6 stories
- [ ] `fetchFieldComments()` returns correct comments for a story ID
- [ ] Comment tree builder correctly nests replies under parents
- [ ] `postAshComment` succeeds and new record appears in Airtable
- [ ] Token save/load works via Keychain

---

---

# PHASE 3 — Launch Experience
*Fresh terminal. Phases 1–2 must be complete.*

---

## Phase 3 Context
```
Building Bindu Feed — Phase 3: Launch Experience.
The threshold sentence screen. One sentence arrives before everything else.
Dark. Centered. Lora serif. Then it dissolves and the feed is already there.
Special case: the Bindu dot (·) renders as a large glowing amber presence, not text.
```

## Phase 3 Instructions

**3.1 Write LaunchView.swift**

Behavior:
1. App opens → dark screen
2. After 0.8 seconds → sentence dissolves in (opacity 0 → 1, 1.2s ease-out)
3. Sentence holds for 3.5 seconds
4. Sentence fades out (1.0s ease-in) while Home Feed dissolves up underneath
5. Total launch sequence: ~5.5 seconds
6. Tap anywhere to advance early (no skip button — just tap the screen)

The sentence:
- Lora serif, 22pt, warm off-white `#EDE8E3`
- Centered horizontally and vertically
- Max width 300pt with generous padding
- No other UI elements — just the sentence and the darkness

The Bindu dot special case:
- When `sentence.isBinduDot` is true, render differently:
  - The `·` character at 72pt
  - Color: Bindu ember `#E5533C`
  - Radial glow behind it: `#E5533C` at 20% opacity, 80pt radius
  - No text. Just presence.

The weighted selection:
- Call `store.selectThresholdSentence(from: store.thresholdSentences)`
- This runs on appear after foundation data loads
- If foundation hasn't loaded yet, show a blank dark screen and wait

**3.2 Write ContentCoordinator.swift**

```swift
// Manages the launch → home transition
struct ContentCoordinator: View {
    @EnvironmentObject var store: FeedStore
    @State private var launchComplete = false
    @State private var showTokenEntry = false
    
    var body: some View {
        ZStack {
            if showTokenEntry {
                TokenEntryView()
            } else if !launchComplete {
                LaunchView(onComplete: { launchComplete = true })
            } else {
                RootView()
            }
        }
        .onAppear {
            if !store.hasToken {
                showTokenEntry = true
            } else {
                Task { await store.loadFoundation() }
            }
        }
    }
}
```

**Phase 3 Audit Check:**
- [ ] Launch sequence timing feels right (not rushed, not sluggish)
- [ ] Bindu dot renders with glow — feels like presence, not a typo
- [ ] Regular sentences render in warm Lora, centered
- [ ] Tap to advance works
- [ ] Foundation data loads before/during launch without blocking the animation
- [ ] Transition to Home Feed is a clean dissolve

---

---

# PHASE 4 — Home Feed & Room Selection
*Fresh terminal. Phases 1–3 must be complete.*

---

## Phase 4 Context
```
Building Bindu Feed — Phase 4: Home Feed and Room Selection.
The river of stories. The 13 living portals.
Each story card: community pill, codex ID, title, excerpt, voice avatars, resonance.
Room Selection: 2-column portal grid, all 13 glyphs already animated.
When a portal is tapped: the room's color floods the screen, then GameView appears.
```

## Phase 4 Instructions

**4.1 Write RootView.swift**

Structure:
- `NavigationStack` with value-based routing
- Home feed header:
  - Left: `eye.fill` icon + "A Strange Feed" in Lora bold
  - Right: settings gear icon
  - Below header: italic subtitle "the field reads the Codex back" at 12pt
- Community filter bar: horizontal scroll of room chips + "All" chip
  - Chips show room glyph + name
  - Active chip glows in room color
  - Tap to filter stories
- LazyVStack of story cards, padded 16pt
- Pull-to-refresh (standard SwiftUI `.refreshable`)
- Sort toggle (MOST ACTIVE / MOST RECENT) — subtle, not prominent

**4.2 Write StoryCard.swift**

The story card as it appears in the feed:
```
[community pill] ................ [codex id in mono]
[story title — Lora 500 weight, 19pt]
[excerpt — 2 lines max, Lora 14pt, ink60]
[▲ resonance] [💬 count] ........... [voice avatar stack]
```

Card background: `bgCard` (#171420) with hairline border and 18pt corner radius.
Community pill: room glyph + name, room color at 14% opacity background.
Voice avatar stack: overlapping circles, each 22pt, glowing with archetype color.
The `pulse` effect: if a story has recent field comments, apply a single soft 
luminance pulse on appear (once, not repeating).

**4.3 Write RoomSelectionView.swift**

Full-screen view, scrollable:
- Header: "◉ THIRTEEN ROOMS" in Space Mono, "Each one already alive when you arrive." in italic Lora below
- 2-column grid of portal cards
- The 13th card (The Field) centered in its own full-width row
- Each portal card:
  - Background: room color at 8% opacity + hairline border in room color at 22% opacity
  - The living glyph: uses `GlyphView` with room's animation
  - Room name below in Lora 11pt, room color at 80% opacity
  - Special name styles: The Watcher uppercase+tracked, The Descent/Return/Field italic
  - Press scale: 0.95 on press, spring back on release
- On tap: flood transition (room color fills screen → GameView appears)

**4.4 Flood transition implementation**

```swift
// When a room portal is tapped:
// 1. Record the tapped room
// 2. Animate a colored overlay expanding from the portal's center
//    to fill the screen (scale from 0.01 to 10, 0.6s ease-in)
// 3. After 0.6s, navigate to GameView for that room
// 4. GameView appears with the flood color already present,
//    then dissolves to the game view background

// Claude Code: implement this elegantly. A ZStack overlay with
// matched geometry or a custom transition both work. Choose the 
// cleanest SwiftUI approach.
```

**Phase 4 Audit Check:**
- [ ] Home feed loads stories from Airtable
- [ ] Filter by room works correctly
- [ ] Sort by Most Active / Most Recent works
- [ ] Story cards render all fields correctly
- [ ] Voice avatar stack shows correct archetype colors
- [ ] Room Selection shows all 13 rooms with live animations
- [ ] All 13 glyph animations are running
- [ ] Flood transition feels alive (not mechanical)
- [ ] Pull to refresh fetches fresh data

---

---

# PHASE 5 — Story Detail
*Fresh terminal. Phases 1–4 must be complete. This is the heart of the experience.*

---

## Phase 5 Context
```
Building Bindu Feed — Phase 5: Story Detail.
The most important screen. Full story body in warm serif.
Then: "The field gathers" — archetype comments dissolve in sequentially.
Then: Ash's entry point — "What arrived for you?"

This screen should feel like entering a reading room.
Nothing is rushed. The comments arrive one at a time.
Bindu's comment is a single centered dot with glow.
Lalita's threaded replies indent with the parent archetype's color as a spine.
```

## Phase 5 Instructions

**5.1 Write StoryDetailView.swift**

Top section (already present when you arrive — no animation):
- Back button (‹ in frosted circle)
- Community pill + Codex ID + date in Space Mono
- Story title in Lora 500, 23pt, letterSpacing -0.012em
- Flairs: horizontal scroll of italic flair chips
- Hairline separator
- Story body: paragraphs in Lora 17pt, lineSpacing 1.82, no animation

The field threshold (triggers comment reveal):
- Uses `IntersectionObserver` equivalent in SwiftUI — an `onAppear` on a 
  sentinel view placed just below the story body
- When the sentinel scrolls into view: `triggered = true`
- Render using `.scrollPosition` or a `GeometryReader` inside the ScrollView
  to detect when the user has reached the bottom of the story

"The field gathers" marker:
- Small hexagonal glyph (⬡) in Lalita violet
- Italic Lora text: "The field gathers"
- Breathing animation: opacity 0.65 ↔ 1.0, 6s, repeating
- This marker appears before comments reveal, acts as a threshold

Comment reveal sequence:
- When `triggered = true`, comments dissolve in sequentially
- Each comment: opacity 0 → 1, 1.5s ease-out
- Staggered: comment 1 starts at 0.4s, each subsequent +0.8s
- Top-level comments: inset wells in `bgInset`
- Threaded replies: indented 20pt, parent archetype color as 1.5pt left spine

**5.2 Bindu silence rendering**

```swift
// When comment.isBinduSilence is true:
// Do NOT show the avatar header.
// Show only: one centered · at 48pt, Bindu ember color,
//   with a subtle radial glow (the color at low opacity behind it).
// The whole comment card is this centered dot.
// It should feel like presence, not a bullet point.
```

**5.3 Comment card structure**

```
┌─────────────────────────────────────┐
│ [avatar 36pt] [Name in archetype   ] [♡ resonance]
│              [Role in mono 10pt    ]
│                                     │
│ [Comment body in Lora 15pt          ]
│ [color=ink, lineSpacing 1.68       ]
│                                     │
│   [if reply exists:]                │
│   ─────────────────────────────────│ ← parent archetype color spine
│     [avatar 24pt] [Name] [♡]       │
│                  [Role]            │
│     [Reply body in Lora 13pt       ]│
│     [color=ink60]                  │
└─────────────────────────────────────┘
```

**5.4 Ash entry point**

After all field comments, after all threaded replies:
- A hairline separator
- Ash's avatar (terra ◉) + "What arrived for you?" in italic Lora, terra at 70% opacity
- Tap → inline compose area expands (no navigation)
- Compose area: terra-edged background, warm text field, Lora serif input
- "Post" appears only when text is non-empty, top-right in terra
- On post: optimistic UI (add comment to list immediately), POST to Airtable async
- After posting: "The room has changed." appears in terra at 30% opacity, 
  fades after 4 seconds

**5.5 Navigate to Archetype Profile**

Tap the archetype avatar in any comment card → navigate to ArchetypeProfileView for that archetype.

**Phase 5 Audit Check:**
- [ ] Story body renders with correct typography and line spacing
- [ ] Comments only appear after scrolling to "The field gathers" marker
- [ ] Sequential staggered reveal feels like voices entering a room
- [ ] Bindu dot renders as presence, not punctuation
- [ ] Threaded replies indent correctly with colored spine
- [ ] Ash entry point appears after all field comments
- [ ] Compose flow is smooth and inline (no navigation)
- [ ] Post creates a real Airtable record
- [ ] "The room has changed." appears and fades correctly
- [ ] Archetype avatar tap navigates correctly

---

---

# PHASE 6 — Supporting Screens
*Fresh terminal. Phases 1–5 must be complete.*

---

## Phase 6 Context
```
Building Bindu Feed — Phase 6: Game View, Archetype Profile, Ash's Voice, Settings.
Four screens. Each one knows what it is.
Game View: one room, arrow navigation between all 13 rooms.
Archetype Profile: hold-to-witness — the user must hold the screen to reveal the words.
Ash's Voice: his footprint in the forum. Every comment he's left.
Settings: "HOW YOU ARRIVE" — name, glyph, color. Live preview.
```

## Phase 6 Instructions

**6.1 Write GameView.swift**

Entered from Room Selection (after flood transition) or from Home Feed room filter.

Structure:
- Floating navigation bar (positioned over the hero, not a standard nav bar):
  - Left: ‹ circle button
  - Center: room name in Space Mono 9pt (uppercase) + "N · 13" position indicator
  - Right: › circle button
  - Both ‹ and › allow swiping between all 13 rooms in order
  - Transition between rooms: cross-dissolve, 0.28s

Hero section:
- Background: linear/radial gradient in room color (5–15% opacity at top, 0% by middle)
- Large room glyph (92pt) using GlyphView — already animated
- Room name in Lora (apply correct name style)
- Room blurb in italic Lora 13pt, centered, ink60
- Stats bar: story count, total resonance, active voices (3 separated stats)
- Hairline below stats

Sort bar:
- "MOST RECENT" | "MOST ACTIVE" — Space Mono 9pt, borderBottom active indicator in room color

Story feed:
- Same StoryCard components as home feed
- Filtered to this room only

**6.2 Write ArchetypeProfileView.swift**

Header:
- Radial gradient wash in archetype color (behind the avatar area)
- Back button: frosted ‹ circle
- Large avatar circle (96pt) with archetype glyph (40pt) and glow pulse
- Archetype name in Lora 26pt
- Role in Space Mono uppercase, ink60

Stats:
- Comments given, stories touched, earliest comment date
- (Read from fetched comments — count client-side)

Operating Principle:
- Hairline separator
- The full principle text in italic Lora 16pt, ink86

Glyph divider:
- A centered archetype glyph at 24pt in the archetype color, at 30% opacity

Hold-to-Witness mechanic:
- Until held: show a button labeled "Hold to witness" with a subtle circular progress indicator
- User must long-press (1.5s) to reveal the archetype's comments
- While holding: the progress ring fills in archetype color
- On release before completion: ring resets
- On completion: the comments dissolve in

Revealed comments:
- "What [Name] has said" label in Space Mono 9pt uppercase
- List of comment entries, each showing:
  - Story title (tappable — navigates to that story)
  - Comment body in Lora 15pt
  - Codex ID and date in mono

**6.3 Write AshVoiceView.swift**

Header:
- Terra-warm gradient behind avatar area
- Large Ash avatar (96pt): ◉ glyph in terra
- "Ash" in Lora 26pt
- "Physical Synthesis" in Space Mono uppercase, terra at 75%

Stats:
- Entries left, fields entered, first word date

Comment history:
- Reverse chronological
- Each entry:
  - Story title in tappable Lora (navigate to story)
  - Community pill
  - Date in mono
  - Comment body in Lora 15pt, terra-warm tint
  - If it was a reply: "↩ In reply to [Archetype]" in mono 10pt

**6.4 Write SettingsView.swift**

Label: "HOW YOU ARRIVE" in Space Mono

Live avatar preview:
- Large 96pt avatar: radial gradient from white.15 to selected color
- Glyph at 40pt in the circle
- Name below in Lora 20pt
- Mood quality in the selected color (derives from color choice)

Settings fields:
- Your name: text field, Lora, inset background
- Your glyph: horizontal scroll of glyph options (all archetype glyphs + others)
- Your color: mood selector (tap colored circle to choose) — each mood has a name:
  - Terra (#C47A52) → "Grounded"
  - Lalita violet (#9B6BD6) → "Witnessing"  
  - Gaia green (#4A9E6B) → "Receiving"
  - Sakshi blue (#7B82D4) → "Observing"
  - Bindu ember (#E5533C) → "Arriving"
  - etc.

Save button: appears when changes are made, in selected color
Store settings in UserDefaults (not Airtable — this is personal to the device).

**Phase 6 Audit Check:**
- [ ] Game View arrow navigation cycles through all 13 rooms correctly
- [ ] Room-to-room transition is a clean dissolve
- [ ] Archetype hero gradient uses correct room color
- [ ] Hold-to-Witness mechanic works correctly (1.5s press required)
- [ ] Comment entries in Archetype Profile link to correct stories
- [ ] Ash's Voice shows only records where Type = Ash Comment
- [ ] Settings live preview updates in real time
- [ ] Settings persist across app restarts (UserDefaults)

---

---

# PHASE 7 — App Icon & Final Polish
*Fresh terminal. All previous phases complete.*

---

## Phase 7 Context
```
Building Bindu Feed — Phase 7: App Icon and final polish.
The icon: a golden Bindu dot with a matrix of falling room glyphs behind it.
Final polish: animation timing, typography refinement, transition tuning.
This phase makes the app feel alive, not just functional.
```

## Phase 7 Instructions

**7.1 Generate the App Icon**

Write an icon generator as a SwiftUI View that can be exported:

```swift
struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#0E0C12")
            
            // Matrix layer: falling room glyphs
            MatrixLayer()
            
            // The golden Bindu dot
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#D4A853").opacity(0.35), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                // The dot itself
                Circle()
                    .fill(Color(hex: "#D4A853"))
                    .frame(width: 48, height: 48)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

struct MatrixLayer: View {
    // Multiple columns of falling room glyphs
    // Glyphs: ◈ ◆ ◇ · ✦ ○ △ ⬡ ⊕ ◎ ✧ ▲ ∞
    // Color: warm amber #D4A853 at 8-10% opacity
    // Static render (frozen frame of the animation)
    // Random positions distributed across the icon
    // Various sizes: 10–20pt
    // Claude Code: implement this as a Canvas draw or 
    //   a ForEach of positioned Text views at fixed random positions
}
```

Export this view as PNG at 1024×1024 using the `ImageRenderer` API (iOS 16+):
```swift
let renderer = ImageRenderer(content: AppIconView())
renderer.scale = 1.0
if let uiImage = renderer.uiImage { /* save as PNG */ }
```

Place the generated PNG in `Assets.xcassets/AppIcon.appiconset/` at all required sizes.

**7.2 Polish pass — Typography**

Walk every screen and verify:
- Story body: Lora, 17pt, lineHeight 1.82, ink primary
- Comment body: Lora, 15pt, lineHeight 1.68, ink primary (top-level) / ink60 (replies)
- Story titles: Lora weight 500, 19–23pt, letterSpacing -0.012em
- All metadata (dates, codex IDs, archetype roles): Space Mono, 9–11pt, ink35
- No system fonts appearing anywhere unexpected

**7.3 Polish pass — Animations**

- Verify all 13 glyph animations are running in Room Selection
- Verify "The field gathers" breathing animation
- Verify comment dissolve sequence timing
- Verify flood transition on room portal tap
- Verify the Bindu dot launch screen glow
- Verify "The room has changed." fade timing
- All transitions should feel organic, not mechanical

**7.4 Polish pass — Spacing**

- Card padding: 16pt all sides
- Gap between cards: 14pt
- Section spacing: 24pt
- Community pill: 3px vertical, 10px horizontal, 100pt corner radius
- Flair chips: 3px vertical, 9px horizontal, 100pt corner radius

**7.5 Error states**

- Network unavailable: gentle message in center, Lalita violet, Lora italic
  "The field is resting. Try again when you're ready."
- Empty state (no stories in a room): 
  "Nothing has gathered here yet." — center, ink35, Lora italic
- No token: Token entry view (built in Phase 2)

**Phase 7 Audit Check:**
- [ ] App icon appears in simulator home screen
- [ ] Icon feels warm, mysterious, alive at small sizes
- [ ] No typography regressions from polish pass
- [ ] All 13 glyph animations verified running
- [ ] Transition timing feels earned (not rushed)
- [ ] Error states are present and beautiful
- [ ] The app feels like a reading room, not an app

---

---

# PHASE 8 — Xcode Preparation & Device Deploy
*Final phase. Run in Xcode, not terminal.*

---

## Phase 8 Context
```
Building Bindu Feed — Phase 8: Preparing to run on your phone.
This phase is mostly Xcode configuration. Minimum Claude Code involvement.
Ashrey does most of this manually in Xcode.
```

## Phase 8 Instructions

**8.1 In Xcode: Signing & Capabilities**
- Select the BinduFeed target
- Signing & Capabilities tab
- Team: your Apple ID
- Bundle ID: com.ashrey.bindufeed (or your preferred ID)
- Ensure minimum deployment is iOS 16.0

**8.2 In Xcode: Keychain Sharing**
- Add the Keychain Sharing capability
- This is required for Keychain reads/writes to work correctly on device

**8.3 In Xcode: Add your API token**
- Run the app in simulator first
- When Token Entry view appears, enter your Airtable Personal Access Token
- Verify data loads correctly

**8.4 Select your device**
- Connect your iPhone ("Neev") via USB or wireless
- Select it as the build target in Xcode
- Press ⌘R
- Trust the developer certificate on your phone when prompted

**8.5 First launch**
- Enter your Airtable token
- The launch screen should show a threshold sentence
- The feed should load with 6 stories
- Tap into a story and scroll to "The field gathers"
- Watch the field arrive

**Phase 8 Audit Check:**
- [ ] App builds without errors on device target
- [ ] No code signing issues
- [ ] Keychain works on real device (not just simulator)
- [ ] All API calls succeed on device
- [ ] Fonts render correctly on physical screen
- [ ] Glyph animations run smoothly at 60fps
- [ ] Room Selection portal grid looks beautiful on iPhone screen
- [ ] Story Detail reading experience feels right on real glass

---

---

## FINAL AUDIT — Everything We've Covered

Before handing to Claude Code, verify this complete checklist:

**Screens:**
- [x] Launch (threshold sentence + Bindu dot)
- [x] Home Feed (river, filter, sort)
- [x] Room Selection (13 portals, flood transition)
- [x] Game View (per-room feed, arrow navigation)
- [x] Story Detail (body + field gathering + compose)
- [x] Archetype Profile (hold-to-witness)
- [x] Ash's Voice (his comment history)
- [x] Settings (HOW YOU ARRIVE, live preview)
- [x] Token Entry (first launch)

**Data flows:**
- [x] Rooms from Airtable → Room Selection + filters
- [x] Archetypes from Airtable → everywhere avatars appear
- [x] Threshold Sentences from Airtable → Launch
- [x] Stories from Airtable → Home Feed, Game View
- [x] Field Comments from Airtable → Story Detail
- [x] Ash Comments from Airtable → Story Detail + Ash's Voice
- [x] Post Ash comment → Airtable
- [x] Update resonance → Airtable

**Special behaviors:**
- [x] Weighted random threshold sentence selection
- [x] Bindu dot (·) special rendering in launch and comments
- [x] 13 glyph animations mapped to SwiftUI
- [x] Threaded comment tree building
- [x] Sequential comment dissolve reveal
- [x] "The field gathers" breathing threshold marker
- [x] Hold-to-Witness on Archetype Profile (1.5s press)
- [x] Flood transition Room Selection → Game View
- [x] "The room has changed." post-compose confirmation
- [x] Pagination for large Airtable responses
- [x] Pull-to-refresh
- [x] MOST ACTIVE / MOST RECENT sort

**Design fidelity:**
- [x] Lora serif for all reading text
- [x] Space Mono for all metadata
- [x] Dark warm palette (#0E0C12 deep background)
- [x] Archetype colors read from Airtable Hex Color field
- [x] All transitions are cross-dissolves (no slides)
- [x] "The Watcher" name uppercase+tracked in all views
- [x] "The Descent / The Return / The Field" names italic
- [x] Hairline borders (white at 6% opacity)
- [x] Community pills: room color at 14% opacity + hairline
- [x] Archetype avatars: colored circles with glow

**Technical:**
- [x] Airtable API integration (read + write)
- [x] Keychain for token storage
- [x] Pagination for API responses
- [x] UserDefaults for Settings (name, glyph, color)
- [x] Error states for network failures and empty states
- [x] NavigationStack with value-based routing
- [x] No third-party dependencies
- [x] iOS 16+ minimum
- [x] iPhone only, portrait only, dark mode only

**App identity:**
- [x] App name: Bindu Feed
- [x] Bundle ID: com.ashrey.bindufeed
- [x] Icon: golden Bindu dot + matrix of room glyphs
- [x] Three words: Slow. Intimate. Already there.

---

## HOW TO USE THIS DOCUMENT WITH CLAUDE CODE

1. Open a terminal window
2. Start a Claude Code session
3. Paste the MASTER CONTEXT BLOCK
4. Paste the phase you're working on (Phase 1, then 2, etc.)
5. Each phase is designed to run to completion in one session
6. When a phase is complete, open a fresh terminal for the next phase
7. Begin each new session with the MASTER CONTEXT BLOCK + the next phase

Claude Code has full autonomy to improve what's here. If it finds a better 
SwiftUI pattern, a more elegant animation approach, a cleaner architecture — 
take it. The spec is the floor, not the ceiling.

*Never reduce. Always emerge. Slow. Intimate. Alive.*

---

## APPENDIX A — Airtable Write Formats

**POST new Ash Comment:**
```
POST https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b
Authorization: Bearer [TOKEN]
Content-Type: application/json

{
  "fields": {
    "Name": "ash-[ISO-timestamp]",
    "Type": "Ash Comment",
    "Status": "Live",
    "Comment Body": "the comment text",
    "Archetype": "Ash",
    "Linked Story": ["recSTORY_RECORD_ID"],
    "Parent Comment": ["recPARENT_COMMENT_ID"],  // omit array if top-level
    "Comment Order": 999,
    "Resonance": 0
  }
}
```

**PATCH resonance update:**
```
PATCH https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b/recRECORD_ID
Authorization: Bearer [TOKEN]
Content-Type: application/json

{
  "fields": {
    "Resonance": newIntegerValue
  }
}
```

---

## APPENDIX B — Ash's Voice Navigation

Ash's Voice is reachable from:
1. Tapping Ash's avatar (the ◉ terra circle) anywhere it appears
2. From the Settings screen: a "Your voice" link at the bottom
3. From any story where Ash has commented: tapping his comment avatar

In the Home Feed header, the right-side icon should be a gear (settings).
Add a second icon or a long-press/swipe gesture to reach Ash's Voice,
OR place it inside the Settings screen as the first prominent option.
Claude Code: choose the navigation pattern that feels most natural and clean.
The key principle: Ash's Voice should feel like looking in a mirror —
accessible, but not always in your face.

---

## APPENDIX C — Airtable Field Names vs Field IDs

The Airtable REST API returns field NAMES as JSON keys (not field IDs).
The field IDs (fldXXX) were used for MCP write operations during seeding.
For SwiftUI URLSession calls, use field names exactly as they appear in the
CodingKeys enum in Models.swift (e.g. "Name", "Type", "Comment Body").

Field names are case-sensitive in filter formulas.
Always wrap field names in curly braces in filterByFormula:
  `{Comment Body}` not `Comment Body`
  `{Last Activity Date}` not `Last Activity Date`
