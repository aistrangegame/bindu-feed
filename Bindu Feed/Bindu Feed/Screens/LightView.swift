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
// One scene per visit, and HE chooses it — six presences stand in the dawn after the
// gate and he walks toward one (E1.1). It is NOT a date-hash: this is the one register
// whose subject is what has not happened yet, and a hash choosing his future for him is
// the wrong gesture in it. Two materials tell you where you are with the words covered:
// the dawn (Near) vs the nave (Far).

private enum LightStage {
    /// `.choosing` — E1.1. The six stand in the dawn and HE picks. It sits after the gate,
    /// never inside it: the stillness gate is the designed exception (accumulate and keep,
    /// force only pauses, *"this is not a test he can fail"*) and the choosing must not touch
    /// it. The way opens by stillness; what he walks toward is then his.
    case approach, hold, choosing, scene, out
}

struct LightView: View {
    @Binding var path: [FeedRoute]
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine

    @State private var stage: LightStage = .approach
    @State private var sceneIndex = 0
    /// Which of the six is under the hand, named but not yet entered.
    @State private var armed: Int?

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
    @State private var holdWork: [DispatchWorkItem] = []   // cancellable on leave

    private let holdMs: Double = 3400             // breath period × 0.34 (comp Hold dur)
    private let carveMs: Double = 4200            // one Declaration line, drawn in (comp)

    private let gateMs: Double = 4600
    private let idleMs: Double = 340

    private var scene: LightScene { LightCanon.scenes[sceneIndex] }
    private var still: Double { min(1, stillMs / gateMs) }

    // How far the scene's arrival has come (0→1): release answers the hand opening (ungrips/3);
    // the others fill as the anchors surface, then hold at 1 once the Declaration is being drawn.
    private var arrivalProgress: Double {
        guard stage == .scene else { return 0 }
        if scene.ungripOnly { return min(1, Double(ungrips) / 3) }
        let a = scene.anchors.isEmpty ? 1 : Double(shownAnchors) / Double(scene.anchors.count)
        return beatLine >= 0 ? 1 : a
    }

    // In the nave the floor floods to LIT cream stone, so the words are DARK ink cut into it
    // (comp --living #16131B / --settled #625849); only the newest anchor is "living", the rest
    // settle. In the dawn (open sky) the words stay light on dark, as they are.
    private var isNave: Bool { scene.material == .nave }
    private var wholeInk: Color { isNave ? Color(hex: shownAnchors > 0 ? "#625849" : "#16131B") : BinduTheme.inkPrimary }
    private func anchorInk(_ newest: Bool) -> Color { isNave ? Color(hex: newest ? "#16131B" : "#625849") : BinduTheme.inkSecondary }
    private var carveInk: Color { isNave ? Color(hex: "#16131B") : Color(hex: "#F5E8DE") }
    private var carveShadow: Color { isNave ? Color.white.opacity(0.92) : Color.black.opacity(0.72) }

