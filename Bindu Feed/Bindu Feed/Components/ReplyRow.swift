import SwiftUI

// A threaded reply nested inside a CommentCard.
// Indented 20pt with a 1.5pt left spine in the parent archetype's color.
// Smaller avatar (24pt) and body type (Lora 13pt @ ink60).
struct ReplyRow: View {
    let comment: FieldComment
    let archetype: Archetype?
    let parentColor: Color
    let onArchetypeTap: (Archetype) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Spine
            Rectangle()
                .fill(parentColor.opacity(0.38))
                .frame(width: 1.5)
                .padding(.leading, 20)

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
