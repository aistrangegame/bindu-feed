import SwiftUI

// THE SEVEN WORLDS OF THE POINT (Amendment-01 §7.3) — each dimension is a visually AND
// interactively DISTINCT world, unified only by the breath, the type, the particle, and
// the ladder. One shared skeleton (dimension → stars → descent) rendered in each world's
// native material and opened by its native gesture:
//   I  The Point   — near-emptiness; points; DWELL (hold) to open
//   II The Turn    — orbital; stars ride rings; TAP draws one inward
//   III The Veil   — gauze layers; PART the curtain (drag) to reach a star
//   IV The Chamber — stone walls; MOVE ALONG them (pan) and touch
//   V  The Mirrors — facing pairs; TURN the surface (tap) to see what faces it
//   VI The Return  — strata; SETTLE down through the layers; the Return's own door at depth
//   VII The Dance  — fast flight; CATCH a star (tap) in motion — the only fast world
// The ●◐○ walked-status coding survives in every world, translated into its material.

// A star placed in a world, carrying its universe index and its walked status.
struct PlacedStar: Identifiable {
    let star: PointStar
    let uni: Int
    var id: String { star.key }
    var status: Int { star.st == "w" ? 2 : (star.st == "p" ? 1 : 0) }   // ●=2 ◐=1 ○=0
}

enum PointWorlds {
    static func placed(_ dim: PointDimension) -> [PlacedStar] {
        var out: [PlacedStar] = []
        for (ui, u) in dim.universes.enumerated() {
            for k in u.stars {
                if let s = PointContent.stars.first(where: { $0.key == k }) {
                    out.append(PlacedStar(star: s, uni: ui))
                }
            }
        }
        return out
    }
    static func hash(_ s: String) -> Double {
        var h: UInt32 = 2166136261
        for b in s.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        return Double(h % 100000) / 100000.0
    }
}

// The ●◐○ star mark + its label, the one shared token across all seven materials.
private struct StarMark: View {
    let placed: PlacedStar
    let hue: Color
    var compact: Bool = false
    var body: some View {
        HStack(spacing: 7) {
            marker
            if !compact {
                Text(placed.star.t)
                    .font(.lora(11.5)).foregroundStyle(BinduTheme.inkPrimary.opacity(placed.status == 0 ? 0.56 : 0.86))
                    .lineLimit(2).frame(maxWidth: 96, alignment: .leading)
            }
        }
    }
    @ViewBuilder private var marker: some View {
        switch placed.status {
        case 2: Circle().fill(hue).frame(width: 9, height: 9).shadow(color: hue.opacity(0.7), radius: 5)   // ● walked
        case 1: Circle().fill(LinearGradient(colors: [hue, .clear], startPoint: .leading, endPoint: .trailing))
                    .overlay(Circle().stroke(hue, lineWidth: 1)).frame(width: 9, height: 9)                  // ◐ in progress
        default: Circle().stroke(hue.opacity(0.6), lineWidth: 1).frame(width: 9, height: 9)                  // ○ seeded
        }
    }
}

// The dispatcher — one world per dimension.
struct PointWorld: View {
    let dimensionN: Int
    let stars: [PlacedStar]
    let hue: Color
    let onOpen: (PointStar) -> Void

    var body: some View {
        switch dimensionN {
        case 1: WorldPoint(stars: stars, hue: hue, onOpen: onOpen)
        case 2: WorldTurn(stars: stars, hue: hue, onOpen: onOpen)
        case 3: WorldVeil(stars: stars, hue: hue, onOpen: onOpen)
        case 4: WorldChamber(stars: stars, hue: hue, onOpen: onOpen)
        case 5: WorldMirrors(stars: stars, hue: hue, onOpen: onOpen)
        case 6: WorldReturn(stars: stars, hue: hue, onOpen: onOpen)
        default: WorldDance(stars: stars, hue: hue, onOpen: onOpen)
        }
    }
}

// ── I · THE POINT — near-emptiness; points approach when he is still; DWELL to open ──
private struct WorldPoint: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    @EnvironmentObject private var breath: Breath
    @State private var dwell: String? = nil
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    ForEach(stars) { p in
                        let seed = PointWorlds.hash(p.id)
                        let drift = 0.5 + 0.42 * sin(t * 0.04 + seed * 6.28)   // approaches centre and away, slowly
                        let ang = seed * 6.2831
                        let rad = (0.20 + seed * 0.24) * drift
                        let x = geo.size.width * (0.5 + cos(ang) * rad)
                        let y = geo.size.height * (0.5 + sin(ang) * rad * 1.15)
                        StarMark(placed: p, hue: hue, compact: dwell != p.id)
                            .scaleEffect(dwell == p.id ? 1.35 : 1)
                            .opacity(0.5 + 0.5 * breath.value)
                            .position(x: x, y: y)
                            .onLongPressGesture(minimumDuration: 0.9, pressing: { pressing in
                                dwell = pressing ? p.id : nil
                            }, perform: { onOpen(p.star); dwell = nil })
                    }
                    Text("look at a point · hold it until it opens")
                        .font(.spaceMono(8)).tracking(2).foregroundStyle(BinduTheme.inkTertiary.opacity(0.4))
                        .position(x: geo.size.width / 2, y: geo.size.height - 40)
                }
            }
        }
    }
}

