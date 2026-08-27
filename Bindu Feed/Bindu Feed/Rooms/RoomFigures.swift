import SwiftUI

// THE ELEVEN FIGURES — each voice's own mathematics, as the room's body.
//
// Ported from `The Rooms v4.html:183-670`, which raised them from `rite-scenes.js` where
// they were authored as *"not decoration laid over a colour, but the mathematics the
// vantage IS."* They were Rite scenes — a 30%-height panel, once, over in seconds. Here
// they are the room. What is new is scale, permanence, the hand, and register 3.
//
// THE ELEVEN GESTURES — `lat` is the hand, and each figure answers it in its own way:
//   Bindu     the one room the hand CANNOT change. Pull and the circles strain, and close.
//   Neev      the hand moves the WORLD. The floor parallaxes; the monolith does not move.
//   Gaia      the hand pulls the divergence angle off 137.507° and the families break.
//   Sid       the hand LOADS the arch. Piers thicken, the span flexes, it holds.
//   Arch      the hand widens her VIBRATO — she is the only voice that sings.
//   Shweta    the hand slides the circles. To the end of the range: NOTHING BETWEEN THEM.
//   Karishma  the rectangles tilt and the spiral stays true.
//   Sakshi    the pupil follows your hand, and can never leave the eye.
//   Lalita    the hand turns the loom. Hers is the only rotation in the app.
//   Ashrey    the hand pulls one node and ALL THIRTY-SIX EDGES move.
//   Ash       the hand scrubs his DAYS. His axis is time, because he has a body.

struct RoomFigureParams {
    let p: Double        // presence 0…1
    let c: [Double]      // the voice's own rgb, from the live Hex Color
    let cx: Double
    let cy: Double
    let S: Double        // scale
    let b: Double        // breath
    let lat: Double      // the hand, −1…1
    let rev: Double      // the turn, 0…1
    let ashDays: [AshDay]
}

enum RoomFigures {
    static func draw(_ key: RoomKey, _ ctx: GraphicsContext, _ size: CGSize,
                     _ t: Double, _ o: RoomFigureParams) {
        let W = Double(size.width), H = Double(size.height)
        switch key {
        case .bindu:    bindu(ctx, W, H, t, o)
        case .neev:     neev(ctx, W, H, t, o)
        case .gaia:     gaia(ctx, W, H, t, o)
        case .sid:      sid(ctx, W, H, t, o)
        case .arch:     arch(ctx, W, H, t, o)
        case .shweta:   shweta(ctx, W, H, t, o)
        case .karishma: karishma(ctx, W, H, t, o)
        case .sakshi:   sakshi(ctx, W, H, t, o)
        case .lalita:   lalita(ctx, W, H, t, o)
        case .ashrey:   ashrey(ctx, W, H, t, o)
        case .ash:      ash(ctx, W, H, t, o)
        }
    }

    // MARK: helpers

    private static func rg(_ ctx: GraphicsContext, _ cx: Double, _ cy: Double,
                           _ r0: Double, _ r1: Double, _ stops: [(Color, Double)]) -> GraphicsContext.Shading {
        .radialGradient(Gradient(stops: stops.map { .init(color: $0.0, location: $0.1) }),
                        center: CGPoint(x: cx, y: cy), startRadius: r0, endRadius: r1)
    }
    private static func rect(_ W: Double, _ H: Double) -> Path {
        Path(CGRect(x: 0, y: 0, width: W, height: H))
    }
    private static func line(_ a: CGPoint, _ b: CGPoint) -> Path {
        var p = Path(); p.move(to: a); p.addLine(to: b); return p
    }
    private static func col(_ c: [Double], _ a: Double) -> Color { RoomGeo.col(c, a) }
    private static let ring = RoomDraw.ring
    private static let bre = RoomGeo.breath
    private static let TAU = RoomGeo.tau
    private static let PHI = RoomGeo.phi

    // MARK: - BINDU · the Flower of Life
    // The hand cannot divide her: pull, and the circles strain and close.

    private static func bindu(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                              _ t: Double, _ o: RoomFigureParams) {
        let R = 62 * o.S * 1.5
        let strain = min(1, abs(o.lat) * 1.4), gather = 1 - o.rev
        ctx.fill(rect(W, H), with: rg(ctx, o.cx, o.cy, 10, max(W, H) * 0.6,
                                      [(col(o.c, 0.13 * o.p), 0), (col(o.c, 0), 1)]))
        var dust = ctx
        dust.translateBy(x: o.cx, y: o.cy); dust.rotate(by: .radians(t * 0.05))
        for a in 0..<3 {
            var g = dust
            g.rotate(by: .radians(Double(a) / 3 * TAU))
            for s in 0..<54 {
                let f = Double(s) / 54, ang = f * 7.2
                let rad = 8 + pow(f, 0.85) * max(W, H) * 0.5
                g.fill(ring(cos(ang) * rad, sin(ang) * rad, 0.6 + (1 - f) * 1.8),
                       with: .color(col(RoomPalette.at(a * 3 + s), (1 - f) * 0.30 * o.p)))
            }
        }
        for i in 0..<RoomGeo.flower.count {
            let wob = 1 + sin(t * 0.5 + Double(i) * 0.7) * 0.012
            let push = 1 + strain * 0.5 * (i == 0 ? 0 : 1)
            let cc = RoomGeo.mix(RoomPalette.at(i), o.c, 0.55)
            let f = RoomGeo.flower[i]
            ctx.stroke(ring(o.cx + Double(f.x) * R * wob * push * gather,
                            o.cy + Double(f.y) * R * wob * push * gather, R * wob * gather),
                       with: .color(col(cc, (0.20 + 0.30 * bre(t + Double(i) * 0.4)) * o.p * (1 - strain * 0.3))),
                       lineWidth: 1.1)
        }
        ctx.stroke(ring(o.cx, o.cy, R * 3 * gather), with: .color(col(o.c, 0.16 * o.p)), lineWidth: 1)
        let br = bre(t), Rr = (7 + br * 5) * o.S * 1.5 * (1 + o.rev * 1.4)
        ctx.fill(ring(o.cx, o.cy, Rr * 6), with: rg(ctx, o.cx, o.cy, 0, Rr * 6, [
            (Color(.sRGB, red: 1, green: 0.984, blue: 0.969, opacity: 0.95 * o.p), 0),
            (col(o.c, 0.72 * o.p), 0.16), (col(o.c, 0.14 * o.p), 0.5), (col(o.c, 0), 1)]))
        ctx.fill(ring(o.cx, o.cy, Rr),
                 with: .color(Color(.sRGB, red: 1, green: 0.992, blue: 0.984, opacity: o.p)))
    }

