import Foundation

// E1 · WORLD VII'S CHAIN — and the relationship that INVERTS world VI's
//
// `world-seven.js:112-300`. `AUDIT D5.8`, BLOCKER: 11 of 23 mechanisms absent — `hand`,
// `offer`, `moveHand`, `letGo`, `chain`, `joinedQ`, `_join`, `tookHand`, `lock`, `joinedNow`,
// and the whole `update` figure.
//
// **THE CAPTION IS THE TELL, AND IT IS THE NINTH SHAPE AGAIN.** `ReadCompany` printed
// `"\(s.revealed) hands · the dance is carrying you"` — the number right, the thing absent.
// Complete-looking output over nothing: `s.revealed` counts SECTIONS READ, and the sentence
// claims a count of HANDS HELD. Every outcome check passes a caption that renders.
//
// **AND ITS RELATIONSHIP IS THE OPPOSITE OF WORLD VI'S.**
//
//   VI · `world-six.js:101` — *"nothing in flight cares whether he is watching."*
//        Time decides; attention does not. An arc abandoned still arrives.
//   VII · `world-seven.js:155` — `letGo()` empties the chain outright.
//        **The dance exists only while a hand is held.** Attention is the whole of it.
//
// So the relationship assertion here is that **letting go actually DISSOLVES it** — not that
// it persists. Kuramoto coupling will happily hold five bodies locked forever if nothing
// breaks the chain, and locked-forever passes every outcome check exactly as world III's
// four sections did. `lock` decaying to zero after `letGo` is the assertion; `lock` reaching
// 1 is not.
enum PointDance {

    /// One body on the floor. Nine that dance, and `d-map`, which is `last` — *"it comes when
    /// everyone else has danced, and not before, and it is not asked."*
    final class Body {
        let id: String
        let uni: Int
        /// `last:(id==='d-map')` — the one nobody may take by the hand.
        let last: Bool
        var x: Double, y: Double, vx = 0.0, vy = 0.0
        /// Its own phase and its own natural rate — the Kuramoto pair.
        var ph: Double
        let w: Double
        var danced = false
        /// Its place in the chain, or −1 for free.
        var chain = -1
        /// How long it has been close enough to the chain to be joining it.
        var near = 0.0
        /// Where the chain wants it this frame, when it is in one. `nil` means free.
        var target: (x: Double, y: Double)?

        init(id: String, uni: Int, index: Int, last: Bool) {
            self.id = id; self.uni = uni; self.last = last
            let a = Double(index) / 9 * (.pi * 2)
            x = cos(a) * 0.52; y = sin(a) * 0.46          // normalised to rim
            ph = (a * 1.7).truncatingRemainder(dividingBy: .pi * 2)
            w = 0.62 + Double(index % 5) * 0.055
        }
    }

    // ── the design's constants, every one of them ──────────────────────

    /// `var GATE=[1.5,3.3,5.5,8.1]` — *"Alone it takes about eight seconds of dancing to
    /// reach the fourth. With four others in the chain it takes under four."*
    static let gates: [Double] = [1.5, 3.3, 5.5, 8.1]
    /// `L=0.22` — the length of one link, and `11.0` its spring. *"a held hand is a spring,
    /// not a weld."*
    static let linkLength = 0.22, linkSpring = 11.0
    /// `K=1.9` — the Kuramoto coupling.
    static let coupling = 1.9
    /// The most that can be holding on at once.
    static let maxChain = 5

    // ── the floor ──────────────────────────────────────────────────────

    private(set) static var bodies: [Body] = []
    /// His hand, in rim-normalised floor coordinates. `nil` when it is not down — and that
    /// single fact is what the whole register hangs on.
    private(set) static var hand: (x: Double, y: Double)?
    private(set) static var chain: [Body] = []
    /// `carry` — how much dancing has been done, at the chain's rate.
    private(set) static var carry = 0.0
    private(set) static var given = 0
    /// `lock` — the order parameter of the chain's phases, 0 → 1. **The number the sound
    /// uses**: `ensemble(lock:)` closes each dancer's detune by it.
    private(set) static var lock = 0.0
    private(set) static var swirl = 0.0
    private(set) static var resolved = 0.0
    /// Every body that has danced, in the order it did. `reset` does not clear this —
    /// *"it does not un-dance anybody."*
    private(set) static var order: [String] = []
    /// Bodies that joined since the last read. `joinedQ` — *"several can take a hand in the
    /// same frame; none is lost."*
    private(set) static var joinedQueue: [Body] = []
    private(set) static var gaveNow: Int?

