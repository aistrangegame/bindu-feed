import Combine
import SwiftUI

// WAVE 1 · THE CALL — "somewhere fast to look", made one gesture.
//
// The Feed's own reason (his goal "The Point"): *when the Lila takes over, there needs to be
// somewhere fast to look that re-orients to the point of existence.* Four readings of the house
// arrived here from four directions (the upgrade atlas, movement I):
//   · Codex C-1260 / C-1002 — the anchor at the summit was always the self; in a low state
//     reflection deepens the low and reassurance doesn't land; what lifted him was his OWN words.
//   · Being's drifting state-words; the Chakra Game's *lay it down* (2.6 s, nothing stored).
//   · Learning's Still Point — each 1.3 s hold takes a layer away until only the ember breathes.
//   · padakarshini's field guide — When · Do · Because.
//
// The movements, none on a clock that moves him on:
//   1. the world dims to the dot; one breath ring passes;
//   2. nine state-words drift (a fresh handful each time); he touches one — or the dot, for none;
//   3. he holds the word to LAY IT DOWN (2.6 s; early release drains, nothing fails, nothing kept);
//   4. one passage of HIS OWN WORDS falls like a leaf, signed by a voice — and, if he stays still,
//      the name resolves to his own and the day he said it;
//   5. he may go down: the Still Point, a hold at a time, to the ember. "surface" is always there.
//
// The answers are his verbatim Codex words (Type `Call`, sort 10001+), gathered once, offline.
// Only a wordless pulse reaches the record; what he laid down is never stored.

enum CallStates {
    static let all = ["scattered", "heavy", "rushed", "unseen", "anxious", "stuck", "tired",
                      "restless", "small", "lost", "behind", "alone", "doubting", "overwhelmed",
                      "numb", "tight", "distracted", "far away"]
}

