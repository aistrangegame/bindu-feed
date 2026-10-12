import Combine
import SwiftUI

// THE REST · LEELA → ACT → RETURN (Codex C-1330, C-1074). A seed he offered to his day leaves an
// open thread at the top of the Feed — a thin violet line, nothing more — until he comes back
// with one line about what happened. Then the thread closes. No reminder, no count.
struct SeedThread: View {
    @EnvironmentObject private var store: FeedStore
    @State private var open = false
    @State private var line = ""
    @FocusState private var focus: Bool

    private let violet = Color(hex: "#9B6BD6")

    var body: some View {
        if store.openSeed != nil {
            VStack(alignment: .leading, spacing: 10) {
                Button { withAnimation(.easeInOut(duration: 0.6)) { open.toggle(); focus = open } } label: {
                    HStack(spacing: 10) {
                        Rectangle().fill(violet.opacity(0.7)).frame(width: 26, height: 1)
                        Text("the seed you took · come back with a line").spaceMonoTracked(8, em: 0.2)
                            .foregroundColor(violet.opacity(0.85))
                    }
                }
                .buttonStyle(.plain)
                if open {
                    HStack(spacing: 10) {
                        TextField("", text: $line, prompt: Text("what happened").foregroundColor(BinduTheme.inkTertiary))
                            .font(.loraItalic(15)).foregroundColor(BinduTheme.inkPrimary)
                            .focused($focus)
                            .submitLabel(.done)
                            .onSubmit(close)
                        Button(action: close) {
                            Circle().fill(violet).frame(width: 7, height: 7).padding(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity)
                }
            }
        }
    }

    private func close() {
        store.returnFromSeed(line)
        line = ""
        open = false
    }
}
