# 6 · RESIDUE — everything in none of the other five files

Generated 2026-08-28 17:30. Raw. Some rows are almost certainly benign; the point is that nothing is filtered before you see it.

## Deferral language in source comments

`TODO` / `FIXME` / `HACK` are all **zero**. The deferrals in this codebase are written in prose instead — which is exactly why no tool ever caught them.

```
Rite/RiteBudget.swift:66:        // "touches" is, for now, the KEPT pair whose thread stays lit plus a depth-rotated
Sound/SoundEngine.swift:804:    // MARK: - Resonance Depth hook (silent stub)
```

### "not yet" — 21 hits
```
Instrument/BinduParticle.swift:42:            // Not yet realised — render at rest so the particle is never absent.
Instrument/AxisModel.swift:80:        .init(i: 0,  z: -5, key: "light",  name: "the Light",   hz: 174,   sub: "what has not yet been"),
Point/PointReadings.swift:61:// NOT YET IMPLEMENTED, and it is structural rather than a constant. In the design the
Point/PointReadings.swift:149:        default:  return "SEEDED ○ — NOT YET WALKED"
Point/PointWorldView.swift:470:            ? "This star is seeded, not yet walked — this is his FIRST TRUE MEETING with the topic: bring its actual substance accurately from its real 
Point/PointWorlds.swift:199:// 8.5px Space Mono at `A*0.38*(0.7+br*0.4)` while the hand is not yet engaged — world-one
App/BinduFeedApp.swift:10:    // starts the shared clock ticking. The audio engine's own LFO is NOT yet
Instrument/InstrumentView.swift:215:        // the Feed edge, where the axis was locked and the Universe not yet hit-testable).
Instrument/InstrumentView.swift:473:        case ..<(-4.4): return "a light that has not yet risen"
Point/PointContent.swift:68:            open: "A seeded star, not yet walked — descend onto it when you want the first real meeting."),
Point/PointContent.swift:273:            open: "This walk was co-built through that glass. What has it reflected back that you had not yet said aloud to anyone?"),
Point/PointContent.swift:331:            walk: "The field’s fourth principle reverses the arrow: need is prayer reaching backward through time, and configurations doing meaningful wor
Point/ApertureEdge.swift:17://      progress, `s` seeded — `STL` spells the last one "SEEDED ○ — NOT YET WALKED". The
Return/ReturnCanon.swift:67:        "not yet\\b",
Screens/DoorView.swift:213:            // Not yet a place — force is absorbed, no navigation (Waves 5/6).
Screens/LightView.swift:37:    /// Which of the six is under the hand, named but not yet entered.
Components/CommentCard.swift:126:            // A voice whose lens hasn't resolved (archetypes not yet loaded) — a quiet Bindu
Rooms/RoomView.swift:30:    /// THE MARK UNDER THE HAND, named but not yet opened. `realIndex`.
Screens/ReturnView.swift:324:                // The kept voice, sounding over the aged self — his young voice, not yet knowing
Store/FeedStore.swift:796:    /// `nil` = not yet determined, and it stays nil until something asks. A surface that
Store/FeedStore.swift:797:    /// gates on met-ness must treat nil as "not yet", never as "unmet" — the design only
```

### "later" — 18 hits
```
Instrument/Breath.swift:15:/// Injected once at the app root and left alone. `WalkContinuity` will later carry
Point/PointContent.swift:49:        PointStar(key: "p-creator", m: "m1", t: "Consciousness as creator", st: "w", ti: "Your own seed, confirmed later.",
Point/PointContent.swift:51:            walk: "Your Codex holds the inversion in your own voice, recorded before the teachers arrived: awareness renders matter; the world appears inside
Return/ReturnStrata.swift:18:    /// later draw as evenly aged, and §10 is explicit: **age comes from days, never from
Return/ReturnCanon.swift:15:    static let sealedSelf = "I wrote it like a comfort — the forgetting is the mercy. But I don\u{2019}t think I believed it yet. I think I was arguing mys
Return/ReturnCanon.swift:21:        AnewVoice(name: "Lalita", line: "You told yourself: ask me later. Look where you are standing. It is later. That is the whole joke, and the whole gra
Return/ReturnCanon.swift:64:        "ask me (later|again)",
Return/ReturnCanon.swift:103:                return ReplyPrompt(frame: "You wrote:", quote: found, ask: "It is later.")
Screens/LightView.swift:528:        // via the Mirror), then the landing arrives a breath and a half later (comp).
Screens/AshComposeView.swift:15:// synchronous archetype responses — the field gathers later via Make.com
Screens/AshComposeView.swift:341:        // surface it on a later load.
Universe/UniWords.swift:36:            "ash": "I wrote it like a comfort — the forgetting is the mercy. But I don’t think I believed it yet. Ask me later if the mercy held.",
Universe/UniverseCamera.swift:74:    // descending" — `descV += (-dy) * 0.00042`, damped 0.935, with a lateral drift at 0.0022
Sound/ThresholdTone.swift:13://   deliberate later kind). Suppressed at cold launch so Arrival owns
Universe/UniverseView.swift:776:    // approached focus (a quiet parallax; the axis pans in depth, not laterally).
Services/AirtableService.swift:533:    /// pool and later surfaces as the reflection-of-the-day ("handed back some
Sound/SoundEngine.swift:170:    /// voice is born reading the one clock. Later voices pick it up automatically.
Store/FeedStore.swift:764:        // August 27 after one return. You cannot first meet a thing later than you sealed it.
```

