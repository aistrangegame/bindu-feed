import SwiftUI
import Combine
import QuartzCore

// THE UNIVERSE CAMERA — the free 2-D flight camera the design intends (comps/The Universe
// v3.html: `cam={x,y,z,vx,vy,vz}`). Three degrees of freedom over the field of regions:
// PAN (drag, with inertia), ZOOM (pinch, continuous), and TAP-to-fly. The four reading
// scales — sky → region → world → fall — are derived from `zoom` ALONE (bands), NOT from
// the 1-D axis. This is what replaces the welded "scroll up/down" Universe.
//
// Coordinates: `fx,fy` are the focus in the same NORMALISED space UniverseView already uses
// (nx=(wx+490)/980, ny=(wy+1030)/1930), and `zoom` is the existing worldToScreen zoom
// (1.0 = the whole sky … ~4.6 = a world). So the camera feeds the unchanged draw path
// directly: worldToScreen(..., zoom: cam.zoom, focus: CGPoint(cam.fx, cam.fy)).
@MainActor
final class UniverseCamera: ObservableObject {
    @Published private(set) var fx: Double = 0.5
    @Published private(set) var fy: Double = 0.5
    @Published private(set) var zoom: Double = 0.95

    static let ZMIN = 0.72          // whole field visible — the sky
    static let ZMAX = 9.0           // a world filling the frame — the mouth of the fall

    // velocities (inertia)
    private var vfx = 0.0, vfy = 0.0, vz = 0.0
    // fly-to target (tap); nil = not flying
    private var tfx: Double?, tfy: Double?, tzoom: Double?

    private var link: CADisplayLink?
    private final class Proxy: NSObject { let cb: () -> Void; init(_ cb: @escaping () -> Void) { self.cb = cb }; @objc func tick() { cb() } }
    private var proxy: Proxy?

    // The scale a given zoom reads as: 0 sky · 1 region · 2 world · 3 fall (the mouth).
    static func scale(_ zoom: Double) -> Int {
        if zoom < 1.6 { return 0 }
        if zoom < 3.3 { return 1 }
        if zoom < 6.2 { return 2 }
        return 3
    }
    var scale: Int { UniverseCamera.scale(zoom) }

    func reset(fx: Double = 0.5, fy: Double = 0.5, zoom: Double = 0.95) {
        self.fx = fx; self.fy = fy; self.zoom = zoom
        vfx = 0; vfy = 0; vz = 0; tfx = nil; tfy = nil; tzoom = nil
    }

    func start() {
        guard link == nil else { return }
        let p = Proxy { [weak self] in MainActor.assumeIsolated { self?.step() } }
        proxy = p
        let l = CADisplayLink(target: p, selector: #selector(Proxy.tick))
        l.add(to: .main, forMode: .common)
        link = l
    }
    func stop() { link?.invalidate(); link = nil; proxy = nil }

    // MARK: - Input (the hand)

    /// Direct-follow pan during a drag: move the focus so the field tracks the finger.
    /// `dx,dy` are the incremental screen-point deltas since the last change.
    func panBy(_ dx: Double, _ dy: Double, _ size: CGSize) {
        tfx = nil; tfy = nil; tzoom = nil                 // a hand cancels any fly-to
        let W = size.width, H = size.height
        fx -= dx / (W * zoom)
        fy -= dy / (H * zoom)
        clampPan()
    }
    /// On drag end, hand the last velocity to inertia (design: cam.vx = dx/z * 0.55).
    func flingPan(_ dx: Double, _ dy: Double, _ size: CGSize) {
        let W = size.width, H = size.height
        vfx = -dx / (W * zoom) * 0.55
        vfy = -dy / (H * zoom) * 0.55
    }
    /// Pinch: `factor` is the incremental scale since the last change (current/previous).
    func pinchBy(_ factor: Double) {
        tfx = nil; tfy = nil; tzoom = nil
        zoom = max(Self.ZMIN, min(Self.ZMAX, zoom * factor))
    }
    /// Ease the camera toward a point (and optionally a zoom) — tap-to-fly.
    func flyTo(fx: Double, fy: Double, zoom: Double? = nil) {
        tfx = min(1.3, max(-0.3, fx)); tfy = min(1.3, max(-0.3, fy)); tzoom = zoom
        vfx = 0; vfy = 0; vz = 0
    }
    /// A small zoom nudge (tap on empty space draws you inward a touch).
    func nudgeZoom(_ dz: Double) { vz += dz }

    // MARK: - The frame

    private func clampPan() {
        // more room to roam the closer you are; the field lives roughly in [0,1] with overscan
        let span = 0.35 / max(0.4, zoom)
        fx = min(1.0 + span, max(-span, fx))
        fy = min(1.0 + span, max(-span, fy))
    }

    private func step() {
        if let tx = tfx, let ty = tfy {                   // flying (tap-to-fly): ease in
            fx += (tx - fx) * 0.12
            fy += (ty - fy) * 0.12
            if let tz = tzoom { zoom += (tz - zoom) * 0.10 }
            if abs(tx - fx) < 0.001 && abs(ty - fy) < 0.001 { tfx = nil; tfy = nil; tzoom = nil }
        } else {                                          // inertia + friction
            fx += vfx; fy += vfy
            vfx *= 0.92; vfy *= 0.92
            zoom *= (1 + vz); vz *= 0.90
            if vz > 0.10 { vz = 0.10 }; if vz < -0.10 { vz = -0.10 }
        }
        zoom = max(Self.ZMIN, min(Self.ZMAX, zoom))
        clampPan()
    }
}
