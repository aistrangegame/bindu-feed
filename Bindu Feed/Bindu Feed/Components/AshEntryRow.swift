import SwiftUI

// The closed-state entry point that lives below all field comments.
// Tap to open the inline composer. The four words are exact and
// permanent: "What arrived for you?"
struct AshEntryRow: View {
    let onTap: () -> Void

    private let terra = BinduTheme.colorAsh

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)

            Button(action: onTap) {
                HStack(spacing: 11) {
                    ZStack {
                        Circle()
                            .fill(terra.opacity(0.22))
                            .blur(radius: 4)
                            .frame(width: 46, height: 46)
                        Circle()
                            .fill(terra)
                            .frame(width: 30, height: 30)
                        Text("◉")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(width: 30, height: 30)

                    Text("What arrived for you?")
                        .font(.loraItalic(14))
                        .foregroundColor(terra.opacity(0.70))
                        .tracking(0.2)

                    Spacer()
                }
                .padding(.top, 15)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

// Renders an Ash Comment in Story Detail's "your voice has been here"
// section below the field comments. The date defaults to "JUST NOW" so
// fresh-post scenarios keep their meaning; refreshed comments pass a
// formatted source date.
struct AshPostedCard: View {
    let commentBody: String
    var date: String = "JUST NOW"
    var name: String = "Ash"
    // The Audio Anchor, quietly: a small voice mark when this entry kept a recording that
    // lives on THIS device. Never a loud play button — the story is the quiet surface; the
    // voice is fully crossed-into through the Return. The parent owns the shared player.
    var audioReference: String? = nil
    var isPlayingThis: Bool = false
    var onPlayTap: () -> Void = {}

    private let terra = BinduTheme.colorAsh

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 9) {
                ZStack {
                    Circle()
                        .fill(terra.opacity(0.22))
                        .blur(radius: 4)
                        .frame(width: 54, height: 54)
                    Circle()
                        .fill(terra)
                        .frame(width: 36, height: 36)
                    Text("◉")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.lora(13, weight: .medium))
                        .foregroundColor(terra)
                    Text(date)
                        .spaceMonoTracked(10)
                        .tracking(0.6)
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                Spacer()
                if AudioAnchorPlayer.exists(audioReference) {
                    Button(action: onPlayTap) {
                        Text("◉")
                            .font(.system(size: 14))
                            .foregroundColor(terra.opacity(isPlayingThis ? 1.0 : 0.42))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(commentBody)
                .font(.lora(15))
                .foregroundColor(terra)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(terra.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(terra.opacity(0.22), lineWidth: 0.5)
        )
    }
}
