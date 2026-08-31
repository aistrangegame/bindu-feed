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
    @State private var anewSpoke = false
    @EnvironmentObject private var breath: Breath
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
    @State private var pulses: [Double] = []

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
                         active: activeRing, activeIn: activeIn, activeTrue: activeTrue,
                         pulses: pulses)

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
        // E3.7 · `return-strata.js:159` — *"a crossing sends one wave out through the strata
        // — sound made visible."* The same event, in both senses at once; the tone alone left
        // the field unmoved by the thing that moved him.
        pulses.append(Date().timeIntervalSinceReferenceDate)
        pulses = pulses.suffix(4)
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
            // `:1093` — the room's own line, in the room's own colour, aged.
            Text(ReturnCanon.roomRemembers(room: storyData.roomName)).spaceMonoTracked(9, em: 0.18)
                .foregroundStyle(ReturnPatina.color(storyData.roomRGB, ReturnPatina.roomLine))
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
                // `:1121` — the walk-on is the ROOM's, not Ash's: it leads further into the
                // story's own room rather than toward the self who sealed it.
                Button { cross(168, .record) } label: {
                    Text(ReturnCanon.storyButton).font(.loraItalic(14))
                        .foregroundStyle(ReturnPatina.color(storyData.roomRGB, ReturnPatina.walkOn))
                        .padding(.vertical, 20)
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
                // E3.8 · **THE PATINA, AS A MATERIAL.** `:1136-1141` — each voice keeps its
                // own hue and is carried toward `#C09550` by an amount that says how much of
                // its identity the thing still is: the rule at the head of `ReturnPatina` is
                // that a border belongs to the room and a name still belongs to the person,
                // so the border takes the most gold and the name the least. The app had a
                // flat `.saturation(0.5).brightness(-0.04)` over the block — one treatment
                // for six materials, and age read as *dimmer* rather than as *older*.
                ForEach(storyData.record) { v in
                    HStack(alignment: .top, spacing: 0) {
                        Rectangle()
                            .fill(ReturnPatina.towardGold(v.hex, ReturnPatina.border))
                            .frame(width: 1)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle().strokeBorder(
                                        ReturnPatina.towardGold(v.hex, ReturnPatina.glyph), lineWidth: 1)
                                    Text(v.glyph).font(.system(size: 8))
                                        .foregroundStyle(ReturnPatina.towardGold(v.hex, ReturnPatina.labelDeep))
                                }
                                .frame(width: 15, height: 15)
                                Text(v.name).font(.lora(12.5, weight: .medium))
                                    .foregroundStyle(ReturnPatina.towardGold(v.hex, ReturnPatina.name))
                                Text(v.role).spaceMonoTracked(8, em: 0.14)
                                    .foregroundStyle(Color(hex: "#EDE8E3").opacity(0.22))
                            }
                            // `:1142` — the line itself is not room-coloured at all: it has
                            // gone to paper, and only the identities keep a hue.
                            Text(v.line).font(.lora(14)).lineSpacing(14 * 0.68)
                                .foregroundStyle(Color(.sRGB, red: 214 / 255, green: 196 / 255,
                                                       blue: 168 / 255, opacity: 0.56))
                        }
                        .padding(.leading, 14)
                    }
                    .fixedSize(horizontal: false, vertical: true)
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

    // V · THE FIELD, SETTLED — **one voice at a time, and each one replaces the last.**
    //
    // `The Return v2.html:1161-1181`. This accumulated: every voice stayed on screen and the
    // next was appended under it, so the movement became a list of two and the counter
    // underneath — `1 / 2`, then `2 / 2` — counted things that were both still visible.
    // `key={v.key}` in the design REMOUNTS the block, which is the whole gesture: you are
    // given one voice, you take it, and it is gone before the next arrives. *"the rest keep
    // their record"* is only true if the one before it stopped being shown.
    //
    // **AND THE LINE ARRIVES ON THE EXHALE** (`:1165`, `onExhale(()=>setShown(true))`). Until
    // it does, the presence is there and has not spoken — which is what makes the wait feel
    // like someone drawing breath rather than a delay. The tap is refused while nothing has
    // been said (`:1167`, `if(!shown)return`), so it cannot be skipped past.
    private var fieldAnew: some View {
        let voices = storyData.anew
        let i = min(anewShown, max(0, voices.count - 1))
        let v = voices.indices.contains(i) ? voices[i] : nil
        return centered {
            Text(ReturnCanon.fieldAnewTitle).spaceMonoTracked(9, em: 0.18)
                .foregroundStyle(BinduTheme.inkTertiary)
            if let v {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        // the 28px disc in the voice's own colour, its glyph inside
                        ZStack {
                            Circle().fill(v.color)
                                .shadow(color: v.color.opacity(0.33), radius: 9)
                            Text(v.glyph).font(.system(size: 11)).foregroundStyle(Color(hex: "#0B0A0C"))
                        }
                        .frame(width: 28, height: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(v.name).font(.lora(14, weight: .medium)).foregroundStyle(v.color)
                            Text(v.role).spaceMonoTracked(9, em: 0.14)
                                .foregroundStyle(BinduTheme.inkTertiary)
                        }
                    }
                    if anewSpoke {
                        Text(v.line).font(.lora(16.5)).lineSpacing(16.5 * 0.74)
                            .foregroundStyle(BinduTheme.inkPrimary)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(v.key)                       // `key={v.key}` — the block is remounted
            }
            Text("\(i + 1) / \(voices.count) · the rest keep their record")
                .spaceMonoTracked(8, em: 0.125).foregroundStyle(BinduTheme.inkTertiary)
                .padding(.top, 10)
        }
        .contentShape(Rectangle())
        .onAppear { speakAnew(voices.first) }
        .onTapGesture {
            guard anewSpoke else { return }          // `:1167` — it cannot be hurried
            if anewShown < voices.count - 1 {
                anewShown += 1
                speakAnew(voices[min(anewShown, voices.count - 1)])
            } else {
                cross(252, .rings)
            }
        }
    }

    /// `:1165` — `Sound.voice(ANEW[i].key, null, 9)` then the line on the exhale. **The voice
    /// sounds as ITSELF**: `presence(_:dur:)` takes pitch from `RoomKey.hz` and timbre from
    /// `CHAR`, where this played `riteVoice(hz: 285)` and then `396` — two fixed pitches that
    /// belonged to whoever spoke first and second rather than to who was speaking.
    private func speakAnew(_ v: ReturnCanon.AnewVoice?) {
        guard let v else { return }
        anewSpoke = false
        if let key = RoomKey(rawValue: v.key) { soundEngine.presence(key, dur: 9) }
        let wait = Breath.exhaleDelay(fromPhase: breath.phase)
        DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
            withAnimation(.easeOut(duration: 2.6)) { anewSpoke = true }
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
                // E3.8 · `:1197-1199` — **the list ends with the thing the rings are rings
                // AROUND.** Without it the movement lists every return and never shows the
                // seed they were made on, and `the seed` is the least gold label on the
                // surface (0.20) because the seed is the story itself and has aged least.
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("the seed")
                        .spaceMonoTracked(8, em: 0.15)
                        .foregroundStyle(ReturnPatina.color(storyData.roomRGB, ReturnPatina.seed))
                        .frame(width: 74, alignment: .leading)
                    Text(storyData.sealedSelf)
                        .font(.lora(13)).lineSpacing(13 * 0.5)
                        .foregroundStyle(Color(hex: "#EDE8E3").opacity(0.8))
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
        }
    }

    // VI · The Rings
    private var rings: some View {
        centered {
            // `:1188` — *one story · every self who met it*, at the light end of the band.
            Text(ReturnCanon.ringsTitle).spaceMonoTracked(9, em: 1.5 / 9)
                .foregroundStyle(ReturnPatina.color(storyData.roomRGB, ReturnPatina.labelLight))
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
