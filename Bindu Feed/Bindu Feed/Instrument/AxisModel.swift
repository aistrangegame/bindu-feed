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

/// C5.6 · the particle's own name at a point on the axis, and the ground band.
///
/// Lifted out of `InstrumentView` so the DOMAIN can be walked. `check_authored` proves the
/// nine literals exist; nothing could ask **which z reaches one** — and four of them were
/// reachable by no state at all, fenced behind a Universe-wide guard. A string that exists
/// and cannot be reached passes every checker in this build.
enum InstrumentNames {
    /// `The Instrument v3.html:1070-1080` — nine names, thresholds
    /// `−4.4, −3.4, −2.4, −1.4, −0.4, 0.6, 1.6, 8.6`.
    static func particle(_ z: Double) -> String {
        switch z {
        case ..<(-4.4): return "a light that has not yet risen"
        case ..<(-3.4): return "a dot in the sky"
        case ..<(-2.4): return "a light in the room"
        case ..<(-1.4): return "the story, close"
        case ..<(-0.4): return "the seed of the well"
        case ..<0.6:    return "the dot in the post"
        case ..<1.6:    return "the dot at the gate"
        case ..<8.6:    return "the point at the centre of the enclosure"
        default:        return "the point"
        }
    }

    /// `:5646` — `onGround(|Z| < 0.42)`. The app had `0.4`.
    static func onGround(z: Double) -> Bool { abs(z) < 0.42 }
}

/// C5.7 · the particle's screen radius — `The Instrument v3.html:1062-1066`.
///
///     base = 3.4 + br*0.9
///     grow = max(0, (Z - 8.4)/1.1)
///     r    = base * (1 + grow*grow*9)
///
/// **THE SMALLNESS IS THE ARGUMENT.** `:1056-1058` — *"Its screen radius is fixed across the
/// whole axis — that is what makes it the only fixed thing — except at the centre, where it
/// stops being a dot in a world and becomes the world."* The app had `5.0 + 4.0*br`: **twice
/// the resting diameter and 4.4× the breath depth.** A particle that breathes visibly is not
/// a fixed thing; it is another moving element in an instrument where everything else moves,
/// and the one point that was supposed to hold still stops holding.
///
/// The `grow` term was already right. What was wrong is the base — the part that never
/// changes and therefore never draws attention to itself unless it is too big.
enum BinduParticleRadius {
    static func base(breath: Double) -> Double { 3.4 + breath * 0.9 }
    static func grow(z: Double) -> Double { max(0, (z - 8.4) / 1.1) }
    static func radius(z: Double, breath: Double) -> Double {
        let g = grow(z: z)
        return base(breath: breath) * (1 + g * g * 9)
    }
}

/// C3.5 + C3.6 · the membrane's body and the gate's rim — `The Instrument v3.html:3505-3535`.
///
/// **ONE `draw` SERVES BOTH, and the branch is the whole point.** `:3511-3512`: *"the gate
/// does not tighten as he nears it — it THINS as he stops. Its radius opens with his stillness
/// instead of closing with his force."* Two opposite gestures rendered by one ring, which is
/// why they were filed as two audit rows (C3.5 MAJOR, C3.6 MINOR) and are one mechanism.
///
/// The app drew both as plain stroked ellipses: no wobble, no beads, no radial fill. A ring
/// that does not wobble has no surface — it reads as a drawn circle rather than a membrane
/// being leaned into, which is the entire sensation the register boundary exists to give.
enum MembraneRing {
    /// `:3516` — the radius. Membrane closes with tension; gate OPENS with stillness.
    static func radius(R0: Double, tension: Double, gate: Bool, still: Double) -> Double {
        gate ? R0 * (1.10 + still * 1.30) : R0 * (1.62 - 0.92 * tension)
    }

    /// `:3517` — wobble depth. The gate's wobble DIES as he stills (`0.030*(1−st)`); the
    /// membrane's GROWS as he pushes (`0.014 + push*0.055`). Opposite again, and the reason
    /// one constant could not serve both.
    static func wobble(gate: Bool, still: Double, push: Double) -> Double {
        gate ? 0.030 * (1 - still) : 0.014 + push * 0.055
    }

