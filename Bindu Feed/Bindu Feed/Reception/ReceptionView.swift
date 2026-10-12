import Combine
import SwiftUI
import UIKit

// SELF-KATHAS · the reception. A story is received in its room's grammar before the page as
// it always was lies under it; the moment the grammar completes — or he asks to read it
// plainly, the one way out of every grammar — the page dissolves up, exactly as it was.
//
// Every grammar keeps an equal path for stillness and for touch: nothing here can be made
// unreachable to a body that cannot do its gesture.

struct ReceptionView: View {
    let story: Story
    let grammar: Grammar
    let color: Color
    var prelude: Bool = false          // the signature `dotBecomesPlace` — a white dot first
    var echo: String? = nil            // The Signal's line that arrives before its question
    let onPass: () -> Void             // The Watcher's "pass": leave the story
    let onReceived: () -> Void

    @State private var leaving = false
    @State private var preluding: Bool

    init(story: Story, grammar: Grammar, color: Color, prelude: Bool = false, echo: String? = nil,
         onPass: @escaping () -> Void, onReceived: @escaping () -> Void) {
        self.story = story; self.grammar = grammar; self.color = color
        self.prelude = prelude; self.echo = echo
        self.onPass = onPass; self.onReceived = onReceived
        _preluding = State(initialValue: prelude)
    }

    var body: some View {
        let k = Katha(story: story, color: color)
        ZStack(alignment: .bottom) {
            (grammar == .byTheBody ? Color.black : BinduTheme.bgDeep).ignoresSafeArea()
            if preluding {
                DotBecomesPlace { withAnimation(.easeInOut(duration: 1.2)) { preluding = false } }
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    Text(story.title)
                        .font(.lora(14, weight: .medium))
                        .foregroundColor(BinduTheme.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 56)
                        .padding(.top, 62)
                        .padding(.bottom, 8)
                    stage(k)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .transition(.opacity)
            }
            Button { finish() } label: {
                Text("read it plainly")
                    .spaceMonoTracked(8, em: 0.22)
                    .foregroundColor(BinduTheme.inkTertiary)
                    .padding(.horizontal, 18).padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 14)
        }
    }

    @ViewBuilder
    private func stage(_ k: Katha) -> some View {
        switch grammar {
        case .twoSided:       TwoSidedPage(k: k, done: finish)
        case .ripens:         RipensUnwatched(k: k, done: finish)
        case .thirdDoor:      ThirdDoor(k: k, pass: onPass, done: finish)
        case .peel:           PeelTheWant(k: k, done: finish)
        case .fromTheEnd:     FromTheEnd(k: k, done: finish)
        case .dress:          TheDress(k: k, done: finish)
        case .pauses:         ThePauses(k: k, done: finish)
        case .byTheBody:      ByTheBody(k: k, done: finish)
        case .oneHouse:       OneHouse(k: k, done: finish)
        case .rings:          WideningRings(k: k, done: finish)
        case .beforeQuestion: BeforeTheQuestion(k: k, echo: echo, done: finish)
        case .stopTheLine:    StopTheLine(k: k, done: finish)
        case .baton:          TheBaton(k: k, done: finish)
        }
    }

    private func finish() {
        guard !leaving else { return }
        leaving = true
        onReceived()
    }
}

// MARK: - A Maya Game · the two-sided page

/// He enters by the side he chooses. The light side reads forward from the opening; the dark
/// side reads backward from the landing. Both end at the same middle page, which comes with
/// no verdict. Turn it over and the other side is still there.
struct TwoSidedPage: View {
    let k: Katha
    let done: () -> Void

    enum Side { case light, dark }
    @State private var side: Side?
    @State private var step = 0
    @State private var atMiddle = false
    @State private var read: Set<String> = []
    @StateObject private var still = Stillness()

    private static let cream = Color(hex: "#EDE3D0")
    private static let ink = Color(hex: "#2A2420")

    private var mid: Int { k.paragraphs.count / 2 }

