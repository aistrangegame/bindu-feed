import CoreMotion
import UIKit
import Combine

// WAVE 4 · THE LIGHT'S OWED GESTURES — the scenes that asked for his body, answered.
//
// `Coverage/14-LIGHT-GESTURES.md` ruled all seventy scenes. This builds the ones whose verb is
// the body rather than the hand: the MOTION four (712 company · 717 intention · 730 anahata ·
// 740 surge), MOTION+ 711 unweighted (face down; it goes on in sound, the app still in front),
// the two ruled toward attitude (725 soles · 729 crow), the API three (744 telling · 755 axis;
// 724's two-touch is left to its own pass), and the two ruled readings (734 enough · 771 red).
// Core Motion attitude asks no permission; nothing here is recorded.
//
// For each of these scenes the body IS the gesture: while the stated condition holds the dawn
// assembles and the anchors come on their own; when it lets go, the scene waits — force is
// absorbed, never punished (the register's temperament, §10).
enum LightBody: Equatable {
    case flatFaceUp        // 712 company — laid flat, face up
    case setDownStill      // 717 intention — set down flat and released
    case turnedAround      // 730 anahata — the source is behind; it moves when faced
    case upright           // 740 surge — upright along the body's axis
    case uprightStill      // 725 soles — upright and still (sitting upright reads as standing; accepted)
    case lifted            // 729 crow — a lift, given by the arm (integrated, re-zeroed at rest)
    case faceDown          // 711 unweighted — face down; it goes on in sound alone
    case covered           // 755 axis — only changes while the screen is covered
    case leftAlone         // 734 enough — set down and left (sustained absence; a recorded divergence)
    case uncaptured        // 744 telling — dims when captured; will not be collected
    case unchecked         // 771 red — closes the moment he leaves the app to check
    case featherTouch      // 722 incarnation — rest with no force at all and it opens; press hard, it resists
    case evenTouch         // 743 marriage — too hard stops it; letting go entirely stops it
    case wideReach         // 724 integration — two touches as far apart as the screen allows

    /// Which scene asks for which body, by the scene's own slug.
    static func of(_ key: String) -> LightBody? {
        let words = Set(key.lowercased().split(whereSeparator: { !$0.isLetter }).map(String.init))
        let table: [(String, LightBody)] = [
            ("company", .flatFaceUp), ("intention", .setDownStill), ("anahata", .turnedAround),
            ("surge", .upright), ("soles", .uprightStill), ("crow", .lifted),
            ("unweighted", .faceDown), ("axis", .covered), ("enough", .leftAlone),
            ("telling", .uncaptured), ("red", .unchecked),
            ("incarnation", .featherTouch), ("marriage", .evenTouch), ("integration", .wideReach),
        ]
        return table.first { words.contains($0.0) }?.1
    }

    /// Does this body gate the scene's arrival and its anchors (rather than a one-off event)?
    var gatesProgress: Bool {
        switch self {
        case .uncaptured, .unchecked: return false
        default: return true
        }
    }
}

/// Reads how the phone is being held. Polled by the Light's tick; publishes nothing, so it
/// never re-renders the scene by itself.
final class LightBodySense {
    private let motion = CMMotionManager()
    private var need: LightBody?
    private var startYaw: Double?
    private var stillSince: Date?
    private var velocity = 0.0
    private var rise = 0.0
    private var last: Date?
    private(set) var gravity = (x: 0.0, y: -1.0, z: 0.0)

    func begin(_ body: LightBody?) {
        stop()
        need = body
        guard let body else { return }
        if body == .covered {
            UIDevice.current.isProximityMonitoringEnabled = true
        }
        guard motion.isDeviceMotionAvailable, body != .uncaptured, body != .unchecked else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 30
        motion.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] m, _ in
            guard let self, let m else { return }
            self.read(m)
        }
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
        if UIDevice.current.isProximityMonitoringEnabled { UIDevice.current.isProximityMonitoringEnabled = false }
        startYaw = nil; stillSince = nil; velocity = 0; rise = 0; last = nil
    }

    private func read(_ m: CMDeviceMotion) {
        let now = Date()
        let dt = last.map { now.timeIntervalSince($0) } ?? 0
        last = now
        gravity = (m.gravity.x, m.gravity.y, m.gravity.z)
        let a = m.userAcceleration
        let mag = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
        if mag < 0.035 {
            if stillSince == nil { stillSince = now }
        } else {
            stillSince = nil
        }
        if startYaw == nil { startYaw = m.attitude.yaw }
        // the lift: acceleration along "up" (against gravity), integrated, re-zeroed at rest
        let up = -(a.x * m.gravity.x + a.y * m.gravity.y + a.z * m.gravity.z) * 9.81
        if stillFor >= 0.6 {
            velocity = 0
            if rise < 0.1 { rise = 0 }       // a held height is kept; an un-lift settles to zero
        } else {
            velocity += up * dt
            velocity *= 0.98                 // a little damping: drift belongs to minutes, a lift to seconds
            rise = max(0, rise + velocity * dt)
        }
        currentYaw = m.attitude.yaw
    }

    private var currentYaw = 0.0
    var stillFor: Double { stillSince.map { Date().timeIntervalSince($0) } ?? 0 }

    /// Is the body's condition holding right now? `touching` is the hand on the glass.
    func holds(_ body: LightBody, touching: Bool) -> Bool {
        switch body {
        case .flatFaceUp:   return gravity.z < -0.88
        case .setDownStill: return gravity.z < -0.88 && stillFor > 1.2 && !touching
        case .turnedAround:
            guard let s = startYaw else { return false }
            var d = abs(currentYaw - s)
            if d > .pi { d = 2 * .pi - d }
            return d > 2.2
        case .upright:      return gravity.y < -0.85
        case .uprightStill: return gravity.y < -0.85 && stillFor > 1.0
        case .lifted:       return rise > 0.12
        case .faceDown:     return gravity.z > 0.85
        case .covered:      return UIDevice.current.proximityState
        case .leftAlone:    return stillFor > 12 && !touching
        case .uncaptured, .unchecked: return true
        // PRESSURE, READ AS IT CAN BE (Coverage/14 PRESSURE · a recorded substitution): force
        // where the screen measures it, otherwise the contact's size — a finger resting with no
        // weight touches less glass than one pressing. Both are read from TouchSense.
        case .featherTouch:
            guard TouchSense.touching else { return false }
            return TouchSense.force >= 0 ? TouchSense.force < 0.18 : TouchSense.radius < 22
        case .evenTouch:
            guard TouchSense.touching else { return false }
            return TouchSense.force >= 0 ? (TouchSense.force > 0.08 && TouchSense.force < 0.55)
                                         : (TouchSense.radius >= 14 && TouchSense.radius < 34)
        case .wideReach:
            let diag = hypot(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            return TouchSense.spread > diag * 0.6
        }
    }
}
