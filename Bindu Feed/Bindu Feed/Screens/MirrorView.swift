import SwiftUI

// Phase 9 — The Mirror.
//
// One reflection per day, chosen deterministically by date-hash over the
// pool of Live Mirror Cards. No tracking, no graduation; every reflection
// is Live from day one. The register (Vow / Koan) drives how the card
// renders — Vow lands upright with a closing dot, Koan stays italic with
// an open ring. One Bindu Draw per day reveals one alternate face, then
// spends to a hollow ring until tomorrow.
struct MirrorView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: [FeedRoute]

    @State private var loaded = false
    @State private var loadError = false
    @State private var floodOpacity: Double = 1.0
    @State private var currentIdx: Int = 0
    @State private var drawn = false
    @State private var showHub = false
    // Bumped on draw so SwiftUI re-mounts the reflection card and re-runs
    // its rise animation — otherwise SwiftUI would diff the body change in
    // place and the alternate would appear without the dissolve.
    @State private var cardAnimationKey: Int = 0
    @State private var leaving = false          // the current card fading/lifting out on a draw

    var body: some View {
        ZStack(alignment: .top) {
            BinduTheme.bgDeep.ignoresSafeArea()

            TerraAtmosphere()

            VStack(spacing: 0) {
                Color.clear.frame(height: 56)

                header
                    .padding(.bottom, BinduTheme.space20)

                content
            }

            HStack(spacing: 10) {
                BackChevron { $path.popDissolve() }
                HubTrigger(open: $showHub)
                Spacer()
            }
            .padding(.horizontal, BinduTheme.space16)
            .padding(.top, BinduTheme.space8)

            // Flood color carries over from Room Selection — same lift
            // pattern as GameView. Terra now (was Ashrey-teal in the old
            // tracking-model Mirror).
            BinduTheme.colorAsh
                .ignoresSafeArea()
                .opacity(floodOpacity)
                .allowsHitTesting(false)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9)) { floodOpacity = 0 }
        }
        .task(id: store.foundationLoaded) {
            await loadIfNeeded()
        }
        .sonicContext(.base)
        .hubOverlay(open: $showHub, path: $path)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 9) {
            Text("THE MIRROR")
                .spaceMonoTracked(11)
                .tracking(2.6)
                .foregroundColor(BinduTheme.colorAsh.opacity(0.78))
            Text("what surfaces on \(prettyDayLabel)")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Content states

    @ViewBuilder
    private var content: some View {
        if !loaded {
            centeredItalic("the field is gathering…", color: BinduTheme.inkTertiary)
        } else if loadError {
            centeredItalic(
                "The field is resting. Try again when you're ready.",
                color: BinduTheme.colorLalita,
                maxWidth: 280
            )
        } else if store.mirrorCards.isEmpty {
            centeredItalic("Nothing is reflected yet.", color: BinduTheme.inkTertiary)
        } else {
            mirrorBody
        }
    }

    private func centeredItalic(_ text: String, color: Color, maxWidth: CGFloat? = nil) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(.loraItalic(13))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .frame(maxWidth: maxWidth)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mirrorBody: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            ReflectionCard(card: store.mirrorCards[currentIdx])
                .id(cardAnimationKey)
                .opacity(leaving ? 0 : 1)          // the old face departs before the new surfaces
                .offset(y: leaving ? -6 : 0)
                .padding(.horizontal, BinduTheme.space24)

            Spacer(minLength: 0)

            binduDraw
                .padding(.bottom, BinduTheme.space24 + 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bindu Draw

    private var binduDraw: some View {
        VStack(spacing: 14) {
            Button { drawAlternate() } label: {
                drawGlyph.padding(8)
            }
            .buttonStyle(.plain)
            .disabled(drawn)

            Text(drawn ? "DRAWN · RETURN TOMORROW" : "DRAW ONCE MORE")
                .spaceMonoTracked(9)
                .tracking(1.8)
                .foregroundColor(drawn ? BinduTheme.inkTertiary : BinduTheme.colorBindu.opacity(0.62))
                .modifier(BreathingOpacity(active: !drawn, lo: 0.26, hi: 1.0, duration: 5))
        }
    }

    @ViewBuilder
    private var drawGlyph: some View {
        if drawn {
            Circle()
                .stroke(BinduTheme.colorBindu.opacity(0.4), lineWidth: 1)
                .frame(width: 13, height: 13)
                .opacity(0.5)
        } else {
            EmberDot()
        }
    }

    // MARK: - Loading + selection

    private func loadIfNeeded() async {
        guard !loaded else { return }
        guard store.foundationLoaded else { return }

        await store.loadMirrorCards()
        // A1.5 · **A CARD WITH NO REGISTER IS NOT SHOWN, RATHER THAN SHOWN AS THE WRONG ONE.**
        //
        // `MirrorCard.register` is optional, and the render asked `card.register == .koan`,
        // so a nil silently became a VOW — upright Lora, *"A VOW · ARRIVED"*, closing `·` —
        // on a card that may be a koan. Not an absence: **a confident assertion of the other
        // register.**
        //
        // This is §6's blank-`Status` lesson in a second field. That rule is that a record
        // missing a discriminator is invisible rather than guessed, and it is enforced on
        // every reader; `Card Register` is a discriminator too — §8: *"The `Card Register`
        // field drives render"* — and it was being guessed. Filtering costs nothing today
        // (all 24 Live cards carry one) and is the only behaviour that cannot be wrong: the
        // app does not know which register a blank card belongs to, so it does not choose.
        let cards = store.mirrorCards.filter { $0.register != nil }

        if cards.isEmpty {
            loadError = store.error != nil
            loaded = true
            return
        }

        let key = Self.dayKey
        // A1.6 · rendezvous, not modulus — see `MirrorDay`. The count appears nowhere, so a
        // card added or archived no longer re-decides every other day.
        guard let baseIdx = MirrorDay.pick(cards.map(\.id), key: key) else {
            loaded = true
            return
        }
        let savedDrawn = UserDefaults.standard.bool(forKey: drawnKey(for: key))
        let savedIdx = UserDefaults.standard.object(forKey: idxKey(for: key)) as? Int

        if savedDrawn, let savedIdx, cards.indices.contains(savedIdx) {
            currentIdx = savedIdx
            drawn = true
        } else {
            currentIdx = baseIdx
            drawn = false
        }
        loaded = true
    }

    // The "+3" lower bound keeps the alternate from landing too close to
    // the base — same prototype trick. Falls through to "spent without
    // revealing" if the pool is too small to honour the gap.
    private func drawAlternate() {
        guard !drawn else { return }
        // A1.5 · the DRAW reads the same pool and must filter identically. One reader
        // filtered and the other not is the shape §10 records for claims: *every* path
        // its owner can leave by, not only the polite one. A blank-register card the
        // day-pick refuses would otherwise arrive through the Bindu Draw instead.
        let cards = store.mirrorCards.filter { $0.register != nil }
        guard cards.count > 3 else {
            drawn = true
            persist(idx: nil, drawn: true)
            return
        }

        let key = Self.dayKey
        // A1.6 · the alternate is second place by the same scoring, which is stable for the
        // same reason first place is — and cannot collide with the base, where the old
        // `(base + 3 + hash % (count − 3)) % count` could land back on it as the pool changed
        // size. The "+3 gap" it was protecting was an index trick guarding an index problem.
        guard let altIdx = MirrorDay.alternate(cards.map(\.id), key: key) else {
            drawn = true
            persist(idx: nil, drawn: true)
            return
        }

        // Two-stage (comp The Mirror): the current reflection fades out and lifts, THEN the
        // alternate rises in — the old face departs before the new surfaces.
        withAnimation(.easeInOut(duration: 0.62)) { leaving = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
            currentIdx = altIdx
            drawn = true
            cardAnimationKey += 1       // new ReflectionCard identity → its own rise-in reveal
            leaving = false
        }
        persist(idx: altIdx, drawn: true)
    }

    private func persist(idx: Int?, drawn: Bool) {
        let key = Self.dayKey
        UserDefaults.standard.set(drawn, forKey: drawnKey(for: key))
        if let idx {
            UserDefaults.standard.set(idx, forKey: idxKey(for: key))
        }
    }

    private func drawnKey(for day: String) -> String { "mirror.draw.\(day).drawn" }
    private func idxKey(for day: String)   -> String { "mirror.draw.\(day).idx" }

    // MARK: - Day helpers

    // Local time on purpose — "today" should match what the user reads on
    // their phone, not UTC. Crossing midnight locally rolls to a new card.
    private static var dayKey: String { AirtableService.localDayString() }   // POSIX/Gregorian/local

    private var prettyDayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: Date())
    }

    // FNV-1a 32-bit, same algo as the design prototype. Deterministic so
    // the same date surfaces the same reflection across launches.
    private static func fnv1a(_ s: String) -> UInt32 {
        var h: UInt32 = 2166136261
        for byte in s.utf8 {
            h ^= UInt32(byte)
            h = h &* 16777619
        }
        return h
    }
}