## Commented-out code

Lines that are commented-out *code* rather than prose (a comment whose body parses as a statement).
```
Point/PointReadings.swift:268://     if (touching) { still = max(0, still − dt*0.55); return null }
Point/PointReadings.swift:666:                        // for the rest of the session. Exactly the fault `handedToRegister`
Point/PointReadings.swift:724:// for having finished it."*
Instrument/InstrumentView.swift:540:                        // for every register in every room, so the thirteen have never had
Point/PointWorldView.swift:349:        // let the world stay legible behind a thing that exists to take the world away.
Instrument/AxisTravel.swift:220:        //     if (still && Z < -2.3) dwell = min(1, dwell + dt*0.30);
Screens/GameView.swift:174:    // for The Watcher, regular Lora elsewhere.
Screens/StoryDetailView.swift:342:    // for a well-formed story, but defensive).
Screens/LightView.swift:220:                        // for a two-line title. Hanging all six titles under them was my
Screens/PracticeDoorView.swift:170:            // if one slips through here (e.g., a "Sentence Source != Bindu"
Screens/PracticeDoorView.swift:284:        // for the Root swap. Notify after the content has visibly settled
Components/TurnOverlay.swift:104:// for the Archive, a scatter for the Universe, a shaft for the Light, a particle for the
Sound/BreathVoice.swift:78:        // if a buffer lacks a valid host time; the re-anchor only removes drift and
Sound/SonicContext.swift:6:// for "what room's weather is on right now, if any." Each top-level /
Sound/SonicContext.swift:16://   .room(Room)                    — that specific room:
Sound/SoundSnapshot.swift:78:    // for new rooms or transient gaps).
Sound/SoundEngine.swift:104:            // if the session or engine refuses, never crashes.
Sound/SoundEngine.swift:480:            // for attention.
```

## `#if DEBUG` survivors

15 blocks. 12 are diagnostic `print` calls; **3 are the TokenEntryView dev doors** — compile-gated out of Release, commented "never ship", and the only tokenless way into the instrument.
```
Screens/RiteRecognitionView.swift:232:            #if DEBUG
Screens/RiteRecognitionView.swift-233-            print("[RiteRecorder] record unavailable: \(error)")
Screens/RiteRecognitionView.swift-234-            #endif
Screens/RiteRecognitionView.swift-235-        }
Screens/TokenEntryView.swift:10:    #if DEBUG
Screens/TokenEntryView.swift-11-    // Dev-only doors (never ship) — walk the Instrument, or the Rite/Gathering (canon
Screens/TokenEntryView.swift-12-    // content, no PAT needed), so both can be verified without a live token.
Screens/TokenEntryView.swift-13-    @State private var showInstrument = false
--
Screens/TokenEntryView.swift:79:                #if DEBUG
Screens/TokenEntryView.swift-80-                Button { demoStartZ = 0; showInstrument = true } label: {
Screens/TokenEntryView.swift-81-                    Text("⟿ walk the Instrument")
Screens/TokenEntryView.swift-82-                        .font(.spaceMono(10)).tracking(2)
--
Screens/TokenEntryView.swift:111:        #if DEBUG
Screens/TokenEntryView.swift-112-        .fullScreenCover(isPresented: $showInstrument) {
Screens/TokenEntryView.swift-113-            ZStack(alignment: .topTrailing) {
Screens/TokenEntryView.swift-114-                InstrumentView(path: $demoPath, startZ: demoStartZ)
Screens/StoryDetailView.swift:503:                #if DEBUG
Screens/StoryDetailView.swift-504-                print("[StoryDetail] Resonance Voice fetch failed for \(story.id): \(error)")
Screens/StoryDetailView.swift-505-                #endif
Screens/StoryDetailView.swift-506-                depthVoice = nil
Sound/AudioAnchorPlayer.swift:63:            #if DEBUG
Sound/AudioAnchorPlayer.swift-64-            print("[AudioAnchorPlayer] play failed: \(error)")
Sound/AudioAnchorPlayer.swift-65-            #endif
Sound/AudioAnchorPlayer.swift-66-            onFinish()
Sound/SoundEngine.swift:105:            #if DEBUG
Sound/SoundEngine.swift-106-            print("[SoundEngine] start failed: \(error)")
Sound/SoundEngine.swift-107-            #endif
Sound/SoundEngine.swift-108-        }
Store/FeedStore.swift:477:            #if DEBUG
Store/FeedStore.swift-478-            print("[FeedStore] postComment failed — queued for retry: \(error)")
Store/FeedStore.swift-479-            #endif
Store/FeedStore.swift-480-            return false
--
Store/FeedStore.swift:611:            #if DEBUG
Store/FeedStore.swift-612-            print("[FeedStore] logStoryMet write failed (local met-cache still set): \(error)")
Store/FeedStore.swift-613-            #endif
Store/FeedStore.swift-614-        }
--
Store/FeedStore.swift:935:            #if DEBUG
Store/FeedStore.swift-936-            print("[FeedStore] writeVow failed — queued for retry: \(error)")
Store/FeedStore.swift-937-            #endif
Store/FeedStore.swift-938-        }
--
Store/FeedStore.swift:999:            #if DEBUG
Store/FeedStore.swift-1000-            print("[FeedStore] markStoryDepth failed for \(storyId): \(error)")
Store/FeedStore.swift-1001-            #endif
Store/FeedStore.swift-1002-        }
Services/AirtableService.swift:125:            #if DEBUG
Services/AirtableService.swift-126-            print("[AirtableService] GET \(url.absoluteString)")
Services/AirtableService.swift-127-            #endif
Services/AirtableService.swift-128-
--
Services/AirtableService.swift:481:                #if DEBUG
Services/AirtableService.swift-482-                print("[AirtableService] Last Activity Date update failed for story \(storyId): \(error)")
Services/AirtableService.swift-483-                #endif
Services/AirtableService.swift-484-            }
--
Services/AirtableService.swift:669:            #if DEBUG
Services/AirtableService.swift-670-            print("[AirtableService] fetchMetStoryIDs failed (sky reads unmet): \(error)")
Services/AirtableService.swift-671-            #endif
Services/AirtableService.swift-672-            return []
--
Services/AirtableService.swift:721:            #if DEBUG
Services/AirtableService.swift-722-            print("[AirtableService] isTodayMet failed (defaulting unmet): \(error)")
Services/AirtableService.swift-723-            #endif
Services/AirtableService.swift-724-            return false
```

