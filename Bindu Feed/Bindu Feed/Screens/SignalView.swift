import SwiftUI

// Phase 9 — The Signal Space.
//
// One transmission per day, chosen deterministically by date-hash over
// the pool of Live Signal records. Second person, oracular, "from
// further out than the personal mind." Ceremonial: a faint teal point
// arrives, then the words resolve line by line from the dark, then sign
// "— THE FIELD." One clean leave. No comments, no resonance, no "next."
struct SignalView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: NavigationPath

    @State private var loaded = false
    @State private var loadError = false
    @State private var floodOpacity: Double = 1.0
    @State private var currentSignal: Signal?
    @State private var phase: Phase = .arriving
    @State private var phaseTask: Task<Void, Never>?
    @State private var showHub = false

    // fileprivate so the helper views (ReceptionGlow, AntennaDot) in this
    // file can take a `SignalView.Phase` parameter.
    fileprivate enum Phase { case arriving, received, gone }

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#08070D").ignoresSafeArea()

            ReceptionGlow(phase: phase)

            VStack(spacing: 0) {
                Color.clear.frame(height: 56)
                portalTitle
                    .padding(.top, 4)

                content
            }

            HStack(spacing: 10) {
                BackChevron { exitScreen() }
                HubTrigger(open: $showHub)
                Spacer()
            }
            .padding(.horizontal, BinduTheme.space16)
            .padding(.top, BinduTheme.space8)

            // Flood color carries over from Room Selection — matches the
            // new teal Signal Space portal so the transition is seamless.
            BinduTheme.colorAshrey
                .ignoresSafeArea()
                .opacity(floodOpacity)
                .allowsHitTesting(false)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9)) { floodOpacity = 0 }
        }
        .onDisappear {
            phaseTask?.cancel()
        }
        .task(id: store.foundationLoaded) {
            await loadIfNeeded()
        }
        .sonicContext(.base)
        .hubOverlay(open: $showHub, path: $path)
    }

    // MARK: - Title

    private var portalTitle: some View {
        Text("THE SIGNAL SPACE")
            .font(.spaceMono(11))
            .tracking(2.8)
            .foregroundColor(BinduTheme.colorAshrey.opacity(phase == .gone ? 0.4 : 0.8))
            .animation(.easeInOut(duration: 1.2), value: phase)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if !loaded {
            centeredItalic("the field is gathering…", color: BinduTheme.inkTertiary)
        } else if loadError {
            centeredItalic(
                "The field is resting. Try again when you're ready.",
                color: BinduTheme.colorLalita,
                maxWidth: 280
            )
        } else if currentSignal == nil {
            centeredItalic("Nothing is signalling yet.", color: BinduTheme.inkTertiary)
        } else {
            transmissionStack
        }
    }

    private func centeredItalic(_ text: String, color: Color, maxWidth: CGFloat? = nil) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(.loraItalic(13))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .frame(maxWidth: maxWidth)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var transmissionStack: some View {
        VStack(spacing: 0) {
            AntennaDot(phase: phase)
                .padding(.top, phase == .gone ? 200 : 90)
                .animation(.easeInOut(duration: 1.4), value: phase)

            transmissionContent
                .padding(.horizontal, 36)
                .padding(.top, 38)

            Spacer(minLength: 0)

            if phase == .received {
                leaveButton
                    .padding(.bottom, BinduTheme.space24 + 24)
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var transmissionContent: some View {
        switch phase {
        case .arriving:
            Text("A SIGNAL IS ARRIVING")
                .font(.spaceMono(9))
                .tracking(2.2)
                .foregroundColor(BinduTheme.colorAshrey.opacity(0.5))
                .modifier(BreathingOpacityHint())
        case .received:
            receivedLines
        case .gone:
            goneState
        }
    }

    private var receivedLines: some View {
        let lines = Self.splitIntoLines(currentSignal?.body ?? "")
        return VStack(spacing: 14) {
            ForEach(Array(lines.enumerated()), id: \.offset) { i, line in
                StaggeredReveal(
                    triggered: phase == .received,
                    delay: 0.12 + Double(i) * 0.52,
                    duration: 1.4
                ) {
                    Text(line)
                        .font(.lora(20))
                        .foregroundColor(BinduTheme.inkPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            StaggeredReveal(
                triggered: phase == .received,
                delay: 0.12 + Double(lines.count) * 0.52 + 0.6,
                duration: 1.6
            ) {
                Text("— THE FIELD")
                    .font(.spaceMono(10))
                    .tracking(2.0)
                    .foregroundColor(BinduTheme.colorAshrey.opacity(0.6))
                    .padding(.top, 18)
            }
        }
    }

    private var goneState: some View {
        VStack(spacing: 22) {
            Text("The signal was received.\nThe field is quiet now.")
                .font(.loraItalic(16))
                .foregroundColor(BinduTheme.inkSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Text("ONE A DAY · RETURN TOMORROW")
                .font(.spaceMono(9))
                .tracking(1.8)
                .foregroundColor(BinduTheme.inkTertiary)
        }
        .padding(.top, 28)
        .transition(.opacity)
    }

    private var leaveButton: some View {
        Button { tapLeave() } label: {
            Text("LEAVE")
                .font(.spaceMono(10))
                .tracking(2.2)
                .foregroundColor(BinduTheme.inkTertiary)
                .padding(10)
                .modifier(BreathingOpacityHint())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Phase actions

    private func tapLeave() {
        guard phase == .received else { return }
        withAnimation(.easeInOut(duration: 1.4)) {
            phase = .gone
        }
    }

    private func exitScreen() {
        phaseTask?.cancel()
        $path.popDissolve()
    }

    // MARK: - Loading + selection

    private func loadIfNeeded() async {
        guard !loaded else { return }
        guard store.foundationLoaded else { return }

        await store.loadSignals()
        let signals = store.signals

        if signals.isEmpty {
            loadError = store.error != nil
            loaded = true
            return
        }

        let key = Self.dayKey
        let idx = Int(Self.fnv1a(key + "·signal") % UInt32(signals.count))
        currentSignal = signals[idx]
        loaded = true
        beginArrival()
    }

    // 2.6s arriving pause matches the prototype — long enough that the
    // antenna feels like a real reception, not a loading spinner.
    private func beginArrival() {
        phase = .arriving
        phaseTask?.cancel()
        phaseTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            if !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.6)) {
                    phase = .received
                }
            }
        }
    }

    // MARK: - Helpers

    // Local time — "today's signal" matches the user's day, not a UTC
    // server's day. See feedback-local-time-day-keys.
    private static var dayKey: String { AirtableService.localDayString() }   // POSIX/Gregorian/local

    private static func fnv1a(_ s: String) -> UInt32 {
        var h: UInt32 = 2166136261
        for byte in s.utf8 {
            h ^= UInt32(byte)
            h = h &* 16777619
        }
        return h
    }

    // Splits a transmission body into reveal-lines. Honors explicit \n
    // breaks first (lets a future Airtable edit override the heuristic
    // for a specific signal), otherwise splits on sentence boundaries and
    // em-dashes — the two natural pause points in this register.
    static func splitIntoLines(_ body: String) -> [String] {
        let explicit = body
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if explicit.count > 1 { return explicit }

        let pattern = "(?<=[.!?—])\\s+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [body]
        }
        let nsBody = body as NSString
        let matches = regex.matches(in: body, range: NSRange(location: 0, length: nsBody.length))
        if matches.isEmpty { return [body] }

        var result: [String] = []
        var lastEnd = 0
        for match in matches {
            let segRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
            let segment = nsBody.substring(with: segRange).trimmingCharacters(in: .whitespacesAndNewlines)
            if !segment.isEmpty { result.append(segment) }
            lastEnd = match.range.location + match.range.length
        }
        let tail = nsBody.substring(from: lastEnd).trimmingCharacters(in: .whitespacesAndNewlines)
        if !tail.isEmpty { result.append(tail) }
        return result.isEmpty ? [body] : result
    }
}

// MARK: - Reception glow

private struct ReceptionGlow: View {
    let phase: SignalView.Phase

    var body: some View {
        let received = phase != .arriving
        let gone = phase == .gone
        return RadialGradient(
            colors: [
                BinduTheme.colorAshrey.opacity(received ? 0.18 : 0.07),
                BinduTheme.colorAshrey.opacity(received ? 0.05 : 0.02),
                .clear
            ],
            center: UnitPoint(x: 0.5, y: 0.3),
            startRadius: 0,
            endRadius: 460
        )
        .opacity(gone ? 0 : 1)
        .animation(.easeInOut(duration: 1.6), value: phase)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Antenna dot

private struct AntennaDot: View {
    let phase: SignalView.Phase

    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(BinduTheme.colorAshrey)
            .frame(width: 9, height: 9)
            .shadow(
                color: BinduTheme.colorAshrey.opacity(phase == .received ? 0.85 : 0.6),
                radius: phase == .received ? 13 : 8
            )
            .shadow(
                color: BinduTheme.colorAshrey.opacity(0.4),
                radius: phase == .received ? 26 : 15
            )
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                // One steady breath cycle that re-targets when phase
                // changes (low/high values switch).
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
            .animation(.easeInOut(duration: 1.4), value: phase)
    }

    private var opacity: Double {
        switch phase {
        case .arriving: return pulse ? 1.0 : 0.40
        case .received: return pulse ? 1.0 : 0.78
        case .gone:     return 0.3
        }
    }

    private var scale: CGFloat {
        switch phase {
        case .arriving: return pulse ? 1.55 : 1.0
        case .received: return pulse ? 1.04 : 0.98
        case .gone:     return 1.0
        }
    }
}

// MARK: - Breathing hint (caption + leave button)

private struct BreathingOpacityHint: ViewModifier {
    @EnvironmentObject private var breath: Breath   // the one master breath
    func body(content: Content) -> some View {
        content.opacity(0.24 + 0.28 * breath.value)
    }
}
