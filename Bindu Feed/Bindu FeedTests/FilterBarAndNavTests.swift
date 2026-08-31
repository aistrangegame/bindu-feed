import Testing
import SwiftUI
@testable import Bindu_Feed

// F2.1 + F4.1 + F4.2 · the filter bar's inactive state, the nav bar's door, the stats' room.
// `Claude Design Round 1/Home Feed.html:128-133`, `comps/Game View.html:503-523,526-533,550`.
@Suite struct FilterBarAndNavTests {

    private func src(_ path: String) -> String {
        let raw = (try? String(contentsOfFile: "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/" + path,
                               encoding: .utf8)) ?? ""
        return raw.split(separator: "\n", omittingEmptySubsequences: false)
            .map { l -> String in
                let t = l.trimmingCharacters(in: .whitespaces)
                return (t.hasPrefix("//") || t.hasPrefix("///")) ? "" : String(l)
            }.joined(separator: "\n")
    }

    // MARK: - F2.1

    @Test("an unselected room has no colour at all — selection IS the colour")
    func theInactiveStateIsNotATint() {
        // `:128-133` — an inactive chip has no room colour at ANY element: grey glyph, grey
        // name, no fill, transparent border, no glow. The app coloured every chip always and
        // turned the active one up ~2.5×, so the inactive state was **inverted**: thirteen
        // coloured pills with one brighter. That is a legend of the rooms with a highlight on
        // it; the design is a row of names with exactly one room present in it.
        //
        // **A still of the ACTIVE chip is identical in both builds** — the difference is only
        // in what the other twelve are doing, which is why a screenshot review passes it.
        let s = src("Components/CommunityFilterBar.swift")
        #expect(s.contains("active ? room.color : BinduTheme.inkTertiary"), "the inactive glyph is coloured again")
        #expect(s.contains("active ? room.color.opacity(0.086) : Color.clear"), "the inactive chip is filled again")
        #expect(!s.contains("room.color.opacity(active ? 1.0 : 0.85)"), "the name is back to a brightness delta")
    }

    @Test("the border stays present when inactive, so the pill does not resize on selection")
    func theBorderIsTransparentNotAbsent() {
        // Removing the overlay instead of clearing its colour changes the pill's width at the
        // moment of selection, which reads as the row twitching rather than a room lighting.
        let s = src("Components/CommunityFilterBar.swift")
        #expect(s.contains("strokeBorder(active ? room.color.opacity(0.22) : Color.clear"))
        #expect(s.contains(".overlay("), "the border overlay was made conditional")
    }

    // MARK: - F4.1

    @Test("the centre of the nav bar is the door out, not a caption")
    func theEscapeHatchExists() {
        // `:503-523` frames the room between two edge arrows and makes the middle column a
        // control. The app made it inert text reporting where you are, so the escape hatch
        // was **absent, not restyled** — stepping was the only way to move.
        let s = src("Screens/GameView.swift")
        #expect(s.contains("Button { $path.pushDissolve(FeedRoute.rooms) }"), "the centre is inert again")
    }

    @Test("the authored line is whole — it had been silently shortened")
    func theStringWasTruncatedNotAbsent() {
        // `:518` is `{idx+1} · 13 · all rooms`. The app rendered `\\(roomIndex + 1) · 13` —
        // **the same authored string with its last two words missing**, which every checker
        // passes because a substring of an authored line matches the haystack. And the label
        // IS the affordance: without *all rooms* the counter is a position; with it, a way out.
        let s = src("Screens/GameView.swift")
        #expect(s.contains("· 13 · all rooms"), "the line is truncated again")
    }

    @Test("the arrows are at the bar's edges, framing the room")
    func theArrowsAreNotACluster() {
        // Both in one right-hand cluster made them a pager beside the title; at the edges they
        // are the walls of the room he is standing in.
        let s = src("Screens/GameView.swift")
        #expect(!s.contains("HStack(spacing: 8) {\n                ArrowCircle"), "the arrows are clustered again")
        #expect(s.contains("Circle().fill(Color(hex: \"#0E0C12\").opacity(0.60))"),
                "the arrow disc takes its colour from behind it again")
    }

    // MARK: - F4.2

    @Test("the stats belong to the room, not to the app")
    func theStatsAreRoomColoured() {
        // `:550` — `<GameStat stat={s} color={game.color} />`. One fixed `#EDE8E3` for all
        // thirteen rooms made the one row of numbers that belongs to THIS room read as chrome.
        let s = src("Screens/GameView.swift")
        #expect(s.contains(".foregroundColor(currentRoom.color)"), "the stats are room-blind again")
    }

    @Test("the label's tracking is stated once, inside the helper")
    func theTrackingIsNotChained() {
        // `spaceMonoTracked` applies its own `.tracking(em * size)` with `em` defaulting to 0,
        // so chaining a second `.tracking` outside it put an inner `tracking(0)` under an
        // outer `tracking(0.56)` on the same Text. One `em:` says it once.
        let s = src("Screens/GameView.swift")
        #expect(s.contains(".spaceMonoTracked(8, em: 0.07)"))
        #expect(!s.contains(".spaceMonoTracked(8)\n                .tracking(0.56)"))
    }
}
