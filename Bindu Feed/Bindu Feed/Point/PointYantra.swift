import SwiftUI
import Combine

// THE YANTRA — `point-yantra.js`, whole.
//
//   *"One figure, drawn once, walked through. The nine enclosures are not nine screens with
//    nine pictures: they are one architecture, and the walk inward is a camera. Scrolling
//    moves the camera; you always see where you are, what you came through, and what is
//    still ahead as a faint promise at the centre."*
//
// This is the item the Pass-5 checklist calls *"the thing that was lost last time."* The app
// has had nine registers drawing nine separate figures; the design has ONE figure and a
// camera. Everything breathes at 0.1 Hz in phase with the drone. The centre point is red.
// It always was.

@MainActor
final class PointYantra: ObservableObject {
    /// One per instrument. The Aperture flares the same figure the registers stand inside.
    static let shared = PointYantra()

    /// `focus` walks `BAND` — 0 outermost, 9 the centre. Fractional between enclosures.
    @Published var focus: Double = 0
    @Published var hue: [Double] = PointYantra.cream
    /// `'walk'` or `'descend'` — the descent dims everything to 0.22 and raises the shaft.
    @Published var descending = false
    @Published var shaft: Double = 0
    /// `The Point v9.html:929` — the camera drops to 0.40 for the last two enclosures, so the
    /// aperture and the bindu sit above centre with room beneath them. It EASES (`+=(target-camY)*0.05`
    /// per frame); it never snaps, because a jump here reads as the figure moving rather than him.
    var camY: Double = 0.5
    private var lastT: Double = 0
    /// Crossing waves, in screen space. Each is the time it was fired.
    @Published private(set) var flares: [Double] = []

    /// `YANTRA.flare()` — a crossing sends one wave out through the whole figure.
    func flare() {
        flares.append(Date().timeIntervalSinceReferenceDate)
        #if DEBUG
        flaresFired += 1     // sticky, so a 3.4s wave can be verified by a slower loop
        #endif
    }
    #if DEBUG
    @Published private(set) var flaresFired = 0
    #endif

    // MARK: - the constants

    /// `BAND` — the radius each enclosure lives at, in unit space, outward to inward.
    static let band: [Double] = [1.38, 0.93, 0.77, 0.62, 0.50, 0.39, 0.29, 0.20, 0.125, 0.06]
    static let cream: [Double] = [237, 230, 214]     // #EDE6D6
    static let red: [Double] = [192, 57, 43]         // #C0392B

    /// The nine primary triangles — five downward (Shakti), four upward (Shiva) — and the
    /// trikona at the centre. `[base, apex, halfWidth]`.
    static let down: [[Double]] = [[0.86, -0.94, 0.92], [0.70, -0.74, 0.80],
                                   [0.52, -0.58, 0.66], [0.34, -0.40, 0.50], [0.16, -0.24, 0.34]]
    static let up: [[Double]] = [[-0.86, 0.94, 0.90], [-0.66, 0.72, 0.74],
                                 [-0.46, 0.54, 0.58], [-0.26, 0.34, 0.42]]
    static let trikona: [Double] = [0.10, -0.17, 0.20]

    /// 150 stars, and they recede as he goes inward — the only cue that he is travelling.
    struct SkyMote { let a: Double, d: Double, r: Double, p: Double, s: Double }
    private static let sky: [SkyMote] = {
        var out: [SkyMote] = []
        out.reserveCapacity(150)
        for i in 0..<150 {
            let fi = Double(i)
            let a: Double = RoomGeo.rnd(fi) * RoomGeo.tau
            let d: Double = 0.06 + RoomGeo.rnd(fi + 50) * 1.5
            let r: Double = 0.3 + RoomGeo.rnd(fi + 90) * 1.0
            let p: Double = RoomGeo.rnd(fi + 7) * RoomGeo.tau
            let sp: Double = 0.4 + RoomGeo.rnd(fi + 3) * 0.6
            out.append(SkyMote(a: a, d: d, r: r, p: p, s: sp))
        }
        return out
    }()

    // MARK: - the camera

    /// *"band[focus] always fills the same share of the frame, so every enclosure is met at
    /// the same size — the walk is a change of place, not of scale."* Log-interpolated, which
    /// is the same guarantee the Universe's `zoom(forAxisZ:)` gives on the other side.
    func scale(_ size: CGSize) -> Double {
        let f = max(0, min(Double(Self.band.count - 1), focus))
        let i = Int(f), j = min(Self.band.count - 1, i + 1), t = f - Double(i)
        let R = min(Double(size.width), Double(size.height)) * 0.335
        let a = log(R / Self.band[i]), b = log(R / Self.band[j])
        return exp(a + (b - a) * t)
    }

