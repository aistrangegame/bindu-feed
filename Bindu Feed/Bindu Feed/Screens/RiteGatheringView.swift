import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// III · THE GATHERING — the field gathers around the story.
//
// The one body, enforced by sequence: one presence forward at a time, full-screen
// (its own procedural field, GatheringScene), while any `silent` presences remain
// a dim breathing GROUND of glyphs at the top ("present · wordless"). `passing`
// presences arrive dimmer (0.42) with a single line. The budget (RiteBudget)
// decides who is full / passing / silent — density, not time; the pace is his
// touch. At depth 0 (Wave 2 default) the whole field is full, so all ten speak.
//
// Closes by RESOLVING BACK TO THE ONE BREATH (the ruling's hard rule; the
// prototype lacked this beat): the field falls away to Bindu's ember at center,
// breathing on the master clock, before the handoff to Recognition.

private enum GatherPhase { case intro, playing, resolving }

struct RiteGatheringView: View {
    let depth: Int
    var voices: [RiteVoice] = RiteVoices.all   // this story's real field-comment voices
    let onDone: () -> Void

    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var breath: Breath

    @State private var phase: GatherPhase = .intro
    @State private var tiers: [String: RiteTier] = [:]
    @State private var speaking: [RiteVoice] = []
    @State private var silent: [RiteVoice] = []
    @State private var idx = 0                 // index into `speaking`
    @State private var shown = 1               // lines revealed for the current presence
    @State private var sceneStart = Date()
    @State private var lastAdvance = Date()
    @State private var resolveStart = Date()

    private var current: RiteVoice? {
        guard phase == .playing, idx < speaking.count else { return nil }
        return speaking[idx]
    }
    private func lines(_ v: RiteVoice) -> [String] {
        tiers[v.key] == .passing ? [v.passing] : v.lines
    }
    private func dim(_ v: RiteVoice) -> Double {
        tiers[v.key] == .passing ? 0.42 : 1.0
    }
    private var currentHint: String? {
        switch phase {
        case .playing: return current.map(hintText)
        case .resolving: return RiteWord.promptContinue
        case .intro: return nil
        }
    }

    private func hintText(_ v: RiteVoice) -> String {
        if tiers[v.key] == .passing { return RiteWord.promptPassing }
        if shown >= lines(v).count { return RiteWord.promptNext }
        return RiteWord.promptContinue
    }

