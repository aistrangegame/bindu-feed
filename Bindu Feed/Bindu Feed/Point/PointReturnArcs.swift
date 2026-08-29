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
    static func leaveRegister() { /* holding, lift and reading are view state; arcs stay */ }

    /// Everything, for a fresh walk. Not called by leaving a register — only by starting over.
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
    static func homeFlash(at now: Date = Date()) -> Double {
        guard let homeFlashAt else { return 0 }
        return max(0, 1 - now.timeIntervalSince(homeFlashAt) * 1.5)
    }
}
