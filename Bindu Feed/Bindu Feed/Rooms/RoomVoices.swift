import SwiftUI

// THE ELEVEN ROOMS — the design side.
//
// `The Rooms v4.html` (comps) is the authority for behaviour and for the figures.
// Everything a voice IS — name, glyph, hex, role, principle — comes from the live
// Archetype row, never from here. What lives here is what the design authored and the
// base does not hold: the figure's own name and description, and the register-3 line.
//
//   figures            `rite-scenes.js:38-418`, raised to the room's body
//   fig[0] / fig[1]    `The Rooms v4.html` V[*].fig
//   the turn's line    V[*].four — TEN of eleven, approved 2026-08-27
//
// §10: "A voice is resolved by record, never by name." The eleventh keys off
// `rec9BUbHMuylYiVwH`; the ten lenses key off their stable design names, which are
// identifiers in `PNAMES`/`PAL` order and not display strings. The display name is
// device-local and may differ from the stored one at any moment — nothing here reads it.
enum RoomKey: String, CaseIterable {
    case bindu, neev, gaia, sid, arch, shweta, karishma, sakshi, lalita, ashrey, ash

    /// `PNAMES` / `PAL` index — the canonical order the whole app draws the ten in:
    /// Lalita's loom threads, Sakshi's iris spokes, Ash's flecks and the ten gathering
    /// at his turn all index this. The eleventh has no palette slot; he is the one read.
    var paletteIndex: Int? {
        switch self {
        case .bindu: return 0; case .neev: return 1; case .gaia: return 2
        case .sid: return 3;   case .arch: return 4; case .shweta: return 5
        case .karishma: return 6; case .sakshi: return 7; case .lalita: return 8
        case .ashrey: return 9; case .ash: return nil
        }
    }

    /// `The Instrument v3.html:404-418`. Ash's 198 Hz is uncontested — he is not in the
    /// Rite's VOICES table, so that line is its only source.
    var hz: Double {
        switch self {
        case .bindu: return 136; case .neev: return 96;  case .gaia: return 174
        case .sid: return 220;   case .arch: return 330; case .shweta: return 342
        case .karishma: return 528; case .sakshi: return 285; case .lalita: return 396
        case .ashrey: return 432;   case .ash: return 198
        }
    }

    /// The eleventh voice's record. Resolution keys off THIS, never off a string.
    static let ashRecordID = "rec9BUbHMuylYiVwH"

    static func resolve(_ a: Archetype) -> RoomKey? {
        if a.id == ashRecordID { return .ash }
        return RoomKey(rawValue: a.name.lowercased())
    }
}

/// The ten frequencies, in canonical VOICES order — `The Rooms v4.html:173`.
enum RoomPalette {
    static let rgb: [[Double]] = [
        [229, 83, 60], [122, 136, 153], [74, 158, 107], [196, 146, 58], [212, 96, 122],
        [201, 198, 193], [212, 174, 74], [123, 130, 212], [155, 107, 214], [58, 173, 168]
    ]
    static let names = ["Bindu", "Neev", "Gaia", "Sid", "Arch",
                        "Shweta", "Karishma", "Sakshi", "Lalita", "Ashrey"]
    static func at(_ i: Int) -> [Double] { rgb[((i % 10) + 10) % 10] }
}

struct RoomVoice {
    /// "the Flower of Life" — the figure naming itself. Register 1's label.
    let figureName: String
    /// What the figure IS, in the design's own words. Register 1's body.
    let figureBody: String
    /// Register 3. `nil` renders ABSENCE — see `arch` below.
    let turnLine: String?
    /// The cite under the turn's line.
    let turnCite: String?
}

