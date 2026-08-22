import SwiftUI

// THE INSTRUMENT — the continuous axis, one space, not screens. Vertical travel
// moves Z; the fifteen registers' shells breathe as atmosphere (nothing created or
// destroyed); the one particle rides the whole axis. Each register renders its own
// content when he settles into it: the Universe outward (−4…−1), the Point inward
// (+2…+8), the gate (+1), the centre's reveal (+9). Reached from the turn's axis
// rows at a target Z; a firm pull travels, a settle lands.
//
// Wave-6 scope, stated for the completeness pass: this is a SwiftUI-Canvas port of
// the axis — travel + shells + particle + per-register content are here and
// walkable end to end. The full passage DSP (wormhole/whitehole with two gates)
// and the membrane meniscus are rendered as a zoom-cross flash (≈); the physics is
// a settle-to-register spring rather than the prototype's force/brake model (≈).

struct InstrumentView: View {
    @Binding var path: NavigationPath
    let startZ: Int

    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine

    @State private var z: Double = 0
    @State private var dragZ: Double = 0          // z at drag start
    @State private var crossFlash: Double = 0     // the passage flash 0…1
    @State private var lastRegister = 5

    private var here: AxisRegister { Axis.nearest(z) }

    var body: some View {
        ZStack {
            Color(hex: "#050408").ignoresSafeArea()

            TimelineView(.animation) { _ in
                shells
            }

            // The register content, brightening as he settles into it.
            content
                .opacity(Axis.presence(here.i, z))
                .allowsHitTesting(Axis.presence(here.i, z) > 0.6)

            // The one particle — rides centre → crown as he goes inward.
            particle

            // The passage flash on crossing.
            if crossFlash > 0.01 {
                Circle().fill(RadialGradient(
                    colors: [here.color.opacity(0.5 * crossFlash), .clear],
                    center: .center, startRadius: 0, endRadius: 400 * (1 + crossFlash)))
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
                Text("pull to travel")
                    .font(.spaceMono(8)).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.3 + 0.3 * breath.value))
                    .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .contentShape(Rectangle())
        .gesture(travel)
        .onAppear {
            z = Double(startZ)
            lastRegister = here.i
            soundEngine.setContext(.base)
        }
    }

    // MARK: - Travel

    private var travel: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { v in
                // Up = inward (+Z), down = outward (−Z). Scaled to design points.
                let delta = -v.translation.height / 150
                z = Axis.clampZ(dragZ + delta)
                checkCrossing()
            }
            .onEnded { _ in
                // Settle into the nearest register.
                let target = Double(Axis.nearest(z).z + 5 - 5)
                withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) { z = target }
                dragZ = z
            }
    }

    private func checkCrossing() {
        let r = Axis.nearest(z)
        if r.i != lastRegister {
            lastRegister = r.i
            dragZ = z   // keep the drag anchored so it doesn't fight the new register
            soundEngine.riteThreshold(hz: r.hz, dur: 4)   // a gate passing (≈ the travel calls)
            crossFlash = 1
            withAnimation(.easeOut(duration: 0.9)) { crossFlash = 0 }
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
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - The one particle (rides centre → crown inward)

    private var particle: some View {
        let inward = max(0, min(1, z / 9))          // 0 at feed, 1 at centre
        let cy = 0.5 - 0.368 * inward                // H/2 → H*0.132
        let r = 12 * (1 - inward * 0.30) + 6 * breath.value
        return GeometryReader { geo in
            Circle()
                .fill(RadialGradient(colors: [BinduParticle.core, BinduParticle.deep.opacity(0)],
                                     center: .center, startRadius: 0, endRadius: r))
                .frame(width: r * 2, height: r * 2)
                .position(x: geo.size.width / 2, y: geo.size.height * cy)
                .shadow(color: BinduParticle.core.opacity(0.5 * breath.value), radius: r)
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

private struct AxisLightSeam: View {
    let onEnter: () -> Void
    var body: some View {
        VStack(spacing: 14) {
            Text("the Light").font(.lora(20)).foregroundStyle(Color(hex: "#EDE3CE"))
            Text("what has not yet been").font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
            Button(action: onEnter) {
                Text("stand inside ›").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#EDE3CE"))
            }
        }
    }
}
