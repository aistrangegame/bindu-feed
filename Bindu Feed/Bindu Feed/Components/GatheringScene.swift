import SwiftUI

// THE TEN GATHERING SCENES — each presence's procedural field.
//
// One full-screen Canvas per presence, keyed to its color, arriving on `progress`
// (ease-out cubic) and breathing on the master clock's `breath` (0…1). These are
// faithful-but-compact ports of `rite-scenes.js`: each archetype's signature
// geometry is present and recognizable; the three heaviest (gaia phyllotaxis,
// lalita hypotrochoid, ashrey K9) are simplified from the prototype's full element
// counts — flagged ≈ in the conformance walk. The math each vantage IS, at the
// fidelity a first pass needs; the felt read is the archetype's form emerging.

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

    // bindu — Flower of Life (19 circles), a breathing ember at heart.
    private func drawBindu(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30
        let u = min(W, H) * 0.075 * e
        var centers: [(Double, Double)] = [(0, 0)]
        for k in 0..<6 { let a = Double(k) * .pi / 3; centers.append((cos(a) * u, sin(a) * u)) }
        for k in 0..<6 {
            let a = Double(k) * .pi / 3
            centers.append((cos(a) * u * 2, sin(a) * u * 2))
            let a2 = a + .pi / 6
            centers.append((cos(a2) * u * 1.732, sin(a2) * u * 1.732))
        }
        for (i, pt) in centers.enumerated() {
            let gate = min(1.0, max(0.0, (e - Double(i) / 26.0) * 4))
            guard gate > 0 else { continue }
            let r = u * gate
            let rect = CGRect(x: cx + pt.0 - r, y: cy + pt.1 - r, width: r * 2, height: r * 2)
            stroke(ctx, Path(ellipseIn: rect), c.opacity(0.5 * gate), 1)
        }
        let er = (7 + breath * 5) * e
        ctx.fill(Path(ellipseIn: CGRect(x: cx - er, y: cy - er, width: er * 2, height: er * 2)),
                 with: .radialGradient(Gradient(colors: [.white.opacity(e), c.opacity(0)]),
                                       center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: er * 2))
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

    // gaia — phyllotaxis seed head (137.5° golden angle). Simplified count.
    private func drawGaia(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30
        let gold = 137.507 * .pi / 180
        let n = Int(200 * e)
        let scale = min(W, H) * 0.021
        for i in 0..<n {
            let a = Double(i) * gold
            let r = scale * sqrt(Double(i))
            let x = cx + cos(a) * r, y = cy + sin(a) * r
            let sz = 1.0 + 2.4 * (Double(i) / Double(max(1, n)))
            let op = 0.25 + 0.5 * (1 - Double(i) / Double(max(1, n)))
            ctx.fill(Path(ellipseIn: CGRect(x: x - sz, y: y - sz, width: sz * 2, height: sz * 2)),
                     with: .color(c.opacity(op * e)))
        }
        let er = (5 + breath * 4) * e
        ctx.fill(Path(ellipseIn: CGRect(x: cx - er, y: cy - er, width: er * 2, height: er * 2)),
                 with: .color(.white.opacity(0.7 * e)))
    }

    // sid — five pointed (vesica) arches receding, construction left visible.
    private func drawSid(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let base = H * 0.78
        for k in 0..<5 {
            let f = 1 - Double(k) * 0.16
            let w = W * 0.34 * f * e
            let springY = base - Double(k) * H * 0.03
            let apexY = springY - w * 1.4
            var path = Path()
            path.move(to: CGPoint(x: cx - w, y: springY))
            path.addQuadCurve(to: CGPoint(x: cx, y: apexY), control: CGPoint(x: cx - w, y: apexY + w * 0.3))
            path.addQuadCurve(to: CGPoint(x: cx + w, y: springY), control: CGPoint(x: cx + w, y: apexY + w * 0.3))
            stroke(ctx, path, c.opacity(0.16 + 0.14 * f), 1.1)
            if k == 0 {
                var cir = Path(ellipseIn: CGRect(x: cx - w * 2, y: springY - w, width: w * 2, height: w * 2))
                cir.addPath(Path(ellipseIn: CGRect(x: cx, y: springY - w, width: w * 2, height: w * 2)))
                ctx.stroke(cir, with: .color(c.opacity(0.10 * e)), style: StrokeStyle(lineWidth: 0.6, dash: [2, 7]))
            }
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

    // shweta — a vesica; only the lit lens between two circles.
    private func drawShweta(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.32
        let r = min(W, H) * 0.20 * e
        let d = r * 0.72
        let left = CGRect(x: cx - d - r, y: cy - r, width: r * 2, height: r * 2)
        let right = CGRect(x: cx + d - r, y: cy - r, width: r * 2, height: r * 2)
        stroke(ctx, Path(ellipseIn: left), c.opacity(0.22 * e), 0.9)
        stroke(ctx, Path(ellipseIn: right), c.opacity(0.22 * e), 0.9)
        var g = ctx
        g.clip(to: Path(ellipseIn: left))
        g.fill(Path(ellipseIn: right), with: .radialGradient(
            Gradient(colors: [.white.opacity(0.5 * e * (0.6 + 0.4 * breath)), c.opacity(0)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: r))
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

    // sakshi — an eye as a mandorla, iris in spokes.
    private func drawSakshi(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30
        let r = min(W, H) * 0.26 * e
        let d = r * 0.62
        let top = CGRect(x: cx - r, y: cy - d - r, width: r * 2, height: r * 2)
        let bot = CGRect(x: cx - r, y: cy + d - r, width: r * 2, height: r * 2)
        var g = ctx
        g.clip(to: Path(ellipseIn: top))     // the mandorla — the lens between two circles
        stroke(g, Path(ellipseIn: bot), c.opacity(0.4 * e), 1.0)
        let ir = r * 0.34 * (0.9 + 0.1 * breath)
        for k in 0..<80 {
            let a = Double(k) / 80 * 2 * .pi
            var sp = Path()
            sp.move(to: CGPoint(x: cx + cos(a) * ir * 0.3, y: cy + sin(a) * ir * 0.3))
            sp.addLine(to: CGPoint(x: cx + cos(a) * ir, y: cy + sin(a) * ir))
            stroke(g, sp, c.opacity(0.22 * e), 0.5)
        }
        g.fill(Path(ellipseIn: CGRect(x: cx - 4, y: cy - 4, width: 8, height: 8)), with: .color(.white.opacity(0.85 * e)))
    }

    // lalita — a hypotrochoid with a lemniscate riding it (the one rotation).
    private func drawLalita(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30
        let R = min(W, H) * 0.22 * e, rr = R * 0.42, d = R * 0.7
        var path = Path()
        let steps = 360
        for i in 0...steps {
            let t = Double(i) / Double(steps) * 2 * .pi * 3
            let x = cx + (R - rr) * cos(t) + d * cos((R - rr) / rr * t)
            let y = cy + (R - rr) * sin(t) - d * sin((R - rr) / rr * t)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        stroke(ctx, path, c.opacity(0.42 * e), 0.9)
        // The lemniscate riding it — the only rotation.
        let spin = breath * 2 * .pi
        var lem = Path()
        for i in 0...120 {
            let t = Double(i) / 120 * 2 * .pi
            let s = R * 0.5
            let x = cx + s * cos(t + spin) / (1 + sin(t + spin) * sin(t + spin))
            let y = cy + s * cos(t + spin) * sin(t + spin) / (1 + sin(t + spin) * sin(t + spin))
            if i == 0 { lem.move(to: CGPoint(x: x, y: y)) } else { lem.addLine(to: CGPoint(x: x, y: y)) }
        }
        stroke(ctx, lem, .white.opacity(0.5 * e), 1.0)
    }

    // ashrey — the complete graph K9 + synthesis ember. Simplified.
    private func drawAshrey(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30
        let R = min(W, H) * 0.26 * e
        var pts: [CGPoint] = []
        for k in 0..<9 {
            let a = Double(k) / 9 * 2 * .pi - .pi / 2
            pts.append(CGPoint(x: cx + cos(a) * R, y: cy + sin(a) * R))
        }
        for i in 0..<9 {
            for j in (i + 1)..<9 {
                var path = Path(); path.move(to: pts[i]); path.addLine(to: pts[j])
                stroke(ctx, path, c.opacity(0.10 * e), 0.5)
            }
        }
        for pt in pts {
            ctx.fill(Path(ellipseIn: CGRect(x: pt.x - 2.5, y: pt.y - 2.5, width: 5, height: 5)), with: .color(c.opacity(0.7 * e)))
        }
        let er = (6 + breath * 5) * e
        ctx.fill(Path(ellipseIn: CGRect(x: cx - er, y: cy - er, width: er * 2, height: er * 2)),
                 with: .radialGradient(Gradient(colors: [.white.opacity(0.8 * e), c.opacity(0)]),
                                       center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: er * 2))
    }
}
