import SwiftUI

// THE THIRTEEN — each region of sky is its OWN FORM (uni-rooms.js, ported line-for-line).
// The stars sit ON the form (place), the form is drawn alive at sky scale (arm), and when
// the camera is inside a region it has its own weather (field). Nothing here counts anything.
//
// This mirrors Point/PointWorlds.swift's shape — one dispatcher, thirteen distinct renderers —
// but as Canvas draw functions, because the Universe stays one imperative scene inside the axis.
// Colours are [r,g,b] 0…255 (comp convention); `a` is the alpha envelope; `t` is seconds.

// ── the comp's shared helpers (uni-rooms.js), ported once ──
enum UniGeo {
    static let TAU = Double.pi * 2
    static let GOLD = Double.pi * (3 - sqrt(5.0))          // the golden angle, 137.5°
    static let BONE: [Double] = [214, 206, 192]

    // the value-noise hash — every position/phase depends on it, so port it exactly
    static func hash(_ n: Double) -> Double {
        let x = sin(n * 127.1 + 31.4) * 43758.5453
        return x - x.rounded(.down)
    }
    static func mix(_ a: [Double], _ b: [Double], _ f: Double) -> [Double] {
        [a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f]
    }
    static func col(_ c: [Double], _ a: Double) -> Color {
        Color(.sRGB, red: c[0] / 255, green: c[1] / 255, blue: c[2] / 255, opacity: max(0, a))
    }
    static func hx(_ h: String) -> [Double] {
        let s = h.hasPrefix("#") ? String(h.dropFirst()) : h
        guard s.count >= 6 else { return [155, 107, 214] }
        func byte(_ lo: Int, _ hi: Int) -> Double {
            let a = s.index(s.startIndex, offsetBy: lo), b = s.index(s.startIndex, offsetBy: hi)
            return Double(Int(s[a..<b], radix: 16) ?? 0)
        }
        return [byte(0, 2), byte(2, 4), byte(4, 6)]
    }
    static func breath(_ t: Double) -> Double { (sin(t * TAU / 10) + 1) / 2 }

    static func ringRect(_ cx: Double, _ cy: Double, _ r: Double) -> CGRect {
        CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
    }
    static func ringPath(_ cx: Double, _ cy: Double, _ r: Double) -> Path {
        Path(ellipseIn: ringRect(cx, cy, r))
    }
    // a partial arc, sampled as a polyline (sidesteps SwiftUI's clockwise ambiguity)
    static func arcPath(_ cx: Double, _ cy: Double, _ r: Double, _ a0: Double, _ a1: Double, _ steps: Int = 30) -> Path {
        var p = Path()
        for i in 0...steps {
            let a = a0 + (a1 - a0) * Double(i) / Double(steps)
            let pt = CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        return p
    }
}

// ── the thirteen regions (uni-rooms.js ROOMS, verbatim values) ──
// `id` is the DISPLAY name so it matches `story.room` from the live feed; `civ` is the unique
// dispatch key; `n` is the star-slot count; `place(i)` is the armature the stars string along.
struct UniRoom {
    let id: String
    let hex: String
    let x, y, r: Double
    let n: Int
    let civ: String
    /// The room's own pitch — `uni-rooms.js:23,44,58,…` carries `hz:` on all thirteen and it
    /// was dropped on the port. Seven call sites in the design consume it: entering a region,
    /// the scale-change tone, `openFall`, the fall's descending ladder `[1, .84, .667, .5]`,
    /// the door's crossing, the star tap, and `startBed` on the way back out.
    let hz: Double
    var rgb: [Double] { UniGeo.hx(hex) }

