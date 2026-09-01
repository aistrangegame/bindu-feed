import Testing
import Foundation
@testable import Bindu_Feed

// E3.5 + E3.6 + E3.7 · the strata's camera — `return-strata.js:66,105-107,136`,
// `The Return v2.html:1278-1292`.
//
// **THREE ROWS, ONE MISSING PARAMETER.** `ReturnStrata` had `let s = 1.0 // arrived (z = 1)`,
// so it could only ever draw the arrived state — and each thing it therefore could not do was
// filed as its own row and would have been built as its own surface: a fall (a port of the
// Universe's), a rings widget, a caption layer. What is asserted here is the parameter and
// what it does to a ring, because that is what all three rows actually rest on.
@Suite struct ReturnDepthTests {

    // MARK: - the camera

    @Test("far is 1.3% of full size, not nothing")
    func theFloorIsNotZero() {
        // `:66` — `s = 0.013 + (1-0.013)*z`. A floor of ZERO would collapse every ring to a
        // point and the fall would begin from nothing rather than from a great distance; the
        // difference is whether there is something down there to fall toward.
        #expect(abs(ReturnDepth.scale(z: 0) - 0.013) < 1e-9)
        #expect(abs(ReturnDepth.scale(z: 1) - 1.0) < 1e-9)
        #expect(ReturnDepth.scale(z: 0) > 0, "the strata vanish at the top of the fall")
    }

