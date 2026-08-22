import SwiftUI

// The threshold marker that sits below the story body.
// Hairline above + "⬡ The field gathers" in italic Lalita Lora,
// breathing opacity (0.65 ↔ 1.0, 6s loop). Its onAppear is the
// trigger that begins the sequential comment dissolve.
struct FieldGathersMarker: View {
    let onArrive: () -> Void

    @EnvironmentObject private var breath: Breath   // the one master breath
    @State private var fired = false

    // Fire when the marker actually SCROLLS INTO VIEW, not at load. The old .onAppear
    // fired immediately (the scroll column is eager), so the staggered comment reveal
    // played entirely off-screen and was never seen. Now we watch the marker's global
    // Y and begin the gathering when its top crosses into the lower ~85% of the screen.
    private func checkVisible(_ minY: CGFloat) {
        let screenH = UIScreen.main.bounds.height
        guard !fired, minY < screenH * 0.85 else { return }
        fired = true
        onArrive()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)

            HStack(spacing: 7) {
                Text("⬡")
                    .font(.system(size: 9))
                    .foregroundColor(BinduTheme.colorLalita)
                    .opacity(0.55)

                Text("The field gathers")
                    .font(.loraItalic(12))
                    .foregroundColor(BinduTheme.colorLalita)
                    .tracking(0.7)
            }
            .padding(.top, 15)
            .opacity(0.65 + 0.35 * breath.value)      // the one master breath
        }
        .padding(.horizontal, BinduTheme.space20)
        .padding(.top, 22)
        .padding(.bottom, 12)
        .background(GeometryReader { geo in
            Color.clear
                .onAppear { checkVisible(geo.frame(in: .global).minY) }
                .onChange(of: geo.frame(in: .global).minY) { _, y in checkVisible(y) }
        })
    }
}
