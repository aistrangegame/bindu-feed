import SwiftUI

struct CommunityPill: View {
    let room: Room
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Text(room.glyph)
                .font(.system(size: compact ? 11 : 12))
                .foregroundColor(room.color)

            roomName(compact ? 10 : 11)
                .foregroundColor(room.color.opacity(0.95))
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(room.color.opacity(0.14))
        )
        .overlay(
            Capsule()
                .strokeBorder(room.color.opacity(0.22), lineWidth: 0.5)
        )
    }

    // E1.18 · **THE FACE AND ITS CASE ARE ONE DECISION, SO THE SWITCH RETURNS A VIEW, NOT A
    // `Font`.** This was a `Font`-valued switch with the mono branch's tracking spelled out
    // at the call site (`room.name == "The Watcher" ? 1.0 : 0`) — the face handed over bare
    // and its two companions left to whoever drew it. Nothing enforced that pairing, which
    // is the shape the whole row is about.
    @ViewBuilder private func roomName(_ size: CGFloat) -> some View {
        switch room.name {
        case "The Descent", "The Return", "The Field":
            Text(room.name).font(.loraItalic(size))
        case "The Watcher":
            Text(room.name).spaceMonoTracked(size, em: 1 / size)
        default:
            Text(room.name).font(.lora(size, weight: .medium))
        }
    }
}
