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

private enum LightStage { case approach, hold, scene, out }

struct LightView: View {
    @Binding var path: [FeedRoute]
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
    @State private var ungrips = 0
    @State private var pendingAnchor = false      // a touch asked; the next exhale answers

    // The Declaration — drawn in one line at a time, each over ~4.2s of held breath
    // (comp The Light v2 · LitSpace). Never delivered whole.
    @State private var beatLine = -1              // highest locked Declaration line (-1 = none yet)
    @State private var drawing: Double = 0        // the current line's draw-in progress, 0…1
    @State private var carveTimer: Timer?
    @State private var landed = false             // the last line locked; the landing has arrived
    @State private var pressing = false           // leading-edge guard for the press gesture

    // The Hold — the dark beat in the shaft between the gate opening and the flood.
    @State private var holdDimmed = false

    private let holdMs: Double = 3400             // breath period × 0.34 (comp Hold dur)
    private let carveMs: Double = 4200            // one Declaration line, drawn in (comp)

    private let gateMs: Double = 4600
    private let idleMs: Double = 340

    private var scene: LightScene { LightCanon.scenes[sceneIndex] }
    private var still: Double { min(1, stillMs / gateMs) }

    var body: some View {
        ZStack {
            material
            switch stage {
            case .approach: approach
            case .hold:     holdBody
            case .scene:    sceneBody
            case .out:      backOut
            }
            // Always a quiet way out — never trapped in the Light.
            VStack {
                HStack {
                    Button { if !path.isEmpty { $path.popToRootDissolve() } } label: {
                        Text("‹ leave").font(.spaceMono(9)).tracking(2)
                            .foregroundStyle(Color(hex: "#EDE3CE").opacity(0.4)).padding(16)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: begin)
        .onDisappear { gate?.invalidate(); carveTimer?.invalidate() }
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
                // The real nave — a dim stone interior, one shaft of light, the pool, the
                // worn rings, the settling beam-dust, flooding dark → lit as the scene opens
                // (The Light v2.html). Replaces the flat gradient + static ellipse stand-in.
                LightNave(breath: breath, still: still, flooding: stage == .scene)
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
                Spacer().frame(height: 90)
                // the scene's name, fading as stillness deepens (comp The Light v2 approach)
                Text(scene.title)
                    .font(.lora(20)).italic()
                    .foregroundStyle(BinduTheme.inkSecondary.opacity(0.75 * (1 - still)))
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
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

    // MARK: - The Hold (standing in the shaft, before the aperture opens)

    private var holdBody: some View {
        VStack {
            Spacer()
            Text("hold")
                .font(.spaceMono(9)).tracking(3)
                .foregroundStyle(BinduTheme.inkTertiary.opacity(holdDimmed ? 0 : 0.6))
                .padding(.bottom, 56)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .onAppear {
            holdDimmed = false
            // the "hold" word fades near the middle of the hold; then the aperture opens
            DispatchQueue.main.asyncAfter(deadline: .now() + holdMs / 1000 * 0.45) {
                withAnimation(.easeInOut(duration: 1.6)) { holdDimmed = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + holdMs / 1000) {
                soundEngine.riteBowl(hz: 174)                 // the aperture opens; light floods down
                withAnimation(.easeInOut(duration: 1.6)) { stage = .scene }
            }
        }
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

            // The Declaration — CUT INTO THE FLOOR one line at a time. Each is drawn in
            // over ~4.2s of held breath (never delivered whole); it locks when he has taken
            // the whole of it. The turn to first person happens in his body first.
            if shownAnchors >= scene.anchors.count {
                VStack(alignment: .leading, spacing: 6) {
                    // the locked lines — debossed into the floor, they never settle
                    ForEach(0..<max(0, beatLine + 1), id: \.self) { i in
                        Text(scene.beat[i])
                            .font(.lora(17, weight: .semibold))
                            .foregroundStyle(Color(hex: "#F5E8DE"))
                            .shadow(color: .black.opacity(0.72), radius: 0, x: 0, y: 1)
                    }
                    // the line surfacing out of the stone right now, as he draws it in
                    if moreBeat, drawing > 0 {
                        Text(scene.beat[beatLine + 1])
                            .font(.lora(17, weight: .semibold))
                            .foregroundStyle(Color(hex: "#F5E8DE").opacity(0.06 + drawing * 0.94))
                            .shadow(color: .black.opacity(0.72 * drawing), radius: 0, x: 0, y: 1)
                            .offset(y: (1 - drawing) * 10)
                            .blur(radius: (1 - drawing) * 3.4)
                    }
                }
                .padding(.top, 6)

                if landed {
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
                } else if moreBeat {
                    Text(drawing > 0 ? "keep drawing it in" : "press · draw it in")
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

    private var beatActive: Bool { shownAnchors >= scene.anchors.count }
    private var moreBeat: Bool { beatLine + 1 < scene.beat.count }

    // A press ASKS for the next anchor (the exhale answers); once the anchors are done,
    // a press-and-hold DRAWS the next Declaration line in. Releasing early lets it sink.
    private var sceneGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !pressing else { return }
                pressing = true
                if beatActive && moreBeat && !landed { beginCarve() }
                else { advanceAnchor() }
            }
            .onEnded { _ in
                pressing = false
                releaseCarve()
            }
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
        Task { await store.logVeilLifted() }
        // Stand in the shaft first (the Hold), then the aperture opens into the scene.
        withAnimation(.easeInOut(duration: 1.0)) { stage = .hold }
    }

    // A touch ASKS; the next exhale answers (the interior's core law). Except `release`,
    // which answers only the hand leaving the glass — each ungrip advances it directly.
    private func advanceAnchor() {
        guard stage == .scene, shownAnchors < scene.anchors.count else { return }
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
        // When the anchors are done the Declaration is ready to be DRAWN IN — nothing
        // surfaces on its own; the first press starts the first line (comp phase 'beat').
    }

    // The exhale answers what the touch asked (delivered near the breath's turn).
    private func deliverOnExhale() {
        guard pendingAnchor, breath.value > 0.9 else { return }
        pendingAnchor = false
        revealAnchor()
    }

    // A press draws the next Declaration line in over ~4.2s; releasing early lets it sink
    // back (comp `release`). It locks only when he has taken the whole of it.
    private func beginCarve() {
        guard stage == .scene, beatActive, moreBeat, carveTimer == nil else { return }
        soundEngine.inkOn(hz: 196)                    // the field leans in while he draws breath
        let start = Date()
        carveTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            let p = min(1, Date().timeIntervalSince(start) / (carveMs / 1000))
            drawing = p
            if p >= 1 { lockCarveLine() }
        }
    }

    private func releaseCarve() {
        guard carveTimer != nil, drawing < 1 else { return }
        carveTimer?.invalidate(); carveTimer = nil
        soundEngine.inkOff()
        withAnimation(.easeOut(duration: 0.4)) { drawing = 0 }
    }

    private func lockCarveLine() {
        carveTimer?.invalidate(); carveTimer = nil
        soundEngine.inkOff()
        soundEngine.axisUngrip()                       // the line locks — a small confirming rise
        withAnimation(.easeInOut(duration: 0.6)) {
            beatLine += 1
            drawing = 0
        }
        // The last line locked — crystallize the whole Declaration into the Vow (it returns
        // via the Mirror), then the landing arrives a breath and a half later (comp).
        if beatLine >= scene.beat.count - 1 {
            let declaration = scene.beat.joined(separator: " ")
            Task { await store.writeVow(text: declaration) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeInOut(duration: 1.0)) { landed = true }
            }
        }
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
                Button { if !path.isEmpty { $path.popToRootDissolve() } } label: {
                    Text("the archive waits ›").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#EDE3CE"))
                }
            }
            .padding(.bottom, 44)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func restart() {
        carveTimer?.invalidate(); carveTimer = nil
        stillMs = 0; shownAnchors = 0; ungrips = 0
        beatLine = -1; drawing = 0; landed = false; holdDimmed = false; pressing = false
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
