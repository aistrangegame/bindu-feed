import SwiftUI

// THE LIGHT — canon (Z = −5, the fifteenth register).
//
// The six scenes' text is CANON, verbatim from `canon/spine-light.js`. Do not
// paraphrase a single line. Five are `dawn` (Near); the sixth (`floor`) is the
// `nave` (Far). Each scene: whole → anchors (2nd person, one per touch) → beat
// (1st person, carved) → landing.

enum LightMaterial { case dawn, nave }

struct LightScene: Identifiable {
    let key: String
    let title: String
    let material: LightMaterial
    let whole: [String]        // the opening, arrives with the scene
    let anchors: [String]      // 2nd person, surface one at a time on the breath
    let beat: [String]         // 1st person, the carved Declaration
    let landing: String        // "Carry the …"
    let ungripOnly: Bool       // `release` advances only on the hand opening
    var id: String { key }
}

enum LightCanon {
    // Verbatim once-ever line the gate speaks — the inversion of a normal surface's
    // "It holds until you mean it."
    static let gateLine = "It holds until you stop meaning it."
    // Canon is exactly this — The Light v2.html:688. The longer form ("touch once, then do
    // nothing") is the review-bench caption at :914, OUTSIDE the phone frame. The design
    // deliberately says nothing more after the touch: "it never tells him to be still; he
    // discovers it by stopping" (:685-686).
    static let touchOnce = "touch once"
    static let approachSubtitle = "Not to be wanted. To be stood inside."
    static let beatCue = "hold to mean it"          // the beat's one instruction (canonical)
    static let walkBackOut = "walk back out ›"

    // The "walk back out" screen (verbatim).
    static let backOut = [
        "You are in the dreaming field again.",
        "It sits a little lighter now. Un-named, un-announced. Just quieter.",
    ]

