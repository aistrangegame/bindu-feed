import SwiftUI

struct RoomSelectionView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: NavigationPath

    @State private var portalFrames: [String: CGRect] = [:]
    @State private var floodRoom: Room?
    @State private var floodAnchor: CGPoint = .zero
    @State private var floodPhase: FloodOverlay.Phase = .idle

    private let columns = [
        GridItem(.flexible(), spacing: BinduTheme.space12),
        GridItem(.flexible(), spacing: BinduTheme.space12)
    ]

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: BinduTheme.space20) {
                    header
                        .padding(.horizontal, BinduTheme.space16)

                    portalGrid
                        .padding(.horizontal, BinduTheme.space16)

                    if let thirteenth = store.rooms.first(where: { $0.sortOrder == 13 }) {
                        RoomPortalCard(room: thirteenth, fullWidth: true) { _ in
                            triggerFlood(for: thirteenth)
                        }
                        .padding(.horizontal, BinduTheme.space16)
                    }

                    Color.clear.frame(height: BinduTheme.space24)
                }
                .padding(.top, BinduTheme.space24)
            }
            .onPreferenceChange(PortalFramePreferenceKey.self) { frames in
                portalFrames = frames
            }

            if let room = floodRoom {
                FloodOverlay(color: room.color, anchor: floodAnchor, phase: $floodPhase)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackChevron { path.removeLast(max(path.count - 0, 0)) }
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("◉")
                    .font(.system(size: 14))
                    .foregroundColor(BinduTheme.colorAsh)
                Text("THIRTEEN ROOMS")
                    .font(.spaceMono(11))
                    .tracking(2.4)
                    .foregroundColor(BinduTheme.inkSecondary)
            }
            Text("Each one already alive when you arrive.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
        }
    }

    private var portalGrid: some View {
        let firstTwelve = store.rooms
            .filter { $0.sortOrder <= 12 }
            .sorted { $0.sortOrder < $1.sortOrder }
        return LazyVGrid(columns: columns, spacing: BinduTheme.space12) {
            ForEach(firstTwelve) { room in
                RoomPortalCard(room: room) { _ in
                    triggerFlood(for: room)
                }
            }
        }
    }

    // MARK: - Flood + navigate

    private func triggerFlood(for room: Room) {
        let frame = portalFrames[room.id] ?? .zero
        floodAnchor = CGPoint(x: frame.midX, y: frame.midY)
        floodRoom = room
        floodPhase = .idle

        // Tick to ensure overlay is laid out at scale 0 before the expand animation runs.
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.6)) {
                floodPhase = .expanding
            }
        }

        // After flood fills the screen, push GameView with the same color.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
            path.append(FeedRoute.room(room))
            // Reset behind the now-covered RoomSelectionView for next time.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                floodPhase = .idle
                floodRoom = nil
            }
        }
    }
}

struct BackChevron: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle().strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}
