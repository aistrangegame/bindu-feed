import SwiftUI

// The Hub is now the TURN (Wave 4, ⚠3 ruling: one navigation surface). This is a
// thin adapter that presents the shared `TurnOverlay` and maps a selection to the
// in-app NavigationPath. The call-site API (`.hubOverlay` + `HubTrigger`) is kept
// so every top-level surface reaches the turn without a sweep. In-app the Rite row
// always shows (a destination, not the Door's daily nag); axis-depths (Universe/
// Light/Point) are absorbed until their registers ship (Waves 5/6).
struct HubOverlay: View {
    @Binding var presented: Bool
    @Binding var path: NavigationPath

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
            case .rite:            path.append(FeedRoute.rite)
            case .archive:         path.removeLast(path.count)   // pop to the home feed (the archive)
            case .route(let r):    path.append(r)
            case .absorbed:        break                          // an axis-depth, not built yet
            }
        }
    }
}

// Attach to any screen that should expose the hub overlay layer. Pairs
// with HubTrigger placed somewhere in the screen's chrome.
extension View {
    func hubOverlay(open: Binding<Bool>, path: Binding<NavigationPath>) -> some View {
        overlay {
            if open.wrappedValue {
                HubOverlay(presented: open, path: path)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: open.wrappedValue)
    }
}
