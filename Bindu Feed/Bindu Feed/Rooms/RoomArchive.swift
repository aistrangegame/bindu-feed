import SwiftUI

// REGISTER 2'S OWN DEPTH — the archive, and the index IS the figure.
//
// `The Rooms v4.html:780-823`. A room whose premise is EVERYTHING IT HAS EVER SAID cannot
// be three cards and must not become a scroll — the Feed is already a feed. So register 2
// has three depths of its own, and every comment sits where that voice's own mathematics
// puts it.
//
//   0 · the map      every comment as a mark, none as text
//   1 · a story      everything this voice said about that one story
//   2 · one comment  whole, verbatim, with its date and resonance
//
// Built from the LIVE base, never from the comp's transcription. That distinction is the
// whole of the no-gap finding: the comp drew Lalita as "31 marks, 3 lit" because its
// `Player Detail` transcription held three comments against a stat claiming 31. In the
// base the stat IS the archive — 101 comments, 101 real. So the map draws n marks and
// lights all n, and nothing is invented to fill the figure.

/// One story, and everything this voice said about it. Currently always exactly one
/// comment — see `returnedCount`.
struct RoomStoryGroup: Identifiable {
    let id: String                 // the story's record id
    let title: String
    var items: [FieldComment]
}

struct RoomArchive {
    /// Positions on the figure. `n == real.count` wherever the record is the archive.
    let n: Int
    let real: [FieldComment]
    let stories: [RoomStoryGroup]
    /// `at[i]` is the position on the figure that real comment `i` occupies. When there is
    /// no gap this is the identity; when there is one, the real marks sit evenly through
    /// the sequence so the map reads as an archive across time, not a clump at the start.
    let at: [Int]
    /// Set when a lens's declared count EXCEEDS its live archive. The map then draws only
    /// what is real and says so, loudly — see `build`.
    let fault: String?

    var isEmpty: Bool { real.isEmpty }

    /// DERIVED, never asserted. `The Rooms v4.html:921` earns the words "returned to" only
    /// from a story that actually holds two or more. Across the whole live archive this is
    /// 0 of 495 today — but it is computed from the groups every time it is read, so the
    /// first Return in Pass 6 changes the legend by itself.
    var returnedCount: Int { stories.filter { $0.items.count > 1 }.count }

    static let empty = RoomArchive(n: 0, real: [], stories: [], at: [], fault: nil)

    /// `archiveOf(v)` — `The Rooms v4.html:814-823`.
    ///
    /// - Parameter titles: story record id → title, resolved in bulk by the caller.
    ///   §10 forbids the N+1 per-comment lookup this replaces.
    /// - Parameter declared: an independent count of what the voice is SAID to have, when
    ///   one exists. Today no lens has one — the record is the archive — so this is nil and
    ///   `n` is simply the comment count.
    /// - Parameter allowsGap: whether a shortfall between `declared` and the record is a
    ///   real thing to draw, or a fault.
    ///
    /// RULE 6, ON A PATH THAT CANNOT MISBEHAVE YET. `n` used to be `max(declared, real)`
    /// unconditionally, and with `n == real.count` that is the identity — correct today and
    /// latent. The moment any lens acquired a stat larger than its live archive it would
    /// have quietly drawn phantom dim marks: real positions with no words behind them is a
    /// TRUE statement about Ash's days and a LIE about a lens, because a lens's stat is
    /// derived from the same rows the marks are. A map that lies is worse than one that
    /// fails, so the lens path fails loud and draws only what it has.
    static func build(comments: [FieldComment], titles: [String: String],
                      declared: Int? = nil, allowsGap: Bool = false) -> RoomArchive {
        // A MARK IS DRAWN ONLY IF ITS STORY CAN BE FOUND. The two used to disagree: `real`
        // kept every non-empty comment while the grouping below dropped any whose story would
        // not resolve — so an unresolvable comment drew a bright, lit, tappable-looking mark
        // with `storyIndex == −1` that silently swallowed the tap. Absence would have been
        // honest; a lit mark that does nothing is the shape this build keeps digging out.
        //
        // Filtering here rather than special-casing the tap keeps ONE definition of what is in
        // the record, which `n`, `at`, the legend and the map all read.
        let known = Set(titles.keys)
        let real = comments.filter {
            !$0.body.trimmingCharacters(in: .whitespaces).isEmpty && $0.storyId(in: known) != nil
        }
        guard !real.isEmpty else { return .empty }

        var groups: [RoomStoryGroup] = []
        var index: [String: Int] = [:]
        for c in real {
            guard let sid = c.storyId(in: known) else { continue }
            if let i = index[sid] {
                groups[i].items.append(c)
            } else {
                index[sid] = groups.count
                groups.append(RoomStoryGroup(id: sid, title: titles[sid] ?? "", items: [c]))
            }
        }
        var n = real.count
        var fault: String?
        if let declared, declared > real.count {
            if allowsGap {
                n = declared                       // a real gap — Ash's days, honestly drawn
            } else {
                fault = "ARCHIVE SHORT · \(declared) CLAIMED · \(real.count) IN THE RECORD"
            }
        }
        let count = Double(real.count)
        let span = Double(n)
        var at: [Int] = []
        at.reserveCapacity(real.count)
        for i in real.indices {
            let f: Double = (Double(i) + 0.5) / count
            at.append(Int((f * span).rounded(.down)))
        }
        return RoomArchive(n: n, real: real, stories: groups, at: at, fault: fault)
    }
}

