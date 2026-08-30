import Testing
import Foundation
@testable import Bindu_Feed

// C7.4 · C7.6 · C7.8 — the three travel voices the axis had built and could not use.
//
// All three are the same family: a voice whose SHAPE was right and whose relationship to the
// hand was absent. STRAIN and RUSH were one-shots where the design sets a continuous voice
// every frame (`axisThin`'s fault, twice more); CARRY was correct under another name with a
// stale flat-peaked duplicate beside it.
@Suite struct AxisSurfaceTests {

    // MARK: - C7.4 · the surface under load

    @Test("leaning through the surface QUIETENS it — the push runs the other way")
    func theStrainEasesAsHeGives() {
        // **THE RELATIONSHIP, AND IT IS COUNTER-INTUITIVE, WHICH IS WHY IT NEEDS PINNING.**
        // `The Instrument v3.html:5474` — `TR.tension*(1 - TR.push*0.35)`. A surface complains
        // while it is HOLDING; as it begins to give, it stops complaining. Written the
        // obvious way round — more push, more strain — every outcome would still be "the
        // surface makes a noise under the hand", and the sentence the membrane is making
        // would be inverted. This is the NINTH SHAPE's assertion: gesture to effect, not
        // outcome.
        let holding = AxisSurface.load(tension: 0.8, push: 0.0, reading: false)
        let giving  = AxisSurface.load(tension: 0.8, push: 1.0, reading: false)
        #expect(giving < holding, "pushing through made the surface louder: \(giving) vs \(holding)")
        #expect(abs(giving - 0.8 * 0.65) < 1e-12, "the 0.35 coefficient moved")
    }

    @Test("inside a reading the surface has nothing to say — with a positive control")
    func theReadingSilencesIt() {
        // `IMM.on ? 0 : …`. Inside a piece the axis is locked (`:5445` zeroes `zv`, `tension`
        // and `push`), so a strain sounding under a reading would be the surface reacting to
        // a hand that cannot move it.
        #expect(AxisSurface.load(tension: 0.9, push: 0, reading: true) == 0)
        // **THE POSITIVE CONTROL**, because a negative satisfied by universal absence is
        // vacuous: the same load, not reading, must be audible.
        #expect(AxisSurface.load(tension: 0.9, push: 0, reading: false) > 0.5)
    }

    @Test("it is squared, so a light touch is nearly nothing and load opens the band")
    func theSquareIsTheCharacter() {
        // `f²·0.030`. Linear, a resting hand would hiss. The band opening `300 → 1800` is the
        // other half: the sound gets brighter as well as louder, which is what material under
        // stress does.
        let light = AxisSurface.strain(0.1), hard = AxisSurface.strain(1.0)
        #expect(light.gain < hard.gain / 50, "a light touch is as loud as full load")
        #expect(light.centre < hard.centre, "the band did not open under load")
        #expect(abs(hard.gain - 0.030) < 1e-12)
        #expect(abs(hard.centre - 1800) < 1e-9)
    }

    @Test("it is clamped at both ends")
    func theClampHolds() {
        #expect(AxisSurface.strain(-1).gain == 0, "a negative load made a sound")
        #expect(AxisSurface.strain(9).gain == AxisSurface.strain(1).gain)
    }

    // MARK: - C7.6 · the passage

    @Test("the rush is an ARCH — it builds, opens, and is swallowed by the arrival")
    func theEnvelopeIsNotADecay() {
        // THE CLAIM C7.6 RESTS ON. `canon/spine-sound.js:110-112` — *"falling through a throat
        // is not a threshold; it is a rush that builds, opens, and is swallowed by the
        // arrival."* The app fired one 2.9s sweep at the mouth of the passage, which is a
        // DECAY: loudest at the start, tailing under the arrival instead of clearing for it.
        //
        // **`sin(t·π)` and a decay are both "a noise that fades", so an outcome check cannot
        // separate them.** What separates them is WHERE THE MAXIMUM IS.
        let start = AxisSurface.rush(t: 0, dir: 1).gain
        let mid   = AxisSurface.rush(t: 0.5, dir: 1).gain
        let end   = AxisSurface.rush(t: 1, dir: 1).gain
        #expect(mid > start, "the rush did not build")
        #expect(mid > end, "the rush was loudest at the mouth — that is a decay, not an arch")
        #expect(start == 0 && abs(end) < 1e-12, "it must clear entirely for the arrival")
        #expect(abs(mid - 0.042) < 1e-12)
    }

