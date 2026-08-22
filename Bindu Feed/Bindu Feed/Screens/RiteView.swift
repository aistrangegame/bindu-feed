import SwiftUI

// THE RITE — the daily meeting. Four movements as one flow, no Next buttons:
// Arrival → Reading → Gathering → Recognition, then the Sealing. A full-screen,
// chrome-free ceremony (modelled on PracticeDoorView) reached via the `.rite`
// route. Wave 2.
//
// Wave-2 scope note (flagged in the conformance walk): the Rite plays the CANON
// story (C-1052, "The Two Who Were One") with the ten authored voices, exactly as
// the prototype does. Wiring it to meet a live feed story — with each archetype's
// actual field comments as the Gathering's voices, and a real return-depth — is a
// larger dynamic system, deferred.

enum RiteMovement { case arrival, reading, gathering, recognition, sealed }

/// A quiet breathing-opacity hint that reads the ONE master breath (never a local
/// `repeatForever` — that's the one-phase-contract anti-pattern). Phase-locked to
/// the app's single 0.1 Hz origin via the injected `Breath`.
struct RiteBreathe: ViewModifier {
    @EnvironmentObject private var breath: Breath
    func body(content: Content) -> some View {
        content.opacity(0.28 + 0.42 * breath.value)
    }
}

struct RiteView: View {
    @Binding var path: [FeedRoute]
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var store: FeedStore

    /// Today's real story (rotating daily) and its real field-comment voices. Defaults to
    /// the canon story/voices when the feed isn't reachable, so the Rite always stands up.
    var storyData: RiteStoryData = .canon
    var voices: [RiteVoice]? = nil

    /// 0 = first meeting; ≥1 = a return (the user has sealed a ring here before). Derived
    /// from the user's Ash-comment count on today's story (FeedStore.riteMeeting). The
    /// Gathering's budget law reads it to thin the field on returns (RiteBudget.tiers).
    var depth: Int = 0

    /// When set, the Rite is running standalone (e.g. from the unmet Door, outside
    /// the nav stack); finishing calls this instead of popping the path.
    var onFinish: (() -> Void)? = nil

    @State private var movement: RiteMovement = .arrival
    @State private var keptText: String = ""

    private var nearBlack: Bool {
        movement == .gathering || movement == .recognition || movement == .sealed
    }

    var body: some View {
        ZStack {
            (nearBlack ? Color(hex: "#050408") : BinduTheme.bgDeep)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: nearBlack)

            content
                .transition(.opacity)

            // A quiet, always-present way out — you are never trapped in the Rite. Leaving
            // marks today dismissed so the Door won't force it again (it stays in the turn).
            if movement != .sealed {
                VStack {
                    HStack {
                        Button(action: leave) {
                            Text("‹ leave")
                                .font(.spaceMono(9)).tracking(2)
                                .foregroundStyle(BinduTheme.inkTertiary.opacity(0.6))
                                .padding(16)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sonicContext(.base)   // the bed — 110 Hz breath under the whole Rite
    }

    private func leave() {
        store.markRiteDismissedToday()
        finish()
    }

    @ViewBuilder private var content: some View {
        switch movement {
        case .arrival:
            RiteArrival(data: storyData, onBegin: begin)
        case .reading:
            RiteReading(data: storyData, onGather: toGathering)
        case .gathering:
            RiteGatheringView(depth: depth, voices: voices ?? RiteVoices.all, onDone: toRecognition)
        case .recognition:
            RiteRecognitionView(onSealed: toSealed)
        case .sealed:
            RiteSealed(data: storyData, text: keptText, onDoor: finish)
        }
    }

    // MARK: - Movement transitions (each with its threshold tone)

    private func begin() {
        soundEngine.riteThreshold(hz: 220, dur: 6)   // the threshold into Reading
        withAnimation(.easeInOut(duration: 1.0)) { movement = .reading }
    }
    private func toGathering() {
        soundEngine.riteThreshold(hz: 146, dur: 7)
        withAnimation(.easeInOut(duration: 1.2)) { movement = .gathering }
    }
    private func toRecognition() {
        soundEngine.riteThreshold(hz: 261, dur: 7)
        withAnimation(.easeInOut(duration: 1.2)) { movement = .recognition }
    }
    private func toSealed(_ text: String) {
        keptText = text
        withAnimation(.easeInOut(duration: 1.0)) { movement = .sealed }
        Task { await store.logStoryMet(codexId: storyData.codexId, title: storyData.title) }
    }
    private func finish() {
        if let onFinish {
            onFinish()
        } else if !path.isEmpty {
            $path.popToRootDissolve()
        }
    }
}

// MARK: - I · Arrival

private struct RiteArrival: View {
    let data: RiteStoryData
    let onBegin: () -> Void
    @State private var appear = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            Text(RiteWord.arrivalKicker)
                .font(.spaceMono(10)).tracking(3)
                .foregroundStyle(BinduTheme.inkTertiary)
            Text(RiteWord.arrivalMeeting)
                .font(.lora(15)).italic()
                .foregroundStyle(BinduTheme.inkSecondary)
            VStack(spacing: 10) {
                Text(data.title)
                    .font(.lora(28, weight: .medium))
                    .foregroundStyle(BinduTheme.inkPrimary)
                    .multilineTextAlignment(.center)
                HStack(spacing: 8) {
                    Text(data.roomName)
                        .font(.spaceMono(9)).tracking(1.5)
                        .foregroundStyle(data.roomColor)
                    Text("·").foregroundStyle(BinduTheme.inkTertiary)
                    Text("\(data.codexId) · \(data.date)")
                        .font(.spaceMono(9)).tracking(1)
                        .foregroundStyle(BinduTheme.inkTertiary)
                }
            }
            .padding(.top, 8)
            Text(RiteWord.arrivalNotDone)
                .font(.lora(13)).italic()
                .foregroundStyle(BinduTheme.inkTertiary)
                .padding(.top, 10)
            Spacer()
            Text(RiteWord.arrivalTouch)
                .font(.spaceMono(9)).tracking(2)
                .foregroundStyle(BinduTheme.inkTertiary)
                .opacity(appear ? 0.7 : 0.2)
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: onBegin)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6)) { appear = true }
        }
    }
}

