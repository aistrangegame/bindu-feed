import Combine
import SwiftUI
import UIKit
import UIKit.UIGestureRecognizerSubclass

// WAVE 1 · THE CALL, FROM ANYWHERE — two fingers held still for a moment, on any surface.
// Installed on the WINDOW, not a view, so it reaches every layer the app ever stacks; it never
// cancels the touches under it and recognises alongside everything else, so no surface loses a
// gesture to it. One finger can never raise it, which keeps it from ever arriving by accident.
struct CallGestureInstaller: UIViewRepresentable {
    let onCall: () -> Void

    static let fingers = 2
    static let hold: TimeInterval = 0.8
    /// THE REST · two fingers swept to the right — the Gaia inversion (a story run back to its memo).
    static let twoFingerBack = Notification.Name("bindu.twoFingerBack")

    func makeCoordinator() -> Coordinator { Coordinator(onCall: onCall) }

    func makeUIView(context: Context) -> UIView {
        let v = InstallView()
        v.isUserInteractionEnabled = false
        v.coordinator = context.coordinator
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onCall = onCall
    }

    final class InstallView: UIView {
        weak var coordinator: Coordinator?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard let window, let coordinator, coordinator.recognizer.view !== window else { return }
            for r in [coordinator.recognizer, coordinator.swipe, coordinator.touch] as [UIGestureRecognizer] {
                r.view?.removeGestureRecognizer(r)
                window.addGestureRecognizer(r)
            }
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onCall: () -> Void
        let recognizer = UILongPressGestureRecognizer()
        let swipe = UISwipeGestureRecognizer()
        let touch = TouchSense()

        init(onCall: @escaping () -> Void) {
            self.onCall = onCall
            super.init()
            recognizer.numberOfTouchesRequired = CallGestureInstaller.fingers
            recognizer.minimumPressDuration = CallGestureInstaller.hold
            recognizer.allowableMovement = 24
            recognizer.cancelsTouchesInView = false
            recognizer.delaysTouchesBegan = false
            recognizer.delegate = self
            recognizer.addTarget(self, action: #selector(fire(_:)))
            swipe.numberOfTouchesRequired = 2
            swipe.direction = .right
            swipe.cancelsTouchesInView = false
            swipe.delegate = self
            swipe.addTarget(self, action: #selector(back(_:)))
            touch.delegate = self
        }

        @objc private func back(_ r: UISwipeGestureRecognizer) {
            NotificationCenter.default.post(name: CallGestureInstaller.twoFingerBack, object: nil)
        }

        @objc private func fire(_ r: UILongPressGestureRecognizer) {
            if r.state == .began { onCall() }
        }

        func gestureRecognizer(_ g: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
    }
}


/// THE REST · how the hand is resting on the glass, app-wide — contact size (and force where the
/// screen has it) and how far apart two fingers are. Never recognises, never cancels a touch;
/// it only listens, for the Light's scenes that are about pressure and reach (722 · 743 · 724).
final class TouchSense: UIGestureRecognizer {
    static var radius: CGFloat = 0          // the largest contact, in points
    static var force: CGFloat = -1          // 0…1 where the screen measures force, else -1
    static var spread: CGFloat = 0          // distance between two touches, in points
    static var touching = false
    static var lastTouch = Date()           // the last moment any finger was on the glass

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
    }
    convenience init() { self.init(target: nil, action: nil) }

    private var live: Set<UITouch> = []

    private func read() {
        TouchSense.touching = !live.isEmpty
        TouchSense.lastTouch = Date()
        TouchSense.radius = live.map(\.majorRadius).max() ?? 0
        if let t = live.first, t.maximumPossibleForce > 0 {
            TouchSense.force = t.force / t.maximumPossibleForce
        } else {
            TouchSense.force = -1
        }
        let pts = live.compactMap { t in t.window.map { t.location(in: $0) } }
        TouchSense.spread = pts.count >= 2 ? hypot(pts[0].x - pts[1].x, pts[0].y - pts[1].y) : 0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) { live.formUnion(touches); read() }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) { read() }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) { live.subtract(touches); read(); if live.isEmpty { state = .failed } }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) { live.subtract(touches); read(); if live.isEmpty { state = .failed } }
    override func reset() { live.removeAll(); read() }
}
