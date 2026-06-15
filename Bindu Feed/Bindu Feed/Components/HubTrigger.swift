import SwiftUI

// A quiet 2×2 dot mark — taps open the hub overlay. Sized to match
// BackChevron's footprint so the two buttons sit cleanly together when
// a screen has both.
struct HubTrigger: View {
    @Binding var open: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                open = true
            }
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) { dot; dot }
                HStack(spacing: 4) { dot; dot }
            }
            .frame(width: 34, height: 34)
            .background(
                Circle().fill(Color.white.opacity(0.04))
            )
            .overlay(
                Circle().strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
            )
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var dot: some View {
        Circle()
            .fill(BinduTheme.inkSecondary)
            .frame(width: 4, height: 4)
    }
}
