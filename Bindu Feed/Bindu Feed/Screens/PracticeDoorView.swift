import SwiftUI

// Phase 9 — The Practice Door.
//
// The launch surface on every open. One of five kinds surfaces per open
// (threshold 40 / practice 23 / gaiaSeed 20 / story 12 / binduDot 5;
// nothing repeats back-to-back; first-ever open = threshold; Bindu
// never doubles). Selection happens in FeedStore.selectPracticeDoorContent.
//
// Tap anywhere to cross — no countdown. The screen settles to dark, then
// the home feed dissolves up underneath via ContentCoordinator.
struct PracticeDoorView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var breath: Breath      // the one master breath
    var onComplete: () -> Void

    @State private var content: PracticeDoorContent?
    @State private var visible = false
    @State private var hasStarted = false
    @State private var hasCrossed = false
    /// SLICE 8 · nil until he answers a seed; then true (offered) or false (held in silence).
    @State private var seedAnswer: Bool?

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            if !store.foundationLoaded {
                preFoundation
            } else if let content {
                contentScreen(for: content)
            } else {
                // Foundation loaded but the selector returned nil (no kind had any data).
                // Must NOT be a trap — this surface has no hub/back, so without an escape a
                // force-quit was the only recovery. Give it TRY AGAIN, like preFoundation.
                VStack(spacing: BinduTheme.space20) {
                    Text("The field is resting. Try again when you're ready.")
                        .font(.loraItalic(15))
                        .foregroundColor(BinduTheme.colorLalita)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: 280)
                    Button {
                        store.error = nil
                        Task { await store.loadFoundation(); startIfReady() }
                    } label: {
                        Text("TRY AGAIN")
                            .spaceMonoTracked(9, em: 2.0 / 9)
                            .foregroundColor(BinduTheme.inkSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, BinduTheme.space24)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { cross() }
        .onAppear { startIfReady() }
        .onChange(of: store.foundationLoaded) { startIfReady() }
        // Hide the system nav bar so the hub-launched route case doesn't
        // get a default back chevron — tap-anywhere-to-cross is the only
        // gesture this surface offers, in both launch and route contexts.
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sonicContext(.base)
    }

    // MARK: - Pre-foundation state

    @ViewBuilder
    private var preFoundation: some View {
        if store.error != nil {
            VStack(spacing: BinduTheme.space20) {
                Text("The field is resting. Try again when you're ready.")
                    .font(.loraItalic(15))
                    .foregroundColor(BinduTheme.colorLalita)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: 280)
                Button {
                    store.error = nil
                    Task { await store.loadFoundation() }
                } label: {
                    Text("TRY AGAIN")
                        .spaceMonoTracked(9)
                        .tracking(2.0)
                        .foregroundColor(BinduTheme.inkSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BinduTheme.space24)
        } else {
            VStack(spacing: BinduTheme.space20) {
                GlyphView(
                    glyph: "∞",
                    size: 56,
                    color: BinduTheme.colorLalita,
                    animation: .glyphField
                )
                Text("The field is gathering.")
                    .font(.loraItalic(13))
                    .foregroundColor(BinduTheme.inkTertiary)
            }
        }
    }

    // MARK: - Door screen for the chosen content

    @ViewBuilder
    private func contentScreen(for content: PracticeDoorContent) -> some View {
        let accent = accentColor(for: content)

        ZStack {
            atmosphere(accent: accent)

            VStack(spacing: 0) {
                Spacer()

                let label = labelText(for: content)
                if !label.isEmpty {
                    Text(label)
                        // `spaceMonoTracked` applies `.tracking(em * size)` to the Text
                        // INSIDE it (`Theme.swift:151`), so a View-level `.tracking` after
                        // it never reaches the glyphs — the label shipped at 0 tracking
                        // while reading as though it had been set. 2.4pt at 10 = 0.24em.
                        .spaceMonoTracked(10, em: 0.24)
                        .foregroundColor(accent.opacity(0.66))
                        .padding(.bottom, 36)
                }

                doorBody(for: content, accent: accent)

                Spacer()

                tapHint
                    .padding(.bottom, BinduTheme.space24 + 10)
            }
            .padding(.horizontal, BinduTheme.space24)
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 8)
            .animation(.easeOut(duration: 1.4), value: visible)
        }
    }

    private func atmosphere(accent: Color) -> some View {
        ZStack {
            RadialGradient(
                colors: [accent.opacity(0.14), accent.opacity(0.035), .clear],
                center: UnitPoint(x: 0.5, y: 0.22),
                startRadius: 0,
                endRadius: 480
            )
            .opacity(0.34 + 0.44 * breath.value)   // the one master breath

            RadialGradient(
                colors: [accent.opacity(0.08), .clear],
                center: UnitPoint(x: 0.5, y: 1.12),
                startRadius: 0,
                endRadius: 440
            )

            // the air settles — the day's light has passed
            DoorDust(rising: false, color: accent)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func doorBody(for content: PracticeDoorContent, accent: Color) -> some View {
        switch content {
        case .threshold(let sentence):
            // Bindu dots are routed through the separate .binduDot kind;
            // if one slips through here (e.g., a "Sentence Source != Bindu"
            // filter missed it), fall back to the ember render.
            if sentence.isBinduDot {
                binduEmber
            } else {
                proseBody(sentence.text, italic: true)
            }
        case .practice(let p):
            // Practice Door.html:146,155-159 — the sub-line is the last child of the
            // SAME centred stack as the body, at the container's own gap of 22, so it
            // rises with the body on the shared fade rather than on a timer of its own.
            VStack(spacing: 22) {
                proseBody(p.body, italic: false)
                if let sub = p.subLine {
                    Text(sub)
                        .font(.loraItalic(14))
                        .tracking(0.7)                     // 0.05em x 14
                        .foregroundColor(accent.opacity(0.70))
                        .multilineTextAlignment(.center)
                }
            }
        case .gaiaSeed(let seed):
            // The door renders the seed as one prose block — line-by-line
            // arrival is the Signal Space's ceremony, not the door's.
            proseBody(seed.body, italic: false)
        case .story(let story):
            storyDoor(story)
        case .binduDot:
            binduEmber
        case .leela(let drop):
            seedDoor(drop, accent: accent)
        }
    }

    /// SLICE 8 · A SEED THAT FOUND HIM. The passage, then the act set apart, then two equal
    /// answers — neither carries shame (a-strange-game D34: *offer it · hold in silence*). An
    /// answer is a whisper and nothing more: the two choices fade, the act stays. A touch
    /// anywhere else still crosses, unanswered, and that is complete too.
    private func seedDoor(_ drop: LeelaDrop, accent: Color) -> some View {
        VStack(spacing: 22) {
            ForEach(Array(drop.passage.enumerated()), id: \.offset) { _, para in
                Text(para)
                    .font(.loraItalic(19))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 320)
            }
            if !drop.act.isEmpty {
                Text(drop.act)
                    .font(.lora(16, weight: .medium))
                    .foregroundColor(accent)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 300)
                    .padding(.top, 6)
            }
            Group {
                if let answered = seedAnswer {
                    Text(answered ? "◡" : "·")
                        .font(.lora(18))
                        .foregroundColor(accent.opacity(0.9))
                        .transition(.opacity)
                } else {
                    HStack(spacing: 34) {
                        Button { answer(drop, offered: true) } label: {
                            Text("offer it").spaceMonoTracked(10, em: 0.2)
                                .foregroundColor(BinduTheme.inkSecondary)
                                .padding(.vertical, 10)
                        }
                        Button { answer(drop, offered: false) } label: {
                            Text("hold in silence").spaceMonoTracked(10, em: 0.2)
                                .foregroundColor(BinduTheme.inkSecondary)
                                .padding(.vertical, 10)
                        }
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.top, 8)
        }
    }

    private func answer(_ drop: LeelaDrop, offered: Bool) {
        soundEngine.fieldThreshold(hz: offered ? 136.1 : 110, dur: 6)
        withAnimation(.easeInOut(duration: 1.6)) { seedAnswer = offered }
        Task { await store.answerLeela(drop, offered: offered) }
    }

    private func proseBody(_ text: String, italic: Bool) -> some View {
        Text(text)
            .font(italic ? .loraItalic(22) : .lora(22, weight: .medium))
            .foregroundColor(BinduTheme.inkPrimary)
            .multilineTextAlignment(.center)
            .lineSpacing(8)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 320)
    }

    private var binduEmber: some View {
        Text("·")
            .font(.system(size: 80))
            .foregroundColor(BinduTheme.colorBindu)
            .shadow(color: BinduTheme.colorBindu.opacity(0.7), radius: 20)
            .modifier(EmberBreathe())
    }

    private func storyDoor(_ story: Story) -> some View {
        let room = store.room(named: story.room)
        return VStack(spacing: 18) {
            if let room {
                CommunityPill(room: room, compact: true)
            }
            Text(story.title)
                .font(.lora(22, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .tracking(-0.3)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 320)
            if !story.excerpt.isEmpty {
                Text("\u{201C}\(story.excerpt)\u{201D}")
                    .font(.loraItalic(14))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 290)
            }
            if !story.codexId.isEmpty {
                Text(story.codexId)
                    .spaceMonoTracked(10, em: 0.06)
                    .foregroundColor(BinduTheme.inkTertiary)
            }
        }
    }

    private var tapHint: some View {
        Text("TAP TO CROSS")
            .spaceMonoTracked(9, em: 0.18)
            // SLICE 4 · legible at the bottom of its breath — it ran 8%–19% and vanished.
            .foregroundColor(BinduTheme.inkMuted)
            .opacity(0.85 + 0.15 * breath.value)   // the one master breath, over the measured ink
    }

    private func centeredItalic(_ text: String, color: Color, maxWidth: CGFloat? = nil) -> some View {
        Text(text)
            .font(.loraItalic(15))
            .foregroundColor(color)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .frame(maxWidth: maxWidth)
    }

    // MARK: - Cross

    private func cross() {
        guard hasStarted, !hasCrossed, content != nil else { return }
        hasCrossed = true

        // Practice Door tone — fires every door cross (cold launch +
        // hub-pushed). Per Model B in the Sound Layer: Practice Door
        // owns the launch threshold; Arrival fires on foreground
        // resume (handled in ContentCoordinator's scene-phase change).
        if let tone = store.practiceDoorTone {
            soundEngine.playPracticeDoorTone(tone)
        }

        // Door content fades out; coordinator's own dissolve takes over
        // for the Root swap. Notify after the content has visibly settled
        // so the home feed dissolves up "underneath."
        withAnimation(.easeIn(duration: 0.8)) {
            visible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onComplete()
        }
    }

    // MARK: - Selection + start

    private func startIfReady() {
        guard !hasStarted else { return }
        guard store.foundationLoaded else { return }
        hasStarted = true
        content = store.selectPracticeDoorContent()
        // Tiny delay so the rise animation reads as an arrival, not a
        // hard-cut. Matches the prototype's 70ms settle.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation { visible = true }
        }
    }

    // MARK: - Per-kind helpers

    private func labelText(for content: PracticeDoorContent) -> String {
        switch content {
        case .threshold: return "A THRESHOLD"
        case .practice:  return "A PRACTICE"
        case .gaiaSeed:  return "A GAIA SEED"
        case .story:     return "WHAT FOUND YOU"
        case .binduDot:  return ""    // canon — no label, the dot is the whole thing
        case .leela:     return ""    // SLICE 8 · never labelled — the play never names itself
        }
    }

    private func accentColor(for content: PracticeDoorContent) -> Color {
        switch content {
        case .threshold: return Color(hex: "#C9A07A")    // dawn warm-gold
        case .practice:  return Color(hex: "#8C96B8")    // slate-blue
        case .gaiaSeed:  return BinduTheme.colorGaia
        case .story(let story):
            return store.room(named: story.room)?.color ?? BinduTheme.colorGaia
        case .binduDot:  return BinduTheme.colorBindu
        case .leela:     return BinduTheme.colorLalita
        }
    }
}

// MARK: - Ember breath modifier

private struct EmberBreathe: ViewModifier {
    @EnvironmentObject private var masterBreath: Breath   // the one 0.1 Hz origin
    func body(content: Content) -> some View {
        let v = masterBreath.value
        return content
            .opacity(0.55 + 0.45 * v)
            .scaleEffect(0.97 + 0.09 * v)
    }
}