    var body: some View {
        TimelineView(.animation) { _ in
            ZStack {
                Color(hex: "#050408").ignoresSafeArea()

                // The silent ground — dim breathing glyphs at the top.
                if !silent.isEmpty && phase == .playing {
                    silentGround
                }

                switch phase {
                case .intro:
                    Text(RiteWord.gatheringIntro)
                        .font(.lora(17)).italic()
                        .foregroundStyle(RiteVoices.voice("lalita")?.color ?? .purple)
                        .transition(.opacity)
                case .playing:
                    if let v = current {
                        presenceLayer(v)
                    }
                case .resolving:
                    resolveLayer
                }

                // The heartbeat — a pulse, not a buzz. Lives in the Gathering only, and it
                // is a VISUAL bar only: `The Rite v3.html` has no haptic anywhere, and the
                // 1.7s `UIImpactFeedbackGenerator` lub-dub that used to run beside this was
                // the app's invention. **A ceremony that taps you on the wrist is asking for
                // attention; this one is asking for stillness.** The bar is the design's own
                // pulse, driven by the master breath rather than by a timer of its own.
                if phase == .playing {
                    heartbeatBar
                }

                // The touch hint — it changes with state (comp The Rite v3): passing voices
                // say "touch to move on", a finished voice "the next presence", else "continue".
                // SLICE 2 · legible. It breathed between 0.28 and 0.56 of the tertiary ink at 9pt
                // — the one line that says what a touch will do was the hardest thing to read.
                if let hint = currentHint {
                    Text(hint)
                        .spaceMonoTracked(10, em: 2 / 10)
                        .foregroundStyle(BinduTheme.inkSecondary.opacity(0.55 + 0.2 * breath.value))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 30)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { tap() }
            // SLICE 2 · WORDS NEVER LEAVE ON THEIR OWN — AND NEVER FOR GOOD. A touch only ever
            // went forward, so a line or a whole presence tapped past was gone with no way back
            // (a double touch lost Sakshi). A swipe to the right steps back: one line, then the
            // presence before, then out of the resolve into the last voice. Forward is still
            // the touch.
            .simultaneousGesture(DragGesture(minimumDistance: 24).onEnded { v in
                if v.translation.width > 50, abs(v.translation.height) < v.translation.width {
                    back()
                }
            })
        }
        .onAppear(perform: begin)
    }

    // MARK: - Layers

    private func presenceLayer(_ v: RiteVoice) -> some View {
        let elapsed = Date().timeIntervalSince(sceneStart)
        let dur = (v.key == "sakshi" || v.key == "shweta") ? 4.2 : 3.4
        let p = min(1.0, elapsed / dur)
        return ZStack {
            GatheringScene(voice: v, progress: p, breath: breath.value, t: Date().timeIntervalSinceReferenceDate)
                .opacity(dim(v))
                .ignoresSafeArea()
            VoiceText(voice: v, lines: lines(v), shown: shown)
        }
        .id(v.key)
        .transition(.opacity)
    }

    private var silentGround: some View {
        HStack(spacing: 16) {
            ForEach(silent) { v in
                Text(v.glyph)
                    .font(.system(size: 15))
                    .foregroundStyle(v.color.opacity(0.30 + 0.20 * breath.value))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 70)
        .overlay(alignment: .top) {
            Text(RiteWord.silentLabel)
                .spaceMonoTracked(8, em: 0.1875)
                .foregroundStyle(BinduTheme.inkTertiary.opacity(0.5 + 0.3 * breath.value))
                .padding(.top, 96)
        }
    }

    private var resolveLayer: some View {
        // The field is gone; Bindu's ember breathes at center on the one breath.
        let t = min(1.0, Date().timeIntervalSince(resolveStart) / 3.2)
        let bindu = RiteVoices.voice("bindu")
        return ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [BinduParticle.core.opacity(0.9 * t), BinduParticle.deep.opacity(0.0)],
                    center: .center, startRadius: 0,
                    endRadius: (10 + 8 * breath.value)))
                .frame(width: (24 + 16 * breath.value), height: (24 + 16 * breath.value))
            Text(bindu?.glyph ?? "·")
                .font(.system(size: 12))
                .foregroundStyle(BinduParticle.core.opacity(t))
        }
        .opacity(t)
    }

    private var heartbeatBar: some View {
        // lub-dub via the master breath's fast harmonic — a pulse, not a buzz.
        let hb = heartbeatOpacity(breath.phase)
        return RoundedRectangle(cornerRadius: 1.5)
            .fill(BinduTheme.inkPrimary.opacity(hb))
            .frame(width: 34, height: 3)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 9)
    }

    private func heartbeatOpacity(_ phase: Double) -> Double {
        // Two thumps per ~1.7s. Derive a fast sub-cycle from the master phase so
        // it stays on one clock. 0.10 rest, 0.30 lub, 0.26 dub.
        let sub = (phase * (Breath.period / 1.7)).truncatingRemainder(dividingBy: 1.0)
        if sub < 0.08 { return 0.10 + 0.20 * (sub / 0.08) }
        if sub < 0.16 { return 0.30 - 0.18 * ((sub - 0.08) / 0.08) }
        if sub < 0.26 { return 0.12 + 0.14 * ((sub - 0.16) / 0.10) }
        if sub < 0.40 { return 0.26 - 0.16 * ((sub - 0.26) / 0.14) }
        return 0.10
    }

    // MARK: - Flow

    private func begin() {
        let all = voices
        let t = RiteBudget.tiers(for: all, depth: depth)
        tiers = t
        speaking = all.filter { t[$0.key] != .silent }
        silent = all.filter { t[$0.key] == .silent }

        // Intro beat, then the first presence.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            guard phase == .intro else { return }      // a touch already began it
            withAnimation(.easeInOut(duration: 1.0)) { phase = .playing }
            enter(0)
        }
    }

    private func enter(_ i: Int) {
        guard i < speaking.count else { resolve(); return }
        idx = i
        shown = 1
        sceneStart = Date()
        lastAdvance = Date()
        let v = speaking[i]
        let count = lines(v).count
        let dur = 4.0 + Double(count) * 3.6
        // Each presence in ITS OWN BODY. `riteVoice` gave all ten the same sine-plus-octave
        // at whatever Hz was passed — the eleven CHAR timbres existed and nothing read them.
        if let k = RoomKey(rawValue: v.key.lowercased()) {
            soundEngine.presence(k, dur: dur)
        } else {
            soundEngine.riteVoice(hz: v.hz, dur: dur)
        }
    }

    private func tap() {
        switch phase {
        case .intro:
            // SLICE 2 · the intro no longer holds him for 2.4s — a touch begins the round.
            withAnimation(.easeInOut(duration: 1.0)) { phase = .playing }
            enter(0)
        case .resolving:
            onDone()
        case .playing:
            guard let v = current else { return }
            lastAdvance = Date()
            let count = lines(v).count
            if shown < count {
                withAnimation(.easeInOut(duration: 1.2)) { shown += 1 }
            } else {
                withAnimation(.easeInOut(duration: 1.0)) { enter(idx + 1) }
            }
        }
    }

    private func resolve() {
        resolveStart = Date()
        withAnimation(.easeInOut(duration: 1.4)) { phase = .resolving }
        // The bed holds; the field has resolved to the one breath. SLICE 2 · it no longer
        // hands him on after 4.5s — nothing moves him on. He stays with the ember as long as
        // he likes; a touch continues to the Recognition, a swipe back returns to the last voice.
    }

    /// SLICE 2 · one step back — a line, then the presence before, then out of the resolve.
    private func back() {
        switch phase {
        case .intro:
            return
        case .resolving:
            guard let last = speaking.indices.last else { return }
            withAnimation(.easeInOut(duration: 1.0)) {
                phase = .playing
                idx = last
                shown = lines(speaking[last]).count
                sceneStart = Date().addingTimeInterval(-10)     // its figure is already drawn
            }
        case .playing:
            if shown > 1 {
                withAnimation(.easeInOut(duration: 0.8)) { shown -= 1 }
            } else if idx > 0 {
                withAnimation(.easeInOut(duration: 1.0)) {
                    idx -= 1
                    shown = lines(speaking[idx]).count
                    sceneStart = Date().addingTimeInterval(-10)
                }
            }
        }
    }

}

