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

    // neev — a hex-packed floor receding to a low horizon, a monolith rising.
    private func drawNeev(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let surf = H * 0.24, vpY = H * 1.2
        for row in 0..<14 {
            let f = Double(row) / 14
            let y = surf + (H - surf) * pow(f, 1.7) * e
            var path = Path(); path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: W, y: y))
            stroke(ctx, path, c.opacity(0.10 + 0.14 * (1 - f)), 0.6)
        }
        for k in stride(from: -6, through: 6, by: 1) {
            let x0 = cx + Double(k) * W * 0.11
            var path = Path(); path.move(to: CGPoint(x: x0, y: surf))
            path.addLine(to: CGPoint(x: cx + (x0 - cx) * 3.4, y: vpY))
            stroke(ctx, path, c.opacity(0.10 * e), 0.6)
        }
        let mw = W * 0.14 * e, mh = H * 0.30 * e
        let mono = CGRect(x: cx - mw / 2, y: surf - mh + 6, width: mw, height: mh)
        ctx.fill(Path(mono), with: .linearGradient(
            Gradient(colors: [c.opacity(0.28 * e), c.opacity(0.06 * e)]),
            startPoint: CGPoint(x: cx, y: surf - mh), endPoint: CGPoint(x: cx, y: surf)))
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
    private func drawArch(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let cy = H * 0.30
        let R = min(W, H) * 0.34 * e
        let m = Int((6 + breath * 6).rounded())
        for ring in 1...4 {
            let rr = R * Double(ring) / 4
            stroke(ctx, Path(ellipseIn: CGRect(x: cx - rr, y: cy - rr, width: rr * 2, height: rr * 2)),
                   c.opacity(0.18 * e), 0.8)
        }
        for k in 0..<(m * 2) {
            let a = Double(k) * .pi / Double(m)
            var path = Path()
            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx + cos(a) * R, y: cy + sin(a) * R))
            stroke(ctx, path, c.opacity(0.16 * e), 0.7)
        }
        let er = (6 + breath * 4) * e
        ctx.fill(Path(ellipseIn: CGRect(x: cx - er, y: cy - er, width: er * 2, height: er * 2)),
                 with: .color(.white.opacity(0.6 * e)))
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
    private func drawKarishma(_ ctx: GraphicsContext, _ W: Double, _ H: Double, _ cx: Double, _ e: Double, _ c: Color) {
        let sy = -H * 0.12, cy = H * 0.34
        let sunR = W * 0.5
        ctx.fill(Path(ellipseIn: CGRect(x: cx - sunR, y: sy - sunR, width: sunR * 2, height: sunR * 2)),
                 with: .radialGradient(Gradient(colors: [c.opacity(0.16 * e), c.opacity(0)]),
                                       center: CGPoint(x: cx, y: sy), startRadius: 0, endRadius: sunR))
        var path = Path()
        let turns = 3.2, steps = 220
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let a = t * turns * 2 * .pi
            let r = min(W, H) * 0.03 * pow(1.16, a) * e
            let x = cx + cos(a) * r, y = cy + sin(a) * r
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        stroke(ctx, path, c.opacity(0.5 * e), 1.2)
        let rid = breath
        let a = rid * turns * 2 * .pi
        let r = min(W, H) * 0.03 * pow(1.16, a) * e
        let bx = cx + cos(a) * r, by = cy + sin(a) * r
        ctx.fill(Path(ellipseIn: CGRect(x: bx - 4, y: by - 4, width: 8, height: 8)), with: .color(.white.opacity(0.9 * e)))
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
