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

/// WHO IS HOLDING THE GESTURE. `The Instrument v3.html:5876` guards the rope with
/// `if(!turnEl…('on') && !ropeEl…('on'))` — the rope is reachable from anywhere, and declines
/// only where a surface is already using the press. This is that exclusion list.
///
/// It exists because world IV's whole gesture IS a sustained press — *"press · a touch leaves
/// nothing"* — so without it the rope opens at 1.1s over the wall he is pressing. The right
/// answer is not to take the rope away from the other fourteen registers; it is to let the
/// Chamber say "this one is mine", the same way `handedToRegister` lets a register say the
/// vertical is.
///
/// Read at fire time, not render time — exactly as the design reads a DOM class at fire time —
/// so it is a plain static and needs no publishing.
enum PressClaim {
    private(set) static var owner: String?
    static var isClaimed: Bool { owner != nil }
    static func claim(_ who: String) { owner = who }
    /// Release only your own claim, so a late `onEnded` cannot free someone else's.
    static func release(_ who: String) { if owner == who { owner = nil } }
}

/// THE SEVEN RECEDE COEFFICIENTS, and the two that invert. Read from all seven sources in
/// Pass 5 and held unimplemented because the reading REPLACED the world and there was nothing
/// behind to dim. The overlay changes that, so they land.
///
///   I 0.62 · II 0.54 · III 0.50 · IV 0.46 · V 0.46 · VI 0.44 · VII 0.44
///
/// **VI and VII invert.** `world-six.js:185-190` returns `−1` while he is reading or holding —
/// *"he has to be able to see the horizon to send over it"* — and `world-seven.js:138-142`
/// while his hand is down and unresolved — *"he needs the floor to dance on."* `1 − (−1)·0.44`
/// = **1.44**: the world gets BRIGHTER. They also scale their own displaced by 0.54, so their
/// deepest dim is ≈0.24 against I's 0.62 — a quarter of the recede, in the two worlds where
/// the ground is the thing he is using.
///
/// A single shared term would have taken those two backwards, which is why one was refused.
enum PointRecede {
    /// index 1…7
    static let k: [Double] = [0, 0.62, 0.54, 0.50, 0.46, 0.46, 0.44, 0.44]
    /// VI and VII are the two whose ground he is standing on while he acts.
    static func inverts(_ n: Int) -> Bool { n >= 6 }

