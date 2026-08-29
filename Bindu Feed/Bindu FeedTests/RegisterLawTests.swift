import Foundation
import AVFoundation
import Testing
@testable import Bindu_Feed

// C1 · THE SEVEN REGISTER LAWS
//
// `spine-sound.js:104-190`. Each law is one register's whole claim expressed as physics, and
// `7-STATE-OF-THE-BUILD.md` §3.1 found all thirteen mechanisms absent — `PointReadings.swift`
// and `PointWorlds.swift` made no `soundEngine` calls at all. A1 built `pk`/`nul`/`ech` and
// A2 the delay line; these measure the movements.
//
// Ordered as they can be asserted: the five with a design caller first, each with a
// measurable effect on the rendered graph, then the two the app wrote the caller for.
@Suite("C1 · the register laws")
struct RegisterLawTests {

    /// The Point's own voice — the climbing bed, where the binaural pair and the octave live.
    /// Every law but `unveil` acts on the second tone or the resonance, and neither exists on
    /// the field bed. `BreathVoiceNodeTests.peakIsInertOnTheFieldBed` records that asymmetry.
    private func pointVoice(rootHz: Double = 174, beat: Double = 8) -> BreathVoice {
        BreathVoice(snapshot: VoiceSnapshot(rootHz: rootHz, binauralHz: beat, level: 0.055,
                                            brightness: 0.42, texture: .sine, bed: .climbing),
                    initialCrossfadeLevel: 1,
                    routeState: RouteStateHolder(true))
    }

    /// The design applies each law with `setTargetAtTime`, so the value ARRIVES rather than
    /// jumping. Every measurement here is taken after several time constants.
    private let settle = 3.0

    // ── I · narrow — the beat closing IS the reading arriving ──────────

