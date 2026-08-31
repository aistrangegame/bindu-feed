import Testing
import SwiftUI
@testable import Bindu_Feed

// D5.5 · BATCH 4 — the light. `world-four.js:151-157`, `:205-213`.
//
// *"He is the magma layer — pressured by every shell above."* The light comes from BELOW, and
// **every other shading decision in the room is drawn against that one fact**: the niche is a
// cut *lit from the floor*, the deboss's light edge is its UPPER one, the vault is the darkest
// thing on screen. The app had no source at all, so each of those read as an arbitrary choice.
@Suite struct ChamberLightTests {

    /// The design's three stops, as the app computes them.
    private func magma(pr: Double, breath br: Double) -> (mid: Double, floor: Double) {
        (0.10 * (0.7 + br * 0.4), (0.20 + pr * 0.16) * (0.8 + br * 0.3))
    }

    @Test("the light is brightest at the floor and absent at the horizon")
    func itComesFromBelow() {
        // Three stops: nothing at the top, a little at 0.42, the most at the very bottom. A
        // gradient the other way up is a sky, and this world is explicitly not one.
        let m = magma(pr: 0.3, breath: 0.5)
        #expect(m.floor > m.mid, "the light is brighter at the horizon than at the floor")
        #expect(m.mid > 0)
    }

    @Test("the magma breathes — that is what makes it a source and not a gradient")
    func itBreathes() {
        // `0.7 + br·0.4` on the mid stop and `0.8 + br·0.3` at the floor. A still gradient
        // reads as paint; the same shape moving with the breath reads as something burning
        // under the floor. Note the floor swings LESS than the middle — the deep layer is
        // steadier than its edge, which is the right way round for a body of molten rock.
        let low = magma(pr: 0, breath: 0), high = magma(pr: 0, breath: 1)
        #expect(high.mid > low.mid, "the magma does not breathe")
        #expect(high.floor > low.floor)
        let midSwing = (high.mid - low.mid) / low.mid
        let floorSwing = (high.floor - low.floor) / low.floor
        #expect(floorSwing < midSwing, "the deep layer flickers more than its edge")
    }

    @Test("bearing on the room brightens the floor, and only the floor")
    func theLoadShowsInTheLight() {
        // `(0.20 + pr·0.16)` is on the bottom stop alone. The room does not get generally
        // brighter under load — the MAGMA does, which is the world's sentence: the pressure
        // is the point, and it is what the light is made of.
        let slack = magma(pr: 0, breath: 0.5), borne = magma(pr: 1, breath: 0.5)
        #expect(borne.floor > slack.floor)
        #expect(borne.mid == slack.mid, "the whole room brightened, not the magma")
    }

    // MARK: - the niche, lit from the floor

    @Test("bearing on a niche OPENS it — the glow grows, it does not merely brighten")
    func theNicheOpens() {
        // `R·(6 + lit·8)`. A radius that answers the hand is an opening; a fixed radius at
        // rising alpha is a lamp being turned up. The app had a fixed 9pt disc with a fixed
        // shadow, which is neither.
        func glow(_ lit: Double, R: Double = 4) -> Double { R * (6 + lit * 8) }
        #expect(glow(1) > glow(0) * 2, "a fully borne niche is barely wider than an untouched one")
        #expect(glow(0) > 0)
    }

    @Test("an untouched niche is still visible, and a borne one is not blown out")
    func theEndsHold() {
        // `al = (0.44 + lit·0.56)·(0.72 + sc·0.7)`, and the core is `min(1, al·1.2)` — the
        // cap is what keeps a near, fully-borne niche from becoming a white hole.
        func al(lit: Double, sc: Double) -> Double { (0.44 + lit * 0.56) * (0.72 + sc * 0.7) }
        #expect(al(lit: 0, sc: 0.30) > 0.35, "an untouched far niche is invisible")
        #expect(min(1, al(lit: 1, sc: 0.65) * 1.2) == 1)
        #expect(al(lit: 1, sc: 0.65) > al(lit: 0, sc: 0.65), "bearing on it did nothing")
    }

    @Test("the niche warms toward cream as it is borne, rather than only lightening")
    func itWarmsWithTheHand() {
        // `mix(HUE, '#FFE0BC', 0.18 + lit·0.42)` — colour, never opacity alone (§11). At rest
        // it is 18% cream; fully borne, 60%. Opacity alone would say *more of the same thing*;
        // the warming says the stone is glowing.
        let hue = UniGeo.hx("#E0713F")
        let cool = UniGeo.mix(hue, [255, 224, 188], 0.18)
        let warm = UniGeo.mix(hue, [255, 224, 188], 0.60)
        #expect(warm[2] > cool[2], "the blue channel did not rise — it is not warming")
        #expect(warm[1] > cool[1])
    }

