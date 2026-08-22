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
    @Binding var path: NavigationPath
    let onReturn: () -> Void

    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var openStar: PointStar?

    private var dim: PointDimension? { PointContent.dimensions.first { $0.n == dimensionN } }
    private var hue: Color { Color(hex: PointContent.hues["m\(dimensionN)"] ?? "#C0392B") }

    var body: some View {
        ZStack {
            // The world material — a per-dimension colour wash (≈ the full per-world
            // materials: stay/turn/part/bear/mirror/strata/pace).
            RadialGradient(colors: [hue.opacity(0.14), .clear],
                           center: .center, startRadius: 0, endRadius: 360)
                .ignoresSafeArea().allowsHitTesting(false)

            if let star = openStar {
                PointStarDescent(star: star, hue: hue, onClose: { withAnimation { openStar = nil } })
            } else if let dim {
                world(dim)
            }
        }
    }

    private func world(_ dim: PointDimension) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(dim.roman) · \(dim.name.uppercased())")
                    .font(.spaceMono(10)).tracking(2.5).foregroundStyle(hue)
                    .padding(.top, 44)
                Text(dim.voice)
                    .font(.lora(16)).italic().lineSpacing(6).foregroundStyle(BinduTheme.inkPrimary)

                ForEach(dim.universes) { uni in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(uni.name).font(.lora(15, weight: .medium)).foregroundStyle(BinduTheme.inkSecondary)
                        Text(uni.sub).font(.loraItalic(12)).foregroundStyle(BinduTheme.inkTertiary)
                        ForEach(uni.stars, id: \.self) { key in
                            if let star = PointContent.star(key) {
                                Button {
                                    soundEngine.riteVoice(hz: 285 + Double(dimensionN) * 40, dur: 6)
                                    withAnimation(.easeInOut(duration: 0.8)) { openStar = star }
                                } label: {
                                    HStack(spacing: 12) {
                                        Circle().fill(hue.opacity(star.st == "w" ? 0.9 : star.st == "p" ? 0.5 : 0.28))
                                            .frame(width: 7, height: 7)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(star.t).font(.lora(15)).foregroundStyle(BinduTheme.inkPrimary)
                                            Text(star.ti).font(.loraItalic(11.5)).foregroundStyle(BinduTheme.inkTertiary)
                                        }
                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top, 6)
                }

                if dimensionN == 6 {
                    // World VI earns its door into the Return.
                    Button(action: onReturn) {
                        Text("open the return ›").font(.spaceMono(10)).tracking(2)
                            .foregroundStyle(hue).padding(.top, 12)
                    }
                }
                if dimensionN == 7 {
                    // The Dance opens onto the Aperture, then the centre.
                    NavigationLink { ApertureView(path: $path) } label: {
                        Text("the aperture ›").font(.spaceMono(10)).tracking(2)
                            .foregroundStyle(hue).padding(.top, 12)
                    }
                }
                Color.clear.frame(height: 60)
            }
            .padding(.horizontal, 32)
        }
        .scrollIndicators(.hidden)
    }
}

// The star descent — SAY → WALK → HAND → OPEN, one beat per touch. Verbatim canon.
private struct PointStarDescent: View {
    let star: PointStar
    let hue: Color
    let onClose: () -> Void
    @State private var beat = 0   // 0 say · 1 walk · 2 hand · 3 open

    private let labels = ["THE RUSH SAYS", "WALK TO WHAT IS TRUE", "WHAT THIS HANDS YOU", "THE INVITATION"]
    private var texts: [String] { [star.say, star.walk, star.hand, star.open] }

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
                Color.clear.frame(height: 60)
            }
            .padding(.horizontal, 32).padding(.top, 20)
        }
        .scrollIndicators(.hidden)
        .contentShape(Rectangle())
        .onTapGesture { if beat < 3 { withAnimation(.easeInOut(duration: 1.0)) { beat += 1 } } }
    }
}
