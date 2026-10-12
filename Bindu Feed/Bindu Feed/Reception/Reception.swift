import Combine
import SwiftUI
import UIKit

// SELF-KATHAS (12 Oct 2026) · Slice 11 onward.
//
// The ruling: take him out of the equation. The Feed is reality meeting itself, and his memos
// are one suit among many. Each ROOM receives its stories in its own grammar; each STORY may
// carry one signature that never repeats inside its room; the other suits (the cloth, the
// company, the land, the machine, the lineage, the maker, the one who returns) are revealed
// through rhyme with a story of his, never added.
//
// The score lives backstage in the Project (`claude/feed-self-kathas-score.md`).
// Nothing in this folder names a grammar, a signature or a suit on screen.

// MARK: - The thirteen grammars of reception

enum Grammar: String, CaseIterable {
    case twoSided        // A Maya Game     · enter by the light or the dark; both end at one middle page
    case ripens          // The Garden      · changes only while he is away
    case thirdDoor       // The Watcher     · open · pass · and, to stillness, the third door
    case peel            // The Descent     · each hold opens the layer beneath; the floor is empty
    case fromTheEnd      // The Return      · the last line first, then back to the first cause
    case dress           // The Forgetting  · a residue overlay that drains while he stays
    case pauses          // The Remembering · lines released with held, empty beats between
    case byTheBody       // The Body        · the screen goes dark; the story is found under the finger
    case oneHouse        // The Thread      · each house shows only what the last hands passed on
    case rings           // The Circle      · widening rings
    case beforeQuestion  // The Signal      · a line before its question; a held gaze on one point
    case stopTheLine     // The Forge       · the line halts at a seam until he touches it
    case baton           // The Field       · each telling begins where the last voice ended

    init?(room: String) {
        switch room {
        case "A Maya Game":     self = .twoSided
        case "The Garden":      self = .ripens
        case "The Watcher":     self = .thirdDoor
        case "The Descent":     self = .peel
        case "The Return":      self = .fromTheEnd
        case "The Forgetting":  self = .dress
        case "The Remembering": self = .pauses
        case "The Body":        self = .byTheBody
        case "The Thread":      self = .oneHouse
        case "The Circle":      self = .rings
        case "The Signal":      self = .beforeQuestion
        case "The Forge":       self = .stopTheLine
        case "The Field":       self = .baton
        default: return nil
        }
    }
}

// MARK: - The twelve signatures — one at most per story, never twice in a room

enum Signature: String, CaseIterable {
    case sealedLastPage   // opens only after he has asked for help (the Call)
    case alreadyDid       // the last line arrives as an answer to "wake up"
    case secondPiece      // a small companion arrives after the reading, unannounced
    case missingNote      // the sound carries what the words leave out, loudest when he is still
    case layersOnReturn   // a second and a third reading surface with dwell, never with visits
    case everyPath        // variant pasts collapse into one as he stays
    case foundPage        // a dated fragment from long before surfaces mid-story, without comment
    case cordCut          // he cuts a thread; the next story launches from where it fell
    case emptySummit      // he climbs toward a figure and finds the top warm and empty
    case alreadyMended    // he reaches to fix a word and finds it whole
    case zeroGap          // the closed-eye and open-eye lines converge until they are one
    case dotBecomesPlace  // a white dot grows until the story forms around it
}

enum KathaHash {
    /// FNV-1a, 64-bit. `hashValue` is reseeded every launch; a signature must not move.
    static func fnv(_ s: String) -> UInt64 {
        var h: UInt64 = 0xcbf29ce484222325
        for b in s.utf8 { h ^= UInt64(b); h = h &* 0x100000001b3 }
        return h
    }
}

enum Signatures {
    /// Codex entries that already asked for a particular signature. The rest are dealt.
    static let asked: [String: Signature] = [
        "C-1253": .everyPath,       // Every Path, Already Walked
        "C-1260": .emptySummit,     // The One at the Top of the Climb
        "C-1171": .alreadyMended,   // Every Time He Reached to Control
        "C-1222": .dotBecomesPlace, // The White Light Behind the Red Dot
    ]

    /// Deal per room, in sort order, so a story's signature never moves when a later story is
    /// written: each room shuffles the twelve by its own name, the asked ones are placed
    /// first, and about three stories in five take the next unused one. A room never repeats.
    static func deal(_ stories: [Story]) -> [String: Signature] {
        var out: [String: Signature] = [:]
        for (room, list) in Dictionary(grouping: stories, by: { $0.room }) {
            let ordered = list.sorted { ($0.sortOrder, $0.id) < ($1.sortOrder, $1.id) }
            var used = Set<Signature>()
            for s in ordered {
                if let a = asked[s.codexId], !used.contains(a) { out[s.id] = a; used.insert(a) }
            }
            let seed = KathaHash.fnv(room)
            let deck = Signature.allCases.sorted {
                KathaHash.fnv("\(seed)·\($0.rawValue)") < KathaHash.fnv("\(seed)·\($1.rawValue)")
            }
            for s in ordered where out[s.id] == nil {
                guard KathaHash.fnv(s.id) % 5 < 3 else { continue }
                guard let next = deck.first(where: { !used.contains($0) }) else { break }
                out[s.id] = next
                used.insert(next)
            }
        }
        return out
    }
}

