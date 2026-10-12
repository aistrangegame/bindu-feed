import SwiftUI

// WAVE 3 · THE UNWINDING — gather → dissolve → play; the half of the ceremony grammar the Feed
// never had. It opens only at a season's turn or around the new moon. Up to eight things he once
// gripped come back one at a time, and each is released by the INVERSE of the gesture that made
// it (Tree of Life's mirror dissolution):
//   · what he sealed by holding (his words, a kept line) — he LIFTS it away, upward;
//   · what he carved by drawing in (a Declaration)      — he PINCHES it back to a point;
//   · a ring he answered (a Return)                      — he UNTURNS it, counter-clockwise.
// Nothing is deleted. Only the grip goes; the words stay where they live. It ends on the particle
// alone.
struct UnwindingView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var breath: Breath
    @Binding var path: [FeedRoute]

    @State private var items: [UnwindItem] = []
    @State private var index = 0
    @State private var loaded = false
    @State private var lift: CGFloat = 0
    @State private var pinch: CGFloat = 1
    @State private var turn: Double = 0          // accumulated counter-clockwise radians
    @State private var lastAngle: Double?
    @State private var letting = false
    @State private var done = false

    private let violet = Color(hex: "#9B6BD6")

    var body: some View {
        GeometryReader { g in
            ZStack {
                Color(hex: "#09070D").ignoresSafeArea()
                RadialGradient(colors: [violet.opacity(0.10), .clear], center: .center, startRadius: 0, endRadius: 420)
                    .ignoresSafeArea()

                if !loaded {
                    ProgressDot()
                } else if done || items.isEmpty {
                    ending
                } else {
                    let item = items[index]
                    VStack(spacing: 30) {
                        Text("\(index + 1) of \(items.count)")
                            .spaceMonoTracked(8, em: 0.3).foregroundColor(BinduTheme.inkTertiary)
                        Text(item.words)
                            .font(.loraItalic(20))
                            .foregroundColor(BinduTheme.inkPrimary)
                            .lineSpacing(8)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 320)
                            .scaleEffect(item.kind == .carved ? pinch : 1)
                            .rotationEffect(.radians(item.kind == .ring ? -turn * 0.25 : 0))
                            .offset(y: item.kind == .held ? -lift : 0)
                            .blur(radius: letting ? 10 : 0)
                            .opacity(letting ? 0 : 1 - Double(progress(item)) * 0.5)
                        Text(hint(item.kind))
                            .spaceMonoTracked(8, em: 0.2)
                            .foregroundColor(violet.opacity(0.8))
                            .opacity(letting ? 0 : 1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(gesture(for: item, center: CGPoint(x: g.size.width / 2, y: g.size.height / 2)))
                    .id(item.id)
                    .transition(.opacity)
                }

                VStack {
                    HStack { BackChevron { $path.popDissolve() }; Spacer() }
                        .padding(.horizontal, 16).padding(.top, 6)
                    Spacer()
                }
            }
        }
        .task {
            items = await store.unwindingItems()
            loaded = true
        }
    }

    private func hint(_ k: UnwindItem.Kind) -> String {
        switch k {
        case .held:   return "you held this · lift it away"
        case .carved: return "you carved this · pinch it back to a point"
        case .ring:   return "you turned this ring · unturn it"
        }
    }

    private func progress(_ item: UnwindItem) -> CGFloat {
        switch item.kind {
        case .held:   return min(1, lift / 160)
        case .carved: return min(1, (1 - pinch) / 0.6)
        case .ring:   return CGFloat(min(1, turn / (1.6 * .pi)))
        }
    }

    private func gesture(for item: UnwindItem, center: CGPoint) -> AnyGesture<Void> {
        switch item.kind {
        case .held:
            return AnyGesture(DragGesture()
                .onChanged { v in lift = max(0, -v.translation.height) }
                .onEnded { _ in
                    if lift > 160 { letGo(item) } else { withAnimation(.easeOut(duration: 0.6)) { lift = 0 } }
                }.map { _ in () })
        case .carved:
            return AnyGesture(MagnificationGesture()
                .onChanged { m in pinch = max(0.2, min(1, m)) }
                .onEnded { _ in
                    if pinch < 0.42 { letGo(item) } else { withAnimation(.easeOut(duration: 0.6)) { pinch = 1 } }
                }.map { _ in () })
        case .ring:
            return AnyGesture(DragGesture(minimumDistance: 4)
                .onChanged { v in
                    let a = Double(atan2(v.location.y - center.y, v.location.x - center.x))
                    if let last = lastAngle {
                        var d = a - last
                        if d > .pi { d -= 2 * .pi }
                        if d < -.pi { d += 2 * .pi }
                        turn = max(0, turn - d)            // counter-clockwise (negative on screen) adds
                    }
                    lastAngle = a
                    if turn >= 1.6 * .pi { letGo(item) }
                }
                .onEnded { _ in
                    lastAngle = nil
                    if !letting { withAnimation(.easeOut(duration: 0.8)) { turn = 0 } }
                }.map { _ in () })
        }
    }

    private func letGo(_ item: UnwindItem) {
        guard !letting else { return }
        letting = true
        store.release(item.id, kind: item.kind.rawValue)
        soundEngine.fieldThreshold(hz: item.kind == .ring ? 110 : 136.1, dur: 6)
        withAnimation(.easeOut(duration: 1.6)) {
            if item.kind == .held { lift = 420 }
            if item.kind == .carved { pinch = 0.02 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            lift = 0; pinch = 1; turn = 0; lastAngle = nil
            letting = false
            withAnimation(.easeInOut(duration: 1.0)) {
                if index + 1 < items.count { index += 1 } else { done = true }
            }
        }
    }

    private var ending: some View {
        VStack(spacing: 26) {
            Spacer()
            Circle().fill(BinduTheme.colorBindu).frame(width: 8, height: 8)
                .shadow(color: BinduTheme.colorBindu.opacity(0.85), radius: 12)
                .scaleEffect(0.92 + 0.16 * breath.value)
            Text(items.isEmpty ? "Nothing is gripped. Only the point." : "Only the point remains.")
                .font(.loraItalic(19)).foregroundColor(BinduTheme.inkPrimary)
            Text("nothing was deleted · only the grip")
                .spaceMonoTracked(8, em: 0.25).foregroundColor(BinduTheme.inkTertiary)
            Spacer()
            Button { $path.popDissolve() } label: {
                Text("return").spaceMonoTracked(9, em: 0.2).foregroundColor(BinduTheme.inkSecondary).padding(14)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 30)
        }
        .transition(.opacity)
        .onAppear { soundEngine.fieldThreshold(hz: 136.1, dur: 9) }
    }
}

/// A single breathing dot — the house's loading state (nothing spins).
struct ProgressDot: View {
    @EnvironmentObject private var breath: Breath
    var body: some View {
        Circle().fill(BinduTheme.inkTertiary).frame(width: 5, height: 5)
            .opacity(0.3 + 0.6 * breath.value)
    }
}