    /// `A = p · (1 − dsp·k)`. `revealed` 0…4 is how much he has been given.
    static func worldAlpha(dimension n: Int, revealed: Int, open: Bool) -> Double {
        guard open else { return 1 }                       // nothing being read: no recede
        let kk = k[max(1, min(7, n))]
        let dsp: Double
        if inverts(n) && revealed < 4 {
            dsp = -1                                       // the horizon · the floor
        } else {
            dsp = Double(revealed) / 4 * (inverts(n) ? 0.54 : 1)
        }
        return max(0, 1 - dsp * kk)
    }
}

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
    /// How much has been given, reported up so the WORLD BEHIND can recede by it.
    let onReveal: (Int) -> Void

    @StateObject private var state: PointReadingState

    init(dimensionN: Int, star: PointStar, hue: Color,
         onClose: @escaping () -> Void, onReveal: @escaping (Int) -> Void = { _ in }) {
        self.dimensionN = dimensionN; self.star = star; self.hue = hue
        self.onClose = onClose; self.onReveal = onReveal
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
        // Plain `.overlay`, not `.overlay(alignment: .bottom)` — the descent needs the whole
        // frame to cover, and the door aligns itself to the bottom from inside it.
        .onChange(of: state.revealed) { _, r in onReveal(r) }
        .onAppear { onReveal(state.revealed) }
        .overlay {
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

    /// `world-two.js:229-232`, verbatim. `travelled` is the design's `this.out`,
    /// `s.revealed` its `given`.
    private var followWord: String {
        if s.revealed >= 4 { return "far out, and still leaving" }
        if travelled < 0.12 { return "holding it" }
        if travelled < 0.44 { return "going" }
        if travelled < 0.72 { return "further" }
        return "far out"
    }

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
                            // `world-two.js:229-232` — the five things this world says while
                            // the ray is held, keyed to how far out he is. Replaced
                            // "take the ray and go" / "keep going", both invented.
                            Text(followWord.uppercased())
                                .spaceMonoTracked(8.5, em: 0.2)
                                .foregroundStyle(hue.opacity(0.55))
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
            // `.simultaneousGesture`, NOT `.gesture`. A ScrollView claims the vertical
            // drag before an ancestor's plain `.gesture` ever sees it, so this reading's own
            // travel was shadowed by its own scroll view: correct gesture, correct maths,
            // never delivered. World I already had `simultaneousGesture` (which is why the
            // rope worked) and V and VII read `translation.width`, which a vertical scroll
            // does not claim — so the fault fell precisely on the readings whose gesture is
            // VERTICAL and sits outside the scroll. That is II and III, and only those.
            .simultaneousGesture(DragGesture(minimumDistance: 2)
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

    // E3 · THE REVERSAL. `world-three.js:96-108` — *"he is holding it open. Sections arrive
    // while he holds, and only while."*
    //
    // This gave on `onEnded`, one section per release, with a comment above it that read
    // *"holding it open long enough to read is what hands a section back"* — describing the
    // design correctly and doing the opposite. **A reversed mechanism is worse than an absent
    // one, because it reads as working**: four sections still arrive, the words are right, the
    // curtains still open, and the only thing wrong is the sentence the world is making. The
    // veil's whole claim is that *presence* decides and distance decides nothing; giving on
    // release makes letting go the thing that gives.
    //
    // `open` is the design's own scalar and the app had none — `ReadParting`'s note said so:
    // *"`this.open` … has no app scalar (the app's `part` is a point or nothing)"*. It has one
    // now, so the `open < 0.30 → 'holding it open'` word is portable too.
    @State private var open: Double = 0
    @State private var holding = false
    @State private var running = false
    /// `var gates=[0.30,0.52,0.74,0.94]` — `world-three.js:100`.
    private let gates = [0.30, 0.52, 0.74, 0.94]

    /// `world-three.js:208-215` — the one star that watches back. When the parting is open
    /// over `v-shadow`, a second hand shows in it, and the world names it. The design gates
    /// on `this.reading.shadow && this.open>0.30`; the app's star key IS that flag.
    private var shadowNamed: Bool { s.star.key == "v-shadow" && part != nil && s.revealed > 0 }

    /// `world-three.js:238-241`, now COMPLETE. The `open < 0.30` branch was unported because
    /// the app had no `open`; E3 gave it one, so *"holding it open"* — the word for the moment
    /// before the first section arrives — is restored with the rest.
    private var partWord: String {
        if part == nil { return "part it with your hand · and hold it open" }
        if s.revealed == 0 { return "nothing here yet" }
        if s.revealed >= 4 { return "handed back" }
        if open < 0.30 { return "holding it open" }
        return s.revealed < 2 ? "it is thinning" : "thinner"
    }

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

                // `world-three.js:238-241`. Replaced "part it where you are", invented.
                // The opening cue is the FIELD's (`WorldVeil`); what the reading says is what
                // the parting is doing. `this.open` — how wide the parting is held — has no
                // app scalar (the app's `part` is a point or nothing), so the design's
                // `open<0.30 -> 'holding it open'` is NOT ported rather than given an
                // invented trigger. It is a REVIEW row in Tools/authored-strings.tsv.
                if !s.done {
                    VStack { Spacer()
                        if shadowNamed {
                            Text("THAT IS YOUR OWN HAND")
                                .spaceMonoTracked(7, em: 0.2)
                                .foregroundStyle(Color(hex: "#FFFBFF").opacity(0.42))
                                .padding(.bottom, 10)
                        }
                        Text(partWord.uppercased())
                            .spaceMonoTracked(8.5, em: 0.2)
                            .foregroundStyle(hue.opacity(0.55)).padding(.bottom, 120)
                    }.allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
            // `.simultaneousGesture`, NOT `.gesture`. A ScrollView claims the vertical
            // drag before an ancestor's plain `.gesture` ever sees it, so this reading's own
            // travel was shadowed by its own scroll view: correct gesture, correct maths,
            // never delivered. World I already had `simultaneousGesture` (which is why the
            // rope worked) and V and VII read `translation.width`, which a vertical scroll
            // does not claim — so the fault fell precisely on the readings whose gesture is
            // VERTICAL and sits outside the scroll. That is II and III, and only those.
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { v in
                    // `place(qx,qy)` — the hand goes down and the veil opens 0.34 at once,
                    // which is already past the first gate: the first section arrives on
                    // contact, and the other three are earned by staying.
                    if part == nil { open = min(1, open + 0.34) }
                    part = v.location
                    holding = true
                }
                .onEnded { _ in
                    // `release()` — the hand comes off. It hands back NOTHING: everything
                    // this parting gave, it gave while it was held.
                    holding = false
                    part = nil
                })
            .onAppear { run() }
            // A hold must be released by every path its owner can leave by (§10) — the strip
            // can vanish mid-press when the fourth give sets `s.done`, and `onEnded` never
            // fires. Same fault as `PressClaim`, one register over.
            .onDisappear { holding = false }
        }
    }

    /// `hold(dt)` and `update(dt, holding)` — `world-three.js:96-108,124-131`.
    ///
    /// `open` grows at **0.42/s while held** and falls at **0.70/s when it is not**, and the
    /// four sections arrive at `[0.30, 0.52, 0.74, 0.94]` as it passes them. Each give hands
    /// its zone back — *"that zone stays thin"* — and a zone once thinned is permanent.
    ///
    /// **AND THE PARTING CLOSES BEHIND HIM.** `:127-128` — below 0.02 the veil takes the
    /// reading back. `given` resets there in the design; here `s.revealed` is the reading's
    /// own progress and is not reset, because the app's sections are a reading that has been
    /// opened rather than a parting being held — resetting it would delete text he has read.
    /// Recorded as a divergence rather than ported blind.
    private func run() {
        guard !running else { return }
        running = true
        Task {
            while !s.done {
                try? await Task.sleep(nanoseconds: 16_000_000)
                let dt = 0.016
                if holding {
                    open = min(1, open + dt * 0.42)
                    if s.revealed < 4 && open >= gates[s.revealed] {
                        if let p = part { thinned.append(p) }   // `handBack` — it stays thin
                        s.give()
                    }
                } else {
                    open = max(0, open - dt * 0.70)             // it closes behind his hand
                }
            }
            running = false
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

    /// `world-four.js:272-274`, verbatim. `press` is the design's own `this.press`.
    private var pressWord: String {
        if s.revealed >= 4 { return "struck" }
        if press < 0.22 { return "bearing" }
        if press < 0.50 { return "it is taking" }
        if press < 0.76 { return "deeper" }
        return "nearly through"
    }
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
                            // `world-four.js:272-274`, verbatim. Replaced "press · a touch
                            // leaves nothing" / "bear down", both invented.
                            Text(pressWord.uppercased())
                                .spaceMonoTracked(8.5, em: 0.2)
                                .foregroundStyle(hue.opacity(press <= 0.05 ? 0.4 : 0.85))
                        }
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                holding = true
                                PressClaim.claim(Self.claimant)   // the wall owns this press
                            }
                            .onEnded { _ in
                                holding = false
                                PressClaim.release(Self.claimant)
                            })
                        // AND when the strip itself goes. The fourth give sets `s.done`,
                        // which removes this whole block MID-PRESS — so `onEnded` never
                        // fires, and without this the claim leaks and the rope stays down
                        // for the rest of the session. Exactly the fault `handedToRegister`
                        // has to release on all four of its scoped paths: a claim must be
                        // released by every way its owner can leave, not just the polite one.
                        .onDisappear { PressClaim.release(Self.claimant) }
                    }
                    ReadingFooter(star: s.star, hue: hue)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 32).padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear { run() }
        // A claim must never outlive its claimant — the same discipline the fall's four
        // scoped paths keep on `handedToRegister`.
        .onDisappear { PressClaim.release(Self.claimant) }
    }

    private static let claimant = "chamber-wall"

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