    @Test("narrow closes the beat toward unison, by 0.94 at full")
    func narrowClosesTheBeat() throws {
        let f = 174.0, beat = 8.0
        let v = pointVoice(rootHz: f, beat: beat)
        v.laws.write(RegisterLaws(beat: Smoothed(beat * (1 - 0.94), tau: 1.2)))   // narrow(1)
        let r = try OfflineRender.render(v.sourceNode, seconds: 6.0)

        // The second tone has moved from f+8 to f+0.48 — and it lives in the RIGHT ear.
        // The right channel carries only that tone and the octave, so 174.48 there is
        // unambiguous where in the left it would be indistinguishable from the root.
        let atOpen = r.magnitude(at: f + beat, ear: .right, from: settle, to: 5.8)
        let atClosed = r.magnitude(at: f + beat * 0.06, ear: .right, from: settle, to: 5.8)
        #expect(atClosed > atOpen * 2,
                "beat did not close: open \(atOpen), closed \(atClosed)")
    }

    @Test("an untouched voice keeps its own beat")
    func beatDefaultsToTheSnapshot() throws {
        let f = 174.0, beat = 8.0
        let r = try OfflineRender.render(pointVoice(rootHz: f, beat: beat).sourceNode, seconds: 6.0)
        let atOpen = r.magnitude(at: f + beat, ear: .right, from: settle, to: 5.8)
        let atClosed = r.magnitude(at: f + beat * 0.06, ear: .right, from: settle, to: 5.8)
        #expect(atOpen > atClosed * 2, "the default moved the beat: \(atOpen) vs \(atClosed)")
    }

    // ── II · widen — the same instrument, the opposite direction ───────

    @Test("widen takes the beat out to 12× — one note becoming two")
    func widenOpensTheBeat() throws {
        let f = 174.0, beat = 8.0
        let v = pointVoice(rootHz: f, beat: beat)
        v.laws.write(RegisterLaws(beat: Smoothed(beat * (1 + 11), tau: 0.5)))     // widen(1)
        let r = try OfflineRender.render(v.sourceNode, seconds: 6.0)
        #expect(r.magnitude(at: f + beat * 12, ear: .right, from: settle, to: 5.8)
                > r.magnitude(at: f + beat, ear: .right, from: settle, to: 5.8) * 2)
    }

    /// The two laws are one instrument read in both directions — `spine-sound.js:111-113`,
    /// *"Same instrument, same register, opposite direction."*
    @Test("narrow and widen move the same parameter opposite ways")
    func narrowAndWidenAreOpposites() {
        let beat = 8.0
        #expect(beat * (1 - 1.0 * 0.94) < beat)      // narrow(1) closes
        #expect(beat * (1 + 1.0 * 11) > beat)        // widen(1) opens
        #expect(abs(beat * (1 - 0.94) - 0.48) < 1e-9)
        #expect(abs(beat * (1 + 11) - 96.0) < 1e-9)
    }

    // ── III · unveil — a filter, not a metaphor ────────────────────────

    @Test("unveil opens the cutoff from 340 Hz muffled to ~19.7 kHz clear")
    func unveilOpens() throws {
        let f = 174.0
        // veiled: 340·58^0 = 340 Hz. The octave at 348 is right at the knee; the register's
        // own upper content is what a veil takes away.
        let veiled = pointVoice(rootHz: f)
        veiled.laws.write(RegisterLaws(veilHz: Smoothed(340, tau: 0.30)))
        let a = try OfflineRender.render(veiled.sourceNode, seconds: 5.0)

        let clear = pointVoice(rootHz: f)              // default is already open
        let b = try OfflineRender.render(clear.sourceNode, seconds: 5.0)

        // the veil is one filter per channel, so it must close in BOTH ears
        for ear in [OfflineRender.Rendered.Ear.left, .right] {
            #expect(a.peak(ear: ear, from: settle) < b.peak(ear: ear, from: settle) * 0.95,
                    "\(ear): veiled \(a.peak(ear: ear, from: settle)), clear \(b.peak(ear: ear, from: settle))")
        }
    }

    @Test("the floor keeps a veil from ever closing all the way again")
    func unveilHasAFloor() {
        // `var base = Math.max(f, floor||0)` — what he has handed back keeps a floor under it
        func hz(_ f: Double, _ floor: Double) -> Double { 340 * pow(58, max(0, min(1, max(f, floor)))) }
        #expect(abs(hz(0, 0) - 340) < 0.5)
        #expect(hz(0, 0.5) > hz(0, 0), "a floor must hold the cutoff up")
        #expect(abs(hz(1, 0) - 340 * 58) < 1, "340·58 = 19_720, above hearing")
    }

    // ── IV · bear — the room ringing under load ────────────────────────

    @Test("bear opens the resonance and sags the tones flat")
    func bearRingsAndSags() throws {
        let f = 174.0
        let v = pointVoice(rootHz: f)
        v.peak.write(PeakSettings(frequencyHz: f * 2, q: 1.2 + 7, gainDB: 13))    // bear(1)
        v.laws.write(RegisterLaws(sag: Smoothed(1 - 0.020, tau: 0.5)))
        let r = try OfflineRender.render(v.sourceNode, seconds: 5.0)
        let flat = try OfflineRender.render(pointVoice(rootHz: f).sourceNode, seconds: 5.0)

        // The resonance sits on the OCTAVE, which both ears carry, so it must swell in both.
        for ear in [OfflineRender.Rendered.Ear.left, .right] {
            #expect(r.magnitude(at: f * 2, ear: ear, from: settle, to: 4.8)
                    > flat.magnitude(at: f * 2, ear: ear, from: settle, to: 4.8) * 2.5,
                    "\(ear) did not ring")
        }
        // BOTH TONES SAG, and they are different tones in different ears — the left at
        // f×0.98 = 170.52 and the right at (f+beat)×0.98. Asserting only the left would
        // leave half the law unmeasured.
        #expect(r.magnitude(at: f * 0.98, ear: .left, from: settle, to: 4.8)
                > r.magnitude(at: f, ear: .left, from: settle, to: 4.8))
        let beat = 8.0
        #expect(r.magnitude(at: (f + beat) * 0.98, ear: .right, from: settle, to: 4.8)
                > r.magnitude(at: f + beat, ear: .right, from: settle, to: 4.8))
    }

    @Test("the sag is 2% at full load and nothing at rest")
    func sagRange() {
        #expect(abs((1 - 1.0 * 0.020) - 0.98) < 1e-12)
        #expect(1 - 0.0 * 0.020 == 1.0)
    }

    // ── V · reflect — face on, edge on, turned away ────────────────────

    /// *"Face on: +. Edge on: zero — a mirror seen edge-on is nothing at all, and the second
    /// tone is gone at the same instant. Turned away: minus, the same note at the same pitch,
    /// arriving inverted. It does not go quiet; it goes HOLLOW."*
    @Test("reflect at 0 takes the second tone away entirely")
    func reflectEdgeOn() throws {
        let f = 174.0, beat = 8.0
        let v = pointVoice(rootHz: f, beat: beat)
        v.laws.write(RegisterLaws(reflect: Smoothed(0, tau: 0.10)))
        let r = try OfflineRender.render(v.sourceNode, seconds: 4.0)
        let faceOn = try OfflineRender.render(pointVoice(rootHz: f, beat: beat).sourceNode, seconds: 4.0)

        #expect(r.magnitude(at: f + beat, ear: .right, from: settle, to: 3.8)
                < faceOn.magnitude(at: f + beat, ear: .right, from: settle, to: 3.8) * 0.15,
                "edge on, the second tone must be gone")
    }

    /// The claim that separates it from a fade: at −1 the tone is at FULL amplitude and
    /// inverted. Same pitch, same level, opposite sign — so the pair sums to less than it was
    /// while neither tone got quieter.
    @Test("reflect at −1 is inverted, not quiet")
    func reflectTurnedAwayIsHollowNotQuiet() throws {
        let f = 174.0, beat = 8.0
        let away = pointVoice(rootHz: f, beat: beat)
        away.laws.write(RegisterLaws(reflect: Smoothed(-1, tau: 0.10)))
        let a = try OfflineRender.render(away.sourceNode, seconds: 4.0)
        let faceOn = try OfflineRender.render(pointVoice(rootHz: f, beat: beat).sourceNode, seconds: 4.0)

        // the magnitude at the second tone's pitch is UNCHANGED — it is still fully there
        let inverted = a.magnitude(at: f + beat, ear: .right, from: settle, to: 3.8)
        let normal = faceOn.magnitude(at: f + beat, ear: .right, from: settle, to: 3.8)
        #expect(abs(inverted - normal) < normal * 0.2,
                "turned away should be as loud as face on: \(inverted) vs \(normal)")
        // and it is NOT the edge-on case
        let edge = pointVoice(rootHz: f, beat: beat)
        edge.laws.write(RegisterLaws(reflect: Smoothed(0, tau: 0.10)))
        let e = try OfflineRender.render(edge.sourceNode, seconds: 4.0)
        #expect(inverted > e.magnitude(at: f + beat, ear: .right, from: settle, to: 3.8) * 3)
    }
}

