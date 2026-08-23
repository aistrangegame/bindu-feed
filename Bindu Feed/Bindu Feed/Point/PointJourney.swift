import Foundation

// THE JOURNEY LOG — the walk kept in the body of the space, given back at the centre.
// Not a count, not a score: the raw material the reveal narrates ("You entered… You
// opened… You descended onto… N visitors arrived that you did not choose…"). Session-
// scoped; reset when a walk completes. Pulse only — nothing here is persisted or ranked.
@MainActor
enum PointJourney {
    static var reachedGate = false
    static var enteredDims: [String] = []
    static var universes: [String] = []       // the named universes he entered (middle tier)
    static var openedStars: [String] = []
    static var descended: [String] = []
    static var visitors = 0

    static func reset() {
        reachedGate = false
        enteredDims = []
        openedStars = []
        descended = []
        visitors = 0
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
        if enteredDims.isEmpty && openedStars.isEmpty {
            out.append("You walked straight through, gate to centre. Some days that is the whole practice.")
        }
        return out
    }
}
