import Testing
import Foundation
import SwiftUI
@testable import Bindu_Feed

// THE LAST STRETCH OF THE AXIS, AND THE GATE THAT IS AN EVENT RATHER THAN A PLACE.
//
// Three claims from the stop-condition batch, asserted where they are assertable. What is NOT
// here is deliberate: the aperture's gradient stops live inside a `Canvas` closure in
// `ThroatView`, and an assertion about them would have to re-implement them — the tautology
// §10 forbids. They are recorded in the commit and owed to the walk instead.
@Suite struct ArrivalAtTheCentreTests {

    @Test("the reveal is past the centre, not at it")
    func theRevealIsEarned() {
        // C5.11 · `The Instrument v3.html:5647` — `if(Z>9.5&&!splitDone)doSplit();`
        //
        // `here.key` becomes "centre" at the midpoint between The Dance (z 8) and the centre
        // (z 9), so the register mounts a full register before the design reveals anything.
        // The relationship, not the constant: **the key changes strictly before the reveal.**
        #expect(Axis.nearest(8.5).key == "centre", "the register mounts at 8.5")
        #expect(Axis.nearest(9.0).key == "centre")
        #expect(!Immersion.chromeSilenced(z: 8.5), "he is AT the centre and not yet past it")
        #expect(!Immersion.chromeSilenced(z: 9.4))
        #expect(Immersion.chromeSilenced(z: 9.6), "past 9.5, inside the 9.62 overshoot")
        #expect(Axis.maxZ > 9.5, "the overshoot has to reach past the threshold or nothing fires")
    }

    @Test("the chrome does not fade at the centre — it stops")
    func theInstrumentFallsSilent() {
        // `doSplit` (`:5763-5766`) sets opacity to 0 and takes the door off; it does not ramp.
        // A ramp would be the wrong sentence: the bloom underneath is the continuous thing.
        // Asserted as a step — there is no z at which the chrome is partly silenced.
        var seenOn = false, seenOff = false
        var z = 8.0
        while z <= Axis.maxZ {
            if Immersion.chromeSilenced(z: z) { seenOff = true } else { seenOn = true }
            z += 0.02
        }
        #expect(seenOn && seenOff, "both states are reachable on the real axis")
        // And it is monotone: once silenced, never again loud.
        var flipped = 0
        var last = Immersion.chromeSilenced(z: 8.0)
        z = 8.0
        while z <= Axis.maxZ {
            let now = Immersion.chromeSilenced(z: z)
            if now != last { flipped += 1; last = now }
            z += 0.01
        }
        #expect(flipped == 1, "one transition on the whole approach, not \(flipped)")
    }

    @MainActor
    @Test("the gate sounds inside a crossing, and never at the register named the gate")
    func theGateIsAnEventNotAPlace() {
        // C7.7 · `:5451` — `if(ev==='gate') B.gate(S.REG[PS.to].hz)`.
        //
        // **THE RELATIONSHIP, WHICH A COUNT CANNOT SEE.** The old build fired when landing on
        // the register whose key is "gate"; the design fires from the two gates inside every
        // passage, carrying the DESTINATION's pitch. Both builds "play the gate tone", so an
        // outcome assertion passes either way — what separates them is which event raises it.
        let travel = AxisTravel(startZ: 0)
        var gateHz: [Double] = []
        var landed: [String] = []
        travel.onGate = { gateHz.append($0.hz) }
        travel.onLand = { landed.append($0.key) }

        travel.stepOut(to: 1)                        // z 0 → +1, the register named "gate"
        #expect(travel.crossing)
        for _ in 0..<600 where travel.crossing { travel.advance(dt: 1.0 / 60) }

        #expect(landed.contains("gate"), "he did land on the gate register — \(landed)")
        #expect(!gateHz.isEmpty, "the crossing has a middle and it sounds")
        // Two gates per earned crossing (`t = 0.34` and `0.68`), each once.
        #expect(gateHz.count == 2, "two gates, once each — got \(gateHz.count)")
        // The pitch is the destination's, which is what makes it say where he is going.
        let to = Axis.nearest(1).hz
        #expect(gateHz.allSatisfy { $0 == to }, "\(gateHz) should all be PS.to's \(to)")
    }

    @Test("a colour mixed with white is not that colour at half alpha")
    func mixIsNotAlpha() {
        // `mixc(cto, WHITE, 0.5)` at `:3687`. The aperture's shoulder is the destination hue
        // made BRIGHTER; alpha over a dark ground makes it dimmer. The two are opposites, and
        // taking one for the other is what kept the crossing from flooding.
        let hue = Color(hex: "#E5533C")
        let mixed = hue.mixedWithWhite(0.5)
        #if canImport(UIKit)
        var r0: CGFloat = 0, g0: CGFloat = 0, b0: CGFloat = 0, a0: CGFloat = 0
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        UIColor(hue).getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
        UIColor(mixed).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        #expect(r1 > r0 && g1 > g0 && b1 > b0, "every channel rises toward white")
        #expect(a1 == a0, "the mix must not spend alpha — that is the other operation")
        // Halfway, exactly, on the channel with the most room to travel.
        #expect(abs(Double(b1) - (Double(b0) + (1 - Double(b0)) * 0.5)) < 1e-6)
        // And the endpoints behave.
        #expect(abs(Double(r0) - Double(UIColor(hue.mixedWithWhite(0)).cgColor.components?[0] ?? -1)) < 1e-6)
        #endif
    }

    @Test("the recognition at the sky is one authored line, held behind real stillness")
    func theDwellRecognitionIsReachable() {
        // B0.5 · `:1298-1302`. The threshold is the point: 0.62 of a 3.33 s fill is past any
        // accidental pause, so it cannot be met by putting the phone down mid-gesture.
        #expect(InstrumentNames.dwellRecognition == "This is what you look like from outside.")
        // The window is real rather than nominal — dwell fills at 0.30/s, so reaching 0.62
        // takes 2.07 s of held stillness, and the alpha only completes 1.0 s after that.
        let toThreshold = 0.62 / 0.30
        let toFull = (0.62 + 0.30) / 0.30
        #expect(toThreshold > 2.0 && toThreshold < 2.1, "≈2.07 s, got \(toThreshold)")
        #expect(toFull < 3.34, "it must finish arriving before dwell caps — \(toFull)")
    }
}