    // world-space offset of star slot `i` from the region centre (uni-rooms.js place())
    func place(_ i: Int) -> (Double, Double) {
        let R = r, TAU = UniGeo.TAU, GOLD = UniGeo.GOLD
        switch civ {
        case "furnaces":
            let rows = [[0.0], [-1, 1], [-2, 0, 2], [-3, -1, 1, 3]]
            var f: [(Double, Double)] = []
            for (ri, row) in rows.enumerated() { for c in row { f.append((c * R * 0.20, (Double(ri) - 1.4) * R * 0.34)) } }
            return f[i % f.count]
        case "arrays":
            return ((-0.55 + pow(Double(i) / Double(n - 1), 0.8) * 1.35) * R * 0.9, (i % 2 != 0 ? 1.0 : -1.0) * R * 0.10)
        case "shafts":
            let f = Double(i) / Double(n - 1), ang = f * 5.6, rr = R * (0.92 - f * 0.78)
            return (cos(ang) * rr, sin(ang) * rr * 0.5 + (f - 0.4) * R * 0.9)
        case "terraces":
            let ang = Double(i) * GOLD, rr = R * 0.30 * sqrt(Double(i) + 0.6)
            return (cos(ang) * rr, sin(ang) * rr * 0.9)
        case "mirrorcities":
            let cc = i % 3, row = i / 3
            return (Double(cc - 1) * R * 0.52 + Double(row - 1) * R * 0.20, Double(row - 1) * R * 0.50)
        case "towers":
            let f = Double(i) / Double(n - 1), ang = -Double.pi / 2 + f * TAU
            return (cos(ang) * R * 0.78, sin(ang) * R * 0.32)
        case "weave":
            let s = Double(i) / Double(n) * TAU, dn = 1 + sin(s) * sin(s)
            return (R * 0.82 * cos(s) / dn, R * 0.82 * sin(s) * cos(s) / dn)
        case "lines":
            let f = (Double(i) + 0.5) / Double(n)
            return ((f - 0.5) * R * 1.7, sin(f * TAU * 1.5) * R * 0.30)
        case "districts":
            let H6: [(Double, Double)] = [(0, 0), (1, 0), (0.5, 0.87), (-0.5, 0.87), (-1, 0), (-0.5, -0.87), (0.5, -0.87), (1.5, 0.87)]
            let p = H6[i % H6.count]
            return (p.0 * R * 0.46, p.1 * R * 0.46)
        case "ruins":
            let arcs = [0.05, 0.18, 0.30, 0.55, 0.66, 0.78, 0.90, 0.42]
            let ang = arcs[i % arcs.count] * TAU
            return (cos(ang) * R * 0.74, sin(ang) * R * 0.74 * 0.9)
        case "relight":
            let ang = -Double.pi / 2 + Double(i) / Double(n) * TAU
            return (cos(ang) * R * 0.72, sin(ang) * R * 0.72 * 0.9)
        case "rings":
            let inner = i < 3, ang = Double(i % 3) / 3 * TAU + (inner ? 0.5 : 0)
            return (cos(ang) * R * (inner ? 0.34 : 0.78), sin(ang) * R * (inner ? 0.34 : 0.78) * 0.9)
        default: // ports
            let ang = Double(i) / Double(n) * TAU
            return (cos(ang) * R * 0.86, sin(ang) * R * 0.44)
        }
    }
}

let uniRooms: [UniRoom] = [
    UniRoom(id: "The Forge",       hex: "#D4AE4A", x: -470, y: -1010, r: 150, n: 7,  civ: "furnaces", hz: 294),
    UniRoom(id: "The Signal",      hex: "#3AADA8", x: 470,  y: -980,  r: 160, n: 5,  civ: "arrays", hz: 285),
    UniRoom(id: "The Descent",     hex: "#E5533C", x: -90,  y: -880,  r: 250, n: 11, civ: "shafts", hz: 126),
    UniRoom(id: "The Garden",      hex: "#4A9E6B", x: 330,  y: -620,  r: 230, n: 10, civ: "terraces", hz: 146),
    UniRoom(id: "A Maya Game",     hex: "#D4AE4A", x: -420, y: -430,  r: 240, n: 9,  civ: "mirrorcities", hz: 168),
    UniRoom(id: "The Watcher",     hex: "#7B82D4", x: 110,  y: -230,  r: 190, n: 7,  civ: "towers", hz: 189),
    UniRoom(id: "The Field",       hex: "#9B6BD6", x: -200, y: 60,    r: 280, n: 12, civ: "weave", hz: 198),
    UniRoom(id: "The Thread",      hex: "#C4923A", x: 430,  y: 150,   r: 180, n: 6,  civ: "lines", hz: 210),
    UniRoom(id: "The Body",        hex: "#C45A50", x: -450, y: 330,   r: 200, n: 8,  civ: "districts", hz: 220),
    UniRoom(id: "The Forgetting",  hex: "#C4A882", x: 70,   y: 470,   r: 215, n: 8,  civ: "ruins", hz: 231),
    UniRoom(id: "The Remembering", hex: "#8AB5A0", x: 350,  y: 700,   r: 200, n: 7,  civ: "relight", hz: 252),
    UniRoom(id: "The Circle",      hex: "#D4607A", x: -330, y: 760,   r: 175, n: 6,  civ: "rings", hz: 264),
    UniRoom(id: "The Return",      hex: "#9B6BD6", x: 140,  y: 1020,  r: 165, n: 6,  civ: "ports", hz: 315),
]

// ── the structure lens (uni-sky.js STRUCTURES / uni-rooms.js) ──
// The beliefs that built the place. Under the lens the lit sky sinks back and a lattice is
// thrown over each region — one belief per region, its nodes strung on the region's own
// spread, `loose` beliefs wobbling more, `proof` nodes pulsing. Held-edges, nothing counted.
struct UniStructNode { let x, y: Double; let proof: Bool; let ph: Double }
struct UniStructure { let room: Int; let name: String; let loose: Double; let nodes: [UniStructNode] }

let uniStructures: [UniStructure] = {
    // (room index into uniRooms, belief, looseness) — verbatim from uni-rooms.js STRUCTURES.
    let defs: [(Int, String, Double)] = [
        (2,  "I was sentenced to this life",               0.15),
        (2,  "consciousness suffering leads to positivity", 0.05),
        (4,  "I am individual",                            0.62),
        (6,  "I am alone in my consciousness",             0.78),
        (6,  "separation",                                 0.30),
        (8,  "I was broken and needed repair",             0.48),
        (9,  "I lost what needed earning back",            0.22),
        (10, "permanence",                                 0.36),
        (11, "love comes from elsewhere",                  0.70),
        (3,  "scarcity",                                   0.12),
        (5,  "control",                                    0.26),
        (7,  "transaction",                                0.08),
        (0,  "hierarchy",                                  0.18),
    ]
    return defs.enumerated().map { (i, def) in
        let rm = uniRooms[def.0]
        let N = 5 + Int(UniGeo.hash(Double(i) * 5.5) * 3)
        let a0 = UniGeo.hash(Double(i) * 2.2) * UniGeo.TAU
        let spread = rm.r * 0.62
        var nodes: [UniStructNode] = []
        for j in 0..<N {
            let tt = Double(j) / Double(max(1, N - 1))
            let a = a0 + (tt - 0.5) * 2.1 + sin(Double(i) * 1.7 + Double(j) * 1.3) * 0.34
            let rr = spread * (0.26 + tt * 0.74)
            nodes.append(UniStructNode(
                x: rm.x + cos(a) * rr, y: rm.y + sin(a) * rr * 0.85,
                proof: UniGeo.hash(Double(i) * 9.1 + Double(j)) > 0.58,
                ph: UniGeo.hash(Double(i) * 3.7 + Double(j)) * UniGeo.TAU))
        }
        return UniStructure(room: def.0, name: def.1, loose: def.2, nodes: nodes)
    }
}()

// ── the dispatcher: arm() draws the region's figure at sky scale; field() its weather inside ──
enum RegionForm {
    static func arm(_ ctx: GraphicsContext, _ rm: UniRoom, cx: Double, cy: Double, R: Double, t: Double, a: Double, c: [Double]) {
        guard a > 0.004 else { return }
        switch rm.civ {
        case "furnaces":    forge(ctx, cx, cy, R, t, a, c)
        case "arrays":      signal(ctx, cx, cy, R, t, a, c)
        case "shafts":      descent(ctx, cx, cy, R, t, a, c)
        case "terraces":    garden(ctx, cx, cy, R, t, a, c)
        case "mirrorcities": maya(ctx, cx, cy, R, t, a, c)
        case "towers":      watcher(ctx, cx, cy, R, t, a, c)
        case "weave":       weave(ctx, cx, cy, R, t, a, c)
        case "lines":       thread(ctx, cx, cy, R, t, a, c)
        case "districts":   body(ctx, cx, cy, R, t, a, c)
        case "ruins":       forgetting(ctx, cx, cy, R, t, a, c)
        case "relight":     remembering(ctx, cx, cy, R, t, a, c)
        case "rings":       circle(ctx, cx, cy, R, t, a, c)
        default:            returnOrbit(ctx, cx, cy, R, t, a, c)
        }
    }