    private func pages(_ s: Side) -> [String] {
        let p = k.paragraphs
        guard p.count > 1 else { return [] }
        return s == .light ? Array(p[0..<mid]) : Array(p[(mid + 1)...].reversed())
    }

    var body: some View {
        ZStack {
            if side == nil {
                choosing
            } else if atMiddle {
                middlePage
            } else if let s = side {
                let ps = pages(s)
                if step < ps.count {
                    page(ps[step], side: s)
                        .id("\(s)-\(step)")
                        .transition(.opacity)
                        .onTapGesture { advance() }
                }
            }
        }
        .asks(still)
        .onAppear { still.start() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            // stillness turns the page as surely as a hand does
            guard let s = side, !atMiddle else { return }
            let ps = pages(s)
            if step < ps.count, t > Katha.dwell(ps[step]) { advance() }
        }
    }

    private var choosing: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Button { enter(.light) } label: {
                    Rectangle().fill(Self.cream).overlay(
                        Text(k.paragraphs.first.map { String($0.prefix(60)) + "…" } ?? "")
                            .font(.loraItalic(13)).foregroundColor(Self.ink.opacity(0.55))
                            .padding(16), alignment: .topLeading)
                }
                .buttonStyle(.plain)
                Button { enter(.dark) } label: {
                    Rectangle().fill(Color.black).overlay(
                        Text(k.paragraphs.last.map { "…" + String($0.suffix(60)) } ?? "")
                            .font(.loraItalic(13)).foregroundColor(BinduTheme.inkSecondary)
                            .padding(16), alignment: .bottomTrailing)
                }
                .buttonStyle(.plain)
            }
            .frame(height: 300)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(k.color.opacity(0.5), lineWidth: 0.6))
            .padding(.horizontal, 34)
            Spacer()
        }
    }

    private func page(_ text: String, side s: Side) -> some View {
        ZStack {
            (s == .light ? Self.cream : Color.black).ignoresSafeArea()
            ScrollView {
                KathaText(text: text, size: 19, color: s == .light ? Self.ink : BinduTheme.inkPrimary)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 60)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var middlePage: some View {
        ZStack {
            LinearGradient(colors: [Self.cream, Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.22).ignoresSafeArea()
            VStack(spacing: 34) {
                Spacer()
                KathaText(text: k.paragraphs[min(mid, k.paragraphs.count - 1)], size: 20, italic: true)
                    .padding(.horizontal, 32)
                if read.count < 2 {
                    Button { turnOver() } label: {
                        Text("turn it over").spaceMonoTracked(8, em: 0.22)
                            .foregroundColor(k.color.opacity(0.8)).padding(12)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .onTapGesture { done() }
    }

    private func enter(_ s: Side) {
        withAnimation(.easeInOut(duration: 0.9)) { side = s; step = 0; atMiddle = pages(s).isEmpty }
        still.touched()
    }

    private func advance() {
        guard let s = side else { return }
        still.touched()
        withAnimation(.easeInOut(duration: 0.8)) {
            if step + 1 < pages(s).count { step += 1 } else { atMiddle = true; read.insert("\(s)") }
        }
    }

    private func turnOver() {
        guard let s = side else { return }
        let other: Side = s == .light ? .dark : .light
        withAnimation(.easeInOut(duration: 1.0)) { atMiddle = false; side = other; step = 0 }
        if pages(other).isEmpty { atMiddle = true }
    }
}

// MARK: - The Garden · ripens unwatched

/// A story changes only while he is away. Hovering does nothing; each stretch away ripens it
/// further, and when he returns it has already moved on — no animation, already there.
struct RipensUnwatched: View {
    let k: Katha
    let done: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var ripe = 1

    /// One paragraph ripens for every ten minutes he is not on this page.
    static let perParagraph: TimeInterval = 600

    private var awayKey: String { "bindu.kathas.garden.away.\(k.story.id)" }
    private var leftKey: String { "bindu.kathas.garden.left.\(k.story.id)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ForEach(Array(k.paragraphs.enumerated()), id: \.offset) { i, p in
                    if i < ripe {
                        KathaText(text: p)
                    } else {
                        seedRow(words: Katha.words(p))
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 26)
            .padding(.bottom, 90)
        }
        .scrollIndicators(.hidden)
        .onAppear { arrive() }
        .onDisappear { leave() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { leave() } else if phase == .active { arrive() }
        }
    }

    private func seedRow(words: Int) -> some View {
        let n = max(3, min(22, words / 6))
        return HStack(spacing: 9) {
            ForEach(0..<n, id: \.self) { j in
                Circle().fill(k.color.opacity(0.18 + 0.1 * Double((j * 7) % 3)))
                    .frame(width: 3.5, height: 3.5)
            }
        }
        .padding(.vertical, 6)
    }

    private func arrive() {
        let d = UserDefaults.standard
        var away = d.double(forKey: awayKey)
        if let left = d.object(forKey: leftKey) as? Date {
            away += max(0, Date().timeIntervalSince(left))
            d.removeObject(forKey: leftKey)
            d.set(away, forKey: awayKey)
        }
        ripe = min(k.paragraphs.count, 1 + Int(away / Self.perParagraph))
        if ripe >= k.paragraphs.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { done() }
        }
    }

    private func leave() {
        UserDefaults.standard.set(Date(), forKey: leftKey)
    }
}

// MARK: - The Watcher · the third door

/// Two obvious gestures are offered — open, pass. Only a still pause reveals the third: the
/// thought beneath the urge, which is the story's own last line, held alone before the rest.
struct ThirdDoor: View {
    let k: Katha
    let pass: () -> Void
    let done: () -> Void

    @StateObject private var still = Stillness()
    @State private var third: Double = 0
    @State private var beneath = false

    var body: some View {
        ZStack {
            if beneath {
                VStack {
                    Spacer()
                    KathaText(text: k.story.closingLine.isEmpty ? (k.paragraphs.last ?? "") : k.story.closingLine,
                              size: 22, italic: true)
                        .padding(.horizontal, 34)
                    Spacer()
                }
                .transition(.opacity)
                .onTapGesture { done() }
                .task {
                    try? await Task.sleep(nanoseconds: 9_000_000_000)
                    done()
                }
            } else {
                VStack(spacing: 40) {
                    Spacer()
                    HStack(alignment: .bottom, spacing: 26) {
                        door("open", tint: BinduTheme.inkSecondary, lit: 1) { done() }
                        if third > 0.01 {
                            door("beneath", tint: k.color, lit: third) {
                                withAnimation(.easeInOut(duration: 1.6)) { beneath = true }
                            }
                            .transition(.opacity)
                        }
                        door("pass", tint: BinduTheme.inkSecondary, lit: 1) { pass() }
                    }
                    Spacer()
                }
            }
        }
        .asks(still)
        .onAppear { still.start() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            // six seconds of nothing, and a third door is simply there; a touch does not take it away
            if t > 6, third < 1 { withAnimation(.easeInOut(duration: 3)) { third = 1 } }
        }
    }

    private func door(_ word: String, tint: Color, lit: Double, act: @escaping () -> Void) -> some View {
        Button(action: act) {
            VStack(spacing: 12) {
                ArchShape()
                    .stroke(tint.opacity(0.75 * lit), lineWidth: 1)
                    .frame(width: 64, height: 104)
                    .overlay(ArchShape().fill(tint.opacity(0.06 * lit)))
                Text(word).spaceMonoTracked(8, em: 0.22).foregroundColor(tint.opacity(0.8 * lit))
            }
        }
        .buttonStyle(.plain)
    }
}

struct ArchShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + r.width / 2))
        p.addArc(center: CGPoint(x: r.midX, y: r.minY + r.width / 2), radius: r.width / 2,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        return p
    }
}

// MARK: - The Descent · peel the want

/// Each hold opens the layer beneath. The ground darkens and the ink brightens as he goes.
/// The floor is nothing at all — and seeing that it is empty dissolves it.
struct PeelTheWant: View {
    let k: Katha
    let done: () -> Void

    @State private var layer = 0
    @StateObject private var still = Stillness()

    private var depth: Double { Double(layer) / Double(max(1, k.paragraphs.count)) }
    private var atFloor: Bool { layer >= k.paragraphs.count }

    var body: some View {
        ZStack {
            Color.black.opacity(0.25 + 0.7 * depth).ignoresSafeArea()
            VStack(spacing: 0) {
                if atFloor {
                    Spacer()
                    TimelineView(.animation) { tl in
                        let t = tl.date.timeIntervalSinceReferenceDate
                        let e = (1 - cos(t * 2 * .pi / 6)) / 2
                        Circle().fill(BinduTheme.colorBindu.opacity(0.5 + 0.5 * e))
                            .frame(width: 5 + 3 * e, height: 5 + 3 * e)
                            .shadow(color: BinduTheme.colorBindu.opacity(0.6), radius: 10 * e)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        KathaText(text: k.paragraphs[layer], size: 19,
                                  color: BinduTheme.inkPrimary.opacity(0.82 + 0.18 * depth))
                            .padding(.horizontal, 30)
                            .padding(.top, 40)
                    }
                    .scrollIndicators(.hidden)
                    .id(layer)
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity.combined(with: .scale(scale: 1.06))))
                }
                HoldPress(duration: 1.25, color: atFloor ? BinduTheme.colorBindu : k.color) { peel() }
                    .padding(.bottom, 64)
            }
        }
        .asks(still)
        .onAppear { still.start() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            // a body that cannot hold goes down by staying: one layer for each long stillness
            let need = atFloor ? 10.0 : Katha.dwell(k.paragraphs[min(layer, k.paragraphs.count - 1)]) + 4
            if t > need { peel() }
        }
    }

    private func peel() {
        still.touched()
        if atFloor { done(); return }
        withAnimation(.easeInOut(duration: 1.1)) { layer += 1 }
    }
}