// MARK: - The per-presence text overlay (surfacing)
//
// Slice 1 · THE GROUND RETURNS TO THE WORDS. The design lays its gradient on the text block
// alone — `The Rite v3.html:1387` *"rgba(5,4,8,0.55) 32%"* — and the figure above stays clear. The port put a `Spacer` inside the block
// that carries the gradient, so the dark ran the whole height of the screen and every vantage's
// figure sat under a third of it at its own centre (`H × 0.30`): the ground dimmed the ground.
// §10 — *"the ground dims, the chrome hides"* — and the figure is neither; it is the vantage.
//
// And the design's own gradient protected its weakest type least: it begins transparent at the
// top of the block, which is exactly where the 9pt mono caption sits. So the block's gradient
// now begins `captionLead` points ABOVE the caption, and the caption reads on shade while the
// figure above it stays clear. Same stops as the design (clear · 0.55 at 32% · 0.9), started
// higher. The role line returns to the design's 9 — the port had 8:
// `The Rite v3.html:1395` *"<Mono size={9}>{v.role}</Mono>"*

private struct VoiceText: View {
    let voice: RiteVoice
    let lines: [String]
    let shown: Int

    /// How far above the caption the words' ground begins.
    private static let captionLead: CGFloat = 72

    var body: some View {
        // SLICE 2 · A LONG VOICE SCROLLS. The live field's comments run far longer than the
        // design's two or three short lines, and the block was pinned to the foot with no
        // scroll, so a long presence ran off the top of the screen. When it fits it sits
        // exactly where it did; when it doesn't, it becomes a reading he can scroll, on a
        // ground dark enough to read over the figure.
        ViewThatFits(in: .vertical) {
            placed
            ScrollView {
                placed.padding(.top, 110)
            }
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(.bottom)
            .background(Color(hex: "#050408").opacity(0.72).ignoresSafeArea())
        }
    }

    private var placed: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            block
                .padding(.horizontal, 34)
                .padding(.top, voice.isCenter ? 0 : Self.captionLead)
                // SLICE 2 · lowered from 210 / 118. Walked: Bindu's caption sat on the Flower's
                // lowest rings (they reach `cy + 3R` ≈ H·0.30 + 186) and Lalita's header met her
                // loop's lower lobe (`1.16·Ro` ≈ 176 under centre). Both still clear the touch
                // hint at 30.
                .padding(.bottom, voice.isCenter ? 150 : 96)
                .frame(maxWidth: .infinity)
                .background(alignment: .bottom) {
                    if !voice.isCenter {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: Color(hex: "#050408").opacity(0.55), location: 0.32),
                                .init(color: Color(hex: "#050408").opacity(0.9), location: 1),
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
        }
    }

    private var block: some View {
        VStack(alignment: voice.isCenter ? .center : .leading, spacing: 14) {
            // Header: name · verb, avatar chip.
            HStack(spacing: 10) {
                Text(voice.glyph)
                    .font(.system(size: 15))
                    .foregroundStyle(voice.color)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(voice.color.opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(voice.name) · \(voice.verb)")
                        .font(.lora(13)).italic()
                        .foregroundStyle(voice.color)
                    Text(voice.role)
                        .spaceMonoTracked(9, em: 0.15)
                        .foregroundStyle(BinduTheme.inkTertiary)
                    // "answering Sakshi" — the one who speaks in reply (comp The Rite v3).
                    if let answering = voice.answering {
                        Text("answering \(answering)")
                            .spaceMonoTracked(8, em: 0.125)
                            .foregroundStyle(voice.color.opacity(0.6))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: voice.isCenter ? .center : .leading)

            // Body lines, surfacing one per tap.
            ForEach(Array(lines.enumerated()), id: \.offset) { i, line in
                Text(line)
                    .font(.lora(16.5))
                    .lineSpacing(7)
                    .foregroundStyle(BinduTheme.inkPrimary)
                    .multilineTextAlignment(voice.isCenter ? .center : .leading)
                    .frame(maxWidth: .infinity, alignment: voice.isCenter ? .center : .leading)
                    .opacity(i < shown ? 1 : 0)
                    .blur(radius: i < shown ? 0 : 4)
                    .offset(y: i < shown ? 0 : 8)
                    .animation(.easeInOut(duration: 1.9), value: shown)
            }

            if shown >= lines.count {
                Text(voice.close)
                    .font(.system(size: 22))
                    .foregroundStyle(voice.color)
                    .shadow(color: voice.color.opacity(0.5), radius: 12)
                    .frame(maxWidth: .infinity, alignment: voice.isCenter ? .center : .leading)
                    .transition(.opacity)
                    .padding(.top, 4)
            }
        }
    }
}
