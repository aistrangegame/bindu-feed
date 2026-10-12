import Combine
import SwiftUI

// WAVE 2 · WHAT YOU KEPT — his commonplace book. Every line he held, from any story, in the
// order he found it; the story and the day beneath each, and room for one word of his own in
// the margin. Nothing counted, nothing ranked.
//
// Above the lines, only when it is true: WHAT KEEPS CALLING — a word his own kept lines share
// across three or more rooms, drawn as those rooms' lights joined by one dashed ember thread.
// When nothing crosses three rooms, nothing is said.
struct BookView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @Binding var path: [FeedRoute]

    @State private var showHub = false
    @State private var editing: String?
    @State private var draft = ""
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("What you kept")
                        .font(.loraItalic(26))
                        .foregroundColor(BinduTheme.inkPrimary)
                        .padding(.top, 18)
                    Text("every line you held, in the order you found it")
                        .font(.lora(13))
                        .foregroundColor(BinduTheme.inkTertiary)
                        .padding(.top, 6)

                    if let calling = store.keepsCalling() {
                        callingThread(calling)
                            .padding(.top, 30)
                    }

                    if store.kept.isEmpty {
                        Text("Nothing kept yet. Hold any line in a story, and it comes here.")
                            .font(.loraItalic(15))
                            .foregroundColor(BinduTheme.inkSecondary)
                            .padding(.top, 60)
                    }

                    VStack(alignment: .leading, spacing: 34) {
                        ForEach(store.kept) { k in entry(k) }
                    }
                    .padding(.top, 36)

                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 26)
            }
            .scrollIndicators(.hidden)
        }
        .floatingBackHub(path: $path, showHub: $showHub)
        .hubOverlay(open: $showHub, path: $path)
        .task { await store.loadKept(); if store.stories.isEmpty { await store.loadStories() } }
    }

    private func story(for k: KeptLine) -> Story? {
        guard let id = k.storyId else { return nil }
        return store.stories.first { $0.id == id }
    }

    @ViewBuilder
    private func entry(_ k: KeptLine) -> some View {
        let st = story(for: k)
        let color = st.flatMap { store.room(named: $0.room)?.color } ?? BinduTheme.colorLalita
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Rectangle().fill(color.opacity(0.7)).frame(width: 1.5)
                Text(k.line)
                    .font(.loraItalic(18))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .lineSpacing(7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.6) {
                if let st { $path.pushDissolve(.story(st)) }
            }

            HStack(spacing: 8) {
                if let st {
                    Text(st.title).font(.lora(12)).foregroundColor(color.opacity(0.8)).lineLimit(1)
                }
                if !k.day.isEmpty {
                    Text(k.day).spaceMonoTracked(8, em: 0.15).foregroundColor(BinduTheme.inkTertiary)
                }
            }
            .padding(.leading, 14)

            margin(k)
                .padding(.leading, 14)
        }
    }

    @ViewBuilder
    private func margin(_ k: KeptLine) -> some View {
        if editing == k.id {
            HStack(spacing: 8) {
                TextField("", text: $draft, prompt: Text("your word").foregroundColor(BinduTheme.inkTertiary))
                    .font(.loraItalic(14))
                    .foregroundColor(BinduTheme.colorAsh)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { commit(k) }
                Button { commit(k) } label: {
                    Circle().fill(BinduTheme.colorAsh).frame(width: 6, height: 6).padding(8)
                }
                .buttonStyle(.plain)
            }
        } else if !k.note.isEmpty {
            Text(k.note)
                .font(.loraItalic(14))
                .foregroundColor(BinduTheme.colorAsh.opacity(0.9))
                .onTapGesture { begin(k) }
        } else {
            Button { begin(k) } label: {
                Text("+ a word of yours").spaceMonoTracked(8, em: 0.15)
                    .foregroundColor(BinduTheme.inkTertiary.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
    }

    private func begin(_ k: KeptLine) {
        draft = k.note
        editing = k.id
        focused = true
    }

    private func commit(_ k: KeptLine) {
        store.setNote(draft.trimmingCharacters(in: .whitespacesAndNewlines), on: k)
        editing = nil
        focused = false
    }

    // MARK: - What keeps calling

    private func callingThread(_ c: (word: String, rooms: [String])) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("what keeps calling")
                .spaceMonoTracked(9, em: 0.3)
                .foregroundColor(BinduTheme.colorBindu.opacity(0.8))
            Canvas { ctx, size in
                let n = c.rooms.count
                let pts: [CGPoint] = (0..<n).map { i in
                    let x = size.width * (0.1 + 0.8 * Double(i) / Double(max(1, n - 1)))
                    let y = size.height * (0.5 + 0.28 * sin(Double(i) * 2.1))
                    return CGPoint(x: x, y: y)
                }
                var thread = Path()
                for (i, p) in pts.enumerated() { if i == 0 { thread.move(to: p) } else { thread.addLine(to: p) } }
                ctx.stroke(thread, with: .color(BinduTheme.colorBindu.opacity(0.55 + 0.3 * breath.value)),
                           style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
                for (i, p) in pts.enumerated() {
                    let col = store.room(named: c.rooms[i])?.color ?? BinduTheme.inkSecondary
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 10, y: p.y - 10, width: 20, height: 20)),
                             with: .radialGradient(Gradient(colors: [col.opacity(0.5), .clear]), center: p, startRadius: 0, endRadius: 10))
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 2.5, y: p.y - 2.5, width: 5, height: 5)), with: .color(col))
                }
            }
            .frame(height: 70)
            Text(c.word)
                .font(.loraItalic(22))
                .foregroundColor(BinduTheme.inkPrimary)
            Text(c.rooms.joined(separator: " · "))
                .font(.lora(12))
                .foregroundColor(BinduTheme.inkTertiary)
        }
    }
}