// MARK: - The Return · read from the end

/// The last line comes first, shown as already true. Then the story unwinds toward its first
/// cause, each earlier part arriving above the one before, so every beat reads as chosen.
struct FromTheEnd: View {
    let k: Katha
    let done: () -> Void

    @State private var shown = 1
    @StateObject private var still = Stillness()

    private var n: Int { k.paragraphs.count }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach((n - shown)..<n, id: \.self) { i in
                        KathaText(text: k.paragraphs[i], size: i == n - 1 ? 20 : 18, italic: i == n - 1,
                                  color: i == n - 1 ? k.color.opacity(0.95) : BinduTheme.inkPrimary)
                            .id(i)
                            .transition(.opacity)
                    }
                    if shown >= n {
                        Button { done() } label: {
                            Circle().fill(k.color.opacity(0.7)).frame(width: 6, height: 6).padding(16)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 30)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .onChange(of: shown) { _, s in
                withAnimation(.easeInOut(duration: 1.0)) { proxy.scrollTo(n - s, anchor: .top) }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { back() }
        .onAppear { still.start() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            let current = k.paragraphs[max(0, n - shown)]
            if shown < n, t > Katha.dwell(current) { back() }
            else if shown >= n, t > Katha.dwell(current) + 6 { done() }
        }
    }

    private func back() {
        still.touched()
        guard shown < n else { return }
        withAnimation(.easeInOut(duration: 1.2)) { shown += 1 }
    }
}

// MARK: - The Forgetting · the dress

/// The story arrives wearing residue — a faint expectation over every line, the costume.
/// Staying lets it drain until only the bare moment is left. Nothing he does hurries it.
struct TheDress: View {
    let k: Katha
    let done: () -> Void

