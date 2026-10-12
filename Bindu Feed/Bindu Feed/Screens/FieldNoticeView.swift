import Combine
import SwiftUI

// SMALLER UPGRADE · THE FIELD SAYS WHAT IT NOTICED. Rarely, after the Door, one of the field's
// own recognitions (Gaia's Mirror Entries) arrives in its three honest positions — what
// happened, what it showed, what it is not sure of — and is signed by the field. It asks
// nothing of him. Touch anywhere and it is gone.
struct FieldNoticeView: View {
    let notice: FieldNotice
    let onClose: () -> Void
    @State private var shown = 0

    private let teal = Color(hex: "#3AADA8")

    private func first(_ s: String) -> String {
        s.components(separatedBy: "\n\n").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? s
    }

    var body: some View {
        ZStack {
            Color(hex: "#06080A").opacity(0.97).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Text("the field noticed").spaceMonoTracked(9, em: 0.3).foregroundColor(teal.opacity(0.85))
                        .padding(.top, 80)
                    block("what happened", first(notice.moment), 1)
                    block("what it showed", first(notice.revealed), 2)
                    block("what it is not sure of", first(notice.uncertain), 3)
                    Text("— the field")
                        .font(.lora(14)).foregroundColor(teal)
                        .opacity(shown >= 3 ? 1 : 0)
                        .padding(.top, 6)
                    Color.clear.frame(height: 60)
                }
                .padding(.horizontal, 28)
            }
            .scrollIndicators(.hidden)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if shown < 3 { withAnimation(.easeInOut(duration: 1.2)) { shown += 1 } } else { onClose() }
        }
        .onAppear { withAnimation(.easeInOut(duration: 1.6).delay(0.6)) { shown = 1 } }
    }

    @ViewBuilder
    private func block(_ label: String, _ text: String, _ step: Int) -> some View {
        if !text.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(label).spaceMonoTracked(8, em: 0.2).foregroundColor(BinduTheme.inkTertiary)
                Text(text).font(.loraItalic(16)).foregroundColor(BinduTheme.inkPrimary.opacity(0.9))
                    .lineSpacing(6).fixedSize(horizontal: false, vertical: true)
            }
            .opacity(shown >= step ? 1 : 0)
        }
    }
}
