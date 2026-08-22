import SwiftUI

// THE LIGHT — the fifteenth register (Z = −5), reached by STILLNESS, not force.
// Wave 5. No haptic anywhere (a law of this door).
//
//   approach → the stillness gate (4600ms, idle-gated, NEVER resets — not a test
//     he can fail); the Bindu softens and opens as stillness accumulates; force is
//     never rewarded. "It holds until you stop meaning it."
//   scene → whole (arrives with the light) → anchors (2nd person, a touch asks and
//     the next answers; `release` answers only the hand opening) → the beat draws
//     in → the CARVE (a held press ≥900ms) turns it to a 1st-person Declaration,
//     debossed, and writes the Vow → landing.
//   out → "walk back out".
//
// One scene per visit, chosen by date-hash (like the Mirror). Two materials tell
// you where you are with the words covered: the dawn (Near) vs the nave (Far).

private enum LightStage { case approach, scene, out }

struct LightView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine

    @State private var stage: LightStage = .approach
    @State private var sceneIndex = 0

    // Stillness gate
    @State private var stillMs: Double = 0
    @State private var touching = false
    @State private var lastInput = Date()
    @State private var gate: Timer?

    // Scene
    @State private var shownAnchors = 0
    @State private var beatDrew: Double = 0     // beat draw-in 0…1
    @State private var carved = false
    @State private var ungrips = 0
    @State private var pendingAnchor = false      // a touch asked; the next exhale answers

    private let gateMs: Double = 4600
    private let idleMs: Double = 340

    private var scene: LightScene { LightCanon.scenes[sceneIndex] }
    private var still: Double { min(1, stillMs / gateMs) }

    var body: some View {
        ZStack {
            material
            switch stage {
            case .approach: approach
            case .scene:    sceneBody
            case .out:      backOut
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: begin)
        .onDisappear { gate?.invalidate() }
        .sonicContext(.base)
    }

    // MARK: - Material (dawn vs nave)

    @ViewBuilder private var material: some View {
        switch scene.material {
        case .dawn:
            ZStack {
                Color(hex: "#08070B").ignoresSafeArea()
                // A low warmth, an open sky, a horizon — no walls.
                RadialGradient(colors: [Color(hex: "#EDE3CE").opacity(0.10 + 0.06 * breath.value), .clear],
                               center: UnitPoint(x: 0.5, y: 1.02), startRadius: 0, endRadius: 520)
                    .ignoresSafeArea().allowsHitTesting(false)
                LightStars(material: .dawn, breath: breath.value)
            }
        case .nave:
            ZStack {
                Color(hex: "#0A0A0C").ignoresSafeArea()
                // A shaft from an aperture beyond the frame, a pool on stone.
                LinearGradient(colors: [Color(hex: "#FBF9F4").opacity(0.10), .clear],
                               startPoint: .top, endPoint: .center)
                    .ignoresSafeArea().allowsHitTesting(false)
                Ellipse().fill(Color(hex: "#FBF9F4").opacity(0.06))
                    .frame(width: 220, height: 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .offset(y: 170)
                LightStars(material: .nave, breath: breath.value)
            }
        }
    }

    // MARK: - Approach (the stillness gate)

    private var approach: some View {
        ZStack {
            // The Bindu — softens and OPENS with stillness (force never rewarded).
            Circle()
                .fill(RadialGradient(
                    colors: [BinduParticle.core.opacity(0.85 - 0.25 * still), BinduParticle.deep.opacity(0)],
                    center: .center, startRadius: 0,
                    endRadius: 14 * (1.10 + still * 1.30)))
                .frame(width: 28 * (1.10 + still * 1.30), height: 28 * (1.10 + still * 1.30))

            VStack {
                Spacer()
                if still > 0.18 {
                    Text(LightCanon.gateLine)
                        .font(.lora(15)).italic()
                        .foregroundStyle(BinduTheme.inkSecondary.opacity(min(1, (still - 0.18) * 2)))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 44)
                }
                Spacer()
                Text(LightCanon.touchOnce)
                    .font(.spaceMono(9)).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.6 * (1 - still)))
                Text(LightCanon.approachSubtitle)
                    .font(.lora(12)).italic()
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.4))
                    .padding(.top, 6).padding(.bottom, 44)
            }
        }
        .contentShape(Rectangle())
        // A touch only PAUSES the fill; lifting resumes where it paused. Never resets.
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in touching = true; lastInput = Date() }
            .onEnded { _ in touching = false; lastInput = Date() })
    }

    // MARK: - Scene

    private var sceneBody: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            // The whole — arrives with the light.
            VStack(alignment: .leading, spacing: 6) {
                ForEach(scene.whole, id: \.self) { line in
                    Text(line).font(.lora(19, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
                }
            }

            // The anchors — one at a time, on a touch (release answers the ungrip).
            ForEach(Array(scene.anchors.prefix(shownAnchors).enumerated()), id: \.offset) { _, line in
                Text(line).font(.lora(15)).lineSpacing(6)
                    .foregroundStyle(BinduTheme.inkSecondary)
                    .transition(.opacity)
            }

            // The beat — draws in, then the carve turns it 1st-person and cuts it.
            if shownAnchors >= scene.anchors.count {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(scene.beat.enumerated()), id: \.offset) { i, line in
                        Text(line)
                            .font(.lora(17, weight: carved ? .semibold : .regular))
                            .foregroundStyle(carved
                                             ? Color(hex: "#F5E8DE")
                                             : BinduTheme.inkPrimary.opacity(min(1, beatDrew * 1.2)))
                            .shadow(color: carved ? .black.opacity(0.72) : .clear, radius: 0, x: 0, y: 1)
                            .opacity(carved ? 1 : min(1, beatDrew))
                            .id(i)
                    }
                }
                .padding(.top, 6)

                if carved {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(scene.landing)
                            .font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
                        Button { withAnimation(.easeInOut(duration: 1.0)) { stage = .out } } label: {
                            Text(LightCanon.walkBackOut)
                                .font(.spaceMono(10)).tracking(2)
                                .foregroundStyle(Color(hex: "#EDE3CE"))
                        }
                    }
                    .transition(.opacity).padding(.top, 12)
                } else if beatDrew >= 0.9 {
                    Text(LightCanon.beatCue)
                        .font(.spaceMono(9)).tracking(2)
                        .foregroundStyle(BinduTheme.inkTertiary)
                        .modifier(RiteBreathe())
                        .padding(.top, 8)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 38)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .gesture(sceneGesture)
        .onChange(of: breath.value) { deliverOnExhale() }
    }

    // A touch reveals the next anchor (for `release`, the ungrip = the lift). Once
    // the beat is drawn, a held press ≥900ms carves it.
    private var sceneGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.9)
            .onEnded { _ in tryCarve() }
            .simultaneously(with: TapGesture().onEnded { advanceAnchor() })
    }

    // MARK: - Flow

    private func begin() {
        // One scene per visit, deterministic by local-day hash.
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let key = fmt.string(from: Date())
        var h: UInt32 = 2166136261
        for b in key.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        sceneIndex = Int(h % UInt32(LightCanon.scenes.count))

        // The stillness gate — accumulates only while the hand is off the glass and
        // no input for 340ms. It NEVER resets; a touch only pauses the fill.
        gate = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard case .approach = stage else { return }   // pattern-match avoids the isolated Equatable
            let idle = Date().timeIntervalSince(lastInput) * 1000
            if !touching && idle > idleMs {
                stillMs = min(gateMs, stillMs + 50)
                if stillMs >= gateMs { openTheLight() }
            }
        }
    }

    private func openTheLight() {
        gate?.invalidate()
        soundEngine.riteBowl(hz: 174)               // the register frequency; the room opens
        Task { await store.logVeilLifted() }
        withAnimation(.easeInOut(duration: 1.6)) { stage = .scene }
        // The beat draws in once the anchors are done (see advanceAnchor).
    }

    // A touch ASKS; the next exhale answers (the interior's core law). Except `release`,
    // which answers only the hand leaving the glass — each ungrip advances it directly.
    private func advanceAnchor() {
        guard stage == .scene, !carved, shownAnchors < scene.anchors.count else { return }
        if scene.ungripOnly {
            ungrips += 1
            soundEngine.axisUngrip()              // the field answers the opened hand
            revealAnchor()                        // the dawn brightens each time the hand lifts
        } else {
            pendingAnchor = true                  // wait for the breath to turn
        }
    }

    private func revealAnchor() {
        guard shownAnchors < scene.anchors.count else { return }
        withAnimation(.easeInOut(duration: 1.4)) { shownAnchors += 1 }
        if shownAnchors == scene.anchors.count { startBeatDraw() }
    }

    // The exhale answers what the touch asked (delivered near the breath's turn).
    private func deliverOnExhale() {
        guard pendingAnchor, breath.value > 0.9 else { return }
        pendingAnchor = false
        revealAnchor()
    }

    private func startBeatDraw() {
        // The beat draws itself in over ~1s, then waits to be meant (carved).
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            beatDrew = min(1, beatDrew + 0.05)
            if beatDrew >= 1 { t.invalidate() }
        }
    }

    private func tryCarve() {
        guard stage == .scene, !carved, shownAnchors >= scene.anchors.count, beatDrew >= 0.9 else { return }
        withAnimation(.easeInOut(duration: 1.2)) { carved = true }
        // The Vow loop — the Declaration, crystallized, returns via the Mirror.
        let declaration = scene.beat.joined(separator: " ")
        Task { await store.writeVow(text: declaration) }
    }

    // MARK: - Walk back out

    private var backOut: some View {
        VStack(spacing: 18) {
            Spacer()
            ForEach(LightCanon.backOut, id: \.self) { line in
                Text(line).font(.lora(15)).italic()
                    .foregroundStyle(BinduTheme.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            HStack(spacing: 26) {
                Button { restart() } label: {
                    Text("again ›").font(.spaceMono(10)).tracking(2).foregroundStyle(BinduTheme.inkTertiary)
                }
                Button { if !path.isEmpty { path.removeLast(path.count) } } label: {
                    Text("the archive waits ›").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#EDE3CE"))
                }
            }
            .padding(.bottom, 44)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func restart() {
        stillMs = 0; shownAnchors = 0; beatDrew = 0; carved = false; ungrips = 0
        withAnimation(.easeInOut(duration: 1.0)) { stage = .approach }
        begin()
    }
}

// A few quiet points of light — stars in the dawn, a dim seam in the nave.
private struct LightStars: View {
    let material: LightMaterial
    let breath: Double

    var body: some View {
        Canvas { ctx, size in
            let hex = material == .dawn ? "#EDE3CE" : "#FBF9F4"
            let base = material == .dawn ? 0.55 : 0.35
            let count = material == .dawn ? 26 : 8
            for i in 0..<count {
                let r = rnd(Double(i) * 1.7)
                let x = rnd(Double(i) * 3.1) * size.width
                let y = rnd(Double(i) * 5.3) * size.height * (material == .dawn ? 0.7 : 1.0)
                let tw = 0.3 + 0.5 * abs(sin(breath * .pi + r * 6))
                let sz = material == .dawn ? (1.0 + r * 1.6) : 1.4
                ctx.fill(Path(ellipseIn: CGRect(x: x - sz, y: y - sz, width: sz * 2, height: sz * 2)),
                         with: .color(Color(hex: hex).opacity(base * tw)))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    private func rnd(_ i: Double) -> Double {
        let x = sin(i * 127.1 + 31.4) * 43758.5453
        return x - floor(x)
    }
}
