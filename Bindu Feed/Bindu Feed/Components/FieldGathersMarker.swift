import SwiftUI

// The threshold marker that sits below the story body.
// Hairline above + "⬡ The field gathers" in italic Lalita Lora,
// breathing opacity (0.65 ↔ 1.0, 6s loop). Its onAppear is the
// trigger that begins the sequential comment dissolve.
struct FieldGathersMarker: View {
    let onArrive: () -> Void

    @EnvironmentObject private var breath: Breath   // the one master breath

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
        .onAppear { onArrive() }
    }
}
