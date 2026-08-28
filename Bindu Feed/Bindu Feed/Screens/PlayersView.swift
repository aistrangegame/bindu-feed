import SwiftUI

// Phase 9 — Players View.
//
// The grid of every presence the field carries: eight lenses (Bindu,
// Gaia, Sid, Arch, Sakshi, Karishma, Ashrey, Lalita), two roots (Neev,
// Shweta), and Ash — "the one who replies." Each card routes to The
// Turning via the .archetype route.
struct PlayersView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: [FeedRoute]

    @State private var showHub = false

    private static let lensNames: [String] = [
        "Bindu", "Gaia", "Sid", "Arch", "Sakshi", "Karishma", "Ashrey", "Lalita"
    ]
    private static let rootNames: Set<String> = ["Neev", "Shweta"]
    private static let ashName = "Ash"

    private var lenses: [Archetype] {
        // Preserve the canonical lens order regardless of Airtable Sort.
        Self.lensNames.compactMap { name in
            store.archetypes.first { $0.name == name }
        }
    }

    private var roots: [Archetype] {
        store.archetypes
            .filter { Self.rootNames.contains($0.name) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var ash: Archetype? {
        store.archetypes.first { $0.name == Self.ashName }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 11),
        GridItem(.flexible(), spacing: 11)
    ]

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 16)

                    subtitle
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.bottom, BinduTheme.space24)

                    lensGrid
                        .padding(.horizontal, BinduTheme.space16)

                    sectionDivider(glyph: "▽", color: Color(hex: "#7A8899"), label: "ROOTS")
                        .padding(.vertical, 28)

                    rootGrid
                        .padding(.horizontal, BinduTheme.space16)

                    sectionDivider(glyph: "◉", color: BinduTheme.colorAsh, label: nil)
                        .padding(.vertical, 28)

                    if let ash {
                        AshramCard(archetype: ash) {
                            $path.pushDissolve(FeedRoute.home(ash))
                        }
                        .padding(.horizontal, BinduTheme.space16)
                    }

                    Color.clear.frame(height: 56)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top, spacing: 0) {
            // Back + hub on the left, the centered title where the nav bar's principal
            // item used to sit — the router has no toolbar to host either.
            ZStack {
                Text("THE PLAYERS")
                    .spaceMonoTracked(10, em: 0.14).foregroundColor(BinduTheme.inkTertiary)
                HStack(spacing: 4) {
                    BackChevron { $path.popDissolve() }
                    HubTrigger(open: $showHub)
                    Spacer()
                }
            }
            .padding(.horizontal, BinduTheme.space16)
            .padding(.vertical, 6)
        }
        .sonicContext(.base)
        .hubOverlay(open: $showHub, path: $path)
    }

    // MARK: - Subtitle

    private var subtitle: some View {
        Text("Eight ways of reading. Two roots. One who replies.")
            .font(.loraItalic(13))
            .foregroundColor(BinduTheme.inkTertiary)
            .lineSpacing(4)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Grids

    private var lensGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            // playerArrive — the presences gather from stillness, staggered (comp i*0.075).
            ForEach(Array(lenses.enumerated()), id: \.element.id) { i, archetype in
                StaggeredReveal(triggered: true, delay: Double(i) * 0.075, duration: 0.8, rise: 10) {
                    PlayerCard(archetype: archetype, isSubstrate: false) {
                        $path.pushDissolve(FeedRoute.home(archetype))
                    }
                }
            }
        }
    }

    private var rootGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(roots) { archetype in
                PlayerCard(archetype: archetype, isSubstrate: true) {
                    $path.pushDissolve(FeedRoute.home(archetype))
                }
            }
        }
    }

    // MARK: - Section divider

    private func sectionDivider(glyph: String, color: Color, label: String?) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                Rectangle()
                    .fill(BinduTheme.hairline)
                    .frame(height: 0.5)
                Text(glyph)
                    .font(.system(size: 11))
                    .foregroundColor(color.opacity(0.30))
                Rectangle()
                    .fill(BinduTheme.hairline)
                    .frame(height: 0.5)
            }
            .padding(.horizontal, BinduTheme.space20)

            if let label {
                Text(label)
                    .font(.spaceMono(9))
                    .tracking(1.26)
                    .foregroundColor(BinduTheme.inkTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, BinduTheme.space20)
            }
        }
    }
}

// MARK: - Player card (lens or root)

private struct PlayerCard: View {
    let archetype: Archetype
    let isSubstrate: Bool

