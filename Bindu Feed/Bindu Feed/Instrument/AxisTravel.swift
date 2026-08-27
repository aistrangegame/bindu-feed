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

    /// The fourteen surfaces' opened state (surface s sits between register s and s+1), read by
    /// the ladder rail. Mutated on the display-link tick; the rail reads it from a per-frame body.
    var openedSurfaces: [Bool] { mem }

    // THE STILLNESS GATE (surface 0, sky→Light) — one accumulator, not a countdown.
    // `dwell` is 0…1; see the block in step() for the law and the numbers.
    private var dwell = 0.0
    private let GATE = 0

    /// The `|turnV| < 0.001` term of the design's `still` — the register's OWN gesture, which
    /// has to have stopped too. Fed by `UniverseCamera` when its pan inertia starts or ends.
    private var registerDrifting = false

    // The passage (a give hands the camera a glide across the membrane).
    private var glideFrom = 0.0, glideTo = 0.0, glideT = 0.0, glideDur = 5.4

    // spine-travel.js T — the numbers are the instrument.
    //
    // These are TWK_DIST['immense'] (The Instrument v3.html:4923), which is what the
    // runtime actually applies: applyMode() (:4936-4940) runs Object.assign(TR, …) at
    // boot (:5985) over the module defaults at :3429-3431. The defaults were ported
    // here previously and are 17% light on DRAG and a full 0.011 light on DAMP.
    //
    // The trap: the default LONG experience uses the preset named `immense`, NOT the
    // one named `long`. Reading the `long` row gives a plausible-looking wrong answer
    // (DRAG .00024 · DAMP .950 · span .34 · DUR 2.9).
    //
    // DAMP compounds: 0.945^60 = 0.033 against 0.956^60 = 0.068 — one second after a
    // release the old numbers had half the glide left. K and RES are TWK_SURF.held
    // (:4925) and were already right.
    //
    // WHEEL 0.00008 and PINCH 0.0020 belong to the same preset but have no input path
    // in the app yet (no wheel, no pinch-to-travel — C2.7). Recorded here, not declared,
    // so they arrive with the gesture rather than sitting dead.
    private let DRAG = 0.00018, DAMP = 0.956, K = 30.0, RES = 0.58, span = 0.42
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

        // `B0.4` — THE LIGHT MUST BE ESCAPABLE.
        //
        // Surface 0 (sky↔Light) is a one-way valve: it answers only the ABSENCE of the hand,
        // so drag can never reopen it. Walk in through the stillness gate and it is marked
        // open on the way. But the Turn offers the Light directly — `A Strange Feed.html:426`,
        // `?z=-5`, which is canon and stays — and arriving that way lands you PAST a surface
        // that was never opened. The gate branch then zeroes `push`, damps 92%/frame and
        // pushes back: trapped.
        //
        // (The audit suggested deleting the Turn's row instead. That would delete an authored
        // string — the same error as inventing one. The row is the design's; the unopened
        // surface is the defect.)
        //
        // Arriving at a register means you are past the surface below it, so mark it open.
        if clamped <= -4.5 { mem[GATE] = true }
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

    // MARK: - The Universe (it asks; the axis travels)

    /// The register is drifting under its own inertia — the Universe's pan glide. Part of
    /// `still`: a camera that is still coasting is not stillness.
    ///
    /// (`setUniverseMode` used to live here, suspending the gate whenever a Universe register
    /// was up. It was called from the `axisLocked` arming block, and when that block went with
    /// the seam nothing set it any more — so the flag read false for ever and the suspension
    /// it documented had silently stopped existing. Deleted rather than re-wired: the design
    /// has no such mode, and the gate's own band and asymmetry are what keep it off you.)
    func setRegisterDrifting(_ v: Bool) { registerDrifting = v }

    /// The tap's inward impulse. The Universe never moves the scale itself — it asks, and
    /// the axis travels, so there stays exactly one scale in the instrument.
    /// `The Universe v3.html:1664,1668` — 0.06 on empty sky, 0.085 on a star.
    func drawIn(_ dz: Double) {
        guard !crossing else { return }
        zv += dz
        lastInput = CACurrentMediaTime()
    }

    /// Leave the Universe: release universe mode and glide the axis back to the Feed (Z=0) via
    /// the passage throat — an explicit exit, replacing the old auto-eject.
    func exitToFeed() {
        beginPassage(toZ: 0, dir: 1)
    }

    // MARK: - Input (the hand)

    /// True while the register that is up has claimed the vertical for its own gesture.
    ///
    /// The fall is the one register that does (`The Universe v3.html:1616-1622` — in the sky
    /// the drag pans, in the fall it descends; an if/else, one owner at a time). The design
    /// uses the same shape for a passage: something else owns the camera, so the hand stands
    /// down (`applyDrag` already guards `!crossing` for exactly this reason).
    ///
    /// This is NOT `axisLocked` returning. That was global, armed on a `.onChange` that never
    /// fired on first appearance, and walled off whole registers. This is scoped to an OPEN
    /// FALL on a chosen star, released the moment the fall closes, and it is enforced HERE at
    /// the source rather than at a gesture — so no call path can route around it.
    private var handedToRegister = false
    func handVerticalToRegister(_ v: Bool) { handedToRegister = v }

    func applyDrag(_ deltaY: Double) {
        guard !crossing else { return }                 // inside a passage the hand is ignored
        guard !handedToRegister else { return }         // the register owns the vertical
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

        // ── THE STILLNESS GATE ─────────────────────────────────────────────────────────────
        // `The Instrument v3.html:5518-5520`, verbatim in its numbers:
        //
        //     const still = !down && |zv| < 0.0016 && |turnV| < 0.001;
        //     if (still && Z < -2.3) dwell = min(1, dwell + dt*0.30);
        //     else                   dwell = max(0, dwell - dt*1.30);
        //
        // It was a flat 4600 ms countdown, armed by `atSky` and by a 340 ms time-since-input
        // proxy for stillness. Three things that timer could not do, and the asymmetry is the
        // whole mechanism:
        //
        //   · `still` is a VELOCITY test, not a since-you-last-touched test. A camera that is
        //     still gliding is not still. The proxy counted it as still 340 ms after the hand
        //     left the glass, which is why the gate fired on a hand that had only just let go.
        //   · it builds over 1/0.30 = 3.33 s, not 4.6.
        //   · it decays over 1/1.30 = 0.77 s — 4.3× faster than it builds. Looking at the
        //     screen for a moment costs almost nothing; only deciding to be still carries you.
        //
        // Band: `Z < −2.3`, the literal reading of "stillness at the sky's edge" (:1024) —
        // wider than the sky alone, and it is the accumulator, not the band, that holds it off.
        let still = !down && abs(zv) < 0.0016 && !registerDrifting
        #if DEBUG
        // A WALK HOOK, NOT A SURFACE. `defaults write <bundle> bindu.debug.nogate -bool YES`
        // suspends the gate for scripted walks. A screenshot→compute→tap loop takes longer
        // than the 3.33s the accumulator needs, so every multi-step approach to one specific
        // star gets delivered to the Light half-way — which blocks the fall, and the fall is
        // where the most unwalked geometry lives. The gate is not wrong; it is simply faster
        // than a scripted hand. Same shape as `parkDebugRoomIfRequested`: one key, no UI, and
        // nothing in a release build compiles this at all.
        if UserDefaults.standard.bool(forKey: "bindu.debug.nogate") {
            thin = 0
            flash = Swift.max(0, flash - dt / 0.9)
            detectCross()
            return
        }
        #endif
        if still && z < -2.3 && !mem[GATE] && !crossing {
            dwell = Swift.min(1, dwell + dt * 0.30)
        } else {
            dwell = Swift.max(0, dwell - dt * 1.30)
        }
        if dwell >= 1 && !mem[GATE] && !crossing {
            dwell = 0
            // The passage carries him from where he STANDS — there is no snap to the sky
            // first. Arriving at a register means you are past every surface below it (the
            // rule `init(startZ:)` already applies to the Turn's Light row), so mark what
            // the passage carries him through rather than leaving a closed surface behind.
            for sfc in 0..<mem.count where Double(sfc) + 0.5 < z + 5 { mem[sfc] = true }
            beginPassage(toZ: -5, dir: -1)               // the sky un-collapses; he is in the Light
        }
        thin = mem[GATE] ? 0 : dwell

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
        glideT = 0; glideDur = 5.4
        dir = d; passageDir = d; passageT = 0
        crossing = true
        flash = 1
    }

    private func detectCross() {
        let r = Axis.nearest(z)
        if r.i != lastRegister { lastRegister = r.i; onCross?(r) }
    }
}
