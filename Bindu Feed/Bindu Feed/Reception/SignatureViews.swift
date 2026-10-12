import Combine
import SwiftUI
import UIKit

// SELF-KATHAS · the signatures, as they sit on the received page. One story carries one at
// most; none of them is named; none of them withholds anything the story needs.

extension Signatures {
    /// Dealt once per shape of the story set, so every view asks the same question cheaply.
    private static var cache: (key: Int, map: [String: Signature]) = (0, [:])

    static func of(_ story: Story, in stories: [Story]) -> Signature? {
        let key = stories.reduce(stories.count) { $0 &+ Int(truncatingIfNeeded: KathaHash.fnv($1.id) & 0xffff) }
        if cache.key != key { cache = (key, deal(stories)) }
        return cache.map[story.id]
    }
}

// MARK: - sealedLastPage · it opens only after he has asked for help

struct SealedLastPage: View {
    let witness: String?
    let opened: Bool
    let color: Color
    let onFacing: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color(hex: "#EDE3D0").opacity(opened ? 0.10 : 0.05))
                if opened, let w = witness, !w.isEmpty {
                    Text(w)
                        .font(.loraItalic(13))
                        .foregroundColor(BinduTheme.inkSecondary)
                        .lineSpacing(5)
                        .padding(14)
                        .transition(.opacity)
                } else {
                    Image(systemName: "seal")
                        .font(.system(size: 15, weight: .ultraLight))
                        .foregroundColor(color.opacity(0.55))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            Rectangle().fill(color.opacity(0.25)).frame(width: 0.6)
            Button(action: onFacing) {
                RoundedRectangle(cornerRadius: 3).fill(Color(hex: "#EDE3D0").opacity(opened ? 0.06 : 0.03))
                    .frame(maxWidth: .infinity, minHeight: 150)
            }
            .buttonStyle(.plain)
            .disabled(!opened)
            .accessibilityLabel("a page for your own")
        }
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(color.opacity(0.25), lineWidth: 0.6))
    }
}

// MARK: - alreadyDid · the last line arrives as an answer to "wake up"

struct AlreadyDid: View {
    let color: Color
    @State private var step = 0

    var body: some View {
        VStack(spacing: 14) {
            Text("wake up")
                .font(.loraItalic(14))
                .foregroundColor(BinduTheme.colorLalita.opacity(step >= 1 ? 0.8 : 0))
            Text("I already did.")
                .font(.lora(17))
                .foregroundColor(BinduTheme.colorAsh.opacity(step >= 2 ? 0.95 : 0))
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            guard step == 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { withAnimation(.easeInOut(duration: 2)) { step = 1 } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { withAnimation(.easeInOut(duration: 2.4)) { step = 2 } }
        }
    }
}

// MARK: - secondPiece · a small companion, unannounced, after the reading

struct SecondPiece: View {
    let text: String?
    @State private var here = false

    var body: some View {
        Group {
            if here, let t = text, !t.isEmpty {
                Text(t)
                    .font(.loraItalic(15))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            try? await Task.sleep(nanoseconds: 20_000_000_000)
            withAnimation(.easeInOut(duration: 3)) { here = true }
        }
    }
}

// MARK: - missingNote · the sound carries what the words leave unsaid

/// Loudest where the words go quiet: when the page has not moved for a while, one long low
/// tone in the room's own root — never more than one at a time, never on a quick reader.
struct MissingNote: View {
    let hz: Double
    /// The page's own stillness — a reference, so the running task always reads it live.
    let page: Stillness
    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var lastNote = Date.distantPast

    var body: some View {
        Color.clear.frame(height: 0)
            .task(id: hz) {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    let now = Date()
                    if page.stillNow > 7, now.timeIntervalSince(lastNote) > 24 {
                        soundEngine.fieldThreshold(hz: hz, dur: 7)
                        lastNote = now
                    }
                }
            }
    }
}

// MARK: - layersOnReturn · a second and a third reading, with dwell, never with visits

struct DwellLayers: View {
    let storyId: String
    let second: String?
    let third: String?
    let color: Color
    @State private var dwell: Double = 0

    private var key: String { "bindu.kathas.dwell.\(storyId)" }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if dwell >= 180, let s = second, !s.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Rectangle().fill(color.opacity(0.5)).frame(width: 1)
                    Text(s).font(.loraItalic(14)).foregroundColor(BinduTheme.inkSecondary).lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity)
            }
            if dwell >= 480, let t = third, !t.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Rectangle().fill(BinduTheme.colorAsh.opacity(0.6)).frame(width: 1)
                    Text(t).font(.lora(14)).foregroundColor(BinduTheme.colorAsh.opacity(0.85)).lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            dwell = UserDefaults.standard.double(forKey: key)
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 2.5)) { dwell += 5 }
                UserDefaults.standard.set(dwell, forKey: key)
            }
        }
    }
}

// MARK: - everyPath · variant pasts collapse into one as he stays

