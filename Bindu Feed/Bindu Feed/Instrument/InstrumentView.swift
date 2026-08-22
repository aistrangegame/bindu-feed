import SwiftUI

// THE INSTRUMENT — the continuous axis, one space, not screens. Vertical travel moves
// Z through fourteen membranes (AxisTravel): a register is separated from its neighbour
// by a surface that must be MEANT — push through it and it gives, once, and stands open;
// the sky's edge opens instead to STILLNESS, delivering you to the Light. Crossing is a
// passage, not a snap: the camera leaves the hand and glides across. The one particle
// rides the whole axis and, at the centre, BLOOMS to fill the frame — it stops being a
// dot in a world and becomes the world ("every dot you touched was me"). Each register
// renders its own content when he settles into it.
//
// Wave-6 rebuild (built to spine-travel.js / spine-passage.js verbatim): the membrane
// physics, the stillness gate, the passage, the opened-surface memory, and the centre
// bloom are here. Still ahead in this surface's own passes: the wormhole/whitehole throat
// visuals, the seven distinct Point worlds, the four-scale Universe, the Light rendered
// in-axis. The hand-feel constants are the design's own; the felt tuning is the Neev walk.

struct InstrumentView: View {
    @Binding var path: NavigationPath
    let startZ: Int

    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine

    @StateObject private var travel: AxisTravel
    @State private var lastDragY: CGFloat = 0
    @State private var showRope = false

    init(path: Binding<NavigationPath>, startZ: Int) {
        self._path = path
        self.startZ = startZ
        self._travel = StateObject(wrappedValue: AxisTravel(startZ: Double(startZ)))
    }

    private var z: Double { travel.z }
    private var here: AxisRegister { Axis.nearest(z) }
    private var atSky: Bool { abs(z + 4) < 0.45 }

