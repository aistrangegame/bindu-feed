import Foundation

// D4.6 · **A RETURN IS A RETURN AND NOT A FRESH ARRIVAL.**
//
// `The Instrument v3.html:4899` `PEND={}` and `:5356-5357`:
//
//     function takeBack(panel,secsEl,id){const p=PEND[panel];
//       if(p&&p.id===id){secsEl.innerHTML=p.html;PEND[panel]=null;}}
//
// parked by `:5318-5320`, under the design's own sentence: *"leaving a register keeps it
// exactly as it was — its selection, what it had already given, its own pressure or parting
// — so a return is a return and not a fresh arrival."*
//
// The app reset `revealed` to 0 on **every** close, so a reading left half-earned had to be
// earned again from nothing. That is not merely a lost convenience: these sections are given
// by a world's own gesture — staying, pressing, parting, keeping pace — so re-earning them
// means performing the gesture again, and the world's claim is that what it gave, it gave.
//
// **THE ID GUARD IS THE MECHANISM, NOT A SAFETY CHECK.** `p.id === id` means a DIFFERENT star
// gets nothing. Without it the registry would hand one star's progress to the next one opened,
// which is worse than resetting — it is the wrong reading arriving pre-earned.
enum PointPending {

    /// One pending per register, exactly as the design keys `PEND` by panel.
    private static var pend: [Int: (star: String, revealed: Int)] = [:]

    /// `park` — leaving a reading keeps what it had already given.
    static func park(dimension: Int, star: String, revealed: Int) {
        pend[dimension] = (star, revealed)
    }

    /// `takeBack` — restores ONLY for the same star, and **only once**, because the design
    /// nulls `PEND[panel]` as it hands it back. Re-parked by the next close, so returning
    /// twice to the same reading works; what it forbids is one park serving two opens.
    static func takeBack(dimension: Int, star: String) -> Int? {
        guard let p = pend[dimension], p.star == star else { return nil }
        pend[dimension] = nil
        return p.revealed
    }

    /// A fresh walk. `PARK`/`PEND` are session state in the design and do not outlive it.
    static func resetAll() { pend = [:] }

    // An accessor to look INSIDE the registry was written here and then deleted: `check_wired`
    // flagged it the moment it existed, because its only caller was a test. A window into
    // private state asserts the implementation rather than the behaviour, and `takeBack`
    // returning nil already says everything the test needed — that nothing is waiting.
}
