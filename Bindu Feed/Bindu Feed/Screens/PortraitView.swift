import SwiftUI

// WAVE 5 · THE PORTRAIT — rupakarshini's S16, from Being's Mirror Days, the Month Mirror and the
// Living Mandala's ring. His walk, drawn back to him, with no number anywhere.
//
//   · the DAYS — one glyph for each day he walked: its colour the room he was most in, a dot
//     for each voice that gathered, an ember for each thing he sealed;
//   · the MONTH — read as one letter, built only from what is true (which rooms, which voice
//     stayed nearest, whether he sealed, what he kept), answered with: it lands · say more ·
//     leave my own word (which goes into the Codex, registered as from the Feed);
//   · the YEAR — one ring, its months shaded by how much of him is in them.
struct PortraitView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @Binding var path: [FeedRoute]

    @State private var showHub = false
    @State private var month = String(AirtableService.localDayString().prefix(7))
    @State private var answer: Answer?
    @State private var ownWord = ""
    @State private var given = false

    enum Answer { case lands, more, word }

    private let sealTypes: Set<String> = ["Ash Replied", "Return", "Walk Completed", "Kept", "Letter Sealed"]

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 34) {
                    Text("The Portrait").font(.loraItalic(28)).foregroundColor(BinduTheme.inkPrimary).padding(.top, 18)
                    yearRing.frame(height: 240).frame(maxWidth: .infinity)
                    daysGrid
                    letter
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 26)
            }
            .scrollIndicators(.hidden)
        }
        .floatingBackHub(path: $path, showHub: $showHub)
        .hubOverlay(open: $showHub, path: $path)
        .task {
            await store.loadActivityMarks()
            if store.stories.isEmpty { await store.loadStories() }
        }
    }

    // MARK: - data, derived (never stored)

    private func marks(inMonth m: String) -> [ActivityMark] { store.activityMarks.filter { $0.day.hasPrefix(m) } }

    private func room(for mark: ActivityMark) -> String? {
        guard let l = mark.link else { return nil }
        return store.stories.first { $0.id == l }?.room
    }

    private func dominantRoom(_ ms: [ActivityMark]) -> String? {
        var c: [String: Int] = [:]
        for m in ms { if let r = room(for: m) { c[r, default: 0] += 1 } }
        return c.max { $0.value < $1.value }?.key
    }

    // MARK: - the year

    private var yearRing: some View {
        let year = String(month.prefix(4))
        let counts = (1...12).map { mm -> Int in marks(inMonth: String(format: "%@-%02d", year, mm)).count }
        let top = max(1, counts.max() ?? 1)
        return Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) * 0.42
            for i in 0..<12 {
                let a0 = Angle.degrees(Double(i) * 30 - 90 + 1.5), a1 = Angle.degrees(Double(i + 1) * 30 - 90 - 1.5)
                var arc = Path()
                arc.addArc(center: c, radius: r, startAngle: a0, endAngle: a1, clockwise: false)
                let w = Double(counts[i]) / Double(top)
                let mKey = String(format: "%@-%02d", year, i + 1)
                let col = dominantRoom(marks(inMonth: mKey)).flatMap { store.room(named: $0)?.color } ?? BinduTheme.inkTertiary
                ctx.stroke(arc, with: .color(col.opacity(0.12 + 0.75 * w)), style: StrokeStyle(lineWidth: 3 + 14 * w, lineCap: .round))
                if mKey == month {
                    let mid = Angle.degrees(Double(i) * 30 - 75)
                    let p = CGPoint(x: c.x + CGFloat(cos(mid.radians)) * (r - 26), y: c.y + CGFloat(sin(mid.radians)) * (r - 26))
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 3, y: p.y - 3, width: 6, height: 6)), with: .color(BinduTheme.colorBindu))
                }
            }
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 2.5, y: c.y - 2.5, width: 5, height: 5)), with: .color(BinduTheme.colorBindu))
        }
        .contentShape(Rectangle())
        .gesture(SpatialTapGesture().onEnded { v in
            // touch a month on the ring to read it
            let size: CGFloat = 240
            let dx = Double(v.location.x - 0.5 * (UIScreen.main.bounds.width - 52)), dy = Double(v.location.y - size / 2)
            var a = atan2(dy, dx) * 180 / .pi + 90
            if a < 0 { a += 360 }
            let i = Int(a / 30) % 12
            withAnimation(.easeInOut(duration: 0.6)) { month = String(format: "%@-%02d", year, i + 1); answer = nil; given = false }
        })
    }

    // MARK: - the days

    private var daysGrid: some View {
        let ms = marks(inMonth: month)
        var byDay: [String: [ActivityMark]] = [:]
        for m in ms { byDay[m.day, default: []].append(m) }
        let days = byDay.keys.sorted()
        return VStack(alignment: .leading, spacing: 12) {
            Text(monthName(month)).spaceMonoTracked(9, em: 0.3).foregroundColor(BinduTheme.inkTertiary)
            if days.isEmpty {
                Text("No walk is drawn for this month.").font(.loraItalic(14)).foregroundColor(BinduTheme.inkTertiary)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 14) {
                ForEach(days, id: \.self) { d in dayGlyph(byDay[d] ?? []) }
            }
        }
    }

    private func dayGlyph(_ ms: [ActivityMark]) -> some View {
        let col = dominantRoom(ms).flatMap { store.room(named: $0)?.color } ?? Color(hex: "#C9A07A")
        let voices = Array(Set(ms.map(\.voice).filter { !$0.isEmpty })).sorted()
        let seals = ms.filter { sealTypes.contains($0.type) }.count
        return Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 9, y: c.y - 9, width: 18, height: 18)),
                     with: .radialGradient(Gradient(colors: [col.opacity(0.7), col.opacity(0.05)]), center: c, startRadius: 0, endRadius: 9))
            for (i, v) in voices.prefix(10).enumerated() {
                let a = Double(i) / Double(max(1, voices.count)) * 2 * .pi
                let p = CGPoint(x: c.x + CGFloat(cos(a)) * 14, y: c.y + CGFloat(sin(a)) * 14)
                let vc = store.archetype(named: v)?.color ?? BinduTheme.inkSecondary
                ctx.fill(Path(ellipseIn: CGRect(x: p.x - 1.4, y: p.y - 1.4, width: 2.8, height: 2.8)), with: .color(vc))
            }
            for k in 0..<min(seals, 3) {
                ctx.fill(Path(ellipseIn: CGRect(x: c.x - 1.6 + CGFloat(k - 1) * 4, y: c.y - 1.6, width: 3.2, height: 3.2)),
                         with: .color(BinduTheme.colorBindu))
            }
        }
        .frame(height: 36)
    }

    private func monthName(_ m: String) -> String {
        guard let d = AirtableService.dayFormatter(timeZone: .current).date(from: m + "-01") else { return m }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB"); f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "MMMM yyyy"
        return f.string(from: d)
    }

    // MARK: - the month, as one letter

    private var letterLines: [String] {
        let ms = marks(inMonth: month)
        guard !ms.isEmpty else { return [] }
        var rooms: [String: Int] = [:]
        for m in ms { if let r = room(for: m) { rooms[r, default: 0] += 1 } }
        let topRooms = rooms.sorted { $0.value > $1.value }.prefix(2).map(\.key)
        var voices: [String: Int] = [:]
        for m in ms where !m.voice.isEmpty { voices[m.voice, default: 0] += 1 }
        let nearest = voices.max { $0.value < $1.value }?.key
        let sealed = ms.contains { sealTypes.contains($0.type) }
        var out: [String] = []
        if topRooms.count == 2 {
            out.append("This month the walk went mostly through \(topRooms[0]) and \(topRooms[1]).")
        } else if let r = topRooms.first {
            out.append("This month the walk kept returning to \(r).")
        } else {
            out.append("This month the walk was quiet, and still it was walked.")
        }
        if let v = nearest { out.append("\(v) was the voice that stayed nearest.") }
        out.append(sealed ? "Some of it you sealed in your own words." : "Nothing was sealed, and nothing needed to be.")
        return out
    }

    private var keptThisMonth: [KeptLine] { store.kept.filter { $0.day.hasPrefix(month) } }

    private var letter: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !letterLines.isEmpty {
                Text("the month, as a letter").spaceMonoTracked(8, em: 0.3).foregroundColor(BinduTheme.inkTertiary)
                Text(letterLines.joined(separator: " "))
                    .font(.loraItalic(18)).foregroundColor(BinduTheme.inkPrimary).lineSpacing(7)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 18) {
                    answerButton("it lands", .lands)
                    answerButton("say more", .more)
                    answerButton("leave my own word", .word)
                }
                .padding(.top, 6)
                switch answer {
                case .lands:
                    Text("It is held.").font(.loraItalic(14)).foregroundColor(BinduTheme.inkSecondary)
                case .more:
                    if keptThisMonth.isEmpty {
                        Text("You kept no lines this month; the walk was the whole of it.").font(.loraItalic(14)).foregroundColor(BinduTheme.inkSecondary)
                    } else {
                        ForEach(keptThisMonth) { k in
                            Text(k.line).font(.loraItalic(15)).foregroundColor(BinduTheme.inkSecondary).lineSpacing(5)
                        }
                    }
                case .word:
                    if given {
                        Text("In the Codex, from here.").font(.loraItalic(14)).foregroundColor(BinduTheme.inkSecondary)
                    } else {
                        TextField("", text: $ownWord, prompt: Text("your word for the month").foregroundColor(BinduTheme.inkTertiary))
                            .font(.loraItalic(16)).foregroundColor(BinduTheme.colorAsh)
                            .submitLabel(.done)
                            .onSubmit {
                                let w = ownWord
                                Task {
                                    if await store.giveToCodex(name: "Month mirror — \(monthName(month))", words: w) {
                                        withAnimation { given = true }
                                    }
                                }
                            }
                    }
                case .none:
                    EmptyView()
                }
            }
        }
    }

    private func answerButton(_ label: String, _ a: Answer) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.5)) { answer = a } } label: {
            Text(label).spaceMonoTracked(8, em: 0.15)
                .foregroundColor(answer == a ? BinduTheme.colorBindu : BinduTheme.inkSecondary)
        }
        .buttonStyle(.plain)
    }
}
