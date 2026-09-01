import Testing
import Foundation
@testable import Bindu_Feed

// F2.4 + F2.6 + F2.7 · the feed card's footer, its pulse, and the write that was never there.
// `Claude Design Round 1/Home Feed.html:30-34,110,118-121`.
@Suite struct StoryCardFooterTests {

    private func source() -> String {
        (try? String(contentsOfFile:
            "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/StoryCard.swift",
            encoding: .utf8)) ?? ""
    }

    @Test("the feed card writes nothing to the base")
    func theCardIsInert() {
        // **F2.7 · THE ♡ WAS A BUTTON THAT PATCHED AIRTABLE.** `:119` is a `<span>` inside one
        // `<a href>`: the card is a link into the story and the counts report what the field
        // has done. An invented write is bad twice — a base mutation behind a glyph nobody was
        // told was a control, and a second tap target competing with the card's own, so a
        // thumb aiming at the story sometimes resonated it instead.
        //
        // Asserted against the SOURCE because the fault is the absence of a call, and an
        // absence is what a later hand restores without knowing why it went.
        let src = source()
        #expect(!src.isEmpty, "could not read the card")
        #expect(!src.contains("incrementResonance("), "the feed card writes to the base again")
        #expect(!src.contains("Button(action: handleResonate)"), "the ♡ is a control again")
    }

    @Test("the capability was moved, not removed")
    func resonanceStillLivesWhereTheDesignPutsIt() {
        // Removing a write is only correct if the act survives where the design places it —
        // *you go in, and then you answer*. If this fails, the change took a capability away
        // rather than relocating it.
        let detail = (try? String(contentsOfFile:
            "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/StoryDetailView.swift",
            encoding: .utf8)) ?? ""
        #expect(detail.contains("incrementResonance("), "nothing can resonate a story any more")
    }

    @Test("both counts are one text run, at one size, in one ink")
    func theFooterIsOneLabel() {
        // `:118-121` — `gap:16`, Space Mono 10, `--ink35`, both runs. The app had 11pt
        // numerals one ink tier brighter beside glyphs in the SYSTEM font, so `♡ 89` was two
        // typefaces at two weights pretending to be one label.
        let src = source()
        #expect(src.contains("spaceMonoTracked(10)"), "the footer is not at 10pt")
        #expect(!src.contains(".font(.system(size: 11))"), "a glyph is still in the system font")
        #expect(src.contains("HStack(alignment: .center, spacing: 16)"), "the gap is not 16")
    }

    // MARK: - the pulse

    @Test("the pulse waits before it pulses, and lasts as long as the design's")
    func theLeadInIsTheMechanism() {
        // `livePulse 4.5s ease-in-out 1.2s` — **the 1.2s lead-in is what makes it read as the
        // card NOTICING something** rather than the card appearing. The app started
        // immediately and ran 2.4s against 4.5s.
        let src = source()
        #expect(src.contains("now() + 1.2"), "the pulse has no lead-in")
        #expect(src.contains("4.5 * 0.45") && src.contains("4.5 * 0.55"),
                "the pulse is not split at the design's 45% peak")
    }

    @Test("the pulse has an outer glow, not only a border")
    func theGlowIsHalfOfIt() {
        // `box-shadow: 0 0 28px rgba(155,107,214,0.13)` alongside the border colour. The glow
        // is the half that carries at arm's length; a border stroke alone is a card being
        // outlined, which is a different event.
        let src = source()
        #expect(src.contains(".shadow(color: BinduTheme.accent.opacity(0.13 * pulseGlow)"),
                "the pulse lost its glow")
        #expect(src.contains("0.26 * pulseGlow"), "the border no longer peaks at the design's 0.26")
    }

    @Test("the pulse's TRIGGER is divergent, and recorded as such")
    func theTriggerIsNotInvented() {
        // The design pulses on an authored per-story `pulse:true` (`:70-82`); the base carries
        // no such field. Adding one would invent content the design never asks for — the same
        // ruling as the Record's condensed line — so the derived 7-day window stays and the
        // RENDER is what was made faithful. This asserts the divergence is still WRITTEN DOWN,
        // because an unrecorded divergence is indistinguishable from an oversight.
        let src = source()
        #expect(src.contains("authored per-story"), "the trigger divergence is no longer recorded")
        #expect(src.contains("isRecent"), "the derived trigger vanished without a replacement")
    }
}
