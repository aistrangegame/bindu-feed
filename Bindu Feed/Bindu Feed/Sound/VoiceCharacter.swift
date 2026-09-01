import Foundation

// THE ELEVEN VOICES, AS SOUND — `field-sound.js:13-25 CHAR`, value for value.
//
//   *"Each presence's own body… the same tuning as the bed, differing only in body and
//    behaviour."*
//
// PITCH AND TIMBRE COME FROM DIFFERENT TABLES, AND THEY DISAGREE. `field-sound.js:27` also
// carries an `HZ` map, and it is NOT the pitch: on six voices the two tables differ, four of
// them audibly —
//
//        VOICES (pitch)   HZ (superseded)
//   shweta      342             329
//   karishma    528             392
//   ashrey      432             196          ← an octave and a fifth apart
//   ash         198             261
//   sakshi      285             285          (agree)
//   lalita      396             396          (agree)
//
// RULED: **pitch from `The Instrument v3.html:404-418` VOICES, timbre from CHAR.** `HZ` is
// the older per-presence tone from before the axis had a ladder; taking it would put Ashrey a
// tenth below where the instrument sings him. Ash's 198 is uncontested — he is not in the
// Rite's table, so `:415` is its only source — and his timbre is `CHAR['ash']`.
struct VoiceCharacter: Equatable, Sendable {
    /// `sine` or `triangle` — the only two the design uses.
    let wave: Wave
    /// Partial ratios, summed. Inharmonic values are deliberate (karishma's 3.02 beats).
    let partials: [Double]
    let gain: Double
    /// Attack and release, in seconds. Shweta's 4.0/9.0 is why she arrives last and stays.
    let atk: Double, rel: Double
    let pan: Double
    /// Optional bodies. Nil is the common case and means "nothing extra happens".
    var flicker: Double? = nil     // bindu — 6.2 Hz tremolo
    var vib: Double? = nil         // arch — 4.6 Hz vibrato
    var air: Double? = nil         // shweta — breath noise at 0.028
    var shimmer: Bool = false      // karishma — the unearned gift
    var gliss: Double? = nil       // lalita — a 1.02 slide, the play awake

    enum Wave: Sendable { case sine, triangle }

    /// Keyed by the voice's key, exactly as `CHAR` is.
    static let all: [String: VoiceCharacter] = [
        "bindu":    .init(wave: .sine,     partials: [1, 2, 3],     gain: 0.055, atk: 0.6, rel: 5.0, pan: 0,     flicker: 6.2),
        "neev":     .init(wave: .sine,     partials: [0.5, 1],      gain: 0.07,  atk: 3.4, rel: 8.0, pan: -0.15),
        "gaia":     .init(wave: .triangle, partials: [1, 1.5],      gain: 0.05,  atk: 1.6, rel: 6.0, pan: -0.3),
        "sid":      .init(wave: .sine,     partials: [1, 1.2],      gain: 0.05,  atk: 1.2, rel: 6.5, pan: 0.25),
        "arch":     .init(wave: .triangle, partials: [1, 2],        gain: 0.048, atk: 0.9, rel: 4.5, pan: 0.35, vib: 4.6),
        "shweta":   .init(wave: .sine,     partials: [1],           gain: 0.012, atk: 4.0, rel: 9.0, pan: 0,    air: 0.028),
        "karishma": .init(wave: .sine,     partials: [1, 2, 3.02],  gain: 0.036, atk: 2.0, rel: 7.0, pan: 0.4,  shimmer: true),
        "sakshi":   .init(wave: .sine,     partials: [1],           gain: 0.026, atk: 5.0, rel: 10.0, pan: -0.4),
        "ashrey":   .init(wave: .sine,     partials: [1, 2],        gain: 0.042, atk: 1.4, rel: 6.0, pan: 0.15),
        "lalita":   .init(wave: .sine,     partials: [1, 1.5],      gain: 0.04,  atk: 2.2, rel: 8.0, pan: 0,    gliss: 1.02),
        "ash":      .init(wave: .sine,     partials: [1, 2, 4],     gain: 0.05,  atk: 1.0, rel: 5.5, pan: 0),
    ]

    /// Resolution is by KEY, and the key is resolved from the record — never from a display
    /// name. `RoomKey.resolve` already does that off `rec9BUbHMuylYiVwH` for Ash.
    static func of(_ key: String) -> VoiceCharacter? { all[key.lowercased()] }
}

// THE POINT'S LADDER — `point-sound.js:10-11`, verbatim.
//
//   *"Nine steps up into the unknown, landing home one octave down. Beating narrows
//    8.0 → 4.0 Hz (alpha into theta)."*
//
// The beat is what makes this surface different from every other one. A field room hums at a
// fixed colour; the Point CLIMBS, and the narrowing beat is the climb made audible. That is
// the whole reason the binaural pair belongs here and nowhere else.
enum PointLadder {
    static let freqs: [Double] = [174, 285, 396, 417, 528, 639, 741, 852, 963, 136.1]
    static let beats: [Double] = [8, 7.5, 7, 6.5, 6, 5.5, 5, 4.5, 4.2, 4]

    /// Enclosure index → its drone. Index 9 is the bindu: home, an octave down (136.1, OM).
    static func drone(_ i: Int) -> (hz: Double, beat: Double) {
        let k = max(0, min(freqs.count - 1, i))
        return (freqs[k], beats[k])
    }
}