// MARK: - II · Reading (touch-paced)

private struct RiteReading: View {
    let data: RiteStoryData
    let onGather: () -> Void
    @State private var lit = 1          // first paragraph pre-lit; his pace, not a timer's

    private var done: Bool { lit >= data.body.count }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Text(data.title)
                        .font(.lora(24, weight: .medium))
                        .foregroundStyle(BinduTheme.inkPrimary)
                        .padding(.top, 60)

                    ForEach(Array(data.body.enumerated()), id: \.offset) { i, para in
                        Text(para)
                            .font(.lora(17))
                            .lineSpacing(7)
                            .foregroundStyle(BinduTheme.inkPrimary)
                            .opacity(i < lit ? 1 : 0.05)
                            .blur(radius: i < lit ? 0 : 5)
                            .offset(y: i < lit ? 0 : 11)
                            .id(i)
                    }

                    if done {
                        Button(action: onGather) {
                            Text("⬡ \(RiteWord.gatherButton)")
                                .font(.lora(15)).italic()
                                .foregroundStyle(data.roomColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 22)
                        }
                        .transition(.opacity)
                        .padding(.top, 20)
                    }
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 34)
                .animation(.easeInOut(duration: 2.6), value: lit)
                .animation(.easeInOut(duration: 2.5), value: done)
            }
            .scrollIndicators(.hidden)
            .contentShape(Rectangle())
            .onTapGesture { advance(proxy) }
            .overlay(alignment: .bottom) {
                if !done {
                    Text(RiteWord.readingBaseLine)
                        .font(.spaceMono(9)).tracking(1.5)
                        .foregroundStyle(BinduTheme.inkTertiary)
                        .padding(.bottom, 16)
                        .modifier(RiteBreathe())
                }
            }
        }
    }

    private func advance(_ proxy: ScrollViewProxy) {
        guard !done else { return }
        let next = lit
        withAnimation(.easeInOut(duration: 2.6)) { lit += 1 }
        // Bring the newly lit paragraph up to reading height.
        withAnimation(.easeInOut(duration: 0.9)) {
            proxy.scrollTo(next, anchor: UnitPoint(x: 0.5, y: 0.52))
        }
    }
}

// MARK: - The Sealing

private struct RiteSealed: View {
    let data: RiteStoryData
    let text: String
    let onDoor: () -> Void
    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var phase = 0   // 0 entry · 1 "room has changed" · 2 "story is whole"

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            if phase >= 0 {
                VStack(spacing: 14) {
                    HStack(spacing: 8) {
                        Text(RiteAsh.glyph).foregroundStyle(RiteAsh.color)
                        Text(RiteWord.sealEntryLabel)
                            .font(.spaceMono(9)).tracking(1.5)
                            .foregroundStyle(BinduTheme.inkTertiary)
                    }
                    if !text.isEmpty {
                        Text(text)
                            .font(.lora(15)).lineSpacing(6)
                            .foregroundStyle(BinduTheme.inkSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .transition(.opacity)
            }
            if phase >= 1 {
                Text(RiteWord.sealChanged)
                    .font(.lora(16)).italic()
                    .foregroundStyle(BinduTheme.inkPrimary)
                    .transition(.opacity)
                    .padding(.top, 8)
            }
            if phase >= 2 {
                VStack(spacing: 16) {
                    Text(data.roomGlyph)
                        .font(.system(size: 30))
                        .foregroundStyle(data.roomColor)
                    Text(RiteWord.sealWhole)
                        .font(.lora(17, weight: .medium))
                        .foregroundStyle(BinduTheme.inkPrimary)
                    Text(RiteWord.sealTomorrow)
                        .font(.lora(13)).italic()
                        .foregroundStyle(BinduTheme.inkTertiary)
                        .multilineTextAlignment(.center)
                    Button(action: onDoor) {
                        Text(RiteWord.sealDoorWaits)
                            .font(.spaceMono(10)).tracking(2)
                            .foregroundStyle(data.roomColor)
                            .padding(.top, 10)
                    }
                }
                .transition(.opacity)
                .padding(.top, 10)
            }
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            soundEngine.riteBowl(hz: 220)   // struck once, the bed holds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
                withAnimation(.easeInOut(duration: 1.4)) { phase = 1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.6) {
                withAnimation(.easeInOut(duration: 1.6)) { phase = 2 }
            }
        }
    }
}
