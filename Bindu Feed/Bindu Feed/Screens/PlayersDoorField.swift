import SwiftUI

// `doorField` — `The Rooms v4.html:1030`, the door's own ground.
//
// The comp guards it with `if(!who){doorField(t,b);return;}` at `:1010`: this is what the
// surface looks like when no voice has been entered. Eleven coloured glows orbit behind the
// grid, one per voice, each a 130px radial gradient at alpha 0.10 of that voice's own hue.
//
// WHAT IT IS FOR, AND WHY A BACKGROUND WAS WORTH PORTING. `PlayersView` painted a flat
// ground, which makes the door a MENU OF ELEVEN CARDS. The glows make it a field the voices
// are already standing in — the same sentence the rest of the app makes, *already alive when
// you arrive*. `_mechverdicts1.md` records it ABSENT with exactly that reading: *"so it reads
// as a field the voices are in rather than a grid of cards."*
//
// The geometry lives here rather than inside the view so it can be asserted. A private
// drawing method is a mechanism no test can reach, and this one has a relationship worth
// pinning — see `PlayersDoorFieldTests`.
enum PlayersDoorField {

    /// `:1033-1034`, verbatim.
    ///
    ///     const a = t*0.05 + i*TAU/keys.length,
    ///           r = Math.min(W,H)*0.42*(0.9 + b*0.07);
    ///     px = W/2 + Math.cos(a)*r,  py = H*0.46 + Math.sin(a)*r*0.46;
    ///
    /// **THE ORBIT IS AN ELLIPSE, AND THAT IS THE WHOLE CLAIM.** `r` on x against `r*0.46`
    /// on y is not a squashed circle for looks: it is what makes the voices pass BEHIND the
    /// grid and return, so the ring reads as depth. A circular orbit at this radius would
    /// carry them around the outside and the surface would read as a carousel — eleven
    /// things being presented — which is the opposite of the sentence the door is making.
    static func point(_ i: Int, count: Int, W: Double, H: Double, t: Double) -> CGPoint {
        let b = RoomGeo.breath(t)
        let r = min(W, H) * 0.42 * (0.9 + b * 0.07)
        let a = t * 0.05 + Double(i) * (2 * Double.pi) / Double(max(1, count))
        return CGPoint(x: W / 2 + cos(a) * r,
                       y: H * 0.46 + sin(a) * r * 0.46)
    }

    /// `:1035-1036` — the glow's reach and its two stops.
    static let radius: Double = 130
    static let innerAlpha: Double = 0.10

    /// The eleven, in `The Rooms v4.html:672`'s own order — which is `RoomKey.allCases`.
    /// The comp's eleventh key is `ashram`; this app resolves that identity as **Ash**
    /// (§7 — a voice is resolved by record, and the display string is device-local, so the
    /// literal here is an ORDERING key against the base's own `Name`, never an identity).
    static let order = ["Bindu", "Neev", "Gaia", "Sid", "Arch", "Shweta",
                        "Karishma", "Sakshi", "Lalita", "Ashrey", "Ash"]
}
