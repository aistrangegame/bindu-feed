import Combine
import SwiftUI

// THE REST · THE ARCHIVE BECOMES A BOOK WHOSE CENTRE IS A DOOR (the Dark Light flip-book). Every
// story is a page, oldest first; a page yellows by how old the telling is (age from the day it
// was spoken, never from its place in the pile). Dragging turns the page in 3D over most of a
// second. The page in the exact middle of the book is not a story: it is a door, and touching it
// opens the fall.
struct ArchiveBookView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @Binding var path: [FeedRoute]

    @State private var index = 0
    @State private var turn: Double = 0          // −1…1 while dragging
    @State private var showHub = false

    private var pages: [Story] {
        store.stories.filter { !$0.sourceDate.isEmpty }.sorted { $0.sourceDate < $1.sourceDate }
    }
    /// The door sits at the true middle, between the two halves of the book.
    private var doorIndex: Int { pages.count / 2 }
    private var count: Int { pages.count + 1 }

    var body: some View {
        ZStack {
            Color(hex: "#0C0A08").ignoresSafeArea()
            GeometryReader { g in
                ZStack {
                    if count > 1 {
                        page(at: index, size: g.size)
                            .rotation3DEffect(.degrees(turn * -80), axis: (x: 0, y: 1, z: 0),
                                              anchor: turn < 0 ? .leading : .trailing, perspective: 0.5)
                            .opacity(1 - abs(turn) * 0.4)
                    }
                }
                .frame(width: g.size.width, height: g.size.height)
                .contentShape(Rectangle())
                .gesture(DragGesture()
                    .onChanged { v in turn = max(-1, min(1, Double(v.translation.width) / Double(g.size.width) * 1.6)) }
                    .onEnded { v in
                        let dir = v.translation.width < -50 ? 1 : (v.translation.width > 50 ? -1 : 0)
                        withAnimation(.easeInOut(duration: 0.45)) { turn = Double(-dir) }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                            if dir != 0 { index = max(0, min(count - 1, index + dir)); soundEngine.blip(hz: 396) }
                            turn = Double(dir)
                            withAnimation(.easeInOut(duration: 0.45)) { turn = 0 }
                        }
                    })
            }
            .padding(.horizontal, 22)
            .padding(.top, 70).padding(.bottom, 50)
        }
        .floatingBackHub(path: $path, showHub: $showHub)
        .hubOverlay(open: $showHub, path: $path)
        .task { if store.stories.isEmpty { await store.loadStories() } }
    }

    /// Days since the story was spoken → how yellow its paper has gone.
    private func age(_ s: Story) -> Double {
        guard let d = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC")!).date(from: s.sourceDate) else { return 0 }
        return min(1, Date().timeIntervalSince(d) / (86_400 * 730))
    }

    private func storyIndex(_ i: Int) -> Int? {
        if i == doorIndex { return nil }
        return i < doorIndex ? i : i - 1
    }

    @ViewBuilder
    private func page(at i: Int, size: CGSize) -> some View {
        if let si = storyIndex(i), pages.indices.contains(si) {
            let s = pages[si]
            let a = age(s)
            let paper = Color(red: 0.95 - 0.06 * a, green: 0.92 - 0.12 * a, blue: 0.86 - 0.22 * a)
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(s.codexId).spaceMonoTracked(8, em: 0.2)
                    Spacer()
                    Text(s.sourceDate).spaceMonoTracked(8, em: 0.2)
                }
                .foregroundColor(Color.black.opacity(0.45))
                Text(s.title).font(.lora(20, weight: .medium)).foregroundColor(Color.black.opacity(0.85))
                Text(s.excerpt.isEmpty ? s.body : s.excerpt)
                    .font(.loraItalic(15)).foregroundColor(Color.black.opacity(0.72)).lineSpacing(6)
                    .lineLimit(14)
                Spacer()
                HStack {
                    Text(s.room).font(.lora(12)).foregroundColor(store.room(named: s.room)?.color ?? .black)
                    Spacer()
                    Button { $path.pushDissolve(.story(s)) } label: {
                        Text("read ›").spaceMonoTracked(8, em: 0.2).foregroundColor(Color.black.opacity(0.55))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .frame(width: size.width, height: size.height)
            .background(RoundedRectangle(cornerRadius: 3).fill(paper).shadow(color: .black.opacity(0.6), radius: 10))
        } else {
            // the middle page — a door into the fall
            VStack(spacing: 22) {
                Spacer()
                Button {
                    soundEngine.fieldThreshold(hz: 84, dur: 8)
                    $path.pushDissolve(.instrument(-1))
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 2).stroke(Color(hex: "#C9A07A").opacity(0.7), lineWidth: 1)
                            .frame(width: 96, height: 150)
                        Circle().fill(BinduTheme.colorBindu).frame(width: 7, height: 7)
                    }
                }
                .buttonStyle(.plain)
                Text("the middle of the book is a door").font(.loraItalic(15)).foregroundColor(Color(hex: "#C9A07A"))
                Spacer()
            }
            .frame(width: size.width, height: size.height)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color(hex: "#16120E")))
        }
    }
}
