import SwiftUI
import QuartzCore
import Combine

// THE TRAVEL — ported from spine-travel.js (The Instrument v3.html), verbatim in its
// numbers and its law. Fourteen membranes sit on the axis, one between each pair of
// registers: a register is not adjacent to its neighbour, it is separated from it by a
// SURFACE that must be MEANT. Drift into one and it holds, strains, and hands you
// gently back; keep meaning it and it thins, beads, GIVES — once, brightly — and from
// then on it stands open, because you opened it. Coming back up through an opened
// surface is nearly free. The fourteenth surface — between the sky (Z−4) and the Light
// (Z−5) — is the one force cannot touch: it answers only the ABSENCE of the hand. Hold
// still one breath (4600ms) at the sky and it thins and delivers you to the Light. When
// a surface gives, the camera leaves the hand: the PASSAGE carries you across.
//
// The constants below are the design's own; the exact hand-feel is the one thing only
// the walk on Neev can finalise. Frame-rate-independent (every damping term is
// pow(base, dt·60)), so ProMotion 120 and 60 travel identically.
@MainActor
final class AxisTravel: ObservableObject {
    @Published private(set) var z: Double
    @Published private(set) var flash: Double = 0       // the passage flash, 0…1
    @Published private(set) var thin: Double = 0        // the stillness gate filling at the sky, 0…1
    @Published private(set) var tension: Double = 0     // how hard the near membrane is felt, 0…1
    @Published private(set) var crossing = false        // inside a passage — the camera is out of the hand
    @Published private(set) var passageT: Double = 0     // 0…1 through the passage
    @Published private(set) var passageDir: Double = 1   // +1 inward (wormhole) · −1 outward (whitehole)
    @Published private(set) var speed: Double = 0        // |velocity| — feeds the glide's level

    var onCross: ((AxisRegister) -> Void)?

    // The hand.
    private var zv = 0.0, force = 0.0, back = 0.0
    private var down = false
    private var lastInput: CFTimeInterval = 0

    // The membranes.
    private var mem = [Bool](repeating: false, count: 14)
    private var push = 0.0, curS = -1, dir = 1.0, gave = -1

    // The stillness gate (surface 0, sky→Light).
    private var gateAcc = 0.0                            // milliseconds accumulated
    private let GATE = 0, GATE_MS = 4600.0

    // The passage (a give hands the camera a glide across the membrane).
    private var glideFrom = 0.0, glideTo = 0.0, glideT = 0.0, glideDur = 2.9

    // spine-travel.js T — the numbers are the instrument.
    private let DRAG = 0.00015, DAMP = 0.945, K = 30.0, RES = 0.58, span = 0.36
    private let MINZ = -5.0, MAXZ = 9.62                 // +0.62 overshoot so the centre can bloom past +9

    private var lastRegister: Int
    private var lastTime: CFTimeInterval = 0
    private var link: CADisplayLink?

    // CADisplayLink needs an @objc target; this proxy hops the main-thread tick back in.
    private final class Proxy: NSObject {
        let cb: () -> Void
        init(_ cb: @escaping () -> Void) { self.cb = cb }
        @objc func tick() { cb() }
    }
    private var proxy: Proxy?

    init(startZ: Double) {
        let clamped = Swift.min(Swift.max(startZ, -5), 9.62)
        z = clamped
        lastRegister = Axis.nearest(clamped).i
    }

