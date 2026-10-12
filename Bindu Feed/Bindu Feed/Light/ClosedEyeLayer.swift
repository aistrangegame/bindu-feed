import SwiftUI
import ARKit

// WAVE 4 · THE CLOSED EYE OPENS THE NAVE — Tree of Life's Axis Dark Field: "she is one closed
// eye away." Ashrey's ruling (11 Oct 2026): the camera, on the device only, nothing recorded,
// stillness always the equal path.
//
// He asks for it once — the small open-eye mark in the corner. After that the front camera does
// one thing: it notices whether both eyes are closed (ARKit's blink coefficients, never an
// image). Three seconds with the eyes closed and the dawn dims into the dark field, phosphenes
// drifting behind the particle, the bed sinking an octave. When the eyes open, one blink's worth
// of time shows the whole Universe as ONE TREE — every room a branch, every story a leaf — and
// then the Light again. Nothing leaves the phone. Where the phone has no face camera, the mark is
// never drawn and the Light's own stillness is the path, as it always was.
struct ClosedEyeLayer: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @StateObject private var eyes = EyeWatcher()
    @State private var dark: Double = 0
    @State private var tree: Double = 0
    @State private var wasDark = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if dark > 0 || tree > 0 {
                darkField
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            if EyeWatcher.supported {
                Button {
                    eyes.active ? eyes.stop() : eyes.start()
                } label: {
                    EyeMark(open: !eyes.active)
                        .frame(width: 22, height: 14)
                        .padding(18)
                        .opacity(eyes.active ? 0.75 : 0.35)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .onChange(of: eyes.closedFor) { _, t in
            if t >= 3, dark == 0 {
                wasDark = true
                soundEngine.fieldThreshold(hz: 68.05, dur: 10)
                withAnimation(.easeInOut(duration: 2.4)) { dark = 1 }
            }
            if t == 0, wasDark {
                wasDark = false
                withAnimation(.easeOut(duration: 0.4)) { dark = 0; tree = 1 }
                soundEngine.fieldThreshold(hz: 136.1, dur: 6)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
                    withAnimation(.easeInOut(duration: 2.0)) { tree = 0 }
                }
            }
        }
        .onDisappear { eyes.stop() }
    }

    private var darkField: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.94 * dark)))
                let c = CGPoint(x: size.width / 2, y: size.height * 0.46)
                // phosphenes — slow, coloured, behind the particle
                if dark > 0 {
                    for i in 0..<26 {
                        let a = Double(i) * 2.39996 + t * 0.05
                        let r = 40 + Double((i * 37) % 160) + 18 * sin(t * 0.3 + Double(i))
                        let p = CGPoint(x: c.x + CGFloat(cos(a) * r), y: c.y + CGFloat(sin(a) * r * 1.3))
                        let hue = [Color(hex: "#9B6BD6"), Color(hex: "#3AADA8"), Color(hex: "#C9A07A"), Color(hex: "#E5533C")][i % 4]
                        let s = 6 + 10 * (0.5 + 0.5 * sin(t * 0.7 + Double(i)))
                        ctx.fill(Path(ellipseIn: CGRect(x: p.x - s, y: p.y - s, width: s * 2, height: s * 2)),
                                 with: .radialGradient(Gradient(colors: [hue.opacity(0.22 * dark), .clear]), center: p, startRadius: 0, endRadius: s))
                    }
                    ctx.fill(Path(ellipseIn: CGRect(x: c.x - 3, y: c.y - 3, width: 6, height: 6)),
                             with: .color(BinduTheme.colorBindu.opacity(dark)))
                }
                // the Universe as one tree — rooms as branches, stories as leaves
                if tree > 0 {
                    ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.9 * tree)))
                    let root = CGPoint(x: size.width / 2, y: size.height * 0.86)
                    let rooms = store.rooms.sorted { $0.sortOrder < $1.sortOrder }
                    var trunk = Path(); trunk.move(to: root); trunk.addLine(to: CGPoint(x: root.x, y: size.height * 0.52))
                    ctx.stroke(trunk, with: .color(Color(hex: "#C9A07A").opacity(0.7 * tree)), lineWidth: 1.4)
                    for (i, room) in rooms.enumerated() {
                        let n = Double(max(1, rooms.count - 1))
                        let ang = -.pi * (0.12 + 0.76 * Double(i) / n)
                        let fork = CGPoint(x: root.x, y: size.height * (0.66 - 0.12 * Double(i % 3) / 2))
                        let tip = CGPoint(x: fork.x + CGFloat(cos(ang) * Double(size.width) * 0.42),
                                          y: fork.y + CGFloat(sin(ang) * Double(size.height) * 0.42))
                        var b = Path(); b.move(to: fork)
                        b.addQuadCurve(to: tip, control: CGPoint(x: (fork.x + tip.x) / 2, y: fork.y - 30))
                        ctx.stroke(b, with: .color(room.color.opacity(0.55 * tree)), lineWidth: 0.9)
                        let leaves = store.stories.filter { $0.room == room.name }.count
                        for k in 0..<min(leaves, 14) {
                            let f = 0.35 + 0.65 * Double(k) / 14
                            let lp = CGPoint(x: fork.x + (tip.x - fork.x) * CGFloat(f) + CGFloat(sin(Double(k) * 2.1) * 6),
                                             y: fork.y + (tip.y - fork.y) * CGFloat(f) - CGFloat(sin(f * .pi) * 30) + CGFloat(cos(Double(k) * 1.7) * 6))
                            let lit = store.metStoryIDs.isEmpty ? 0.5 : 0.85
                            ctx.fill(Path(ellipseIn: CGRect(x: lp.x - 1.8, y: lp.y - 1.8, width: 3.6, height: 3.6)),
                                     with: .color(room.color.opacity(lit * tree)))
                        }
                    }
                }
            }
        }
    }
}