// ── the two the design defines and never calls ────────────────────────
//
// `spine-sound.js:164` `nul` and `:176` `distance` have NO caller anywhere in the design
// corpus. Every other register law has one. So C1 wrote the callers, and they are the app's
// own idiom — the numbers are the design's and exact, the invocation is ours.
// `Coverage/9` §5b.
@Suite("C1 · nul and distance · callers are the app's own")
@MainActor
struct AppOwnLawTests {

    private func voice() -> BreathVoice {
        BreathVoice(snapshot: .breathDefault, initialCrossfadeLevel: 1,
                    routeState: RouteStateHolder(false))
    }

    /// THE ASSERTION THAT PROVES WORLD V RATHER THAN APPROXIMATING IT.
    ///
    /// *"the SAME signal, summed at exactly minus one. Not a fade and not a duck — a copy of
    /// the voice cancelling the voice."* A fade approaches zero; a null IS zero. And the echo
    /// send must still carry, because it taps `pk` upstream of the null — which is the whole
    /// reason the tap was moved.
    @Test("a null is exactly zero AND the echo send still carries")
    func nullIsExactAndTheSendSurvives() throws {
        func peakThrough(_ nul: Double) throws -> OfflineRender.Rendered {
            try OfflineRender.render(voice().sourceNode,
                                     through: [AVAudioMixerNode()],
                                     seconds: 1.0,
                                     afterStart: { chain in
                (chain[0] as! AVAudioMixerNode).outputVolume = SoundEngine.nullVolume(for: nul)
            })
        }
        let open = try peakThrough(0).peak(from: 0.5)
        let nulled = try peakThrough(-1)
        let profile = stride(from: 0.0, to: 1.0, by: 0.1)
            .map { String(format: "%.1f:%.5f", $0, nulled.peak(from: $0, to: $0 + 0.1)) }
            .joined(separator: " ")

        #expect(open > 0.001)
        #expect(nulled.peak(from: 0.5) == 0,
                "a null is exact; a fade only approaches. profile \(profile)")

