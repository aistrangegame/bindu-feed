import SwiftUI

struct TokenEntryView: View {
    @EnvironmentObject private var store: FeedStore
    var onSaved: () -> Void = {}

    @State private var token: String = ""
    @FocusState private var fieldFocused: Bool

    #if DEBUG
    // Dev-only doors (never ship) — walk the Instrument, or the Rite/Gathering (canon
    // content, no PAT needed), so both can be verified without a live token.
    @State private var showInstrument = false
    @State private var showRite = false
    @State private var demoPath = NavigationPath()
    #endif

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

                #if DEBUG
                Button { showInstrument = true } label: {
                    Text("⟿ walk the Instrument")
                        .font(.spaceMono(10)).tracking(2)
                        .foregroundColor(BinduTheme.inkTertiary)
                        .padding(.top, BinduTheme.space16)
                }
                Button { showRite = true } label: {
                    Text("⟿ the Rite")
                        .font(.spaceMono(10)).tracking(2)
                        .foregroundColor(BinduTheme.inkTertiary)
                        .padding(.top, BinduTheme.space8)
                }
                #endif

                Spacer()
            }
            .padding(.vertical, BinduTheme.space24)
        }
        .onAppear { fieldFocused = true }
        #if DEBUG
        .fullScreenCover(isPresented: $showInstrument) {
            ZStack(alignment: .topTrailing) {
                InstrumentView(path: $demoPath, startZ: 0)
                Button { showInstrument = false } label: {
                    Text("✕").font(.spaceMono(15))
                        .foregroundColor(BinduTheme.inkSecondary)
                        .padding(16)
                }
            }
        }
        .fullScreenCover(isPresented: $showRite) {
            ZStack(alignment: .topTrailing) {
                RiteView(path: $demoPath, onFinish: { showRite = false })
                Button { showRite = false } label: {
                    Text("✕").font(.spaceMono(15))
                        .foregroundColor(BinduTheme.inkSecondary)
                        .padding(16)
                }
            }
        }
        #endif
    }

    private func begin() {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.saveToken(trimmed)
        onSaved()
    }
}
