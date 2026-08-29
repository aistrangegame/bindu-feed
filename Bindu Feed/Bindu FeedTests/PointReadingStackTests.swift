import Testing
import Foundation
@testable import Bindu_Feed

// `stackFrom` / `floorY` — `The Reading.html:286-294`. The reading displacing the world.
@Suite struct PointReadingStackTests {

    static let H = 852.0
    static func floor(verb: Bool = false, verbH: Double = 40) -> Double {
        PointReadingStack.floorY(H: H, railHeight: 48, verbVisible: verb, verbHeight: verbH)
    }

    // MARK: - the relationship, not the outcome

    @Test func eachSectionGivenPushesTheStackHigher() {
        // THE CLAIM. "Four sections are laid out" is true of a downward ScrollView too —
        // that is exactly what the app does now and what this mechanism replaces. What
        // `stackFrom` asserts is a RELATIONSHIP between how much has been given and where
        // the group sits: the stack NEVER descends as sections arrive, and once there is
        // more of it than the headroom allows, every further section lifts it.
        //
        // The two halves matter separately, and the first draft of this test asserted only
        // the second and failed. `min(originMax, floor − total)` means the origin is a
        // CEILING the stack rests against while it is still short: with four modest
        // sections the group never reaches it and never moves at all. That is the design's
        // behaviour, not a defect — the reading does not start shoving the world aside for
        // one line — so it is asserted rather than assumed away with taller test content.
        let f = Self.floor()
        let origin = Self.H * 0.54
        // Tall enough that the stack outgrows its headroom partway, as a real reading does.
        let heights = [120.0, 110, 140, 100]

        var ys: [Double] = []
        for given in 0...4 {
            ys.append(PointReadingStack.stackFrom(originMax: origin, gap: 13,
                                                  heights: heights, given: given, floorY: f))
        }
        // Never descends.
        for i in 1..<ys.count {
            #expect(ys[i] <= ys[i - 1] + 1e-9, "given \(i) pushed the stack DOWN: \(ys)")
        }
        // Rests at the ceiling while short, then rises — both halves present in one run.
        #expect(ys[0] == origin && ys[1] == origin, "the ceiling did not hold early: \(ys)")
        #expect(ys[4] < ys[3] && ys[3] < origin,
                "the stack never outgrew its headroom, so this proved nothing: \(ys)")

        // Uncapped, the displacement is exactly what was given, plus the gaps between.
        let all = PointReadingStack.stackFrom(originMax: 10_000, gap: 13,
                                              heights: heights, given: 4, floorY: f)
        #expect(abs(all - (f - (120 + 110 + 140 + 100 + 13 * 3))) < 1e-9)
    }

    @Test func theGapFallsBetweenSectionsAndNotBeforeTheFirst() {
        // `(n ? gap : 0)` — one section reserves no gap, four reserve three. Getting this
        // wrong is invisible at four sections and wrong at one, which is the register-0
        // recede's fault in a different file: a rule that looks right in the case you built
        // it for.
        let f = Self.floor()
        let one = PointReadingStack.stackFrom(originMax: 10_000, gap: 13,
                                              heights: [64], given: 1, floorY: f)
        #expect(abs(one - (f - 64)) < 1e-9, "a single section reserved a gap it has no neighbour for")

        let two = PointReadingStack.stackFrom(originMax: 10_000, gap: 13,
                                              heights: [64, 52], given: 2, floorY: f)
        #expect(abs(two - (f - (64 + 52 + 13))) < 1e-9)
    }

    @Test func originMaxIsACeilingTheStackNeverRisesPast() {
        // `Math.min(originMax, …)`. With little given, the floor-relative position would sit
        // low on the screen — the origin caps how high the group may sit, so it does not
        // drift up into the star before there is anything to show.
        let f = Self.floor()
        let capped = PointReadingStack.stackFrom(originMax: Self.H * 0.54, gap: 13,
                                                 heights: [10], given: 1, floorY: f)
        #expect(abs(capped - Self.H * 0.54) < 1e-9, "the ceiling did not hold: \(capped)")
    }

    // MARK: - `floorY`'s asymmetry

    @Test func theVerbCanOnlyRaiseTheFloorNeverLowerIt() {
        // `f = Math.min(f, H - 96 - verbHeight - 10)` — a `min`, not an assignment. A SHORT
        // verb line must not be able to push the stack DOWN into the rail. This is the kind
        // of thing that is correct in every case you try and wrong in the one you do not, so
        // it is tested at the extreme: a verb so short its reserve sits below the rail's.
        let bare = Self.floor()
        let tall = Self.floor(verb: true, verbH: 200)
        #expect(tall < bare, "a tall verb must lift the floor: \(tall) vs \(bare)")

        let tiny = Self.floor(verb: true, verbH: 0)
        #expect(tiny <= bare, "a short verb must never lower the floor: \(tiny) vs \(bare)")
    }

    // MARK: - the three call sites

    @Test func theThreeSitesCarryTheirOwnOriginsAndGaps() {
        // `:333` · `:466` · `:543`. Three worlds stack; the other four never call it, and
        // the numbers are per-world rather than shared.
        #expect(PointReadingStack.Site.stillness.originFraction == 0.54)
        #expect(PointReadingStack.Site.stillness.gap == 13)
        #expect(PointReadingStack.Site.parting.originFraction == 0.56)
        #expect(PointReadingStack.Site.parting.gap == 12)
        #expect(PointReadingStack.Site.bearing.originFraction == 0.14)
        #expect(PointReadingStack.Site.bearing.gap == 11)

        // Bearing's origin is a quarter of the others' — world IV's reading sits high,
        // because the press happens against the wall below it. The three are not a
        // near-miss of one shared constant, and must not be collapsed into one.
        #expect(PointReadingStack.Site.bearing.originFraction
                < PointReadingStack.Site.stillness.originFraction / 3)
    }
}
