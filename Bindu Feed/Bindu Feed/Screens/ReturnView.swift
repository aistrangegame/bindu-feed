import SwiftUI

// THE RETURN — re-meeting a sealed story (Wave 5). Eight movements as one flow:
// Summons → (the fall) → Aged Room → Story Again → Record → Field Settled → Rings
// → Reply → Sealing. The story is the one unaged thing; everything around it wears
// the patina. He adds his own ring; the story does not move.
//
// The past self is NEVER regenerated — the Reply quotes his verbatim sealed words
// via the forward detector, or shows the four native words (ReturnCanon.replyPrompt).
//
// The story shown, its record, its sealed self, and its "how long ago" are all REAL —
// the returned story the user actually sealed (ReturnStoryData, built by the store), or
// canon only when nothing is reachable. The ring (the reply) is PERSISTED — a durable
// Ash-comment write, the same retry-queued path Compose uses.
//
// Wave-5 scope (flagged): the aged patina is a saturate/warm treatment on the aged
// elements, not the full canvas strata; the fall is a fade (the axis fall ships Wave 6).

private enum ReturnStage { case summons, fall, room, story, record, field, rings, reply, sealed }

struct ReturnView: View {
    @Binding var path: [FeedRoute]
    var storyData: ReturnStoryData = .canon        // TODAY's sealed story (rotating), or canon
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var store: FeedStore

    @State private var stage: ReturnStage = .summons
    @State private var anewShown = 0
    @State private var ringAdded = false
    @State private var replyText = ""
    @State private var sealPhase = 0
    // E3.5/E3.6/E3.7 · ONE CAMERA. `The Return v2.html:1045` — *"the strata canvas — one
    // field, one camera, every movement."* `z` and `camNow` are that camera; the fall drives
    // them and every other movement settles them. Nothing else draws a ring.
    @State private var fallStart: Double? = nil
    @State private var z: Double = 0
    @State private var camNow: Double = 0.34
    @State private var whispers = false
    @State private var activeRing = -1
    @State private var activeIn: Double = 1
    @State private var activeTrue: Double = 1
    @State private var ringBirth: Double? = nil
    @State private var camera: Timer? = nil

    // The Audio Anchor — the kept voice of the sealed self, reached here (the descent grants
    // it). Raw, no chrome; the silence is held after it ends.
    @StateObject private var anchor = AudioAnchorPlayer()
    @State private var voiceHeldSilence = false

    // The Reply quotes his real prior words (never generated) — from THIS story's sealed self.
    private var prompt: ReturnCanon.ReplyPrompt { ReturnCanon.replyPrompt(prior: storyData.sealedSelf) }

