import Combine
import SwiftUI

// SELF-KATHAS · what the store knows about reception: which signature a story carries, the
// line that arrives before its question, the page found from long before, the next thread,
// and the quiet refresh that lets a revealed rhyme simply be there.

extension FeedStore {

    func signature(for story: Story) -> Signature? {
        Signatures.of(story, in: stories)
    }

    /// The Signal's line before its question: the last line of a story from another room that
    /// he has not yet met. It will only make sense after. One per day, by rendezvous.
    func echo(for story: Story) -> String? {
        let opened = RhymeGate.received.union(metStoryIDs)
        let day = AirtableService.localDayString()
        return stories
            .filter { $0.id != story.id && $0.room != story.room && !opened.contains($0.id) && !$0.closingLine.isEmpty }
            .min { KathaHash.fnv(day + story.id + $0.id) < KathaHash.fnv(day + story.id + $1.id) }?
            .closingLine
    }

    /// A dated fragment from long before — at least three hundred days earlier — that shares the
    /// story's rarest long word. Shown mid-story with its date and nothing else.
    func foundPage(for story: Story) -> (line: String, date: String)? {
        let f = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC") ?? .current)
        guard let here = f.date(from: story.sourceDate) else { return nil }
        func words(_ s: String) -> Set<String> {
            Set(s.lowercased().split { !$0.isLetter }.map(String.init).filter { $0.count >= 7 })
        }
        let mine = words(story.body)
        var best: (Story, Int)?
        for s in stories where s.id != story.id {
            guard let then = f.date(from: s.sourceDate), here.timeIntervalSince(then) > 300 * 86_400 else { continue }
            let shared = mine.intersection(words(s.body)).count
            if shared > (best?.1 ?? 0) { best = (s, shared) }
        }
        guard let (older, _) = best,
              let line = Sentences.split(older.body).first?.text,
              let then = f.date(from: older.sourceDate) else { return nil }
        let out = DateFormatter()
        out.locale = Locale(identifier: "en_US_POSIX")
        out.calendar = Calendar(identifier: .gregorian)
        out.dateFormat = "MMMM yyyy"
        return (line, out.string(from: then).lowercased())
    }

    /// Where the cut thread falls: the next story in this room he has not yet received, else
    /// the next one anywhere.
    func nextThread(after story: Story) -> Story? {
        let opened = RhymeGate.received.union(metStoryIDs)
        let room = stories.filter { $0.room == story.room }.sorted { $0.sortOrder < $1.sortOrder }
        if let i = room.firstIndex(where: { $0.id == story.id }) {
            let after = room[(i + 1)...] + room[..<i]
            if let s = after.first(where: { !opened.contains($0.id) }) { return s }
        }
        return stories.first { $0.id != story.id && !opened.contains($0.id) }
    }

    /// A rhyme opened during the session is simply there the next time he looks — no flash of
    /// loading, no announcement. Only the whole set is refreshed; the room he is in refetches
    /// itself on its own turn.
    func revealRhymes() async {
        guard let all = try? await AirtableService.shared.fetchStories(room: nil, sort: .mostActive) else { return }
        guard Set(all.map(\.id)) != Set(stories.map(\.id)) else { return }
        stories = all
        // The river he returns to is already changed: the feed keeps its own filter (one room,
        // or all of them) and takes the newly revealed rhyme in the place the gate gives it.
        let rooms = Set(feedStories.map(\.room))
        feedStories = rooms.count == 1 ? all.filter { rooms.contains($0.room) } : all
    }

    /// The Codex memo's first sentence, for the third reading of a story that layers on return.
    func firstMemoLine(for story: Story) async -> String? {
        guard !story.codexId.isEmpty, let m = await memo(for: story) else { return nil }
        return Sentences.split(m).first?.text
    }
}
