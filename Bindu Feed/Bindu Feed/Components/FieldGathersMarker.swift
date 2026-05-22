import SwiftUI

// The threshold marker that sits below the story body.
// Hairline above + "⬡ The field gathers" in italic Lalita Lora,
// breathing opacity (0.65 ↔ 1.0, 6s loop). Its onAppear is the
// trigger that begins the sequential comment dissolve.
struct FieldGathersMarker: View {
    let onArrive: () -> Void

    @State private var breathing = false

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
            .opacity(breathing ? 1.0 : 0.65)
        }
        .padding(.horizontal, BinduTheme.space20)
        .padding(.top, 22)
        .padding(.bottom, 12)
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                breathing = true
            }
            onArrive()
        }
    }
}
