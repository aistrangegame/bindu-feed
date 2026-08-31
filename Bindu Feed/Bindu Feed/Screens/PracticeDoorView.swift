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
                        .spaceMonoTracked(10)
                        .tracking(2.4)
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
        }
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
                    .spaceMonoTracked(10)
                    .tracking(0.6)
                    .foregroundColor(BinduTheme.inkTertiary)
            }
        }
    }

    private var tapHint: some View {
        Text("TAP TO CROSS")
            .spaceMonoTracked(9)
            .tracking(1.6)
            .foregroundColor(BinduTheme.inkTertiary)
            .opacity(0.24 + 0.31 * breath.value)   // the one master breath
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
