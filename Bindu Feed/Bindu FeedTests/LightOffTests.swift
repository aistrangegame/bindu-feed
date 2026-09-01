import Testing
import Foundation
import AVFoundation
@testable import Bindu_Feed

// `lightOff` / `closeTheRoom` — `field-sound.js:307-312` and `The Light v2.html:283-288`.
// A way to put the Light's room tone out.
@Suite struct LightOffTests {

    /// The Light's room tone as `lightRoomTone()` builds it: `sineOctave`, 6s in, 40s out.
    static func roomTone() -> CeremonyVoice {
        CeremonyVoice(hz: 528, peak: 0.012, attackSeconds: 6,
                      releaseSeconds: 40, synth: .sineOctave)
    }

    // MARK: - the relationship, not the outcome

    @Test("the room can be put out before its own release runs")
    func fadeEndsItEarly() throws {
        // THE CLAIM. "The tone eventually stops" is true of the version with no `lightOff` at
        // all — it stops after 40 seconds, in whatever register the user has walked into.
        // `_mechverdicts1.md`: *"It runs to its own 40s release wherever the user goes."*
        // What this mechanism claims is that LEAVING ends it, so the assertion is about the
        // difference between a tone left alone and the same tone told to go.
        let left = Self.roomTone()
        let alone = try OfflineRender.render(left.sourceNode, seconds: 12.0)
        let stillThere = alone.peak(from: 10.0, to: 12.0)
        #expect(stillThere > 1e-5,
                "the tone was already gone at 10s, so this test proves nothing: \(stillThere)")

        let closed = Self.roomTone()
        closed.fadeOut(seconds: 6)
        let gone = try OfflineRender.render(closed.sourceNode, seconds: 12.0)
        let after = gone.peak(from: 8.0, to: 12.0)
        #expect(after < stillThere * 0.02,
                "the room did not close: \(after) against \(stillThere) left alone")
    }

    @Test("the fade takes its own duration and does not cut")
    func itRampsRatherThanStopping() throws {
        // `linearRampToValueAtTime(0, t + dur)`, not a stop. A cut is a click, and the whole
        // register is about leaving quietly. Measured as presence partway through: at half
        // the fade the tone must still be there.
        let v = Self.roomTone()
        v.fadeOut(seconds: 6)
        let r = try OfflineRender.render(v.sourceNode, seconds: 8.0)

        let midway = r.peak(from: 2.5, to: 3.5)
        #expect(midway > 1e-5, "the fade cut instead of ramping: \(midway)")
        let ended = r.peak(from: 6.5, to: 8.0)
        #expect(ended < midway * 0.05, "the fade never finished: \(ended) vs \(midway)")
    }

    @Test("a second leave cannot shorten the fade into a click")
    func fadeIsIdempotent() throws {
        // A register can be left twice — the button, then the view disappearing — and the
        // second call must not restart a shorter ramp over an already-quieter tone. This is
        // the claim-release discipline §10 records: every exit calls the same release, so
        // the release has to tolerate being called by all of them.
        let once = Self.roomTone()
        once.fadeOut(seconds: 6)
        let a = try OfflineRender.render(once.sourceNode, seconds: 8.0)

        let twice = Self.roomTone()
        twice.fadeOut(seconds: 6)
        twice.fadeOut(seconds: 0.05)      // a second, much shorter leave
        let b = try OfflineRender.render(twice.sourceNode, seconds: 8.0)

        // THE GUARD THAT MAKES THIS NON-VACUOUS. With `fadeOut` a no-op, both renders are
        // identical and this test passes having proved nothing — confirmed by running it
        // that way. So first establish that a fade is actually happening, by comparing
        // against a voice that was never asked to close.
        let never = Self.roomTone()
        let n = try OfflineRender.render(never.sourceNode, seconds: 8.0)
        let nm = n.peak(from: 2.5, to: 3.5)

        let am = a.peak(from: 2.5, to: 3.5), bm = b.peak(from: 2.5, to: 3.5)
        #expect(am < nm * 0.9, "no fade is under way, so idempotence is untested: \(am) vs \(nm)")
        #expect(abs(am - bm) / am < 0.02,
                "the second leave changed the fade: \(bm) against \(am)")
    }

    @Test("an unclosed room is unaffected, so the fade is the thing being measured")
    func noFadeMeansNoChange() throws {
        // Green-on-absent, inside the suite: the same voice with no `fadeOut` must behave as
        // the engine's ordinary one-shot. Without this, every assertion above could be
        // passing on something else in the voice.
        let v = Self.roomTone()
        let r = try OfflineRender.render(v.sourceNode, seconds: 12.0)
        #expect(r.peak(from: 10.0, to: 12.0) > 1e-5, "an untouched room tone stopped on its own")
    }
}
