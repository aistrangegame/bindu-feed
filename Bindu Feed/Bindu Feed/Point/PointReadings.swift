import SwiftUI
import Combine

// SEVEN WAYS OF READING ONE STAR.
//
// The audit's own sentence for this pass: *the app has seven ways of PICKING a star where
// the design has seven ways of READING one.* Both were true. `PointWorlds` gives each
// dimension its own material and its own way of choosing — and then every one of them
// handed the star to the same scrolling sheet, which is `point-levels.js:161 openSheet()`,
// the v9 generic reading. E3 rules that sheet superseded: no generic reading ships, not
// anywhere, not as a fallback.
//
// (Keep the distinction sharp: the FIVE-FIELD DESCENT FALLBACK at `point-levels.js:210-211`
// is a different object — verbatim-ported, correct, and it stays. It is level 3, shared by
// all seven worlds in the design too. What dies is level 2's shared sheet.)
//
// So the four sections arrive by each world's own hand:
//
//   I   THE POINT     stillness   rest near one and STAY; it surfaces out of the white
//   II  THE TURN      following   take the ray and travel out — SAY at the origin, OPEN at the rim
//   III THE VEIL      parting     read THROUGH a parting you are holding; each section leaves it thinner
//   IV  THE CHAMBER   pressing    press, and the strike deepens — below 0.12, no impression at all
//   V   THE MIRRORS   turning     turn the glass; half arrives mirror-written from the far side
//   VI  THE RETURN    sending     send it out and wait; it turns at the far point and comes back carrying one
//   VII THE DANCE     company     keep pace, or it scatters
//
// The section labels are `openSheet`'s own, which were never the sheet's — they name the
// four sections and outlive it.

// THE RECEDE, READ FROM ALL SEVEN SOURCES BEFORE ANYTHING SHARED WAS FOLDED IN.
//
// Every world dims as it gives — `A = p * (1 − dsp * k)` — and the coefficient is a
// GRADIENT, not a constant. The emptier the world, the further it gets out of the way:
//
//   I   THE POINT     0.62   world-one.js:112     the deepest recede; the emptiness is the subject
//   II  THE TURN      0.54   world-two.js:132
//   III THE VEIL      0.50   world-three.js:148
//   IV  THE CHAMBER   0.46   world-four.js:144
//   V   THE MIRRORS   0.46   world-five.js:210    × (1 − bk*0.86) — see below
//   VI  THE RETURN    0.44   world-six.js:239
//   VII THE DANCE     0.44   world-seven.js:315
//
// AND VI AND VII INVERT IT. Their `displaced()` returns **−1** while he is acting, which
// makes `1 − dsp*k` = 1.44: the world gets BRIGHTER, not dimmer.
//
//   VI  `if(!this.reading||this.holding)return -1;`   *"he has to be able to see the
//        horizon to send over it"* (`world-six.js:185-190`)
//   VII `if(this.hand&&!this.resolved)return -1;`     *"he needs the floor to dance on"*
//        (`world-seven.js:138-142`)
//
// Both also scale their own `displaced` by 0.54 internally, so their deepest dim is
// 0.54 × 0.44 ≈ 0.24 against I's 0.62 — a quarter of the recede, in the two worlds where
// the ground is the thing he is using. A single shared dim would have flattened all of
// this: it would have taken the two inverting worlds the wrong way entirely.
//
// V carries a second, opposite term: `× (1 − bk*0.86)` for the guard pane, because *"a
// mirror at the end of a hall is always larger than the walk to it predicts — so the guard
// LOOMS where everything else recedes"* (`world-five.js:198-200`). It is not part of the
// recede; it is its inverse, and it belongs with the guard-pane build.
//
// NOT YET IMPLEMENTED, and it is structural rather than a constant. In the design the
// reading OVERLAYS the world and the world recedes under it; in the app `PointWorldView`
// shows the reading INSTEAD of the world, so there is nothing behind to dim. Wiring the
// recede means drawing the world behind the reading and feeding `revealed` back into its
// alpha — which is also what would stop a world's own chrome reading through, the thing
// the world-V walk turned up.

