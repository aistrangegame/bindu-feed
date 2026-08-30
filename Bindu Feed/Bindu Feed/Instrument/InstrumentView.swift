import SwiftUI

// THE INSTRUMENT — the continuous axis, one space, not screens. Vertical travel moves
// Z through fourteen membranes (AxisTravel): a register is separated from its neighbour
// by a surface that must be MEANT — push through it and it gives, once, and stands open;
// the sky's edge opens instead to STILLNESS, delivering you to the Light. Crossing is a
// passage, not a snap: the camera leaves the hand and glides across. The one particle
// rides the whole axis and, at the centre, BLOOMS to fill the frame — it stops being a
// dot in a world and becomes the world ("every dot you touched was me"). Each register
// renders its own content when he settles into it.
//
// Wave-6 rebuild (built to spine-travel.js / spine-passage.js verbatim): the membrane
// physics, the stillness gate, the passage throat, the opened-surface memory, and the centre
// bloom are all here — and so are the content worlds: the seven distinct Point worlds
// (PointWorldView), the Universe (UniverseView), and the Light rendered in-axis
// (AxisLightSeam), each mounted in `content` below. The hand-feel constants are the design's
// own; the felt tuning — and the continuous "cathedral" Universe camera — are the Neev walk.

struct InstrumentView: View {
    @Binding var path: [FeedRoute]
    let startZ: Int

    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine

    @StateObject private var travel: AxisTravel
    @State private var lastDragY: CGFloat = 0
    @State private var showRope = false
    @State private var pointHolds = false      // a Point universe or star reading is open

    /// C7.4 · `The Instrument v3.html:5474` — `IMM.on ? 0 : TR.tension*(1 - TR.push*0.35)`.
    /// `pointHolds` is this app's `IMM.on`: inside a reading the axis is locked and the
    /// surface has nothing to say. The `push` term is the relationship worth having — a
    /// surface complains while it HOLDS and eases as it begins to give, so leaning through
    /// quietens it rather than straining it further.
    private var strainDrive: Double {
        AxisSurface.load(tension: travel.tension, push: travel.push, reading: pointHolds)
    }

    /// C7.6 · the passage's own progress, and 0 whenever no passage is running — which is
    /// `:5472`'s `B.rush(0, PS.dir)`. A continuous voice has to be told to stop.
    private var rushDrive: Double { travel.crossing ? travel.passageT : 0 }
    // Set true while a front layer (a Point world body, or a star reading ScrollView) is open,
    // so the axis drag stands down and the card's own scroll/pan works. Without this, the
    // outer `.highPriorityGesture` steals every drag from the presented card.

    // The travelling pitch — log-interpolated between adjacent registers (hzAt(Z)).
    //
    // E2 SAYS "CLAMP TO 13", AND THAT RULING MUST NOT BE APPLIED HERE. It is a fix for the
    // DESIGN'S array, not for this one. `The Instrument v3.html:4155` reads
    // `R[Math.min(14, i+1)].hz` against `SPINE.REG`, which has FOURTEEN entries (0…13) —
    // the pre-Light spine — so at `Z ≥ 8` it indexes 14 and reads `undefined`. Clamping the
    // JS to 13 is right.
    //
    // `Axis.registers` has FIFTEEN, because the Light was added at `z = −5`. Index 13 is d7
    // at 852 Hz and index 14 is the centre at 963. Clamping THIS to 13 would sound the bindu
    // as the Dance — it would silently collapse the last register onto the one before it, at
    // exactly the place the walk is supposed to arrive. The C1 warning box already says it:
    // from the pre-Light extraction take strings only, nothing index-related.
    private func hzAt(_ z: Double) -> Double {
        let i = z + 5
        let lo = max(0, min(14, Int(i.rounded(.down))))
        let hi = max(0, min(14, Int(i.rounded(.up))))
        let f = i - Double(lo)
        let a = Axis.registers[lo].hz, b = Axis.registers[hi].hz
        guard a > 0, b > 0 else { return 136.1 }
        return exp(log(a) + (log(b) - log(a)) * f)
    }

    init(path: Binding<[FeedRoute]>, startZ: Int) {
        self._path = path
        self.startZ = startZ
        self._travel = StateObject(wrappedValue: AxisTravel(startZ: Double(startZ)))
    }

    /// 393 / the live frame width — see `travelGesture`.
    @State private var designScale: Double = 1

    private var z: Double { travel.z }
    private var here: AxisRegister { Axis.nearest(z) }
    private var atSky: Bool { abs(z + 4) < 0.45 }
    private var inUniverse: Bool { ["sky", "region", "world", "fall"].contains(here.key) }

    // Content presence. `here` is always the NEAREST register, so `presence` never drops
    // below 0.65 in a register (0.494 in the centre's +0.62 overshoot) — a mounted register
    // is by construction visible.
    //
    // The Universe band is ONE continuous camera: full across −4…−1, so it does NOT crossfade
    // between its own four registers, only at the band's outer edges. That override used to
    // REPLACE presence, and at each edge it fell far below it — `(z+4.6)/0.6` is 0.17 at
    // z = −4.5 — which is where the dead band came from: the sky on screen, and dead to the
    // hand across z ∈ (−4.6, −4.27), with the feed edge doing the same across (−0.775, −0.5).
    // That second one is `B0.3` still standing in its other form.
    //
    // It is a floor now, not a replacement. The band still keeps the four Universe registers
    // continuously lit (which is its whole job); it can no longer take a register below the
    // presence it would have had on its own.
    private var contentOpacity: Double {
        let presence = Axis.presence(here.i, z)
        guard inUniverse else { return presence }
        let feedFade = max(0, min(1, (-0.5 - z) / 0.5))    // fades in from the feed edge
        let lightFade = max(0, min(1, (z + 4.6) / 0.6))    // fades out toward the Light edge
        return max(presence, min(feedFade, lightFade))
    }

