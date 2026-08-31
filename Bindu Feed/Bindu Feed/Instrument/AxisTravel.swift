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
    /// C2.6 · `PS.after` — 1 at the landing, decaying over 0.75s. The passage's hold on the
    /// surface does not end when the passage does.
    @Published private(set) var after: Double = 0

    /// `flare` — `The Chrome.html:199-212`. **THE PASSAGE HAS A MIDDLE.**
    ///
    /// Two gates at `t = 0.34` and `0.68`, each firing once per crossing. The comp's own
    /// note is the whole reason they exist: *"They exist so the crossing has a middle."* A
    /// 5.4-second glide with nothing in it is a wait; two strikes inside it make it a
    /// passage with structure, and it is what tells the hand the crossing is still happening
    /// rather than stalled. `AxisTravel` published only `passageT`, so there was no middle
    /// and nothing could have drawn one.
    ///
    /// Decays like `flash`, and is **not** raised on a swift crossing — see `glideSwift`.
    @Published private(set) var gateFlare: Double = 0
    @Published private(set) var passageDir: Double = 1   // +1 inward (wormhole) · −1 outward (whitehole)
    @Published private(set) var speed: Double = 0        // |velocity| — feeds the glide's level

    /// `immA` — `The Instrument v3.html:5501`, integrated here because this object owns the
    /// frame clock and the design integrates it in the same loop that advances Z.
    ///
    /// **IT LIVES ON THE CLOCK, NOT IN A VIEW.** A `@State` mutated per frame from inside a
    /// `TimelineView` body is SwiftUI's "modifying state during view update" fault; and the
    /// law is explicit Euler with a direction-dependent rate, which no `withAnimation` can
    /// express. `Immersion.step` is the arithmetic; this is only where the seconds come from.
    @Published private(set) var immA: Double = 0

    /// `!!pc` — whether a piece is open at all. Separate from `immA` because `:5503` needs
    /// BOTH: an immersion value that is still fading out after the piece is gone is not
    /// immersion, it is the withdrawal.
    @Published private(set) var pieceOpen = false
    private var pieceGiven = 0
    private var pieceDisplacement: Double = 0
    private var pieceDimension = 0

    /// `hush` — `:5642-5643`. `inWorld()` returns the live reading's own `displaced()`, and
    /// `hush = withStar ? max(0.42, dspNow) : 0`. The chrome steps aside for a reading by at
    /// LEAST 0.42 the moment one opens, and further as it is given.
    ///
    /// Its scope is NOT `piece()`'s. `inWorld` (`:5635-5640`) covers d1…d4 only — registers
    /// 2, 3, 4, 5 — so in the Dance the chrome fades by `immA` alone and never by `hush`.
    /// It also carries no `||IMM.on` latch, where `piece()` does: `hush` answers the live
    /// gesture, not the state the gesture put him in.
    var hush: Double {
        guard pieceOpen, (1...4).contains(pieceDimension) else { return 0 }
        return max(0.42, Double(min(4, max(0, pieceGiven))) / 4)
    }

    /// `IMM.on` — `:5503`. Not `pointHolds`: that is true from the moment a reading opens,
    /// this is true only once three of its four sections have been admitted.
    var immersed: Bool { pieceOpen && immA > Immersion.onThreshold }

    /// `:5496-5500` — the app's reach of `piece()`. `given` is the reading's `revealed`.
    ///
    /// `displacement` defaults to 0 because the halved-depth channel cannot win for any piece
    /// this app can reach (see `Immersion.target`); it is a parameter rather than a constant
    /// so the Light can hand up `arrive*2` when C4.7 gives it somewhere to hand it from.
    func setPiece(given: Int, dimension: Int = 0, displacement: Double = 0) {
        pieceOpen = true; pieceGiven = given
        pieceDimension = dimension; pieceDisplacement = displacement
    }

    /// `letGo()` (`:5346-5353`) — the identity and the count are dropped on the SAME frame the
    /// piece closes, and every module's `reset` zeroes `given` (`:2441`, `:2653`, `:2903`,
    /// `:3172`). Only `immA` is left to fall on its own. `:5505` is not this path: it is the
    /// fallback for a piece that LAPSES without a `letGo`, and its job is to keep the piece's
    /// material key alive through the fade — which for every key but the Far light scene is
    /// the register's own key anyway.
    func clearPiece() {
        pieceOpen = false; pieceGiven = 0; pieceDimension = 0; pieceDisplacement = 0
    }

    var onCross: ((AxisRegister) -> Void)?

    /// C7.11 · **A LANDING IS NOT A CROSSING, AND ONLY A LANDING SOUNDS.**
    ///
    /// `The Instrument v3.html:5452` — `if(ev==='land'){ Z=PS.z1; TR.s=-1; B.give(S.REG[PS.to].hz); }`
    /// The design's per-register arrival tone fires from **inside the passage's landing** and
    /// from nowhere else. Every other `B.threshold` call site in the design is a specific
    /// event — `letGo()` at `:5354`, the IMMENSE entry at `:5504`, the turn at `:5082` — and
    /// **not one of them is a plain register crossing.**
    ///
    /// `onCross` fires from both paths (`detectCross()` runs inside a passage and outside it),
    /// so the app struck a bell every time he drifted past a boundary. That is the behaviour
    /// `spine-sound.js:12-13` says was **replaced**. `AUDIT C7.11`.
    var onLand: ((AxisRegister) -> Void)?

    // The hand.
    private var zv = 0.0, force = 0.0, back = 0.0
    /// Readable so the stillness drone can be cut the instant the hand arrives — E4.2's
    /// "gone in ~0.2s" is about the TOUCH, not about the accumulator's 1.30/s decay.
    private(set) var down = false
    private var lastInput: CFTimeInterval = 0

    // The membranes.
    private var mem = [Bool](repeating: false, count: 14)
    /// `PS.swift` / `PS.hit` — the current passage's kind, and which gates have fired.
    private var glideSwift = false
    private var gateHit = [false, false]
    private var lastPassageT = 0.0
    /// C3.5 · **PUBLISHED, because the membrane's BODY is drawn from it.** `TR.draw` uses
    /// `push` for the wobble depth (`0.014 + push*0.055`), the stroke's third term, the line
    /// width (`0.7 + push*1.5`), the beads' size and the push-glow. The app drew a plain
    /// ellipse and substituted `tension` where the design uses `push`, so the membrane had no
    /// way to look *leaned into* as opposed to merely near.
    /// C3.4 · `TR.crossed` — how many membranes he has been given through. The resting line
    /// fires only `if(TR.crossed === 0)` (`:5475`): it is what the axis says to someone who
    /// has **not yet crossed anything**, so counting is the whole guard. Nothing counted them.
    @Published private(set) var crossed = 0

    @Published private(set) var push = 0.0
    private var curS = -1, dir = 1.0, gave = -1

    /// The fourteen surfaces' opened state (surface s sits between register s and s+1), read by
    /// the ladder rail. Mutated on the display-link tick; the rail reads it from a per-frame body.
    var openedSurfaces: [Bool] { mem }

    // THE STILLNESS GATE (surface 0, sky→Light) — one accumulator, not a countdown.
    // `dwell` is 0…1; see the block in `advance(dt:)` for the law and the numbers.
    /// B0.5 · **PUBLISHED, BECAUSE THE SHADER'S HALF WAS ALREADY BUILT AND STARVED.**
    ///
    /// `InstrumentField.metal`'s `mSky` computes the light-bend from it —
    /// `v += dwell * pow(max(0, cos(13·a2)), 7) * smoothstep(1.30, 0.04, |q|) * 0.11` — and
    /// `InstrumentView` passed `.float(0)`. The gesture was implemented, the accumulator was
    /// running, and the two were never connected: **a uniform pinned to zero and a uniform
    /// nobody wrote are indistinguishable from the outside**, which is why `AUDIT B7.1` (still open) reads
    /// *"no implementation"* for a sweep whose shader half `mSky` already draws. What is missing there is the app computing the value, which is a
    /// smaller job than the row implies.
    ///
    /// **A NOTE I FIRST WROTE WRONG, KEPT BECAUSE THE CORRECTION IS THE USEFUL PART.** It said
    /// `dwell` and `thin` are different values and that `dwell` *"keeps answering stillness
    /// after the gate is through"*. **It does not.** `:353` sets `dwell = 0` the instant the
    /// gate fires, and the fill branch is guarded by `!mem[GATE]`, so it can never refill.
    /// `thin` is `mem[GATE] ? 0 : dwell`, so the two are equal before the gate and both zero
    /// after it — **behaviourally identical, and I explained a distinction that is not there.**
    /// A trace printed it in one line: `dwell` went 0.81 → 0.00 in a single step, which is not
    /// a 1.30/s drain.
    ///
    /// `dwell` is still the right name to publish, for a smaller reason than the one I gave:
    /// it is the quantity the design itself names (`DP.dwell`,
    /// `The Instrument v3.html:1242-1248`), so the shader reads the thing the design reads.
    /// If the gate's reset is ever revisited, the light-bend follows the design's variable
    /// rather than a derived one that happens to match today.
    @Published private(set) var dwell = 0.0
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
    // C7.8's shape, found by the duplicate sweep: the axis's bounds were written THREE times —
    // `Axis.minZ`/`Axis.maxZ` with an uncalled `Axis.clampZ` beside them, this private pair,
    // and bare literals at `beginAt`. The copy that LOOKED canonical (named, documented, citing
    // `spine-axis.js:87`) was the one nothing used, so correcting the overshoot there would
    // have moved nothing. One source now: `Axis.clampZ`.

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
        let clamped = Axis.clampZ(startZ)
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
        // The link's ONLY job is to say how much time passed. Everything else is `advance`.
        let p = Proxy { [weak self] in
            MainActor.assumeIsolated {
                guard let self else { return }
                let now = CACurrentMediaTime()
                let dt = now - self.lastTime
                self.lastTime = now
                self.advance(dt: dt)
            }
        }
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
    /// B7.5 · one step further out on the Universe's ladder — a real passage, not a jump, so
    /// the way back out is the way in reversed rather than a teleport.
    func stepOut(to target: Double) {
        guard !crossing else { return }
        beginPassage(toZ: target, dir: target > z ? 1 : -1)
    }

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
        guard !handedToRegister else { return }         // the register owns the vertical
        // C2.5 · `:5922` — `zv += (-dy)·DRAG; TR.force += (-dy)·DRAG;` runs whether or not a
        // passage is on, and `:5448` hands `TR.force` to the passage as its lean. **The
        // steering and the lean are two things**: inside a passage the hand must not move
        // `zv` — he cannot steer — but it still presses, and the crossing answers by going
        // faster. Guarding both together made the one event he is most invested in the one
        // event he could not touch.
        force += (-deltaY) * DRAG
        lastInput = CACurrentMediaTime()
        guard !crossing else { return }
        zv += (-deltaY) * DRAG
    }

    func setDown(_ v: Bool) {
        down = v
        if v { lastInput = CACurrentMediaTime() }
    }

    private var atSky: Bool { abs(z + 4) < 0.45 }

    // MARK: - The frame

    /// THE DISPLAY LINK SUPPLIES `dt` AND NOTHING ELSE.
    ///
    /// `step()` used to read `CACurrentMediaTime()` itself, so **every claim about this file
    /// was OWED by construction** — the landing-versus-drift-past distinction (C7.11), the
    /// passage's `swift`/`hit` behaviour in situ, the stillness gate's accumulation, the
    /// membrane's give. None of them can be lifted into a pure function the way `AxisPassage`
    /// and `DanceCatch` were, **because in each case the mechanism IS the sequencing.**
    ///
    /// So the clock is injected instead of the mechanism extracted. A test drives
    /// `advance(dt:)` directly and the whole axis becomes assertable without a simulator, a
    /// frame, or a wall clock — the same bargain `OfflineRender` made for sound, where the
    /// harness came before the work it proves (A3 before A1/A2).
    ///
    /// `dt` is still clamped here rather than at the caller: a test that hands over a huge
    /// step must be governed by the same rule a dropped frame is, or it would be exercising
    /// a machine the app never runs.
    func advance(dt rawDt: CFTimeInterval) {
        // `:3604` — `if (this.after > 0) this.after = Math.max(0, this.after - dt/0.75)`.
        if after > 0 { after = max(0, after - min(0.05, rawDt) / 0.75) }

        // `:5497-5501` — BEFORE the passage branch, because the design integrates immA in the
        // main loop unconditionally. A withdrawal that paused for the 5.4s of a crossing would
        // hold the world at whatever alpha it had when he left.
        //
        // The design's own `min(1, dt*k)` clamp is kept inside `Immersion.step` for fidelity
        // and cannot bind here: `dt` is capped at 1/30 below, and 0.0333·2.6 = 0.087.
        let tgt = pieceOpen
            ? Immersion.target(displacement: pieceDisplacement, given: pieceGiven)
            : 0
        immA = Immersion.step(immA, toward: tgt, dt: min(rawDt, 1.0 / 30.0))

        var dt = rawDt
        guard dt > 0 else { return }
        dt = Swift.min(dt, 1.0 / 30.0)
        let f = dt * 60.0

        // Inside a passage: the camera glides across on a smoothstep; the hand is out.
        if crossing {
            // `:3605` — `this.t += dt/this.dur * boost`. The lean is spent as it is read:
            // `:5448` zeroes `TR.force` on the same line it passes it.
            glideT += dt / glideDur * AxisPassage.boost(force: force)
            force = 0
            let tt = Swift.min(1, glideT)
            passageT = tt
            // `:210-211` — the two gates, once each, and NEVER on a slip-through. A surface
            // you have already opened has no middle to mark: that is the difference the
            // whole ledger rests on, so the gates are what a crossing HAS and a slip-through
            // does not.
            for i in AxisPassage.gatesCrossing(from: lastPassageT, to: tt, swift: glideSwift)
            where !gateHit[i] {
                gateHit[i] = true
                gateFlare = 1
            }
            lastPassageT = tt
            gateFlare = Swift.max(0, gateFlare - dt * 2.2)      // `:262` flare decay
            let e = tt * tt * (3 - 2 * tt)               // smoothstep
            z = glideFrom + (glideTo - glideFrom) * e
            flash = Swift.max(0, flash - dt / 0.9)
            if tt >= 1 {
                // C2.6 · `:3612` — `this.on = false; this.after = 1;` **on the same frame.**
                // The app set `crossing = false` and nothing else, so the rail, `#where` and
                // the shells snapped back the instant he landed. Arriving somewhere and
                // having the furniture reappear is a different act from it fading in.
                z = glideTo; crossing = false; passageT = 0; force = 0; after = 1
                // A slip-through keeps what it was given; an earned crossing ends at rest.
                // `:249` zeroes `zv`; `:255` multiplies it by 0.45 and lets him carry on.
                if !glideSwift { zv = 0 }
                detectCross()
                onLand?(Axis.nearest(z))       // `ev === 'land'` — the only arrival that sounds
                return
            }
            detectCross()
            return
        }

        // The membrane returns the share of speed it lets him keep.
        zv *= update(dt: dt)
        zv += back * f
        z = Axis.clampZ(z + zv * f)
        zv *= pow(DAMP, f)
        speed = abs(zv)

        if gave >= 0 {
            crossed += 1                       // `:191` — `TR.mem[s]=true; TR.crossed++`
            beginPassage(surface: gave, dir: dir, swift: false); gave = -1; zv = 0
        } else {
            // `swift` — `The Chrome.html:250-256`. **A SURFACE ALREADY OPENED IS A
            // SLIP-THROUGH, NOT AN EVENT.**
            //
            //     const s = surfaceAt(Z);
            //     if (s >= 0 && TR.mem[s] && Math.abs(zv) > 0.004) {
            //       const at = s+0.5, q = Z+5, prev = q-zv;
            //       if ((prev<at && q>=at) || (prev>at && q<=at)) { PS.begin(s,TR.dir,true,Z); zv *= 0.45; }
            //     }
            //
            // `_mechverdicts1.md` recorded it ABSENT: *"Re-crossing a surface you already
            // meant costs the same full 5.4s ceremony as the first time — the reward for
            // having meant it is invisible."* The memory was already here (`mem`,
            // `openedSurfaces`); nothing read it on the way back through.
            //
            // **The reward is the whole point.** `0.85s` against `5.4`, no gates, and
            // `zv ×= 0.45` so he comes out of it STILL MOVING rather than stopped — the comp
            // calls it *"quick and still a crossing"*. An instrument that charges full
            // ceremony for a door you have already opened teaches you not to go back.
            if let sIdx = AxisPassage.slipThrough(z: z, zv: zv, opened: mem) {
                beginPassage(surface: sIdx, dir: dir, swift: true)
                zv *= AxisPassage.slipSpeedKept
            }
        }

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

    private func beginPassage(surface s: Int, dir d: Double, swift: Bool = false) {
        let target = d > 0 ? Double((s + 1) - 5) : Double(s - 5)
        beginPassage(toZ: target, dir: d, swift: swift)
    }

    private func beginPassage(toZ target: Double, dir d: Double, swift: Bool = false) {
        glideFrom = z
        glideTo = Axis.clampZ(target)
        // `:203` — `this.dur = swift ? 0.85 : TR.DUR`.
        glideSwift = swift
        gateHit = [false, false]
        glideT = 0; glideDur = AxisPassage.duration(swift: swift); lastPassageT = 0
        dir = d; passageDir = d; passageT = 0
        crossing = true
        flash = 1
    }

    /// C7.3 · **THE TRAIL IS WHAT HE LEFT, NOT WHERE HE ARRIVED.**
    ///
    /// `canon/spine-sound.js:170-176` wraps the register voice:
    ///
    ///     var was = this.cur ? this.cur.f : 0;
    ///     axis.call(this, Z);
    ///     if (was && this.cur && this.cur.f !== was) this.trail(was);
    ///
    /// — under the comment at `:55`, *"what he left, still sounding behind him."* The tone
    /// falls away as it goes (`setTargetAtTime(hz·0.985)`) over 7.5s, which only means
    /// anything if it is the register receding behind him.
    ///
    /// **THIS IS THE NINTH SHAPE AND NOTHING OUTCOME-SHAPED CAN SEE IT.** A trail sounded on
    /// every crossing, at a real register's pitch, decaying correctly — and it sang the
    /// DESTINATION. *"A tone plays when you cross"* is true of both builds. What separates
    /// them is which of the two registers it is, and the app had the arrival: the sound of
    /// leaving somewhere, playing the name of the place you have just reached.
    private func detectCross() {
        let r = Axis.nearest(z)
        guard r.i != lastRegister else { return }
        let left = Axis.register(at: lastRegister)      // `was`
        lastRegister = r.i
        if let left { onCross?(left) }
    }
}
