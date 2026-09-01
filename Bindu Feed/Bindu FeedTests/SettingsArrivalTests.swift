import Testing
import Foundation
@testable import Bindu_Feed

// F10.1 + F10.2 + F10.3 · the arrival card, the save control, and who is speaking.
// `Claude Design Round 1/Settings.html:419, 444-453, 471-472, 541-559`.
@Suite struct SettingsArrivalTests {

    /// **THE HAYSTACK IS CODE, NOT COMMENTS — and these tests failed on their first run for
    /// exactly that reason.** Every assertion below that an old string is GONE was defeated by
    /// the comment explaining why it went: `SAVE THE ARRIVAL`, `the name you arrive with` and
    /// `match.name.uppercased()` all still appear in the file, quoted in the note above the
    /// code that replaced them.
    ///
    /// This is the same fault that defeated the first version of Rule 4's forward check —
    /// `TOUCH TO READ` stayed green after deletion because a comment three lines up quoted the
    /// design — and it is written down in §10 as *narrow the haystack to what actually
    /// executes*. It is worth meeting once from this side: a source-asserting test is only
    /// honest if it reads the same thing the compiler does.
    private func source() -> String {
        let raw = (try? String(contentsOfFile:
            "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SettingsView.swift",
            encoding: .utf8)) ?? ""
        return raw.split(separator: "\n", omittingEmptySubsequences: false)
            .map { line -> String in
                let t = line.trimmingCharacters(in: .whitespaces)
                return (t.hasPrefix("//") || t.hasPrefix("///")) ? "" : String(line)
            }
            .joined(separator: "\n")
    }

    // MARK: - F10.1 · what the preview says

    @Test("the preview shows what the colour MEANS, not what it is called")
    func theQualityIsTheContent() {
        // `:452` renders `currentMood.quality`. The app returned `match.name.uppercased()`, so
        // the preview read `TERRA` — the label of the swatch he had just tapped, repeated back
        // at him. The quality phrase is the only line on that card that says anything about
        // HIM, and the phrases were already in the file, read by the picker two hundred lines
        // below while the preview showed the name.
        let src = source()
        #expect(src.contains("selectedMoodQuality"), "the preview is back to the mood's name")
        #expect(!src.contains("match.name.uppercased()"), "the name is being shown again")
    }

    @Test("a spoken phrase is not uppercased, and it says so out loud")
    func theCaseIsDeliberate() {
        // Every mono label on this screen uppercases by the class rule — and this one is a
        // spoken phrase rather than chrome, so `GROUNDED, PRESENT` would make it a category
        // heading. `.textCase(nil)` records the exception where a later sweep will look,
        // instead of leaving it to be "fixed" into consistency.
        let src = source()
        #expect(src.contains(".textCase(nil)"), "the quality phrase is being uppercased again")
    }

    // MARK: - F10.2 · the save control's three states

    @Test("there are three states, and the third one was nothing at all")
    func theThirdStateExists() {
        // `:541-559` — saved / changed / unchanged, mutually exclusive. The app had the first
        // two and rendered NOTHING for the third. An empty space says the same thing as a
        // screen still loading or a button that has failed to appear; `NO CHANGES` says *there
        // is nothing here to save, and that is correct*. It also stops the layout jumping by
        // the height of a pill on every save.
        let src = source()
        #expect(src.contains("\"NO CHANGES\""), "the unchanged state renders nothing again")
        #expect(src.contains("if justSaved {"), "the confirmation no longer wins over the pill")
    }

    @Test("the save word is offered, not demanded")
    func theQuietWord() {
        // `:551` — one Lora word in his own chosen colour. The app said `SAVE THE ARRIVAL` in
        // tracked mono: a chrome label in the imperative, telling him what the screen is for.
        // Same act, different relationship.
        let src = source()
        #expect(src.contains("Text(\"Save\")"), "the save control is shouting again")
        #expect(!src.contains("SAVE THE ARRIVAL"))
    }

    @Test("the confirmation clears at the design's 2 seconds, not a fifth longer")
    func theDwellIsTheDesign() {
        // `:419` — `setTimeout(() => setSaved_(false), 2000)`. The app held it 2.4s, which is
        // not a rounding of 2.0 but long enough that the confirmation is still there after he
        // has looked away and back — which turns *saved* into *stuck*.
        let src = source()
        #expect(src.contains("now() + 2.0"), "the confirmation dwells longer than the design's")
        #expect(!src.contains("now() + 2.4"))
    }

    // MARK: - F10.3 · who is speaking

    @Test("the field ASKS him — it does not describe itself")
    func theFieldIsAQuestion() {
        // `:471` — *"What do you call yourself?"* against the app's *"the name you arrive
        // with"*. One is a question put to him; the other is the app describing its own field.
        // This screen is the one place he says who he is, so the difference is who is speaking.
        let src = source()
        #expect(src.contains("What do you call yourself?"), "the field describes itself again")
        #expect(!src.contains("the name you arrive with"))
    }

    @Test("a name is a line, and it is held to 32")
    func theCapIsEnforced() {
        // `:472` — `maxLength={32}`, never enforced. Without it the preview above wraps and
        // the arrival card it feeds truncates silently somewhere else instead — the cap is
        // there so the overflow is refused at the one place he can see it happen.
        let src = source()
        #expect(src.contains("v.count > 32"), "the name field takes any length again")
        #expect(src.contains("String(v.prefix(32))"))
    }

    // MARK: - green on absent

    @Test("an unrecognised colour still says something about him")
    func theFallbackIsAPhrase() {
        // `?? "arriving"` — lower case, a phrase, in the same voice as the eight. A fallback
        // in a different register is how a preview tells him the app has lost track of him.
        let src = source()
        #expect(src.contains("?? \"arriving\""))
        #expect(!src.contains("\"ARRIVING\""), "the fallback is chrome again")
    }
}
