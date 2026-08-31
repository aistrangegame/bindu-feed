import SwiftUI

// A threaded reply nested inside a CommentCard.
// Indented 20pt with a 1.5pt left spine in the parent archetype's color.
// Smaller avatar (24pt) and body type (Lora 13pt @ ink60).
struct ReplyRow: View {
    let comment: FieldComment
    let archetype: Archetype?
    let parentColor: Color
    let onArchetypeTap: (Archetype) -> Void

    @EnvironmentObject private var store: FeedStore
    @State private var resonanceBoost: Int = 0
    @State private var resonancePressed: Bool = false
    @State private var resonanceInFlight: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Spine
            // F5.2 · **INDENT IS HIERARCHY.** `Claude Design Round 1/comps/Story Detail.html:544-549`
            // — `marginLeft: 42`, `paddingLeft: 12`, `borderLeft: 1.5px solid ${parentColor}38`.
            // The app's spine sat at 20, so a reply read as another voice at the same level
            // rather than as an answer to the one above it. The audit named the consequence
            // exactly — *"replies read as barely-indented siblings rather than a clear
            // thread"* — and then filed it MINOR, because the delta is 22 points.
            Rectangle()
                .fill(parentColor.opacity(0.38))
                .frame(width: 1.5)
                .padding(.leading, 42)

            content
                .padding(.leading, 12)
        }
        .padding(.top, 14)
    }

    private var content: some View {
        HStack(alignment: .top, spacing: 8) {
            avatarButton

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(comment.archetype)
                        .font(.lora(12, weight: .medium))
                        .foregroundColor(archetypeColor)
                    Spacer(minLength: BinduTheme.space8)
                    if displayResonance > 0 {
                        Button(action: handleResonate) {
                            Text("♡ \(displayResonance)")
                                .spaceMonoTracked(10)
                                .foregroundColor(BinduTheme.inkTertiary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(resonancePressed ? 0.85 : 1.0)
                        .animation(.spring(response: 0.32, dampingFraction: 0.55), value: resonancePressed)
                        .disabled(resonanceInFlight)
                    }
                }

                if let role = archetype?.role, !role.isEmpty {
                    Text(role.uppercased())
                        .spaceMonoTracked(10)
                        .tracking(0.6)
                        .foregroundColor(BinduTheme.inkTertiary)
                }

                Text(comment.body)
                    .font(.lora(13))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
    }

    private var archetypeColor: Color {
        archetype?.color ?? BinduTheme.inkSecondary
    }

    private var displayResonance: Int { comment.resonance + resonanceBoost }

    private func handleResonate() {
        guard !resonanceInFlight else { return }
        let current = displayResonance
        resonanceBoost += 1
        resonanceInFlight = true
        resonancePressed = true

        Task { @MainActor in
            await store.incrementResonance(recordId: comment.id, current: current)
            resonanceInFlight = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            resonancePressed = false
        }
    }

    @ViewBuilder
    private var avatarButton: some View {
        if let archetype {
            Button {
                onArchetypeTap(archetype)
            } label: {
                VoiceAvatar(archetype: archetype, size: 24)
            }
            .buttonStyle(.plain)
        } else {
            Circle()
                .fill(BinduTheme.inkTertiary.opacity(0.2))
                .frame(width: 24, height: 24)
        }
    }
}
