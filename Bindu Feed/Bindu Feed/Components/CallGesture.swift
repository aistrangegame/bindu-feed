import SwiftUI
import UIKit

// WAVE 1 · THE CALL, FROM ANYWHERE — two fingers held still for a moment, on any surface.
// Installed on the WINDOW, not a view, so it reaches every layer the app ever stacks; it never
// cancels the touches under it and recognises alongside everything else, so no surface loses a
// gesture to it. One finger can never raise it, which keeps it from ever arriving by accident.
struct CallGestureInstaller: UIViewRepresentable {
    let onCall: () -> Void

    static let fingers = 2
    static let hold: TimeInterval = 0.8

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
            coordinator.recognizer.view?.removeGestureRecognizer(coordinator.recognizer)
            window.addGestureRecognizer(coordinator.recognizer)
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onCall: () -> Void
        let recognizer = UILongPressGestureRecognizer()

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
        }

        @objc private func fire(_ r: UILongPressGestureRecognizer) {
            if r.state == .began { onCall() }
        }

        func gestureRecognizer(_ g: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
    }
}
