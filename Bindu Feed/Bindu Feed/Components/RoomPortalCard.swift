import SwiftUI

struct PortalFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct RoomPortalCard: View {
    let room: Room
    var fullWidth: Bool = false
    var onTap: (CGPoint) -> Void

    @State private var pressed = false

    var body: some View {
        let h: CGFloat = fullWidth ? 150 : 160
        VStack(spacing: BinduTheme.space12) {
            Spacer(minLength: 0)

            GlyphView(
                glyph: room.glyph,
                size: max(room.glyphSize, 44),
                color: room.color,
                animation: room.animation
            )
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            Text(room.name)
                .font(nameFont)
                .foregroundColor(room.color.opacity(0.80))
                .tracking(room.name == "The Watcher" ? 1.8 : 0)
                .lineLimit(1)
        }
        .padding(.vertical, BinduTheme.space16)
        .padding(.horizontal, BinduTheme.space12)
        .frame(maxWidth: .infinity, minHeight: h, maxHeight: h, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(room.color.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(room.color.opacity(0.22), lineWidth: 0.6)
        )
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: PortalFramePreferenceKey.self,
                    value: [room.id: proxy.frame(in: .global)]
                )
            }
        )
        .scaleEffect(pressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: pressed)
        .contentShape(Rectangle())
        .onTapGesture { location in
            // location is in local coords; we report the room id and let the
            // parent look up the global frame center via the preference key.
            _ = location
            // Bounce press visually then call onTap.
            pressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                pressed = false
                onTap(CGPoint(x: 0, y: 0)) // anchor resolved by parent via preference
            }
        }
    }

    private var nameFont: Font {
        let size: CGFloat = 11
        switch room.name {
        case "The Descent", "The Return", "The Field":
            return .loraItalic(size, weight: .medium)
        case "The Watcher":
            return .spaceMono(size)
        default:
            return .lora(size, weight: .medium)
        }
    }
}

// Full-screen flood: a circle in `color` centered at `anchor`,
// scaling from 0.01 → 10x viewport over 0.6s ease-in.
struct FloodOverlay: View {
    let color: Color
    let anchor: CGPoint
    var glyph: String? = nil            // the room's mark, expanding as the colour floods
    @Binding var phase: Phase

    enum Phase {
        case idle
        case expanding
    }

    var body: some View {
        GeometryReader { proxy in
            let size = max(proxy.size.width, proxy.size.height) * 2.2
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .position(anchor)
                    .scaleEffect(phase == .expanding ? 1.0 : 0.001, anchor: .center)
                    .opacity(phase == .expanding ? 1.0 : 0.0)
                // the glyph swells to fill the screen as the room takes you in (comp scale 11)
                if let glyph {
                    Text(glyph)
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                        .position(anchor)
                        .scaleEffect(phase == .expanding ? 6 : 1, anchor: .center)
                        .opacity(phase == .expanding ? 0.3 : 0)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
