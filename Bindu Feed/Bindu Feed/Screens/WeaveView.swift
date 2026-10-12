import Combine
import SwiftUI

// WAVE 5 · THE WEAVE (Codex C-1134 — Atman scarf, Brahman cloth). The register only he would
// dream: a man whose family has woven for three generations, seeing his own life as cloth.
//
// The FRONT is the Atman scarf: the months of his Codex as the warp, running down; the thirteen
// rooms as the weft, running across in their own colours; where a room and a month cross, a
// motif for each story — a knot where he sealed it, a thicker thread where he returned to it.
// A drag across flips the cloth. The BACK is the Brahman weave: the same crossings, but every
// thread is a VOICE — the ten who gathered — so the reverse shows who was holding each place.
struct WeaveView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: [FeedRoute]

    @State private var showHub = false
    @State private var flip: Double = 0          // 0 front … 180 back
    @State private var dragFlip: Double = 0

    var body: some View {
        ZStack {
            Color(hex: "#0B0A0E").ignoresSafeArea()
            VStack(spacing: 14) {
                Text(showingBack ? "the Brahman weave" : "the Atman scarf")
                    .font(.loraItalic(22)).foregroundColor(BinduTheme.inkPrimary)
                    .padding(.top, 56)
                Text(showingBack ? "every thread a voice that held the place" : "months down · rooms across · a knot where you sealed")
                    .font(.lora(12)).foregroundColor(BinduTheme.inkTertiary)
                cloth
                    .rotation3DEffect(.degrees(flip + dragFlip), axis: (x: 0, y: 1, z: 0), perspective: 0.4)
                    .padding(.horizontal, 18)
                    .gesture(DragGesture()
                        .onChanged { v in dragFlip = Double(v.translation.width) * 0.6 }
                        .onEnded { v in
                            let total = flip + Double(v.translation.width) * 0.6
                            withAnimation(.easeInOut(duration: 0.9)) {
                                flip = abs(total - flip) > 50 ? (flip == 0 ? 180 : 0) : flip
                                dragFlip = 0
                            }
                        })
                Text("drag across to turn the cloth").spaceMonoTracked(8, em: 0.2).foregroundColor(BinduTheme.inkMuted)
                    .padding(.bottom, 26)
            }
        }
        .floatingBackHub(path: $path, showHub: $showHub)
        .hubOverlay(open: $showHub, path: $path)
        .task {
            if store.stories.isEmpty { await store.loadStories() }
            if store.storyStats.isEmpty { await store.loadStoryStats() }
        }
    }

    private var showingBack: Bool {
        let a = (flip + dragFlip).truncatingRemainder(dividingBy: 360)
        return abs(a) > 90 && abs(a) < 270
    }

    private var months: [String] {
        Array(Set(store.stories.compactMap { $0.sourceDate.count >= 7 ? String($0.sourceDate.prefix(7)) : nil })).sorted()
    }

    private var rooms: [Room] { store.rooms.sorted { $0.sortOrder < $1.sortOrder } }

    private var cloth: some View {
        let ms = months, rs = rooms
        let back = showingBack
        return Canvas { ctx, size in
            guard !ms.isEmpty, !rs.isEmpty else { return }
            let W = size.width, H = size.height
            let colW = W / CGFloat(rs.count), rowH = H / CGFloat(ms.count)
            // the drawing is mirrored on the back so it reads correctly after the turn
            if back { ctx.translateBy(x: W, y: 0); ctx.scaleBy(x: -1, y: 1) }
            // warp — the months, running down
            for i in 0..<rs.count {
                let x = colW * (CGFloat(i) + 0.5)
                ctx.fill(Path(CGRect(x: x - 0.4, y: 0, width: 0.8, height: H)),
                         with: .color(Color(hex: "#C9A07A").opacity(back ? 0.10 : 0.18)))
            }
            // weft — the rooms, across, in their colours (front) or faint (back)
            for (j, _) in ms.enumerated() {
                let y = rowH * (CGFloat(j) + 0.5)
                for (i, r) in rs.enumerated() {
                    let x0 = colW * CGFloat(i)
                    let over = (i + j) % 2 == 0
                    ctx.fill(Path(CGRect(x: x0, y: y - 0.6, width: colW, height: 1.2)),
                             with: .color(r.color.opacity(back ? 0.08 : (over ? 0.38 : 0.16))))
                }
            }
            // the motifs
            for st in store.stories {
                guard st.sourceDate.count >= 7, let j = ms.firstIndex(of: String(st.sourceDate.prefix(7))),
                      let i = rs.firstIndex(where: { $0.name == st.room }) else { continue }
                let jitter = CGFloat(MirrorDay.fnv1a(st.id) % 100) / 100 - 0.5
                let c = CGPoint(x: colW * (CGFloat(i) + 0.5) + jitter * colW * 0.5,
                                y: rowH * (CGFloat(j) + 0.5) + jitter * rowH * 0.3)
                if back {
                    let voices = store.stats(for: st.id).archetypes
                    for (k, v) in voices.prefix(10).enumerated() {
                        let vc = store.archetype(named: v)?.color ?? BinduTheme.inkSecondary
                        let a = Double(k) / Double(max(1, voices.count)) * .pi
                        var thread = Path()
                        thread.move(to: CGPoint(x: c.x - CGFloat(cos(a)) * 6, y: c.y - CGFloat(sin(a)) * 3))
                        thread.addLine(to: CGPoint(x: c.x + CGFloat(cos(a)) * 6, y: c.y + CGFloat(sin(a)) * 3))
                        ctx.stroke(thread, with: .color(vc.opacity(0.75)), lineWidth: 0.9)
                    }
                } else {
                    let col = rs[i].color
                    let sealed = store.sealedStoryIDs.contains(st.id)
                    let returned = !(store.returnRings[st.id] ?? []).isEmpty
                    if returned {
                        ctx.stroke(Path(ellipseIn: CGRect(x: c.x - 4.5, y: c.y - 4.5, width: 9, height: 9)), with: .color(col.opacity(0.9)), lineWidth: 1.6)
                    }
                    if sealed {
                        var knot = Path()
                        knot.move(to: CGPoint(x: c.x - 3, y: c.y - 3)); knot.addLine(to: CGPoint(x: c.x + 3, y: c.y + 3))
                        knot.move(to: CGPoint(x: c.x + 3, y: c.y - 3)); knot.addLine(to: CGPoint(x: c.x - 3, y: c.y + 3))
                        ctx.stroke(knot, with: .color(BinduTheme.colorBindu), lineWidth: 1.2)
                    } else {
                        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 1.6, y: c.y - 1.6, width: 3.2, height: 3.2)),
                                 with: .color(col.opacity(store.metStoryIDs.contains(st.id) ? 0.95 : 0.45)))
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.02)))
    }
}
