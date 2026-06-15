import SwiftUI

@main
struct BinduFeedApp: App {
    @StateObject private var store = FeedStore()
    @StateObject private var soundEngine = SoundEngine()

    var body: some Scene {
        WindowGroup {
            ContentCoordinator()
                .environmentObject(store)
                .environmentObject(soundEngine)
                .preferredColorScheme(.dark)
        }
    }
}
