import SwiftUI

// A POINT WORLD (one of the seven dimensions, m1…m7) rendered on the axis. Its
// voice, its universes, and its stars; a star descends into SAY → WALK → HAND →
// OPEN (verbatim canon, touch-paced). The descent write-back (Point Descent) is
// noted in the walk — for Wave 6 the walk deepens in-session (persisting the
// write-back is the same layer the ring uses; both flagged where session-only).
//
// World VI (The Return) earns its door into the Return ceremony.

struct PointWorldView: View {
    let dimensionN: Int          // 1…7 → m1…m7
    @Binding var path: [FeedRoute]
    let onReturn: () -> Void

    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var selectedUniverse: PointUniverse?   // the middle tier: dimension → universe → star
    @State private var openStar: PointStar?
    @State private var goodnight = false

    // The solfeggio ladder — one tone per dimension (285…852), the ladder rising as he descends.
    private let ladder: [Double] = [285, 396, 417, 528, 639, 741, 852]

    private var dim: PointDimension? { PointContent.dimensions.first { $0.n == dimensionN } }
    private var hue: Color { Color(hex: PointContent.hues["m\(dimensionN)"] ?? "#C0392B") }

    var body: some View {
        ZStack {
            if let star = openStar {
                // LEVEL 2 — the reading, in THIS world's own hand. E3: the shared sheet
                // (`point-levels.js:161 openSheet()`) is superseded and ships nowhere.
                PointReading(dimensionN: dimensionN, star: star, hue: hue,
                             onClose: { withAnimation { openStar = nil } })
            } else if let u = selectedUniverse {
                // LEVEL 1 — the universe as a constellation: its stars in the world's native
                // material (Amendment §7.3: the universe, drawn inside the figure).
                PointWorld(dimensionN: dimensionN, stars: PointWorlds.placed(u), hue: hue) { s in
                    soundEngine.riteVoice(hz: ladder[(dimensionN - 1) % 7], dur: 6)
                    PointJourney.openedStars.append(s.t)
                    withAnimation(.easeInOut(duration: 0.8)) { openStar = s }
                }
                .ignoresSafeArea()

                VStack(spacing: 6) {
                    Text(u.name.uppercased()).font(.spaceMono(9)).tracking(2).foregroundStyle(hue)
                    Text(u.sub).font(.loraItalic(12)).foregroundStyle(BinduTheme.inkSecondary)
                        .multilineTextAlignment(.center).lineLimit(2).padding(.horizontal, 44)
                    Spacer()
                }
                .padding(.top, 46).allowsHitTesting(false)

                VStack {
                    HStack {
                        Button { withAnimation(.easeInOut(duration: 0.6)) { selectedUniverse = nil } } label: {
                            Text("‹ the enclosure").font(.spaceMono(9)).tracking(2)
                                .foregroundStyle(BinduTheme.inkTertiary).padding(16)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            } else if let dim {
                // LEVEL 0 — the dimension holds its named universes (the middle tier).
                PointUniversesView(dim: dim, hue: hue) { u in
                    soundEngine.riteVoice(hz: ladder[(dimensionN - 1) % 7], dur: 5)
                    PointJourney.universes.append(u.name)
                    withAnimation(.easeInOut(duration: 0.7)) { selectedUniverse = u }
                }
                .ignoresSafeArea()

                if dimensionN == 6 {
                    VStack { Spacer()
                        Button(action: onReturn) {
                            Text("settle deeper · open the return ›")
                                .font(.spaceMono(9)).tracking(2).foregroundStyle(hue)
                        }.padding(.bottom, 64)
                    }
                }
                if dimensionN == 7 {
                    VStack { Spacer()
                        Button { $path.pushDissolve(FeedRoute.aperture) } label: {
                            Text("the aperture ›").font(.spaceMono(9)).tracking(2).foregroundStyle(hue)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 64)
                    }
                }

                // The goodnight — "I Love You" at first arrival in this world, in its hue, then gone.
                if goodnight {
                    Text("I Love You")
                        .font(.loraItalic(21)).foregroundStyle(hue)
                        .shadow(color: hue.opacity(0.4), radius: 10)
                        .transition(.opacity)
                }
            }
        }
        // Lock the axis whenever a world body (selectedUniverse) or a star reading (openStar)
        // is open, so their own drag/scroll wins over the axis travel gesture.
        .onChange(of: openStar != nil) { _, _ in syncAxisLock() }
        .onChange(of: selectedUniverse != nil) { _, _ in syncAxisLock() }
        .onAppear {
            syncAxisLock()
            if let dim { PointJourney.enteredDims.append(dim.name) }
            if !PointGoodnight.shown.contains(dimensionN) {
                PointGoodnight.shown.insert(dimensionN)
                withAnimation(.easeIn(duration: 1.2)) { goodnight = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    withAnimation(.easeOut(duration: 1.4)) { goodnight = false }
                }
            }
        }
    }

    /// Was: told the axis to lock itself while a reading was open. The axis is never locked
    /// now — the vertical always walks it, which is what makes a register reachable at all
    /// (`B0.2`). A reading that needs to keep the vertical claims it locally, the way the
    /// fall does; nothing reaches up and disables the instrument.
    private func syncAxisLock() { }
}

// The goodnights are said once per dimension per session, then gone.
private enum PointGoodnight { static var shown = Set<Int>() }

// A deeper reading, generated live in the Arch register and kept (point-levels.js generate()).
// Its five fields ARE the offline fallback at `point-levels.js:210-211` — verbatim-ported,
// audit-marked correct, and explicitly kept by the E3 ruling.
struct PointDeeper: Codable { let arrival, teaching, thread, practice, ascent: String }

/// LEVEL 3 — the descent, one true layer deeper. Shared by all seven worlds, as it is in
/// the design (`descent` is a single global element there). This is NOT the sheet E3 kills:
/// the sheet was level 2's generic four-section reading; this is level 3, and its five-field
/// offline fallback at `point-levels.js:210-211` is verbatim-ported and correct.
struct PointDescentDoor: View {
    let star: PointStar
    let hue: Color
    @State private var deeper: PointDeeper?
    @State private var reaching = false
    @State private var reached = false
    private var cacheKey: String { "point.descent.\(star.t)" }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let d = deeper {
                ScrollView { deeperStages(d).padding(.horizontal, 32).padding(.bottom, 40) }
                    .frame(maxHeight: 380)
            } else if reaching {
                Text("descending…").spaceMonoTracked(9, em: 0.2)
                    .foregroundStyle(hue.opacity(0.7)).padding(.bottom, 34)
            } else {
                Button { Task { await descend() } } label: {
                    Text("▽ DESCEND ONE LAYER DEEPER").spaceMonoTracked(10, em: 0.2)
                        .foregroundStyle(hue)
                }
                .buttonStyle(.plain).padding(.bottom, 34)
            }
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [.clear, Color(hex: "#050408").opacity(0.9)],
                                   startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }

    @ViewBuilder private func deeperStages(_ d: PointDeeper) -> some View {
        let stages: [(String, String, Bool)] = [
            ("arrival", d.arrival, false), ("the teaching", d.teaching, false),
            ("the thread", d.thread, true), ("the practice", d.practice, true), ("the ascent", d.ascent, false)
        ].filter { !$0.1.isEmpty }
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(stages.enumerated()), id: \.offset) { _, s in
                VStack(alignment: .leading, spacing: 6) {
                    Text(s.0.uppercased()).font(.spaceMono(9)).tracking(1.5).foregroundStyle(hue.opacity(0.7))
                    Text(s.1).font(.lora(s.2 ? 14 : 15.5)).lineSpacing(6)
                        .foregroundStyle(s.2 ? BinduTheme.inkSecondary : BinduTheme.inkPrimary)
                }
                .transition(.opacity)
            }
        }
        .padding(.top, 10)
    }

