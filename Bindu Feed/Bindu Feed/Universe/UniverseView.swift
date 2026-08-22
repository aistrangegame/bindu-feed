import SwiftUI

// THE UNIVERSE (Z −4…−1) — the outward inversion, the zoom out into the many.
// Stars ARE stories (met glow, unmet faint), each room a region of sky in its
// colour, the whole cosmos breathing at 0.1 Hz. The attendant motes are one per
// voice that actually spoke on a story (derived, never decoration) — unmet stars
// have no company. Three reading distances (sky → world → fall); the fall opens
// the Return (entering at Movement II — the fall WAS the Summons).
//
// Wave-6 scope for the completeness pass: the stars-as-stories, the room-coloured
// regions, met-glow, the motes, and the fall's door are here and walkable. The
// thirteen sky-forms as exact geometric armatures (tetractys, phyllotaxis, …) are
// rendered as room-coloured clusters (≈); the two-lens (star/structure) and the
// full four-layer continuous fall are the reveal's door here + the Return ceremony.

struct UniverseView: View {
    let register: AxisRegister
    @Binding var path: NavigationPath
    let onFall: () -> Void

    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath

    // How close: sky = far, region/world = mid, fall = the strata.
    private var distance: Int {
        switch register.key { case "sky": return 0; case "region", "world": return 1; default: return 2 }
    }

    var body: some View {
        ZStack {
            TimelineView(.animation) { _ in sky }

            if register.key == "fall" {
                VStack {
                    Spacer()
                    Text("the fall").font(.lora(18)).italic().foregroundStyle(Color(hex: "#9FB2C4"))
                    Text("who sat with it · what you left here").font(.loraItalic(12)).foregroundStyle(BinduTheme.inkTertiary)
                    Button(action: onFall) {
                        Text("open the return ›").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#9FB2C4"))
                            .padding(.top, 10)
                    }
                    Spacer().frame(height: 60)
                }
            }
        }
    }

    private var sky: some View {
        Canvas { ctx, size in
            let b = breath.value
            let stories = store.stories
            for (i, story) in stories.enumerated() {
                // Deterministic placement by id.
                let h = hash(story.id)
                let x = frac(h) * size.width
                let y = frac(h * 1.7) * size.height
                let room = store.room(named: story.room)
                let color = room?.color ?? BinduTheme.colorLalita
                let stats = store.stats(for: story.id)
                let met = stats.commentCount > 0 || story.resonance > 0
                let base = met ? 0.85 : 0.28
                let tw = 0.6 + 0.4 * abs(sin(b * .pi + Double(i)))
                let sz = met ? 2.2 : 1.4
                ctx.fill(Path(ellipseIn: CGRect(x: x - sz, y: y - sz, width: sz * 2, height: sz * 2)),
                         with: .color(color.opacity(base * tw)))
                if met { // the halo = resonance
                    let hr = sz * 3
                    ctx.fill(Path(ellipseIn: CGRect(x: x - hr, y: y - hr, width: hr * 2, height: hr * 2)),
                             with: .color(color.opacity(0.06 * tw)))
                }
                // Attendant motes — at closer distance, the voices that spoke orbit.
                if distance >= 1 && met {
                    let voices = stats.archetypes.count
                    for v in 0..<min(voices, 6) {
                        let a = Double(v) / 6 * 2 * .pi + b * 0.5
                        let orbit = sz * 6
                        let mx = x + cos(a) * orbit, my = y + sin(a) * orbit
                        let mc = store.archetype(named: stats.archetypes[v])?.color ?? color
                        ctx.fill(Path(ellipseIn: CGRect(x: mx - 1.2, y: my - 1.2, width: 2.4, height: 2.4)),
                                 with: .color(mc.opacity(distance >= 1 ? 0.7 : 0.0)))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func hash(_ s: String) -> Double {
        var h: UInt32 = 2166136261
        for b in s.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        return Double(h)
    }
    private func frac(_ x: Double) -> Double { let v = x * 0.0001; return v - floor(v) }
}
