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
        // F2.1 · **ROOM COLOUR *IS* THE SELECTION — IT IS NOT A TINT LAID OVER IT.**
        // `Home Feed.html:128-133`: an inactive chip has **no room colour at any element** —
        // grey glyph, grey name, no fill, transparent border, no glow. The app gave every
        // chip its room's colour always and turned the brightness up ~2.5× on the active one,
        // so **the inactive state was inverted**: thirteen coloured pills, one slightly
        // brighter. That is a legend of the rooms with a highlight on it, where the design is
        // a row of names with exactly one room present in it.
        //
        // The difference is not a delta anyone can see in a still of the ACTIVE chip — it is
        // visible only in what the other twelve are doing, which is why a screenshot review
        // passes it.
        //
        // The border stays PRESENT and transparent when inactive rather than being removed,
        // so the pill does not change width on selection.
        Button(action: action) {
            HStack(spacing: 6) {
                Text(room.glyph)
                    .font(.system(size: 11))
                    .foregroundColor(active ? room.color : BinduTheme.inkTertiary)

                roomName(13)
                    .tracking(0.13)                                  // 0.01em × 13
                    .foregroundColor(active ? room.color : BinduTheme.inkTertiary.opacity(0.55))
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(active ? room.color.opacity(0.086) : Color.clear)   // `16`₁₆
            )
            .overlay(
                Capsule()
                    .strokeBorder(active ? room.color.opacity(0.22) : Color.clear, lineWidth: 1)
            )
            .shadow(
                color: active ? room.color.opacity(0.094) : .clear,           // `18`₁₆
                radius: active ? 7 : 0
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.35), value: active)
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
