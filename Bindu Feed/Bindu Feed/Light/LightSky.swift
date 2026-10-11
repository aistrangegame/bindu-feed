import SwiftUI

// THE SKY OF LIGHTS — Slice 3 (Ashrey, 2026-10-11): *"experience not just 6 lights, but all of
// them using a concept of galaxies of lights… and lights that are visited more get bigger and
// vaster. Something immersive."*
//
// DIVERGENCE, RECORDED. `LightDraw` held that seventy-six futures shown at once would be "a
// list", and that a daily draw of six kept him from managing the future. Ashrey ruled the other
// way, and the sky answers the draw's own worry rather than ignoring it: this is not a list.
// Nothing is ranked, nothing is sorted by worth, nothing is counted on screen. The lights stand
// where their FAMILY gathers them — the family each scene carries in the base (`FAMILY:` in
// its Excerpt, `kind` on the model) — and the only thing that changes their size is where he
// has actually stood. The sky becomes a map of where he lives, drawn by his own visits.
//
// THE GALAXIES ARE THE BASE'S, NOT THE APP'S. A family label like `Codex (C-1207)` or
// `Tree of Life / the close` names its galaxy by the part before the note. The canon six carry
// `Future` ×5 and `Far` ×1 and are a galaxy like any other. No galaxy name is written here.

// MARK: - Galaxy membership

extension LightScene {
    /// The galaxy a scene belongs to: its authored family, without the author's note.
    var galaxy: String {
        var g = kind
        for sep in [" (", " /"] {
            if let r = g.range(of: sep) { g = String(g[..<r.lowerBound]) }
        }
        g = g.trimmingCharacters(in: .whitespacesAndNewlines)
        return g.isEmpty ? "Future" : g
    }
}

// MARK: - Visits (where he has stood)

/// How often he has stood inside each light, and which he has carved.
///
/// **Two sources, and the larger wins.** This device counts every visit as it happens, so the
/// sky answers at once and offline. The base holds every `Veil Lifted` pulse linked to a scene's
/// record — written by `FeedStore.logVeilLifted` since before the sky existed — so a visit on
/// another device still grows the light here. The canon six have no record to link and are
/// counted on the device alone.
enum LightVisits {
    private static let visitsKey = "bindu.light.visits"
    private static let carvedKey = "bindu.light.carved"

    static func local(_ key: String) -> Int {
        (UserDefaults.standard.dictionary(forKey: visitsKey) as? [String: Int])?[key] ?? 0
    }

    static func count(_ s: LightScene, remote: [String: Int]) -> Int {
        max(local(s.key), s.recordId.flatMap { remote[$0] } ?? 0)
    }

    static func record(_ s: LightScene) {
        var d = (UserDefaults.standard.dictionary(forKey: visitsKey) as? [String: Int]) ?? [:]
        d[s.key, default: 0] += 1
        UserDefaults.standard.set(d, forKey: visitsKey)
    }

    static func carved(_ s: LightScene) -> Bool {
        (UserDefaults.standard.stringArray(forKey: carvedKey) ?? []).contains(s.key)
    }

    static func markCarved(_ s: LightScene) {
        var a = UserDefaults.standard.stringArray(forKey: carvedKey) ?? []
        if !a.contains(s.key) { a.append(s.key); UserDefaults.standard.set(a, forKey: carvedKey) }
    }

    /// The growth curve. Gentle: the first visit shows, the fifth is unmistakable, the
    /// fiftieth is vast without swallowing the sky.
    static func growth(_ v: Int) -> Double { log2(1 + Double(v)) }
}

// MARK: - Layout (deterministic, so a light is always where he left it)

struct LightSkyLayout {
    struct Galaxy {
        let name: String
        let center: CGPoint
        let radius: Double
        let members: [Int]          // indices into the scene array
        let tint: Color
    }

    let galaxies: [Galaxy]
    /// Each scene's home within its galaxy, relative to the galaxy centre, before drift.
    let offsets: [CGPoint]
    let extent: Double

    static func hash(_ s: String) -> Double {
        var h: UInt32 = 2166136261
        for b in s.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        return Double(h % 10_000) / 10_000
    }

    /// Dawn tints only — the Light's material is bone (`LightCanon.hex`); each galaxy leans a
    /// little warmer, cooler, rosier or greener so they read as different places in one dawn.
    private static let tints: [String] = ["#EDE3CE", "#F2D7B6", "#E7D2E4", "#D6E2EA", "#E3E8CF",
                                          "#F0CFC0", "#DCD6F0", "#EDE0C0", "#D2E6DC", "#F3E3D3"]

