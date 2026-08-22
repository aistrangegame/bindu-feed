import SwiftUI

/// One particle. One being, at every scale, created once and never replaced —
/// which is why the centre can truthfully say *"Every dot you touched was me."*
/// It is never named or explained anywhere in the UI; it simply is.
///
/// This is the skeleton: the state model plus the resting render, driven by
/// `Breath`. `wandering`, `gate`, `split`, `draw`, and `ember` are declared so
/// call sites can already refer to them, but only `resting` is realised here —
/// each remaining state arrives with the wave that needs it.
enum BinduState: Equatable {
    case resting     // crown, breathing on the 10s clock
    case wandering   // untethered drift (9–14s relocations), untappable
    case gate        // ~1.1s hold at a membrane
    case split       // three: Knowledge · Will · Action, then merge
    case draw        // the Mirror
    case ember       // comment-scale
}

/// The particle's data. One colour family only — never a second hue.
struct BinduParticle {
    /// The one colour family. Warm ember red, `#E5533C` ↔ `#C0392B`.
    static let core = Color(hex: "#E5533C")
    static let deep = Color(hex: "#C0392B")

    var state: BinduState = .resting
}

/// The resting render: a single soft dot that swells and settles on the breath.
/// It reads `Breath` from the environment — it never runs its own clock. Other
/// states will branch inside `body` as their waves land.
struct BinduParticleView: View {
    @EnvironmentObject private var breath: Breath
    var particle: BinduParticle = .init()
    var baseSize: CGFloat = 14

    var body: some View {
        switch particle.state {
        case .resting:
            resting
        default:
            // Not yet realised — render at rest so the particle is never absent.
            resting
        }
    }

    private var resting: some View {
        let swell = 0.85 + 0.30 * breath.value        // gentle 0.85 → 1.15 breathing
        let d = baseSize * swell
        return Circle()
            .fill(
                RadialGradient(
                    colors: [BinduParticle.core, BinduParticle.deep],
                    center: .center, startRadius: 0, endRadius: d
                )
            )
            .frame(width: d, height: d)
            .shadow(color: BinduParticle.core.opacity(0.5 * breath.value),
                    radius: baseSize * 0.9 * swell)
            .opacity(0.9)
    }
}

#Preview {
    ZStack {
        BinduTheme.bgDeep.ignoresSafeArea()
        BinduParticleView(baseSize: 40)
    }
    .environmentObject(Breath())
}
