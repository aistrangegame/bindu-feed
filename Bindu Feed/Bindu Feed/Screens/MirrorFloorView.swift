import SwiftUI

// WAVE 5 · THE MIRROR UNDER THE FLOOR — rupakarshini's S15 and Lalita Family's Mirror, walked.
// A separate room: the Mirror card stays sealed and untouched; nothing here reads it.
//
// Beneath a story he has sealed, a door resists (1.25 s), then the floor gives. Each hold takes
// him one level deeper until LOOK stands in the dark, its two O's blinking. One question, about
// HIM — never about anyone in the story (Lalita's polarity: the mirror's subject is always you).
// He answers in a word; the glass returns it reflected, then turns it to read true. A vow is
// offered to him as YOU and carved by him as I — his word inside it, nothing composed around
// it but the frame. Carving keeps it (as the Light's Declarations are kept). Then he walks out
// into the sky, onto that story's star, met.
struct MirrorFloorView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var breath: Breath
    @Binding var path: [FeedRoute]
    let story: Story

    private enum Step { case descending, look, asking, reflected, vow, carved }
    @State private var step: Step = .descending
    @State private var depth = 0                 // 0…3 levels down
    @State private var word = ""
    @State private var turned = false
    @State private var blink = false
    @FocusState private var writing: Bool

    private var accent: Color { store.room(named: story.room)?.color ?? BinduTheme.colorLalita }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            depthLines.ignoresSafeArea()

            switch step {
            case .descending: descending
            case .look:       look
            case .asking:     asking
            case .reflected:  reflected
            case .vow:        vow
            case .carved:     carvedView
            }

            VStack {
                HStack { BackChevron { $path.popDissolve() }; Spacer() }
                    .padding(.horizontal, 16).padding(.top, 6)
                Spacer()
            }
        }
        .onAppear { soundEngine.fieldThreshold(hz: 98, dur: 8) }
    }

    /// Strata rising past him as he goes down.
    private var depthLines: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let n = 9 + depth * 4
                for i in 0..<n {
                    let y = (Double(i) / Double(n) * Double(size.height) - t * 8 * Double(depth + 1))
                        .truncatingRemainder(dividingBy: Double(size.height))
                    let yy = y < 0 ? y + Double(size.height) : y
                    ctx.fill(Path(CGRect(x: 0, y: yy, width: Double(size.width), height: 0.6)),
                             with: .color(accent.opacity(0.05 + 0.02 * Double(depth))))
                }
            }
        }
    }

    // 1 · each hold, one level deeper
    private var descending: some View {
        VStack(spacing: 30) {
            Spacer()
            Text(["the floor gave", "deeper", "deeper still", "here"][min(depth, 3)])
                .font(.loraItalic(18)).foregroundColor(BinduTheme.inkSecondary)
                .id(depth).transition(.opacity)
            HoldEmber(duration: 1.25, color: accent, size: 70, label: "hold to go down") {
                soundEngine.fieldThreshold(hz: 98 / pow(2, Double(depth + 1) / 4), dur: 6)
                withAnimation(.easeInOut(duration: 1.2)) {
                    if depth < 2 { depth += 1 } else { depth = 3; step = .look }
                }
                if depth >= 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { withAnimation(.easeInOut(duration: 1.4)) { step = .asking } }
                }
            }
            Spacer().frame(height: 120)
        }
    }

    // 2 · LOOK, its O's blinking
    private var look: some View {
        HStack(spacing: 6) {
            Text("L").font(.lora(54, weight: .medium))
            eye
            eye
            Text("K").font(.lora(54, weight: .medium))
        }
        .foregroundColor(BinduTheme.inkPrimary)
        .transition(.opacity)
        .onAppear {
            for k in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + Double(k) * 1.1) {
                    withAnimation(.easeInOut(duration: 0.12)) { blink = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { withAnimation(.easeInOut(duration: 0.12)) { blink = false } }
                }
            }
        }
    }

    private var eye: some View {
        Circle().stroke(BinduTheme.inkPrimary, lineWidth: 3.2)
            .frame(width: 38, height: blink ? 3 : 38)
            .overlay(Circle().fill(accent).frame(width: 9, height: blink ? 1 : 9))
    }

    // 3 · one question, about him
    private var asking: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("What in you was this story about?")
                .font(.loraItalic(22)).foregroundColor(BinduTheme.inkPrimary)
                .multilineTextAlignment(.center)
            TextField("", text: $word, prompt: Text("one word").foregroundColor(BinduTheme.inkTertiary))
                .font(.lora(24))
                .multilineTextAlignment(.center)
                .foregroundColor(accent)
                .focused($writing)
                .submitLabel(.done)
                .onSubmit(answer)
                .padding(.horizontal, 40)
            Spacer()
        }
        .padding(.horizontal, 26)
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { writing = true } }
        .transition(.opacity)
    }

    private var cleanWord: String {
        word.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
    }

    private func answer() {
        guard !cleanWord.isEmpty else { return }
        writing = false
        withAnimation(.easeInOut(duration: 1.0)) { step = .reflected }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeInOut(duration: 1.6)) { turned = true }
            soundEngine.fieldThreshold(hz: 136.1, dur: 6)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.6) { withAnimation(.easeInOut(duration: 1.4)) { step = .vow } }
    }

    // 4 · the glass returns his word
    private var reflected: some View {
        Text(cleanWord)
            .font(.lora(40, weight: .medium))
            .foregroundColor(accent)
            .scaleEffect(x: turned ? 1 : -1, y: 1)
            .rotation3DEffect(.degrees(turned ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .opacity(turned ? 1 : 0.7)
            .transition(.opacity)
    }

    // 5 · offered as you, carved as I
    private var vow: some View {
        VStack(spacing: 34) {
            Spacer()
            Text("You may carry \(cleanWord).")
                .font(.loraItalic(22)).foregroundColor(BinduTheme.inkSecondary)
            Text("I carry \(cleanWord).")
                .font(.lora(24, weight: .medium)).foregroundColor(BinduTheme.inkPrimary)
                .opacity(0.35)
            HoldEmber(duration: 1.6, color: accent, size: 60, label: "hold to carve it as yours") {
                Task { await store.writeVow(text: "I carry \(cleanWord).") }
                soundEngine.carryTone(hz: 174)
                withAnimation(.easeInOut(duration: 1.4)) { step = .carved }
            }
            Spacer()
        }
        .transition(.opacity)
    }

    // 6 · out into the sky, onto that story's star
    private var carvedView: some View {
        VStack(spacing: 26) {
            Spacer()
            Text("I carry \(cleanWord).")
                .font(.lora(24, weight: .medium)).foregroundColor(BinduTheme.inkPrimary)
            Text("carved · it will come back to you some ordinary morning")
                .spaceMonoTracked(8, em: 0.2).foregroundColor(BinduTheme.inkTertiary)
            Spacer()
            Button {
                Task { await store.logStoryMet(storyId: story.id, title: story.title) }
                $path.popDissolve()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { $path.pushDissolve(.instrument(-2)) }
            } label: {
                Text("walk out into the sky").spaceMonoTracked(9, em: 0.2).foregroundColor(accent).padding(14)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 40)
        }
        .transition(.opacity)
    }
}
