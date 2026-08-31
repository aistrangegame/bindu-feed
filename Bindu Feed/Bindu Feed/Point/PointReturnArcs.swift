import Foundation

// E2 · WORLD VI'S ARC REGISTRY — the wall clock, outside the view
//
// `world-six.js:86-170`. The register's whole sentence is one relationship:
//
//     `world-six.js:101` — *"leaving the register closes the reading. It does not cancel a
//     lap: nothing in flight cares whether he is watching."*
//
// The app's arc was two nested `DispatchQueue.main.asyncAfter` closures inside
// `ReadSending`, with its existence held in a `@State private var sent`. Leave the register
// and the flight goes with the view — so the one thing world VI claims was the one thing it
// could not do. And it carried ONE arc where the design carries a list.
//
// **THIS IS THE NINTH SHAPE FROM THE OTHER SIDE** (§10). World III's reversal was a
// relationship between a gesture and an effect; this is a relationship between an ABSENCE
// and an effect. No outcome check reaches either: *"a send comes back"* was true of the old
// code too. *"A send comes back when nobody is watching"* was not.
//
// The registry lives here, outside SwiftUI, on `Date` — the same idiom as `MirrorHall.backAt`,
// which the app already uses for world V's withdrawal for exactly this reason.
enum PointReturn {

    /// One thing in flight. `t0` is a wall-clock instant, not a countdown, so an arc knows
    /// when it lands without anything having to keep counting for it.
    struct Arc: Equatable {
        let id: String
        /// Which lap this is for that star — 1…4. It decides how long the flight takes.
        let n: Int
        /// Where the hand sent it, −1…1.
        let aim: Double
        let t0: Date
        let dur: Double
        /// Deep Time — *"it has been travelling since long before he arrived."*
        let deep: Bool

        /// UNWIRED(AUDIT D5.7 is OPEN — an arc's progress is read only by tests; the flight is still undrawn)
        func progress(at now: Date) -> Double {
            min(1, max(0, now.timeIntervalSince(t0) / dur))
        }
        func isHome(at now: Date) -> Bool { now.timeIntervalSince(t0) >= dur }
    }

    /// An arrival, waiting for him to be present. `world-six.js:94` — *"arrivals waiting for
    /// him to be present."* A lap that lands while he is elsewhere is not lost and is not
    /// delivered to nobody; it queues.
    struct Arrival: Equatable {
        let id: String
        let i: Int
        let n: Int
        let deep: Bool
        let all: Bool
    }

    /// `var DUR=[3.2,5.4,8.0,11.2]` — `world-six.js:84`. *"Each successive send is a wider
    /// arc and a longer wait: three seconds, …"* The fourth lap takes three and a half times
    /// the first, which is the register teaching patience with its own arithmetic.
    static let durations: [Double] = [3.2, 5.4, 8.0, 11.2]

    // ── the registry. Static, because it must outlive every view that shows it. ──

    private(set) static var arcs: [Arc] = []
    private(set) static var trails: [Arc] = []
    /// Per star: how many laps have come home.
    private(set) static var got: [String: Int] = [:]
    private(set) static var pending: [Arrival] = []
    private(set) static var total = 0
    private(set) static var deepSent = false
    /// `home` — the flash at the centre as a probe passes through, decaying at 1.5/s.
    private(set) static var homeFlashAt: Date?

    /// `reset()` — *"leaving the register closes the reading. It does not cancel a lap."*
    /// It clears what the HAND was doing and nothing that is in the air.
    /// TEST-ONLY(a documented NO-OP, as in `PointChamber` — *leaving the register closes the
    /// reading. It does not cancel a lap.* What it does not clear is the whole content.)
    static func leaveRegister() { /* holding, lift and reading are view state; arcs stay */ }

    /// Everything, for a fresh walk. Not called by leaving a register — only by starting over.
    /// TEST-ONLY(a static registry that must outlive every view; the suite needs it emptied
    /// between cases, and `.serialized` is why it can be. The app never resets the arcs.)
    static func resetAll() {
        arcs = []; trails = []; got = [:]; pending = []
        total = 0; deepSent = false; homeFlashAt = nil
    }

    // ── the send ──────────────────────────────────────────────────────

    /// `release()` — `world-six.js:126-137`. *"The whole act. After this line the hand has
    /// nothing further to do with it, and there is no way written anywhere to get it back."*
    ///
    /// Returns `nil` for a touch: `if(this.lift<0.14){this.lift=0;return null;}` — **not a
    /// send. Just a touch.** A register about letting go has to be able to tell the
    /// difference between letting go and brushing past.
    @discardableResult
    static func send(id: String, aim: Double, lift: Double, at now: Date = Date()) -> Arc? {
        guard lift >= 0.14 else { return nil }
        guard !isFlying(id) else { return nil }          // it is not here to be taken
        guard (got[id] ?? 0) < 4 else { return nil }     // it has come all the way home
        let n = (got[id] ?? 0) + 1
        let a = Arc(id: id, n: n, aim: aim,
                    t0: now, dur: durations[min(3, n - 1)], deep: false)
        arcs.append(a)
        return a
    }

