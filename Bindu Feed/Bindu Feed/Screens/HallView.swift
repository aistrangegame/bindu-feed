import Combine
import SwiftUI

// WAVE 5 · THE HALL OF PERSPECTIVES (Codex C-1281, C-1280). Under every story's gathered voices
// there was always a hidden page, and it opens only on a day he has called — once he has looked
// for help, he can see that help was every voice at once.
//
// An inverted tree: its roots up in the Light's galaxies, an ∞ of eyes on its trunk, and one
// branch hanging down for each voice that spoke on this story, the voice's first sentence at
// its tip. The eleventh branch is empty and is his. He adds his own perspective (it joins the
// story's thread as his comment), and the hall closes in his own voice: I already did.
struct HallView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var breath: Breath
    @Binding var path: [FeedRoute]
    let story: Story

    @State private var voices: [FieldComment] = []
    @State private var mine = ""
    @State private var added = false
    @State private var showHub = false
    @FocusState private var writing: Bool

    private let gold = Color(hex: "#C9A07A")

    var body: some View {
        ZStack {
            Color(hex: "#09080C").ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    roots.frame(height: 150)
                    Text(story.title)
                        .font(.loraItalic(18)).foregroundColor(BinduTheme.inkSecondary)
                        .multilineTextAlignment(.center).padding(.horizontal, 30)
                        .padding(.bottom, 26)
                    ForEach(Array(voices.enumerated()), id: \.element.id) { i, c in
                        branch(c, i)
                    }
                    yours.padding(.top, 20)
                    Color.clear.frame(height: 90)
                }
            }
            .scrollIndicators(.hidden)
        }
        .floatingBackHub(path: $path, showHub: $showHub)
        .hubOverlay(open: $showHub, path: $path)
        .task {
            let all = (try? await AirtableService.shared.fetchFieldComments(storyId: story.id)) ?? []
            var seen = Set<String>()
            voices = all.sorted { $0.commentOrder < $1.commentOrder }.filter { seen.insert($0.archetype).inserted }
        }
    }

    /// Roots in the galaxies, the trunk with its ∞ of eyes.
    private var roots: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let cx = size.width / 2
                for i in 0..<40 {
                    let x = Double(size.width) * (0.5 + 0.48 * sin(Double(i) * 1.7))
                    let y = 10 + Double(i * 13 % 70)
                    let a = 0.25 + 0.25 * sin(t * 0.6 + Double(i))
                    ctx.fill(Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2)), with: .color(Color(hex: "#EDE3CE").opacity(a)))
                }
                for k in 0..<7 {
                    var root = Path()
                    let sx = Double(cx) + (Double(k) - 3) * 34
                    root.move(to: CGPoint(x: sx, y: 20))
                    root.addQuadCurve(to: CGPoint(x: cx, y: 110), control: CGPoint(x: sx * 0.5 + Double(cx) * 0.5, y: 80))
                    ctx.stroke(root, with: .color(gold.opacity(0.35)), lineWidth: 0.8)
                }
                ctx.fill(Path(CGRect(x: cx - 0.7, y: 110, width: 1.4, height: 40)), with: .color(gold.opacity(0.6)))
                // the ∞ of eyes
                var inf = Path()
                for s in 0...60 {
                    let th = Double(s) / 60 * 2 * .pi, d = 1 + sin(th) * sin(th)
                    let p = CGPoint(x: Double(cx) + 22 * cos(th) / d, y: 128 + 22 * sin(th) * cos(th) / d)
                    if s == 0 { inf.move(to: p) } else { inf.addLine(to: p) }
                }
                ctx.stroke(inf, with: .color(gold.opacity(0.55 + 0.3 * breath.value)), lineWidth: 1)
                for side in [-1.0, 1.0] {
                    ctx.fill(Path(ellipseIn: CGRect(x: Double(cx) + side * 13 - 2, y: 126, width: 4, height: 4)), with: .color(gold))
                }
            }
        }
    }

    private func firstSentence(_ s: String) -> String {
        Sentences.split(s).first?.text ?? s
    }

    private func branch(_ c: FieldComment, _ i: Int) -> some View {
        let a = store.archetype(named: c.archetype)
        let col = a?.color ?? BinduTheme.inkSecondary
        let left = i % 2 == 0
        return HStack(alignment: .top, spacing: 0) {
            if !left { Spacer(minLength: 40) }
            VStack(alignment: left ? .leading : .trailing, spacing: 6) {
                Text(c.archetype).spaceMonoTracked(8, em: 0.25).foregroundColor(col)
                Text(firstSentence(c.body))
                    .font(.loraItalic(15)).foregroundColor(BinduTheme.inkPrimary.opacity(0.88))
                    .multilineTextAlignment(left ? .leading : .trailing)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 12).padding(.horizontal, 16)
            .overlay(alignment: left ? .trailing : .leading) {
                Rectangle().fill(col.opacity(0.5)).frame(width: 30, height: 0.8).offset(x: left ? 30 : -30)
            }
            if left { Spacer(minLength: 40) }
        }
        .padding(.horizontal, 22)
        .background(alignment: .center) { Rectangle().fill(gold.opacity(0.35)).frame(width: 1) }
    }

    private var yours: some View {
        VStack(spacing: 18) {
            Text("the eleventh").spaceMonoTracked(8, em: 0.3).foregroundColor(BinduTheme.colorAsh.opacity(0.85))
            if added {
                Text(mine).font(.loraItalic(16)).foregroundColor(BinduTheme.inkPrimary)
                    .multilineTextAlignment(.center).padding(.horizontal, 30)
                Text("I already did.")
                    .font(.lora(22, weight: .medium)).foregroundColor(BinduTheme.colorAsh)
                    .padding(.top, 20)
                    .transition(.opacity)
            } else {
                TextField("", text: $mine, prompt: Text("your perspective").foregroundColor(BinduTheme.inkTertiary), axis: .vertical)
                    .font(.loraItalic(16)).foregroundColor(BinduTheme.inkPrimary)
                    .multilineTextAlignment(.center)
                    .focused($writing)
                    .padding(.horizontal, 30)
                HoldEmber(duration: 1.4, color: BinduTheme.colorAsh, size: 52, label: "hold to add it",
                          enabled: !mine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                    writing = false
                    let text = mine.trimmingCharacters(in: .whitespacesAndNewlines)
                    Task { _ = await store.postComment(storyId: story.id, body: text, parentId: nil) }
                    soundEngine.fieldThreshold(hz: 198, dur: 7)
                    withAnimation(.easeInOut(duration: 1.6)) { added = true }
                }
            }
        }
    }
}
