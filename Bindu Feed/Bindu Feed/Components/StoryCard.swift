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
                // `border-color` AND `box-shadow` — the glow is the half that carries.
                .stroke(BinduTheme.accent.opacity(0.26 * pulseGlow), lineWidth: 0.5)
                .shadow(color: BinduTheme.accent.opacity(0.13 * pulseGlow), radius: 14)
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

    // F2.4 + F2.7 · **THE COUNTS ARE INERT TEXT, AND THE WHOLE CARD IS THE TAP TARGET.**
    // `Claude Design Round 1/Home Feed.html:118-121` — `gap:16`, both `♡ n` and `↳ n` in
    // Space Mono 10 at `--ink35`, each **a single text run**.
    //
    // **F2.7 · THE ♡ WAS A BUTTON THAT PATCHED AIRTABLE, AND THE DESIGN NEVER PUT A WRITE
    // HERE.** `:119` is a `<span>` inside one `<a href>`: the card is a link into the story,
    // and the counts report what the field has done. An invented write is bad twice over —
    // it puts a base mutation behind a glyph nobody was told was a control, and it competes
    // with the card's own tap target, so a thumb aiming at the story sometimes resonated it.
    // **The capability is not lost**: `StoryDetailView` resonates, which is where the design
    // places it — you go in, and then you answer.
    //
    // F2.4 · both runs at 10pt in `inkTertiary`. The app had 11pt numerals one ink tier
    // brighter, and glyphs in the SYSTEM font beside Space Mono numerals — so `♡ 89` was two
    // typefaces at two weights pretending to be one label.
    private var bottomRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("\u{2661} \(story.resonance)")
                .spaceMonoTracked(10)
                .foregroundColor(BinduTheme.inkTertiary)
            Text("\u{21B3} \(stats.commentCount)")
                .spaceMonoTracked(10)
                .foregroundColor(BinduTheme.inkTertiary)

            Spacer(minLength: BinduTheme.space8)

            if !archetypes.isEmpty {
                VoiceAvatarStack(archetypes: archetypes, size: 22)
            }
        }
    }

    // MARK: - Pulse

    /// F2.6 · `Home Feed.html:30-34,110` — `livePulse 4.5s ease-in-out 1.2s 1 forwards`,
    /// peaking at **45%**: `border-color → rgba(155,107,214,0.26)` **and**
    /// `box-shadow: 0 0 28px rgba(155,107,214,0.13)`.
    ///
    /// Three things were wrong and one of them is not fixable here. The app ran 2.4s against
    /// 4.5s, started immediately where the design waits **1.2s** — the lead-in is what makes
    /// it read as the card noticing something rather than the card appearing — and drew only a
    /// border stroke with **no outer glow**, which is the half that carries at arm's length.
    ///
    /// **THE TRIGGER STAYS DIVERGENT AND IT IS RECORDED RATHER THAN INVENTED.** The design
    /// pulses on an **authored per-story `pulse:true`** (`:70-82`, demo data in the comp); the
    /// base carries no such field, and adding one would be inventing content the design never
    /// asks for — the same ruling as the Record's condensed line. So the app keeps its derived
    /// 7-day window and the RENDER is made faithful. What is authored and what is derived are
    /// different claims, and only one of them is ours to fix.
    private func firePulseIfRecent() {
        guard isRecent else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {          // `1.2s` lead-in
            withAnimation(.easeInOut(duration: 4.5 * 0.45)) { pulseGlow = 1 }   // to the 45% peak
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5 * 0.45) {
                withAnimation(.easeInOut(duration: 4.5 * 0.55)) { pulseGlow = 0 }
            }
        }
    }

    // F2.7 · `handleResonate` and its three `@State` flags are DELETED, not merely unwired.
    // It held a live `store.incrementResonance` — a PATCH to the base — and dead code with a
    // base write in it is what a later hand rewires without ever learning that the design put
    // no write on this card. The capability lives in `StoryDetailView`, where the design
    // places it. `git log` is the record; the file is not the place to keep a removed action.

    private var isRecent: Bool {
        guard !story.lastActivityDate.isEmpty else { return false }
        let f = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC") ?? .current)
        guard let date = f.date(from: story.lastActivityDate) else { return false }
        return Date().timeIntervalSince(date) < 7 * 24 * 3600
    }
}