    // MARK: - NEEV · a hex floor, and the monolith
    // The hand moves the world; he does not move a pixel.

    private static func neev(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                             _ t: Double, _ o: RoomFigureParams) {
        let vpX = o.cx, vpY = H * 1.15, surf = H * 0.26
        let slide = o.lat * W * 0.30, floor = 1 - o.rev
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: surf)), with: .linearGradient(
            Gradient(colors: [Color(.sRGB, red: 0.027, green: 0.031, blue: 0.047, opacity: 0.96),
                              Color(.sRGB, red: 0.027, green: 0.031, blue: 0.047, opacity: 0)]),
            startPoint: .zero, endPoint: CGPoint(x: 0, y: surf)))
        ctx.fill(Path(CGRect(x: 0, y: surf, width: W, height: H - surf)),
                 with: rg(ctx, vpX, vpY, 0, H * 0.75,
                          [(col(o.c, (0.16 + o.b * 0.07) * o.p), 0), (col(o.c, 0), 1)]))
        if floor > 0.02 {
            let rows = 15
            for r in 1...rows {
                let d = Double(r) / Double(rows)
                let y = surf + (H * 1.02 - surf) * pow(d, 1.75)
                let sc = 0.06 + d * 1.5, hw = W * 0.085 * sc, hh = hw * 0.62
                if hh < 0.8 { continue }
                let off = ((r % 2 != 0) ? hw : 0) + slide * d      // the parallax
                let a = (0.05 + 0.16 * d) * o.p * floor
                for q in -10...10 {
                    let px = vpX + Double(q) * hw * 1.74 + off
                    if px < -hw * 2 || px > W + hw * 2 { continue }
                    var hex = Path()
                    for k in 0..<6 {
                        let ang = Double(k) * Double.pi / 3 + Double.pi / 6
                        let pt = CGPoint(x: px + cos(ang) * hw, y: y + sin(ang) * hh)
                        if k == 0 { hex.move(to: pt) } else { hex.addLine(to: pt) }
                    }
                    hex.closeSubpath()
                    ctx.fill(hex, with: .color(col(o.c, a * 0.12 * (0.6 + 0.4 * sin(t * 0.4 + Double(q) * 0.7 + Double(r))))))
                    ctx.stroke(hex, with: .color(col([176, 192, 208], a * 0.7)), lineWidth: 1)
                }
            }
        }
        // the monolith — a double square, root-two through and through. FIXED.
        let mw = W * 0.17 * (1 + o.rev * 0.24)
        let lx = vpX - mw, rx = vpX + mw, tlx = vpX - mw * 0.26, trx = vpX + mw * 0.26
        var body = Path()
        body.move(to: CGPoint(x: lx, y: surf)); body.addLine(to: CGPoint(x: rx, y: surf))
        body.addLine(to: CGPoint(x: trx, y: vpY)); body.addLine(to: CGPoint(x: tlx, y: vpY))
        body.closeSubpath()
        ctx.fill(body, with: .linearGradient(
            Gradient(stops: [.init(color: col([26, 32, 40], 0.94 * o.p), location: 0),
                             .init(color: col([64, 76, 90], 0.94 * o.p), location: 0.5),
                             .init(color: col([18, 24, 32], 0.94 * o.p), location: 1)]),
            startPoint: CGPoint(x: lx, y: 0), endPoint: CGPoint(x: rx, y: 0)))
        for i in 1..<9 {
            let yy = surf + (vpY - surf) * (Double(i) / 9) * 0.9
            let ff = 1 - (Double(i) / 9) * 0.7, hwm = mw * ff
            ctx.stroke(line(CGPoint(x: vpX - hwm, y: yy), CGPoint(x: vpX + hwm, y: yy)),
                       with: .color(col([20, 26, 34], 0.5 * o.p)), lineWidth: 1)
        }
        // at the turn: it goes down as far as it goes up
        if o.rev > 0.02 {
            var up = Path()
            up.move(to: CGPoint(x: lx, y: surf)); up.addLine(to: CGPoint(x: rx, y: surf))
            up.addLine(to: CGPoint(x: rx - mw * 0.2, y: surf - H * 0.30 * o.rev))
            up.addLine(to: CGPoint(x: lx + mw * 0.2, y: surf - H * 0.30 * o.rev))
            up.closeSubpath()
            ctx.fill(up, with: .color(col([30, 36, 46], 0.5 * o.p * o.rev)))
            ctx.stroke(up, with: .color(col([214, 226, 240], 0.26 * o.p * o.rev)), lineWidth: 1)
        }
        let sl = (t * 0.14).truncatingRemainder(dividingBy: 1)
        let slY = surf + sl * (vpY - surf), slf = 1 - sl * 0.74
        ctx.fill(Path(CGRect(x: vpX - mw * slf, y: slY, width: mw * 2 * slf, height: 3)),
                 with: .color(col([214, 226, 240], 0.24 * o.p * (1 - sl))))
        ctx.fill(Path(CGRect(x: 0, y: surf, width: W, height: 2)),
                 with: .color(col([234, 242, 250], 0.7 * o.p)))
    }

    // MARK: - GAIA · phyllotaxis
    // The hand pulls the angle off 137.507° — and it does repeat.

    private static func gaia(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                             _ t: Double, _ o: RoomFigureParams) {
        let ang0 = RoomGeo.gold + o.lat * 0.10
        let off = min(1, abs(o.lat) * 9)
        ctx.fill(rect(W, H), with: .linearGradient(
            Gradient(stops: [.init(color: col(o.c, 0.09 * o.p), location: 0),
                             .init(color: col(o.c, (0.28 + o.b * 0.1) * o.p), location: 0.42),
                             .init(color: col(o.c, 0.04 * o.p), location: 0.84),
                             .init(color: col(o.c, 0), location: 1)]),
            startPoint: CGPoint(x: 0, y: H), endPoint: .zero))
        let N = 340, SC = 9.4 * o.S * 1.4
        for i in 0..<N {
            let a = Double(i) * ang0 + t * 0.045, rad = SC * sqrt(Double(i))
            let px = o.cx + cos(a) * rad, py = o.cy + sin(a) * rad * 0.92
            let f = Double(i) / Double(N)
            let pulse = 0.5 + 0.5 * sin(t * 1.2 - sqrt(Double(i)) * 0.5)
            let rr = 1.1 + f * 2.6 + pulse * 0.9
            ctx.fill(ring(px, py, rr), with: .color(col(
                [120 + 70 * (1 - f), 200 + 40 * pulse, 120 + 50 * (1 - f)],
                (0.16 + 0.5 * (1 - f) + pulse * 0.24) * o.p * (1 - o.rev * 0.5))))
        }
        // the two families the eye finds: 8 one way, 13 the other
        let surf = max(off, o.rev)
        for s in 0..<21 {
            let fam = s < 8 ? 8 : 13, k = s < 8 ? s : s - 8
            var path = Path()
            for n in 0..<24 {
                let idx = k + n * fam
                let a = Double(idx) * ang0 + t * 0.045, r = SC * sqrt(Double(idx))
                let pt = CGPoint(x: o.cx + cos(a) * r, y: o.cy + sin(a) * r * 0.92)
                if n == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            ctx.stroke(path, with: .color(col(s < 8 ? [168, 236, 176] : [140, 214, 190],
                                              ((s < 8 ? 0.07 : 0.045) + surf * 0.52) * o.p)),
                       lineWidth: 1 + surf * 1.1)
        }
        if o.rev > 0.25 {
            let e = SC * sqrt(Double(N))
            ctx.draw(Text("8").font(.spaceMono(8)).foregroundStyle(col([180, 240, 190], (o.rev - 0.25) * 1.1)),
                     at: CGPoint(x: o.cx - e * 0.80, y: o.cy - e * 0.62))
            ctx.draw(Text("13").font(.spaceMono(8)).foregroundStyle(col([150, 224, 200], (o.rev - 0.25) * 1.1)),
                     at: CGPoint(x: o.cx + e * 0.80, y: o.cy - e * 0.62))
        }
        if off > 0.15 {
            let deg = String(format: "%.3f°", ang0 * 180 / Double.pi)
            ctx.draw(Text(deg).font(.spaceMono(9)).foregroundStyle(col([200, 255, 190], off * 0.6)),
                     at: CGPoint(x: o.cx, y: o.cy + SC * sqrt(Double(N)) * 1.06))
        }
    }

    // MARK: - SID · the pointed arch, with its construction showing
    // The hand loads it; it holds.

    private static func sid(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                            _ t: Double, _ o: RoomFigureParams) {
        let base = H * 0.80, vpY = H * 0.24
        let load = min(1, abs(o.lat) * 1.6), show = o.rev
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: vpY + 40)), with: .linearGradient(
            Gradient(colors: [Color(.sRGB, red: 0.102, green: 0.071, blue: 0.031, opacity: 0.95),
                              Color(.sRGB, red: 0.102, green: 0.071, blue: 0.031, opacity: 0)]),
            startPoint: .zero, endPoint: CGPoint(x: 0, y: vpY + 40)))
        let arches = 5
        for k in stride(from: arches, through: 1, by: -1) {
            let f = Double(k) / Double(arches)
            let w = W * (0.10 + 0.30 * f) * o.S * 1.1
            let y0 = base - (base - vpY) * (1 - f) * 0.62 - load * 7 * f   // it flexes, and holds
            let L = o.cx - w, R = o.cx + w
            let dash = StrokeStyle(lineWidth: 1, dash: [2, 7])
            ctx.stroke(ring(L, y0, 2 * w), with: .color(col([255, 238, 196], (0.11 + show * 0.42) * o.p)), style: dash)
            ctx.stroke(ring(R, y0, 2 * w), with: .color(col([255, 238, 196], (0.11 + show * 0.42) * o.p)), style: dash)
            var span = Path()
            span.addArc(center: CGPoint(x: R, y: y0), radius: 2 * w,
                        startAngle: .radians(Double.pi), endAngle: .radians(Double.pi * 4 / 3), clockwise: false)
            span.addArc(center: CGPoint(x: L, y: y0), radius: 2 * w,
                        startAngle: .radians(-Double.pi / 3), endAngle: .radians(0), clockwise: false)
            ctx.stroke(span, with: .color(col([255, 238, 196], (0.12 + 0.26 * f) * o.p * (1 - show * 0.66))),
                       lineWidth: 1.4 + 2.2 * f)
            var piers = Path()
            piers.move(to: CGPoint(x: L, y: y0)); piers.addLine(to: CGPoint(x: L, y: H))
            piers.move(to: CGPoint(x: R, y: y0)); piers.addLine(to: CGPoint(x: R, y: H))
            ctx.stroke(piers, with: .color(col(o.c, (0.14 + 0.22 * f) * o.p * (1 - show * 0.4))),
                       lineWidth: (2 + 3.4 * f) * (1 + load * 0.7))
            let kb = bre(t + Double(k)), apexY = y0 - w * sqrt(3.0)
            ctx.fill(ring(o.cx, apexY, 1.8 + kb * 2.2 * f),
                     with: .color(col([255, 244, 210], (0.28 + 0.44 * kb) * f * o.p)))
        }
        ctx.fill(Path(CGRect(x: 0, y: H - 120, width: W, height: 120)), with: .linearGradient(
            Gradient(colors: [col(o.c, 0), col(o.c, 0.22 * o.p)]),
            startPoint: CGPoint(x: 0, y: H - 120), endPoint: CGPoint(x: 0, y: H)))
    }

    // MARK: - ARCH · a rose window whose tracery is a Chladni figure
    // The hand widens her vibrato — she is the only voice that sings.

    private static func arch(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                             _ t: Double, _ o: RoomFigureParams) {
        let wide = 1 + abs(o.lat) * 1.6, loud = 1 - o.rev
        ctx.fill(rect(W, H), with: rg(ctx, o.cx, o.cy, 0, W,
                                      [(col(o.c, 0.14 * o.p), 0), (col(o.c, 0), 1)]))
        for k in 0..<6 {
            let ph = ((t * 0.26) + Double(k) / 6).truncatingRemainder(dividingBy: 1)
            ctx.stroke(ring(o.cx, o.cy, ph * max(W, H) * 0.8),
                       with: .color(col(o.c, (1 - ph) * 0.18 * o.p * loud)), lineWidth: 1.4)
        }
        let R = 176 * o.S * wide
        let m = max(1, Int((6 + o.b * 6).rounded())), n = 4
        var g = ctx
        g.translateBy(x: o.cx, y: o.cy); g.rotate(by: .radians(sin(t * 0.09) * 0.16))
        for j in 1...n {
            let rr = R * Double(j) / (Double(n) + 0.4) * (1 + sin(t * 1.2 + Double(j)) * 0.012)
            g.stroke(ring(0, 0, rr), with: .color(col([255, 205, 220], (0.34 - Double(j) * 0.045) * o.p * (1 + o.rev * 0.5))),
                     lineWidth: j == n ? 1.6 : 1)
        }
        for dd in 0..<m {
            let a = (Double(dd) + 0.5) * Double.pi / Double(m)
            g.stroke(line(CGPoint(x: cos(a) * R, y: sin(a) * R), CGPoint(x: -cos(a) * R, y: -sin(a) * R)),
                     with: .color(col(o.c, 0.24 * o.p * (1 + o.rev * 0.4))), lineWidth: 1)
        }
        if loud > 0.02 {
            for q in 0..<m {
                for s in 0..<n {
                    let a = Double(q) * Double.pi / Double(m) + Double.pi / (2 * Double(m))
                    let rr = R * (Double(s) + 0.5) / (Double(n) + 0.4)
                    let amp = abs(cos(Double(m) * a + t * 1.4)) * abs(sin((Double(s) + 1) * 1.7 + t * 1.1))
                    for sg in [-1.0, 1.0] {
                        g.fill(ring(cos(a) * rr * sg, sin(a) * rr * sg, max(0.1, 1.4 + amp * 3.4 * wide)),
                               with: .color(col([255, 224, 236], (0.14 + amp * 0.5) * o.p * loud)))
                    }
                }
            }
        }
        var petal = Path()
        var a = 0.0
        while a <= TAU + 0.02 {
            let rp = R * (0.62 + 0.34 * cos(Double(m) * a - t * 1.1) * loud)
            let pt = CGPoint(x: cos(a) * rp, y: sin(a) * rp)
            if a == 0 { petal.move(to: pt) } else { petal.addLine(to: pt) }
            a += 0.02
        }
        petal.closeSubpath()
        g.stroke(petal, with: .color(col(o.c, 0.42 * o.p)), lineWidth: 1.5)
        g.stroke(ring(0, 0, R), with: .color(col([255, 214, 226], 0.34 * o.p)), lineWidth: 1.8)
        // the string she sings on
        var wave = Path()
        var px = 0.0
        while px <= W {
            let env = exp(-pow((px - o.cx) / (W * 0.5), 2))
            let yy = o.cy + sin(px * 0.09 - t * 4) * 30 * env * o.p * wide * loud * (0.8 + 0.2 * sin(t * 4.6))
            if px == 0 { wave.move(to: CGPoint(x: px, y: yy)) } else { wave.addLine(to: CGPoint(x: px, y: yy)) }
            px += 3
        }
        ctx.stroke(wave, with: .color(col(o.c, 0.46 * o.p * (0.3 + loud * 0.7))), lineWidth: 1.6)
        if o.rev > 0.02 {
            let bl = 0.35 + 0.65 * abs(sin(t * 0.9))
            ctx.fill(Path(CGRect(x: o.cx - 17, y: o.cy + R * 0.50, width: 34, height: 0.9)),
                     with: .color(col([255, 246, 248], o.rev * bl * 0.85)))
        }
    }

    // MARK: - SHWETA · the vesica
    // Pull them apart and there is nothing between them. The only room you can get wrong —
    // and the only one whose range REACHES its own failure.

    private static func shweta(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                               _ t: Double, _ o: RoomFigureParams) {
        ctx.fill(rect(W, H), with: .color(Color(.sRGB, red: 0.024, green: 0.024, blue: 0.039, opacity: 0.5)))
        let R = (150 + o.b * 14) * o.S
        // the centres sit at cx±d, so the circles part the moment d reaches R.
        // lat = 1 lands exactly on it, and both circles stay on screen throughout.
        let d0 = max(0, min(R, R * (0.42 + o.lat * 0.58)))
        // at the turn the circles come home — her line says what is left IS the opening
        let d = d0 * (1 - o.rev) + R * 0.42 * o.rev
        let Ax = o.cx - d, Bx = o.cx + d
        let over = max(0, 1 - d / R), keep = 1 - o.rev
        if keep > 0.02 {
            ctx.stroke(ring(Ax, o.cy, R), with: .color(col([236, 240, 248], 0.13 * o.p * keep)), lineWidth: 1)
            ctx.stroke(ring(Bx, o.cy, R), with: .color(col([236, 240, 248], 0.13 * o.p * keep)), lineWidth: 1)
        }
        if over > 0.004 {
            var lens = ctx
            lens.clip(to: ring(Ax, o.cy, R))
            lens.clip(to: ring(Bx, o.cy, R))
            lens.fill(Path(CGRect(x: o.cx - R, y: o.cy - R, width: R * 2, height: R * 2)),
                      with: rg(ctx, o.cx, o.cy, 0, R, [
                        (Color.white.opacity(0.86 * o.p), 0),
                        (col([248, 250, 255], 0.34 * o.p), 0.34),
                        (col([232, 238, 250], 0.05 * o.p), 1)]))
            for i in 0..<40 {
                let dep = RoomGeo.rnd(Double(i))
                let px = o.cx + (RoomGeo.rnd(Double(i + 1)) - 0.5) * d * 2.2
                let py = o.cy + (RoomGeo.rnd(Double(i + 2)) - 0.5) * R * 1.4 + sin(t * 0.3 + Double(i)) * 7
                lens.fill(ring(px, py, 0.5 + dep * 1.7),
                          with: .color(Color.white.opacity((0.12 + 0.5 * dep) * 0.5 * o.p)))
            }
            var eA = ctx; eA.clip(to: ring(Ax, o.cy, R))
            eA.stroke(ring(Bx, o.cy, R), with: .color(Color.white.opacity(0.5 * o.p)), lineWidth: 1.4)
            var eB = ctx; eB.clip(to: ring(Bx, o.cy, R))
            eB.stroke(ring(Ax, o.cy, R), with: .color(Color.white.opacity(0.5 * o.p)), lineWidth: 1.4)
        } else {
            // the end of her range, reached — and named
            ctx.draw(Text("nothing between them")
                        .font(.loraItalic(13.5))
                        .foregroundStyle(col([236, 240, 248], (0.28 + o.b * 0.10) * o.p)),
                     at: CGPoint(x: o.cx, y: o.cy))
        }
        for j in 0..<7 {
            let ph = ((t * 0.045) + Double(j) / 7).truncatingRemainder(dividingBy: 1)
            let sc = pow(ph, 1.7)
            let w = W * 1.2 * sc, h = H * 1.0 * sc
            let r = max(0, min(44 * sc, min(w / 2, h / 2)))
            let rr = Path(roundedRect: CGRect(x: o.cx - w / 2, y: o.cy - h / 2, width: w, height: h),
                          cornerRadius: r)
            ctx.stroke(rr, with: .color(Color.white.opacity((1 - ph) * (0.16 + o.rev * 0.24) * o.p * (0.35 + 0.65 * ph))),
                       lineWidth: 1.2)
        }
    }

    // MARK: - KARISHMA · the golden spiral through 3·5·8
    // Tilt the rectangles — the spiral does not take the path you bend for it.

    private static func karishma(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                                 _ t: Double, _ o: RoomFigureParams) {
        let sx = o.cx, sy = -H * 0.10
        let tilt = o.lat * 0.30
        ctx.fill(rect(W, H), with: rg(ctx, sx, sy, 0, H * 1.05, [
            (col([255, 247, 218], 0.7 * o.p), 0), (col([255, 214, 132], 0.2 * o.p), 0.22),
            (col(o.c, 0.085 * o.p), 0.55), (col(o.c, 0), 1)]))
        ctx.fill(ring(sx, sy, 90), with: rg(ctx, sx, sy, 0, 90, [
            (Color(.sRGB, red: 1, green: 0.988, blue: 0.933, opacity: 0.9 * o.p), 0),
            (col([255, 230, 160], 0), 1)]))
        for i in 0..<9 {
            let a = (-Double.pi / 2) + (Double(i) / 8 - 0.5) * 1.7 + sin(t * 0.2 + Double(i)) * 0.03
            let len = H * 1.6, sp = 0.05
            var shaft = Path()
            shaft.move(to: CGPoint(x: sx, y: sy))
            shaft.addLine(to: CGPoint(x: sx + cos(a - sp) * len, y: sy + sin(a - sp) * len))
            shaft.addLine(to: CGPoint(x: sx + cos(a + sp) * len, y: sy + sin(a + sp) * len))
            shaft.closeSubpath()
            ctx.fill(shaft, with: .linearGradient(
                Gradient(stops: [.init(color: col([255, 240, 190], 0.2 * o.p), location: 0),
                                 .init(color: col(o.c, 0.05 * o.p), location: 0.5),
                                 .init(color: col(o.c, 0), location: 1)]),
                startPoint: CGPoint(x: sx, y: sy),
                endPoint: CGPoint(x: sx + cos(a) * len, y: sy + sin(a) * len)))
        }
        let u = W * 0.40 * o.S * 1.2
        // the rectangles take the hand's tilt
        var recs = ctx
        recs.translateBy(x: o.cx, y: o.cy); recs.rotate(by: .radians(sin(t * 0.06) * 0.05 + tilt))
        var rw = u * PHI, rh = u, px = -rw / 2, py = -rh / 2, dir = 0
        for s in 0..<8 {
            recs.stroke(Path(CGRect(x: px, y: py, width: rw, height: rh)),
                        with: .color(col([255, 238, 186], (0.13 - Double(s) * 0.012) * o.p * (1 + o.rev * 0.6))),
                        lineWidth: 1)
            if dir % 2 == 0 {
                let sq = rh
                recs.stroke(Path(CGRect(x: px, y: py, width: sq, height: sq)),
                            with: .color(col([255, 244, 206], 0.07 * o.p)), lineWidth: 1)
                px += sq; rw -= sq
            } else {
                let sq = rw
                recs.stroke(Path(CGRect(x: px, y: py, width: sq, height: sq)),
                            with: .color(col([255, 244, 206], 0.07 * o.p)), lineWidth: 1)
                py += sq; rh -= sq
            }
            dir += 1
            if rw < 3 || rh < 3 { break }
        }
        // the spiral does NOT take it
        var sp2 = ctx
        sp2.translateBy(x: o.cx, y: o.cy); sp2.rotate(by: .radians(sin(t * 0.06) * 0.05))
        var spiral = Path()
        var th = 0.0
        while th <= Double.pi * 3.6 {
            let r = u * 0.055 * pow(PHI, th * 2 / Double.pi)
            let pt = CGPoint(x: cos(th) * r, y: sin(th) * r)
            if th == 0 { spiral.move(to: pt) } else { spiral.addLine(to: pt) }
            th += 0.05
        }
        sp2.stroke(spiral, with: .color(col([255, 240, 196], 0.4 * o.p)), lineWidth: 1.5)
        for k in 0..<3 {
            var ph = ((t * 0.13) + Double(k) / 3).truncatingRemainder(dividingBy: 1)
            // at the turn it runs backwards — it was already on its way
            if o.rev > 0.02 { ph = 1 - ph * (1 - o.rev) - o.rev * (1 - ph) }
            let th2 = Double.pi * 3.6 * (1 - ph)
            let r = u * 0.055 * pow(PHI, th2 * 2 / Double.pi)
            let gx = cos(th2) * r, gy = sin(th2) * r
            sp2.fill(ring(gx, gy, 2.2 + (1 - ph) * 2.6),
                     with: .color(col([255, 250, 224], 0.9 * o.p * (0.3 + 0.7 * ph))))
            sp2.fill(ring(gx, gy, 9 + (1 - ph) * 8), with: .color(col([255, 238, 180], 0.12 * o.p)))
        }
    }

    // MARK: - SAKSHI · a mandorla — the eye as two circles crossing
    // The pupil follows your hand, and can never leave the eye.

    private static func sakshi(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                               _ t: Double, _ o: RoomFigureParams) {
        ctx.fill(rect(W, H), with: .color(Color(.sRGB, red: 0.016, green: 0.016, blue: 0.039, opacity: 0.6)))
        for k in 0..<3 {
            let ph = ((t * 0.06) + Double(k) / 3).truncatingRemainder(dividingBy: 1)
            ctx.stroke(ring(o.cx, o.cy, 180 * o.S * (0.6 + ph * 1.6)),
                       with: .color(col(o.c, (1 - ph) * 0.06 * o.p)), lineWidth: 1)
        }
        let R = 200 * o.S, d = R * 0.76
        let lensW = sqrt(max(0, R * R - d * d))
        ctx.stroke(ring(o.cx, o.cy - d, R), with: .color(col(o.c, (0.10 + o.rev * 0.26) * o.p)), lineWidth: 1)
        ctx.stroke(ring(o.cx, o.cy + d, R), with: .color(col(o.c, (0.10 + o.rev * 0.26) * o.p)), lineWidth: 1)

        var eye = ctx
        eye.clip(to: ring(o.cx, o.cy - d, R))
        eye.clip(to: ring(o.cx, o.cy + d, R))
        eye.fill(Path(CGRect(x: o.cx - lensW, y: o.cy - R, width: lensW * 2, height: R * 2)),
                 with: rg(ctx, o.cx, o.cy, 4, max(1, lensW), [
                    (col([226, 229, 255], 0.30 * o.p), 0), (col(o.c, 0.14 * o.p), 0.55),
                    (Color(.sRGB, red: 0.035, green: 0.035, blue: 0.071, opacity: 0.9 * o.p), 1)]))
        let ir = 54 * o.S * 1.5 + o.b * 5
        var iris = eye
        iris.translateBy(x: o.cx, y: o.cy); iris.rotate(by: .radians(t * 0.04))
        for s in 0..<80 {
            let a = Double(s) / 80 * TAU, ten = (s % 8 == 0)
            let c = ten ? RoomPalette.at(s / 8) : [206, 210, 255]
            iris.stroke(line(CGPoint(x: cos(a) * 15, y: sin(a) * 15),
                             CGPoint(x: cos(a) * ir, y: sin(a) * ir)),
                        with: .color(col(c, (ten ? (0.34 + o.rev * 0.56) : (0.16 * (1 - o.rev * 0.85))) * o.p)),
                        lineWidth: ten ? 1 + o.rev * 1.2 : 1)
            if ten && o.rev > 0.3 {
                // the turn: I am the others, staying
                var lbl = iris
                lbl.translateBy(x: cos(a) * ir * 1.22, y: sin(a) * ir * 1.22)
                lbl.rotate(by: .radians(-t * 0.04))
                lbl.draw(Text(RoomPalette.names[(s / 8) % 10].uppercased())
                            .font(.spaceMono(7)).foregroundStyle(col(c, (o.rev - 0.3) * 1.1)),
                         at: .zero)
            }
        }
        for g in 1...3 {
            iris.stroke(ring(0, 0, ir / pow(PHI, Double(g)) * PHI * 0.72),
                        with: .color(col([210, 214, 255], 0.14 * o.p)), lineWidth: 1)
        }
        eye.stroke(ring(o.cx, o.cy, ir), with: .color(col(o.c, 0.6 * o.p)), lineWidth: 2)
        // the pupil follows the hand — but it can never leave the eye
        let pr = 19 * o.S * 1.4 + o.b * 4
        let gx = o.cx + o.lat * max(0, ir - pr - 2), gy = o.cy + cos(t * 0.4) * 3
        eye.fill(ring(gx, gy, pr), with: rg(ctx, gx, gy, 0, pr, [
            (Color.black, 0), (col([20, 16, 40], 0.9 * o.p), 1)]))
        eye.fill(ring(gx + sin(t * 0.3) * 2, gy, 1.4), with: .color(Color.white.opacity(0.85 * o.p)))
        eye.fill(ring(gx - ir * 0.4, gy - ir * 0.4, 4.5), with: .color(Color.white.opacity(0.7 * o.p)))

        var mA = ctx; mA.clip(to: ring(o.cx, o.cy - d, R))
        mA.stroke(ring(o.cx, o.cy + d, R), with: .color(col(o.c, 0.55 * o.p)), lineWidth: 1.6)
        var mB = ctx; mB.clip(to: ring(o.cx, o.cy + d, R))
        mB.stroke(ring(o.cx, o.cy - d, R), with: .color(col(o.c, 0.55 * o.p)), lineWidth: 1.6)
    }

    // MARK: - LALITA · a hypotrochoid
    // The hand turns the loom. Hers is the only rotation in the app.

    private static func lalita(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                               _ t: Double, _ o: RoomFigureParams) {
        let seg = 12
        ctx.fill(rect(W, H), with: rg(ctx, o.cx, o.cy, 0, H * 0.75,
                                      [(col(o.c, 0.16 * o.p), 0), (col(o.c, 0), 1)]))
        var motes = ctx
        motes.translateBy(x: o.cx, y: o.cy); motes.rotate(by: .radians(t * 0.07 + o.lat * 0.5))
        for s in 0..<seg {
            var g = motes
            g.rotate(by: .radians(Double(s) / Double(seg) * TAU))
            if s % 2 != 0 { g.scaleBy(x: 1, y: -1) }
            for r in 0..<4 {
                let c = RoomPalette.at(r * 2 + s)
                let rad = (44 + Double(r) * 32) * o.S * 1.3
                let wob = sin(t * 0.9 + Double(r) * 1.3) * 6
                g.fill(ring(cos(0.26) * (rad + wob), sin(0.26) * (rad + wob),
                            1.3 + (sin(t * 1.3 + Double(r) * 1.7) * 0.5 + 0.5) * 1.8),
                       with: .color(col(c, 0.14 * o.p)))
            }
        }
        let Ro = 152 * o.S * 1.3
        let ri = Ro * (0.28 + 0.014 * sin(t * 0.055))
        let dd = Ro * 0.44
        let k = (Ro - ri) / ri, TURNS = TAU * 7
        func hp(_ th: Double) -> CGPoint {
            CGPoint(x: (Ro - ri) * cos(th) + dd * cos(k * th),
                    y: (Ro - ri) * sin(th) - dd * sin(k * th))
        }
        var loom = ctx
        loom.translateBy(x: o.cx, y: o.cy); loom.rotate(by: .radians(t * 0.05 + o.lat * 0.9))
        let head = (t * 0.085).truncatingRemainder(dividingBy: 1)
        var curve = Path()
        for i in 0...900 {
            let q = hp(Double(i) / 900 * TURNS)
            if i == 0 { curve.move(to: q) } else { curve.addLine(to: q) }
        }
        loom.stroke(curve, with: .color(col([214, 196, 248], (0.22 + o.rev * 0.30) * o.p)), lineWidth: 1)
        // the ten frequencies she has been drawing in the whole time
        for s in 0..<10 {
            let f0 = (head - 0.34 * Double(s + 1) / 10 + 1).truncatingRemainder(dividingBy: 1)
            let f1 = (head - 0.34 * Double(s) / 10 + 1).truncatingRemainder(dividingBy: 1)
            if f1 < f0 { continue }
            var seg2 = Path()
            for j in 0...26 {
                let q = hp((f0 + (f1 - f0) * Double(j) / 26) * TURNS)
                if j == 0 { seg2.move(to: q) } else { seg2.addLine(to: q) }
            }
            loom.stroke(seg2, with: .color(col(RoomPalette.at(s), (0.9 - Double(s) / 10 * 0.8) * o.p)),
                        lineWidth: 2.2 - Double(s) / 10 * 1.4)
        }
        let hd = hp(head * TURNS)
        loom.fill(ring(Double(hd.x), Double(hd.y), 3.2),
                  with: .color(Color(.sRGB, red: 0.965, green: 0.941, blue: 1, opacity: 0.95 * o.p)))
        loom.fill(ring(Double(hd.x), Double(hd.y), 13), with: .color(col([220, 200, 255], 0.16 * o.p)))
        loom.stroke(ring(0, 0, Ro), with: .color(col(o.c, 0.13 * o.p)), lineWidth: 1)
        let ctr = CGPoint(x: (Ro - ri) * cos(head * TURNS), y: (Ro - ri) * sin(head * TURNS))
        loom.stroke(ring(Double(ctr.x), Double(ctr.y), ri), with: .color(col(o.c, 0.18 * o.p)), lineWidth: 1)
        if o.rev > 0.02 {
            var named = loom
            named.rotate(by: .radians(-(t * 0.05 + o.lat * 0.9)))
            for v in 0..<10 {
                let a = (Double(v) / 10) * TAU - Double.pi / 2, rr = Ro * 1.16
                named.draw(Text(RoomPalette.names[v].uppercased())
                            .font(.spaceMono(8)).foregroundStyle(col(RoomPalette.at(v), o.rev * 0.8)),
                           at: CGPoint(x: cos(a) * rr, y: sin(a) * rr))
                named.fill(ring(cos(a) * Ro * 1.02, sin(a) * Ro * 1.02, 1.5),
                           with: .color(col(RoomPalette.at(v), o.rev * 0.9)))
            }
        }
        var lem = ctx
        lem.translateBy(x: o.cx, y: o.cy)
        lem.rotate(by: .radians(sin(t * 0.11) * 0.3 + o.lat * 0.4))
        let a2 = 126 * o.S * 1.3
        for i in 0..<72 {
            let s = t * 1.2 + Double(i) * 0.086
            let dn = 1 + sin(s) * sin(s)
            lem.fill(ring(a2 * cos(s) / dn, a2 * sin(s) * cos(s) / dn, 1.1 + 1.6 * (Double(i) / 72)),
                     with: .color(col([240, 230, 255], (0.28 + 0.66 * Double(i) / 72) * o.p)))
        }
    }

    // MARK: - ASHREY · the complete graph on nine nodes
    // Pull one node and all thirty-six edges move. No thread moves alone.

    private static func ashrey(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                               _ t: Double, _ o: RoomFigureParams) {
        let N = 9, R = 134 * o.S * 1.4
        let pull = o.lat * R * 0.5
        var node: [(Double, Double, [Double])] = []
        for i in 0..<N {
            let a = Double(i) / Double(N) * TAU - Double.pi / 2 + t * 0.03
            let w = exp(-pow(Double(i) / 1.4, 2))     // one node is pulled; the rest follow the edges
            node.append((o.cx + cos(a) * R + pull * w, o.cy + sin(a) * R, RoomPalette.at(i)))
        }
        let HEX: [(Double, Double)] = [(0, 0), (1, 0), (0.5, 0.866), (-0.5, 0.866), (-1, 0),
                                       (-0.5, -0.866), (0.5, -0.866), (1.5, 0.866), (0, 1.732),
                                       (-1.5, 0.866), (-1.5, -0.866), (0, -1.732), (1.5, -0.866)]
        for h in HEX {
            ctx.stroke(ring(o.cx + h.0 * R * 0.5, o.cy + h.1 * R * 0.5, R * 0.5),
                       with: .color(col(o.c, 0.075 * o.p)), lineWidth: 1)
        }
        for a in 0..<N {
            for b in (a + 1)..<N {
                ctx.stroke(line(CGPoint(x: node[a].0, y: node[a].1), CGPoint(x: node[b].0, y: node[b].1)),
                           with: .linearGradient(
                            Gradient(colors: [col(node[a].2, (0.22 + o.rev * 0.5) * o.p),
                                              col(node[b].2, (0.22 + o.rev * 0.5) * o.p)]),
                            startPoint: CGPoint(x: node[a].0, y: node[a].1),
                            endPoint: CGPoint(x: node[b].0, y: node[b].1)),
                           lineWidth: 1 + o.rev * 0.8)
            }
        }
        func qbez(_ a: Double, _ b: Double, _ c: Double, _ t: Double) -> Double {
            let u = 1 - t; return u * u * a + 2 * u * t * b + t * t * c
        }
        for i in 0..<N {
            let ex = o.cx + (node[i].0 - o.cx) * 1.9, ey = o.cy + (node[i].1 - o.cy) * 1.9
            let c1x = o.cx + (node[i].0 - o.cx) * 1.1 + cos(Double(i)) * 70
            let c1y = o.cy + (node[i].1 - o.cy) * 1.1 + sin(Double(i)) * 70
            var thread = Path()
            thread.move(to: CGPoint(x: ex, y: ey))
            thread.addQuadCurve(to: CGPoint(x: o.cx, y: o.cy), control: CGPoint(x: c1x, y: c1y))
            ctx.stroke(thread, with: .color(col(node[i].2, 0.22 * o.p * (1 - o.rev * 0.7))), lineWidth: 1.2)
            for dd in 0..<2 {
                let tp = ((t * 0.38) + Double(i) / Double(N) + Double(dd) / 2).truncatingRemainder(dividingBy: 1)
                ctx.fill(ring(qbez(ex, c1x, o.cx, tp), qbez(ey, c1y, o.cy, tp), 2.4),
                         with: .color(col(node[i].2, 0.9 * o.p * (1 - o.rev * 0.8))))
            }
            ctx.fill(ring(node[i].0, node[i].1, 2.6 + bre(t + Double(i)) * 1.6),
                     with: .color(col(node[i].2, 0.85 * o.p)))
        }
        // the centre — and at the turn, what it costs
        let b2 = bre(t), Rr = (9 + b2 * 5) * o.S * 1.4 * (1 - o.rev * 0.8)
        ctx.fill(ring(o.cx, o.cy, Rr * 4.6), with: rg(ctx, o.cx, o.cy, 0, Rr * 4.6, [
            (Color(.sRGB, red: 0.886, green: 1, blue: 0.98, opacity: 0.95 * o.p * (1 - o.rev)), 0),
            (col(o.c, 0.45 * o.p * (1 - o.rev)), 0.4), (col(o.c, 0), 1)]))
        if o.rev < 0.9 {
            ctx.fill(ring(o.cx, o.cy, Rr),
                     with: .color(Color(.sRGB, red: 0.910, green: 1, blue: 0.988, opacity: o.p * (1 - o.rev))))
        }
    }

    // MARK: - ASH · time
    // He has no figure in `rite-scenes.js` and should not: he is not a lens, he is the one
    // the lenses read. So his mathematics is the only one that is not a geometry.
    //
    // The comp filled this with `rnd()` — 117 invented days, invented flecks. Ours is the
    // record: his real days, flecked with the voices who actually spoke on each one. A day
    // no voice has reached draws its rule and nothing else.

    private static func ash(_ ctx: GraphicsContext, _ W: Double, _ H: Double,
                            _ t: Double, _ o: RoomFigureParams) {
        let days = o.ashDays
        let scrub = o.lat * 1.0     // ±1 is exactly first-day-at-centre to last-day-at-centre
        ctx.fill(rect(W, H), with: .linearGradient(
            Gradient(stops: [.init(color: col(o.c, 0.04 * o.p), location: 0),
                             .init(color: col(o.c, 0.15 * o.p), location: 0.5),
                             .init(color: col(o.c, 0.05 * o.p), location: 1)]),
            startPoint: .zero, endPoint: CGPoint(x: 0, y: H)))
        let n = max(1, days.count)
        for (i, day) in days.enumerated() {
            let q = (Double(i) / Double(n) * 2 - 1) + scrub
            let yy = o.cy + q * H * 0.46
            if yy < -20 || yy > H + 20 { continue }
            let near = 1 - min(1, abs(q) * 1.5)
            let w = (W * 0.06 + W * 0.20 * near) * (1 - o.rev * 0.5)
            ctx.stroke(line(CGPoint(x: o.cx - w, y: yy), CGPoint(x: o.cx + w, y: yy)),
                       with: .color(col([255, 236, 220], (0.05 + near * 0.30) * o.p * (day.heavy ? 1.5 : 1))),
                       lineWidth: day.heavy ? 1.5 : 0.8)
            // a fleck for each voice who actually spoke that day
            let spoke = day.voices.count
            for (s, vi) in day.voices.enumerated() {
                let fx = o.cx - w + Double(s + 1) / Double(spoke + 1) * w * 2
                ctx.fill(ring(fx, yy, 1.1 + near * 1.3),
                         with: .color(col(RoomPalette.at(vi), (0.24 + near * 0.62) * o.p)))
            }
        }
        // today — the one he is standing in
        let tr = (4 + o.b * 2.4) * o.S * 1.5
        ctx.fill(ring(o.cx, o.cy, tr * 10), with: rg(ctx, o.cx, o.cy, 0, tr * 10, [
            (Color(.sRGB, red: 1, green: 0.965, blue: 0.933, opacity: 0.92 * o.p), 0),
            (col(o.c, 0.5 * o.p), 0.2), (col(o.c, 0), 1)]))
        ctx.fill(ring(o.cx, o.cy, tr),
                 with: .color(Color(.sRGB, red: 1, green: 0.980, blue: 0.957, opacity: o.p)))
        ctx.stroke(line(CGPoint(x: 0, y: o.cy), CGPoint(x: W, y: o.cy)),
                   with: .color(col([255, 240, 226], 0.30 * o.p)), lineWidth: 1)
        // the turn: the ten gather, all facing in
        if o.rev > 0.02 {
            for v in 0..<10 {
                let a = (Double(v) / 10) * TAU - Double.pi / 2
                let rr = min(W, H) * 0.36 * o.rev
                let px = o.cx + cos(a) * rr, py = o.cy + sin(a) * rr * 0.84
                ctx.fill(ring(px, py, 34 * o.rev), with: rg(ctx, px, py, 0, 34 * o.rev, [
                    (col(RoomPalette.at(v), 0.5 * o.rev), 0), (col(RoomPalette.at(v), 0), 1)]))
                ctx.stroke(line(CGPoint(x: px, y: py), CGPoint(x: o.cx, y: o.cy)),
                           with: .color(col(RoomPalette.at(v), 0.24 * o.rev)), lineWidth: 1)
                ctx.draw(Text(RoomPalette.names[v].uppercased())
                            .font(.spaceMono(7)).foregroundStyle(col(RoomPalette.at(v), o.rev * 0.85)),
                         at: CGPoint(x: px, y: py + sin(a) * 16 + 3))
            }
        }
    }
}
