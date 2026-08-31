import SwiftUI

struct CommunityFilterBar: View {
    let rooms: [Room]
    @Binding var selectedRoom: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BinduTheme.space8) {
                AllChip(active: selectedRoom == nil) {
                    selectedRoom = nil
                }
                ForEach(rooms) { room in
                    RoomChip(room: room, active: selectedRoom == room.name) {
                        selectedRoom = (selectedRoom == room.name) ? nil : room.name
                    }
                }
            }
            .padding(.horizontal, BinduTheme.space16)
        }
    }
}

private struct AllChip: View {
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("All")
                .font(.spaceMono(10)).textCase(.uppercase)
                .tracking(1)
                .foregroundColor(active ? BinduTheme.inkPrimary : BinduTheme.inkSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(active ? BinduTheme.inkPrimary.opacity(0.08) : Color.clear)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(
                            active ? BinduTheme.inkPrimary.opacity(0.40) : BinduTheme.hairline,
                            lineWidth: 0.5
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct RoomChip: View {
    let room: Room
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(room.glyph)
                    .font(.system(size: 11))
                    .foregroundColor(room.color)

                Text(room.name)
                    .font(nameFont)
                    .foregroundColor(room.color.opacity(active ? 1.0 : 0.85))
                    .tracking(room.name == "The Watcher" ? 1.0 : 0)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(room.color.opacity(active ? 0.20 : 0.08))
            )
            .overlay(
                Capsule()
                    .strokeBorder(room.color.opacity(active ? 0.55 : 0.20), lineWidth: 0.5)
            )
            .shadow(
                color: room.color.opacity(active ? 0.35 : 0),
                radius: active ? 8 : 0
            )
        }
        .buttonStyle(.plain)
    }

    private var nameFont: Font {
        let size: CGFloat = 10
        switch room.name {
        case "The Descent", "The Return", "The Field":
            return .loraItalic(size)
        case "The Watcher":
            return .spaceMono(size)
        default:
            return .lora(size, weight: .medium)
        }
    }
}

struct FeedSortToggle: View {
    @Binding var sort: StorySort

    var body: some View {
        HStack(spacing: 10) {
            sortLabel("MOST ACTIVE", value: .mostActive)
            Text("·")
                .font(.spaceMono(9)).textCase(.uppercase)
                .foregroundColor(BinduTheme.inkTertiary)
            sortLabel("MOST RECENT", value: .mostRecent)
        }
    }

    @ViewBuilder
    private func sortLabel(_ text: String, value: StorySort) -> some View {
        let active = sort == value
        Button {
            sort = value
        } label: {
            Text(text)
                .font(.spaceMono(9)).textCase(.uppercase)
                .tracking(1.2)
                .foregroundColor(active ? BinduTheme.inkPrimary : BinduTheme.inkTertiary)
        }
        .buttonStyle(.plain)
    }
}
