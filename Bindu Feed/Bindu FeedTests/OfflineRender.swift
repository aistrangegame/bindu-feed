import Foundation
import AVFoundation

// A3 · THE OFFLINE RENDER HARNESS
//
// `8-ACTION-PLAN.md` STAGE A3. Every voice in `Sound/` is a standalone `final class`
// exposing an `AVAudioSourceNode` at 48 kHz deinterleaved stereo. This attaches one to a
// private `AVAudioEngine` in `enableManualRenderingMode(.offline, …)`, pulls frames as
// fast as the CPU allows, and hands back the samples.
//
// WHY IT EXISTS. `7-STATE-OF-THE-BUILD.md` §5 says only three things about the sound need
// ears — mix balance, reverb character, headphone routing. Everything else is a number:
// peaks, envelopes, partial ratios, the binaural beat, L/R divergence. Until this file
// there was no way to read any of them without a device and a person, so `AUDIT.md:944`
// (the bowl at four times its stated ceiling) sat open through an entire build while
// every string-keyed checker reported green.
//
// CALIBRATION. `7-STATE-OF-THE-BUILD.md` §6.3: *"Every verification tool in this build
// shipped, on its first run, with the exact fault it was built to catch."* So this
// harness is calibrated in both directions before anything trusts it — see
// `HarnessCalibrationTests.swift`, which feeds it signals of known amplitude and known
// spectrum and requires it to go red on the wrong ones.
enum OfflineRender {

    /// What came out. Deinterleaved, exactly as the render block wrote it.
    struct Rendered {
        let left: [Float]
        let right: [Float]
        let sampleRate: Double

        var frameCount: Int { left.count }
        var seconds: Double { Double(left.count) / sampleRate }

        /// Sample index for a time in seconds, clamped into the buffer.
        ///
        /// The clamp happens in DOUBLE, before the conversion. Clamping after it — which is
        /// what this did on its first run — traps the moment a caller passes the default
        /// `to: .greatestFiniteMagnitude`, because `Int(.greatestFiniteMagnitude * 48000)`
        /// is not representable. It took down the whole test process, so every test in the
        /// bundle reported "failed" including an empty one, which is exactly the kind of
        /// green-looking wreckage `7-STATE-OF-THE-BUILD.md` §6.3 is about.
        private func index(_ t: Double) -> Int {
            guard t.isFinite else { return t > 0 ? left.count : 0 }
            return Int(max(0, min(Double(left.count), t * sampleRate)))
        }

        private func slice(_ ch: [Float], _ from: Double, _ to: Double) -> ArraySlice<Float> {
            let a = index(from), b = max(index(from), index(to))
            return ch[a..<b]
        }

        /// Largest absolute sample across both channels in a window (whole buffer by default).
        func peak(from: Double = 0, to: Double = .greatestFiniteMagnitude) -> Double {
            let l = slice(left, from, to).reduce(0.0) { max($0, abs(Double($1))) }
            let r = slice(right, from, to).reduce(0.0) { max($0, abs(Double($1))) }
            return max(l, r)
        }

        func rms(from: Double = 0, to: Double = .greatestFiniteMagnitude) -> Double {
            let s = slice(left, from, to)
            guard !s.isEmpty else { return 0 }
            return (s.reduce(0.0) { $0 + Double($1) * Double($1) } / Double(s.count)).squareRoot()
        }

        /// Amplitude of the component at `hz`, measured over a window.
        ///
        /// A direct correlation rather than an FFT bin, so any frequency can be asked for —
        /// the bowl's partials are inharmonic (`2.004 · 2.98 · 4.02`) and would each land
        /// between bins. Returns the amplitude of that sinusoid, in the same units as the
        /// samples, so `magnitude(at: f)` of a `0.075·sin(2πft)` signal is `0.075`.
        func magnitude(at hz: Double, from: Double = 0, to: Double = .greatestFiniteMagnitude) -> Double {
            let s = slice(left, from, to)
            guard s.count > 1 else { return 0 }
            let w = 2.0 * .pi * hz / sampleRate
            var re = 0.0, im = 0.0
            for (i, v) in s.enumerated() {
                let p = w * Double(i)
                re += Double(v) * cos(p)
                im += Double(v) * sin(p)
            }
            return 2.0 * (re * re + im * im).squareRoot() / Double(s.count)
        }

        /// Where the envelope crests — the time of the largest absolute sample.
        var peakTime: Double {
            var best = 0.0, at = 0
            for (i, v) in left.enumerated() where abs(Double(v)) > best { best = abs(Double(v)); at = i }
            return Double(at) / sampleRate
        }

