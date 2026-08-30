import SwiftUI

// THE AXIS — fifteen registers on one Z coordinate (Z = −5 … +9). The running Feed
// is the Z=0 slice; the Universe pulls outward (−4…−1), the Point inward (+1…+9),
// the Light at −5. One continuous space: every register exists at every moment at
// its own scale; nothing is created or destroyed as he moves.
//
//   presence(i, Z) = clamp(1.30 − |(Z+5) − i|·1.30, 0, 1)   — how inhabited a
//   register is at a given Z (full at its exact scale, gone at ±1 unit).
//   rim(i, Z) = R0 · 2^((Z+5) − i)                          — its drawn radius.

/// What `#where` shows: at most a `top` line, the register's name in its own casing,
/// and at most a `sub`. `spine-axis.js:118-122` composes exactly two shapes and no
/// others — a Point register carries the roman and its `n of 7`, everything else
/// carries its sub-line. `dim` is NEVER rendered bare; only ever as "N of 7".
struct AxisWhere {
    let top: String?
    let name: String
    let sub: String?
}

struct AxisRegister: Identifiable {
    let i: Int          // index = Z + 5
    let z: Int
    let key: String
    let name: String
    let hz: Double
    /// The canon sub-line. Universe / Feed / gate / centre only — nil on the Point side.
    let sub: String?
    /// I…VII, and 1…7. Point side only — nil everywhere else. Mutually exclusive with `sub`.
    let roman: String?
    let dim: Int?
    var id: Int { i }

    init(i: Int, z: Int, key: String, name: String, hz: Double,
         sub: String? = nil, roman: String? = nil, dim: Int? = nil) {
        self.i = i; self.z = z; self.key = key; self.name = name; self.hz = hz
        self.sub = sub; self.roman = roman; self.dim = dim
    }

    /// `spine-axis.js:118-122` — two shapes, never a third.
    var whereBlock: AxisWhere {
        if let roman, let dim {
            return AxisWhere(top: "\(roman) · \(dim) of 7", name: name, sub: nil)
        }
        return AxisWhere(top: nil, name: name, sub: sub)
    }

    /// The chrome hue — the rail, the particle, the register tint. This is the canvas
    /// `HUE[]` at The Instrument v3.html:3423-3424, NOT the shader's `base[]`
    /// (spine-field.js:204-206), which colours the atmosphere shells and lives verbatim
    /// in InstrumentField.metal. Two palettes, two jobs; do not reconcile them.
    ///
    /// `region`/`world`/`fall` are overwritten at runtime with the room he is actually
    /// in — see `Axis.roomHue`. The value here is only the resting colour before a room
    /// is known. "The Universe side is never generic."
    var color: Color {
        switch key {
        case "light":  return Color(hex: "#EDE3CE")
        case "sky":    return Color(hex: "#7C8698")
        case "region", "world", "fall":
            return Color(hex: Axis.roomHue ?? "#8A93A6")
        case "feed":   return Color(hex: "#C9A07A")
        case "gate":   return Color(hex: "#C0392B")
        case "centre": return Color(hex: "#E5533C")   // the particle; BinduParticle agrees
        default:
            // +2…+8 → the seven Point dimensions m1…m7.
            let m = "m\(z - 1)"
            return Color(hex: PointContent.hues[m] ?? "#C0392B")
        }
    }
}

