import SwiftUI

// THE UNIVERSE (Z −4…−1) — the outward inversion: everything he has lived, as sky.
// Built to uni-sky.js / uni-rooms.js / uni-field.js: the thirteen rooms are thirteen
// REGIONS of sky, each in its own colour at its own place; met stories are lights that,
// up close, become INHABITED PLANETS (life only where he has been — settlements grow with
// depth); every met star carries its COMPANY in orbit, one mote per voice that spoke,
// each at its own phase so the sky never synchronises into a mechanism; and the FALL
// opens a star's whole life in four layers down into the Return. The four axis registers
// are the four reading distances — sky (all regions) → region → world (a planet) → fall.
//
// Depth is read off resonance (res ≥85→8 · 60→5 · 44→3 · 28→1), exactly as the ledger
// wires it. Nothing here is written or counted; the sky is the archive, derived.

// The thirteen regions + their forms live in UniRegions.swift (ported from uni-rooms.js).

struct UniverseView: View {
    let register: AxisRegister
    @Binding var path: [FeedRoute]
    let onFall: () -> Void

    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath

    // The star the traveller approached — set by tapping a region/star (Tap to approach).
    @State private var selectedStoryId: String? = nil
    // When the fall register was reached — drives the four-layer descent's depth d (0→~0.95).
    @State private var fallStartT: Double? = nil

    // The structure lens — 0 lit sky … 1 the belief-lattice thrown over the regions. A quiet
    // toggle ramps it; the draw reads the live value each TimelineView tick.
    @State private var lens: Double = 0
    @State private var lensOn = false
    @State private var lensTimer: Timer?

