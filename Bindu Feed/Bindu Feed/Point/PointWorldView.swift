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
    @Binding var axisLocked: Bool    // told UP to InstrumentView: true while a world body / star reading is open
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
                // LEVEL 2 — the star reading + descent.
                PointStarDescent(star: star, hue: hue, onClose: { withAnimation { openStar = nil } })
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
        .onDisappear { axisLocked = false }
    }

    private func syncAxisLock() { axisLocked = openStar != nil || selectedUniverse != nil }
}

// The goodnights are said once per dimension per session, then gone.
private enum PointGoodnight { static var shown = Set<Int>() }

// A deeper reading, generated live in the Arch register and kept (point-levels.js generate()).
struct PointDeeper: Codable { let arrival, teaching, thread, practice, ascent: String }

// The star descent — SAY → WALK → HAND → OPEN, one beat per touch (verbatim canon), and then
// the true descent: one live layer deeper (Arch register), generated once and PERSISTED per star.
private struct PointStarDescent: View {
    let star: PointStar
    let hue: Color
    let onClose: () -> Void
    @State private var beat = 0   // 0 say · 1 walk · 2 hand · 3 open
    @State private var deeper: PointDeeper?
    @State private var reaching = false
    @State private var reached = false     // the descent has been asked for

    private let labels = ["THE RUSH SAYS", "WALK TO WHAT IS TRUE", "WHAT THIS HANDS YOU", "THE INVITATION"]
    private var texts: [String] { [star.say, star.walk, star.hand, star.open] }
    private var cacheKey: String { "point.descent.\(star.t)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Button { onClose() } label: { Text("‹").font(.system(size: 20)).foregroundStyle(BinduTheme.inkTertiary) }
                    Spacer()
                }
                Text(star.t).font(.lora(24, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
                Text(star.ti).font(.loraItalic(14)).foregroundStyle(hue)
                ForEach(0...beat, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(labels[i]).font(.spaceMono(9)).tracking(1.5).foregroundStyle(hue.opacity(0.7))
                        Text(texts[i]).font(.lora(15.5)).lineSpacing(6).foregroundStyle(BinduTheme.inkPrimary)
                    }
                    .transition(.opacity)
                }
                if beat < 3 {
                    Text("touch to walk further").font(.spaceMono(9)).tracking(2)
                        .foregroundStyle(BinduTheme.inkTertiary).padding(.top, 4)
                }

                // Past the OPEN — the descent one true layer deeper, generated and kept.
                if beat >= 3 {
                    if let d = deeper {
                        deeperStages(d)
                    } else if reaching {
                        Text("descending…").font(.spaceMono(9)).tracking(2).foregroundStyle(hue.opacity(0.7)).padding(.top, 8)
                    } else {
                        Button { Task { await descend() } } label: {
                            Text("▽ descend one layer deeper").font(.spaceMono(10)).tracking(2).foregroundStyle(hue).padding(.top, 8)
                        }.buttonStyle(.plain)
                    }
                }
                Color.clear.frame(height: 60)
            }
            .padding(.horizontal, 32).padding(.top, 20)
        }
        .scrollIndicators(.hidden)
        .contentShape(Rectangle())
        .onTapGesture {
            if beat < 3 {
                withAnimation(.easeInOut(duration: 1.0)) { beat += 1 }
                if beat == 3 { PointJourney.descended.append(star.t) }   // walked to the OPEN — the descent
            }
        }
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
        let prompt = """
        You are the descent-voice of an instrument called The Point — a nine-enclosure walk a seeker uses \
        to reorient when caught in mental rush. He has descended onto the star "\(star.t)" (\(star.ti)). \
        The instrument's held reading of this star: "\(held)".

        Write the descent in the ARCH register — devotion made audible, warmth threaded through precision. \
        Its four frequencies, all present: TEACHING — never declare; name what the reader currently holds, \
        then walk him to primary evidence (actual names, actual texts, actual numbers, terms in their \
        original language) and trust him to arrive. PROTECTIVE — equip, never alarm; fill a gap he didn't \
        know he had. JOY — delight as substrate, legible without exclamation marks. INVITATION — the ending \
        opens a door, never closes on a conclusion. Second person, present tense, no mysticism-clichés. Go \
        one true layer deeper than the held reading — material it did not include.

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
