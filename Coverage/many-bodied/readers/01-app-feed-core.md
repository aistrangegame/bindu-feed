# 01 · The app as built — the Feed-core half

Reader 01. Source: `/home/claude/bindu-feed/Bindu Feed/Bindu Feed/` (paths below are relative to that root). All line numbers are from the files as they stand on `main`, 12 Oct 2026.

## Files read

- **CLAUDE.md** §1–9 (lines 1–367), with §10 doctrine skipped as asked.
- **App/** (3): BinduFeedApp, ContentCoordinator, Navigation.
- **Store/** (1): FeedStore (all 1885 lines).
- **Reception/** (4): Reception, ReceptionView, SignatureViews, FeedStore+Kathas.
- **Models/** (2): Models, Sky.
- **Services/** (4): AirtableService (all 1382 lines), KeychainService, HeartbeatService, SpeechCapture.
- **Rooms/** (6): RoomView, RoomTravel, RoomStay, RoomVoices, RoomArchive, RoomFigures.
- **Components/** (26): every file.
- **Screens/** (38): every file. Some were read with pure `//` comment lines removed: LightView, DoorView, PracticeDoorView, Rite*, Present, Call, Mirror, Signal, AshCompose, AshVoice, Players, Turning and Return. The code itself was read in full, and the original line numbers are kept.

Some code was only skimmed, because it is pure Canvas drawing:

- RoomFigures.swift lines 200–892.
- The body of every draw function in GatheringScene.swift.
- The padding and colour styling lines in SettingsView.

I grepped those three to confirm none of them reads data or state. The only exceptions are `ashDays` in RoomFigures and the text "nothing between them" (RoomFigures:532). Nothing I was assigned is missing.

---

## 1. Surface inventory

### Launch chain (ContentCoordinator)

**WakingView** (Components/WakingView.swift)
- **When:** every cold open, over everything (ContentCoordinator:104).
- **Gesture and content:** none. The motes gather into the ember over 1.65 s.

**TokenEntryView**
- **When:** shown only when there is no PAT (ContentCoordinator:30).
- **Debug:** DEBUG builds add doors into the Instrument, sky, light, point and the Rite (TokenEntryView:79–104).

**DoorView**, on every open (ContentCoordinator:38). It has two weathers:

- **Unmet** — today's story has not been met in the Rite and was not dismissed (DoorView:75–88).
  - It shows the room glyph, the title of `storyOfDay()` and "touch to receive". A tap opens RiteView inline (DoorView:47).
  - "not today · enter the field ›" calls `markRiteDismissedToday` (DoorView:140).
  - **Content:** `store.storyOfDay()` (FeedStore:1355), a rendezvous hash over `store.stories`. That list has already passed through the rhyme gate.
- **Met** — the Door becomes PracticeDoorView (DoorView:104–107).
- **Gestures on both weathers:**
  - Pull down past 84 pt opens the Turn (DoorView:187).
  - A 1.1 s long-press opens the Rope overlay (DoorView:178). The Rope marks a low day (DoorView:300) and offers three exits: WALK THE POINT → `instrument(1)`, LAY IT DOWN → the Call, RETURN TO THE DAY.
  - On the new moon a 50% dark veil sits over the Door (DoorView:53).
- **DoorAir** (Components/DoorAir.swift) is layered over the Door:
  - a 6% tint from the room of the last met story (`lastMetRoom`);
  - "tratak": 11 s with no touch makes a white light drift behind the dot;
  - the **Suit mark**: a tap cycles Red, Black and Blue (FeedStore:474). White is earned only when a Red or Black day ends in a sealed Rite (FeedStore:482).

**PracticeDoorView** (Screens/PracticeDoorView.swift)
- **Pick:** five weighted kinds, plus a Leela seed when one has found its moment (FeedStore:1097–1167).
  - **Threshold** — Type=Threshold Sentence, source not Bindu.
  - **Practice** — Type=Practice Invitation.
  - **Gaia seed** — Type=Gaia Seed.
  - **Story** — any `store.stories`.
  - **Bindu dot**.
  - **Leela** — Type=Leela. It offers "offer it" / "hold in silence" and writes App Activity Note or Silence Held, linked to the drop (FeedStore:978).
- **Gesture:** tap anywhere to cross (PracticeDoorView:58).

**Crossing.** The eyelid blink, then RootView. Two seconds later three things are tried in turn, and each gives way if an earlier one landed:
- `offerLetter(at: .door)`;
- `offerFieldNotice()`, a Gaia Mirror Entry from table `tbll9fXzLSa44XqUi`;
- `offerGift()`, the gift triad (ContentCoordinator:177–181).

**Always-on overlays** (ContentCoordinator:71–107):
- **CallView** — two fingers held for 0.8 s anywhere (Components/CallGesture.swift:254–256).
- **LetterArrivalView**.
- **GiftTriadView** — gifts a story, a Mandala energy and a Field song. The song opens `instrument(8)`.
- **FieldNoticeView**.
- **Two-finger swipe right** — on a story this is the Gaia inversion: the story runs back to its raw memo (StoryDetailView:294).

### RootView: the Feed, or "river" (Screens/RootView.swift)

- **Header** (RootView:148–172):
  - HubTrigger, which opens the Turn;
  - the wordmark "A Strange Feed";
  - a PointyTrail(.line);
  - the AshMark, leading to `.ash`;
  - the subtitle "the field reads the Codex back".
- **Below the header:**
  - **SeedThread** — an open Leela seed. He can return with a line (FeedStore:491). That writes an App Activity "Note".
  - "the archive, as a book ›" → `.archiveBook`.
  - **CommunityFilterBar** — "All" plus 13 room chips (Components/CommunityFilterBar.swift).
  - **FeedSortToggle** — MOST ACTIVE (Last Activity Date) or MOST RECENT (Source Date).
  - **StoryCards** → `.story`.
- **Content:** `store.feedStories`, from `fetchStories(room:sort:)`, which is filtered by the rhyme gate (AirtableService:402).
- **Lalita play** — rarely, one line he kept, or the closing line of the day's story, dances across a cream screen (RootView:51–56, LalitaPlay.swift).
- **Homecoming glow** — when a ceremony closes, a warm glow and a 136.1 Hz tone (RootView:95–102).
- **Deep links** — `bindufeed://` rite, return, light, gate, point/n and story/id (FeedStore:1628–1657).

### The Turn: one menu for the whole app (Components/TurnOverlay.swift:36–49, HubOverlay.swift)

- **Rows:**
  - Rite;
  - Rooms;
  - Archive, which pops back to the Feed;
  - Universe → `instrument(-4)`;
  - Light → `instrument(-5)`;
  - Point → `instrument(1)`;
  - What You Kept;
  - The Present;
  - The Codex;
  - Unwinding — shown only at the new moon or a season turn;
  - Players;
  - How You Arrive.
- **Inside the app** the Turn passes `unmet: true`, so the Rite row always shows (HubOverlay:15).
- **The Nityā line** — tonight's Nityā is named at the foot of the menu (TurnOverlay:109).

### Story surfaces

**StoryDetailView** (`.story`) — the heart. In order on the page:

1. **ReceptionView**, layered over the page (StoryDetailView:237–245). It runs the room's grammar until the grammar finishes or he taps "read it plainly".
2. **The page.** It shows:
   - the pill, the codex line and the date;
   - the **rewind spiral**: hold it 2.2 s and the page shows the raw memo (StoryDetailView:393–423);
   - a "found ∞" mark;
   - the title and flairs;
   - the body, in one of three sizes, chosen by pinch or spread (StoryDetailView:118–127): the essence, which is the excerpt; the transmission; or the memo.
   - "read by hand";
   - inside the body: long-press a paragraph to keep a line (StoryDetailView:522); the hide-and-seek ∞; and an ember on paragraphs he has kept from.
3. **The signature block** (StoryDetailView:584–610).
4. **Resonance ▲** (StoryDetailView:768–827). A tap PATCHes Resonance. A 1.5 s hold opens the **Resonance Depth** overlay: closing line, then threshold sentence, then the Resonance Voice. When it dissolves it writes `Last Depth Date`.
5. **"The field gathers"** marker. The field comments then reveal one at a time (StoryDetailView:629–659). An avatar tap leads to `.turning`.
6. **Teacher, once** — a Learning persona (StoryDetailView:142).
7. **Grace, once** — a Mandala moment or Learning completion within 3 days of the story (StoryDetailView:153).
8. **Answered in silence** — "you answered this in silence".
9. **AshPostedCards**, with voice playback.
10. **"the hall of perspectives ›"**, shown only when he has called today (StoryDetailView:190).
11. **AshEntryRow** "What arrived for you?" → `.compose`.
12. **Only if he has sealed words on this story:** "you sealed this once · return ›" → `.returnCeremony(story)`, and the **FloorDoor** → `.mirrorFloor` (StoryDetailView:207–221).

**Writes from StoryDetail:**
- Resonance and Last Depth Date (Feed row PATCH);
- `Kept` rows (FeedStore:817);
- App Activity: Story Resonated (first resonance only), Kept, Read by Hand;
- local stores: RhymeGate.received, foundStories, the grace/teacher "shown" sets, and dwell.

**The other story surfaces:**

- **ReadByHandView** (`.readByHand`)
  - A finger rests on the glass and the words step on at the room's own pace (ReadByHandView:41–48).
  - Lifting the finger leaves an ember where he stopped. A double-tap keeps the sentence.
  - The close shows "where you stayed" (the top 3 sentences), then "This came through you" plus the Codex id and date, then "— Ashrey". A suit story says "too" and drops the signature (ReadByHandView:269–281).
  - **Writes:** stay seconds to UserDefaults, App Activity Read by Hand, Kept.
- **AshComposeView** (`.compose`)
  - Hold the ember 2.3 s to release.
  - Empty text means a reply in silence: App Activity Silence Held (FeedStore:506).
  - Otherwise an Ash Comment is posted, Last Activity Date is PATCHed and App Activity Ash Replied is written.
- **HallView** (`.hall`)
  - An inverted tree with one branch per voice and the first sentence of each.
  - "the eleventh" holds his own perspective. Holding it posts an Ash Comment, and the screen closes on "I already did."
- **MirrorFloorView** (`.mirrorFloor`)
  - Three holds down, then LOOK, then "What in you was this story about?" in one word.
  - The word is mirrored, then offered as a vow "I carry X". Carving it calls `writeVow`, which writes a Mirror Card Vow.
  - "walk out into the sky" logs Story Met and pushes `instrument(-2)` (MirrorFloorView:194–196).
- **ReturnView** via ReturnRoute (`.returnCeremony`). The Return/ folder belongs to the other reader. On my side:
  - ReturnRoute (RootView:367–419) shows "nothing has returned yet" when nothing is sealed.
  - A ring needs non-empty reply text. It writes `Return` + `Return Answer` and App Activity Return (FeedStore:1750).

### Rooms

- **RoomSelectionView** (`.rooms`)
  - Twelve portals with sortOrder ≤12, then the 13th full width (sortOrder==13), the divider "AND THE FIELD TURNS TO YOU", and the Mirror and Signal cards.
  - Entry is a flood transition.
- **GameView** (`.room`)
  - One room at a time, with chevrons cycling all 13.
  - It shows the hero glyph, the authored "poetry stats", a sort control and the room's StoryCards.
  - **Room stay:** at 60 s the room settles; at 240 s it turns its premise (`RoomStay.turn`) and RoomTurnMark draws over the glyph (GameView:112–124, 207–216).
  - **Content:** `fetchStories(room:)`, which also passes through the rhyme gate.
- **MirrorView** (`.mirror`)
  - The day's card from Type=Mirror Card, chosen by rendezvous hash. This includes his own carved vows (900 band).
  - "DRAW ONCE MORE" can be used once a day.
- **SignalView** (`.signal`)
  - The day's Signal: arriving, then received with line-by-line reveal, then gone.
  - LEAVE, then "ONE A DAY · RETURN TOMORROW".

### Players and the voice rooms

- **PlayersView** (`.players`) — eight lens cards, two roots, and the Ash card. All of them lead to `.home(archetype)`.
- **RoomView** (`.home`) — one voice's mathematics at four registers (Rooms/RoomView.swift).
  - **The registers:** 0 met · 1 the figure · 2 what it has said · 3 the turn.
  - **Gestures:** vertical drag moves between registers; horizontal drag is the voice's own gesture, set out in the RoomFigures header lines 9–20.
  - **Register 2** maps every comment that voice has made onto its figure. One tap arms a mark and names it; a second tap opens the story's comments; a card tap shows one comment; a tap on the ground rises.
  - **Content:** `fetchArchetypeComments`; for Ash, his comments plus Return Answers.
  - **Ash's own room** is his days as a spine (`AshSpine`).
- **TheTurningView** (`.turning`)
  - **Reached only** by tapping a comment avatar.
  - Trace the ∞ by holding 2.9 s; the room dawns; "WHAT X HAS SAID" resolves.
  - When complete it offers a Turning letter (TheTurningView:334).
- **AshVoiceView** (`.ash`) — every Ash Comment and Return Answer, with the story and reply context. A tap leads to the story.

### Records he keeps

- **BookView** (`.book`)
  - Kept lines, each with an optional margin word (PATCHes Comment Body).
  - "what keeps calling" appears when a word recurs across three or more rooms (FeedStore:865).
- **PresentView** (`.present`)
  - **Above the NOW line:** sealed forward letters, plus "write forward" with six seal conditions.
  - **Below it:** the Codex river by day, coloured by category. "write back to this day" seals a letter with the condition `back(day)`.
  - Links to Portrait and Weave.
- **PortraitView** (`.portrait`)
  - A year ring and day glyphs built from App Activity marks.
  - A month letter answered by "it lands", "say more" or "leave my own word". The last writes a Codex row.
- **WeaveView** (`.weave`)
  - The front is the Atman scarf: months down, rooms across, a knot where he sealed, a ring where he returned, brighter where met.
  - Drag to flip. The back is the Brahman weave, its voice threads drawn from storyStats.
- **ArchiveBookView** (`.archiveBook`)
  - Every dated story, oldest first. The paper yellows with the story's age.
  - Drag to turn the page. The middle page is a door to `instrument(-1)`.
- **CodexView** (`.codex`)
  - Speak (on-device SpeechCapture) or write, then hold to give.
  - The words become a Codex row with `Source App = Bindu Feed` (AirtableService:1132). "given from here" lists those rows.
- **UnwindingView** (`.unwinding`)
  - Up to eight things he once gripped: Ash comments, carved vows, ring answers, kept lines.
  - Each is released by the opposite of the gesture that made it: lift, pinch, or turn back.
  - Writes App Activity Released.

### Ceremonies held in Screens/ (models in Light/ and Rite/)

- **RiteView** — five movements:
  1. Arrival.
  2. Reading — paragraphs light one tap at a time (RiteView:207–288).
  3. Gathering — the real voices in canon order, with the Rite budget tiers on return.
  4. Recognition — a recorded voice plus his typed words.
  5. Sealed — with optional "seal it forward", a letter 90 days out.

  **Writes:**
  - App Activity Story Met (FeedStore:1304);
  - an Ash Comment with Audio Reference;
  - the Rite word, kept for the Dance;
  - White suit, if earned.
- **LightView** — the stillness gate, then hold, then the sky of scenes, then the scene (anchors, a carved Declaration, the landing).
  - **Writes:** Veil Lifted, linked to the scene; `writeVow` from the carved beat; a sealed-forward letter.
- **SettingsView**
  - Name, colour "today", mark, sound, a link to the voice, "YOUR ROAD" (share road, forget me) and change token.
  - The mood colour and name are display only.

---

## 2. Game mechanics that already exist

For each mechanic: the move, the response, and whether doing it changes anything elsewhere.

| Mechanic | Move | Response | Effect elsewhere |
|---|---|---|---|
| **Room grammars** (ReceptionView) | Thirteen gestures: choose a side; stay away; wait for the third door; hold to peel; tap backward; stay; ask in the gaps; trace in the dark; pass on; widen; gaze; touch the seam; hand on | Story revealed; the page dissolves up | **Yes:** marks RhymeGate.received, then `revealRhymes()` reveals that story's suit stories in the river (StoryDetailView:550–554). Nothing else. |
| **Signatures** (SignatureViews) | Twelve, dealt per room | See below | Only sealedLastPage reads elsewhere (calledToday). cordCut pushes the next unreceived story. |
| **Read by hand** | Finger rests; double-tap keeps | "where you stayed" plus authorship reveal | Kept lines feed Book, Lalita play, Portrait, Unwinding. Stays are written (FeedStore:845) and never read again. |
| **Keep a line** (long-press a paragraph) | Choose a sentence | An ember in the margin | Book; "what keeps calling"; Lalita play; Portrait "say more"; Unwinding. |
| **The Call** (two fingers) | Choose a state word, lay it down (hold 2.6 s), "go down" (holds of 1.3 s) | One of his own Codex passages, signed first by an archetype, then "— Ashrey · date" | **Yes:** `calledToday` opens the Hall on every story and the sealedLastPage signature, and lands any call-sealed letter. Logs App Activity Called. |
| **Letters across time** | Seal forward (Present, Light, Rite) or back to a day | A gold light descends when the condition holds | Conditions read the Door, the Veil (InstrumentView:405), the Turning, the Call, the new moon, absence. Back letters ring that day in the Present river. |
| **Kept → Book** | Margin word | Shown back | None beyond the Book. |
| **Portrait** | Tap a month; answer the letter | Ring, glyphs, letter | "leave my own word" writes a Codex row. |
| **Weave** | Drag to flip | Front and back | Read-only; reflects sealed, returned and met. |
| **Hall** | Add the eleventh perspective | "I already did." | Posts an Ash Comment, so the story becomes sealed and Return plus Floor appear. |
| **Floor (Mirror under the floor)** | Hold three times, one word, carve | A vow | **Yes:** the vow enters the Mirror pool and may come back on some future morning. Story Met moves the day to met (Door weather, axis seam). |
| **Unwinding** | Lift, pinch, turn back | "Only the point remains." | Only removes the item from future Unwinding lists (`released`). |
| **Gift triad** | Take a story, appreciate an energy (hold), dance a song | Story or Dance opens | None recorded. |
| **Turning** | Trace ∞ (hold 2.9 s) | Dawn; the voice's words | Lands any Turning-sealed letter. |
| **Pointy** | — (no move) | A trail: line in the Feed, circle in Rooms, ∞ in the Turning | None. |
| **Lalita play** | — (no move) | A kept line dances | None. |
| **Waking** | — (no move) | The ember assembles | None. |
| **Room stay** (GameView) | Stay 60 s, then 240 s | Settles, then turns its premise | None; nothing is recorded (RoomStay comment, lines 4–10). |
| **Room travel and archive** (RoomView) | Vertical registers, lateral gesture, arm then open a mark | The figure answers the hand; comments shown | None; read-only. |
| **Resonance and Depth** | Tap, or hold 1.5 s | Count +1; the depth overlay | PATCHes Resonance and Last Depth Date. The first resonance writes App Activity. Resonance drives Room and Turning stats. |
| **Hide-and-seek** | Read the day's story 30 s, follow ∞ | Jumps to an older unmet story from another room | Marks it found; "found ∞" appears on it. |
| **Leela seed** | Offer it, or hold in silence | The thread opens at the top of the Feed | Taking it later writes "A seed returned". |
| **Rope** (Door long-press) | — | Breath, then the line, then exits | Marks a low day, so no seed that day. |
| **Suits** (Red, Black, Blue, White) | Tap the Door mark | The mark is coloured | A sealed Rite turns Red or Black to White. **Nothing else reads the suit** (only DoorAir:40). |
| **Mood colour** (Settings) | Pick | Ember and compose colours | Display only. |
| **Codex give** | Speak or write, hold | "It is in the Codex now." | A Codex row. No path back into a story inside the app. |
| **Tratak** | Stay still 11 s at the Door | A light moves behind the dot | None. |
| **Field notice** | Tap through three positions | Signed "— the field" | Never shown again. |
| **Grace and Teacher** | Read | A margin note, once | Never shown again. |

**The twelve signatures** (SignatureViews; how each is placed: StoryDetailView:584–625):

- **sealedLastPage** — the facing page opens only on a day he has called.
- **alreadyDid** — "wake up" / "I already did."
- **secondPiece** — the Resonance Voice arrives after 20 s.
- **missingNote** — after 7 s still, a root tone sounds.
- **layersOnReturn** — dwell of 180 s or 480 s surfaces Lalita's line, then the first line of the memo.
- **everyPath** — the first paragraph is ghosted, then settles.
- **foundPage** — an old line, dated, mid-story.
- **cordCut** — a cut cord pushes the next unreceived story.
- **emptySummit** — a hold, or stillness, climbs the slope.
- **alreadyMended** — tap the cracked word.
- **zeroGap** — the closing line converges.
- **dotBecomesPlace** — a prelude before the grammar.

---

## 3. Every restriction in this half

**C** = collapses: it hides content or blocks access. **P** = pacing or condition: it shapes time but everything stays reachable.

### The rhyme gate and what hides stories

1. **C · RhymeGate.arrange inside `fetchStories`** (AirtableService:400–402; Reception:196–230).
   - A suit story is dropped from every list until its `Rhymes With` host is in RhymeGate.met (App Activity Story Met) or RhymeGate.received (UserDefaults `bindu.kathas.received`).
   - Because it filters at fetch time, **the suit stories are missing everywhere**:
     - the Feed river (RootView:182);
     - every GameView room (GameView:488);
     - `store.stories`, and with it the Rite's `storyOfDay` (FeedStore:1355), the Door's unmet story, the Practice Door "what found you", the Gift story;
     - the Universe sky and rebuildUniSky (FeedStore:1674), ArchiveBook, Weave;
     - echo, foundPage, nextThread, seekClue;
     - `resolveLink`, so a `bindufeed://story/<suit id>` deep link "arrives nowhere" (FeedStore:1650–1656).
   - The only reads that skip it are `fetchStoriesByIds` (AirtableService:618, used by AshVoice and Turning for story titles) and `revealRhymes()`.
2. **C · Met only refreshes at launch.**
   - `RhymeGate.met` is set from `metStoryIDs.didSet` (FeedStore:56–58).
   - `metStoryIDs` loads only at bootstrap (ContentCoordinator:198).
   - `logStoryMet` (FeedStore:1304) does **not** add to `metStoryIDs`.
   - So a story met in the Rite or the Floor opens its rhyme only on the **next cold launch**.
   - The Rite's Reading also never marks `RhymeGate.received` (RiteView:207–288).
3. **C · Ask-to-see: rhyme placement.**
   - `arrange` seats a revealed suit story directly after its host *when the host is in the same list* (Reception:222–228).
   - On "Most Recent" sort, or in a filtered room, it simply joins wherever the host sits.
   - The rhyme itself is never **shown** as a rhyme on either story. The relationship is used only as a key.
4. **C · echo, nextThread and seekClue exclude met or received stories.**
   - `echo(for:)` takes only unopened stories from other rooms (FeedStore+Kathas:17–22).
   - `nextThread` takes only unreceived ones (FeedStore+Kathas:52–60).
   - `seekClue` works only in the day's story, and only toward older, unmet, unfound stories from other rooms (FeedStore:604–622).
   - All three are pacing in spirit, but between them they pull only from the unopened.

### Gates on surfaces and routes

5. **C · Hall of perspectives:** shown only when `calledToday` (StoryDetailView:190; FeedStore:907).
6. **C · sealedLastPage:** the witness line and the facing-page button stay disabled until he has called today (SignatureViews:51; StoryDetailView:587).
7. **C · Unwinding:** the Turn row is shown only within a day of the new moon or a solstice or equinox (TurnOverlay:46, 60–61). There is no other route.
8. **C · Return and Floor door:** only on a story he has sealed (StoryDetailView:207). This is a condition, but it is the only way into the Floor.
9. **C · Turning words:**
   - "WHAT X HAS SAID" is invisible until the trace hold completes. Partial light from 55% (TheTurningView:369–392).
   - **There is no stillness path:** the hold is required.
10. **C · Comment resonance:** the ♡ control shows only when resonance is >0 (CommentCard:655, ReplyRow:251). A comment at zero cannot be resonated.
11. **C · Practice Door "what found you":**
    - The story is shown, but a tap crosses to the Feed and never opens that story (PracticeDoorView:58, 285–314).
    - The kind needs `store.stories` loaded, so it is often unavailable (FeedStore:1136).
12. **C · Turning has one way in:** only via a comment avatar (StoryDetailView:709). It is not in the Turn or Players. Players go to RoomView instead.
13. **C · Thirteenth room:** RoomSelection shows it only if a room has `sortOrder == 13` (RoomSelectionView:32).

### Pacing in the grammars and signatures

14. **P/C · Ripens unwatched (The Garden):**
    - One paragraph ripens for every **10 minutes away** (ReceptionView:236).
    - A first visit shows one paragraph and seed-dots.
    - The only other way through is "read it plainly".
15. **P · The Dress (The Forgetting):** a fixed 32 s drain (ReceptionView:502). "read it plainly" escapes.
16. **P · Other grammar timings:**
    - dwell = 4 s + words/2.6 (Reception:253);
    - the Watcher's third door after 6 s still (ReceptionView:345);
    - Signal tratak: 3–10 s still, or a 2.6 s hold (ReceptionView:837–849);
    - The Body warms after 8–14 s still (ReceptionView:669);
    - Peel needs a 1.25 s hold or dwell + 4 s;
    - Pauses: 5.5 s gaps (ReceptionView:552).
17. **P · Grammar applies only with ≥2 paragraphs** (StoryDetailView:537–540); a one-paragraph story skips reception.
18. **P · Signature timings:**
    - secondPiece after 20 s (SignatureViews:101);
    - DwellLayers at 180 s and 480 s of total dwell (SignatureViews:146, 154) — dwell, not visits, as the house law asks;
    - MissingNote after 7 s still, at most once every 24 s;
    - EmptySummit climbs slowly while still.

### Daily, rare and once-only limits

19. **P · Once a day:**
    - Mirror draw, once a day (MirrorView:143, 204–262).
    - Signal, one card a day, with the copy "ONE A DAY · RETURN TOMORROW" (SignalView:592).
    - storyOfDay, one Rite story a day (FeedStore:1355).
    - Rite once the day is met: once met or dismissed, the Door turns to the Practice Door (DoorView:75–78).
20. **P · Rare arrivals** (FeedStore):
    - Leela: one open in four, never two days running, never on a rope day, never twice the same, AFTER and NOT BEFORE conditions (FeedStore:952–975).
    - Gift: a 3-day cooldown, then 1 in 6 (FeedStore:546–556).
    - Field notice: a 7-day cooldown, then 1 in 3, each notice shown once ever (FeedStore:566–578).
    - Lalita play: a 5-day cooldown, then 1 in 20 (FeedStore:582–589).
21. **P · Once ever:** grace per story (FeedStore:421–438); teacher per story (FeedStore:443–456).
22. **P · Hide-and-seek glow:** after 30 s on the page (StoryDetailView:272).
23. **P · Room stay:** 60 s and 240 s; leaving resets them (GameView:112–124; RoomStay:12–13).
24. **P · Holds**, all draining on early release:
    - Resonance Depth 1.5 s;
    - Compose 2.3 s;
    - FloorDoor 1.25 s;
    - Call 2.6 s and 1.3 s;
    - Turning 2.9 s;
    - rewind spiral 2.2 s.

    **Equal path missing:** HoldEmber (Components/HoldEmber.swift) and FloorDoor have no accessibility action and no stillness path. HoldPress has one (Reception:319).
25. **P · Letters:** each opens only when its seal condition holds (FeedStore:685–701). A letter whose arrival he closes without touching stays waiting.
26. **P · Light gate:** 4.6 s of stillness (LightView:93, 689–695).
27. **P · Unwinding:** up to 8 items, newest first (FeedStore:775–777).
28. **P · Rite budget:** on a return (depth>0) some voices are "passing" or "silent" (RiteGatheringView:200–206 via Rite/RiteBudget.swift:51). **It thins what is shown**, which is close to a collapse.

### Data filters

29. **Data filters:**
    - `Status='Live'` on every read.
    - The Codex river drops the category "Health" (AirtableService:1084, 1118).
    - Learning drops therapy rows (AirtableService:1359).
    - The Practice Door's Bindu dot is never doubled.
    - A threshold sentence never repeats back to back (AirtableService:1016).

### Counts shown on screen (against the house law "nothing counted")

- StoryCard `♡ n ↳ n` (StoryCard:406–411).
- StoryDetail resonance number (StoryDetailView:811).
- GameView `n · 13 · all rooms` (GameView:164), plus the authored stats and the fallback counts.
- RoomView stats and legend: "N fields", ♡ total, "N stories · none twice", "X of N" (RoomView:487–493, 657–673).
- Turning stats (TheTurningView:198–205).
- AshVoice "entries left / fields entered" (AshVoiceView:160–164).
- Unwinding "1 of N" (UnwindingView:228).
- Return "i / N", "N voices answered" (ReturnView:388; Return/ReturnPatina.swift:160).
- Rite recognition timer mm:ss (RiteRecognitionView:517, 547).
- Comment ♡ n.

---

## 4. Where the stories live

**Every list starts at `fetchStories`.** It reads Type=Story, Live, optionally one room, and sorts by Last Activity Date or Source Date, descending. Then the rhyme gate filters it.
- `store.stories` is the whole set; `store.feedStories` is the filtered, sorted view (FeedStore:20–25, 158–175).
- Stories are **not in bootstrap.** They load when RootView appears (RootView:44–47), or on the Door's unmet path (DoorView:80).

**Surfaces that show stories:**
- the Feed river, with room filter and sort;
- GameView rooms, sorted Most Recent by default;
- ArchiveBook, oldest first, only stories with a `sourceDate`; an undated story never becomes a page (ArchiveBookView:19);
- Weave, as motifs;
- the Universe (other reader);
- the Practice Door (title only);
- the Gift triad (prefers unmet);
- the Rite (one a day);
- the Return (sealed stories only);
- the Door's unmet face;
- hide-and-seek targets;
- the cordCut next thread;
- the Signal echo — a closing line only;
- foundPage — a first sentence and date only;
- Lalita play — a closing line;
- Book, Hall, Floor and Read-by-hand, each reached from a story.

**Surfaces that never show a story body or title:**
- Mirror (cards), Signal (transmissions), the Call (Call passages, his own words).
- Codex and Present (Codex titles, not Feed stories).
- Portrait (rooms and voices only), Settings, Players.
- Light (scenes), Unwinding (his own words).
- RoomView shows story titles as a mark's name and a card heading, never the body.
- The Turning's WordCards show the title but it **cannot be tapped** (TheTurningView:513–523).

**The suit stories** (Sort 124–137). They are filtered by the gate described in §3 item 1, but beyond that:
- `Suit` is never rendered. ReadByHand changes "you" to "you too" and drops "— Ashrey" (ReadByHandView:269–281).
- StoryDetail hides the Codex number, and pinch never opens a memo for them (StoryDetailView:123, 341).
- **Where else they could appear once ungated**, because each of these already reads `store.stories`:
  - the Door's unmet face and the Rite (`storyOfDay`);
  - the Practice Door "what found you";
  - Gift, echo (the line before the Signal's question), foundPage;
  - the hide-and-seek clue, which needs a `sourceDate`;
  - Weave, ArchiveBook (if dated), the Universe sky.

  They cannot appear in the Return (nothing of his is sealed on them yet), in the Turning or voice rooms unless voices have commented on them, or in Hall or Floor until he seals them.

---

## 5. Islands that don't talk to each other

1. **Kept lines vs the Rite and Return.** Kept lines feed only Book, Lalita play, Portrait and Unwinding. The Return's prompt and the Rite budget ignore them; the RiteBudget comment admits "kept" is a proxy (RiteBudget:65–68).
   **Loop:** a kept line could steer which voices hold the Rite, or become the Return's quote.
2. **Stays from read-by-hand** are written and never read again (FeedStore:845–860; `stays(for:)` has no caller).
   **Loop:** where he stayed could set the next story's grammar pace, or which line Lalita plays.
3. **Suits (Red, Black, Blue, White)** are read only by DoorAir. **The mood colour** in Settings is read only for display.
   **Loop:** the suit or mood he arrives in could pick the river's first story, choose its room grammar, or weight the Practice Door kinds.
4. **Room stay** — the 240 s premise turn records nothing.
   **Loop:** staying could open that room's next story or its rhyme. This is a condition that lights things up, not a lock.
5. **RoomView (voice rooms)** is read-only and never links to StoryDetail. Arming a mark names a story but cannot open it.
   **Loop:** the second tap could open the story itself, turning the voice room into a door into the river.
6. **The Turning** sits outside the Turn menu and Players, and its WordCard titles are dead.
7. **The Call's chosen state word** goes nowhere except choosing the passage. It is never even logged (FeedStore:909–919).
   **Loop:** the state could tint the river or choose which grammar receives the next story.
8. **Codex give** writes a raw Codex row (no Status), with no in-app path from that entry to a story.
   **Loop:** "the field is reading it" could become a visible state, and a new story from it could land as a letter.
9. **Gift, Field notice, Grace, Teacher** each arrive once and leave no trace anywhere else.
10. **Unwinding `released`** only filters the Unwinding itself.
    **Loop:** a released vow could leave the Mirror pool; a released kept line could fade from the Book.
11. **Universe filaments** (UniverseView:233) write Type=Filament rows that no surface in my half reads.
    **Loop:** a filament drawn between two stars could set the river order, or show the rhyme between them.
12. **The Signal and Mirror cards** are their own pools, with no tie to the day's story or room. Only the Signal room *grammar* borrows an echo.
13. **The rhyme itself** is never drawn on either the host or the suit story.
    **Loop:** after a story is received, show its rhymes — a thread from the cloth, the land and so on — as a visible link, not a reveal by key.
14. **The Practice Door's "what found you"** is a dead end (§3 item 11).
15. **Grammar completion** writes nothing but `received`. There is no App Activity type for "received", so Portrait and Weave cannot show it.
16. **The Light scene** has no tie to the day's story or room, apart from writing vows.

---

## 6. Built but unreachable or half-wired

1. **`forgetToday()` and `forgotToday`.**
   - The intent is that "today's story reads as unread" after the corridor (FeedStore:782–792).
   - `forgetToday` is called from InstrumentView:256, but `forgotToday` has **no reader**. The "reads as unread" effect is not shown.
2. **`stays(for:)`** has no caller (FeedStore:858).
3. **GameView per-room atmosphere is dead.**
   - `heroBackground` switches on `room.id` (GameView:400), which is the Airtable record id, against room *names*.
   - Every room falls through to the Field's fallback gradient, and the authored per-room hero washes never draw.
4. **Practice Door `.story`** has no route to the story (§3 item 11).
5. **The Turning for Ash** calls `fetchArchetypeComments(archetypeName:)` without `isAsh` (TheTurningView:457). It would come up empty for Ash, but Ash's comments render with no avatar, so it is unreachable anyway.
6. **The Resonance Depth "Notice." fallback** shows when there is no Resonance Voice: a generic Sakshi line (StoryDetailView:1089).
7. **RiteRecognition "words" stage.** The audio is recorded but **not transcribed**. The "transcript" is an empty TextEditor he types into (RiteRecognitionView:527–545). SpeechCapture exists (Services/SpeechCapture.swift) but is used only by CodexView.
8. **RhymeGate.met is stale within a session** (§3 item 2). `revealRhymes()` (FeedStore+Kathas:65) refetches, but the gate still reads the old met set. Only `received`, which StoryDetail sets, opens a rhyme mid-session.
9. **`unwindingOpen`** (FeedStore:745) is unused; TurnOverlay recomputes it.
10. **`LetterSeal.back`** letters are written and shown in the Present river, but never *arrive*. This is by design; worth knowing.
11. **The debug Rite door** runs on canon content (TokenEntryView:98–137).
12. **Two ways to sort.** The Feed's MOST ACTIVE / MOST RECENT and GameView's own sort duplicate each other. Neither orders by rhyme or by met-ness.
13. **The authored GameView stats** ("147 veils lifted…", GameView:250–264) are fixed poetry, with numbers that look like counts.
