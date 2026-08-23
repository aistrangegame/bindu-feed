import SwiftUI

// Mirror and Signal Space aren't Airtable Room records — they're
// app-defined portals that share the Room portal visual language. Wider
// horizontal cards (full-width, stacked) rather than 2-col tiles, with
// glyph on the left and name + person-label + descriptor on the right.
// The separate tier under "AND THE FIELD TURNS TO YOU" tells the user
// these are a different kind of door: the field facing them, not a space
// they enter.
struct FieldSurfaceConfig {
    let id: String
    let glyph: String
    let color: Color
    let name: String
    let animation: GlyphAnimation
    let label: String?
    let descriptor: String?

    static let mirror = FieldSurfaceConfig(
        id: "mirror",
        glyph: "◐",
        color: BinduTheme.colorAsh,
        name: "The Mirror",
        animation: .glyphBreathe,
        label: "first person",
        descriptor: "What you have already seen, handed back."
    )

    static let signal = FieldSurfaceConfig(
        id: "signal",
        glyph: "⊙",
        color: BinduTheme.colorAshrey,
        name: "The Signal Space",
        animation: .glyphSignal,
        label: "second person",
        descriptor: "One transmission, received whole — then you leave."
    )
}

struct FieldSurfacePortalCard: View {
    let config: FieldSurfaceConfig
    var onTap: (CGPoint) -> Void

    @State private var pressed = false

    var body: some View {
        HStack(alignment: .center, spacing: BinduTheme.space16) {
            GlyphView(
                glyph: config.glyph,
                size: 38,
                color: config.color,
                animation: config.animation
            )
            .frame(width: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(config.name)
                    .font(.lora(15, weight: .medium))
                    .foregroundColor(config.color.opacity(0.88))
                    .lineLimit(1)

                if let label = config.label {
                    Text(label.uppercased())
                        .font(.spaceMono(9))
                        .tracking(2.0)
                        .foregroundColor(BinduTheme.inkTertiary)
                }

                if let descriptor = config.descriptor {
                    Text(descriptor)
                        .font(.loraItalic(13))
                        .foregroundColor(BinduTheme.inkSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer(minLength: 0)
            // the turn-card chevron (comp Room Selection TurnCard)
            Text("\u{203A}")
                .font(.system(size: 18))
                .foregroundColor(config.color.opacity(0.6))
        }
        .padding(.vertical, BinduTheme.space20)
        .padding(.horizontal, BinduTheme.space20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(config.color.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(config.color.opacity(0.22), lineWidth: 0.6)
        )
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: PortalFramePreferenceKey.self,
                    value: [config.id: proxy.frame(in: .global)]
                )
            }
        )
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: pressed)
        .contentShape(Rectangle())
        .onTapGesture { _ in
            pressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                pressed = false
                onTap(CGPoint(x: 0, y: 0))   // anchor resolved by parent via preference
            }
        }
    }
}