    var body: some View {
        ZStack {
            Color(hex: "#050408").ignoresSafeArea()

            // THE FIELD — the Metal multi-shell atmosphere (InstrumentField.metal). All 15
            // register-shells composited additively every frame at their own scale, so the
            // register forming ahead and the one receding behind are BOTH present as glow.
            // This is the rich "background" that was missing; the CPU shells below are now
            // only the interaction meniscus.
            fieldBackground

            TimelineView(.animation) { _ in
                shells
            }

            // THE YANTRA — one figure, behind the whole Point walk, and the camera is the
            // walk itself. Not nine backdrops: `The Point v9.html:923-937 camera()` drives ONE
            // figure's focus from the scroll position, so what he came through stays visible
            // behind him and what is ahead is a faint promise at the centre.
            //
            // It is the enclosure the registers STAND ON, not decoration behind them — which
            // is why `PointUniversesView` places its universes by re-projecting through this
            // object's own `anchors()` and `toScreen()` rather than drawing its own ring.
            if travel.z > 0.35 {
                PointYantraView()
                    .opacity(min(1, (travel.z - 0.35) / 0.5))
            }

            // The register content, brightening as he settles into it. The Universe band
            // (−4…−1) stays continuously present as one camera (fading only at its feed/light
            // edges) so the flowing camera doesn't pulse dim between the four registers.
            content
                .opacity(contentOpacity)
                // No opacity threshold. `content` is a `switch` on `here.key`, so exactly ONE
                // register is ever mounted and it is always the nearest — and with the floor
                // above, a mounted register is never dimmer than 0.494. There is no state in
                // which content is on screen but invisible, so a threshold could only ever
                // take away something visible, which is what the old `> 0.55` did at both
                // edges of the Universe band.
                //
                // The design gates interaction PER AFFORDANCE and never by a global opacity —
                // the door by its four conditions (`:1549-1573`), the mouth by `desc ≥ 0.84`
                // (`uni-fall.js:24`), the lens by its own band. Those all still stand. What
                // you can see, you can touch; while a passage carries you, you can't.
                .allowsHitTesting(!travel.crossing)

            // The stillness gate — at the sky, the way on thins with stillness, not force.
            if travel.thin > 0.01 {
                stillnessGate
            }

            // The one particle — rides centre → crown, and blooms into the world at +9.
            particle

            // The particle's self-name at this scale (#pname), floated just beneath it.
            particleNameLabel

            // The ladder (#rail) — where he is on the fifteen-register axis.
            ladderRail

            // The seam — the two directions, named, at the Feed's own scale.
            axisSeam

            // The passage throat — a wormhole inward, a whitehole outward.
            if travel.crossing {
                ThroatView(t: travel.passageT, dir: travel.passageDir, hue: here.color)
                    .ignoresSafeArea().allowsHitTesting(false)
            }

            // `flare` — `The Chrome.html:211`. THE TWO GATES, at `t = 0.34` and `0.68`.
            //
            // *"They exist so the crossing has a middle."* Drawn tighter and dimmer than the
            // crossing flash above: the flash says a membrane GAVE, the gates say the passage
            // is still under way. A 5.4s glide with nothing in it reads as a stall, and this
            // is what tells the hand it is being carried rather than stuck.
            //
            // Never fires on a slip-through, because `AxisPassage.gatesCrossing` returns none
            // when `swift` — the difference the whole ledger rests on, and it must be visible
            // rather than merely true.
            if travel.gateFlare > 0.01 {
                Circle().fill(RadialGradient(
                    colors: [here.color.opacity(0.22 * travel.gateFlare), .clear],
                    center: .center, startRadius: 0, endRadius: 240 * (1 + travel.gateFlare)))
                    .ignoresSafeArea().allowsHitTesting(false)
            }

            // The passage flash on crossing.
            if travel.flash > 0.01 {
                Circle().fill(RadialGradient(
                    colors: [here.color.opacity(0.5 * travel.flash), .clear],
                    center: .center, startRadius: 0, endRadius: 400 * (1 + travel.flash)))
                    .ignoresSafeArea().allowsHitTesting(false)
            }

            // The back affordance — pinned to the TOP via a full-height top-aligned frame (a
            // VStack+Spacer collapses to centre inside this ZStack). In the Universe the ‹ leaves
            // the sky (glides back to the Feed).
            //
            // TWO CHEVRONS OWNED THIS CORNER. This one and `ReadingHead`'s, stacked, while a
            // reading was open. They are NOT redundant and neither is deletable: this one
            // leaves the instrument (`popToRootDissolve`) or the sky; the reading's closes the
            // reading. They are MIS-LAYERED — and stacked they are worse than ambiguous,
            // because the one a hand reaches for first drops him out of the whole instrument
            // when he meant "back one step".
            //
            // The design never has to choose: its reading is an opaque `.ovl` over the host
            // chrome, so during a reading only the reading's own back exists. That is the same
            // recession `#where` and `#pname` now make, on the same signal.
            if !pointHolds {
            HStack {
                Button {
                    // B7.5 · one scale at a time. `The Universe v3.html:1701-1710` walks him
                    // out in four presses; this dumped him to the Feed from anywhere, so the
                    // Universe's whole depth collapsed to one exit and the way out did not
                    // retrace the way in.
                    if inUniverse {
                        if let out = UniverseBack.step(from: z) { travel.stepOut(to: out) }
                        else { travel.exitToFeed() }
                    }
                    else if !path.isEmpty { $path.popToRootDissolve() }
                } label: {
                    Text("‹").font(.system(size: 22)).foregroundStyle(BinduTheme.inkTertiary)
                        .frame(width: 40, height: 40)          // a real hit target
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            // #where — the words for where he is. Never a number, never a progress bar.
            whereBlock
        }
        .background(GeometryReader { g in
            Color.clear.onAppear { designScale = 393 / max(1, Double(g.size.width)) }
                       .onChange(of: g.size.width) { _, w in designScale = 393 / max(1, Double(w)) }
        })
        .navigationBarBackButtonHidden(true)
        .contentShape(Rectangle())
        // NOT high-priority any more, and never locked. The vertical belongs to the axis and
        // the horizontal to the register, so there is nothing to win: `.simultaneously` lets
        // both run and each takes the component that is its own. Deleting `axisLocked` is
        // what closes B0.1 (it armed only in `.onChange(of:)`, which SwiftUI does not fire on
        // first appearance, so entering directly at the sky arrived un-armed), B0.2 (the lock
        // made the four Universe registers mutually unreachable) and B0.3 (the dead band at
        // the Feed edge, where the axis was locked and the Universe not yet hit-testable).
        .simultaneousGesture(travelGesture)
        // THE ROPE, FROM ANYWHERE — `The Instrument v3.html:5874-5877`, in its own capitals:
        // *"the rope is reachable from ANYWHERE now. The particle is always present, so the
        // rope is always one gesture from the hand."* The "now" is the point: this was
        // deliberately widened past the brief's Door-and-gate scope, and Instrument v3
        // outranks prose on the ladder. All fifteen registers, always.
        //
        // I narrowed it to the gate to stop it eating world IV, and that was the wrong fix —
        // it bought one reading by taking the rope away from fourteen registers. The design
        // had already solved it on the SAME LINE:
        //
        //     if(!turnEl.classList.contains('on') && !ropeEl.classList.contains('on'))
        //         pressT = setTimeout(…openRope…, 1100);
        //
        // — an exclusion list, not a narrowing. The rope declines where another surface is
        // already holding the gesture. `PressClaim` is that list, in the same shape as
        // `handedToRegister`: the surface that owns a sustained press claims it, and the rope
        // stands down THERE and nowhere else.
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 1.1).onEnded { _ in
                guard !showRope, !PressClaim.isClaimed else { return }
                withAnimation(.easeInOut(duration: 0.8)) { showRope = true }
            }
        )
        .overlay {
            if showRope {
                DoorRopeOverlay(onExit: { _ in
                    withAnimation(.easeInOut(duration: 0.8)) { showRope = false }
                })
                .transition(.opacity)
            }
        }
        // THE POINT ASKS FOR THE CLIMBING BED, and only the Point. Enclosure = `z - 1` (gate
        // 0, d1…d7 1…7, the centre 9) — the same arithmetic the yantra's camera uses, so the
        // pitch he hears and the enclosure he is standing in can never disagree. Off the
        // Point band the field bed resumes: a room that hums rather than climbs.
        .onChange(of: here.key) { _, _ in
            let onPoint = travel.z >= 0.5
            soundEngine.setContext(onPoint
                ? .point(enclosure: Int(PointYantra.focus(forAxisZ: travel.z).rounded()))
                : .base)
        }
        .onChange(of: travel.z) {
            soundEngine.setAxisGlide(hz: hzAt(travel.z), level: min(0.03, travel.speed * 8))
            // The axis IS the yantra's camera. `focus(forAxisZ:)` carries the ten-against-nine
            // arithmetic; the hue mixes between the two enclosures he is between.
            PointYantra.shared.setEnclosure(PointYantra.focus(forAxisZ: travel.z))
        }
        .onChange(of: travel.crossing) { _, crossing in
            if crossing { soundEngine.axisGive(hz: here.hz) }   // it breaks — the strain snaps
        }
        // C7.6 · `:5450` — `B.rush(PS.t, PS.dir)`, every frame of the crossing.
        .onChange(of: rushDrive) { _, t in soundEngine.setRush(t: t, dir: travel.passageDir) }
        // C7.4 · `:5474` — `B.strain(IMM.on ? 0 : TR.tension*(1 - TR.push*0.35))`.
        //
        // **OBSERVED AS THE WHOLE EXPRESSION, NOT AS ITS TERMS.** Watching `tension` alone
        // would miss a frame where only `push` moved, and one `.onChange` per term is three
        // chances to forget the fourth. The design passes one number; so does this.
        .onChange(of: strainDrive) { _, f in soundEngine.setStrain(f) }
        .onChange(of: travel.thin) { _, thin in
            // E4.2 — continuous, following the accumulator rather than firing once at 0.1.
            // `travel.down` is the hand arriving: the drone goes in ~0.2s, not on a decay.
            soundEngine.setStillness(fill: thin, touching: travel.down)
            // C3.3 · `:5484` fires `sayGate()` at `gateAcc > 700` — 700ms into a 4600ms gate,
            // **15.2% of the way**, early rather than on arrival. The app's gate is the
            // velocity-based `dwell` rather than a flat countdown, so the proportion is what
            // ports, not the millisecond: the line comes when he has only just begun to be
            // still, which is the point of saying it at all.
            if travel.dwell > 0.152, TravOnce.sayGate() {
                DispatchQueue.main.asyncAfter(deadline: .now() + TravOnce.holdSeconds) {
                    withAnimation(.easeInOut(duration: 2.4)) { TravOnce.endHold() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + TravOnce.revertSeconds) {
                        TravOnce.revert()
                    }
                }
            }
            // C3.4 · `:5475` — the resting line, on the first hard lean before anything has
            // been crossed. `sayOnce` carries its own guards; this only supplies the state.
            if TravOnce.sayOnce(crossed: travel.crossed, tension: travel.tension) {
                DispatchQueue.main.asyncAfter(deadline: .now() + TravOnce.holdSeconds) {
                    withAnimation(.easeInOut(duration: 2.4)) { TravOnce.endHold() }
                }
            }
        }
        .onAppear {
            // The camera must be set BEFORE the first frame, not only when z next changes.
            // `onChange` fires on transitions; a launch parked at a register (the deep links,
            // and `startZ` generally) has no transition, so without this the whole Point walk
            // draws at `BAND[0]` — the outermost enclosure — no matter which register he is
            // standing in, and the universes stand on that ring because it is the one the
            // figure is actually drawing. Measured: the bhupura came out 145pt half-width at
            // avarana III, which is `s≈99` — `BAND[0]`, not `BAND[3]`'s 217.
            PointYantra.shared.setEnclosure(PointYantra.focus(forAxisZ: travel.z))
            // C7.11 · a DRIFT-PAST leaves a trail and strikes nothing. The threshold tone
            // moved to `onLand` below, where the design puts it.
            travel.onCross = { reg in
                soundEngine.axisTrail(hz: reg.hz)               // the register forming / left behind
            }
            travel.onLand = { reg in
                if reg.key == "gate" {
                    soundEngine.axisGate(hz: reg.hz)
                    PointJourney.reachedGate = true
                } else if reg.key == "centre" {
                    // `resolve` — `spine-sound.js`. **APP-OWN CALLER, AND LABELLED SO.**
                    //
                    // The fourth specified-never-invoked mechanism, after `nul`, `distance`
                    // and `send`: built and MEASURED, defined in the design, and fired from
                    // nowhere in it. `Coverage/10-OWED.md` §7 enumerates all eight sound
                    // calls in `The Point v9.html` — `resolve` is not among them — so **there
                    // is no upstream call site to compare this against, and a future session
                    // must not look for one.**
                    //
                    // WHY HERE. `resolve` performs nine just intervals on 852 collapsing to a
                    // unison and then 852 → 963: the axis arriving at the centre. The app
                    // already holds that moment exactly — `AxisModel.swift:94`, `z: 9`,
                    // `key: "centre"`, `hz: 963`, `sub: "the point, at last"`. Same z, same
                    // name, same pitch. The design *describes* this crossing precisely and
                    // plays a generic `B.threshold` at it, as it does at every register.
                    //
                    // The alternative was to leave the crossing that means *the point, at
                    // last* sounding identical to every other one — and sameness costs most
                    // exactly where the instrument's whole climb ends. Same reasoning as the
                    // other three: specified by the design, never invoked by it, completed
                    // here.
                    //
                    // **REVERT, one line:** `soundEngine.spineThreshold(hz: reg.hz)` in place
                    // of `resolve()`, and this branch deleted.
                    soundEngine.resolve()
                } else {
                    soundEngine.spineThreshold(hz: reg.hz)   // `B.threshold(S.at(Z).hz)` — Instrument v3:5354
                }
            }
            soundEngine.setContext(.base)
            travel.start()
            soundEngine.startAxisGlide()
        }
        .onDisappear { travel.stop(); soundEngine.stopAxisGlide() }
    }

    // MARK: - Travel (the hand feeds AxisTravel; the engine owns the physics)

    /// The axis drag. VERTICAL ONLY — the horizontal belongs to whichever register is up
    /// (The Instrument v3.html:5906-5926), so this never reads `translation.width`.
    ///
    /// `K = 393/frameWidth` normalises the delta to the design's own frame (:5904) so a
    /// gesture means the same thing on every screen size; without it a 430pt Pro Max
    /// travelled ~9% further per swipe than the 393pt frame the constants were tuned on.
    /// `C2.8`.
    private var travelGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { v in
                let delta = v.translation.height - lastDragY
                lastDragY = v.translation.height
                travel.setDown(true)
                travel.applyDrag(Double(delta) * designScale)
            }
            .onEnded { _ in
                lastDragY = 0
                travel.setDown(false)
            }
    }

