import SwiftUI

// WAVE 2 · ROOMS THAT CHANGE IF HE STAYS — Mandala's adaptation clock, given to the Rooms.
// A room is a place, and places answer time spent in them. At about a minute the room
// SETTLES — its light deepens, its glyph slows into its own breath. At about four minutes,
// reached only by staying, the room TURNS ITS OWN PREMISE: one line arrives under the
// blurb, and the glyph does the thing the room has been waiting to do — the Forgetting's
// ring closes, the Watcher blinks, the Signal's pulse finally lands. Leaving resets nothing
// anywhere but here; there is no record and no count, only a room that met him.
enum RoomStay {
    static let settleAt: TimeInterval = 60
    static let turnAt: TimeInterval = 240

    /// The premise each room turns into, for the one who stayed.
    static let turn: [String: String] = [
        "A Maya Game":     "You stayed. The game noticed the one watching it.",
        "The Descent":     "There was no bottom. Only the falling, and you, unafraid of it.",
        "The Thread":      "Every thread you followed was one thread, following you home.",
        "The Garden":      "Nothing here was planted. All of it was allowed.",
        "The Forge":       "The maker and the made were struck from one fire.",
        "The Body":        "Before any story, this. One breath, already enough.",
        "The Forgetting":  "The loop closes. You were the one who noticed it.",
        "The Watcher":     "The watcher blinks. For one moment, only seeing.",
        "The Remembering": "You did not remember it. It remembered you.",
        "The Signal":      "It landed. It was always landing.",
        "The Return":      "You never left. You came back only to see that.",
        "The Circle":      "Every face at the table was one face, passing the bread.",
        "The Field":       "Thirteen rooms, one ground. You are standing on it.",
    ]
}

/// The glyph's own act, drawn over it once the room has turned.
struct RoomTurnMark: View {
    let roomName: String
    let color: Color
    let size: CGFloat
    let turned: Double          // 0 → 1 over the turn's arrival

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, sz in
                let c = CGPoint(x: sz.width / 2, y: sz.height / 2)
                let r = size * 0.78
                switch roomName {
                case "The Forgetting":
                    // the ring closes — a gap that narrows to nothing
                    let gap = (1 - turned) * 0.22
                    var ring = Path()
                    ring.addArc(center: c, radius: r, startAngle: .radians(-.pi / 2 + gap * .pi),
                                endAngle: .radians(1.5 * .pi - gap * .pi), clockwise: false)
                    ctx.stroke(ring, with: .color(color.opacity(0.75 * turned)), lineWidth: 1.2)
                case "The Watcher":
                    // one slow blink, every eleven seconds, once turned
                    let ph = (t.truncatingRemainder(dividingBy: 11)) / 11
                    let lid = ph < 0.06 ? sin(ph / 0.06 * .pi) : 0
                    let h = r * 2 * lid * turned
                    ctx.fill(Path(CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: h / 2)), with: .color(BinduTheme.bgDeep))
                    ctx.fill(Path(CGRect(x: c.x - r, y: c.y + r - h / 2, width: r * 2, height: h / 2)), with: .color(BinduTheme.bgDeep))
                case "The Signal":
                    // the pulse that always went out now comes IN and lands at the glyph
                    let ph = (t.truncatingRemainder(dividingBy: 4)) / 4
                    let rr = r * 2.6 * (1 - ph)
                    ctx.stroke(Path(ellipseIn: CGRect(x: c.x - rr, y: c.y - rr, width: rr * 2, height: rr * 2)),
                               with: .color(color.opacity(0.5 * ph * turned)), lineWidth: 1)
                default:
                    // every other room: one closing circle of its own colour, breathing
                    let br = 0.5 + 0.5 * sin(t * 2 * .pi / 10)
                    ctx.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                               with: .color(color.opacity((0.25 + 0.25 * br) * turned)), lineWidth: 0.8)
                }
            }
        }
        .frame(width: size * 3, height: size * 3)
        .allowsHitTesting(false)
    }
}