    /// D5.7 · `aimTo(px,py,cx,cy,rim)` — `world-six.js:120-125`. Where the hand has taken it,
    /// and how far it has been drawn up out of its post.
    ///
    /// `aim` is horizontal displacement over `rim*0.46`, clamped to ±1. `lift` is how far ABOVE
    /// the star's own spot the hand has gone, over `rim*0.34`, clamped to 0…1 — **drawing it
    /// DOWN is not negative lift, it is no lift**, which is why the clamp floors at 0 and why a
    /// downward drag can never send.
    static func aim(handX: Double, spotX: Double, rim: Double) -> Double {
        max(-1, min(1, (handX - spotX) / (rim * 0.46)))
    }
    static func lift(handY: Double, spotY: Double, rim: Double) -> Double {
        max(0, min(1, (spotY - handY) / (rim * 0.34)))
    }

    /// D5.7 · **WHAT THE WORLD ASKS, IN WORDS** — `world-six.js:417-426`, all five states.
    ///
    /// The app had only the un-sent one. The two `holding` states were absent **because the
    /// gesture was absent**: world VI opened on a tap, so there was no holding to describe.
    /// Porting the strings onto a tap would have put authored words on the wrong gesture —
    /// which passes every checker and reads as fixed.
    ///
    /// **THE CUE TRACKS THE SEND THRESHOLD.** `DRAW IT UP` while `lift < 0.14`, `LET GO` once
    /// past it — the same 0.14 that `send` uses to tell a send from a touch (`:131`, *"not a
    /// send. Just a touch."*). So the words are not a label on the gesture, they are the
    /// gesture's own state read aloud: he is told the instant he has drawn it up far enough
    /// for letting go to mean something.
    static func cue(holding: Bool, lift: Double, arcs: [Arc]) -> String {
        if holding { return lift < 0.14 ? "DRAW IT UP · AIM · LET GO" : "LET GO" }
        if arcs.isEmpty { return "TAKE ONE · SEND IT OVER · WAIT" }
        if arcs.contains(where: { $0.deep }) { return "SOMETHING IS COMING THAT YOU DID NOT SEND" }
        if arcs.count > 1 { return "THEY WILL COME BACK IN THEIR OWN ORDER" }
        return "IT WILL COME BACK. NOT WHEN YOU WANT IT TO."
    }

    static func isFlying(_ id: String) -> Bool { arcs.contains { $0.id == id } }

    // ── the wall clock ────────────────────────────────────────────────

    /// `tick()` — `world-six.js:143-169`. *"Runs whether or not he is in the register."*
    ///
    /// Everything about an arc's fate is a function of `t0`, `dur` and the moment it is
    /// asked — so nothing has to be running for a lap to complete. Ticking after an hour of
    /// absence lands every arc that was due, in order, exactly as if it had been watched.
    @discardableResult
    static func tick(at now: Date = Date()) -> [Arrival] {
        var landed: [Arrival] = []
        var stillFlying: [Arc] = []
        for a in arcs {
            guard a.isHome(at: now) else { stillFlying.append(a); continue }
            trails.append(a)
            if trails.count > 26 { trails.removeFirst() }
            homeFlashAt = now
            if a.deep {
                got[a.id] = 4
                // Deep Time hands over all four at once: the crossing was made before him.
                for k in 1...4 {
                    landed.append(Arrival(id: a.id, i: k, n: 4, deep: true, all: k == 1))
                }
            } else {
                got[a.id] = a.n
                total += 1
                landed.append(Arrival(id: a.id, i: a.n, n: a.n, deep: false, all: false))
            }
        }
        arcs = stillFlying
        pending.append(contentsOf: landed)

        // `world-six.js:163-168` — *"Deep Time lets itself go, once he knows what a return
        // looks like. It is already mid-flight when it appears: it has been travelling since
        // long before he arrived."* `t0` is set 9.2s in the PAST, which is the whole point:
        // it is not launched, it is discovered already on its way.
        if !deepSent && total >= 4 {
            deepSent = true
            arcs.append(Arc(id: "x-cycles", n: 4, aim: -0.34,
                            t0: now.addingTimeInterval(-9.2), dur: 23.0, deep: true))
        }
        return landed
    }

    /// `take()` — `world-six.js:170`. *"what he is present for, handed over one at a time."*
    static func take() -> Arrival? { pending.isEmpty ? nil : pending.removeFirst() }

    /// `home=Math.max(0,this.home-dt*1.5)` — the flash decays over 1/1.5 s.
    /// UNWIRED(AUDIT D5.7 is OPEN — world VI's door is still unconditioned; the homecoming flash has no surface reading it)
    static func homeFlash(at now: Date = Date()) -> Double {
        guard let homeFlashAt else { return 0 }
        return max(0, 1 - now.timeIntervalSince(homeFlashAt) * 1.5)
    }
}
