import SwiftUI

enum FeedRoute: Hashable {
    case rooms
    case room(Room)
    case story(Story)
    case archetype(Archetype)
    case ash
    case settings
    case mirror
    case signal
    case players
    case practiceDoor
    case compose(Story)
}
