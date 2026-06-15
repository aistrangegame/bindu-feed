import SwiftUI

// The terra mark on Home Feed's top-right — tap to enter Ash's Voice.
// Solid terra circle with the ◉ glyph and a soft outer glow.
struct AshMark: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("◉")
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.88))
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(BinduTheme.colorAsh)
                )
                .shadow(color: BinduTheme.colorAsh.opacity(0.4), radius: 8)
        }
        .buttonStyle(.plain)
    }
}