    static func floor(universes: [[String]]) {
        guard bodies.isEmpty else { return }
        var index = 0
        for (ui, stars) in universes.enumerated() {
            for id in stars {
                bodies.append(Body(id: id, uni: ui, index: index, last: id == "d-map"))
                index += 1
            }
        }
    }

    static func resetAll() {
        bodies = []; hand = nil; chain = []
        carry = 0; given = 0; lock = 0; swirl = 0; resolved = 0
        order = []; joinedQueue = []; gaveNow = nil
    }

    // ── offering a hand, and taking it back ────────────────────────────

    /// `offer(px,py,…)` — the hand comes down.
    @discardableResult
    static func offer(x: Double, y: Double) -> Bool {
        guard resolved == 0 else { return false }
        hand = (x, y)
        return true
    }

    static func moveHand(x: Double, y: Double) {
        guard hand != nil, resolved == 0 else { return }
        hand = (x, y)
    }

    /// `letGo()` — `world-seven.js:155-160`. **THE INVERSION.** The chain is emptied, every
    /// body is freed, `carry` and `given` go to zero. The dance does not continue without a
    /// hand, and `lock` has nothing left to hold it up.
    ///
    /// What it does NOT clear is `danced` and `order` — *"it does not un-dance anybody."*
    /// A body that has danced has danced; only the holding is undone.
    static func letGo() {
        guard hand != nil else { return }
        hand = nil
        joinedQueue = []
        for b in chain { b.chain = -1; b.near = 0 }
        chain = []
        carry = 0
        given = 0
    }

    /// `reset()` — leaving the register. *"leaving the register lets go of his hand. It does
    /// not stop the figure and it does not un-dance anybody."* Same as `letGo` on the chain,
    /// and the bodies keep moving because the floor is not his.
    static func leaveRegister() {
        hand = nil
        joinedQueue = []
        for b in chain { b.chain = -1 }
        chain = []
        carry = 0
        given = 0
    }

    static func takeJoined() -> Body? { joinedQueue.isEmpty ? nil : joinedQueue.removeFirst() }

    // ── the figure ─────────────────────────────────────────────────────

