import SwiftUI

// The Door's air — a field of motes that RISE on the unmet door (something coming to meet
// you) and SETTLE on the met door (the day's light has passed). The defining atmospheric
// layer on both weathers of A Strange Feed.html, absent in the first-pass Door.
struct DoorDust: View {
    var rising: Bool
    var color: Color = Color(hex: "#C9A07A")

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let W = size.width, H = size.height
                for i in 0..<16 {
                    let dep = rnd(Double(i))
                    let x = rnd(Double(i) + 1) * W + sin(t * 0.2 + Double(i)) * 8
                    let sp = (4 + dep * 12) * (rising ? 1 : 0.45)
                    // rising: drift up and wrap; settling: drift slowly down toward the floor
                    let raw = (rnd(Double(i) + 2) * H + (rising ? -t * sp : t * sp)).truncatingRemainder(dividingBy: H)
                    let y = (raw + H).truncatingRemainder(dividingBy: H)
                    let r = 0.5 + dep * 1.6
                    let a = (0.10 + dep * 0.28) * (0.5 + 0.5 * sin(t * 0.5 + Double(i)))
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                             with: .color(color.opacity(a)))
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func rnd(_ i: Double) -> Double { let x = sin(i * 127.1 + 31.4) * 43758.5453; return x - x.rounded(.down) }
}
