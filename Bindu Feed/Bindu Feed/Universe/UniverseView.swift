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

// The thirteen regions — id · colour · world-position · radius · civilisation (uni-rooms.js).
private struct UniRoom { let id: String; let hex: String; let x, y, r: Double; let civ: String }
private let uniRooms: [UniRoom] = [
    .init(id: "The Forge", hex: "#D4AE4A", x: -470, y: -1010, r: 150, civ: "furnaces"),
    .init(id: "The Signal", hex: "#3AADA8", x: 470, y: -980, r: 160, civ: "arrays"),
    .init(id: "The Descent", hex: "#E5533C", x: -90, y: -880, r: 250, civ: "shafts"),
    .init(id: "The Garden", hex: "#4A9E6B", x: 330, y: -620, r: 230, civ: "terraces"),
    .init(id: "A Maya Game", hex: "#D4AE4A", x: -420, y: -430, r: 240, civ: "mirrorcities"),
    .init(id: "The Watcher", hex: "#7B82D4", x: 110, y: -230, r: 190, civ: "towers"),
    .init(id: "The Field", hex: "#9B6BD6", x: -200, y: 60, r: 280, civ: "weave"),
    .init(id: "The Thread", hex: "#C4923A", x: 430, y: 150, r: 180, civ: "lines"),
    .init(id: "The Body", hex: "#C45A50", x: -450, y: 330, r: 200, civ: "districts"),
    .init(id: "The Forgetting", hex: "#C4A882", x: 70, y: 470, r: 215, civ: "ruins"),
    .init(id: "The Remembering", hex: "#8AB5A0", x: 350, y: 700, r: 200, civ: "relight"),
    .init(id: "The Circle", hex: "#D4607A", x: -330, y: 760, r: 175, civ: "rings"),
    .init(id: "The Return", hex: "#B9AEA2", x: 60, y: 900, r: 175, civ: "ports"),
]

struct UniverseView: View {
    let register: AxisRegister
    @Binding var path: [FeedRoute]
    let onFall: () -> Void

    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath

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

    // World coords → screen, with the register's zoom pulling a region toward the frame.
    private func regionCenter(_ rm: UniRoom, _ size: CGSize, zoom: Double, focus: CGPoint) -> CGPoint {
        let nx = (rm.x + 490) / 980, ny = (rm.y + 1030) / 1930
        var x = nx, y = ny
        // zoom pulls the focused region to centre and magnifies around it
        x = 0.5 + (nx - focus.x) * zoom
        y = 0.5 + (ny - focus.y) * zoom
        return CGPoint(x: x * size.width, y: y * size.height)
    }

    // MARK: - Draw

    private func draw(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double) {
        let b = breath.value
        // The focus region deepens as he goes in: the most-lived room fills the frame.
        let stories = store.stories
        let focusStory = stories.filter { met($0) }.max(by: { $0.resonance < $1.resonance }) ?? stories.first
        let focusRoom = focusStory.map { room($0.room) } ?? uniRooms[2]
        let fnx = (focusRoom.x + 490) / 980, fny = (focusRoom.y + 1030) / 1930
        let focus = CGPoint(x: fnx, y: fny)
        let zoom = [1.0, 2.1, 4.6, 4.6][min(scale, 3)]

        // ── the world scale: one story becomes an inhabited planet ──
        if scale >= 2, let s = focusStory {
            drawPlanet(ctx, size, story: s, rm: focusRoom, t: t, b: b)
            return
        }

        // ── sky / region: the thirteen regions, their stars, their company ──
        for rm in uniRooms {
            let c = regionCenter(rm, size, zoom: zoom, focus: focus)
            let color = Color(hex: rm.hex)
            let rr = rm.r / 980 * size.width * zoom * 0.6
            guard c.x > -rr, c.x < size.width + rr, c.y > -rr, c.y < size.height + rr else { continue }
            // the nebula
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - rr, y: c.y - rr, width: rr * 2, height: rr * 2)),
                     with: .radialGradient(.init(colors: [color.opacity(0.07 + 0.03 * b), .clear]),
                                           center: c, startRadius: 0, endRadius: rr))
            // region name — far zoom only, dim (uni-sky.js §wayfinding)
            if scale == 0 {
                ctx.draw(Text(rm.id.uppercased()).font(.spaceMono(6)).foregroundStyle(color.opacity(0.28)),
                         at: CGPoint(x: c.x, y: c.y - rr * 0.5))
            }
            // its stars
            let mine = store.stories.filter { $0.room == rm.id }
            for (i, s) in mine.enumerated() {
                let a = -Double.pi / 2 + Double(i) * (2 * .pi / Double(max(mine.count, 1)))
                let sr = rr * 0.62
                let sx = c.x + cos(a) * sr, sy = c.y + sin(a) * sr
                let isMet = met(s)
                let tw = 0.6 + 0.4 * abs(sin(t * 0.6 + Double(i)))
                let base = isMet ? 0.9 : 0.26
                let sz = isMet ? 2.3 : 1.3
                ctx.fill(Path(ellipseIn: CGRect(x: sx - sz, y: sy - sz, width: sz * 2, height: sz * 2)),
                         with: .color(color.opacity(base * tw)))
                if isMet {
                    let d = depth(s)
                    // the halo = its warmth (the Resonance Voice); depth rings around it
                    let hr = sz * 3
                    ctx.fill(Path(ellipseIn: CGRect(x: sx - hr, y: sy - hr, width: hr * 2, height: hr * 2)),
                             with: .color(color.opacity(0.06 * tw)))
                    if scale >= 1 && d > 0 {
                        for k in 1...min(d, 6) {
                            let dr = sz * 2.0 + Double(k) * 2.4
                            ctx.stroke(Path(ellipseIn: CGRect(x: sx - dr, y: sy - dr, width: dr * 2, height: dr * 2)),
                                       with: .color(color.opacity(0.05)), lineWidth: 0.5)
                        }
                    }
                    // ── the company: one mote per voice that spoke, each at its own phase ──
                    // (uni-field.js §8.6 — never synchronises: per-star seed + varied period)
                    if scale >= 1 {
                        let voices = store.stats(for: s.id).archetypes
                        let seed = hash(s.id)
                        let per = 3.0 + seed * 23.0                    // 3–26s family
                        for (v, name) in voices.prefix(6).enumerated() {
                            let ang = Double(v) / 6 * 2 * .pi + t * (2 * .pi / per) + seed * 6.2831
                            let orbit = sz * 5.5
                            let mx = sx + cos(ang) * orbit, my = sy + sin(ang) * orbit
                            let mc = store.archetype(named: name)?.color ?? color
                            ctx.fill(Path(ellipseIn: CGRect(x: mx - 1.2, y: my - 1.2, width: 2.4, height: 2.4)),
                                     with: .color(mc.opacity(0.7)))
                        }
                    }
                }
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
