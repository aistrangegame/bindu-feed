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
    /// D2.6 · **THE ROPE. `The Point v9.html:873` — `Journey = {…, rope:false}`.** It was the
    /// one field the walk had no record of: the rope is fully built and reachable, and the
    /// reveal could not say it had happened.
    static var rope = false
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
        universes = []
        rope = false
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
        // D2.6 · `point-levels.js:289`, and the design places it SECOND — between the gate
        // and what he entered. `openRope()` sets it (`:261`), so a rope reached for and
        // dismissed still counts: reaching is the act, not staying.
        if rope { out.append("You reached for the rope. I was the dot you breathed with.") }
        // D2.6 · **TRANSIT AND CHOICE ARE TWO DIFFERENT CLAIMS AND THE APP MADE ONE OF THEM
        // TWICE.** `point-levels.js:290` narrates `Journey.universes` — pushed at `:149`
        // inside `openUniverse`, a deliberate tap on a NAMED UNIVERSE. The app narrated
        // `enteredDims`, appended in `PointWorldView.onAppear` — and that view is mounted by
        // `Axis.nearest(z)`, so **merely passing a register appended its name**. A walk with
        // no taps at all reported *"You entered The Point · The Turn · The Veil · and 4
        // more."* The array the design narrates was written at the right site and read by
        // nothing.
        if !universes.isEmpty { out.append("You entered " + nameList(universes, 3) + ".") }
        // The transit log gets its own true sentence rather than being deleted or left to
        // impersonate choice — `The Instrument v3.html:5769`, the higher-precedence source,
        // which narrates passage as passage and caps at FOUR where choice caps at three.
        if !enteredDims.isEmpty { out.append("You passed through " + nameList(enteredDims, 4) + ".") }
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
        // D2.6 · `point-levels.js:294` guards this on `universes` — **the same array `:290`
        // narrates.** Guarded on `enteredDims` it was unreachable by construction: transit
        // filled the array, and transit is exactly what this line exists to describe. The
        // authored straight-through sentence could never appear on a straight-through walk.
        //
        // D2.9 · and it is `center`. The app had naturalised one letter into the file's own
        // British spelling — the string is canon (`PointContent.swift:385` already carries the
        // American form byte-exact), so this was the one site of two that disagreed with
        // itself. A registry row called it a DIVERGENCE; it was a typo with a verdict on it.
        if universes.isEmpty && openedStars.isEmpty {
            out.append("You walked straight through, gate to center. Some days that is the whole practice.")
        }
        return out
    }
}
