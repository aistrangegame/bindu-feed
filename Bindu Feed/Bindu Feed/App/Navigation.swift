import SwiftUI

enum FeedRoute: Hashable {
    case rooms
    case room(Room)
    case story(Story)
    case turning(Archetype)      // was .archetype — the view is TheTurningView
    case ash
    case settings
    case mirror
    case signal
    case players
    case practiceDoor
    case compose(Story)
    case rite            // the daily meeting (Wave 2)
    case light           // the fifteenth register, reached by stillness (Wave 5)
    case returnCeremony  // re-meeting a sealed story (Wave 5)
}