    @State private var drained: Double = 0
    static let seconds: Double = 32

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ForEach(Array(k.paragraphs.enumerated()), id: \.offset) { _, p in
                    ZStack(alignment: .topLeading) {
                        KathaText(text: p, color: Color(hex: "#C4A882").opacity(0.55 * (1 - drained)))
                            .offset(x: 3 * (1 - drained), y: -2 * (1 - drained))
                            .blur(radius: 1.6 * (1 - drained))
                        KathaText(text: p, color: BinduTheme.inkPrimary.opacity(0.45 + 0.55 * drained))
                            .blur(radius: 1.1 * (1 - drained))
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 26)
            .padding(.bottom, 90)
        }
        .scrollIndicators(.hidden)
        .overlay(
            LinearGradient(colors: [Color(hex: "#C4A882").opacity(0.10), .clear, Color(hex: "#C4A882").opacity(0.08)],
                           startPoint: .top, endPoint: .bottom)
                .opacity(1 - drained)
                .allowsHitTesting(false)
        )
        .task {
            let start = Date()
            while !Task.isCancelled, drained < 1 {
                drained = min(1, Date().timeIntervalSince(start) / Self.seconds)
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            if !Task.isCancelled { done() }
        }
    }
}

// MARK: - The Remembering · the pauses

/// Lines are released with held, empty beats between them. Recognition happens in the gaps.
/// A touch asks for the next line; the next exhale gives it.
struct ThePauses: View {
    let k: Katha
    let done: () -> Void

