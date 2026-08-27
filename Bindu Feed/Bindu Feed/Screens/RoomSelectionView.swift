import SwiftUI

struct RoomSelectionView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: [FeedRoute]

    @State private var portalFrames: [String: CGRect] = [:]
    @State private var floodColor: Color?
    @State private var floodAnchor: CGPoint = .zero
    @State private var floodGlyph: String?
    @State private var floodPhase: FloodOverlay.Phase = .idle
    @State private var showHub = false

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

                    twoMoreDoorsSection

                    Color.clear.frame(height: BinduTheme.space24)
                }
                .padding(.top, BinduTheme.space24)
            }
            .onPreferenceChange(PortalFramePreferenceKey.self) { frames in
                portalFrames = frames
            }

            if let floodColor {
                FloodOverlay(color: floodColor, anchor: floodAnchor, glyph: floodGlyph, phase: $floodPhase)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .floatingBackHub(path: $path, showHub: $showHub)
        .sonicContext(.base)
        .hubOverlay(open: $showHub, path: $path)
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
                    .tracking(1.54)
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

    // MARK: - Two more doors section

    private var twoMoreDoorsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)
                .padding(.vertical, BinduTheme.space24)

            Text("AND THE FIELD TURNS TO YOU")
                .font(.spaceMono(9))
                .tracking(1.62)     // 0.18em x 9 — Room Selection.html:745-749
                .foregroundColor(BinduTheme.inkSecondary)
                .padding(.horizontal, BinduTheme.space16)

            VStack(spacing: BinduTheme.space12) {
                FieldSurfacePortalCard(config: .mirror) { _ in
                    triggerFlood(forSurface: .mirror, route: .mirror)
                }
                FieldSurfacePortalCard(config: .signal) { _ in
                    triggerFlood(forSurface: .signal, route: .signal)
                }
            }
            .padding(.horizontal, BinduTheme.space16)
            .padding(.top, BinduTheme.space16)
        }
    }

    // MARK: - Flood + navigate

    private func triggerFlood(for room: Room) {
        performFlood(anchorId: room.id, color: room.color, glyph: room.glyph, route: .room(room))
    }

    private func triggerFlood(forSurface config: FieldSurfaceConfig, route: FeedRoute) {
        performFlood(anchorId: config.id, color: config.color, glyph: config.glyph, route: route)
    }

    private func performFlood(anchorId: String, color: Color, glyph: String?, route: FeedRoute) {
        let frame = portalFrames[anchorId] ?? .zero
        floodAnchor = CGPoint(x: frame.midX, y: frame.midY)
        floodColor = color
        floodGlyph = glyph
        floodPhase = .idle

        // Tick to ensure overlay is laid out at scale 0 before the expand animation runs.
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.6)) {
                floodPhase = .expanding
            }
        }

        // After flood fills the screen, mount the destination instantly
        // behind it (no NavigationStack slide). The destination's own color
        // overlay starts at opacity 1.0 and dissolves out, so the user sees
        // the color lift like a curtain — not a page turn.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) {
                $path.pushDissolve(route)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                floodPhase = .idle
                floodColor = nil
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