    // MARK: - The ladder (#rail) — where he is on the fifteen-register axis

    // #where (v3 :4348-4351 + paintWhere :4979-4992, and The Chrome.html:12-16) — a CENTRED
    // BLOCK at top:100px, not a top-edge label. Three lines, and the register's name is in
    // ITS OWN CASING: "the Light", "a region", "The Chamber" — never uppercased.
    //
    //   .top  Space Mono 9 · .3em · uppercase · rgba(237,232,227,.34)   ("III · 3 of 7")
    //   .nm   serif 23 · -.01em · #EDE8E3 · margin-top 5
    //   .sub  italic 13 · line-height 1.6 · rgba(237,232,227,.48) · max-width 300 · margin-top 9
    //
    // Repainted only when the register KEY changes (`.id`), crossfading over 1.1s — it does
    // ── #seam · THE TWO DIRECTIONS, NAMED ────────────────────────────────────────
    // `The Instrument v3.html:4653-4656`, gated at `:5619`:
    //     seam.classList.toggle('on', Math.abs(Z)<0.30 && GR.weather==='met')
    //
    // It speaks only at the Feed's own scale, and only on a day that has been met — the
    // axis naming what lies either way from where he is standing, once there is something
    // in both directions to name. `:4385-4389`: left/right 30, bottom 112, two flex
    // columns with an 18 gap, Space Mono 7.5 / .14em / uppercase at `rgba(237,232,227,.24)`,
    // line-height 1.7, and a 1.2s opacity transition.
    //
    // `store.todayMet` is nil until something has read the day. Nil is NOT unmet: the
    // design does not know the weather before the Door reads it either, so the seam simply
    // does not speak yet.
    private var axisSeam: some View {
        let near = max(0, min(1, (0.30 - abs(travel.z)) / 0.08))
        let on = store.todayMet == true ? near : 0
        return VStack {
            Spacer()
            HStack(alignment: .top, spacing: 18) {
                seamColumn("pull down · outward", "everything that has met you")
                seamColumn("pull up · inward", "everything you have gathered")
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 112)
        }
        .opacity(on)
        .animation(.easeInOut(duration: 1.2), value: on)
        .allowsHitTesting(false)
    }