// MARK: - The reflection card

private struct ReflectionCard: View {
    let card: MirrorCard
    @State private var visible = false

    var body: some View {
        let isKoan = card.register == .koan
        let registerLabel = isKoan ? "STILL LIVING" : "A VOW · ARRIVED"
        let closing = isKoan ? "◌" : "·"

        VStack(spacing: 30) {
            Text(registerLabel)
                .spaceMonoTracked(10)
                .tracking(2.5)
                .foregroundColor(BinduTheme.colorAsh.opacity(0.72))

            Text(card.body)
                .font(isKoan ? .loraItalic(22) : .lora(22, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(9)
                .fixedSize(horizontal: false, vertical: true)

            Text(closing)
                .font(.lora(15))
                .foregroundColor(BinduTheme.colorAsh.opacity(0.55))
        }
        .padding(.vertical, 38)
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: "#15121C"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(BinduTheme.colorAsh.opacity(0.28), lineWidth: 1)
        )
        .overlay(  // diagonal terra sheen — the surface you look into
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(
                    colors: [
                        BinduTheme.colorAsh.opacity(0.12),
                        Color.white.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: UnitPoint(x: 0.0, y: 0.0),
                    endPoint: UnitPoint(x: 0.6, y: 0.5)
                ))
                .allowsHitTesting(false)
        )
        .shadow(color: BinduTheme.colorAsh.opacity(0.15), radius: 28)
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                visible = true
            }
        }
    }
}