// R-GUARD · THE EXCEPTION, ruled and not discovered (`world-five.js:32-50`).
//
//   *"The warning is posted at the exit: achievement is the trap. A world built on pairing,
//    closing on a star that warns against collecting the pairs, is only a gift if the
//    INTERACTION breaks — otherwise it is the eleventh collected thing."*
//
// So the guard is the one pane with nothing on the other side. `pair: null`, `side: 0` — and
// `give()` at `:158-162` hard-sets `side='this'`, `through=''`: **the reading never crosses
// at it.** Ten panes train him to expect the far side; he turns this one and finds his own
// reflection and no partner. No caption fills the gap — `:430-432` is an empty branch with a
// comment saying so, because *"a caption here would be the instrument explaining its own
// guard."* The emptiness is the content.
//
// It does not advance the walk. Completing it WITHDRAWS the hall and carries him back out to
// the Surface, the gate he came in by — *"a guard turns you back; it does not let you pass
// for having finished it."*
//
// TWO THINGS FOUND ON THE PORT, both worth stating plainly:
//
//  1 · `sendBack` and `mute` are declared at `:106-107`, set at `:161`, and READ BY NOTHING —
//      not in the app, and not in the reference build either. Grepped every design source:
//      the only hits are their own declaration, reset and assignment. The prose at `:44-46`
//      is unambiguous about what they are for, so they are wired here from the prose. This is
//      the `beatCue` class again: declared, set, never called, and indistinguishable from
//      absence until someone goes looking.
//  2 · The silence is not an omission. *"At the exact instant every other star sounds its
//      arrival, this one is silent — a true null, the only deliberate silence in the Point.
//      Sakshi's register: it witnesses, it does not teach."* So `mute` suppresses the arrival
//      tone, and that suppression must never be "fixed".
//
// `bk()` (`:173-179`) is a WALL CLOCK, not a state — *"it runs on its own clock rather than
// on his presence… a walk that returns finds the hall standing, or finds it rising, and never
// finds it snapping."* Rise `sm(e/2.4)` over 0–2.4s · hold 1 to 3.6s · ease `sm(1−(e−3.6)/1.8)`
// to 5.4s · then 0.
/// THE WITHDRAWAL'S CLOCK LIVES OUTSIDE THE READING, and that is the whole point of it.
///
/// `world-five.js:170-172`: *"The withdrawal is a moment, not a state — so it runs on its own
/// clock rather than on his presence. It rises, holds while he is carried out, and eases back
/// down; a walk that returns finds the hall standing, or finds it rising, and NEVER FINDS IT
/// SNAPPING."*
///
/// Built first with `backAt` as `@State` on the reading, it snapped — the reading closes at
/// 3.0s, taking its own `.task` with it, so the hall was cut off at the top of the hold and
/// the ease-down from 3.6→5.4s never ran. The design names that failure in its own comment.
/// So the clock is static and the hall is drawn by the enclosure, which outlives the reading.
enum MirrorHall {
    static var backAt: Date?