    func bandRadius() -> Double {
        let f = max(0, min(Double(Self.band.count - 1), focus))
        let i = Int(f), j = min(Self.band.count - 1, i + 1)
        return Self.band[i] + (Self.band[j] - Self.band[i]) * (f - Double(i))
    }

    /// `toScreen(x, y)` — the projection every node is placed through. This is the whole of
    /// "on its real enclosure radius": a node's position is not a ring drawn near the figure,
    /// it is the figure's own coordinate run through the figure's own camera.
    func toScreen(_ x: Double, _ y: Double, in size: CGSize) -> CGPoint {
        let s = scale(size)
        return CGPoint(x: Double(size.width) / 2 + x * s, y: Double(size.height) * camY + y * s)
    }

    /// TEN enclosures against NINE axis registers. `The Point v9.html:876-909` builds the feed
    /// as gate · avarana I…VII · **avarana VIII, the aperture** · avarana IX, the bindu — and
    /// `camera()` sets `setFocus(f)` from the scroll position, so enclosure index IS register
    /// index. The app's axis carries only nine of them: the Aperture is its own route, off the
    /// axis, so no register stands on `BAND[8]`.
    ///
    /// That does not make `BAND[8]` skippable — it makes it a band he PASSES THROUGH. Walking
    /// d7 → the centre crosses the aperture's enclosure without stopping in it, which is the
    /// literal truth of the walk. So `z 8…9` spans `focus 7…9` at double rate, and the centre
    /// lands on `BAND[9] = 0.06` where the design puts it — not on 8, which would stand the
    /// bindu on the aperture's ring to avoid a visible change of scale.
    static func focus(forAxisZ z: Double) -> Double {
        z <= 8 ? max(0, z - 1) : min(9, 7 + (z - 8) * 2)
    }
    /// `DIMHUE` — `The Point v9.html:871`, all ten.
    static let dimHue = ["m1", "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m2", "m7"]
    static func hue(forEnclosure i: Int) -> [Double] {
        let k = dimHue[max(0, min(9, i))]
        return RoomGeo.hex(PointContent.hues[k] ?? "#EDE6D6")
    }

    /// `The Point v9.html:926-932` — one call: the camera takes its focus from where he is,
    /// and the air takes its colour by MIXING the two enclosures he is between. The hue is a
    /// continuous quantity along the walk, not a per-register constant that switches.
    func setEnclosure(_ f: Double) {
        let fc = max(0, min(9, f))
        focus = fc
        let i = Int(fc), j = min(9, i + 1), t = fc - Double(i)
        let a = Self.hue(forEnclosure: i), b = Self.hue(forEnclosure: j)
        hue = (0..<3).map { a[$0] + (b[$0] - a[$0]) * t }
    }

    /// `anchors(n, idx)` — where the `n` things of an enclosure sit ON it. The Universe's
    /// nodes are re-projected through this every frame, so they ride the real figure rather
    /// than a ring drawn to look like it.
    static func anchors(_ n: Int, _ idx: Int) -> [CGPoint] {
        let r = band[max(0, min(band.count - 1, idx))] * 0.72
        return (0..<max(1, n)).map { i in
            let a = -Double.pi / 2 + (Double(i) + 0.5) * (RoomGeo.tau / Double(max(1, n)))
                  + (idx % 2 != 0 ? 0.16 : 0)
            return CGPoint(x: cos(a) * r, y: sin(a) * r)
        }
    }

    // MARK: - the figure

    private func petals(_ ctx: GraphicsContext, _ count: Int, _ ri: Double, _ ro: Double,
                        _ rot: Double, _ w: Double, _ shading: GraphicsContext.Shading, _ lw: Double) {
        for i in 0..<count {
            let a = rot + Double(i) * RoomGeo.tau / Double(count)
            let hw = w * 0.5
            func P(_ r: Double, _ ang: Double) -> CGPoint { CGPoint(x: cos(ang) * r, y: sin(ang) * r) }
            let p0 = P(ri, a - hw), p1 = P(ro, a), p2 = P(ri, a + hw)
            let m = (ri + ro) * 0.53
            let c0 = P(m, a - hw * 0.62), c1 = P(m, a + hw * 0.62)
            var path = Path()
            path.move(to: p0)
            path.addQuadCurve(to: p1, control: c0)
            path.addQuadCurve(to: p2, control: c1)
            ctx.stroke(path, with: shading, lineWidth: lw)
        }
    }