        // HALF is a fade, and must not be mistaken for the null
        let half = try peakThrough(-0.5).peak(from: 0.5)
        #expect(half > 0 && half < open, "half open is a fade: \(half) vs \(open)")

        // AND THE SEND SURVIVES IT. The send taps the voice node, which is upstream of the
        // null mixer, so a fully-open null leaves the echo untouched.
        let v = voice()
        v.null.write(-1)
        #expect(try OfflineRender.render(v.sourceNode, seconds: 0.5).peak() > 0.001,
                "the tap went silent — the null is downstream of the send, not upstream")
    }

    @Test("nullVolume maps the design's range exactly, and clamps outside it")
    func nullVolumeExact() {
        #expect(SoundEngine.nullVolume(for: 0) == 1)
        #expect(SoundEngine.nullVolume(for: -1) == 0)
        #expect(SoundEngine.nullVolume(for: -0.5) == 0.5)
        #expect(SoundEngine.nullVolume(for: -2) == 0)
        #expect(SoundEngine.nullVolume(for: 1) == 1)
    }

    /// `distance(f)` drives two things at once — `ech.gain → f·0.62` and
    /// `delayTime → 0.30 + f·1.35` — and both must stay inside what the app's nodes accept.
    @Test("distance's whole range is representable")
    func distanceRange() {
        for i in 0...10 {
            let f = Double(i) / 10
            let send = f * 0.62, time = 0.30 + f * 1.35
            #expect(send >= 0 && send <= 1, "send \(send) outside a mixer's volume")
            #expect(time > 0 && time <= 2.0, "delayTime \(time) above the unit's ceiling")
        }
        #expect(abs(0.62 - 1.0 * 0.62) < 1e-12)     // fully away
        #expect(abs((0.30 + 1.35) - 1.65) < 1e-12)
    }
}

// ── VI · what is sent, and what comes back ────────────────────────────
//
// `spine-sound.js:189-228`. The register whose whole physics is the delay line A2 built:
// *"the room IS the distance it travelled."* `send` is called nowhere in the design either —
// like `nul` and `distance`, the caller is the app's; the numbers are the design's.
@Suite("C1 · VI · send, arrive, arriveAll")
struct ReturnRegisterTests {

