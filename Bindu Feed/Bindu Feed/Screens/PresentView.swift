import SwiftUI

// WAVE 3 · THE PRESENT — the axis becomes a two-way timeline.
//
// From the Chakra Game's Correspondence and his own Codex (the bidirectional soul): one line of
// light across the page, the NOW. Above it, the letters he has sealed forward — each a small
// light holding still, its seal written beneath it (a date, or a condition: when he has been
// away, when he is in the Veil, when he traces the Turning again, the next time he calls, the
// new moon). Their words stay sealed until the moment comes; then the light descends and lands
// wherever he is. Below the line runs the river of his Codex days, newest first, each a faint
// glyph; touching a day shows what he spoke that day, and lets him write BACK to that self.
struct PresentView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine
    @Binding var path: [FeedRoute]

    @State private var showHub = false
    @State private var composing: Compose?
    @State private var openDay: String?

    enum Compose: Identifiable, Hashable {
        case forward
        case back(String)
        var id: String { switch self { case .forward: return "f"; case .back(let d): return "b" + d } }
    }

    private let gold = Color(hex: "#C9A07A")

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    forwardSky
                    nowLine
                    // WAVE 5 · the walk drawn back, and the life as cloth — both below the NOW
                    HStack(spacing: 26) {
                        Button { $path.pushDissolve(FeedRoute.portrait) } label: {
                            Text("your walk, drawn ›").spaceMonoTracked(8, em: 0.2).foregroundColor(BinduTheme.inkSecondary)
                        }
                        Button { $path.pushDissolve(FeedRoute.weave) } label: {
                            Text("your life as cloth ›").spaceMonoTracked(8, em: 0.2).foregroundColor(BinduTheme.inkSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 26)
                    river
                    Color.clear.frame(height: 90)
                }
            }
            .scrollIndicators(.hidden)

            if let c = composing {
                LetterComposer(mode: c, onSeal: { body, seal in
                    store.sealLetter(body, seal: seal)
                    soundEngine.fieldThreshold(hz: 174, dur: 6)
                    withAnimation(.easeInOut(duration: 0.8)) { composing = nil }
                }, onLeave: {
                    withAnimation(.easeInOut(duration: 0.6)) { composing = nil }
                })
                .transition(.opacity)
                .zIndex(5)
            }
        }
        .floatingBackHub(path: $path, showHub: $showHub)
        .hubOverlay(open: $showHub, path: $path)
        .task { await store.loadCodexDays() }
    }

    // MARK: - above the line: letters sealed forward

    private var waiting: [Letter] { store.letters.filter { !$0.isBack && !$0.isOpen } }
    private var opened: [Letter] { store.letters.filter { !$0.isBack && $0.isOpen } }

    private var forwardSky: some View {
        VStack(spacing: 22) {
            Text("The Present")
                .font(.loraItalic(28))
                .foregroundColor(BinduTheme.inkPrimary)
                .padding(.top, 20)
            Text("above the line, what you sent ahead · below it, the days you spoke")
                .font(.lora(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            if waiting.isEmpty {
                Text("Nothing is on its way yet.")
                    .font(.loraItalic(15)).foregroundColor(BinduTheme.inkSecondary)
                    .padding(.vertical, 30)
            } else {
                VStack(spacing: 26) {
                    ForEach(Array(waiting.enumerated()), id: \.element.id) { i, l in
                        VStack(spacing: 8) {
                            Circle().fill(gold)
                                .frame(width: 6, height: 6)
                                .shadow(color: gold.opacity(0.9), radius: 8 + 4 * breath.eased(offset: Double(i) * 0.13))
                                .offset(y: CGFloat(-3 * breath.eased(offset: Double(i) * 0.13)))
                            Text(l.seal.label).font(.loraItalic(13)).foregroundColor(gold.opacity(0.85))
                            Text("sealed \(l.sealedOn)").spaceMonoTracked(7.5, em: 0.15).foregroundColor(BinduTheme.inkTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .offset(x: CGFloat((i % 3) - 1) * 60)
                    }
                }
                .padding(.vertical, 20)
            }

            Button { withAnimation(.easeInOut(duration: 0.6)) { composing = .forward } } label: {
                Text("write forward").spaceMonoTracked(9, em: 0.2)
                    .foregroundColor(gold)
                    .padding(.vertical, 10).padding(.horizontal, 18)
                    .overlay(Capsule().stroke(gold.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 26)

            if !opened.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("already reached you").spaceMonoTracked(8, em: 0.25).foregroundColor(BinduTheme.inkTertiary)
                    ForEach(opened) { l in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(l.body).font(.loraItalic(15)).foregroundColor(BinduTheme.inkSecondary).lineSpacing(5)
                            Text("sealed \(l.sealedOn) · opened \(l.openedOn)").spaceMonoTracked(7.5, em: 0.12).foregroundColor(BinduTheme.inkTertiary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.bottom, 26)
            }
        }
    }

    // MARK: - the NOW

    private var nowLine: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, BinduTheme.colorBindu.opacity(0.85), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
                .shadow(color: BinduTheme.colorBindu.opacity(0.7), radius: 6 + 4 * breath.value)
            Text("now").spaceMonoTracked(8, em: 0.4)
                .foregroundColor(BinduTheme.colorBindu)
                .padding(.horizontal, 10)
                .background(BinduTheme.bgDeep)
        }
        .padding(.vertical, 18)
    }

    // MARK: - below the line: the river of Codex days

    private struct Month: Identifiable { let id: String; let days: [String: [CodexDay]] }

    private var months: [Month] {
        var byMonth: [String: [String: [CodexDay]]] = [:]
        for d in store.codexDays { byMonth[String(d.date.prefix(7)), default: [:]][d.date, default: []].append(d) }
        return byMonth.sorted { $0.key > $1.key }.map { Month(id: $0.key, days: $0.value) }
    }

    private func color(_ category: String, _ app: String) -> Color {
        if app == "Bindu Feed" { return BinduTheme.colorBindu }
        switch category {
        case "Reflections": return Color(hex: "#9B6BD6")
        case "Ideas", "Discovery": return Color(hex: "#3AADA8")
        case "Knowledge", "Collection", "Systems": return Color(hex: "#9FB2C4")
        case "Meeting Minutes", "Work Story", "Work Stuff", "Strategy", "Agenda": return Color(hex: "#B9AEA2")
        default: return Color(hex: "#C47A52")
        }
    }

    private var river: some View {
        VStack(alignment: .leading, spacing: 26) {
            ForEach(months) { month in
                let m = month.id
                let days = month.days
                VStack(alignment: .leading, spacing: 10) {
                    Text(m).spaceMonoTracked(8, em: 0.25).foregroundColor(BinduTheme.inkTertiary)
                    // the days of that month as glyphs on one strand
                    HStack(spacing: 0) {
                        ForEach(days.keys.sorted(by: >), id: \.self) { day in
                            let ds = days[day] ?? []
                            let backs = store.letters.contains { if case .back(let d) = $0.seal { return d == day }; return false }
                            Button { withAnimation(.easeInOut(duration: 0.5)) { openDay = openDay == day ? nil : day } } label: {
                                ZStack {
                                    if backs {
                                        Circle().stroke(gold.opacity(0.7), lineWidth: 0.8).frame(width: 13, height: 13)
                                    }
                                    Circle().fill(color(ds.first?.category ?? "", ds.first?.sourceApp ?? ""))
                                        .frame(width: CGFloat(4 + min(4, ds.count) * 1.5), height: CGFloat(4 + min(4, ds.count) * 1.5))
                                        .opacity(openDay == day ? 1 : 0.6)
                                }
                                .frame(width: 22, height: 22)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer(minLength: 0)
                    }
                    if let od = openDay, let ds = days[od] {
                        dayDetail(od, ds)
                            .transition(.opacity)
                    }
                }
            }
        }
        .padding(.horizontal, 26)
    }

    private func dayDetail(_ day: String, _ ds: [CodexDay]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(day).spaceMonoTracked(8, em: 0.2).foregroundColor(BinduTheme.inkSecondary)
            ForEach(ds) { d in
                Text([d.number, d.title].filter { !$0.isEmpty }.joined(separator: "  "))
                    .font(.lora(14)).foregroundColor(BinduTheme.inkPrimary.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(store.letters.filter { if case .back(let d) = $0.seal { return d == day }; return false }) { l in
                Text(l.body).font(.loraItalic(14)).foregroundColor(gold).lineSpacing(4)
                    .padding(.leading, 10)
                    .overlay(alignment: .leading) { Rectangle().fill(gold.opacity(0.5)).frame(width: 1) }
            }
            Button { withAnimation(.easeInOut(duration: 0.6)) { composing = .back(day) } } label: {
                Text("write back to this day").spaceMonoTracked(8, em: 0.2).foregroundColor(gold).padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))
    }
}

// MARK: - the composer

struct LetterComposer: View {
    let mode: PresentView.Compose
    let onSeal: (String, LetterSeal) -> Void
    let onLeave: () -> Void

    @State private var text = ""
    @State private var choice = 0
    @State private var date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @FocusState private var focus: Bool

    private let gold = Color(hex: "#C9A07A")
    private let conditions: [(String, LetterSeal?)] = [
        ("on a day", nil),
        ("when I have been away", .absence),
        ("when I am in the Veil", .veil),
        ("when I trace the Turning again", .turning),
        ("the next time I call", .call),
        ("at the new moon", .newMoon),
    ]

    var body: some View {
        ZStack {
            Color(hex: "#07060A").opacity(0.96).ignoresSafeArea()
                .onTapGesture { focus = false }
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: onLeave) {
                        Text("leave it").spaceMonoTracked(9, em: 0.2).foregroundColor(BinduTheme.inkTertiary)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                Text(header).font(.loraItalic(20)).foregroundColor(gold)
                TextEditor(text: $text)
                    .font(.loraItalic(17))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .scrollContentBackground(.hidden)
                    .focused($focus)
                    .frame(minHeight: 170)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))

                if case .forward = mode {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("let it open").spaceMonoTracked(8, em: 0.25).foregroundColor(BinduTheme.inkTertiary)
                        ForEach(Array(conditions.enumerated()), id: \.offset) { i, c in
                            Button { choice = i } label: {
                                HStack(spacing: 10) {
                                    Circle().fill(choice == i ? gold : Color.clear)
                                        .overlay(Circle().stroke(gold.opacity(0.6), lineWidth: 0.8))
                                        .frame(width: 8, height: 8)
                                    Text(c.0).font(.lora(14)).foregroundColor(choice == i ? BinduTheme.inkPrimary : BinduTheme.inkSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        if choice == 0 {
                            DatePicker("", selection: $date, in: Date()..., displayedComponents: .date)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .tint(gold)
                        }
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    HoldEmber(duration: 1.6, color: gold, size: 60, label: "hold to seal",
                              enabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                        onSeal(text, seal)
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 26)
            .padding(.top, 60)
        }
    }

    private var header: String {
        switch mode {
        case .forward: return "To the one who will open this"
        case .back(let d): return "To the one who spoke on \(d)"
        }
    }

    private var seal: LetterSeal {
        switch mode {
        case .back(let d): return .back(d)
        case .forward:
            if let s = conditions[choice].1 { return s }
            return .date(AirtableService.dayFormatter(timeZone: .current).string(from: date))
        }
    }
}
