import Combine
import SwiftUI

// WAVE 3 · THE SHADOW CORRIDOR — "again?" answered by forgetting (Codex C-1327, C-1288: the
// game is only playable because it is forgotten). Nine beats down the axis. On each beat one
// register's name loses its colour, then its words, from the centre back to the gate — until
// nothing is named, and the one thing left says: let's play. The day's story goes dark in the
// sky again, so it can be met as if for the first time. Forgetting, made sacred.
struct ShadowCorridorView: View {
    let onDone: () -> Void

    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var beat = 0
    @State private var landed = false

    /// The axis from the centre back to the gate, in each register's own name and hue.
    private let names: [(String, String)] = [
        ("the centre", "#EDE3CE"), ("The Dance", "#E8A0BF"), ("The Return", "#3AADA8"),
        ("The Mirrors", "#9FB2C4"), ("The Chamber", "#C47A52"), ("The Veil", "#9B6BD6"),
        ("The Turn", "#C9A07A"), ("The Point", "#C0392B"), ("the gate", "#B9AEA2"),
    ]
    static let beatSeconds = 1.5

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 14) {
                ForEach(Array(names.enumerated()), id: \.offset) { i, n in
                    let faded = i < beat
                    let fading = i == beat
                    Text(n.0)
                        .font(.loraItalic(17))
                        .foregroundColor(faded ? BinduTheme.inkTertiary : Color(hex: n.1))
                        .opacity(faded ? 0 : (fading ? 0.55 : 0.9))
                        .blur(radius: faded ? 6 : 0)
                }
            }
            .opacity(landed ? 0 : 1)

            if landed {
                VStack(spacing: 30) {
                    Text("let's play")
                        .font(.loraItalic(26))
                        .foregroundColor(BinduTheme.inkPrimary)
                    Circle().fill(BinduTheme.colorBindu).frame(width: 7, height: 7)
                        .shadow(color: BinduTheme.colorBindu.opacity(0.8), radius: 10)
                }
                .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if landed { onDone() } }
        .onAppear(perform: walk)
    }

    private func walk() {
        for i in 0..<names.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i + 1) * Self.beatSeconds) {
                withAnimation(.easeInOut(duration: 1.2)) { beat = i + 1 }
                soundEngine.fieldThreshold(hz: 136.1 / pow(2, Double(i) / 9), dur: 2.5)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(names.count + 1) * Self.beatSeconds) {
            withAnimation(.easeInOut(duration: 2.0)) { landed = true }
            soundEngine.fieldThreshold(hz: 136.1, dur: 9)
        }
    }
}
