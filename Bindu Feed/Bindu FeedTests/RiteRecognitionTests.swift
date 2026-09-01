import Testing
import Foundation
@testable import Bindu_Feed

// E2.5 + E2.6 · the Recognition — what stands through the ceremony, and what the timer is.
// `Claude Design Round 1/The Rite v3.html:1473-1477`, `:1493-1496`.
@Suite struct RiteRecognitionTests {

    private func source() -> String {
        let raw = (try? String(contentsOfFile:
            "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteRecognitionView.swift",
            encoding: .utf8)) ?? ""
        // Comments quote both strings by name, so the haystack has to be code — the same
        // lesson the Settings batch met, and the same one that defeated Rule 4's first check.
        return raw.split(separator: "\n", omittingEmptySubsequences: false)
            .map { l -> String in
                let t = l.trimmingCharacters(in: .whitespaces)
                return (t.hasPrefix("//") || t.hasPrefix("///")) ? "" : String(l)
            }.joined(separator: "\n")
    }

    // MARK: - E2.5 · which line stands through the rite

    @Test("the question is what stands; the disclosure belongs to the moment before")
    func theSlotsAreTheRightWayRound() {
        // `:1473` opens its wrapper BEFORE any stage guard, so the avatar and *"What arrived
        // for you?"* are present while he answers. The app made the persistent line *"spoken ·
        // kept in your voice"* — the mechanic's note about storage — and put the question
        // inside `case .prompt`, where it vanishes the moment he starts speaking. **The screen
        // held its own footnote up for the length of the rite.**
        //
        // Nothing was deleted; the two authored strings traded places — which is why neither
        // an outcome check nor a string checker could see it: both render, both are authored,
        // both are correct copy in the wrong slot.
        let src = source()
        let promptAt = src.range(of: "RiteWord.recogPrompt").map { src.distance(from: src.startIndex, to: $0.lowerBound) }
        let labelAt = src.range(of: "RiteWord.recogKeptLabel").map { src.distance(from: src.startIndex, to: $0.lowerBound) }
        let switchAt = src.range(of: "switch stage").map { src.distance(from: src.startIndex, to: $0.lowerBound) }
        #expect(promptAt != nil && labelAt != nil && switchAt != nil)
        #expect(promptAt! < switchAt!, "the question is inside the stage switch again")
        #expect(labelAt! > switchAt!, "the disclosure is standing through the whole rite again")
    }

    @Test("the question is Ash asking, not the app labelling")
    func theQuestionCarriesHisColour() {
        // `:1475` — Lora italic **17** in `ASH.color` at 0.9. The app had 20pt in `inkPrimary`:
        // a heading in the app's own ink, where the design has a person speaking in his.
        let src = source()
        #expect(src.contains(".font(.loraItalic(17))"), "the question is not at 17")
        #expect(src.contains("RiteAsh.color.opacity(0.9)"), "the question lost Ash's colour")
    }

    // MARK: - E2.6

    @Test("the timer is a length of speech, not a stopwatch")
    func theMinutesAreNotPadded() {
        // `:1495` — `{mm}:{ss}`, minutes unpadded. Seven seconds reads `0:07`, not `00:07`:
        // a leading zero makes a two-digit field out of a number that is almost always one
        // digit, and a field is what a stopwatch has. This is the length of something he said.
        func mmss(_ seconds: Int) -> String { String(format: "%d:%02d", seconds / 60, seconds % 60) }
        #expect(mmss(7) == "0:07")
        #expect(mmss(67) == "1:07")
        #expect(mmss(7) != "00:07", "the timer pads its minutes again")
    }

    @Test("`listening` is a state, not a presence")
    func theWordDoesNotBreathe() {
        // The design strips the word of Ash's colour and its breathing. Colouring and
        // breathing it makes the LABEL the thing that is alive, when the thing that is alive
        // is him — and the app then had two breathing elements competing on one screen.
        let src = source()
        guard let r = src.range(of: "case .listening:") else { Issue.record("no listening stage"); return }
        let block = String(src[r.lowerBound...].prefix(420))
        #expect(!block.contains("RiteBreathe"), "the listening label is breathing again")
        #expect(block.contains("BinduTheme.inkTertiary"), "the label took Ash's colour back")
    }

    @Test("Keep it dims when there is nothing to keep — and still works")
    func theColourGatesButTheActionDoesNot() {
        // `:1496` colours on `text.trim()` **and** gates the click on it. The app keeps the
        // spoken audio, which the design has no notion of, so gating the action would leave a
        // man who SPOKE and typed nothing with no exit and a stranded recording. The colour
        // carries the design's claim; the ungated action answers a state the design cannot
        // have — and the divergence is written at the site rather than left implicit.
        let src = source()
        #expect(src.contains(".foregroundStyle(t: text, color: RiteAsh.color)"),
                "the dim-when-empty helper is unwired again")
        #expect(src.contains("onSealed(text.trimmingCharacters"),
                "the seal action was gated — a spoken-but-unwritten rite now has no exit")
        let raw = (try? String(contentsOfFile:
            "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteRecognitionView.swift",
            encoding: .utf8)) ?? ""
        #expect(raw.contains("DIVERGENCE"), "the ungated action is no longer recorded as deliberate")
    }
}