## Empty function bodies
```
Components/AshEntryRow.swift:61  var onPlayTap: () -> Void =
Screens/TokenEntryView.swift:5  var onSaved: () -> Void =
```

## Divergences recorded in source but never promoted to CLAUDE.md §10

Source comments that declare a deliberate departure from the design. §10 is meant to be the register of these; a divergence living only in a code comment is invisible to anyone reading the doc.
```
Point/PointReadings.swift:546:                // `open<0.30 -> 'holding it open'` is NOT ported rather than given an
Point/PointWorldView.swift:74:            // clear it. A DELIBERATE geometry divergence: the design's number is right for
Point/PointWorlds.swift:182:    // `nodeAngle` deleted with the ring it served. Note it was NOT the design's angle either:
Rite/RiteBudget.swift:10:// Two deliberate departures from the prototype, both flagged in the Wave 2
Rite/RiteContent.swift:8:// NOT the prototype's own hz values; the divergence is deliberate and flagged in
Rite/RiteContent.swift:61:    // Prototype hz differ (bindu 136 etc.) — divergence is intentional, flagged.
Sound/RiteTones.swift:51:        /// **This parameter is the app's, not the design's.** The design ramps an oscillator's
Rooms/RoomFigures.swift:13://   Gaia      the hand pulls the divergence angle off 137.507° and the families break.
Sound/AxisTones.swift:159:// divergence already recorded when the dwell was ported; the drone follows the accumulator
Store/FeedStore.swift:582:    /// id straight through — which is why the pair written in the same second diverged.
```

## Deferrals recorded only in commit messages
```
8cb137d The four unwalked readings walk; the rope stops eating world IV
```

## Drifted citations in SWIFT SOURCE — a tooling blind spot

`check_citations.py` scans `.md` docs only. **Swift source comments have never been checked**, and they carry 212 design citations. Four of them are impossible — they point past the end of the file they name:

```
Point/PointWorldView.swift:294   cites point-levels.js:1249  — that file has 321 lines
Universe/UniverseCamera.swift:202 cites uni-sky.js:1033      — that file has 337 lines
Universe/UniverseView.swift:354   cites uni-sky.js:1033      — that file has 337 lines
Universe/UniverseView.swift:935   cites uni-sky.js:1336      — that file has 337 lines
```

Two further citations name `A Strange Feed.html`, which is not in the design bundle at all.

This is the same class as §10's own miscitation of `The Instrument v3.html:1084`, and it is the fifth instance of documentation drift found in this build. The fix is to extend `check_citations.py` to Swift comments — 212 citations currently unchecked.