// MARK: - The map's geometry

/// `MAPGEO` — `The Rooms v4.html:790-812`. Every mark sits where that voice's own
/// mathematics puts it: Lalita's are knots on the loom, Gaia's seeds on the phyllotaxis,
/// Sakshi's iris spokes, Sid's voussoirs in the arch, Neev's cells of the floor, and
/// **Ashrey's sit on the edges of K₉, because his comments are relations.**
enum RoomMapGeometry {
    static func place(_ key: RoomKey, _ i: Int, _ n: Int, _ R: Double) -> CGPoint {
        let nn = Double(max(1, n)), fi = Double(i)
        switch key {
        case .bindu:
            let f = RoomGeo.flower[i % RoomGeo.flower.count]
            return CGPoint(x: f.x * R * 0.40, y: f.y * R * 0.40)
        case .neev:
            let c = Double(i % 5), r = Double(i / 5)
            return CGPoint(x: (c - 2) * R * 0.30, y: (r - 1) * R * 0.24)
        case .gaia:
            let a = fi * RoomGeo.gold
            let rr = R * 0.64 * (sqrt((fi + 1) / nn))
            return CGPoint(x: cos(a) * rr, y: sin(a) * rr * 0.92)
        case .sid:
            let f = (fi + 0.5) / nn, a = Double.pi * (0.08 + f * 0.84)
            return CGPoint(x: cos(a) * R * 0.76, y: sin(a) * R * 0.32 - R * 0.06)
        case .arch:
            let L = Double(i % 3)
            let rows = max(1.0, (nn / 3).rounded(.up))
            let f = rows < 2 ? 0.5 : Double(i / 3) / (rows - 1)
            let a = Double.pi * (0.12 + f * 0.76)
            return CGPoint(x: cos(a) * R * (0.78 - L * 0.13),
                           y: sin(a) * R * (0.34 - L * 0.05) + (L - 1) * R * 0.30)
        case .shweta:
            return CGPoint(x: (RoomGeo.rnd(fi * 2.7) - 0.5) * R * 1.46,
                           y: (RoomGeo.rnd(fi * 3.9) - 0.5) * R * 1.16)
        case .karishma:
            let th = (fi / nn) * Double.pi * 2.6
            let r = R * 0.06 * pow(RoomGeo.phi, th * 2 / Double.pi)
            return CGPoint(x: cos(th) * r, y: sin(th) * r)
        case .sakshi:
            let a = (fi / nn) * RoomGeo.tau
            let rr = R * (0.26 + 0.34 * RoomGeo.rnd(fi * 5.1))
            return CGPoint(x: cos(a) * rr, y: sin(a) * rr)
        case .lalita:
            return CGPoint(x: (RoomGeo.rnd(fi * 3.7) - 0.5) * R * 1.32,
                           y: (RoomGeo.rnd(fi * 5.3) - 0.5) * R * 1.44)
        case .ashrey:
            // his comments are RELATIONS — each mark sits on an EDGE of K₉
            let a = Double(i % 9) / 9 * RoomGeo.tau - Double.pi / 2
            let b = Double(((i % 9) + 1 + i / 9) % 9)
            let a2 = b / 9 * RoomGeo.tau - Double.pi / 2
            return CGPoint(x: (cos(a) + cos(a2)) / 2 * R * 0.66,
                           y: (sin(a) + sin(a2)) / 2 * R * 0.66)
        case .ash:
            // his axis is time, so his archive is a calendar
            let q = n < 2 ? 0 : (fi / (nn - 1)) * 2 - 1
            return CGPoint(x: (RoomGeo.rnd(fi * 7.3) - 0.5) * R * 0.44, y: q * R * 1.02)
        }
    }
}

