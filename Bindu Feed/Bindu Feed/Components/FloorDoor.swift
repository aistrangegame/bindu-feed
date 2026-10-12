import SwiftUI

// WAVE 5 · the door in the floor beneath a sealed story. It resists: a hold of 1.25 s, a ring
// closing round a thin line, and then the floor gives.
struct FloorDoor: View {
    let color: Color
    let onOpen: () -> Void

    @State private var p: Double = 0
    @State private var holding = false
    @State private var start: Date?

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Rectangle().fill(color.opacity(0.25 + 0.5 * p)).frame(width: 64, height: 1)
                Rectangle().fill(color.opacity(0.8)).frame(width: 64 * p, height: 1)
            }
            .frame(width: 90, height: 26)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !holding else { return }
                    holding = true; start = Date(); tick()
                }
                .onEnded { _ in
                    holding = false; start = nil
                    if p < 1 { withAnimation(.easeOut(duration: 0.5)) { p = 0 } }
                })
            Text("the floor beneath").spaceMonoTracked(8, em: 0.25)
                .foregroundColor(color.opacity(0.55 + 0.4 * p))
        }
    }

    private func tick() {
        guard holding, let s = start else { return }
        p = min(1, Date().timeIntervalSince(s) / 1.25)
        if p >= 1 {
            holding = false
            onOpen()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { p = 0 }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 60) { tick() }
    }
}