enum Axis {
    /// Sub-lines and romans verbatim from The Chrome.html:134-148, cross-checked against
    /// spine-axis.js:40-55. NOTE spine-axis.js is the pre-Light 14-register extraction
    /// (Z0=−4, NSHELL=14) — its STRINGS are canon, its INDEXING is not. This table is
    /// fifteen, i = Z + 5, matching InstrumentField.metal:188 `float zi = uZ + 5.0`.
    static let registers: [AxisRegister] = [
        .init(i: 0,  z: -5, key: "light",  name: "the Light",   hz: 174,   sub: "what has not yet been"),
        .init(i: 1,  z: -4, key: "sky",    name: "the sky",     hz: 110,   sub: "everything you have lived"),
        .init(i: 2,  z: -3, key: "region", name: "a region",    hz: 174,   sub: "one room of the Feed"),
        .init(i: 3,  z: -2, key: "world",  name: "a world",     hz: 198,   sub: "one story, close"),
        .init(i: 4,  z: -1, key: "fall",   name: "the fall",    hz: 84,    sub: "who sat with it · what you left here"),
        .init(i: 5,  z: 0,  key: "feed",   name: "the Feed",    hz: 136.1, sub: "the turn"),
        .init(i: 6,  z: 1,  key: "gate",   name: "the gate",    hz: 174,   sub: "the deal"),
        .init(i: 7,  z: 2,  key: "d1",     name: "The Point",   hz: 285,   roman: "I",   dim: 1),
        .init(i: 8,  z: 3,  key: "d2",     name: "The Turn",    hz: 396,   roman: "II",  dim: 2),
        .init(i: 9,  z: 4,  key: "d3",     name: "The Veil",    hz: 417,   roman: "III", dim: 3),
        .init(i: 10, z: 5,  key: "d4",     name: "The Chamber", hz: 528,   roman: "IV",  dim: 4),
        .init(i: 11, z: 6,  key: "d5",     name: "The Mirrors", hz: 639,   roman: "V",   dim: 5),
        .init(i: 12, z: 7,  key: "d6",     name: "The Return",  hz: 741,   roman: "VI",  dim: 6),
        .init(i: 13, z: 8,  key: "d7",     name: "The Dance",   hz: 852,   roman: "VII", dim: 7),
        .init(i: 14, z: 9,  key: "centre", name: "the centre",  hz: 963,   sub: "the point, at last"),
    ]

    /// The room he is actually in, as a hex. `spine-field.js:211-216 setRoom()` overwrites
    /// the region/world/fall slots with it on every room change — "so the Universe side is
    /// never generic". nil until a room is known.
    /// **SHARED STATIC · any test suite touching this is `.serialized`** (§10 TENTH SHAPE).
    /// The rule is *at creation, not at flake* — `PointReturn` and `PointDance` cost a pass to
    /// learn it. Nothing tests this yet; the first suite that does inherits the trap.
    static var roomHue: String?

    static let minZ: Double = -5
    /// ZN + 0.62. The overshoot past the centre is where `bindu.fill()` completes and the
    /// centre blooms — `spine-axis.js:87` `clamp: max(Z0, min(ZN+0.62, Z))`. A clamp at 9.0
    /// makes the centre unreachable.
    static let maxZ: Double = 9.62

    static func presence(_ i: Int, _ z: Double) -> Double {
        max(0, min(1, 1.30 - abs((z + 5) - Double(i)) * 1.30))
    }

    /// The register nearest a given Z.
    static func nearest(_ z: Double) -> AxisRegister {
        registers[max(0, min(14, Int((z + 5).rounded())))]
    }

    static func clampZ(_ z: Double) -> Double { max(minZ, min(maxZ, z)) }
}

/// The shader's own driven quantities, as functions rather than literals.
///
/// C4.5 · six of eight were `.float(0)` with a *"Phase 2"* comment. They are not phase-two
/// features: the shader computes with every one of them and has been multiplying by zero.
enum InstrumentField {
    /// `The Instrument v3.html:5589` — `reveal: Math.max(0, (Z - 8.6) / 0.9)`.
    ///
    /// **Nothing until the last 0.4 of the axis, then a ramp to 1 exactly at the centre.**
    /// `z 9` is *the point, at last*, and `(9 − 8.6)/0.9 = 0.444`… which does NOT reach 1 —
    /// the ramp is written to keep climbing past the register, to `z 9.5`, and the axis clamps
    /// at `9.62`. So the bloom is still opening as he arrives and is at its fullest just past
    /// it: the design does not put the maximum on the register, it puts it beyond.
    static func reveal(z: Double) -> Double { max(0, (z - 8.6) / 0.9) }
}
