import SwiftUI
import QuartzCore
import Combine

// THE HAND, IN A ROOM — `The Rooms v4.html:835, 917-1004, 1077-1099`.
//
//   the vertical walks the four registers · the horizontal is the voice's own
//
// The same law the instrument's axis obeys, at a different scale. Two things are load
// bearing and both are easy to lose:
//
//  · ONE GESTURE IS ONE REGISTER. `anchor = round(D)` is taken on touch-down, and D is
//    clamped to `anchor ± 1` for the life of that gesture. A long fast swipe therefore
//    advances exactly one register, and a flick cannot skip past two. Release glides to
//    the register reached — `D += (round(D) − D) * 0.14` — never past it.
//  · |lat| ≤ 1 IS THE FULL RANGE. Not a coordinate that keeps going: one swipe reaches
//    each voice's whole intended range, and no swipe goes beyond it. The end is a
//    rubber-band, not a wall.
//
// Frame-rate independent: every damping term is `pow(base, dt·60)`, so ProMotion 120 and
// 60 feel identical. The comp could assume 60; a phone cannot.
@MainActor
final class RoomTravel: ObservableObject {
    /// 0…3 — met · the figure · what it has said · the turn.
    @Published private(set) var d: Double = 0
    /// −1…1 (rubber-banding to ±1.10) — the voice's own gesture.
    @Published private(set) var lat: Double = 0

    /// `PER` — 240px is one register. `The Rooms v4.html:835`.
    private let per = 240.0
    private var latV = 0.0
    private var anchor = 0.0
    private var down = false
    /// Shweta's is the one range that does not spring home: pulled to the end it STAYS at
    /// *nothing between them*, because that is a place you are allowed to leave her room
    /// standing in. `:1005` — `if(!down && who!=='shweta') lat *= 0.965`.
    private var holdsLat = false

    private var lastTime: CFTimeInterval = 0
    private var link: CADisplayLink?
    private final class Proxy: NSObject {
        let cb: () -> Void
        init(_ cb: @escaping () -> Void) { self.cb = cb }
        @objc func tick() { cb() }
    }
    private var proxy: Proxy?

    func configure(holdsLat: Bool) { self.holdsLat = holdsLat }

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

    // MARK: - the hand

    func begin() {
        down = true
        anchor = d.rounded()
    }

    /// `dx`/`dy` are incremental deltas ALREADY normalised to the design's 393pt frame, so
    /// a gesture means the same thing on every screen size (`C2.8`).
    func drag(dx: Double, dy: Double) {
        // one owner per event — the instrument's law, at :1085
        if abs(dx) > abs(dy) {
            latV += dx * (holdsLat ? 0.00055 : 0.00080)
        } else {
            let next = d + dy / per
            d = min(max(next, anchor - 1), anchor + 1)
            d = min(max(d, 0), 3)
        }
    }

    func end() { down = false }

    private func step() {
        let now = CACurrentMediaTime()
        var dt = now - lastTime
        lastTime = now
        guard dt > 0 else { return }
        dt = min(dt, 1.0 / 30.0)
        let f = dt * 60.0

        lat += latV * f
        latV *= pow(0.91, f)
        // the rubber band — the range REACHES its own end, it is not stopped short of it
        if abs(lat) > 1 {
            lat = (lat < 0 ? -1 : 1) * min(1.10, 1 + (abs(lat) - 1) * 0.34)
            latV *= pow(0.42, f)
        }
        if !down {
            let s = d.rounded()
            d += (s - d) * (1 - pow(1 - 0.14, f))
            if abs(s - d) < 0.002 { d = s }
            if !holdsLat { lat *= pow(0.965, f) }
        }
    }
}
