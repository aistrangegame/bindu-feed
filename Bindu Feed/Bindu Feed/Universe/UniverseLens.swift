import Foundation

/// B7.4 · **THE LENS RAIL.** `Claude Design Round 1/comps/The Universe v3.html:1383-1388`
/// (the strip) and `:1674-1698` (its hand).
///
/// The row filed this as *"the lens is a text button, not the rail"*, and the button was not
/// merely a plainer control — it was a control for a **different quantity**. `lens` is a 0…1
/// scalar threaded through the whole renderer: `(1 − lens·0.94)` on the motes, the room mixed
/// toward BONE by `lens·0.3`, `lens·0.35` on the planet. Under a toggle every one of those
/// terms only ever saw 0 or 1, so the sky had two states where the design has a continuum.
///
/// **THREE THINGS HERE ARE EASY TO PORT WRONG AND EACH CHANGES THE GESTURE:**
///
/// 1 · **The drag is HORIZONTAL and RELATIVE.** `cursor:ew-resize`, and `:1682` reads
///     `railBase + (railX − e.clientX)/150` — it starts from the value the lens already had
///     when the hand landed, and pulling LEFT raises it. An absolute mapping (value from the
///     touch's position on the track) would make the lens jump to meet the finger on contact,
///     which is a slider; this is a nudge from where you are.
/// 2 · **The rendered lens LAGS the rail.** `:1517` — `lens += (lensTarget − lens)·0.07` every
///     frame. The knob is under the hand immediately and the sky arrives a beat later. A
///     linear ramp of the same duration reads as a transition; the exponential chase reads as
///     the world being heavy.
/// 3 · **The tap survives.** `:1694` toggles the lens when the pointer moved 5px or less, so
///     the control the app already had is not wrong — it was half of one.
enum LensRail {

    /// The track's own length, and the divisor of the drag. Not the rail's 30px width.
    static let travel: Double = 150
    /// `:1695` — beyond this the gesture was a drag and the tap does not also fire.
    static let tapSlop: Double = 5

    /// `:1682`. `startX` is where the hand landed; `x` is where it is now.
    static func drag(base: Double, startX: Double, x: Double) -> Double {
        clamp(base + (startX - x) / travel)
    }

    /// `:1687` — the release commits to one end. The continuum is for the hand, not for rest.
    static func snap(_ v: Double) -> Double { v > 0.5 ? 1 : 0 }

    /// `:1696` — a tap goes to the other end from wherever the target stands.
    static func toggle(_ v: Double) -> Double { v > 0.5 ? 0 : 1 }

    /// `:1689` — `if(was !== (to>0.5))`. **The voice sounds on the CROSSING, not on the
    /// gesture**: dragging from 0.2 to 0.4 and letting go is a movement that changes nothing,
    /// and it must be silent.
    static func crossed(was: Double, to: Double) -> Bool { (was > 0.5) != (to > 0.5) }

    /// `:1517`, one frame of the chase at 30fps-equivalent step.
    static func follow(_ lens: Double, target: Double, step: Double = 0.07) -> Double {
        lens + (target - lens) * step
    }

    /// `:1677` — the knob slides LEFT as the lens rises, and brightens as it goes.
    static func knobX(_ v: Double) -> Double { -v * 16 }
    static func knobAlpha(_ v: Double) -> Double { 0.42 + v * 0.34 }

    /// `:1437` / `:1676`. The two names the sky answers to.
    static let star = "the star lens"
    static let structure = "the structure lens"
    static func label(_ v: Double) -> String { v > 0.5 ? structure : star }

    private static func clamp(_ v: Double) -> Double { max(0, min(1, v)) }
}
