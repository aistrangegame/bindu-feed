import Combine
import AVFoundation
import Speech
import Foundation

// WAVE 3 · the ear of the Codex section. What he speaks is written down on the phone
// (on-device recognition where the phone supports it), live, in his own words; nothing is
// recorded to a file and no audio leaves the device. The session is taken only while he
// holds, and handed back to the field's ambient mix the moment he lets go — the same
// discipline as the Rite's recorder.
final class SpeechCapture: ObservableObject {
    @Published private(set) var transcript = ""
    @Published private(set) var listening = false
    @Published private(set) var refused = false

    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var prefix = ""
    private var wanted = false
    private var tookSession = false
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    /// Begin listening; whatever is already written stays, and the new words follow it.
    func start(after existing: String) {
        wanted = true
        prefix = existing.isEmpty ? "" : existing + " "
        SFSpeechRecognizer.requestAuthorization { @Sendable status in
            guard status == .authorized else {
                Task { @MainActor in self.refused = true }
                return
            }
            AVAudioApplication.requestRecordPermission { @Sendable granted in
                Task { @MainActor in
                    guard granted else { self.refused = true; return }
                    self.begin()
                }
            }
        }
    }

    private func begin() {
        guard wanted, !listening, let recognizer, recognizer.isAvailable else { return }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement,
                                    options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
            try session.setActive(true, options: [])
            tookSession = true
        } catch { return }

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition { req.requiresOnDeviceRecognition = true }
        request = req

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else { cleanup(); return }
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { @Sendable buffer, _ in
            req.append(buffer)
        }
        engine.prepare()
        do { try engine.start() } catch { cleanup(); return }
        listening = true

        task = recognizer.recognitionTask(with: req) { @Sendable [weak self] result, error in
            guard let self else { return }
            if let result {
                let text = result.bestTranscription.formattedString
                Task { @MainActor in self.transcript = self.prefix + text }
            }
            if error != nil || (result?.isFinal ?? false) {
                Task { @MainActor in self.cleanup() }
            }
        }
    }

    /// Stop listening; the words so far stay.
    func stop() {
        wanted = false
        request?.endAudio()
        cleanup()
    }

    func reset(to text: String) { transcript = text }

    private func cleanup() {
        if engine.isRunning {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }
        task?.cancel()
        task = nil
        request = nil
        if tookSession {
            tookSession = false
            try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        }
        listening = false
    }
}