    @Test("the fall builds early and spends most of itself arriving")
    func theDescentIsBraked() {
        // `:1284` — `z = eo(p^1.35)`, two easings stacked.
        //
        // **MY FIRST EXPECTATION HERE WAS WRONG AND THE TEST CAUGHT IT.** I asserted the
        // familiar slow-fast-slow shape — that the middle is the fastest part. Measured, the
        // rate peaks at **p ≈ 0.22** and decays from there: 1.03 over the first 5%, 1.80 at
        // the peak, 0.006 over the last 5%. `p^1.35` only softens the first instant; `eo`'s
        // cubic-out governs everything after, so the curve is front-loaded.
        //
        // That is a different sensation and the right one for this register: he commits
        // early and then spends **three quarters of the fall arriving** — by the halfway
        // point he is already 78% of the way down. A symmetric ease would make the landing an
        // event; this makes it a settling.
        let rate = { (a: Double, b: Double) in (ReturnDepth.z(atProgress: b) - ReturnDepth.z(atProgress: a)) / (b - a) }
        let opening = rate(0.00, 0.05), peak = rate(0.20, 0.25), landing = rate(0.95, 1.00)
        #expect(opening < peak, "the fall started at full speed — `p^1.35` is not doing its work")
        #expect(landing < opening / 10, "the fall did not brake — `eo` is not doing its work")
        #expect(ReturnDepth.z(atProgress: 0.5) > 0.75,
                "the fall is not front-loaded — half the descent should be most of the way down")
        #expect(ReturnDepth.z(atProgress: 0) == 0)
        #expect(abs(ReturnDepth.z(atProgress: 1) - 1) < 1e-9)
    }

    @Test("the fall is measured in breaths, not seconds")
    func theClockIsTheRegisters() {
        // `:1282` — `7200*(breathMs/9000)`. A literal 7.2s would be right at one tempo and
        // wrong everywhere the breath is set, and it would look correct in every screenshot.
        #expect(abs(ReturnDepth.duration(breathSeconds: 9) - 7.2) < 1e-9)
        #expect(ReturnDepth.duration(breathSeconds: 12) > ReturnDepth.duration(breathSeconds: 9))
        #expect(abs(ReturnDepth.duration(breathSeconds: 4.5) - 3.6) < 1e-9)
    }

    @Test("the camera settles and never cuts")
    func theCameraSettles() {
        // `:67` — `camY += (camTarget - camY)*0.018`. Each step is smaller than the last, so
        // a movement change is a drift rather than a jump between two heights.
        var cam = 0.40
        var steps: [Double] = []
        for _ in 0..<200 { let next = ReturnDepth.settle(cam, toward: 0.255); steps.append(cam - next); cam = next }
        #expect(abs(cam - 0.255) < 0.005, "the camera never arrived: \(cam)")
        for i in 1..<steps.count { #expect(steps[i] < steps[i - 1], "step \(i) grew — the settle went linear") }
    }

    // MARK: - what the camera does to a ring

    @Test("rings sweep out past the camera, outermost first")
    func theRingsPass() {
        // `:105-106`. **This is what makes the fall a fall and not a zoom.** A ring inside
        // the frame is fully drawn; one that has outgrown it fades and is then skipped, so
        // the old selves go by one at a time in the order they were laid down.
        let H = 800.0
        #expect(ReturnDepth.pass(radius: 100, height: H) == 1, "a near ring was already fading")
        #expect(ReturnDepth.pass(radius: H * 0.80, height: H) < 1)
        #expect(ReturnDepth.pass(radius: H * 0.80, height: H) > 0)
        #expect(ReturnDepth.passed(radius: H * 1.05, height: H), "a ring behind the camera was still drawn")
        // and the order: a bigger ring is always further gone than a smaller one
        #expect(ReturnDepth.pass(radius: 600, height: H) < ReturnDepth.pass(radius: 520, height: H))
    }

    @Test("a ring that was already there is fully grown and perfectly true")
    func nilIsTheRestingState() {
        // Every ring but the one he just sealed. `nil` must read as *arrived long ago*, not
        // as zero — a `?? 0` here would have every old ring born again on every frame.
        #expect(ReturnDepth.grown(nil) == 1)
        #expect(ReturnDepth.wobble(trueness: nil, rel: 0, t: 0, index: 0)
                == ReturnDepth.wobble(trueness: 1, rel: 0, t: 0, index: 0))
    }

    @Test("a new ring enters out of true and comes into it")
    func theRingComesIntoTune() {
        // `:1290-1299` — *"the visual twin of the sound entering 1.5% flat and coming into
        // tune."* An arriving ring is visibly out of round; a fade-in would have been the
        // same arrival with the meaning removed.
        let entering = ReturnDepth.wobble(trueness: 0, rel: 0.2, t: 0, index: 0)
        let settled = ReturnDepth.wobble(trueness: 1, rel: 0.2, t: 0, index: 0)
        #expect(entering > settled, "the new ring arrived already true")
        #expect(abs(entering - settled - 1.5) < 1e-9, "the out-of-true term is not 1.5")
        #expect(ReturnDepth.grown(0) == 0)
        #expect(ReturnDepth.grown(1) == 1)
    }

    @Test("the newest ring is the loudest thing, and distance thins as well as fades")
    func theActiveRingReads() {
        #expect(ReturnDepth.alpha(rel: 0, active: true, phase: 0, grown: 1, pass: 1)
                > ReturnDepth.alpha(rel: 0, active: false, phase: 0, grown: 1, pass: 1))
        // A far ring must be a HAIRLINE, not a full-weight line at low opacity — the two
        // read completely differently and only one of them is distance.
        #expect(ReturnDepth.lineWidth(rel: 1, active: false, scale: ReturnDepth.scale(z: 0))
                < ReturnDepth.lineWidth(rel: 1, active: false, scale: 1))
        #expect(ReturnDepth.nodeRadius(rel: 1, active: false, scale: ReturnDepth.scale(z: 0))
                < ReturnDepth.nodeRadius(rel: 1, active: false, scale: 1))
        // a ring that has passed contributes nothing, however new it is
        #expect(ReturnDepth.alpha(rel: 0, active: true, phase: 1, grown: 1, pass: 0) == 0)
    }

    // MARK: - the whispers are a branch in the loop, not a caption layer

    @Test("a ring names itself only while it is passing, and only during the fall")
    func theWhisperIsGatedOnTheRing() {
        // `:136` — `S.whispers && z>0.06 && z<0.92 && R>H*0.16 && pass>0.12`. **Three of the
        // four gates are properties of the RING**, which is why this cannot be a caption over
        // the fall: the names have to arrive one at a time, as each ring goes by.
        let H = 800.0, R = H * 0.5
        #expect(ReturnDepth.whispers(on: true, z: 0.5, radius: R, height: H, pass: 1))
        #expect(!ReturnDepth.whispers(on: false, z: 0.5, radius: R, height: H, pass: 1),
                "the strata whispered outside the fall")
        #expect(!ReturnDepth.whispers(on: true, z: 0.02, radius: R, height: H, pass: 1),
                "a ring named itself before the fall had begun")
        #expect(!ReturnDepth.whispers(on: true, z: 0.97, radius: R, height: H, pass: 1),
                "a ring was still naming itself as he landed")
        #expect(!ReturnDepth.whispers(on: true, z: 0.5, radius: H * 0.10, height: H, pass: 1),
                "a ring too small to read still spoke")
        #expect(!ReturnDepth.whispers(on: true, z: 0.5, radius: R, height: H, pass: 0.05),
                "a ring already gone past still spoke")
    }

    // MARK: - E3.7 · the crossing, the dust, the paper

    @Test("a crossing leaves, rather than rippling")
    func theWaveDeparts() {
        // `:163-165`. It goes out fast and fades on a SQUARED curve, so it is nearly gone by
        // the halfway point — a linear fade would leave a ring hanging in the field, which is
        // a different event: a wave that arrives somewhere rather than one that leaves.
        #expect(ReturnDepth.pulseAlpha(q: 0) == 0.20)
        #expect(ReturnDepth.pulseAlpha(q: 0.5) == 0.05, "the wave lingered — the fade is not squared")
        #expect(ReturnDepth.pulseAlpha(q: 1) == 0)
        let early = ReturnDepth.pulseRadius(q: 0.25, W: 400, H: 800, scale: 1)
        let late = ReturnDepth.pulseRadius(q: 0.75, W: 400, H: 800, scale: 1)
        #expect(early > ReturnDepth.pulseRadius(q: 0, W: 400, H: 800, scale: 1))
        #expect(late - early < early, "the wave did not slow — it is travelling at a constant rate")
    }

    @Test("a wave sent from far off is as small as the field it crosses")
    func theWaveIsInTheCamera() {
        // `·s`. Without it a crossing during the fall would throw a full-screen ring across a
        // field drawn at 1.3% — the sound made visible at the wrong scale entirely.
        #expect(ReturnDepth.pulseRadius(q: 0.5, W: 400, H: 800, scale: ReturnDepth.scale(z: 0))
                < ReturnDepth.pulseRadius(q: 0.5, W: 400, H: 800, scale: 1))
    }

    @Test("the air thickens as he arrives")
    func theDustIsDepth() {
        // `:170`. A fixed count gave the same dust at the top of the fall as in the room, so
        // nothing about the air said he had got closer.
        #expect(ReturnDepth.moteCount(z: 0) == 16)
        #expect(ReturnDepth.moteCount(z: 1) == 44)
        #expect(ReturnDepth.moteCount(z: 0.51) > ReturnDepth.moteCount(z: 0.49))
    }

    @Test("an old story is on older paper")
    func theGrainIsAge() {
        // `:22` — *"a material, not an opacity."* The amount is age, and it is never zero:
        // even a story sealed yesterday is on paper.
        #expect(abs(ReturnDepth.grainAmount(age: 0) - 0.05) < 1e-9)
        #expect(abs(ReturnDepth.grainAmount(age: 1) - 0.19) < 1e-9)
        #expect(ReturnDepth.grainAmount(age: 0) > 0, "a new story has no surface at all")
    }

    // MARK: - green on absent

    @Test("at rest the camera changes nothing about any ring")
    func arrivedIsNeutral() {
        #expect(ReturnDepth.scale(z: 1) == 1)
        #expect(ReturnDepth.settle(0.40, toward: 0.40) == 0.40)
        #expect(ReturnDepth.grown(nil) == 1)
        #expect(ReturnDepth.pass(radius: 10, height: 800) == 1)
        #expect(!ReturnDepth.whispers(on: false, z: 1, radius: 400, height: 800, pass: 1))
        // and no crossing means no wave: the list is empty and nothing is drawn
        #expect(ReturnDepth.pulseAlpha(q: 1) == 0)
    }
}
