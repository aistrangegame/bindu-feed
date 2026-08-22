import SwiftUI

// Holds opacity=0 until `triggered` is true, then fades in over `duration`
// after `delay` seconds. Uses its own @State so the animation fires correctly
// regardless of whether the view materializes before or after `triggered`
// flips — `.animation(value: triggered)` would silently no-op when a view
// is first rendered with `triggered` already true.
struct StaggeredReveal<Content: View>: View {
    let triggered: Bool
    let delay: Double
    let duration: Double
    @ViewBuilder let content: () -> Content

    @State private var visible = false

    var body: some View {
        content()
            .opacity(visible ? 1 : 0)
            .onAppear { revealIfReady() }
            .onChange(of: triggered) { revealIfReady() }
    }

    private func revealIfReady() {
        guard triggered, !visible else { return }
        withAnimation(.easeOut(duration: duration).delay(delay)) {
            visible = true
        }
    }
}