enum PointSection: Int, CaseIterable {
    case say, walk, hand, open
    var label: String {
        switch self {
        case .say:  return "what the rush says"
        case .walk: return "the walk"
        case .hand: return "what this hands you"
        case .open: return "the open door"
        }
    }
    func text(_ s: PointStar) -> String {
        switch self {
        case .say: return s.say; case .walk: return s.walk
        case .hand: return s.hand; case .open: return s.open
        }
    }
    /// `openSheet` set the first and last in its quote face.
    var quoted: Bool { self == .say || self == .open }
}

/// `STL` — `point-levels.js:9`, verbatim. The star's own provenance, which belongs wherever
/// the star is read; it does not belong to the sheet that used to print it.
enum PointStatusLabel {
    static func text(_ st: String) -> String {
        switch st {
        case "w": return "WALKED ●"
        case "p": return "IN PROGRESS ◐"
        default:  return "SEEDED ○ — NOT YET WALKED"
        }
    }
    static func footer(_ st: String) -> String { text(st) + " · THE LEARNING FIELD" }
}

/// What every world's reading shares: the star, its hue, and how far it has been let in.
@MainActor final class PointReadingState: ObservableObject {
    @Published var revealed = 0          // 0…4 sections given up
    let star: PointStar
    init(star: PointStar) { self.star = star }

    var next: PointSection? { revealed < 4 ? PointSection(rawValue: revealed) : nil }
    var done: Bool { revealed >= 4 }

    func give() {
        guard revealed < 4 else { return }
        withAnimation(.easeInOut(duration: 1.0)) { revealed += 1 }
        if revealed == 4 { PointJourney.descended.append(star.t) }
    }
}

// MARK: - one section, in the shared type

private struct SectionBlock: View {
    let section: PointSection
    let star: PointStar
    let hue: Color
    var mirrored = false
    var thinned = false
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(section.label.uppercased()).spaceMonoTracked(9, em: 0.17)
                .foregroundStyle(hue.opacity(0.7))
            Text(section.text(star))
                .font(section.quoted ? .loraItalic(15.5) : .lora(15.5))
                .lineSpacing(6)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(thinned ? 0.72 : 1))
        }
        .scaleEffect(x: mirrored ? -1 : 1, y: 1)     // V — it arrives mirror-written
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ReadingFooter: View {
    let star: PointStar
    let hue: Color
    var body: some View {
        Text(PointStatusLabel.footer(star.st))
            .spaceMonoTracked(7.5, em: 0.16)
            .foregroundStyle(BinduTheme.inkPrimary.opacity(0.26))
            .padding(.top, 8)
    }
}

