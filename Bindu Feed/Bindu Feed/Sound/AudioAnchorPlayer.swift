import Foundation
import AVFoundation
import Combine

// THE AUDIO ANCHOR — Movement IV's kept voice, played back across time. Consciousness
// recognizing itself through an audio anchor point: not a reconstruction of the voice, the
// voice itself, exactly as it was spoken.
//
// The four laws (memory: project-bindu-feed-audio-anchor) live in HOW this plays and how the
// surfaces use it:
//   1 · RAW — this plays the file untouched. No processing, no trimming, no normalization, no
//       rate, no "best take." AVAudioPlayer over the file as recorded. (The recorder writes it
//       raw; nothing here cleans it.)
//   2 · CROSSED-INTO — reached mainly through the Return; the surfaces decide where the
//       affordance lives, never a loud always-on button. This class is only the mechanism.
//   3 · NO CHROME — there is deliberately NO seek/scrub/rate/duration API here. play() and
//       stop(), an isPlaying flag, nothing to build a scrubber from. You cannot fast-forward
//       your own past.
//   4 · HOLD THE SILENCE — on finish the surface is told once (onFinish); it holds the quiet.
//       This class never auto-replays and never chains.
//
// The audio lives LOCALLY (Airtable holds only the filename). We resolve filename → the
// RiteRecorder recordings directory → AVAudioPlayer. An absent file = the affordance is simply
// absent (the surfaces gate on `exists`), never a broken player. Session is left untouched —
// it plays through the app's ambient, silent-switch-honoring session, because the field never
// imposes; a voice you reached for is heard when the phone is willing to sound.
@MainActor
final class AudioAnchorPlayer: NSObject, ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var currentFile: String?      // which anchor is sounding, if any

    private var player: AVAudioPlayer?
    private var onFinish: (() -> Void)?

    /// The on-device URL for a kept-voice filename, or nil if it isn't on this device.
    static func fileURL(for filename: String) -> URL? {
        let url = RiteRecorder.recordingsDirectory().appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    /// True only when there is a real, playable local file — the surfaces gate their affordance
    /// on this, so a missing file shows nothing rather than a dead button.
    static func exists(_ filename: String?) -> Bool {
        guard let f = filename, !f.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        return fileURL(for: f) != nil
    }

    /// Play the kept voice, raw and whole. `onFinish` fires once when it ends (or fails), so the
    /// surface can hold its silence — never called mid-play, never chained into another take.
    func play(_ filename: String, onFinish: @escaping () -> Void) {
        guard let url = Self.fileURL(for: filename) else { onFinish(); return }
        stop()
        do {
            let p = try AVAudioPlayer(contentsOf: url)   // the file, untouched
            p.delegate = self
            p.prepareToPlay()
            p.play()
            player = p
            currentFile = filename
            isPlaying = true
            self.onFinish = onFinish
        } catch {
            #if DEBUG
            print("[AudioAnchorPlayer] play failed: \(error)")
            #endif
            onFinish()
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentFile = nil
        onFinish = nil
    }
}

extension AudioAnchorPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.player = nil
            self.isPlaying = false
            self.currentFile = nil
            let cb = self.onFinish
            self.onFinish = nil
            cb?()      // the surface holds the silence from here
        }
    }
}
