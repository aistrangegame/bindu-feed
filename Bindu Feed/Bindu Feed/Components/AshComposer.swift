import SwiftUI

// Inline compose area for Ash's voice. Opens when the user taps
// "What arrived for you?" — terra-edged background, warm caret,
// Lora serif input. "Post" appears top-right only when text is non-empty.
struct AshComposer: View {
    let onPost: (String) -> Void
    let onCancel: () -> Void

    @State private var text: String = ""
    @FocusState private var fieldFocused: Bool

    private let terra = BinduTheme.colorAsh

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("…")
                        .font(.lora(15))
                        .foregroundColor(BinduTheme.inkTertiary)
                        .padding(.top, 6)
                        .padding(.leading, 2)
                }
                TextEditor(text: $text)
                    .focused($fieldFocused)
                    .font(.lora(15))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .tint(terra)
                    .frame(minHeight: 88)
                    .padding(.horizontal, -4)
                    .padding(.top, -2)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(terra.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(terra.opacity(0.28), lineWidth: 0.5)
        )
        .onAppear { fieldFocused = true }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            // Manually compose Ash's avatar — the FeedStore archetype lookup
            // may not always include the Ash record, so we don't depend on it.
            ZStack {
                Circle()
                    .fill(terra.opacity(0.22))
                    .blur(radius: 4)
                    .frame(width: 44, height: 44)
                Circle()
                    .fill(terra)
                    .frame(width: 28, height: 28)
                Text("◉")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(width: 28, height: 28)

            Text("What arrived for you?")
                .font(.loraItalic(15))
                .foregroundColor(terra.opacity(0.85))
                .tracking(0.2)

            Spacer(minLength: BinduTheme.space8)

            if !trimmed.isEmpty {
                Button {
                    onPost(trimmed)
                } label: {
                    Text("Post")
                        .font(.lora(14))
                        .tracking(0.4)
                        .foregroundColor(terra)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    onCancel()
                } label: {
                    Text("×")
                        .font(.system(size: 18))
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
