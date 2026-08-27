import SwiftUI

// THE GATE'S DEALS — `canon/point-content.js:422-428`, verbatim.
//
// Five of them. The gate register used to hold one invented line ("keep pulling inward")
// and then, after the Rule-1 sweep, nothing at all — because the slot was real and the
// content had never been wired. This is the content: copied, not authored.
//
// `The Instrument v3.html:5098` prints `DEALS[0]` at the gate under the eyebrow "the gate".
// `The Point v9.html:877` draws one at random at its own gate. Both are canon; the axis's
// gate is the one this register is, so it takes the first.
enum PointDeals {
    static let all: [String] = [
        "You are a being of light, traveling. Inward from this gate: dimensions, universes, stars. Read a star — or descend onto it. Diving in is how you ascend.",
        "Nine enclosures, walked inward. What they hold is not explained at the door. That is not an oversight.",
        "The walk knows you are here. Some of it will introduce itself. Some of it will wait to be found.",
        "Everything in here you gathered yourself — arranged so it can catch you. And one or two things you did not gather. Those are gifts.",
        "A rope for the drowning minute. A cathedral for the returning hour. Both open from this gate.",
    ]

    /// `The Instrument v3.html:5098` — the axis's gate speaks the first.
    static var atTheGate: String { all[0] }
}

/// The gate (Z +2). `#gate` at `The Instrument v3.html:4423-4426`: bottom-anchored,
/// `padding:0 34px 96px`, the eyebrow in Space Mono 9 / `.28em` / uppercase at
/// `rgba(237,232,227,.34)`, and the deal in serif 16 / line-height 1.72 at
/// `rgba(237,232,227,.82)`. Left-aligned — the gate is the one register that speaks in
/// a paragraph rather than a centred line.
struct PointGateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)
            Text("THE GATE")
                .spaceMonoTracked(9, em: 0.28)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.34))
                .padding(.bottom, 14)
            Text(PointDeals.atTheGate)
                .font(.lora(16))
                .lineSpacing(16 * 0.72)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 34)
        .padding(.bottom, 96)
        .allowsHitTesting(false)
    }
}

/// `SM` — `canon/point-content.js:16`, verbatim. The three words the instrument uses for a
/// star's state, and the ones the descent prompt reports as `Status:`. `STL` (its display
/// form, `point-levels.js:9`) lives in `PointStatusLabel` beside the readings that print it.
enum PointStatus {
    static func word(_ st: String) -> String {
        switch st {
        case "w": return "walked"
        case "p": return "in progress"
        default:  return "seeded"
        }
    }
}
