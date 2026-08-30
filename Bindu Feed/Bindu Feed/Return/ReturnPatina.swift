import SwiftUI

// F3 · THE RETURN'S SURFACE — E3.8, E3.9, E3.2's rows
//
// Three findings that are one material: **the Return is the same story, kept.** Everything it
// shows has been handled, and the design says so in colour rather than in opacity.

/// E3.8 · `towardGold(h, t)` — `The Return v2.html:1040`,
/// `A.rgba(A.mixc(hex2(h), hex2('#C09550'), t), 1)`.
///
/// **THE PATINA IS A COLOUR, NOT A FADE.** `ReturnView` used `.saturation(0.5).brightness(−0.04)`
/// on the raw voice colour — which desaturates *toward grey*. Gold is not less colour; it is a
/// different colour, and a room's hue moved 50% toward `#C09550` still carries which room it
/// was. §11 of the design: *"colour, never opacity alone."*
///
/// The four weights are the design's own, and they are not one value used four times:
/// borders 0.5 · glyphs 0.45 · names 0.42 · mono labels 0.30–0.40. **The further from the
/// voice's own identity a thing is, the more gold it takes** — a border belongs to the room,
/// a name still belongs to the person.
enum ReturnPatina {
    /// `#C09550`, and nothing else is gold.
    static let gold = (r: 192.0, g: 149.0, b: 80.0)

    static let border = 0.50
    static let glyph  = 0.45
    static let name   = 0.42
    /// *"every room-coloured mono label 0.3–0.4"* — the band, and both ends are used:
    /// `RingsView` puts its title at 0.3 and its `the seed` label at 0.2.
    static let labelLight = 0.30
    static let labelDeep  = 0.40
    /// `towardGold(STORY.roomHex, 0.2)` — `The Return v2.html:1198`, the seed's own label,
    /// the least gold thing on the surface because the seed is the story itself.
    static let seed = 0.20

    /// `mixc(a, b, t)` on the raw components, exactly as the design mixes them.
    /// One channel of gold, by index — so a test can state the mix in the same terms.
    /// WIRED-BY(`gold` — a projection of the same three constants `towardGold` mixes with, not a second copy of them)
    static func goldChannel(_ i: Int) -> Double { [gold.r, gold.g, gold.b][i] }

    static func mix(_ rgb: [Double], _ t: Double) -> [Double] {
        let k = max(0, min(1, t))
        return [rgb[0] + (gold.r - rgb[0]) * k,
                rgb[1] + (gold.g - rgb[1]) * k,
                rgb[2] + (gold.b - rgb[2]) * k]
    }

    static func color(_ rgb: [Double], _ t: Double) -> Color {
        let c = mix(rgb, t)
        return Color(.sRGB, red: c[0] / 255, green: c[1] / 255, blue: c[2] / 255, opacity: 1)
    }
}

/// E3.9 · the sealed line, debossed. `The Return v2.html:1116-1117`.
///
/// *"in Movement III the one paragraph equal to `STORY.sealedLine` renders `className="deboss"`
/// at 17.5px italic, everything else at 16px."* Two shadows, one down and dark and one up and
/// warm — the sentence is cut INTO the surface rather than laid on it, which is the same claim
/// world IV makes about a wall.
///
/// `ReturnView` rendered every paragraph identically, so the one line he actually sealed was
/// indistinguishable from the ones around it.
enum ReturnDeboss {
    static let size: CGFloat = 17.5
    static let ordinarySize: CGFloat = 16
    static let ink = Color(hex: "#C2A472")
    /// `0 1px 0 rgba(0,0,0,.65)` — the cut's own shadow, below.
    static let shadowDown = (color: Color.black.opacity(0.65), y: CGFloat(1))
    /// `0 −1px 0 rgba(255,236,198,.08)` — the light catching its upper edge.
    static let shadowUp = (color: Color(.sRGB, red: 1, green: 236/255, blue: 198/255,
                                        opacity: 0.08), y: CGFloat(-1))
}

