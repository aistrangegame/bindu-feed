import SwiftUI

struct VoiceAvatar: View {
    let archetype: Archetype
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            // outer glow halo
            Circle()
                .fill(archetype.color.opacity(0.22))
                .blur(radius: 4)
                .frame(width: size * 1.6, height: size * 1.6)

            // body
            Circle()
                .fill(archetype.color.opacity(0.30))
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .strokeBorder(archetype.color.opacity(0.55), lineWidth: 0.5)
                )

            Text(archetype.glyph)
                .font(.system(size: size * 0.52))
                .foregroundColor(archetype.color)
        }
        .frame(width: size, height: size)
    }
}

// Overlapping circles, first archetype layered on top.
// Background ring in bgCard keeps the overlap clean.
struct VoiceAvatarStack: View {
    let archetypes: [Archetype]
    var size: CGFloat = 22
    var maxVisible: Int = 4
    var ringColor: Color = BinduTheme.bgCard

    var body: some View {
        let visible = Array(archetypes.prefix(maxVisible))
        let overlap = size * 0.55

        HStack(spacing: -overlap) {
            ForEach(Array(visible.enumerated()), id: \.offset) { index, archetype in
                VoiceAvatar(archetype: archetype, size: size)
                    .background(
                        Circle()
                            .fill(ringColor)
                            .frame(width: size + 3, height: size + 3)
                    )
                    .zIndex(Double(visible.count - index))
            }

            if archetypes.count > maxVisible {
                Text("+\(archetypes.count - maxVisible)")
                    .font(.spaceMono(9))
                    .foregroundColor(BinduTheme.inkTertiary)
                    .padding(.leading, overlap + 4)
            }
        }
    }
}