private struct ReadingHead: View {
    let star: PointStar
    let hue: Color
    let onClose: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: onClose) {
                Text("‹").font(.system(size: 20)).foregroundStyle(BinduTheme.inkTertiary)
            }.buttonStyle(.plain)
            Text(star.t).font(.lora(24, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
            Text(star.ti).font(.loraItalic(14)).foregroundStyle(hue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - the dispatcher

struct PointReading: View {
    let dimensionN: Int
    let star: PointStar
    let hue: Color
    let onClose: () -> Void

    @StateObject private var state: PointReadingState

    init(dimensionN: Int, star: PointStar, hue: Color, onClose: @escaping () -> Void) {
        self.dimensionN = dimensionN; self.star = star; self.hue = hue; self.onClose = onClose
        _state = StateObject(wrappedValue: PointReadingState(star: star))
    }

    var body: some View {
        ZStack {
            switch dimensionN {
            case 1: ReadStillness(s: state, hue: hue, onClose: onClose)
            case 2: ReadFollowing(s: state, hue: hue, onClose: onClose)
            case 3: ReadParting(s: state, hue: hue, onClose: onClose)
            case 4: ReadPressing(s: state, hue: hue, onClose: onClose)
            case 5: ReadTurning(s: state, hue: hue, onClose: onClose)
            case 6: ReadSending(s: state, hue: hue, onClose: onClose)
            default: ReadCompany(s: state, hue: hue, onClose: onClose)
            }
        }
        // Level 3 is shared by all seven, in the design too — the descent, and its fallback.
        .overlay(alignment: .bottom) {
            if state.done { PointDescentDoor(star: star, hue: hue) }
        }
    }
}

// MARK: - I · THE POINT — stillness
// `world-one.js:70-100`, and I had it exactly backwards on the first cut.
//
//   *"Touching a star CHOOSES it. That is all touching does — it does not open anything.
//    What opens it is letting go and STAYING."*
//
//     if (touching) { still = max(0, still − dt*0.55); return null }
//     still = min(1, still + dt*0.30)
//     gates = [0.14, 0.38, 0.64, 0.88]
//
// STILLNESS IN THIS INSTRUMENT IS ALWAYS AN ASYMMETRIC ACCUMULATOR THAT DECAYS UNDER
// ACTION, NEVER A TIMER. Three instances now — the sky's dwell (0.30 build / 1.30 decay
// past Z < −2.3), this one (0.30 / 0.55), and `still` as a velocity test rather than a
// since-last-touch test. Twice already "held" or "no recent input" has been mistaken for
// "still", and my first cut here made it a third: a hold-to-build ring on a 2.2s timer,
// which is the opposite gesture. A fourth stillness surface gets built this way, and its
// decay term gets checked first.
//
// There is no contention with the rope. The rope is a press; this admits on hands off.
// `Deal 5` — *a rope for the drowning minute, a cathedral for the returning hour, both
// open from this gate* — and it is the one affordance that is never conditional.

private struct ReadStillness: View {
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var still: Double = 0
    @State private var touching = false
    @State private var running = false

    private let gates = [0.14, 0.38, 0.64, 0.88]

    /// `world-one.js:184-186`, verbatim — the only four things this world says.
    private var stateWord: String {
        if still < 0.05 { return "let go" }
        if still < 0.14 { return "staying" }
        return s.revealed < 2 ? "it is admitting you" : "still admitting"
    }

    var body: some View {
        ZStack {
            // "the more he is given, the less there is around it" — `displaced() = given/4`,
            // and the world's alpha is `A = p * (1 − dsp*0.62)`.
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    let dsp = Double(s.revealed) / 4
                    let A = 1 - dsp * 0.62
                    for i in 0..<70 {
                        let a = RoomGeo.rnd(Double(i)) * RoomGeo.tau
                        let r = min(size.width, size.height)
                            * (0.10 + RoomGeo.rnd(Double(i + 5)) * 0.42)
                        let cx = size.width / 2 + cos(a) * r
                        let cy = size.height * 0.46 + sin(a) * r * 1.25
                        let tw = 0.4 + 0.6 * abs(sin(t * 0.5 + Double(i)))
                        ctx.fill(RoomDraw.ring(Double(cx), Double(cy),
                                               0.7 + RoomGeo.rnd(Double(i + 2)) * 1.1),
                                 with: .color(BinduTheme.inkPrimary.opacity((0.06 + 0.10 * tw) * A)))
                    }
                }
            }
            .ignoresSafeArea().allowsHitTesting(false)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ReadingHead(star: s.star, hue: hue, onClose: onClose)
                    ForEach(0..<s.revealed, id: \.self) { i in
                        SectionBlock(section: PointSection(rawValue: i)!, star: s.star, hue: hue)
                            .transition(.opacity)
                    }
                    if !s.done {
                        // the gauge is a report, not a control: it fills when the hand is OFF
                        ZStack {
                            Circle().stroke(hue.opacity(0.14), lineWidth: 1).frame(width: 74, height: 74)
                            Circle().trim(from: 0, to: still)
                                .stroke(hue.opacity(0.7), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                                .frame(width: 74, height: 74).rotationEffect(.degrees(-90))
                            // its four states, verbatim — `world-one.js:184-186`
                            Text(stateWord.uppercased())
                                .spaceMonoTracked(8.5, em: 0.2)
                                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.44))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    ReadingFooter(star: s.star, hue: hue)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 32).padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        // Reaching for it interrupts, and it closes without complaint.
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in touching = true }
            .onEnded { _ in touching = false })
        .onAppear { run() }
    }

    private func run() {
        guard !running else { return }
        running = true
        Task {
            while !s.done {
                try? await Task.sleep(nanoseconds: 16_000_000)
                let dt = 0.016
                if touching {
                    still = max(0, still - dt * 0.55)      // acting suspends it
                } else {
                    still = min(1, still + dt * 0.30)
                    if s.revealed < 4 && still >= gates[s.revealed] { s.give() }
                }
            }
            running = false
        }
    }
}

