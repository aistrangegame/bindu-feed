import SwiftUI

// THE APERTURE — avarana VIII, and it is WHOLE WITHOUT A KEY.
//
// `The Aperture.html` (comps). The surface used to be dead without a personal Anthropic
// key: it asked for one and did nothing else. The instinct there was to design a graceful
// failure, and the comp found the better answer by asking what the model was actually for:
//
//   *"the model was never supplying the unpredictability."*
//
// The Aperture promises two things — a register drawn from traditions this library has
// never walked, and something arriving that you did not choose. The first is a local table
// of 37. The second was never about generated text; it was about THIS CAME FROM OUTSIDE
// YOUR LOOP. A random draw from 37 traditions you have never walked *is* that.
//
//   THE STANDARD APERTURE GIVES YOU THE REGISTER, HONESTLY,
//   AND NEVER FABRICATES THE TEACHING.
//
// So every slot fills locally and none of them pretends. With a key the frame does not
// change — same eye, same three slots, same typography — the live call fills the line and
// the deepening, and *where this library stops* stays underneath. The key is an
// enhancement to a complete surface, never the thing that makes it work.
//
// THE ORIGIN SLOT IS GONE. The comp authored a `tradition and where it lives` line for all
// 37 and marked every one `authored · for approval` — 37 factual claims about living
// traditions needing checking before launch. They duplicate what the register string
// already carries: "Qalb — the heart-organ of the Sufi Lataif" states its own origin. So
// there is nothing to approve and nothing to fact-check, in either state.
struct ApertureView: View {
    @Binding var path: [FeedRoute]
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine

    @State private var keyInput = ""
    @State private var hasKey = KeychainService.load("anthropic_api_key") != nil
    @State private var showKeyEntry = false
    @State private var card: VisitorCard?
    @State private var status = ""
    @State private var busy = false
    @State private var arrived = false

    private let hue = Color(hex: "#D4A94B")
    private let cream = Color(hex: "#F0E9DC")
    private var dim: Color { cream.opacity(0.62) }
    private var faint: Color { cream.opacity(0.30) }

    /// The three slots. `reg` is the eyebrow, `line` the compressed sentence, `deep` the
    /// body — and `edge`, which is always present, is where this library stops.
    private struct VisitorCard {
        let reg: String
        let line: String
        let deep: String
        let edge: String
    }

    // The 37 unwalked registers — `The Instrument v3.html:931-951` / `canon/point-content.js`,
    // verbatim, and already byte-identical here before this pass. Untouched.
    /// **SHARED STATIC · any test suite touching this is `.serialized`** (§10 TENTH SHAPE).
    /// The rule is *at creation, not at flake* — `PointReturn` and `PointDance` cost a pass to
    /// learn it. Nothing tests this yet; the first suite that does inherits the trap.
    private static var drawn = Set<String>()
    /// The last six lines the model returned, for the live prompt's own avoid-list. BOTH
    /// guards are needed and they guard different axes: the pool guard is the only one that
    /// can work with no model; `seen` only exists once there is one. `The Aperture.html:94`.
    private static var seen: [String] = []
    private static let registers: [String] = [
        "Qalb — the heart-organ of the Sufi Lataif", "Sirr — the secret, in the Sufi Lataif",
        "Fana — dissolution, among the Sufi stations", "Baqa — abiding-after-dissolution, among the Sufi stations",
        "Sabr — patience, among the Sufi maqamat", "Tawakkul — trust, among the Sufi maqamat",
        "Coire Sois — the Celtic cauldron of wisdom at the crown", "Coire \u{00C9}rmai — the Celtic cauldron of motion at the heart",
        "Awen — the flowing inspiration of the Celtic register", "the lower dan tian of the Daoist body",
        "Wuji — the uncarved, before the taiji", "the sixth ox-herding picture — riding the ox home",
        "the tenth ox-herding picture — the marketplace with helping hands",
        "the bardo of dream, among the six Tibetan bardos", "the bardo of becoming, among the six Tibetan bardos",
        "Da\u{2019}at — the hidden sephirah that holds the others together", "Tiferet — beauty, at the center of the Tree",
        "Yesod — the foundation sephirah", "Ma\u{2019}at — the Egyptian register of truth-as-balance",
        "the Duat — the Egyptian purification passage", "Barzakh — the Sufi isthmus between registers",
        "Yemaya — the Yoruba register of the mothering sea", "Eshu — the Yoruba register of the crossroads",
        "Or\u{00ED} — the Yoruba register of personal destiny at the crown", "Sila — the Inuit register of weather-breath-consciousness",
        "the Rainbow Serpent — the Aboriginal Dreaming register", "a songline — country that must be sung to stay alive",
        "the waning crescent — the lunar register of release", "Samhain — the Celtic register of the thinned veil",
        "Imbolc — the Celtic register of first stirring", "the Norns — past, present and future at the roots of the world-tree",
        "Tara — the bodhisattva register of swift compassion", "Kshitigarbha — the bodhisattva who works in the deepest places",
        "the middle cauldron turning — sorrow converting to poetry", "Nafs — the Sufi register of the self that must be befriended",
        "the illuminative way — the second Christian contemplative register", "Rid\u{0101} — contentment, among the Sufi stations",
    ]

