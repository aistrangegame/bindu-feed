import SwiftUI

// The house's one commit gesture, made reusable for the waves' new places: an ember he holds
// while a ring closes around it. Release early and the ring drains — nothing fails, nothing is
// lost. Reaching the full ring commits. (Compose's ember, the Call's lay-it-down, the Rite's
// seal — one grammar, padakarshini G-hold.)
struct HoldEmber: View {
    var duration: Double = 1.6
    var color: Color = BinduTheme.colorBindu
    var size: CGFloat = 64
    var label: String? = nil
    var enabled: Bool = true
    let onDone: () -> Void

    @EnvironmentObject private var breath: Breath
    @State private var progress: Double = 0
    @State private var holding = false
    @State private var start: Date?

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().stroke(color.opacity(0.14), lineWidth: 1)
                Circle().trim(from: 0, to: progress)
                    .stroke(color.opacity(0.85), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Circle().fill(color)
                    .frame(width: 10 + 6 * progress, height: 10 + 6 * progress)
                    .shadow(color: color.opacity(0.8), radius: 10 + 10 * progress)
                    .scaleEffect(0.94 + 0.12 * breath.value)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .opacity(enabled ? 1 : 0.35)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard enabled, !holding else { return }
                    holding = true
                    start = Date()
                    tick()
                }
                .onEnded { _ in
                    holding = false
                    start = nil
                    if progress < 1 { withAnimation(.easeOut(duration: 0.6)) { progress = 0 } }
                })
            if let label {
                Text(label).spaceMonoTracked(9, em: 0.2)
                    .foregroundColor(color.opacity(enabled ? 0.8 : 0.35))
            }
        }
    }

    private func tick() {
        guard holding, let s = start else { return }
        let p = min(1, Date().timeIntervalSince(s) / duration)
        progress = p
        if p >= 1 {
            holding = false
            start = nil
            onDone()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { withAnimation(.easeOut(duration: 0.6)) { progress = 0 } }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 60) { tick() }
    }
}
