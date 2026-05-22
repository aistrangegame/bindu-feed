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

    private var header: some View {
        HStack(alignment: .top, spacing: 9) {
            avatarButton

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(comment.archetype)
                        .font(.lora(13, weight: .medium))
                        .foregroundColor(parentColor)
                    Spacer(minLength: BinduTheme.space8)
                    if comment.resonance > 0 {
                        Text("♡ \(comment.resonance)")
                            .font(.spaceMono(10))
                            .foregroundColor(BinduTheme.inkTertiary)
                    }
                }
                if let role = archetype?.role, !role.isEmpty {
                    Text(role.uppercased())
                        .font(.spaceMono(10))
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
            // Placeholder while archetype lookup unavailable
            Circle()
                .fill(BinduTheme.inkTertiary.opacity(0.2))
                .frame(width: 36, height: 36)
        }
    }
}