// MARK: - II · THE TURN — following
// "He takes hold of a ray and travels out along it. Each section arrives one turn further
//  from the centre — SAY near the origin, OPEN at the rim." Stillness is the one thing that
//  cannot work here: a perfection that stops moving cannot know itself.

private struct ReadFollowing: View {
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var travelled: Double = 0     // 0 origin … 1 rim

    var body: some View {
        GeometryReader { geo in
            ZStack {
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in
                        let cx = Double(size.width) / 2, cy = Double(size.height) * 0.5
                        let R = min(Double(size.width), Double(size.height)) * 0.46
                        // the ray he is on, and the rings he has passed
                        for k in 0..<4 {
                            let f = Double(k + 1) / 4
                            ctx.stroke(RoomDraw.ring(cx, cy, R * f),
                                       with: .color(hue.opacity(travelled >= f - 0.26 ? 0.22 : 0.07)),
                                       lineWidth: 1)
                        }
                        var ray = Path()
                        ray.move(to: CGPoint(x: cx, y: cy))
                        ray.addLine(to: CGPoint(x: cx + cos(-.pi / 2 + t * 0.04) * R,
                                                y: cy + sin(-.pi / 2 + t * 0.04) * R))
                        ctx.stroke(ray, with: .color(hue.opacity(0.3)), lineWidth: 1)
                        // the particle at the centre — the one he has been touching all along
                        ctx.fill(RoomDraw.ring(cx, cy, 3 + 2 * RoomGeo.breath(t)),
                                 with: .color(hue.opacity(0.9)))
                        // where he is on the ray
                        let px = cx + cos(-.pi / 2 + t * 0.04) * R * travelled
                        let py = cy + sin(-.pi / 2 + t * 0.04) * R * travelled
                        ctx.fill(RoomDraw.ring(px, py, 4), with: .color(Color.white.opacity(0.9)))
                    }
                }
                .ignoresSafeArea().allowsHitTesting(false)

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        ReadingHead(star: s.star, hue: hue, onClose: onClose)
                        ForEach(0..<s.revealed, id: \.self) { i in
                            SectionBlock(section: PointSection(rawValue: i)!, star: s.star, hue: hue)
                                .padding(.leading, Double(i) * 10)      // one turn further out
                                .transition(.opacity)
                        }
                        if !s.done {
                            Text(s.revealed == 0 ? "take the ray and go" : "keep going")
                                .font(.loraItalic(13)).foregroundStyle(hue.opacity(0.55))
                                .frame(maxWidth: .infinity)
                        }
                        ReadingFooter(star: s.star, hue: hue)
                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 32).padding(.top, 20)
                }
                .scrollIndicators(.hidden)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 2)
                .onChanged { v in
                    // going outward is what gives; stopping gives nothing
                    let d = -Double(v.translation.height) / Double(geo.size.height) * 1.6
                    travelled = min(1, max(0, travelled + max(0, d) * 0.06))
                    let want = Int(travelled * 4.0)
                    if want > s.revealed { s.give() }
                })
        }
    }
}