struct CallView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var breath: Breath
    let onClose: () -> Void

    private enum Phase { case dim, words, layDown, answer, still }
    @State private var phase: Phase = .dim
    @State private var words: [String] = Array(CallStates.all.shuffled().prefix(9))
    @State private var chosen: String?
    @State private var ring: Double = 0            // the breath ring, then the hold rings
    @State private var holding = false
    @State private var holdStart: Date?
    @State private var laid = false
    @State private var answer: CallAnswer?
    @State private var fell = false
    @State private var resolved = false
    @State private var stillStage = 0
    @State private var lastTouch = Date()
    @State private var appear = false

    private static let layHold = 2.6
    private static let stillHold = 1.3

    var body: some View {
        ZStack {
            Color(hex: "#07060A").opacity(appear ? 0.97 : 0).ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { lastTouch = Date() }

            switch phase {
            case .dim:     dimLayer
            case .words:   wordsLayer
            case .layDown: layDownLayer
            case .answer:  answerLayer
            case .still:   stillLayer
            }

            // always a calm way out
            VStack {
                Spacer()
                Button { close() } label: {
                    Text("surface").spaceMonoTracked(10, em: 0.2)
                        .foregroundColor(BinduTheme.inkMuted)
                        .padding(18)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 26)
            }
            .opacity(appear ? 1 : 0)
        }
        .onAppear(perform: begin)
    }

    // MARK: 1 · the dot, one breath ring

    private var dimLayer: some View {
        ZStack {
            Circle().stroke(BinduTheme.colorBindu.opacity(0.35 * (1 - ring)), lineWidth: 1)
                .frame(width: 18 + 220 * ring, height: 18 + 220 * ring)
            dot
        }
    }

    private var dot: some View {
        Circle().fill(BinduTheme.colorBindu)
            .frame(width: 9, height: 9)
            .shadow(color: BinduTheme.colorBindu.opacity(0.8), radius: 14)
            .scaleEffect(0.92 + 0.16 * breath.value)
    }

    // MARK: 2 · nine words drifting

    private var wordsLayer: some View {
        GeometryReader { g in
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    ForEach(Array(words.enumerated()), id: \.offset) { i, w in
                        let p = drift(i, t, g.size)
                        Text(w)
                            .font(.loraItalic(19))
                            .foregroundColor(BinduTheme.inkPrimary.opacity(0.82))
                            .padding(10)
                            .contentShape(Rectangle())
                            .position(p)
                            .onTapGesture { choose(w) }
                    }
                    dot.position(x: g.size.width / 2, y: g.size.height / 2)
                        .onTapGesture { choose(nil) }
                }
            }
        }
        .transition(.opacity)
    }

    /// Each word on its own slow path, never crossing the dot.
    private func drift(_ i: Int, _ t: Double, _ s: CGSize) -> CGPoint {
        let a = Double(i) / 9 * 2 * .pi + t * 0.035 * (i % 2 == 0 ? 1 : -1)
        let rx = s.width * (0.30 + 0.06 * sin(t * 0.11 + Double(i)))
        let ry = s.height * (0.26 + 0.05 * cos(t * 0.09 + Double(i) * 1.7))
        return CGPoint(x: s.width / 2 + cos(a) * rx, y: s.height / 2 + sin(a) * ry)
    }

    // MARK: 3 · lay it down

    private var layDownLayer: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle().stroke(BinduTheme.inkPrimary.opacity(0.10), lineWidth: 1).frame(width: 150, height: 150)
                Circle().trim(from: 0, to: ring)
                    .stroke(BinduTheme.colorBindu.opacity(0.75), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                    .rotationEffect(.degrees(-90)).frame(width: 150, height: 150)
                Text(chosen ?? "·")
                    .font(.loraItalic(26))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .offset(y: laid ? 24 : 0)
                    .blur(radius: laid ? 8 : 0)
                    .opacity(laid ? 0 : 1)
            }
            .contentShape(Circle())
            .gesture(holdGesture(duration: Self.layHold, onDone: layIt))
            Text(laid ? " " : "hold, and lay it down")
                .spaceMonoTracked(9, em: 0.2)
                .foregroundColor(BinduTheme.inkMuted)
        }
        .transition(.opacity)
    }

    // MARK: 4 · his own words fall

    private var answerLayer: some View {
        VStack(spacing: 26) {
            Spacer()
            if let a = answer {
                Text(a.words)
                    .font(.loraItalic(20))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                    .rotationEffect(.degrees(fell ? 0 : -2.5))
                    .offset(y: fell ? 0 : -46)
                    .opacity(fell ? 1 : 0)
                ZStack {
                    Text("— \(a.signer)")
                        .font(.lora(14))
                        .foregroundColor(signerColor(a).opacity(resolved ? 0 : 0.9))
                    Text("— Ashrey · \(a.spokenOn)")
                        .font(.lora(14))
                        .foregroundColor(BinduTheme.colorAsh.opacity(resolved ? 0.95 : 0))
                }
                .opacity(fell ? 1 : 0)
            }
            Spacer()
            if fell {
                Button { goDown() } label: {
                    Text("go down").spaceMonoTracked(10, em: 0.2)
                        .foregroundColor(BinduTheme.inkSecondary)
                        .padding(12)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
            Spacer().frame(height: 80)
        }
        .padding(.horizontal, 24)
        .transition(.opacity)
    }

    // MARK: 5 · the Still Point

    private var stillStages: [String] {
        guard let a = answer else { return ["·"] }
        let sentences = a.words.split(whereSeparator: { ".?!".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let last = sentences.last.map { $0 + "." } ?? a.words
        let three = last.replacingOccurrences(of: ".", with: "").split(separator: " ").suffix(3).joined(separator: " ")
        return [a.words, last, three, ""]
    }

    private var stillLayer: some View {
        let stages = stillStages
        let s = min(stillStage, stages.count - 1)
        let size: CGFloat = [20, 26, 34, 0][min(s, 3)]
        return VStack(spacing: 30) {
            Spacer()
            ZStack {
                if stages[s].isEmpty {
                    dot.scaleEffect(1.6)
                } else {
                    Text(stages[s])
                        .font(.loraItalic(size))
                        .foregroundColor(BinduTheme.inkPrimary)
                        .lineSpacing(8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(s)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .contentShape(Rectangle())
            .gesture(holdGesture(duration: Self.stillHold, onDone: deeper))
            if s < stages.count - 1 {
                Circle().trim(from: 0, to: ring)
                    .stroke(BinduTheme.inkPrimary.opacity(0.4), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .rotationEffect(.degrees(-90)).frame(width: 28, height: 28)
            }
            Spacer()
            Spacer().frame(height: 80)
        }
        .padding(.horizontal, 24)
        .background(Color.black.opacity(0.25 * Double(s)).ignoresSafeArea())
        .transition(.opacity)
    }

    // MARK: - The hold (one engine: commit at the threshold, early release drains, nothing fails)

    private func holdGesture(duration: Double, onDone: @escaping () -> Void) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                lastTouch = Date()
                guard !holding else { return }
                holding = true
                holdStart = Date()
                tickHold(duration: duration, onDone: onDone)
            }
            .onEnded { _ in
                holding = false
                holdStart = nil
                withAnimation(.easeOut(duration: 0.6)) { ring = 0 }      // drains, never fails
            }
    }

    private func tickHold(duration: Double, onDone: @escaping () -> Void) {
        guard holding, let start = holdStart else { return }
        let p = min(1, Date().timeIntervalSince(start) / duration)
        ring = p
        if p >= 1 {
            holding = false
            holdStart = nil
            onDone()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 60) { tickHold(duration: duration, onDone: onDone) }
    }

    // MARK: - Movement

    private func begin() {
        withAnimation(.easeInOut(duration: 0.8)) { appear = true }
        soundEngine.fieldThreshold(hz: 110, dur: 8)
        withAnimation(.easeOut(duration: 5.0)) { ring = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            ring = 0
            withAnimation(.easeInOut(duration: 1.6)) { phase = .words }
        }
    }

    private func choose(_ w: String?) {
        chosen = w
        if w == nil {               // none — nothing to lay down; the answer comes straight
            reveal()
            return
        }
        ring = 0
        withAnimation(.easeInOut(duration: 1.0)) { phase = .layDown }
    }

    private func layIt() {
        soundEngine.fieldThreshold(hz: 110, dur: 6)
        withAnimation(.easeIn(duration: 1.7)) { laid = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) { reveal() }
    }

    private func reveal() {
        answer = store.callAnswer(for: chosen)
        ring = 0
        withAnimation(.easeInOut(duration: 1.0)) { phase = .answer }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 2.4)) { fell = true }
            soundEngine.fieldThreshold(hz: 136.1, dur: 7)
        }
        lastTouch = Date()
        watchStillness()
        Task { await store.logCall() }
    }

    /// Four seconds of stillness and the voice's name resolves to his own.
    private func watchStillness() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard phase == .answer || phase == .still else { return }
            if !resolved, fell, Date().timeIntervalSince(lastTouch) >= 4.0 + 2.4 {
                withAnimation(.easeInOut(duration: 2.2)) { resolved = true }
                return
            }
            if !resolved { watchStillness() }
        }
    }

    private func goDown() {
        ring = 0
        stillStage = 0
        withAnimation(.easeInOut(duration: 1.2)) { phase = .still }
    }

    private func deeper() {
        ring = 0
        withAnimation(.easeInOut(duration: 1.3)) { stillStage += 1 }
    }

    private func close() {
        withAnimation(.easeInOut(duration: 0.9)) { appear = false }
        soundEngine.fieldThreshold(hz: 136.1, dur: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            onClose()
            // WAVE 3 · a letter sealed "the next time I call" lands as he surfaces
            if answer != nil { store.offerLetter(at: .call) }
        }
    }

    private func signerColor(_ a: CallAnswer) -> Color {
        store.archetype(named: a.signer)?.color ?? BinduTheme.inkSecondary
    }
}