// MARK: - The rhyme gate — revealed, never added

enum RhymeGate {
    static let receivedKey = "bindu.kathas.received"
    /// Met in the Rite or the floor beneath — fed by `FeedStore.metStoryIDs`.
    static var met: Set<String> = []

    static var received: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: receivedKey) ?? [])
    }

    static func markReceived(_ id: String) {
        var r = received
        guard !r.contains(id) else { return }
        r.insert(id)
        UserDefaults.standard.set(Array(r), forKey: receivedKey)
    }

    static func isOpen(_ s: Story) -> Bool {
        s.rhymesWith.isEmpty || met.contains(s.rhymesWith) || received.contains(s.rhymesWith)
    }

    /// Hide every suit story whose rhyme he has not yet met; seat each revealed one directly
    /// after the story it rhymes with, when that story is in the same list.
    static func arrange(_ list: [Story]) -> [Story] {
        let open = list.filter(isOpen)
        let suits = open.filter { !$0.rhymesWith.isEmpty }
        guard !suits.isEmpty else { return open }
        let hostIds = Set(open.map { $0.id })
        var out: [Story] = []
        for s in open where s.rhymesWith.isEmpty || !hostIds.contains(s.rhymesWith) {
            out.append(s)
            out.append(contentsOf: suits.filter { $0.rhymesWith == s.id })
        }
        return out
    }
}

// MARK: - Shared instruments for the grammars

/// What a grammar is handed: the story broken the two ways it can be walked.
struct Katha {
    let story: Story
    let color: Color
    let paragraphs: [String]
    let sentences: [(paragraph: Int, text: String)]

    init(story: Story, color: Color) {
        self.story = story
        self.color = color
        self.paragraphs = story.body.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        self.sentences = Sentences.split(story.body)
    }

    static func words(_ s: String) -> Int { s.split(separator: " ").count }

    /// Unhurried: a dwell long enough to read twice before anything moves on its own.
    static func dwell(_ s: String) -> Double { 6 + Double(words(s)) / 2.0 }
}

/// Stillness, read from the absence of touch — never measured in the body.
@MainActor
final class Stillness: ObservableObject {
    @Published private(set) var still: TimeInterval = 0
    private var last = Date()
    private var tick: AnyCancellable?

    func touched() { last = Date(); if still != 0 { still = 0 } }

    func start() {
        last = Date()
        tick = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.still = Date().timeIntervalSince(self.last)
            }
    }

    func stop() { tick = nil }
}

extension View {
    /// Every touch on this surface is an ask, and resets nothing but the stillness.
    func asks(_ s: Stillness) -> some View {
        self.contentShape(Rectangle())
            .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in s.touched() })
    }
}

/// A hold is the hold it was designed to be: it fills while held, waits for the release once
/// full, and drains — never fails — if let go early. VoiceOver's activate is its other door.
struct HoldPress: View {
    let duration: Double
    let color: Color
    var size: CGFloat = 46
    let onComplete: () -> Void

    @State private var p: Double = 0
    @State private var holding = false
    @State private var task: Task<Void, Never>?

    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(0.22), lineWidth: 1)
            Circle().trim(from: 0, to: p)
                .stroke(color, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle().fill(color.opacity(0.35 + 0.55 * p))
                .frame(width: 6 + 8 * p, height: 6 + 8 * p)
                .shadow(color: color.opacity(0.7 * p), radius: 8 * p)
        }
        .frame(width: size, height: size)
        .contentShape(Circle().inset(by: -22))
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in begin() }
            .onEnded { _ in end() })
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onComplete() }
        .onDisappear { task?.cancel() }
    }

    private func begin() {
        guard !holding else { return }
        holding = true
        task?.cancel()
        task = Task { @MainActor in
            while !Task.isCancelled, p < 1 {
                p = min(1, p + 0.016 / duration)
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    private func end() {
        holding = false
        task?.cancel()
        if p >= 1 {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            onComplete()
            p = 0
            return
        }
        task = Task { @MainActor in
            while !Task.isCancelled, p > 0 {
                p = max(0, p - 0.016 / 0.6)
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }
}

/// The page's own text, at the reading measure.
struct KathaText: View {
    let text: String
    var size: CGFloat = 18
    var italic = false
    var color: Color = BinduTheme.inkPrimary

    var body: some View {
        Text(text)
            .font(italic ? .loraItalic(size) : .lora(size))
            .foregroundColor(color)
            .lineSpacing(size * 0.55)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