// MARK: - III · THE VEIL — parting
// "He never gets to lift it. He only ever parts it, where he is, while he is there." And
// what he has already received leaves a zone permanently THINNER — not clear, thinner.
// The veil remembers what was handed back and does not take it again.

private struct ReadParting: View {
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var part: CGPoint?      // where the hand is holding it open
    @State private var thinned: [CGPoint] = []   // permanently thinner, one per section received

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        ReadingHead(star: s.star, hue: hue, onClose: onClose)
                        ForEach(0..<s.revealed, id: \.self) { i in
                            SectionBlock(section: PointSection(rawValue: i)!, star: s.star, hue: hue,
                                         thinned: true)
                                .transition(.opacity)
                        }
                        ReadingFooter(star: s.star, hue: hue)
                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 32).padding(.top, 20)
                }
                .scrollIndicators(.hidden)

                // four curtains at four depths, drifting at four rates — closing behind the hand
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in
                        for layer in 0..<4 {
                            let drift = t * (0.05 + Double(layer) * 0.035)
                            var gauze = ctx
                            gauze.translateBy(x: sin(drift) * Double(6 + layer * 5), y: 0)
                            var body = Path(CGRect(origin: .zero, size: size))
                            // the parting the hand is holding, and every zone handed back
                            var holes: [CGPoint] = thinned
                            if let p = part { holes.append(p) }
                            for h in holes {
                                body.addEllipse(in: CGRect(x: Double(h.x) - 92, y: Double(h.y) - 62,
                                                           width: 184, height: 124))
                            }
                            gauze.fill(body, with: .color(Color(hex: "#0A0810")
                                .opacity(0.30 - Double(layer) * 0.045)), style: FillStyle(eoFill: true))
                        }
                    }
                }
                .ignoresSafeArea().allowsHitTesting(false)

                if !s.done && part == nil {
                    VStack { Spacer()
                        Text("part it where you are")
                            .font(.loraItalic(13)).foregroundStyle(hue.opacity(0.55)).padding(.bottom, 120)
                    }.allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { v in part = v.location }
                .onEnded { v in
                    // holding it open long enough to read is what hands a section back
                    if !s.done {
                        thinned.append(v.location)
                        s.give()
                    }
                    part = nil
                })
        }
    }
}

// MARK: - IV · THE CHAMBER — pressing
// `world-four.js:100-133`. The one architectural register, and walls are the only surface
// in the instrument that can be INSCRIBED — so here the reading is a thing pressed into a
// surface rather than a thing that arrives.
//
//     press += dt * (0.30 + load(Z)*0.26)          while bearing
//     gates  = [0.22, 0.46, 0.70, 0.92]
//     release → press -= dt*0.52, and below 0.02 the niche closes and `given` resets
//
// *"nothing here is a tap, because an impression cannot be made by touching."* And the
// strike deepens with the press: the struck title only exists above `press > 0.05`, and
// its ink is `min(1, press*2.4)` — so a light bearing leaves a partial impression and a
// touch leaves none at all. (The checklist rounds this to 0.12; these are the source's
// own numbers, and they are what is implemented.)
//
// Note this is NOT the stillness rule inverted by accident — pressing IS action, so it
// builds under the hand and decays when the hand leaves. Opposite world, opposite term.

private struct ReadPressing: View {
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var press: Double = 0
    @State private var holding = false
    @State private var running = false

    private let gates = [0.22, 0.46, 0.70, 0.92]

