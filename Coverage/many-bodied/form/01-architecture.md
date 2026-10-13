# Form 01 · Information architecture, structure and navigation: the whole app as one place

*Form pass, reader 01 · 12 Oct 2026 (evening) · backstage. Lens: the map. That covers every register on the axis, every screen, every menu and turn ("WHERE TO"), every way in and out, the Door's slot, the Archive's many turns, RoomSelection, Players, Settings, and how each new thing in W0–W8 is reached.*

**Read for this pass:**
- FORM-BRIEF and AGENT-COMMON.
- GAMEPLAN and CONTRACT, in full.
- The nine scores. Every navigation, route, Turn-row, Door, river, Book, axis and room section was read in full; the rest was skimmed for its structure.
- READINESS-REVIEW, and readers 01, 02, 13, 14 and 21.
- The skills:
  - padakarshini: SKILL.md; `gestures.md` G0, G12, G13, G14–G16, G38–G50; `forms.md` A14, B1–B4, C, D and E; and `elements-2026-09-30.md` §6.2, §6.3 (the 14 Feed screens) and §6.9.
  - rupakarshini: SKILL.md, plus `shapes.md` S1, S2, S11–S17 and Nesting.
  - a-strange-game: SKILL.md, `journey-flow.md`, `journey-topology-v2.md` and `storage-pools.md`.
- The real navigation code, read in the repo:
  - `App/Navigation.swift` and `App/ContentCoordinator.swift`;
  - `Components/TurnOverlay.swift` and `Components/HubOverlay.swift`;
  - `Screens/RootView.swift`, `DoorView.swift`, `RoomSelectionView.swift` and `PresentView.swift`;
  - the chrome of `Instrument/InstrumentView.swift` (:320–335, :1087–1163) and `AxisModel.registers`;
  - every `pushDissolve`, `popDissolve` and `pendingLaunchRoute` call site in the app (a grep across `Screens/ Components/ Rooms/ Instrument/ Universe/ Point/`).

---

## 1 · First principles: fifteen laws the whole map obeys

| # | Law | Why (source) |
|---|---|---|
| P1 | **One place, many faces.** Every surface is one of three things. It is a *register* of the one axis, a *face* of the one board (River · Sky · Cloth · Arc · Spine · Book), or a *ceremony door* that returns him to exactly where he stood. Nothing else exists. | GAMEPLAN §3.2; rupakarshini S12 and S14 seams ("out to the exact depth left from; never to a generic home") |
| P2 | **The list is the axis seen as a list.** WHERE TO names *places*, ordered by depth and lit by where he stands. A depth row glides there; a ceremony row crosses. | padakarshini elements §6.3, "The turn", later form; G42 the Veil |
| P3 | **Lit, never locked, applies to the map.** Every place is in the list on every day. Light alone (B3: 0.95 · 0.82 · 0.62 · 0.30 · 0.16) says where he is and what this hour offers. No row is ever filtered out. | GAMEPLAN law 2; padakarshini B3; W0 14.5's own fix, generalised |
| P4 | **The map fits a screen.** One piece per screen, nothing taller than ~700 px at 390 wide. A menu that runs off the glass is a wall. | padakarshini SKILL "one piece per screen" |
| P5 | **A hidden gesture is never the only way.** Every gesture-only door has a visible, focusable twin *on the same surface*. | GAMEPLAN law 7; elements "Three gestures on one surface", the guard: "a button for the turn, a reachable control for the rope" |
| P6 | **Every inward pass has its outward pass.** ‹ always does something, retraces the way in, and is never a no-op or a jump to a generic home. | rupakarshini law 3; padakarshini law 14 and G38; ceremony grammar D step 8 |
| P7 | **Context travels.** Moving from one face or register to another carries the focus: this story, this day, this room. | rupakarshini law 21, "context comes from where the reader stood" |
| P8 | **One name, one place.** No two places share an on-screen name unless they are one place. Where a name is shared on purpose, the two places hold a door to each other. | padakarshini method 9–10 (wording canon; one identity per entity) |
| P9 | **A depth budget.** The rope is one move from anywhere. Any place is two moves from anywhere (the Turn, then its row). Any story is at most three moves from the river, by sight or by a word. | Feed doctrine "slow, intimate", made measurable; plan review §7 |
| P10 | **The quiet state is designed first.** The low day, the empty river and the first open are drawn before the rich state. | rupakarshini law 19; GAMEPLAN law 5 |
| P11 | **No lobby.** The first screen is the first movement of the day's meeting. Nothing stands in front of it. | elements §6.3 "No lobby" |
| P12 | **One thing at a time:** at openings, at closes, and at the head of the river. | GAMEPLAN law 11; plan review N7 |
| P13 | **Two taps on dense figures.** On a map, the first tap names and the second goes. A single tap that moves is a trapdoor. | elements §6.4 "Two taps, never one" |
| P14 | **Architecture invisible.** Places are named by what they are to him, never by mechanism. | GAMEPLAN law 10; W4 §0 |
| P15 | **Every place is reachable without motion, sound or a long hold.** VoiceOver has a rotor of places, and every row is a button. | CONTRACT §7 accessibility; G42 keyboard guard |

---

## 2 · The app today, through this lens

### 2.1 The map as built (main @ 275eabd)

```
cold open ─► WakingView 1.65 s ─► [TokenEntry, only without a PAT]
          ─► THE DOOR  (ContentCoordinator.doorCrossed == false; never shown again until a cold launch)
               unmet: room glyph · "One story has come to meet you." · title · touch to receive ─► RITE (inline) ─► river
                      "not today · enter the field ›" ─► river
               met:   PracticeDoor (threshold 40 · practice 23 · Gaia seed 20 · what found you 12 · dot 5 · Leela)
                      tap anywhere ─► river            ("what found you" crosses, never opens the story)
               ⠿ dot mark / pull 84 pt ─► WHERE TO (any row also dismisses today's Rite — DoorView.handleTurn)
               long-press 1.1 s ─► ROPE ─► walk the point (gate) · lay it down (the Call) · return to the day
          ─► crossing +2 s: letter › field notice › gift   (cooldown dice)

THE RIVER  = RootView.feedScreen, the root of a ZStack path of mounted layers
  ⠿ Turn · "A Strange Feed" · Pointy · AshMark ─► Ash's voice
  "the archive, as a book ›" ─► ArchiveBook      chips: All + 13 rooms      MOST ACTIVE / MOST RECENT
  cards ─► STORY ─► compose · read by hand · hall (called day) · return/floor (sealed) · avatar ─► Turning
                    cordCut / hide-and-seek ─► another story · ∞ rewind spiral (memo)

WHERE TO (TurnOverlay, VStack, 12 rows; no scroll)
  Rite (unmet only) · Rooms · Archive(=pop to river) · Universe(z−4) · Light(z−5) · Point(z+1) · What You Kept(BookView)
  · The Present · The Codex · Unwinding (new moon / season turn only) · Players · How You Arrive        ☽ Nityā

THE AXIS (InstrumentView, pushed as .instrument(z); no Turn on it; ‹ = step out in the Universe, else pop to the river)
  −5 Light seam "stand inside ›" ─► LIGHT ceremony
  −4 sky · −3 region · −2 world (door ─► STORY; met stars only) · −1 fall (mouth ─► RETURN)
   0 Feed seam "enter the feed ›" (pops to river)
  +1 gate · +2…+8 worlds I–VII (VI door ─► RETURN · VII door ─► APERTURE ─► "TO THE CENTRE ›" pushes a 2nd axis)
  +9 centre ─► again? ─► corridor ─► gate
  rail: 15 ticks + 14 surface dots, rungs tap = one passage

Off the Turn:  Rooms ─► RoomSelection (12 grid + 13th wide + "AND THE FIELD TURNS TO YOU": Mirror, Signal)
                        ─► GameView (‹ › chevrons, "n · 13 · all rooms" ─► grid)
               Players ─► 8 lens cards + 2 roots + Ash ─► RoomView(.home)
               Present ─► "your walk, drawn ›" PORTRAIT · "your life as cloth ›" WEAVE
               Codex · Book(kept) · Unwinding · Settings(How You Arrive ─► Ash's voice)
Overlays from anywhere: the Call (two fingers 0.8 s) · LetterArrival · Gift ─► story | instrument(8) · FieldNotice · Lalita play
```