    private func seamColumn(_ a: String, _ b: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(a.uppercased()).spaceMonoTracked(7.5, em: 0.14)
            Text(b.uppercased()).spaceMonoTracked(7.5, em: 0.14)
        }
        .lineSpacing(7.5 * 0.7)                       // line-height 1.7 on a 7.5 face
        .foregroundStyle(Color(hex: "#EDE8E3").opacity(0.24))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // not re-tick with Z. Hidden on the ground, past the centre, and inside a passage.
    private var whereBlock: some View {
        let w = here.whereBlock
        // `withStar` — the design's FOURTH hide condition (`:4979-4992`), and it was the one
        // never wired, because nothing on the Point side ever said a star was held. It showed
        // as the register's name printed straight through the star's own title.
        let hidden = abs(travel.z) < 0.42 || travel.z > 8.6 || travel.crossing || pointHolds
        return VStack(spacing: 0) {
            if let top = w.top {
                Text(top.uppercased())
                    .font(.spaceMono(9)).tracking(2.7)          // .3em × 9
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.34))
            }
            Text(w.name)                                        // its own casing
                .font(.lora(23))
                .tracking(-0.23)                                // -.01em × 23
                .foregroundStyle(BinduTheme.inkPrimary)
                .padding(.top, w.top == nil ? 0 : 5)
            if let sub = w.sub {
                Text(sub)
                    .font(.loraItalic(13))
                    .lineSpacing(13 * 0.6)                      // line-height 1.6
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.48))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .padding(.top, 9)
            }
        }
        .id(here.key)
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // `#where{top:100px}` is measured from the phone's own top edge — the comp draws no
        // status bar, so its 100 already allows for one. Laid inside the safe area this sat
        // at 159 on this device, and had done since Pass B: the verification checked that it
        // was IMPLEMENTED, not that it was POSITIONED, and there is nothing beside it for the
        // error to show against. See the frame-mismatch note in `RoomView`.
        .ignoresSafeArea()
        // `:5646` shows it at `0.9*(1−hush)*(1−immA)`. The app has neither `hush` nor
        // `immA`, so the base 0.9 is what survives the port — 1.0 was the app's, not the
        // design's.
        .opacity(hidden ? 0 : 0.9)
        .animation(.easeInOut(duration: 1.1), value: here.key)
        .animation(.easeInOut(duration: 1.1), value: hidden)
        .allowsHitTesting(false)
    }

    // The right-edge rail (v3 #rail, verbatim): 15 register ticks + 14 surface-dots between
    // them, column-reverse (register 0 the Light at the bottom, register 14 the centre at the
    // top — up is inward, matching travel). Ticks are bone hairlines, right-anchored; the
    // current register is a widened red needle (17px), its neighbours half-lit (13px). A
    // surface is a hollow bone point until it has been MEANT — then filled red and kept.
    private var ladderRail: some View {
        Canvas { ctx, size in
            let regs = Axis.registers
            let n = regs.count                                   // 15
            let step = 21.0
            let railH = Double(n - 1) * step
            let top = (size.height - railH) / 2
            let edge = size.width - 13                           // `right:13px`
            let left = edge - 17                                 // the widest tick's own left edge
            let curI = Axis.nearest(z).i
            let opened = travel.openedSurfaces
            let bone = Color(hex: "#EDE8E3")
            let red = Color(hex: "#E5533C")
            // THE NEEDLE GROWS TOWARD THE EDGE, not away from it. `#rail i` carries an
            // explicit `width`, so the flex container's cross-axis default resolves to
            // flex-start: every tick shares a LEFT edge at `W − 13 − 17` and the current one
            // extends RIGHTWARD. Anchored right and grown leftward it has the same silhouette
            // at rest and the opposite motion as he travels — and the motion is what reads.
            for reg in regs {
                let yy = top + railH - Double(reg.i) * step
                let d = abs(reg.i - curI)
                let w: Double = reg.i == curI ? 17 : (d == 1 ? 13 : 9)
                let col: Color = reg.i == curI ? red.opacity(0.85) : bone.opacity(d == 1 ? 0.42 : 0.16)
                ctx.fill(Path(CGRect(x: left, y: yy - 0.5, width: w, height: 1)), with: .color(col))
            }
            // surface-dots (14) at the midpoints, aligned to the edge; hollow until opened
            for s in 0..<(n - 1) {
                let yA = top + railH - Double(s) * step
                let yB = top + railH - Double(s + 1) * step
                let ym = (yA + yB) / 2
                // `align-self:flex-end; margin-right:3px` → centre at `W − 13 − 3 − 1.5`
            let cxs = edge - 4.5, r = 1.5
                let rect = CGRect(x: cxs - r, y: ym - r, width: r * 2, height: r * 2)
                if s < opened.count && opened[s] {
                    ctx.fill(Path(ellipseIn: rect), with: .color(red.opacity(0.55)))     // meant → filled, kept
                } else {
                    ctx.stroke(Path(ellipseIn: rect), with: .color(bone.opacity(0.20)), lineWidth: 0.5)
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .opacity(travel.crossing ? 0 : 1)
        .animation(.easeInOut(duration: 0.5), value: here.i)
    }

    // The particle's self-name at the current scale (v3 Spine.bindu.name — 9 strings by Z, not
    // one per register: the whole interior reads "the point at the centre of the enclosure").
    /// C5.6 · the nine names live in `InstrumentNames` so the domain can be walked.
    private func particleName(_ z: Double) -> String { InstrumentNames.particle(z) }

    // #pname — the name floats just under the particle in red mono; hidden on the Feed ground
    // and once the particle begins to become the centre (Z > 7.9).
    //
    // AND HIDDEN OUTRIGHT UNDER A READING, not dimmed. It is drawn at a FIXED point
    // (`height*0.5 + 22`) while the reading scrolls past it, so it collided with a different
    // line of body text every frame — twice in one screenshot, mid-sentence both times. The
    // dim reached the figure and not this, because this is the instrument's chrome and not
    // the yantra's.
    //
    // Hide, not dim, and the design agrees twice over: its reading is an `.ovl` at
    // `z-index:12` over `rgba(7,8,13,.965)`, so `#pname` is simply COVERED — 0.22 is not what
    // the design shows here, it is what a transparent app has to choose instead. And a mono
    // caption crossing serif body text does not read as ground at any alpha; it reads as
    // damage. The figure recedes because it is behind the words; a caption ON the words has
    // no receded state that is honest.
    private var particleNameLabel: some View {
        // C5.6 · **`inUniverse` MADE FOUR AUTHORED NAMES UNREACHABLE.**
        //
        // `The Instrument v3.html:5646` hides `#pname` iff `onGround(|Z| < 0.42) || Z > 7.9`.
        // The app added `inUniverse`, which is the whole `sky · region · world · fall` band —
        // and **four of the particle's nine canon names live there**: *a dot in the sky*, *a
        // light in the room*, *the story, close*, *the seed of the well* (`:1070-1080`, and
        // `particleName` below carries all nine verbatim). They could never appear. Four
        // authored strings, present in the app, addressable by no reachable state.
        //
        // This is Rule 4's backwards half (§10) in its quietest form: not a string deleted and
        // not one invented, but one **built and then fenced off** — and no string checker can
        // see it, because `check_authored` proves the literal is THERE. Only asking *which z
        // reaches it* finds this, and nothing asks that mechanically.
        //
        // `crossing` and `pointHolds` are the app's own and stay, RECORDED rather than
        // silently kept: inside a passage the camera owns the vertical and a caption tracking
        // a name the hand cannot change is noise; when the Point holds, the register owns the
        // vertical for the same reason. Neither is in the design because the design has
        // neither state.
        //
        // `0.42`, not `0.4` — the design's own number.
        let hidden = travel.crossing || z > 7.9 || pointHolds
            || (here.key == "feed" && InstrumentNames.onGround(z: z))
        return GeometryReader { geo in
            Text(particleName(z).uppercased())
                .font(.spaceMono(7.5)).tracking(1.5)
                .foregroundStyle(Color(hex: "#E5533C").opacity(0.52))
                .position(x: geo.size.width / 2, y: geo.size.height * 0.5 + 22)
        }
        .allowsHitTesting(false)
        .opacity(hidden ? 0 : 1)
        .animation(.easeInOut(duration: 1.0), value: hidden)
    }

    // MARK: - The field (the Metal multi-shell atmosphere)

    // Hosts InstrumentField.metal as the base layer. `position` arrives in the view's own
    // point-space; the shader recentres it and composites every shell. Uniforms are fed live
    // from travel.z, the clock, and the breath. The interaction-driven uniforms (sweep, hand,
    // sync, dwell) rest at neutral here and are raised in Phase 2 as those gestures land.
    private var fieldBackground: some View {
        GeometryReader { geo in
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 100000)
                let wx = UniWeather.of(store.currentUniRoomId)
                let skyArray = store.uniSky
                Rectangle()
                    .fill(Color.black)
                    .colorEffect(ShaderLibrary.instrumentField(
                        .float2(geo.size),                 // uRes
                        .float(Float(t)),                  // uT
                        .float(Float(z)),                  // uZ  — the live axis coordinate
                        .float(Float(breath.value)),       // uBr
                        // C4.5 · uSync / uSpin — VII's pace and the frame turning with its
                        // lane. `The Instrument v3.html:5588` feeds `DANCE.sync` and
                        // `DANCE.spin * 0.55`. `PointDance.lock` is the app's chain coming
                        // into time — the same quantity by a different construction — and it
                        // is static, so the axis can read it without the Point being mounted.
                        // A world he is not in reads 0, which is what `leaveRegister()` leaves.
                        .float(Float(PointDance.lock)),    // uSync
                        .float(Float(PointDance.lock * 0.55)),  // uSpin
                        // C4.5 · uReveal — **THE CENTRE BLOOM.** `:5589` is
                        // `Math.max(0, (Z - 8.6) / 0.9)`: nothing until the last 0.4 of the
                        // axis, then a ramp to 1 exactly at the centre (z 9). The shader's
                        // `col += HUES[14] * uReveal * (0.05 + 0.05*uBr)` has been multiplying
                        // by a hard zero, so the arrival at *the point, at last* has had no
                        // light of its own — the one place on the axis where that matters.
                        .float(Float(InstrumentField.reveal(z: z))),  // uReveal
                        // B0.5 · THE SKY ANSWERS STILLNESS. `The Instrument v3.html:1242-1248`
                        // bends every room's light toward the centre as `dwell` fills, and
                        // `mSky` has computed that term all along against a hard `0`.
                        // `travel.dwell`, not `travel.thin` — see the note on the property.
                        .float(Float(travel.dwell)),       // uDwell
                        .float2(0, 0),                     // uSweep  (memory sweep — Phase 2)
                        // uWx — THE LIVE ROOM'S OWN WEATHER. This was the design's FALLBACK
                        // literal `(0.4, 0.02, 0.2)` (`uni-deep.js:91`'s `|| [...]`) hardcoded
                        // for every register in every room, so the thirteen have never had
                        // their own turbulence, drift or grain. The Forge churns at 0.92; the
                        // Watcher is nearly still at 0.12; the Forgetting is 0.86 grain.
                        .float3(Float(wx[0]), Float(wx[1]), Float(wx[2])),
                        // C4.5 · uHand — the veil's parting, carved out of its own density in
                        // the shader. `The Instrument v3.html:2967` `[hand.x, hand.y, open*0.62]`,
                        // fed at `:5592`. `PointVeil` is the bridge; both sides existed and had
                        // no wire between them.
                        .float3(Float(PointVeil.uHand.0), Float(PointVeil.uHand.1),
                                Float(PointVeil.uHand.2)),  // uHand
                        // uRm — 39 floats, the rooms' light-wells with a DERIVED density.
                        // `ROOMS_FALLBACK` in the shader pins every one at a flat 0.6.
                        // `.floatArray` supplies BOTH the pointer and its length — the Metal
                        // side declares `device const float *uRm, int uRmCount`. Passing the
                        // count as a second argument breaks the stitch: "Function stitching
                        // failed: instrumentField", which is a link error, not a maths one.
                        .floatArray(skyArray)
                    ))
                    // C3.8 · **THE WORLD HE IS LEAVING GOES SOFT BEFORE IT GOES AWAY.**
                    // `:3480` `blur(zv) = min(8, |zv|·300)`, applied to the field at `:5612`.
                    // The `300` is the character: axis speeds are tiny — a firm drag is about
                    // `0.02` — so it turns a number that looks like nothing into 6px of
                    // softening, and the cap at 8 keeps the fastest travel from erasing the
                    // atmosphere. Without it the field is equally sharp standing still and at
                    // full speed, and nothing in the frame says he is moving.
                    .blur(radius: FieldBlur.radius(zv: travel.speed))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Shells (the interaction meniscus only — the shader owns the atmosphere)

    private var shells: some View {
        // C3.5 · the wobble is a function of TIME, so this canvas needs a clock it did not
        // have. A still ring is the defect being fixed, not a cheaper version of the fix.
        TimelineView(.animation) { tl in
        let t = tl.date.timeIntervalSinceReferenceDate
        Canvas { ctx, size in
            let R0 = min(size.width, size.height) * 0.5
            let cx = size.width / 2, cy = size.height / 2
            // The near membrane, felt as a meniscus that tightens as he leans into it.
            let ten = travel.tension
            if ten > 0.02 {
                // C3.5 · the membrane's BODY — `The Instrument v3.html:3519-3532`. It was a
                // plain stroked ellipse: no wobble, no beads, no fill. A ring that does not
                // wobble has no surface; it reads as a drawn circle rather than something
                // being leaned into, which is the whole sensation a register boundary gives.
                MembraneRing.draw(ctx, cx: cx, cy: cy, R0: R0, t: t, color: here.color,
                                  tension: ten, push: travel.push, gate: false, still: 0)
            }
        }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - The stillness gate (the sky thins with stillness)

    private var stillnessGate: some View {
        GeometryReader { geo in
            let R0 = min(geo.size.width, geo.size.height) * 0.5
            let still = travel.thin
            let rim = R0 * (1.10 + still * 1.30)
            ZStack {
                // C3.6 · the same ring, the opposite gesture. `:3511-3512` — *"the gate does
                // not tighten as he nears it — it THINS as he stops."* Its wobble DIES into
                // stillness (`0.030*(1−st)`) where the membrane's grows with the push.
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in
                        MembraneRing.draw(ctx, cx: size.width / 2, cy: size.height / 2,
                                          R0: min(size.width, size.height) * 0.5, t: t,
                                          color: Color(hex: "#EDE3CE"),
                                          tension: 1, push: 0, gate: true, still: still)
                    }
                    .allowsHitTesting(false)
                }
                // C3.3 · **ONCE, EVER — and in the design's own medium.** This was shown on
                // every visit, lowercase, at 12pt: a caption that reappears is a caption, and
                // the design's is *"the one thing the surface is ever allowed to say, once,
                // ever"*. Lora italic 13.5, `rgba(237,232,227,.46)`, 2.4s in and out.
                if let line = TravOnce.showing {
                    Text(line)
                        .font(.loraItalic(13.5))
                        .foregroundStyle(Color(.sRGB, red: 237/255, green: 232/255,
                                               blue: 227/255, opacity: 0.46))
                        .position(x: geo.size.width / 2, y: 178)
                        .transition(.opacity)
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - The one particle (rides centre → crown, blooms into the world at the centre)

    private var particle: some View {
        let inward = max(0, min(1, z / 9))                    // 0 at feed, 1 at centre
        let fill = max(0, min(1, (z - 8.6) / 0.95))           // paints the whole frame red at the centre
        let cy = 0.5 - 0.368 * inward                         // H/2 → H*0.132
        // C5.7 · `3.4 + br*0.9`, not `5.0 + 4.0*br`. The app's resting particle was twice the
        // design's diameter and breathed 4.4× as hard — see `BinduParticleRadius`.
        let r = BinduParticleRadius.radius(z: z, breath: breath.value)
        return GeometryReader { geo in
            ZStack {
                if fill > 0.001 {                             // it becomes the world
                    Rectangle().fill(BinduParticle.core.opacity(fill)).ignoresSafeArea()
                }
                Circle()
                    .fill(RadialGradient(colors: [BinduParticle.core, BinduParticle.deep.opacity(0)],
                                         center: .center, startRadius: 0, endRadius: r))
                    .frame(width: r * 2, height: r * 2)
                    .position(x: geo.size.width / 2, y: geo.size.height * cy)
                    // `:5742` — the halo grows with the company, `1 + CARRY.length*0.05`.
                    .shadow(color: BinduParticle.core.opacity(0.5 * breath.value),
                            radius: min(r, 40) * (1 + Double(PointJourney.carried.count) * 0.05))

                // THE COMPANY — `:5750-5758`. *"What he carried up. The same being, in more
                // company than it kept when he went down. Never numbered, never listed,
                // always there."* One mote per carried reading, in that reading's own hue,
                // at the golden angle so no two ever sit on each other, drawn at whatever
                // scale the particle is at and collapsing into it as it becomes the world.
                if !PointJourney.carried.isEmpty {
                    TimelineView(.animation) { tl in
                        let t = tl.date.timeIntervalSinceReferenceDate
                        Canvas { ctx, size in
                            let cx = size.width / 2, ccy = size.height * cy
                            for (i, c) in PointJourney.carried.enumerated() {
                                let ang = t * 0.07 + Double(i) * 2.399     // the golden angle
                                let rr = (r * 4.6 + 11 + Double(i) * 2.4) * (1 - fill * 0.96)
                                let px = cx + cos(ang) * rr, py = ccy + sin(ang) * rr
                                ctx.fill(Path(ellipseIn: CGRect(x: px - 8, y: py - 8, width: 16, height: 16)),
                                         with: .radialGradient(
                                            .init(colors: [c.hue.opacity(0.85), c.hue.opacity(0)]),
                                            center: CGPoint(x: px, y: py), startRadius: 0, endRadius: 8))
                                ctx.fill(Path(ellipseIn: CGRect(x: px - 1.5, y: py - 1.5, width: 3, height: 3)),
                                         with: .color(c.hue.opacity(0.95)))
                            }
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Per-register content

    @ViewBuilder private var content: some View {
        switch here.key {
        case "d1", "d2", "d3", "d4", "d5", "d6", "d7":
            PointWorldView(dimensionN: here.z - 1, path: $path,
                           onReturn: {
                               store.markDeparture(z: travel.z)
                               $path.pushDissolve(FeedRoute.returnCeremony(nil))
                           },
                           onHold: { held in
                               pointHolds = held
                               travel.handVerticalToRegister(held)
                           })
        case "centre":
            PointRevealView(path: $path)
        case "gate":
            AxisGateView()
        case "sky", "region", "world", "fall":
            // The Universe's scale IS the axis (`axisZ`), so nothing is locked and nothing
            // competes: the vertical walks the axis, the horizontal is the register's own.
            // `onDrawIn` is the tap's inward impulse — the Universe asks, the axis travels.
            UniverseView(register: here,
                         axisZ: travel.z,
                         onDrawIn: { travel.drawIn($0) },
                         onHandVertical: { travel.handVerticalToRegister($0) },
                         onRegisterDrift: { travel.setRegisterDrifting($0) },
                         path: $path,
                         onFall: { story in
                             // he crossed from HERE — the Return puts him back at this depth
                             store.markDeparture(z: travel.z)
                             // It carries the story he descended into. It used to pass `nil`,
                             // and the Return then fell back to its daily rotation — he
                             // arrived somewhere he had not been going. `B5.3`.
                             $path.pushDissolve(FeedRoute.returnCeremony(story))
                         },
                         onExit: { travel.exitToFeed() })
        case "feed":
            AxisFeedSeam { if !path.isEmpty { $path.popToRootDissolve() } }
        case "light":
            AxisLightSeam { $path.pushDissolve(FeedRoute.light) }
        default:
            EmptyView()
        }
    }
}

// THE PASSAGE — the crossing drawn as a throat (spine-passage.js): perspective rings
// scrolling through the tunnel with an aperture flooding at the far end. Inward is a
// wormhole (the world rushes outward past him, light pours from the point); outward a
// whitehole (the sky un-collapses on arrival). ≈ the full three-act draw; the throat +
// aperture are here.
private struct ThroatView: View {
    let t: Double; let dir: Double; let hue: Color
    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let R0 = min(size.width, size.height) * 0.5
            let run = pow(t, 1.28) * 3.4 * dir
            for i in 0..<34 {
                var zz = (Double(i) / 34.0 + run).truncatingRemainder(dividingBy: 1.0)
                if zz <= 0.02 { zz += 1 }
                let r = R0 * 0.085 / zz
                guard r < R0 * 2.5 else { continue }
                let a = (1 - zz) * 0.5 * (0.55 + 0.45 * sin(Double(i) * 2.1))
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                           with: .color(hue.opacity(a)), lineWidth: 0.6 + (1 - zz) * 2.0)
            }
            let ap = pow(max(0, (t - 0.28) / 0.72), 2.5)
            if ap > 0 {
                let ar = R0 * (0.02 + ap * 2.3)
                ctx.fill(Path(ellipseIn: CGRect(x: cx - ar, y: cy - ar, width: ar * 2, height: ar * 2)),
                         with: .radialGradient(.init(colors: [.white.opacity(0.5 * ap), hue.opacity(0.2 * ap), .clear]),
                                               center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: ar))
            }
        }
    }
}

// The gate (Z+1) — the deal, the threshold inward. Names the seven dimensions that lie ahead
// so he knows there is somewhere to go (wayfinding: the gate was a dead end before).
/// The gate (Z+1).
///
/// It used to draw four things, all of them invented: its own name (which `#where` now
/// renders from the register), a sub-line — *"everything you know, arranged"* where canon
/// is **"the deal"** — an instruction, *"keep pulling inward"*, and a listing of the seven
/// dimension names. None exists in any design file.
///
/// What belongs here is the gate's DEAL: five canon strings at `canon/point-content.js:422-428`,
/// pinned to `DEALS[0]` by `The Instrument v3.html:5098`. The register is literally named
/// *"the gate · the deal"* and the deal is the one thing it did not say (`D2.1`, BLOCKER).
///
/// Porting them is Pass 5 (`HANDOFF-BUILD-LIST.md` §3). Until then this renders ABSENCE —
/// which is the rule: an unwired slot renders nothing, never an invention.
/// The gate (Z +2) — `PointGateView`, which carries the five canon DEALS.
///
/// This was `EmptyView()` from the Rule-1 sweep until Pass 5: the register was real, the
/// slot was real, and the only thing in it had been invented ("keep pulling inward"). The
/// sweep was right to take that out and right to leave the register bare until the content
/// arrived. `canon/point-content.js:422-428` is the content.
private typealias AxisGateView = PointGateView

/// The Feed seam (Z 0).
///
/// The name and the sub-line are `#where`'s now — the register carries them, and canon for
/// this one is **"the turn"**, not the *"life size — the turn"* that was invented here. Both
/// duplicated lines are gone; what is left is the affordance, which is a door, not a label.
private struct AxisFeedSeam: View {
    let onEnter: () -> Void
    var body: some View {
        Button(action: onEnter) {
            Text("enter the feed ›")
                .font(.spaceMono(10)).tracking(2).foregroundStyle(BinduTheme.colorBindu)
        }
    }
}

// The Light register (Z−5) — the dawn material itself (S-L01): an ember low in the sky,
// a horizon band, steam rising before he arrived. Hour-aware — the future looks different
// at six and at noon because he does. Reached by the stillness gate; "stand inside" opens
// the full ceremony (the scenes, the carve).
private struct AxisLightSeam: View {
    let onEnter: () -> Void
    @EnvironmentObject private var breath: Breath

    private var hourWarm: Double {                        // <4 night · <7 dawn · <11 morning · <15 high · <20 evening
        let h = Calendar.current.component(.hour, from: Date())
        switch h { case ..<4: return 0.2; case ..<7: return 0.55; case ..<11: return 0.8; case ..<15: return 1.0; case ..<20: return 0.7; default: return 0.25 }
    }

    var body: some View {
        ZStack {
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    let hy = size.height * 0.60
                    let warm = hourWarm
                    // the horizon — dawn ground
                    ctx.fill(Path(CGRect(x: 0, y: hy, width: size.width, height: size.height - hy)),
                             with: .linearGradient(.init(colors: [Color(hex: "#C9A07A").opacity(0.10 + 0.10 * warm), .clear]),
                                                   startPoint: CGPoint(x: 0, y: size.height), endPoint: CGPoint(x: 0, y: hy)))
                    // the ember, low, breathing
                    let ex = size.width / 2, ey = hy - 8
                    let er = 26.0 + 10 * breath.value
                    ctx.fill(Path(ellipseIn: CGRect(x: ex - er, y: ey - er, width: er * 2, height: er * 2)),
                             with: .radialGradient(.init(colors: [BinduParticle.core.opacity(0.5 + 0.3 * warm), .clear]),
                                                   center: CGPoint(x: ex, y: ey), startRadius: 0, endRadius: er))
                    // steam, rising before he arrived
                    for i in 0..<16 {
                        let seed = Double(i)
                        let phase = (t * 0.06 + seed * 0.13).truncatingRemainder(dividingBy: 1)
                        let sx = ex + sin(seed * 2.3 + t * 0.2) * (30 + seed * 4)
                        let sy = ey - phase * size.height * 0.5
                        let a = (1 - phase) * 0.10 * warm
                        ctx.fill(Path(ellipseIn: CGRect(x: sx - 1.5, y: sy - 1.5, width: 3, height: 3)),
                                 with: .color(Color(hex: "#EDE3CE").opacity(a)))
                    }
                }
            }
            .ignoresSafeArea().allowsHitTesting(false)

            // A3 — THE REGISTER IS NAMED ONCE. This printed "the Light" and "what has not
            // yet been" while `#where` printed the identical pair from `Axis.registers` — at
            // z −5 all four of its hide conditions are false, so both stood on screen at once,
            // differing only in size (Lora 20 vs 23) and colour.
            //
            // `#where` is the design's object (`:4348-4351`, the centred block at top:100) and
            // names every register; the seam is the register's CONTENT and offers the way in.
            // So the seam keeps its door and drops the title it was repeating.
            VStack(spacing: 12) {
                Spacer()
                Button(action: onEnter) {
                    Text("stand inside ›").font(.spaceMono(10)).tracking(2).foregroundStyle(Color(hex: "#EDE3CE"))
                }.padding(.top, 6)
                Spacer().frame(height: 150)
            }
        }
    }
}