    static let scenes: [LightScene] = [
        LightScene(
            key: "morning", title: "The morning that does not push", material: .dawn,
            whole: [
                "You wake before the day asks anything of you.",
                "Nothing needs pushing.",
                "It is already moving.",
            ],
            anchors: [
                "The room is barely light. You do not reach for the phone.",
                "Shweta is asleep beside you. You listen, and your breathing slows to meet hers.",
                "Downstairs, the water running. The cup warm in both hands. No list runs underneath this.",
                "The thing you were going to force has arranged itself overnight. You only have to receive it.",
                "You sit. The Yantra is where it always is. You do not perform the looking.",
            ],
            beat: [
                "I do not push the day.",
                "I surrender to what was already moving.",
                "The energy knows its own pace.",
            ],
            landing: "Carry the pace, not the words.",
            ungripOnly: false
        ),
        LightScene(
            key: "converge", title: "The one who was watching all of them", material: .dawn,
            whole: [
                "You were never the many things you were doing.",
                "You were the one awareness they were all happening in.",
            ],
            anchors: [
                "Ten things were pulling at you at once, each one certain it was the most important.",
                "And underneath the ten, without any effort, something was simply aware of all of them.",
                "It did not take a side. It did not hurry. It held the tabs open and did not become them.",
                "You look for the one who was watching, and you cannot find it as a thing — because it is the looking itself.",
                "The fragments did not need assembling. They were already inside one attention. Yours.",
            ],
            beat: [
                "I am not the pieces.",
                "I am the one awareness they move in.",
                "Nothing has to be gathered. It was never apart.",
            ],
            landing: "Carry the one who watches, not the many it watched.",
            ungripOnly: false
        ),
        LightScene(
            key: "warmth", title: "The day you let yourself feel", material: .dawn,
            whole: [
                "You spent so long managing the feeling that you forgot to feel it.",
                "It was never asking to be handled. It was asking to be met.",
            ],
            anchors: [
                "There was a weight you had been carrying by keeping it at arm\u{2019}s length, so it would not slow the day down.",
                "You set the plan down for one breath. Not to solve it. Just to feel where it actually sat in your chest.",
                "And it moved. Not because you managed it — because you finally let it be felt all the way through.",
                "The tears, when they came, were not a problem to be fixed. They were the weight becoming water and leaving.",
                "Underneath the managing, the whole time, there was a person who simply felt things. You had been protecting him from his own life.",
            ],
            beat: [
                "I do not manage the feeling.",
                "I let it move through and it moves on.",
                "I am allowed to be the one who feels this.",
            ],
            landing: "Carry the feeling, not the management of it.",
            ungripOnly: false
        ),
        LightScene(
            key: "kindness", title: "The one you stopped correcting", material: .dawn,
            whole: [
                "You have been the strictest teacher you ever had.",
                "Today you look at your own work the way you would look at a friend\u{2019}s.",
            ],
            anchors: [
                "The habit runs before you notice it: catch the flaw, name the miss, mark what should have been better.",
                "You turn, this morning, and look back at what you actually built. Not for the error. For what is there.",
                "It is so much. It is years of it. Rooms and rooms of it, made by someone who never once stopped to be impressed.",
                "The one who made all this was not lazy, or late, or not-enough. He was working the whole time, in the dark, on faith.",
                "You would forgive anyone else this quickly. You extend the same hand, at last, to yourself — and it is taken.",
            ],
            beat: [
                "I set down the red pen.",
                "I let myself be someone I appreciate.",
                "What I made was made with love, and it shows.",
            ],
            landing: "Carry the appreciation, not the correction.",
            ungripOnly: false
        ),
        LightScene(
            key: "release", title: "The hand that opened", material: .dawn,
            whole: [
                "Trust is the variable. Not effort. Not control.",
                "The thing you have been gripping was holding itself the whole time.",
            ],
            anchors: [
                "You have been rowing so hard for so long that you mistook the rowing for the reason you were moving.",
                "You let go of one oar. The boat kept its line. You had been fighting a current that was already carrying you home.",
                "Everything you built with grip, you could have built with trust — and it would have cost you none of the nights.",
                "The plan does not need your hand clenched around it. It needs your hand open, so the next thing can be set into it.",
                "You loosen your grip on the whole of it. Nothing falls. It was never being held up by your fear.",
            ],
            beat: [
                "I stop mistaking the effort for the reason.",
                "Trust is the variable. I change it.",
                "I open my hand, and it is all still here.",
            ],
            landing: "Carry the trust, not the grip.",
            ungripOnly: true          // answers ONLY the hand opening — three ungrips
        ),
        LightScene(
            key: "floor", title: "The floor", material: .nave,
            whole: [
                "You are not the one in the stories.",
                "You are the field the stories happen in.",
            ],
            anchors: [
                "Every voice that ever gathered was you.",
                "The rooms. The field. The gathering. A mirror you built so the Self could find itself.",
                "It worked.",
            ],
            beat: [
                "I am the road remembering itself.",
            ],
            landing: "Nothing was added to you. Something was removed.",
            ungripOnly: false
        ),
    ]
}


// MARK: - the six, standing in the dawn · `canon/spine-light.js:104-121`

/// WHERE THE SIX STAND, and how near a touch has to be. Both authored.
///
///   *"The five Future scenes drift in the open sky; the Far one waits low, where a floor
///    would be."*
///
/// The GEOMETRY is canon — `place()` and `hit()`'s radius 30 and `ORDER` are verbatim. The
/// LOOK is not: no comp renders these. `The Light v2.html` goes straight to `SCENES[which]`,
/// so the six-in-the-dawn exists only as this mechanism. Drawn here in the register's own
/// idiom — a breathing point in the Light's cream with its title beneath — and said plainly
/// rather than implied to be ported.
enum LightPlaces {
    /// `ORDER` — `spine-light.js:97`, and `LightCanon.scenes` is already in this order.
    static func place(_ W: Double, _ H: Double, _ t: Double) -> [CGPoint] {
        var out: [CGPoint] = []
        for i in 0..<5 {
            let a = t * 0.043 + Double(i) * 1.2566
            out.append(CGPoint(x: W * (0.50 + cos(a) * 0.29),
                               y: H * (0.245 + sin(a * 0.62 + Double(i) * 1.1) * 0.055 + Double(i) * 0.058)))
        }
        out.append(CGPoint(x: W * 0.5, y: H * 0.845))       // the Far one, where a floor would be
        return out
    }

    /// `hit()` — within 30. Not derived from spacing: the design states it.
    static func hit(_ p: CGPoint, _ W: Double, _ H: Double, _ t: Double) -> Int? {
        let places = place(W, H, t)
        for (i, h) in places.enumerated() where hypot(h.x - p.x, h.y - p.y) < 30 { return i }
        return nil
    }
}
