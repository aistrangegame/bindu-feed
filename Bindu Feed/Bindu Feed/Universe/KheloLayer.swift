import Combine
import SwiftUI

// SMALLER UPGRADE · KHELO, ONCE A YEAR. On Holi the sky is powder. A flick of the finger throws
// colour — each throw in one of the thirteen rooms' colours — and where it lands, two stories
// from two different rooms light together for a moment, their titles side by side. Play, with
// nothing kept.
extension Sky {
    /// Rangwālī Holī — the day after the Phālguna full moon, which falls between late February
    /// and late March. Good to a day, as everything on this clock is.
    static func isHoli(_ d: Date = Date()) -> Bool {
        let cal = Calendar(identifier: .gregorian)
        guard let y = cal.date(byAdding: .day, value: -1, to: d) else { return false }
        let c = cal.dateComponents([.month, .day], from: y)
        guard let m = c.month, let day = c.day else { return false }
        let inWindow = (m == 2 && day >= 24) || (m == 3 && day <= 27)
        return inWindow && isFullMoon(y)
    }
}

/// One flick of colour, handed in by the axis (which keeps its own drag).
struct KheloFling: Equatable { let id = UUID(); let from: CGPoint; let by: CGSize }

struct KheloLayer: View {
    let fling: KheloFling?
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine

    private struct Throw: Identifiable { let id = UUID(); let at: CGPoint; let dir: CGSize; let color: Color; let born: Date; let pair: (String, String)? }
    @State private var throws_: [Throw] = []

    var body: some View {
        TimelineView(.animation) { tl in
            Canvas { ctx, size in
                for th in throws_ {
                    let t = tl.date.timeIntervalSince(th.born)
                    guard t < 5 else { continue }
                    for k in 0..<40 {
                        let spread = Double(k) * 0.157
                        let d = min(1, t / 1.2)
                        let p = CGPoint(x: th.at.x + th.dir.width * CGFloat(d) * 1.4 + CGFloat(cos(spread * 9)) * CGFloat(20 + 30 * d),
                                        y: th.at.y + th.dir.height * CGFloat(d) * 1.4 + CGFloat(sin(spread * 7)) * CGFloat(20 + 30 * d))
                        let r = 5 + 9 * d
                        ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                                 with: .radialGradient(Gradient(colors: [th.color.opacity(0.35 * (1 - t / 5)), .clear]), center: p, startRadius: 0, endRadius: r))
                    }
                    if let pair = th.pair, t > 1.0 {
                        let a = min(1, (t - 1.0) / 0.8) * (1 - max(0, t - 4) / 1)
                        let land = CGPoint(x: th.at.x + th.dir.width * 1.4, y: th.at.y + th.dir.height * 1.4)
                        ctx.draw(Text(pair.0 + "  ·  " + pair.1).font(.loraItalic(13)).foregroundColor(.white.opacity(a)), at: land)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: fling) { _, f in if let f { throwPowder(from: f.from, by: f.by) } }
    }

    private func throwPowder(from p: CGPoint, by d: CGSize) {
        let rooms = store.rooms.shuffled()
        guard let r = rooms.first else { return }
        var pair: (String, String)?
        let a = store.stories.filter { $0.room == r.name }.randomElement()
        let b = store.stories.filter { $0.room != r.name }.randomElement()
        if let a, let b { pair = (a.title, b.title) }
        throws_.append(Throw(at: p, dir: d, color: r.color, born: Date(), pair: pair))
        throws_ = throws_.filter { Date().timeIntervalSince($0.born) < 5 }
        soundEngine.fieldThreshold(hz: (r.rootHz ?? 110) * 2, dur: 3)
    }
}
