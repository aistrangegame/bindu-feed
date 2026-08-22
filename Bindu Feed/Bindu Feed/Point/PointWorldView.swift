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
    @State private var goodnight = false

    // The solfeggio ladder — one tone per dimension (285…852), the ladder rising as he descends.
    private let ladder: [Double] = [285, 396, 417, 528, 639, 741, 852]

    private var dim: PointDimension? { PointContent.dimensions.first { $0.n == dimensionN } }
    private var hue: Color { Color(hex: PointContent.hues["m\(dimensionN)"] ?? "#C0392B") }

    var body: some View {
        ZStack {
            if let star = openStar {
                PointStarDescent(star: star, hue: hue, onClose: { withAnimation { openStar = nil } })
            } else if let dim {
                // The dimension as its own distinct world (Amendment §7.3).
                PointWorld(dimensionN: dimensionN, stars: PointWorlds.placed(dim), hue: hue) { s in
                    soundEngine.riteVoice(hz: ladder[(dimensionN - 1) % 7], dur: 6)
                    PointJourney.openedStars.append(s.t)
                    withAnimation(.easeInOut(duration: 0.8)) { openStar = s }
                }
                .ignoresSafeArea()

                // The world's name + voice, quiet at the crown.
                VStack(spacing: 6) {
                    Text("\(dim.roman) · \(dim.name.uppercased())")
                        .font(.spaceMono(9)).tracking(2.5).foregroundStyle(hue)
                    Text(dim.voice)
                        .font(.loraItalic(12)).foregroundStyle(BinduTheme.inkSecondary)
                        .multilineTextAlignment(.center).lineLimit(2).padding(.horizontal, 44)
                    Spacer()
                }
                .padding(.top, 46)
                .allowsHitTesting(false)

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
                        NavigationLink { ApertureView(path: $path) } label: {
                            Text("the aperture ›").font(.spaceMono(9)).tracking(2).foregroundStyle(hue)
                        }.padding(.bottom, 64)
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
        .onAppear {
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
}

// The goodnights are said once per dimension per session, then gone.
private enum PointGoodnight { static var shown = Set<Int>() }

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
        .onTapGesture {
            if beat < 3 {
                withAnimation(.easeInOut(duration: 1.0)) { beat += 1 }
                if beat == 3 { PointJourney.descended.append(star.t) }   // walked to the OPEN — the descent
            }
        }
    }
}
