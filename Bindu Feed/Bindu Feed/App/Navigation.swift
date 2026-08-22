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
}
