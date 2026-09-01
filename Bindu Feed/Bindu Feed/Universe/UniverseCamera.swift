import SwiftUI
import Combine
import QuartzCore

// THE UNIVERSE CAMERA.
//
// What changed at the seam, and why.
//
// The Universe used to carry its own independent `zoom`, driven by pinch, while the axis
// carried `Z`. Two scales for one space — so the axis had to be LOCKED whenever the
// Universe was up (`axisLocked`), and that lock is what made the four Universe registers
// mutually unreachable, opened a dead band at the Feed edge, and froze the shader's `uZ`.
// (`B0.1`–`B0.3`.)
//
// The design never had two. Inside the axis the Universe's scale IS Z:
//
//     spine-axis.js:75   rim(i, Z, R0) = R0 · 2^((Z+5) − i)
//     uni-deep.js:123+   every shell is drawn at S.rim(…) and faded by S.presence(…)
//
// and the standalone page's `cam.z` (The Universe v3.html:1463, ZMIN .22 → ZMAX 34) is
// that same scale under another name. So `zoom` is now DERIVED from the axis, by the
// log-interpolation the design uses wherever a scale is walked (point-yantra.js:48-53,
// "the walk is a change of place, not of scale"). Nothing mutates it directly.
//
// The hand then splits the way the design splits it (The Instrument v3.html:5906-5926):
//
//     vertical   → walks the axis        (and therefore the scale)
//     horizontal → the register's own gesture — here, flight across the sky
//
// Coordinates: `fx,fy` are the focus in the same NORMALISED space UniverseView uses
// (nx=(wx+490)/980, ny=(wy+1030)/1930), so the draw path is fed unchanged.
@MainActor
final class UniverseCamera: ObservableObject {
    // STATUS(2026-08-29): THE WORLD'S TURN — `uni-deep.js:250-303`. **BUILT.**
    // `UniverseView:703` carries it — three faces at TAU/3. This line read "and it was
    // never built" after it had been, while the view's own comment said "never built until
    // now": two comments in one build disagreeing about the same mechanism, and the stale
    // one sitting on the file a reader opens first.
    //
    // `The Instrument v3.html:5906-5926` gives the law: the vertical always walks the axis,
    // and the horizontal is the register's own gesture — `else if(|Z+2|<0.75) turnV += dx*0.0016`.
    // At the world register that gesture turns the body: three faces at TAU/3 each, the story,
    // then who sat with it, then how often he came back. It "keeps the turn" — there is no
    // spring home, only friction.
    //
    // Nothing in the app read `turnV`, because nothing wrote it. The horizontal at the world
    // register did nothing at all, and the three faces the design authored — including the
    // company's glyphs and the depth rings — have never been on screen.
    @Published private(set) var turn: Double = 0
    private var turnV: Double = 0

    func turnBy(_ dx: Double) { turnV += dx * 0.0016 }
    func stepTurn(_ dt: Double) {
        turn += turnV
        turnV *= pow(0.94, dt * 60)          // it keeps the turn; friction only
        if abs(turnV) < 0.00002 { turnV = 0 }
    }

    @Published private(set) var fx: Double = 0.5
    @Published private(set) var fy: Double = 0.5
    /// Derived from the axis. Never set by a gesture — see `setAxisZ`.
    @Published private(set) var zoom: Double = ZMIN

    /// The design's own range (The Universe v3.html:1463) — 154:1, not the 12:1 that was
    /// here. The span is what lets a star grow continuously from a 2px point into a planet
    /// without a mode switch; at 12:1 the world scale lives in the last 30% and the code
    /// needed hard cuts to reach it.
    static let ZMIN = 0.22
    static let ZMAX = 34.0

    /// The four Universe registers, as axis Z.
    static let axisZFar: Double = -4      // the sky
    static let axisZNear: Double = -1     // the fall

    // ── THE FALL ────────────────────────────────────────────────────────────────────────
    // Its own descent, with its own momentum. `desc` is 0…1 through the four layers and is
    // NOT derived from zoom: `The Universe v3.html:1621` — "in the fall, pulling up is
    // descending" — `descV += (-dy) * 0.00042`, damped 0.935, with a lateral drift at 0.0022
    // damped 0.93 that parallaxes the strata.
    @Published private(set) var desc: Double = 0
    @Published private(set) var driftX: Double = 0
    @Published private(set) var driftY: Double = 0
    /// The consent ring at the mouth, 0…1. It closes ONLY while the hand keeps asking and
    /// stops the instant he stops. `B5.3`.
    @Published private(set) var mouthPull: Double = 0
    /// Set true the frame the ring completes. The host reads it once and crosses.
    @Published private(set) var mouthMeant = false

