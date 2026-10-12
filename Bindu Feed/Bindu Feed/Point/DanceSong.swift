import Combine
import SwiftUI
import AVFoundation

// THE REST · WORLD VII BECOMES A REAL DANCE (Bindu Dances; the Field's Performer). Arriving at the
// Dance, one of his own Field songs begins, quietly, under the world — twenty-seven finished
// dances that had nowhere to play. At the song's peak, the word from today's Rite Recognition
// (the line he sealed) rises in the middle of the dancers and dissolves. Leaving the Dance lets
// the song go. If the Rite has not been met today, the song plays and no word is invented.
@MainActor
final class DancePlayer: ObservableObject {
    @Published private(set) var progress: Double = 0
    @Published private(set) var title = ""
    private var player: AVPlayer?
    private var timeObs: Any?

    func play(_ track: FieldTrack) {
        stop()
        guard let url = URL(string: track.audioURL) else { return }
        title = track.title
        let p = AVPlayer(url: url)
        p.volume = 0
        player = p
        timeObs = p.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 600), queue: .main) { [weak self] t in
            Task { @MainActor in
                guard let self, let item = self.player?.currentItem else { return }
                let d = item.duration.seconds
                if d.isFinite, d > 0 { self.progress = t.seconds / d }
                // fade in over six seconds, never above a quiet room
                self.player?.volume = Float(min(0.55, t.seconds / 6 * 0.55))
            }
        }
        p.play()
    }

    func stop() {
        if let o = timeObs { player?.removeTimeObserver(o) }
        timeObs = nil
        player?.pause()
        player = nil
        progress = 0
    }
}

struct DanceSongLayer: View {
    @EnvironmentObject private var store: FeedStore
    @StateObject private var player = DancePlayer()
    @State private var wordShown = false

    var body: some View {
        ZStack {
            if let w = store.riteWordToday {
                Text(w)
                    .font(.loraItalic(44))
                    .foregroundColor(Color(hex: "#E8A0BF"))
                    .shadow(color: Color(hex: "#E8A0BF").opacity(0.6), radius: 18)
                    .opacity(wordShown ? 1 : 0)
                    .scaleEffect(wordShown ? 1 : 0.86)
                    .blur(radius: wordShown ? 0 : 8)
            }
            VStack {
                Spacer()
                if !player.title.isEmpty {
                    Text("♪").font(.lora(12)).foregroundColor(BinduTheme.inkTertiary)
                        .padding(.bottom, 120)
                }
            }
        }
        .allowsHitTesting(false)
        .task {
            await store.loadSiblings()
            if let t = store.danceSong() { player.play(t) }
        }
        .onChange(of: player.progress) { _, p in
            // the peak — about six tenths in — the word rises, then dissolves
            if p > 0.58, p < 0.62, !wordShown {
                withAnimation(.easeOut(duration: 2.4)) { wordShown = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    withAnimation(.easeInOut(duration: 4)) { wordShown = false }
                }
            }
        }
        .onDisappear { player.stop() }
    }
}
