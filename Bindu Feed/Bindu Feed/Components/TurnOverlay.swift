import SwiftUI

// THE TURN — the one navigation surface (Wave 4, per the ⚠3 ruling: the turn
// supersedes the Hub). "WHERE TO" — the axis seen as a list of breathing-glyph
// rows, "tap anywhere to stay." Used in two contexts that share these rows and
// this overlay, differing only in how a selection is handled:
//   • the launch Door (DoorView) — outside the nav stack;
//   • every top-level surface in RootView (via `.hubOverlay`, now the turn).
//
// Breathing marks read the ONE master breath (offset for per-row variety, same
// 0.1 Hz clock). Axis-depth rows (Universe/Light/Point) are absorbed until their
// registers ship (Waves 5/6). Row marks are breathing glyphs, not the prototype's
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
    .init(id: "light", name: "The Light", sub: "the future, already underway", glyph: "▷", hex: "#EDE3CE", dest: .route(.light), unmetOnly: false),
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
                    .font(.spaceMono(10)).tracking(3.4)
                    .foregroundStyle(BinduTheme.inkTertiary)
                    .padding(.top, 80).padding(.bottom, 30)

                VStack(spacing: 13) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { i, row in
                        Button { onSelect(row.dest) } label: {
                            HStack(spacing: 15) {
                                Text(row.glyph)
                                    .font(.system(size: 16))
                                    .foregroundStyle(row.color)
                                    .frame(width: 22)
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
                    .font(.spaceMono(9)).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary.opacity(0.4 + 0.4 * breath.value))
                    .padding(.bottom, 40)
            }
        }
        .onAppear { appear = true }
    }
}
