import SwiftUI

// The mark on Home Feed's top-right — tap to enter Ash's Voice. It IS the user's
// arrival identity: it shows the glyph and colour chosen in Settings ("HOW YOU ARRIVE"),
// and updates the moment you change them (it used to hardcode ◉/terra and never reflect
// the choice at all — which is why the top-right never changed after Settings).
struct AshMark: View {
    let onTap: () -> Void
    @State private var settings = ArrivalSettings.load()

    private var color: Color { Color(hex: settings.colorHex) }
    private var glyph: String { settings.glyph.isEmpty ? "◉" : settings.glyph }

    var body: some View {
        Button(action: onTap) {
            Text(glyph)
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.88))
                .frame(width: 36, height: 36)
                .background(Circle().fill(color))
                .shadow(color: color.opacity(0.4), radius: 8)
        }
        .buttonStyle(.plain)
        .onAppear { settings = ArrivalSettings.load() }
        .onReceive(NotificationCenter.default.publisher(for: .arrivalSettingsChanged)) { _ in
            settings = ArrivalSettings.load()
        }
    }
}

extension Notification.Name {
    static let arrivalSettingsChanged = Notification.Name("bindu.arrival.changed")
}