// ── II · THE TURN — everything in slow orbit; TAP draws a star inward from its circle ──
private struct WorldTurn: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2, cy = geo.size.height / 2
            let R0 = min(geo.size.width, geo.size.height) * 0.5
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    Canvas { ctx, size in                       // the violet orbital arcs
                        for u in 0..<4 {
                            let r = R0 * (0.34 + Double(u) * 0.20)
                            ctx.stroke(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                                       with: .color(hue.opacity(0.12)), lineWidth: 0.6)
                        }
                    }
                    ForEach(Array(stars.enumerated()), id: \.element.id) { i, p in
                        let ring = p.uni % 4
                        let inRing = stars.filter { $0.uni % 4 == ring }.count
                        let idx = stars.filter { $0.uni % 4 == ring }.firstIndex(where: { $0.id == p.id }) ?? 0
                        let r = R0 * (0.34 + Double(ring) * 0.20)
                        let dirn = ring % 2 == 0 ? 1.0 : -1.0
                        let a = Double(idx) / Double(max(inRing, 1)) * 6.2831 + t * 0.16 * dirn
                        StarMark(placed: p, hue: hue, compact: true)
                            .position(x: cx + cos(a) * r, y: cy + sin(a) * r)
                            .onTapGesture { onOpen(p.star) }
                    }
                }
            }
        }
    }
}

// ── III · THE VEIL — gauze upon gauze; PART the curtain (horizontal drag) to reach in ──
private struct WorldVeil: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    @State private var part: CGFloat = 0     // 0 closed … 1 fully parted
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    // six drifting gauze bands; they slide aside as he parts them
                    Canvas { ctx, size in
                        for b in 0..<6 {
                            let base = size.width * (Double(b) + 0.5) / 6
                            let sway = sin(t * 0.3 + Double(b)) * 10
                            let shove = Double(part) * size.width * 0.5 * (b < 3 ? -1 : 1)
                            let x = base + sway + shove
                            var band = Path()
                            band.addRect(CGRect(x: x - 34, y: 0, width: 68, height: size.height))
                            ctx.fill(band, with: .color(hue.opacity(0.05 + 0.05 * (1 - Double(part)))))
                        }
                    }
                    ForEach(stars) { p in
                        let seed = PointWorlds.hash(p.id)
                        StarMark(placed: p, hue: hue, compact: part < 0.5)
                            .opacity(0.18 + 0.82 * Double(part))
                            .position(x: geo.size.width * (0.16 + seed * 0.68),
                                      y: geo.size.height * (0.16 + PointWorlds.hash(p.id + "y") * 0.68))
                            .allowsHitTesting(part > 0.4)
                            .onTapGesture { onOpen(p.star) }
                    }
                    Text(part < 0.4 ? "part the veil ›" : "")
                        .font(.spaceMono(8)).tracking(2).foregroundStyle(BinduTheme.inkTertiary.opacity(0.5))
                        .position(x: geo.size.width / 2, y: geo.size.height - 40)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(DragGesture().onChanged { v in
                    part = min(1, max(0, abs(v.translation.width) / (geo.size.width * 0.5)))
                }.onEnded { _ in withAnimation(.easeOut(duration: 1.4)) { part = part > 0.5 ? 1 : 0 } })
            }
        }
    }
}

// ── IV · THE CHAMBER — an interior of dark warmth; MOVE ALONG the walls (pan) ──
private struct WorldChamber: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    @State private var panX: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            let spread = geo.size.width * 1.4
            ZStack {
                Canvas { ctx, size in                           // lit stone courses, ember from below-left
                    for c in 0..<7 {
                        let y = size.height * Double(c) / 7
                        ctx.stroke(Path { $0.move(to: CGPoint(x: 0, y: y)); $0.addLine(to: CGPoint(x: size.width, y: y)) },
                                   with: .color(hue.opacity(0.08)), lineWidth: 0.6)
                    }
                    ctx.fill(Path(ellipseIn: CGRect(x: -80, y: size.height - 60, width: 260, height: 260)),
                             with: .radialGradient(.init(colors: [hue.opacity(0.14), .clear]),
                                                   center: CGPoint(x: 40, y: size.height), startRadius: 0, endRadius: 220))
                }
                ForEach(Array(stars.enumerated()), id: \.element.id) { i, p in
                    let col = Double(i) / Double(max(stars.count - 1, 1))
                    StarMark(placed: p, hue: hue)
                        .position(x: 40 + col * spread + panX,
                                  y: geo.size.height * (0.22 + Double(p.uni % 4) * 0.18))
                        .onTapGesture { onOpen(p.star) }
                }
                Text("move along the wall").font(.spaceMono(8)).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.45))
                    .position(x: geo.size.width / 2, y: geo.size.height - 40)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(DragGesture().onChanged { v in panX = v.translation.width }
                .onEnded { _ in withAnimation(.easeOut(duration: 0.4)) { panX = max(-spread + geo.size.width * 0.5, min(0, panX)) } })
        }
    }
}

