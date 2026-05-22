import SwiftUI

@main
struct BinduFeedApp: App {
    @StateObject private var store = FeedStore()

    var body: some Scene {
        WindowGroup {
            ContentCoordinator()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
