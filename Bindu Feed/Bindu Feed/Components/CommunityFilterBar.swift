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
                .spaceMonoTracked(10)
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

                roomName(10)
                    .foregroundColor(room.color.opacity(active ? 1.0 : 0.85))
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

    // E1.18 · **THE FACE AND ITS CASE ARE ONE DECISION, SO THE SWITCH RETURNS A VIEW, NOT A
    // `Font`.** This was a `Font`-valued switch with the mono branch's tracking spelled out
    // at the call site (`room.name == "The Watcher" ? 1.0 : 0`) — the face handed over bare
    // and its two companions left to whoever drew it. Nothing enforced that pairing, which
    // is the shape the whole row is about.
    @ViewBuilder private func roomName(_ size: CGFloat) -> some View {
        switch room.name {
        case "The Descent", "The Return", "The Field":
            Text(room.name).font(.loraItalic(size))
        case "The Watcher":
            Text(room.name).spaceMonoTracked(size, em: 1 / size)
        default:
            Text(room.name).font(.lora(size, weight: .medium))
        }
    }
}

struct FeedSortToggle: View {
    @Binding var sort: StorySort

    var body: some View {
        HStack(spacing: 10) {
            sortLabel("MOST ACTIVE", value: .mostActive)
            Text("·")
                .spaceMonoTracked(9)
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
                .spaceMonoTracked(9)
                .tracking(1.2)
                .foregroundColor(active ? BinduTheme.inkPrimary : BinduTheme.inkTertiary)
        }
        .buttonStyle(.plain)
    }
}
