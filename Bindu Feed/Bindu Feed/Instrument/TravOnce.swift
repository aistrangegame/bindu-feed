import Foundation

/// C3.3 + C3.4 · **THE ONE THING THE SURFACE IS EVER ALLOWED TO SAY, ONCE, EVER.**
///
/// `The Instrument v3.html:5415-5431`. One element, `#trav .once`, carries two authored lines
/// and each fires a single time in the life of the instrument:
///
///   · `sayOnce()` at `:5475` — `!memOnce && TR.crossed === 0 && TR.tension > 0.55`, the first
///     time he leans hard on a membrane **before he has crossed anything**. Called with no
///     argument, so the element keeps its resting text: *"It holds until you mean it."*
///   · `sayGate()` at `:5484` — `gateAcc > 700`, once, ever: *"It holds until you stop meaning
///     it."* Held 8500ms, then after a further 2600ms the text **reverts to the resting line**.
///
/// **THE PAIR IS THE POINT AND EITHER ALONE IS A DIFFERENT SENTENCE.** *Mean it* is what the
/// axis asks of someone who has not yet crossed; *stop meaning it* is what the gate asks of
/// someone who has arrived and must now be still. The second is the inversion of the first, and
/// it reverts to the first — so the surface ends where it began, having said both halves once.
/// `AUDIT C3.3` (the gate's line, every time, wrong medium) and `C3.4` (the resting line absent
/// entirely) are the two halves of that one sentence.
///
/// **SHARED STATIC · any suite touching it is `.serialized`** (§10 tenth shape, at creation).
///
/// Both latches are plain per-launch vars in the design (`:4900 memOnce`, `:5423 gateSaid`) —
/// *"the life of the instrument"* is a session, not a stored preference. Deliberately NOT
/// persisted: a line that never returns after the first launch cannot be re-read by someone
/// who did not understand it the first time, and neither line is a reward to be spent.
@MainActor
enum TravOnce {
    /// `:4645` — the element's resting text, and what `sayOnce()` shows.
    static let resting = "It holds until you mean it."
    /// `:5427` — the gate's inversion.
    static let atTheGate = "It holds until you stop meaning it."

    /// `:5419` / `:5430` — held 8500ms.
    static let holdSeconds: Double = 8.5
    /// `:5430` — and 2600ms after that, the gate's line reverts to the resting one.
    static let revertSeconds: Double = 2.6

    private(set) static var saidOnce = false
    private(set) static var saidGate = false
    /// What the element reads right now. `nil` while nothing is being said.
    private(set) static var showing: String?
    /// The text the element holds when silent — the resting line, until the gate has spoken
    /// and reverted, which is also the resting line. It is the same line either way; the
    /// revert exists so the gate's inversion does not stay on screen as the surface's answer.
    private(set) static var text = TravOnce.resting

    /// `:5475` — the first hard lean, before anything has been crossed.
    /// Returns true when it actually fires, so a caller can start the hold.
    @discardableResult
    static func sayOnce(crossed: Int, tension: Double) -> Bool {
        guard !saidOnce, crossed == 0, tension > 0.55 else { return false }
        saidOnce = true
        showing = resting
        return true
    }

    /// `:5484` — `gateAcc > 700`, once, ever.
    @discardableResult
    static func sayGate() -> Bool {
        guard !saidGate else { return false }
        saidGate = true
        text = atTheGate
        showing = atTheGate
        return true
    }

    /// The end of a hold: the line goes, and the gate's text reverts to the resting one.
    static func endHold() { showing = nil }
    static func revert() { text = resting }

    /// Tests only — the design has no reset, because a session is the lifetime.
    static func resetForTesting() {
        saidOnce = false; saidGate = false; showing = nil; text = resting
    }
}
