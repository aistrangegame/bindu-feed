import Combine
import SwiftUI

// THE REST · three small things the Door now carries.
//   · THE GROUND WEARS THE WEATHER (the Chakras app): a 6% tint of the room of the last story
//     he met — the Door remembers where he was without saying so.
//   · TRATAK ON THE DOT (Codex C-1222, C-1337): eleven seconds of stillness and a soft white
//     light begins to move behind the point — what he once saw behind the red dot. Any touch
//     lets it go.
//   · THE FLASH SUITS (Codex C-1005): a small mark at the foot of the Door; touching it picks
//     the suit he arrives in — Red, Black, Blue. White is never picked: it lights only when a
//     Red or Black arrival ends in a sealed Rite.
struct DoorAir: View {
    @EnvironmentObject private var store: FeedStore
    @State private var drift: Double = 0

    var body: some View {
        ZStack {
            if let r = store.lastMetRoom {
                r.color.opacity(0.06).ignoresSafeArea().allowsHitTesting(false)
            }
            TimelineView(.animation) { tl in
                let still = TouchSense.touching ? 0 : tl.date.timeIntervalSince(TouchSense.lastTouch)
                let a = max(0, min(1, (still - 11) / 4))
                Canvas { ctx, size in
                    guard a > 0 else { return }
                    let t = tl.date.timeIntervalSinceReferenceDate
                    let c = CGPoint(x: size.width / 2 + CGFloat(sin(t * 0.21) * 34), y: size.height * 0.44 + CGFloat(cos(t * 0.17) * 22))
                    let r: CGFloat = 70
                    ctx.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                             with: .radialGradient(Gradient(colors: [Color.white.opacity(0.10 * a), .clear]), center: c, startRadius: 0, endRadius: r))
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                Spacer()
                Button { store.cycleSuit() } label: {
                    SuitMark(suit: store.suitToday)
                        .frame(width: 14, height: 14)
                        .padding(14)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 18)
            }
        }
    }
}

struct SuitMark: View {
    let suit: FeedStore.Suit?
    var body: some View {
        Canvas { ctx, size in
            let r = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)
            var d = Path()
            d.move(to: CGPoint(x: r.midX, y: r.minY)); d.addLine(to: CGPoint(x: r.maxX, y: r.midY))
            d.addLine(to: CGPoint(x: r.midX, y: r.maxY)); d.addLine(to: CGPoint(x: r.minX, y: r.midY)); d.closeSubpath()
            if let s = suit {
                ctx.fill(d, with: .color(Color(hex: s.hex).opacity(0.9)))
            } else {
                ctx.stroke(d, with: .color(BinduTheme.inkTertiary), lineWidth: 0.8)
            }
        }
    }
}
