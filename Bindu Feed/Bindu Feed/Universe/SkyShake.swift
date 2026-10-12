import Combine
import CoreMotion
import SwiftUI

// WAVE 4 · THE SHAKE PULSE (Codex C-1311, the euphoria pulse). In the sky, a shake of the phone
// sends one wave out through every star; as it passes each room, that room chimes in its own
// pitch. A body-gesture with nothing to achieve — joy, made audible. No permission is asked
// (accelerometer only); nothing is recorded.
final class SkyShake {
    private let motion = CMMotionManager()
    private var lastFire = Date.distantPast
    var onShake: (() -> Void)?

    func start() {
        guard motion.isAccelerometerAvailable, !motion.isAccelerometerActive else { return }
        motion.accelerometerUpdateInterval = 1.0 / 30
        motion.startAccelerometerUpdates(to: .main) { [weak self] d, _ in
            guard let self, let a = d?.acceleration else { return }
            let g = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
            if g > 2.3, Date().timeIntervalSince(self.lastFire) > 3 {
                self.lastFire = Date()
                self.onShake?()
            }
        }
    }

    func stop() { motion.stopAccelerometerUpdates() }
}

/// The wave itself — one ring of light opening across the sky.
struct SkyWave: View {
    let started: Date
    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSince(started)
            Canvas { ctx, size in
                guard t >= 0, t < 3.4 else { return }
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let r = CGFloat(t / 3.4) * max(size.width, size.height) * 0.9
                let a = 1 - t / 3.4
                ctx.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                           with: .color(Color(hex: "#EDE3CE").opacity(0.35 * a)), lineWidth: 2 + 10 * a)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
