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
    @State private var heartbeat: Timer?

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

                // The heartbeat — a pulse, not a buzz. Visual bar (the haptic fires
                // from the timer). Lives in the Gathering only.
                if phase == .playing {
                    heartbeatBar
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { tap() }
        }
        .onAppear(perform: begin)
        .onDisappear { heartbeat?.invalidate() }
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
                .font(.spaceMono(8)).tracking(1.5)
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
            withAnimation(.easeInOut(duration: 1.0)) { phase = .playing }
            enter(0)
        }
        startHeartbeat()
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
        soundEngine.riteVoice(hz: v.hz, dur: dur)
    }

    private func tap() {
        switch phase {
        case .intro:
            return
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
        heartbeat?.invalidate()
        resolveStart = Date()
        withAnimation(.easeInOut(duration: 1.4)) { phase = .resolving }
        // The bed holds; the field has resolved to the one breath. Hand off after
        // the ember has settled (a touch also advances — see tap()).
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            if phase == .resolving { onDone() }
        }
    }

    // MARK: - Heartbeat haptic (Gathering only)

    private func startHeartbeat() {
        heartbeat?.invalidate()
        heartbeat = Timer.scheduledTimer(withTimeInterval: 1.7, repeats: true) { _ in
            #if canImport(UIKit)
            let gen = UIImpactFeedbackGenerator(style: .soft)
            gen.impactOccurred(intensity: 0.5)                       // lub
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.35)  // dub
            }
            #endif
        }
    }
}

// MARK: - The per-presence text overlay (surfacing)

private struct VoiceText: View {
    let voice: RiteVoice
    let lines: [String]
    let shown: Int

    var body: some View {
        VStack(alignment: voice.isCenter ? .center : .leading, spacing: 14) {
            Spacer()
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
                        .font(.spaceMono(8)).tracking(1.2)
                        .foregroundStyle(BinduTheme.inkTertiary)
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
        .padding(.horizontal, 34)
        .padding(.bottom, voice.isCenter ? 210 : 118)
        .background(
            voice.isCenter ? nil :
                LinearGradient(
                    colors: [.clear, Color(hex: "#050408").opacity(0.55), Color(hex: "#050408").opacity(0.9)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()
        )
    }
}
