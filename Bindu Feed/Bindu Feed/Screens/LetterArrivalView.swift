import Combine
import SwiftUI

// WAVE 3 · A LETTER LANDS. No notification ever announces it: the moment its condition comes
// true, wherever he is, one gold light descends the screen from above — the axis seen end-on
// — and settles at the centre. Touching it opens the letter in his own hand, signed by the
// self who sealed it and the day. Opening is the only thing recorded.
struct LetterArrivalView: View {
    let letter: Letter
    let onOpen: () -> Void
    let onClose: () -> Void

    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var fall: CGFloat = 0
    @State private var opened = false
    @State private var shown = false

    private let gold = Color(hex: "#C9A07A")

    var body: some View {
        GeometryReader { g in
            ZStack {
                Color(hex: "#07060A").opacity(shown ? 0.94 : 0).ignoresSafeArea()

                if !opened {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, gold.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 1, height: max(0, g.size.height * 0.5 * fall))
                        Circle().fill(gold).frame(width: 9, height: 9)
                            .shadow(color: gold, radius: 14)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .offset(y: -6)
                    .contentShape(Rectangle())
                    .onTapGesture { open() }

                    Text(letter.seal.label)
                        .font(.loraItalic(14))
                        .foregroundColor(gold.opacity(fall >= 1 ? 0.85 : 0))
                        .offset(y: 40)
                } else {
                    VStack(alignment: .leading, spacing: 22) {
                        Spacer()
                        Text(letter.body)
                            .font(.loraItalic(20))
                            .foregroundColor(BinduTheme.inkPrimary)
                            .lineSpacing(9)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("— you, on \(letter.sealedOn)")
                            .font(.lora(14))
                            .foregroundColor(BinduTheme.colorAsh)
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: close) {
                                Text("keep walking").spaceMonoTracked(9, em: 0.2)
                                    .foregroundColor(BinduTheme.inkTertiary).padding(14)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 30)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) { shown = true }
            withAnimation(.easeInOut(duration: 3.2).delay(0.4)) { fall = 1 }
            soundEngine.fieldThreshold(hz: 174, dur: 8)
        }
    }

    private func open() {
        guard !opened else { return }
        onOpen()
        soundEngine.fieldThreshold(hz: 136.1, dur: 7)
        withAnimation(.easeInOut(duration: 1.4)) { opened = true }
    }

    private func close() {
        withAnimation(.easeInOut(duration: 0.8)) { shown = false; opened = false; fall = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { onClose() }
    }
}
