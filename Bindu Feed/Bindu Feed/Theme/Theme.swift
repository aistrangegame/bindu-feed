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

    static func spaceMono(_ size: CGFloat) -> Font {
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
