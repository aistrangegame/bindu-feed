import SwiftUI

struct CommunityPill: View {
    let room: Room
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Text(room.glyph)
                .font(.system(size: compact ? 11 : 12))
                .foregroundColor(room.color)

            Text(room.name)
                .font(roomNameFont)
                .foregroundColor(room.color.opacity(0.95))
                .lineLimit(1)
                .tracking(room.name == "The Watcher" ? 1.0 : 0)
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

    private var roomNameFont: Font {
        let size: CGFloat = compact ? 10 : 11
        switch room.name {
        case "The Descent", "The Return", "The Field":
            return .loraItalic(size)
        case "The Watcher":
            return .spaceMono(size)
        default:
            return .lora(size, weight: .medium)
        }
    }
}
