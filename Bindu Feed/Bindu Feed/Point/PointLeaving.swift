import Foundation

// STAGE D · THE LEAVING DECAY — `8-ACTION-PLAN.md` D
//
// *"A scalar raised to 1 on release, decaying per frame, keeping `given` alive and giving the
// world its one closing word. One mechanic pattern."*
//
// A world does not stop when the hand comes off it. It closes — over its own time, at its own
// rate, and it says one thing while it does. Every closing line in the Point is a sentence
// about what the world keeps after he has let go, and none of them shipped.
//
// THE COUNT, MEASURED AGAINST THE DESIGN RATHER THAN THE PLAN. `8-ACTION-PLAN.md` D says
// *"seven instances, eight cues."* Reading the seven world files, it is **five and four**:
//
//   I   `leaving`   0.9   `world-one.js:66,89,193`      IT CLOSED. IT DOES NOT MIND.
//   II  `reeling`   0.7   `world-two.js:71,116,123`     — no closing branch in its cue
//   III `closing`   0.8   `world-three.js:68,121,130`   IT CLOSED BEHIND YOU. IT ALWAYS DOES.
//   IV  `easing`    0.8   `world-four.js:135,275-277`   THE WALL EASED. WHAT WAS STRUCK STAYS STRUCK.
//   V   `settling`  0.55  `world-five.js:182,189,443`   THE GLASS LET GO. WHAT FACED YOU, FACED YOU.
//   VI  —                 `home` (`:152,174`, rate 1.5) is every return passing through the
//                         particle, not a leaving decay. Plan **E2**.
//   VII —                 `resolved` (`:122`) is the d-map's permanent close, not a decay,
//                         and it carries TWO lines rather than one:
//                         THE MAP BECAME ARCHITECTURE / THE DOOR OUT IS THE DOOR IN · PULL UP
//
// Recorded rather than forced to seven: the checklist is not canon (§10), and building two
// instances that do not exist upstream would be inventing the mechanic to match a tally.

/// One world's leaving decay. `Math.max(0, x − dt·rate)`, integrated.
///
/// **ON A WALL CLOCK, NOT A FRAME ACCUMULATOR** — `ReadTurning` already had this shape and it
/// is the right one: `world-five.js:104`, *"the withdrawal finishes whether he is here or
/// not."* A per-frame subtraction pauses when the view does, so a world left mid-close would
/// still be closing when he came back to it, which is the opposite of what a close is. From
/// an instant and a rate, the value is exact at any moment and needs no loop to keep it true.
struct LeavingDecay: Equatable {
    /// The world's own rate, per second, from its own file.
    let rate: Double
    /// When the hand came off. `nil` while he is still holding — a world being held is not
    /// closing, and this is the difference between the two states.
    private(set) var releasedAt: Date?

    init(rate: Double) { self.rate = rate }

    /// `release: function(){ if(this.following) this.reeling = 1; }` — raised to 1, once.
    /// Only if something was actually held: releasing nothing closes nothing.
    mutating func release(held: Bool = true) { if held { releasedAt = Date() } }

    /// He took hold again. The close is over because it never finished.
    mutating func hold() { releasedAt = nil }

    /// The scalar, at a moment. 1 at release, 0 after `duration`.
    func value(at now: Date = Date()) -> Double {
        guard let releasedAt else { return 0 }
        return max(0, 1 - now.timeIntervalSince(releasedAt) * rate)
    }

    /// The design's own threshold for showing the closing word — `else if(this.x > 0.02)`.
    func isClosing(at now: Date = Date()) -> Bool { value(at: now) > 0.02 }

    /// How long the whole close lasts. `1/rate` — I closes in 1.1s, V takes 1.8s.
    var duration: Double { 1 / rate }
}

/// The five rates and the four closing lines, as canon.
enum PointLeaving {
    /// Each world's own decay rate, or `nil` where the design declares none.
    static func rate(dimension n: Int) -> Double? {
        switch n {
        case 1: return 0.9        // `world-one.js:89`    — leaving
        case 2: return 0.7        // `world-two.js:123`   — reeling
        case 3: return 0.8        // `world-three.js:130` — closing
        case 4: return 0.8        // `world-four.js:135`  — easing
        case 5: return 0.55       // `world-five.js:189`  — settling
        default: return nil       // VI and VII have no leaving decay; see the header
        }
    }

    /// The one thing a world says while it closes. Verbatim, uppercase as the design draws
    /// it (`x.fillText(...)` at `H−150`, in Space Mono at 8.5px).
    static func line(dimension n: Int) -> String? {
        switch n {
        case 1: return "IT CLOSED. IT DOES NOT MIND."
        case 3: return "IT CLOSED BEHIND YOU. IT ALWAYS DOES."
        case 4: return "THE WALL EASED. WHAT WAS STRUCK STAYS STRUCK."
        case 5: return "THE GLASS LET GO. WHAT FACED YOU, FACED YOU."
        // II decays and says nothing — `world-two.js:226-232` has no closing branch. Its
        // held words already end at *"far out, and still leaving"*, which is a world that
        // never closes in the first place.
        default: return nil
        }
    }

    /// A world's decay, ready to use, or `nil` where the design declares none.
    static func decay(dimension n: Int) -> LeavingDecay? {
        rate(dimension: n).map(LeavingDecay.init(rate:))
    }
}
