import SwiftUI

// THE JOURNEY LOG — the walk kept in the body of the space, given back at the centre.
// Not a count, not a score: the raw material the reveal narrates ("You entered… You
// opened… You descended onto… N visitors arrived that you did not choose…"). Session-
// scoped; reset when a walk completes. Pulse only — nothing here is persisted or ranked.
@MainActor
enum PointJourney {
    /// **SHARED STATIC · any test suite touching this is `.serialized`** (§10 TENTH SHAPE).
    /// The rule is *at creation, not at flake* — `PointReturn` and `PointDance` cost a pass to
    /// learn it. Nothing tests this yet; the first suite that does inherits the trap.
    static var reachedGate = false
    static var enteredDims: [String] = []
    static var universes: [String] = []       // the named universes he entered (middle tier)
    static var openedStars: [String] = []
    static var descended: [String] = []
    static var visitors = 0

    /// THE CARRY — `The Instrument v3.html:4899` `const CARRY=[]`, and `:5334` `sealCarry()`.
    ///
    /// *"Taking it up is weightless — no list, no collection, nothing counted. What it
    /// leaves behind is company: one more mote in orbit around the one particle, at every
    /// scale, for the rest of the walk."* (`:5331-5333`)
    ///
    /// It is NEVER rendered as a count and never as a list. The only place it becomes
    /// visible is the motes, and the only place it becomes words is the one line at the
    /// centre. `walk-continuity.js:44` says the same thing from the ceremony's side:
    /// *"read-only, and never rendered as a count."*
    ///
    /// It lives here rather than in a serialised walk object on purpose — see the note on
    /// `carriedTitles` below.
    static var carried: [(title: String, hue: Color)] = []

    /// The titles, oldest first, for the one line the reveal is allowed to say.
    static var carriedTitles: [String] { carried.map(\.title) }

    static func reset() {
        reachedGate = false
        enteredDims = []
        openedStars = []
        descended = []
        visitors = 0
        carried = []
    }

    // Distinct, order-preserving; "a · b · c · and N more" past `max`.
    static func nameList(_ arr: [String], _ max: Int) -> String {
        var seen = Set<String>(); var uniq: [String] = []
        for s in arr where !s.isEmpty && !seen.contains(s) { seen.insert(s); uniq.append(s) }
        if uniq.count <= max { return uniq.joined(separator: " · ") }
        return uniq.prefix(max).joined(separator: " · ") + " · and \(uniq.count - max) more"
    }

    // The walk narrated back — the reveal's spine.
    static func narration() -> [String] {
        var out: [String] = []
        out.append(reachedGate ? "You pressed me at the gate."
                               : "You slipped past the gate — I came along anyway.")
        if !enteredDims.isEmpty { out.append("You entered " + nameList(enteredDims, 3) + ".") }
        if !openedStars.isEmpty { out.append("You opened " + nameList(openedStars, 3) + ".") }
        if !descended.isEmpty { out.append("You descended onto " + nameList(descended, 2) + " — and came back up.") }
        if visitors > 0 {
            out.append(visitors == 1 ? "One visitor arrived that you did not choose."
                                     : "\(visitors) visitors arrived that you did not choose.")
        }
        // `The Instrument v3.html:5776`, verbatim. The one place the carry becomes words,
        // and it refuses to be a count in the same breath.
        if !carried.isEmpty {
            out.append("You carried " + nameList(carriedTitles, 2)
                       + " up with you. What you carry is not a list. It is a change in what you notice.")
        }
        if enteredDims.isEmpty && openedStars.isEmpty {
            out.append("You walked straight through, gate to centre. Some days that is the whole practice.")
        }
        return out
    }
}