    // Reading distance from the register: sky far → fall close.
    private var scale: Int {
        switch register.key { case "sky": return 0; case "region": return 1; case "world": return 2; default: return 3 }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in draw(ctx, size, t) }
                        .allowsHitTesting(false)          // the Canvas never eats hits
                }
                if register.key == "fall" {
                    VStack {
                        Spacer()
                        Text("the fall").font(.lora(18)).italic().foregroundStyle(Color(hex: "#9FB2C4"))
                        Text("the story, close · who sat with it · what you left here")
                            .font(.loraItalic(11)).foregroundStyle(BinduTheme.inkTertiary)
                        Button(action: onFall) {
                            Text("the mouth of the return ›").font(.spaceMono(9)).tracking(2)
                                .foregroundStyle(Color(hex: "#9FB2C4")).padding(.top, 10)
                        }
                        Spacer().frame(height: 60)
                    }
                }
                // The structure lens toggle — only where the regions are legible (sky/region).
                if scale <= 1 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: toggleLens) {
                                Text(lensOn ? "the light ›" : "the structure ›")
                                    .font(.spaceMono(9)).tracking(2)
                                    .foregroundStyle(Color(hex: "#AAB2BC").opacity(lensOn ? 0.9 : 0.5))
                                    .padding(16)
                            }
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            // Tap to APPROACH — choose which star's world you fall into. A discrete tap
            // (no movement) is recognised simultaneously with the parent axis drag, so
            // dragging still zooms and a tap only sets the focus (Tap to approach).
            .simultaneousGesture(SpatialTapGesture().onEnded { v in handleTap(v.location, geo.size) })
        }
        .ignoresSafeArea()
        // Mark when the fall register is reached, so the four-layer descent can advance.
        .onChange(of: register.key) { _, key in
            fallStartT = key == "fall" ? Date().timeIntervalSinceReferenceDate : nil
        }
        .onAppear { if register.key == "fall" { fallStartT = Date().timeIntervalSinceReferenceDate } }
        .onDisappear { lensTimer?.invalidate() }
    }

    // Ramp the lens toward its toggled target over ~1s (Canvas reads `lens` each tick).
    private func toggleLens() {
        lensOn.toggle()
        let target: Double = lensOn ? 1 : 0
        lensTimer?.invalidate()
        lensTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            let step = 0.06
            if abs(lens - target) <= step { lens = target; lensTimer?.invalidate(); lensTimer = nil }
            else { lens += lens < target ? step : -step }
        }
    }

    // Map a tap to the nearest star and make it the approached focus.
    private func handleTap(_ loc: CGPoint, _ size: CGSize) {
        guard scale <= 1 else { return }                  // only where stars are choosable
        let fr = focusRegion()
        let focus = CGPoint(x: (fr.x + 490) / 980, y: (fr.y + 1030) / 1930)
        let zoom = [1.0, 2.1, 4.6, 4.6][min(scale, 3)]
        var best: (id: String, d: Double)?
        for rm in uniRooms {
            for (i, s) in store.stories.filter({ $0.room == rm.id }).enumerated() {
                let sw = starWorld(rm, i, s)
                let sp = worldToScreen(sw.0, sw.1, size, zoom: zoom, focus: focus)
                let dd = Double(hypot(sp.x - loc.x, sp.y - loc.y))
                if dd < 44, best == nil || dd < best!.d { best = (s.id, dd) }
            }
        }
        if let b = best { selectedStoryId = b.id }
    }

    // MARK: - Data helpers

    private func depth(_ story: Story) -> Int {
        let r = story.resonance
        return r >= 85 ? 8 : (r >= 60 ? 5 : (r >= 44 ? 3 : (r >= 28 ? 1 : 0)))
    }
    private func met(_ story: Story) -> Bool {
        store.stats(for: story.id).commentCount > 0 || story.resonance > 0
    }
    private func room(_ name: String) -> UniRoom { uniRooms.first { $0.id == name } ?? uniRooms[6] }
    private func hash(_ s: String) -> Double {
        var h: UInt32 = 2166136261
        for b in s.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        return Double(h % 100000) / 100000.0
    }
    private func nhash(_ x: Double) -> Double {          // uni-sky.js hash(n)
        let v = sin(x * 127.1 + 31.4) * 43758.5453
        return v - floor(v)
    }

    // World coords → screen, with the register's zoom pulling the focus region toward the frame.
    private func worldToScreen(_ wx: Double, _ wy: Double, _ size: CGSize, zoom: Double, focus: CGPoint) -> CGPoint {
        let nx = (wx + 490) / 980, ny = (wy + 1030) / 1930
        let x = 0.5 + (nx - focus.x) * zoom
        let y = 0.5 + (ny - focus.y) * zoom
        return CGPoint(x: x * size.width, y: y * size.height)
    }
    private func regionCenter(_ rm: UniRoom, _ size: CGSize, zoom: Double, focus: CGPoint) -> CGPoint {
        worldToScreen(rm.x, rm.y, size, zoom: zoom, focus: focus)
    }
    // The star's world position: strung on its region's own armature (uni-rooms.js place()).
    private func starWorld(_ rm: UniRoom, _ i: Int, _ story: Story) -> (Double, Double) {
        let p = rm.place(i % max(1, rm.n))
        let jx = (hash(story.id) - 0.5) * rm.r * 0.10
        let jy = (hash(story.id + "j") - 0.5) * rm.r * 0.10
        return (rm.x + p.0 + jx, rm.y + p.1 + jy)
    }

    // MARK: - Draw

    // The story the traveller is approaching — the one they tapped, else the most-lived.
    private func focusStoryValue() -> Story? {
        if let id = selectedStoryId, let s = store.stories.first(where: { $0.id == id }) { return s }
        return store.stories.filter { met($0) }.max(by: { $0.resonance < $1.resonance }) ?? store.stories.first
    }
    private func focusRegion() -> UniRoom { focusStoryValue().map { room($0.room) } ?? uniRooms[2] }

    private func draw(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double) {
        let b = breath.value
        let W = size.width, H = size.height
        let focusRoom = focusRegion()
        let focusStory = focusStoryValue()
        let focus = CGPoint(x: (focusRoom.x + 490) / 980, y: (focusRoom.y + 1030) / 1930)
        let zoom = [1.0, 2.1, 4.6, 4.6][min(scale, 3)]

        // ── the fall: the approached star's whole life opens in four descending layers ──
        if scale == 3 {
            if let s = focusStory {
                let d = fallStartT.map { max(0.02, min(0.95, (t - $0) / 5.5)) } ?? 0.02
                drawFall(ctx, size, story: s, rm: focusRoom, t: t, d: d)
            }
            return
        }
        // ── the world scale: one story becomes an inhabited planet ──
        if scale == 2, let s = focusStory {
            drawPlanet(ctx, size, story: s, rm: focusRoom, t: t, b: b)
            return
        }

        // ── region weather: the focus region's own field, when you're inside it ──
        if scale >= 1 {
            RegionForm.field(ctx, focusRoom, W, H, t: t, a: 0.5, c: focusRoom.rgb)
        }

        // ── the thirteen regions: each its own figure, its stars strung on the armature ──
        let armA = scale == 0 ? 0.9 : 0.42
        for rm in uniRooms {
            let c = regionCenter(rm, size, zoom: zoom, focus: focus)
            let color = Color(hex: rm.hex)
            let armR = rm.r / 980 * W * zoom
            let rr = armR * 0.6
            guard c.x > -armR, c.x < W + armR, c.y > -armR, c.y < H + armR else { continue }
            // the nebula wash behind the figure
            ctx.fill(UniGeo.ringPath(c.x, c.y, rr),
                     with: .radialGradient(.init(colors: [color.opacity(0.07 + 0.03 * b), .clear]),
                                           center: c, startRadius: 0, endRadius: rr))
            // the region's OWN form, drawn alive (uni-rooms.js arm) — the whole point of the pass
            RegionForm.arm(ctx, rm, cx: c.x, cy: c.y, R: armR, t: t, a: armA, c: rm.rgb)
            // region name — far zoom only, dim (uni-sky.js §wayfinding)
            if scale == 0 {
                ctx.draw(Text(rm.id.uppercased()).font(.spaceMono(6)).foregroundStyle(color.opacity(0.28)),
                         at: CGPoint(x: c.x, y: c.y - armR * 0.62))
            }
            // its stars, strung on the region's armature (not a generic circle)
            let mine = store.stories.filter { $0.room == rm.id }
            for (i, s) in mine.enumerated() {
                let sw = starWorld(rm, i, s)
                let sp = worldToScreen(sw.0, sw.1, size, zoom: zoom, focus: focus)
                drawStar(ctx, at: sp, story: s, color: color, index: i, t: t)
            }
        }

        // ── the structure lens: the lit sky sinks back and the belief-lattice is thrown over ──
        if lens > 0.02 {
            // the light dims — two ways of standing in the same place (uni-sky.js lens)
            ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                     with: .color(Color(.sRGB, red: 8 / 255, green: 7 / 255, blue: 11 / 255, opacity: 0.36 * lens)))
            drawStructures(ctx, size, t: t, zoom: zoom, focus: focus, lens: lens)
        }
    }

    // The belief-lattices, beneath the light (uni-sky.js STRUCTURES): a wobbling held-edge
    // strand through each region's nodes, proof-nodes pulsing, the belief named at the head.
    private func drawStructures(_ ctx: GraphicsContext, _ size: CGSize, t: Double, zoom: Double, focus: CGPoint, lens: Double) {
        let W = size.width, H = size.height, z = zoom
        for (i, st) in uniStructures.enumerated() {
            let soft = st.loose
            let a = lens * (0.46 - soft * 0.24)
            let col = UniGeo.mix(UniGeo.BONE, [168, 178, 188], soft * 0.5)
            let wob = 1 + soft * 2.6
            let pts: [CGPoint] = st.nodes.map { nd in
                worldToScreen(nd.x + sin(t * 0.16 + nd.ph) * wob * 5,
                              nd.y + cos(t * 0.13 + nd.ph * 1.3) * wob * 5,
                              size, zoom: zoom, focus: focus)
            }
            if pts.allSatisfy({ $0.x < -60 || $0.x > W + 60 || $0.y < -60 || $0.y > H + 60 }) { continue }
            _ = i
            // the strand — a quadratic through the node midpoints (comp quadraticCurveTo)
            if pts.count >= 2 {
                var path = Path(); path.move(to: pts[0])
                for j in 1..<pts.count {
                    let mid = CGPoint(x: (pts[j - 1].x + pts[j].x) / 2, y: (pts[j - 1].y + pts[j].y) / 2)
                    path.addQuadCurve(to: mid, control: pts[j - 1])
                }
                path.addLine(to: pts[pts.count - 1])
                ctx.stroke(path, with: .color(UniGeo.col(col, a)),
                           style: StrokeStyle(lineWidth: max(0.8, 1.4 * min(1.6, z)), lineCap: .round))
            }
            // the nodes — proof-nodes pulse, held-nodes sit quiet
            for (j, nd) in st.nodes.enumerated() {
                let p = pts[j]
                let gl = nd.proof ? (0.5 + 0.5 * sin(t * 0.7 + nd.ph)) : 0.25
                let r = (1.6 + (nd.proof ? 1.6 : 0)) * min(2, max(0.8, z))
                ctx.fill(UniGeo.ringPath(p.x, p.y, r), with: .color(UniGeo.col(col, lens * (0.20 + gl * 0.44 - soft * 0.12))))
            }
            // the belief, named at the head node
            if z > 0.85, z < 6, let head = pts.first {
                ctx.draw(Text(st.name).font(.spaceMono(9)).foregroundStyle(UniGeo.col(col, lens * min(0.42, (z - 0.85) * 0.7))),
                         at: CGPoint(x: head.x + 11, y: head.y + 3), anchor: .leading)
            }
        }
    }

    // one star on the sky — met stars carry a halo, depth rings, and their company in orbit.
    private func drawStar(_ ctx: GraphicsContext, at p: CGPoint, story s: Story, color: Color, index i: Int, t: Double) {
        let sx = p.x, sy = p.y
        let isMet = met(s)
        let tw = 0.6 + 0.4 * abs(sin(t * 0.6 + Double(i)))
        let base = isMet ? 0.9 : 0.26
        let sz = isMet ? 2.3 : 1.3
        ctx.fill(UniGeo.ringPath(sx, sy, sz), with: .color(color.opacity(base * tw)))
        guard isMet else { return }
        let d = depth(s)
        let hr = sz * 3
        ctx.fill(UniGeo.ringPath(sx, sy, hr), with: .color(color.opacity(0.06 * tw)))
        // the approached star wears a quiet ring, so you can see which world you chose
        if s.id == selectedStoryId {
            ctx.stroke(UniGeo.ringPath(sx, sy, sz * 4), with: .color(color.opacity(0.5)), lineWidth: 1)
        }
        if scale >= 1 && d > 0 {
            for k in 1...min(d, 6) {
                let dr = sz * 2.0 + Double(k) * 2.4
                ctx.stroke(UniGeo.ringPath(sx, sy, dr), with: .color(color.opacity(0.05)), lineWidth: 0.5)
            }
        }
        // ── the company: one mote per voice that spoke, each at its own phase ──
        // (uni-field.js — never synchronises: per-star seed + varied period)
        if scale >= 1 {
            let voices = store.stats(for: s.id).archetypes
            let seed = hash(s.id)
            let per = 3.0 + seed * 23.0                    // 3–26s family
            for (v, name) in voices.prefix(6).enumerated() {
                let ang = Double(v) / 6 * 2 * .pi + t * (2 * .pi / per) + seed * 6.2831
                let orbit = sz * 5.5
                let mx = sx + cos(ang) * orbit, my = sy + sin(ang) * orbit
                let mc = store.archetype(named: name)?.color ?? color
                ctx.fill(UniGeo.ringPath(mx, my, 1.2), with: .color(mc.opacity(0.7)))
            }
        }
    }

    // The inhabited planet — life only where he has been. A faithful port of uni-sky.js
    // planet(): the offset-lit body, seed-stable continents, the night side, and the
    // CIVILISATION with each region's own civ signature (towers face out, arrays speak up,
    // shafts/terraces ring, mirrorcities double, furnaces rift, weave net, rings orbit,
    // ports send ships) — the detail the old first pass dropped.
    private func drawPlanet(_ ctx: GraphicsContext, _ size: CGSize, story: Story, rm: UniRoom, t: Double, b: Double) {
        let px = size.width / 2, py = size.height * 0.42
        let R = min(size.width, size.height) * 0.26
        let col = rm.rgb, isMet = met(story), d = depth(story), detail = 1.0
        let seed = hash(story.id) * 1000                       // stable per-story seed
        let spin = t * 0.05, tilt = (UniGeo.hash(seed * 23.3) - 0.5) * 0.7
        let SUN = (x: -0.58, y: -0.34, z: 0.74)
        func H(_ n: Double) -> Double { UniGeo.hash(n) }
        func proj(_ lat: Double, _ lon: Double) -> (Double, Double, Double, Double, Double) {
            let a = lon + spin
            let ux = cos(lat) * sin(a), uy = sin(lat), uz = cos(lat) * cos(a)
            let ct = cos(tilt), st = sin(tilt)
            return (ux * ct - uy * st, ux * st + uy * ct, uz, ux, uy)   // tx, ty, uz(front), ux, uy
        }
        func mc(_ o: [Double], _ f: Double, _ a: Double) -> Color { UniGeo.col(UniGeo.mix(col, o, f), a) }
        let black = { (a: Double) in Color(.sRGB, red: 2 / 255, green: 2 / 255, blue: 5 / 255, opacity: a) }

        // the body — offset-lit sphere (met warm, unmet grey)
        ctx.fill(UniGeo.ringPath(px, py, R), with: .radialGradient(Gradient(stops: isMet ? [
            .init(color: mc([255, 250, 242], 0.34, 0.72), location: 0),
            .init(color: mc([20, 18, 26], 0.30, 0.62), location: 0.45),
            .init(color: mc([6, 5, 10], 0.82, 0.96), location: 1)] : [
            .init(color: mc([168, 168, 178], 0.55, 0.34), location: 0),
            .init(color: mc([80, 80, 92], 0.6, 0.24), location: 0.5),
            .init(color: Color(.sRGB, red: 8 / 255, green: 8 / 255, blue: 12 / 255, opacity: 0.9), location: 1)]),
            center: CGPoint(x: px - R * 0.36, y: py - R * 0.34), startRadius: R * 0.05, endRadius: R * 1.05))
        // land — the same continents every time he returns
        if detail > 0.2 {
            for i in 0..<7 {
                let lat = (H(seed * 3.1 + Double(i)) - 0.5) * 2.2, lon = H(seed * 5.7 + Double(i)) * UniGeo.TAU
                let p = proj(lat, lon); if p.2 <= 0.06 { continue }
                let rr = R * (0.10 + H(seed * 7.3 + Double(i)) * 0.22) * p.2
                ctx.fill(Path(ellipseIn: CGRect(x: px + p.0 * R - rr, y: py + p.1 * R - rr * 0.72, width: rr * 2, height: rr * 1.44)),
                         with: .color(mc([16, 14, 20], 0.55, 0.30 * detail * p.2)))
            }
        }
        // night, the edge, the atmosphere
        var gn = ctx; gn.clip(to: UniGeo.ringPath(px, py, R))
        gn.fill(Path(CGRect(x: px - R, y: py - R, width: R * 2, height: R * 2)), with: .radialGradient(
            Gradient(stops: [.init(color: black(0.94), location: 0), .init(color: black(0.58), location: 0.5), .init(color: black(0), location: 1)]),
            center: CGPoint(x: px + R * 0.4, y: py + R * 0.4), startRadius: R * 0.1, endRadius: R * 1.7))
        ctx.stroke(UniGeo.ringPath(px, py, R * 1.02), with: .color(mc([255, 252, 246], 0.5, isMet ? 0.30 : 0.12)), lineWidth: 1)
        ctx.fill(UniGeo.ringPath(px, py, R * 1.5), with: .radialGradient(
            Gradient(stops: [.init(color: UniGeo.col(col, isMet ? 0.16 : 0.05), location: 0), .init(color: UniGeo.col(col, 0), location: 1)]),
            center: CGPoint(x: px, y: py), startRadius: R * 0.96, endRadius: R * 1.5))

        guard isMet, detail >= 0.25 else {
            planetTitle(ctx, story, rm, px, py, R)
            return
        }

        // ── the civilisation — it only exists where he has been ──
        let n = 3 + d * 4
        var lit: [(Double, Double, Double, Double)] = []      // wx, wy, alpha, size
        for j in 0..<n {
            var lat0 = (H(seed * 11.3 + Double(j) * 1.7) - 0.5) * 2.3
            var lon0 = H(seed * 13.1 + Double(j) * 2.3) * UniGeo.TAU
            switch rm.civ {
            case "towers": lat0 *= 0.35
            case "lines":  lat0 = sin(Double(j) * 0.9) * 0.5; lon0 = Double(j) / Double(n) * UniGeo.TAU
            case "rings":  let rr2 = 0.4 + Double(j % 3) * 0.28
                           lat0 = sin(Double(j) * 2.1) * rr2; lon0 = (Double(j) * 2.399963).truncatingRemainder(dividingBy: UniGeo.TAU)
            default: break
            }
            let p2 = proj(lat0, lon0); if p2.2 <= 0.04 { continue }
            let illum = p2.3 * SUN.x + p2.4 * SUN.y + p2.2 * SUN.z
            let night = max(0, min(1, (0.18 - illum) / 0.5))
            var flick = 1.0
            if rm.civ == "ruins" { flick = H(seed + Double(j) + (t * 0.4).rounded(.down)) > 0.35 ? 1 : 0.12 }
            if rm.civ == "relight" { flick = 0.25 + 0.75 * max(0, sin(t * 0.5 - Double(j) * 0.4)) }
            if rm.civ == "districts" { flick = 0.4 + 0.6 * (0.5 + 0.5 * sin(t * 1.05 - lat0 * 2.4)) }
            let sz = (1.1 + H(seed * 17.7 + Double(j)) * 1.7) * max(0.6, min(2.6, R / 38)) * (0.5 + p2.2 * 0.5)
            let a = (0.34 + night * 0.66) * flick * detail
            let wx = px + p2.0 * R, wy = py + p2.1 * R
            lit.append((wx, wy, a, sz))
            ctx.fill(UniGeo.ringPath(wx, wy, sz), with: .color(mc([255, 242, 214], night > 0.4 ? 0.84 : 0.35, a)))
            if night > 0.35 && R > 28 { ctx.fill(UniGeo.ringPath(wx, wy, sz * 4.6), with: .color(mc([255, 230, 176], 0.7, a * 0.16))) }
            // the civ signatures — each kind of world builds its own way
            if rm.civ == "towers" && R > 46 {
                var l = Path(); l.move(to: CGPoint(x: wx, y: wy)); l.addLine(to: CGPoint(x: px + p2.0 * R * 1.22, y: py + p2.1 * R * 1.22))
                ctx.stroke(l, with: .color(UniGeo.col(col, a * 0.4)), lineWidth: 0.8)
            }
            if rm.civ == "arrays" && R > 46 && j % 3 == 0 {
                var l = Path(); l.move(to: CGPoint(x: wx, y: wy)); l.addLine(to: CGPoint(x: px + p2.0 * R * 1.55, y: py + p2.1 * R * 1.55 - R * 0.2))
                ctx.stroke(l, with: .color(mc([220, 255, 252], 0.5, a * 0.30)), lineWidth: 0.8)
            }
            if rm.civ == "shafts" && R > 50 {
                ctx.stroke(UniGeo.ringPath(wx, wy, sz * 3.4), with: .color(mc([255, 190, 160], 0.4, a * 0.28)), lineWidth: 0.7)
            }
            if rm.civ == "terraces" && R > 50 {
                for q in 1...2 { ctx.stroke(UniGeo.ringPath(wx, wy, sz * (2.4 + Double(q) * 2.2)), with: .color(mc([210, 255, 200], 0.4, a * 0.16)), lineWidth: 0.6) }
            }
            if rm.civ == "mirrorcities" && R > 44 {
                let pm = proj(-lat0, lon0)
                if pm.2 > 0.04 { ctx.fill(UniGeo.ringPath(px + pm.0 * R, py + pm.1 * R, sz * 0.8), with: .color(mc([255, 244, 220], 0.6, a * 0.45))) }
            }
        }
        // the roads between them, and what moves along the roads
        if R > 22 && lit.count > 1 {
            for m in 0..<(lit.count - 1) {
                let A = lit[m], Bp = lit[m + 1]
                if hypot(A.0 - Bp.0, A.1 - Bp.1) > R * 1.1 { continue }
                var road = Path(); road.move(to: CGPoint(x: A.0, y: A.1)); road.addLine(to: CGPoint(x: Bp.0, y: Bp.1))
                ctx.stroke(road, with: .color(mc([255, 238, 206], 0.6, min(A.2, Bp.2) * 0.30)), lineWidth: 0.6)
                let ph = (t * 0.22 + Double(m) * 0.31).truncatingRemainder(dividingBy: 1)
                ctx.fill(UniGeo.ringPath(A.0 + (Bp.0 - A.0) * ph, A.1 + (Bp.1 - A.1) * ph, 1.1), with: .color(UniGeo.col([255, 246, 226], min(A.2, Bp.2) * 0.85)))
            }
        }
        // the rift, the net, the great rings — one signature per kind of world
        if R > 26 {
            switch rm.civ {
            case "furnaces":
                var rift = Path(); var first = true
                for f in 0...40 {
                    let p3 = proj(sin(Double(f) / 40 * 3.1) * 0.7 - 0.1, Double(f) / 40 * UniGeo.TAU * 0.8 - 0.7)
                    if p3.2 <= 0 { continue }
                    let pt = CGPoint(x: px + p3.0 * R, y: py + p3.1 * R)
                    if first { rift.move(to: pt); first = false } else { rift.addLine(to: pt) }
                }
                ctx.stroke(rift, with: .color(UniGeo.col([255, 196, 120], 0.34 * detail)), lineWidth: 1.4)
            case "weave":
                for la in -2...2 {
                    var pth = Path(); var first = true
                    for lo in 0...44 { let p4 = proj(Double(la) * 0.45, Double(lo) / 44 * UniGeo.TAU); if p4.2 <= 0.02 { continue }
                        let pt = CGPoint(x: px + p4.0 * R, y: py + p4.1 * R); if first { pth.move(to: pt); first = false } else { pth.addLine(to: pt) } }
                    ctx.stroke(pth, with: .color(UniGeo.col(col, 0.14 * detail)), lineWidth: 0.6)
                }
                for lo2 in 0..<8 {
                    var pth = Path(); var first = true
                    for la2 in -20...20 { let p5 = proj(Double(la2) / 20 * 1.4, Double(lo2) / 8 * UniGeo.TAU); if p5.2 <= 0.02 { continue }
                        let pt = CGPoint(x: px + p5.0 * R, y: py + p5.1 * R); if first { pth.move(to: pt); first = false } else { pth.addLine(to: pt) } }
                    ctx.stroke(pth, with: .color(UniGeo.col(col, 0.10 * detail)), lineWidth: 0.6)
                }
            case "rings":
                for rr3 in 1...3 { ctx.stroke(UniGeo.ringPath(px, py, R * (0.28 + Double(rr3) * 0.20)), with: .color(mc([255, 230, 236], 0.4, 0.10 * detail)), lineWidth: 0.7) }
            default: break
            }
        }
        // what orbits it — only worlds long lived-on have traffic above them
        if d >= 3 && R > 24 {
            let ct = cos(tilt * 0.8), st = sin(tilt * 0.8)
            for o in 0..<2 {
                let orr = R * (1.34 + Double(o) * 0.30), oe = 0.30 + Double(o) * 0.10
                var orbit = Path()
                for k in 0...48 {
                    let ang = Double(k) / 48 * UniGeo.TAU, ox = cos(ang) * orr, oy = sin(ang) * orr * oe
                    let pt = CGPoint(x: px + ox * ct - oy * st, y: py + ox * st + oy * ct)
                    if k == 0 { orbit.move(to: pt) } else { orbit.addLine(to: pt) }
                }
                ctx.stroke(orbit, with: .color(UniGeo.col(col, 0.13 * detail)), lineWidth: 0.7)
                let ships = 1 + o
                for sh in 0..<ships {
                    let ang = ((t * (0.16 + Double(o) * 0.07) + Double(sh) / Double(ships) + Double(o) * 0.3).truncatingRemainder(dividingBy: 1)) * UniGeo.TAU
                    let ox = cos(ang) * orr, oy = sin(ang) * orr * oe
                    ctx.fill(UniGeo.ringPath(px + ox * ct - oy * st, py + ox * st + oy * ct, 1.5), with: .color(UniGeo.col([255, 250, 238], 0.8 * detail)))
                }
            }
            if rm.civ == "ports" && R > 60 {
                let pang = (t * 0.10).truncatingRemainder(dividingBy: 1) * UniGeo.TAU
                ctx.fill(UniGeo.ringPath(px + cos(pang) * R * 1.7, py + sin(pang) * R * 0.6, 2.4), with: .color(UniGeo.col([246, 240, 255], 0.9 * detail)))
            }
        }
        planetTitle(ctx, story, rm, px, py, R)
    }

    private func planetTitle(_ ctx: GraphicsContext, _ story: Story, _ rm: UniRoom, _ px: Double, _ py: Double, _ R: Double) {
        ctx.draw(Text(story.title).font(.lora(15, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary),
                 at: CGPoint(x: px, y: py + R + 34))
        ctx.draw(Text(rm.id.uppercased()).font(.spaceMono(8)).foregroundStyle(Color(hex: rm.hex).opacity(0.7)),
                 at: CGPoint(x: px, y: py + R + 56))
    }

    // THE FALL — the approached star's whole life opening in four descending layers
    // (uni-fall.js). 3·strata (his own rings, every return aged), 1·approach (the sun,
    // its halo the Resonance Voice), 2·gathering (the company settling orbit → seats +
    // the story), 4·mouth (the Return opening). Drawn back-to-front; d is the descent 0→1.
    private func drawFall(_ ctx: GraphicsContext, _ size: CGSize, story: Story, rm: UniRoom, t: Double, d: Double) {
        let W = size.width, H = size.height
        func seg(_ a: Double, _ b: Double) -> Double { max(0, min(1, (d - a) / (b - a))) }
        let app = 1 - seg(0.16, 0.34), gath = seg(0.14, 0.30) * (1 - seg(0.52, 0.74))
        let strat = seg(0.44, 0.66), mouth = seg(0.84, 0.96)
        let col = rm.rgb, br = UniGeo.breath(t), dep = depth(story)
        let cx = W / 2, cy = H * (0.40 - 0.10 * gath + 0.05 * strat)
        let enter = min(1, d / 0.3)

        // the sky closes over — what was above stays only as atmosphere
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                 with: .color(Color(.sRGB, red: 4 / 255, green: 3 / 255, blue: 7 / 255, opacity: 0.80 * enter + 0.15 * strat)))

        // ── 3 · the strata — his own rings, every return, aged ──
        if strat > 0.004 {
            for k in stride(from: dep, through: 0, by: -1) {
                let age = dep > 0 ? Double(k) / Double(dep) : 0
                let local = max(0, min(1, strat * Double(dep + 1) - Double(dep - k)))
                let rr = (52 + Double(k) * 40) * (0.5 + strat * 0.5) * (1 + local * 1.7)
                let a = (0.36 - age * 0.19) * strat * (1 - local * 0.82)
                if a <= 0.004 { continue }
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - rr, y: cy - rr * 0.9, width: rr * 2, height: rr * 1.8)),
                           with: .color(UniGeo.col(UniGeo.mix(col, UniGeo.BONE, age * 0.7), a)), lineWidth: (1.6 - age * 0.9) * (1 + local))
                let ix = cx + rr * 0.72, iy = cy - rr * 0.30
                ctx.fill(UniGeo.ringPath(ix, iy, 1.6 + (1 - age) * 1.6), with: .color(UniGeo.col(UniGeo.mix(col, UniGeo.BONE, age * 0.8), min(1, a * 1.8))))
            }
        }

        // ── 1 · the approach — the sun, its halo the Resonance Voice (warmth, no body) ──
        let Sr = (6 + br * 2.6) * enter * (1 + app * 3.4 + d * 2.0)
        let hal = Sr * (7.4 + app * 2.2) * (0.94 + br * 0.10)
        ctx.fill(UniGeo.ringPath(cx, cy, hal), with: .radialGradient(Gradient(stops: [
            .init(color: UniGeo.col(UniGeo.mix(col, [255, 250, 242], 0.72), 0.80 * enter * (0.55 + app * 0.45)), location: 0),
            .init(color: UniGeo.col(UniGeo.mix(col, [255, 242, 226], 0.34), 0.40 * enter), location: 0.16),
            .init(color: UniGeo.col(col, 0.17 * enter * (0.6 + app * 0.4)), location: 0.46),
            .init(color: UniGeo.col(col, 0), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: hal))
        ctx.fill(UniGeo.ringPath(cx, cy, Sr), with: .color(Color(.sRGB, red: 1, green: 253 / 255, blue: 250 / 255, opacity: 0.95 * enter)))

        // ── 2 · the gathering — the company settles from orbit into its seats, + the story ──
        if gath > 0.004 {
            let set = max(0, min(1, (d - 0.17) / 0.16))
            let S = min(W * 0.40, 158)
            if set > 0.35 {
                ctx.draw(Text(story.codexId).font(.spaceMono(9)).foregroundStyle(BinduTheme.inkTertiary),
                         at: CGPoint(x: cx, y: cy - hal * 0.42 - 18))
                ctx.draw(Text(story.title).font(.lora(16, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary),
                         at: CGPoint(x: cx, y: cy - hal * 0.42))
            }
            let voices = Array(store.stats(for: story.id).archetypes.prefix(6))
            let m = max(1, voices.count)
            for (i, name) in voices.enumerated() {
                let ang = Double(i) / Double(m) * UniGeo.TAU + t * (1 - set * 0.92) * 0.3
                let orbX = cx + cos(ang) * Sr * 2.2, orbY = cy + sin(ang) * Sr * 2.2
                let f = m < 2 ? 0.5 : (Double(i) + 0.5) / Double(m)
                let seatAng = (0.11 + f * 0.78) * Double.pi
                let seatX = cx + cos(seatAng) * S * 1.06, seatY = cy + sin(seatAng) * S * 0.98
                let px2 = orbX + (seatX - orbX) * set, py2 = orbY + (seatY - orbY) * set
                let mc = store.archetype(named: name)?.color ?? Color(hex: rm.hex)
                if set > 0.2 {
                    var line = Path(); line.move(to: CGPoint(x: cx, y: cy)); line.addLine(to: CGPoint(x: px2, y: py2))
                    ctx.stroke(line, with: .color(mc.opacity(0.20 * gath)), lineWidth: 0.6)
                }
                ctx.fill(UniGeo.ringPath(px2, py2, 3), with: .color(mc.opacity(0.66 * gath + set * 0.34)))
            }
        }

        // ── 4 · the mouth — the deepest stratum opens the Return ──
        if mouth > 0.01 {
            let mr = (34 + br * 12) * mouth
            ctx.fill(UniGeo.ringPath(cx, cy, mr * 3), with: .radialGradient(Gradient(stops: [
                .init(color: UniGeo.col([255, 246, 230], 0.44 * mouth), location: 0),
                .init(color: UniGeo.col(UniGeo.mix(col, [218, 182, 112], 0.7), 0.26 * mouth), location: 0.34),
                .init(color: UniGeo.col(col, 0), location: 1)]),
                center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: mr * 3))
            ctx.stroke(UniGeo.ringPath(cx, cy, mr * (1.5 + br * 0.14)), with: .color(UniGeo.col(UniGeo.mix(col, [236, 206, 150], 0.8), 0.20 * mouth)), lineWidth: 1)
        }
    }
}