    /// rise `sm(e/2.4)` · hold 1 to 3.6s · ease `sm(1−(e−3.6)/1.8)` to 5.4s · then gone.
    static func bk(_ now: Date = Date()) -> Double {
        guard let t0 = backAt else { return 0 }
        let e = now.timeIntervalSince(t0)
        if e < 2.4 { return RoomGeo.sm(0, 1, e / 2.4) }
        if e < 3.6 { return 1 }
        if e < 5.4 { return RoomGeo.sm(0, 1, 1 - (e - 3.6) / 1.8) }
        backAt = nil
        return 0
    }
}

private struct ReadTurning: View {
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var turn: Double = 0          // half-turns taken
    @State private var settling = false
    @State private var bk: Double = 0            // this reading's own read of the shared clock
    @State private var withdrawing = false

    private var isGuard: Bool { s.star.key == "r-guard" }

    /// `:200-201` — *"a mirror at the end of a hall is always larger than the walk to it
    /// predicts, so the guard LOOMS where everything else recedes."* `sc` 1.16 against the
    /// other panes' 0.60…, and `A = p(1−dsp·0.46)(1−bk·0.86)` — the second term is the
    /// inverse of the recede, and it belongs to the guard alone.
    private var loom: Double { isGuard ? 1.16 : 1.0 }