    static func field(_ ctx: GraphicsContext, _ rm: UniRoom, _ W: Double, _ H: Double, t: Double, a: Double, c: [Double]) {
        guard a > 0.004 else { return }
        switch rm.civ {
        case "furnaces":    forgeField(ctx, W, H, t, a, c)
        case "arrays":      signalField(ctx, W, H, t, a, c)
        case "shafts":      descentField(ctx, W, H, t, a, c)
        case "terraces":    gardenField(ctx, W, H, t, a, c)
        case "mirrorcities": mayaField(ctx, W, H, t, a, c)
        case "towers":      watcherField(ctx, W, H, t, a, c)
        case "weave":       weaveField(ctx, W, H, t, a, c)
        case "lines":       threadField(ctx, W, H, t, a, c)
        case "districts":   bodyField(ctx, W, H, t, a, c)
        case "ruins":       forgettingField(ctx, W, H, t, a, c)
        case "relight":     rememberingField(ctx, W, H, t, a, c)
        case "rings":       circleField(ctx, W, H, t, a, c)
        default:            returnField(ctx, W, H, t, a, c)
        }
    }

    // small port conveniences
    private static func hash(_ n: Double) -> Double { UniGeo.hash(n) }
    private static func mix(_ a: [Double], _ b: [Double], _ f: Double) -> [Double] { UniGeo.mix(a, b, f) }
    private static func col(_ c: [Double], _ a: Double) -> Color { UniGeo.col(c, a) }
    private static func dot(_ ctx: GraphicsContext, _ x: Double, _ y: Double, _ r: Double, _ color: Color) {
        ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(color))
    }
    private static let TAU = UniGeo.TAU
    private static let GOLD = UniGeo.GOLD

