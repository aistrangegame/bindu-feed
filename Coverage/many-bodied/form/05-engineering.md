# Form pass · 05 · Engineering: first principles and best practice

*Lens: the build itself. This covers state, data, persistence, rendering, failure, testability, boundaries, naming, and the house laws as executable checks. Read against `Bindu Feed/CLAUDE.md` (§3, §6, §10 in full, §12, §15), the Swift tree at `Bindu Feed/Bindu Feed/` on branch `many-bodied` (12 Oct), CONTRACT, GAMEPLAN, READINESS-REVIEW, and scores W0–W8. Line numbers are hints; the symbol is the address.*

*Numbers marked ≈ are estimates from the code and the content ledger, not measurements. Each one names the measurement that would replace it.*

---

## 1 · First principles (the laws the build should obey)

These come from platform practice for a single-user, private, offline-tolerant SwiftUI app on iOS 18, and from the house's own §10 doctrine, which already states most of them in its own words.

1. **One source of truth per fact, reachable from one place.** Each fact has one owner: a story, a comment, a day-key, a room's identity, "what he did". Everything else reads it. *Why:* this is §10's "duplicated contract" class, which has caused five instances so far (day-key, `Axis.clampZ`, the `"Ash"` literals, D5.8, the gold palette). Every fix was a single reachable source rather than a corrected copy.
2. **Render from what is on the device; the network only refreshes.** The Door, the river and every story page must draw from a local snapshot in under a second, with or without signal. *Why:* "slow, intimate, already there" cannot survive a spinner, and the base is about to grow to ≈3,700 rows.
3. **Observe narrowly.** A view re-renders only when a value it actually reads changes. Nothing that ticks per frame is published into the environment. *Why:* one store with 46 `@Published` properties, observed by 45 files, turns every small write into a whole-app invalidation.
4. **Frame-rate work lives in leaves, and only while it is seen.** Per-frame code belongs inside `TimelineView`/`Canvas`/Metal leaves or a display-link engine. It stops when its layer is covered, at rest, or off-screen. *Why:* `RootView` keeps every layer mounted on purpose (§4), so a covered layer that keeps animating spends the whole budget on nothing.
5. **Pure logic is pure.** Rules, measures, indices, layouts and parsers take values and return values. They import no SwiftUI or UIKit, do no I/O and read no clock directly, and they are tested without a Simulator. *Why:* §10's "a test for an expression in a view body re-implements it" (`ImmersionTests`). A formula is only testable once it lives in the model layer.
6. **One door to the network, one door to the disk, one clock.** Airtable, LLM, UserDefaults, files and `now()` each have exactly one owner, which is also where the harness injects. *Why:* rate limits, auth, proof marking, FORGET ME, the harness clock and privacy can each only be enforced at a single choke point.
7. **No write is ever lost, doubled or orphaned.** A write is durable before it is sent and is retried with backoff that respects the server. A write that depends on another write's record id waits for it, and an ambiguous failure never produces a duplicate. *Why:* his authored words are the only content in the house that cannot be regenerated, and today 11 write paths are `try?` and leave no trace (W0 15.2).
8. **State that grows with use goes in a file, not in UserDefaults. Every key has a writer, a reader, a FORGET rule and a bound.** *Why:* UserDefaults is one plist, loaded whole and rewritten whole. Per-day keys (`bindu.met.<day>`, `bindu.suit.<day>`, `bindu.rite.word.<day>`, …) add keys forever.
9. **Identity by record id, everywhere, including routes.** *Why:* this is §10 ("a story is resolved by record id, never by a soft key"). A route that carries a `Story` value carries a stale copy once the snapshot refreshes.
10. **Decode off the main thread; the main thread draws.** *Why:* the project sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so `AirtableService` (a plain class) decodes every page on the main actor today.
11. **Fail soft and fail visible to the builder, never to him.** Offline, 429, 401, 422 and schema drift each have a specified behaviour and a log line. The screen shows absence, never an error string. *Why:* this is §10's "an unwired slot renders absence", which the house laws state as "never on a low day".
12. **Every gate is a counted, calibrated mechanism.** A rule that matters (nothing counted, nothing locked, no private names, every key mapped, no network outside the client) is a checker or a domain-walk test. It is calibrated red-on-bad, green-on-good and green-on-absent before it is trusted. *Why:* this is §10's most-repeated lesson: every checker in this build shipped on its first run with the fault it was built to catch.
13. **A god object is a duplicated contract waiting to happen.** A type that owns every fact and every rule becomes the place where new waves paste near-copies. Every wave must leave `FeedStore` smaller or the same size. *Why:* `clearToken()` already resets 13 properties by hand and misses the rest.
14. **Privacy is structural.** His words never leave the device except to his own base. Logs in Release hold no field values. Denylists of private names stay in `Tools/`, never in the binary. *Why:* this is a private instrument. A shipped list of names to avoid would itself be a list of names.

---

## 2 · The app today through this lens (as built, 12 Oct, `many-bodied`)

### 2.1 Inventory

