import XCTest

// THE LAUNCH SMOKE TEST — one test, and it is the only UI test in this build.
//
// **WHAT WAS HERE BEFORE, AND WHY IT WENT.** Xcode's template leaves three tests in a new UI
// target, and all three shipped untouched for the length of this project:
//
//   · `testExample()` — `app.launch()` and nothing else, under a comment telling you where to
//     put the assertions. Deleted: it duplicated this test's launch and added no failure mode.
//   · `testLaunchPerformance()` — `measure(metrics: [XCTApplicationLaunchMetric()])` with **no
//     baseline recorded**, so there is no value it can be worse than. Deleted: §10's tautology
//     in the performance layer — it cannot fail, and it took a green checkmark for saying so.
//   · `testLaunch()` — launched, attached a screenshot, asserted nothing. **Rewritten below**
//     rather than deleted, because its `app.launch()` has a real failure mode and §15 records
//     that exact failure happening: `AVAudioEngineGraph::Initialize: required condition is
//     false: inputNode != nullptr || outputNode != nullptr`, an Obj-C assert on first device
//     launch that no unit test could reach. A launch smoke test is worth having. A launch
//     smoke test that asserts nothing is three green checkmarks over an untested launch.
//
// **AND THEY MADE THE BAR INCONSISTENT.** Earlier three-run bars in this build counted 516 and
// did not include these; a later one counted 533 and did. The same suite reported two numbers
// depending on which target the counter reached, which is the instrument-counting-the-evidence
// fault in the one measurement the build's claims of doneness rest on.
final class LaunchSmokeTest: XCTestCase {

    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testTheAppLaunchesAndRendersSomething() throws {
        let app = XCUIApplication()
        app.launch()

        // The launch itself is half the assertion — `AVAudioEngine` starting on a graph with
        // no I/O node materialised is an Obj-C assert, not a Swift throw, so it terminates the
        // process rather than failing anything catchable.
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 30),
                      "the app did not reach the foreground — state \(app.state.rawValue)")

        // The other half: a process that is running and drawing nothing is what a crashed
        // render or a blank first surface looks like, and `runningForeground` alone is happy
        // with it. The token gate is the first surface on a clean install; the Practice Door
        // is the first on a returning one. Either draws text.
        let drew = app.staticTexts.firstMatch.waitForExistence(timeout: 20)
        XCTAssertTrue(drew, "launched to a foreground process with no text on screen")

        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "first surface"
        shot.lifetime = .keepAlways
        add(shot)
    }
}
