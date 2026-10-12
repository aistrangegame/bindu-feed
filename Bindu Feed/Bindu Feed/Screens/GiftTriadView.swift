import Combine
import SwiftUI

// THE REST · THE GIFT TRIAD (Codex C-1353). On a rare open, after the Door, three gifts from
// three of his instruments: one story to read (from the Feed), one energy to appreciate (from
// the Mandala — its name, its quality, its appreciation phrase; never its seed syllable), and one
// song to dance (from the Field — it opens the Dance, where it plays). Taking none is complete.
struct GiftTriadView: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    let onStory: (Story) -> Void
    let onDance: () -> Void
    let onClose: () -> Void

    @State private var story: Story?
    @State private var energy: MandalaEnergy?
    @State private var song: FieldTrack?
    @State private var appreciated = false
    @State private var shown = 0

    var body: some View {
        ZStack {
            Color(hex: "#08070B").opacity(0.97).ignoresSafeArea()
                .onTapGesture { onClose() }
            VStack(alignment: .leading, spacing: 34) {
                Text("three gifts, if you want them").spaceMonoTracked(9, em: 0.3).foregroundColor(BinduTheme.inkTertiary)
                if let s = story {
                    gift("a story to read", s.title, color: store.room(named: s.room)?.color ?? BinduTheme.colorLalita, step: 1) {
                        onStory(s)
                    }
                }
                if let e = energy {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("an energy to appreciate").spaceMonoTracked(8, em: 0.2).foregroundColor(BinduTheme.inkTertiary)
                        Text(e.name).font(.loraItalic(22)).foregroundColor(Color(hex: "#9B6BD6"))
                        Text(e.quality).font(.lora(14)).foregroundColor(BinduTheme.inkSecondary)
                        if appreciated {
                            Text(e.appreciation).font(.loraItalic(15)).foregroundColor(BinduTheme.inkPrimary).transition(.opacity)
                        } else {
                            HoldEmber(duration: 1.2, color: Color(hex: "#9B6BD6"), size: 36, label: "hold to appreciate") {
                                soundEngine.fieldThreshold(hz: 174, dur: 6)
                                withAnimation(.easeInOut(duration: 1.2)) { appreciated = true }
                            }
                        }
                    }
                    .opacity(shown >= 2 ? 1 : 0)
                }
                if let t = song {
                    gift("a song to dance", t.title, color: Color(hex: "#E8A0BF"), step: 3) { onDance() }
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 90)
        }
        .onAppear {
            story = store.stories.filter { !store.metStoryIDs.contains($0.id) }.randomElement() ?? store.stories.randomElement()
            energy = store.mandalaEnergies.randomElement()
            song = store.danceSong()
            for k in 1...3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(k) * 0.9) { withAnimation(.easeInOut(duration: 1.2)) { shown = k } }
            }
        }
    }

    private func gift(_ label: String, _ title: String, color: Color, step: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(label).spaceMonoTracked(8, em: 0.2).foregroundColor(BinduTheme.inkTertiary)
                Text(title).font(.loraItalic(20)).foregroundColor(color).multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .opacity(shown >= step ? 1 : 0)
    }
}