    @State private var shown = 0
    @State private var asked = false
    @State private var beat: Task<Void, Never>?

    static let gap: UInt64 = 5_500_000_000

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if shown == 0 {
                        Circle().fill(k.color.opacity(0.6)).frame(width: 4, height: 4)
                            .frame(maxWidth: .infinity).padding(.top, 180)
                    }
                    ForEach(0..<shown, id: \.self) { i in
                        let s = k.sentences[i]
                        let newPara = i > 0 && k.sentences[i - 1].paragraph != s.paragraph
                        KathaText(text: s.text, size: 18)
                            .padding(.top, i == 0 ? 0 : (newPara ? 30 : 12))
                            .id(i)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .padding(.bottom, 140)
            }
            .scrollIndicators(.hidden)
            .onChange(of: shown) { _, s in
                if s > 0 { withAnimation(.easeInOut(duration: 1.4)) { proxy.scrollTo(s - 1, anchor: .center) } }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { ask() }
        .onAppear { schedule(after: 4_000_000_000) }
        .onDisappear { beat?.cancel() }
    }

    private func schedule(after ns: UInt64) {
        beat?.cancel()
        beat = Task { @MainActor in
            try? await Task.sleep(nanoseconds: ns)
            guard !Task.isCancelled else { return }
            release()
        }
    }

    private func release() {
        asked = false
        if shown >= k.sentences.count { done(); return }
        withAnimation(.easeInOut(duration: 2.2)) { shown += 1 }
        schedule(after: shown >= k.sentences.count ? 7_000_000_000 : Self.gap)
    }

    private func ask() {
        guard !asked else { return }
        asked = true
        schedule(after: 1_100_000_000)
    }
}

// MARK: - The Body · entered by the body

/// The screen goes dark. The story is there, but only under the finger: where he touches,
/// warmth stays, and the words come up through it. Left untouched, the whole page slowly
/// warms on its own — the equal path for a body that cannot trace.
struct ByTheBody: View {
    let k: Katha
    let done: () -> Void

    @State private var index = 0
    @State private var marks: [CGPoint] = []
    @State private var warmth: Double = 0
    @State private var lastHaptic = CGPoint(x: -999, y: -999)
    @StateObject private var still = Stillness()

    private let feel = UISelectionFeedbackGenerator()

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Color.black
                    KathaText(text: k.paragraphs[index], size: 19)
                        .padding(.horizontal, 30)
                        .padding(.top, 30)
                        .frame(width: geo.size.width, alignment: .topLeading)
                        .mask(
                            ZStack {
                                Color.white.opacity(0.03 + 0.97 * warmth)
                                Canvas { ctx, _ in
                                    for m in marks {
                                        ctx.fill(Path(ellipseIn: CGRect(x: m.x - 54, y: m.y - 54, width: 108, height: 108)),
                                                 with: .color(.white))
                                    }
                                }
                                .blur(radius: 22)
                            }
                        )
                        .id(index)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                    still.touched()
                    marks.append(v.location)
                    if marks.count > 900 { marks.removeFirst(marks.count - 900) }
                    if hypot(v.location.x - lastHaptic.x, v.location.y - lastHaptic.y) > 34 {
                        feel.selectionChanged(); lastHaptic = v.location
                    }
                })
            }
            Button { next() } label: {
                Circle().fill(k.color.opacity(0.35 + 0.5 * min(1, Double(marks.count) / 160 + warmth)))
                    .frame(width: 8, height: 8).padding(18)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 54)
        }
        .onAppear { still.start(); feel.prepare() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            let w = max(0, min(1, (t - 8) / 6))
            if w > warmth { warmth = w }
        }
    }

    private func next() {
        still.touched()
        if index + 1 >= k.paragraphs.count { done(); return }
        withAnimation(.easeInOut(duration: 0.9)) { index += 1; marks = []; warmth = 0 }
    }
}

