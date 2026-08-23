import SwiftUI

// The thirteen rooms' bespoke title typographies and TWO glyph scales (Game View hero vs Room
// Selection portal), as design constants. A single Airtable `Glyph Size` field can hold neither
// two scales nor thirteen distinct type treatments, so — like the authored hero stats and the
// per-room hero gradients — they live here in code, verbatim from the comps
// (Game View.html nameStyle/glyphSize · Room Selection.html gSize).
struct RoomStyle {
    let heroSize: CGFloat
    let heroWeight: Font.Weight
    let heroItalic: Bool
    let heroTrackingEm: CGFloat      // em (as authored); × size at render
    let uppercase: Bool
    let heroGlyph: CGFloat           // Game View hero glyph
    let portalGlyph: CGFloat         // Room Selection portal glyph

    var heroFont: Font {
        heroItalic ? .loraItalic(heroSize, weight: heroWeight) : .lora(heroSize, weight: heroWeight)
    }
    var heroTracking: CGFloat { heroTrackingEm * heroSize }

    static func forRoom(_ name: String) -> RoomStyle {
        switch name {
        case "A Maya Game":     return .init(heroSize: 23, heroWeight: .medium,  heroItalic: false, heroTrackingEm: 0,     uppercase: false, heroGlyph: 70, portalGlyph: 48)
        case "The Garden":      return .init(heroSize: 23, heroWeight: .medium,  heroItalic: false, heroTrackingEm: 0,     uppercase: false, heroGlyph: 60, portalGlyph: 44)
        case "The Watcher":     return .init(heroSize: 17, heroWeight: .regular, heroItalic: false, heroTrackingEm: 0.16,  uppercase: true,  heroGlyph: 52, portalGlyph: 42)
        case "The Descent":     return .init(heroSize: 24, heroWeight: .medium,  heroItalic: true,  heroTrackingEm: -0.02, uppercase: false, heroGlyph: 44, portalGlyph: 34)
        case "The Return":      return .init(heroSize: 24, heroWeight: .regular, heroItalic: true,  heroTrackingEm: 0,     uppercase: false, heroGlyph: 78, portalGlyph: 50)
        case "The Forgetting":  return .init(heroSize: 22, heroWeight: .regular, heroItalic: false, heroTrackingEm: 0,     uppercase: false, heroGlyph: 52, portalGlyph: 44)
        case "The Remembering": return .init(heroSize: 22, heroWeight: .regular, heroItalic: false, heroTrackingEm: 0,     uppercase: false, heroGlyph: 54, portalGlyph: 44)
        case "The Body":        return .init(heroSize: 23, heroWeight: .regular, heroItalic: false, heroTrackingEm: 0,     uppercase: false, heroGlyph: 60, portalGlyph: 46)
        case "The Thread":      return .init(heroSize: 22, heroWeight: .regular, heroItalic: false, heroTrackingEm: 0.08,  uppercase: false, heroGlyph: 54, portalGlyph: 44)
        case "The Circle":      return .init(heroSize: 23, heroWeight: .regular, heroItalic: false, heroTrackingEm: -0.01, uppercase: false, heroGlyph: 56, portalGlyph: 44)
        case "The Signal":      return .init(heroSize: 22, heroWeight: .regular, heroItalic: false, heroTrackingEm: 0.06,  uppercase: false, heroGlyph: 56, portalGlyph: 44)
        case "The Forge":       return .init(heroSize: 23, heroWeight: .medium,  heroItalic: false, heroTrackingEm: 0,     uppercase: false, heroGlyph: 56, portalGlyph: 42)
        case "The Field":       return .init(heroSize: 24, heroWeight: .regular, heroItalic: true,  heroTrackingEm: 0,     uppercase: false, heroGlyph: 68, portalGlyph: 52)
        default:                return .init(heroSize: 23, heroWeight: .regular, heroItalic: false, heroTrackingEm: 0,     uppercase: false, heroGlyph: 56, portalGlyph: 44)
        }
    }
}
