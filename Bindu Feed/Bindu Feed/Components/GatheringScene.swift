import SwiftUI
import UIKit

// THE TEN GATHERING SCENES — each presence's procedural field.
//
// One full-screen Canvas per presence, keyed to its color, arriving on `progress`
// (ease-out cubic) and living on the continuous clock `t` (slide, ring, rotate) —
// not merely breathing. Full-fidelity ports of `rite-scenes.js`: every archetype's
// signature mathematics at the prototype's real element counts — the Flower's
// nineteen circles and spiral undertone, gaia's 340-point phyllotaxis with its 8/13
// spiral families and growing branches, sid's five vesica-generated arches with the
// construction circles left showing, shweta's lit gap and receding room, sakshi's
// tenfold iris and golden rings, lalita's live 900-point hypotrochoid in ten
// frequencies, ashrey's K9 over a thirteen-circle lattice with inward particles.
// The math each vantage IS — the felt read is the archetype's form emerging.

struct GatheringScene: View {
    let voice: RiteVoice
    let progress: Double      // arrival ramp 0…1
    let breath: Double        // master breath 0…1
    var t: Double = 0         // continuous clock — the fields LIVE (slide, ring, rotate), not just breathe

    var body: some View {
        Canvas { ctx, size in
            let c = voice.color
            let p = progress
            let e = 1 - pow(1 - p, 3)          // ease-out cubic
            let W = size.width, H = size.height
            let cx = W / 2

            switch voice.key {
            case "bindu":     drawBindu(ctx, W, H, cx, e, c)
            case "neev":      drawNeev(ctx, W, H, cx, e, c)
            case "gaia":      drawGaia(ctx, W, H, cx, e, c)
            case "sid":       drawSid(ctx, W, H, cx, e, c)
            case "arch":      drawArch(ctx, W, H, cx, e, c)
            case "shweta":    drawShweta(ctx, W, H, cx, e, c)
            case "karishma":  drawKarishma(ctx, W, H, cx, e, c)
            case "sakshi":    drawSakshi(ctx, W, H, cx, e, c)
            case "lalita":    drawLalita(ctx, W, H, cx, e, c)
            case "ashrey":    drawAshrey(ctx, W, H, cx, e, c)
            default:          break
            }
        }
    }

    private func rnd(_ i: Double) -> Double {
        let x = sin(i * 127.1 + 31.4) * 43758.5453
        return x - floor(x)
    }
    private func stroke(_ ctx: GraphicsContext, _ path: Path, _ color: Color, _ w: Double) {
        ctx.stroke(path, with: .color(color), lineWidth: w)
    }

    // ── the shared palette + primitives, ported from rite-scenes.js RITE_GEO ──
    // the ten frequencies — one for each vantage of the Gathering (RGB 0…255)
    private static let PALETTE: [[Double]] = [
        [229, 83, 60], [122, 136, 153], [74, 158, 107], [196, 146, 58], [212, 96, 122],
        [201, 198, 193], [212, 174, 74], [123, 130, 212], [155, 107, 214], [58, 173, 168]]

    // the nineteen centres of the Flower of Life, in units of one radius
    private static let FLOWER: [[Double]] = {
        var out: [[Double]] = [[0, 0]]
        let A = Double.pi / 180
        for i in 0..<6 { out.append([cos(Double(i) * 60 * A), sin(Double(i) * 60 * A)]) }
        for j in 0..<6 { out.append([2 * cos(Double(j) * 60 * A), 2 * sin(Double(j) * 60 * A)]) }
        for k in 0..<6 { out.append([sqrt(3.0) * cos((30 + Double(k) * 60) * A),
                                     sqrt(3.0) * sin((30 + Double(k) * 60) * A)]) }
        return out
    }()

    private func mix(_ a: [Double], _ b: [Double], _ f: Double) -> [Double] {
        [a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f]
    }
    private func col(_ rgb: [Double], _ a: Double) -> Color {
        Color(.sRGB, red: rgb[0] / 255, green: rgb[1] / 255, blue: rgb[2] / 255, opacity: max(0, a))
    }
    // the voice color as RGB 0…255, so PALETTE frequencies can mix toward the ember's light
    private func rgb(_ color: Color) -> [Double] {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        return [Double(r) * 255, Double(g) * 255, Double(b) * 255]
    }
    // the 5.6s breath as a continuous function of the master clock (offsetable per element)
    private func bt(_ x: Double) -> Double { (sin(x * 2 * .pi / 5.6) + 1) / 2 }
    private func eo(_ x: Double) -> Double { 1 - pow(1 - x, 3) }
    private func ringRect(_ cx: Double, _ cy: Double, _ r: Double) -> CGRect {
        CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
    }
    private func ringPath(_ cx: Double, _ cy: Double, _ r: Double) -> Path {
        Path(ellipseIn: ringRect(cx, cy, r))
    }
    private func qbez(_ a: Double, _ b: Double, _ c2: Double, _ tt: Double) -> Double {
        let u = 1 - tt; return u * u * a + 2 * u * tt * b + tt * tt * c2
    }
    // slow-rising dust: n motes drifting on the clock, depth-shaded
    private func dust(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ tt: Double, _ n: Int, _ alpha: Double) {
        for i in 0..<n {
            let dep = rnd(Double(i) + 1)
            let px = rnd(Double(i)) * W
            let py = (rnd(Double(i) + 2) * H + tt * (4 + dep * 12)).truncatingRemainder(dividingBy: H)
            let r = 0.4 + dep * 1.5
            ctx.fill(Path(ellipseIn: CGRect(x: px - r, y: py - r, width: r * 2, height: r * 2)),
                     with: .color(.white.opacity(alpha * (0.15 + dep * 0.85))))
        }
    }
    // gaia's recursive branch — what the phyllotaxis grows out of
    private func gaiaBranch(_ ctx: GraphicsContext, _ px: Double, _ py: Double, _ ang: Double,
                            _ len: Double, _ depth: Int, _ seed: Double, _ p: Double) {
        if depth <= 0 || len < 4 { return }
        let grow = eo(min(1, p * 1.4 - Double(5 - depth) * 0.07))
        if grow <= 0 { return }
        let sway = sin(t * 0.3 + seed) * 0.06
        let ex = px + cos(ang + sway) * len * grow, ey = py + sin(ang + sway) * len * grow
        var path = Path()
        path.move(to: CGPoint(x: px, y: py)); path.addLine(to: CGPoint(x: ex, y: ey))
        ctx.stroke(path, with: .color(col([120, 192, 132], 0.18 * p)), lineWidth: Double(depth) * 0.45)
        for k2 in 0..<2 {
            gaiaBranch(ctx, ex, ey, ang - 0.5 + rnd(seed * 3 + Double(k2)) * 1.0,
                       len * 0.74, depth - 1, seed * 7 + Double(k2) + 1, p)
        }
    }