    private func tri(_ ctx: GraphicsContext, _ base: Double, _ apex: Double, _ hw: Double,
                     _ shading: GraphicsContext.Shading, _ lw: Double) {
        var p = Path()
        p.move(to: CGPoint(x: -hw, y: base))
        p.addLine(to: CGPoint(x: hw, y: base))
        p.addLine(to: CGPoint(x: 0, y: apex))
        p.closeSubpath()
        ctx.stroke(p, with: shading, lineWidth: lw)
    }

    /// The bhupura. The outermost square carries the four gates.
    private func square(_ ctx: GraphicsContext, _ e: Double, _ gates: Bool,
                        _ shading: GraphicsContext.Shading, _ lw: Double) {
        ctx.stroke(Path(CGRect(x: -e, y: -e, width: e * 2, height: e * 2)), with: shading, lineWidth: lw)
        guard gates else { return }
        let w = e * 0.16, d = e * 0.10
        for (ux, uy) in [(0.0, -1.0), (0.0, 1.0), (-1.0, 0.0), (1.0, 0.0)] {
            let r: CGRect = uy != 0
                ? CGRect(x: -w, y: uy > 0 ? e : -e - d, width: w * 2, height: d)
                : CGRect(x: ux > 0 ? e : -e - d, y: -w, width: d, height: w * 2)
            ctx.stroke(Path(r), with: shading, lineWidth: lw)
        }
    }

    /// The whole figure, at one line weight and alpha.
    private func figure(_ ctx: GraphicsContext, _ col: [Double], _ a: Double, _ lw: Double, _ t: Double) {
        let sh = GraphicsContext.Shading.color(RoomGeo.col(col, a))
        square(ctx, 1.46, true, sh, lw)
        square(ctx, 1.38, false, sh, lw)
        square(ctx, 1.30, false, sh, lw)
        petals(ctx, 16, 0.88, 1.00, t * 0.008, RoomGeo.tau / 16 * 0.78, sh, lw)
        petals(ctx, 8, 0.70, 0.84, -t * 0.011, RoomGeo.tau / 8 * 0.70, sh, lw)
        ctx.stroke(RoomDraw.ring(0, 0, 0.66), with: sh, lineWidth: lw)
        for d in Self.down { tri(ctx, d[0], d[1], d[2], sh, lw) }
        for u in Self.up { tri(ctx, u[0], u[1], u[2], sh, lw) }
        tri(ctx, Self.trikona[0], Self.trikona[1], Self.trikona[2], sh, lw)
    }

    // MARK: - the frame

