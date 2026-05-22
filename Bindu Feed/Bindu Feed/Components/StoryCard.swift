import SwiftUI

struct StoryCard: View {
    let story: Story
    let room: Room?
    let stats: StoryStats
    let archetypes: [Archetype]

    @State private var pulseGlow: Double = 0

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
            if let room {
                CommunityPill(room: room, compact: true)
            }
            Spacer(minLength: BinduTheme.space12)
            Text(story.codexId)
                .font(.spaceMono(10))
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
            Label {
                Text("\(story.resonance)")
                    .font(.spaceMono(11))
                    .foregroundColor(BinduTheme.inkSecondary)
            } icon: {
                Text("▲")
                    .font(.system(size: 10))
                    .foregroundColor(BinduTheme.inkTertiary)
            }

            Label {
                Text("\(stats.commentCount)")
                    .font(.spaceMono(11))
                    .foregroundColor(BinduTheme.inkSecondary)
            } icon: {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 9))
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

    private var isRecent: Bool {
        guard !story.lastActivityDate.isEmpty else { return false }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        guard let date = f.date(from: story.lastActivityDate) else { return false }
        return Date().timeIntervalSince(date) < 7 * 24 * 3600
    }
}