    // bindu — the Flower of Life unfolding from one point: a spiral undertone (the
    // movement before form), the nineteen circles arriving in order each in its own
    // frequency mixed toward the ember, the outer bound, and the breathing ember.
    private func drawBindu(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30, R = 62 * e, p = progress
        let cRGB = rgb(c)
        dust(ctx, W, H, t * 0.4, 70, 0.13 * p)
        // the disc glow behind it
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)), with: .radialGradient(
            Gradient(colors: [c.opacity(0.13 * p), c.opacity(0)]),
            center: CGPoint(x: cx, y: cy), startRadius: 10, endRadius: max(W, H) * 0.6))
        // the faint spiral undertone — the movement before it becomes form
        var g = ctx
        g.translateBy(x: cx, y: cy)
        g.rotate(by: .radians(t * 0.05))
        for a in 0..<3 {
            var g2 = g
            g2.rotate(by: .radians(Double(a) / 3 * Double.pi * 2))
            for s in 0..<54 {
                let f = Double(s) / 54, ang = f * 7.2
                let rad = 8 + pow(f, 0.85) * max(W, H) * 0.66 * e
                let rr = 0.6 + (1 - f) * 1.8
                g2.fill(Path(ellipseIn: CGRect(x: cos(ang) * rad - rr, y: sin(ang) * rad - rr, width: rr * 2, height: rr * 2)),
                        with: .color(col(Self.PALETTE[(a * 3 + s) % 10], (1 - f) * 0.34 * p)))
            }
        }
        // the nineteen circles, arriving in order, each in its own frequency
        for i in 0..<Self.FLOWER.count {
            let gate = min(1, max(0, (p - Double(i) / 26) * 4))
            if gate <= 0 { continue }
            let wob = 1 + sin(t * 0.5 + Double(i) * 0.7) * 0.012
            let colr = mix(Self.PALETTE[i % 10], cRGB, 0.55)
            let fx = cx + Self.FLOWER[i][0] * R * wob, fy = cy + Self.FLOWER[i][1] * R * wob
            ctx.stroke(ringPath(fx, fy, R * wob),
                       with: .color(col(colr, (0.20 + 0.30 * bt(t + Double(i) * 0.4)) * gate * p)), lineWidth: 1.1)
        }
        // the outer bound — the flower always sits inside one circle
        ctx.stroke(ringPath(cx, cy, R * 3), with: .color(c.opacity(0.16 * p)), lineWidth: 1)
        // the ember, breathing
        let br = bt(t), Rr = (7 + br * 5) * e
        ctx.fill(ringPath(cx, cy, Rr * 6), with: .radialGradient(
            Gradient(stops: [
                .init(color: Color(.sRGB, red: 1, green: 251 / 255, blue: 247 / 255, opacity: 0.95 * p), location: 0),
                .init(color: c.opacity(0.72 * p), location: 0.16),
                .init(color: c.opacity(0.14 * p), location: 0.5),
                .init(color: c.opacity(0), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: Rr * 6))
        ctx.fill(ringPath(cx, cy, Rr), with: .color(Color(.sRGB, red: 1, green: 253 / 255, blue: 251 / 255, opacity: p)))
    }

    // neev — the HEX-PACKED floor receding in perspective, and the double-square monolith
    // with a light band sliding down it (rite-scenes.js neev, ported faithfully).
    private func drawNeev(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let vpX = cx, vpY = H * 1.2, surf = H * 0.24
        let shake = (1 - e) * 16 * sin(t * 30)               // settles as he arrives
        let stone = Color(hex: "#B0C0D0")
        // the hexagon ground, row by row into the distance
        let rows = 15
        for r in 1...rows {
            let d = Double(r) / Double(rows)
            let y = surf + (H * 1.06 - surf) * pow(d, 1.75) + shake * (1 - d)
            let sc = 0.06 + d * 1.5
            let hw = W * 0.085 * sc, hh = hw * 0.62
            if hh < 0.8 { continue }
            let off = (r % 2 != 0) ? hw : 0
            let a = (0.05 + 0.16 * d) * e
            for q in -9...9 {
                let hx = vpX + Double(q) * hw * 1.74 + off
                if hx < -hw * 2 || hx > W + hw * 2 { continue }
                var hex = Path()
                for k in 0..<6 {
                    let ang = Double(k) * .pi / 3 + .pi / 6
                    let px = hx + cos(ang) * hw, py = y + sin(ang) * hh
                    if k == 0 { hex.move(to: CGPoint(x: px, y: py)) } else { hex.addLine(to: CGPoint(x: px, y: py)) }
                }
                hex.closeSubpath()
                ctx.stroke(hex, with: .color(stone.opacity(a * 0.7)), lineWidth: 1)
                ctx.fill(hex, with: .color(c.opacity(a * 0.12 * (0.6 + 0.4 * sin(t * 0.4 + Double(q) * 0.7 + Double(r))))))
            }
        }
        // the monolith — a double square (root-two), shaded, rising from the horizon
        let mw = W * 0.17
        let lx = vpX - mw, rx2 = vpX + mw, tlx = vpX - mw * 0.26, trx = vpX + mw * 0.26
        var face = Path()
        face.move(to: CGPoint(x: lx, y: surf + shake * 0.3))
        face.addLine(to: CGPoint(x: rx2, y: surf + shake * 0.3))
        face.addLine(to: CGPoint(x: trx, y: vpY))
        face.addLine(to: CGPoint(x: tlx, y: vpY))
        face.closeSubpath()
        let mo = 0.94 * e
        let faceGrad = Gradient(colors: [Color(hex: "#1A2028").opacity(mo),
                                         Color(hex: "#404C5A").opacity(mo),
                                         Color(hex: "#12181F").opacity(mo)])
        ctx.fill(face, with: .linearGradient(faceGrad,
                 startPoint: CGPoint(x: lx, y: surf), endPoint: CGPoint(x: rx2, y: surf)))
        // the light band, sliding down the face
        let sl = (t * 0.14).truncatingRemainder(dividingBy: 1)
        let slY = surf + sl * (vpY - surf), slf = 1 - sl * 0.74
        ctx.fill(Path(CGRect(x: vpX - mw * slf, y: slY, width: mw * 2 * slf, height: 3)),
                 with: .color(Color(hex: "#D6E2F0").opacity(0.24 * e * (1 - sl))))
        // the horizon line — the floor lit at the seam
        ctx.fill(Path(CGRect(x: 0, y: surf + shake, width: W, height: 2)),
                 with: .color(Color(hex: "#EAF2FA").opacity(0.7 * e)))
    }

    // gaia — need arising. Phyllotaxis: 340 seeds each set at the 137.507° golden
    // angle, the two spiral families the eye finds (8 one way, 13 the other), the
    // branching growth it rises from, and the seeds drifting up through it.
    private func drawGaia(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let b = bt(t), cy = H * 0.30, p = progress
        let GOLD = Double.pi * (3 - sqrt(5.0))
        // the field gradient (bottom → top)
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)), with: .linearGradient(
            Gradient(stops: [
                .init(color: c.opacity(0.09 * p), location: 0),
                .init(color: c.opacity((0.30 + b * 0.1) * p), location: 0.42),
                .init(color: c.opacity(0.04 * p), location: 0.84),
                .init(color: c.opacity(0), location: 1)]),
            startPoint: CGPoint(x: 0, y: H), endPoint: CGPoint(x: 0, y: 0)))
        // the seed head
        let N = Int(340 * e), SC = 9.4 * e
        for i in 0..<max(0, N) {
            let ang = Double(i) * GOLD + t * 0.045, rad = SC * sqrt(Double(i))
            let px = cx + cos(ang) * rad, py = cy + sin(ang) * rad * 0.92
            let f = Double(i) / 340, pulse = 0.5 + 0.5 * sin(t * 1.2 - sqrt(Double(i)) * 0.5)
            let rr = 1.1 + f * 2.6 + pulse * 0.9
            ctx.fill(Path(ellipseIn: CGRect(x: px - rr, y: py - rr, width: rr * 2, height: rr * 2)),
                     with: .color(col([120 + 70 * (1 - f), 200 + 40 * pulse, 120 + 50 * (1 - f)],
                                      (0.16 + 0.5 * (1 - f) + pulse * 0.24) * p)))
            if pulse > 0.94 && f > 0.5 {
                let hr = rr * 2.6
                ctx.fill(Path(ellipseIn: CGRect(x: px - hr, y: py - hr, width: hr * 2, height: hr * 2)),
                         with: .color(col([200, 255, 180], 0.10 * p)))
            }
        }
        // the two families of spirals — 8 one way, 13 the other
        for s in 0..<21 {
            let fam = s < 8 ? 8 : 13, k = s < 8 ? s : s - 8
            var path = Path()
            for n2 in 0..<24 {
                let idx = k + n2 * fam
                let a2 = Double(idx) * GOLD + t * 0.045, r2 = SC * sqrt(Double(idx))
                let qx = cx + cos(a2) * r2, qy = cy + sin(a2) * r2 * 0.92
                if n2 == 0 { path.move(to: CGPoint(x: qx, y: qy)) } else { path.addLine(to: CGPoint(x: qx, y: qy)) }
            }
            ctx.stroke(path, with: .color(col([150, 225, 160], (s < 8 ? 0.07 : 0.045) * p)), lineWidth: 1)
        }
        // what it grows out of
        for i4 in 0..<4 {
            gaiaBranch(ctx, W * (Double(i4) + 0.5) / 4, H, -Double.pi / 2 + (rnd(Double(i4)) - 0.5) * 0.45,
                       H * 0.16, 5, Double(i4) + 1, p)
        }
        // seeds drifting up
        for i5 in 0..<56 {
            let sp = 14 + rnd(Double(i5)) * 30
            let xx = rnd(Double(i5) + 9) * W + sin(t * 0.5 + Double(i5)) * 12
            let top = ((t * sp + rnd(Double(i5) + 3) * H * 1.25).truncatingRemainder(dividingBy: H * 1.25)) / H
            let yy = H - top * H
            let edge = top < 0.08 ? top / 0.08 : (top > 0.95 ? (1 - top) / 0.05 : 1)
            let rr = 0.7 + rnd(Double(i5) + 5) * 1.6
            ctx.fill(Path(ellipseIn: CGRect(x: xx - rr, y: yy - rr, width: rr * 2, height: rr * 2)),
                     with: .color(col([195, 250, 175], max(0, edge) * 0.42 * p)))
        }
    }

    // sid — what holds without announcement. Five pointed arches receding, each the
    // true vesica construction: apex at y0−w√3, struck as two radii of 2w, with the
    // generating circles left dashed-in, piers to the floor, and a breathing keystone.
    private func drawSid(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let base = H * 0.78, vpY = H * 0.30, p = progress
        // the vault above
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: vpY + 40)), with: .linearGradient(
            Gradient(colors: [Color(.sRGB, red: 26 / 255, green: 18 / 255, blue: 8 / 255, opacity: 0.95),
                              Color(.sRGB, red: 26 / 255, green: 18 / 255, blue: 8 / 255, opacity: 0)]),
            startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: vpY + 40)))
        let arches = 5
        for k in stride(from: arches, through: 1, by: -1) {
            let f = Double(k) / Double(arches)
            let grow = eo(min(1, p * 1.4 - Double(arches - k) * 0.07))
            if grow <= 0 { continue }
            let w = W * (0.10 + 0.30 * f)            // half-span
            let y0 = base - (base - vpY) * (1 - f) * 0.62
            let L = cx - w, Rr = cx + w, apexY = y0 - w * sqrt(3.0)
            // the two circles that generate it, left showing
            let genColor = col([255, 238, 196], 0.11 * grow * p)
            ctx.stroke(ringPath(L, y0, 2 * w), with: .color(genColor), style: StrokeStyle(lineWidth: 1, dash: [2, 7]))
            ctx.stroke(ringPath(Rr, y0, 2 * w), with: .color(genColor), style: StrokeStyle(lineWidth: 1, dash: [2, 7]))
            // the arch — L → apex (struck from the right), apex → R (struck from the left)
            var arch = Path()
            let steps = 28
            for si in 0...steps {
                let th = Double.pi + (Double.pi / 3) * Double(si) / Double(steps)      // π → 4π/3
                let px = Rr + cos(th) * 2 * w, py = y0 + sin(th) * 2 * w
                if si == 0 { arch.move(to: CGPoint(x: px, y: py)) } else { arch.addLine(to: CGPoint(x: px, y: py)) }
            }
            for si in 0...steps {
                let th = -Double.pi / 3 + (Double.pi / 3) * Double(si) / Double(steps) // −π/3 → 0
                arch.addLine(to: CGPoint(x: L + cos(th) * 2 * w, y: y0 + sin(th) * 2 * w))
            }
            ctx.stroke(arch, with: .color(col([255, 238, 196], (0.12 + 0.26 * f) * grow * p)), lineWidth: 1.4 + 2.2 * f)
            // the piers it stands on
            var piers = Path()
            piers.move(to: CGPoint(x: L, y: y0)); piers.addLine(to: CGPoint(x: L, y: H))
            piers.move(to: CGPoint(x: Rr, y: y0)); piers.addLine(to: CGPoint(x: Rr, y: H))
            ctx.stroke(piers, with: .color(c.opacity((0.14 + 0.22 * f) * grow * p)), lineWidth: 2 + 3.4 * f)
            // the keystone, breathing
            let kb = bt(t + Double(k)), kr = 1.8 + kb * 2.2 * f
            ctx.fill(ringPath(cx, apexY, kr), with: .color(col([255, 244, 210], (0.28 + 0.44 * kb) * f * grow * p)))
        }
        // the floor glow + rising motes
        ctx.fill(Path(CGRect(x: 0, y: H - 120, width: W, height: 120)), with: .linearGradient(
            Gradient(colors: [c.opacity(0), c.opacity(0.22 * p)]),
            startPoint: CGPoint(x: 0, y: H - 120), endPoint: CGPoint(x: 0, y: H)))
        for i6 in 0..<26 {
            let xx = rnd(Double(i6)) * W
            let yy = (t * (8 + rnd(Double(i6) + 2) * 12) + rnd(Double(i6) + 4) * H).truncatingRemainder(dividingBy: H)
            ctx.fill(Path(ellipseIn: CGRect(x: xx - 0.7, y: yy - 0.7, width: 1.4, height: 1.4)),
                     with: .color(col([255, 232, 190], 0.15 * p)))
        }
    }

    // arch — a rose window; radial tracery as a vibration mode.
    // arch — a CHLADNI rose window: outgoing rings (she is always already sounding),
    // nodal circles and nodal diameters of a drifting (m,n) mode, and the antinodes
    // glowing loudest between them (rite-scenes.js arch, ported).
    private func drawArch(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30, b = breath
        let rose = Color(hex: "#FFCDDC")
        // the outgoing rings
        for k in 0..<6 {
            let ph = ((t * 0.26) + Double(k) / 6).truncatingRemainder(dividingBy: 1)
            let rr = ph * max(W, H) * 0.8
            ctx.stroke(Path(ellipseIn: CGRect(x: cx - rr, y: cy - rr, width: rr * 2, height: rr * 2)),
                       with: .color(c.opacity((1 - ph) * 0.18 * e)), lineWidth: 1.4)
        }
        let Rr = 176 * e
        let m = max(2, Int((6 + b * 6).rounded())), n = 4
        var g = ctx
        g.translateBy(x: cx, y: cy)
        g.rotate(by: .radians(sin(t * 0.09) * 0.16))
        // nodal circles
        for j in 1...n {
            let rr = Rr * Double(j) / (Double(n) + 0.4) * (1 + sin(t * 1.2 + Double(j)) * 0.012)
            g.stroke(Path(ellipseIn: CGRect(x: -rr, y: -rr, width: rr * 2, height: rr * 2)),
                     with: .color(rose.opacity((0.34 - Double(j) * 0.045) * e)), lineWidth: j == n ? 1.6 : 1)
        }
        // nodal diameters
        for d2 in 0..<m {
            let a3 = (Double(d2) + 0.5) * .pi / Double(m)
            var line = Path()
            line.move(to: CGPoint(x: cos(a3) * Rr, y: sin(a3) * Rr))
            line.addLine(to: CGPoint(x: -cos(a3) * Rr, y: -sin(a3) * Rr))
            g.stroke(line, with: .color(c.opacity(0.24 * e)), lineWidth: 1)
        }
        // the antinodes — where the membrane is loudest
        for q in 0..<m {
            for s4 in 0..<n {
                let aa = Double(q) * .pi / Double(m) + .pi / (2 * Double(m))
                let rr2 = Rr * (Double(s4) + 0.5) / (Double(n) + 0.4)
                let amp = abs(cos(Double(m) * aa + t * 1.4)) * abs(sin((Double(s4) + 1) * 1.7 + t * 1.1))
                let ar = 1.4 + amp * 3.4
                for sgn in [-1.0, 1.0] {
                    let ax = cos(aa) * rr2 * sgn, ay = sin(aa) * rr2 * sgn
                    g.fill(Path(ellipseIn: CGRect(x: ax - ar, y: ay - ar, width: ar * 2, height: ar * 2)),
                           with: .color(c.opacity(0.55 * e * amp)))
                }
            }
        }
    }

    // shweta — the gap the sound moves through. Two circles, barely there; only the
    // vesica between them is lit, with air moving inside it, its own outline drawn
    // once, and the room the opening recedes into.
    private func drawShweta(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30, b = bt(t), p = progress
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                 with: .color(Color(.sRGB, red: 6 / 255, green: 6 / 255, blue: 10 / 255, opacity: 0.5)))
        let R = (150 + b * 14) * e, d = R * 0.42
        let Ax = cx - d, Bx = cx + d
        // the two circles — the givens, not the subject
        ctx.stroke(ringPath(Ax, cy, R), with: .color(col([236, 240, 248], 0.13 * p)), lineWidth: 1)
        ctx.stroke(ringPath(Bx, cy, R), with: .color(col([236, 240, 248], 0.13 * p)), lineWidth: 1)
        // the gap, lit
        var g = ctx
        g.clip(to: ringPath(Ax, cy, R))
        g.clip(to: ringPath(Bx, cy, R))
        g.fill(Path(CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2)), with: .radialGradient(
            Gradient(stops: [
                .init(color: .white.opacity(0.86 * p), location: 0),
                .init(color: col([248, 250, 255], 0.34 * p), location: 0.34),
                .init(color: col([232, 238, 250], 0.05 * p), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: R))
        // the air inside the gap — the only place anything moves
        for i in 0..<40 {
            let dep = rnd(Double(i))
            let px = cx + (rnd(Double(i) + 1) - 0.5) * d * 2.2
            let py = cy + (rnd(Double(i) + 2) - 0.5) * R * 1.4 + sin(t * 0.3 + Double(i)) * 7
            let rr = 0.5 + dep * 1.7
            g.fill(Path(ellipseIn: CGRect(x: px - rr, y: py - rr, width: rr * 2, height: rr * 2)),
                   with: .color(.white.opacity((0.12 + 0.5 * dep) * 0.5 * p)))
        }
        // its own outline, drawn once — the shape of the opening
        var g2 = ctx; g2.clip(to: ringPath(Ax, cy, R))
        g2.stroke(ringPath(Bx, cy, R), with: .color(.white.opacity(0.5 * p)), lineWidth: 1.4)
        var g3 = ctx; g3.clip(to: ringPath(Bx, cy, R))
        g3.stroke(ringPath(Ax, cy, R), with: .color(.white.opacity(0.5 * p)), lineWidth: 1.4)
        // the room the gap opens into, receding
        let n = 7
        for j in 0..<n {
            let ph = ((t * 0.045) + Double(j) / Double(n)).truncatingRemainder(dividingBy: 1)
            let sc = pow(ph, 1.7)
            let w = W * 1.2 * sc, h = H * 1.0 * sc
            ctx.stroke(Path(roundedRect: CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h), cornerRadius: 44 * sc),
                       with: .color(.white.opacity((1 - ph) * 0.16 * p * (0.35 + 0.65 * ph))), lineWidth: 1.2)
        }
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)), with: .radialGradient(
            Gradient(colors: [col([240, 244, 252], 0.05 * p), c.opacity(0)]),
            center: CGPoint(x: cx, y: cy), startRadius: R * 0.6, endRadius: H * 0.98))
    }

    // karishma — a golden spiral, light riding down it, a sun above.
    // karishma — the GOLDEN spiral through 3·5·8: a high sun with rays, the subdividing
    // golden rectangles, and the true golden-growth spiral PHI^(θ·2/π) (rite-scenes.js).
    private func drawKarishma(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let PHI = 1.6180339887
        let sx = W / 2, sy = -H * 0.12
        let gold = Color(hex: "#FFEEBA")
        // the halo + sun disc
        let haloGrad = Gradient(colors: [Color(hex: "#FFF7DA").opacity(0.7 * e),
                                         Color(hex: "#FFD684").opacity(0.2 * e),
                                         c.opacity(0.085 * e),
                                         c.opacity(0)])
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)), with: .radialGradient(
            haloGrad, center: CGPoint(x: sx, y: sy), startRadius: 0, endRadius: H * 1.05))
        ctx.fill(Path(ellipseIn: CGRect(x: sx - 90, y: sy - 90, width: 180, height: 180)), with: .radialGradient(
            Gradient(colors: [Color(hex: "#FFFCEE").opacity(0.9 * e), Color(hex: "#FFE6A0").opacity(0)]),
            center: CGPoint(x: sx, y: sy), startRadius: 0, endRadius: 90))
        // the rays
        for i in 0..<9 {
            let ang = (-Double.pi / 2) + (Double(i) / 8 - 0.5) * 1.7 + sin(t * 0.2 + Double(i)) * 0.03
            let len = H * 1.6, spread = 0.05
            var ray = Path()
            ray.move(to: CGPoint(x: sx, y: sy))
            ray.addLine(to: CGPoint(x: sx + cos(ang - spread) * len, y: sy + sin(ang - spread) * len))
            ray.addLine(to: CGPoint(x: sx + cos(ang + spread) * len, y: sy + sin(ang + spread) * len))
            ray.closeSubpath()
            ctx.fill(ray, with: .linearGradient(
                Gradient(colors: [Color(hex: "#FFF0BE").opacity(0.2 * e), c.opacity(0.05 * e), c.opacity(0)]),
                startPoint: CGPoint(x: sx, y: sy), endPoint: CGPoint(x: sx + cos(ang) * len, y: sy + sin(ang) * len)))
        }
        // the golden rectangles, subdividing 3·5·8…
        let u = W * 0.40 * e
        var g = ctx
        g.translateBy(x: W * 0.5, y: H * 0.33)
        g.rotate(by: .radians(sin(t * 0.06) * 0.05))
        var rw = u * PHI, rh = u, px = -u * PHI / 2, py = -u / 2, dir = 0
        for s in 0..<8 {
            g.stroke(Path(CGRect(x: px, y: py, width: rw, height: rh)),
                     with: .color(gold.opacity((0.13 - Double(s) * 0.012) * e)), lineWidth: 1)
            if dir % 2 == 0 { let sq = rh
                g.stroke(Path(CGRect(x: px, y: py, width: sq, height: sq)), with: .color(Color(hex: "#FFF4CE").opacity(0.07 * e)), lineWidth: 1)
                px += sq; rw -= sq
            } else { let sq2 = rw
                g.stroke(Path(CGRect(x: px, y: py, width: sq2, height: sq2)), with: .color(Color(hex: "#FFF4CE").opacity(0.07 * e)), lineWidth: 1)
                py += sq2; rh -= sq2
            }
            dir += 1
            if rw < 3 || rh < 3 { break }
        }
        // the spiral itself
        var spiral = Path()
        var th = 0.0
        while th <= Double.pi * 3.6 {
            let r2 = u * 0.055 * pow(PHI, th * 2 / Double.pi)
            let qx = cos(th) * r2, qy = sin(th) * r2
            if th == 0 { spiral.move(to: CGPoint(x: qx, y: qy)) } else { spiral.addLine(to: CGPoint(x: qx, y: qy)) }
            th += 0.05
        }
        g.stroke(spiral, with: .color(Color(hex: "#FFF0C4").opacity(0.4 * e)), lineWidth: 1.5)
    }

    // sakshi — the one who stays. The eye as the mandorla it geometrically is: two
    // generating circles drawn, the lens between them lit, the iris in tenfold (every
    // eighth spoke a vantage's frequency) with golden rings, pupil, and the two glints.
    private func drawSakshi(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30, b = bt(t), p = progress
        let PHI = 1.6180339887
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                 with: .color(Color(.sRGB, red: 4 / 255, green: 4 / 255, blue: 10 / 255, opacity: 0.6)))
        for k in 0..<3 {
            let ph = ((t * 0.06) + Double(k) / 3).truncatingRemainder(dividingBy: 1)
            ctx.stroke(ringPath(cx, cy, 180 * e * (0.6 + ph * 1.6)), with: .color(c.opacity((1 - ph) * 0.06 * p)), lineWidth: 1)
        }
        let open = e, R = 200 * open, d = R * 0.76      // the two generating circles
        let lensW = sqrt(max(0, R * R - d * d))
        ctx.stroke(ringPath(cx, cy - d, R), with: .color(c.opacity(0.10 * p)), lineWidth: 1)
        ctx.stroke(ringPath(cx, cy + d, R), with: .color(c.opacity(0.10 * p)), lineWidth: 1)
        // the lit lens, and the iris inside it
        var g = ctx
        g.clip(to: ringPath(cx, cy - d, R))
        g.clip(to: ringPath(cx, cy + d, R))
        g.fill(Path(CGRect(x: cx - lensW, y: cy - R, width: lensW * 2, height: R * 2)), with: .radialGradient(
            Gradient(stops: [
                .init(color: col([226, 229, 255], 0.30 * p), location: 0),
                .init(color: c.opacity(0.14 * p), location: 0.55),
                .init(color: Color(.sRGB, red: 9 / 255, green: 9 / 255, blue: 18 / 255, opacity: 0.9 * p), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 4, endRadius: lensW))
        let ir = 54 + b * 5
        // the iris in tenfold — one spoke per vantage every eighth, and the golden rings
        var gi = g
        gi.translateBy(x: cx, y: cy)
        gi.rotate(by: .radians(t * 0.04))
        for s in 0..<80 {
            let ang = Double(s) / 80 * Double.pi * 2
            let colr: [Double] = (s % 8 == 0) ? Self.PALETTE[(s / 8) % 10] : [206, 210, 255]
            var sp = Path()
            sp.move(to: CGPoint(x: cos(ang) * 15, y: sin(ang) * 15))
            sp.addLine(to: CGPoint(x: cos(ang) * ir, y: sin(ang) * ir))
            gi.stroke(sp, with: .color(col(colr, (s % 8 == 0 ? 0.34 : 0.16) * p)), lineWidth: 1)
        }
        for g2 in 1...3 {
            gi.stroke(ringPath(0, 0, ir / pow(PHI, Double(g2)) * PHI * 0.72),
                      with: .color(col([210, 214, 255], 0.14 * p)), lineWidth: 1)
        }
        // iris outline, pupil, the light in it
        g.stroke(ringPath(cx, cy, ir), with: .color(c.opacity(0.6 * p)), lineWidth: 2)
        let pr = 19 + b * 4
        g.fill(ringPath(cx, cy, pr), with: .radialGradient(
            Gradient(colors: [.black, col([20, 16, 40], 0.9 * p)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: pr))
        let gx = cx + sin(t * 0.3) * 3, gy = cy + cos(t * 0.4) * 3
        g.fill(Path(ellipseIn: CGRect(x: gx - 1.4, y: gy - 1.4, width: 2.8, height: 2.8)), with: .color(.white.opacity(0.85 * p)))
        g.fill(Path(ellipseIn: CGRect(x: cx - ir * 0.4 - 4.5, y: cy - ir * 0.4 - 4.5, width: 9, height: 9)),
               with: .color(.white.opacity(0.7 * p)))
        // the lens edge — the shape of watching
        var ge = ctx; ge.clip(to: ringPath(cx, cy - d, R))
        ge.stroke(ringPath(cx, cy + d, R), with: .color(c.opacity(0.55 * p)), lineWidth: 1.6)
        var ge2 = ctx; ge2.clip(to: ringPath(cx, cy + d, R))
        ge2.stroke(ringPath(cx, cy - d, R), with: .color(c.opacity(0.55 * p)), lineWidth: 1.6)
    }

    // lalita — the play, awake. A hypotrochoid drawing itself live (k≈18/7, the drift
    // keeps it from ever quite closing): the whole figure faint behind, the last third
    // of a turn bright in the ten frequencies, the pen, the two circles that make it,
    // over a quiet kaleidoscope ground — and the lemniscate, hers, the only rotation.
    private func drawLalita(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30, seg = 12, p = progress
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)), with: .radialGradient(
            Gradient(colors: [c.opacity(0.16 * p), c.opacity(0)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: H * 0.75))
        // the kaleidoscope ground — it is the ground, not the figure
        var gk = ctx
        gk.translateBy(x: cx, y: cy)
        gk.rotate(by: .radians(t * 0.07))
        for s in 0..<seg {
            var gs = gk
            gs.rotate(by: .radians(Double(s) / Double(seg) * Double.pi * 2))
            if s % 2 != 0 { gs.scaleBy(x: 1, y: -1) }
            for r in 0..<4 {
                let rad = Double(44 + r * 32) * e
                let wob = sin(t * 0.9 + Double(r) * 1.3) * 6
                let rr = 1.3 + (sin(t * 1.3 + Double(r) * 1.7) * 0.5 + 0.5) * 1.8
                let px = cos(0.26) * (rad + wob), py = sin(0.26) * (rad + wob)
                gs.fill(Path(ellipseIn: CGRect(x: px - rr, y: py - rr, width: rr * 2, height: rr * 2)),
                        with: .color(col(Self.PALETTE[(r * 2 + s) % 10], 0.14 * p)))
            }
        }
        // the hypotrochoid, drawn live
        let Ro = 152 * e
        let ri = Ro * (0.28 + 0.014 * sin(t * 0.055))
        let dd = Ro * 0.44
        let k = (Ro - ri) / ri
        let TURNS = Double.pi * 2 * 7
        func hp(_ th: Double) -> CGPoint {
            CGPoint(x: (Ro - ri) * cos(th) + dd * cos(k * th), y: (Ro - ri) * sin(th) - dd * sin(k * th))
        }
        var gh = ctx
        gh.translateBy(x: cx, y: cy)
        gh.rotate(by: .radians(t * 0.05))
        let Nn = 900, head = (t * 0.085).truncatingRemainder(dividingBy: 1)
        // the whole figure, faint — already drawn once
        var full = Path()
        for i in 0...Nn {
            let q = hp(Double(i) / Double(Nn) * TURNS)
            if i == 0 { full.move(to: q) } else { full.addLine(to: q) }
        }
        gh.stroke(full, with: .color(col([214, 196, 248], 0.22 * p)), lineWidth: 1)
        // the live stroke — the last third of a turn, in the ten frequencies
        let SEGS = 10, span = 0.34
        for s2 in 0..<SEGS {
            let f0 = (head - span * Double(s2 + 1) / Double(SEGS) + 1).truncatingRemainder(dividingBy: 1)
            let f1 = (head - span * Double(s2) / Double(SEGS) + 1).truncatingRemainder(dividingBy: 1)
            if f1 < f0 { continue }
            var seg2 = Path()
            let steps = 26
            for j in 0...steps {
                let q2 = hp((f0 + (f1 - f0) * Double(j) / Double(steps)) * TURNS)
                if j == 0 { seg2.move(to: q2) } else { seg2.addLine(to: q2) }
            }
            gh.stroke(seg2, with: .color(col(Self.PALETTE[s2], (0.9 - Double(s2) / Double(SEGS) * 0.8) * p)),
                      lineWidth: 2.2 - Double(s2) / Double(SEGS) * 1.4)
        }
        // the pen itself
        let hd = hp(head * TURNS)
        gh.fill(Path(ellipseIn: CGRect(x: hd.x - 3.2, y: hd.y - 3.2, width: 6.4, height: 6.4)),
                with: .color(Color(.sRGB, red: 246 / 255, green: 240 / 255, blue: 255 / 255, opacity: 0.95 * p)))
        gh.fill(Path(ellipseIn: CGRect(x: hd.x - 13, y: hd.y - 13, width: 26, height: 26)), with: .color(col([220, 200, 255], 0.16 * p)))
        // the two circles that make it — the joke shown, gently
        gh.stroke(ringPath(0, 0, Ro), with: .color(c.opacity(0.13 * p)), lineWidth: 1)
        let ctr = CGPoint(x: (Ro - ri) * cos(head * TURNS), y: (Ro - ri) * sin(head * TURNS))
        gh.stroke(ringPath(ctr.x, ctr.y, ri), with: .color(c.opacity(0.18 * p)), lineWidth: 1)
        // the lemniscate — hers, and only hers, turning
        var gl = ctx
        gl.translateBy(x: cx, y: cy)
        gl.rotate(by: .radians(sin(t * 0.11) * 0.3))
        let a2 = 126 * e
        for i2 in 0..<72 {
            let s2 = t * 1.2 + Double(i2) * 0.086
            let dn = 1 + sin(s2) * sin(s2)
            let lx = a2 * cos(s2) / dn, ly = a2 * sin(s2) * cos(s2) / dn
            let rr = 1.1 + 1.6 * (Double(i2) / 72)
            gl.fill(Path(ellipseIn: CGRect(x: lx - rr, y: ly - rr, width: rr * 2, height: rr * 2)),
                    with: .color(col([240, 230, 255], (0.28 + 0.66 * Double(i2) / 72) * p)))
        }
    }

    // ashrey — where the threads meet. Nine nodes each in its own frequency, every
    // relation drawn as a gradient edge, over the field's thirteen-circle lattice;
    // each node also sends a curved thread inward carrying two travelling particles,
    // and the centre is the synthesis ember — what holding all the relations costs.
    private func drawAshrey(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30, N = 9, R = 134 * e, p = progress
        dust(ctx, W, H, t * 0.3, 34, 0.07 * p)
        var node: [(x: Double, y: Double, c: [Double])] = []
        for i in 0..<N {
            let ang = Double(i) / Double(N) * Double.pi * 2 - Double.pi / 2 + t * 0.03
            node.append((cx + cos(ang) * R, cy + sin(ang) * R, Self.PALETTE[i]))
        }
        // the thirteen circles under it all — the field's own lattice
        let HEX: [[Double]] = [[0, 0], [1, 0], [0.5, 0.866], [-0.5, 0.866], [-1, 0], [-0.5, -0.866], [0.5, -0.866],
                               [1.5, 0.866], [0, 1.732], [-1.5, 0.866], [-1.5, -0.866], [0, -1.732], [1.5, -0.866]]
        for h in HEX {
            ctx.stroke(ringPath(cx + h[0] * R * 0.5, cy + h[1] * R * 0.5, R * 0.5),
                       with: .color(c.opacity(0.075 * p)), lineWidth: 1)
        }
        // every relation
        for a in 0..<N {
            for b in (a + 1)..<N {
                var path = Path()
                path.move(to: CGPoint(x: node[a].x, y: node[a].y))
                path.addLine(to: CGPoint(x: node[b].x, y: node[b].y))
                ctx.stroke(path, with: .linearGradient(
                    Gradient(colors: [col(node[a].c, 0.22 * p), col(node[b].c, 0.22 * p)]),
                    startPoint: CGPoint(x: node[a].x, y: node[a].y), endPoint: CGPoint(x: node[b].x, y: node[b].y)),
                    lineWidth: 1)
            }
        }
        // and what each one sends inward
        for i3 in 0..<N {
            let ex = cx + (node[i3].x - cx) * 1.9, ey = cy + (node[i3].y - cy) * 1.9
            let c1x = cx + (node[i3].x - cx) * 1.1 + cos(Double(i3)) * 70
            let c1y = cy + (node[i3].y - cy) * 1.1 + sin(Double(i3)) * 70
            var q = Path()
            q.move(to: CGPoint(x: ex, y: ey))
            q.addQuadCurve(to: CGPoint(x: cx, y: cy), control: CGPoint(x: c1x, y: c1y))
            ctx.stroke(q, with: .color(col(node[i3].c, 0.22 * p)), lineWidth: 1.2)
            for dsend in 0..<2 {
                let tp = ((t * 0.38) + Double(i3) / Double(N) + Double(dsend) / 2).truncatingRemainder(dividingBy: 1)
                let lx = qbez(ex, c1x, cx, tp), ly = qbez(ey, c1y, cy, tp)
                ctx.fill(Path(ellipseIn: CGRect(x: lx - 2.4, y: ly - 2.4, width: 4.8, height: 4.8)), with: .color(col(node[i3].c, 0.9 * p)))
                ctx.fill(Path(ellipseIn: CGRect(x: lx - 7, y: ly - 7, width: 14, height: 14)), with: .color(col(node[i3].c, 0.16 * p)))
            }
            let nr = 2.6 + bt(t + Double(i3)) * 1.6
            ctx.fill(Path(ellipseIn: CGRect(x: node[i3].x - nr, y: node[i3].y - nr, width: nr * 2, height: nr * 2)),
                     with: .color(col(node[i3].c, 0.85 * p)))
        }
        // the synthesis ember
        let b2 = bt(t), Rr = (9 + b2 * 5) * e
        ctx.fill(ringPath(cx, cy, Rr * 4.6), with: .radialGradient(
            Gradient(stops: [
                .init(color: Color(.sRGB, red: 226 / 255, green: 1, blue: 250 / 255, opacity: 0.95 * p), location: 0),
                .init(color: c.opacity(0.45 * p), location: 0.4),
                .init(color: c.opacity(0), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: Rr * 4.6))
        ctx.fill(ringPath(cx, cy, Rr), with: .color(Color(.sRGB, red: 232 / 255, green: 1, blue: 252 / 255, opacity: p)))
    }
}