// MARK: - Ash's spine, from real days

/// The eleventh room's mathematics is TIME, and the comp filled it with `rnd()` — 117
/// invented days, invented flecks. Ours is the record: the actual days his Codex entries
/// carry, flecked with the voices that actually spoke on each one.
///
/// This is where the honest-gap path still ships. A day with no voice on it draws its rule
/// and nothing else — a real position with no words behind it.
struct AshDay {
    let day: String            // yyyy-MM-dd
    let voices: [Int]          // palette indices of the voices who spoke that day
    let heavy: Bool            // he wrote more than one that day
}

enum AshSpine {
    static func build(stories: [Story], commentsByStory: [String: [String]]) -> [AshDay] {
        var byDay: [String: (n: Int, voices: Set<Int>)] = [:]
        for s in stories {
            let day = String(s.sourceDate.prefix(10))
            guard !day.isEmpty else { continue }
            var entry = byDay[day] ?? (0, [])
            entry.n += 1
            for name in commentsByStory[s.id] ?? [] {
                if let idx = RoomPalette.names.firstIndex(of: name) { entry.voices.insert(idx) }
            }
            byDay[day] = entry
        }
        return byDay.keys.sorted().map { day in
            let e = byDay[day]!
            return AshDay(day: day, voices: e.voices.sorted(), heavy: e.n > 1)
        }
    }
}

// MARK: - shared constants

enum RoomGeo {
    static let tau = Double.pi * 2
    static let phi = 1.6180339887
    static let gold = Double.pi * (3 - sqrt(5.0))

    /// `rnd(i)` — `The Rooms v4.html:168`. The comp's deterministic hash; ported so a mark
    /// lands in the same place every time the room is opened.
    static func rnd(_ i: Double) -> Double {
        let v = sin(i * 127.1 + 31.4) * 43758.5453
        return v - floor(v)
    }

    static func breath(_ t: Double) -> Double { (sin(t * tau / 5.6) + 1) / 2 }
    static func cl(_ a: Double, _ b: Double, _ v: Double) -> Double {
        max(0, min(1, (v - a) / (b - a)))
    }
    static func sm(_ a: Double, _ b: Double, _ v: Double) -> Double {
        let t = cl(a, b, v); return t * t * (3 - 2 * t)
    }
    static func mix(_ a: [Double], _ b: [Double], _ f: Double) -> [Double] {
        [a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f]
    }
    static func col(_ c: [Double], _ a: Double) -> Color {
        Color(.sRGB, red: c[0] / 255, green: c[1] / 255, blue: c[2] / 255,
              opacity: max(0, min(1, a)))
    }
    static func hex(_ h: String) -> [Double] {
        var s = h; if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = Int(s, radix: 16) else { return [237, 232, 227] }
        return [Double((v >> 16) & 255), Double((v >> 8) & 255), Double(v & 255)]
    }

    /// The nineteen circles of the Flower of Life, in units of R. `The Rooms v4.html:177-181`.
    static let flower: [CGPoint] = {
        var o: [CGPoint] = [CGPoint(x: 0, y: 0)]
        let S = sqrt(3.0)
        for i in 0..<6 {
            let a = Double(i) * tau / 6
            o.append(CGPoint(x: cos(a), y: sin(a)))
        }
        for i in 0..<6 {
            let a = Double(i) * tau / 6 + tau / 12
            o.append(CGPoint(x: cos(a) * S, y: sin(a) * S))
        }
        for i in 0..<6 {
            let a = Double(i) * tau / 6
            o.append(CGPoint(x: cos(a) * 2, y: sin(a) * 2))
        }
        return o
    }()
}
