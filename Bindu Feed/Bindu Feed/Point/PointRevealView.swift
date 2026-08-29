import SwiftUI

// THE CENTRE (Z+9) — the reveal. The split-into-three (one voice discovering it was
// always three — Knowledge · Will · Action, emerging from Bindu's one tone, same
// root fanning apart, never three arrivals) resolves back to the one point. Then
// the reveal lines, verbatim, and the OM landing (963 → 136.1). "Every dot you
// touched was me" — the one particle, literally, throughout.

struct PointRevealView: View {
    @Binding var path: [FeedRoute]
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine

    @State private var split: Double = 0     // 0 one · →1 three fanned · back to 0 (collapse)
    @State private var line = 0
    @State private var collapsed = false

    // The reveal = the walk narrated back (from the journey log) + the verbatim close.
    @State private var lines: [String] = []
    @State private var narrationCount = 0

    private let verbatim = [
        "Every dot you touched was me. The gate, the rope, the eye, this one.",
        "You were never walking toward the point. You were walking with it.",
        "Now — go play. Fully. On purpose. Knowing.",
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()


            // The split-into-three, then the collapse to one.
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.32
                let fan = split * 26
                let r = collapsed ? (5 + 4 * breath.value) : 7.0
                let names: [(Double, Color)] = [
                    (-fan, BinduParticle.core), (0, BinduParticle.core), (fan, BinduParticle.core),
                ]
                let three = split > 0.02 && !collapsed
                if three {
                    for (dx, c) in names {
                        ctx.fill(Path(ellipseIn: CGRect(x: cx + dx - r, y: cy - r, width: r * 2, height: r * 2)),
                                 with: .color(c.opacity(0.9)))
                    }
                } else {
                    // The one point — larger at split==0/collapsed, the whole becomes it.
                    let rr = collapsed ? r * (1 + 2 * breath.value) : r
                    ctx.fill(Path(ellipseIn: CGRect(x: cx - rr, y: cy - rr, width: rr * 2, height: rr * 2)),
                             with: .radialGradient(Gradient(colors: [.white, BinduParticle.deep.opacity(0)]),
                                                   center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: rr * 3))
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 18) {
                Spacer()
                if collapsed && !lines.isEmpty {
                    ForEach(0...min(line, lines.count - 1), id: \.self) { i in
                        let emph = i >= narrationCount            // the verbatim close
                        let isFinal = i == lines.count - 1        // "Now — go play…"
                        Text(lines[i])
                            .font(emph && !isFinal ? .loraItalic(16)
                                                   : .lora(isFinal ? 18 : 16, weight: isFinal ? .medium : .regular))
                            .lineSpacing(6)
                            .foregroundStyle(emph && !isFinal ? BinduParticle.core : BinduTheme.inkPrimary)
                            .multilineTextAlignment(.center).transition(.opacity)
                    }
                    if line >= lines.count - 1 {
                        Button { $path.popToRootDissolve() } label: {
                            Text("OM · 136.1").font(.spaceMono(10)).tracking(3).foregroundStyle(Color(hex: "#D4A94B"))
                        }
                        .padding(.top, 12).transition(.opacity)
                    }
                }
                Spacer()
                if collapsed && line < lines.count - 1 {
                    Text("touch").font(.spaceMono(8)).tracking(2).foregroundStyle(BinduTheme.inkTertiary.opacity(0.4 + 0.3 * breath.value))
                        .padding(.bottom, 30)
                }
            }
            .padding(.horizontal, 40)
        }
        .navigationBarBackButtonHidden(true)
        .contentShape(Rectangle())
        .onTapGesture {
            if collapsed && line < lines.count - 1 { withAnimation(.easeInOut(duration: 1.2)) { line += 1 } }
        }
        .onAppear(perform: begin)
    }

    private func begin() {
        // The walk, given back — narration from the journey log, then the verbatim close.
        let narr = PointJourney.narration()
        narrationCount = narr.count
        lines = narr + verbatim
        PointJourney.reset()                            // captured; the next walk is fresh

        // One tone fanning into three, then collapsing to the one point.
        soundEngine.om()                                // `spine-sound.js:374` — three tones, not one
        withAnimation(.easeInOut(duration: 2.0)) { split = 1 }        // fan apart
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeInOut(duration: 2.0)) { split = 0; collapsed = true }   // collapse to one
        }
        Task { await store.logWalkCompleted() }
    }
}