    private var descV = 0.0
    private var asking = false
    private var inFall = false

    /// The mouth is open — `uni-fall.js:24`, `mouth = seg(0.84, 0.96)`.
    var atMouth: Bool { desc >= 0.84 }

    /// B5.8 · `fall` — `The Universe v3.html:1506` ramps `+0.011` per frame while the camera
    /// flies to the star, and `:895` derives `enter = min(1, fall)` from it. The app read
    /// `enter` off the DESCENT depth (`d/0.3`), which is a different quantity entirely: the
    /// descent is what he does after arriving, and `enter` is the arriving. So the company
    /// faded in as he went DOWN rather than as he came IN, and a star opened at full descent
    /// showed a gathering already seated.
    private(set) var fall: Double = 0

    func setInFall(_ v: Bool) {
        inFall = v
        if v { fall = 0 }
        if !v { desc = 0; descV = 0; driftX = 0; driftY = 0; mouthPull = 0; mouthMeant = false; asking = false }
    }

    /// The descent gesture. Pulling UP descends.
    func descendBy(dx: Double, dy: Double) {
        descV += (-dy) * 0.00042
        driftX += dx * 0.0022
        driftY += dy * 0.0022
        asking = true
    }

    /// The hand let go. The ring stops closing; it does not reset, and it does not fire.
    func stopAsking() { asking = false }

    func clearMouthMeant() { mouthMeant = false }

    /// Reported to the axis when the pan inertia starts or stops — the `|turnV| < 0.001`
    /// term of the design's `still` (`The Instrument v3.html:5518`). The stillness gate has
    /// to know that the register's OWN gesture has come to rest too, not just the axis's.
    /// Fires only on a change, never per frame.
    var onDriftChange: ((Bool) -> Void)?
    private var drifting = false

    // Pan velocity (inertia). No `vz` — the scale is not a thing the hand throws here.
    private var vfx = 0.0, vfy = 0.0
    private var tfx: Double?, tfy: Double?

    private var lastTime: CFTimeInterval = 0
    private var link: CADisplayLink?
    private final class Proxy: NSObject { let cb: () -> Void; init(_ cb: @escaping () -> Void) { self.cb = cb }; @objc func tick() { cb() } }
    private var proxy: Proxy?

    // MARK: - The scale, derived

    /// Log-interpolate ZMIN…ZMAX across the four Universe registers. Equal travel in Z is
    /// equal *perceived* travel in scale, which is the property `scale()` in point-yantra.js
    /// exists to guarantee.
    static func zoom(forAxisZ z: Double) -> Double {
        let t = max(0, min(1, (z - axisZFar) / (axisZNear - axisZFar)))
        return ZMIN * pow(ZMAX / ZMIN, t)
    }

    /// Called every frame by the host with the live axis Z. This is the only writer of `zoom`.
    func setAxisZ(_ z: Double) {
        let target = Self.zoom(forAxisZ: z)
        if abs(target - zoom) > 1e-9 { zoom = target }
    }

    /// The overlapping reading bands — `uni-sky.js:18-23`, verbatim.
    ///
    /// These are the whole answer to `B2.1`. They OVERLAP by construction: sky∩region across
    /// z 0.45–1.05, region∩world across 2.6–5.4. There is no z at which exactly one is lit,
    /// so there is nothing to switch between and no renderer to swap.
    struct Bands { let sky: Double, region: Double, world: Double }
    static func bands(_ z: Double) -> Bands {
        func cl(_ a: Double, _ b: Double, _ x: Double) -> Double { max(0, min(1, (x - a) / (b - a))) }
        return Bands(
            sky:    1 - cl(0.55, 1.05, z),
            region: cl(0.45, 0.95, z) * (1 - cl(3.2, 5.4, z)),
            world:  cl(2.6, 4.6, z)
        )
    }
    var bands: Bands { Self.bands(zoom) }