    // One live layer deeper, in the Arch register — generated once, then persisted per star so a
    // re-descent returns the same reading (point-levels.js cache[k]). Graceful offline fallback.
    private func descend() async {
        guard !reached else { return }
        reached = true
        // persisted?
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode(PointDeeper.self, from: data) {
            withAnimation(.easeInOut(duration: 1.0)) { deeper = cached }
            return
        }
        let held = star.walk.replacingOccurrences(of: "*", with: "")
        let fallback = PointDeeper(
            arrival: "The deeper field is quiet just now — this is the held knowing.",
            teaching: held, thread: "",
            practice: "One breath. Feet on the ground. Eyes soft.",
            ascent: "Carry the one line that landed.")
        guard let key = KeychainService.load("anthropic_api_key"), !key.isEmpty,
              let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            withAnimation(.easeInOut(duration: 1.0)) { deeper = fallback }; return
        }
        reaching = true
        // `point-levels.js:186-196 generate()` — three things the earlier port dropped, and
        // the third is the load-bearing one: the star's DIMENSION, its STATUS in `SM`
        // ("walked" / "in progress" / "seeded"), and a different instruction for a SEEDED
        // star. Fourteen of the 66 are seeded, and for those the descent is his FIRST
        // meeting with the topic, not a layer under a reading he has already walked.
        let dimName = PointContent.dimensions.first { d in
            d.universes.contains { $0.stars.contains(star.key) }
        }?.name ?? ""
        let status = PointStatus.word(star.st)
        let seededBranch = star.st == "s"
            ? "This star is seeded, not yet walked — this is his FIRST TRUE MEETING with the topic: bring its actual substance accurately from its real tradition or science, going well beyond the held reading."
            : "Go one true layer deeper than the held reading — material it did not include."
        let prompt = """
        You are the descent-voice of an instrument called The Point — a nine-enclosure walk a seeker uses \
        to reorient when caught in mental rush. He has descended onto the star "\(star.t)" (\(star.ti)) \
        in the dimension "\(dimName)". The instrument's held reading of this star: "\(held)". \
        Status: \(status).

        Write the descent in the ARCH register — devotion made audible, warmth threaded through precision. \
        Its four frequencies, all present: TEACHING — never declare; name what the reader currently holds, \
        then walk him to primary evidence (actual names, actual texts, actual numbers, terms in their \
        original language) and trust him to arrive. PROTECTIVE — equip, never alarm; fill a gap he didn't \
        know he had. JOY — delight as substrate, legible without exclamation marks. INVITATION — the ending \
        opens a door, never closes on a conclusion. Second person, present tense, no mysticism-clichés. Go \
        \(seededBranch)

        Respond with ONLY a JSON object, no markdown fences, keys: "arrival" (1-2 sentences), "teaching" \
        (4-6 sentences), "thread" (1-2 sentences), "practice" (1-2 sentences), "ascent" (1 sentence). No preamble.
        """
        let body: [String: Any] = ["model": "claude-opus-5", "max_tokens": 1024,
                                   "messages": [["role": "user", "content": prompt]]]
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(key, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        var result = fallback
        if let (data, resp) = try? await URLSession.shared.data(for: req),
           let http = resp as? HTTPURLResponse, http.statusCode == 200,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let content = json["content"] as? [[String: Any]] {
            let text = content.compactMap { ($0["type"] as? String) == "text" ? $0["text"] as? String : nil }.joined()
            let cleaned = text.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "")
            if let lo = cleaned.firstIndex(of: "{"), let hi = cleaned.lastIndex(of: "}"), lo <= hi,
               let d = try? JSONDecoder().decode(PointDeeper.self, from: Data(cleaned[lo...hi].utf8)) {
                result = d
                UserDefaults.standard.set(try? JSONEncoder().encode(d), forKey: cacheKey)   // kept
            }
        }
        reaching = false
        withAnimation(.easeInOut(duration: 1.0)) { deeper = result }
    }
}