/// E3.2 · one row of the Rings list. `The Return v2.html:1191-1196`.
///
/// **`rel` IS POSITION, AND POSITION ONLY** — `(r.i)/(n−1)`, 0 for the oldest and 1 for the
/// newest. That is deliberate here and is NOT the age fault E3.4 describes: the list is a
/// stack and it dims by where a row SITS in it, while `ReturnStrata`'s colour dims by DAYS.
/// The same word means two things one layer apart, and §10's *"age comes from days, never from
/// rank"* governs the strata, not this.
struct ReturnRingRow: Identifiable, Equatable {
    let id: Int
    /// `92 DAYS AGO` — the mono column, 74pt wide.
    let when: String
    /// The first words of what he wrote, or the em-dashed absence.
    let frag: String
    /// How many voices answered this ring. `Claude Design Round 2/comps/The Return.html:242` — *"N voices answered"* or
    /// *"no answer"*.
    let answers: Int

    /// E3.2 · **THE ROW IS BUILT FROM WHAT HE ACTUALLY LEFT THERE.**
    ///
    /// `Claude Design Round 2/comps/The Return.html:123 renderRings` lists each prior return with the words it was sealed
    /// with. The app drew concentric circles from a COUNT and said nothing — *"a ring you can
    /// see and cannot read is a record of having spoken with the speech taken out"*, which is
    /// the one thing this surface exists to do.
    ///
    /// **Nothing was missing from the base.** §10: his return words live in a `Return Answer`
    /// with `Archetype = Ash`, parented to the ring — the Pass 6 write is proven, and
    /// `AirtableService.fetchReturnAnswers`'s own note says outright that *"Ash's own words
    /// are `Return Answer` too (they are the ring's `frag`)"*. This was a READ that was never
    /// built, not content that was never written.
    ///
    /// The fragment is the opening of what he wrote, and an em-dash when a ring carries no
    /// words at all — a ring can be sealed with silence, and that is a state to show rather
    /// than a gap to fill.
    static func frag(from words: String, limit: Int = 64) -> String {
        let t = words.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return "—" }
        let flat = t.replacingOccurrences(of: "\n", with: " ")
        guard flat.count > limit else { return flat }
        // Cut on a word, not mid-word: a fragment that ends inside a word reads as damage.
        let head = flat.prefix(limit)
        if let sp = head.lastIndex(of: " ") { return String(head[..<sp]) + "…" }
        return String(head) + "…"
    }

    /// `92 DAYS AGO` — the mono column. Zero is *TODAY*, because "0 DAYS AGO" is a sentence
    /// no one says, and one is *YESTERDAY*.
    static func when(days: Int) -> String {
        switch days {
        case ..<1: return "TODAY"
        case 1:    return "YESTERDAY"
        default:   return "\(days) DAYS AGO"
        }
    }

    /// `rel = n<=1 ? 1 : i/(n-1)` — the oldest row is 0 and the newest is 1.
    static func rel(index i: Int, of n: Int) -> Double {
        n <= 1 ? 1 : Double(i) / Double(n - 1)
    }
    /// `dim = 0.34 + 0.5*(1−rel)` — the OLD are brighter. A ring that has been carried longer
    /// reads stronger than one made yesterday, which is the whole surface's argument.
    static func fragOpacity(rel: Double) -> Double { 0.34 + 0.5 * (1 - rel) }
    /// `rgba(210,178,120, 0.3 + 0.42*(1−rel))` — the `when` column, same direction.
    static func whenOpacity(rel: Double) -> Double { 0.3 + 0.42 * (1 - rel) }
    /// `filter: saturate(1 − 0.35*(1−rel))` — and the old are *less saturated* as they brighten:
    /// louder and greyer at once, which is what a kept thing looks like.
    static func saturation(rel: Double) -> Double { 1 - 0.35 * (1 - rel) }

    /// `Claude Design Round 2/comps/The Return.html:242` — the answer count, in the design's own grammar.
    var answerLine: String {
        answers == 0 ? "no answer"
                     : String(answers) + " voice" + (answers > 1 ? "s" : "") + " answered"
    }
}