| Area | As built | Works | Does not |
|---|---|---|---|
| **Size** | 142 Swift files plus 1 Metal file, 44,099 lines. Largest: `FeedStore` 1,885 · `UniverseView` 1,786 · `PointWorlds` 1,643 · `SoundEngine` 1,616 · `PointReadings` 1,461 · `AirtableService` 1,382 · `InstrumentView` 1,321 | Folders track registers (Instrument/Point/Universe/Light/Rite/Return), and the code↔design map in CLAUDE.md is accurate | Seven files above 1,300 lines; the four largest each mix view, model and I/O |
| **State: `FeedStore`** | `@MainActor ObservableObject`, **46 `@Published`**, ~100 functions, `MARK` sections named by wave (`WAVE 1…5`, `SLICE 8`, `SMALLER UPGRADES`, `THE REST`). Observed by **45 files** through `@EnvironmentObject` | Single owner of content; the bulk-comment law (§10) keeps the Turning and AshVoice off N+1 | **God object.** It mixes content, his walk (≈30 UserDefaults keys read directly), cooldown rules, the Practice Door selector, deep links, the sky's uniforms (`uniSky`), navigation intents (`pendingLaunchRoute`, `axisGlide`, `pendingLink`), write queues and activity logging. Any of 46 publishes invalidates every mounted observer. `clearToken()` resets a hand-kept list of 13 properties |
| **Other observables** | 15 `ObservableObject` classes (Breath, AxisTravel, RoomTravel, UniverseCamera, SoundEngine, SpeechCapture, PointYantra, PointReadingState, NaveFloor, Stillness, EyeWatcher, DancePlayer, RiteRecorder, AudioAnchorPlayer, FeedStore) | Display-link engines are correctly frame-locked (§10, the Breath contract) | **`Breath` publishes `phase`/`value` on every display frame** (`Instrument/Breath.swift`, `@Published` set in `tick`). It is injected app-wide (`BinduFeedApp` `@StateObject`), and 10 view types hold it as `@EnvironmentObject`, including `InstrumentView`, `RoomView` and `PointWorlds`. Those bodies re-evaluate at 60–120 Hz whether or not they are on top |
| **Network: `AirtableService`** | One class, `static let shared`. 37 `fetch*` functions, 6 hand-rolled pagination loops beside the core `fetch`, `URLSession` timeouts 20/40 s. Decodes by field **name** (W0 15.1 moves this to ID) | Resilient per-record decode (one bad row never blanks a surface); field-ID writes already used by `logActivity`/Codex | **No rate limiting, no 429 handling, no retry, no 401/403 path, no in-flight dedupe.** MainActor-isolated, so decoding runs on the main thread. Two views call `api.anthropic.com` directly (`ApertureView:342`, `PointWorldView:645`) |
| **Comments** | `fetchFieldComments(storyId:)` = **fetch all Field Comments, then filter** (linked-record caveat, §6). `loadComments(for:)` calls it on **every** story open (`StoryDetailView:700,719`) and every sky fall (`UniverseView:633`). `loadStoryStats` fetches all comments again | Correct under the formula limitation | Today ≈7 pages per open. After the content waves (≈475 stories × 5 children plus Lalita replies, Resonance Voices and Ash Comments, ≈2,700 rows) it is **≈27 sequential pages per story open, ≈6–12 s on LTE**, and it repeats for every story. *Measure:* `os_signpost` around `loadComments` |
| **Cold launch** | `ContentCoordinator.bootstrap()` fires `loadFoundation` (an internal `async let` group of 7) plus **7 more detached `Task`s at t=0**; RootView then adds stories and story stats | The Door needs only the foundation tier; Field Sounds fall back (`fallbackBreath`) | ≈14 concurrent requests at launch against Airtable's limit of 5 requests/s per base. A 429 costs a 30 s wait. Nothing is cached, so **offline means an empty house** except the Light (`bindu.light.sources`) and kept lines (`bindu.kept.cache`) |
| **Persistence** | **43 distinct `bindu.*`/`mirror.*`/`point.*` key literals, 104 `UserDefaults` call sites**, spread over FeedStore and views. Two separate pending queues (`bindu.comments.pending`, `bindu.vows.pending`). Per-day key families (`met.`, `suit.`, `rope.`, `rite.word.`, `rite.dismissed.`, `mirror.draw.`) | Local-time day-keys go through one formatter (§10, fixed 30 Aug) | No registry of keys: STATE.md does not exist yet (W0 15.9). Per-day families grow without bound. Light sources sit as a `Data` blob in UserDefaults |
| **Writes** | 11 `try?` fire-and-forget write paths (W0 15.2 lists them), plus two durable queues | Comments and vows survive failure | Every other write fails silently. Several later operations need an id that a queued write would not yet have, e.g. `setNote` PATCHes `line.id` of a Kept that may be a placeholder |
| **Rendering** | **50 `Canvas`, 41 `TimelineView(.animation)`, 5 `CADisplayLink`s, 1 Metal `colorEffect`** (`InstrumentView:861`) | Metal shader is sim-verifiable; `CADisplayLink` for travel and camera | **No `TimelineView` is ever paused** (no `paused:` anywhere), so the axis shader and its eight timelines keep running under a story. **A state write happens inside a Canvas draw**: `UniverseView.draw` sets `store.currentUniRoomId` via `DispatchQueue.main.async` (`:939`), which invalidates all 45 store observers each time the focus region changes during a pan |
| **Models** | Single `RecordFields` `CodingKeys` (§10). `Story` is a synthesized `Hashable` struct over every field including `body` | One decoder (§10) | `FeedRoute.story(Story)` carries the value, so a pushed page shows the copy from push time and route equality hashes whole bodies |
| **Statics** | 64 `static var`s (PointJourney ×7, PressClaim, MirrorHall, PointGoodnight, ApertureView.drawn/seen, …) | §10 TENTH SHAPE names them and demands `.serialized` | Shared mutable state outside any store, invisible to FORGET ME |
| **Haptics** | `HeartbeatService` owns one `CHHapticEngine` | — | W0 §3 and W2 §3.7 each add their own engine (three total) |
| **Concurrency settings** | `SWIFT_VERSION = 5.0`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `IPHONEOS_DEPLOYMENT_TARGET = 18.0` | Default MainActor removes most data races | Everything not explicitly marked `nonisolated` runs on main, including JSON decode and future `RhymeIndex`/`HouseLight` builds over 475 stories |
| **Tests and gates** | 76 unit-test files (Swift Testing; ~530 cases), 1 UI test file; `Tools/verify.sh` (7 checkers, pre-commit); `bar.sh` counts executed tests | A world-class calibration culture: count, never the banner; four-quadrant calibration; domain walks (`ParticleNameTests.allNineAreReachable`) | **The data layer has zero tests**: no URL stub, no fixture decode, no queue semantics. `Tools/house_law.sh` does not exist yet (W0 15.10 creates it) |
| **Privacy** | PAT in Keychain, `AfterFirstUnlockThisDeviceOnly`; DEBUG `print` of GET URLs (no token) | Token never printed | Anthropic key and calls live in views; no file-protection class is set anywhere; nothing excludes caches from backup (no files yet) |

### 2.2 What to keep, by name
- The **calibration discipline** (§10) is the strongest engineering asset in the repo. Every proposal below that adds a check comes with its known-bad and known-good fixture, because that is how this house works.
- **Resilient decode**, **one day-key formatter**, **record-id identity**, the **lock-free audio render path** (§15 render-path discipline), **display-link engines**, and **cross-dissolve routing with every layer mounted**. The last one is right for continuity; it only needs a pause signal (§4.4 R3).

---

## 3 · The app after W0–W8 as scored: where the scores, added together, break these principles

Each score designs its own pieces well. Added up, they produce the following.

**3.1 FeedStore becomes the house's only noun (P1, P3, P13).** The scores reference `FeedStore` 99 times and each adds state to it:
- W1 `store.rhyme` (didSet on `stories`) and `draw(_:index:)`
- W3 `store.houseLight` and the receivedOn backfill
- W4 the relay keys (§2.4 "small additions to `FeedStore`")
- W5 `store.arrivals` (an `ObservableObject`)
- W6 `store.ledger` (an `ObservableObject` with `revision`)
- W7 `store.conditions` (an `ObservableObject` held in `@Published var conditions = HouseConditions()`)
- ≈15 new `load*`/`fetch*` pools: Interludes, Waiting Roles, Swatches, Second Letters, Veils, Constellations, Planted Seeds, Waiting Tellings, house rows, walks, map rooms, mandala rings, offered words, codex days at bootstrap, field tracks

Projected: ≈3,000+ lines and 55–60 publishers.

