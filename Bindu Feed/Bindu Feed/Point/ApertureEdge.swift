import SwiftUI

// WHERE THIS LIBRARY STOPS — the Aperture's fourth line, and the sharpest thing it says.
//
// `The Aperture.html:92-93`: *"The best thing the Aperture can say without a model is a
// claim about ITSELF, not about the tradition. Some registers have a nearest walked star.
// Many have nothing next to them at all, and the card says so plainly: this library has
// nothing beside it. Those are the best cards."*
//
// The comp shipped this deliberately under-claimed — it could only read ten stars — and
// asked for it to be completed against the full 66. This is that completion.
//
// TWO RULES GOVERN EVERY ENTRY.
//
//  1 · ONLY A WALKED STAR MAY BE CLAIMED. The card's sentence is "the nearest thing this
//      library HAS WALKED", and `SM` is precise about the difference: `w` walked, `p` in
//      progress, `s` seeded — `STL` spells the last one "SEEDED ○ — NOT YET WALKED". The
//      comp's own table claims `x-cycles · Deep time` for Samhain and for the Norns, and
//      `x-cycles` is SEEDED. Both are re-pointed here at walked stars; that is a correction
//      to the comp, not a preference, and it is the kind of thing only the full 66 reveals.
//  2 · NOTHING BESIDE IT IS THE DEFAULT, and it is not a failure. Eight of the 37 keep it,
//      because a claim a reader would not nod at is worse than an empty edge.
//
// This is a claim about the contents of THIS library, checkable against the 66 — which is
// exactly what the authored `origin` table was not, and why that table is gone.
enum ApertureEdge {
    /// register key → (star key, star title). Absent = nothing beside it.
    static let table: [String: (key: String, title: String)] = [
        // ── from the comp, unchanged ──
        "Qalb": ("t-treasure", "The hidden treasure"),
        "Fana": ("t-oneall", "The One is the All"),
        "Baqa": ("t-oneall", "The One is the All"),
        "Sabr": ("c-compression", "The pressure is the point"),
        "Ridā": ("c-compression", "The pressure is the point"),
        "Awen": ("d-poets", "The singers"),
        "the middle cauldron turning": ("d-poets", "The singers"),
        "the sixth ox-herding picture": ("d-marketplace", "Return to the marketplace"),
        "the tenth ox-herding picture": ("d-marketplace", "Return to the marketplace"),
        "Nafs": ("v-inherit", "95% inheritance"),
        "Ma’at": ("v-diagnostic", "The belief diagnostic"),
        "Sila": ("p-exist", "You exist"),
        "Wuji": ("p-exist", "You exist"),
        "a songline": ("r-ritual", "Ritual & festival"),
        "the Rainbow Serpent": ("r-ritual", "Ritual & festival"),
        "Eshu": ("r-ritual", "Ritual & festival"),

        // ── re-pointed: the comp claimed `x-cycles`, which is SEEDED ──
        "Samhain": ("x-window", "The window is open"),          // a thinned veil is an open window
        "the Norns": ("c-frames", "Shift between frames"),      // past as a property of the frame now selects

        // ── completed against the full 66 ──
        "Sirr": ("p-turiya", "Turiya"),                         // the innermost, beneath the three states
        "Tawakkul": ("c-fruits", "Action, never the fruits"),   // trust IS the release of the outcome
        "Coire Sois": ("d-poets", "The singers"),               // the crown cauldron is the poet's
        "Coire Érmai": ("d-poets", "The singers"),              // the same manuscript, the middle vessel
        "the lower dan tian": ("c-bindutree", "Blink · Breathe · Press"),  // a body-locus breath practice
        "the bardo of dream": ("r-dream", "Dream & journey"),
        "the bardo of becoming": ("x-choose", "Choose by frequency"),      // where the next birth is selected
        "Orí": ("x-volunteer", "You volunteered"),              // the destiny chosen before birth
        "the waning crescent": ("c-change", "Everything changes"),
        "Kshitigarbha": ("d-marketplace", "Return to the marketplace"),    // returning to the deepest places to help
        "the illuminative way": ("v-gnosis", "The gnosis current"),        // illumination as direct knowing

        // ── and eight keep the empty edge, on purpose ──
        //   Da’at · Tiferet · Yesod · the Duat · Barzakh · Yemaya · Imbolc · Tara
        //   Each has a resonance somewhere in the 66, but none a reader would nod at, and
        //   "this library has nothing beside it" is the truer card.
    ]

    /// Three of the 37 carry no em-dash — they are a whole phrase, not name + gloss. Key
    /// their edge off the phrase the design wrote. `The Aperture.html:205-209`.
    private static let alias: [String: String] = [
        "the lower dan tian of the Daoist body": "the lower dan tian",
        "the bardo of dream, among the six Tibetan bardos": "the bardo of dream",
        "the bardo of becoming, among the six Tibetan bardos": "the bardo of becoming",
    ]

    static func name(of register: String) -> String {
        guard let r = register.range(of: " — ") else { return register }
        return String(register[..<r.lowerBound])
    }
    static func gloss(of register: String) -> String? {
        guard let r = register.range(of: " — ") else { return nil }
        return String(register[r.upperBound...])
    }
    private static func key(of register: String) -> String {
        alias[register] ?? name(of: register)
    }

    /// The card's fourth line. Never absent: it says where the library stops either way.
    static func line(for register: String) -> String {
        if let e = table[key(of: register)] {
            return "The nearest thing this library has walked: \(e.title) · \(e.key)."
        }
        return "This library has nothing beside it."
    }
}