    var body: some View {
        ZStack {
            // the enclosure's own ground. `#phone{background:#0A0803}` — without it the
            // field's gradient is translucent and the layer beneath shows through, because
            // RootView is a ZStack of routes and nothing else paints an opaque floor here.
            Color(hex: "#0A0803").ignoresSafeArea()

            // AVARANA VIII IS AN ENCLOSURE OF THE YANTRA, so the yantra is its field — not
            // the three squares and one petal ring I sketched here first.
            //
            // `focus 8`, not 7. `The Point v9.html:876-909` builds ten enclosures and the
            // FIRST is the gate, so avarana VIII is `BAND[8] = 0.125` — index 7 is avarana
            // VII, the Dance. Counting the avaranas as if they started the array puts the
            // Aperture one enclosure too far out, which is a coordinate, so it is measured.
            // `:1026` also drops the camera to 0.40 for the last two, where these plates are
            // long and want the room beneath.
            //
            // HUE: GOLD, and DIMHUE does not overrule it. Three reasons, recorded so this
            // is not re-litigated from `:871` alone:
            //
            //   1 · `DIMHUE` lives in `The Point v9.html`, the v9 generation already ruled
            //       superseded when E3 killed `openSheet()`. It is not a live authority.
            //   2 · The Aperture is one of the seven comps, and the ladder gives each comp
            //       its own area. `The Aperture.html:7 --hue:#D4A94B` — and its thumbnail is
            //       drawn gold at `:346`, so the colour is stated twice in its own file.
            //   3 · The table self-corroborates: `['m1','m1','m2','m3','m4','m5','m6','m7',
            //       'm2','m7']` reuses index 2's hue at 8 and index 7's at 9. That is a
            //       ten-slot array PADDED from an eight-hue palette, not a choice made for
            //       the aperture. Nothing was decided at index 8; it was filled.
            PointYantraView()
                .onAppear {
                    PointYantra.shared.focus = 8
                    PointYantra.shared.camY = 0.40
                    PointYantra.shared.hue = RoomGeo.hex("#D4A94B")
                }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("AVARANA VIII · THE APERTURE · THE LOOP, OPENED")
                        .spaceMonoTracked(8, em: 0.24).foregroundStyle(faint)
                    Text("What you did not choose")
                        .font(.lora(25, weight: .medium)).tracking(-0.014 * 25)
                        .foregroundStyle(cream).padding(.top, 9)
                    Text("Every dimension behind you came from inside the loop. Open the eye: a register is drawn from traditions this library has never walked, and something arrives that you cannot predict — from the world’s old knowing, or from what is happening this very week.")
                        .font(.lora(13.5)).lineSpacing(13.5 * 0.72)
                        .foregroundStyle(dim).padding(.top, 13)
                        .fixedSize(horizontal: false, vertical: true)

                    eye.frame(maxWidth: .infinity).padding(.top, 26)

                    Text(status.uppercased())
                        .spaceMonoTracked(8, em: 0.14).foregroundStyle(faint)
                        .frame(maxWidth: .infinity, minHeight: 12).padding(.top, 16)

                    if let card { visitor(card).padding(.top, 14) }

                    if arrived && !busy {
                        Button { Task { await open() } } label: {
                            Text("LET ANOTHER ARRIVE").spaceMonoTracked(8.5, em: 0.2).foregroundStyle(hue)
                        }
                        .buttonStyle(.plain).padding(.top, 14)
                    }

                    // The key is offered, never demanded — and never in the way of the surface.
                    if !hasKey {
                        Button { withAnimation { showKeyEntry.toggle() } } label: {
                            Text(showKeyEntry ? "NEVER MIND" : "A KEY IS PRESENT")
                                .spaceMonoTracked(8.5, em: 0.2).foregroundStyle(faint)
                        }
                        .buttonStyle(.plain).padding(.top, 18)
                        if showKeyEntry { keyEntry.padding(.top, 12) }
                    }

                    if arrived {
                        Button { $path.pushDissolve(FeedRoute.instrument(9)) } label: {
                            Text("TO THE CENTRE ›").spaceMonoTracked(8.5, em: 0.2).foregroundStyle(hue)
                        }
                        .buttonStyle(.plain).padding(.top, 22)
                    }
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 30).padding(.top, 68)
            }
            .scrollIndicators(.hidden)
            // `#plate{padding:68px 30px 92px}` — from the phone's own edges.
            .ignoresSafeArea()

