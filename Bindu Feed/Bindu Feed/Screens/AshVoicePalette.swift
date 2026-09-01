import SwiftUI

/// F8.1 – F8.4 · **THE TERRA PALETTE THIS SURFACE IS MADE OF.**
/// `Claude Design Round 1/comps/Ash's Voice.html:379-381` — `--a`, `--a08`, `--a20`.
///
/// Four rows were filed against this file and each named a different missing thing: a ring
/// where the design has a sphere, a card on the wrong ground, an inverted entry order, stats
/// in the wrong ink. **Three of the four are the same absence** — the comp defines a terra
/// palette in its `:root` and paints the whole screen from it, and the app reached for
/// `BinduTheme` at every site instead. One voice's page, in the app's general colours.
///
/// So the amounts live here once. Not because repetition is untidy, but because a palette
/// re-derived at four call sites is four chances to derive it differently — which is exactly
/// what happened: `terra.opacity(0.35)`, `terra.opacity(0.55)`, `terra.opacity(0.92)` and
/// `BinduTheme.bgInset`, none of them a value the design states.
enum AshVoice {
    /// `--a` — `#C47A52`. Ash's own colour, and the only hue on this screen.
    static let terra = Color(hex: "#C47A52")
    /// `--a08` — the card's ground. **A tint, not a panel**: at 8% the terra is barely there,
    /// which is what makes the page read as one voice's rather than as a list of cards.
    static let ground = Color(.sRGB, red: 196 / 255, green: 122 / 255, blue: 82 / 255, opacity: 0.08)
    /// `:487` — the card's own hairline.
    static let cardBorder = Color(.sRGB, red: 196 / 255, green: 122 / 255, blue: 82 / 255, opacity: 0.14)
    /// `:534` — the thread block's rule. **This is the only spine on the surface**, and it
    /// belongs to the quoted context, not to the card: the app had drawn one down the whole
    /// card at 0.55 and none beside the thing being answered, which says the entry is a quote
    /// and the quote is not.
    static let threadRule = Color(.sRGB, red: 196 / 255, green: 122 / 255, blue: 82 / 255, opacity: 0.25)
    /// `:591` — the highlight at 38%/38% of the sphere.
    static let highlight = Color(.sRGB, red: 220 / 255, green: 160 / 255, blue: 120 / 255, opacity: 0.9)

    /// `:596` — the glyph is **white at 0.88, not terra**. Terra-on-terra is the one
    /// combination that cannot be read, and it is what the app had: a terra glyph on a terra
    /// disc, legible only because the disc was too faint to be a disc.
    static let glyphInk = Color.white.opacity(0.88)
}