    /// `world-five.js:438` — the word under the held pane. The guard's own is fixed from the
    /// second give: nothing else will ever be true of it.
    private var word: String? {
        if bk > 0 { return nil }                             // the withdrawal says nothing
        if isGuard && s.revealed >= 2 { return "only your own reflection" }
        if s.revealed >= 4 { return "faced" }
        if s.revealed == 0 { return "turn a mirror · and see what faces it" }
        // `world-five.js:439` — `st=|cos(angleOf(held))|`, and below 0.12 the pane is
        // edge-on and there is nothing to read off it. `turn` counts half-turns, so the
        // pane's angle is `turn * pi`.
        if abs(cos(turn * .pi)) < 0.12 { return "edge-on · nothing" }
        return settling ? "the other face" : "facing you"
    }

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
                        // The guard's reading NEVER arrives mirror-written: `give()` sets
                        // `side='this'` and `through=''` unconditionally for it. Nothing
                        // faces it, so nothing can come from the far side.
                        SectionBlock(section: PointSection(rawValue: i)!, star: s.star, hue: hue,
                                     mirrored: !isGuard && i % 2 == 1 && settling && i == s.revealed - 1)
                            .transition(.opacity)
                            .animation(.easeOut(duration: 1.1), value: settling)
                    }
                    if !s.done, let w = word {
                        // NOT rotated with the glass. `world-five.js:427-441` draws this in
                        // screen space at `(cx, H-150)`; it is the world speaking, not
                        // something printed on the pane. The rotation was inherited from the
                        // invented "turn the glass" line it replaced, and on the guard it
                        // made exactly the wrong claim — a mirror-written "only your own
                        // reflection" implies a far side, which is the one thing the guard
                        // does not have.
                        Text(w.uppercased()).spaceMonoTracked(8.5, em: 0.2)
                            .foregroundStyle(hue.opacity(0.55))
                            .frame(maxWidth: .infinity)
                    }
                    ReadingFooter(star: s.star, hue: hue)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 32).padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        // THE WITHDRAWAL. The hall looms, whites out, and carries him back to the Surface.
        // It runs on its own clock so it finishes whether he is here or not.
        // THE HALL IS DRAWN ONCE, and it is drawn by the ENCLOSURE (`PointWorldView`), which
        // outlives this reading — the reading is carried out at 3.0s and the withdrawal runs
        // to 5.4s. Drawing it here as well composited `1 − (1 − 0.86·bk)²` = **0.98** at the
        // peak instead of 0.86: two correct layers making one wrong value. The reading keeps
        // only the hit-blocking, so the hall cannot be tapped through while it stands.
        .overlay {
            if bk > 0 { Color.clear.ignoresSafeArea().allowsHitTesting(bk > 0.2) }
        }
        .scaleEffect(1 + bk * (loom - 1))
        .task(id: withdrawing) {
            guard withdrawing, let t0 = MirrorHall.backAt else { return }
            // The reading shows the rise; the ENCLOSURE shows the hold and the ease-down,
            // because by then the reading is gone. `sendBack` — *"it withdraws the hall and
            // carries him back out to the Surface, the gate he came in by."*
            while !Task.isCancelled {
                let e = Date().timeIntervalSince(t0)
                bk = MirrorHall.bk()
                if e >= 3.0 { onClose(); return }
                try? await Task.sleep(for: .milliseconds(33))
            }
        }
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 4)
            .onEnded { v in
                guard !s.done, abs(v.translation.width) > 40 else { return }
                withAnimation(.easeInOut(duration: 0.9)) { turn += 0.5 }
                settling = true
                s.give()
                // `:161` — at the fourth give the guard withdraws the hall and sends him back.
                if isGuard && s.revealed >= 4 { MirrorHall.backAt = Date(); withdrawing = true }
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
    /// The FLIGHT is not here — it is in `PointReturn`, on the wall clock, outside this
    /// view. This is only whether the probe is drawn above the line.
    @State private var sent = false
    @State private var polling = false

    /// `world-six.js:423-428`. The design's `arcs.length>1` and `deep` branches now HAVE
    /// state to hang on — `PointReturn.arcs` is a list and Deep Time is a real arc — so the
    /// two lines that were REVIEW rows for having nothing to read are readable.
    private var sendWord: String {
        let flying = PointReturn.arcs
        if flying.contains(where: { $0.deep }) { return "something is coming that you did not send" }
        if flying.count > 1 { return "they will come back in their own order" }
        if !flying.isEmpty { return "it will come back. not when you want it to." }
        if s.revealed > 0 { return "send another · or send the same one further" }
        return "take one · send it over · wait"
    }

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
                            // `world-six.js:423-428`. Replaced "send it out" / "it is out
                            // there", both invented. The app carries ONE arc at a time, so
                            // the design's `arcs.length>1` and `deep` branches ("THEY WILL
                            // COME BACK IN THEIR OWN ORDER", "SOMETHING IS COMING THAT YOU
                            // DID NOT SEND") have no state to hang on and are NOT invented
                            // into being. Both are REVIEW rows.
                            Text(sendWord.uppercased())
                                .spaceMonoTracked(8.5, em: 0.2)
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
        // Everything that landed while he was elsewhere is collected on arrival — the
        // register does not lose a lap for having been left.
        .onAppear { PointReturn.tick(); run() }
    }

    /// Its own time — and there is no gesture that shortens it.
    ///
    /// E2 · THE FLIGHT NO LONGER LIVES HERE. This was two nested `asyncAfter` closures over
    /// a `@State`, so leaving the register took the arc with the view — and world VI's one
    /// claim is `world-six.js:101`, *"leaving the register closes the reading. It does not
    /// cancel a lap: nothing in flight cares whether he is watching."* The arc goes into
    /// `PointReturn` on a wall clock; this view only draws it and collects what has landed.
    private func send() {
        // `lift` is a real drawn-up quantity in the design; the app's send is a button, so
        // it is a full send by construction. Recorded rather than faked with a 0.
        guard PointReturn.send(id: s.star.key, aim: 0, lift: 1) != nil else { return }
        sent = true
        withAnimation(.easeOut(duration: 2.4)) { out = 1 }
        run()
    }

    /// Polls the registry — it does not own the clock, it reads it. Arrivals that landed
    /// while he was elsewhere are waiting in `pending` and are handed over one at a time.
    private func run() {
        guard !polling else { return }
        polling = true
        Task {
            while !s.done {
                try? await Task.sleep(nanoseconds: 100_000_000)
                PointReturn.tick()
                let flying = !PointReturn.arcs.isEmpty
                if sent && !flying { withAnimation(.easeIn(duration: 2.4)) { out = 0 } }
                sent = flying
                // `take()` — what he is present for, one at a time.
                while PointReturn.take() != nil, !s.done { s.give() }
            }
            polling = false
        }
    }
}

