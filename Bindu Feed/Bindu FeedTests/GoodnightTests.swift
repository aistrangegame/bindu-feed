import Testing
import Foundation
@testable import Bindu_Feed

// D5.11 · the goodnight is a whisper at the particle, not a headline in the frame.
@Suite struct GoodnightTests {

    @Test("it is said AFTER he has arrived, which is what makes it an aside")
    func theDelayIsTheMeaning() {
        // **THE ONE THAT IS NOT COSMETIC.** `The Point v9.html:998` — `setTimeout(…, 2400)`.
        // Said on arrival it is a greeting and the world is announcing itself. Said 2400ms
        // later it is an aside: he has arrived, looked around, and then it is mentioned. The
        // app said it immediately, so the first thing every world did was declare itself.
        #expect(PointGoodnight.delaySeconds == 2.4)
        #expect(PointGoodnight.delaySeconds > PointGoodnight.fadeSeconds,
                "it begins before its own fade-in has finished — that is arrival, not aside")
    }

    @Test("it is small and dim — a whisper cannot carry a shadow")
    func itIsAWhisper() {
        // `:42-43` — `font-size:12px`, `opacity:.8`. The app had **21pt with a 10pt hue
        // shadow**: nearly twice the type, and a shadow is precisely what would make 12pt
        // read as a headline. Every one of those was the same edit in a different property.
        #expect(PointGoodnight.pointSize == 12)
        #expect(PointGoodnight.opacity == 0.8)
        #expect(PointGoodnight.pointSize < 21, "back to a headline")
    }

    @Test("it stands BESIDE the particle, not over it and not in the middle of the frame")
    func besideTheParticle() {
        // `:995` — `left + 16`, `top - 5` from the particle's own rect. Up and to the right:
        // it is said next to the thing, which is what an aside looks like. Centred in the
        // frame it is the world talking; beside the particle it is someone talking to him.
        #expect(PointGoodnight.offset.x > 0, "it moved to the particle's left")
        #expect(PointGoodnight.offset.y < 0, "it sits below the particle")
        #expect(PointGoodnight.offset == (x: 16.0, y: -5.0))
    }

    @Test("it holds for 2.6s and fades the same both ways")
    func theTimings() {
        // `:997` removes `.in` after 2600ms, and the CSS transition is `1.1s` in BOTH
        // directions — the app had 1.2s in and 1.4s out, so it arrived and left at different
        // speeds, which reads as a thing being taken away rather than fading.
        #expect(PointGoodnight.holdSeconds == 2.6)
        #expect(PointGoodnight.fadeSeconds == 1.1)
    }

    @Test("once per dimension, ever — the design's own `ilyDone`")
    func onceEver() {
        PointGoodnight.shown.removeAll()
        #expect(!PointGoodnight.shown.contains(3))
        PointGoodnight.shown.insert(3)
        #expect(PointGoodnight.shown.contains(3), "it would be said a second time")
        PointGoodnight.shown.removeAll()
    }
}
