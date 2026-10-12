import SwiftUI

// The Hub is now the TURN (Wave 4, ⚠3 ruling: one navigation surface). This is a
// thin adapter that presents the shared `TurnOverlay` and maps a selection to the
// in-app route stack. The call-site API (`.hubOverlay` + `HubTrigger`) is kept
// so every top-level surface reaches the turn without a sweep. In-app the Rite row
// always shows (a destination, not the Door's daily nag); axis-depths (Universe/
// Light/Point) are absorbed until their registers ship (Waves 5/6).
struct HubOverlay: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var presented: Bool
    @Binding var path: [FeedRoute]

    var body: some View {
        TurnOverlay(unmet: true, onStay: dismiss, onSelect: handle)
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) { presented = false }
    }

    private func handle(_ dest: TurnDestination) {
        withAnimation(.easeInOut(duration: 0.3)) { presented = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            switch dest {
            case .rite:            $path.pushDissolve(FeedRoute.rite)
            case .archive:         $path.popToRootDissolve()   // pop to the home feed (the archive)
            case .route(.instrument(let z)):
                // SLICE 10 · THE TURN BECOMES THE AXIS, SEEN AS A LIST (padakarshini elements
                // §6.3). When he is already in the instrument, a depth row does not stack a
                // second axis on top of the first: whatever lies above the axis comes off and
                // the camera glides, continuously, to the depth the row named — the list
                // dissolving into the space it named. Ceremony rows still cross as before.
                if let i = path.lastIndex(where: { if case .instrument = $0 { return true } else { return false } }) {
                    withAnimation(.easeInOut(duration: 0.5)) { path.removeSubrange((i + 1)...) }
                    store.axisGlide = z
                } else {
                    $path.pushDissolve(.instrument(z))
                }
            case .route(let r):    $path.pushDissolve(r)
            case .absorbed:        break                          // an axis-depth, not built yet
            }
        }
    }
}

// Attach to any screen that should expose the hub overlay layer. Pairs
// with HubTrigger placed somewhere in the screen's chrome.
extension View {
    func hubOverlay(open: Binding<Bool>, path: Binding<[FeedRoute]>) -> some View {
        overlay {
            if open.wrappedValue {
                HubOverlay(presented: open, path: path)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: open.wrappedValue)
    }

    // The floating top-left back + hub chrome, reserving its own top-safe-area space.
    // This is the custom router's replacement for the NavigationStack toolbar that used
    // to host BackChevron + HubTrigger — with no nav bar, those `.toolbar {}` blocks
    // render nothing, so screens carry the chrome in-view instead (the pattern GameView
    // already used). `safeAreaInset` reserves the strip so content sits below it, exactly
    // as the nav bar did.
    func floatingBackHub(path: Binding<[FeedRoute]>, showHub: Binding<Bool>) -> some View {
        safeAreaInset(edge: .top, spacing: 0) {
            HStack(spacing: 4) {
                BackChevron { path.popDissolve() }
                HubTrigger(open: showHub)
                Spacer()
            }
            .padding(.horizontal, BinduTheme.space16)
            .padding(.vertical, 6)
            // SLICE 4 · the Lalita Pass — walked: a story's paragraphs scrolled up under the
            // clock and behind ‹ and the hub, type over type. The chrome now stands on the
            // page's own ground, which fades out below it, so the words go quiet before they
            // reach it (the Rite's Reading does the same with its top mask).
            .background(alignment: .top) {
                LinearGradient(stops: [.init(color: BinduTheme.bgDeep, location: 0),
                                       .init(color: BinduTheme.bgDeep, location: 0.55),
                                       .init(color: BinduTheme.bgDeep.opacity(0), location: 1)],
                               startPoint: .top, endPoint: .bottom)
                    .padding(.bottom, -22)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
            }
        }
    }
}