struct EveryPath: View {
    let text: String
    let color: Color
    @State private var spread: Double = 1

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<3, id: \.self) { i in
                let a = Double(i - 1)
                KathaText(text: text, size: 17, color: color.opacity(0.28 * spread))
                    .offset(x: CGFloat(a * 9 * spread), y: CGFloat((i == 1 ? -7 : 5) * spread))
                    .rotationEffect(.degrees(a * 1.4 * spread))
                    .blur(radius: 1.2 * spread)
            }
            KathaText(text: text, size: 17)
        }
        .contentShape(Rectangle())
        .onTapGesture { scatter() }
        .onAppear { settle() }
    }

    private func scatter() {
        withAnimation(.easeOut(duration: 0.5)) { spread = 1 }
        settle()
    }

    private func settle() {
        withAnimation(.easeInOut(duration: 6).delay(1.5)) { spread = 0 }
    }
}

// MARK: - foundPage · a dated fragment from long before, without comment

struct FoundPage: View {
    let line: String
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date).spaceMonoTracked(8, em: 0.2).foregroundColor(Color(hex: "#6B5A44"))
            Text(line).font(.loraItalic(14)).foregroundColor(Color(hex: "#3A2F25"))
                .lineSpacing(5).fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: 280, alignment: .leading)
        .background(Color(hex: "#E8DCC4").opacity(0.92))
        .rotationEffect(.degrees(-1.6))
        .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - cordCut · he cuts a thread, and the next story launches from where it fell

struct CordCut: View {
    let color: Color
    let onFallen: () -> Void
    @State private var cut = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Rectangle().fill(color.opacity(0.6)).frame(width: 1, height: 70)
                Circle().fill(color.opacity(0.8)).frame(width: 6, height: 6)
            }
            .offset(y: cut ? 420 : 0)
            .opacity(cut ? 0 : 1)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 18).onEnded { v in
            if abs(v.translation.width) > 36 { fall() }
        })
        .onLongPressGesture(minimumDuration: 1.2) { fall() }
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { fall() }
    }

    private func fall() {
        guard !cut else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeIn(duration: 1.3)) { cut = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { onFallen() }
    }
}

// MARK: - emptySummit · he climbs toward a figure and finds the top warm and empty

struct EmptySummit: View {
    let color: Color
    @State private var climb: Double = 0
    @State private var task: Task<Void, Never>?
    @StateObject private var still = Stillness()

    var body: some View {
        Canvas { ctx, size in
            let base = CGPoint(x: size.width * 0.2, y: size.height - 6)
            let peak = CGPoint(x: size.width * 0.5, y: 14)
            var m = Path()
            m.move(to: base); m.addLine(to: peak); m.addLine(to: CGPoint(x: size.width * 0.8, y: size.height - 6))
            ctx.stroke(m, with: .color(color.opacity(0.45)), lineWidth: 0.8)
            let p = CGPoint(x: base.x + (peak.x - base.x) * climb, y: base.y + (peak.y - base.y) * climb)
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - 2.5, y: p.y - 2.5, width: 5, height: 5)), with: .color(BinduTheme.colorAsh))
            if climb < 0.97 {
                ctx.fill(Path(ellipseIn: CGRect(x: peak.x - 3, y: peak.y - 9, width: 6, height: 6)),
                         with: .color(Color.white.opacity(0.7 * (1 - climb))))
            } else {
                let r = 40.0
                ctx.fill(Path(ellipseIn: CGRect(x: peak.x - r, y: peak.y - r, width: 2 * r, height: 2 * r)),
                         with: .radialGradient(Gradient(colors: [Color(hex: "#D4AE4A").opacity(0.5), .clear]),
                                               center: peak, startRadius: 0, endRadius: r))
            }
        }
        .frame(height: 140)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in still.touched(); hold(true) }
            .onEnded { _ in hold(false) })
        .onAppear { still.start() }
        .onDisappear { still.stop(); task?.cancel() }
        .onReceive(still.$still) { t in
            // staying climbs too — slower, but it arrives
            if t > 6, climb < 1 { climb = min(1, climb + 0.0035) }
        }
    }

    private func hold(_ on: Bool) {
        task?.cancel()
        guard on else { return }
        task = Task { @MainActor in
            while !Task.isCancelled, climb < 1 {
                climb = min(1, climb + 0.016 / 4)
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }
}

// MARK: - zeroGap · the closed eye and the open eye converge until they are one

struct ZeroGap: View {
    let line: String
    let color: Color
    @State private var gap: Double = 1

    var body: some View {
        ZStack {
            Text(line).font(.loraItalic(17)).foregroundColor(color.opacity(0.35))
                .blur(radius: 3 * gap).offset(y: CGFloat(22 * gap))
            Text(line).font(.loraItalic(17)).foregroundColor(BinduTheme.inkPrimary)
                .offset(y: CGFloat(-22 * gap))
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .onAppear { withAnimation(.easeInOut(duration: 9).delay(2)) { gap = 0 } }
    }
}