// MARK: - The Thread · one house at a time

/// Each stage shows only what the last hands passed on. A passed house folds into a thread
/// across the top; only when the last one is passed does the whole cloth appear.
struct OneHouse: View {
    let k: Katha
    let done: () -> Void

    @State private var house = 0
    @State private var weaving = false
    @StateObject private var still = Stillness()

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 5) {
                ForEach(0..<house, id: \.self) { i in
                    Capsule().fill(k.color.opacity(0.35 + 0.4 * Double(i % 2)))
                        .frame(height: 1.6)
                        .scaleEffect(x: weaving ? 1 : 0.86, anchor: i % 2 == 0 ? .leading : .trailing)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 14)
            .frame(height: 14 + CGFloat(max(house, 1)) * 6.6, alignment: .top)

            if house < k.paragraphs.count {
                ScrollView {
                    KathaText(text: k.paragraphs[house], size: 19)
                        .padding(.horizontal, 30)
                        .padding(.top, 26)
                        .padding(.bottom, 60)
                }
                .scrollIndicators(.hidden)
                .id(house)
                .transition(.asymmetric(insertion: .opacity, removal: .opacity.combined(with: .offset(y: -40))))
            } else {
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { passOn() }
        .asks(still)
        .onAppear { still.start() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            if house < k.paragraphs.count, t > Katha.dwell(k.paragraphs[house]) { passOn() }
        }
    }

    private func passOn() {
        still.touched()
        guard house < k.paragraphs.count else { return }
        withAnimation(.easeInOut(duration: 1.0)) { house += 1 }
        if house >= k.paragraphs.count {
            withAnimation(.easeInOut(duration: 1.8)) { weaving = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { done() }
        }
    }
}

// MARK: - The Circle · widening rings

/// The story opens small and widens ring by ring. Each part arrives with its ring; the figure
/// above holds them all, breathing, the newest the widest.
struct WideningRings: View {
    let k: Katha
    let done: () -> Void

    @State private var rings = 1
    @StateObject private var still = Stillness()

    var body: some View {
        VStack(spacing: 0) {
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    let c = CGPoint(x: size.width / 2, y: size.height / 2)
                    let n = k.paragraphs.count
                    for i in 0..<rings {
                        let base = 6 + (Double(i) / Double(max(1, n - 1))) * Double(size.height / 2 - 8)
                        let r = base * (1 + 0.025 * sin(t * 2 * .pi / 10 + Double(i)))
                        let a = i == rings - 1 ? 0.75 : 0.22 + 0.3 * Double(i) / Double(max(1, rings))
                        ctx.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)),
                                   with: .color(k.color.opacity(a)), lineWidth: i == rings - 1 ? 1.2 : 0.7)
                    }
                    ctx.fill(Path(ellipseIn: CGRect(x: c.x - 2.5, y: c.y - 2.5, width: 5, height: 5)),
                             with: .color(k.color))
                }
            }
            .frame(height: 150)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        ForEach(0..<rings, id: \.self) { i in
                            KathaText(text: k.paragraphs[i], size: 18,
                                      color: BinduTheme.inkPrimary.opacity(i == rings - 1 ? 1 : 0.62))
                                .id(i).transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
                .onChange(of: rings) { _, r in
                    withAnimation(.easeInOut(duration: 1.0)) { proxy.scrollTo(r - 1, anchor: .top) }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { widen() }
        .onAppear { still.start() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            if t > Katha.dwell(k.paragraphs[rings - 1]) { widen() }
        }
    }

    private func widen() {
        still.touched()
        if rings >= k.paragraphs.count { done(); return }
        withAnimation(.easeInOut(duration: 1.3)) { rings += 1 }
    }
}

