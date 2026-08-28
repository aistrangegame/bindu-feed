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
    @State private var fallStart: Double? = nil     // drives the four-layer descent d (0→~0.98)

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
            ReturnStrata(rings: storyData.returnCount, age: storyData.age)

            content.transition(.opacity)

            // Always a quiet way out — never trapped in the Return.
            VStack {
                HStack {
                    Button { if !path.isEmpty { $path.popToRootDissolve() } } label: {
                        Text("‹ leave").font(.spaceMono(9)).tracking(2)
                            .foregroundStyle(ReturnCanon.ashColor.opacity(0.5)).padding(16)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sonicContext(.base)
        .onDisappear { anchor.stop() }
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
                        .font(.spaceMono(9)).tracking(1.5)
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

    private func cross(_ hz: Double, _ next: ReturnStage) {
        soundEngine.riteThreshold(hz: hz, dur: 5)
        withAnimation(.easeInOut(duration: 1.1)) { stage = next }
    }

    // I · Summons
    private var summons: some View {
        centered {
            Text(ReturnCanon.summonsKicker).font(.spaceMono(9)).tracking(2).foregroundStyle(BinduTheme.inkTertiary)
            Text(ReturnCanon.summonsLine).font(.lora(14)).italic().foregroundStyle(BinduTheme.inkSecondary)
            Text(storyData.title).font(.lora(26, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
                .multilineTextAlignment(.center).padding(.top, 6)
            // The sealed line, cut in — debossed, not printed (the seal is pressed, not written).
            Text("\(storyData.codexId) · sealed \(storyData.sealedWhen)")
                .font(.spaceMono(9)).tracking(1).foregroundStyle(BinduTheme.inkTertiary)
                .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)
            if !storyData.firstMet.isEmpty {
                Text("you first met this · \(storyData.firstMet)")
                    .font(.spaceMono(9)).tracking(1).foregroundStyle(ReturnCanon.ashColor.opacity(0.6))
            }
            hint(ReturnCanon.summonsHint)
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 1.2)) { stage = .fall } }
    }

    // The fall — the sealed story's whole life opening in four descending layers (uni-fall.js,
    // the same descent the Universe falls through): 3·strata (his own rings, aged, rising to
    // meet him), 1·approach (the sun, its halo the Resonance Voice), 2·gathering (the aged
    // company settles orbit→seats, drawn as their own glyph-presences), 4·mouth (the Return
    // opening). Driven by d over 5.5s, then the aged room resolves.
    private var fall: some View {
        ZStack {
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                let d = fallStart.map { max(0.02, min(0.98, (t - $0) / 5.5)) } ?? 0.02
                Canvas { ctx, size in drawReturnFall(ctx, size, t: t, d: d) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            soundEngine.riteBowl(hz: 168)                    // the Summons strike
            fallStart = Date().timeIntervalSinceReferenceDate
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                withAnimation(.easeInOut(duration: 1.2)) { stage = .room }
            }
        }
    }

    // Ported from UniverseView.drawFall (uni-fall.js), re-pointed to the Return's own data:
    // depth = returnCount (his rings here), the company = storyData.record (the real aged
    // gathering, kept), colour = roomRGB. Drawn back-to-front; d is the descent 0→1.
    private func drawReturnFall(_ ctx: GraphicsContext, _ size: CGSize, t: Double, d: Double) {
        let W = size.width, H = size.height
        func seg(_ a: Double, _ b: Double) -> Double { max(0, min(1, (d - a) / (b - a))) }
        let app = 1 - seg(0.16, 0.34), gath = seg(0.14, 0.30) * (1 - seg(0.52, 0.74))
        let strat = seg(0.44, 0.66), mouth = seg(0.84, 0.96)
        let col = storyData.roomRGB, br = UniGeo.breath(t), dep = max(0, storyData.returnCount)
        let cx = W / 2, cy = H * (0.40 - 0.10 * gath + 0.05 * strat)
        let enter = min(1, d / 0.3)

        // the ground closes over
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                 with: .color(Color(.sRGB, red: 4 / 255, green: 3 / 255, blue: 7 / 255, opacity: 0.80 * enter + 0.15 * strat)))

        // ── 3 · the strata — his own rings, every return, aged ──
        if strat > 0.004 {
            for k in stride(from: dep, through: 0, by: -1) {
                let age = dep > 0 ? Double(k) / Double(dep) : 0
                let local = max(0, min(1, strat * Double(dep + 1) - Double(dep - k)))
                let rr = (52 + Double(k) * 40) * (0.5 + strat * 0.5) * (1 + local * 1.7)
                let a = (0.36 - age * 0.19) * strat * (1 - local * 0.82)
                if a <= 0.004 { continue }
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - rr, y: cy - rr * 0.9, width: rr * 2, height: rr * 1.8)),
                           with: .color(UniGeo.col(UniGeo.mix(col, UniGeo.BONE, age * 0.7), a)), lineWidth: (1.6 - age * 0.9) * (1 + local))
                let ix = cx + rr * 0.72, iy = cy - rr * 0.30
                ctx.fill(UniGeo.ringPath(ix, iy, 1.6 + (1 - age) * 1.6), with: .color(UniGeo.col(UniGeo.mix(col, UniGeo.BONE, age * 0.8), min(1, a * 1.8))))
            }
        }

        // ── 1 · the approach — the sun, its halo the Resonance Voice (warmth, no body) ──
        let Sr = (6 + br * 2.6) * enter * (1 + app * 3.4 + d * 2.0)
        let hal = Sr * (7.4 + app * 2.2) * (0.94 + br * 0.10)
        ctx.fill(UniGeo.ringPath(cx, cy, hal), with: .radialGradient(Gradient(stops: [
            .init(color: UniGeo.col(UniGeo.mix(col, [255, 250, 242], 0.72), 0.80 * enter * (0.55 + app * 0.45)), location: 0),
            .init(color: UniGeo.col(UniGeo.mix(col, [255, 242, 226], 0.34), 0.40 * enter), location: 0.16),
            .init(color: UniGeo.col(col, 0.17 * enter * (0.6 + app * 0.4)), location: 0.46),
            .init(color: UniGeo.col(col, 0), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: hal))
        ctx.fill(UniGeo.ringPath(cx, cy, Sr), with: .color(Color(.sRGB, red: 1, green: 253 / 255, blue: 250 / 255, opacity: 0.95 * enter)))

        // ── 2 · the gathering — the aged company settles from orbit into its seats, + the story ──
        if gath > 0.004 {
            let set = max(0, min(1, (d - 0.17) / 0.16))
            let S = min(W * 0.40, 158)
            if set > 0.35 {
                ctx.draw(Text(storyData.codexId).font(.spaceMono(9)).foregroundStyle(BinduTheme.inkTertiary),
                         at: CGPoint(x: cx, y: cy - hal * 0.42 - 18))
                ctx.draw(Text(storyData.title).font(.lora(16, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary),
                         at: CGPoint(x: cx, y: cy - hal * 0.42))
            }
            let voices = Array(storyData.record.prefix(6))
            let m = max(1, voices.count)
            for (i, v) in voices.enumerated() {
                let isAsh = v.name.lowercased() == "ash"
                let ang = Double(i) / Double(m) * UniGeo.TAU + t * (1 - set * 0.92) * 0.3
                let orbX = cx + cos(ang) * Sr * 2.2, orbY = cy + sin(ang) * Sr * 2.2
                let f = m < 2 ? 0.5 : (Double(i) + 0.5) / Double(m)
                let seatAng = (0.11 + f * 0.78) * Double.pi
                let seatX = isAsh ? cx - S * 0.24 : cx + cos(seatAng) * S * 1.06
                let seatY = isAsh ? cy + S * 0.46 : cy + sin(seatAng) * S * 0.98
                let px = orbX + (seatX - orbX) * set, py = orbY + (seatY - orbY) * set
                let mc = v.color.opacity(1)
                if set > 0.2 {
                    var line = Path(); line.move(to: CGPoint(x: cx, y: cy)); line.addLine(to: CGPoint(x: px, y: py))
                    ctx.stroke(line, with: .color(v.color.opacity(0.20 * gath)), lineWidth: 0.6)
                }
                let a = 0.66 * gath + set * 0.34
                ctx.draw(Text(v.glyph).font(.lora(isAsh ? 19 : 17)).foregroundStyle(mc.opacity(a)),
                         at: CGPoint(x: px, y: py))
                if set > 0.6 {
                    ctx.draw(Text(v.name.uppercased()).font(.spaceMono(8)).foregroundStyle(mc.opacity(0.66 * (set - 0.6) / 0.4)),
                             at: CGPoint(x: px, y: py + 15))
                }
            }
        }

        // ── 4 · the mouth — the deepest stratum opens the Return ──
        if mouth > 0.01 {
            let mr = (34 + br * 12) * mouth
            ctx.fill(UniGeo.ringPath(cx, cy, mr * 3), with: .radialGradient(Gradient(stops: [
                .init(color: UniGeo.col([255, 246, 230], 0.44 * mouth), location: 0),
                .init(color: UniGeo.col(UniGeo.mix(col, [218, 182, 112], 0.7), 0.26 * mouth), location: 0.34),
                .init(color: UniGeo.col(col, 0), location: 1)]),
                center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: mr * 3))
            ctx.stroke(UniGeo.ringPath(cx, cy, mr * (1.5 + br * 0.14)), with: .color(UniGeo.col(UniGeo.mix(col, [236, 206, 150], 0.8), 0.20 * mouth)), lineWidth: 1)
        }

        // the caption for the layer he is in (uni-fall.js phrases)
        let caps = ["the story, close", "who sat with it", "what you left here", "the mouth of the return"]
        let ci = d < 0.20 ? 0 : (d < 0.50 ? 1 : (d < 0.88 ? 2 : 3))
        ctx.draw(Text(caps[ci]).font(.loraItalic(12)).foregroundStyle(BinduTheme.inkTertiary.opacity(0.8)),
                 at: CGPoint(x: cx, y: H - 74))
    }

    // II · Aged Room
    private var room: some View {
        centered {
            Text(ReturnCanon.roomRemembers(room: storyData.roomName)).font(.spaceMono(9)).tracking(1.5).foregroundStyle(BinduTheme.inkTertiary)
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
                        Text("\(v.name) · \(v.role)").font(.spaceMono(9)).tracking(0.5).foregroundStyle(v.color.opacity(0.7))
                        Text(v.lines.first ?? "").font(.lora(14)).lineSpacing(5).foregroundStyle(BinduTheme.inkSecondary)
                    }
                    .saturation(0.5).brightness(-0.04)     // .pressed — the aged gathering
                }
                Text(ReturnCanon.recordSealedYou(when: storyData.sealedWhen)).font(.spaceMono(9)).tracking(0.5).foregroundStyle(ReturnCanon.ashColor).padding(.top, 8)
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
            Text(ReturnCanon.fieldAnewTitle).font(.spaceMono(9)).tracking(1.5).foregroundStyle(BinduTheme.inkTertiary)
            ForEach(Array(storyData.anew.prefix(max(1, anewShown)).enumerated()), id: \.offset) { _, v in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(v.name) · now").font(.spaceMono(9)).tracking(0.5).foregroundStyle(BinduTheme.inkTertiary)
                    Text(v.line).font(.lora(16)).lineSpacing(6).foregroundStyle(BinduTheme.inkPrimary)
                }
                .transition(.opacity).padding(.top, 8)
            }
            Text("\(min(max(1, anewShown), storyData.anew.count)) / \(storyData.anew.count) · the rest keep their record")
                .font(.spaceMono(8)).tracking(1).foregroundStyle(BinduTheme.inkTertiary).padding(.top, 10)
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

    // VI · The Rings
    private var rings: some View {
        centered {
            Text(ReturnCanon.ringsTitle).font(.spaceMono(9)).tracking(1.5).foregroundStyle(BinduTheme.inkTertiary)
            ReturnRings(newRing: false, priorRings: storyData.returnCount).frame(height: 180)
            Text(ReturnCanon.ringsBody).font(.lora(14)).lineSpacing(6).foregroundStyle(BinduTheme.inkSecondary)
                .multilineTextAlignment(.center)
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
                .font(.spaceMono(9)).tracking(0.5).foregroundStyle(ReturnCanon.ashColor)
            if let frame = prompt.frame, let quote = prompt.quote {
                Text(frame).font(.spaceMono(9)).tracking(1).foregroundStyle(BinduTheme.inkTertiary)
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
            Text(ReturnCanon.replyKept).font(.spaceMono(9)).tracking(1).foregroundStyle(BinduTheme.inkTertiary)
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
        soundEngine.riteBowl(hz: 210)          // the ring's bowl
        // The ring is now a RING — `Type='Return'` plus its `Return Answer` — not an Ash
        // comment standing in for one. It persisted before, but into the wrong shape: the
        // strata counted comments, so a story he had commented on twice and never returned
        // to drew two rings, and one he had returned to drew none.
        let text = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty, !storyData.storyId.isEmpty {
            let storyId = storyData.storyId
            Task { await store.sealReturn(storyId: storyId, text: text) }
        }
        withAnimation(.easeInOut(duration: 1.0)) { stage = .sealed }
    }

    // VIII · The Sealing
    private var sealing: some View {
        centered {
            Text("◉ you, now · today").font(.spaceMono(9)).tracking(0.5).foregroundStyle(ReturnCanon.ashColor)
            ReturnRings(newRing: true, priorRings: storyData.returnCount).frame(height: 150)
            if sealPhase == 0 {
                Text(ReturnCanon.sealPlain).font(.loraItalic(14)).foregroundStyle(BinduTheme.inkSecondary).multilineTextAlignment(.center)
            }
            if sealPhase >= 1 {
                Text(ReturnCanon.sealAdded).font(.lora(17, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary).transition(.opacity)
            }
            if sealPhase >= 2 {
                VStack(spacing: 14) {
                    Text(ReturnCanon.sealDwell1).font(.lora(13)).italic().foregroundStyle(BinduTheme.inkTertiary).multilineTextAlignment(.center)
                    Text(ReturnCanon.sealDwell2).font(.lora(13)).italic().foregroundStyle(BinduTheme.inkTertiary).multilineTextAlignment(.center)
                    Button { if !path.isEmpty { $path.popToRootDissolve() } } label: {
                        Text(ReturnCanon.archiveWaits).font(.spaceMono(10)).tracking(2).foregroundStyle(ReturnCanon.ashColor).padding(.top, 8)
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
        Text(text).font(.spaceMono(9)).tracking(2).foregroundStyle(BinduTheme.inkTertiary).modifier(RiteBreathe()).padding(.top, 20)
    }
}

// The strata: a seed with a ring for EACH return he sealed here (not a fixed two), the
// oldest dimmest; the new ring — the reply he adds today — is the plainest, growing.
private struct ReturnRings: View {
    let newRing: Bool
    var priorRings: Int = 2
    @State private var grow: CGFloat = 0

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            // ZERO IS A REAL ANSWER. `max(1, …)` drew a ring for a return that never
            // happened — a story he has never come back to showed the same strata as one he
            // had returned to once, so the first return changed nothing on screen. *"Around
            // it, a ring for each time you returned."* None means none; the seed stands alone.
            let n = max(0, priorRings)
            // Keep the whole strata inside the frame however many rings there are.
            let gap = min(size.width, size.height) * 0.45 / Double(n + 2)
            // The seed.
            ctx.fill(Path(ellipseIn: CGRect(x: cx - 4, y: cy - 4, width: 8, height: 8)),
                     with: .color(Color(hex: "#E4DCC8")))
            // Past rings — aged (amber), dimming outward toward the oldest.
            for i in stride(from: 1, through: n, by: 1) {
                let r = 8 + Double(i) * gap
                let age = Double(i) / Double(n + 2)               // 0 newest-of-old … →1 oldest
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                           with: .color(Color(hex: "#D0A048").opacity(0.5 - age * 0.30)), lineWidth: 1)
            }
            // The new ring — today's reply, the plainest thing on the screen, growing.
            if newRing {
                let r = (8 + Double(n + 1) * gap) * grow
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                           with: .color(Color(hex: "#E4DCC8").opacity(0.85 * grow)), lineWidth: 1.2)
            }
        }
        .onAppear {
            if newRing { withAnimation(.easeOut(duration: 2.6)) { grow = 1 } }
        }
    }
}
