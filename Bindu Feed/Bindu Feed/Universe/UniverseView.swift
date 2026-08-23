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

    // Reading distance from the register: sky far → fall close.
    private var scale: Int {
        switch register.key { case "sky": return 0; case "region": return 1; case "world": return 2; default: return 3 }
    }

    var body: some View {
        ZStack {
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in draw(ctx, size, t) }
                    .ignoresSafeArea().allowsHitTesting(false)
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
        }
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

        // ── the world scale: one story becomes an inhabited planet ──
        if scale >= 2, let s = focusStory {
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

    // The inhabited planet — life only where he has been (uni-sky.js planet()).
    private func drawPlanet(_ ctx: GraphicsContext, _ size: CGSize, story: Story, rm: UniRoom, t: Double, b: Double) {
        let cx = size.width / 2, cy = size.height * 0.42
        let R = min(size.width, size.height) * 0.26
        let color = Color(hex: rm.hex)
        let d = depth(story)
        let seed = hash(story.id)
        let spin = t * 0.05

        // the body — offset-lit sphere
        ctx.fill(Path(ellipseIn: CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2)),
                 with: .radialGradient(.init(colors: [color.opacity(0.5), color.opacity(0.12), .black.opacity(0.9)]),
                                       center: CGPoint(x: cx - R * 0.35, y: cy - R * 0.35), startRadius: 0, endRadius: R * 1.6))
        // continents — the same land every time he returns (seed), night side dark
        for i in 0..<40 {
            let lat = (nhash(seed * 3.1 + Double(i) * 0.13) - 0.5) * 2.2
            let lon = nhash(seed * 5.7 + Double(i) * 0.17) * 2 * .pi + spin
            let uz = cos(lat) * cos(lon)
            guard uz > 0.06 else { continue }
            let ux = cos(lat) * sin(lon), uy = sin(lat)
            let px = cx + ux * R, py = cy - uy * R
            ctx.fill(Path(ellipseIn: CGRect(x: px - 2, y: py - 2, width: 4, height: 4)),
                     with: .color(color.opacity(0.22 * uz)))
        }
        // the civilisation — settlements grow with depth, bright on the night side
        let n = 3 + d * 4
        for j in 0..<n {
            let lat = (nhash(seed * 11.3 + Double(j) * 1.7) - 0.5) * 2.3
            let lon = nhash(seed * 13.1 + Double(j) * 2.3) * 2 * .pi + spin
            let uz = cos(lat) * cos(lon)
            guard uz > 0.04 else { continue }
            let ux = cos(lat) * sin(lon), uy = sin(lat)
            let px = cx + ux * R, py = cy - uy * R
            let flick = 0.5 + 0.5 * sin(t * 0.9 + Double(j))
            ctx.fill(Path(ellipseIn: CGRect(x: px - 1.4, y: py - 1.4, width: 2.8, height: 2.8)),
                     with: .color(Color(hex: "#FBF3D6").opacity(0.5 + 0.4 * flick)))
        }
        // an orbital ring, on worlds long lived-on
        if d >= 3 {
            ctx.stroke(Path(ellipseIn: CGRect(x: cx - R * 1.35, y: cy - R * 0.5, width: R * 2.7, height: R)),
                       with: .color(color.opacity(0.14)), lineWidth: 0.6)
        }
        // the title, close enough to read
        ctx.draw(Text(story.title).font(.lora(15, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary),
                 at: CGPoint(x: cx, y: cy + R + 34))
        ctx.draw(Text(rm.id.uppercased()).font(.spaceMono(8)).foregroundStyle(color.opacity(0.7)),
                 at: CGPoint(x: cx, y: cy + R + 56))
    }
}