**A real defect, not a style point:** a class held in a `@Published` property of an `ObservableObject` does **not** propagate its inner changes. `store.conditions.groundHex` changing does not fire `store.objectWillChange`, so a view reading `store.conditions.x` through `@EnvironmentObject store` will not update. W5 §2.1, W6 §1 and W7 §2.3 all use this shape. It "renders as working" in any walk that relaunches between steps, which is §10's FIFTH SHAPE.

**3.2 Cold launch collapses under the new bootstrap (P2, P10).** The scores add the following to `bootstrap()`:
- stories (W0 14.16)
- the whole Codex day list, to find one earliest date (W5 §2.7)
- `loadSiblings` plus `fetchHouseRows` plus walks, identity, map, mandala rings and offered words (W7 §2.2)
- Interludes (W0 15.6), Waiting Roles (W2 §1.5) and the other new pools

RootView keeps its own `loadStories` (W0 14.16 calls it "idempotent"). It is idempotent in result but **not in cost**: it is a second full fetch in parallel. It also keeps `loadStoryStats`, which fetches all comments.

≈35–45 requests and ≈75–90 pages at first open. At 5 requests/s that is **≥15–18 s even if perfectly paced**. Unpaced, as `bootstrap()` fires today, it trips the 429 lockout (30 s). W0 15.2 paces **writes** at 250 ms but **reads share the same per-base budget** and nothing paces them. *Measure:* signposts per request in the W0 walk's cold open.

**3.3 Every story open refetches every comment (P1, P2).** Nothing in W0–W8 changes `loadComments(for:)`. W6 §2.5 adds the Wall of Voices (all Field Comments plus Resonance Voices). W3 §7, W4 §3.9 and W7 §2.4 add more readers of the same rows. With ≈2,700 children, this is the single largest cost in the build.

**3.4 Fourteen-plus new state containers, one event stream (P1, P8).** The scores add **≈70 new `bindu.*` keys** (115 distinct in the scores against 45 in code). Many are different views of one stream, "what he did, when, where":
- W2 `bindu.room.memory` (≤200 marks × 21 rooms)
- W3 `receivedOn`, `circuit.will`, `circuit.closed`, `carried.ever`, `book.sentBack`, `dot.found`, `plays.met`, `walk.current`, `second.offered`
- W4 `met.last`, `relay.baton`, `draw.log`, `wagers`, `board.*`, `gates`
- W5 `arrival.surfaced`, `arrival.bag`, `swatch.under`, `deep.carried`
- W6 `house.events` (≤4,000 marks, a JSON array re-encoded on every `note`), plus a **migration at W6 that copies W1–W5's keys into it** (W6 §1 "Migration")
- W7 `conditions.*`

Several are JSON blobs that grow (`house.events` is ≈400 KB at the fold point; `room.memory` is ≈4,200 marks). They are written to UserDefaults on the main thread with each event. Per-day families add `bindu.draw.<day>`, `bindu.call.word.<day>`, `bindu.rite.stitch.<day>`, `bindu.sig.blink.<day>`, `bindu.witness.<week>` and `bindu.between.<day>`. That is ≈10 new keys a day, ≈3,600 a year, none pruned.

**The ledger the house needs is designed at W6, after five waves have each built their own.** That order produces the duplicated-contract class by construction.