    func start() {
        guard link == nil else { return }
        lastTime = CACurrentMediaTime()
        let p = Proxy { [weak self] in MainActor.assumeIsolated { self?.step() } }
        proxy = p
        let l = CADisplayLink(target: p, selector: #selector(Proxy.tick))
        l.add(to: .main, forMode: .common)
        link = l
    }

    func stop() { link?.invalidate(); link = nil; proxy = nil }

    // MARK: - Input (the hand)

    func applyDrag(_ deltaY: Double) {
        guard !crossing else { return }                 // inside a passage the hand is ignored
        zv += (-deltaY) * DRAG
        force += (-deltaY) * DRAG
        lastInput = CACurrentMediaTime()
    }

    func setDown(_ v: Bool) {
        down = v
        if v { lastInput = CACurrentMediaTime() }
    }

    private var atSky: Bool { abs(z + 4) < 0.45 }

    // MARK: - The frame

    private func step() {
        let now = CACurrentMediaTime()
        var dt = now - lastTime
        lastTime = now
        guard dt > 0 else { return }
        dt = Swift.min(dt, 1.0 / 30.0)
        let f = dt * 60.0

        // Inside a passage: the camera glides across on a smoothstep; the hand is out.
        if crossing {
            glideT += dt / glideDur
            let tt = Swift.min(1, glideT)
            passageT = tt
            let e = tt * tt * (3 - 2 * tt)               // smoothstep
            z = glideFrom + (glideTo - glideFrom) * e
            flash = Swift.max(0, flash - dt / 0.9)
            if tt >= 1 { z = glideTo; crossing = false; passageT = 0; zv = 0; force = 0 }
            detectCross()
            return
        }

        // The membrane returns the share of speed it lets him keep.
        zv *= update(dt: dt)
        zv += back * f
        z = Swift.min(Swift.max(z + zv * f, MINZ), MAXZ)
        zv *= pow(DAMP, f)
        speed = abs(zv)

        if gave >= 0 { beginPassage(surface: gave, dir: dir); gave = -1; zv = 0 }

        // The stillness gate: at the sky's edge, the way on opens by not being asked for.
        if atSky && !mem[GATE] && !crossing {
            let busy = down || (now - lastInput) < 0.34
            if !busy { gateAcc = Swift.min(GATE_MS, gateAcc + dt * 1000) }
            if gateAcc >= GATE_MS {
                gateAcc = 0; mem[GATE] = true
                z = -4; zv = 0
                beginPassage(toZ: -5, dir: -1)           // the sky un-collapses; he is in the Light
            }
        } else if !atSky {
            gateAcc = 0
        }
        thin = (atSky && !mem[GATE]) ? gateAcc / GATE_MS : 0

        flash = Swift.max(0, flash - dt / 0.9)
        detectCross()
    }

    // The surface between shell s and s+1 stands at Z + 5 = s + 0.5.
    private func surfaceAt(_ Z: Double) -> Int {
        let s = Int((Z + 5 - 0.5).rounded())
        return (s < 0 || s > 13) ? -1 : s
    }

    // spine-travel.js update — everything the membrane is, is in these lines.
    private func update(dt: Double) -> Double {
        let fce = force; force = 0
        if fce != 0 { dir = fce > 0 ? 1 : -1 }
        let q = z + 5
        let s = surfaceAt(z)
        back = 0
        if s < 0 { tension = 0; push = 0; curS = -1; return 1 }
        if curS != s { curS = s; push = 0 }
        let at = Double(s) + 0.5
        let d = abs(q - at)
        let t = 1 - Swift.min(1, d / span)
        let open = mem[s]
        tension = open ? t * 0.20 : t

        // The stillness gate: pushing it only holds it; it thins to the absence of pushing.
        if s == GATE && !open {
            push = 0
            if t > 0.06 {
                if !down { back = (q < at ? -1 : 1) * 0.0026 * t }
                return pow(1 - 0.92 * t, dt * 60)
            }
            return 1
        }

        let toward = (q < at) ? (dir > 0) : (dir < 0)
        if !open {
            // Meaning it counts from the moment the surface is felt at all.
            if toward && t > 0.02 && fce != 0 {
                push = Swift.min(1, push + abs(fce) * K)
            } else if !down {
                push = Swift.max(0, push - dt * 0.18)
            }
            if push >= 1 {                               // it gives
                mem[s] = true; flash = 1; gave = s
                return 0
            }
        }
        if !open && t > 0.30 {                           // it holds — and hands him back
            if !down && push < 0.5 { back = (q < at ? -1 : 1) * 0.0016 * t }
            return pow(1 - RES * t * (1 - push * 0.85), dt * 60)
        }
        return open ? pow(1 - 0.05 * t, dt * 60) : 1     // an opened surface is nearly free
    }

    // MARK: - The passage

    private func beginPassage(surface s: Int, dir d: Double) {
        let target = d > 0 ? Double((s + 1) - 5) : Double(s - 5)
        beginPassage(toZ: target, dir: d)
    }

    private func beginPassage(toZ target: Double, dir d: Double) {
        glideFrom = z
        glideTo = Swift.min(Swift.max(target, MINZ), MAXZ)
        glideT = 0; glideDur = 2.9
        dir = d; passageDir = d; passageT = 0
        crossing = true
        flash = 1
    }

    private func detectCross() {
        let r = Axis.nearest(z)
        if r.i != lastRegister { lastRegister = r.i; onCross?(r) }
    }
}
