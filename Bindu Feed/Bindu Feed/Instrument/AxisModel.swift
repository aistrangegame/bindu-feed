import SwiftUI

// THE AXIS — fifteen registers on one Z coordinate (Z = −5 … +9). The running Feed
// is the Z=0 slice; the Universe pulls outward (−4…−1), the Point inward (+1…+9),
// the Light at −5. One continuous space: every register exists at every moment at
// its own scale; nothing is created or destroyed as he moves.
//
//   presence(i, Z) = clamp(1.30 − |(Z+5) − i|·1.30, 0, 1)   — how inhabited a
//   register is at a given Z (full at its exact scale, gone at ±1 unit).
//   rim(i, Z) = R0 · 2^((Z+5) − i)                          — its drawn radius.

struct AxisRegister: Identifiable {
    let i: Int          // index = Z + 5
    let z: Int
    let key: String
    let name: String
    let hz: Double
    var id: Int { i }
    var color: Color {
        // Point registers wear their dimension hue; the rest a neutral ink.
        switch key {
        case "light":  return Color(hex: "#EDE3CE")
        case "sky", "region", "world", "fall": return Color(hex: "#9FB2C4")
        case "feed":   return Color(hex: "#E5533C")
        case "gate":   return Color(hex: "#C9A07A")
        default:
            // +2…+8 → the seven Point dimensions m1…m7.
            let m = "m\(z - 1)"
            return Color(hex: PointContent.hues[m] ?? "#C0392B")
        }
    }
}

enum Axis {
    static let registers: [AxisRegister] = [
        .init(i: 0,  z: -5, key: "light",  name: "the Light",  hz: 174),
        .init(i: 1,  z: -4, key: "sky",    name: "the sky",    hz: 110),
        .init(i: 2,  z: -3, key: "region", name: "a region",   hz: 174),
        .init(i: 3,  z: -2, key: "world",  name: "a world",    hz: 198),
        .init(i: 4,  z: -1, key: "fall",   name: "the fall",   hz: 84),
        .init(i: 5,  z: 0,  key: "feed",   name: "the Feed",   hz: 136.1),
        .init(i: 6,  z: 1,  key: "gate",   name: "the gate",   hz: 174),
        .init(i: 7,  z: 2,  key: "d1",     name: "The Point",  hz: 285),
        .init(i: 8,  z: 3,  key: "d2",     name: "The Turn",   hz: 396),
        .init(i: 9,  z: 4,  key: "d3",     name: "The Veil",   hz: 417),
        .init(i: 10, z: 5,  key: "d4",     name: "The Chamber", hz: 528),
        .init(i: 11, z: 6,  key: "d5",     name: "The Mirrors", hz: 639),
        .init(i: 12, z: 7,  key: "d6",     name: "The Return",  hz: 741),
        .init(i: 13, z: 8,  key: "d7",     name: "The Dance",   hz: 852),
        .init(i: 14, z: 9,  key: "centre", name: "the centre",  hz: 963),
    ]

    static let minZ: Double = -5
    static let maxZ: Double = 9.0

    static func presence(_ i: Int, _ z: Double) -> Double {
        max(0, min(1, 1.30 - abs((z + 5) - Double(i)) * 1.30))
    }

    /// The register nearest a given Z.
    static func nearest(_ z: Double) -> AxisRegister {
        registers[max(0, min(14, Int((z + 5).rounded())))]
    }

    static func clampZ(_ z: Double) -> Double { max(minZ, min(maxZ, z)) }
}