    var body: some View {
        ZStack {
            material
            switch stage {
            case .approach: approach
            case .hold:     holdBody
            case .choosing: choosingBody
            case .scene:    sceneBody
                    // `lightBed` — *"the bare light: almost nothing. A single high room-tone,
                    // barely there, so the silence has an edge to it. The breath cues ride on
                    // this."* 528 + 792, six seconds to reach 0.012.
                    .onAppear { soundEngine.lightRoomTone() }
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
                // Each Future scene arrives its OWN way (spine-light.js): converge's motes
                // drifting into one field, warmth blooming from below, kindness rising from
                // behind onto what he built, release's rings brightening one-per-ungrip, morning
                // thinning toward him. Only during the scene, keyed on its arrival progress.
                if stage == .scene {
                    LightDawnArrival(key: scene.key, p: arrivalProgress).ignoresSafeArea()
                }
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

    // E1.1 · THE SIX, STANDING IN THE DAWN — and he chooses.
    //
    // Geometry is canon (`LightPlaces`, `spine-light.js:104-121`): five drifting in the open
    // sky, the Far one low where a floor would be, hit radius 30. The LOOK is the app's — no
    // comp draws these — so it is the register's own idiom and nothing more: a breathing point
    // in the Light's cream with its title beneath, the Far one distinguished because its
    // material is the nave and not the dawn.
    private var choosingBody: some View {
        GeometryReader { geo in
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                let W = Double(geo.size.width), H = Double(geo.size.height)
                let places = LightPlaces.place(W, H, t)
                ZStack(alignment: .topLeading) {
                    Color.clear
                    ForEach(Array(LightCanon.scenes.enumerated()), id: \.offset) { i, sc in
                        let p = i < places.count ? places[i] : .zero
                        let far = sc.material == .nave
                        let br = 0.72 + 0.28 * RoomGeo.breath(t + Double(i) * 1.7)
                        // ONE NAME AT A TIME. The design places POINTS — `place()` spaces the
                        // six by 0.058·H, which is ample for a light and nowhere near enough
                        // for a two-line title. Hanging all six titles under them was my
                        // addition and it collided three of them into one another.
                        //
                        // So the same two stages the Rooms' marks use: the first touch arms
                        // and NAMES, the second enters. It fits this register especially —
                        // he approaches one of six futures and it tells him what it is before
                        // he commits to it — and it adds no instruction, only a name.
                        VStack(spacing: 9) {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color(hex: "#F5F0E8").opacity((far ? 0.55 : 0.85) * br * (armed == i ? 1.25 : 1)),
                                             Color(hex: "#EDE3CE").opacity(0)],
                                    center: .center, startRadius: 0, endRadius: far ? 17 : 13))
                                .frame(width: far ? 34 : 26, height: far ? 34 : 26)
                            if armed == i {
                                Text(sc.title)
                                    .font(.loraItalic(12.5))
                                    .foregroundStyle(Color(hex: "#EDE3CE").opacity(0.78))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 150)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .transition(.opacity)
                            }
                        }
                        .position(x: p.x, y: p.y)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { loc in
                    // `The Instrument v3.html:5872` — `if(k && LT.select(k)) { liteRender(); B.blip(174); }`
                    guard let k = LightPlaces.hit(loc, W, H, t) else {
                        withAnimation(.easeInOut(duration: 0.6)) { armed = nil }; return
                    }
                    if armed == k {
                        sceneIndex = k
                        soundEngine.riteBowl(hz: 174)      // `:5873` — `B.blip(174)`
                        withAnimation(.easeInOut(duration: 1.4)) { stage = .scene }
                    } else {
                        withAnimation(.easeInOut(duration: 0.7)) { armed = k }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

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
            // Cancellable, so leaving during the hold doesn't ring the bowl or flip the stage
            // on a torn-down view (the comp clears both timers on unmount).
            let dim = DispatchWorkItem { withAnimation(.easeInOut(duration: 1.6)) { holdDimmed = true } }
            let open = DispatchWorkItem {
                // `:739` — `Sound.veilLift(3); Sound.bowl(174);` The veil is drawn away and
                // everything drains downward and out; the bowl strikes once into the space
                // it leaves. Subtraction, then a single arrival.
                soundEngine.lightVeilLift(dur: 3)
                soundEngine.riteBowl(hz: 174)                 // the aperture opens; light floods down
                withAnimation(.easeInOut(duration: 1.6)) { stage = .choosing }
            }
            holdWork = [dim, open]
            DispatchQueue.main.asyncAfter(deadline: .now() + holdMs / 1000 * 0.45, execute: dim)
            DispatchQueue.main.asyncAfter(deadline: .now() + holdMs / 1000, execute: open)
        }
        .onDisappear { holdWork.forEach { $0.cancel() } }
    }

    // MARK: - Scene

    // E1.2 · THE COLUMN LIFTS AND MASKS.
    //
    // A five-anchor scene grew downward from the vertical centre and ran off the lit area onto
    // dim stone — the words kept going where the light stopped. Two different things: it LIFTS
    // (the column rises as it fills, so its foot stays inside the light) and it MASKS (what
    // passes the boundary FADES rather than being cut, because a hard edge on stone reads as a
    // crop and a fade reads as the edge of the light).
    //
    // The lift is driven by how much has surfaced — the same quantity the rest of the register
    // reads — not by a measured height, so it cannot fight the layout.
    private var columnLift: Double {
        let filled = scene.anchors.isEmpty ? 0 : Double(shownAnchors) / Double(scene.anchors.count)
        return -filled * 96 - (beatActive ? 42 : 0)
    }

    private var sceneBody: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            // The whole — arrives with the light.
            VStack(alignment: .leading, spacing: 6) {
                ForEach(scene.whole, id: \.self) { line in
                    Text(line).font(.lora(19, weight: .medium)).foregroundStyle(wholeInk)
                }
            }

            // The anchors — one at a time, on a touch (release answers the ungrip).
            ForEach(Array(scene.anchors.prefix(shownAnchors).enumerated()), id: \.offset) { i, line in
                Text(line).font(.lora(15)).lineSpacing(6)
                    .foregroundStyle(anchorInk(i == shownAnchors - 1))   // only the newest is living
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
                            .foregroundStyle(carveInk)
                            .shadow(color: carveShadow, radius: 0, x: 0, y: 1)
                    }
                    // the line surfacing out of the stone right now, as he draws it in
                    if moreBeat, drawing > 0 {
                        Text(scene.beat[beatLine + 1])
                            .font(.lora(17, weight: .semibold))
                            .foregroundStyle(carveInk.opacity(0.06 + drawing * 0.94))
                            .shadow(color: carveShadow.opacity(drawing), radius: 0, x: 0, y: 1)
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
        .offset(y: columnLift)
        .animation(.easeInOut(duration: 1.2), value: columnLift)
        .mask(
            LinearGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.10),
                .init(color: .black, location: 0.88),
                .init(color: .clear, location: 1.0),
            ], startPoint: .top, endPoint: .bottom)
        )
        .contentShape(Rectangle())
        .gesture(sceneGesture)
        .onChange(of: breath.value) { deliverOnExhale() }
        // The conductor's cue — the Light is a breathing exercise where words happen to appear.
        // Bound to the breath's phase (in/hold/out/rest); shown while anchors surface, before
        // the beat takes over its own "press · draw it in" cue.
        .overlay(alignment: .bottom) {
            if stage == .scene, !beatActive, !breathCue.isEmpty {
                Text(breathCue)
                    .font(.spaceMono(9)).tracking(3)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.55))
                    .padding(.bottom, 26)
            }
        }
    }

    // in .40 / hold .15 / out .40 / rest .05 (comp CYCLE), read off the master breath phase.
    private var breathCue: String {
        let p = breath.phase
        if p < 0.40 { return "draw it in" }
        if p < 0.55 { return "hold" }
        if p < 0.95 { return "let it go" }
        return ""
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
                // A press ASKS for the next anchor (the exhale answers) — but the `release`
                // scene answers ONLY the hand opening, so it waits for .onEnded below.
                else if !beatActive && !scene.ungripOnly { advanceAnchor() }
            }
            .onEnded { _ in
                pressing = false
                releaseCarve()                                   // no-op unless mid-carve
                // the hand opened — the `release` scene's anchors advance on the lift
                if !beatActive && scene.ungripOnly && !landed { advanceAnchor() }
            }
    }

    // MARK: - Flow

    private func begin() {
        // E1.1 · NO DAY-HASH. It read: "One scene per visit, deterministic by local-day hash",
        // and a date chose his future for him in the one register whose whole subject is what
        // has not happened yet. The six stand in the dawn and he picks — `spine-light.js:104`,
        // and `The Instrument v3.html:5872` selects on a touch, not on a clock.
        //
        // A ruling from the conflict document that never reached a pass plan, which is exactly
        // how an item survives seven passes: nothing disagreed with it, because nothing asked.

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
        // `The Light v2.html:637` — `Sound.openTheRoom(8.5); Sound.breathIn(6);`
        // The room is heard before it is seen, and the breath draws in and HOLDS.
        soundEngine.lightOpenTheRoom(dur: 8.5)
        soundEngine.lightBreathIn(dur: 6)
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
        // `:786` — `Sound.breathIn(4.2)` on the draw-in. The same gesture as the opening,
        // shorter: he is holding the line rather than entering the room.
        soundEngine.lightBreathIn(dur: 4.2)
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
        holdWork.forEach { $0.cancel() }
        stillMs = 0; shownAnchors = 0; ungrips = 0
        beatLine = -1; drawing = 0; landed = false; holdDimmed = false; pressing = false
        pendingAnchor = false; touching = false; lastInput = Date()
        withAnimation(.easeInOut(duration: 1.0)) { stage = .approach }
        begin()
    }
}