    /// Players View.html:155-177 — the border alpha is PER-PRESENCE, and it is the only
    /// thing that lights the Zeroth and the Meta differently from the eight. Flattening it
    /// to one value loses that signal entirely.
    ///   zeroth (Bindu) `42` = 25.9%  ·  meta (Lalita) `38` = 22%
    ///   substrate       `1C` = 11%   ·  everything else `26` = 14.9%
    private var borderAlpha: Double {
        if isSubstrate { return 0.11 }
        switch archetype.name {
        case "Bindu":  return 0.259
        case "Lalita": return 0.22
        default:       return 0.149
        }
    }
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 14) {
                glyphCircle
                    .padding(.top, 4)

                VStack(spacing: 5) {
                    Text(archetype.name)
                        .font(.lora(isSubstrate ? 11 : 12, weight: .medium))
                        .foregroundColor(archetype.color.opacity(isSubstrate ? 0.80 : 0.94))
                        .lineLimit(1)
                    Text(archetype.role.uppercased())
                        .font(.spaceMono(8))
                        .tracking(0.8)
                        .foregroundColor(isSubstrate ? archetype.color.opacity(0.50) : BinduTheme.inkTertiary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(archetype.color.opacity(isSubstrate ? 0.04 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(archetype.color.opacity(borderAlpha), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleStyle(scale: 0.96))
    }

    private var glyphCircle: some View {
        let size: CGFloat = isSubstrate ? 52 : 64
        return ZStack {
            // Outer atmospheric haze
            Circle()
                .fill(
                    RadialGradient(
                        colors: [archetype.color.opacity(0.16), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.85
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            // Vessel
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            archetype.color.opacity(0.118),   // ${color}1E
                            archetype.color.opacity(0.039),   // ${color}0A
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle().strokeBorder(archetype.color.opacity(0.196), lineWidth: 1)  // ${color}32
                )

            // Glyph — each presence at its own breath cadence (comp)
            GlyphView(
                glyph: archetype.glyph,
                size: glyphSize,
                color: archetype.color,
                animation: GlyphAnimation.presence(archetype.name).0,
                period: GlyphAnimation.presence(archetype.name).1
            )
            .shadow(color: archetype.color.opacity(0.55), radius: glowRadius)
        }
        .frame(width: size, height: size)
    }

    private var glyphSize: CGFloat {
        switch archetype.name {
        case "Bindu":   return 34
        case "Lalita":  return 36
        case "Shweta":  return 32
        case "Neev":    return 28
        default:        return 30
        }
    }

    private var glowRadius: CGFloat {
        switch archetype.name {
        case "Bindu":   return 18
        case "Lalita":  return 14
        case "Neev":    return 8
        case "Shweta":  return 7
        default:        return 10
        }
    }
}

// MARK: - Ashram card (Ash, full-width)

private struct AshramCard: View {
    let archetype: Archetype
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                glyphCircle

                VStack(alignment: .leading, spacing: 3) {
                    Text(archetype.name)
                        .font(.lora(14, weight: .medium))
                        .foregroundColor(archetype.color.opacity(0.94))
                    Text(archetype.role.uppercased())
                        .font(.spaceMono(9))
                        .tracking(0.9)
                        .foregroundColor(BinduTheme.inkTertiary)
                    Text("the one who replies")
                        .font(.loraItalic(11))
                        .foregroundColor(archetype.color.opacity(0.48))
                        .padding(.top, 2)
                }

                Spacer(minLength: 8)

                Text("›")
                    .font(.system(size: 20))
                    .foregroundColor(archetype.color.opacity(0.50))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(archetype.color.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(archetype.color.opacity(0.28), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleStyle(scale: 0.985))
    }

    private var glyphCircle: some View {
        let size: CGFloat = 52
        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [archetype.color.opacity(0.14), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.85
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            archetype.color.opacity(0.18),
                            archetype.color.opacity(0.06),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle().strokeBorder(archetype.color.opacity(0.32), lineWidth: 1)
                )

            Text(archetype.glyph)
                .font(.system(size: 22))
                .foregroundColor(archetype.color)
                .shadow(color: archetype.color.opacity(0.5), radius: 9)
        }
        .frame(width: size, height: size)
    }
}


/// THE PRESS THAT DOES NOT EAT THE SCROLL.
///
/// Both cards used `.simultaneousGesture(DragGesture(minimumDistance: 0))` to drive their
/// `pressed` highlight. A zero-distance drag on a scroll CHILD claims the touch sequence
/// before the enclosing `ScrollView` can recognise a pan, so the list could not be scrolled —
/// **and that fails a real finger, not only a synthetic one.** Neev, Shweta and Ash live below
/// the fold, so the eleventh voice was unreachable in his own instrument for that reason.
///
/// It was recorded as "synthetic touches don't drive a SwiftUI ScrollView". That was wrong:
/// the Return's story view scrolls under the same synthetic drags, because it has no child
/// gesture competing. Same class as the Point readings' shadowing, inverted — there a parent
/// `.gesture` lost to a ScrollView; here a child gesture beats one.
///
/// `ButtonStyle` is the scroll-cooperative way to get the same `isPressed`.
struct PressScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}
