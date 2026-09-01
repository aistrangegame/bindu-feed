import SwiftUI

// Top-level field comment as it appears in Story Detail.
// Inset well (bgInset), avatar + name + role, body in Lora,
// resonance heart on the right. Threaded replies render below
// with a colored spine in the parent archetype's color.
struct CommentCard: View {
    let comment: FieldComment
    let archetype: Archetype?
    let replies: [CommentNode]
    let lookupArchetype: (String) -> Archetype?
    let onArchetypeTap: (Archetype) -> Void

    @EnvironmentObject private var store: FeedStore
    @State private var resonanceBoost: Int = 0
    @State private var resonancePressed: Bool = false
    @State private var resonanceInFlight: Bool = false

    var body: some View {
        if comment.isBinduSilence {
            BinduSilenceCard()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 10)

                Text(comment.body)
                    .font(.lora(15))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                if !replies.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(replies) { node in
                            ReplyRow(
                                comment: node.comment,
                                archetype: lookupArchetype(node.comment.archetype),
                                parentColor: parentColor,
                                onArchetypeTap: onArchetypeTap
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(BinduTheme.bgInset)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
            )
        }
    }

    private var parentColor: Color {
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

    private var header: some View {
        HStack(alignment: .top, spacing: 9) {
            avatarButton

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(comment.archetype)
                        .font(.lora(13, weight: .medium))
                        .foregroundColor(parentColor)
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
            }
        }
    }

    @ViewBuilder
    private var avatarButton: some View {
        if let archetype {
            Button {
                onArchetypeTap(archetype)
            } label: {
                VoiceAvatar(archetype: archetype, size: 36)
            }
            .buttonStyle(.plain)
        } else {
            // A voice whose lens hasn't resolved (archetypes not yet loaded) — a quiet Bindu
            // dot rather than a blank disc, so it reads as "a presence, unnamed", not an error.
            ZStack {
                Circle().fill(BinduTheme.inkTertiary.opacity(0.14)).frame(width: 36, height: 36)
                Text("·").font(.system(size: 16)).foregroundColor(BinduTheme.inkTertiary.opacity(0.6))
            }
        }
    }
}
