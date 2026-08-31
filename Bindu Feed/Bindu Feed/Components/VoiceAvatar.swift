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
    /// `border: 2px` on each side of a 22pt circle = 26, not 25.
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
                VoiceAvatar(archetype: archetype, size: size)
                    .background(
                        Circle()
                            .fill(ringColor)
                            .frame(width: size + Self.ringInset, height: size + Self.ringInset)
                    )
                    .zIndex(Double(archetypes.count - index))
            }
        }
    }
}