    var body: some View {
        ZStack {
            // the light comes from BELOW — he is the molten layer, so the floor glows
            LinearGradient(colors: [Color(hex: "#0A0806"), hue.opacity(0.10 + press * 0.16)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ReadingHead(star: s.star, hue: hue, onClose: onClose)
                    ForEach(0..<s.revealed, id: \.self) { i in
                        SectionBlock(section: PointSection(rawValue: i)!, star: s.star, hue: hue)
                            .padding(.leading, 14)
                            .overlay(alignment: .leading) {   // struck into the wall
                                Rectangle().fill(hue.opacity(0.35)).frame(width: 1.5)
                            }
                            .transition(.opacity)
                    }
                    if !s.done {
                        VStack(spacing: 8) {
                            // the impression: nothing at all below 0.05, deepening at press*2.4
                            Rectangle()
                                .fill(hue.opacity(press <= 0.05 ? 0 : 0.30 * min(1, press * 2.4)))
                                .frame(height: 2 + press * 10)
                                .frame(maxWidth: .infinity)
                                .background(Rectangle().fill(hue.opacity(0.08)).frame(height: 1.5))
                            Text(press <= 0.05 ? "press · a touch leaves nothing" : "bear down")
                                .font(.loraItalic(13))
                                .foregroundStyle(hue.opacity(press <= 0.05 ? 0.4 : 0.85))
                        }
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { _ in holding = true }
                            .onEnded { _ in holding = false })
                    }
                    ReadingFooter(star: s.star, hue: hue)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 32).padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear { run() }
    }

    private func run() {
        guard !running else { return }
        running = true
        Task {
            while !s.done {
                try? await Task.sleep(nanoseconds: 16_000_000)
                let dt = 0.016
                if holding {
                    press = min(1, press + dt * 0.42)          // 0.30 + a mid load
                    if s.revealed < 4 && press >= gates[s.revealed] { s.give() }
                } else {
                    press = max(0, press - dt * 0.52)
                }
            }
            running = false
        }
    }
}

// MARK: - V · THE MIRRORS — turning
// "The reading physically CROSSES THE LINE every half turn — a section arrives on this
//  side, the next arrives from the other, mirror-written, and unflips as it settles."

private struct ReadTurning: View {
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var turn: Double = 0          // half-turns taken
    @State private var settling = false

    var body: some View {
        ZStack {
            // the vertical mirror line the hall is arranged about
            GeometryReader { g in
                Rectangle().fill(hue.opacity(0.14)).frame(width: 0.5)
                    .position(x: g.size.width / 2, y: g.size.height / 2)
            }
            .ignoresSafeArea().allowsHitTesting(false)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ReadingHead(star: s.star, hue: hue, onClose: onClose)
                    ForEach(0..<s.revealed, id: \.self) { i in
                        // every other section came from the far side
                        SectionBlock(section: PointSection(rawValue: i)!, star: s.star, hue: hue,
                                     mirrored: i % 2 == 1 && settling && i == s.revealed - 1)
                            .transition(.opacity)
                            .animation(.easeOut(duration: 1.1), value: settling)
                    }
                    if !s.done {
                        Text("turn the glass")
                            .font(.loraItalic(13)).foregroundStyle(hue.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .rotation3DEffect(.degrees(turn * 180), axis: (x: 0, y: 1, z: 0))
                    }
                    ReadingFooter(star: s.star, hue: hue)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 32).padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 4)
            .onEnded { v in
                guard !s.done, abs(v.translation.width) > 40 else { return }
                withAnimation(.easeInOut(duration: 0.9)) { turn += 0.5 }
                settling = true
                s.give()
                // it arrives mirror-written and UNFLIPS as it settles
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeOut(duration: 1.1)) { settling = false }
                }
            })
    }
}

// MARK: - VI · THE RETURN — sending
// "He takes a star, aims, and lets go. That is the entire act. It rises, crosses the line,
//  travels out, TURNS — visibly, slowly, at the far point of its arc — and comes back on
//  its own time carrying one section. He cannot pull it. He cannot hurry it."

private struct ReadSending: View {
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var out: Double = 0        // 0 here · 1 the far point
    @State private var sent = false

