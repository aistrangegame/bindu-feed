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
    /// The Point's half of `handedToRegister` — the same contract the Universe's fall uses.
    /// TRUE while a universe body or a star reading is open: the register owns the vertical,
    /// and `#where` steps aside because a star is held.
    var onHold: (Bool) -> Void = { _ in }

    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var selectedUniverse: PointUniverse?   // the middle tier: dimension → universe → star
    @State private var openStar: PointStar?
    @State private var goodnight = false
    /// How much of the reading has been given — the world behind recedes by it.
    @State private var revealed = 0

    // The solfeggio ladder — one tone per dimension (285…852), the ladder rising as he descends.
    private let ladder: [Double] = [285, 396, 417, 528, 639, 741, 852]

    private var dim: PointDimension? { PointContent.dimensions.first { $0.n == dimensionN } }

    private var hue: Color { Color(hex: PointContent.hues["m\(dimensionN)"] ?? "#C0392B") }

    var body: some View {
        ZStack {
            // THE WORLD IS DRAWN BEHIND THE READING, NOT REPLACED BY IT.
            //
            // This was a mutually-exclusive `if / else if` chain, so at level 2 the world was
            // unmounted and there was nothing to recede — which is why the seven coefficients
            // sat read-but-unimplemented since Pass 5. `A = p·(1 − dsp·k)` needs a `p` to
            // multiply.
            //
            // It also closes A5: the world's own chrome (its header, its `‹ the enclosure`)
            // stays OUT of the reading, because only the material is drawn behind — the
            // chrome belongs to the level he is not on.
            if let star = openStar, let u = selectedUniverse {
                PointWorld(dimensionN: dimensionN, stars: PointWorlds.placed(u), hue: hue,
                           onOpen: { _ in }, quiet: true)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .opacity(PointRecede.worldAlpha(dimension: dimensionN,
                                                    revealed: revealed, open: true))
                    .animation(.easeInOut(duration: 1.1), value: revealed)

                PointReading(dimensionN: dimensionN, star: star, hue: hue,
                             onClose: { withAnimation { openStar = nil }; revealed = 0 },
                             onReveal: { revealed = $0 })
            } else if let star = openStar {
                // reached without a universe (the debug star hook) — no world to recede
                PointReading(dimensionN: dimensionN, star: star, hue: hue,
                             onClose: { withAnimation { openStar = nil }; revealed = 0 })
            } else if let u = selectedUniverse {
                // LEVEL 1 — the universe as a constellation: its stars in the world's native
                // material (Amendment §7.3: the universe, drawn inside the figure).
                PointWorld(dimensionN: dimensionN, stars: PointWorlds.placed(u), hue: hue) { s in
                    // `world-five.js:49-50` — *"at the exact instant every other star sounds
                    // its arrival, this one is silent: a true null, the only deliberate
                    // silence in the Point. Sakshi's register — it witnesses, it does not
                    // teach."* `mute` is set at `:161` and read by nothing in the reference
                    // build; it is read HERE. This silence is the design, never a gap to fix.
                    if s.key != "r-guard" {
                        soundEngine.riteVoice(hz: ladder[(dimensionN - 1) % 7], dur: 6)
                    }
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
        // THE HALL, WITHDRAWN. Drawn here rather than in the reading because the reading is
        // carried out at 3.0s and the withdrawal runs to 5.4s — it has to have somewhere to
        // finish. `world-five.js:200-201`: it LOOMS (1.16) where everything else recedes.
        .overlay {
            if dimensionN == 5 {
                TimelineView(.animation) { _ in
                    let bk = MirrorHall.bk()
                    if bk > 0 {
                        Color(hex: "#EAFBF8").opacity(bk * 0.86)
                            .ignoresSafeArea().allowsHitTesting(false)
                    }
                }
            }
        }
        // Released on the way out, like the fall's four scoped paths: a register that is no
        // longer mounted must never still be holding the vertical.
        .onDisappear { onHold(false); PointYantra.shared.readingOpen = false }
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
    /// This was an EMPTY BODY. Declared, wired into three call sites, commented with exactly
    /// what it does — and doing nothing, which is indistinguishable from a lock that is on.
    ///
    /// The cost was not cosmetic. Every Point reading takes a vertical or near-vertical drag
    /// (II travels outward on it, III parts on it, IV presses on it), and with the axis still
    /// listening the drag walked the axis to the next register instead. WORLD II WAS NOT
    /// WALKABLE BY ANY HAND — the first upward swipe carried you from The Turn to The Veil
    /// with the reading still open behind it.
    ///
    /// `AxisTravel.handedToRegister` already existed and is enforced at the source in
    /// `applyDrag`, so no call path can route around it. It only ever needed to be told.
    private func syncAxisLock() {
        onHold(openStar != nil || selectedUniverse != nil)
        // The figure recedes under a READING specifically — not under the universe body,
        // where the nodes are standing on the figure and it is the thing being looked at.
        PointYantra.shared.readingOpen = openStar != nil
    }
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
    @State private var shown = 0                 // stages revealed so far
    @EnvironmentObject private var soundEngine: SoundEngine
    private var cacheKey: String { "point.descent.\(star.t)" }

    /// `[label, text, minor]`, then FILTERED on non-empty (`point-levels.js:1249`). Five is
    /// the ceiling, not the count — and offline it is always FOUR, because the fallback's
    /// `thread` is `''` by design and filters itself out. The two minor stages are set
    /// smaller, dimmer and italic (`.d-stage.minor`, `:1097`).
    private func stages(_ d: PointDeeper) -> [(String, String, Bool)] {
        [("arrival", d.arrival, false), ("the teaching", d.teaching, false),
         ("the thread", d.thread, true), ("the practice", d.practice, true),
         ("the ascent", d.ascent, false)].filter { !$0.1.isEmpty }
    }

    var body: some View {
        // A LAYER IN THE STAGE, not a system modal. `.ovl{position:absolute;inset:0;z-index:12}`
        // is a sibling of the feed inside `#stage` — so this is a full-bleed ZStack, and the
        // door is one item aligned to its bottom.
        //
        // It was a `.fullScreenCover` first, and that silently did nothing: the cover was
        // attached to a `Group` whose `if` renders EMPTY the moment `deeper` is set, so at the
        // instant it should present, its anchor no longer exists. The shaft rose and the
        // figure dimmed on cue — every visible signal said the descent had begun — and the
        // reading it was meant to cover just sat there. Absence again, wearing the shape of
        // something wired.
        ZStack(alignment: .bottom) {
            if deeper == nil {
                // The door, at the foot of the reading.
                VStack(spacing: 0) {
                    if reaching {
                        Text("descending…").spaceMonoTracked(8, em: 0.24)
                            .foregroundStyle(BinduTheme.inkPrimary.opacity(0.3)).padding(.bottom, 34)
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
            } else {
                descentOverlay.transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        // THE DESCENT IS AN OVERLAY OVER EVERYTHING, not a panel inside the reading.
        // `.ovl{position:absolute;inset:0;z-index:12;background:rgba(7,8,13,.965)}` (`:1050`)
        // — it covers the world, the plate and the reading, which is why the register content
        // is hidden (`feed.style.opacity=0`, `:1242`) and the yantra goes to `descend` with
        // the shaft raised. A 380pt scroll box inside the reading was the wrong object: it
        // let the world stay legible behind a thing that exists to take the world away.
    }

    @ViewBuilder private var descentOverlay: some View {
        if let d = deeper {
            let st = stages(d)
            ZStack(alignment: .top) {
                Color(red: 7 / 255, green: 8 / 255, blue: 13 / 255).opacity(0.965).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // `.dtopic` — mono 8 / .3em / uppercase / --dhue / centred / mb 34
                        Text(star.t.uppercased()).spaceMonoTracked(8, em: 0.3)
                            .foregroundStyle(hue).multilineTextAlignment(.center)
                            .padding(.bottom, 34)

                        ForEach(Array(st.enumerated()), id: \.offset) { i, sg in
                            VStack(spacing: 0) {
                                // `.d-label` — mono 7.5 / .3em / --dhue at .75 / mb 12
                                Text(sg.0.uppercased()).spaceMonoTracked(7.5, em: 0.3)
                                    .foregroundStyle(hue.opacity(0.75)).padding(.bottom, 12)
                                // `.d-text` 17/1.76 cream · `.minor` 14.5 dim italic
                                Text(sg.1)
                                    .font(sg.2 ? .loraItalic(14.5) : .lora(17))
                                    .lineSpacing(sg.2 ? 10 : 13)
                                    .foregroundStyle(sg.2 ? BinduTheme.inkSecondary : BinduTheme.inkPrimary)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 330)
                            .padding(.bottom, 34)
                            // `.d-stage` — opacity 0 + translateY(12), 2.4s ease on both
                            .opacity(i < shown ? 1 : 0)
                            .offset(y: i < shown ? 0 : 12)
                            .animation(.easeInOut(duration: 2.4), value: shown)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 120).padding(.horizontal, 34).padding(.bottom, 90)
                }
                .scrollIndicators(.hidden)

                if shown >= st.count {
                    HStack {
                        Button { ascend() } label: {
                            Text("‹ ascend").spaceMonoTracked(8.5, em: 0.2)
                                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.3)).padding(10)
                        }.buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.leading, 24).padding(.top, 8)
                    .transition(.opacity)
                }
            }
            // TAP ADVANCES ONE STAGE — it does not skip to the end. `:1256-1260` reveals the
            // NEXT un-revealed stage and nothing more; only when there is no next does the
            // ascent appear. He can outrun the 3400ms clock, one stage at a time; he cannot
            // jump the walk.
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 2.4)) { shown = min(st.count, shown + 1) }
            }
            .task(id: st.count) {
                // `700 + i*3400` (`:1253`), and the ascent at `700 + n*3400` (`:1255`).
                for i in 0..<st.count {
                    let due = 700 + i * 3400
                    try? await Task.sleep(for: .milliseconds(due))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 2.4)) { shown = max(shown, i + 1) }
                }
            }
        }
    }

    // One live layer deeper, in the Arch register — generated once, then persisted per star so a
    // re-descent returns the same reading (point-levels.js cache[k]). Graceful offline fallback.
    /// `:229` — the hall comes back: the figure returns to `walk`, the shaft drops, the
    /// register content is legible again, and the glide runs the other way.
    private func ascend() {
        shown = 0
        deeper = nil
        PointYantra.shared.descending = false
        withAnimation(.easeInOut(duration: 1.4)) { PointYantra.shared.shaft = 0 }
        soundEngine.setAxisGlide(hz: 0, level: 0)
    }

    private func descend() async {
        guard !reached else { return }
        reached = true
        shown = 0
        // `:206` — `YANTRA.setMode('descend'); YANTRA.shaft=1;`. The figure dims to 0.22 and
        // one shaft of the enclosure's light remains, which is the only thing still lit
        // while he is under it.
        PointYantra.shared.descending = true
        withAnimation(.easeInOut(duration: 1.8)) { PointYantra.shared.shaft = 1 }
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