    /// `update(dt)` — `world-seven.js:167-297`. Nine coupled bodies: cohesion, separation,
    /// alignment with their own universe, one slow shared swirl, and Kuramoto phase coupling
    /// — *"so they fall into time with each other the way anything that dances together
    /// does. He is a tenth body when his hand is down."*
    @discardableResult
    static func update(_ rawDt: Double) -> Double {
        let dt = min(0.05, rawDt)
        gaveNow = nil
        let res = resolved
        let damp = res > 0 ? max(0, 1 - res * 1.6) : 1
        swirl += dt * 0.16 * damp

        // where the chain wants each of them — a line of links off his hand
        for b in bodies { b.target = nil }
        if let h = hand, res == 0 {
            var prev = h
            for b in chain {
                let ang = atan2(b.y - prev.y, b.x - prev.x)
                b.target = (prev.x + cos(ang) * linkLength, prev.y + sin(ang) * linkLength)
                prev = (b.x, b.y)
            }
        }

        let mx = bodies.reduce(0) { $0 + $1.x } / Double(bodies.count)
        let my = bodies.reduce(0) { $0 + $1.y } / Double(bodies.count)

        for b in bodies {
            var ax = 0.0, ay = 0.0
            if let t = b.target {
                ax += (t.x - b.x) * linkSpring; ay += (t.y - b.y) * linkSpring
            } else {
                ax += (mx - b.x) * 0.52; ay += (my - b.y) * 0.52          // cohesion, gently
                let r = max(0.001, (b.x * b.x + b.y * b.y).squareRoot())  // the floor's current
                ax += (-b.y / r) * 0.78 * (0.4 + r); ay += (b.x / r) * 0.78 * (0.4 + r)
                if !chain.isEmpty, let h = hand, !b.last {                // toward a dancing pair
                    let hx = h.x - b.x, hy = h.y - b.y
                    let hd = max(1e-9, (hx * hx + hy * hy).squareRoot())
                    let pull = min(1.05, 0.30 / (hd * hd + 0.13))
                    ax += hx / hd * pull; ay += hy / hd * pull
                }
            }
            for o in bodies where o !== b {
                let dx = b.x - o.x, dy = b.y - o.y, d2 = dx * dx + dy * dy
                if d2 < 0.0484 && d2 > 1e-6 {                             // separation
                    let d = d2.squareRoot()
                    ax += dx / d * (0.22 - d) * 9.5; ay += dy / d * (0.22 - d) * 9.5
                }
                if o.uni == b.uni {                                       // alignment
                    ax += (o.vx - b.vx) * 0.30; ay += (o.vy - b.vy) * 0.30
                }
            }
            // the pulse — every body moves a little more on its own upbeat
            let pu = 0.86 + cos(b.ph) * 0.20
            b.vx = (b.vx + ax * dt) * 0.955; b.vy = (b.vy + ay * dt) * 0.955
            b.x += b.vx * dt * pu * damp; b.y += b.vy * dt * pu * damp
            let rr = (b.x * b.x + b.y * b.y).squareRoot()
            if rr > 0.76 {                                                // a soft edge
                let k = 0.76 / rr
                b.x *= k; b.y *= k; b.vx *= 0.72; b.vy *= 0.72
            }
        }

        // PHASE. Inside the chain the coupling is strong, so a chain comes into time with
        // itself and the floor hears it happen.
        for b in bodies {
            var s = 0.0, cnt = 0.0
            for o in bodies where o !== b {
                let both = b.chain >= 0 && o.chain >= 0
                let w = both ? 1.0 : (o.uni == b.uni ? 0.30 : 0.10)
                s += w * sin(o.ph - b.ph); cnt += w
            }
            b.ph += (b.w + (cnt > 0 ? coupling * s / cnt : 0)) * dt * damp
            if b.ph > .pi * 8 { b.ph -= .pi * 8 }
        }

        // how in time the chain is — the number the sound and the shader use
        if !chain.isEmpty {
            var sx = 0.0, sy = 0.0
            for b in chain { sx += cos(b.ph); sy += sin(b.ph) }
            let r = (sx * sx + sy * sy).squareRoot() / Double(chain.count)
            lock += (r - lock) * min(1, dt * 2.2)
        } else {
            // **AND THIS IS THE INVERSION, IN ONE LINE.** With no chain there is nothing to
            // be in time with, so the lock falls. A dance that kept its lock after the hand
            // came off would be a dance nobody was in.
            lock = max(0, lock - dt * 1.1)
        }

        joins(dt: dt, res: res)
        if resolved > 0 { resolved = min(1, resolved + dt * 0.40) }
        return lock
    }

    /// *"The nearest free body takes his offered hand. After that, anyone who stays close to
    /// the chain long enough joins it. Nobody is chosen; it is whoever the figure brings."*
    private static func joins(dt: Double, res: Double) {
        guard let h = hand, res == 0 else { return }
        if chain.isEmpty {
            var best: Body?, bd = 1e9
            for b in bodies where !b.last {
                let d = ((b.x - h.x) * (b.x - h.x) + (b.y - h.y) * (b.y - h.y)).squareRoot()
                if d < bd { bd = d; best = b }
            }
            if let best, bd < 0.19 { join(best) }
        } else if chain.count < maxChain {
            for b in bodies where b.chain < 0 && !b.last {
                var cd = 1e9
                for c in chain {
                    cd = min(cd, ((b.x - c.x) * (b.x - c.x) + (b.y - c.y) * (b.y - c.y)).squareRoot())
                }
                if cd < 0.28 {
                    b.near += dt
                    if b.near > 1.9 && chain.count < maxChain { join(b) }
                } else {
                    b.near = max(0, b.near - dt * 1.4)
                }
            }
        }
        // *"the pace: the sections come faster the more of them there are — and it does not
        // start until somebody has actually taken the hand. The wait for a body to cross the
        // floor is not dancing, and a section spent during it would be handed to nobody."*
        if !chain.isEmpty {
            carry += dt * (0.52 + Double(chain.count) * 0.46)
            if given < 4 && carry >= gates[given] {
                given += 1
                gaveNow = given
            }
        }

        // d-map — *"it comes when everyone else has danced, and not before, and it is not
        // asked."*
        if res == 0, let map = bodies.first(where: { $0.last }), !map.danced, !chain.isEmpty {
            let all = bodies.filter { !$0.last }.allSatisfy(\.danced)
            if all { join(map); resolved = 0.0001; given = 4; gaveNow = 1 }
        }
    }

    private static func join(_ b: Body) {
        b.chain = chain.count
        chain.append(b)
        b.near = 0
        if !b.danced { b.danced = true; order.append(b.id) }
        joinedQueue.append(b)
    }
}