// MARK: - Atmosphere

// All three read the ONE master breath (Wave 4 Era-A reconciliation) — no local
// repeatForever. `duration` is kept on BreathingOpacity for call-site compat but
// the single 0.1 Hz period now governs.
private struct TerraAtmosphere: View {
    @EnvironmentObject private var breath: Breath
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [BinduTheme.colorAsh.opacity(0.16), BinduTheme.colorAsh.opacity(0.04), .clear],
                center: UnitPoint(x: 0.5, y: 0.3), startRadius: 0, endRadius: 500
            )
            .opacity(0.40 + 0.32 * breath.value)

            RadialGradient(
                colors: [BinduTheme.colorAsh.opacity(0.07), .clear],
                center: UnitPoint(x: 0.5, y: 1.05), startRadius: 0, endRadius: 460
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Ember dot

private struct EmberDot: View {
    @EnvironmentObject private var breath: Breath
    var body: some View {
        Text("·")
            .font(.system(size: 30))
            .foregroundColor(BinduTheme.colorBindu)
            .shadow(color: BinduTheme.colorBindu.opacity(0.7), radius: 8)
            .opacity(0.55 + 0.45 * breath.value)
            .scaleEffect(0.96 + 0.11 * breath.value)
    }
}

// MARK: - Breathing opacity modifier

private struct BreathingOpacity: ViewModifier {
    let active: Bool
    let lo: Double
    let hi: Double
    let duration: Double        // kept for call-site compat; the master period governs
    @EnvironmentObject private var breath: Breath

    func body(content: Content) -> some View {
        content.opacity(active ? (lo + (hi - lo) * breath.value) : 1)
    }
}
