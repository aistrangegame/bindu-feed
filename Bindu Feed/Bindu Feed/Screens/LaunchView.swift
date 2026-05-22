import SwiftUI

struct LaunchView: View {
    @EnvironmentObject private var store: FeedStore
    var onComplete: () -> Void

    @State private var sentence: ThresholdSentence? = nil
    @State private var phase: Phase = .pause
    @State private var hasStarted = false
    @State private var hasFinished = false

    private enum Phase {
        case pause       // dark, sentence not yet shown
        case visible     // sentence at full opacity
        case fadingOut   // sentence on its way out
    }

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            if let sentence {
                sentenceView(sentence)
                    .opacity(phase == .visible ? 1 : 0)
                    .animation(animation(for: phase), value: phase)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { advanceEarly() }
        .onAppear { startIfReady() }
        .onChange(of: store.foundationLoaded) { _ in startIfReady() }
    }

    // MARK: - Sequence

    private func startIfReady() {
        guard !hasStarted else { return }
        guard store.foundationLoaded, !store.thresholdSentences.isEmpty else { return }
        hasStarted = true
        sentence = store.selectThresholdSentence(from: store.thresholdSentences)

        // 0.8s dark pause → fade in (1.2s) → hold 3.5s → fade out (1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard !hasFinished else { return }
            phase = .visible
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8 + 1.2 + 3.5) {
            beginFadeOut()
        }
    }

    private func beginFadeOut() {
        guard hasStarted, !hasFinished else { return }
        hasFinished = true
        phase = .fadingOut
        // Notify the coordinator at the start of the fade so RootView
        // dissolves up underneath while the sentence dissolves out above.
        onComplete()
    }

    private func advanceEarly() {
        guard hasStarted else { return } // pre-foundation tap is intentionally inert
        beginFadeOut()
    }

    private func animation(for phase: Phase) -> Animation {
        switch phase {
        case .pause:     return .linear(duration: 0)
        case .visible:   return .easeOut(duration: 1.2)
        case .fadingOut: return .easeIn(duration: 1.0)
        }
    }

    // MARK: - Rendering

    @ViewBuilder
    private func sentenceView(_ sentence: ThresholdSentence) -> some View {
        if sentence.isBinduDot {
            binduDot
        } else {
            Text(sentence.text)
                .font(.lora(22))
                .foregroundColor(BinduTheme.inkPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 300)
                .padding(.horizontal, BinduTheme.space24)
        }
    }

    private var binduDot: some View {
        ZStack {
            // Radial glow: #E5533C at 20% opacity, 80pt radius
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            BinduTheme.colorBindu.opacity(0.20),
                            BinduTheme.colorBindu.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .blur(radius: 6)

            Text("·")
                .font(.system(size: 72))
                .foregroundColor(BinduTheme.colorBindu)
        }
    }
}