// ── V · THE MIRRORS — perspectives paired and facing; TURN a surface to see its other ──
private struct WorldMirrors: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    @State private var turned: Set<String> = []
    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            ZStack {
                Rectangle().fill(hue.opacity(0.14)).frame(width: 0.8)                 // the mirror seam
                    .frame(maxHeight: .infinity).position(x: cx, y: geo.size.height / 2)
                ForEach(Array(stars.enumerated()), id: \.element.id) { i, p in
                    let left = i % 2 == 0
                    let row = Double(i / 2)
                    let rows = ceil(Double(stars.count) / 2)
                    let y = geo.size.height * (0.18 + (rows <= 1 ? 0.3 : row / (rows - 1) * 0.62))
                    StarMark(placed: p, hue: hue)
                        .rotation3DEffect(.degrees(turned.contains(p.id) ? 0 : (left ? 40 : -40)), axis: (x: 0, y: 1, z: 0))
                        .position(x: left ? cx - geo.size.width * 0.24 : cx + geo.size.width * 0.24, y: y)
                        .onTapGesture {
                            if turned.contains(p.id) { onOpen(p.star) }
                            else { withAnimation(.easeInOut(duration: 0.7)) { _ = turned.insert(p.id) } }
                        }
                }
                Text("turn a surface · then again to enter").font(.spaceMono(8)).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.45))
                    .position(x: cx, y: geo.size.height - 40)
            }
        }
    }
}

// ── VI · THE RETURN — the world of strata; SETTLE down through the time-layers ──
private struct WorldReturn: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Canvas { ctx, size in                            // rose strata + rings, aged with depth
                    for s in 0..<7 {
                        let y = size.height * (0.12 + Double(s) * 0.12)
                        let age = Double(s) / 7
                        ctx.stroke(Path { $0.move(to: CGPoint(x: 20, y: y)); $0.addLine(to: CGPoint(x: size.width - 20, y: y)) },
                                   with: .color(hue.opacity(0.16 - 0.12 * age)), lineWidth: 0.7)
                    }
                }
                ForEach(Array(stars.enumerated()), id: \.element.id) { i, p in
                    let strat = Double(i) / Double(max(stars.count - 1, 1))
                    StarMark(placed: p, hue: hue)
                        .saturation(1 - strat * 0.5).opacity(1 - strat * 0.35)        // deeper = aged
                        .position(x: geo.size.width * (0.5 + (i % 2 == 0 ? -0.22 : 0.22)),
                                  y: geo.size.height * (0.14 + strat * 0.62))
                        .onTapGesture { onOpen(p.star) }
                }
            }
        }
    }
}

// ── VII · THE DANCE — motion everything; CATCH a star in flight (the only fast world) ──
private struct WorldDance: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2, cy = geo.size.height / 2
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    Canvas { ctx, size in                        // fast gold streaks
                        for k in 0..<10 {
                            let ph = Double(k) / 10 * 6.2831
                            let x = cx + cos(t * 0.7 + ph) * size.width * 0.42
                            let y = cy + sin(t * 0.9 + ph) * size.height * 0.36
                            ctx.stroke(Path { $0.move(to: CGPoint(x: x, y: y)); $0.addLine(to: CGPoint(x: x + 26, y: y + 10)) },
                                       with: .color(hue.opacity(0.18)), lineWidth: 0.8)
                        }
                    }
                    ForEach(Array(stars.enumerated()), id: \.element.id) { i, p in
                        let ph = Double(i) / Double(max(stars.count, 1)) * 6.2831
                        let x = cx + cos(t * 0.55 + ph) * geo.size.width * 0.36
                        let y = cy + sin(t * 0.73 + ph * 1.3) * geo.size.height * 0.30
                        StarMark(placed: p, hue: hue, compact: true)
                            .position(x: x, y: y)
                            .onTapGesture { onOpen(p.star) }
                    }
                    Text("catch one in flight").font(.spaceMono(8)).tracking(2)
                        .foregroundStyle(BinduTheme.inkTertiary.opacity(0.45))
                        .position(x: cx, y: geo.size.height - 40)
                }
            }
        }
    }
}
