import SwiftUI

// Phase 9 — Ash's Compose.
//
// Full-screen writing ritual that replaces the inline AshComposer. The
// screen is lit by the user's arrival color, glyph, and name from
// Settings (ArrivalSettings in UserDefaults). The user types, then
// presses-and-holds the ember; a ring fills over ~2.3s up / ~0.62s decay,
// and on full hold the comment posts to Airtable. After release: the
// words settle as the user's released entry, then "The room has changed."
// fades in, then a quiet "RETURN TO THE STORY ›" link.
//
// The Airtable write goes through FeedStore.postComment, which now
// resolves the user's archetype name dynamically (the step-2 fix). No
// synchronous archetype responses — the field gathers later via Make.com
// (§9.10).
struct AshComposeView: View {
    @EnvironmentObject private var store: FeedStore
    let story: Story
    var onPosted: () -> Void

    @State private var text: String = ""
    @State private var phase: Phase = .writing
    @State private var ready: Bool = false
    @State private var progress: Double = 0
    @State private var pressing: Bool = false
    @State private var traceTask: Task<Void, Never>?
    @State private var releaseTask: Task<Void, Never>?
    @State private var settled: Bool = false
    @State private var showClosing: Bool = false
    @State private var settings: ArrivalSettings = .init()

    @FocusState private var fieldFocused: Bool

    private enum Phase { case writing, released }

    private let upDuration: TimeInterval = 2.3
    private let downDuration: TimeInterval = 0.62

    // Fall back to the arrival default (per ArrivalSettings) — Lalita
    // violet + Bindu dot — never to terra/◉. The compose ritual is the
    // user's identity speaking back; Ash-canonical terra would be the
    // wrong vocabulary here. The struct's defaults are the source of
    // truth so changing them in one place propagates here automatically.
    private var accent: Color {
        let hex = settings.colorHex.isEmpty ? ArrivalSettings().colorHex : settings.colorHex
        return Color(hex: hex)
    }

    private var displayGlyph: String {
        settings.glyph.isEmpty ? ArrivalSettings().glyph : settings.glyph
    }

    // Display name is the one exception — it falls back to "Ash" because
    // ArrivalSettings's default name is the empty string (not meant for
    // display), and "Ash" is the canonical Airtable identity for the
    // person who replies.
    private var displayName: String {
        settings.name.isEmpty ? "Ash" : settings.name
    }

