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
    /// The comp's `riseIn` — the element also lifts from `rise` points below as it fades in.
    /// 0 = a pure dissolve (the earlier behaviour).
    var rise: CGFloat = 0
    /// F7.4 · the comp's `substrateArrive` ends at **`opacity: 0.72`**, not 1 — the roots
    /// arrive quieter than the lenses and STAY quieter. Weight is part of the sequence:
    /// the gathering says *the lenses, then the roots more softly, then him*.
    var settledOpacity: Double = 1
    @ViewBuilder let content: () -> Content

    @State private var visible = false

    var body: some View {
        content()
            .opacity(visible ? settledOpacity : 0)
            .offset(y: visible ? 0 : rise)
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