    // MARK: - green on absent

    @Test("with no load and no hand the magma still burns, faintly")
    func theSourceNeverGoesOut() {
        // `0.20` with `pr = 0`. He is the molten layer whether or not he is pressing; a floor
        // that goes dark when he lets go would say the light was his doing.
        #expect(magma(pr: 0, breath: 0.5).floor > 0.15)
    }
}

// D5.5 · BATCH 5 — the rope. `world-four.js:39-40`, `:254-262`.
//
// *"And this is the rope's home. The rope hangs here, visible, because the chamber is the
// register the rope was built for."* In this one world it is simply present — **no caption,
// no cue, not explained.** That silence is the mechanism, not an omission: everywhere else the
// rope is something reached for; here it is furniture. A label would turn the one register
// that has always had it into the register that advertises it.
@Suite struct ChamberRopeTests {

    private let rim = 200.0
    private func ropeX(at f: Double, t: Double) -> Double {
        rim * 0.62 + sin(f * 2.2 + t * 0.16) * rim * 0.012
    }

    @Test("it hangs from above the back wall, not from inside the room")
    func itComesOutOfTheVault() {
        // `ry0 = cy − bh·1.1`. The 1.1 puts its anchor ABOVE the top of the back wall, so it
        // comes down out of the dark vault. Anchored at `bh` exactly it would start on the
        // wall's edge and read as drawn on it.
        let bh = rim * 1.12 * PointChamber.BACK
        let anchor = -bh * 1.1
        #expect(anchor < -bh, "the rope starts inside the room")
    }

    @Test("it hangs a real distance, and stops short of the floor")
    func itHangsAndEnds() {
        // `f2·rim·0.60` over sixteen segments. Long enough to be a rope; short enough that it
        // does not reach the magma.
        let drop = rim * 0.60
        let bh = rim * 1.12 * PointChamber.BACK
        #expect(drop > rim * 0.4, "it is a stub, not a rope")
        #expect(-bh * 1.1 + drop < rim, "it hangs past the floor of the room")
    }

    @Test("it sways, slowly, and by far less than the room moves")
    func itIsAlive() {
        // `sin(f2·2.2 + t·0.16)·rim·0.012`. The amplitude is a hundredth of the rim — a rope
        // in still air, not a pendulum. And the phase runs along its LENGTH (`f2·2.2`), so it
        // curves rather than swinging rigidly.
        let a = ropeX(at: 0.5, t: 0), b = ropeX(at: 0.5, t: 20)
        #expect(a != b, "the rope is frozen")
        #expect(abs(a - b) < rim * 0.03, "it is swinging like a pendulum")
        let top = ropeX(at: 0, t: 3), mid = ropeX(at: 0.5, t: 3), foot = ropeX(at: 1, t: 3)
        #expect(!(abs(top - mid) < 1e-9 && abs(mid - foot) < 1e-9), "the rope is a straight line")
    }

    @Test("sixteen segments — a rope drawn as one line does not hang")
    func itIsNotOneStroke() {
        // The count is what lets the curve exist at all. Two points give a straight cord
        // however the sway is computed.
        var xs: [Double] = []
        for q in 0...16 { xs.append(ropeX(at: Double(q) / 16, t: 1.5)) }
        #expect(xs.count == 17)
        let spread = (xs.max() ?? 0) - (xs.min() ?? 0)
        #expect(spread > 0.5, "every segment sits at the same x — there is no curve")
    }

    // MARK: - green on absent

    @Test("the rope is not explained — nothing is said about it anywhere")
    func itCarriesNoCaption() {
        // `:254` — *"This is its home; it is not explained."* The invented-string rule and the
        // design agree here for once by saying nothing: this pass adds no label, no cue and no
        // registry entry. Asserted so a later hand that adds a helpful caption fails here
        // rather than in a walk.
        let src = try? String(contentsOfFile:
            "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift", encoding: .utf8)
        guard let src else { Issue.record("could not read the world"); return }
        guard let r = src.range(of: "THE ROPE HANGS HERE") else { Issue.record("the rope is gone"); return }
        let block = String(src[r.lowerBound...].prefix(1400))
        #expect(!block.contains("Text(\""), "something is being said about the rope")
        #expect(!block.lowercased().contains("pull the rope"))
    }
}
