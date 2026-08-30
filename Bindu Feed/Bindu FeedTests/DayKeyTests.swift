import Testing
import Foundation
@testable import Bindu_Feed

// §9 · the day-key contract, and the calendar that broke it.
@Suite struct DayKeyTests {

    @Test("a non-Gregorian device calendar cannot corrupt a day-key")
    func theCalendarCannotMoveTheDay() {
        // **THE BUG THIS FIXES, AND IT WAS SILENT FOR A SUBSET OF USERS.** Eight sites built
        // a bare `DateFormatter` with `dateFormat = "yyyy-MM-dd"` and no locale or calendar.
        // `DateFormatter` then uses the DEVICE's — so on a Buddhist calendar `"2026-08-30"`
        // parses as Buddhist year 2026, which is Gregorian 1483. `days(since:)` is §10's
        // *age comes from days, never from rank* mechanism and was one of the eight.
        //
        // Asserted by parsing through the factory and checking the Gregorian components,
        // which is the property the contract is about — not by comparing two formatters,
        // which would agree with each other while both being wrong.
        let f = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC") ?? .current)
        let d = f.date(from: "2026-08-30")
        #expect(d != nil, "the canonical day string no longer parses")
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC") ?? .current
        #expect(cal.component(.year, from: d!) == 2026)
        #expect(cal.component(.month, from: d!) == 8)
        #expect(cal.component(.day, from: d!) == 30)
    }

    @Test("the writer and the reader agree on which day it is")
    func writesAndReadsAgree() {
        // `localDayString`'s own claim: *"every date the app WRITES and every day-key it
        // COMPARES flows through this, so writes and reads can never disagree."* That was
        // false while eight readers built their own. This pins the round trip.
        let now = Date()
        let written = AirtableService.localDayString(now)
        let read = AirtableService.dayFormatter(timeZone: .current).date(from: written)
        #expect(read != nil, "the app cannot read back the day it just wrote")
        #expect(AirtableService.localDayString(read!) == written)
    }

    @Test("age is measured in days, and an empty date is zero rather than a guess")
    func daysSince() {
        // §10: *age comes from days, never from rank.* The empty case must be 0 — a missing
        // date is not an old one.
        #expect(ReturnRing.days(since: "") == 0)
        let today = AirtableService.localDayString(Date())
        #expect(ReturnRing.days(since: today) == 0, "today is not zero days old")
    }

    @Test("nothing builds its own day formatter — the contract is asserted where it can FAIL")
    func oneFormatter() {
        // **THE DOC COMMENT IS WHY THIS BUG SURVIVED.** `localDayString` asserts *"every date
        // the app WRITES and every day-key it COMPARES flows through this"* — and it says so
        // **in the one place that honoured it**. A reader checking the contract lands on the
        // implementation, finds it correctly written, and leaves. **A contract asserted at its
        // own implementation cannot detect its own violation.**
        //
        // So the assertion lives here, where a new bare formatter makes it fail — the same
        // move `ArrivalNameTests.oneSource` makes for the display name. It reads source
        // because that is where this particular contract can be broken: every violation is
        // valid Swift that is correct on any Gregorian device, so no runtime assertion on any
        // one device can see it.
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Bindu Feed")
        let fm = FileManager.default
        var offenders: [String] = []
        guard let walker = fm.enumerator(at: app, includingPropertiesForKeys: nil) else {
            Issue.record("could not read the app sources"); return
        }
        for case let url as URL in walker where url.pathExtension == "swift" {
            guard let text = try? String(contentsOf: url, encoding: .utf8) else { continue }
            // the factory itself, and the Return's own dated formatters, are the sanctioned
            // ones — everything else must go through `AirtableService.dayFormatter`.
            if url.lastPathComponent == "AirtableService.swift" { continue }
            if url.lastPathComponent == "ReturnCanon.swift" { continue }
            for (n, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
                let t = line.trimmingCharacters(in: .whitespaces)
                if t.hasPrefix("//") { continue }
                if t.contains("dateFormat") && t.contains("yyyy-MM-dd") {
                    offenders.append("\(url.lastPathComponent):\(n + 1)")
                }
            }
        }
        #expect(offenders.isEmpty,
                "these build their own day formatter instead of AirtableService.dayFormatter, so a non-Gregorian device calendar corrupts them: \(offenders.joined(separator: ", "))")
    }
}
