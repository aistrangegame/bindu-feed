import Testing
import Foundation
@testable import Bindu_Feed

// D5.5 · the chamber's reading is PRESSED, not tapped.
//
// **`.serialized` because `PressClaim` is shared static state** — §10's tenth shape, applied
// at creation. `PointReadings.swift:87` says of it: *"Nothing tests this yet; the first suite
// that does inherits the trap."* This is that suite.
@Suite(.serialized) struct ChamberPressTests {

    /// How long a press must be borne before the first gate cuts, at a given depth.
    static func secondsToOpen(z: Double) -> Double {
        PointChamber.gates[0] / PointChamber.pressRate(z: z)
    }

    // MARK: - the relationship, not the outcome

    @Test("the niche opens by being borne, not by being touched")
    func aPressHasDurationAndATapDoesNot() {
        // THE CLAIM. `AUDIT D5.5` — *"press back, and the harder the press the deeper the
        // inscription is struck"* — and `D5.1` names this world and the Dance as its two
        // sharpest instances. Both had the same shape: the mechanism one layer in, the entry
        // contradicting the world. **A tap has no duration, so it cannot be borne**, and
        // bearing is the whole of world IV.
        //
        // The number that matters is that the wait is REAL — long enough to be a held act,
        // short enough not to be a punishment.
        let t = Self.secondsToOpen(z: 3)
        #expect(t > 0.25, "the niche opens in \(t)s — that is a tap with extra steps")
        #expect(t < 1.2, "the niche takes \(t)s — bearing is not endurance")
    }

    @Test("the load decides how fast it cuts")
    func deeperCutsFaster() {
        // `pressRate(z:) = 0.30 + load(z:)*0.26`, and `load(z:) = (z+4)/9` — *"the number of
        // registers standing over this one sets the load."* The relationship is that the
        // chamber's own depth changes the press, so the same finger does different work at
        // different places on the axis. A constant rate would satisfy "a press opens it".
        let shallow = Self.secondsToOpen(z: -4)      // load 0
        let deep = Self.secondsToOpen(z: 5)          // load 1
        #expect(deep < shallow, "depth did not change the cut: \(deep) vs \(shallow)")
        #expect(abs(PointChamber.pressRate(z: -4) - 0.30) < 1e-9)
        #expect(abs(PointChamber.pressRate(z: 5) - 0.56) < 1e-9)
    }

    @Test("what was struck stays struck, and only ever deepens")
    func theInscriptionIsKept() {
        // *"release and what was struck stays struck."* The entry strikes to depth 1; the
        // reading strikes deeper. A later shallower strike must not erase a deeper one — the
        // wall records the most that was ever borne, not the last thing that happened.
        PointChamber.resetAll()
        PointChamber.strike("k", to: 1)
        #expect(PointChamber.depth(of: "k") == 1)
        PointChamber.strike("k", to: 3)
        #expect(PointChamber.depth(of: "k") == 3)
        PointChamber.strike("k", to: 2)
        #expect(PointChamber.depth(of: "k") == 3, "a shallower press undid a deeper one")
        PointChamber.leaveRegister()
        #expect(PointChamber.depth(of: "k") == 3, "leaving the register erased the wall")
        PointChamber.resetAll()
    }

    // MARK: - the claim, released by every exit

    @Test("a press claims the hand, and every exit gives it back")
    func theClaimIsReleased() {
        // §10 · *"A CLAIM IS RELEASED BY EVERY PATH ITS OWNER CAN LEAVE BY, NOT ONLY THE
        // POLITE ONE."* `PressClaim` leaked once because the surface vanished mid-press and
        // `onEnded` never fired, and the rope stayed dead for the whole session. The chamber
        // has three exits — the niche opening, the finger lifting, and the view going away —
        // and all three call one `endPress()`.
        PressClaim.release("chamber.x")               // start from clean
        #expect(!PressClaim.isClaimed)
        PressClaim.claim("chamber.x")
        #expect(PressClaim.isClaimed)
        PressClaim.release("chamber.x")
        #expect(!PressClaim.isClaimed, "the claim outlived the press")
    }

    @Test("a release cannot free someone else's claim")
    func onlyYourOwnClaim() {
        // `release(_ who:)` checks ownership, so a late `onEnded` from a niche the hand has
        // already left cannot unlock a press that belongs to another surface.
        PressClaim.release("chamber.a"); PressClaim.release("chamber.b")
        PressClaim.claim("chamber.a")
        PressClaim.release("chamber.b")
        #expect(PressClaim.isClaimed, "a stranger's release freed the claim")
        PressClaim.release("chamber.a")
        #expect(!PressClaim.isClaimed)
    }

    // MARK: - green on absent

    @Test("the gates are the design's, and the first is the entry")
    func theGates() {
        #expect(PointChamber.gates == [0.22, 0.46, 0.70, 0.92])
        #expect(PointChamber.gates[0] > 0, "an entry gate of zero is a tap")
    }
}