    /// A NAME for where he is, for wayfinding only — never a mode, never a branch in the
    /// draw path. `The Universe v3.html:1531` computes it from the same continuous bands.
    var scaleName: String {
        let b = bands
        return b.world > 0.55 ? "world" : (b.region > 0.5 ? "region" : "sky")
    }

    func reset(fx: Double = 0.5, fy: Double = 0.5) {
        self.fx = fx; self.fy = fy
        vfx = 0; vfy = 0; tfx = nil; tfy = nil
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

    /// Direct-follow pan during a drag. `dx,dy` are incremental screen-point deltas.
    ///
    /// Velocity is now sampled HERE, on every move — `cam.vx = dx/cam.z * 0.55`
    /// (The Universe v3.html:1619) — not once at the end from a predicted-end delta. A
    /// projection is not a velocity: it made a slow drag that stopped dead still throw, and
    /// a fast flick that decelerated not throw at all.
    func panBy(_ dx: Double, _ dy: Double, _ size: CGSize) {
        tfx = nil; tfy = nil
        let W = size.width, H = size.height
        fx -= dx / (W * zoom)
        fy -= dy / (H * zoom)
        vfx = -dx / (W * zoom) * 0.55
        vfy = -dy / (H * zoom) * 0.55
        clampPan()
    }

    /// The hand let go — inertia is already loaded by the last `panBy`.
    func endPan() { tfx = nil; tfy = nil }

    /// Tap-to-fly. The design does NOT ease to a fitted zoom (`uni-sky.js:1033` — "nothing
    /// snaps, nothing zooms to fit"); it recentres by a fixed FRACTION, instantly, and hands
    /// the scale a small impulse. The impulse is the axis's to take — see `onDrawIn`.
    func recentre(fx tx: Double, fy ty: Double, fraction: Double) {
        tfx = nil; tfy = nil
        vfx = 0; vfy = 0
        fx += (tx - fx) * fraction
        fy += (ty - fy) * fraction
        clampPan()
    }

    // MARK: - The frame

    private func clampPan() {
        // `span = 520/max(.3, z)` in the design's world units (The Universe v3.html:1501);
        // normalised here against the 980-unit field width.
        let span = (520.0 / max(0.3, zoom)) / 980.0
        fx = min(1.0 + span, max(-span, fx))
        fy = min(1.0 + span, max(-span, fy))
    }

    private func step() {
        // `:1506` — the flight's own clock, independent of the descent that follows it.
        if inFall && fall < 1 { fall = min(1, fall + 0.011) }
        let now = CACurrentMediaTime()
        var dt = now - lastTime
        lastTime = now
        guard dt > 0 else { return }
        dt = min(dt, 1.0 / 30.0)
        stepTurn(dt)
        let f = dt * 60.0

        if let tx = tfx, let ty = tfy {
            fx += (tx - fx) * (1 - pow(1 - 0.12, f))
            fy += (ty - fy) * (1 - pow(1 - 0.12, f))
            if abs(tx - fx) < 0.001 && abs(ty - fy) < 0.001 { tfx = nil; tfy = nil }
        } else {
            fx += vfx * f
            fy += vfy * f
            // 0.945/frame, the design's (:1497). It was 0.92 — a third shorter — and applied
            // per-tick with no dt, so a ProMotion 120Hz device decayed it in half the time
            // and threw twice as far. `AxisTravel` has always done this correctly.
            let d = pow(0.945, f)
            vfx *= d; vfy *= d
        }
        clampPan()

        // the register's own motion, for the stillness gate — coasting is not stillness
        let nowDrifting = tfx != nil || abs(vfx) > 6e-5 || abs(vfy) > 6e-5
        if nowDrifting != drifting { drifting = nowDrifting; onDriftChange?(nowDrifting) }

        // ── the fall's own integration ──
        if inFall {
            desc = max(0, min(1, desc + descV * f))
            descV *= pow(0.935, f)
            driftX *= pow(0.93, f)
            driftY *= pow(0.93, f)

            // Consent. It closes over ~1.4s of continuing to ask, and falls back over ~0.7s
            // the moment he stops. Nothing here fires on its own.
            if atMouth && asking {
                mouthPull = min(1, mouthPull + dt / 1.4)
                if mouthPull >= 1 && !mouthMeant { mouthMeant = true }
            } else {
                mouthPull = max(0, mouthPull - dt / 0.7)
            }
        }
    }
}