### 2.2 Inventory: every place, how you reach it today, how you leave it

| Place | Route | Ways in today | Way out | Note |
|---|---|---|---|---|
| Waking | — | cold open | auto 1.65 s | input never blocked (ruled 11 Oct) |
| Door (unmet / met) | — | cold open only | tap · not today · Turn · rope | **not reachable again until a cold launch** |
| River | root | crossing · Turn "Archive" · axis Feed seam | Turn · cards · AshMark · book link | root of every stack |
| Story | `.story` | river, room list, sky door (met stars only), Book page, Ash voice, Book kept line, hide-and-seek, cordCut, gift | ‹ pops | 12 doors at its foot (reader 01 §1) |
| Read by hand · Compose · Hall · Floor · Return | various | story page only (Hall only on a called day; Floor and Return only when sealed) | ‹ / ceremony close | Return also from the fall's mouth and the VI door |
| Turning | `.turning` | comment avatar only | ‹ | not in the Turn or in Players |
| Rooms | `.rooms` | Turn | ‹, flood ─► room | the 13th room is hard-coded |
| GameView | `.room` | RoomSelection | chevrons · label ─► grid | the same room as sky region −3, **with no door between the two** |
| Mirror · Signal | `.mirror` `.signal` | **the foot of RoomSelection only** | ‹ | the persons tier |
| Players ─► voice rooms | `.players` `.home` | Turn | ‹ | marks can't open stories |
| Book (kept lines) | `.book` | Turn "What You Kept" | ‹ | |
| ArchiveBook | `.archiveBook` | river link only | ‹, middle page ─► fall | |
| Present | `.present` | Turn | ‹ | the only door to Portrait and Weave |
| Portrait · Weave | `.portrait` `.weave` | **Present only** | ‹ | |
| Codex | `.codex` | Turn | ‹ | |
| Unwinding | `.unwinding` | Turn, **only at the new moon or a season's turn** | ‹ | |
| Settings | `.settings` | Turn "How You Arrive" | ‹ | |
| Axis (all 15 registers) | `.instrument(z)` | Turn (Universe/Light/Point) · rope "walk the point" · gift dance · Floor walk-out · deep link | ‹ · rail · lean | **no WHERE TO anywhere on the axis** |
| Light (proper) | `.light` | the axis −5 seam's "stand inside ›" · deep link | ceremony close | Turn row Light ─► seam ─► tap: 3 moves |
| Aperture | `.aperture` | **World VII's door only** | ‹ · "TO THE CENTRE ›" pushes a second `.instrument(9)` over the first | |
| Rite | `.rite` | Door (unmet) · Turn (unmet only) · deep link | close | once a day |
| The Call | overlay | two fingers held · the rope's LAY IT DOWN, after 20 s of words | close | **no visible door on any surface** |
| Rope | overlay | long-press on the Door and the axis | its exits | **no visible twin** (breaks the corpus guard) |

### 2.3 What works, and must be kept

1. **WHERE TO itself.** The breathing marks drawn in each row's own hand, each sub-line in its own colour, *tap anywhere to stay*, Nityā at the foot. It is the right form; only its contents went wrong.
2. **The path stack keeps every layer mounted.** Scroll, compose text and the axis all survive a push or pop. `closeCeremony()` pops exactly one layer, which already satisfies ceremony grammar step 8.
3. **The Universe's ‹ steps out one scale at a time** (`UniverseBack.step`), retracing the way in (P6).
4. **The rail rungs** are the equal path through the axis for a tired hand.
5. **Two weathers on one Door,** the blink crossing used at one surface only, and the dissolve everywhere else.
6. **The Turn's depth rows glide when already inside the axis** (`HubOverlay` Slice 10). This is the "axis seen as a list" made literal.

### 2.4 What does not work today

| # | Defect | Evidence |
|---|---|---|
| T1 | **The axis has no Turn.** From the sky, the Point or the Light, the only exits are ‹, the rail and the rope. The design says a slow pull opens the Turn in the Instrument. | `InstrumentView` has no `HubTrigger` or `TurnOverlay`; elements §6.3 "Three gestures": *"In the Instrument, the turn needs a slow pull; a firm pull departs outward"* |
| T2 | **‹ outside the Universe pops the whole stack to the river.** Entering the axis from a story (gift → dance) and leaving loses the story. | `InstrumentView.swift:331` |
| T3 | **Two axes stack.** The Aperture's "TO THE CENTRE ›" and the Floor's walk-out push a second `.instrument` over the first. | `ApertureView.swift:162`, `MirrorFloorView.swift:196` |
| T4 | **"The Archive" means three things.** The Turn row pops to the river; "the archive, as a book ›" opens ArchiveBook; "What You Kept" opens BookView. | `TurnOverlay.swift:38`, `HubOverlay.swift:28`, `RootView.swift:123` |
| T5 | **Every Turn choice from the unmet Door silently dismisses today's Rite.** | `DoorView.handleTurn` → `markRiteDismissedToday()` |
| T6 | **Mirror and Signal sit only at the foot of RoomSelection. Portrait and Weave sit only in the Present.** | §2.2 |
| T7 | **The Call and the rope have no visible door.** | §2.2 |
| T8 | **A room and its region are two places.** GameView and region −3 have no door between them, and a story page has no door to its own star. | §2.2 |
| T9 | **The Door is cold-launch-only.** iOS keeps the app alive for days, so on most mornings he resumes into last night's screen. The morning Door, the Rite invitation and every "per opening" rule rarely fire. | `ContentCoordinator.doorCrossed` is reset only on token loss; W5 §2.4 (1): *"a foreground resume is not one"* |

---

## 3 · The app after W0–W8 as scored: where the sum breaks the laws

### 3.1 WHERE TO, as the nine scores leave it

| Row | Added by | Destination |
|---|---|---|
| The Rite (always; on a met day → **the Draw**) | W4 §3.11 | `.rite` / `.draw(nil)` |
| The Return | W4 §3.11 | `.returnCeremony(nil)`, coloured in **the room The Return's hex** |
| The Rooms (`every way in`) | W0 15.4 #13 | `.rooms` |
| The Board · The Draw | W4 §3.11 | `.board` · `.draw(nil)` |
| The Archive (→ the river; after W6, glide to z 0) | today; W6 §2.1 | root |
| The Book | W3 §7 | `.archiveBook` |
| The Cloth | W3 §4 | `.weave` |
| The Universe · The Light · The Point | today | glide −4 / −5 / +1 |
| What You Kept (BookView, which by now holds *what found you*, the board, the seasons, what you carried, the gates) | today; W0 15.5; W4 §4.6; W5 §6 | `.book` |
| The Present · The Codex | today | |
| The Gates | W4 §3.11 | `.gates` |
| The Unwinding (always) | W0 14.5 | |
| Rest a moment | W0 14.21 | rope overlay |
| The Turning | W0 14.7 | `.turning(a)` |
| The Old Story | W0 14.8 | glide −4 + gather |
| The Whole House | W6 §6.1 | `HouseView` |
| the voices | W6 §2.5 | Wall of Voices |
| walk a chain | W6 §10.5 | the journey chooser |
| The Players · How You Arrive | today | |
| *advance 10 min* (DEBUG) | W0 15.3 | harness |

