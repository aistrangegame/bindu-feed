import SwiftUI

// The shared systems that later waves fill in. These are deliberate skeletons:
// each carries its locked numbers in doc comments so the interface is a promise,
// not a guess. Bodies arrive with the wave that first needs them. Nothing here is
// wired into the running app yet.

/// The patina — one shared aging value, rendered per material (sound detune/
/// lowpass, colour saturate, type ink-state, space strata depth). Amendment §11.
/// Locked: `age(days) = clamp(pow(days/1095, 0.55))`; saturation `1 − 0.30·a`;
/// breath multiplier `1 + 0.45·a`; grain `0.05 + 0.14·a`. Aged bed lowpass
/// 900 → 430, root −0.4% / fifth −0.6% flat, breath ×1.35, 0.07 Hz wobble.
struct Age {
    /// 0 (fresh) → 1 (fully aged, ~3 years). `days` since the record's moment.
    var value: Double = 0
    static func from(days: Double) -> Age {
        Age(value: min(max(pow(days / 1095, 0.55), 0), 1))
    }
}

/// The axis and its thirteen membranes — surfaces that resist force and *give*
/// when meant; once open, nearly free. Locked: shell `i = Z + 5`;
/// `presence = clamp(1.30 − |(Z+5) − i|·1.30, 0, 1)`; membranes at `Z+5 = s+0.5`;
/// open threshold `push ≥ 1`; passage `5.4s` (0.85s already-open). Default mode
/// is LONG (SHORT stays honestly kept behind the pill).
enum TravelMode { case long, short }
struct Travel {
    var mode: TravelMode = .long
    /// Target register on the single Z axis, −5 … +9.
    var z: Double = 0
}

/// The crossing as an event — wormhole inward / whitehole outward, two gates,
/// un-steerable, the camera leaves the hand. Locked: `Z = z0 + (z1−z0)·smoothstep(t)`;
/// gates at t = 0.34 and 0.68; aperture `((t−0.28)/0.72)^2.5`; landing bloom 0.75s.
/// One shared passage ships first; the fifteen destination-grammars are later polish.
struct Passage {
    var from: Double = 0
    var to: Double = 0
}

/// The ground inside a piece — one full-frame canvas per register; he can tell
/// where he is with the words covered. Locked: `tgt = max(worldDisp·0.5,
/// sectionsGiven/4)·CAP`, CAP 1 / 0.80 / 0.44; axis locks + world freezes at
/// `immersion > 0.55`; shell blur `+ immersion·11`.
struct Material {
    var immersion: Double = 0
}

/// The fifteenth register (Z = −5) — the Light. A held space, not a walk, so it
/// is exempt from `WalkableHierarchy`. Two materials: the dawn (Near, five Future
/// scenes) and the nave (Far, S-L06). Locked: stillness accumulator 4600ms; carve
/// press ≥ 900ms; release = three ungrips (`arrive = ungrips / 3`). Opens to the
/// absence of force, never to force. Wording canon lives in the extracted
/// `canon/spine-light.js`.
enum LightDepth { case near, far }
struct Light {
    var depth: LightDepth = .near
}

/// The ceremony handoff — carries the breath phase, the depth he left from, and
/// the ledger across the two document-ceremonies (the Rite, the Return) so a walk
/// reads as one breath. Locked: `sessionStorage['asf.walk']`, TTL 90 min; returns
/// to the axis at the depth left, on the breath left on; writes nothing back.
struct WalkContinuity {
    var z: Double = 0
    var breathPhase: Double = 0
}
