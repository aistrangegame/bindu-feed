import Foundation
import Testing
@testable import Bindu_Feed

// B2 · THE MUTE
//
// `field-sound.js:31,88-89,327` — `muted`, `setMuted(m)`, `setOn(v)`. The app shipped with
// none of them: no engine call, no control in Settings, no way to stop a continuous bed
// that starts on launch. A shipping defect independent of everything else in the layer.
//
// The FADE itself (1.4s on `mainMixerNode.outputVolume`) needs a running engine and is
// verified by reading; what is checkable here is the state, its persistence, and that a
// muted launch is muted before the first buffer.
@Suite("B2 · the mute")
@MainActor
struct SoundMuteTests {

    @Test("setMuted and setOn are inverses, and the state follows")
    func toggling() {
        let d = UserDefaults.standard
        let restore = d.bool(forKey: SoundMuteKey)
        defer { d.set(restore, forKey: SoundMuteKey) }

        d.set(false, forKey: SoundMuteKey)
        let e = SoundEngine()
        #expect(e.isMuted == false)

        e.setMuted(true)
        #expect(e.isMuted == true)
        #expect(d.bool(forKey: SoundMuteKey) == true, "a mute must survive the launch")

        e.setOn(true)
        #expect(e.isMuted == false)
        e.setOn(false)
        #expect(e.isMuted == true)
    }

    @Test("a muted launch starts muted")
    func mutedLaunchIsMuted() {
        let d = UserDefaults.standard
        let restore = d.bool(forKey: SoundMuteKey)
        defer { d.set(restore, forKey: SoundMuteKey) }

        d.set(true, forKey: SoundMuteKey)
        #expect(SoundEngine().isMuted == true)
        d.set(false, forKey: SoundMuteKey)
        #expect(SoundEngine().isMuted == false)
    }
}
