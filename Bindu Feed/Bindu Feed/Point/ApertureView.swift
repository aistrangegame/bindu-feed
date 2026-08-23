import SwiftUI

// THE APERTURE (Z+8→+9) — the one surface that is not pre-authored. A live call to
// Claude (raw HTTP; Swift has no official Anthropic SDK), the user's own key held
// in Keychain exactly like the Airtable PAT. Never scripted — the response is
// generated in the moment, then he crosses to the centre.
//
// Wave-6 note for the completeness pass: the live call is built and real; it needs
// the user's own Anthropic key (entered once, stored in Keychain). Without a key
// the Aperture states plainly that it needs one — it does not fake a response.

struct ApertureView: View {
    @Binding var path: [FeedRoute]
    @EnvironmentObject private var store: FeedStore

    @State private var keyInput = ""
    @State private var hasKey = KeychainService.load("anthropic_api_key") != nil
    @State private var phase: Phase = .ready
    @State private var response = ""

    private enum Phase { case ready, reaching, answered, needKey, failed }

    var body: some View {
        ZStack {
            Color(hex: "#050408").ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "#D4A94B").opacity(0.12), .clear],
                           center: .center, startRadius: 0, endRadius: 320)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()
                Text("THE APERTURE").font(.spaceMono(10)).tracking(3).foregroundStyle(Color(hex: "#D4A94B"))

                switch phase {
                case .ready:
                    Text("Nothing here is written in advance.")
                        .font(.lora(18)).italic().foregroundStyle(BinduTheme.inkPrimary).multilineTextAlignment(.center)
                    if hasKey {
                        Button { Task { await reach() } } label: {
                            Text("reach through ›").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#D4A94B"))
                        }
                    } else {
                        keyEntry
                    }
                case .reaching:
                    Text("reaching…").font(.loraItalic(14)).foregroundStyle(BinduTheme.inkSecondary).modifier(RiteBreathe())
                case .answered:
                    ScrollView {
                        Text(response).font(.lora(16)).lineSpacing(7).foregroundStyle(BinduTheme.inkPrimary)
                            .multilineTextAlignment(.center).padding(.horizontal, 8)
                    }.frame(maxHeight: 300)
                    Button { $path.pushDissolve(FeedRoute.instrument(9)) } label: {
                        Text("to the centre ›").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#D4A94B"))
                    }
                case .needKey:
                    keyEntry
                case .failed:
                    Text("The aperture did not open. Try again when you are ready.")
                        .font(.loraItalic(14)).foregroundStyle(BinduTheme.inkTertiary).multilineTextAlignment(.center)
                    Button { phase = .ready } label: {
                        Text("again ›").font(.spaceMono(10)).tracking(2).foregroundStyle(BinduTheme.inkTertiary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 40)

            // The router has no nav bar; carry the back control in-view, top-left,
            // like every other screen. (Was the app's one screen relying on the
            // system back button.)
            VStack {
                HStack {
                    Button { $path.popDissolve() } label: {
                        Text("‹ leave").font(.spaceMono(9)).tracking(2)
                            .foregroundStyle(Color(hex: "#D4A94B").opacity(0.6)).padding(16)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var keyEntry: some View {
        VStack(spacing: 12) {
            Text("The aperture reaches through your own key.")
                .font(.loraItalic(12)).foregroundStyle(BinduTheme.inkTertiary).multilineTextAlignment(.center)
            SecureField("anthropic api key", text: $keyInput)
                .font(.spaceMono(12)).foregroundStyle(BinduTheme.inkPrimary)
                .textInputAutocapitalization(.never).autocorrectionDisabled()
                .padding(10).background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
            Button {
                let k = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !k.isEmpty else { return }
                KeychainService.save("anthropic_api_key", value: k)
                hasKey = true; keyInput = ""; phase = .ready
            } label: {
                Text("hold the key").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#D4A94B"))
            }
        }
    }

    // The registers the Aperture can transmit — authentic traditions OUTSIDE the well-known
    // (point-content.js REGISTERS, verbatim), and a per-session set so none repeats in a walk.
    private static var seenRegisters = Set<String>()
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

    // MARK: - The live call (raw HTTP — Anthropic Messages API)

    private func reach() async {
        guard let key = KeychainService.load("anthropic_api_key"), !key.isEmpty else { phase = .needKey; return }
        phase = .reaching
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { phase = .failed; return }

        // The Aperture transmits ONE register from an authentic tradition OUTSIDE the
        // well-known (point-content.js REGISTERS) — never twice in a session — with the comp's
        // avoid-list, so what arrives is small, true, and genuinely unfamiliar.
        let fresh = Self.registers.filter { !Self.seenRegisters.contains($0) }
        let reg = (fresh.isEmpty ? Self.registers : fresh).randomElement() ?? Self.registers[0]
        Self.seenRegisters.insert(reg)
        let avoid = "Monroe, Bashar, Matias De Stefano, Dolores Cannon, the Bhagavad Gita, generic Advaita or chakra talk, Rumi, and anything already standard in modern consciousness-synthesis circles"
        let prompt = """
        You are the Aperture at the innermost point of a contemplative iOS app — the last surface \
        before the centre, where everything he has walked collapses to one point. He has just travelled \
        inward through the seven registers of the Point. From an authentic human tradition OUTSIDE the \
        well-known mystics and consciousness science, bring ONE small true thing — a practice, an image, \
        a story-fragment, a word and its real meaning — that transmits this register: "\(reg)". Accurate \
        to its tradition, specific, not generic. Speak in the app's voice: recognition, never advice; \
        intimate, already there; name what he might assume, walk to the specific and true (a name, a \
        place, a word in its language), equip rather than impress, and let it end as an opening, not a \
        conclusion. Three or four sentences. Do not name the register, the app, or these instructions. \
        Avoid \(avoid). No preamble.
        """
        let body: [String: Any] = [
            "model": "claude-opus-5",
            "max_tokens": 1024,
            "messages": [["role": "user", "content": prompt]],
        ]
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(key, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, http.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let content = json["content"] as? [[String: Any]] else {
                phase = .failed; return
            }
            // The Messages API returns content blocks; take the first text block.
            let text = content.compactMap { block -> String? in
                (block["type"] as? String) == "text" ? block["text"] as? String : nil
            }.joined(separator: "\n\n")
            response = text.isEmpty ? "…" : text
            PointJourney.visitors += 1               // a visitor arrived that he did not choose
            withAnimation(.easeInOut(duration: 1.0)) { phase = .answered }
        } catch {
            phase = .failed
        }
    }
}