    init(scenes: [LightScene]) {
        // Galaxies keep the base's order of first appearance — never ranked.
        var order: [String] = []
        var groups: [String: [Int]] = [:]
        for (i, s) in scenes.enumerated() {
            let g = s.galaxy
            if groups[g] == nil { order.append(g) }
            groups[g, default: []].append(i)
        }
        let golden = 2.399963
        var gals: [Galaxy] = []
        var offs = Array(repeating: CGPoint.zero, count: scenes.count)
        var ext = 0.0
        for (gi, name) in order.enumerated() {
            let members = groups[name] ?? []
            let n = Double(members.count)
            let R = members.count == 1 ? 18 : 52 + 24 * n.squareRoot()
            let ring = gi == 0 ? 0 : 230 * (Double(gi) + 0.35).squareRoot()
            let a = Double(gi) * golden + Self.hash(name) * 0.6
            let c = CGPoint(x: cos(a) * ring, y: sin(a) * ring)
            ext = max(ext, ring + R)
            let seed = Self.hash(name) * .pi * 2
            for (j, idx) in members.enumerated() {
                let frac = (Double(j) + 0.5) / n
                let r = members.count == 1 ? 0 : R * frac.squareRoot() * (0.82 + 0.3 * Self.hash(scenes[idx].key))
                let th = Double(j) * golden + seed + (r / max(R, 1)) * 1.9      // the arms wind
                offs[idx] = CGPoint(x: cos(th) * r, y: sin(th) * r)
            }
            let tint = Color(hex: Self.tints[Int(Self.hash(name) * Double(Self.tints.count)) % Self.tints.count])
            gals.append(Galaxy(name: name, center: c, radius: R, members: members, tint: tint))
        }
        galaxies = gals
        offsets = offs
        extent = max(ext, 200)
    }

    /// Where scene `i` stands at time `t` in sky units — each galaxy turns slowly about its
    /// centre, the inner lights faster, as a galaxy does.
    func position(_ i: Int, galaxy g: Galaxy, t: Double) -> CGPoint {
        let o = offsets[i]
        let r = (o.x * o.x + o.y * o.y).squareRoot()
        let w = 0.018 / (0.6 + r / max(g.radius, 1))
        let a = t * w
        return CGPoint(x: g.center.x + o.x * cos(a) - o.y * sin(a),
                       y: g.center.y + o.x * sin(a) + o.y * cos(a))
    }
}

// MARK: - The sky

struct LightSkyView: View {
    let scenes: [LightScene]
    let remoteVisits: [String: Int]
    let onEnter: (Int) -> Void

    @EnvironmentObject private var breath: Breath

    /// The camera: what point of the sky is at the centre of the screen, and how near.
    @State private var cam: CGPoint = .zero
    @State private var zoom: Double = 0
    @State private var flight: Flight?
    @State private var dragFrom: CGPoint?
    @State private var pinchFrom: Double?
    @State private var armed: Int?
    @State private var focus: String?

    private struct Flight {
        let fromCam: CGPoint, fromZoom: Double, toCam: CGPoint, toZoom: Double
        let start: Date, dur: Double
    }

    private var layout: LightSkyLayout { LightSkyLayout(scenes: scenes) }