private struct EyeMark: View {
    let open: Bool
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            var lid = Path()
            lid.move(to: CGPoint(x: 0, y: h / 2))
            lid.addQuadCurve(to: CGPoint(x: w, y: h / 2), control: CGPoint(x: w / 2, y: open ? -h * 0.3 : h * 0.9))
            ctx.stroke(lid, with: .color(Color(hex: "#EDE3CE")), lineWidth: 1)
            if open {
                var low = Path()
                low.move(to: CGPoint(x: 0, y: h / 2))
                low.addQuadCurve(to: CGPoint(x: w, y: h / 2), control: CGPoint(x: w / 2, y: h * 1.3))
                ctx.stroke(low, with: .color(Color(hex: "#EDE3CE")), lineWidth: 1)
                ctx.fill(Path(ellipseIn: CGRect(x: w / 2 - 2.2, y: h / 2 - 2.2, width: 4.4, height: 4.4)), with: .color(Color(hex: "#EDE3CE")))
            }
        }
    }
}

/// Notices only whether both eyes are closed — ARKit blend-shape coefficients, never a frame.
final class EyeWatcher: NSObject, ObservableObject, ARSessionDelegate {
    static var supported: Bool { ARFaceTrackingConfiguration.isSupported }

    @Published private(set) var active = false
    /// Seconds both eyes have been closed (0 when open). Published in whole half-seconds.
    @Published private(set) var closedFor: Double = 0

    private let session = ARSession()
    private var closedSince: Date?

    func start() {
        guard Self.supported else { return }
        let c = ARFaceTrackingConfiguration()
        c.isLightEstimationEnabled = false
        session.delegate = self
        session.run(c, options: [.resetTracking, .removeExistingAnchors])
        active = true
    }

    func stop() {
        guard active else { return }
        session.pause()
        active = false
        closedSince = nil
        closedFor = 0
    }

    nonisolated func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let face = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        let l = face.blendShapes[.eyeBlinkLeft]?.doubleValue ?? 0
        let r = face.blendShapes[.eyeBlinkRight]?.doubleValue ?? 0
        let closed = l > 0.6 && r > 0.6
        Task { @MainActor in self.note(closed) }
    }

    private func note(_ closed: Bool) {
        if closed {
            if closedSince == nil { closedSince = Date() }
            let t = (Date().timeIntervalSince(closedSince!) * 2).rounded(.down) / 2
            if t != closedFor { closedFor = t }
        } else {
            closedSince = nil
            if closedFor != 0 { closedFor = 0 }
        }
    }
}