// MARK: - VII · THE DANCE — company
// Nine bodies already dancing when he arrives, coupled to each other and not to him. "Keep
// pace or it scatters" — the only fast world, and the only one where the reading is not
// his to hold.

private struct ReadCompany: View {
    @EnvironmentObject private var soundEngine: SoundEngine
    @ObservedObject var s: PointReadingState
    let hue: Color
    let onClose: () -> Void
    @State private var pace: Double = 0

    /// `world-seven.js:494-499` — *"a world that has closed is not a dead surface. It says
    /// what it is and it says where the way on runs."* `res>0.02` is the resolved world;
    /// `s.done` is that here. The second line is the only direction left in the instrument.
    private var closedLines: (String, String)? {
        s.done ? ("THE MAP BECAME ARCHITECTURE", "THE DOOR OUT IS THE DOOR IN · PULL UP") : nil
    }

    /// `world-seven.js:503-505`, verbatim — and now reading `chain.length`, which is what
    /// the design reads.
    ///
    /// **THIS CAPTION WAS THE TELL FOR `AUDIT D5.8`.** It printed `"\(s.revealed) hands"`
    /// with `s.revealed` counting SECTIONS READ, so it announced a number of hands held in a
    /// world that had no hands to hold: the number right and the thing absent, which is §10's
    /// NINTH SHAPE — complete-looking output over nothing. It rendered, so every outcome
    /// check passed it.
    private var danceWord: String {
        let held = PointDance.chain.count
        if held == 0 { return "someone is coming across the floor" }
        if held == 1 { return "you are dancing · it goes quicker in company" }
        return "\(held) hands · the dance is carrying you"
    }
    @State private var lastMove = Date()
    @State private var dancing = false

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
                            // `world-seven.js:503-505`. Replaced "keep pace" / "they are
                            // already dancing", both invented. `this.chain` — who he has
                            // gathered — is `s.revealed` here.
                            if let (top, way) = closedLines {
                                Text(top).spaceMonoTracked(8.5, em: 0.2)
                                    .foregroundStyle(Color(hex: "#FFF3DC").opacity(0.40))
                                Text(way).spaceMonoTracked(8.5, em: 0.2)
                                    .foregroundStyle(hue.opacity(0.42))
                            } else {
                                Text(danceWord.uppercased())
                                    .spaceMonoTracked(8.5, em: 0.2)
                                    .foregroundStyle(hue.opacity(0.55))
                            }
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
        // E1 · `offer` / `moveHand` / `letGo`. A HAND, not a pace meter: the register's whole
        // claim is that the dance exists while a hand is held and stops when it is not, and
        // that cannot be said by a scalar that decays on inactivity.
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { v in
                guard !s.done else { return }
                let rim = 393.0
                let hx = (Double(v.location.x) - rim / 2) / rim
                let hy = (Double(v.location.y) - 426) / rim
                if PointDance.hand == nil { PointDance.offer(x: hx, y: hy) }
                else { PointDance.moveHand(x: hx, y: hy) }
                lastMove = Date()
            }
            .onEnded { _ in
                // `letGo()` — the chain empties, and `lock` has nothing left to hold it up.
                PointDance.letGo()
                soundEngine.leaveAll()          // C1's dancers go the way they came: a fade
            })
        .onAppear {
            let seven = PointContent.dimensions.first(where: { $0.n == 7 })
            PointDance.floor(universes: seven?.universes.map(\.stars) ?? [])
            run()
        }
        .onDisappear { PointDance.leaveRegister(); soundEngine.leaveAll() }
    }

    /// The figure's own loop. It drives `PointDance.update`, hands each new body its VOICE,
    /// and closes the ensemble's detune by the chain's `lock`.
    ///
    /// **C1'S DANCERS ARE WIRED HERE, IN THE SAME PASS AS THE CHAIN.** `join`, `ensemble`,
    /// `leaveAll` and `DancerVoice` were built and measured and left undriven — and an
    /// undriven voice waiting on a mechanic that has just landed is exactly how the design's
    /// own four uncalled mechanisms happened. It is not filed behind the chain; it lands with
    /// it.
    private func run() {
        guard !dancing else { return }
        dancing = true
        Task {
            var last = Date()
            while !s.done {
                try? await Task.sleep(nanoseconds: 33_000_000)
                let now = Date()
                let dt = now.timeIntervalSince(last); last = now
                let lock = PointDance.update(dt)
                // every body that took a hand this frame gets its own voice at its own
                // harmonic of 852 — `joinedQ`, so none is lost when several join at once
                while let body = PointDance.takeJoined() {
                    soundEngine.join(min(4, max(0, body.chain)))
                }
                // `ensemble(lock)` — the detune closes as they come into time
                soundEngine.ensemble(lock: lock)
                pace = lock                       // the bar IS the lock now, not a pace meter
                if let g = PointDance.gaveNow, g > s.revealed { s.give() }
            }
            dancing = false
        }
    }
}
