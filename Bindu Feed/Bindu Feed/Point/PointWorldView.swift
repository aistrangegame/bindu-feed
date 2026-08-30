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
    @Binding var path: [FeedRoute]
    let onReturn: () -> Void
    /// The Point's half of `handedToRegister` — the same contract the Universe's fall uses.
    /// TRUE while a universe body or a star reading is open: the register owns the vertical,
    /// and `#where` steps aside because a star is held.
    var onHold: (Bool) -> Void = { _ in }

    @EnvironmentObject private var soundEngine: SoundEngine
    @State private var selectedUniverse: PointUniverse?   // the middle tier: dimension → universe → star
    @State private var openStar: PointStar?
    /// `#carry.done` — this reading has been taken up; the label dims and stops asking.
    @State private var carryDone = false
    @State private var goodnight = false
    /// How much of the reading has been given — the world behind recedes by it.
    @State private var revealed = 0

    // The solfeggio ladder — one tone per dimension (285…852), the ladder rising as he descends.
    private let ladder: [Double] = [285, 396, 417, 528, 639, 741, 852]

    private var dim: PointDimension? { PointContent.dimensions.first { $0.n == dimensionN } }

    // ── C1 · THE WIRING · a register reaches its law ─────────────────────────────
    //
    // `7-STATE-OF-THE-BUILD.md` §3.1: *"`PointReadings.swift` and `PointWorlds.swift` contain
    // no `soundEngine` calls at all."* They still do not, and should not — they are model and
    // view files with no engine in scope. Each world hands up the ONE quantity it is about
    // (`PointLawSignal`) and this, which owns the engine, applies the law.
    //
    // Ordered by REGISTER, not by law, so each is walkable as a unit.
    //
    // WHAT CAN BE ASSERTED OFFLINE, and what cannot:
    //   · the LAWS themselves — every one is measured in `RegisterLawTests` against a
    //     rendered graph. Those numbers are settled.
    //   · this MAPPING — pure, and `PointLawTests` asserts each case reaches its own law.
    //   · **the SIGNALS need the device.** That `part` actually reaches 1, that `panX` spans
    //     its spread, that `settle` bottoms out at `H*0.7` — those are gestures, and no
    //     offline render can walk them. This is exactly the boundary where a "verified" claim
    //     could go soft, so it is named: **the laws are measured, the wiring is read, and
    //     the walk is owed.**
    private func apply(_ signal: PointLawSignal) {
        switch signal {
        case .admitted(let f):            soundEngine.narrow(f)
        case .drawn(let f):               soundEngine.widen(f)
        case .parted(let f, let floor):   soundEngine.unveil(f, floor: floor)
        case .load(let f):                soundEngine.bear(f)
        case .facing(let c):              soundEngine.reflect(c)
        case .away(let f):                soundEngine.distance(f)
        }
    }

    // ── #carry · TAKE IT UP ──────────────────────────────────────────────────────
    // `The Instrument v3.html:4682` the affordance, `:4621-4627` its dress, `:5334`
    // `sealCarry()`. *"Taking it up is weightless — no list, no collection, nothing
    // counted. What it leaves behind is company: one more mote in orbit around the one
    // particle, at every scale, for the rest of the walk."*
    //
    // WHAT THIS RESOLVES. When walk-continuity landed I declined to store `carry`,
    // `carved` and `crossed`, on the grounds that E5 lets a ceremony colour itself by them
    // and nothing actually read them — so a stored field would have been an unwired slot.
    // That was right on the evidence, and it stays right about the CEREMONIES: neither
    // `The Return v2.html` nor `The Rite v3.html` ever reads `W.carry` after declaring it.
    // What was missing was the OTHER consumer — `:5826`, the instrument restoring its own
    // CARRY, and `:5752`, the motes. Building this does not add an unused field; it
    // completes one that only looked unused because its reader had never been built.
    // Fourth and last instance of that shape, after DEALS, WORDS and TURN IT.
    @ViewBuilder
    private func carryAffordance(_ star: PointStar) -> some View {
        VStack { Spacer()
            VStack(spacing: 17) {
                Button { sealCarry(star) } label: {
                    Text("take it up")
                        .spaceMonoTracked(10, em: 0.24)
                        .foregroundStyle(Color(hex: "#FFF0E7").opacity(carryDone ? 0.35 : 0.88))
                        .padding(.bottom, 4)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(Color(hex: "#E5533C")
                                .opacity(carryDone ? 0 : 0.46)).frame(height: 1)
                        }
                }
                .buttonStyle(.plain).disabled(carryDone)
                Button { letGo() } label: {
                    Text("let it go")
                        .spaceMonoTracked(8.5, em: 0.2)
                        .foregroundStyle(BinduTheme.inkPrimary.opacity(0.34))
                }
                .buttonStyle(.plain)
            }
            // `#carry` is `bottom:54` in the comp, where nothing else stands. The app puts
            // the descend door at `bottom:34` in the same corner — an element the comp does
            // not have — so at 54 the two overlap and both become unreadable. Raised to
            // clear it. A DELIBERATE geometry divergence: the design's number is right for
            // the design's screen, and copying it here would produce the collision the
            // number exists to avoid.
            .padding(.bottom, 118)
        }
        .animation(.easeInOut(duration: 1.5), value: carryDone)
    }

    /// `:5334-5343`. Push, mark the surface kept, sound it, and let go on its own after
    /// 2400ms — he does not have to dismiss what he decided to keep.
    private func sealCarry(_ star: PointStar) {
        guard !carryDone else { return }
        PointJourney.carried.append((title: star.t, hue: hue))
        carryDone = true
        soundEngine.carryTone(hz: PointLadder.drone(dimensionN).hz)   // `B.carry(reg.hz)` — the register's own tone
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            if openStar != nil { letGo() }
        }
    }

    /// `:5344` — the reading closes and the world comes back. The claim releases here and
    /// on `onDisappear`, so no exit path leaves `carryDone` armed for the next star.
    private func letGo() {
        park()
        withAnimation { openStar = nil }
        revealed = 0
        carryDone = false
    }

    /// D4.6 · `:5318-5320`. **EVERY EXIT PARKS**, which is the claim-release rule applied to
    /// state rather than to a claim: `letGo`, both `onClose` paths and `onDisappear` all pass
    /// through here, so no way out of a reading drops what it had given. The polite path is
    /// the one that always works and therefore the one that proves nothing.
    private func park() {
        guard let star = openStar else { return }
        PointPending.park(dimension: dimensionN, star: star.key, revealed: revealed)
    }

    private var hue: Color { Color(hex: PointContent.hues["m\(dimensionN)"] ?? "#C0392B") }

    var body: some View {
        ZStack {
            // THE WORLD IS DRAWN BEHIND THE READING, NOT REPLACED BY IT.
            //
            // This was a mutually-exclusive `if / else if` chain, so at level 2 the world was
            // unmounted and there was nothing to recede — which is why the seven coefficients
            // sat read-but-unimplemented since Pass 5. `A = p·(1 − dsp·k)` needs a `p` to
            // multiply.
            //
            // It also closes A5: the world's own chrome (its header, its `‹ the enclosure`)
            // stays OUT of the reading, because only the material is drawn behind — the
            // chrome belongs to the level he is not on.
            if let star = openStar, let u = selectedUniverse {
                PointWorld(dimensionN: dimensionN, stars: PointWorlds.placed(u), hue: hue,
                           onOpen: { _ in }, quiet: true, onLaw: apply)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .opacity(PointRecede.worldAlpha(dimension: dimensionN,
                                                    revealed: revealed, open: true))
                    .animation(.easeInOut(duration: 1.1), value: revealed)

                PointReading(dimensionN: dimensionN, star: star, hue: hue,
                             onClose: { park(); withAnimation { openStar = nil }; revealed = 0 },
                             onReveal: { revealed = $0 })

                carryAffordance(star)
            } else if let star = openStar {
                // reached without a universe (the debug star hook) — no world to recede
                PointReading(dimensionN: dimensionN, star: star, hue: hue,
                             onClose: { park(); withAnimation { openStar = nil }; revealed = 0 })
            } else if let u = selectedUniverse {
                // LEVEL 1 — the universe as a constellation: its stars in the world's native
                // material (Amendment §7.3: the universe, drawn inside the figure).
                PointWorld(dimensionN: dimensionN, stars: PointWorlds.placed(u), hue: hue,
                           onOpen: { s in
                    // `world-five.js:49-50` — *"at the exact instant every other star sounds
                    // its arrival, this one is silent: a true null, the only deliberate
                    // silence in the Point. Sakshi's register — it witnesses, it does not
                    // teach."* `mute` is set at `:161` and read by nothing in the reference
                    // build; it is read HERE. This silence is the design, never a gap to fix.
                    if s.key != "r-guard" {
                        soundEngine.riteVoice(hz: ladder[(dimensionN - 1) % 7], dur: 6)
                    } else {
                        // C1 · **THE CALLER `nul` NEVER HAD.** The comment above already
                        // names it — *"a true null, the only deliberate silence in the
                        // Point"* — and the app honoured it by NOT PLAYING A SOUND. That is
                        // absence, and `Claude Design Round 2/design-source/spine-sound.js:164` is explicit that it is not:
                        // *"Not a fade — the voice summed against itself, which is exact.
                        // The stone tail already in the air keeps decaying, so the hall dies
                        // away and then there is nothing."*
                        //
                        // Skipping a call leaves the bed running underneath. The null takes
                        // the bed itself to zero while the room's tail keeps going, which is
                        // audibly a different event and is the one the register is about.
                        soundEngine.nul()
                    }
                    PointJourney.openedStars.append(s.t)
                    // D4.6 · `takeBack` — the same star returns to what it had already given.
                    revealed = PointPending.takeBack(dimension: dimensionN, star: s.key) ?? 0
                    withAnimation(.easeInOut(duration: 0.8)) { openStar = s }
                }, onLaw: apply)
                .ignoresSafeArea()

                VStack(spacing: 6) {
                    Text(u.name.uppercased()).font(.spaceMono(9)).tracking(2).foregroundStyle(hue)
                    Text(u.sub).font(.loraItalic(12)).foregroundStyle(BinduTheme.inkSecondary)
                        .multilineTextAlignment(.center).lineLimit(2).padding(.horizontal, 44)
                    Spacer()
                }
                .padding(.top, 46).allowsHitTesting(false)

                VStack {
                    HStack {
                        Button { withAnimation(.easeInOut(duration: 0.6)) { selectedUniverse = nil } } label: {
                            Text("‹ the enclosure").font(.spaceMono(9)).tracking(2)
                                .foregroundStyle(BinduTheme.inkTertiary).padding(16)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            } else if let dim {
                // LEVEL 0 — the dimension holds its named universes (the middle tier).
                PointUniversesView(dim: dim, hue: hue) { u in
                    soundEngine.riteVoice(hz: ladder[(dimensionN - 1) % 7], dur: 5)
                    PointJourney.universes.append(u.name)
                    withAnimation(.easeInOut(duration: 0.7)) { selectedUniverse = u }
                }
                .ignoresSafeArea()

                if dimensionN == 6 {
                    // `spine-axis.js:67-68` — the z:7 `return6` door. *"VI is called The
                    // Return because it is about the same thing. Descend deep enough into
                    // its strata and the kinship becomes a door."* A door carries a LABEL
                    // and a LINE; the app had fused an invented "settle deeper ·" onto the
                    // label and dropped the line entirely. Both restored, verbatim.
                    VStack { Spacer()
                        Text("This depth and that descent are the same room.")
                            .font(.loraItalic(13))
                            .foregroundStyle(BinduTheme.inkSecondary.opacity(0.66))
                            .multilineTextAlignment(.center).padding(.horizontal, 32)
                            .padding(.bottom, 9)
                        Button(action: onReturn) {
                            Text("open the return")
                                .font(.spaceMono(9)).tracking(2).foregroundStyle(hue)
                        }.padding(.bottom, 64)
                    }
                }
                if dimensionN == 7 {
                    VStack { Spacer()
                        Button { $path.pushDissolve(FeedRoute.aperture) } label: {
                            Text("the aperture ›").font(.spaceMono(9)).tracking(2).foregroundStyle(hue)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 64)
                    }
                }

                // The goodnight — "I Love You" at first arrival in this world, in its hue, then gone.
                if goodnight {
                    // D5.11 · beside the particle, at the design's size and alpha, with no
                    // shadow — a shadow is what makes 12pt readable as a headline.
                    Text("I Love You")
                        .font(.loraItalic(PointGoodnight.pointSize))
                        .foregroundStyle(hue.opacity(PointGoodnight.opacity))
                        .offset(x: PointGoodnight.offset.x, y: PointGoodnight.offset.y)
                        .transition(.opacity)
                }
            }
        }
        // I · `narrow(f)`. *"as a star admits him, the two tones converge toward unison. The
        // beat narrowing IS the reading arriving — by the fourth section the world is very
        // nearly one note."* `revealed` runs 0…4 (`PointReadings.swift:116` divides by 4) and
        // the design's own sentence names the fourth section, so the quantity needs no
        // scaling of my invention: it is `revealed / 4`.
        //
        // Sent for EVERY register, not only I. A reading is being admitted wherever he is,
        // and `narrow` is the law of the register he is in — I's is the one the design
        // describes, and the others hold their own beat unless their law moves it.
        .onChange(of: revealed) { _, r in
            if dimensionN == 1 { apply(.admitted(Double(r) / 4)) }
        }
        // EVERY REGISTER LEAVES AS IT ARRIVED — see `SoundEngine.releaseRegisterLaws`.
        // Entering must not inherit the previous register's physics, and leaving must not
        // bequeath its own. Both ends, because only one of them is the polite path.
        .onAppear { soundEngine.releaseRegisterLaws() }
        .onDisappear { soundEngine.releaseRegisterLaws() }
        // Lock the axis whenever a world body (selectedUniverse) or a star reading (openStar)
        // is open, so their own drag/scroll wins over the axis travel gesture.
        .onChange(of: openStar != nil) { _, _ in syncAxisLock() }
        .onChange(of: selectedUniverse != nil) { _, _ in syncAxisLock() }
        // THE HALL, WITHDRAWN. Drawn here rather than in the reading because the reading is
        // carried out at 3.0s and the withdrawal runs to 5.4s — it has to have somewhere to
        // finish. `world-five.js:200-201`: it LOOMS (1.16) where everything else recedes.
        .overlay {
            if dimensionN == 5 {
                TimelineView(.animation) { _ in
                    let bk = MirrorHall.bk()
                    if bk > 0 {
                        Color(hex: "#EAFBF8").opacity(bk * 0.86)
                            .ignoresSafeArea().allowsHitTesting(false)
                    }
                }
            }
        }
        // Released on the way out, like the fall's four scoped paths: a register that is no
        // longer mounted must never still be holding the vertical.
        .onDisappear { park(); onHold(false); PointYantra.shared.readingOpen = false; carryDone = false }
        .onAppear {
            syncAxisLock()
            if let dim { PointJourney.enteredDims.append(dim.name) }
            if !PointGoodnight.shown.contains(dimensionN) {
                PointGoodnight.shown.insert(dimensionN)
                // `:998` — 2400ms AFTER arrival, not on it. Said as he arrives it is a
                // greeting and the world is announcing itself; said once he is already here
                // it is an aside.
                DispatchQueue.main.asyncAfter(deadline: .now() + PointGoodnight.delaySeconds) {
                    withAnimation(.easeInOut(duration: PointGoodnight.fadeSeconds)) { goodnight = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + PointGoodnight.holdSeconds) {
                        withAnimation(.easeInOut(duration: PointGoodnight.fadeSeconds)) { goodnight = false }
                    }
                }
            }
        }
    }

    /// Was: told the axis to lock itself while a reading was open. The axis is never locked
    /// now — the vertical always walks it, which is what makes a register reachable at all
    /// (`B0.2`). A reading that needs to keep the vertical claims it locally, the way the
    /// fall does; nothing reaches up and disables the instrument.
    /// This was an EMPTY BODY. Declared, wired into three call sites, commented with exactly
    /// what it does — and doing nothing, which is indistinguishable from a lock that is on.
    ///
    /// The cost was not cosmetic. Every Point reading takes a vertical or near-vertical drag
    /// (II travels outward on it, III parts on it, IV presses on it), and with the axis still
    /// listening the drag walked the axis to the next register instead. WORLD II WAS NOT
    /// WALKABLE BY ANY HAND — the first upward swipe carried you from The Turn to The Veil
    /// with the reading still open behind it.
    ///
    /// `AxisTravel.handedToRegister` already existed and is enforced at the source in
    /// `applyDrag`, so no call path can route around it. It only ever needed to be told.
    private func syncAxisLock() {
        onHold(openStar != nil || selectedUniverse != nil)
        // The figure recedes under a READING specifically — not under the universe body,
        // where the nodes are standing on the figure and it is the thing being looked at.
        PointYantra.shared.readingOpen = openStar != nil
    }
}

// The goodnights are said once per dimension per session, then gone.
/// **SHARED STATIC · any test suite touching this is `.serialized`** (§10 TENTH SHAPE).
/// The rule is *at creation, not at flake* — `PointReturn` and `PointDance` cost a pass to
/// learn it. Nothing tests this yet; the first suite that does inherits the trap.
/// D5.11 · **THE GOODNIGHT IS A WHISPER AT THE PARTICLE, NOT A HEADLINE IN THE FRAME.**
///
/// `comps/The Point v9.html:42-43` — `#ily` is **12px** Lora italic, `opacity 0 → .8` over a
/// `1.1s` transition, no shadow; `:991-999` places it at the particle's own rect (`left+16`,
/// `top-5`), tints it with the dimension's hue, waits **2400ms after arrival** and takes it
/// away **2600ms** later.
///
/// The app said it at **21pt centred in the frame with a 10pt hue shadow, immediately on
/// arrival**. Every one of those is the same edit in a different property: a thing said
/// beside the particle, quietly, once he is already here — turned into the first thing the
/// world does and the largest thing on it.
///
/// **THE DELAY IS THE PART THAT IS NOT COSMETIC.** Said on arrival it is a greeting, and the
/// world is announcing itself. Said 2400ms later it is an aside — he has arrived, looked, and
/// then it is mentioned. The design's own name for the mechanism is `ilyDone`: once per
/// dimension, ever.
enum PointGoodnight {
    static var shown = Set<Int>()

    /// `:998` — `setTimeout(…, 2400)`.
    static let delaySeconds: Double = 2.4
    /// `:997` — `setTimeout(() => remove('in'), 2600)`.
    static let holdSeconds: Double = 2.6
    /// `transition: opacity 1.1s ease`, the same both ways.
    static let fadeSeconds: Double = 1.1
    /// `font-size:12px`, and `#ily.in{opacity:.8}`.
    static let pointSize: Double = 12
    static let opacity: Double = 0.8
    /// `left + 16`, `top - 5` from the particle's own rect — beside it, not over it.
    static let offset = (x: 16.0, y: -5.0)
}

// A deeper reading, generated live in the Arch register and kept (point-levels.js generate()).
// Its five fields ARE the offline fallback at `point-levels.js:210-211` — verbatim-ported,
// audit-marked correct, and explicitly kept by the E3 ruling.
struct PointDeeper: Codable { let arrival, teaching, thread, practice, ascent: String }

/// LEVEL 3 — the descent, one true layer deeper. Shared by all seven worlds, as it is in
/// the design (`descent` is a single global element there). This is NOT the sheet E3 kills:
/// the sheet was level 2's generic four-section reading; this is level 3, and its five-field
/// offline fallback at `point-levels.js:210-211` is verbatim-ported and correct.
struct PointDescentDoor: View {
    let star: PointStar
    let hue: Color
    @State private var deeper: PointDeeper?
    @State private var reaching = false
    @State private var reached = false
    @State private var shown = 0                 // stages revealed so far
    @EnvironmentObject private var soundEngine: SoundEngine
    private var cacheKey: String { PointDescentCache.key(for: star) }   // D4.5 · the id, not the title

    /// `[label, text, minor]`, then FILTERED on non-empty (`point-levels.js:1249`). Five is
    /// the ceiling, not the count — and offline it is always FOUR, because the fallback's
    /// `thread` is `''` by design and filters itself out. The two minor stages are set
    /// smaller, dimmer and italic (`.d-stage.minor`, `:1097`).
    private func stages(_ d: PointDeeper) -> [(String, String, Bool)] {
        [("arrival", d.arrival, false), ("the teaching", d.teaching, false),
         ("the thread", d.thread, true), ("the practice", d.practice, true),
         ("the ascent", d.ascent, false)].filter { !$0.1.isEmpty }
    }

    var body: some View {
        // A LAYER IN THE STAGE, not a system modal. `.ovl{position:absolute;inset:0;z-index:12}`
        // is a sibling of the feed inside `#stage` — so this is a full-bleed ZStack, and the
        // door is one item aligned to its bottom.
        //
        // It was a `.fullScreenCover` first, and that silently did nothing: the cover was
        // attached to a `Group` whose `if` renders EMPTY the moment `deeper` is set, so at the
        // instant it should present, its anchor no longer exists. The shaft rose and the
        // figure dimmed on cue — every visible signal said the descent had begun — and the
        // reading it was meant to cover just sat there. Absence again, wearing the shape of
        // something wired.
        ZStack(alignment: .bottom) {
            if deeper == nil {
                // The door, at the foot of the reading.
                VStack(spacing: 0) {
                    if reaching {
                        Text("descending…").spaceMonoTracked(8, em: 0.24)
                            .foregroundStyle(BinduTheme.inkPrimary.opacity(0.3)).padding(.bottom, 34)
                    } else {
                        // `point-levels.js:107` — `<button id="descendBtn">descend onto this
                        // star</button>`. The design DREW this surface and it is not silent
                        // here, so the authored label is the only correct string. It had been
                        // "▽ DESCEND ONE LAYER DEEPER", invented — the seventh instance of an
                        // invented instructional string standing where an authored one belongs,
                        // and the first found by the forward check rather than by memory.
                        Button { Task { await descend() } } label: {
                            Text("descend onto this star").spaceMonoTracked(10, em: 0.2)
                                .foregroundStyle(hue)
                        }
                        .buttonStyle(.plain).padding(.bottom, 34)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [.clear, Color(hex: "#050408").opacity(0.9)],
                                           startPoint: .top, endPoint: .bottom).ignoresSafeArea())
            } else {
                descentOverlay.transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        // THE DESCENT IS AN OVERLAY OVER EVERYTHING, not a panel inside the reading.
        // `.ovl{position:absolute;inset:0;z-index:12;background:rgba(7,8,13,.965)}` (`:1050`)
        // — it covers the world, the plate and the reading, which is why the register content
        // is hidden (`feed.style.opacity=0`, `:1242`) and the yantra goes to `descend` with
        // the shaft raised. A 380pt scroll box inside the reading was the wrong object: it
        // let the world stay legible behind a thing that exists to take the world away.
    }

    @ViewBuilder private var descentOverlay: some View {
        if let d = deeper {
            let st = stages(d)
            ZStack(alignment: .top) {
                Color(red: 7 / 255, green: 8 / 255, blue: 13 / 255).opacity(0.965).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // `.dtopic` — mono 8 / .3em / uppercase / --dhue / centred / mb 34
                        Text(star.t.uppercased()).spaceMonoTracked(8, em: 0.3)
                            .foregroundStyle(hue).multilineTextAlignment(.center)
                            .padding(.bottom, 34)

                        ForEach(Array(st.enumerated()), id: \.offset) { i, sg in
                            VStack(spacing: 0) {
                                // `.d-label` — mono 7.5 / .3em / --dhue at .75 / mb 12
                                Text(sg.0.uppercased()).spaceMonoTracked(7.5, em: 0.3)
                                    .foregroundStyle(hue.opacity(0.75)).padding(.bottom, 12)
                                // `.d-text` 17/1.76 cream · `.minor` 14.5 dim italic
                                Text(sg.1)
                                    .font(sg.2 ? .loraItalic(14.5) : .lora(17))
                                    .lineSpacing(sg.2 ? 10 : 13)
                                    .foregroundStyle(sg.2 ? BinduTheme.inkSecondary : BinduTheme.inkPrimary)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 330)
                            .padding(.bottom, 34)
                            // `.d-stage` — opacity 0 + translateY(12), 2.4s ease on both
                            .opacity(i < shown ? 1 : 0)
                            .offset(y: i < shown ? 0 : 12)
                            .animation(.easeInOut(duration: 2.4), value: shown)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 120).padding(.horizontal, 34).padding(.bottom, 90)
                }
                .scrollIndicators(.hidden)

                if shown >= st.count {
                    HStack {
                        Button { ascend() } label: {
                            Text("‹ ascend").spaceMonoTracked(8.5, em: 0.2)
                                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.3)).padding(10)
                        }.buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.leading, 24).padding(.top, 8)
                    .transition(.opacity)
                }
            }
            // TAP ADVANCES ONE STAGE — it does not skip to the end. `:1256-1260` reveals the
            // NEXT un-revealed stage and nothing more; only when there is no next does the
            // ascent appear. He can outrun the 3400ms clock, one stage at a time; he cannot
            // jump the walk.
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 2.4)) { shown = min(st.count, shown + 1) }
            }
            .task(id: st.count) {
                // `700 + i*3400` (`:1253`), and the ascent at `700 + n*3400` (`:1255`).
                for i in 0..<st.count {
                    let due = 700 + i * 3400
                    try? await Task.sleep(for: .milliseconds(due))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 2.4)) { shown = max(shown, i + 1) }
                }
            }
        }
    }

    // One live layer deeper, in the Arch register — generated once, then persisted per star so a
    // re-descent returns the same reading (point-levels.js cache[k]). Graceful offline fallback.
    /// `:229` — the hall comes back: the figure returns to `walk`, the shaft drops, the
    /// register content is legible again, and the glide runs the other way.
    private func ascend() {
        shown = 0
        deeper = nil
        PointYantra.shared.descending = false
        withAnimation(.easeInOut(duration: 1.4)) { PointYantra.shared.shaft = 0 }
        soundEngine.setAxisGlide(hz: 0, level: 0)
        // C3 · `:1263` — `Snd.glide(PT.cur(), false)`. The comment above already said *"and
        // the glide runs the other way"*; it had nothing to run.
        soundEngine.glide(enclosure: Int(PointYantra.shared.focus.rounded()), down: false)
    }

    private func descend() async {
        guard !reached else { return }
        reached = true
        shown = 0
        // `:206` — `YANTRA.setMode('descend'); YANTRA.shaft=1;`. The figure dims to 0.22 and
        // one shaft of the enclosure's light remains, which is the only thing still lit
        // while he is under it.
        PointYantra.shared.descending = true
        withAnimation(.easeInOut(duration: 1.8)) { PointYantra.shared.shaft = 1 }
        // C3 · `The Point v9.html:1236` — `Snd.glide(PT.cur(), true)`. The enclosure's own
        // tone falls an octave over 2.2s as he goes under. The descent was silent.
        // `PT.cur()` is the enclosure he is in; the app's is `PointYantra.shared.focus`.
        soundEngine.glide(enclosure: Int(PointYantra.shared.focus.rounded()), down: true)
        // persisted?
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode(PointDeeper.self, from: data) {
            withAnimation(.easeInOut(duration: 1.0)) { deeper = cached }
            return
        }
        let held = star.walk.replacingOccurrences(of: "*", with: "")
        let fallback = PointDeeper(
            arrival: "The deeper field is quiet just now — this is the held knowing.",
            teaching: held, thread: "",
            practice: "One breath. Feet on the ground. Eyes soft.",
            ascent: "Carry the one line that landed.")
        guard let key = KeychainService.load("anthropic_api_key"), !key.isEmpty,
              let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            withAnimation(.easeInOut(duration: 1.0)) { deeper = fallback }; return
        }
        reaching = true
        // `point-levels.js:186-196 generate()` — three things the earlier port dropped, and
        // the third is the load-bearing one: the star's DIMENSION, its STATUS in `SM`
        // ("walked" / "in progress" / "seeded"), and a different instruction for a SEEDED
        // star. Fourteen of the 66 are seeded, and for those the descent is his FIRST
        // meeting with the topic, not a layer under a reading he has already walked.
        let dimName = PointContent.dimensions.first { d in
            d.universes.contains { $0.stars.contains(star.key) }
        }?.name ?? ""
        let status = PointStatus.word(star.st)
        let seededBranch = star.st == "s"
            ? "This star is seeded, not yet walked — this is his FIRST TRUE MEETING with the topic: bring its actual substance accurately from its real tradition or science, going well beyond the held reading."
            : "Go one true layer deeper than the held reading — material it did not include."
        let prompt = """
        You are the descent-voice of an instrument called The Point — a nine-enclosure walk a seeker uses \
        to reorient when caught in mental rush. He has descended onto the star "\(star.t)" (\(star.ti)) \
        in the dimension "\(dimName)". The instrument's held reading of this star: "\(held)". \
        Status: \(status).

        Write the descent in the ARCH register — devotion made audible, warmth threaded through precision. \
        Its four frequencies, all present: TEACHING — never declare; name what the reader currently holds, \
        then walk him to primary evidence (actual names, actual texts, actual numbers, terms in their \
        original language) and trust him to arrive. PROTECTIVE — equip, never alarm; fill a gap he didn't \
        know he had. JOY — delight as substrate, legible without exclamation marks. INVITATION — the ending \
        opens a door, never closes on a conclusion. Second person, present tense, no mysticism-clichés. Go \
        \(seededBranch)

        Respond with ONLY a JSON object, no markdown fences, keys: "arrival" (1-2 sentences), "teaching" \
        (4-6 sentences), "thread" (1-2 sentences), "practice" (1-2 sentences), "ascent" (1 sentence). No preamble.
        """
        let body: [String: Any] = ["model": "claude-opus-5", "max_tokens": 1024,
                                   "messages": [["role": "user", "content": prompt]]]
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(key, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        var result = fallback
        if let (data, resp) = try? await URLSession.shared.data(for: req),
           let http = resp as? HTTPURLResponse, http.statusCode == 200,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let content = json["content"] as? [[String: Any]] {
            let text = content.compactMap { ($0["type"] as? String) == "text" ? $0["text"] as? String : nil }.joined()
            let cleaned = text.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "")
            if let lo = cleaned.firstIndex(of: "{"), let hi = cleaned.lastIndex(of: "}"), lo <= hi,
               let d = try? JSONDecoder().decode(PointDeeper.self, from: Data(cleaned[lo...hi].utf8)) {
                result = d
                UserDefaults.standard.set(try? JSONEncoder().encode(d), forKey: cacheKey)   // kept
            }
        }
        reaching = false
        withAnimation(.easeInOut(duration: 1.0)) { deeper = result }
    }
}