**24 rows, plus the DEBUG row and the Nityā line, in a `VStack` that does not scroll.** At the drawn sizes (Lora 16 name, italic 12.5 sub, 13 pt spacing ≈ 44–47 pt per row, plus 80 + 30 pt of header and ~60 pt of footer), the list is about 1,250 pt tall on an 844 pt screen. **Rows 15–24 render off the glass and cannot be tapped:**
- The Whole House;
- the voices;
- walk a chain;
- the Players;
- How You Arrive (and with it FORGET ME and CARRY YOUR ROAD);
- and, by W4's own ordering, Rest a moment, The Turning and The Old Story.

This breaks P4 and P9. It also breaks law 5 directly, because the rope's only visible door lies below the fold.

### 3.2 The breaks, numbered (each cites the score sections that add up to it)

**B1 · Menu overflow and overload.** The overflow is described in §3.1 (W0 14.5, 14.7, 14.8, 14.21; W3 §4 and §7; W4 §3.11; W6 §2.5, §6.1 and §10.5). The 24 rows mix seven kinds of thing in one undifferentiated column:
- registers (Universe, Light, Point, Archive);
- faces of the board (Cloth, Book, Old Story);
- ceremonies (Rite, Return, Gates, Unwinding);
- games (Board, Draw, walk a chain);
- people (Players, The Turning, the voices);
- a resting place (Rest a moment);
- settings (How You Arrive).

The original Turn had 8 rows and the rule *"the turn never nags."* Each score added its own rows and none designed the whole.

**B2 · Two Books.**
- W3 §7 makes **ArchiveBookView** "the Book" and adds the Turn row The Book (W3 §19 item 6 notices the problem and leaves both).
- W0 15.5, W4 §4.6 and W5 §6 put the Book's *record of arrivals* (*what found you*, the board's walks, the seasons, what you carried, the gates walked, the Recitation's "say them all back ›") into **BookView**, which the Turn still calls "What You Kept".
- GAMEPLAN law 3 says every arrival "stays in the Book".

He will open The Book and not find the season's letter.

