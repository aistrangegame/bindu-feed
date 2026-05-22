import SwiftUI

struct TokenEntryView: View {
    @EnvironmentObject private var store: FeedStore
    var onSaved: () -> Void = {}

    @State private var token: String = ""
    @FocusState private var fieldFocused: Bool

    private var canBegin: Bool {
        !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            VStack(spacing: BinduTheme.space24) {
                Spacer()

                VStack(spacing: BinduTheme.space12) {
                    Text("·")
                        .font(.system(size: 56))
                        .foregroundColor(BinduTheme.colorBindu)
                        .opacity(0.85)

                    Text("Enter your Airtable")
                        .font(.lora(18))
                        .foregroundColor(BinduTheme.inkPrimary)
                    Text("Personal Access Token")
                        .font(.lora(18))
                        .foregroundColor(BinduTheme.inkPrimary)
                }
                .multilineTextAlignment(.center)

                SecureField("", text: $token, prompt: Text("paste token")
                    .foregroundColor(BinduTheme.inkTertiary))
                    .focused($fieldFocused)
                    .font(.spaceMono(13))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .tint(BinduTheme.accent)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, BinduTheme.space16)
                    .padding(.vertical, BinduTheme.space12)
                    .panel(cornerRadius: 12, fill: BinduTheme.bgInset)
                    .padding(.horizontal, BinduTheme.space24)

                Button(action: begin) {
                    Text("Begin")
                        .font(.lora(15, weight: .medium))
                        .tracking(1)
                        .foregroundColor(canBegin ? BinduTheme.accent : BinduTheme.inkTertiary)
                        .padding(.horizontal, BinduTheme.space24)
                        .padding(.vertical, BinduTheme.space12)
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(
                                    canBegin ? BinduTheme.accent.opacity(0.55) : BinduTheme.hairline,
                                    lineWidth: 0.75
                                )
                        )
                }
                .disabled(!canBegin)

                Spacer()
            }
            .padding(.vertical, BinduTheme.space24)
        }
        .onAppear { fieldFocused = true }
    }

    private func begin() {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.saveToken(trimmed)
        onSaved()
    }
}
