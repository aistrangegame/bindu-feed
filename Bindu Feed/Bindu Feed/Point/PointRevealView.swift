import SwiftUI

// THE CENTRE (Z+9) — the reveal. The split-into-three (one voice discovering it was
// always three — Knowledge · Will · Action, emerging from Bindu's one tone, same
// root fanning apart, never three arrivals) resolves back to the one point. Then
// the reveal lines, verbatim, and the OM landing (963 → 136.1). "Every dot you
// touched was me" — the one particle, literally, throughout.

struct PointRevealView: View {
    @Binding var path: [FeedRoute]
    /// SLICE 4 · the Lalita Pass — `again?` carries him back to the gate, the walk fresh.
    var onAgain: () -> Void = {}
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

            // SLICE 4 · the lines accumulate, and the walk's narration can run long — the
            // design's `#reveal` scrolls (`revealEl.scrollTop = revealEl.scrollHeight`), so
            // this does too: the newest line is always in view, and what rises fades before
            // it reaches the point.
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 18) {
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
                                    // SLICE 4 · THE LALITA PASS — *"Now — go play"* is answered by the
                                    // design's one door, `again?` (`Claude Design Round 1/comps/The Point v9.html:912`,
                                    // `.lnk` in `--red`), whose click scrolls the walk back to the gate
                                    // (`again2.onclick` → `window.PT.scrollTo(0)`). The app had put its own
                                    // label here and sent him to the app's root: the game finished and did
                                    // not offer itself again. The door now carries him back up the axis to
                                    // the gate, the walk fresh; staying, or putting the phone down, are
                                    // still his.
                                    Button(action: onAgain) {
                                        Text("again?").spaceMonoTracked(9.5, em: 0.2)
                                            .foregroundStyle(Color(hex: "#C0392B"))
                                            .padding(.vertical, 12).padding(.horizontal, 20)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 4).transition(.opacity)
                                }
                            }
                            Color.clear.frame(height: 1).id("end")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, geo.size.height * 0.44)
                        .padding(.bottom, 90)
                    }
                    .scrollIndicators(.hidden)
                    .mask(LinearGradient(stops: [.init(color: .clear, location: 0.30),
                                                 .init(color: .black, location: 0.42)],
                                         startPoint: .top, endPoint: .bottom))
                    .onChange(of: line) { _, _ in
                        withAnimation(.easeInOut(duration: 1.2)) { proxy.scrollTo("end", anchor: .bottom) }
                    }
                }
            }
            .padding(.horizontal, 40)

            VStack {
                Spacer()
                if collapsed && line < lines.count - 1 {
                    Text("touch").spaceMonoTracked(8, em: 0.25).foregroundStyle(BinduTheme.inkMuted.opacity(0.85 + 0.15 * breath.value))
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
        // `The Point v9.html:1341` — `Snd.shimmer(); Snd.om(); YANTRA.flare();`, fired as
        // `.encl[9]` goes bare: enclosure 9 is 136.1, the landing home an octave down. The
        // app played the OM and not the shimmer beside it. Found while reading the corpus to
        // settle where `resolve` belongs; the reveal is one of the two moments that ARE
        // marked, and it was marked incompletely.
        soundEngine.shimmer()                           // five solfeggio tones, an octave up
        soundEngine.om()                                // `Claude Design Round 2/design-source/spine-sound.js:374` — three tones, not one
        withAnimation(.easeInOut(duration: 2.0)) { split = 1 }        // fan apart
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeInOut(duration: 2.0)) { split = 0; collapsed = true }   // collapse to one
        }
        Task { await store.logWalkCompleted() }
    }
}
