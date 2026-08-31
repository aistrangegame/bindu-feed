import SwiftUI

extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&value)
        let r, g, b, a: Double
        switch trimmed.count {
        case 6:
            r = Double((value & 0xFF0000) >> 16) / 255
            g = Double((value & 0x00FF00) >> 8) / 255
            b = Double(value & 0x0000FF) / 255
            a = 1
        case 8:
            r = Double((value & 0xFF000000) >> 24) / 255
            g = Double((value & 0x00FF0000) >> 16) / 255
            b = Double((value & 0x0000FF00) >> 8) / 255
            a = Double(value & 0x000000FF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

enum BinduTheme {
    static let bgDeep    = Color(hex: "#0E0C12")
    static let bgCard    = Color(hex: "#171420")
    static let bgInset   = Color(hex: "#121018")
    static let hairline  = Color.white.opacity(0.06)

    static let inkPrimary   = Color(hex: "#EDE8E3")
    static let inkSecondary = Color(hex: "#EDE8E3").opacity(0.60)
    static let inkTertiary  = Color(hex: "#EDE8E3").opacity(0.35)

    static let colorBindu    = Color(hex: "#E5533C")
    static let colorGaia     = Color(hex: "#4A9E6B")
    static let colorSid      = Color(hex: "#C4923A")
    static let colorArch     = Color(hex: "#D4607A")
    static let colorSakshi   = Color(hex: "#7B82D4")
    static let colorKarishma = Color(hex: "#D4AE4A")
    static let colorAshrey   = Color(hex: "#3AADA8")
    static let colorLalita   = Color(hex: "#9B6BD6")
    static let colorAsh      = Color(hex: "#C47A52")
    static let colorNeev     = Color(hex: "#7A8899")
    static let colorShweta   = Color(hex: "#ABA7A2")

    static let accent = colorLalita

    static let space4:  CGFloat = 4
    static let space8:  CGFloat = 8
    static let space12: CGFloat = 12
    static let space14: CGFloat = 14
    static let space16: CGFloat = 16
    static let space20: CGFloat = 20
    static let space24: CGFloat = 24
}

extension Font {
    // PostScript names from the registered variable fonts:
    //   Lora-Regular, Lora-Regular_Medium, Lora-Regular_SemiBold, Lora-Regular_Bold
    //   Lora-Italic,  Lora-Italic_Medium-Italic, Lora-Italic_SemiBold-Italic, Lora-Italic_Bold-Italic
    //   SpaceMono-Regular
    static func lora(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(loraPostScriptName(weight: weight, italic: false), size: size)
    }

    static func loraItalic(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(loraPostScriptName(weight: weight, italic: true), size: size)
    }

    /// **THE MONO FACE IS NOT AVAILABLE WITHOUT ITS CASE.** `fileprivate` on purpose: the
    /// two entry points below are the only ways to ask for it, and both uppercase. See the
    /// note on `spaceMonoTracked` for why case belongs to the role rather than to the string.
    fileprivate static func spaceMonoFace(_ size: CGFloat) -> Font {
        .custom("SpaceMono-Regular", size: size)
    }

    private static func loraPostScriptName(weight: Font.Weight, italic: Bool) -> String {
        let base = italic ? "Lora-Italic" : "Lora-Regular"
        let suffix: String? = {
            switch weight {
            case .medium:                   return italic ? "Medium-Italic" : "Medium"
            case .semibold:                 return italic ? "SemiBold-Italic" : "SemiBold"
            case .bold, .heavy, .black:     return italic ? "Bold-Italic" : "Bold"
            default:                        return nil
            }
        }()
        if let suffix { return "\(base)_\(suffix)" }
        return base
    }
}

struct PanelModifier: ViewModifier {
    var cornerRadius: CGFloat
    var fill: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
            )
    }
}

extension View {
    func panel(cornerRadius: CGFloat = 18, fill: Color = BinduTheme.bgCard) -> some View {
        modifier(PanelModifier(cornerRadius: cornerRadius, fill: fill))
    }
}

