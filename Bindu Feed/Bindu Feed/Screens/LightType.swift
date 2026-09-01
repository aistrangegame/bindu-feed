import CoreGraphics

/// E1.17 · **THE LIGHT'S TYPE SCALE.** `The Light v2.html:826-853`.
///
/// In this register the type is the only voice — there is no chrome, no card, no label — so
/// its sizes carry meaning that would be decoration anywhere else. Two of these numbers are
/// mechanisms:
///
/// · **The whole travels, 21 → 15** (`:827-828`, transitioned over 2.6s together with its
///   colour and line-height). It arrives at the size of the only thing on the floor, and
///   demotes itself to a heading once the anchors have taken over. The app held it at a fixed
///   19 — between the two, so it was never either, and the settling never happened.
/// · **The Declaration is 21 and carries NO extra weight** (`:841`). The app set `.semibold`
///   to make it read as cut; the comp cuts it with the shadow pair at `:30` instead. Weight
///   and deboss look alike in a still and behave differently as the line surfaces.
enum LightType {

    /// `:827` — living-and-alone, then settled.
    static func wholeSize(alone: Bool) -> CGFloat { alone ? 21 : 15 }
    /// `lineHeight` 1.5 → 1.6. SwiftUI's `lineSpacing` is the gap, so it is `size·(f − 1)`.
    static func wholeLeading(alone: Bool) -> CGFloat {
        let s = wholeSize(alone: alone)
        return s * ((alone ? 1.5 : 1.6) - 1)
    }
    /// `letterSpacing:-0.014em` on the whole, `-0.012em` on the Declaration.
    static func wholeTracking(alone: Bool) -> CGFloat { wholeSize(alone: alone) * -0.014 }

    /// `:835` — 16.5/1.7. Between the settled whole and the Declaration, which is where an
    /// anchor sits in the register: more than a heading, less than a vow.
    static let anchorSize: CGFloat = 16.5
    static let anchorLeading: CGFloat = anchorSize * 0.7
    /// `:836` — the gap below each anchor.
    static let anchorGap: CGFloat = 14

    /// `:841` — the same 21 the whole ARRIVED at. The Declaration does not grow past the
    /// opening; it takes the opening's own size back after the anchors have shrunk it.
    static let beatSize: CGFloat = 21
    static let beatLeading: CGFloat = beatSize * 0.5
    static let beatTracking: CGFloat = beatSize * -0.012
    static let beatGap: CGFloat = 11

    /// `:853` — 18/1.6, italic, settled.
    static let landingSize: CGFloat = 18
    static let landingLeading: CGFloat = landingSize * 0.6

    /// `:824` — the whole is flush against the anchors while it is alone, and opens a gap once
    /// it has been received.
    static func wholeGap(alone: Bool) -> CGFloat { alone ? 0 : 18 }
}