    var body: some View {
        ZStack {
            Color(hex: "#08070B").ignoresSafeArea()
            // The strata — the aged rings, the seed, the settling dust — living behind every
            // movement (return-strata.js), not a static wash. His own returns, warmed by age.
            // AGE FROM DAYS, NEVER FROM RANK. `age = returnCount/5` was bug class 3 in the
            // open: a story sealed three years ago and returned to once read brand new,
            // while five returns in one week read as a decade old. `ReturnAge.of(days:)` is
            // `return-strata.js:20-23` verbatim — `clamp(pow(days/1095, 0.55))`.
            // Per-ring ages, indexed to the draw loop: `[i]` is the ring at radius `i`, so the
            // outermost/newest sits last. `ringDays` is oldest-first, and the innermost ring is
            // `i == 1`, so it lines up with a single-slot offset.
            ReturnStrata(rings: storyData.returnCount, age: storyData.age,
                         ringAges: [0] + storyData.ringDays.map { ReturnAge.of(days: $0).a },
                         camY: camNow, z: z, whispers: whispers,
                         ringWhens: ["the seed"] + storyData.ringRows.map(\.when),
                         active: activeRing, activeIn: activeIn, activeTrue: activeTrue)

            content.transition(.opacity)

            // Always a quiet way out — never trapped in the Return.
            VStack {
                HStack {
                    Button { if !path.isEmpty { $path.popToRootDissolve() } } label: {
                        Text("‹ leave").spaceMonoTracked(9, em: 2 / 9)
                            .foregroundStyle(ReturnCanon.ashColor.opacity(0.5)).padding(16)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sonicContext(.base)
        .onAppear { runCamera() }
        .onDisappear { anchor.stop(); camera?.invalidate(); camera = nil }
    }

    // The Audio Anchor affordance — quiet, never a loud play button; no scrubber, no timeline,
    // no duration. Tap to hear the voice you left; while it sounds the ember breathes on the
    // master clock; when it ends the silence is HELD (a settling mark, ~2.6s) before the
    // affordance returns. (Law 3: no chrome. Law 4: hold the silence after.)
    @ViewBuilder private func audioAnchor(_ ref: String) -> some View {
        if voiceHeldSilence {
            Text("◌")
                .font(.system(size: 16))
                .foregroundStyle(ReturnCanon.ashColor.opacity(0.30))
                .padding(.top, 8)
                .transition(.opacity)
        } else if anchor.isPlaying, anchor.currentFile == ref {
            Button { anchor.stop() } label: {
                Text("◉")
                    .font(.system(size: 20))
                    .foregroundStyle(ReturnCanon.ashColor)
                    .modifier(RiteBreathe())            // the ember breathes while the voice sounds
            }
            .padding(.top, 8)
        } else {
            Button {
                anchor.play(ref) {
                    // hold the silence after — no snap-back, no autoplay, no replay button
                    withAnimation(.easeInOut(duration: 0.8)) { voiceHeldSilence = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                        withAnimation(.easeInOut(duration: 1.2)) { voiceHeldSilence = false }
                    }
                }
            } label: {
                HStack(spacing: 7) {
                    Text("◉").font(.system(size: 13))
                    Text("hear the voice you left")
                        .spaceMonoTracked(9, em: 1.5 / 9)
                }
                .foregroundStyle(ReturnCanon.ashColor.opacity(0.72))
            }
            .padding(.top, 8)
        }
    }

    @ViewBuilder private var content: some View {
        switch stage {
        case .summons: summons
        case .fall:    fall
        case .room:    room
        case .story:   storyAgain
        case .record:  record
        case .field:   fieldAnew
        case .rings:   rings
        case .reply:   reply
        case .sealed:  sealing
        }
    }

    /// `The Return v2.html:1275` — *"the camera settles at its own height per movement — the
    /// strata sit clear of the words."* The Rings movement lifts it highest (0.255) because
    /// that is the movement ABOUT the rings; during the fall nothing settles, because the
    /// fall is driving the camera itself.
    private var camTarget: Double? {
        switch stage {
        case .fall:    return nil
        case .rings:   return 0.255
        case .summons: return 0.34
        default:       return 0.40
        }
    }

    /// One loop for the whole register: the fall drives `z`/`camY` while it runs, and every
    /// other movement lets the camera settle toward its own height. `:67` — it settles at
    /// 0.018 a frame and never cuts.
    private func runCamera() {
        camera?.invalidate()
        camera = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { _ in
            if let t0 = fallStart {
                let dur = ReturnDepth.duration(breathSeconds: Breath.period)
                let p = min(1, (Date().timeIntervalSinceReferenceDate - t0) / dur)
                z = ReturnDepth.z(atProgress: p)
                camNow = ReturnDepth.camY(atProgress: p)
                if p >= 1 {
                    fallStart = nil; whispers = false
                    soundEngine.riteBowl(hz: 168)              // `:1289` — the landing
                    withAnimation(.easeInOut(duration: 1.2)) { stage = .room }
                }
            } else {
                z = min(1, z + (1 - z) * 0.018 + 0.0004)
                if let target = camTarget { camNow = ReturnDepth.settle(camNow, toward: target) }
            }
            // `:1291-1299` — the new ring grows over 2.6s and comes into true over 4s.
            if let b0 = ringBirth {
                let e = Date().timeIntervalSinceReferenceDate - b0
                activeIn = min(1, e / 2.6)
                activeTrue = min(1, e / 4.0)
                if activeTrue >= 1 { ringBirth = nil }
            }
        }
    }

    private func cross(_ hz: Double, _ next: ReturnStage) {
        soundEngine.fieldThreshold(hz: hz, dur: 7)   // `The Return v2.html:1314` — threshold(hz,7)
        withAnimation(.easeInOut(duration: 1.1)) { stage = next }
    }

    // I · Summons
    private var summons: some View {
        centered {
            Text(ReturnCanon.summonsKicker).spaceMonoTracked(9, em: 2 / 9).foregroundStyle(BinduTheme.inkTertiary)
            Text(ReturnCanon.summonsLine).font(.lora(14)).italic().foregroundStyle(BinduTheme.inkSecondary)
            Text(storyData.title).font(.lora(26, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
                .multilineTextAlignment(.center).padding(.top, 6)
            // The sealed line, cut in — debossed, not printed (the seal is pressed, not written).
            Text("\(storyData.codexId) · sealed \(storyData.sealedWhen)")
                .spaceMonoTracked(9, em: 1 / 9).foregroundStyle(BinduTheme.inkTertiary)
                .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)
            if !storyData.firstMet.isEmpty {
                Text("you first met this · \(storyData.firstMet)")
                    .spaceMonoTracked(9, em: 1 / 9).foregroundStyle(ReturnCanon.ashColor.opacity(0.6))
            }
            hint(ReturnCanon.summonsHint)
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 1.2)) { stage = .fall } }
    }

    // THE FALL — **one continuous camera move through the strata, not an animation.**
    //
    // `The Return v2.html:1278-1292`. This was a port of `UniverseView.drawFall` — the other
    // ceremony's four-layer choreography, its captions and its 5.5s — running BESIDE a strata
    // renderer that could only draw the arrived state. The design has no second renderer: the
    // fall sets `z` and `camY` on the field already behind every movement, turns `whispers`
    // on so each ring names itself as it sweeps past, and stops. See `ReturnDepth`.
    private var fall: some View {
        Color.clear
            .onAppear {
                // `:1279` — the aged bed opens the fall. **The bowl lands at the END**
                // (`:1289`, `else{ whispers=false; Sound.bowl(168); setStage('room'); }`).
                // It was sounding at the start, so the arrival was announced before it
                // happened — the register's one landing, played over the departure.
                soundEngine.agedBed()
                whispers = true
                fallStart = Date().timeIntervalSinceReferenceDate
            }
    }

    // II · Aged Room
    private var room: some View {
        centered {
            Text(ReturnCanon.roomRemembers(room: storyData.roomName)).spaceMonoTracked(9, em: 1.5 / 9).foregroundStyle(BinduTheme.inkTertiary)
            Text(ReturnCanon.roomLine(when: storyData.sealedWhen)).font(.lora(16)).lineSpacing(6).foregroundStyle(BinduTheme.inkSecondary)
                .multilineTextAlignment(.center).padding(.top, 10)
            hint(ReturnCanon.roomHint)
        }
        .contentShape(Rectangle())
        .onTapGesture { cross(126, .story) }
    }

    // III · The Story, Again (the one unaged thing)
    private var storyAgain: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(storyData.title).font(.lora(23, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary).padding(.top, 56)
                Text(ReturnCanon.storyUnchanged).font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
                ForEach(Array(storyData.body.enumerated()), id: \.offset) { _, p in
                    Text(p).font(.lora(16)).lineSpacing(7).foregroundStyle(BinduTheme.inkPrimary)
                }
                Button { cross(168, .record) } label: {
                    Text(ReturnCanon.storyButton).font(.loraItalic(14)).foregroundStyle(ReturnCanon.ashColor).padding(.vertical, 20)
                }
                Color.clear.frame(height: 60)
            }
            .padding(.horizontal, 34)
        }
        .scrollIndicators(.hidden)
    }

    // IV · The Record (the gathering, pressed; the self he sealed, in ash)
    private var record: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(ReturnCanon.recordIntro).font(.lora(15)).italic().foregroundStyle(BinduTheme.inkSecondary).padding(.top, 56)
                ForEach(storyData.record) { v in
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(v.name) · \(v.role)").spaceMonoTracked(9, em: 0.5 / 9).foregroundStyle(v.color.opacity(0.7))
                        Text(v.line).font(.lora(14)).lineSpacing(5).foregroundStyle(BinduTheme.inkSecondary)
                    }
                    .saturation(0.5).brightness(-0.04)     // .pressed — the aged gathering
                }
                Text(ReturnCanon.recordSealedYou(when: storyData.sealedWhen)).spaceMonoTracked(9, em: 0.5 / 9).foregroundStyle(ReturnCanon.ashColor).padding(.top, 8)
                Text(storyData.sealedSelf)
                    .font(.loraItalic(15)).lineSpacing(6)
                    .foregroundStyle(ReturnCanon.ashColor)
                    .saturation(0.85)                       // .dried — the past self, ash terracotta
                    .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)
                // The kept voice, sounding over the aged self — his young voice, not yet knowing
                // what he now knows. Only if the recording is on this device.
                if AudioAnchorPlayer.exists(storyData.audioReference), let ref = storyData.audioReference {
                    audioAnchor(ref)
                }
                Text(ReturnCanon.recordSettled).font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary).padding(.top, 6)
                Button { cross(189, .field) } label: {
                    Text(ReturnCanon.recordButton).font(.loraItalic(14)).foregroundStyle(ReturnCanon.ashColor).padding(.vertical, 18)
                }
                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, 34)
        }
        .scrollIndicators(.hidden)
    }

    // V · The Field, Settled (1–2 voices speak anew, living ink)
    private var fieldAnew: some View {
        centered {
            Text(ReturnCanon.fieldAnewTitle).spaceMonoTracked(9, em: 1.5 / 9).foregroundStyle(BinduTheme.inkTertiary)
            ForEach(Array(storyData.anew.prefix(max(1, anewShown)).enumerated()), id: \.offset) { _, v in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(v.name) · now").spaceMonoTracked(9, em: 0.5 / 9).foregroundStyle(BinduTheme.inkTertiary)
                    Text(v.line).font(.lora(16)).lineSpacing(6).foregroundStyle(BinduTheme.inkPrimary)
                }
                .transition(.opacity).padding(.top, 8)
            }
            Text("\(min(max(1, anewShown), storyData.anew.count)) / \(storyData.anew.count) · the rest keep their record")
                .spaceMonoTracked(8, em: 0.125).foregroundStyle(BinduTheme.inkTertiary).padding(.top, 10)
        }
        .contentShape(Rectangle())
        .onAppear { if anewShown == 0 { anewShown = 1; soundEngine.riteVoice(hz: 285, dur: 7) } }
        .onTapGesture {
            if anewShown < storyData.anew.count {
                withAnimation(.easeInOut(duration: 1.2)) { anewShown += 1 }
                soundEngine.riteVoice(hz: 396, dur: 7)
            } else {
                cross(252, .rings)
            }
        }
    }

    /// E3.2 · `renderRings` — **each prior return, with the words he left there.**
    ///
    /// `Claude Design Round 2/comps/The Return.html:123`. The movement drew concentric circles from a count and said
    /// nothing about any of them; a ring you can see and cannot read is a record of having
    /// spoken with the speech taken out.
    ///
    /// **The oldest row is the strongest.** `ReturnRingRow.fragOpacity` runs `0.34 + 0.5·(1−rel)`
    /// and `rel` is 0 at the oldest, so a ring carried for months reads louder than one made
    /// yesterday. That inversion is the surface's argument and the thing to check first if
    /// this ever looks wrong: a list dimming by recency has it exactly backwards.
    ///
    /// Empty renders nothing at all — a story returned to zero times has no rows, and the
    /// canon body above already says so. No placeholder, no "no returns yet".
    @ViewBuilder private var ringsList: some View {
        let rows = storyData.ringRows
        if !rows.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(rows) { row in
                    let rel = ReturnRingRow.rel(index: row.id, of: rows.count)
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(row.when)
                            .spaceMonoTracked(8, em: 0.15)
                            .foregroundStyle(ReturnDeboss.ink.opacity(ReturnRingRow.whenOpacity(rel: rel)))
                            .frame(width: 74, alignment: .leading)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(row.frag)
                                .font(.lora(13)).lineSpacing(4)
                                .foregroundStyle(BinduTheme.inkPrimary.opacity(ReturnRingRow.fragOpacity(rel: rel)))
                            Text(row.answerLine)
                                .spaceMonoTracked(8, em: 0.1375)
                                .foregroundStyle(BinduTheme.inkTertiary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
        }
    }

    // VI · The Rings
    private var rings: some View {
        centered {
            Text(ReturnCanon.ringsTitle).spaceMonoTracked(9, em: 1.5 / 9).foregroundStyle(BinduTheme.inkTertiary)
            Text(ReturnCanon.ringsBody).font(.lora(14)).lineSpacing(6).foregroundStyle(BinduTheme.inkSecondary)
                .multilineTextAlignment(.center)
            ringsList
            hint(ReturnCanon.ringsHint)
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 1.0)) { stage = .reply } }
    }

    // VII · The Reply (quote-or-four-words; his words, never generated)
    private var reply: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("◉ you, now · in reply to you, \(storyData.sealedWhen)")
                .spaceMonoTracked(9, em: 0.5 / 9).foregroundStyle(ReturnCanon.ashColor)
            if let frame = prompt.frame, let quote = prompt.quote {
                Text(frame).spaceMonoTracked(9, em: 1 / 9).foregroundStyle(BinduTheme.inkTertiary)
                Text("\u{201C}\(quote)\u{201D}")
                    .font(.loraItalic(15)).foregroundStyle(ReturnCanon.ashColor).saturation(0.85)
                    .multilineTextAlignment(.center)
            }
            Text(prompt.ask).font(.lora(18)).italic().foregroundStyle(BinduTheme.inkPrimary)
            TextEditor(text: $replyText)
                .font(.lora(15)).foregroundStyle(BinduTheme.inkPrimary)
                .scrollContentBackground(.hidden).frame(height: 120)
                .tint(ReturnCanon.ashColor)
                .padding(8).background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                .overlay(alignment: .topLeading) {
                    if replyText.isEmpty {
                        Text(ReturnCanon.replyPlaceholder).font(.lora(15)).foregroundStyle(BinduTheme.inkTertiary)
                            .padding(.horizontal, 13).padding(.vertical, 16).allowsHitTesting(false)
                    }
                }
            Text(ReturnCanon.replyKept).spaceMonoTracked(9, em: 1 / 9).foregroundStyle(BinduTheme.inkTertiary)
            Button {
                guard !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                addRing()
            } label: {
                Text(ReturnCanon.addTheRing).font(.lora(16))
                    .foregroundStyle(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                     ? ReturnCanon.ashColor.opacity(0.35) : ReturnCanon.ashColor)
            }
            Spacer()
        }
        .padding(.horizontal, 34)
    }

    /// THE RING CLOSES ONLY WHILE THE HAND ASKS. This is reachable from exactly one place —
    /// the button under his written reply — and from no timer, no `onAppear`, no completion
    /// callback. It writes nothing when the reply is empty: a ring that arrived empty would
    /// be a return he did not make.
    private func addRing() {
        // F2 · `The Return v2.html:1308-1310` — `Sound.ring(idx)` and then, 3.4s later,
        // `Sound.bowl(210)`. The RING comes first and the bowl lands inside its long form:
        // a ring grows over 9s and is not struck, and the bowl is the moment it is sealed.
        soundEngine.ring(step: storyData.returnCount)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
            soundEngine.riteBowl(hz: 210)      // the ring's bowl
        }
        // The ring is now a RING — `Type='Return'` plus its `Return Answer` — not an Ash
        // comment standing in for one. It persisted before, but into the wrong shape: the
        // strata counted comments, so a story he had commented on twice and never returned
        // to drew two rings, and one he had returned to drew none.
        let text = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty, !storyData.storyId.isEmpty {
            let storyId = storyData.storyId
            Task { await store.sealReturn(storyId: storyId, text: text) }
        }
        // E3.6 · `:1291-1299` — `addRing`. The ring is added to the ONE field: it grows over
        // 2.6s and settles from eccentric into true over 4s, *"the visual twin of the sound
        // entering 1.5% flat and coming into tune."* It used to appear in a separate 150pt
        // diagram drawn over the strata, which aged its rings by INDEX and coloured them from
        // a fixed amber — two representations of the same rings, agreeing about nothing.
        activeRing = max(0, storyData.returnCount) + 1
        activeIn = 0; activeTrue = 0
        ringBirth = Date().timeIntervalSinceReferenceDate
        withAnimation(.easeInOut(duration: 1.0)) { stage = .sealed }
    }

    /// E3.11 · **THE SEALING SHOWS HIM WHAT HE KEPT.**
    ///
    /// `AUDIT E3.11` — *"the Sealing never shows him what he kept."* He writes into the reply,
    /// presses *add the ring*, and the closing movement showed him canon prose and a widget:
    /// the one thing absent from the surface was **the thing he had just written**. `replyText`
    /// was read once, to decide whether the button was enabled and what to send, and never
    /// rendered.
    ///
    /// It is the same fault as the rings list one movement earlier (E3.2), at the other end of
    /// the act: **a return you can complete and cannot re-read.** The words go to the base and
    /// the screen moves on without them, so the moment of sealing shows everything except the
    /// seal.
    ///
    /// Drawn with the DEBOSS, because that is what this surface does to a sealed line
    /// (`ReturnPatina` F3): cut into the material rather than laid on it — light on the upper
    /// edge, shadow below. His words are now part of the thing, which is what sealing means.
    @ViewBuilder private var keptWords: some View {
        let kept = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !kept.isEmpty {
            Text(kept)
                .font(.lora(ReturnDeboss.size))
                .italic()
                .lineSpacing(6)
                .multilineTextAlignment(.center)
                .foregroundStyle(ReturnDeboss.ink)
                .shadow(color: ReturnDeboss.shadowDown.color, radius: 0, y: ReturnDeboss.shadowDown.y)
                .shadow(color: ReturnDeboss.shadowUp.color, radius: 0, y: ReturnDeboss.shadowUp.y)
                .padding(.horizontal, 10)
                .padding(.top, 4)
                .transition(.opacity)
        }
    }

    // VIII · The Sealing
    private var sealing: some View {
        centered {
            Text("◉ you, now · today").spaceMonoTracked(9, em: 0.5 / 9).foregroundStyle(ReturnCanon.ashColor)
            if sealPhase == 0 {
                Text(ReturnCanon.sealPlain).font(.loraItalic(14)).foregroundStyle(BinduTheme.inkSecondary).multilineTextAlignment(.center)
            }
            if sealPhase >= 1 {
                Text(ReturnCanon.sealAdded).font(.lora(17, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary).transition(.opacity)
                keptWords
            }
            if sealPhase >= 2 {
                VStack(spacing: 14) {
                    Text(ReturnCanon.sealDwell1).font(.lora(13)).italic().foregroundStyle(BinduTheme.inkTertiary).multilineTextAlignment(.center)
                    Text(ReturnCanon.sealDwell2).font(.lora(13)).italic().foregroundStyle(BinduTheme.inkTertiary).multilineTextAlignment(.center)
                    // walk-continuity — if he crossed from the axis, he goes back to the
                    // depth he left, not to a cold Door. The way back is already open behind
                    // him because the axis was never unmounted; only the route is restored.
                    Button {
                        if let z = store.departureZ() {
                            store.clearDeparture()
                            $path.popToRootDissolve()
                            store.pendingLaunchRoute = .instrument(Int(z.rounded()))
                        } else if !path.isEmpty { $path.popToRootDissolve() }
                    } label: {
                        Text(ReturnCanon.archiveWaits).spaceMonoTracked(10, em: 0.2).foregroundStyle(ReturnCanon.ashColor).padding(.top, 8)
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) { withAnimation(.easeInOut(duration: 1.2)) { sealPhase = 1 } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.6) { withAnimation(.easeInOut(duration: 1.4)) { sealPhase = 2 } }
        }
    }

    // MARK: - Helpers

    private func centered<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        VStack(spacing: 16) { Spacer(); content(); Spacer() }
            .padding(.horizontal, 40).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    private func hint(_ text: String) -> some View {
        Text(text).spaceMonoTracked(9, em: 2 / 9).foregroundStyle(BinduTheme.inkTertiary).modifier(RiteBreathe()).padding(.top, 20)
    }
}

// The strata: a seed with a ring for EACH return he sealed here (not a fixed two), the
// oldest dimmest; the new ring — the reply he adds today — is the plainest, growing.