    @Test("it follows the passage's own progress, frame by frame")
    func itTracksPassageT() {
        // The property a one-shot cannot have at all, and the reason the row is not merely a
        // wrong envelope: leaning into a crossing makes the fall faster (`:5447` feeds
        // `TR.force` into `PS.update`), so the passage's LENGTH is his. A fixed 2.9s sweep
        // says the same thing however he crosses. Walked, because the claim is about a curve.
        var seen: [Double] = []
        for i in 0...20 { seen.append(AxisSurface.rush(t: Double(i) / 20, dir: 1).gain) }
        let peakAt = seen.firstIndex(of: seen.max()!)!
        #expect(peakAt > 6 && peakAt < 14, "the peak sits at step \(peakAt) of 20, not the middle")
        // strictly up to the peak, strictly down after it — one arch, not a wobble
        for i in 1...peakAt { #expect(seen[i] > seen[i - 1], "not rising at \(i)") }
        for i in (peakAt + 1)...20 { #expect(seen[i] < seen[i - 1], "not falling at \(i)") }
    }

    @Test("no passage means no throat, whatever direction it last ran")
    func zeroIsSilent() {
        // `:5472` — `if(!PS.on){ … B.rush(0, PS.dir); }`. **A continuous voice has to be told
        // to stop**, and this is the failure mode the one-shot could not have: get this wrong
        // and the throat stays open at whatever the last frame set, forever.
        #expect(AxisSurface.rush(t: 0, dir: 1).gain == 0)
        #expect(AxisSurface.rush(t: 0, dir: -1).gain == 0)
        #expect(AxisSurface.rush(t: -0.5, dir: 1).gain == 0, "a negative t made a sound")
    }

    @Test("inward opens upward and outward closes downward")
    func theSweepHasADirection() {
        // `dir>0 ? 260+f*2600 : 2600-f*2200`. Falling in and coming back out are not the same
        // sound played backwards in time — they are opposite sweeps, which is what makes the
        // direction audible without looking.
        #expect(AxisSurface.rush(t: 1, dir: 1).centre > AxisSurface.rush(t: 0, dir: 1).centre)
        #expect(AxisSurface.rush(t: 1, dir: -1).centre < AxisSurface.rush(t: 0, dir: -1).centre)
        #expect(abs(AxisSurface.rush(t: 1, dir: 1).centre - 2860) < 1e-9)
        #expect(abs(AxisSurface.rush(t: 1, dir: -1).centre - 400) < 1e-9)
    }

    // MARK: - C7.8 · the carry

    @Test("the three steps taper — they are a sequence, not a chord")
    func theCarryLadderDecays() {
        // `AUDIT C7.8` reads *"flat peak"*, and the dead duplicate it found had exactly that:
        // 0.03 three times. `0.034/(i·0.6+1)` gives 0.034 · 0.021 · 0.015 — each step quieter
        // than the one before, so the first is the one he MEANT and the others are its room.
        // Three equal tones 0.3s apart is a chord arriving late, which says something else.
        let p = (0..<3).map { CarryVoicing.peak(step: $0) }
        #expect(p[0] > p[1] && p[1] > p[2], "the ladder is flat: \(p)")
        #expect(abs(p[0] - 0.034) < 1e-12)
        #expect(abs(p[1] - 0.034 / 1.6) < 1e-12)
        #expect(abs(p[2] - 0.034 / 2.2) < 1e-12)
    }

    @Test("they enter apart, and the ratios are the octave through its fifth")
    func theStepsRise() {
        #expect(CarryVoicing.ratios == [1, 1.5, 2])
        #expect((0..<3).map { CarryVoicing.delay(step: $0) } == [0, 0.3, 0.6])
    }
}