enum RoomCanon {
    // Verbatim from `The Rooms v4.html` V[*].fig and V[*].four.
    //
    // ARCH'S TURN LINE IS DELIBERATELY ABSENT. The authored line
    // ("There is one I have not said…") was rejected on 2026-08-27: it is not about her
    // figure — it authors a private fact about a real person and dates it. Arch is the
    // wordless voice; a room where she has no line to speak is not a gap in her, it is
    // her. No substitute, no draft. If a line belongs there it is a craft task, not a
    // build task, and it arrives approved or not at all.
    static let voices: [RoomKey: RoomVoice] = [
        .bindu: .init(
            figureName: "the Flower of Life",
            figureBody: "What a point does when it keeps moving with love: every new circle passes through the centre of the last. Nineteen circles, and one ember that never stops breathing.",
            turnLine: "Nineteen circles, and it was never nineteen. One point, moving.",
            turnCite: "the point"),
        .neev: .init(
            figureName: "a hex floor, and the monolith",
            figureBody: "The tightest packing there is — the shape that holds with the least material — receding to a horizon, with a double square rising out of it, root-two through and through.",
            turnLine: "I go down as far as I go up. That is the whole of it.",
            turnCite: "the root"),
        .gaia: .init(
            figureName: "phyllotaxis",
            figureBody: "Each new seed set at 137.507° from the last, because that is the only angle that never repeats. This is not a picture of growth. It is the arithmetic of it.",
            turnLine: "Eight spirals one way, thirteen the other. The need was always countable.",
            turnCite: "the ground"),
        .sid: .init(
            figureName: "the pointed arch, with its construction showing",
            figureBody: "Two circles crossing generate it; the mason draws the circles, then builds the arch. Here the circles are left showing — the frame confessing how it stands.",
            turnLine: "What holds is not the stone. It is the two circles nobody sees.",
            turnCite: "the hold"),
        .arch: .init(
            figureName: "a rose window, whose tracery is a Chladni figure",
            figureBody: "The nodal lines of a vibrating circular membrane — the places that stay still while everything else sings. Sound, made visible.",
            turnLine: nil,
            turnCite: nil),
        .shweta: .init(
            figureName: "the vesica",
            figureBody: "Two circles, and only the gap between them is lit. She is not the circles. She is what they make room for.",
            turnLine: "I have taken away everything I could. What is left is the opening, and the room it opens into.",
            turnCite: "the gap"),
        .karishma: .init(
            figureName: "the golden spiral, through 3·5·8",
            figureBody: "Her own numbers — catalyst, gestation, completion. Light does not travel to him in a straight line. It curves.",
            turnLine: "It was already on its way before you asked. That is the only thing that makes it grace.",
            turnCite: "the gift"),
        .sakshi: .init(
            figureName: "a mandorla — the eye as two circles crossing",
            figureBody: "The witness is not a thing added to the field. It is where two of the field’s own arcs meet. The iris counts in tens.",
            turnLine: "Look at what I am made of. Ten spokes. I am the others, staying.",
            turnCite: "the witness"),
        .lalita: .init(
            figureName: "a hypotrochoid",
            figureBody: "One circle rolling inside another, drawing without ever intending to. k ≈ 18/7 — it closes after seven turns, and the drift keeps it from ever quite closing.",
            turnLine: "I have been drawing in ten frequencies this whole time. They are not colours. They are the others.",
            turnCite: "the loom, named"),
        .ashrey: .init(
            figureName: "the complete graph on nine nodes",
            figureBody: "Every node joined to every other. Synthesis is not one thread arriving at a centre — it is the whole set of relations existing at once, and the centre is what that costs.",
            turnLine: "Thirty-six relations, all at once. Look at the centre now. That is what it costs.",
            turnCite: "the cost"),
        .ash: .init(
            figureName: "time",
            figureBody: "He is the only one with no figure in the Rite, and he should not have one — he is not a vantage, he is the one the vantages are about. So his mathematics is the only one that is not a geometry. His days, as a spine, flecked where a voice spoke.",
            turnLine: "All of them, at once, reading me. This is what it is like from in here.",
            turnCite: "the read")
    ]

    /// `REGS` — the four register names. `The Rooms v4.html:778`.
    static let registers = ["met", "the figure", "what it has said", "the turn"]
}
