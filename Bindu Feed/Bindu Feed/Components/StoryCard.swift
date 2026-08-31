import SwiftUI

struct StoryCard: View {
    let story: Story
    let room: Room?
    let stats: StoryStats
    let archetypes: [Archetype]
    /// The community pill is shown on the Home Feed; hidden inside a room (Game View),
    /// where you already know which room you're in (comp Game View.html omits it).
    var showCommunity: Bool = true

    @EnvironmentObject private var store: FeedStore
    @State private var pulseGlow: Double = 0
    @State private var resonanceBoost: Int = 0
    @State private var resonancePressed: Bool = false
    @State private var resonanceInFlight: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: BinduTheme.space12) {
            topRow
            titleAndExcerpt
            bottomRow
        }
        .padding(BinduTheme.space16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .panel()
        .overlay(
            // Single soft luminance pulse on appear when recent.
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(BinduTheme.accent.opacity(pulseGlow), lineWidth: 0.5)
                .allowsHitTesting(false)
        )
        .onAppear { firePulseIfRecent() }
    }

    // MARK: - Sections

    private var topRow: some View {
        HStack(alignment: .center) {
            if showCommunity, let room {
                CommunityPill(room: room, compact: true)
            }
            Spacer(minLength: BinduTheme.space12)
            Text(story.codexId)
                .spaceMonoTracked(10)
                .foregroundColor(BinduTheme.inkTertiary)
                .tracking(0.5)
        }
    }

    private var titleAndExcerpt: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(story.title)
                .font(.lora(19, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .lineSpacing(2)
                .lineLimit(3)

            if !story.excerpt.isEmpty {
                Text(story.excerpt)
                    .font(.lora(14))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .lineSpacing(3)
                    .lineLimit(2)
            }
        }
    }

    private var bottomRow: some View {
        HStack(alignment: .center, spacing: BinduTheme.space12) {
            Button(action: handleResonate) {
                Label {
                    Text("\(story.resonance + resonanceBoost)")
                        .spaceMonoTracked(11)
                        .foregroundColor(BinduTheme.inkSecondary)
                } icon: {
                    Text("\u{2661}")                        // ♡ — the resonance glyph, one across the app
                        .font(.system(size: 11))
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .scaleEffect(resonancePressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.32, dampingFraction: 0.55), value: resonancePressed)
            .disabled(resonanceInFlight)

            Label {
                Text("\(stats.commentCount)")
                    .spaceMonoTracked(11)
                    .foregroundColor(BinduTheme.inkSecondary)
            } icon: {
                Text("\u{21B3}")                            // ↳ — comments, the comp's own mark
                    .font(.system(size: 11))
                    .foregroundColor(BinduTheme.inkTertiary)
            }

            Spacer(minLength: BinduTheme.space8)

            if !archetypes.isEmpty {
                VoiceAvatarStack(archetypes: archetypes, size: 22)
            }
        }
    }

    // MARK: - Pulse

    private func firePulseIfRecent() {
        guard isRecent else { return }
        // Run once: fade in over 0.6s, hold briefly, fade out over 1.6s.
        withAnimation(.easeOut(duration: 0.6)) { pulseGlow = 0.35 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 1.6)) { pulseGlow = 0 }
        }
    }

    // MARK: - Resonance

    private func handleResonate() {
        guard !resonanceInFlight else { return }
        let current = story.resonance + resonanceBoost
        resonanceBoost += 1
        resonanceInFlight = true
        resonancePressed = true

        Task { @MainActor in
            await store.incrementResonance(
                recordId: story.id,
                current: current,
                storyContext: ResonanceStoryContext(title: story.title, excerpt: story.excerpt)
            )
            resonanceInFlight = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            resonancePressed = false
        }
    }

    private var isRecent: Bool {
        guard !story.lastActivityDate.isEmpty else { return false }
        let f = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC") ?? .current)
        guard let date = f.date(from: story.lastActivityDate) else { return false }
        return Date().timeIntervalSince(date) < 7 * 24 * 3600
    }
}
