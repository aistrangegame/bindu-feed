import SwiftUI

// When a Field Comment's body is just "·", we render the whole
// comment card as a single large centered dot with an ember glow.
// No avatar, no name, no role, no resonance. Just presence.
struct BinduSilenceCard: View {
    var body: some View {
        ZStack {
            // Subtle warm radial wash behind the dot.
            RadialGradient(
                colors: [BinduTheme.colorBindu.opacity(0.22), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 80
            )
            .frame(width: 160, height: 160)

            Text("·")
                .font(.lora(48))
                .foregroundColor(BinduTheme.colorBindu)
                .shadow(color: BinduTheme.colorBindu.opacity(0.45), radius: 14)
                .offset(y: -14) // optical centering — the lora dot sits low in its em-box
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(BinduTheme.bgInset)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
        )
    }
}