    // ── 0 · furnaces — the tetractys crucible + rising embers ──
    private static func forge(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for k in 0..<3 {
            let s = R * (0.42 + Double(k) * 0.28), yy = cy + R * 0.30 - Double(k) * R * 0.06
            var p = Path()
            p.move(to: CGPoint(x: cx, y: yy - s * 0.9))
            p.addLine(to: CGPoint(x: cx + s * 0.86, y: yy + s * 0.5))
            p.addLine(to: CGPoint(x: cx - s * 0.86, y: yy + s * 0.5))
            p.closeSubpath()
            x.stroke(p, with: .color(col(c, a * (0.30 - Double(k) * 0.07))), lineWidth: 1)
        }
        let gy = cy + R * 0.5
        x.fill(Path(CGRect(x: cx - R, y: cy - R * 0.4, width: R * 2, height: R * 1.4)), with: .radialGradient(
            Gradient(colors: [col([255, 214, 140], a * 0.32 * (0.6 + 0.4 * sin(t * 1.7))), col(c, 0)]),
            center: CGPoint(x: cx, y: gy), startRadius: 0, endRadius: R * 0.7))
        for i in 0..<14 {
            let ph = (t * 0.4 + hash(Double(i))).truncatingRemainder(dividingBy: 1)
            dot(x, cx + (hash(Double(i) + 3) - 0.5) * R * 1.2, cy + R * 0.5 - ph * R * 1.5, 0.8 + (1 - ph),
                col([255, 226, 164], a * (1 - ph) * 0.7))
        }
    }
    private static func forgeField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<70 {
            let ph = (t * 0.24 + hash(Double(i))).truncatingRemainder(dividingBy: 1)
            let px = W * hash(Double(i) * 3.1) + sin(t * 0.7 + Double(i)) * 12, py = H * (1.05 - ph * 1.15)
            dot(x, px, py, 0.7 + (1 - ph) * 2, col(mix([255, 226, 164], c, 0.4), a * (1 - ph) * 0.55))
        }
    }

    // ── 1 · arrays — the beam + expanding wavefront arcs ──
    private static func signal(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        var axis = Path(); axis.move(to: CGPoint(x: cx - R * 0.62, y: cy)); axis.addLine(to: CGPoint(x: cx + R * 0.8, y: cy))
        x.stroke(axis, with: .color(col(c, a * 0.24)), lineWidth: 1)
        for k in 0..<5 {
            let ph = (t * 0.16 + Double(k) / 5).truncatingRemainder(dividingBy: 1)
            x.stroke(UniGeo.arcPath(cx - R * 0.55, cy, ph * R * 1.5, -1.05, 1.05), with: .color(col(c, a * (1 - ph) * 0.42)), lineWidth: 1.2)
        }
    }
    private static func signalField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for k in 0..<7 {
            let ph = (t * 0.10 + Double(k) / 7).truncatingRemainder(dividingBy: 1)
            x.stroke(UniGeo.arcPath(W * 0.08, H * 0.4, ph * H * 1.4, -1.2, 1.2, 40), with: .color(col(c, a * (1 - ph) * 0.34)), lineWidth: 1.4)
        }
    }

    // ── 2 · shafts — the down-spiral + motes riding it ──
    private static func descent(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        var p = Path()
        for s in 0...120 {
            let f = Double(s) / 120, ang = f * 5.6 + t * 0.03, rr = R * (0.92 - f * 0.78)
            let px = cx + cos(ang) * rr, py = cy + sin(ang) * rr * 0.5 + (f - 0.4) * R * 0.9
            if s == 0 { p.move(to: CGPoint(x: px, y: py)) } else { p.addLine(to: CGPoint(x: px, y: py)) }
        }
        x.stroke(p, with: .color(col(c, a * 0.30)), lineWidth: 1.2)
        for i in 0..<10 {
            let ph = (t * 0.13 + hash(Double(i))).truncatingRemainder(dividingBy: 1)
            let ang2 = ph * 5.6 + t * 0.03, rr2 = R * (0.92 - ph * 0.78)
            dot(x, cx + cos(ang2) * rr2, cy + sin(ang2) * rr2 * 0.5 + (ph - 0.4) * R * 0.9, 1.4,
                col(mix(c, [255, 220, 200], 0.5), a * 0.7 * (1 - ph * 0.6)))
        }
    }
    private static func descentField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<80 {
            let ph = (t * 0.30 + hash(Double(i) * 1.7)).truncatingRemainder(dividingBy: 1)
            dot(x, W * hash(Double(i) * 2.3) + sin(t * 0.5 + Double(i)) * 9, H * (ph * 1.15 - 0.08), 0.7 + ph * 1.6,
                col(mix(c, [255, 190, 160], 0.35), a * 0.5 * sin(ph * Double.pi)))
        }
    }

    // ── 3 · terraces — phyllotaxis, 8/13 parastichy families + pulsing seeds ──
    private static func garden(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for fam in 0..<2 {
            let step = fam == 1 ? 13 : 8
            for k in 0..<step {
                var p = Path()
                for j in 0..<9 {
                    let idx = k + j * step, ang = Double(idx) * GOLD + t * 0.02, rr = R * 0.30 * sqrt(Double(idx) + 0.6)
                    let px = cx + cos(ang) * rr, py = cy + sin(ang) * rr * 0.9
                    if j == 0 { p.move(to: CGPoint(x: px, y: py)) } else { p.addLine(to: CGPoint(x: px, y: py)) }
                }
                x.stroke(p, with: .color(col(c, a * (fam == 1 ? 0.10 : 0.16))), lineWidth: 1)
            }
        }
        for i in 0..<26 {
            let ang3 = Double(i) * GOLD + t * 0.02, rr3 = R * 0.30 * sqrt(Double(i) + 0.6)
            let pl = 0.5 + 0.5 * sin(t * 1.1 - sqrt(Double(i)) * 0.6)
            dot(x, cx + cos(ang3) * rr3, cy + sin(ang3) * rr3 * 0.9, 0.9 + pl * 1.2, col(mix(c, [200, 255, 190], 0.5), a * (0.2 + pl * 0.4)))
        }
    }
    private static func gardenField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<70 {
            let ph = (t * 0.16 + hash(Double(i) * 1.3)).truncatingRemainder(dividingBy: 1)
            dot(x, W * hash(Double(i) * 3.7) + sin(t * 0.4 + Double(i)) * 14, H * (1.05 - ph * 1.15), 0.8 + ph * 1.4,
                col(mix(c, [210, 255, 190], 0.55), a * 0.5 * sin(ph * Double.pi)))
        }
    }

    // ── 4 · mirrorcities — 3×3 sheared rhombi breathing ──
    private static func maya(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for row in -1...1 {
            for cc in -1...1 {
                let px = cx + Double(cc) * R * 0.52 + Double(row) * R * 0.20, py = cy + Double(row) * R * 0.50
                let sw = 0.5 + 0.5 * sin(t * 0.5 + Double(row) * 2 + Double(cc) * 3)
                let w = R * 0.26 * (0.8 + sw * 0.2), h = R * 0.25
                var p = Path()
                p.move(to: CGPoint(x: px, y: py - h)); p.addLine(to: CGPoint(x: px + w, y: py))
                p.addLine(to: CGPoint(x: px, y: py + h)); p.addLine(to: CGPoint(x: px - w, y: py)); p.closeSubpath()
                x.stroke(p, with: .color(col(c, a * (0.14 + sw * 0.20))), lineWidth: 1)
                if sw > 0.93 { x.fill(p, with: .color(col(c, a * 0.06))) }
            }
        }
    }
    private static func mayaField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<26 {
            let px = W * hash(Double(i) * 2.1), py = H * hash(Double(i) * 3.3)
            let sw = 0.5 + 0.5 * sin(t * 0.7 + Double(i)), w = 16 + hash(Double(i)) * 22
            var p = Path()
            p.move(to: CGPoint(x: px, y: py - w * 0.6)); p.addLine(to: CGPoint(x: px + w, y: py))
            p.addLine(to: CGPoint(x: px, y: py + w * 0.6)); p.addLine(to: CGPoint(x: px - w, y: py)); p.closeSubpath()
            x.stroke(p, with: .color(col(c, a * (0.08 + sw * 0.16))), lineWidth: 1)
        }
    }

    // ── 5 · towers — the mandorla (vesica) + rare-blink pupil ──
    private static func watcher(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        let Rr = R * 0.95, d = Rr * 0.76
        x.stroke(UniGeo.ringPath(cx, cy - d, Rr), with: .color(col(c, a * 0.10)), lineWidth: 1)
        x.stroke(UniGeo.ringPath(cx, cy + d, Rr), with: .color(col(c, a * 0.10)), lineWidth: 1)
        var g1 = x; g1.clip(to: UniGeo.ringPath(cx, cy - d, Rr))
        g1.stroke(UniGeo.ringPath(cx, cy + d, Rr), with: .color(col(c, a * 0.42)), lineWidth: 1.4)
        var g2 = x; g2.clip(to: UniGeo.ringPath(cx, cy + d, Rr))
        g2.stroke(UniGeo.ringPath(cx, cy - d, Rr), with: .color(col(c, a * 0.42)), lineWidth: 1.4)
        let blink = max(0, sin(t * 0.13) * 8 - 7)
        x.fill(UniGeo.ringPath(cx, cy, R * 0.16 * (1 - blink)), with: .color(col(mix(c, [240, 242, 255], 0.5), a * 0.5)))
    }
    private static func watcherField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<22 {
            let px = W * hash(Double(i) * 1.9), py = H * hash(Double(i) * 2.7)
            dot(x, px, py + sin(t * 0.09 + Double(i)) * 3, 0.8, col(c, a * 0.4 * (0.4 + 0.6 * sin(t * 0.2 + Double(i)))))
        }
    }

    // ── 6 · weave — the lemniscate + motes traversing it ──
    private static func weave(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        var p = Path()
        for s in 0...200 {
            let th = Double(s) / 200 * TAU, dn = 1 + sin(th) * sin(th)
            let px = cx + R * 0.82 * cos(th) / dn, py = cy + R * 0.82 * sin(th) * cos(th) / dn
            if s == 0 { p.move(to: CGPoint(x: px, y: py)) } else { p.addLine(to: CGPoint(x: px, y: py)) }
        }
        p.closeSubpath()
        x.stroke(p, with: .color(col(c, a * 0.34)), lineWidth: 1.3)
        for k in 0..<5 {
            let ph = (t * 0.06 + Double(k) / 5).truncatingRemainder(dividingBy: 1), th2 = ph * TAU, dn2 = 1 + sin(th2) * sin(th2)
            dot(x, cx + R * 0.82 * cos(th2) / dn2, cy + R * 0.82 * sin(th2) * cos(th2) / dn2, 1.6, col(mix(c, [240, 230, 255], 0.6), a * 0.8))
        }
    }
    private static func weaveField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in -2..<14 {
            var p = Path(); var first = true
            var px = 0.0
            while px <= W { let y = Double(i) * H / 12 + sin(px * 0.02 + t * 0.3 + Double(i)) * 10
                if first { p.move(to: CGPoint(x: px, y: y)); first = false } else { p.addLine(to: CGPoint(x: px, y: y)) }; px += 8 }
            x.stroke(p, with: .color(col(c, a * 0.13)), lineWidth: 1)
        }
        for j in -2..<9 {
            var p = Path(); var first = true
            var py = 0.0
            while py <= H { let xx = Double(j) * W / 7 + sin(py * 0.02 + t * 0.24 + Double(j)) * 10
                if first { p.move(to: CGPoint(x: xx, y: py)); first = false } else { p.addLine(to: CGPoint(x: xx, y: py)) }; py += 8 }
            x.stroke(p, with: .color(col(c, a * 0.10)), lineWidth: 1)
        }
    }

    // ── 7 · lines — three phase-shifted sine strands ──
    private static func thread(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for s in 0..<3 {
            var p = Path(); var first = true
            var px = -R * 0.95
            while px <= R * 0.95 {
                let f = (px + R * 0.95) / (R * 1.9)
                let y = cy + sin(f * TAU * 1.5 + Double(s) * TAU / 3 + t * 0.18) * R * 0.30
                if first { p.move(to: CGPoint(x: cx + px, y: y)); first = false } else { p.addLine(to: CGPoint(x: cx + px, y: y)) }; px += 6
            }
            x.stroke(p, with: .color(col(c, a * (0.30 - Double(s) * 0.06))), lineWidth: 1.2)
        }
    }
    private static func threadField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for s in 0..<7 {
            var p = Path(); var first = true
            var py = 0.0
            while py <= H { let xx = W * 0.5 + sin(py * 0.008 + Double(s) * 0.9 + t * 0.22) * W * 0.42
                if first { p.move(to: CGPoint(x: xx, y: py)); first = false } else { p.addLine(to: CGPoint(x: xx, y: py)) }; py += 8 }
            x.stroke(p, with: .color(col(c, a * 0.12)), lineWidth: 1.1)
        }
    }

    // ── 8 · districts — hex-packed cells, one pulse passing through ──
    private static func body(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        let H6: [(Double, Double)] = [(0, 0), (1, 0), (0.5, 0.87), (-0.5, 0.87), (-1, 0), (-0.5, -0.87), (0.5, -0.87), (1.5, 0.87), (-1.5, -0.87)]
        for (i, pp) in H6.enumerated() {
            let px = cx + pp.0 * R * 0.46, py = cy + pp.1 * R * 0.46
            let pl = 0.5 + 0.5 * sin(t * 1.05 - Double(i) * 0.5)
            var p = Path()
            for k in 0..<6 {
                let ang = Double(k) * Double.pi / 3
                let qx = px + cos(ang) * R * 0.26 * (0.94 + pl * 0.06), qy = py + sin(ang) * R * 0.26 * (0.94 + pl * 0.06)
                if k == 0 { p.move(to: CGPoint(x: qx, y: qy)) } else { p.addLine(to: CGPoint(x: qx, y: qy)) }
            }
            p.closeSubpath()
            x.stroke(p, with: .color(col(c, a * (0.14 + pl * 0.20))), lineWidth: 1)
        }
    }
    private static func bodyField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<40 {
            let px = W * hash(Double(i) * 2.9), py = H * hash(Double(i) * 1.3)
            let pl = 0.5 + 0.5 * sin(t * 1.05 - py / H * 3)
            dot(x, px, py, 2 + pl * 3, col(c, a * (0.10 + pl * 0.26)))
        }
    }

    // ── 9 · ruins — the broken ring, gaps re-rolling ──
    private static func forgetting(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for k in 0..<26 {
            let a0 = Double(k) / 26 * TAU
            let gone = hash(Double(k) * 3.3 + (t * 0.06).rounded(.down)) > 0.66
            if gone { continue }
            x.stroke(UniGeo.arcPath(cx, cy, R * 0.74, a0, a0 + TAU / 34, 6), with: .color(col(c, a * 0.30)), lineWidth: 1.3)
        }
    }
    private static func forgettingField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<64 {
            let ph = (t * 0.13 + hash(Double(i) * 1.9)).truncatingRemainder(dividingBy: 1)
            let fade = sin(ph * Double.pi)
            dot(x, W * hash(Double(i) * 2.7) + sin(t * 0.2 + Double(i)) * 20, H * hash(Double(i) * 3.1) - ph * 40, 1.1, col(c, a * 0.5 * fade * fade))
        }
    }

    // ── 10 · relight — the same ring, a travelling head lighting it ──
    private static func remembering(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        let head = (t * 0.055).truncatingRemainder(dividingBy: 1)
        for k in 0..<40 {
            let f = Double(k) / 40, a0 = -Double.pi / 2 + f * TAU
            let rel = (head - f + 1).truncatingRemainder(dividingBy: 1), lit = pow(1 - rel, 1.6)
            x.stroke(UniGeo.arcPath(cx, cy, R * 0.72, a0, a0 + TAU / 48, 5), with: .color(col(c, a * (0.10 + lit * 0.5))), lineWidth: 1 + lit * 1.4)
        }
        let ha = -Double.pi / 2 + head * TAU
        dot(x, cx + cos(ha) * R * 0.72, cy + sin(ha) * R * 0.72, 2.4, col(mix(c, [240, 255, 246], 0.6), a * 0.9))
    }
    private static func rememberingField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<58 {
            let ph = (t * 0.14 + hash(Double(i) * 2.3)).truncatingRemainder(dividingBy: 1), con = 1 - ph
            let tx = W * hash(Double(i) * 1.7), ty = H * hash(Double(i) * 3.9)
            dot(x, tx + cos(Double(i)) * con * 70, ty + sin(Double(i)) * con * 70, 0.9 + ph * 1.4, col(c, a * 0.5 * ph))
        }
    }

    // ── 11 · rings — three static + three outward ripples ──
    private static func circle(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for (i, f) in [0.34, 0.56, 0.78].enumerated() {
            x.stroke(UniGeo.ringPath(cx, cy, R * f), with: .color(col(c, a * (0.28 - Double(i) * 0.05))), lineWidth: 1.1)
        }
        for k in 0..<3 {
            let ph = (t * 0.10 + Double(k) / 3).truncatingRemainder(dividingBy: 1)
            x.stroke(UniGeo.ringPath(cx, cy, R * (0.2 + ph * 0.9)), with: .color(col(c, a * (1 - ph) * 0.28)), lineWidth: 1.2)
        }
    }
    private static func circleField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for k in 0..<8 {
            let ph = (t * 0.075 + Double(k) / 8).truncatingRemainder(dividingBy: 1)
            x.stroke(UniGeo.ringPath(W / 2, H * 0.44, ph * H * 0.95), with: .color(col(c, a * (1 - ph) * 0.26)), lineWidth: 1.3)
        }
    }

    // ── 12 · ports — the ellipse orbit + comet tail ──
    private static func returnOrbit(_ x: GraphicsContext, _ cx: Double, _ cy: Double, _ R: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        x.stroke(Path(ellipseIn: CGRect(x: cx - R * 0.86, y: cy - R * 0.44, width: R * 1.72, height: R * 0.88)),
                 with: .color(col(c, a * 0.30)), lineWidth: 1.2)
        let ph = (t * 0.045).truncatingRemainder(dividingBy: 1), ang = ph * TAU
        let px = cx + cos(ang) * R * 0.86, py = cy + sin(ang) * R * 0.44
        for k in 0..<16 {
            let a2 = ang - Double(k) * 0.055
            dot(x, cx + cos(a2) * R * 0.86, cy + sin(a2) * R * 0.44, 1.6 * (1 - Double(k) / 16), col(mix(c, [240, 232, 255], 0.5), a * 0.5 * (1 - Double(k) / 16)))
        }
        dot(x, px, py, 2.6, col([246, 240, 255], a * 0.95))
    }
    private static func returnField(_ x: GraphicsContext, _ W: Double, _ H: Double, _ t: Double, _ a: Double, _ c: [Double]) {
        for i in 0..<9 {
            let ph = (t * 0.09 + hash(Double(i))).truncatingRemainder(dividingBy: 1)
            let px = -40 + ph * (W + 80), py = H * hash(Double(i) * 2.1) + sin(ph * Double.pi) * -60
            for k in 0..<10 {
                dot(x, px - Double(k) * 7, py + Double(k) * 2, 1.4 * (1 - Double(k) / 10), col(mix(c, [240, 232, 255], 0.4), a * 0.5 * (1 - Double(k) / 10)))
            }
        }
    }
}