**3.5 The river moves inside the per-frame view (P3, P4).** W6 §2.1 mounts `FeedRiver` (a LazyVStack of ≈475 cards plus W1's weft overlay plus the Verb Mala) inside `InstrumentView`. That view's struct already re-evaluates its body every display frame, through `@EnvironmentObject breath` and `@StateObject travel`. Readiness flags the gesture risk (scroll vs lean). **The render risk is unflagged:** the river's parent body runs at 120 Hz on ProMotion. W1 §3.2's `RiverWeft` gathers `anchorPreference` frames from every card, and the preference reduction reruns on every scroll frame.

**3.6 The write layer as scored has four holes (P7).** W0 15.2 is a strong design: one writer, a durable queue, sandboxing, proof marking. It still leaves:
- **(a) Dependent writes.** W4/W5 Return → Return Answer (`Parent Comment` = the ring's id), Kept → note PATCH, Letter → `Letter Opened` PATCH, Filament → its activity. A queued parent leaves the child holding a placeholder id, so the child gets 404 or 422 and becomes "blocked".
- **(b) 401/403** fall under "a 4xx is kept as `blocked` and retried on each launch once only". A revoked token would mark every authored word blocked.
- **(c) Ambiguous failures.** A timeout after the POST reached Airtable, retried, gives a duplicate Ash Comment or letter. Airtable has no idempotency key.
- **(d) Storage.** The queue lives in UserDefaults, and `writes.log` grows forever with no rotation.

**3.7 The clock is DEBUG-only but read in Release (P6).** W0 15.3 defines `Harness.now()` "inside `#if DEBUG`", and W4 §2.1 has `Round.phase(_ d: Date = Harness.now())` in shipping code. As written, this either does not compile in Release or forks every time read into two paths. There are 26 harness flags across the scores; each one needs a single seam, not a `#if DEBUG` inside feature logic. Otherwise the walks (DEBUG) verify a different program from the one on Neev (Release).

**3.8 Three haptic engines, two hold engines, three timers (P1).** HoldEngine has its own CHHaptic latch (W0 §3). RoomHaptics adds a separate `CHHapticEngine`, chosen "so the pulse never stops" (W2 §3.7). HeartbeatService has a third. Interaction between the hold latch and a room turn is unspecified. Elsewhere, ElementArc dwell timers (W2 §6.2), CloseConductor timers (W2 §12) and the HoldEngine stillness drive each keep their own clocks. Not one of these is on `Breath`.

**3.9 Logic placed in views or screens (P5).** `Screens/ClothLayout.swift` is pure (W3 §4.6) but lives in Screens. `RhymeIndex.accent(of:) -> Color` couples the index to SwiftUI. `Reception/ReceptionViewNew.swift` (W2 §5) is named after when it was written, not what it holds. W2 §12a A cites `Screens/RoomView.swift`, which does not exist; the file is `Rooms/RoomView.swift`. Eleven new types share the prefix `House*` (Light, Ledger, Conditions, Walk, Measure, Rows, Yantra, View, Ground, Event, Mark). DECISIONS had to rule which is `store.house`.

**3.10 Performance gates are too weak and Simulator-only (P12).** "No frame > 33 ms" (W1 §8.3, W3 §17.3, W6 §14 C) is a 30 fps floor on a 60/120 Hz device. W8 §6 mentions "cold-launch time to the Door" but sets no number. No score measures memory, launch, or hitch ratio.

**3.11 The data layer stays untested (P12).** W0 builds the most consequential new system, `AirtableWriter` and its queue. Its proof is live rows plus "a request-level unit test" for Codex only. Nothing tests 429, 401, ordering, dependency, sandbox-never-flushes (R4) or migration of the two old queues.

---

## 4 · Gaps and opportunities: the target architecture, the budget, the rules

### 4.1 Target architecture (layers, owners, where every new system lives)

```
┌ Views (Screens/, Rooms/, Universe/, Point/, Light/, Rite/, Return/, Components/, Reception/Grammars/)
│   read @Observable models through @Environment; per-frame work only in leaves; routes carry ids
├ Engines (frame-rate, main thread, display-link only while active)
│   Breath (pure function of time) · HoldEngine · AxisTravel · RoomTravel · UniverseCamera
│   SoundEngine (audio thread rules unchanged, §15) · Haptics (ONE CHHapticEngine, channels)
├ Models (@Observable @MainActor final classes; small; each owns one kind of state)
│   AppModel (container; owns the rest; rebuilt on token change = FORGET-safe reset)
│     ContentModel   stories · catalog pools · CommentIndex · derived indices (rhyme, rooms)
│     WalkModel      his walk on this phone: projections over the LedgerLog
│     ArrivalEngine  (W5)  ·  HouseConditions (W7)  ·  HouseLight (W3, derived)
│     WriteModel     queue status for the builder (never shown to him)
│     NavModel       pendingLaunchRoute · axisGlide · pendingLink · departure
│     SkyModel       uniSky · focus room (set from camera state, never from draw)
│   FeedStore      → a thin facade forwarding to the above, so the 45 call sites compile;
│                    shrinks every wave; no new stored property is ever added to it
├ Domain/ (pure Swift; no SwiftUI/UIKit/Foundation networking; no clock; unit-tested)
│   RhymeIndex · KathaMarks · RoomCanon (data) · ElementArc · CloseConductor rules · ArcKindShape
│   HouseMeasure · CircuitRules · ArrivalRules/ArrivalPicks · Porous · Round · TimeLaw · Season
│   DrawScope · ClothLayout · BookModel · FieldScore · LightHand table · Gates (→ ReleaseGates)
│   HouseConditions.rebuild(...) (the pure function; the class just holds its result)
├ Data
│   FeedSnapshot     on-disk content cache (Caches/feed-snapshot.v1.json), stale-while-revalidate
│   CommentIndex     [storyId: [Comment]] built once per snapshot, off-main
│   LedgerLog        Application Support/ledger.jsonl — append-only events of his walk
│   DeviceState      typed keys (enum DeviceKey) for small prefs; the ONLY UserDefaults door
│   WriteQueue       Application Support/write-queue.json — durable, ordered, dependency-aware
│   AirtableWriter   the only write door (W0 15.2, completed per §4.3)
├ Platform
│   AirtableClient   actor · the ONLY URLSession user for api.airtable.com
│   LLMClient        the only door to api.anthropic.com (moves out of ApertureView/PointWorldView)
│   HouseClock       now() in Release; HarnessConfig overrides it in DEBUG
│   Keychain · Log (writes.log rotation; Release logs carry ids and statuses, never field values)
└ Harness/ (#if DEBUG only) HarnessConfig parsed once → injects Clock, DeviceState root,
   AirtableClient fixtures, Writer sandbox, Arrival RNG seed. No #if DEBUG outside Harness/ and the seams.
```

**Where each new system lives:**

| System (score) | Layer and file | Notes |
|---|---|---|
| HoldEngine (W0 §3) | Engines · `Components/HoldEngine.swift` | One instance per gesture. Display link through a weak proxy (the `AxisTravel` pattern), invalidated in `cancel()` and `deinit`. Haptics through `Haptics.hold` |
| AirtableWriter, offline queue (W0 15.2) | Data · `Services/AirtableWriter.swift` + `Services/WriteQueue.swift` | Sends through `AirtableClient`; §4.3 specifies the rest |
| Harness (W0 15.3) | `Harness/HarnessConfig.swift` | 26 flags in one typed struct; every flag names its seam |
| RoomCanon (W0 15.4 / W2 §2) | Domain · `Domain/RoomCanon.swift` (data) + `Rooms/RoomCanon+Style.swift` (Color, Font) | Keeps the purity line |
| ArrivalRules/Engine/Picks/Porous (W0 15.5, W5 §2) | Domain (rules, picks, porous) + Models (`ArrivalEngine` `@Observable`) | The engine reads the ledger projection, not raw keys |
| RhymeIndex (W1 §2.2) | Domain · `Domain/RhymeIndex.swift` | Built **off-main** when the snapshot changes; `accent` returns a hex; the view maps it to `Color` |
| KathaMarks (W2 §1.4) | Domain | Parsed once at snapshot decode, off-main |
| ElementArc, CloseConductor, ArcKindShape (W2 §6.2, §12) | Domain (rules) + `Reception/` views | Timers read `HouseClock` through `TimelineView`, never `Task.sleep` |
| RoomMemory (W2 §6.4) | **A projection over LedgerLog** (kind `roomMark`) | Not its own key; FORGET/CARRY come free |
| RoomHaptics (W2 §3.7) | Engines · `Services/Haptics.swift`, channel `.room` | One engine, three channels (pulse · hold · room) and a priority rule (§4.4 R9) |
| HouseMeasure / HouseLight (W3 §2) | Domain (measure) + derived value on `WalkModel` | Recomputed coalesced, once per run-loop turn, off a ledger revision |
| CircuitStore, WalkStore, PlaysMet (W3) | **Projections over LedgerLog** | `PointJourney` stays a facade, as W3 §13.1 already designs |
| Round, Season, TimeLaw (W4 §2, W5) | Domain; read `HouseClock` only through a parameter | — |
| DrawScope + `draw(_:index:)` (W1/W4) | Domain + `ContentModel` | `bindu.draw.log` becomes ledger kind `drawn` |
| HouseLedger (W6 §1) | **Moves to W0** as `LedgerLog` + `WalkModel` | W6 keeps its API names (`note`, `has`, `weight`, `ids`, `last`, `dwellByRoom`) |
| FeedRiver at z=0 (W6 §2) | Views; `Instrument/FeedRiver.swift` | `Equatable`; never reads Breath or AxisTravel (§4.4 R2) |
| HouseConditions, house rows (W7 §2) | Data (rows in the snapshot cache, delta-fetched) + Domain (`rebuild`) + Models | Rebuild coalesced; not on every ledger note |
| BookModel, ClothLayout (W3) | Domain | Computed on data change only |

### 4.2 Data: fetch strategy for ≈3,700 rows, made concrete

**The snapshot (P2).** Everything the app reads from The Feed (`tbl7vzODMMJUgeX0b`) is one cache.
- **Storage.** `Caches/feed-snapshot.v1.json` holds records by id, keyed by field id, plus `cursor` (ISO-8601) and `schema: 1`. It is written atomically with `.completeUntilFirstUserAuthentication` protection and is excluded from backup (it is a cache of his base; the base is the backup).
- **Cold launch.** Decode the snapshot off-main (≈4 MB, an estimated 60–120 ms on A15; *measure with a signpost*). Build `CommentIndex`, `RhymeIndex`, `KathaMarks` and catalog pools off-main, then publish once. The Door, the river and every story page draw from it.
- **Refresh, one request in the steady state.** `filterByFormula = IS_AFTER(LAST_MODIFIED_TIME(), '<cursor − 120 s>')`, **no Type filter and no Status filter**, `returnFieldsByFieldId=true`, every page. Merge by id. Status is applied **client-side** (Live ∪ Staged visible; Archived/Draft dropped), so a record that leaves Live is removed. A record moved to Archived would never match a server-side `Status` filter, so a filtered delta would miss it. Proof rows (`Name` starts with `BUILD PROOF`) are dropped in the decoder, in one place.
- **First ever launch, no snapshot.** Use priority lanes in `AirtableClient`.
  - **P0** foundation: Rooms, Archetypes, Threshold Sentences, Field Sounds, Practice, Gaia. 1–2 pages, filtered by `Type`. The Door draws from these.
  - **P1** Stories (≈5 pages).
  - **P2** the full-table pass that builds the snapshot (≈37 pages, ≈10 s, behind the Door).
- **Linked-record filtering stays client-side** (§6 caveat), now against the in-memory `CommentIndex`, not a refetch. `loadComments(for:)` becomes a dictionary lookup. **This is the largest single win in the build.**
- **Calibrate the delta once (§10 discipline):** edit one story in the base → one record returns; an inverse link (`Rhymed By`) changes → confirm the partner's modified time moves, else add the partner on the client by symmetry (RhymeIndex already does); an Archived flip → the record leaves the screen.
- **Other tables.**
  - App Activity uses the same delta by `CREATED_TIME()`. It is append-only by law, which makes it cheaper: W7's 35-day window becomes a growing local log with a cursor.
  - Codex needs only `maxRecords=1`, `sort Date asc`, `fields[]=Date`, once, cached forever, for W5's earliest day. Today's `fetchCodexDays` pages the whole Codex. The Present's own list stays lazy (when the Present opens).
  - Bindu Field, Mandala, Map and Walks are small catalogs with a 24 h freshness check and the same snapshot pattern.

**AirtableClient (P6, P7, P10, P11).**
- An actor. Its methods are `nonisolated` async, and decoding happens inside it, so nothing decodes on main.
- **Token bucket** of 5 per second per base, burst 4, max 4 in flight. Reads and writes share it.
- **429:** stop the lane for `max(30 s, Retry-After)`, then resume. No exponential storm.
- **5xx/network:** retry reads 3× with jitter (0.5 s, 2 s, 5 s), then fall back to the snapshot.
- **Single-flight:** identical GETs in flight are coalesced, which fixes the double `loadStories` at launch.
- **401/403:** set `AuthState.lapsed`. Reads stop and the snapshot serves. Writes stay queued as `.waitingForAuth`, never `blocked`. The app keeps working. Settings shows a quiet row, *how you arrive* style; it is not a notification, and the existing token screen is reachable from there. Nothing is deleted.
- **404 on a table or field:** log, treat as empty, never crash.
- **422:** handled per W0 15.2.

### 4.3 The write path, completed (P7)

- **Durable before send.** Each `WriteQueue` entry is `{id: UUID, clientWriteId, dependsOn: [UUID], table, method, recordRef, fields, kind, createdAt, attempts, state, lastStatus, lastBody}`. It lives in `Application Support/write-queue.json` (atomic and file-protected), not UserDefaults. The old `bindu.comments.pending` and `bindu.vows.pending` migrate on first launch; there is a unit test for it.
- **Dependencies.** A write that needs another's record id carries `"$ref:<entryId>"` in place of the id (in `recordRef`, or inside a link array). Flush resolves refs from the parent's `.landed(recordId)`; a child never sends before its parent lands. This covers Return → Return Answer, Kept → note PATCH, Letter → Letter Opened, Filament → its activity, and any later wave's pair.
- **Idempotency without server support.** Every POST carries `clientWriteId`.
  - On a timeout or connection loss **after** the request left (an ambiguous failure), the next attempt first GETs by `filterByFormula = {Client Write Id}='<uuid>'` (one request). If a row exists, the write is landed.
  - This needs one new text field, `Client Write Id`, on The Feed and App Activity. Track 1 adds it by schema; adding fields is allowed and nothing is renamed or deleted.
  - Until the field exists, the writer puts `cid:<uuid>` in App Activity `Notes` (`fldVyj4hkzxcrIBoJ`). For Feed rows it accepts the small duplicate risk and logs it.
- **States** are `queued · sending · landed · blocked(4xx not auth) · waitingForAuth · sandboxed`. `blocked` is retried on each launch (per W0) **and** whenever `AuthState` returns to ok.
- **Order.** FIFO per dependency chain. Independent chains may interleave under the shared bucket.
- **Log.** `writes.log` rotates at 1 MB (two files kept). **Release lines carry time · kind · method · table · status · record id only, never field values and never body excerpts.** DEBUG `SANDBOX` lines may carry field JSON (W0 15.2) and are compiled out of Release.

### 4.4 Rendering, observation and performance: the rules

- **R1 · Breath becomes a function, not a publisher.** `Breath.value(at t: CFTimeInterval) -> Double` and `phase(at:)` stay pure functions of the launch-anchored origin; the one-breath contract (§9 Breath header) is unchanged. Every reader takes `t` from its own `TimelineView(.animation)` context date, or its engine's link. `@EnvironmentObject breath` is retired from all 10 view types. *Calibration:* `OneBreathTests` stays green; a `Self._printChanges()` probe on `InstrumentView` shows no body re-evaluation per frame at rest.
- **R2 · Heavy containers never sit under a per-frame parent.** `FeedRiver`, `StoryDetailView`'s text and the Book's pages are `Equatable` views fed ids and value snapshots. Per-frame chrome (particle, rail, shader uniforms) lives in its own leaf structs.
- **R3 · Covered layers pause.** `RootView` passes `\.isFrontmost` (true only for the top layer, or the base when the path is empty). Every `TimelineView` uses `.animation(minimumInterval: nil, paused: !isFrontmost)`. Display-link engines `stop()` when not frontmost; the Metal field holds its last frame. Sound is unaffected (SonicContext already owns it). *This alone removes an estimated 30–60 % of main-thread time under any pushed page; measure with Time Profiler on the W8 device walk.*
- **R4 · No state writes inside `draw`.** The focus room is derived in `UniverseCamera` on change of focus (hysteresis: a 0.5 s dwell inside a region), never in `Canvas`.
- **R5 · Canvas discipline for hundreds of marks.**
  - Layouts (positions, paths) are computed on data change and cached as `Path`s grouped by style bucket (colour × alpha band), then drawn in one `fill`/`stroke` per bucket.
  - Cull against the visible rect plus 10 %.
  - Level of detail by zoom: below 0.5 px a star is a point, with no glow.
  - No per-element `.blur`/shadow filters. A glow is one pre-resolved symbol (`context.resolveSymbol`) or one `drawLayer` with a single filter.
  - Hit-testing through a spatial grid built on layout (W6 §6 already does this; make it the rule for the sky, the Cloth, the eagle-eye and the Point rings).
- **R6 · `RiverWeft` (W1 §3.2) draws threads only between cards whose frames are visible.** It uses one overlay `Canvas` and a preference keyed by id, de-duplicated so an unchanged frame does not republish.
- **R7 · `@Observable` for every new container**, never `ObservableObject` and never a nested `@Published` class. Observation tracks property reads through any reference path, which fixes §3.1's propagation defect. `FeedStore` itself migrates to `@Observable` in W0 Slice 15. It is a mechanical change: `@EnvironmentObject var store: FeedStore` becomes `@Environment(FeedStore.self) private var store` at 45 sites.
- **R8 · Coalesce derived rebuilds.** HouseLight, HouseConditions and RhymeIndex rebuild at most once per run-loop turn (a `rebuildScheduled` flag), off-main where they are O(n + edges). Dwell is accumulated in memory and written to the ledger **once per visit, on leave**, never per second.
- **R9 · One haptic engine.** `Haptics` holds one `CHHapticEngine`, with players per channel. Priority: `hold` latch > `room` turn > `pulse` (the pulse keeps running under the others at reduced intensity; it never stops, which keeps W2 §3.7's intent).

### 4.5 The performance budget (written into CLAUDE.md §10 by W0; gated per wave)

| Measure | Budget | Where measured |
|---|---|---|
| Launch to first Door frame, with a snapshot present | **≤ 1.0 s** (p90) | `XCTApplicationLaunchMetric` on the pinned Simulator; MetricKit `MXAppLaunchMetric` on the W8 device walk |
| Launch to Door, first install, no snapshot | ≤ 3.0 s (P0 lane only) | W0 walk step 1 with `-HarnessFresh YES -HarnessNoSnapshot YES` |
| Story page open, tap to text | ≤ 150 ms, **0 network requests** | signpost `story.open`; request count from `AirtableClient` log |
| Background refresh in the steady state | ≤ 2 requests per open (Feed delta plus App Activity delta) | `AirtableClient` request log |
| Requests in any 1 s window | ≤ 5 per base, **0 × 429 in any walk** | the client's log; a W0 Done line |
| Frame pacing: river scroll, sky pan, Cloth pan, eagle-eye | **hitch-time ratio < 5 ms/s** and p95 frame ≤ 16.7 ms (60 Hz Simulator) | `XCTOSSignpostMetric.scrollDecelerationMetric` + custom signposts; replaces "no frame > 33 ms" |
| Same on device (ProMotion if Neev has it) | hitch ratio < 5 ms/s; p95 ≤ 8.3 ms at 120 Hz | Instruments Animation Hitches, W8 §6 |
| Main-thread work per frame, any register at rest | ≤ 4 ms | Time Profiler, W8 §6 |
| Covered-layer work | 0 timeline ticks under a pushed page | `_printChanges` / signpost probe, unit test of `isFrontmost` |
| Memory | resident ≤ 200 MB; growth ≤ 5 MB over a 15-min walk | `XCTMemoryMetric`; Allocations on device |
| Snapshot decode | ≤ 150 ms off-main; main-thread block ≤ 16 ms at publish | signposts |
| Disk | snapshot ≤ 8 MB; ledger compacts above 2 MB; writes.log ≤ 2 MB | file sizes in the W8 audit |
| UserDefaults plist | ≤ 256 KB; no key family grows per day without a prune | `check_state.py` + a size probe in the walk |

### 4.6 The house laws as enforceable checks (Tools/house_law.sh and two new checkers)

Each check ships with `Tools/fixtures/house_law/<check>.bad.swift` (must go red) and `.good.swift` (must stay green), plus a green-on-absent guard (the pattern's target file exists). That is §10's calibration, built before first use.

| Law | Check | Kind |
|---|---|---|
| Nothing counted | (1) W0 §7B's grep battery, kept. (2) **positive allowlist:** every `\(` inside `Text(`, `.accessibilityLabel(` or `.accessibilityValue(` must be a call to `TimeWords.*`, `nameList(`, `.title`, `.name`, `.codexId`, or a `String` in `Tools/interp-allow.txt`. (3) **domain walk:** an XCUITest that visits every register on the `many` fixtures and asserts no `staticTexts` label matches `\b\d+\b`, except dates and the registered exceptions. Only walking the domain finds a fenced or stray numeral (§10 `ParticleNameTests` principle) | grep + UI test |
| Nothing locked or hidden-until | Unit test: for every story id in the `many` fixture, `route(for: story/<id>)` resolves, the page renders a non-empty body, and the sky star is enterable. Grep battery (W0 §7B) for the retired gates | test + grep |
| Never on a low day | `ArrivalEngineTests` 4 (W5), plus a grep that every `ask(` caller sits behind `ArrivalEngine` (no side-door arrivals) | test + grep |
| One network door | No `URLSession`, `URLRequest` or `api.airtable.com`/`api.anthropic.com` outside `Services/AirtableClient*.swift` and `Services/LLMClient.swift` | grep |
| One disk door | No `UserDefaults.standard` outside `Store/DeviceState.swift` and `Harness/`; no `FileManager` writes outside `Data/` | grep |
| One clock | No `Date()` or `Date.now` outside `Platform/HouseClock.swift`, `Harness/` and tests. Existing sites move in W0; until then a ratchet count may only fall | grep with ratchet |
| Every key mapped | **`Tools/check_state.py`:** every `DeviceKey` case appears in STATE.md with writer, reader, FORGET, CARRY and bound, and vice versa; every key literal in Swift is a `DeviceKey`. Calibrate both directions | checker (it can join verify.sh as the 8th, or sit beside it as house_law does) |
| No write lost | No `try? await` on any writer or service write (W0 §7B, kept). Unit tests on the queue (§5 item 7) | grep + test |
| Pure domain | No `import SwiftUI` or `import UIKit` in `Domain/` | grep |
| God-object ratchet | `wc -l Store/FeedStore.swift` ≤ the previous wave's value; the number of `@Published` and stored `var`s in FeedStore ≤ the previous value | count, stored in `Tools/ratchet.txt` |
| Release is clean | After the Release build: `strings` on the binary finds no `-Harness`, `SANDBOX`, `BUILD PROOF ·` writer branch or `arrivals.log` | post-build script, W8 |
| Private names never on screen | `Tools/screen_audit.py` runs over a DEBUG-exported snapshot (`-HarnessDump snapshot`) using the do-not-use list held **only in Tools/**. It never compiles a name list into the app | checker, W8 and on each content wave |
| Two voices, ceiling 0.55 | A `SoundEngine` invariant asserted in DEBUG plus an offline render test (the pattern of `SoundLayerTests`): two transients requested within 1.2 s give one | test |

### 4.7 Engineering rules every wave must obey (paste into each score's "How to work")

- **E1.** No new stored property on `FeedStore`. New state goes in its own `@Observable` model under `AppModel`; FeedStore may only forward.
- **E2.** No new `ObservableObject`. No `@Published` holding a class.
- **E3.** Every new persistent value is a `DeviceKey` case (small, bounded) or a ledger kind (anything that grows), with its STATE.md row in the same commit. No per-day key without a prune rule.
- **E4.** Every new read goes through `AirtableClient` and the snapshot. **No view triggers a network fetch for content the snapshot holds.** A new pool is a `Type` the snapshot already carries, filtered in memory.
- **E5.** Every new write goes through `AirtableWriter`, declares its dependencies, and has a queue unit test.
- **E6.** Every rule, measure, index or layout goes in `Domain/` and is unit-tested there. A test asserts the relationship the design draws, never the port's arithmetic (§10).
- **E7.** Per-frame code lives in a leaf; it pauses when `!isFrontmost`; it never writes state inside `draw`.
- **E8.** Every timed behaviour reads `HouseClock`. The harness overrides only seams; no `#if DEBUG` inside feature logic.
- **E9.** Every static registry gets `.serialized` tests at birth (§10 TENTH SHAPE).
- **E10.** Every new checker or detector ships with its bad, good and absent fixtures, run before it is trusted.
- **E11.** Routes and arrivals carry record ids; views resolve them from `ContentModel` at render.
- **E12.** Each wave's Done means includes the budget rows (§4.5) that its surfaces touch, measured, with the number in STATUS.md.

---

## 5 · Recommended changes to the scores

Numbered for mechanical folding. Format: **target · change · priority**. MUST means before W0 starts, or before the named wave starts where it says so.

1. **W0 §2 (new 15.0, before 14.0) · Platform seams.** Create `Platform/HouseClock.swift` (`now()`; Release returns `Date()`; `HarnessConfig` overrides it), `Store/DeviceState.swift` (`enum DeviceKey`, the only UserDefaults door) and `Harness/HarnessConfig.swift` (all 26 flags typed, parsed once). Rewrite W0 15.3 so `Harness.now()` becomes `HouseClock.now()`, and update W4 §2.1, W5 §2.7 and W2 §6.2 to read `HouseClock`. · **MUST**
2. **W0 15.1 + 15.2 · `AirtableClient` actor.** Shared token bucket for reads and writes (5/s, burst 4, 4 in flight); 429 → pause the lane `max(30 s, Retry-After)`; single-flight GET dedupe; decode in the actor (off-main); proof-row filtering in the decoder only; 401/403 → `AuthState.lapsed` (snapshot serves, writes `.waitingForAuth`). W0 15.2's "pace 250 ms" moves into the bucket. · **MUST**
3. **W0 (new 15.12) · `FeedSnapshot` + `CommentIndex`.**
   - On-disk content cache (`Caches/feed-snapshot.v1.json`, file-protected, excluded from backup).
   - Delta refresh by `IS_AFTER(LAST_MODIFIED_TIME(), cursor−120 s)` with no Type or Status filter; status applied on the client.
   - Priority lanes for the first install.
   - `loadComments(for:)` becomes an index lookup (`StoryDetailView:700,719`, `UniverseView:633`). `loadStoryStats` derives from the index.
   - Walk step: airplane mode after one launch, then the Door, the river, a story with its five voices and the sky all render.
   - Amend CLAUDE.md §10 "no local persistence" to "content cache + files in STATE.md".
   - · **MUST**
4. **W0 14.16 · Remove "RootView's own load stays (it is idempotent)."** Stories come from the snapshot; RootView never fetches. · **MUST** (folds into 3)
5. **W0 15.2 · Write queue completion.**
   - The queue moves to `Application Support/write-queue.json`, not UserDefaults.
   - Entries carry `dependsOn` and `$ref:` placeholders (Return→Answer, Kept→note, Letter→opened, Filament→activity).
   - 401/403 become `.waitingForAuth`, never `blocked`.
   - `blocked` retries on launch and on auth recovery.
   - `writes.log` rotates at 1 MB, and Release lines hold no field values.
   - · **MUST**
6. **W0 15.2 + CONTRACT §2.1 · `Client Write Id`.** Track 1 adds a text field `Client Write Id` to The Feed and App Activity (adding is allowed). The writer sets it on every POST and checks by it before retrying an ambiguous failure. Until the field exists, App Activity uses `Notes` `cid:`. · **SHOULD** (Track 1 schema before W0 Slice 15)
7. **W0 §7 (new D′) · Data-layer tests with a `URLProtocol` stub.** Pagination, decode by id, a resilient bad row, 429 pause, 401 lapse, 422 owed, timeout-then-landed with no duplicate, dependency order, sandbox-never-flushes (R4), and migration of `bindu.comments.pending`/`bindu.vows.pending`. Each has a stated build in which it fails. · **MUST**
8. **W0 15.9 ← W6 §1 · Move `HouseLedger` to W0** as `Data/LedgerLog` (`ledger.jsonl`, append-only, debounced flush 0.5 s and on background, compacted above 2 MB by W6's own fold rule) plus `WalkModel` projections. W6 keeps its API names and its writer/reader matrix (§1.1). Delete W6 §1's "Migration" step, since there is nothing to migrate. · **MUST**
9. **W2 §6.4, W3 §1.2, W4 §2.4, W5 §2.8–2.9, W7 §2.3 · State as ledger kinds.**
   - These become ledger kinds or projections, not new UserDefaults keys: `room.memory`, `receivedOn`, `circuit.*`, `carried.ever`, `book.sentBack`, `dot.found`, `plays.met`, `second.offered`, `met.last`, `relay.baton`, `draw.log`, `arrival.surfaced`, `swatch.under`, `deep.carried`, `danceword.surfaced`.
   - Keep as `DeviceKey`s (small, bounded): `arrival.bag`, `arrival.lastKind`, `conditions.cursor`, `book.place`, `guide.done`, `firstLine.on`, `forgotAt`.
   - Each score's STATE.md rows stay; their "Lives in" column reads `ledger · <kind>`.
   - · **MUST**
10. **All scores · Per-day key families get a prune rule.** One dictionary key per family (`[day: value]`, trimmed to 400 days at launch) instead of `bindu.<family>.<day>`. Existing families migrate in W0 15.9. · **SHOULD**
11. **W0 (new 15.13) · `@Observable` for every new container; FeedStore migrates.**
    - W5 `ArrivalEngine`, W6 `HouseLedger`/`WalkModel`, W7 `HouseConditions` and W3 `HouseLight`'s holder are `@Observable`.
    - `FeedStore` converts in W0 Slice 15 (`@Environment(FeedStore.self)` at 45 sites).
    - W7 §2.3's `@Published var conditions = HouseConditions()` becomes `let conditions = HouseConditions()` on an `@Observable` store.
    - · **MUST** (the nested-publisher propagation defect, §3.1)
12. **W0 14.0 / new 14.0b · Breath as a pure function.** Retire the per-frame `@Published` and the `@EnvironmentObject breath` at its 10 view types; readers take `t` from their `TimelineView`. Add `\.isFrontmost` from `RootView`, and pause every `TimelineView`, display link and the Metal field on covered layers. · **MUST before W6** (SHOULD in W0)
13. **W6 §2.1 · `FeedRiver` must be `Equatable`, take ids and value inputs, and never read Breath, AxisTravel or the store's per-frame state.** Add a Done line: `_printChanges` probe shows the river body does not re-evaluate while the axis particle breathes; scroll hitch ratio < 5 ms/s on `w1-rhyme-many`. · **MUST**
14. **W1 §3.2 `RiverWeft` · Threads only between visible cards.** One overlay `Canvas`; a preference de-duplicated by id and frame. · **SHOULD**
15. **W1 §2.2 · `RhymeIndex` builds off-main on snapshot change; `accent(of:)` returns a hex string** (the view maps it to `Color`). The file moves to `Domain/RhymeIndex.swift`. · **SHOULD**
16. **W0 (new folder rule) + W1–W7 file placement · Pure types live in `Domain/`, with a house_law grep against SwiftUI/UIKit imports there.**
    - Move into `Domain/`: `Screens/ClothLayout.swift`, `Book/BookModel.swift`, `Store/HouseMeasure.swift`, `Store/ArrivalPicks.swift`, `Store/Porous.swift`, `Store/Round.swift`, `Services/FieldScore.swift`, the logic of `Reception/CloseConductor.swift` and `ElementArc`, and the `LightHand` table.
    - · **SHOULD**
17. **W2 §5 · Rename `Reception/ReceptionViewNew.swift` to `Reception/Grammars/<Room>Grammar.swift`**, one file per new grammar. · **SHOULD**
18. **W2 §12a A · Path fix:** `Screens/RoomView.swift` → `Rooms/RoomView.swift`. · **SHOULD**
19. **W4 · Rename `Store/Gates.swift` to `Domain/ReleaseGates.swift`**, because "gate" already names the Point's gate register and DEALS. · **LATER**
20. **W2 §3.7 + W0 §3 · One `Haptics` service** (one `CHHapticEngine`, channels pulse, hold and room, with the priority rule §4.4 R9). `RoomHaptics` becomes a set of patterns, not an engine. `HeartbeatService` moves onto it. · **SHOULD**
21. **W0 §3 HoldEngine · Display link through a weak proxy, invalidated in `cancel()`/`deinit`.** Haptics go through `Haptics.hold`. Test: a view dismissed mid-hold leaves no running link (the §10 claim-release discipline). · **SHOULD**
22. **Universe (W0 14.3 or W6 §7) · Move the `currentUniRoomId` write out of `UniverseView.draw` (`:939`)** into `UniverseCamera`, on focus change with a 0.5 s hysteresis. · **SHOULD**
23. **W5 §2.7 · Earliest Codex day by `maxRecords=1`, `sort Date asc`, `fields[]=Date`, cached as a `DeviceKey` forever.** Do not add `loadCodexDays()` to `bootstrap()`. · **SHOULD**
24. **W7 §2.2 · House rows join the snapshot pattern** (App Activity delta by `CREATED_TIME()` cursor into a local log). `house-rows.json` folds into it. `fetchOfferedWords` "all time" becomes a filter over the local log. · **SHOULD**
25. **W7 §2.3, W3 §2 · Rebuilds are coalesced** (once per run-loop turn) and off-main where O(n). Dwell is noted to the ledger once per visit, on leave. · **SHOULD**
26. **W6 §2.5 Wall of Voices · Read `CommentIndex`, never refetch.** Drift by `ScrollPosition` updated from a `TimelineView` that pauses when not frontmost; rows virtualized (`LazyVStack`) with no per-row timers. · **SHOULD**
27. **W1 §8.3, W3 §17.3, W6 §14 C, W8 §6 · Replace "no frame > 33 ms" with the §4.5 budget rows** (hitch ratio, p95, launch, memory, request count, 0 × 429). W8 §6 records MetricKit launch and hitch payloads from the device walk to a local file (no upload). · **SHOULD**
28. **W0 15.10 · `house_law.sh` grows the §4.6 structural checks, each with bad, good and absent fixtures.** Add `Tools/check_state.py` (STATE.md ↔ `DeviceKey` ↔ literals) and `Tools/ratchet.txt` (FeedStore lines, publishers, `Date()` sites). · **MUST** (check_state and the network/disk door greps); **SHOULD** (the rest)
29. **W0 15.10 · CLAUDE.md §3/§6/§10 gain** the layer map (§4.1), the failure-mode table (offline · 429 · 5xx · 401/403 · 404 · 422 · ambiguous timeout · schema drift · clock or day rollover mid-session), the performance budget (§4.5) and the engineering rules E1–E12. · **SHOULD**
30. **W0 15.9 · `clearToken()` and FORGET ME reset by rebuilding `AppModel`'s walk-side models**, not by hand-listing properties. Test: every `DeviceKey` marked `FORGET: clear` is absent after `forgetMe()`, and the content snapshot remains. · **SHOULD**
31. **W0 (any slice) · `LLMClient`** takes the two `api.anthropic.com` calls out of `ApertureView`/`PointWorldView`; the key stays in Keychain. The client accepts only canon library text (the 66 stars), never Feed or Codex bodies. · **LATER**
32. **W0 · Routes carry ids** (`.story(id)`, `.compose(id)`, `.returnCeremony(id?)`), resolved from `ContentModel` at render; an unknown id renders absence. LINEAGE: *carries forward*. · **SHOULD**
33. **W8 §1.4 Staged audit + §7 · Snapshot schema bump on delivery day** (`schema: 2` forces one full rebuild after the flip), and a Release post-build `strings` check for harness or sandbox remnants (§4.6). · **SHOULD**
34. **W8 §8 · Add the `screen_audit.py` pass** over a DEBUG-exported snapshot. The denylist stays in `Tools/` and never enters the binary. · **SHOULD**
35. **All scores · Paste rules E1–E12 (§4.7) into each score's "How to work this wave" and add the FeedStore ratchet as a Done line.** · **MUST**
