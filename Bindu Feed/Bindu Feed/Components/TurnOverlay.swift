import SwiftUI

// THE TURN — the one navigation surface (Wave 4, per the ⚠3 ruling: the turn
// supersedes the Hub). "WHERE TO" — the axis seen as a list of breathing-glyph
// rows, "tap anywhere to stay." Used in two contexts that share these rows and
// this overlay, differing only in how a selection is handled:
//   • the launch Door (DoorView) — outside the nav stack;
//   • every top-level surface in RootView (via `.hubOverlay`, now the turn).
//
// Breathing marks read the ONE master breath (offset for per-row variety, same
// 0.1 Hz clock). The axis-depth rows (Universe/Light/Point) now NAVIGATE into the
// axis at their register — Universe→instrument(-4), Light→instrument(-5),
// Point→instrument(1) — via FeedRoute.instrument(Int). Row marks are breathing glyphs, not the prototype's
// hand-drawn originals (≈, ledger polish).

enum TurnDestination {
    case rite
    case archive
    case route(FeedRoute)
    case absorbed          // an axis-depth with no register yet
}

struct TurnRow: Identifiable {
    let id: String
    let name: String
    let sub: String
    let glyph: String
    let hex: String
    let dest: TurnDestination
    let unmetOnly: Bool
    var color: Color { Color(hex: hex) }
}

let turnRows: [TurnRow] = [
    .init(id: "rite", name: "The Rite", sub: "today\u{2019}s meeting", glyph: "◆", hex: "#4A9E6B", dest: .rite, unmetOnly: true),
    .init(id: "rooms", name: "The Rooms", sub: "thirteen ways in", glyph: "⌗", hex: "#B9AEA2", dest: .route(.rooms), unmetOnly: false),
    .init(id: "archive", name: "The Archive", sub: "everything, as it stands", glyph: "≡", hex: "#A9A29B", dest: .archive, unmetOnly: false),
    .init(id: "universe", name: "The Universe", sub: "the whole of it, from above", glyph: "✧", hex: "#9FB2C4", dest: .route(.instrument(-4)), unmetOnly: false),
    .init(id: "light", name: "The Light", sub: "the future, already underway", glyph: "▷", hex: "#EDE3CE", dest: .route(.instrument(-5)), unmetOnly: false),
    .init(id: "point", name: "The Point", sub: "everything you know, arranged", glyph: "·", hex: "#C0392B", dest: .route(.instrument(1)), unmetOnly: false),
    .init(id: "players", name: "The Players", sub: "the lenses that read", glyph: "◊", hex: "#3AADA8", dest: .route(.players), unmetOnly: false),
    .init(id: "arrive", name: "How You Arrive", sub: "name, colour, mark", glyph: "◉", hex: "#C47A52", dest: .route(.settings), unmetOnly: false),
]

struct TurnOverlay: View {
    var unmet: Bool = false
    let onStay: () -> Void
    let onSelect: (TurnDestination) -> Void

    @EnvironmentObject private var breath: Breath
    @State private var appear = false

    private var rows: [TurnRow] { turnRows.filter { !($0.unmetOnly && !unmet) } }

    var body: some View {
        ZStack {
            Color(hex: "#08070B").opacity(0.80).ignoresSafeArea()
                .background(.ultraThinMaterial)
                .contentShape(Rectangle())
                .onTapGesture { onStay() }              // tap anywhere to stay

            VStack(spacing: 0) {
                Text("WHERE TO")
                    .font(.spaceMono(10)).textCase(.uppercase).tracking(3.4)
                    .foregroundStyle(BinduTheme.inkTertiary)
                    .padding(.top, 80).padding(.bottom, 30)

                VStack(spacing: 13) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { i, row in
                        Button { onSelect(row.dest) } label: {
                            HStack(spacing: 15) {
                                // each row's mark drawn in its own hand — a small composition,
                                // not a shared glyph set (comp A Strange Feed.html turn marks).
                                TurnMark(id: row.id, color: row.color)
                                    .frame(width: 22, height: 22)
                                    .opacity(0.55 + 0.4 * breath.eased(offset: Double(i) * 0.09))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(row.name).font(.lora(16)).foregroundStyle(BinduTheme.inkPrimary)
                                    Text(row.sub).font(.loraItalic(12.5)).foregroundStyle(BinduTheme.inkSecondary)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 7)
                        .animation(.easeOut(duration: 0.62).delay(0.14 + Double(i) * 0.075), value: appear)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
                Text("tap anywhere to stay")
                    .font(.spaceMono(9)).textCase(.uppercase).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.4 + 0.4 * breath.value))
                    .padding(.bottom, 40)
            }
        }
        .onAppear { appear = true }
    }
}