// A few quiet points of light — stars in the dawn, a dim seam in the nave.
// The Future scenes' distinct arrivals (spine-light.js draw()), each its own way in. Additive
// over the base dawn, keyed on the scene and its arrival progress `p`.
private struct LightDawnArrival: View {
    let key: String
    let p: Double

    var body: some View {
        Canvas { ctx, size in
            let W = size.width, H = size.height, A = 1.0
            let bone: [Double] = [237, 227, 206]
            func rect(_ stops: [Gradient.Stop], _ c: CGPoint, _ r: CGFloat) {
                ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                         with: .radialGradient(Gradient(stops: stops), center: c, startRadius: 0, endRadius: r))
            }
            func vrect(_ stops: [Gradient.Stop], _ s: CGPoint, _ e: CGPoint) {
                ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                         with: .linearGradient(Gradient(stops: stops), startPoint: s, endPoint: e))
            }
            switch key {
            case "converge":                                      // scattered motes drift into one field
                for i in 0..<40 {
                    let ang = rnd(Double(i)) * .pi * 2
                    let d0 = max(W, H) * 0.62 * (1 - p) * (0.5 + rnd(Double(i) * 1.7) * 0.8)
                    let px = W * 0.5 + cos(ang) * d0, py = H * 0.44 + sin(ang) * d0
                    ctx.fill(UniGeo.ringPath(px, py, 1.1), with: .color(col(bone, A * (0.20 + p * 0.45))))
                }
            case "warmth":                                        // the heat reaches the hand before the eye
                rect([.init(color: col([255, 206, 150], A * 0.30 * p), location: 0),
                      .init(color: col([255, 206, 150], 0), location: 1)],
                     CGPoint(x: W * 0.5, y: H * 0.86), W * (0.30 + p * 0.80))
            case "kindness":                                      // light rises from behind, onto what he built
                vrect([.init(color: col([255, 232, 200], A * 0.16 * p), location: 0),
                       .init(color: col([255, 232, 200], 0), location: 1)],
                      CGPoint(x: W * 0.5, y: H), CGPoint(x: W * 0.5, y: H * 0.12))
                for i in 0..<9 {
                    let ry = H * (0.30 + Double(i) * 0.055), rw = W * (0.10 + rnd(Double(i) * 2.7) * 0.42)
                    ctx.fill(Path(CGRect(x: W * 0.5 - rw / 2, y: ry, width: rw, height: 1.4)),
                             with: .color(col([255, 236, 208], A * 0.10 * p * (1 - Double(i) / 11))))
                }
            case "release":                                       // brightens one ring per opened hand
                rect([.init(color: col([255, 244, 226], A * 0.24 * p), location: 0),
                      .init(color: col([255, 244, 226], 0), location: 1)],
                     CGPoint(x: W * 0.5, y: H * 0.5), max(W, H) * 0.70)
                let ungrips = p * 3
                for i in 0..<3 {
                    let ok = Double(i) < ungrips ? 1.0 : 0.14
                    ctx.stroke(UniGeo.ringPath(W * 0.5, H * 0.5, W * (0.16 + Double(i) * 0.10)),
                               with: .color(col(bone, A * 0.22 * ok)), lineWidth: 0.7)
                }
            default:                                              // morning: the dawn thins toward him
                vrect([.init(color: col([255, 238, 214], A * 0.20 * p), location: 0),
                       .init(color: col([255, 238, 214], 0), location: 1)],
                      CGPoint(x: W * 0.5, y: H * 0.86), CGPoint(x: W * 0.5, y: H * 0.20))
            }
        }
        .blendMode(.plusLighter)                                  // comp globalCompositeOperation='lighter'
        .allowsHitTesting(false)
    }
    private func rnd(_ i: Double) -> Double { let x = sin(i * 127.1 + 31.4) * 43758.5453; return x - floor(x) }
    private func col(_ c: [Double], _ a: Double) -> Color {
        Color(.sRGB, red: c[0] / 255, green: c[1] / 255, blue: c[2] / 255, opacity: max(0, min(1, a)))
    }
}

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