**B3 · Two doors to one place that disagree, and one name for two places.**
- **The Rite row on a met day opens the Draw** (W4 §3.11), so two rows lead to one surface under two names. W4 §3.5 B already gives the Rite its own *let it go and draw again*.
- **"The Archive" glides to the river** (W6 §2.1). The label is untrue and duplicates The Book.
- **The Return** names three places: the ceremony row (W4 §3.11, *in the room's own colour*), room 5, and Point world VI. Only world VI says they are one ("This depth and that descent are the same room", `PointWorldView:273`). The room has no door to the ceremony.
- **The Gates** (W4) and **THE GATE** (+1, the deal) are both on screen.
- **The Old Light** room (W2 §5.7, at the top of the sky) and **the Light** (−5) sit one register apart, with no stated relation.
- **Four rings of the rooms:**
  - RoomSelection's ring (W0 15.4, W2 §3.3);
  - the eagle-eye's mandala of seats (W6 §6.2 B);
  - the HouseYantra's enclosures (W7 §7);
  - the board's lit glyphs (W4 §3.2).

  Each is built separately, with its own geometry and its own tap rules.

**B4 · The axis as root breaks the way back (W6 §2.1, W7 §3.3).**
- W6 makes the axis the root and turns every `.instrument(z)` push into "popToRoot + glide". Two consequences:
  - The axis's ‹ outside the Universe still runs `if !path.isEmpty { popToRoot }` (`InstrumentView:331`). At the root the path is empty, so **‹ at the gate, the Point worlds and the Light seam does nothing**.
  - Every story-surface that sends him into the axis **loses the story beneath**: the Floor's "walk out into the sky", the gift's dance, the Aperture's "to the centre", and the Feed seam. This breaks ceremony grammar step 8 and P6.
- W7 §3.3's *dance it* still does `pushDissolve(.instrument(8))`, which **contradicts W6 §2.1** by stacking a second axis on the root.

**B5 · There is still no WHERE TO on the axis, and the river's pull now means two things.**
- After W6, the only `HubTrigger` on the root is in the river's header (z 0, scrolled to the top). From the sky, a region, a world, the fall, the gate, the seven worlds or the centre, there is no Turn (T1 survives W6).
- At the river's top edge, W6 §2.1 turns the downward pull into the **outward lean**. That is the same gesture as G12's 84 pt **slow pull that opens the Turn** on the Door. W6 retires `.refreshable` but never resolves the pull. The corpus did: slow pull opens the Turn, firm pull departs.

**B6 · The river's trailing edge has four owners (W6 §2.1 + W3 §6.2, §9.1–9.2).**
- **The rail rungs, at z 0 after W6.** Their hit frame is 44 pt wide at `x = W − 22` (`InstrumentView.railRungs` :762–785), so it covers `W−44…W`. Cards are inset 16 pt, so **every card's trailing 28 pt becomes a "glide to register" target** wherever the rail spans. A tap on the right of a card would throw him to another register.
- W3's quiet-room strip, with a 24 pt hit area.
- W3's wandering dot, resting at `x = W − 9`, and its hiding ring.

**B7 · The river's foot is overloaded and out of reach.** These all sit at the river's foot:
- the Verb Mala, pinned (W1 §6);
- the "the voices ›" link (W6 §2.5);
- the #seam, speaking at the foot (W6 §2.2);
- the inward lean edge toward the gate (W6 §2.1).

At 469 stories the foot is hundreds of cards away. The voices' river-foot door is effectively unreachable, and it shares its pixels with the membrane.

**B8 · The river's head is crowded, against P12.** Before the first card there are about eight bands:
- the header row (Turn, wordmark, Pointy, AshMark);
- the subtitle;
- the witness line (W6 §2.5);
- the `ArrivalHead` (W5 §3.4), or on a low day the lead swatch (W5 §7);
- `SeedThread`;
- "the archive, as a book ›";
- 22 chips;
- a three-way sort (W1 §3.2).

On top of that, the order of the cards is moved by:
- the bright lane (W2 §12.3);
- filament seating (W6 §7.4);
- SIDE BY SIDE.

**B9 · The Door's slot has two owners and gains a lobby.**
- W4 §2.3 builds an *ask* slot (askYesterday · askNight · askBetween · doorWords · threeDoors · board · quiet).
- W5 §2.6 and §3.2 build an *arrival lot* with its own Door seat, plus overrides (letter › season letter › wager).
- The two are reconciled by one ad-hoc sentence ("when the Door's arrival is non-nil, W4's ask waits").
- **On the unmet weather, W5 §3.2 shows an arrival "first, as a page", and a tap "continues to the weather".** That is a screen in front of the day's meeting, which breaks P11 and elements "No lobby".

**B10 · The low day is known too late, and the rope has no twin on the Door.**
- `Round.isLowDay` is true only once the rope has been pulled today, Rest a moment opened, or a state laid down at the Call (W4 §2.1). On a heavy morning, before he has done any of these, the house shows its full self:
  - Waking may carry the year-ago page (W5 §4.8);
  - the Door asks "Yesterday's story — how did it sit?" (W4 §3.1);
  - a due wager or season letter takes the slot (W4 §4.1 and §4.5).
- The quiet way out is a 1.1 s long-press on empty ground (hidden). Its only visible twin (W0 4.1) is a Turn row that, per §3.1, lies below the fold. The one gentle *visible* door is W4's `one line is enough ›`.

This is the single largest gap against GAMEPLAN law 5.

**B11 · Openings depend on cold launches.** W5 §2.4 defines an opening as a cold launch, and a foreground resume as not one. Five things hang on openings, so all five fire only when iOS happens to have killed the app:
- the Door;
- the asks;
- the wager's return (W4 §4.5, "the first opening on or after `dueOn`");
- the season letter;
- the whole arrival engine.

Most mornings he will resume into last night's Return.

**B12 · Gesture-only and buried places (P5, P9).**

| Place | Its only way in | Moves from the river |
|---|---|---|
| **The house as one figure** (W7 §7) | "one pinch further out" than the eagle-eye: no row, no button. Its VO action exists only once inside it | hidden |
| **The Call** | two fingers held; or rope → wait 20 s → LAY IT DOWN | hidden, or 3 + a wait |
| **Mirror, with W6's year of veils · Signal, with its archive** | Turn → Rooms → past a 21-glyph ring and 11 rows of two-column cards → card | 3 + a long scroll |
| **The Aperture** (W5 delivers kathas here) | inside World VII | ≈ 5 |
| **Portrait** | Present only. W3 §7.3 moves its month letters into the Book, so the Portrait is now a duplicate with one door | 3 |
| **The Waiting Room** | the foot of the Unwritten's room list (by design: absence noticed first) | 3 + scroll |
| **A named old story** | no find. River scroll; chips; or Book → contents → riffle (≤ 20 leaves flick) | unbounded at 469 |

**B13 · The story page's foot is a menu (P12).** After all the waves, a received page closes with:
- the close conductor's shape, signature and one after-thing (W2 §12, W3, W4 §4.5, W7 §3.3 and §6.1), with the draw-path after it (W3 §9.4);
- a column of doors:
  - `hall ›` (W0 14.4);
  - *What arrived for you?*;
  - `meet it in the Rite ›` (W4 §3.5 C);
  - `return to it ›` or `you sealed this once · return ›` (W4 §3.7);
  - the FloorDoor;
  - read by hand;
  - `SwatchUnder` (W5 §3.5).

That is up to eight stacked lines, and law 11 governs only the after-thing.

**B14 · "Thirteen-room" thinking survives.**
- RoomSelection keeps the persons tier "AND THE FIELD TURNS TO YOU" (Mirror, Signal) *after* the room list, where with 13 it was a short scroll (W2 §3.3, "unchanged").
- W3 §12.3 seats rooms that ripen through the Lalita loop (22–40) on the same r = 0.40·side ring. At 40 glyphs × 22 pt on r ≈ 143 pt they touch, and 44 pt hit targets overlap.
- GameView's chevrons (G43) step one room at a time. Reaching the far side of 21–40 rooms takes 10–20 taps.
- The Rooms row's mark draws `rooms.count` dots inside 22 pt (W0 15.4 #13): a census drawn as noise.

**B15 · The faces of the board are navigational islands.** GAMEPLAN §3.2 says the six faces are *the same board seen differently*, yet each is reached by its own route, and none can step to another while keeping what he is looking at:

| Face | Ways in |
|---|---|
| River | root |
| Sky | Turn → Universe |
| Cloth | Turn row · Present link · Book back cover |
| Arc | the Old Story's Turn row · rail mark · stillness |
| Spine | eagle-eye page D only |
| Book | Turn row · river link |

From a Book page he cannot see that story's star, and from a Cloth stitch he cannot reach that day's page.

**B16 · Dense figures that move on a single tap (P13).** Each of these is a trapdoor:
- RoomSelection's ring: the first tap floods into the room (W2 §3.3);
- the eagle-eye's 4 pt seats: "tap it, lands there" (W6 §6.4);
- the yantra's enclosures (W7 §7).

At 469 seats, a mis-tap opens a random story.

### 3.3 Depth: moves from the river after W0–W8 (as scored)

| To | Moves | | To | Moves |
|---|---|---|---|---|
| a story on screen | 1 | | the Book (self-writing) | 2 (Turn row) |
| a story in a named room | 2 (chip) / 4 (Turn → Rooms → glyph → card) | | the seasons, what you carried | 2 (What You Kept) — **not** in the Book |
| a story by memory of a phrase | — no path | | the Cloth | 2 |
| today's Rite | 0 (Door) / 2 | | the Whole House | 2 *if the row is on screen* (it is not, §3.1) |
| the Return | 2 | | the yantra | hidden |
| the Board · the Draw · the Gates | 2 | | Mirror · Signal | 3 + long scroll |
| the Light (proper) | 3 (row → seam → stand inside) | | Portrait | 3 |
| a Point reading | 5–6 | | the Aperture | ≈ 5 |
| the rope | 1 (hidden) / 2 + below the fold | | the Call | hidden / rope + 20 s |
| How You Arrive (FORGET ME) | **below the fold** | | | |

### 3.4 What a person who opens the app on a low day meets (as scored)

1. **Waking.** 1.65 s, possibly carrying last year's found page (W5 §4.8). The day is not yet known to be low.
2. **The unmet Door.** In the upper third, an ask ("Yesterday's story — how did it sit?", or the board's "Carry a question in."), *or* a due wager card ("Did it appear?"), *or* the season's letter descending. Below that: the day's story, `touch to receive`, `not today ›` and `one line is enough ›`.
3. **The way to quiet is invisible.** He can long-press empty ground (if he remembers it), or open WHERE TO and scroll. W4's 24 s stillness twin *crosses into the Rite*: stillness on a heavy morning carries him into the ceremony.
4. **Only after he pulls the rope** does the house stand down and the Rite open with *read who you are*.

The design intent (GAMEPLAN law 5: "the house leads with stillness") is right. The *architecture* makes him declare the low day before it can be honoured.

---

## 4 · Gaps and opportunities: the target architecture

### 4.1 The single map (target, after the changes in §5)

```
                         ┌──────────────────────── ANY SURFACE ─────────────────────────┐
                         │  ⠿ WHERE TO (button on every surface incl. every axis register)│
                         │  ○ rest  (rope: visible mark on Door + river header + Turn foot)│
                         │  two fingers = the Call · ‹ = one step back, never a no-op     │
                         └───────────────────────────────────────────────────────────────┘

OPENING (cold launch, OR resume after ≥ 3 h away, OR the local day changed)
  Waking ─► THE DOOR  weather (unmet · met · quiet) + ONE slot  ─► crossing ─► where he was / river z 0
            slot owner: the arrival engine (W5). W4 asks are kinds in it. Never a page before the weather.
            quiet weather = low day known at open (rope last evening · Call laid down < 12 h · Being in-between)

THE AXIS = the root (W6). One camera, no cuts. ‹ steps out; at root ‹ glides toward z 0; a "return thread" restores
the stack he came from.
   −5  THE LIGHT ─────────── (stand inside ›) ─► LIGHT ceremony
       ↑ stillness gate; the Old Light's region sits at the sky's crown, just beneath ("the light already left")
   −4  THE SKY  ◯ the Old Story (Arc face) · word-stars · constellations · held lights
   −3  a REGION  ◄══ door ══►  GameView of the same room      (one room, two scales)
   −2  a WORLD  (4 faces) ◄══ door ══► STORY page               (one story, two scales)
   −1  the FALL ─► mouth ─► RETURN
    0  THE RIVER (FeedRiver)  head: ONE line slot · chips · sort  │ cards │ foot: Verb Mala
   +1  THE GATE (the deal)
 +2…+8 worlds I–VII (kathas by verb) · VI ─► RETURN · VII ─► dance / APERTURE
   +9  THE CENTRE (the whole house narrated)

THE SIX FACES OF THE BOARD (one focus carried across them by the face strip ≈ ✧ ≋ ◯ ⋮ ▯)
   River (z 0) · Sky (z −4) · Cloth · Arc (Old Story) · Spine (eagle-eye D) · Book
   └─ the eagle-eye (THE WHOLE HOUSE) sees all of them at once ─► one more step: the house as one figure

PLACES (pushed over the axis, each a face or a door; ‹ returns to the exact depth)
   THE ROOMS  ring of 21 (+ inner ring for ripened rooms) · Mirror ✦ and Signal ✧ beneath the dot
              ─► GameView ─► story            (the Unwritten ─► the Waiting Room)
   THE BOOK   contents: from the first page · the ones who told it · the way it came · the tree · every last line
              · the last page · what you kept · what found you · what you carried      (BookView = its margin)
              back cover ─► THE CLOTH
   THE PRESENT  NOW · letters · speak it in (Codex) · river of days ─► This Day · your walk, drawn (Portrait)
   THE BOARD (and the walked chains) · THE DRAW (scopes: everything · room · body · verb · a word)
   THE PLAYERS  lens cards ─► voice rooms │ the turning › │ every voice › (Wall of Voices)
   HOW YOU ARRIVE  who (name · the name that surfaced) · how today (colour · mark) · your road (carry · forget)

CEREMONIES (cross with a bloom; close returns to the exact layer — closeCeremony)
   Rite (any story) · Return (any story) · Gates of Release · Unwinding · Light · Floor · Hall · Seam · Two Doors
   · Triptych · Recitation · Season Letter · name rite · journey ring · Call
```

### 4.2 WHERE TO, redesigned: the Veil of places (G42 + B3, in the 8-row spirit of the original)

**Form.** It stays `TurnOverlay`: same ground (`#08070B` at 0.80, ultraThinMaterial), same `WHERE TO` label, same breathing hand-drawn marks, same *tap anywhere to stay*.

**Changes:**
- The body goes inside a `ScrollView` (fallback only; the target is to fit) with a height budget of **≤ 700 pt at 390 wide** (P4).
- The 24 rows become **four bands** separated by 0.5 pt hairlines at `white 0.06`, with no headings. The list never says which kind a row is; its band shows it (elements "The turn").
- Every row is always present (P3). Its light is set by **B3 tiers** from the hour and from where he stands.
- Measured: band 1 at 5 × 44 = 220 pt, band 2 at 4 × 26 + 52 = 156 pt, band 3 at 4 × 52 = 208 pt, header 80 pt and foot 70 pt, about 734 pt in all. That exceeds the 700 pt budget, so this is where the `ScrollView` fallback applies; band 1 always sits on the glass.

**Band 1 · the day** (rows at 44 pt; lit by the hour, `calendar--day`: *"doors that change with the hour"*).

| Row | Sub (APP-OWN) | Mark | Light |
|---|---|---|---|
| The Rite | `today’s meeting` / `again, with any story` | ◆ | here 0.95 while unmet before noon; open 0.82 otherwise. **Always `.rite`**: on a met day RiteRoute draws `draw(.everything)`; never the Draw |
| The Call | `ask, and something answers` | the Call's own dot-in-ring | open 0.82 always. **New row (law 5, P5)** |
| The Return | `a story you met, met again` | ✦ | ground 0.62 before 18:00, open 0.82 after (W4's hour rule). Colour `#D9B48A`, **not** the room's hex |
| The Gates of Release | `set something down` | ∩ | ground before dusk, open after |
| The Unwinding | `the grip can go` / `tonight, the grip can go` | ∿ | open 0.82 at the new moon or a season's turn, ground 0.62 otherwise (W0 14.5's numbers) |

**Band 2 · the house, by depth** (the axis seen as a list, drawn as *bands of glass*, elements §6.4).
- Four rows of **26 pt**, one per register group, in z order: The Light (−5) · The Universe (−4) · The Feed (0) · The Point (+1).
- The row for **where he stands** swells to 52 pt and shows its sub-line (the canon register sub-lines). The rest show name only, at 0.82.
- The Universe row carries a second 44 pt hit target at its trailing end: the **◯ mark of the Old Story** (W0 14.8 becomes a mark, not a row). VoiceOver: a separate button, `the old story`.
- "The Archive" is renamed **The Feed**, sub `everything as it arrives`.
- A fifth, final band row **⊙ The Whole House** (W6 §6.1) sits at the foot of the column: the house from above, outside depth.
- Choosing a row glides the camera continuously (`axisGlide`). It never pushes.

**Band 3 · the places you keep and play** (a two-column grid of 52 pt tiles in the hub-card style of elements §6.3, "The hidden-until-asked hub": 10 pt dot, Lora 16 name, italic 12.5 sub). Eight tiles:

| Tile | Sub | Absorbs |
|---|---|---|
| The Rooms | `every way in` | — |
| The Book | `the record, page by page` | "What You Kept" (retired into the Book's contents, §4.4) |
| The Cloth | `the pattern nobody designed` | — |
| The Present | `what you sent ahead · speak it in` | "The Codex" row (CodexView becomes the Present's first door, `speak it into the source ›`, under the NOW line) |
| The Board | `carry a question in` | "walk a chain" (its opening sheet offers `or walk a path through the field ›`) |
| The Draw | `let the field choose` | — |
| The Players | `the voices that read` | "The Turning" row and "the voices" row (§4.6) |
| How You Arrive | `name, colour, mark` | — |

All eight tiles are open 0.82. The one he came from is here 0.95.

**Foot:**
- **Left:** `○ rest a moment` (Space Mono 9, `#6E6A78`, a 44 pt button). This is W0 14.21's row, moved where it can never fall below the fold.
- **Right:** `☽ Nityā`.
- **Beneath:** `tap anywhere to stay`.
- **On a low day** (`Round.isLowDay`), `Rest a moment` also appears as the **first row of band 1 at 0.95**. The round's rows drop to ground (0.62); the Call stays open (0.82).

**Count:** 5 + 5 + 8 = **18 places** across 4 bands, fitting one screen, down from 24 undifferentiated rows that do not. Nothing is removed. Every retired row has its new address (the LINEAGE lines are in §5).

**Opening WHERE TO:**
- the `HubTrigger` on **every** surface, including the axis chrome beside ‹, thinning with depth (rupakarshini law 6: 100 → 80 → 60 → 25 → 0 %, and a touch brings it back);
- G12's slow pull on the Door and at the river's top edge (§4.3);
- VoiceOver: the trigger button, plus the magic-tap-adjacent action `where to` on the root.

### 4.3 The pull at the river's top: slow pull opens the Turn, firm pull leans (resolves B5)

At z 0 with the river at its top edge, a downward drag runs both detectors:
- **The Turn:** `pull ≥ 84 pt` **and** `peak |v| < 650 pt/s` **and** the membrane's `push < 0.5` at 84 pt. The Turn opens and the push drains at the membrane's own rate (G15: 0.18/s).
- **The lean:** otherwise. G15 numbers, unchanged.

This is the corpus rule *"the turn needs a slow pull; a firm pull departs outward along the axis"* (elements §6.3). The 650 pt/s figure is proposed here; tune it on the device walk (W8 §6). The `HubTrigger` remains the guaranteed path.

### 4.4 One Book (resolves B2)

**ArchiveBookView is the Book** (W3 §7 stands). **BookView becomes the Book's margin.** Its route `.book` is unchanged, and it is entered from the Book's contents, never from the Turn.

W3 §7.2's contents gain three lines after `the last page`:
- `what you kept` → BookView at the kept lines;
- `what found you` → BookView at W5 §6's rows;
- `what you carried` → BookView at W4 §4.6's sections (the board · the seasons · what you carried · the gates).

The other changes:
- The Book's *back cover* thread already leads to the Cloth.
- `the archive, as a book ›` on the river retires. Its address moves to the Book tile.
- The Recitation's `say them all back ›` stays at the margin's foot.
- GAMEPLAN law 3 ("stays in the Book") becomes literally true.

### 4.5 The way back on the root axis: the return thread (resolves B4, P6)

1. **The return thread.** New `store.axisReturn: [FeedRoute]?`, written in one place: every site that pops the stack to glide (W6 §2.1), when the popped stack was not empty *and* the origin was not the Turn. These are:
   - the Floor's walk-out (`MirrorFloorView:196`);
   - the gift's dance (`ContentCoordinator` → `pendingLaunchRoute .instrument(8)`);
   - W7 §3.3's *dance it*, which uses this instead of a push;
   - the Aperture's "TO THE CENTRE ›";
   - the deep links `gate` and `point/n`.
2. **‹ on the axis**, in order:
   1. In the Universe: step out one scale (`UniverseBack.step`).
   2. Else, if `axisReturn` is set: the glyph becomes `‹ <first three words of the story's title>` (Space Mono 9, `inkTertiary`). Tap → re-push the stored stack (all layers but the last without animation, the last with the dissolve), then clear it.
   3. Else, at the root: glide one register toward z 0, the outward pass of the way in (rupakarshini law 3). **Never a no-op.**
3. **Clearing.** `axisReturn` clears when used, or when a Turn row or a rung is chosen. It holds one stack, not a history.
4. **VoiceOver:** the ‹ is a button labelled `back to <title>`, or `back toward the feed`.

### 4.6 Players becomes the home of every voice

PlayersView keeps the eight lens cards, the two roots and Ash. W0 14.7's `the turning ›` sits under each card. The page gains:
- **At the top:** one line, `the voice that sat with today’s story ›` (W0 14.7's Turn-row logic: the first non-Ash archetype on `storyOfDay`, else Sakshi). It replaces the Turn row.
- **At the foot:** `every voice in the house ›` → the Wall of Voices (W6 §2.5). It replaces both the Turn row and the river-foot link. **The river-foot link is removed:** at 469 cards it is out of reach, and it shares the inward-lean edge (B7).

### 4.7 The Door: one slot, a quiet weather, a visible rest (resolves B9, B10, B11)

1. **One slot, one owner.** W5's engine owns the Door seat. W4's ask kinds (`askYesterday · askNight · askBetween · doorWords · threeDoors · board · quiet`) are kinds inside it, with W4's weights folded into W5 R5. The overrides keep W4's order (letter › season letter › wager). Everything renders **in the slot**: the upper third, above the room glyph, as W4 §3.1 places the ask. **W5 §3.2's "arrival as a page before the weather" is withdrawn** (P11).
2. **A visible rest on the Door.** A `○` button mirrors the dot mark on the opposite corner (dot mark: top 62, left 26):
   - position: bottom 44, left 26; a 9 pt ring, 1 pt stroke `#E5533C` at 0.34, breathing on `breathSoft 14s`, 44 pt hit;
   - VoiceOver: `rest a moment`;
   - it opens `DoorRopeOverlay` and calls `markRopeToday()`.

   The same mark sits in the river's header, after AshMark. This fulfils the corpus guard: *"a reachable control for the rope"*.
3. **The quiet weather: the low day known at the opening.** `Round.isLowDay` is also true at the opening when any of these holds:
   - `bindu.rope.<yesterday>` was set after 18:00;
   - the Call was laid down within the last 12 h (W4 §2.1's own source, carried over the night);
   - Being's last in-between word (W7 §5.5) is one of the heavy ones.

   On such an opening:
   - the Door's slot holds `quiet`;
   - Waking carries nothing;
   - the unmet Door's 24 s stillness twin **does not cross into the Rite**. On a quiet weather it rests;
   - the Door shows the brief's **third weather** (elements §6.3, "the void, which is the rope"): the ground at `#050407`, the room wash halved, `one line is enough ›` lifted to `inkSecondary`.

   It clears on the first story received that day. Nothing is said. *The heavy day closes nothing*: the Rite, the river and every room stay one touch away.
4. **What counts as an opening.** W5's `beginOpening()` also runs when `scenePhase` becomes `.active` and **either** the app was in the background for **≥ 3 h**, **or** the local day changed since it was last active. On such a resume:
   - the Door is presented over the mounted stack (`doorCrossed = false`; the path stays mounted beneath);
   - the crossing lands at z 0, and the old stack is kept in `axisReturn` (§4.5), so last night's place is one ‹ away.

   This makes the morning, the asks, the wager's return and the season letter arrive on a phone that is never cold-launched.

### 4.8 One room, two scales; one story, two scales (resolves T8, B15 in part)

- **GameView ↔ region −3.**
  - A tap on GameView's hero glyph shows, beneath it, `in the sky ›` (Space Mono 9, room colour at 0.7). This is the two-tap rule's naming step. A second tap glides the axis to that room's region (popping to the root with `axisReturn` = this room).
  - In region −3, when he stands near the region's centre, the room's name line (canon) gains `the room ›`, which pushes `.room`.
- **Story page ↔ world −2.** A tap on the room pill in the story header shows `the room ›  ·  its star ›` (Space Mono 9) for 6 s.
  - `its star ›` glides to −2, centred on that star, with `axisReturn` = this story.
  - In the world, the existing door (`TOUCH TO READ`) is the way back.
- **The Return room ↔ the Return ceremony.** The Return's GameView carries, under its story list, `open the return ›` (as the Descent carries `go down through the gates ›`, W4 §4.4). The shared name becomes the rhyme Point world VI already speaks: *this depth and that descent are the same room*.
- **The Old Light ↔ the Light.** The Old Light's region keeps W2's place at the sky's crown. The stillness gate's dawn (`uDwell` bending toward the centre) begins over that region, so *the light already left* lies just beneath *what has not yet been*: past light under future light, one register apart. **No word is added.**

### 4.9 The face strip: the board's six faces, one focus (resolves B15; the emergent move)

`Components/FaceStrip.swift` puts six glyphs in their own hands at the foot of each face:

| Face | Glyph |
|---|---|
| River | ≈ |
| Sky | ✧ |
| Cloth | ≋ |
| Arc | ◯ |
| Spine | ⋮ |
| Book | ▯ |

- **Drawing:** 18 pt glyphs, 44 pt hit each, centred in a 52 pt bottom inset. The current face is at 0.95 and the others at 0.35. Each glyph clears 3:1. It appears on touch and thins after 4 s still (chrome law 6). On the story page it is never shown (the page is for reading; the Turn curl is its sideways move).
- **Tap a glyph → that face, focused on what he was looking at:**

  | Focus | River | Sky | Cloth | Arc | Spine | Book |
  |---|---|---|---|---|---|---|
  | a story | its card scrolled to | its star centred at −2 | the stitch of the day it was received (else its source day) | its Chapter node | its Vertebra bead | its page |
  | a day | that day's first card | — | its column | — | — | its month letter |
  | a room | its chip | its region | its weft | its node | — | its first page in the bodies path |

  If there is no focus, the face opens as it always does.
- **Crossing:** the W0 15.6 bloom in the focus's room colour.
- **VoiceOver:** a rotor `faces`, one item per face.
- **Hosts:** FeedRiver, UniverseView (−4 to −2), ClothView, the Old Story state, HouseView page D, ArchiveBookView.

This is GAMEPLAN §3.2's sentence made into a gesture: *"six faces, each the same board seen differently"*.

### 4.10 Find a story by a word (resolves the 469-story depth gap, P9)

The Draw (W4 §3.4) gains a fifth scope chip, **`a word`** (Space Mono 9), after the body swatches.
- Tap it: a one-line field with no placeholder, or a hold of the ember to speak (`SpeechCapture`).
- Return: the deck holds only stories whose body or title carries the word (whole word, case-insensitive), and **every such story lights across the house** through W7 §6's `litWord` path (card stroke, star ring, Book bead).
- The deck draws in the usual way, never with a count or a list.
- Stillness twin: none needed, because typing is the act.
- VoiceOver: the same field. Its result is announced as the first title drawn. The "join with…" sheet (W1 §4.1) remains the full index.

This makes any remembered phrase three moves from anywhere (Turn → Draw → word) and adds no new surface.

### 4.11 The ring of rooms holds the whole house (resolves B14, B16)

- **Ring sizes.** The 21 canon rooms sit on r = 0.40·side. Rooms that ripen (22–40) sit on an **inner ring** at r = 0.26·side, Sort Order clockwise from −90°.
- **Hit-testing.** Ring glyphs are hit-tested by nearest centre within 26 pt, so a 44 pt touch never lands between two glyphs.
- **Two taps.**
  - First tap on a glyph: its name (Lora italic 12) and blurb (one line) appear beneath the ring, and the glyph lifts 1.08×.
  - Second tap on the same glyph, or a tap on the name: the flood.
  - W2's long-press-for-name becomes this first tap. W2 §12a D's 270° Trace keeps its own drag.
- **The persons tier moves inside the ring.** Under the centre dot, the two marks that turn to him: ✦ Mirror (first person, `#C9A07A`) and ✧ Signal (second person, `#3AADA8`), each 18 pt, 44 pt hit, 34 pt apart. Beneath the dot, `and the field turns to you` (Space Mono 8, em 0.18, ink 0.35). **The divider and the two portal cards after the list retire into the ring**: Mirror and Signal go from three moves plus a long scroll to two moves.
- **The Rooms row's mark** draws thirteen dots, one bright: a mark of "the rooms", never `rooms.count` (B14).
- **One ring geometry.** `RoomRing` is one component, at three densities:
  - RoomSelection (glyphs);
  - the eagle-eye's mandala of seats (W6 §6.2 B: glyphs plus seats);
  - the yantra (W7 §7: glyphs seated by `avarana`).

  All three share the same positions, so a room never moves between figures. Seats obey the two-tap rule: the first tap names (title), the second tap or a pinch-in lands.

### 4.12 The river's head and its edges: one owner each (resolves B6, B7, B8)

- **Head: one line slot.** Under the subtitle, at most **one** line, by precedence:
  1. the low-day lead swatch (W5 §7);
  2. the riverHead arrival (W5 §3.4);
  3. `SeedThread` (an open Leela seed);
  4. the witness line (W6 §2.5).

  Whatever does not show this opening keeps its own home (the swatch under its story, arrivals in *what found you*, the seed in the Book's margin). The chips and the sort stay.
- **Trailing edge at z 0.** The rail is **drawn but not hit-tested** while the river is scrolled away from both edges. Its rungs take touches only within 60 pt of the top or bottom edge (where leaning happens anyway), or after a touch on the rail's own thin line wakes it for 3 s. VoiceOver keeps `walk outward` / `walk inward`. The quiet-room strip and the resting dot own the trailing gutter mid-river.
- **Foot.** The Verb Mala stays pinned. `the voices ›` leaves (§4.6). The #seam speaks only at the foot edge, as W6 §2.2 says.

### 4.13 The story page's foot: one line of doors (resolves B13)

The close conductor keeps its one after-thing. Beneath *What arrived for you?* (his answer stays on paper, unchanged), the remaining doors collapse into **one row**:

`the hall · the floor · the return · the rite`

- Style: Space Mono 8, em 0.2, `inkTertiary`, separated by ` · `, each a 44 pt button.
- `the floor` is present only when sealed (as today). `the return` reads `return` or `sealed · return` (W4 §3.7).
- `read by hand` stays where it is, in the header area. `SwatchUnder` stays the last element.
- **LATER, the emergent form:** rupakarshini law 18, *"paper is where you read; dark is where your reading is reflected"*. Overscrolling 84 pt past the page's foot and holding 1.25 s (G14, with the row as its visible twin) descends into **beneath the page**: a dark register with these four doors, in the Floor's under-dark.

### 4.14 The house as one figure, and the Call: visible doors (resolves B12)

- **HouseYantra (W7 §7).** HouseView's four page dots gain a fifth mark, a 4 pt ⊙ after them. Tapping it opens the figure. VoiceOver: the action `the whole house, as one figure` on HouseView. "One more pinch out" stays as the gesture.
- **The Call** gets the WHERE TO row (§4.2, band 1). The rope's `LAY IT DOWN` stays.

### 4.15 The journey flow and the pools, read as the Feed's skeleton (a-strange-game)

The Feed already holds the journey of A Strange Game. It is scattered, and the redesign above gathers it:

| a-strange-game station | The Feed's place after this pass |
|---|---|
| The Welcome (arrival, commitment press) | the Door: weather, one slot, the Rite's first movement |
| The One (name · higher-self name, immutable) | How You Arrive → `who`: the name, plus W4's name rite (*the name that surfaced*) |
| The Call (Gaia; ask for help) | the Call: now a row of the day's band, as well as two fingers |
| The Leela (Lalita; drops that end in real-world acts) | the Board and the Leela drops in the Door's slot |
| The Road Home (the dwelling; standing place, five doors, the cavity brightening by tier) | the river, plus W3's warming ground. Its *Notifications surface* is W5's *what found you*, held in the Book's margin and never counted ("Three seeds have surfaced" is dropped under the house law) |
| Bindu (the walk to the point) | the axis inward, ending at the centre's narration of the whole house |

**Storage pools → the three sections of How You Arrive** (LATER; P8):
- `who` (essence): name, the name that surfaced;
- `how today` (being): colour today, mark;
- `your road` (memory): carry your road, forget me.

The being pool is also what the Door reads to know the quiet weather (§4.7).

---

## 5 · Recommended changes to the scores (for mechanical folding)

| # | Target | Change | Priority |
|---|---|---|---|
| 1 | **W0 14.5, 14.7, 14.8, 14.21; W3 §4, §7; W4 §3.11; W6 §2.5, §6.1, §10.5** | Replace every "add a Turn row" with WHERE TO as specified in §4.2: four bands, 18 places, B3 tiers by hour and place, `ScrollView` fallback, ≤ 700 pt at 390 wide. Retired rows and their addresses: The Archive → The Feed (band 2) · What You Kept → The Book's contents · The Codex → the Present · The Old Story → the ◯ mark on the Universe band · The Turning and the voices → Players · walk a chain → the Board's opening sheet · Rest a moment → the Turn's foot (and band 1 on a low day). Write each as a LINEAGE line, *carries forward → <new address>*. Build in W0 (rows 1–12 plus the bands), and let later waves add tiles into the bands, never new rows. | **MUST before build** |
| 2 | W0 14.5 / §4.1 GESTURES; W6 §2.1 | `TurnOverlay` must scroll if its content exceeds the screen. Add a W0 Done line: *at 24 dynamic-type steps and at 18 places, every row is tappable on iPhone SE (667 pt)*. | **MUST** |
| 3 | W6 §2.1 | Add a `HubTrigger` to the axis chrome beside ‹ on every register (InstrumentView :321 HStack), thinning with `Immersion` chrome. A touch brings it back. | **MUST** |
| 4 | W6 §2.1; W7 §3.3; W0 14.3 | The return thread (§4.5): `store.axisReturn`. ‹ at the root is never a no-op (step out → return thread → glide toward z 0). W7 §3.3's `pushDissolve(.instrument(8))` becomes popToRoot + glide + `axisReturn` (resolves the W6 ↔ W7 contradiction). The Floor's walk-out, the gift's dance and the Aperture's centre do the same. | **MUST** |
| 5 | W6 §2.1 | The rail's rungs at z 0: hit-testing off while the river is scrolled mid-way; on within 60 pt of either edge, or for 3 s after the rail is touched (§4.12). Add a W6 Done line: *a tap on any card's trailing 28 pt opens the story, never a glide*. | **MUST** |
| 6 | W3 §7, §19.6; W0 15.5; W4 §4.6; W5 §6 | One Book (§4.4): the contents gain `what you kept · what found you · what you carried`, each opening BookView (the margin) at its section. The Turn row What You Kept retires. W4 §4.6 and W5 §6 say "the Book's margin" for BookView. The river's `the archive, as a book ›` retires. | **MUST** |
| 7 | W5 §3.2; W4 §2.3 | One Door slot owned by the arrival engine. W4's ask kinds fold into W5 R5 with W4's weights. Arrivals on the unmet weather render **in the slot**, never as a page before the weather (withdraw "ArrivalDoorPage … a tap continues to the weather"). | **MUST** |
| 8 | W0 4.1 GESTURES (Rope); W4 §3.1 | The rope's visible twin on the Door (the `○` mark, bottom 44 / left 26, spec §4.7.2) and in the river header. Done line: *the rope opens from the Door with no long-press and no Turn*. | **MUST** |
| 9 | W4 §2.1, §3.1; W5 §2.5 R3, §4.8 | The quiet weather (§4.7.3): `Round.isLowDay` is also true at the opening after an evening rope, a Call laid down within 12 h, or a heavy Being word. On it: the slot holds `quiet`, Waking carries nothing, and **the unmet Door's 24 s stillness twin does not cross into the Rite**. It clears on the first story received. | **MUST** |
| 10 | W5 §2.4 (1) | An opening also begins on a resume after ≥ 3 h in the background or across the local day. The Door is presented over the mounted stack, and the crossing keeps the old stack in `axisReturn`. Without this, the wager's return (W4 §4.5), the season letter (W4 §4.1) and the morning ask rarely fire. | **MUST** |
| 11 | W7 §7 | The house as one figure gets a visible door (a fifth page mark ⊙ on HouseView) and a VoiceOver action from HouseView (law 7). | **MUST** |
| 12 | W0 14.21 / W4 §3.11 | The Call as a row of band 1, `ask, and something answers`, opening `store.callOpen`. Gesture unchanged. | **MUST** (law 7) |
| 13 | W4 §3.5 C, §3.11 | The Rite row is always `.rite`. On a met day RiteRoute takes `draw(.everything)` as its story, and the Arrival's `let it go and draw again` is the deck. Never route the Rite row to `.draw` (two doors disagreeing). | SHOULD |
| 14 | W6 §2.1 | The Feed's top-edge pull: a slow pull (≥ 84 pt, peak < 650 pt/s, push < 0.5) opens WHERE TO; a firm pull leans out (§4.3). Add both to GESTURES' collision list. Device-walk check in W8 §6. | SHOULD |
| 15 | W2 §3.3; W3 §12.3; W6 §6.2 B; W7 §7 | One `RoomRing` (§4.11): the canon 21 on the outer ring, ripened rooms on an inner ring at r 0.26; nearest-glyph hit-testing; **two taps** (name, then go) on the ring, the mandala's seats and the yantra; the persons tier (Mirror ✦, Signal ✧, `and the field turns to you`) moves under the dot, and the two portal cards and the divider retire into it. | SHOULD |
| 16 | W2 §3.4; W6 §3 / region −3; StoryDetail header (W2 §3.9 site) | One room at two scales and one story at two scales (§4.8): `in the sky ›` from the GameView hero; `the room ›` in a region; `the room ›  ·  its star ›` from the story's room pill. All glide with `axisReturn`. | SHOULD |
| 17 | W4 §3.7 | The Return row's colour is `#D9B48A`, not the room's hex. The Return room's GameView gains `open the return ›` (the rhyme of world VI). | SHOULD |
| 18 | W4 §3.11, §4.4 | Name the place **The Gates of Release** on screen (Turn tile and three-doors line), so it never collides with the +1 register's `THE GATE`. | SHOULD |
| 19 | W6 §2.5; PlayersView | The Wall of Voices moves to the foot of Players (`every voice in the house ›`). The river-foot link is removed. `the voice that sat with today’s story ›` heads Players. | SHOULD |
| 20 | W5 §3.4; W5 §7; W6 §2.5; RootView | The river head's one line slot, by precedence: low-day swatch › riverHead arrival › SeedThread › witness line (§4.12). | SHOULD |
| 21 | W4 §3.5 C, §3.7; W2 §12; W5 §3.5 | The story page's foot doors collapse into one row: `the hall · the floor · the return · the rite` (§4.13). | SHOULD |
| 22 | W4 §3.4; W7 §6 | The Draw's fifth scope, **`a word`** (typed or spoken), lights every story carrying it through `litWord` and draws among them (§4.10). Done line: *a phrase from any story reaches it in ≤ 3 moves from the river*. | SHOULD |
| 23 | W6 (new §6.5) | The face strip (§4.9): six faces, one focus carried, on River · Sky · Cloth · Arc · Spine · Book; a VoiceOver rotor `faces`. | SHOULD |
| 24 | W0 15.4 #13 | The Rooms row's mark: thirteen dots, one bright, never `rooms.count`. | SHOULD |
| 25 | W4 §3.6; W3 §5.4; SettingsView | How You Arrive is read as three sections: `who` · `how today` · `your road` (the pools). Labels only; no new state. | LATER |
| 26 | W2 §12 / W4 | *Beneath the page* (§4.13 LATER): a G14 descent past the story's foot into a dark register holding the four doors, with the row as its twin. | LATER |
| 27 | W2 §5.7; W6 §8 | The Old Light / Light relation (§4.8): the stillness gate's dawn begins over the Old Light's region. No words. | LATER |
| 28 | DOORS / LINEAGE (W0 §4.3) | One LINEAGE line per moved door in rows 1, 6, 12, 15 and 19, written as *carries forward → <new address>*, so "nothing vanishes" holds through the reorganisation. | **MUST** (with 1) |

---

### Top 10 findings (one line each)

1. As scored, WHERE TO reaches **24 rows in a non-scrolling `VStack`**. Rows 15–24 render off-screen, among them Rest a moment, the Players, How You Arrive (FORGET ME) and the Whole House.
2. **There is no WHERE TO anywhere on the axis**, today or after W6. And at the river's top, W6's outward lean takes over G12's slow pull without resolving it.
3. **W6's root axis makes ‹ a no-op at the gate, the Point and the Light, and loses the story beneath** every glide. W7 §3.3 still pushes a second axis.
4. **Two Books:** W3 builds the Book on ArchiveBookView, while W0, W4 and W5 put the seasons, the board walks, the wagers and *what found you* in BookView ("What You Kept").
5. **The low day is known only after he pulls a hidden rope.** A heavy morning meets asks, wagers and season letters, and stillness at the Door crosses him into the Rite.
6. **Openings mean cold launches,** so on an iPhone that resumes for days the Door, the asks, the wager's return and the season letter rarely arrive.
7. **W5 puts an arrival page before the unmet Door's weather.** That is a lobby in front of the day's meeting, and the Door's slot has two engines.
8. **W6's rail rungs at z 0 cover the trailing 28 pt of every card,** alongside W3's quiet strip and the dot: four owners on one edge.
9. **Gesture-only or buried places:** the house as one figure (pinch only), the Call, Mirror and Signal (at the foot of 21 rooms), the Portrait and the Aperture. There is no way to find one of 469 stories by a remembered phrase.
10. **The six faces of the board are six separate routes.** A face strip carrying one focus (story, day, room) across River, Sky, Cloth, Arc, Spine and Book is the missing spine of "one board, many faces".