    /// Above this nearness the lights say their names; below it, the galaxies do.
    private static let namesAt = 1.15

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let L = layout
            let fit = Self.fitZoom(L, size)
            // read once per change, never per frame
            let counts = scenes.map { LightVisits.count($0, remote: remoteVisits) }
            let carved = scenes.map { LightVisits.carved($0) }
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cz = camera(at: tl.date)
                let c = cz.0
                let z = cz.1 == 0 ? fit : cz.1
                ZStack {
                    Canvas { ctx, sz in
                        draw(ctx, sz, L, c, z, t, counts, carved)
                    }
                    labels(size, L, c, z, t, counts)
                }
                .contentShape(Rectangle())
                .gesture(SpatialTapGesture().onEnded { v in
                    tap(v.location, size, L, c, z, fit, t)
                })
                .simultaneousGesture(DragGesture(minimumDistance: 6)
                    .onChanged { v in
                        settleFlight(c, z)
                        if dragFrom == nil { dragFrom = c }
                        let from = dragFrom ?? c
                        cam = CGPoint(x: from.x - v.translation.width / z,
                                      y: from.y - v.translation.height / z)
                        if zoom == 0 { zoom = z }
                    }
                    .onEnded { _ in dragFrom = nil })
                .simultaneousGesture(MagnifyGesture()
                    .onChanged { v in
                        settleFlight(c, z)
                        if pinchFrom == nil { pinchFrom = z }
                        zoom = min(4.5, max(fit * 0.8, (pinchFrom ?? z) * v.magnification))
                    }
                    .onEnded { _ in pinchFrom = nil })
            }
            .overlay(alignment: .bottom) { armedCard(L) }
        }
        .ignoresSafeArea()
    }

    // MARK: Camera

    private static func fitZoom(_ L: LightSkyLayout, _ size: CGSize) -> Double {
        min(size.width, size.height) / (2 * L.extent) * 0.94
    }

    private func camera(at now: Date) -> (CGPoint, Double) {
        guard let f = flight else { return (cam, zoom) }
        let p = min(1, now.timeIntervalSince(f.start) / f.dur)
        let e = p < 0.5 ? 2 * p * p : 1 - pow(-2 * p + 2, 2) / 2
        return (CGPoint(x: f.fromCam.x + (f.toCam.x - f.fromCam.x) * e,
                        y: f.fromCam.y + (f.toCam.y - f.fromCam.y) * e),
                f.fromZoom + (f.toZoom - f.fromZoom) * e)
    }

    /// A hand on the sky takes the camera from wherever the flight has carried it.
    private func settleFlight(_ c: CGPoint, _ z: Double) {
        guard flight != nil else { return }
        flight = nil; cam = c; zoom = z
    }

    private func fly(to c: CGPoint, zoom z: Double, from fc: CGPoint, _ fz: Double) {
        flight = Flight(fromCam: fc, fromZoom: fz, toCam: c, toZoom: z, start: Date(), dur: 1.6)
        cam = c; zoom = z
    }

    private func screen(_ p: CGPoint, _ size: CGSize, _ c: CGPoint, _ z: Double) -> CGPoint {
        CGPoint(x: size.width / 2 + (p.x - c.x) * z, y: size.height / 2 + (p.y - c.y) * z)
    }

    // MARK: Drawing

    /// A light's size is where he has stood. Unvisited lights are faint seeds; each visit
    /// widens the point and its halo, and past a few the halo becomes a nebula.
    private func draw(_ ctx: GraphicsContext, _ size: CGSize, _ L: LightSkyLayout,
                      _ c: CGPoint, _ z: Double, _ t: Double,
                      _ counts: [Int], _ carved: [Bool]) {
        let zs = min(2.2, max(0.55, z))      // lights grow with nearness, but gently
        for g in L.galaxies {
            // the galaxy's own glow — brighter where he has stood more
            let gv = g.members.reduce(0) { $0 + counts[$1] }
            let gc = screen(g.center, size, c, z)
            let gr = g.radius * z * 1.45
            let ga = (0.05 + 0.025 * LightVisits.growth(gv)) * (focus == nil || focus == g.name ? 1 : 0.45)
            ctx.fill(Path(ellipseIn: CGRect(x: gc.x - gr, y: gc.y - gr, width: gr * 2, height: gr * 2)),
                     with: .radialGradient(Gradient(colors: [g.tint.opacity(ga), g.tint.opacity(0)]),
                                           center: gc, startRadius: 0, endRadius: gr))
            for i in g.members {
                let s = scenes[i]
                let v = counts[i]
                let k = LightVisits.growth(v)
                let p = screen(L.position(i, galaxy: g, t: t), size, c, z)
                if p.x < -200 || p.y < -200 || p.x > size.width + 200 || p.y > size.height + 200 { continue }
                let br = 0.78 + 0.22 * RoomGeo.breath(t + LightSkyLayout.hash(s.key) * 9)
                let far = s.material == .nave
                let col = far ? Color(hex: LightCanon.pool) : g.tint
                let core = (1.3 + 1.5 * k) * zs
                let halo = core * (4.5 + 2.2 * k)
                let al = (v == 0 ? 0.42 : min(0.95, 0.62 + 0.1 * k)) * br * (armed == i ? 1.3 : 1)
                // the nebula — what a light becomes where he keeps returning
                if v >= 4 {
                    let nr = halo * (1.6 + 0.35 * k)
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - nr, y: p.y - nr, width: nr * 2, height: nr * 2)),
                             with: .radialGradient(Gradient(colors: [col.opacity(0.10 * br), col.opacity(0)]),
                                                   center: p, startRadius: 0, endRadius: nr))
                }
                ctx.fill(Path(ellipseIn: CGRect(x: p.x - halo, y: p.y - halo, width: halo * 2, height: halo * 2)),
                         with: .radialGradient(Gradient(colors: [col.opacity(al * 0.5), col.opacity(0)]),
                                               center: p, startRadius: 0, endRadius: halo))
                ctx.fill(Path(ellipseIn: CGRect(x: p.x - core, y: p.y - core, width: core * 2, height: core * 2)),
                         with: .color(col.opacity(al)))
                // a declaration carved here is carried as a ring
                if carved[i] {
                    let rr = core * 3.2
                    ctx.stroke(Path(ellipseIn: CGRect(x: p.x - rr, y: p.y - rr, width: rr * 2, height: rr * 2)),
                               with: .color(col.opacity(0.45 * br)), lineWidth: 0.8)
                }
                // the Far one is a seam, not a star — stone, below (`spine-light.js:200-202`)
                if far {
                    ctx.fill(Path(CGRect(x: p.x - 26 * zs, y: p.y - 0.35, width: 52 * zs, height: 0.7)),
                             with: .color(col.opacity(al * 0.30)))
                }
            }
        }
    }

    @ViewBuilder
    private func labels(_ size: CGSize, _ L: LightSkyLayout, _ c: CGPoint, _ z: Double, _ t: Double,
                        _ counts: [Int]) -> some View {
        let near = z >= Self.namesAt
        ZStack {
            ForEach(Array(L.galaxies.enumerated()), id: \.offset) { _, g in
                let gc = screen(g.center, size, c, z)
                if !near || g.members.count == 1 {
                    // the galaxy names itself from afar; a lone light names itself always
                    Text(g.members.count == 1 ? scenes[g.members[0]].title : g.name)
                        .font(.loraItalic(g.members.count == 1 ? 11.5 : 14))
                        .foregroundStyle(g.tint.opacity(g.members.count == 1 ? 0.5 : 0.72))
                        .fixedSize()
                        .position(x: gc.x, y: gc.y - g.radius * z * 1.05 - (g.members.count == 1 ? 6 : 0))
                }
                if near && g.members.count > 1 {
                    ForEach(g.members, id: \.self) { i in
                        let p = screen(L.position(i, galaxy: g, t: t), size, c, z)
                        Text(scenes[i].title)
                            .font(.loraItalic(11))
                            .foregroundStyle(Color(hex: LightCanon.hex).opacity(armed == i ? 0.95 : 0.55))
                            .frame(maxWidth: 120)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .position(x: p.x, y: p.y + 16 + LightVisits.growth(counts[i]) * 5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: Touch

    private func tap(_ loc: CGPoint, _ size: CGSize, _ L: LightSkyLayout,
                     _ c: CGPoint, _ z: Double, _ fit: Double, _ t: Double) {
        let near = z >= Self.namesAt
        // 1 · a light — when near enough to see the lights as themselves, or a lone one
        var best: (Int, Double)?
        for g in L.galaxies where near || g.members.count == 1 {
            for i in g.members {
                let p = screen(L.position(i, galaxy: g, t: t), size, c, z)
                let d = Double(hypot(p.x - loc.x, p.y - loc.y))
                if d < 34, d < (best?.1 ?? .infinity) { best = (i, d) }
            }
        }
        if let (i, _) = best {
            if armed == i { onEnter(i); return }                 // second touch — stand inside
            withAnimation(.easeInOut(duration: 0.6)) { armed = i }  // first touch — it comes forward
            return
        }
        // 2 · a galaxy — fly into it
        for g in L.galaxies {
            let gc = screen(g.center, size, c, z)
            if hypot(gc.x - loc.x, gc.y - loc.y) < max(44, g.radius * z * 1.2) {
                let tz = min(4.0, min(size.width, size.height) * 0.36 / max(g.radius, 30))
                withAnimation(.easeInOut(duration: 0.5)) { armed = nil; focus = g.name }
                fly(to: g.center, zoom: max(tz, Self.namesAt + 0.05), from: c, z)
                return
            }
        }
        // 3 · the open dark — step back out to the whole sky
        withAnimation(.easeInOut(duration: 0.5)) { armed = nil; focus = nil }
        fly(to: .zero, zoom: fit, from: c, z)
    }

    // MARK: The light that has come forward

    @ViewBuilder
    private func armedCard(_ L: LightSkyLayout) -> some View {
        if let i = armed, scenes.indices.contains(i) {
            let s = scenes[i]
            Button { onEnter(i) } label: {
                VStack(spacing: 10) {
                    Text(s.galaxy.uppercased())
                        .spaceMonoTracked(8.5, em: 0.2)
                        .foregroundStyle(Color(hex: LightCanon.hex).opacity(0.5))
                    Text(s.title)
                        .font(.loraItalic(20))
                        .foregroundStyle(Color(hex: LightCanon.hex))
                        .multilineTextAlignment(.center)
                    if !s.vector.isEmpty {
                        Text(s.vector)
                            .font(.lora(14.5))
                            .lineSpacing(5)
                            .foregroundStyle(BinduTheme.inkSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 36).padding(.top, 26).padding(.bottom, 64)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [.clear, Color(hex: "#08070B").opacity(0.92)],
                                   startPoint: .top, endPoint: .bottom)
                        .padding(.top, -40)
                )
            }
            .buttonStyle(.plain)
            .transition(.opacity)
            .id(i)
        }
    }
}