// MARK: - The Signal · before the question

/// A line arrives first that belongs to a story he has not read yet — it will make sense only
/// afterwards. Then one point. A held gaze on it, or a held finger, and light moves behind
/// it until the story opens.
struct BeforeTheQuestion: View {
    let k: Katha
    let echo: String?
    let done: () -> Void

    @StateObject private var still = Stillness()
    @State private var light: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            if let e = echo, !e.isEmpty {
                Text(e)
                    .font(.loraItalic(13))
                    .foregroundColor(BinduTheme.inkTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 44)
                    .padding(.top, 34)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.white.opacity(0.75 * light), k.color.opacity(0.35 * light), .clear],
                                         center: .center, startRadius: 0, endRadius: 30 + 150 * light))
                    .frame(width: 360, height: 360)
                Circle().fill(k.color).frame(width: 7, height: 7)
                    .shadow(color: k.color.opacity(0.8), radius: 6)
                HoldPress(duration: 2.6, color: k.color, size: 64) { done() }
                    .opacity(0.35)
            }
            Spacer()
        }
        .asks(still)
        .onAppear { still.start() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            // tratak: the gaze held on one point; a glance away does not undo what was gathered
            let l = max(0, min(1, (t - 3) / 7))
            if l > light { light = l }
            if light >= 1 { done() }
        }
    }
}

// MARK: - The Forge · stop the line

/// The line runs on its own at a reading pace. At one seam it stops — a single word, lit —
/// and will not continue until he touches it. Stop the line is the maker's own value.
struct StopTheLine: View {
    let k: Katha
    let done: () -> Void

    @State private var shown = 1
    @State private var mended = false
    @State private var runner: Task<Void, Never>?

    private var seamIndex: Int { min(k.paragraphs.count - 1, Int(Double(k.paragraphs.count) * 0.6)) }

    /// The seam is the longest word in the paragraph three-fifths of the way down.
    private var seam: (word: String, range: Range<String.Index>)? {
        let p = k.paragraphs[seamIndex]
        var best: (String, Range<String.Index>)?
        var cursor = p.startIndex
        for w in p.split(separator: " ") {
            let trimmed = w.trimmingCharacters(in: .punctuationCharacters)
            guard let r = p.range(of: trimmed, range: cursor..<p.endIndex) else { continue }
            cursor = r.upperBound
            if trimmed.count >= 6, trimmed.count > (best?.0.count ?? 0) { best = (trimmed, r) }
        }
        return best.map { ($0.0, $0.1) }
    }

    private var halted: Bool { shown - 1 == seamIndex && !mended && seam != nil }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(0..<shown, id: \.self) { i in
                        if i == seamIndex, !mended, let s = seam {
                            let p = k.paragraphs[i]
                            Button { mend() } label: {
                                (Text(String(p[..<s.range.lowerBound]))
                                 + Text(s.word).foregroundColor(BinduTheme.colorBindu).underline(true, color: BinduTheme.colorBindu.opacity(0.6)))
                                    .font(.lora(18)).foregroundColor(BinduTheme.inkPrimary)
                                    .lineSpacing(10)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .id(i)
                        } else {
                            KathaText(text: k.paragraphs[i]).id(i).transition(.opacity)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 26)
                .padding(.bottom, 110)
            }
            .scrollIndicators(.hidden)
            .onChange(of: shown) { _, s in
                withAnimation(.easeInOut(duration: 1.0)) { proxy.scrollTo(s - 1, anchor: .top) }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { advance() }      // his pace, not only the line's — except at the seam
        .onAppear { run() }
        .onDisappear { runner?.cancel() }
    }

    private func advance() {
        guard !halted else { return }
        if shown >= k.paragraphs.count { runner?.cancel(); done(); return }
        withAnimation(.easeInOut(duration: 1.0)) { shown += 1 }
        run()
    }

    private func run() {
        runner?.cancel()
        runner = Task { @MainActor in
            while !Task.isCancelled {
                if halted { return }
                let wait = Katha.dwell(k.paragraphs[shown - 1])
                try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                guard !Task.isCancelled, !halted else { return }
                if shown >= k.paragraphs.count {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    if !Task.isCancelled { done() }
                    return
                }
                withAnimation(.easeInOut(duration: 1.0)) { shown += 1 }
            }
        }
    }

    private func mend() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.4)
        withAnimation(.easeInOut(duration: 0.6)) { mended = true }
        run()
    }
}