    private var armed: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack(alignment: .top) {
            BinduTheme.bgDeep.ignoresSafeArea()

            arrivalLight

            VStack(spacing: 0) {
                Color.clear.frame(height: 56)

                context
                    .padding(.top, 4)
                    .padding(.bottom, BinduTheme.space24)

                Group {
                    if phase == .writing {
                        writingSurface
                    } else {
                        releasedSurface
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            HStack {
                BackChevron { onPosted() }
                Spacer()
            }
            .padding(.horizontal, BinduTheme.space16)
            .padding(.top, BinduTheme.space8)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            settings = ArrivalSettings.load()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                ready = true
            }
        }
        .onDisappear {
            traceTask?.cancel()
            releaseTask?.cancel()
        }
    }

    // MARK: - Arrival light

    private var arrivalLight: some View {
        ZStack {
            RadialGradient(
                colors: [
                    accent.opacity(0.09 + progress * 0.19),
                    accent.opacity(0.03 + progress * 0.05),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.27),
                startRadius: 0,
                endRadius: 520
            )

            RadialGradient(
                colors: [
                    accent.opacity(0.05 + progress * 0.11),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 1.12),
                startRadius: 0,
                endRadius: 440
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Context

    private var context: some View {
        VStack(spacing: 7) {
            Text("INTO THE FIELD")
                .font(.spaceMono(10))
                .tracking(2.6)
                .foregroundColor(accent.opacity(0.72))

            HStack(spacing: 5) {
                Text("on")
                    .font(.loraItalic(13))
                    .foregroundColor(BinduTheme.inkTertiary)
                Text(story.title)
                    .font(.loraItalic(13))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BinduTheme.space20)
    }

    // MARK: - Writing surface

    private var writingSurface: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("What arrived for you?")
                .font(.loraItalic(21))
                .foregroundColor(accent.opacity(0.92))
                .lineSpacing(4)
                .opacity(armed ? 0.45 : 1)
                .animation(.easeOut(duration: 0.8), value: armed)
                .padding(.bottom, 22)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("write what arrived…")
                        .font(.loraItalic(19))
                        .foregroundColor(BinduTheme.inkTertiary.opacity(0.55))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .focused($fieldFocused)
                    .font(.lora(19))
                    .lineSpacing(8)
                    .foregroundColor(BinduTheme.inkPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .tint(accent)
                    .padding(.horizontal, -4)
            }

            Spacer(minLength: 8)

            emberControl
                .padding(.bottom, BinduTheme.space24 + 14)
        }
        .padding(.horizontal, 30)
        .opacity(ready ? 1 : 0)
        .animation(.easeOut(duration: 1.4), value: ready)
        .onAppear {
            // Slight delay so the keyboard doesn't fight the appearing
            // arrival animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                fieldFocused = true
            }
        }
    }

    private var emberControl: some View {
        VStack(spacing: 13) {
            ZStack {
                Circle()
                    .stroke(accent.opacity(armed ? 0.16 : 0.09), lineWidth: 1.5)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: max(0.001, progress))
                    .stroke(accent, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: accent.opacity(0.5 + progress * 0.4),
                        radius: 3 + progress * 10
                    )

                Text(displayGlyph)
                    .font(.system(size: 27))
                    .foregroundColor(accent)
                    .shadow(
                        color: accent.opacity(0.5 + progress * 0.4),
                        radius: 8 + progress * 18
                    )
                    .modifier(EmberWake(active: armed && progress < 0.02))
            }
            .frame(width: 80, height: 80)
            .opacity(armed ? 1.0 : 0.38)
            .animation(.easeOut(duration: 0.6), value: armed)
            .contentShape(Circle())
            .gesture(holdGesture)

            Text(hintText)
                .font(.spaceMono(9))
                .tracking(1.6)
                .foregroundColor(armed ? accent.opacity(0.62) : BinduTheme.inkTertiary)
                .modifier(HintFade(active: armed && progress < 0.02))
                .multilineTextAlignment(.center)
        }
    }

    private var hintText: String {
        if !armed { return "WRITE, THEN HOLD TO RELEASE" }
        if progress > 0.04 { return "HOLD — LET IT RISE" }
        return "HOLD TO RELEASE INTO THE FIELD"
    }

    private var holdGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard armed, phase == .writing, !pressing else { return }
                beginPress()
            }
            .onEnded { _ in
                guard phase == .writing else { return }
                endPress()
            }
    }

    // MARK: - Press / release loops

    private func beginPress() {
        pressing = true
        releaseTask?.cancel()
        releaseTask = nil
        let start = Date()
        let startProgress = progress
        traceTask?.cancel()
        traceTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let p = min(1.0, startProgress + elapsed / upDuration)
                progress = p
                if p >= 1.0 {
                    progress = 1.0
                    pressing = false
                    traceTask = nil
                    await release()
                    return
                }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    private func endPress() {
        pressing = false
        traceTask?.cancel()
        traceTask = nil
        let start = Date()
        let startProgress = progress
        releaseTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let p = max(0.0, startProgress - elapsed / downDuration)
                progress = p
                if p <= 0 {
                    progress = 0
                    releaseTask = nil
                    return
                }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    @MainActor
    private func release() async {
        fieldFocused = false
        let body = text.trimmingCharacters(in: .whitespacesAndNewlines)

        withAnimation(.easeOut(duration: 0.6)) {
            phase = .released
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            withAnimation(.easeOut(duration: 1.4)) {
                settled = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 1.6)) {
                showClosing = true
            }
        }

        // Post in parallel with the visual ceremony — the user doesn't
        // wait on the network. On success, flag Story Detail to re-fetch
        // its comment tree on appear.
        // Durable: postComment queues + retries on failure, so the comment is never lost
        // even offline. Always flag a refresh — the write landed now, or the retry will
        // surface it on a later load.
        await store.postComment(storyId: story.id, body: body, parentId: nil)
        store.flagStoryRefresh(storyId: story.id)
    }

    // MARK: - Released surface

    private var releasedSurface: some View {
        VStack(spacing: 0) {
            releasedEntryCard
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .opacity(settled ? 1 : 0)
                .offset(y: settled ? 0 : -16)

            Spacer(minLength: 0)

            if showClosing {
                VStack(spacing: 22) {
                    Text("The room has changed.")
                        .font(.loraItalic(15))
                        .foregroundColor(BinduTheme.inkSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Button {
                        onPosted()
                    } label: {
                        Text("RETURN TO THE STORY ›")
                            .font(.spaceMono(9))
                            .tracking(1.8)
                            .foregroundColor(BinduTheme.inkTertiary)
                            .padding(10)
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var releasedEntryCard: some View {
        let body = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(accent)
                        .frame(width: 30, height: 30)
                    Text(displayGlyph)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.92))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.lora(13, weight: .medium))
                        .foregroundColor(accent)
                    Text("RELEASED JUST NOW")
                        .font(.spaceMono(9))
                        .tracking(0.8)
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                Spacer()
            }

            Text(body)
                .font(.lora(16))
                .foregroundColor(BinduTheme.inkPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(accent.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(accent.opacity(0.26), lineWidth: 1)
        )
        .shadow(color: accent.opacity(0.13), radius: 21)
    }
}

// MARK: - Ember wake modifier

private struct EmberWake: ViewModifier {
    let active: Bool
    @EnvironmentObject private var breath: Breath   // the one master breath
    func body(content: Content) -> some View {
        content.scaleEffect(active ? (0.97 + 0.075 * breath.value) : 1)
    }
}

// MARK: - Hint fade modifier

private struct HintFade: ViewModifier {
    let active: Bool
    @EnvironmentObject private var breath: Breath   // the one master breath
    func body(content: Content) -> some View {
        content.opacity(active ? (0.26 + 0.29 * breath.value) : 1)
    }
}