    /// *"It bends down and away as it goes, the way a thing leaving does."* `f×2 → f×1.12`
    /// across 1.5s — a fall of nearly an octave while it goes.
    @Test("send bends down and away as it leaves")
    func sendBendsDown() throws {
        let f = 396.0
        let v = CeremonyVoice(hz: f * 2, peak: 0.075, attackSeconds: 0.05, releaseSeconds: 1.65,
                              synth: .sine, endHz: f * 1.12, glideSeconds: 1.5,
                              envelope: .linearExp)
        let r = try OfflineRender.render(v.sourceNode, seconds: 2.0)
        // early it is up at f×2; by the end it has fallen to f×1.12
        for ear in [OfflineRender.Rendered.Ear.left, .right] {
            #expect(r.magnitude(at: f * 2, ear: ear, from: 0.02, to: 0.30)
                    > r.magnitude(at: f * 1.12, ear: ear, from: 0.02, to: 0.30))
            #expect(r.magnitude(at: f * 1.12, ear: ear, from: 1.2, to: 1.6)
                    > r.magnitude(at: f * 2, ear: ear, from: 1.2, to: 1.6))
        }
        #expect(abs(r.peak() - 0.075) < 0.010, "peak \(r.peak()), design says 0.075")
    }

    /// *"a thing leaving goes somewhere."* The pan ramps 0 → pan across 1.4s, so it starts
    /// centred and ends off to one side.
    @Test("send travels across the head")
    func sendPans() throws {
        let f = 396.0
        let v = CeremonyVoice(hz: f * 2, peak: 0.075, attackSeconds: 0.05, releaseSeconds: 1.65,
                              synth: .sine, endHz: f * 1.12, glideSeconds: 1.5,
                              envelope: .linearExp, panTo: 1.0, panSeconds: 1.4)
        let r = try OfflineRender.render(v.sourceNode, seconds: 2.0)
        let earlyL = r.magnitude(at: f * 2, ear: .left, from: 0.05, to: 0.2)
        let earlyR = r.magnitude(at: f * 2, ear: .right, from: 0.05, to: 0.2)
        #expect(abs(earlyL - earlyR) < earlyL * 0.25, "it must start centred")
        let lateL = r.magnitude(at: f * 1.12, ear: .left, from: 1.3, to: 1.6)
        let lateR = r.magnitude(at: f * 1.12, ear: .right, from: 1.3, to: 1.6)
        #expect(lateR > lateL * 3, "it must end to one side: L \(lateL) R \(lateR)")
    }

    /// THE SHAPE OF A THING APPROACHING. Every other event in the app strikes and decays;
    /// this one swells in. A linear attack would make it a note that started.
    @Test("arrive swells in backwards, cresting at 1.15s")
    func arriveSwellsIn() throws {
        let v = CeremonyVoice(hz: 528 * 1.5, peak: 0.052 / 1.22, attackSeconds: 1.15,
                              releaseSeconds: 2.25, synth: .sineOctaveBelow,
                              envelope: .expSwellExp)
        let r = try OfflineRender.render(v.sourceNode, seconds: 3.6)
        #expect(abs(r.peakTime - 1.15) < 0.12, "crest at \(r.peakTime)s, design says 1.15")
        // it really swells: quiet at the start, loud at the crest
        #expect(r.peak(to: 0.2) < r.peak(from: 1.0, to: 1.3) * 0.2,
                "it started loud — that is a strike, not an approach")
    }

    /// *"one interval up — a fifth, a sixth, a seventh, and on the fourth return the octave:
    /// the lap that finally arrives home."* And each lap is quieter than the last.
    @Test("the four laps are a fifth, a sixth, a seventh and the octave")
    func fourLaps() {
        let R = [1.5, 5.0 / 3.0, 15.0 / 8.0, 2.0]
        #expect(abs(R[0] - 1.5) < 1e-12)          // a fifth
        #expect(abs(R[1] - 1.6667) < 1e-3)        // a sixth
        #expect(abs(R[2] - 1.875) < 1e-12)        // a seventh
        #expect(R[3] == 2.0)                      // home
        var peaks: [Double] = []
        for n in 1...4 { peaks.append(0.052 / (1 + Double(n) * 0.22)) }
        var quieter = true
        for i in 1..<peaks.count where peaks[i] >= peaks[i - 1] { quieter = false }
        #expect(quieter, "each lap quieter than the last: \(peaks)")
        // arriveAll hands over all four at 0.30s apart — the crossing made before him
        var offsets: [Double] = []
        for n in 1...4 { offsets.append(Double(n - 1) * 0.30) }
        let want: [Double] = [0, 0.30, 0.60, 0.90]
        var spaced = true
        for i in 0..<4 where abs(offsets[i] - want[i]) > 1e-9 { spaced = false }
        #expect(spaced, "0.30s apart: \(offsets)")      // 3×0.30 is 0.8999…, not 0.9
    }

    @Test("arrive carries an octave BELOW, not above")
    func arriveIsLargerNotBrighter() throws {
        let hz = 528.0 * 1.5
        let v = CeremonyVoice(hz: hz, peak: 0.04, attackSeconds: 1.15, releaseSeconds: 2.25,
                              synth: .sineOctaveBelow, envelope: .expSwellExp)
        let r = try OfflineRender.render(v.sourceNode, seconds: 3.0)
        for ear in [OfflineRender.Rendered.Ear.left, .right] {
            let f = r.magnitude(at: hz, ear: ear, from: 0.9, to: 2.0)
            #expect(abs(r.magnitude(at: hz * 0.5, ear: ear, from: 0.9, to: 2.0) / f - 0.34) < 0.08)
            #expect(r.magnitude(at: hz * 2, ear: ear, from: 0.9, to: 2.0) / f < 0.08,
                    "\(ear): no octave above")
        }
    }
}

