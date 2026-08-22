import SwiftUI

// The "WHERE TO" overlay — a dim/blurred sheet revealing four calm rows
// that route to the app's top-level destinations. Tap a row to go; tap
// anywhere else to dismiss.
struct HubOverlay: View {
    @Binding var presented: Bool
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            // Backdrop: dim near-black + blur. Tap to dismiss.
            Color(red: 0.031, green: 0.027, blue: 0.047)
                .opacity(0.86)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                Spacer()

                Text("WHERE TO")
                    .font(.spaceMono(10))
                    .tracking(2.6)
                    .foregroundColor(BinduTheme.inkTertiary)
                    .padding(.bottom, BinduTheme.space24)

                VStack(spacing: 11) {
                    row(color: BinduTheme.colorBindu,
                        name: "The Rite",
                        descriptor: "one story has come to meet you") { go(to: .rite) }

                    row(color: BinduTheme.colorLalita,
                        name: "The Rooms",
                        descriptor: "thirteen ways in") { go(to: .rooms) }

                    row(color: BinduTheme.colorSakshi,
                        name: "The Players",
                        descriptor: "the lenses that read") { go(to: .players) }

                    row(color: Color(hex: "#C9A07A"),
                        name: "The Practice Door",
                        descriptor: "cross the threshold") { go(to: .practiceDoor) }

                    row(color: Color(hex: "#ABA7A2"),
                        name: "How You Arrive",
                        descriptor: "name, colour, mark") { go(to: .settings) }
                }
                .padding(.horizontal, BinduTheme.space24)

                Spacer()

                Text("TAP ANYWHERE TO STAY")
                    .font(.spaceMono(9))
                    .tracking(1.8)
                    .foregroundColor(BinduTheme.inkTertiary)
                    .padding(.bottom, BinduTheme.space24 + 16)
            }
        }
    }

    private func row(
        color: Color,
        name: String,
        descriptor: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .shadow(color: color.opacity(0.6), radius: 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.lora(16))
                        .foregroundColor(BinduTheme.inkPrimary)
                    Text(descriptor)
                        .font(.loraItalic(12.5))
                        .foregroundColor(BinduTheme.inkSecondary)
                }

                Spacer(minLength: 8)

                Text("›")
                    .font(.system(size: 18))
                    .foregroundColor(color.opacity(0.7))
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: "#171420").opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(color.opacity(0.22), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            presented = false
        }
    }

    // Dismiss first, then push after a tick so the overlay fade-out
    // begins cleanly before the nav transition starts.
    private func go(to route: FeedRoute) {
        withAnimation(.easeInOut(duration: 0.3)) {
            presented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            path.append(route)
        }
    }
}

// Attach to any screen that should expose the hub overlay layer. Pairs
// with HubTrigger placed somewhere in the screen's chrome.
extension View {
    func hubOverlay(open: Binding<Bool>, path: Binding<NavigationPath>) -> some View {
        overlay {
            if open.wrappedValue {
                HubOverlay(presented: open, path: path)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: open.wrappedValue)
    }
}
