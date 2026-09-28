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
    /// One fetch per visit to the register.
    @State private var loaded = false

    // Stillness gate
    @State private var stillMs: Double = 0
    @State private var touching = false
    @State private var lastInput = Date()
    @State private var gate: Timer?

    // Scene
    /// Latches the blank carving's landing so the 50ms tick cannot re-enter it.
    @State private var landingScheduled = false
    @State private var shownAnchors = 0
    @State private var ungrips = 0
    /// E1.5+E1.6 · the arrival, as real state rather than a reading of how much has been read.
    @State private var arrive: Double = 0
    @State private var sceneTick: Timer?
    @State private var wholeDelivered = false
    /// E1.3 · the Declaration drawing itself in, unasked — `spine-light.js:149`.
    @State private var drew: Double = 0
    @State private var carved = false
    /// E1.7 · **UP TO TWO ASKS MAY BE QUEUED, AND THE EXHALE ANSWERS ONE PER BREATH.**
    /// `Claude Design Round 1/comps/The Light v2.html:759` — `wants = min(2, wants+1)`. A
    /// `Bool` could hold only one, so a second touch during a breath was simply lost: the
    /// register's law is *a touch asks and the next exhale answers*, and dropping the ask
    /// makes it *a touch asks unless you already asked*.
    @State private var wants = 0
    /// The cycle the last delivery went out on — `:763`'s `last`. Delivery needs a NEW
    /// breath, not merely an exhaling one, or one long exhale delivers everything.
    @State private var lastDelivered = -1

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

    /// Today's six, drawn from the base — or the canon six when the base has said nothing.
    ///
    /// **THE FALLBACK IS THE CRASH FIX, NOT A CONVENIENCE.** `scene` is read in `body`, in
    /// `material`, and in both timers, and it used to be `LightCanon.scenes[sceneIndex]` — an
    /// unguarded subscript. That was safe only while the array was a Swift literal of six. Once
    /// it can come from the network it can be empty (no token, no network, a filter that
    /// matches nothing), and an empty array would trap on the first frame of the register.
    ///
    /// Falling back to the canon six is the `FieldSound.fallbackBreath` pattern (§15): the
    /// Breath must never go silent, and the Light must never be a crash. It also means the
    /// six that were authored once still stand when nothing else can be reached.
    /// **THE VISIT'S SIX ARE DECIDED ONCE AND HELD — this was a computed property and that was
    /// a blocker.** `pool` called `LightDraw.today(from:)` on EVERY body evaluation, with a
    /// fresh `localDayString()` and a fresh read of `store.lightScenes`. Three consequences,
    /// all of them on the surface:
    ///
    ///  · **The fetch landing mid-visit replaced the six under him.** `store.lightScenes` is
    ///    `[]` until the lazy load returns, so the first visit of a launch rendered the CANON
    ///    six — the approach naming *"The morning that does not push"* — and then swapped to
    ///    the drawn six mid-gate. A fetch slower than the ~8s gate-and-hold changed the scene
    ///    he was standing in.
    ///  · **Local midnight redrew the day under him**, replacing the scene mid-read.
    ///  · And the swap could TRAP: `sceneBody` subscripts the new scene's `beat` with the old
    ///    scene's `beatLine`, which is out of range for any scene with fewer Declaration lines
    ///    — including all seven `[blank — his own carving]` scenes, whose `beat` is empty.
    ///
    /// It also ran inside `TimelineView(.animation)`, so a UserDefaults read plus a 70-entry
    /// dictionary build happened every frame, and the day's first draw performed a UserDefaults
    /// WRITE from inside view evaluation.
    ///
    /// Settled at most once per visit by `settleSix()`, and never re-read after.
    @State private var sixToday: [LightScene] = []

    private var pool: [LightScene] {
        sixToday.isEmpty ? LightCanon.scenes : sixToday
    }

    /// Decide the day's six, once. Idempotent by `sixToday.isEmpty`.
    ///
    /// `force` is the last moment it can be deferred: the gate completing is when the six stop
    /// being an implementation detail and become the thing he is looking at. If the fetch has
    /// not landed by then the canon six stand for this visit — a stable walk on the fallback,
    /// rather than a correct pool arriving late enough to move the ground.
    private func settleSix(force: Bool = false) {
        guard sixToday.isEmpty else { return }
        let drawn = LightDraw.today(from: store.lightScenes)
        if !drawn.isEmpty { sixToday = drawn }
        else if force { sixToday = LightCanon.scenes }
    }

    private var scene: LightScene {
        let p = pool
        // Still not a bare subscript: `sceneIndex` comes from `LightPlaces.hit` (0…5) and the
        // pool is normally six, but a short pool must bend rather than trap.
        return p.indices.contains(sceneIndex) ? p[sceneIndex] : (p.first ?? LightCanon.scenes[0])
    }
    private var still: Double { min(1, stillMs / gateMs) }

    // How far the scene's arrival has come (0→1): release answers the hand opening (ungrips/3);
    // the others fill as the anchors surface, then hold at 1 once the Declaration is being drawn.
    private var arrivalProgress: Double {
        guard stage == .scene else { return 0 }
        return arrive
    }

    // In the nave the floor floods to LIT cream stone, so the words are DARK ink cut into it
    // (comp --living #16131B / --settled #625849); only the newest anchor is "living", the rest
    // settle. In the dawn (open sky) the words stay light on dark, as they are.
    private var isNave: Bool { scene.material == .nave }
    private var wholeInk: Color { isNave ? Color(hex: shownAnchors > 0 ? "#625849" : "#16131B") : BinduTheme.inkPrimary }
    private func anchorInk(_ newest: Bool) -> Color { isNave ? Color(hex: newest ? "#16131B" : "#625849") : BinduTheme.inkSecondary }
    private var carveInk: Color { isNave ? Color(hex: "#16131B") : Color(hex: "#F5E8DE") }
    private var carveShadow: Color { isNave ? Color.white.opacity(0.92) : Color.black.opacity(0.72) }
    /// `:30` — `0 -0.5px 0.5px rgba(22,19,27,0.22)`, the dark lip above the cut.
    private var carveRim: Color { isNave ? Color(hex: "#16131B").opacity(0.22) : Color.white.opacity(0.16) }

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
                        Text("‹ leave").spaceMonoTracked(9, em: 2 / 9)
                            .foregroundStyle(Color(hex: "#EDE3CE").opacity(0.4)).padding(16)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: begin)
        // Lazy, like the Mirror's (`MirrorView:171-175`) — not `bootstrap()`, because most
        // opens never reach the Light and the approach's 4600ms gate is ample cover for a
        // fetch. `loaded` guards the re-entry; `foundationLoaded` is the same precondition
        // every content surface waits on.
        // **`id:` — the precedent this cites carries it and this dropped it.**
        // `MirrorView:63` is `.task(id: store.foundationLoaded)`. A `.task` with no id runs
        // once per appearance: if `foundationLoaded` was still false at the instant the Light
        // appeared, the guard returned and nothing ever re-fired, so the visit stood on the
        // canon six and the seventy never loaded until he left and came back. Keyed on the
        // same precondition, it re-runs the moment the foundation lands.
        .task(id: store.foundationLoaded) {
            guard !loaded, store.foundationLoaded else { return }
            await store.loadLightScenes()
            loaded = true
            settleSix()          // the six become decidable the instant the rows arrive
        }
        .onDisappear { gate?.invalidate(); carveTimer?.invalidate(); sceneTick?.invalidate() }
        .sonicContext(.base)
    }

    // MARK: - Material (dawn vs nave)

    /// **WHAT HE IS STANDING IN BEFORE HE HAS CHOSEN IS THE REGISTER, NOT A SCENE.**
    /// `material` switched on `scene.material`, and `scene` is `pool[sceneIndex]` with
    /// `sceneIndex` still 0 — so the approach, the hold and the choosing all rendered whatever
    /// the draw happened to put first. With six hand-written scenes that was always the canon
    /// morning and always `.dawn`, so the bug could not appear; with seventy it can be one of
    /// the seven `the particle and space` rows, and the stillness gate then fills over black
    /// space with a static red glow behind the Bindu, and the six *"standing in the dawn"*
    /// stand in a sky that is not the dawn. `canon/spine-light.js` is unambiguous that the
    /// choosing happens in the dawn. Only once he is inside a scene does that scene's material
    /// take over — and `.out` keeps it, because leaving happens from where he was.
    private var standingMaterial: LightMaterial {
        switch stage {
        case .scene, .out: return scene.material
        default:           return .dawn
        }
    }

    @ViewBuilder private var material: some View {
        switch standingMaterial {
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
                    LightDawnArrival(arrival: scene.arrival, p: arrivalProgress).ignoresSafeArea()
                }
            }
        case .particleAndSpace:
            // **NO HORIZON AND NO GROUND.** The dawn puts a low warmth at `y = 1.02` and keeps
            // its stars in the upper 0.7 of the frame — both are a floor, and a floor is the
            // one thing these seven scenes deny. So there is no ground gradient here and the
            // stars fill the whole frame: space in every direction, and the particle in it.
            //
            // The particle is the app's own, not a new colour — `BinduParticle.core`, the same
            // ember the Instrument rests on. These scenes are the Essence family; the point
            // they fall away to is the point the whole app is named for.
            ZStack {
                Color(hex: "#050408").ignoresSafeArea()
                // The falling-away, drawn where subtraction is possible: outside the additive
                // Canvas. As the arrival fills, the sky goes and the point stays — which is
                // what `dissolve` says, and what the additive wash above cannot do alone.
                LightStars(material: .particleAndSpace, breath: breath.value)
                    .opacity(1 - 0.88 * arrivalProgress)
                Circle()
                    .fill(RadialGradient(
                        colors: [BinduParticle.core.opacity(0.50 + 0.18 * breath.value),
                                 BinduParticle.deep.opacity(0)],
                        center: .center, startRadius: 0, endRadius: 44))
                    .frame(width: 88, height: 88)
                    .allowsHitTesting(false)
                if stage == .scene {
                    LightDawnArrival(arrival: scene.arrival, p: arrivalProgress).ignoresSafeArea()
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
                // `The Light v2.html:680-681` — `opacity: 1 - prog*0.55`. **THE PLACE'S NAME
                // STAYS.** It fades to a FLOOR of 0.45, never to nothing: he is going still in
                // front of a named thing, and the name is the last thing to go because it is
                // the only thing on the screen that says where he is.
                Text(scene.title)
                    .font(.lora(20)).italic()
                    .foregroundStyle(BinduTheme.inkSecondary.opacity(1 - still * 0.55))
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
                    .spaceMonoTracked(9, em: 2 / 9)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.6 * (1 - still)))
                // `:682-683` — `opacity: 1 - prog`. **THE SENTENCE GOES.** It is the
                // invitation, and an invitation still on screen once he has accepted it is
                // nagging. Held at a flat 0.4 the app had these two exactly INVERTED — the
                // name faded to nothing and the sentence stood forever — so going still left
                // the wrong line up.
                Text(LightCanon.approachSubtitle)
                    .font(.lora(12)).italic()
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(1 - still))
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
    // sky, the Far one low where a floor would be, hit radius 30.
    //
    // **THE LOOK IS CANON TOO, AND THE COMMENT THAT USED TO STAND HERE SAID OTHERWISE.** It
    // read *"no comp draws these — so it is the register's own idiom"*, and `spine-light.js:186-204`
    // (extracted from `The Instrument v3.html:4074-4091`) draws all six, term by term. A false
    // statement about the corpus is what licensed the invention: nobody looked again, because
    // the file said there was nothing to look at.
    //
    // What the design actually says, and the app had inverted:
    //
    //   · TWO MATERIALS, NOT ONE. `far ? pc : c` — the Far one is `pool` #FBF9F4, the stone;
    //     the five futures are `hex` #EDE3CE, the dawn. The app drew all six in one invented
    //     #F5F0E8, so the Light's two materials became one.
    //   · THE FAR ONE IS DIMMEST. `far ? 0.40 : 0.62`. The app had `far ? 0.55 : 0.85`.
    //   · **THE FAR ONE IS SMALLEST** — `far ? 16 : 22` — and the app drew it BIGGEST, at
    //     `far ? 17 : 13`. The relation was reversed, so the floor read as the brightest, most
    //     present thing in the dawn.
    //   · IT IS NOT A STAR. `:200-202` strokes a horizontal seam ±W·0.13 through it in stone
    //     at `al*0.30`, under the design's own words: *"the Far one is a seam, not a star —
    //     stone, below."* Absent entirely.
    //
    // Together the app made the floor the most prominent of the six futures, in the wrong
    // material, as a star. The one thing that is NOT a future to be chosen was presented as
    // the most choosable.
    //
    // KEPT, and app-own: the two-stage arm/name. The design places POINTS and the app must
    // place titles too — see the note at the `VStack` below.
    private var choosingBody: some View {
        GeometryReader { geo in
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                let W = Double(geo.size.width), H = Double(geo.size.height)
                let places = LightPlaces.place(W, H, t)
                ZStack(alignment: .topLeading) {
                    Color.clear
                    ForEach(Array(pool.enumerated()), id: \.offset) { i, sc in
                        // No `.zero` fallback. It used to read `i < places.count ? … : .zero`,
                        // which is how seventy scenes would have stacked invisibly in the
                        // top-left under the leave button rather than failing loudly. The draw
                        // seeds exactly as many as `place()` positions, so a mismatch is a bug
                        // to see, not to absorb.
                        let p = places[min(i, places.count - 1)]
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
                        // `:193` — `al = a*(far?0.40:0.62)`; the arm factor is the app's.
                        let material = Color(hex: far ? LightCanon.pool : LightCanon.hex)
                        let al = (far ? 0.40 : 0.62) * br * (armed == i ? 1.25 : 1)
                        let halo = far ? 16.0 : 22.0            // `:195` — the Far one SMALLER
                        VStack(spacing: 9) {
                            ZStack {
                                // `:196` — the wash, `al*0.55` at the centre to nothing.
                                Circle()
                                    .fill(RadialGradient(
                                        colors: [material.opacity(al * 0.55), material.opacity(0)],
                                        center: .center, startRadius: 0, endRadius: halo))
                                    .frame(width: halo * 2, height: halo * 2)
                                // `:198-199` — the point itself, `rr + br*0.5`, at full `al`.
                                Circle()
                                    .fill(material.opacity(al))
                                    .frame(width: ((far ? 2.0 : 2.6) + br * 0.5) * 2,
                                           height: ((far ? 2.0 : 2.6) + br * 0.5) * 2)
                                // `:200-202` — *"the Far one is a seam, not a star — stone,
                                // below."* A horizontal rule through it, and the only thing
                                // in the dawn that is not a point of light.
                                if far {
                                    Rectangle()
                                        .fill(Color(hex: LightCanon.pool).opacity(al * 0.30))
                                        .frame(width: W * 0.26, height: 0.7)
                                }
                            }
                            .frame(width: halo * 2, height: halo * 2)
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
                        // Stood inside — one pulse, carrying the scene it was stood in.
                        let chosen = pool.indices.contains(k) ? pool[k] : nil
                        Task {
                            await store.logVeilLifted(sceneId: chosen?.recordId,
                                                      sceneTitle: chosen?.title)
                        }
                        soundEngine.blip(hz: 174)          // `:5873` — `B.blip(174)`, and now actually a blip
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
                .spaceMonoTracked(9, em: 3 / 9)
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

    // E1.17 · **THE TYPE IS THE REGISTER'S ONLY VOICE HERE, SO ITS SIZES ARE THE CONTENT.**
    // `The Light v2.html:826-853`. Every number below is that block's, and three of them are
    // not decoration:
    //
    //  · **the whole SHRINKS, 21 → 15, over 2.6s** as the first anchor lands (`:827-828`
    //    transitions `font-size`, `color` and `line-height` together). It arrives at the size
    //    of the only thing on the floor and demotes itself to a heading once it has been
    //    received. The app held it at a fixed 19 — between the two, so it was never either.
    //  · **the Declaration is 21, not 17, and carries NO extra weight** (`:841`). The app made
    //    it `.semibold` to read as cut; the comp cuts it with the shadow pair, not the face.
    //  · **the deboss is TWO shadows** (`:30`) — white below AND a dark hairline above. One
    //    shadow is a drop shadow; the pair is a groove.
    private var wholeIsAlone: Bool { shownAnchors == 0 }
    private var settledInk: Color { anchorInk(false) }

    private var sceneBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            // The whole — arrives with the light, then settles as the anchors take over.
            VStack(alignment: .leading, spacing: 6) {
                // Indexed, not `id: \.self`: two identical lines in one WHOLE collide and
                // SwiftUI drops one. Six hand-checked scenes never hit it; seventy-six might.
                ForEach(Array(scene.whole.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .loraSize(LightType.wholeSize(alone: wholeIsAlone))
                        .tracking(LightType.wholeTracking(alone: wholeIsAlone))
                        .lineSpacing(LightType.wholeLeading(alone: wholeIsAlone))
                        .foregroundStyle(wholeInk)
                }
            }
            .padding(.bottom, LightType.wholeGap(alone: wholeIsAlone))
            .animation(.easeInOut(duration: 2.6), value: wholeIsAlone)

            // The anchors — one at a time, on a touch (release answers the ungrip).
            ForEach(Array(scene.anchors.prefix(shownAnchors).enumerated()), id: \.offset) { i, line in
                Text(line).font(.lora(LightType.anchorSize)).lineSpacing(LightType.anchorLeading)
                    .foregroundStyle(anchorInk(i == shownAnchors - 1))   // only the newest is living
                    .padding(.bottom, LightType.anchorGap)
                    .transition(.opacity)
            }

            // The Declaration — CUT INTO THE FLOOR one line at a time. Each is drawn in
            // over ~4.2s of held breath (never delivered whole); it locks when he has taken
            // the whole of it. The turn to first person happens in his body first.
            if shownAnchors >= scene.anchors.count {
                VStack(alignment: .leading, spacing: LightType.beatGap) {
                    // the locked lines — debossed into the floor, they never settle
                    ForEach(0..<max(0, beatLine + 1), id: \.self) { i in
                        Text(scene.beat[i])
                            .font(.lora(LightType.beatSize)).tracking(LightType.beatTracking).lineSpacing(LightType.beatLeading)
                            .foregroundStyle(carveInk)
                            .shadow(color: carveShadow, radius: 0, x: 0, y: 1)
                            .shadow(color: carveRim, radius: 0.5, x: 0, y: -0.5)
                    }
                    // the line surfacing out of the stone right now, as he draws it in
                    if moreBeat, drawing > 0 {
                        Text(scene.beat[beatLine + 1])
                            .font(.lora(LightType.beatSize)).tracking(LightType.beatTracking).lineSpacing(LightType.beatLeading)
                            .foregroundStyle(carveInk.opacity(0.06 + drawing * 0.94))
                            // `:848` — the highlight RISES with the draw (`0 ${drawing}px`), so
                            // the groove deepens as the line surfaces rather than arriving cut.
                            .shadow(color: carveShadow.opacity(drawing * 0.95), radius: 0, x: 0, y: drawing)
                            .offset(y: (1 - drawing) * 10)
                            .blur(radius: (1 - drawing) * 3.4)
                    }
                }
                .padding(.top, 6)

                if landed {
                    VStack(alignment: .leading, spacing: 16) {
                        // `[none]` is an authored value, not a missing one: some scenes end on
                        // the Declaration and carry nothing out. An empty `Text` would leave a
                        // silent gap above the way out; drawing nothing is what the row says.
                        if scene.hasLanding {
                            Text(scene.landing)
                                .font(.loraItalic(LightType.landingSize)).lineSpacing(LightType.landingLeading)
                                .foregroundStyle(settledInk)
                        }
                        Button {
                            // `The Light v2.html:801` — `const leave = () => {
                            // Sound.closeTheRoom(6); Sound.darkReturns(); onLeave(); }`.
                            // This called no sound at all, so the bed `lightVeilLift`
                            // drained never came back. *AUDIT E4.1 / G3.1.*
                            //
                            // `closeTheRoom(6)` is the FIRST half and was still missing after
                            // that fix: the room tone kept sounding for its own 40s release
                            // wherever he went next. It is the same mechanism as
                            // `field-sound.js:307 lightOff(dur)` under a second name — both
                            // cancel the schedule and ramp the room's gain to zero — and the
                            // two files carry different defaults (6 and 5), so the Light's own
                            // number is passed explicitly rather than left to either default.
                            soundEngine.lightOff(dur: 6)
                            soundEngine.darkReturns()
                            withAnimation(.easeInOut(duration: 1.0)) { stage = .out }
                        } label: {
                            Text(LightCanon.walkBackOut)
                                .spaceMonoTracked(10, em: 0.2)
                                .foregroundStyle(Color(hex: "#EDE3CE"))
                        }
                    }
                    .transition(.opacity).padding(.top, 12)
                } else if moreBeat {
                    // E1.4 · **THE AUTHORED CUE, AT LAST** — `The Instrument v3.html:5282`
                    // `if(!LT.carved) h += '<div class="hold">hold to mean it</div>'`, named as
                    // canon at `REVIEW-AND-WIRING.md:48` and sitting declared-and-unused at
                    // `LightCanon.beatCue` for the whole build while the app invented
                    // `"press · draw it in"` / `"keep drawing it in"` to describe six presses.
                    // **The words could not be ported before the gesture was**: `hold to mean
                    // it` over a six-press beat is authored copy on the wrong mechanism, which
                    // passes every checker and reads as fixed.
                    Text(LightCanon.beatCue)
                        .spaceMonoTracked(9, em: 2 / 9)
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
                    .spaceMonoTracked(9, em: 3 / 9)
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

    /// **THE SCENE WHOSE DECLARATION IS HIS TO WRITE.** Seven of the seventy-six carry
    /// `[blank — his own carving]`, and the parser holds that as `beat: []` + `carvingIsHis`.
    ///
    /// The subscript at the carve was never the danger — `moreBeat` is false on an empty beat,
    /// so nothing traps. **The danger was a dead end:** `landed` false and `moreBeat` false
    /// means no cue, no landing and no way on but `‹ leave`, which reads as a broken scene
    /// rather than an authored silence.
    ///
    /// So a blank carving completes on its anchors and goes to its landing. **Nothing is
    /// substituted** — the Declaration is simply not the app's to write, and the app does not
    /// pretend one arrived.
    ///
    /// OWED (Wave 3): the surface where he carves it. That is almost certainly the same
    /// surface as the Light's recognition — his voice, kept, landing after the scene — and
    /// building two would be building one twice. Recorded rather than approximated here.
    private var awaitingHisCarving: Bool { beatActive && scene.carvingIsHis && !landed }

    // A press ASKS for the next anchor (the exhale answers); once the anchors are done,
    // a press-and-hold DRAWS the next Declaration line in. Releasing early lets it sink.
    private var sceneGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !pressing else { return }
                pressing = true
                // E1.3 · **ONE HELD PRESS CARVES, and only once `drew >= 0.9`** (`:178`):
                // he cannot mean it before it is there to be meant. This called `beginCarve`,
                // which drew ONE LINE in over `carveMs` per press — six presses for six lines,
                // in the register whose sentence is *it is not asked for, it is MEANT*.
                if beatActive && moreBeat && !landed,
                   LightCanon.LightBeat.mayCarve(drew: drew, carved: carved) { beginCarve() }
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
            // E4.2 · **THE GATE MADE AUDIBLE, IN THE ONE REGISTER THAT IS ABOUT WAITING.**
            //
            // `setStillness` existed and had exactly ONE caller, `InstrumentView:290`. The
            // Light — the register whose entire approach IS a 4600ms accumulation — never
            // called it, so the gate ran in silence and the only sign of progress was
            // visual. §10 names why that matters: this drone does not accompany the
            // accumulator, **it IS the accumulator, audible.**
            //
            // Called every tick rather than on a threshold, and OUTSIDE the idle branch, so
            // it follows the fill in both directions: a touch must be heard cutting it, not
            // just heard failing to advance it. `still` is the same 0…1 the visuals ride, so
            // the two cannot drift apart.
            soundEngine.setStillness(fill: still, touching: touching)
        }
    }

    /// E1.5+E1.6 · `canon/spine-light.js:136-148`'s `tick`, in the app's idiom. The arrival
    /// runs on its OWN clock and the reading waits for it — the inversion this pair fixes is
    /// that the app had the reading drive the arrival instead.
    private func startSceneTick() {
        sceneTick?.invalidate()
        var last = Date()
        sceneTick = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard case .scene = stage else { return }
            let now = Date(); let dt = now.timeIntervalSince(last); last = now
            if arrive < 1 {
                arrive = scene.ungripOnly
                    ? LightCanon.LightArrival.fromUngrips(ungrips)
                    : LightCanon.LightArrival.step(arrive, dt: dt, touching: touching)
            }
            // *"the arrival IS the delivery: when the dawn has assembled, the whole is simply
            // there. He never has to ask for the first thing."* `:147-148`
            // E1.3 · `:149` — while the beat is up it draws ITSELF in, `dt*0.85`, ≈1.18s,
            // **with no press**. Nothing is asked of him while the Declaration arrives; the
            // app required a held press per line to draw each one.
            if arrive >= 1 && beatActive && moreBeat && !carved {
                drew = LightCanon.LightBeat.draw(drew, dt: dt)
            }
            // A blank carving has no Declaration to draw in, so the scene would otherwise sit
            // at the last anchor with nothing on offer. It completes on the anchors instead —
            // and completes SILENTLY, because the one thing that must never happen here is a
            // line arriving where his own words go.
            // **THE SAME NUMBER AS THE CARVED PATH, ON THE WRONG PARAMETER.** `:828` waits
            // `Breath.period * 1.6` (16s) and THEN dissolves the landing in over 1.0s, which is
            // the comp's `setTimeout(…, breathMs*1.6)`. This used that number as the fade's
            // DURATION with no wait, so the landing and `walk back out ›` began appearing while
            // the last anchor was still arriving, and took sixteen seconds to do it. A sibling
            // transposition — the right constant, the wrong parameter, and it reads as
            // considered precisely because the neighbour carries the same number (§10).
            //
            // And it had no latch, so a 50ms tick re-entered `withAnimation` twenty times a
            // second for the rest of the scene.
            if arrive >= 1 && awaitingHisCarving && !landingScheduled {
                landingScheduled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + Breath.period * 1.6) {
                    withAnimation(.easeInOut(duration: 1.0)) { landed = true }
                }
            }
            if arrive >= 1 && !wholeDelivered {
                wholeDelivered = true
                withAnimation(.easeInOut(duration: 1.2)) { }
            }
        }
    }

    private func openTheLight() {
        // `The Light v2.html:637` — `Sound.openTheRoom(8.5); Sound.breathIn(6);`
        // The room is heard before it is seen, and the breath draws in and HOLDS.
        soundEngine.lightOpenTheRoom(dur: 8.5)
        soundEngine.lightBreathIn(dur: 6)
        gate?.invalidate()
        // THE LAST MOMENT THE SIX CAN BE DEFERRED. Past here he is looking at them, so they
        // stop moving: if the fetch has not landed, the canon six stand for this visit rather
        // than the ground changing under him a second later.
        settleSix(force: true)
        startSceneTick()
        // The pulse used to fire HERE, at the gate — before he had chosen anything, so it
        // recorded "the Light was opened" and could name no scene. It fires on entering a
        // scene now (`choosingBody`'s second touch), because *stood inside* is what the
        // activity says and what the sky's brightness is derived from. Opening the gate and
        // walking back out is not a visit to a scene.
        // Stand in the shaft first (the Hold), then the aperture opens into the scene.
        withAnimation(.easeInOut(duration: 1.0)) { stage = .hold }
    }

    // A touch ASKS; the next exhale answers (the interior's core law). Except `release`,
    // which answers only the hand leaving the glass — each ungrip advances it directly.
    private func advanceAnchor() {
        // `advance()` — `:169` — is blocked while `arrive < 1`. Nothing is readable until
        // the gate completes; the whole arrives by itself and is never asked for.
        guard stage == .scene, shownAnchors < scene.anchors.count else { return }
        guard LightCanon.LightArrival.mayAdvance(arrive: arrive) || (scene.ungripOnly && arrive < 1)
        else { return }
        // E1.5 · **THE UNGRIP GATES THE ARRIVAL; IT DOES NOT REVEAL A LINE.**
        // `:152-155` — `ungripped()` counts only while `arrive < 1`, and once the scene has
        // assembled, release's anchors advance on touch *like every other scene* (`:139-142`
        // is explicit that only the ARRIVAL is different). This did both at once, so five
        // anchors against three counted ungrips saturated the gate at anchor 3, and canon's
        // *"the dawn does not assemble until the hand has opened three times, then the scene
        // begins"* became *"each lift reveals a line."*
        if scene.ungripOnly && arrive < 1 {
            ungrips += 1
            soundEngine.axisUngrip()              // the field answers the opened hand
        } else {
            wants = min(2, wants + 1)             // `:759` — a second ask is kept
        }
    }

    private func revealAnchor() {
        guard shownAnchors < scene.anchors.count else { return }
        withAnimation(.easeInOut(duration: 1.4)) { shownAnchors += 1 }
        // When the anchors are done the Declaration is ready to be DRAWN IN — nothing
        // surfaces on its own; the first press starts the first line (comp phase 'beat').
    }

    // The exhale answers what the touch asked (delivered near the breath's turn).
    /// E1.7 · `:764-765` — fires only on a NEW breath cycle whose phase is `'out'`.
    ///
    /// This read `breath.value > 0.9`, and on an eased 0→1→0 curve that is **the peak of the
    /// INHALE** — so the register's one law, *a touch asks and the next exhale answers*,
    /// delivered on the wrong half of the breath. The value alone cannot tell the two halves
    /// apart: 0.9 rising and 0.9 falling are the same number. The linear `phase` can —
    /// `0.5 … 1.0` is the falling half.
    private func deliverOnExhale() {
        guard wants > 0 else { return }
        guard breath.phase >= 0.5, breath.cycle != lastDelivered else { return }
        lastDelivered = breath.cycle
        wants -= 1
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
        // C7.8 · `The Instrument v3.html:5374` — `if(held0>=900&&LT.carve()){ …; B.carry(174); }`.
        // **CARRY IS THE VOICE FOR A LINE HE MEANT**, and this played `ungrip` — which is the
        // design's answer to an OPENED hand at `:5368`, the opposite gesture. Three rising
        // steps at 174 · 261 · 348 that stay in the room for 6.5s, against a 1.2s rise that
        // goes away: *"a perspective taken up… no list, no collection, nothing counted."*
        soundEngine.carryTone(hz: 174)
        withAnimation(.easeInOut(duration: 0.6)) {
            beatLine += 1
            drawing = 0
            drew = 0; carved = false          // `:174` — the next beat draws itself in afresh
        }
        // The last line locked — crystallize the whole Declaration into the Vow (it returns
        // via the Mirror), then the landing arrives a breath and a half later (comp).
        if beatLine >= scene.beat.count - 1 {
            let declaration = scene.beat.joined(separator: " ")
            Task { await store.writeVow(text: declaration) }
            // E1.8 · `Claude Design Round 1/comps/The Light v2.html:792` —
            // `setTimeout(…, breathMs*1.6)`, and `breathMs` is the true breath: **16 000ms**,
            // not 1.6 seconds. The comment said *"a breath and a half later"* and the number
            // said a breath and a half of nothing — a tenth of the wait, so the landing
            // arrived while the last line was still settling instead of after it had been sat
            // with. The unit was dropped, and the prose kept describing the intent.
            DispatchQueue.main.asyncAfter(deadline: .now() + Breath.period * 1.6) {
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
                    Text("again ›").spaceMonoTracked(10, em: 0.2).foregroundStyle(BinduTheme.inkTertiary)
                }
                Button { if !path.isEmpty { $path.popToRootDissolve() } } label: {
                    Text("the archive waits ›").spaceMonoTracked(10, em: 0.2).foregroundStyle(Color(hex: "#EDE3CE"))
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
        stillMs = 0; shownAnchors = 0; ungrips = 0; arrive = 0; wholeDelivered = false
        drew = 0; carved = false
        // **`landingScheduled` AND `armed` BOTH BELONG HERE, AND NEITHER WAS.**
        // `landingScheduled` is the latch added to stop the 50ms tick re-entering the blank
        // carving's landing — and a latch with no reset is a one-shot for the lifetime of the
        // view. Left out, the SECOND visit to any of the seven `[blank — his own carving]`
        // scenes could never reach `landed`: no landing, no `walk back out ›`, only `‹ leave`.
        // **Exactly the dead end the latch's own comment says the mechanism exists to prevent**,
        // reintroduced by the fix for it, and invisible on any first walk.
        //
        // `armed` is older and the same shape: it survived `restart()`, so re-approaching found
        // a point already armed and already named, and one tap entered it — collapsing the
        // two-stage arm-then-commit that §10 records as this register's whole affordance.
        landingScheduled = false; armed = nil
        beatLine = -1; drawing = 0; landed = false; holdDimmed = false; pressing = false
        wants = 0; lastDelivered = -1; touching = false; lastInput = Date()
        withAnimation(.easeInOut(duration: 1.0)) { stage = .approach }
        begin()
    }
}

// A few quiet points of light — stars in the dawn, a dim seam in the nave.
// The Future scenes' distinct arrivals (spine-light.js draw()), each its own way in. Additive
// over the base dawn, keyed on HOW THE SCENE ARRIVES and its progress `p`.
//
// E1.15 · **THIS SWITCHED ON THE SCENE'S KEY AND THAT WAS A LATENT BUG.** `L.draw`'s wash
// branch (`:205-248`) reads as a switch on identity, and the port copied the shape — which is
// indistinguishable from correct while there are six hand-written scenes whose keys ARE their
// arrivals. With seventy-six from the base, every unknown key falls to `default:` and renders
// `morning`'s stillness wash over a scene that arrives by turning, or by release. Canon names
// the quantity in its own header — *"Every one of them arrives by a form of NOT forcing —
// stillness, convergence, warmth, turning, release"* — and the model simply never carried it.
private struct LightDawnArrival: View {
    let arrival: LightArrivalKind
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
            switch arrival {
            case .convergence:                                      // scattered motes drift into one field
                for i in 0..<40 {
                    let ang = rnd(Double(i)) * .pi * 2
                    let d0 = max(W, H) * 0.62 * (1 - p) * (0.5 + rnd(Double(i) * 1.7) * 0.8)
                    let px = W * 0.5 + cos(ang) * d0, py = H * 0.44 + sin(ang) * d0
                    ctx.fill(UniGeo.ringPath(px, py, 1.1), with: .color(col(bone, A * (0.20 + p * 0.45))))
                }
            case .warmth:                                        // the heat reaches the hand before the eye
                rect([.init(color: col([255, 206, 150], A * 0.30 * p), location: 0),
                      .init(color: col([255, 206, 150], 0), location: 1)],
                     CGPoint(x: W * 0.5, y: H * 0.86), W * (0.30 + p * 0.80))
            case .turning:                                      // light rises from behind, onto what he built
                vrect([.init(color: col([255, 232, 200], A * 0.16 * p), location: 0),
                       .init(color: col([255, 232, 200], 0), location: 1)],
                      CGPoint(x: W * 0.5, y: H), CGPoint(x: W * 0.5, y: H * 0.12))
                for i in 0..<9 {
                    let ry = H * (0.30 + Double(i) * 0.055), rw = W * (0.10 + rnd(Double(i) * 2.7) * 0.42)
                    ctx.fill(Path(CGRect(x: W * 0.5 - rw / 2, y: ry, width: rw, height: 1.4)),
                             with: .color(col([255, 236, 208], A * 0.10 * p * (1 - Double(i) / 11))))
                }
            case .release:                                       // brightens one ring per opened hand
                rect([.init(color: col([255, 244, 226], A * 0.24 * p), location: 0),
                      .init(color: col([255, 244, 226], 0), location: 1)],
                     CGPoint(x: W * 0.5, y: H * 0.5), max(W, H) * 0.70)
                let ungrips = p * 3
                for i in 0..<3 {
                    let ok = Double(i) < ungrips ? 1.0 : 0.14
                    ctx.stroke(UniGeo.ringPath(W * 0.5, H * 0.5, W * (0.16 + Double(i) * 0.10)),
                               with: .color(col(bone, A * 0.22 * ok)), lineWidth: 0.7)
                }
            case .dissolve:                                       // everything falls away to the point
                // **THIS CANVAS IS ADDITIVE — `.blendMode(.plusLighter)` below — SO NOTHING
                // DRAWN HERE CAN EVER DARKEN.** The first version of this case stroked
                // nine near-black rings (`[5,4,8]`) to close a vignette from the edges inward,
                // and additive blending contributed at most ~2/255: the field never dimmed, the
                // forty stars of the space sky stayed at full brightness for the whole scene,
                // and the only thing that happened was a red radial shrinking. A subtraction
                // written in a medium that can only add. It was a no-op that read as a wash.
                //
                // The falling-away is expressed where it CAN be — the sky's own stars fade with
                // `p` in the `.particleAndSpace` material — and what is left here is the only
                // half additive blending can carry: the point, gathering as everything else
                // goes. Tightening as it brightens, so the light concentrates rather than
                // spreads.
                rect([.init(color: col([229, 83, 60], A * (0.16 + 0.34 * p)), location: 0),
                      .init(color: col([229, 83, 60], 0), location: 1)],
                     CGPoint(x: W * 0.5, y: H * 0.5), W * (0.30 - p * 0.17))
            case .stillness, .nave:                               // morning: the dawn thins toward him
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
            // Three materials, three skies. The nave's eight are a seam glimpsed through
            // stone; the dawn's twenty-six sit in the upper 0.7 because the lower third is
            // ground. **The particle and space has no ground, so its stars fill the frame** —
            // `span = 1.0`, the same as the nave, but many more of them and dimmer, because
            // the point is what he is looking at.
            let hex: String
            let base: Double
            let count: Int
            let span: Double
            switch material {
            case .dawn:             hex = "#EDE3CE"; base = 0.55; count = 26; span = 0.7
            case .nave:             hex = "#FBF9F4"; base = 0.35; count = 8;  span = 1.0
            case .particleAndSpace: hex = "#DCE3F0"; base = 0.42; count = 40; span = 1.0
            }
            for i in 0..<count {
                let r = rnd(Double(i) * 1.7)
                let x = rnd(Double(i) * 3.1) * size.width
                let y = rnd(Double(i) * 5.3) * size.height * span
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

// E1.17 · SwiftUI will not interpolate a `.font`, so a size that is meant to TRAVEL needs its
// own animatable channel — otherwise `21 → 15` snaps and the 2.6s settle is not on screen.
private struct LoraSize: ViewModifier, Animatable {
    var size: CGFloat
    var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }
    func body(content: Content) -> some View { content.font(.lora(size)) }
}

extension View {
    /// The Lora face at a size that can be animated between two values.
    func loraSize(_ size: CGFloat) -> some View { modifier(LoraSize(size: size)) }
}
