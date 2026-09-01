import Testing
import Foundation
@testable import Bindu_Feed

// E1.17 · the Light's type scale — `The Light v2.html:826-853`, `:30`.
//
// **THE ROW WAS FILED AS "sizes/weights/inks differ" AND ONE OF THE DIFFERENCES IS NOT A
// SIZE.** The whole is not set at a size; it TRAVELS between two, and the travel is how the
// register says the opening has been received. A test that pinned "the whole is 21" would
// pass on a build that never settles, so the assertions below are about the movement and
// about the direction of it.
@Suite struct LightTypeTests {

    // MARK: - the relationship, not the outcome

    @Test("the whole shrinks as the anchors take over, and never grows")
    func theWholeSettles() {
        // `:827` — `fontSize: phase==='whole' ? 21 : 15`, transitioned over 2.6s. The app held
        // a fixed 19: between the two, so it read as neither the only thing on the floor nor
        // a heading over the anchors, and nothing happened when the first anchor landed.
        #expect(LightType.wholeSize(alone: true) == 21)
        #expect(LightType.wholeSize(alone: false) == 15)
        #expect(LightType.wholeSize(alone: false) < LightType.wholeSize(alone: true),
                "the whole grew as it was received — the settle runs backwards")
    }

    @Test("the line opens as the size falls — the two move opposite ways")
    func theLeadingCompensates() {
        // `lineHeight` goes 1.5 → 1.6 while the size goes 21 → 15. The smaller type is set
        // LOOSER in proportion, which is what keeps a demoted paragraph readable instead of
        // merely small. Porting the size without the line-height gives a cramped block that
        // looks like a bug nobody can name.
        let aloneRatio = (LightType.wholeSize(alone: true) + LightType.wholeLeading(alone: true))
            / LightType.wholeSize(alone: true)
        let settledRatio = (LightType.wholeSize(alone: false) + LightType.wholeLeading(alone: false))
            / LightType.wholeSize(alone: false)
        #expect(abs(aloneRatio - 1.5) < 1e-6)
        #expect(abs(settledRatio - 1.6) < 1e-6)
        #expect(settledRatio > aloneRatio, "the smaller setting was not given the looser line")
    }

    @Test("the whole holds its place until it is received, then opens a gap")
    func theGapArrivesWithTheAnchors() {
        // `:824` — `marginBottom: phase==='whole' ? 0 : 18`.
        #expect(LightType.wholeGap(alone: true) == 0)
        #expect(LightType.wholeGap(alone: false) == 18)
    }

    @Test("the Declaration takes back the opening's own size")
    func theBeatIsTheWholesArrivalSize() {
        // `:841` — 21, the same number the whole ARRIVES at and then gives up. The Declaration
        // is not bigger than the opening; it is the opening's size returning after the anchors
        // have shrunk it, which is why a `beatSize` of 17 (what shipped) flattened the register
        // into one voice getting quieter.
        #expect(LightType.beatSize == LightType.wholeSize(alone: true))
        #expect(LightType.beatSize > LightType.anchorSize)
        #expect(LightType.anchorSize > LightType.wholeSize(alone: false),
                "an anchor must sit above the settled whole, not level with it")
    }

    @Test("the tracking is proportional, so it survives a size change")
    func theTrackingIsInEm() {
        // `-0.014em` and `-0.012em`. Ported as fixed points they would be right at one size
        // and wrong at the other — and the whole has two sizes, so a fixed value cannot be
        // correct in both places it appears.
        #expect(abs(LightType.wholeTracking(alone: true) / LightType.wholeSize(alone: true)
                    - LightType.wholeTracking(alone: false) / LightType.wholeSize(alone: false)) < 1e-9)
        #expect(LightType.wholeTracking(alone: true) < 0, "the tracking must be tight, not open")
        #expect(abs(LightType.beatTracking / LightType.beatSize + 0.012) < 1e-9)
        // The Declaration is tracked slightly LOOSER than the whole — 0.012 against 0.014 —
        // because it is cut into the floor and a groove needs the room.
        #expect(abs(LightType.beatTracking) < abs(LightType.wholeTracking(alone: true)))
    }

    @Test("the landing is the largest settled thing on the floor")
    func theLanding() {
        // `:853` — 18/1.6 italic. The app set it at 13, the size of a caption, so the line the
        // register leaves him with read as a footnote under the vow.
        #expect(LightType.landingSize == 18)
        #expect(LightType.landingSize > LightType.wholeSize(alone: false))
        #expect(LightType.landingSize < LightType.beatSize, "the landing must not rival the vow")
        #expect(abs((LightType.landingSize + LightType.landingLeading) / LightType.landingSize - 1.6) < 1e-6)
    }

    @Test("the gaps widen as the lines get heavier — except at the vow")
    func theRhythm() {
        // 6 between the whole's own lines, 14 under an anchor, 11 between Declarations. The
        // Declaration's gap is TIGHTER than the anchors' even though its type is larger,
        // because the lines of a vow belong together and the anchors arrive one at a time.
        #expect(LightType.anchorGap == 14)
        #expect(LightType.beatGap == 11)
        #expect(LightType.beatGap < LightType.anchorGap,
                "the Declaration was spaced out like a list of separate arrivals")
    }

    // MARK: - green on absent

    @Test("every measure is positive and the leadings are real gaps")
    func nothingIsZeroByAccident() {
        for v in [LightType.anchorSize, LightType.anchorLeading, LightType.beatSize,
                  LightType.beatLeading, LightType.landingSize, LightType.landingLeading,
                  LightType.wholeLeading(alone: true), LightType.wholeLeading(alone: false)] {
            #expect(v > 0, "a measure came through as \(v)")
        }
    }
}