            if !arrived && !busy {
                VStack { Spacer()
                    Text("OPEN THE EYE").spaceMonoTracked(8.5, em: 0.26)
                        .foregroundStyle(cream.opacity(0.34)).padding(.bottom, 56)
                }
                .ignoresSafeArea()            // `.hint{bottom:56px}`
                .allowsHitTesting(false)
            }


            VStack {
                HStack {
                    Button { $path.popDissolve() } label: {
                        Text("‹ leave").spaceMonoTracked(9, em: 2 / 9)
                            .foregroundStyle(hue.opacity(0.6)).padding(16)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - the eye

    /// `point-levels.js:120-121` — two counter-facing triangles, verbatim, with the circle
    /// and the centre dot the earlier build dropped. 42s/rev, accelerating to 2.4s while it
    /// is reaching.
    private var eye: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            let period = busy ? 2.4 : 42.0
            let a = (t.truncatingRemainder(dividingBy: period)) / period * 360
            Canvas { ctx, size in
                let s = min(size.width, size.height) / 96
                var g = ctx
                g.translateBy(x: size.width / 2, y: size.height / 2)
                g.rotate(by: .degrees(a))
                g.scaleBy(x: s, y: s)
                g.translateBy(x: -48, y: -48)
                var up = Path()
                up.move(to: .init(x: 48, y: 14)); up.addLine(to: .init(x: 84, y: 76))
                up.addLine(to: .init(x: 12, y: 76)); up.closeSubpath()
                g.stroke(up, with: .color(hue.opacity(0.5)), lineWidth: 1 / s)
                var dn = Path()
                dn.move(to: .init(x: 48, y: 82)); dn.addLine(to: .init(x: 12, y: 20))
                dn.addLine(to: .init(x: 84, y: 20)); dn.closeSubpath()
                g.stroke(dn, with: .color(hue.opacity(0.22)), lineWidth: 1 / s)
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                ctx.stroke(Path(ellipseIn: CGRect(x: c.x - 34 * s, y: c.y - 34 * s, width: 68 * s, height: 68 * s)),
                           with: .color(hue.opacity(0.3)), lineWidth: 1)
                ctx.fill(Path(ellipseIn: CGRect(x: c.x - 2.4 * s, y: c.y - 2.4 * s, width: 4.8 * s, height: 4.8 * s)),
                         with: .color(Color(hex: "#FFF6E2").opacity(0.9)))
            }
        }
        .frame(width: 120, height: 120)
        .contentShape(Rectangle())
        .onTapGesture { Task { await open() } }
    }

    // MARK: - the card

    private func visitor(_ c: VisitorCard) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(c.reg.uppercased()).spaceMonoTracked(8, em: 0.16).foregroundStyle(hue)
                .padding(.bottom, 10)
            Text(c.line).font(.lora(19)).lineSpacing(19 * 0.44)
                .foregroundStyle(cream).padding(.bottom, 12)
                .fixedSize(horizontal: false, vertical: true)
            Text(c.deep).font(.lora(14.5)).lineSpacing(14.5 * 0.7)
                .foregroundStyle(dim)
                .fixedSize(horizontal: false, vertical: true)
            // the edge — where this library stops. Its own rule, above it.
            Rectangle().fill(hue.opacity(0.2)).frame(height: 0.5).padding(.top, 10)
            Text(c.edge).font(.loraItalic(14.5)).lineSpacing(14.5 * 0.7)
                .foregroundStyle(cream.opacity(0.5)).padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)
        }
        .transition(.opacity)
    }

    private var keyEntry: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("With a key the same frame fills two of its slots from outside. Without one it is already whole.")
                .font(.loraItalic(12)).foregroundStyle(faint)
                .fixedSize(horizontal: false, vertical: true)
            SecureField("anthropic api key", text: $keyInput)
                .spaceMonoTracked(12).foregroundStyle(cream)
                .textInputAutocapitalization(.never).autocorrectionDisabled()
                .padding(10).background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
            Button {
                let k = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !k.isEmpty else { return }
                KeychainService.save("anthropic_api_key", value: k)
                hasKey = true; keyInput = ""; showKeyEntry = false
            } label: {
                Text("HOLD THE KEY").spaceMonoTracked(8.5, em: 0.2).foregroundStyle(hue)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - opening

    private func drawRegister() -> String {
        if Self.drawn.count >= Self.registers.count { Self.drawn.removeAll() }
        let fresh = Self.registers.filter { !Self.drawn.contains($0) }
        let r = fresh.randomElement() ?? Self.registers[0]
        Self.drawn.insert(r)
        return r
    }

    private func open() async {
        guard !busy else { return }
        busy = true
        withAnimation(.easeInOut(duration: 0.5)) { card = nil }
        let reg = drawRegister()
        status = "drawing from the unwalked traditions…"
        if hasKey {
            await live(reg)
        } else {
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            standard(reg)
        }
        busy = false
    }

    /// The standard state. Every slot local, nothing fabricated: the register, its gloss,
    /// and then the honest part — where this library stops.
    private func standard(_ reg: String) {
        let nm = ApertureEdge.name(of: reg)
        let gl = ApertureEdge.gloss(of: reg)
        status = ""
        withAnimation(.easeInOut(duration: 1.2)) {
            card = VisitorCard(
                reg: "unwalked · drawn just now",
                // a register with no gloss is already a whole phrase — never doubled
                line: gl.map { "\(nm) — \($0)." } ?? "\(reg).",
                deep: "This library has never walked it. It is held here by name only — a door in the wall of what you chose.",
                edge: ApertureEdge.line(for: reg))
            arrived = true
        }
        PointJourney.visitors += 1        // a visitor arrived that he did not choose
        // C3 · `The Point v9.html:1286` — `Journey.visitors++; Snd.shimmer(); YANTRA.flare();`
        // Five solfeggio tones an octave up, 0.18s apart. The flare below was restored in an
        // earlier pass for exactly this reason — *"it existed and was never called"* — and the
        // sound beside it was still missing. The arrival was silent.
        soundEngine.shimmer()
        // `YANTRA.flare()` — the crossing sends one wave out through the whole figure. It
        // existed and was never called, which is the same fault as a word that is wired and
        // unreachable: the reachability half is the half that matters.
        PointYantra.shared.flare()
    }

    /// With a key: the same frame, two slots filled from outside. `The Aperture.html:259-287`.
    private func live(_ reg: String) async {
        guard let key = KeychainService.load("anthropic_api_key"), !key.isEmpty,
              let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            standard(reg); return
        }
        let avoid = "Monroe, Bashar, Matias De Stefano, Dolores Cannon, the Bhagavad Gita, generic Advaita or chakra talk, Rumi, and anything already standard in modern consciousness-synthesis circles"
        let already = Self.seen.isEmpty ? "none" : Self.seen.joined(separator: "; ")
        let prompt = """
        You are the Aperture of an instrument called The Point. From authentic human tradition \
        OUTSIDE a library spanning the well-known mystics and consciousness science, bring ONE small \
        true thing — a practice, an image, a story-fragment, a word and its real meaning — that \
        transmits this register: "\(reg)". Accurate to its tradition, specific, not generic. Speak in \
        the Arch register: name what the reader might assume, walk to the specific and true (a name, a \
        place, a word in its language), equip rather than impress, and let the deepening end as an \
        opening rather than a conclusion. Respond with ONLY a JSON object, no markdown fences, keys: \
        "line" (one compressed sentence, 8-20 words, that reorients a person caught in mental rush — \
        do not name the register), "deepening" (2-3 sentences: the thing itself, precisely, then what \
        it hands the reader), "register" ("\(reg)"). Avoid \(avoid). Avoid anything already given this \
        session: \(already). No preamble.
        """
        let body: [String: Any] = ["model": "claude-opus-5", "max_tokens": 1024,
                                   "messages": [["role": "user", "content": prompt]]]
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(key, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        guard let (data, resp) = try? await URLSession.shared.data(for: req),
              let http = resp as? HTTPURLResponse, http.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]] else {
            // the authored failure line — and then the surface is still whole
            status = "the aperture stayed closed this time — breathe once, and try again"
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            standard(reg); return
        }
        let text = content.compactMap { ($0["type"] as? String) == "text" ? $0["text"] as? String : nil }.joined()
        let cleaned = text.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "")
        guard let lo = cleaned.firstIndex(of: "{"), let hi = cleaned.lastIndex(of: "}"), lo <= hi,
              let obj = try? JSONSerialization.jsonObject(with: Data(cleaned[lo...hi].utf8)) as? [String: Any],
              let line = obj["line"] as? String, !line.isEmpty else {
            status = "the aperture stayed closed this time — breathe once, and try again"
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            standard(reg); return
        }
        status = ""
        withAnimation(.easeInOut(duration: 1.2)) {
            card = VisitorCard(
                reg: "through " + ((obj["register"] as? String) ?? reg),
                line: line,
                deep: (obj["deepening"] as? String) ?? "",
                edge: ApertureEdge.line(for: reg))   // the fourth line stays, either way
            arrived = true
        }
        Self.seen.append(line)
        if Self.seen.count > 6 { Self.seen.removeFirst() }
        PointJourney.visitors += 1
        PointYantra.shared.flare()
    }
}