// MARK: - Tracking, in the unit the design authors it in

extension View {
    /// Space Mono at the design's own tracking.
    ///
    /// The comps author `letter-spacing` in **em**, and em is a multiple of the font size:
    /// `0.14em` on a 10pt label is **1.4pt**, not 14. Passing the em value through as points
    /// is what made ~20 chrome labels 55–85% too wide. `RoomStyle.heroTracking` (`:20`) has
    /// always done this multiply for the room heroes; nothing else did.
    ///
    /// Pass the size and the em straight off the comp — `spaceMonoTracked(10, em: 0.14)` —
    /// and let this do the arithmetic, so the call site keeps the design's own numbers.
    /// **CASE IS A PROPERTY OF THE ROLE, NOT OF THE STRING.** Three design sources define
    /// `.mono` with `text-transform:uppercase` INDEPENDENTLY — `The Light v2.html:25`,
    /// `The Point v9.html:16` and `Claude Design Round 1/The Return v2.html:923` — so every
    /// mono element in the design is uppercase by class. The app carried it per-string at 21
    /// sites and omitted it at the rest: the duplicated-contract shape, fourth instance.
    ///
    /// A label that genuinely should not uppercase opts out with `.textCase(nil)` — a
    /// decision with a name rather than an omission.
    ///
    /// **CANVAS-DRAWN TEXT IS THE ONE PLACE A MODIFIER CANNOT REACH**, and E1.18 is what
    /// happens when a law is documented as reaching everywhere it can and left to authors
    /// everywhere it cannot: `GraphicsContext.draw` takes a `Text`, `.textCase` returns
    /// `some View`, and 14 Canvas labels were drawing whatever case their string happened to
    /// carry. The note here previously ASSERTED that those labels uppercase their string
    /// instead. Most did. `Text("touch")` at `UniverseView` did not, and neither did five
    /// data labels — **a documented contract with no mechanism behind it is a comment, and
    /// this file was the thing telling readers the contract held.**
    ///
    /// So the face itself is `fileprivate` now and `Text.spaceMono(_:_:em:)` below is the
    /// Canvas door. Both doors uppercase; there is no third door. The wrong thing is not
    /// discouraged, it does not compile.
    func spaceMonoTracked(_ size: CGFloat, em: CGFloat = 0) -> some View {
        self.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size)
    }
}

/// **THE CASE RULE STOPS AT THE CANVAS, AND THE DESIGN SAYS SO IN ITS OWN CODE.**
/// `text-transform` is a CSS property of a DOM element; `fillText` never sees it. So the
/// comps case canvas text **one call at a time**, and they are not uniform about it:
/// `The Universe v3.html` has three `fillText(x.toUpperCase(), …)` and four plain ones — and
/// `:977` draws *"touch"* in lower case on the line after `:973` uppercases a name.
///
/// **THIS ALMOST BECAME A DEFECT OF ITS OWN.** The first version of this door uppercased
/// unconditionally, on the strength of the `.mono{text-transform:uppercase}` class rule. That
/// rule is real and governs every mono ELEMENT — and it would have silently uppercased
/// `'touch'`, `s.codex` and `st.name`, three labels the design deliberately leaves alone.
/// A law generalised one surface past its evidence.
///
/// So the Canvas door does not decide; it makes deciding unavoidable. There is no default.
enum MonoCase { case upper, asWritten }

extension Text {
    /// The mono face for `GraphicsContext.draw`, which needs a `Text` and cannot take a view
    /// modifier. The case is required, and each call site's answer comes from the
    /// corresponding `fillText` in the comp.
    static func spaceMono(_ s: String, _ size: CGFloat, em: CGFloat = 0, _ c: MonoCase) -> Text {
        Text(c == .upper ? s.uppercased() : s).font(.spaceMonoFace(size)).tracking(em * size)
    }
}
