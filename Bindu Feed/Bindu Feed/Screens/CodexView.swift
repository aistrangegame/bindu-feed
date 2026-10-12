import SwiftUI

// WAVE 3 · THE CODEX — the Feed listens, and writes back into the source it was made from.
//
// Ashrey's ruling: a real Codex section in every app, writing rows straight into the Codex
// with a register of which app they came from. Here he speaks (held ember, on-device words) or
// writes; names it or lets its first words name it; and holds to give it to the Codex. It goes
// in raw, as he said it, marked `Source App = Bindu Feed`. Before noon the page opens on the
// question the house asks of mornings: what came through the night?
//
// Below, everything this app has given the Codex, newest first — the register, made visible.
struct CodexView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @Binding var path: [FeedRoute]

    @StateObject private var ear = SpeechCapture()
    @State private var words = ""
    @State private var name = ""
    @State private var showHub = false
    @State private var given = false
    @State private var giving = false
    @FocusState private var writing: Bool

    private var morning: Bool { Calendar.current.component(.hour, from: Date()) < 12 }
    private let gaia = Color(hex: "#7FA88B")

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()
            RadialGradient(colors: [gaia.opacity(ear.listening ? 0.16 : 0.07), .clear],
                           center: .top, startRadius: 0, endRadius: 560)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: ear.listening)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("The Codex")
                        .font(.loraItalic(28))
                        .foregroundColor(BinduTheme.inkPrimary)
                        .padding(.top, 18)
                    Text(morning ? "What came through the night?" : "Speak it, or write it. It goes into the Codex as you said it.")
                        .font(.lora(15))
                        .foregroundColor(BinduTheme.inkSecondary)
                        .padding(.top, 8)

                    if given {
                        givenState.padding(.top, 60)
                    } else {
                        composer.padding(.top, 30)
                    }

                    fromThisApp.padding(.top, 56)
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 26)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .floatingBackHub(path: $path, showHub: $showHub)
        .hubOverlay(open: $showHub, path: $path)
        .onChange(of: ear.transcript) { _, t in if ear.listening { words = t } }
        .task { await store.loadCodexDays() }
        .onDisappear { ear.stop() }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 22) {
            ZStack(alignment: .topLeading) {
                if words.isEmpty && !writing {
                    Text(ear.listening ? "listening…" : "hold the ember and speak, or touch here to write")
                        .font(.loraItalic(17))
                        .foregroundColor(BinduTheme.inkTertiary)
                        .padding(.top, 8).padding(.leading, 5)
                }
                TextEditor(text: $words)
                    .font(.lora(17))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .scrollContentBackground(.hidden)
                    .focused($writing)
                    .frame(minHeight: 160)
                    .lineSpacing(8)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))

            TextField("", text: $name, prompt: Text("a name for it (or its first words will be)").foregroundColor(BinduTheme.inkTertiary))
                .font(.loraItalic(14))
                .foregroundColor(BinduTheme.inkSecondary)

            if ear.refused {
                Text("The phone has not been allowed to hear. Writing works the same.")
                    .font(.loraItalic(13)).foregroundColor(BinduTheme.inkTertiary)
            }

            HStack(alignment: .top) {
                // the ear — held, not toggled: it listens only while the hand is there
                VStack(spacing: 12) {
                    ZStack {
                        Circle().stroke(gaia.opacity(0.25), lineWidth: 1).frame(width: 64, height: 64)
                        Circle().fill(gaia.opacity(ear.listening ? 0.9 : 0.5))
                            .frame(width: ear.listening ? 18 : 12, height: ear.listening ? 18 : 12)
                            .shadow(color: gaia.opacity(0.8), radius: ear.listening ? 16 : 6)
                    }
                    .contentShape(Circle())
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !ear.listening { writing = false; ear.start(after: words) }
                        }
                        .onEnded { _ in ear.stop() })
                    Text("hold to speak").spaceMonoTracked(9, em: 0.2).foregroundColor(gaia.opacity(0.8))
                }
                Spacer()
                HoldEmber(duration: 1.4, color: BinduTheme.colorBindu, size: 64,
                          label: "hold to give it", enabled: !words.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !giving) {
                    give()
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var givenState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Circle().fill(BinduTheme.colorBindu).frame(width: 8, height: 8)
                .shadow(color: BinduTheme.colorBindu.opacity(0.8), radius: 10)
            Text("It is in the Codex now.")
                .font(.loraItalic(22)).foregroundColor(BinduTheme.inkPrimary)
            Text("from Bindu Feed · \(AirtableService.localDayString())")
                .spaceMonoTracked(9, em: 0.2).foregroundColor(BinduTheme.inkTertiary)
            Button {
                words = ""; name = ""; ear.reset(to: "")
                withAnimation(.easeInOut(duration: 0.8)) { given = false }
            } label: {
                Text("speak again").spaceMonoTracked(9, em: 0.2).foregroundColor(BinduTheme.inkSecondary).padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
    }

    private var fromThisApp: some View {
        let mine = store.codexDays.filter { $0.sourceApp == "Bindu Feed" }
        return VStack(alignment: .leading, spacing: 14) {
            Text("given from here").spaceMonoTracked(9, em: 0.3).foregroundColor(BinduTheme.inkTertiary)
            if mine.isEmpty {
                Text("Nothing yet. The first thing you give from here starts the register.")
                    .font(.loraItalic(14)).foregroundColor(BinduTheme.inkTertiary)
            }
            ForEach(mine) { d in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(d.date).spaceMonoTracked(8, em: 0.1).foregroundColor(BinduTheme.inkTertiary)
                    Text(d.title).font(.lora(15)).foregroundColor(BinduTheme.inkSecondary).lineLimit(2)
                }
            }
        }
    }

    private func give() {
        ear.stop()
        giving = true
        let w = words, n = name
        Task {
            let ok = await store.giveToCodex(name: n, words: w)
            giving = false
            if ok {
                soundEngine.fieldThreshold(hz: 136.1, dur: 7)
                withAnimation(.easeInOut(duration: 1.2)) { given = true }
            }
        }
    }
}
