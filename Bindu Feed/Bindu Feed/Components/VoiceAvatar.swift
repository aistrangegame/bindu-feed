import SwiftUI

struct VoiceAvatar: View {
    let archetype: Archetype
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            // outer glow halo
            Circle()
                .fill(archetype.color.opacity(0.22))
                .blur(radius: 4)
                .frame(width: size * 1.6, height: size * 1.6)

            // body — a SOLID disc in the archetype's colour (the comps draw filled discs,
            // not the ghosted 0.30 ring this used to render), with a white glyph.
            Circle()
                .fill(archetype.color)
                .frame(width: size, height: size)

            Text(archetype.glyph)
                .font(.system(size: size * 0.52))
                .foregroundColor(.white.opacity(0.88))
        }
        .frame(width: size, height: size)
    }
}

// Overlapping circles, first archetype layered on top.
// Background ring in bgCard keeps the overlap clean.
struct VoiceAvatarStack: View {
    let archetypes: [Archetype]
    var size: CGFloat = 22
    var ringColor: Color = BinduTheme.bgCard

    /// F2.5 · `Claude Design Round 1/Home Feed.html:100` — `marginLeft: i > 0 ? -7 : 0` on a **22pt** circle, so the
    /// overlap is `7/22`. The app used `size * 0.55` = 12.1pt, **1.7× the design**, and the
    /// stack read as a tight clump rather than a row of faces standing slightly in front of
    /// one another.
    static let overlapRatio: CGFloat = 7.0 / 22.0
    /// F2.5 · **`box-sizing: border-box`, AND IT DECIDES THE WHOLE STACK.**
    /// `Claude Design Round 1/Home Feed.html:14` sets it on `*`, and the avatar at `:100` is
    /// `width:22 … border:'2px solid var(--card)'` — so **22 is the OUTER footprint and the
    /// coloured disc is 18**. The ring is drawn INSIDE the 22, not around it.
    ///
    /// The app read it as a content box: a 22pt disc with the ring added outside, giving a
    /// 26pt footprint. Every face rendered 18% too wide and every disc 22% too large — and
    /// because `marginLeft:-7` is an absolute offset, the ADVANCE stayed right (22−7 = 15)
    /// while the footprint grew, so the occlusion went from 7/22 = 32% to 11/26 = 42%. The
    /// row's own gap — *"the stack reads as a tight clump"* — was reduced and not closed.
    ///
    /// **AND THE TEST ENCODED THE SAME MISREADING.** `AvatarStackTests` asserted
    /// `22 + ringInset == 26` under the name *"26 around a 22pt face"* — a tautology in the
    /// shape of a measurement, so the suite could not have caught this and a green run was
    /// never evidence. Found 2026-08-30 by an adversarial re-read, not by the tests.
    ///
    /// This is now the ring's THICKNESS on each side, and the outer edge is `size`.
    static let ringInset: CGFloat = 4

    var body: some View {
        // **EVERY ARCHETYPE, AS THE DESIGN RENDERS THEM.** This capped at four and added
        // `Text("+\(count - maxVisible)")` — **an invented affordance**, and one no checker
        // could see: it is INTERPOLATED, and `check_rendered` extracts literals. The
        // gathering's size became a number in a chip instead of a row of faces, which is a
        // different claim about what a gathering is.
        let overlap = size * Self.overlapRatio

        HStack(spacing: -overlap) {
            ForEach(Array(archetypes.enumerated()), id: \.offset) { index, archetype in
                // The disc sits INSIDE the ring: outer edge `size`, face `size − 4`.
                //
                // **AND THE FOOTPRINT MUST BE THE LAYOUT SIZE, NOT JUST THE DRAWN ONE.** A
                // `.background` is drawn behind and contributes NOTHING to layout, so with
                // the face alone in the stack the advance would be `18 − 7 = 11` and the
                // ring — still 22 wide — would occlude 50%, worse than the 26pt version this
                // is fixing. The explicit `.frame(size)` is what makes the border box real:
                // advance `22 − 7 = 15`, exactly the design's `marginLeft:-7` on a 22pt div.
                VoiceAvatar(archetype: archetype, size: size - Self.ringInset)
                    .background(
                        Circle()
                            .fill(ringColor)
                            .frame(width: size, height: size)
                    )
                    .frame(width: size, height: size)
                    .zIndex(Double(archetypes.count - index))
            }
        }
    }
}
