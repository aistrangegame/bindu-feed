import Foundation
import Testing
@testable import Bindu_Feed

// B4 · THE FIRST RETURN ANYONE SEALS — *AUDIT E3.1*, BLOCKER
//
// `ReturnStrata.draw` walked `stride(from: n - 1, through: 1, by: -1)` with
// `n = returnCount`. A `stride` from 0 through 1 by −1 is EMPTY, so a story with exactly
// one sealed return drew no ring at all — and every count above that drew one too few.
//
// `return-strata.js:65,97` reads `n = S.rings.length` over
// `[{when:'the seed'}, ...age.returns]` (`The Return v2.html:1268`): index 0 is the seed,
// which is drawn on its own, so `n` is returns **+ 1**. The app passed `returnCount`
// straight in. `ringAges` was already built seed-first as `[0] + ringDays`, and its last
// element was provably never read — the same off-by-one seen from the other side.
@Suite("B4 · the strata's rings · AUDIT E3.1")
struct ReturnStrataTests {

    private func rings(_ returns: Int) -> [Int] { Array(ReturnStrata.ringIndices(returns: returns)) }

    @Test("one return draws one ring — the case that drew nothing")
    func firstReturnDrawsARing() {
        #expect(rings(1) == [1])
    }

    @Test("k returns draw k rings, outermost first")
    func countMatches() {
        for k in 0...6 { #expect(rings(k).count == k, "\(k) returns → \(rings(k).count) rings") }
        #expect(rings(4) == [4, 3, 2, 1])       // newest outermost, drawn first
    }

    @Test("no returns draws no rings — the seed alone is a real state")
    func zeroIsReal() {
        #expect(rings(0).isEmpty)
        #expect(rings(-3).isEmpty)              // never negative, whatever the store hands over
    }

    /// The other side of the same off-by-one: `ReturnView` builds `ringAges` as
    /// `[0] + storyData.ringDays`, seed-first. Every index the draw loop visits must land
    /// inside it, and — the part that was broken — the LAST element must actually be read.
    @Test("every ring index addresses a real ringAges slot, including the last")
    func ringAgesLineUp() {
        for k in 1...6 {
            let ringAges = [0.0] + Array(repeating: 0.5, count: k)     // as ReturnView builds it
            let idx = rings(k)
            #expect(idx.allSatisfy { $0 < ringAges.count })
            #expect(idx.max() == ringAges.count - 1, "the newest ring must read the last age")
        }
    }
}