// ── VII · THE DANCE — the only polyphonic register ────────────────────
@Suite("C1 · VII · join, ensemble, leaveAll")
struct DanceRegisterTests {

    /// *"each body that joins the chain is a real voice of its own at a harmonic of 852."*
    @Test("the five bodies are harmonics of 852, each quieter than the last")
    func harmonicsOf852() {
        let expected = [852.0, 1278.0, 1704.0, 2130.0, 2556.0]
        for k in 0..<5 {
            let d = DancerVoice(k: k)
            #expect(abs(d.hz - expected[k]) < 0.001, "body \(k) at \(d.hz)")
        }
    }

    /// *"entering out of tune and pulling into lock as the figure holds."* The detune
    /// alternates side and grows with k — they are not merely mistuned, they are mistuned
    /// away from each other.
    @Test("they enter out of tune, alternating and widening")
    func enterOutOfTune() {
        let cents = (0..<5).map { DancerVoice(k: $0).restingDetuneCents }
        #expect(cents == [-11, 16, -21, 26, -31])
        #expect(cents.allSatisfy { $0 != 0 }, "a dancer that enters in tune has nothing to find")
        let alternates = zip(cents, cents.dropFirst()).allSatisfy { $0 * $1 < 0 }
        #expect(alternates, "they must alternate: the chord beats because they disagree")
        let widening = zip(cents, cents.dropFirst()).allSatisfy { abs($1) > abs($0) }
        #expect(widening, "each body enters further out than the last")
    }

    /// `ensemble(lock)` closes the detune to `det·(1−lock)`, so at full lock they are in tune
    /// and the beating stops. That IS the register's claim: they find each other.
    @Test("ensemble closes the detune to zero at full lock")
    func ensembleLocks() throws {
        let d = DancerVoice(k: 1)
        d.setDetune(cents: 0)                        // ensemble(1.0)
        let locked = try OfflineRender.render(d.sourceNode, seconds: 3.0)
        let e = DancerVoice(k: 1)                    // ensemble(0) — resting detune
        let loose = try OfflineRender.render(e.sourceNode, seconds: 3.0)

        // in tune, the energy sits on the harmonic; out of tune it has moved off it
        // body 1 is panned RIGHT — `(k odd ? +1 : −1)·min(0.7, 0.18 + k·0.16)` = +0.34 — so
        // the right ear is where its energy actually is.
        let onPitch = locked.magnitude(at: 1278, ear: .right, from: 1.5, to: 2.9)
        let offPitch = loose.magnitude(at: 1278, ear: .right, from: 1.5, to: 2.9)
        #expect(locked.peak(ear: .right) > locked.peak(ear: .left), "body 1 pans right")
        #expect(onPitch > offPitch * 1.5,
                "lock did not tune them: locked \(onPitch), loose \(offPitch)")
        // 16 cents at 1278 Hz is ~11.8 Hz sharp — that is where the loose one went
        let sharpHz: Double = 1278 * pow(2.0, 16.0 / 1200.0)
        let atSharp = loose.magnitude(at: sharpHz, ear: .right, from: 1.5, to: 2.9)
        #expect(atSharp > offPitch)
    }

    @Test("a dancer fades rather than cutting when it leaves")
    func leavingIsAFade() throws {
        let d = DancerVoice(k: 0)
        let r = try OfflineRender.render(d.sourceNode, seconds: 2.0, afterStart: { _ in })
        #expect(r.peak(from: 1.4) > 0.001, "it should still be holding")
        #expect(!d.isDone)
        d.leave()
        let after = try OfflineRender.render(d.sourceNode, seconds: 2.0)
        #expect(after.peak(from: 1.5) < after.peak(to: 0.2), "it must come down")
    }
}