    /// `:3519-3521` — the ring's own outline, 132 segments.
    /// `rr = r·(1 + wob·sin(7a + 1.9t)·sin(3a − 1.1t))` — two incommensurate frequencies, so
    /// the surface never repeats within a turn.
    static func segments(r: Double, wobble w: Double, t: Double, count: Int = 132) -> [Double] {
        (0...count).map { k in
            let a = Double(k) / Double(count) * 2 * Double.pi
            return r * (1 + w * sin(a * 7 + t * 1.9) * sin(a * 3 - t * 1.1))
        }
    }

    /// `:3524` — stroke alpha. The membrane carries a `push` term the app dropped entirely.
    static func strokeAlpha(gate: Bool, tension: Double, still: Double, push: Double) -> Double {
        gate ? 0.06 + still * 0.40 : 0.10 + tension * 0.44 + push * 0.30
    }
    /// `:3525` — `0.7 + push*1.5`. The app used `tension`, so leaning changed nothing.
    static func lineWidth(push: Double) -> Double { 0.7 + push * 1.5 }

    /// `:3530-3532` — nine beads riding the wobble at `t*0.5 + b/9·TAU`.
    static func beadAngles(t: Double, count: Int = 9) -> [Double] {
        (0..<count).map { t * 0.5 + Double($0) / Double(count) * 2 * Double.pi }
    }
    static func beadRadius(r: Double, wobble w: Double, angle: Double, t: Double) -> Double {
        r * (1 + w * 0.6 * sin(angle * 7 + t * 1.9))
    }
    static func beadSize(push: Double) -> Double { 0.9 + push * 1.9 }
    static func beadAlpha(gate: Bool, still: Double, push: Double) -> Double {
        gate ? 0.10 + still * 0.55 : 0.15 + push * 0.6
    }

    /// The whole ring, in one place, so the membrane and the gate cannot drift apart.
    @MainActor
    static func draw(_ ctx: GraphicsContext, cx: Double, cy: Double, R0: Double, t: Double,
                     color: Color, tension: Double, push: Double, gate: Bool, still: Double) {
        let r = radius(R0: R0, tension: tension, gate: gate, still: still)
        let w = wobble(gate: gate, still: still, push: push)
        let rs = segments(r: r, wobble: w, t: t)

        var ring = Path()
        for (k, rr) in rs.enumerated() {
            let a = Double(k) / Double(rs.count - 1) * 2 * Double.pi
            let p = CGPoint(x: cx + cos(a) * rr, y: cy + sin(a) * rr)
            k == 0 ? ring.move(to: p) : ring.addLine(to: p)
        }
        ring.closeSubpath()
        ctx.stroke(ring,
                   with: .color(color.opacity(strokeAlpha(gate: gate, tension: tension,
                                                          still: still, push: push))),
                   lineWidth: lineWidth(push: push))

        // `:3527-3529` — zero at the centre, so it is a RIM GLOW and the inside stays empty.
        ctx.fill(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                 with: .radialGradient(
                    Gradient(stops: [
                        .init(color: color.opacity(0), location: 0.35),
                        .init(color: color.opacity(tension * 0.05), location: 0.86),
                        .init(color: color.opacity(fillOuterAlpha(gate: gate, tension: tension,
                                                                  still: still)), location: 1)]),
                    center: CGPoint(x: cx, y: cy), startRadius: r * 0.35, endRadius: r))

        // `:3530-3532` — nine beads riding the same wobble, one turn every 4π seconds.
        let bs = beadSize(push: push)
        let ba = beadAlpha(gate: gate, still: still, push: push)
        for angle in beadAngles(t: t) {
            let rb = beadRadius(r: r, wobble: w, angle: angle, t: t)
            let x = cx + cos(angle) * rb, y = cy + sin(angle) * rb
            ctx.fill(Path(ellipseIn: CGRect(x: x - bs, y: y - bs, width: bs * 2, height: bs * 2)),
                     with: .color(color.opacity(ba)))
        }
    }

    /// `:3527-3529` — the fill's outer stop. Zero at the centre, so it is a rim glow rather
    /// than a disc: the ring has an inside that stays empty.
    static func fillOuterAlpha(gate: Bool, tension: Double, still: Double) -> Double {
        gate ? still * 0.13 : tension * 0.16
    }
}