    func draw(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double, breath br: Double) {
        let W = Double(size.width), H = Double(size.height)
        let s = scale(size) * (1 + 0.010 * br)
        let cx = W / 2, cy = H * camY
        let bandR = bandRadius()
        let dim = descending ? 0.22 : 1.0

        // the sky, receding as he goes inward
        let zoom = log(s) * 0.16
        for st in Self.sky {
            let r = st.d * max(W, H) * 0.62 * (1 + zoom * 0.6)
            let x = cx + cos(st.a) * r, y = cy + sin(st.a) * r * 0.96
            if x < -8 || x > W + 8 || y < -8 || y > H + 8 { continue }
            let al = (0.10 + 0.26 * abs(sin(t * 0.28 * st.s + st.p))) * dim
            ctx.fill(RoomDraw.ring(x, y, st.r), with: .color(RoomGeo.col(Self.cream, al)))
        }

        // the hue of the enclosure, breathed into the air around it
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)), with: .radialGradient(
            Gradient(stops: [
                .init(color: RoomGeo.col(hue, (0.10 + 0.05 * br) * dim), location: 0),
                .init(color: RoomGeo.col(hue, 0.035 * dim), location: 0.42),
                .init(color: Color(.sRGB, red: 7 / 255, green: 8 / 255, blue: 13 / 255, opacity: 0), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: max(W, H) * 0.72))

        var fig = ctx
        fig.translateBy(x: cx, y: cy)
        fig.scaleBy(x: s, y: s)

        // the figure entire — faint, always there, the architecture he is inside of
        figure(fig, Self.cream, 0.16 * dim, 1.05 / s, t)

        // the enclosure he is IN: the same lines, lit, inside an annulus of attention
        let inner = bandR * 0.62, outer = bandR * 1.34
        var ann = fig
        var annulus = Path()
        annulus.addEllipse(in: CGRect(x: -outer, y: -outer, width: outer * 2, height: outer * 2))
        annulus.addEllipse(in: CGRect(x: -inner, y: -inner, width: inner * 2, height: inner * 2))
        ann.clip(to: annulus, style: FillStyle(eoFill: true))
        figure(ann, hue, (0.62 + 0.16 * br) * dim, 1.9 / s, t)

        // and its bloom
        fig.fill(RoomDraw.ring(0, 0, outer), with: .radialGradient(
            Gradient(stops: [
                .init(color: RoomGeo.col(hue, 0), location: 0),
                .init(color: RoomGeo.col(hue, (0.055 + 0.03 * br) * dim), location: 0.5),
                .init(color: RoomGeo.col(hue, 0), location: 1)]),
            center: .zero, startRadius: inner, endRadius: outer))

        // a crossing sends one wave out through the whole figure. SCREEN SPACE — the wave is
        // the same size at every depth, because it is the sound he is seeing.
        for f in flares {
            let q = (t - f) / 3.4
            guard q >= 0, q < 1 else { continue }
            let eoq = 1 - pow(1 - q, 3)
            let R = 6 + eoq * max(W, H) * 0.62
            ctx.stroke(RoomDraw.ring(cx, cy, R),
                       with: .color(RoomGeo.col(hue, 0.30 * (1 - q) * (1 - q))), lineWidth: 1.4)
        }

        // the centre. Red, from the first screen, before anything is said about it.
        let pr = 5.2 + br * 2.4
        ctx.fill(RoomDraw.ring(cx, cy, pr * 7), with: .radialGradient(
            Gradient(stops: [.init(color: RoomGeo.col(Self.red, 0.8), location: 0),
                             .init(color: RoomGeo.col(Self.red, 0.30), location: 0.3),
                             .init(color: RoomGeo.col(Self.red, 0), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: pr * 7))
        ctx.fill(RoomDraw.ring(cx, cy, pr * 0.5), with: .color(RoomGeo.col([234, 126, 106], 0.95)))

        // incense — motes in the lit air, rising slowly
        for i in 0..<34 {
            let dp = RoomGeo.rnd(Double(i + 11))
            let x = (RoomGeo.rnd(Double(i + 5)) * W + sin(t * 0.13 + Double(i)) * 14 + W)
                .truncatingRemainder(dividingBy: W)
            let y0 = (RoomGeo.rnd(Double(i + 29)) * H - t * (3 + dp * 9))
                .truncatingRemainder(dividingBy: H)
            let al = (0.05 + dp * 0.26) * (0.5 + 0.5 * sin(t * 0.4 + Double(i))) * dim
            ctx.fill(RoomDraw.ring(x, (y0 + H).truncatingRemainder(dividingBy: H), 0.5 + dp * 1.3),
                     with: .color(RoomGeo.col(hue, al)))
        }

        // the descent: the figure recedes and one shaft of the enclosure's light remains
        if shaft > 0 {
            ctx.fill(Path(CGRect(x: W * 0.5 - 134, y: 0, width: 268, height: H)),
                     with: .linearGradient(
                        Gradient(stops: [.init(color: RoomGeo.col(hue, 0.22 * shaft), location: 0),
                                         .init(color: RoomGeo.col(hue, 0.07 * shaft), location: 0.5),
                                         .init(color: RoomGeo.col(hue, 0), location: 1)]),
                        startPoint: .zero, endPoint: CGPoint(x: 0, y: H)))
        }
    }

    /// Per frame: ease the camera's height and drop flares that have finished, so the array
    /// cannot grow without bound.
    func reap(_ t: Double) {
        if !flares.isEmpty { flares.removeAll { t - $0 >= 3.4 } }
        let dt = lastT == 0 ? 1.0 / 60 : max(0, min(0.1, t - lastT))
        lastT = t
        let target = focus >= 7.4 ? 0.40 : 0.5      // `:929`
        camY += (target - camY) * (1 - pow(1 - 0.05, dt * 60))
    }
}

/// The yantra, behind whatever enclosure he is standing in.
struct PointYantraView: View {
    @ObservedObject var y: PointYantra = .shared
    @EnvironmentObject private var breath: Breath

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                y.draw(ctx, size, t, breath: breath.value)
            }
            .onChange(of: tl.date) { _, _ in y.reap(t) }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
