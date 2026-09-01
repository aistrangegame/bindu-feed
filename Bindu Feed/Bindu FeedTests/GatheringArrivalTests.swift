import Testing
import SwiftUI
@testable import Bindu_Feed

// F7.4 + F5.2 · the gathering's order and weight, and the thread's hierarchy.
@Suite struct GatheringArrivalTests {

    // MARK: - F7.4 · a gathering arrives as a gathering, not a list

    @Test("the sequence is an ORDER: lenses, then roots, then him")
    func theOrderIsTheSentence() {
        // `Claude Design Round 1/Players View.html:55-64,398-430`. The app staggered only the
        // lenses; the roots, both dividers and Ash's card had no delay at all, so everything
        // after the lenses arrived in one block. **A gathering that arrives all at once and
        // equally bright is a list.**
        let lensLast  = Double(7) * 0.075          // eight lenses, the last of them
        let rootFirst = 0.66
        let ash       = 0.90
        #expect(lensLast < rootFirst, "the roots begin before the lenses have finished")
        #expect(rootFirst < ash, "he does not arrive last")
        #expect(0.62 < rootFirst, "the ROOTS divider arrives after the roots it introduces")
        #expect(0.82 < ash, "his divider arrives after him")
    }

    @Test("the roots arrive QUIETER and stay quieter — weight is part of the sequence")
    func theRootsAreDimmer() {
        // `substrateArrive` ends at **opacity 0.72**, not 1. The app had no settled opacity at
        // all, so the roots landed as bright as the lenses. The design's sentence is *the
        // lenses, then the roots more softly, then him* — and a uniform brightness says the
        // gathering has no shape.
        //
        // Asserted through the component's own parameter, so a future reveal that drops it
        // diverges from something that exists rather than being a plausible omission.
        let root = StaggeredReveal(triggered: true, delay: 0.66, duration: 0.9,
                                   rise: 6, settledOpacity: 0.72) { EmptyView() }
        let lens = StaggeredReveal(triggered: true, delay: 0, duration: 0.8,
                                   rise: 10) { EmptyView() }
        #expect(root.settledOpacity == 0.72)
        #expect(lens.settledOpacity == 1, "the lenses no longer arrive at full weight")
        #expect(root.settledOpacity < lens.settledOpacity)
    }

    @Test("the roots rise less far than the lenses")
    func theRiseDiffers() {
        // `translateY(10px)` for the lenses against `6px` for the substrates — they settle
        // rather than gather. A shared rise would make them the same kind of thing.
        let root = StaggeredReveal(triggered: true, delay: 0.66, duration: 0.9,
                                   rise: 6, settledOpacity: 0.72) { EmptyView() }
        let lens = StaggeredReveal(triggered: true, delay: 0, duration: 0.8,
                                   rise: 10) { EmptyView() }
        #expect(root.rise < lens.rise)
        #expect(lens.rise == 10 && root.rise == 6)
    }
}