// MARK: - The Field · the baton

/// Each telling begins where the last voice ended. The story passes through several tellers,
/// each a different suit of the same listening; the last words of one are the first light of
/// the next.
struct TheBaton: View {
    let k: Katha
    let done: () -> Void

    @EnvironmentObject private var store: FeedStore
    @State private var leg = 0
    @StateObject private var still = Stillness()

    private var tellers: [Archetype] {
        let pool = store.archetypes.filter { !$0.glyph.isEmpty && $0.name != "Ash" }
        guard !pool.isEmpty else { return [] }
        let sorted = pool.sorted { KathaHash.fnv(k.story.id + $0.id) < KathaHash.fnv(k.story.id + $1.id) }
        return Array(sorted.prefix(4))
    }

    private func teller(_ i: Int) -> Archetype? {
        let t = tellers
        return t.isEmpty ? nil : t[i % t.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if leg > 0 {
                let prev = k.paragraphs[leg - 1].split(separator: " ").suffix(5).joined(separator: " ")
                Text("… " + prev)
                    .font(.loraItalic(14))
                    .foregroundColor((teller(leg - 1)?.color ?? k.color).opacity(0.7))
                    .padding(.horizontal, 30)
                    .padding(.top, 22)
                    .id("prev-\(leg)")
                    .transition(.opacity)
            }
            HStack(alignment: .top, spacing: 12) {
                Text(teller(leg)?.glyph ?? "·")
                    .font(.lora(15))
                    .foregroundColor(teller(leg)?.color ?? k.color)
                    .padding(.top, 3)
                ScrollView {
                    KathaText(text: k.paragraphs[leg], size: 18)
                        .padding(.bottom, 60)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.leading, 18)
            .padding(.trailing, 28)
            .padding(.top, 16)
            .id(leg)
            .transition(.opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .onTapGesture { handOn() }
        .asks(still)
        .onAppear { still.start() }
        .onDisappear { still.stop() }
        .onReceive(still.$still) { t in
            if t > Katha.dwell(k.paragraphs[leg]) { handOn() }
        }
    }

    private func handOn() {
        still.touched()
        if leg + 1 >= k.paragraphs.count { done(); return }
        withAnimation(.easeInOut(duration: 1.0)) { leg += 1 }
    }
}

// MARK: - The signature that is a prelude · the dot becomes the place

struct DotBecomesPlace: View {
    let then: () -> Void
    @State private var grow: Double = 0

    var body: some View {
        GeometryReader { geo in
            let full = hypot(geo.size.width, geo.size.height)
            ZStack {
                Color.black.ignoresSafeArea()
                Circle()
                    .fill(RadialGradient(colors: [Color.white, Color.white.opacity(0.85), BinduTheme.bgDeep],
                                         center: .center, startRadius: 0, endRadius: max(3, CGFloat(grow) * full / 2)))
                    .frame(width: max(6, CGFloat(grow) * full), height: max(6, CGFloat(grow) * full))
                    .opacity(1 - max(0, grow - 0.8) * 5)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            let start = Date()
            while !Task.isCancelled, grow < 1 {
                let t = min(1, Date().timeIntervalSince(start) / 4.2)
                grow = t >= 1 ? 1 : t * t * (3 - 2 * t)
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
            if !Task.isCancelled { then() }
        }
    }
}