    var body: some View {
        ZStack {
            GeometryReader { g in
                let horizon = g.size.height * 0.42
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(hue.opacity(0.20)).frame(height: 0.5)
                        .offset(y: horizon)
                    // the probe, above the line only while it is away
                    Circle().fill(Color.white.opacity(0.85)).frame(width: 6, height: 6)
                        .offset(x: g.size.width / 2 - 3,
                                y: horizon + 40 - sin(out * .pi) * (horizon - 30))
                        .opacity(sent ? 1 : 0.35)
                }
            }
            .ignoresSafeArea().allowsHitTesting(false)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ReadingHead(star: s.star, hue: hue, onClose: onClose)
                    ForEach(0..<s.revealed, id: \.self) { i in
                        SectionBlock(section: PointSection(rawValue: i)!, star: s.star, hue: hue)
                            .transition(.opacity)
                    }
                    if !s.done {
                        Button {
                            guard !sent else { return }
                            send()
                        } label: {
                            Text(sent ? "it is out there" : "send it out")
                                .font(.loraItalic(13))
                                .foregroundStyle(hue.opacity(sent ? 0.35 : 0.65))
                        }
                        .buttonStyle(.plain).frame(maxWidth: .infinity)
                    }
                    ReadingFooter(star: s.star, hue: hue)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 32).padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
    }

    /// Its own time — and there is no gesture that shortens it.
    private func send() {
        sent = true
        withAnimation(.easeOut(duration: 2.4)) { out = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeIn(duration: 2.4)) { out = 0 }     // it turns, and comes back
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                s.give(); sent = false
            }
        }
    }
}

// MARK: - VII · THE DANCE — company
// Nine bodies already dancing when he arrives, coupled to each other and not to him. "Keep
// pace or it scatters" — the only fast world, and the only one where the reading is not
// his to hold.

private struct ReadCompany: View {
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var pace: Double = 0
    @State private var lastMove = Date()

    var body: some View {
        ZStack {
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    let cx = Double(size.width) / 2, cy = Double(size.height) * 0.5
                    for i in 0..<9 {
                        let a = t * (0.5 + Double(i) * 0.07) + Double(i) / 9 * RoomGeo.tau
                        let r = min(Double(size.width), Double(size.height)) * (0.16 + Double(i % 3) * 0.13)
                        ctx.fill(RoomDraw.ring(cx + cos(a) * r, cy + sin(a) * r * 0.7, 3),
                                 with: .color(RoomGeo.col(RoomPalette.at(i), 0.25 + pace * 0.6)))
                    }
                }
            }
            .ignoresSafeArea().allowsHitTesting(false)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ReadingHead(star: s.star, hue: hue, onClose: onClose)
                    ForEach(0..<s.revealed, id: \.self) { i in
                        SectionBlock(section: PointSection(rawValue: i)!, star: s.star, hue: hue)
                            .transition(.opacity)
                    }
                    if !s.done {
                        VStack(spacing: 6) {
                            Rectangle().fill(hue.opacity(0.12)).frame(height: 1.5)
                                .overlay(alignment: .leading) {
                                    GeometryReader { g in
                                        Rectangle().fill(hue.opacity(0.8))
                                            .frame(width: g.size.width * pace)
                                    }
                                }
                            Text(pace > 0.05 ? "keep pace" : "they are already dancing")
                                .font(.loraItalic(13)).foregroundStyle(hue.opacity(0.55))
                        }
                    }
                    ReadingFooter(star: s.star, hue: hue)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 32).padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 1)
            .onChanged { v in
                guard !s.done else { return }
                let now = Date()
                let dt = max(0.008, now.timeIntervalSince(lastMove))
                lastMove = now
                let speed = min(1.0, abs(Double(v.translation.width)) / dt / 900)
                pace = min(1, pace * 0.86 + speed * 0.22)
                if pace >= 1 { pace = 0.2; s.give() }
            })
        .onAppear { scatter() }
    }

    /// It scatters the moment he stops keeping pace. Nothing else in the Point decays.
    private func scatter() {
        Task {
            while !s.done {
                try? await Task.sleep(nanoseconds: 60_000_000)
                if Date().timeIntervalSince(lastMove) > 0.16 { pace = max(0, pace - 0.05) }
            }
        }
    }
}
