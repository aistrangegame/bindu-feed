import SwiftUI
import Combine
import AVFoundation

// IV · RECOGNITION — "What arrived for you?"
//
// prompt → listening → settling → words. His spoken reflection is recorded (the
// audio kept) while the field leans in (inkOn 174); the transcript is his to type
// and mend, kept in his voice. The recorder is DEFENSIVE: if the mic permission,
// the session, or the recorder is unavailable, the flow still completes — the
// timer runs and the transcript stands; only the kept audio is skipped. Real
// speech-to-text transcription is deferred (the prototype types it too); the
// audio capture + session coordination are device-verify items.

private enum RecogStage { case prompt, listening, settling, words }

struct RiteRecognitionView: View {
    let onSealed: (String) -> Void

    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var stage: RecogStage = .prompt
    @State private var seconds = 0
    @State private var text = ""
    @State private var timer: Timer?
    @StateObject private var recorder = RiteRecorder()
    @FocusState private var editing: Bool

    private var mmss: String { String(format: "%02d:%02d", seconds / 60, seconds % 60) }

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            HStack(spacing: 8) {
                Text(RiteAsh.glyph).foregroundStyle(RiteAsh.color)
                Text(RiteWord.recogKeptLabel)
                    .font(.spaceMono(9)).tracking(1.5)
                    .foregroundStyle(BinduTheme.inkTertiary)
            }

            switch stage {
            case .prompt:
                Text(RiteWord.recogPrompt)
                    .font(.lora(20)).italic()
                    .foregroundStyle(BinduTheme.inkPrimary)
                Button(action: startListening) {
                    Text("◉")
                        .font(.system(size: 34))
                        .foregroundStyle(RiteAsh.color)
                        .padding(20)
                        .background(Circle().stroke(RiteAsh.color.opacity(0.4), lineWidth: 1))
                }
                Text(RiteWord.recogTouchSpeak)
                    .font(.spaceMono(9)).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary)

            case .listening:
                Text(mmss)
                    .font(.spaceMono(22)).foregroundStyle(BinduTheme.inkPrimary)
                Text(RiteWord.recogListening)
                    .font(.spaceMono(9)).tracking(2)
                    .foregroundStyle(RiteAsh.color)
                    .modifier(RiteBreathe())
                Button(action: stopListening) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(RiteAsh.color)
                        .frame(width: 22, height: 22)
                        .padding(18)
                        .background(Circle().stroke(RiteAsh.color.opacity(0.4), lineWidth: 1))
                }

            case .settling:
                Text(RiteWord.recogSettling)
                    .font(.lora(15)).italic()
                    .foregroundStyle(BinduTheme.inkSecondary)

            case .words:
                VStack(spacing: 14) {
                    Text(RiteWord.recogTranscript)
                        .font(.spaceMono(9)).tracking(1.5)
                        .foregroundStyle(BinduTheme.inkTertiary)
                    TextEditor(text: $text)
                        .focused($editing)
                        .font(.lora(16))
                        .foregroundStyle(BinduTheme.inkPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(height: 160)
                        .tint(RiteAsh.color)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                    HStack {
                        Text("voice kept · \(mmss)")
                            .font(.spaceMono(9)).tracking(1)
                            .foregroundStyle(BinduTheme.inkTertiary)
                        Spacer()
                        Button(RiteWord.recogKeepIt) {
                            let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !t.isEmpty { onSealed(t) }
                        }
                        .font(.lora(15))
                        .foregroundStyle(t: text, color: RiteAsh.color)
                    }
                }
                .padding(.horizontal, 6)
            }
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear { timer?.invalidate(); soundEngine.inkOff() }
    }

    private func startListening() {
        stage = .listening
        seconds = 0
        soundEngine.inkOn(hz: 174)                     // the field leans in
        recorder.start()                                // best-effort audio capture
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in seconds += 1 }
    }

    private func stopListening() {
        timer?.invalidate()
        recorder.stop()
        soundEngine.inkOff()
        withAnimation(.easeInOut(duration: 0.8)) { stage = .settling }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.8)) { stage = .words }
            editing = true
        }
    }
}

private extension View {
    // Dim the Keep-it button until there is something to keep.
    func foregroundStyle(t: String, color: Color) -> some View {
        foregroundStyle(t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? color.opacity(0.35) : color)
    }
}

// MARK: - The recorder (defensive)

/// Records Ash's spoken reflection to an m4a while listening. Every step is
/// best-effort: permission denial, a session refusal, or a recorder failure are
/// swallowed — the Recognition flow proceeds without kept audio. The audio file
/// URL (when captured) is where a future surface could play it back.
@MainActor
final class RiteRecorder: ObservableObject {
    private var recorder: AVAudioRecorder?
    private(set) var lastURL: URL?

    func start() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            guard granted else { return }
            Task { @MainActor in self?.beginRecording() }
        }
    }

    private func beginRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            // Allow record while the bed keeps playing; restored on stop.
            try session.setCategory(.playAndRecord, mode: .default,
                                    options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("rite-\(Int(Date().timeIntervalSince1970)).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
            ]
            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.record()
            recorder = rec
            lastURL = url
        } catch {
            #if DEBUG
            print("[RiteRecorder] record unavailable: \(error)")
            #endif
        }
    }

    func stop() {
        recorder?.stop()
        recorder = nil
        // Restore the field's ambient, mix-with-others session.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
    }
}
