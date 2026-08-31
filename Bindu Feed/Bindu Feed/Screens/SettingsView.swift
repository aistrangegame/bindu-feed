import SwiftUI

// PHASE 6 — Settings ("HOW YOU ARRIVE").
// Personal to the device. Stored in UserDefaults, not Airtable.
// Live preview at the top updates as the user picks a glyph, color, name.
struct SettingsView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @Binding var path: [FeedRoute]

    @State private var name: String = ""
    @State private var glyph: String = ""
    @State private var colorHex: String = ""
    @State private var savedSnapshot: ArrivalSettings = .init()
    @State private var justSaved = false
    @State private var showHub = false
    @State private var showClearConfirm = false

    @FocusState private var nameFocused: Bool

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            RadialGradient(
                colors: [selectedColor.opacity(0.18), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: BinduTheme.space24) {
                    label
                        .padding(.top, BinduTheme.space20)

                    livePreview

                    nameField

                    moodPicker            // color first, then the mark (comp order)

                    glyphPicker

                    // F10.2 · `Claude Design Round 1/Settings.html:541-559` — **three mutually exclusive
                    // states, and the app had two.** The order matters: `saved_` wins over
                    // `changed`, so the confirmation is not immediately replaced by the pill
                    // that produced it.
                    if justSaved {
                        Text("Saved. You\u{2019}ve arrived.")
                            .font(.loraItalic(14))
                            .foregroundColor(selectedColor.opacity(0.8))
                            .transition(.opacity)
                    } else if hasChanges {
                        saveButton
                    } else {
                        // **THE THIRD STATE, WHICH WAS NOTHING AT ALL.** `:557` — a quiet
                        // `NO CHANGES` in mono 9 at ink35. An empty space says the same thing
                        // as a screen that is still loading, or one whose button has failed to
                        // appear; the line says *there is nothing here to save, and that is
                        // the correct state*. It is also what keeps the layout from jumping
                        // by the height of a pill every time he saves.
                        Text("NO CHANGES")
                            .spaceMonoTracked(9, em: 0.1)
                            .foregroundColor(BinduTheme.inkTertiary)
                            .transition(.opacity)
                    }

                    soundToggle

                    voiceLink

                    changeTokenLink

                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, BinduTheme.space20)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .floatingBackHub(path: $path, showHub: $showHub)
        .onAppear(perform: loadSavedSettings)
        .sonicContext(.base)
        .hubOverlay(open: $showHub, path: $path)
    }

    // MARK: - Label

    private var label: some View {
        VStack(spacing: 6) {
            Text("HOW YOU ARRIVE")
                .spaceMonoTracked(11)
                .tracking(1.54)
                .foregroundColor(BinduTheme.inkSecondary)
            Text("Personal to this device.")
                .font(.loraItalic(12))
                .foregroundColor(BinduTheme.inkTertiary)
        }
    }

    // MARK: - Live preview

    private var livePreview: some View {
        VStack(spacing: BinduTheme.space12) {
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.30))
                    .blur(radius: 22)
                    .frame(width: 150, height: 150)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.15), selectedColor],
                            center: .center,
                            startRadius: 4,
                            endRadius: 56
                        )
                    )
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle().strokeBorder(selectedColor.opacity(0.55), lineWidth: 0.6)
                    )
                Text(glyph.isEmpty ? "·" : glyph)
                    .font(.system(size: 40))
                    .foregroundColor(BinduTheme.inkPrimary)
            }
            .frame(width: 150, height: 150)

            // F10.3 · **THE FALLBACK IS HIS NAME, NOT A PLACEHOLDER.** §7: *"The display-name
            // fallback specifically is `\"Ash\"` — the canonical identity, because the struct's
            // default name is empty by intent."* The design agrees — `Claude Design Round 1/Settings.html:448` is
            // `{name || 'Ash'}`. This said `"Unnamed"`, and it was the ONE site of four that
            // did: `AshComposeView:59`, `AshVoiceView:34` and `StoryDetailView:325` all say
            // "Ash". The odd one out was the screen where he sets the name — so the app told
            // him he was Unnamed in the only place he would look.
            Text(ArrivalSettings(name: name).displayName)
                .font(.lora(20, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)

            Text(selectedMoodQuality)
                .spaceMonoTracked(10, em: 0.08)
                .textCase(nil)                       // a spoken phrase, not chrome
                .foregroundColor(selectedColor.opacity(0.75))
        }
        .padding(.vertical, BinduTheme.space12)
    }

    // MARK: - Name

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("YOUR NAME")
            TextField(
                "",
                text: $name,
                // F10.3 · `:471` — **the design ASKS.** *"What do you call yourself?"* against
                // the app's *"the name you arrive with"*: one is a question put to him, the
                // other is the app describing its own field. The whole screen is the one place
                // he says who he is, and the difference is who is speaking.
                prompt: Text("What do you call yourself?").foregroundColor(BinduTheme.inkTertiary)
            )
            .focused($nameFocused)
            .font(.lora(17))
            .foregroundColor(BinduTheme.inkPrimary)
            .tint(selectedColor)
            .padding(.horizontal, BinduTheme.space16)
            .padding(.vertical, BinduTheme.space12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BinduTheme.bgInset)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
            )
            .submitLabel(.done)
            // `:472` — `maxLength={32}`, never enforced here. A name is a line, not a field to
            // fill; without the cap the preview above wraps and the arrival card it feeds
            // silently truncates somewhere else instead.
            .onChange(of: name) { _, v in
                if v.count > 32 { name = String(v.prefix(32)) }
            }
            .onSubmit {
                nameFocused = false
                saveSettings()
            }
        }
    }

    // MARK: - Glyph picker

    // The mark — a wrap-grid of 52pt rounded-square tiles (comp Settings.html "Your mark").
    private var glyphPicker: some View {
        let cols = [GridItem(.adaptive(minimum: 52, maximum: 52), spacing: 8, alignment: .leading)]
        return VStack(alignment: .leading, spacing: 14) {
            sectionLabel("YOUR MARK")
            LazyVGrid(columns: cols, alignment: .leading, spacing: 8) {
                ForEach(Self.glyphOptions, id: \.self) { g in
                    let active = glyph == g
                    Button { glyph = g } label: {
                        Text(g)
                            .font(.system(size: 24))
                            .foregroundColor(active ? selectedColor : BinduTheme.inkTertiary)
                            .frame(width: 52, height: 52)
                            .background(RoundedRectangle(cornerRadius: 14)
                                .fill(active ? selectedColor.opacity(0.09) : Color.white.opacity(0.04)))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(active ? selectedColor.opacity(0.45) : BinduTheme.hairline, lineWidth: active ? 1 : 0.5))
                            .shadow(color: active ? selectedColor.opacity(0.25) : .clear, radius: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Mood / color picker

    // Your color today — a 2-column grid of mood CARDS: swatch + name + quality phrase
    // (comp Settings.html "Your color today"), not a strip of bare circles.
    private var moodPicker: some View {
        let cols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        return VStack(alignment: .leading, spacing: 14) {
            sectionLabel("YOUR COLOR TODAY")
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(Self.moods, id: \.hex) { mood in
                    let active = colorHex == mood.hex
                    let mc = Color(hex: mood.hex)
                    Button { colorHex = mood.hex } label: {
                        HStack(spacing: 12) {
                            Circle().fill(mc).frame(width: 28, height: 28)
                                .shadow(color: active ? mc.opacity(0.6) : .clear, radius: 8)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mood.name)
                                    .font(.lora(13, weight: .medium))
                                    .foregroundColor(active ? mc : BinduTheme.inkSecondary)
                                Text(mood.quality)
                                    .spaceMonoTracked(9, em: 0.3 / 9)
                                    .foregroundColor(BinduTheme.inkTertiary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14)
                            .fill(active ? mc.opacity(0.078) : Color.white.opacity(0.04)))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(active ? mc.opacity(0.25) : BinduTheme.hairline, lineWidth: active ? 1 : 0.5))
                        .shadow(color: active ? mc.opacity(0.10) : .clear, radius: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Save button

    /// F10.2 · `:546-554` — **a quiet `Save` in Lora 15, not a shouted instruction.**
    ///
    /// The app said `SAVE THE ARRIVAL` in tracked mono at 2.4 — a chrome label in the
    /// imperative, telling him what the screen is for. The design says one Lora word in his
    /// own chosen colour: the same act, offered rather than demanded. Everything else about
    /// the pill is the design's own — `bg ${color}18`, `border ${color}40`, r100, 11/32, and
    /// a `0 0 18px ${color}20` glow that the app had dropped, which is what makes it read as
    /// lit from within rather than outlined.
    private var saveButton: some View {
        Button {
            saveSettings()
        } label: {
            Text("Save")
                .font(.lora(15)).tracking(0.02 * 15)
                .foregroundColor(selectedColor)
                .padding(.horizontal, 32)
                .padding(.vertical, 11)
                .background(
                    Capsule().fill(selectedColor.opacity(0.094))      // `${color}18`
                )
                .overlay(
                    Capsule().strokeBorder(selectedColor.opacity(0.25), lineWidth: 1)   // `${color}40`
                )
                .shadow(color: selectedColor.opacity(0.125), radius: 9)                  // `0 0 18px ${color}20`
        }
        .buttonStyle(.plain)
        .transition(.opacity)
    }

    // MARK: - Change token

    private var changeTokenLink: some View {
        VStack(alignment: .leading, spacing: 6) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)
                .padding(.vertical, 4)

            Button {
                showClearConfirm = true
            } label: {
                HStack(spacing: 8) {
                    Text("CHANGE TOKEN")
                        .spaceMonoTracked(11)
                        .tracking(2.4)
                        .foregroundColor(BinduTheme.inkSecondary)
                    Spacer()
                }
                .padding(BinduTheme.space16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BinduTheme.bgInset)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            Text("if Airtable issued you a new one")
                .font(.loraItalic(11))
                .foregroundColor(BinduTheme.inkTertiary)
                .padding(.horizontal, BinduTheme.space16)
                .padding(.top, 2)
        }
        .alert("Change the token?", isPresented: $showClearConfirm) {
            Button("Keep", role: .cancel) {}
            Button("Clear", role: .destructive) {
                store.clearToken()
            }
        } message: {
            Text("You'll return to the token entry screen. Your name, glyph, and color stay.")
        }
    }

    // MARK: - Sound · B2

    /// THE ONE PLACE THE FIELD CAN BE ASKED TO STOP.
    ///
    /// `field-sound.js:89,327` — `setMuted` / `setOn`. There was no mute anywhere in the
    /// app: no engine call, no control, nothing in Settings. A continuous bed that starts
    /// on launch and cannot be turned off is a shipping defect independent of every other
    /// thing in the sound layer.
    ///
    /// The control is the design's own, verbatim: `The Point v9.html:1019` toggles a mono
    /// button between `⊙ sound` and `◉ sound`. Nothing is invented here — not the glyphs,
    /// not the word, not the case.
    private var soundToggle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)
                .padding(.vertical, 4)

            Button {
                soundEngine.setOn(soundEngine.isMuted)
            } label: {
                HStack(spacing: 8) {
                    Text(soundEngine.isMuted ? "\u{2299} sound" : "\u{25C9} sound")
                        .spaceMonoTracked(11)
                        .tracking(2.4)
                        .foregroundColor(soundEngine.isMuted
                                         ? BinduTheme.inkTertiary : BinduTheme.inkSecondary)
                    Spacer()
                }
                .padding(BinduTheme.space16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BinduTheme.bgInset)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Voice link

    private var voiceLink: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)
                .padding(.vertical, 4)

            Button {
                $path.pushDissolve(FeedRoute.ash)
            } label: {
                HStack(spacing: 8) {
                    Text("◉")
                        .font(.system(size: 14))
                        .foregroundColor(BinduTheme.colorAsh)
                    Text("Your voice")
                        .font(.lora(15))
                        .foregroundColor(BinduTheme.inkPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                .padding(BinduTheme.space16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BinduTheme.bgInset)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .spaceMonoTracked(9)
            .tracking(0.9)
            .foregroundColor(BinduTheme.inkSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var selectedColor: Color {
        colorHex.isEmpty ? BinduTheme.accent : Color(hex: colorHex)
    }

    /// F10.1 · **THE PREVIEW SHOWS WHAT THE COLOUR MEANS, NOT WHAT IT IS CALLED.**
    /// `Claude Design Round 1/Settings.html:452` renders `currentMood.quality` — *"grounded, present"* — under
    /// the name, in the chosen colour at 0.75 and **not uppercased**.
    ///
    /// This returned `match.name.uppercased()`, so the preview read `TERRA`: the label of the
    /// swatch he just tapped, repeated back at him. The quality phrase is the only line on
    /// that card that says anything about HIM — it is the difference between a colour picker
    /// confirming a selection and a page telling him how he is arriving today. The phrases
    /// were already here, verbatim from the comp, and read by the picker two hundred lines
    /// down while the preview showed the name instead.
    ///
    /// **AND IT IS NOT UPPERCASED.** Every mono label on this screen is, by the class rule —
    /// but this one is a spoken phrase rather than chrome, and `.uppercase` would make
    /// *grounded, present* into a category heading. The design leaves the case alone; so does
    /// this, with `.textCase(nil)` saying so out loud rather than by omission.
    private var selectedMoodQuality: String {
        Self.moods.first { $0.hex == colorHex }?.quality ?? "arriving"
    }

    private var hasChanges: Bool {
        name != savedSnapshot.name
            || glyph != savedSnapshot.glyph
            || colorHex != savedSnapshot.colorHex
    }

    // MARK: - Persistence

    private func loadSavedSettings() {
        let s = ArrivalSettings.load()
        savedSnapshot = s
        name = s.name
        glyph = s.glyph
        colorHex = s.colorHex
    }

    private func saveSettings() {
        // Dismiss focus first so the TextField commits any in-flight character
        // before we read `name` — on device, tapping the button while the
        // keyboard is up can otherwise drop the last keystroke.
        nameFocused = false
        let s = ArrivalSettings(name: name, glyph: glyph, colorHex: colorHex)
        s.save()
        withAnimation(.easeInOut(duration: 0.5)) { savedSnapshot = s; justSaved = true }
        // `Claude Design Round 1/Settings.html:419` — `setTimeout(() => setSaved_(false), 2000)`. The app held it 2.4s, which is not a rounding of
        // 2.0 but a fifth longer: long enough that the confirmation is still on screen after
        // he has looked away and back, which is what turns *saved* into *stuck*.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.8)) { justSaved = false }
        }
    }

    // MARK: - Options

    // The eight marks, verbatim from the comp (Settings.html GLYPHS).
    static let glyphOptions: [String] = ["◉", "◈", "◆", "△", "✦", "⊕", "◎", "∞"]

    struct Mood {
        let hex: String
        let name: String
        let quality: String
    }

    // The eight moods with their quality phrases, verbatim from the comp (Settings.html MOODS).
    static let moods: [Mood] = [
        Mood(hex: "#C47A52", name: "Terra", quality: "grounded, present"),
        Mood(hex: "#E5A352", name: "Ember", quality: "warm, seeking"),
        Mood(hex: "#7B82D4", name: "Clear", quality: "witness, open"),
        Mood(hex: "#4A9E6B", name: "Deep",  quality: "rooted, growing"),
        Mood(hex: "#D4607A", name: "Open",  quality: "expressive, alive"),
        Mood(hex: "#9B6BD6", name: "Play",  quality: "awake, aware"),
        Mood(hex: "#C4923A", name: "Held",  quality: "solid, warm"),
        Mood(hex: "#3AADA8", name: "Flow",  quality: "connected, synthesis"),
    ]
}

// MARK: - Persistence model

struct ArrivalSettings: Codable, Equatable {
    var name: String = ""
    var glyph: String = "·"
    var colorHex: String = "#9B6BD6"  // Lalita violet default

    /// **THE ONE PLACE THE DISPLAY-NAME FALLBACK LIVES.** §7: *"The display-name fallback
    /// specifically is `"Ash"` — the canonical identity, because the struct's default name is
    /// empty by intent."* The design agrees at `Claude Design Round 1/Settings.html:448` — `{name || 'Ash'}`.
    ///
    /// **IT WAS WRITTEN AS A LITERAL IN FOUR PLACES AND ONE OF THEM DRIFTED** to `"Unnamed"`.
    /// Same shape as the axis bounds (`Axis.clampZ`): a documented contract duplicated until
    /// one copy disagrees — and no checker sees it, because every copy is valid Swift and the
    /// odd one out is a plausible word. **The drift landed on `SettingsView`, and that is not
    /// bad luck:** the other three read a persisted `ArrivalSettings`, and this one reads the
    /// `@State` field being edited, so it was the only site not already holding the shared
    /// value — and it is the screen where he types his name, so the app called him *Unnamed*
    /// in the one place he would look.
    var displayName: String { name.isEmpty ? "Ash" : name }

    static let defaultsKey = "bindu.arrival.settings"

    static func load() -> ArrivalSettings {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(ArrivalSettings.self, from: data)
        else {
            return ArrivalSettings()
        }
        return decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: ArrivalSettings.defaultsKey)
        // Tell the live surfaces (the feed's AshMark, etc.) to re-read immediately.
        NotificationCenter.default.post(name: .arrivalSettingsChanged, object: nil)
    }
}
