import SwiftUI

// WAVE 2 · READ BY HAND — the second door into every story, of equal weight to reading it.
//
// From Learning's Voice: the words land only while his finger rests on the glass, at the
// room's own pace, and every time he lifts it the place he stayed is marked with an ember.
// The landing line (the story's closing line, or its last sentence) arrives slower, in the
// room's colour — the heart phrase. A double touch keeps the sentence he is on into his book.
//
// The close gives back WHERE HE STAYED — the sentences he held longest, never as a number —
// and only then says whose voice this was: *this came through you*, his Codex mark and the
// day he spoke it. The transmission turns out to have been his own voice all along.
struct ReadByHandView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @Binding var path: [FeedRoute]
    let story: Story

    private struct Word: Identifiable { let id: Int; let text: String; let sentence: Int; let landing: Bool }

    @State private var words: [Word] = []
    @State private var sentences: [String] = []
    @State private var revealed = 0
    @State private var touching = false
    @State private var lastStep = Date()
    @State private var liftedAt: Date?
    @State private var embers: [Int: Double] = [:]      // word index → seconds stayed after it
    @State private var stays: [String: Double] = [:]    // sentence → seconds stayed
    @State private var keptNow: Set<Int> = []
    @State private var phase: Phase = .reading
    @State private var closeStep = 0
    @State private var started = false

    private enum Phase { case reading, close }

    private var room: Room? { store.room(named: story.room) }
    private var accent: Color { room?.color ?? BinduTheme.colorLalita }

    /// Words per second by the room's own weather: the rooms that go down read slowest.
    private var pace: Double {
        switch story.room {
        case "The Descent", "The Forgetting": return 1.7
        case "The Body", "The Watcher", "The Remembering": return 2.0
        case "The Signal", "The Forge", "A Maya Game": return 2.9
        default: return 2.4
        }
    }

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()
            RadialGradient(colors: [accent.opacity(touching ? 0.10 : 0.05), .clear],
                           center: .bottom, startRadius: 0, endRadius: 520)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: touching)

            switch phase {
            case .reading: reading
            case .close:   closing
            }

            VStack {
                HStack {
                    BackChevron { leave() }
                    Spacer()
                }
                .padding(.horizontal, BinduTheme.space16)
                .padding(.top, 6)
                Spacer()
            }
        }
        .onAppear(perform: prepare)
        .sonicContext(room.map { SonicContext.room($0) } ?? .base)
    }

    // MARK: - Reading

    private var reading: some View {
        GeometryReader { g in
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(story.title)
                                .font(.lora(19, weight: .medium))
                                .foregroundColor(BinduTheme.inkSecondary)
                                .padding(.bottom, 28)
                            revealedText
                                .lineSpacing(14)
                                .fixedSize(horizontal: false, vertical: true)
                            Color.clear.frame(height: 1).id("end")
                            Color.clear.frame(height: g.size.height * 0.45)
                        }
                        .padding(.horizontal, 26)
                        .padding(.top, 70)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: revealed) { _, _ in
                        withAnimation(.easeOut(duration: 0.6)) { proxy.scrollTo("end", anchor: .center) }
                    }
                }
                // the whole page is the hand's
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { _ in press() }
                        .onEnded { _ in lift() })
                    .simultaneousGesture(TapGesture(count: 2).onEnded { keepCurrent() })

                if !started {
                    VStack(spacing: 10) {
                        Spacer()
                        Circle().fill(accent).frame(width: 7, height: 7)
                            .shadow(color: accent.opacity(0.8), radius: 10)
                        Text("rest a finger to read")
                            .spaceMonoTracked(9, em: 0.2)
                            .foregroundColor(BinduTheme.inkMuted)
                        Spacer().frame(height: 90)
                    }
                    .allowsHitTesting(false)
                    .transition(.opacity)
                }
            }
        }
    }

    /// The words so far, with an ember after every place he lifted his hand.
    private var revealedText: Text {
        var t = Text("")
        var lastSentence = -1
        for w in words.prefix(revealed) {
            if w.sentence != lastSentence, lastSentence >= 0, paragraphBreak(before: w.sentence) {
                t = t + Text("\n\n")
            } else if lastSentence >= 0 {
                t = t + Text(" ")
            }
            lastSentence = w.sentence
            let word = Text(w.text)
                .font(w.landing ? .loraItalic(18.5) : .lora(17.5))
                .foregroundColor(w.landing ? accent : BinduTheme.inkPrimary.opacity(keptNow.contains(w.sentence) ? 1 : 0.92))
            t = t + word
            if let s = embers[w.id], s > 0.4 {
                t = t + Text(s > 3 ? " ●" : " •").font(.system(size: s > 3 ? 9 : 7)).foregroundColor(accent.opacity(0.85))
            }
        }
        return t
    }

    @State private var paragraphOf: [Int] = []
    private func paragraphBreak(before sentence: Int) -> Bool {
        guard sentence > 0, sentence < paragraphOf.count else { return false }
        return paragraphOf[sentence] != paragraphOf[sentence - 1]
    }

    // MARK: - The hand

    private func prepare() {
        let split = Sentences.split(story.body)
        sentences = split.map { $0.text }
        paragraphOf = split.map { $0.paragraph }
        let landingText = story.closingLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let landingIndex: Int = {
            if !landingText.isEmpty, let i = sentences.lastIndex(where: { $0.contains(landingText) || landingText.contains($0) }) { return i }
            return max(0, sentences.count - 1)
        }()
        var out: [Word] = []
        for (si, s) in sentences.enumerated() {
            for w in s.split(separator: " ", omittingEmptySubsequences: true) {
                out.append(Word(id: out.count, text: String(w), sentence: si, landing: si == landingIndex))
            }
        }
        words = out
    }

    private func press() {
        guard phase == .reading, !touching else { return }
        touching = true
        if !started { withAnimation(.easeOut(duration: 0.8)) { started = true } }
        if let l = liftedAt, revealed > 0 {
            let held = Date().timeIntervalSince(l)
            embers[revealed - 1, default: 0] += held
            let s = sentences[words[revealed - 1].sentence]
            stays[s, default: 0] += held
        }
        liftedAt = nil
        lastStep = Date()
        step()
    }

    private func lift() {
        touching = false
        liftedAt = Date()
        if revealed >= words.count, !words.isEmpty { finish() }
    }

    /// One word at a time while the finger rests; the landing line at half the pace.
    private func step() {
        guard touching, phase == .reading, revealed < words.count else { return }
        let w = words[revealed]
        let gap = (1.0 / pace) * (w.landing ? 2.0 : 1.0) * (w.text.last.map { ".?!,;:—".contains($0) } == true ? 1.6 : 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + gap) {
            guard touching, phase == .reading, revealed < words.count else { return }
            withAnimation(.easeOut(duration: 0.35)) { revealed += 1 }
            // the reading itself counts as staying, sentence by sentence
            stays[sentences[w.sentence], default: 0] += gap
            if revealed == words.count { soundEngine.fieldThreshold(hz: 136.1, dur: 6) }
            step()
        }
    }

    private func keepCurrent() {
        guard revealed > 0 else { return }
        let si = words[revealed - 1].sentence
        guard !keptNow.contains(si) else { return }
        keptNow.insert(si)
        store.keep(sentences[si], from: story)
        soundEngine.fieldThreshold(hz: 174, dur: 3)
    }

    // MARK: - Where you stayed

    private func finish() {
        guard phase == .reading else { return }
        store.recordStays(stays, for: story.id)
        withAnimation(.easeInOut(duration: 1.4)) { phase = .close }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { withAnimation(.easeInOut(duration: 1.6)) { closeStep = 1 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { withAnimation(.easeInOut(duration: 2.0)) { closeStep = 2 } }
    }

    private var stayedLines: [String] {
        let ranked = stays.sorted { $0.value > $1.value }.map(\.key)
        let top = Array(ranked.prefix(3))
        return sentences.filter { top.contains($0) }      // in the order they stood
    }

    private var spokenOn: String {
        guard let d = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC")!).date(from: story.sourceDate) else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: d)
    }

    private var closing: some View {
        VStack(spacing: 26) {
            Spacer()
            Text("where you stayed")
                .spaceMonoTracked(9, em: 0.3)
                .foregroundColor(accent.opacity(0.8))
            VStack(spacing: 18) {
                ForEach(stayedLines, id: \.self) { line in
                    HStack(alignment: .top, spacing: 10) {
                        Circle().fill(accent.opacity(0.8)).frame(width: 5, height: 5).padding(.top, 9)
                        Text(line)
                            .font(.loraItalic(18))
                            .foregroundColor(BinduTheme.inkPrimary)
                            .lineSpacing(7)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 30)

            VStack(spacing: 8) {
                Text("This came through you")
                    .font(.lora(15))
                    .foregroundColor(BinduTheme.inkSecondary)
                Text([story.codexId, spokenOn].filter { !$0.isEmpty }.joined(separator: " · "))
                    .spaceMonoTracked(9, em: 0.2)
                    .foregroundColor(BinduTheme.colorAsh.opacity(0.85))
            }
            .opacity(closeStep >= 1 ? 1 : 0)

            Text("— Ashrey")
                .font(.lora(15))
                .foregroundColor(BinduTheme.colorAsh)
                .opacity(closeStep >= 2 ? 1 : 0)

            Spacer()
            Button { leave() } label: {
                Text("back to the story").spaceMonoTracked(9, em: 0.2)
                    .foregroundColor(BinduTheme.inkTertiary)
                    .padding(14)
            }
            .buttonStyle(.plain)
            .opacity(closeStep >= 2 ? 1 : 0)
            .padding(.bottom, 30)
        }
    }

    private func leave() {
        if phase == .reading, !stays.isEmpty { store.recordStays(stays, for: story.id) }
        $path.popDissolve()
    }
}
