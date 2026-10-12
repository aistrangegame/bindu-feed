import Combine
import Foundation

// WAVE 3 · the two slow clocks the house keeps beside the day: the moon and the seasons.
// Mandala's lunar service, ported in its simplest honest form — the mean synodic month from a
// known new moon, good to within a day, which is all a door that opens "around the new moon"
// needs. The Nityā qualities ride on the same phase (Ashrey's ruling, 11 Oct 2026).
enum Sky {
    static let synodic = 29.530588853
    /// 2000-01-06 18:14 UTC, a new moon.
    static let epoch = Date(timeIntervalSince1970: 947_182_440)

    /// 0 = new, 0.5 = full, 1 = new again.
    static func moonPhase(_ d: Date = Date()) -> Double {
        let days = d.timeIntervalSince(epoch) / 86_400
        let p = days.truncatingRemainder(dividingBy: synodic) / synodic
        return p < 0 ? p + 1 : p
    }

    /// Within about a day of the new moon.
    static func isNewMoon(_ d: Date = Date()) -> Bool {
        let p = moonPhase(d); return p < 0.034 || p > 0.966
    }

    /// Within about a day of the full moon.
    static func isFullMoon(_ d: Date = Date()) -> Bool { abs(moonPhase(d) - 0.5) < 0.034 }

    /// The lunar day, 1…30 — the tithi the Nityā rides on (waxing 1–15, waning 16–30).
    static func tithi(_ d: Date = Date()) -> Int { min(30, Int(moonPhase(d) * 30) + 1) }

    /// The sixteen Nityā of the waxing fortnight, named in their traditional order; the
    /// waning fortnight walks them back. Only their names travel here — never a practice.
    static let nitya = ["Kāmeśvarī", "Bhagamālinī", "Nityaklinnā", "Bheruṇḍā", "Vahnivāsinī",
                        "Mahāvajreśvarī", "Śivadūtī", "Tvaritā", "Kulasundarī", "Nityā",
                        "Nīlapatākā", "Vijayā", "Sarvamaṅgalā", "Jvālāmālinī", "Citrā", "Lalitā"]

    /// Today's Nityā: Lalitā herself on the full moon, the others by the tithi.
    static func nityaToday(_ d: Date = Date()) -> String {
        if isFullMoon(d) { return "Lalitā" }
        let t = tithi(d)
        let i = t <= 15 ? t - 1 : 30 - t
        return nitya[max(0, min(14, i))]
    }

    /// Within a day of a solstice or equinox (by the calendar day, near enough for a door).
    static func isSeasonTurn(_ d: Date = Date()) -> Bool {
        let c = Calendar(identifier: .gregorian).dateComponents([.month, .day], from: d)
        guard let m = c.month, let day = c.day else { return false }
        let turns = [(3, 20), (6, 21), (9, 22), (12, 21)]
        return turns.contains { $0.0 == m && abs($0.1 - day) <= 1 }
    }
}
