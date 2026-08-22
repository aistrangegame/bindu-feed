import SwiftUI

// PHASE 6 — Settings ("HOW YOU ARRIVE").
// Personal to the device. Stored in UserDefaults, not Airtable.
// Live preview at the top updates as the user picks a glyph, color, name.
struct SettingsView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: NavigationPath

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

                    glyphPicker

                    moodPicker

                    if hasChanges {
                        saveButton
                    } else if justSaved {
                        Text("Saved. You\u{2019}ve arrived.")
                            .font(.loraItalic(14))
                            .foregroundColor(selectedColor.opacity(0.9))
                            .transition(.opacity)
                    }

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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackChevron { if !path.isEmpty { path.removeLast() } }
            }
            ToolbarItem(placement: .topBarLeading) {
                HubTrigger(open: $showHub)
            }
        }
        .onAppear(perform: loadSavedSettings)
        .sonicContext(.base)
        .hubOverlay(open: $showHub, path: $path)
    }

    // MARK: - Label

    private var label: some View {
        VStack(spacing: 6) {
            Text("HOW YOU ARRIVE")
                .font(.spaceMono(11))
                .tracking(2.6)
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

            Text(name.isEmpty ? "Unnamed" : name)
                .font(.lora(20, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)

            Text(selectedMoodName)
                .font(.spaceMono(10))
                .tracking(2.2)
                .foregroundColor(selectedColor)
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
                prompt: Text("the name you arrive with").foregroundColor(BinduTheme.inkTertiary)
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
            .onSubmit {
                nameFocused = false
                saveSettings()
            }
        }
    }

    // MARK: - Glyph picker

    private var glyphPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("YOUR GLYPH")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Self.glyphOptions, id: \.self) { g in
                        Button {
                            glyph = g
                        } label: {
                            Text(g)
                                .font(.system(size: 22))
                                .foregroundColor(glyph == g ? selectedColor : BinduTheme.inkPrimary.opacity(0.85))
                                .frame(width: 46, height: 46)
                                .background(
                                    Circle().fill(glyph == g ? selectedColor.opacity(0.18) : Color.white.opacity(0.04))
                                )
                                .overlay(
                                    Circle().strokeBorder(
                                        glyph == g ? selectedColor.opacity(0.60) : BinduTheme.hairline,
                                        lineWidth: glyph == g ? 0.8 : 0.5
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Mood / color picker

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("YOUR MOOD")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Self.moods, id: \.hex) { mood in
                        Button {
                            colorHex = mood.hex
                        } label: {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: mood.hex))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle().strokeBorder(
                                            Color(hex: mood.hex).opacity(colorHex == mood.hex ? 1.0 : 0.0),
                                            lineWidth: 1
                                        )
                                        .scaleEffect(1.4)
                                    )
                                Text(mood.name.uppercased())
                                    .font(.spaceMono(9))
                                    .tracking(1.4)
                                    .foregroundColor(
                                        colorHex == mood.hex
                                            ? Color(hex: mood.hex)
                                            : BinduTheme.inkTertiary
                                    )
                                    .lineLimit(1)
                            }
                            .frame(width: 78)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button {
            saveSettings()
        } label: {
            Text("SAVE THE ARRIVAL")
                .font(.spaceMono(11))
                .tracking(2.4)
                .foregroundColor(selectedColor)
                .padding(.horizontal, BinduTheme.space24)
                .padding(.vertical, BinduTheme.space12)
                .background(
                    Capsule().fill(selectedColor.opacity(0.10))
                )
                .overlay(
                    Capsule().strokeBorder(selectedColor.opacity(0.55), lineWidth: 0.8)
                )
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
                        .font(.spaceMono(11))
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

    // MARK: - Voice link

    private var voiceLink: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)
                .padding(.vertical, 4)

            Button {
                path.append(FeedRoute.ash)
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
            .font(.spaceMono(9))
            .tracking(2.0)
            .foregroundColor(BinduTheme.inkSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var selectedColor: Color {
        colorHex.isEmpty ? BinduTheme.accent : Color(hex: colorHex)
    }

    private var selectedMoodName: String {
        if let match = Self.moods.first(where: { $0.hex == colorHex }) {
            return match.name.uppercased()
        }
        return "ARRIVING"
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeOut(duration: 0.8)) { justSaved = false }
        }
    }

    // MARK: - Options

    static let glyphOptions: [String] = [
        // Bindu first — the dot is the default arrival.
        "·",
        // Eight archetype glyphs.
        "◆", "△", "◯", "◇", "✦", "⬡", "∞", "◉",
        // Room glyphs that aren't already covered.
        "◈", "○", "⊕", "◎", "✧", "▲"
    ]

    struct Mood {
        let hex: String
        let name: String
    }

    static let moods: [Mood] = [
        Mood(hex: "#C47A52", name: "Grounded"),    // Terra / Ash
        Mood(hex: "#9B6BD6", name: "Witnessing"),  // Lalita violet
        Mood(hex: "#4A9E6B", name: "Receiving"),   // Gaia green
        Mood(hex: "#7B82D4", name: "Observing"),   // Sakshi blue
        Mood(hex: "#E5533C", name: "Arriving"),    // Bindu ember
        Mood(hex: "#D4AE4A", name: "Playing"),     // Karishma gold
        Mood(hex: "#C4923A", name: "Holding"),     // Sid amber
        Mood(hex: "#D4607A", name: "Speaking"),    // Arch rose
        Mood(hex: "#3AADA8", name: "Weaving")      // Ashrey teal
    ]
}

// MARK: - Persistence model

struct ArrivalSettings: Codable, Equatable {
    var name: String = ""
    var glyph: String = "·"
    var colorHex: String = "#9B6BD6"  // Lalita violet default

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