        /// How far the two channels differ. Zero for a centred (mono) voice; the binaural
        /// pair's whole claim is that this is NOT zero on headphones.
        var channelDivergence: Double {
            guard left.count == right.count, !left.isEmpty else { return 0 }
            var d = 0.0
            for i in 0..<left.count { d = max(d, abs(Double(left[i]) - Double(right[i]))) }
            return d
        }
    }

    enum Failure: Error, CustomStringConvertible {
        case format
        case buffer
        case render(AVAudioEngineManualRenderingStatus)

        var description: String {
            switch self {
            case .format:      return "OfflineRender: could not build the 48 kHz stereo render format"
            case .buffer:      return "OfflineRender: could not allocate the render buffer"
            case .render(let s): return "OfflineRender: renderOffline returned \(s.rawValue)"
            }
        }
    }

    /// Render `seconds` of one source node through a private engine, offline.
    ///
    /// The node is connected to `mainMixerNode` in its OWN output format — the same
    /// connection `SoundEngine.playCeremony` makes — so what comes back is what the app
    /// would hand the hardware, minus the reverb (which the engine attaches separately and
    /// which `7-STATE-OF-THE-BUILD.md` §5 lists as one of the three things only ears can
    /// judge).
    static func render(_ node: AVAudioSourceNode,
                       seconds: Double,
                       sampleRate: Double = 48000) throws -> Rendered {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        else { throw Failure.format }

        let engine = AVAudioEngine()
        engine.attach(node)
        _ = engine.mainMixerNode          // pull the output node into the graph before start
        engine.connect(node, to: engine.mainMixerNode, format: node.outputFormat(forBus: 0))

        try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 4096)
        try engine.start()
        defer { engine.stop(); engine.disableManualRenderingMode() }

        guard let buffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat,
                                            frameCapacity: engine.manualRenderingMaximumFrameCount)
        else { throw Failure.buffer }

        var left: [Float] = [], right: [Float] = []
        let total = Int(seconds * sampleRate)
        left.reserveCapacity(total); right.reserveCapacity(total)

        var remaining = AVAudioFrameCount(total)
        while remaining > 0 {
            let ask = min(buffer.frameCapacity, remaining)
            let status = try engine.renderOffline(ask, to: buffer)
            guard status == .success, buffer.frameLength > 0 else { throw Failure.render(status) }
            let n = Int(buffer.frameLength)
            if let ch = buffer.floatChannelData {
                left.append(contentsOf: UnsafeBufferPointer(start: ch[0], count: n))
                right.append(contentsOf: UnsafeBufferPointer(start: ch[1], count: n))
            }
            remaining -= buffer.frameLength
        }

        return Rendered(left: left, right: right, sampleRate: sampleRate)
    }

    /// A known signal, for calibrating the harness itself. Not used by the app.
    ///
    /// `partials` are (ratio, weight) pairs; the sum is scaled by `peak`, so a single
    /// `(1, 1)` partial at `peak` is a plain sine of exactly that amplitude.
    static func probe(hz: Double,
                      peak: Double,
                      partials: [(Double, Double)] = [(1, 1)],
                      pan: Double = 0,
                      sampleRate: Double = 48000) -> AVAudioSourceNode {
        let ratios = partials.map(\.0), weights = partials.map(\.1)
        // EACH PARTIAL KEEPS ITS OWN PHASE. Multiplying one wrapped phase by a
        // non-integer ratio — which is what this did first, and what the app's own bowl
        // did before G3.3 — puts a discontinuity in every partial at every wrap, and the
        // energy smears out of its bin. Calibration caught it: `knownSpectrum` read the
        // 2.004 partial at 0.0006 instead of 0.3125.
        var phases = [Double](repeating: 0, count: partials.count)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let gl = 1.0 - max(0, pan), gr = 1.0 + min(0, pan)
        return AVAudioSourceNode(format: format) { _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)
            for frame in 0..<Int(frameCount) {
                var s = 0.0
                for k in ratios.indices {
                    phases[k] += 2.0 * .pi * (hz * ratios[k]) / sampleRate
                    if phases[k] >= 2.0 * .pi { phases[k] -= 2.0 * .pi }
                    s += sin(phases[k]) * weights[k]
                }
                s *= peak
                bufL?[frame] = Float(s * gl)
                bufR?[frame] = Float(s * gr)
            }
            return noErr
        }
    }
}