// Each turn row's mark, drawn in its own hand (comp: thirteen dots for the Rooms, strata
// for the Archive, a scatter for the Universe, a shaft for the Light, a particle for the
// Point, two lenses for the Players, ◉ for How You Arrive). A small 22×22 composition.
private struct TurnMark: View {
    let id: String
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let W = size.width, H = size.height, c = color
            func dot(_ x: Double, _ y: Double, _ r: Double, _ a: Double) {
                ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(c.opacity(a)))
            }
            switch id {
            case "rooms":                       // thirteen dots, one dim
                var k = 0
                for row in 0..<4 {
                    let cols = row < 3 ? 4 : 1
                    for col in 0..<cols {
                        let x = W * (0.16 + Double(col) * 0.22), y = H * (0.16 + Double(row) * 0.22)
                        dot(x, y, 1.3, k == 5 ? 0.28 : 0.85); k += 1
                    }
                }
            case "archive":                     // four strata bars
                for i in 0..<4 {
                    let y = H * (0.24 + Double(i) * 0.17)
                    ctx.fill(Path(CGRect(x: W * 0.14, y: y, width: W * 0.72, height: 1.4)), with: .color(c.opacity(0.85 - Double(i) * 0.14)))
                }
            case "universe":                    // a scattered sky
                let pts: [(Double, Double, Double)] = [(0.2, 0.3, 1.3), (0.5, 0.18, 1.0), (0.78, 0.34, 1.2), (0.34, 0.6, 1.0), (0.66, 0.7, 1.3), (0.5, 0.5, 0.8), (0.85, 0.62, 0.9), (0.16, 0.8, 0.9)]
                for p in pts { dot(W * p.0, H * p.1, p.2, 0.85) }
            case "light":                       // a widening shaft of light
                var shaft = Path()
                shaft.move(to: CGPoint(x: W * 0.44, y: 0)); shaft.addLine(to: CGPoint(x: W * 0.56, y: 0))
                shaft.addLine(to: CGPoint(x: W * 0.82, y: H)); shaft.addLine(to: CGPoint(x: W * 0.18, y: H)); shaft.closeSubpath()
                ctx.fill(shaft, with: .linearGradient(Gradient(colors: [c.opacity(0.7), c.opacity(0.05)]),
                                                      startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: H)))
            case "point":                       // one particle, aglow
                ctx.fill(Path(ellipseIn: CGRect(x: W * 0.5 - 8, y: H * 0.5 - 8, width: 16, height: 16)),
                         with: .radialGradient(Gradient(colors: [c.opacity(0.8), c.opacity(0)]), center: CGPoint(x: W * 0.5, y: H * 0.5), startRadius: 0, endRadius: 8))
                dot(W * 0.5, H * 0.5, 2, 0.95)
            case "players":                     // two overlapping lenses
                ctx.stroke(Path(ellipseIn: CGRect(x: W * 0.10, y: H * 0.28, width: W * 0.52, height: H * 0.44)), with: .color(c.opacity(0.85)), lineWidth: 1)
                ctx.stroke(Path(ellipseIn: CGRect(x: W * 0.38, y: H * 0.28, width: W * 0.52, height: H * 0.44)), with: .color(c.opacity(0.85)), lineWidth: 1)
            case "arrive":                      // ◉ — the mark of arrival
                ctx.stroke(Path(ellipseIn: CGRect(x: W * 0.24, y: H * 0.24, width: W * 0.52, height: H * 0.52)), with: .color(c.opacity(0.85)), lineWidth: 1.2)
                dot(W * 0.5, H * 0.5, 2.4, 0.95)
            default:                            // rite — a filled diamond
                var d = Path()
                d.move(to: CGPoint(x: W * 0.5, y: H * 0.2)); d.addLine(to: CGPoint(x: W * 0.78, y: H * 0.5))
                d.addLine(to: CGPoint(x: W * 0.5, y: H * 0.8)); d.addLine(to: CGPoint(x: W * 0.22, y: H * 0.5)); d.closeSubpath()
                ctx.fill(d, with: .color(c.opacity(0.85)))
            }
        }
    }
}