    var body: some View {
        ZStack {
            Color(hex: "#050408").ignoresSafeArea()

            TimelineView(.animation) { _ in
                shells
            }

            // The register content, brightening as he settles into it.
            content
                .opacity(Axis.presence(here.i, z))
                .allowsHitTesting(Axis.presence(here.i, z) > 0.6 && !travel.crossing)

            // The stillness gate — at the sky, the way on thins with stillness, not force.
            if travel.thin > 0.01 {
                stillnessGate
            }

            // The one particle — rides centre → crown, and blooms into the world at +9.
            particle

            // The passage flash on crossing.
            if travel.flash > 0.01 {
                Circle().fill(RadialGradient(
                    colors: [here.color.opacity(0.5 * travel.flash), .clear],
                    center: .center, startRadius: 0, endRadius: 400 * (1 + travel.flash)))
                    .ignoresSafeArea().allowsHitTesting(false)
            }

            // Where he is + the exit.
            VStack {
                HStack {
                    Button { if !path.isEmpty { path.removeLast(path.count) } } label: {
                        Text("‹").font(.system(size: 22)).foregroundStyle(BinduTheme.inkTertiary)
                    }
                    Spacer()
                    Text(here.name.uppercased())
                        .font(.spaceMono(9)).tracking(2)
                        .foregroundStyle(here.color.opacity(0.7))
                    Spacer()
                    Color.clear.frame(width: 22)
                }
                .padding(.horizontal, 20).padding(.top, 8)
                Spacer()
                Text(atSky && !travel.crossing ? "be still — the way opens" : "pull to travel")
                    .font(.spaceMono(8)).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.3 + 0.3 * breath.value))
                    .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .contentShape(Rectangle())
        .gesture(travelGesture)
        // The rope from anywhere (§7.5) — a ~1.1s long-press; the particle is always here.
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 1.1).onEnded { _ in
                withAnimation(.easeInOut(duration: 0.8)) { showRope = true }
            }
        )
        .overlay {
            if showRope {
                DoorRopeOverlay(onExit: { _ in
                    withAnimation(.easeInOut(duration: 0.8)) { showRope = false }
                })
                .transition(.opacity)
            }
        }
        .onAppear {
            travel.onCross = { reg in
                soundEngine.riteThreshold(hz: reg.hz, dur: 4)   // the crossing, struck
                if reg.key == "gate" { PointJourney.reachedGate = true }
            }
            soundEngine.setContext(.base)
            travel.start()
        }
        .onDisappear { travel.stop() }
    }

    // MARK: - Travel (the hand feeds AxisTravel; the engine owns the physics)

    private var travelGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { v in
                let delta = v.translation.height - lastDragY
                lastDragY = v.translation.height
                travel.setDown(true)
                travel.applyDrag(Double(delta))
            }
            .onEnded { _ in
                lastDragY = 0
                travel.setDown(false)
            }
    }

    // MARK: - Shells (the atmosphere)

    private var shells: some View {
        Canvas { ctx, size in
            let R0 = min(size.width, size.height) * 0.5
            let cx = size.width / 2, cy = size.height / 2
            let b = breath.value
            // Draw far → near so nearer registers sit on top.
            for reg in Axis.registers {
                let p = Axis.presence(reg.i, z)
                guard p > 0.01 else { continue }
                let rim = R0 * pow(2, (z + 5) - Double(reg.i)) * (0.98 + 0.04 * b)
                guard rim > 6, rim < R0 * 6 else { continue }
                let op = p * 0.5
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - rim, y: cy - rim, width: rim * 2, height: rim * 2)),
                           with: .color(reg.color.opacity(op)), lineWidth: 0.8)
            }
            // The near membrane, felt as a meniscus that tightens as he leans into it.
            let ten = travel.tension
            if ten > 0.02 {
                let rim = R0 * (1.62 - 0.92 * ten)
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - rim, y: cy - rim, width: rim * 2, height: rim * 2)),
                           with: .color(here.color.opacity(0.10 + 0.34 * ten)), lineWidth: 0.7 + 1.5 * ten)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - The stillness gate (the sky thins with stillness)

    private var stillnessGate: some View {
        GeometryReader { geo in
            let R0 = min(geo.size.width, geo.size.height) * 0.5
            let still = travel.thin
            let rim = R0 * (1.10 + still * 1.30)
            ZStack {
                Circle()
                    .stroke(Color(hex: "#EDE3CE").opacity(0.12 + 0.55 * still), lineWidth: 0.8 + still)
                    .frame(width: rim * 2, height: rim * 2)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                Text("it holds until you stop meaning it")
                    .font(.loraItalic(12)).foregroundStyle(Color(hex: "#EDE3CE").opacity(0.25 + 0.5 * still))
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.30)
                    .opacity(still > 0.12 ? 1 : 0)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - The one particle (rides centre → crown, blooms into the world at the centre)

    private var particle: some View {
        let inward = max(0, min(1, z / 9))                    // 0 at feed, 1 at centre
        let grow = max(0, min(1, (z - 8.4) / 1.1))            // begins to swell near the centre
        let fill = max(0, min(1, (z - 8.6) / 0.95))           // paints the whole frame red at the centre
        let cy = 0.5 - 0.368 * inward                         // H/2 → H*0.132
        let base = 5.0 + 4.0 * breath.value                   // the only fixed thing — small, constant
        let r = base * (1 + grow * grow * 9)                  // then it balloons
        return GeometryReader { geo in
            ZStack {
                if fill > 0.001 {                             // it becomes the world
                    Rectangle().fill(BinduParticle.core.opacity(fill)).ignoresSafeArea()
                }
                Circle()
                    .fill(RadialGradient(colors: [BinduParticle.core, BinduParticle.deep.opacity(0)],
                                         center: .center, startRadius: 0, endRadius: r))
                    .frame(width: r * 2, height: r * 2)
                    .position(x: geo.size.width / 2, y: geo.size.height * cy)
                    .shadow(color: BinduParticle.core.opacity(0.5 * breath.value), radius: min(r, 40))
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Per-register content

    @ViewBuilder private var content: some View {
        switch here.key {
        case "d1", "d2", "d3", "d4", "d5", "d6", "d7":
            PointWorldView(dimensionN: here.z - 1, path: $path,
                           onReturn: { path.append(FeedRoute.returnCeremony) })
        case "centre":
            PointRevealView(path: $path)
        case "gate":
            AxisGateView()
        case "sky", "region", "world", "fall":
            UniverseView(register: here, path: $path,
                         onFall: { path.append(FeedRoute.returnCeremony) })
        case "feed":
            AxisFeedSeam { if !path.isEmpty { path.removeLast(path.count) } }
        case "light":
            AxisLightSeam { path.append(FeedRoute.light) }
        default:
            EmptyView()
        }
    }
}

// The gate (Z+1) — the deal, the threshold inward.
private struct AxisGateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("the gate").font(.lora(20)).italic().foregroundStyle(Color(hex: "#C9A07A"))
            Text("everything you know, arranged").font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
            Text("pull inward to enter the Point").font(.spaceMono(9)).tracking(2).foregroundStyle(BinduTheme.inkTertiary)
        }
    }
}

private struct AxisFeedSeam: View {
    let onEnter: () -> Void
    var body: some View {
        VStack(spacing: 14) {
            Text("the Feed").font(.lora(20, weight: .medium)).foregroundStyle(BinduTheme.colorBindu)
            Text("life size — the turn").font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
            Button(action: onEnter) {
                Text("enter the feed ›").font(.spaceMono(10)).tracking(2).foregroundStyle(BinduTheme.colorBindu)
            }
        }
    }
}

// The Light register (Z−5) — the dawn material itself (S-L01): an ember low in the sky,
// a horizon band, steam rising before he arrived. Hour-aware — the future looks different
// at six and at noon because he does. Reached by the stillness gate; "stand inside" opens
// the full ceremony (the scenes, the carve).
private struct AxisLightSeam: View {
    let onEnter: () -> Void
    @EnvironmentObject private var breath: Breath

    private var hourWarm: Double {                        // <4 night · <7 dawn · <11 morning · <15 high · <20 evening
        let h = Calendar.current.component(.hour, from: Date())
        switch h { case ..<4: return 0.2; case ..<7: return 0.55; case ..<11: return 0.8; case ..<15: return 1.0; case ..<20: return 0.7; default: return 0.25 }
    }

    var body: some View {
        ZStack {
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    let hy = size.height * 0.60
                    let warm = hourWarm
                    // the horizon — dawn ground
                    ctx.fill(Path(CGRect(x: 0, y: hy, width: size.width, height: size.height - hy)),
                             with: .linearGradient(.init(colors: [Color(hex: "#C9A07A").opacity(0.10 + 0.10 * warm), .clear]),
                                                   startPoint: CGPoint(x: 0, y: size.height), endPoint: CGPoint(x: 0, y: hy)))
                    // the ember, low, breathing
                    let ex = size.width / 2, ey = hy - 8
                    let er = 26.0 + 10 * breath.value
                    ctx.fill(Path(ellipseIn: CGRect(x: ex - er, y: ey - er, width: er * 2, height: er * 2)),
                             with: .radialGradient(.init(colors: [BinduParticle.core.opacity(0.5 + 0.3 * warm), .clear]),
                                                   center: CGPoint(x: ex, y: ey), startRadius: 0, endRadius: er))
                    // steam, rising before he arrived
                    for i in 0..<16 {
                        let seed = Double(i)
                        let phase = (t * 0.06 + seed * 0.13).truncatingRemainder(dividingBy: 1)
                        let sx = ex + sin(seed * 2.3 + t * 0.2) * (30 + seed * 4)
                        let sy = ey - phase * size.height * 0.5
                        let a = (1 - phase) * 0.10 * warm
                        ctx.fill(Path(ellipseIn: CGRect(x: sx - 1.5, y: sy - 1.5, width: 3, height: 3)),
                                 with: .color(Color(hex: "#EDE3CE").opacity(a)))
                    }
                }
            }
            .ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 12) {
                Spacer()
                Text("the Light").font(.lora(20)).foregroundStyle(Color(hex: "#EDE3CE"))
                Text("what has not yet been").font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
                Button(action: onEnter) {
                    Text("stand inside ›").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#EDE3CE"))
                }.padding(.top, 6)
                Spacer().frame(height: 150)
            }
        }
    }
}
