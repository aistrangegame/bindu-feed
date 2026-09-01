# Coverage/12 — THE SIBLING-CONSTANT SWEEP

**Run 2026-08-31.** 264 sibling groups enumerated across the whole design corpus · all 264
checked against the app · all 131 non-matching adversarially refuted.

## Why

`The Instrument v3.html:5645` gives `#where` **no** base opacity constant; `:5646` opens
`#pname` with `0.9`. The port had them the other way round — the right number on the wrong
sibling, and its absence on the right one. It survived four passes because:

- Two adjacent chrome captions: a reader sees `0.9` on one and `1.0` on the other and
  concludes somebody weighed them against each other.
- The comment justifying it **cited `:5646`** — `#pname`'s line — and quoted `#pname`'s
  expression to justify `#where`'s number. A **correct citation of the wrong element**, so
  `check_citations` verifies it and every string checker passes.
- **Both rows were CLOSED**: C5.2 (BLOCKER) and C5.6 (MAJOR).

It was found by accident. This sweep asks the question on purpose.

## Result

| verdict | n | |
|---|---:|---|
| MATCHED | 82 | each member carries its own constant |
| NOT-PORTED | 76 | no member has an app expression — an absence, not a mis-pairing |
| ONE-MISSING | 41 | one member kept its constant, the other silently did not |
| COLLAPSED | 38 | both given ONE value where the design distinguishes them |
| BOTH-WRONG | 21 | each carries a plausible number, neither is the design's |
| UNCLEAR | 6 | blocked on an unresolved design-precedence question |

**48 of the 131 refutations changed the verdict — 37%.** That rate is the whole argument for
the refute phase: a single agent's read of a pairing is a first draft. An earlier §10 sweep
had eight of eight corrected; this one is better and still nowhere near trustworthy unattacked.

**NO `TRANSPOSED` VERDICT SURVIVED.** The seed instance is repaired (`dd5076b`) and no second
clean A-has-B's-value swap exists. What the sweep found is the fault's *neighbours* — the
same porting-by-eye, one step less tidy.

## Where the 106 live findings sit

| | n | |
|---|---:|---|
| **over a CLOSED row** | 33 | a row states the app matches the design and it does not |
| **unowned** | 72 | no audit row covers the constant at all — a register gap, not a wrong close |
| over an OPEN row | 0 | already known to be unfinished; this adds the specific constant |
| no row cited | 1 | |

**The 72 unowned are the larger half, and they are a different problem.** They are not rows
closed wrongly; they are constants the audit never enumerated. `AUDIT.md` is organised by
SURFACE, and a constant is not a surface — so a pair of sibling values has no natural row to
live in unless one of them happens to break something a reader noticed.

## Over a CLOSED row — a row asserts the app matches, and it does not

33 groups — 15 COLLAPSED · 9 ONE-MISSING · 8 BOTH-WRONG · 1 UNCLEAR

### BOTH-WRONG — `canon-travel-node-smoothing-constants` · rows `C7.1`, `C7.4`, `C7.6`, `E4.6`

**Design** — Five setTargetAtTime time constants inside one try block, `canon/spine-sound.js:47-51` (B.travel):
· o frequency → 0.07 s — `v.o.frequency.setTargetAtTime(hz,t,0.07)` (:47)
· o2 frequency → 0.07 s — `v.o2.frequency.setTargetAtTime(hz*1.006,t,0.07)` (:48)
· tone gain → 0.11 s — `v.g.gain.setTargetAtTime(s*0.030,t,0.11)` (:49)
· bandpass frequency → 0.14 s — `v.bp.frequency.setTargetAtTime(hz*2.4,t,0.14)` (:50)
· noise gain → 0.16 s — `v.n.gain.setTargetAtTime(s*s*0.022,t,0.16)` (:51)
The ordering is the design's statement: PITCH is the quickest to answer (0.07), the LEVEL lags it (0.11), and the noise half lags further still (0.14, 0.16) — the tone finds the new register before its loudness settles, and the air arrives last.

**App** — The port is `AxisGlideVoice`, "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/AxisTones.swift:106-142". It smooths on the audio thread with raw per-sample one-pole coefficients instead of τ:

· o frequency → `curHz += (goal.hz - curHz) * 0.0006   // smooth pitch glide` — AxisTones.swift:129
· o2 frequency → NO INDEPENDENT SITE. The twin is derived from the already-smoothed `curHz` at AxisTones.swift:133 (`twinPhase += 2 * .pi * (curHz * 1.006) / sampleRate`), so it inherits member 1's constant exactly. The design also gives these two 0.07/0.07, so this collapse is faithful.
· tone gain → `curLevel += (goal.level - curLevel) * 0.0009` — AxisTones.swift:130
· bandpass frequency → NO PORT. `AxisGlideVoice` has no noise source and no bandpass; it is two sines and nothing else.
· noise gain → NO PORT. `0.022` does not occur anywhere in the Swift sound layer.

Converted at the file's own 48 kHz (k = 1 − e^(−1/(fs·τ))):
· design 0.07 s = k 0.00029757 ; app has 0.0006 → τ ≈ 0.0347 s (2.0× too fast)
· design 0.11 s = k 0.00018938 ; app has 0.0009 → τ ≈ 0.0231 s (4.75× too fast)
Neither app number is the design's, and neither is a mis-copy of a sibling's — they are invented.

Related sites, same voice, not this group: the level LAW `min(0.03, travel.speed * 8)` at "/Users/ashrey/Bind

**Comment** — NONE. There is no citation to be wrong: the app's two smoothing lines carry no design reference at all. AxisTones.swift:129 has only the trailing `// smooth pitch glide`; :130 has no comment; the class header at :103-105 says "Lock-driven targets, smoothed on the audio thread" and names no file or line. `check_citations` therefore has nothing to check on this group — the known #where/#pname instance hid behind a correct citation of the wrong element, this one hides behind no citation at all.

Two near-misses worth naming, both clean on inspection:
· "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu F

**Evidence** — THE FINDING IS TWO-PART, and one part is a shape the audit row does not record.

1 · MEMBERS 4 AND 5 ARE NOT PORTED. `B.travel` is a tone half AND a noise half — two oscillators through a lowpass, plus a looped noise buffer through a bandpass at `hz*2.4`. `AxisGlideVoice` (AxisTones.swift:106-142) builds only `phase`/`twinPhase` sines. No `createBufferSource` equivalent, no biquad, no `0.022`, no `2.4` multiplier. `grep 0.022` across the Swift tree returns only RiteTones' ink lean and a UniRegions colour. So members 4 and 5 have no app expression to compare, and their 0.14/0.16 never crossed.

2 · MEMBERS 1 AND 3 ARE BOTH-WRONG, AND THEIR RELATION IS INVERTED. This is the part worth carrying back. The design's two constants are not just two numbers, they are an ORDER: 0.07 on the pitch against 0.11 on the gain means the level is 1.57× SLOWER than the pitch — the tone lands on the new reg

**Refutation** — Survives every refutation attempt. (1) Design verbatim: canon/spine-sound.js:47-51 reads exactly as quoted, all five lines, one try block; upstream "Claude Design Round 1/The Instrument v3.html":4178-4182 is character-identical, so no competing design source exists. (2) App verbatim: AxisTones.swift:129 `curHz += (goal.hz - curHz) * 0.0006          // smooth pitch glide` and :130 `curLevel += (goal.level - curLevel) * 0.0009`, both per-sample inside the frameCount loop; the twin at :133 derives from the already-smoothed curHz, so member 2 truly has no independent site and its collapse is faithful (design gives 1 and 2 the same 0.07). (3) Invented, not ported: grep for 0.0006/0.0009 across the repo hits no .js/.html/.md design file at all — only AxisTones.swift and two unrelated test files.

### BOTH-WRONG — `canon-travel-register-peak-gains` · rows `C7.3`, `C7.4`, `C7.5`, `C7.6`, `C7.8`, `C7.9`, `E4.7`
*The refutation corrected this from the checker's first verdict.*

**Design** — All nine located in `/Users/ashrey/Bindu Feed/canon/spine-sound.js`:

1. B.travel — `v.g.gain.setTargetAtTime(s*0.030,t,0.11)` — :49  (peak 0.030)
2. B.trail — `gn.gain.linearRampToValueAtTime(0.026/(i+1.6),t+0.5)` — :63  (i∈[0,1] → **0.01625** and **0.01000**, a 1.625:1 taper)
3. B.strain — `this._sf.g.gain.setTargetAtTime(f*f*0.030,t,0.12)` — :82  (peak 0.030)
4. B.give — `gn.gain.setValueAtTime(0.055,t)` — :92  (peak 0.055)
5. B.carry — `gn.gain.linearRampToValueAtTime(0.034/(i*0.6+1),st+0.25)` — :104  (0.0340 / 0.02125 / 0.01545)
6. B.rush — `this._rs.g.gain.setTargetAtTime(env*0.042,t,0.08)` — :124  (peak 0.042)
7. B.gate — `gn.gain.linearRampToValueAtTime(0.048,t+0.05)` — :135  (peak **0.048**)
8. B.thin — `this._th.g.gain.setTargetAtTime(f*f*0.026,t,0.35)` — :154  (peak 0.026)
9. B.ungrip — `gn.gain.linearRampToValueAtTime(0.024,t+0.45)` — :165  (peak **0.024**)

Nine named voices, seven distinct values. Pre-existing collisions: travel/strain at 0.030, trail/thin at 0.026. gate (0.048) and ungrip (0.024) are the loudest and the quietest of the nine and sit exactly 2:1 apart — the widest deliberate separation in the file.

**App** — All app paths absolute under `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/`.

1. **travel** → `AxisGlideVoice` (`Sound/AxisTones.swift:106-142`), level set by `SoundEngine.setAxisGlide` — `Sound/SoundEngine.swift:1459`: `glideVoice?.set(hz: hz, level: min(0.03, level))`; driver `Instrument/InstrumentView.swift:340`: `level: min(0.03, travel.speed * 8)`. **Ceiling 0.03 = design's 0.030 ✓** (slope wrong — design is `min(1, speed*150)*0.030` = `min(0.030, speed*4.5)`; that is C7.2's recorded "1.8× too loud", not a peak fault).
2. **trail** → `Sound/SoundEngine.swift:1504-1507`: `AxisVoice(… twinRatio: 2.0, peak: 0.026, … mode: .twin)`. `.twin` mixes as `(sin(phase)+sin(twinPhase))*0.5` (`Sound/AxisTones.swift:80`), so **each partial is 0.013 — the two are EQUAL.** Design gives 0.01625 and 0.01000. **The numerator 0.026 is ported; the divisor `(i+1.6)` is not.**
3. **strain** → `Instrument/AxisModel.swift:454`: `(c * c * 0.030, 300 + c * 1500)` ✓ MATCHED.
4. **give** → `Sound/SoundEngine.swift:1531`: `peak: 0.055` ✓ MATCHED.
5. **carry** → `Instrument/AxisModel.swift:478`: `static func peak(step i: Int) -> Double { 0.034 / (Double(i) * 0.6 + 1) }` ✓ MATCHED (taper intact).
6. **rush** → `Instrument/AxisModel.swift:467`: `(env * 0.042, …)` ✓ MATCHED.
7. **gate** → `Sound/SoundEngin

**Comment** — **NONE of the known kind** — no comment on one member cites another member's design line. Every design citation in the travel-register port resolves to its own element:

- `SoundEngine.swift:1508-1509` (strain) → `canon/spine-sound.js:70-85` ✓ strain's own block
- `SoundEngine.swift:1521,1533` (give) → `canon/spine-sound.js:87-96` and `:95` ✓ give's own block
- `SoundEngine.swift:1535` (rush) → `canon/spine-sound.js:110-127` ✓ rush's own block
- `AxisModel.swift:450` (strain) → `:80-83` ✓ · `AxisModel.swift:457` (rush) → `:122-125` ✓
- `AxisModel.swift:471` (carry) → `canon/spine-sound.js:97-1

**Evidence** — **WHAT WAS MEASURED.** All nine design values read from `/Users/ashrey/Bindu Feed/canon/spine-sound.js` (full 177-line read, not a grep). All nine app sites located by ROLE, not by name — the app renames every one: `B.travel`→`AxisGlideVoice`/`setAxisGlide`, `B.strain`→`AxisSurface.strain`+`SurfaceNoiseVoice(q:7)`, `B.rush`→`AxisSurface.rush`+`SurfaceNoiseVoice(q:0.9)`, `B.carry`→`CarryVoicing.peak`/`carryTone`, `B.thin`→`StillnessVoice`. **All nine are ported; none is NOT-PORTED.**

**THE FINDING · gate and ungrip are COLLAPSED onto 0.03, and 0.03 is travel's number.**
```
design   travel 0.030   gate 0.048   ungrip 0.024      (three distinct, gate:ungrip = 2:1)
app      travel 0.03    gate 0.03    ungrip 0.03       (one value, three voices)
```
`0.048` and `0.024` appear nowhere in the Swift source as sound gains. This is the memory's recorded consequence — *"the design has four distin

**Refutation** — MEASUREMENTS VERIFIED, VERDICT REFUTED. All nine design lines in /Users/ashrey/Bindu Feed/canon/spine-sound.js read exactly as quoted (full 177-line read): :49 s*0.030, :63 0.026/(i+1.6), :82 f*f*0.030, :92 0.055, :104 0.034/(i*0.6+1), :124 env*0.042, :135 0.048, :154 f*f*0.026, :165 0.024. All nine app sites read as quoted: SoundEngine.swift:1459 min(0.03,level), :1506 peak 0.026 .twin, :1531 peak 0.055, :1551 peak 0.03 (gate), :1563 peak 0.03 (ungrip); AxisModel.swift:454/467/478; AxisTones.swift:208 0.062. Neither 0.048 nor 0.024 exists as a Swift sound gain. So the two raw gaps are real. COLLAPSED is nonetheless the wrong verdict, on three counts.

(1) NOT A HIDDEN FAULT — FULLY RECORDED, PER MEMBER. Coverage/1-AUDIT-254.md:245 (C7.7, MAJOR, OPEN) and :248 (C7.10, COSMETIC, OPEN), with

### BOTH-WRONG — `gameview-navbar-two-captions` · rows `F0.1`, `F4.1`, `F4.2`, `F4.3`

**Design** — The design distinguishes the two by giving each ONE property the other lacks, both on `var(--ink35)`:

· A — GameNavBar room name, `Claude Design Round 1/comps/Game View.html:517`
  `fontFamily:'Space Mono'`, `fontSize:9`, `color:'var(--ink35)'`, `letterSpacing:'0.1em'`, `textTransform:'uppercase'`, `textAlign:'center'` — tracking and case, NO opacity. Uniform across all thirteen rooms (it does NOT spread `game.nameStyle`).

· B — GameNavBar `{idx+1} · 13 · all rooms`, `Claude Design Round 1/comps/Game View.html:518`
  `fontFamily:'Space Mono'`, `fontSize:8`, `color:'var(--ink35)'`, `opacity:.55` — opacity, NO letterSpacing, NO textTransform.

Third element in the same component, for provenance: the arrow `btn` style, `Game View.html:505-513`, carries `color:'var(--ink60)'`.
`Game View.html` contains no `.mono` class and no `text-transform` rule, so `:518` genuinely renders lower-case — `:517` spelling `textTransform:'uppercase'` explicitly is the proof no class covers it.

**App** — · A → `navBarRoomLabel`, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift:192-211` (call site `:141`). Ported, but restyled per-room off the hero's vocabulary:
  `:196-199`  Lora italic 12 · `.tracking(0.4)` · `inkSecondary`   (Descent/Return/Field)
  `:201-204`  `.spaceMonoTracked(9)` · `.tracking(2.0)` · `inkSecondary`  (Watcher)
  `:206-209`  Lora 12 · `.tracking(0.2)` · `inkSecondary`   (the other nine)

· B → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift:143-145`
  `Text("\(roomIndex + 1) · 13 · all rooms")` · `.spaceMonoTracked(8, em: 0.175)` · `.foregroundColor(BinduTheme.inkTertiary.opacity(0.55))`

Axis-by-axis (`--ink35` = `inkTertiary`, `--ink60` = `inkSecondary`, per `Theme/Theme.swift:33-35`):

| axis | design A | app A | design B | app B |
|---|---|---|---|---|
| size | 9 | 12 (9 only for Watcher) ✗ | 8 | 8 ✓ |
| tracking | 0.1em (= 0.9pt) | 0.2 / 0.4 / 2.0 raw pt ✗ | none | 0.175em (= 1.4pt) ✗ |
| opacity | none | none ✓ | .55 | .55 ✓ |
| color | ink35 | ink60 ✗ | ink35 | ink35 ✓ |
| case | uppercase | Watcher only ✗ | none | always uppercase ✗ |

The two properties the design gives ONLY to A — tracking and uppercase — are in the app ONLY on B. `spaceMonoTracked` (`Theme/Theme.swift:151-153`) applies `.textCase(.upperc

**Comment** — YES — and it is the same shape as the known instance, in the negative direction: the only design-line citation covering member A is member B's line.

`GameView.swift:121-125`, the block comment that opens `floatingNavBar` and governs the whole centre column including `navBarRoomLabel` at `:141`:

  "**AND THE LINE WAS AUTHORED ALL ALONG, SILENTLY SHORTENED.** `:518` is
   `{idx+1} · 13 · all rooms`; the app rendered `\(roomIndex + 1) · 13` — the same
   string with its last two words missing, which every checker passes because a
   substring of an authored line matches the haystack."

That cit

**Evidence** — **The finding: the two properties that distinguish the pair are on the wrong sibling, and the upper caption also took a third element's colour.**

The design's whole scheme for this pair is one property each. A gets `letterSpacing:'0.1em'` and `textTransform:'uppercase'`; B gets `opacity:.55`; both share `var(--ink35)` and differ by one point of size. The app inverts the distinguishing half: B carries tracking (`em: 0.175`) and uppercase, both of which the design gives it neither of; A carries neither (except Watcher, which uppercases for a different reason — its hero nameStyle does). B keeps its own opacity, so this is not a clean swap — A's properties migrated down onto a sibling that already had its own. That is why I return BOTH-WRONG rather than TRANSPOSED: on the group's declared tracking axis, neither member holds the design's value. A holds raw points (0.2/0.4/2.0) where the desi

**Refutation** — SURVIVES. Design verified verbatim: `Claude Design Round 1/comps/Game View.html:517` = `fontFamily:'Space Mono, monospace',fontSize:9,color:'var(--ink35)',letterSpacing:'0.1em',textTransform:'uppercase',textAlign:'center'` on `{game.name}`; `:518` = `fontFamily:'Space Mono, monospace',fontSize:8,color:'var(--ink35)',opacity:.55` on `{idx+1} · 13 · all rooms`. Both are adjacent `<span>`s inside the SAME flex-column `<div>` at `:516` (`gap:3`), same typeface, same `--ink35`, one point of size apart — a genuine designed pair, so the false-TRANSPOSED risk is excluded. The file has no `.mono` class (grepped: zero hits), so `:518` genuinely renders lower-case; `:517` spelling `textTransform` explicitly proves no class covers it.

App verified: `Bindu Feed/Bindu Feed/Screens/GameView.swift:189-21

### BOTH-WRONG — `lightv2-risefade-durations` · rows `E1.17`, `E1.2`, `E1.3`, `E1.4`, `E1.5`, `E1.6`, `E1.7`

**Design** — Both members live in one JSX column in `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light v2.html`, sharing one keyframe declared at :27 — `@keyframes riseFade{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}` — and differing only in duration.

· MEMBER A — anchors → `animation:'riseFade 2.4s ease-out both'` at :837 (element opens :835 `<p key={i} style={{fontSize:16.5,lineHeight:1.7,textWrap:'pretty',marginBottom:14,` · :836 `color:i===anchor?'var(--living)':'var(--settled)',transition:'color 3s ease',`).
· MEMBER B — Declarations (carved) → `animation:'riseFade 2.6s ease-out both'` at :843 (element opens :842 `<p key={i} className="carved" style={{fontSize:21,lineHeight:1.5,letterSpacing:'-0.012em',`).

The distinction the design draws is 0.2s, B slower than A: the vow surfaces a beat more slowly than the anchor above it, on the same rise.

**App** — One renderer only — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift` (grep for `riseFade` across the whole app tree returns ZERO hits; `scene.anchors` is referenced in no other file).

· MEMBER A — anchors: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:360-365`, entrance carried by `:364` `.transition(.opacity)`, whose duration comes from the driver at `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:607` — `withAnimation(.easeInOut(duration: 1.4)) { shownAnchors += 1 }`. **1.4s, not 2.4s.**
· MEMBER B — Declarations (carved): `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:373-379`, which carries NO `.transition` modifier at all (SwiftUI's implicit `.opacity` insertion), duration from the driver at `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:660` — `withAnimation(.easeInOut(duration: 0.6)) { beatLine += 1; drawing = 0; drew = 0; carved = false }`. **0.6s, not 2.6s.**

Neither number is its own member's and neither is its sibling's, so this is not a transposition — each site carries a plausible invented constant. Three further facts about the pairing:

1. THE RELATION IS INVERTED. Design: B is SLOWER than A by 0.2s (2.4 → 2.6). App: A is slower than B by 0.

**Comment** — NONE — and the shape of the absence is the finding.

Neither app site cites ANY design line for its duration. `LightView.swift:359` reads only `// The anchors — one at a time, on a touch (release answers the ungrip).`; `LightView.swift:372` reads only `// the locked lines — debossed into the floor, they never settle`. `:605-610` (`revealAnchor`) and `:660` carry no citation for the 1.4 / 0.6. A repo-wide grep for `:837` and `:843` returns zero hits in the app tree (the only `:835` hit is `LightType.swift:28`, and two unrelated `The Rooms v4.html:835` hits in `Rooms/RoomTravel.swift`). So `chec

**Evidence** — DESIGN — `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light v2.html`
:27  `@keyframes riseFade{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}`
:835 `<p key={i} style={{fontSize:16.5,lineHeight:1.7,textWrap:'pretty',marginBottom:14,`
:836 `  color:i===anchor?'var(--living)':'var(--settled)',transition:'color 3s ease',`
:837 `  animation:'riseFade 2.4s ease-out both'}}>{a}</p>`
:842 `<p key={i} className="carved" style={{fontSize:21,lineHeight:1.5,letterSpacing:'-0.012em',`
:843 `  textWrap:'pretty',marginBottom:11,animation:'riseFade 2.6s ease-out both'}}>{b}</p>`

APP — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift`
:359 `// The anchors — one at a time, on a touch (release answers the ungrip).`
:361 `Text(line).font(.lora(LightType.anchorSize)).lineSpacing(LightType.anchorLeading)`
:362 `    .foregroundStyle(anchorI

**Refutation** — SURVIVES ATTACK. Every quoted line verified verbatim.

DESIGN (`/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light v2.html`): `:27` keyframe, `:835-837` (anchors, no letterSpacing, `riseFade 2.4s ease-out both`), `:842-843` (carved, `riseFade 2.6s ease-out both`) all read exactly as quoted.

APP (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift`): `:360-365` with `.transition(.opacity)` at `:364`; `:373-379` with no `.transition`; `:607` `withAnimation(.easeInOut(duration: 1.4)) { shownAnchors += 1 }`; `:660-663` `withAnimation(.easeInOut(duration: 0.6))` wrapping `beatLine += 1; drawing = 0; drew = 0; carved = false`. `beatLine` starts at -1 (`:68`), so `:660` also governs the FIRST Declaration line's arrival.

REFUTATIONS ATTEMPTED, ALL FAILED:
1. ALTER

### BOTH-WRONG — `lite-block-rhythm` · rows `E1.17`, `E1.2`, `E1.3`, `E1.4`

**Design** — All four are `margin-top` — the gap ABOVE each block — in `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html`:

· `#lite .anc`  → `margin-top:26px` — `:4609`
· `#lite .beat` → `margin-top:34px` (same declaration also carries `gap:11px`) — `:4612`
· `#lite .land` → `margin-top:32px` — `:4616`
· `#lite .hold` → `margin-top:24px` — `:4617`

Role mapping is one-to-one and confirmed against the design's own renderer `liteRender()` at `:5271-5289`: `.anc` = each anchor (`:5278`), `.beat` = the Declaration block (`:5280`), `.hold` = the cue emitted immediately after the beat while `!LT.carved` (`:5282`), `.land` = the landing (`:5284`).

**App** — Every member IS ported as an element; not one carries its own member's constant. All in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift` (`sceneBody`), constants in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightType.swift`:

· `.anc` → `LightView.swift:363` `.padding(.bottom, LightType.anchorGap)`, `LightType.swift:33` `static let anchorGap: CGFloat = 14`. **14, not 26 — and it is a gap BELOW, not above.** 14 is the subordinate comp's `marginBottom:14` (`Claude Design Round 1/comps/The Light v2.html:835`).
· `.beat` → `LightView.swift:392` `.padding(.top, 6)` on the Declaration `VStack`. **6, not 34.** The 6 is the WHOLE's own inter-line constant (comp `:827` `marginBottom:6`, mirrored at `LightView.swift:347` `VStack(alignment: .leading, spacing: 6)`) — a sibling's number standing on the beat's top gap. Note the SAME design declaration `:4612` also carries `gap:11px`, and THAT half is ported (`LightType.swift:40 beatGap = 11`, `LightView.swift:371`): one line read, half taken.
· `.land` → `LightView.swift:421` `.transition(.opacity).padding(.top, 12)`. **12, not 32** — and 12 is not the comp's number either (comp `:852` says `marginTop:16`). It belongs to no source in the repo. Adjacent: the comp's `:854` `marginTop:22` on the walk-back-out

**Comment** — Not a cross-sibling line citation this time — a **range citation that covers all four members and is false for three of them**, plus one wrong-line citation on the member whose value is right.

The covering comment, `LightView.swift:328-330`:

> `// E1.17 · **THE TYPE IS THE REGISTER'S ONLY VOICE HERE, SO ITS SIZES ARE THE CONTENT.**`
> `// `The Light v2.html:826-853`. Every number below is that block's, and three of them are`
> `// not decoration:`

"Every number below is that block's" is untrue of `.padding(.top, 6)` (`:392`), `.padding(.top, 12)` (`:421`), `spacing: 16` (`:395`) and `.paddi

**Evidence** — **1 · The precedence ladder makes this a fault, not a source preference.** `Bindu Feed/CLAUDE.md:40` — *"`Claude Design Round 1/comps/` and the CDR1 per-register HTML — single-register detail only, always **subordinate** to the unified Instrument"*; restated at `:907` and at `:687` (*"`The Light v2.html` is a per-register comp at tier 3 and **explicitly subordinate**"*). E1.3 ran exactly this adjudication for the beat's cue **thirteen days ago and in the same closure batch**, superseding the comp's two cue strings in favour of `The Instrument v3.html:5282`. E1.17 closed the same day taking its numbers from the file E1.3 had just demoted — and there is no recorded adjudication for the block rhythm anywhere: `#lite`, `liteRender`, and the line numbers 4609/4612/4616/4617 return **zero hits** across all of `Coverage/` (`1-AUDIT-254.md`, `_verdicts1-3.md`, `_mechverdicts1-3.md`). The group i

**Refutation** — Survives attack. DESIGN verbatim at every cited line: :4609 margin-top:26px, :4612 margin-top:34px;display:flex;flex-direction:column;gap:11px, :4616 margin-top:32px, :4617 margin-top:24px. #lite is display:flex;flex-direction:column, so margins do not collapse and these four ARE the effective gaps. Role mapping to liteRender() :5271-5289 confirmed one-to-one (.whole/.anc/.beat+.hold/.land). APP verbatim at every cited line: LightView.swift:363 .padding(.bottom, LightType.anchorGap), :392 .padding(.top, 6), :395 spacing: 16, :421 .padding(.top, 12), :435 .padding(.top, 8); LightType.swift:33 anchorGap=14, :40 beatGap=11, :48 wholeGap 0/18. Effective gaps confirmed: anchor-to-beat 34 -> 20 (14+6), beat-to-landing 32 -> 12, beat-to-cue 24 -> 8, anchor-to-anchor 26 -> 14. All four members wro

### BOTH-WRONG — `return-reply-quote-vs-ask` · rows `E2.5`, `E3.12`, `E3.13`, `E3.5`, `E3.7`
*The refutation corrected this from the checker's first verdict.*

**Design** — Authority is Round 1 (Round 2's `comps/The Return.html` is only 502 lines and has no Reply movement at all; the app's own porting note, `Return/ReturnCanon.swift:74`, names `The Return v2.html`, which agrees).

MEMBER A — the quoted past self:
· `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html:650` → fontSize **15**, color **var(--ash)**, opacity **0.72**
· twin: `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Return v2.html:1220` → fontSize **15**, opacity **0.82**, colour+italic+`saturate(.85)` inherited from `.dried` (`The Return v2.html:931`)

MEMBER B — the ask ("It is later." / "What arrived for you?"):
· `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html:652` → fontSize **16**, color **var(--ash)**, opacity **0.9**
· twin: `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Return v2.html:1222` → fontSize **16**, color **var(--ash)**, opacity **0.92**

Both sources agree on the relation: same colour, 15 vs 16 (one point), 0.72/0.82 vs 0.9/0.92 (~0.18/0.10 apart). Opacity is the axis that does the receding.

**App** — MEMBER A — the quote, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:503-504`:

    Text("\u{201C}\(quote)\u{201D}")
        .font(.loraItalic(15)).foregroundStyle(ReturnCanon.ashColor).saturation(0.85)

→ size **15** (its own, correct) · ash (`ReturnCanon.swift:10` = `#C47A52`, no baked alpha) · **NO opacity modifier** · `.saturation(0.85)` correctly carried over from `.dried`.

MEMBER B — the ask, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:507`:

    Text(prompt.ask).font(.lora(18)).italic().foregroundStyle(BinduTheme.inkPrimary)

→ size **18** (design says 16) · **inkPrimary** (`Theme/Theme.swift:33` = `#EDE8E3`, no alpha — design says var(--ash)) · **NO opacity modifier**.

`.lora`/`.loraItalic` (`Theme/Theme.swift:65-71`) pass the number straight to `.custom(_:size:)` — no scale factor, so 18 is literally 18pt. No parent supplies the missing alpha: the enclosing `VStack` (`:497`) carries only `.padding(.horizontal, 34)` (`:530`), and it is reached bare from the stage switch at `:144`.

So on the named opacity axis: design 0.72 vs 0.9 → app **1.0 vs 1.0**. The pair is flattened onto one value. The app then re-separates the two lines on axes the design did not use for this — colour (terracotta vs bone-white) and a 3-point

**Comment** — NONE — and the absence is itself the mechanism here.

Neither app site carries a comment, and **no citation of these design lines exists anywhere in the app**: `grep` for `1220`, `1222`, `:650`, `:652` across `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed` returns zero hits. Every `The Return` citation in the app points at Round 2 (`ReturnAnswers.swift:3,15,23,56,107,114`; `ReturnPatina.swift:105,111,159`; `ReturnView.swift:421`) — a file that does not contain the Reply movement.

This is the same invisibility as the known `#where`/`#pname` instance arrived at from the other side: there the c

**Evidence** — VERDICT REASONING — why COLLAPSED and not the others:
· TRANSPOSED — ruled out: the quote does not carry 16/0.9 and the ask does not carry 15/0.72. No swap.
· BOTH-WRONG — ruled out on size: the quote's 15 is exactly the design's.
· ONE-MISSING — describes the size axis only (quote ported with its constant, ask ported with a wrong one), not the group.
· **COLLAPSED — this is it, on the property the group is named for.** The design distinguishes the two lines by opacity, 0.72 vs 0.9. The app gives both members the same value: neither carries an opacity modifier, so both render at 1.0. Two distinguished constants → one shared constant. That is the variant's definition exactly, and it is the purer form of the rail case, where only one member drifted toward its sibling.

WHY IT SURVIVED — the four properties of the class, all present:
1. Not a dropped value and not a wrong one on the quote —

**Refutation** — THE FAULT IS REAL — every fact re-verified from source. Design `Claude Design Round 1/comps/The Return.html:650` = `fontSize:15,color:'var(--ash)',opacity:0.72`; `:652` = `fontSize:16,color:'var(--ash)',opacity:0.9`. Twin `The Return v2.html:1220` = fontSize 15 + `opacity:0.82` under `.dried` (`:931` = `color:var(--ash);font-style:italic;filter:saturate(.85)`); `:1222` = `fontStyle:italic,fontSize:16,color:'var(--ash)',opacity:0.92`. App `Screens/ReturnView.swift:503-504` = `.font(.loraItalic(15)).foregroundStyle(ReturnCanon.ashColor).saturation(0.85)`; `:507` = `.font(.lora(18)).italic().foregroundStyle(BinduTheme.inkPrimary)`. `ReturnCanon.ashColor` (`ReturnCanon.swift:10` #C47A52) and `BinduTheme.inkPrimary` (`Theme.swift:33` #EDE8E3) carry NO baked alpha; `.lora`/`.loraItalic` (`Theme.

### BOTH-WRONG — `rooms-turncard-two-captions` · rows `F0.2`, `F3.4`
*The refutation corrected this from the checker's first verdict.*

**Design** — Both members live in ONE baseline-aligned flex row — `Claude Design Round 1/comps/Room Selection.html:669` `{ display:'flex', alignItems:'baseline', gap:9 }`.

MEMBER A — turn.name (Lora), `Room Selection.html:670`:
  fontFamily 'Lora, serif' · fontSize **15** · color **turn.color** · opacity **0.92** · letterSpacing **'0.01em'** · no fontWeight (400)

MEMBER B — turn.person (Space Mono), `Room Selection.html:671`:
  fontFamily 'Space Mono, monospace' · fontSize **8** · color **turn.color** · opacity **0.5** · letterSpacing **'0.12em'** · textTransform uppercase

`turn.color` is per-card: `#C47A52` (mirror) / `#3AADA8` (signalspace), `Room Selection.html:568,573`. The shared `turn.color` is the whole sibling relation; the pair differs on exactly three constants — size, opacity, tracking.

THIRD ELEMENT, needed to read the fault — the section eyebrow, `Room Selection.html:747`:
  Space Mono · fontSize **9** · color **var(--ink35)** (`:375` = rgba(237,232,227,0.35)) · letterSpacing **'0.18em'** · uppercase

**App** — Port: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/FieldSurfacePortalCard.swift`. Both members ported, in the same view, four lines apart.

MEMBER A — `FieldSurfacePortalCard.swift:57-60`:
    Text(config.name)
        .font(.lora(15, weight: .medium))
        .foregroundColor(config.color.opacity(0.88))
        .lineLimit(1)
  size 15 ✓ · hue config.color ✓ · opacity **0.88** (design 0.92) ✗ · tracking **ABSENT** — `Font.lora` (`Theme/Theme.swift:65`) returns a Font only; no `.tracking` anywhere in the chain, so 0.01em is dropped ✗ · adds `weight: .medium`, which `:670` does not carry ✗

MEMBER B — `FieldSurfacePortalCard.swift:62-67`:
    if let label = config.label {
        Text(label.uppercased())
            .spaceMonoTracked(9)
            .tracking(1.08)
            .foregroundColor(BinduTheme.inkTertiary)
    }
  size **9** (design 8) ✗ · colour **BinduTheme.inkTertiary** = `#EDE8E3` @ 0.35 (`Theme/Theme.swift:35`) — not `config.color` at all ✗ · opacity therefore **0.35** (design 0.5) ✗ · tracking 1.08 = 0.12em × **9**; the em is B's own, the base is not (0.12 × 8 = 0.96) ✗ · uppercase ✓

STRUCTURE — `FieldSurfacePortalCard.swift:56`: `VStack(alignment: .leading, spacing: 5)`. The design's baseline ROW (`:669`, gap 9) became a vertical STACK: name on one l

**Comment** — NONE — and the absence is itself the tell, a second way past `check_citations`.

Neither caption site carries a comment, and **the file cites no design line number anywhere**. The only comments are:
 · `FieldSurfacePortalCard.swift:3-9` — a prose header over the whole struct: "Wider horizontal cards (full-width, stacked) rather than 2-col tiles, with glyph on the left and name + person-label + descriptor on the right." It **states the stack as the intent** without citing `:669`, the baseline row it replaces — a design divergence written down as a decision, with no line to check it against.
 · 

**Evidence** — VERDICT BOTH-WRONG, with a ONE-MISSING inside member A and a TRANSPOSED across the section eyebrow. Not a swap between the two members — checked and ruled out: A carries none of B's numbers and B carries none of A's.

Per constant:
| constant | design A (:670) | app A (:57-60) | design B (:671) | app B (:62-67) |
|---|---|---|---|---|
| size | 15 | 15 ✓ | 8 | **9** ✗ (the eyebrow's) |
| colour | turn.color | config.color ✓ | turn.color | **inkTertiary** ✗ |
| opacity | 0.92 | **0.88** ✗ | 0.5 | **0.35** ✗ (ink35, the eyebrow's tier) |
| tracking | 0.01em | **absent** ✗ | 0.12em | 0.12em × **9** = 1.08 ✗ (right em, wrong base; 0.96 authored) |

WHY THIS ONE SURVIVED — the same shape as `#where`/`#pname`, reached differently:
1. **0.88 is not a sibling's number, it is nobody's.** `grep "opacity: 0.88"` across `Claude Design Round 1/comps/` returns two hits, both keyframe midpoints in glyph

**Refutation** — PAIR VERDICT SURVIVES; THE FINDING AS WRITTEN DOES NOT. Keep BOTH-WRONG, rewrite the rows/evidence sections.

WHAT I CONFIRMED. Design reads exactly as quoted: `Room Selection.html:669` `{display:'flex',alignItems:'baseline',gap:9}`; `:670` Lora 15 / turn.color / 0.92 / '0.01em' / no fontWeight; `:671` Space Mono 8 / turn.color / 0.5 / '0.12em' / uppercase; `:747` eyebrow Space Mono 9 / var(--ink35) / '0.18em'; `:375` --ink35 = rgba(237,232,227,0.35). App reads exactly as quoted: `FieldSurfacePortalCard.swift:56` VStack(spacing:5); `:57-60` .lora(15,weight:.medium) + config.color.opacity(0.88), and `Font.lora` (`Theme.swift:65`) returns a Font only — no .tracking anywhere in that chain, so 0.01em is genuinely dropped; `:62-67` .spaceMonoTracked(9) [= .font(spaceMonoFace(9)).textCase(.upper

### BOTH-WRONG — `world-state-word-alpha` · rows `D5.3`

**Design** — All four are the HELD-word branch of each world's `H-150` caption — the branch taken while the hand is engaged and `given < 4`. Colour is `#EDE8E3` (the neutral ink) in all four; only the constant moves.

· I THE POINT   → `rgba('#EDE8E3', A*0.44)` — Round 1 `Claude Design Round 1/The Instrument v3.html:2560`; Round 2 `Claude Design Round 2/design-source/world-one.js:188`
· II THE TURN   → `rgba('#EDE8E3', A*0.44)` — Round 1 `…v3.html:2809`; Round 2 `world-two.js:230`
· III THE VEIL  → `rgba('#EDE8E3', A*0.44)` — Round 1 `…v3.html:3072`; Round 2 `world-three.js:240`
· IV THE CHAMBER→ `rgba('#EDE8E3', A*0.46)` — Round 1 `…v3.html:3369`; Round 2 `world-four.js:273`

Both rounds agree exactly, so the 0.44/0.46 split is not a Round-1 typo. Widening past the stated group settles what the group could not: the full ladder is I 0.44 · II 0.44 · III 0.44 · IV 0.46 · V 0.46 (`world-five.js:441`, on `#EAFBF8`) · VI 0.48 (`world-six.js:429`, on `#FFE9F4`) · VII 0.46 (`world-seven.js:507`, on `#FFF3DC`). The Chamber's 0.46 is the first step of a monotone rise across seven worlds, each with its own ink. **AUTHORED-DIFFERENT, not ported-wrong.**

**App** — The app splits the design's one `H-150` slot in two: the un-engaged CUE branch lives in `WorldCue` (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:248-261`, at `0.38*(0.7+br*0.4)` — correctly ported), and this group's HELD branch lives in the four reading views. All four ports are in one file: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift`.

· I  `PointReadings.swift:373-375` — `Text(stateWord.uppercased()) … .foregroundStyle(BinduTheme.inkPrimary.opacity(0.44))`. `BinduTheme.inkPrimary = Color(hex: "#EDE8E3")` (`Theme/Theme.swift:33`). **0.44 on #EDE8E3 — its own member's constant, and its own member's colour. MATCHED.**
· II `PointReadings.swift:477-479` — `.foregroundStyle(hue.opacity(0.55))`. Design 0.44. **Wrong constant AND wrong colour** — `hue` here is `#B9A5E8` (`PointContent.swift:49` via `PointWorldView.swift:157`), a violet, not the ink.
· III `PointReadings.swift:612-614` — `.foregroundStyle(hue.opacity(0.55))`. Design 0.44. `hue` = `#7D74C9`.
· IV `PointReadings.swift:747-749` — `.foregroundStyle(hue.opacity(press <= 0.05 ? 0.4 : 0.85))`. Design is a flat 0.46. **Neither leg is 0.46, and the two-state gate on `press` has no counterpart in the design's branch at all.** `hue` = `#E0713F`.

Not TRANSPOSED: 0.55 is no

**Comment** — **NONE of the known shape.** No comment on one member cites another member's design line. All four cite their own world's file: `world-one.js:184-186` (`:372`), `world-two.js:229-232` (`:474`), `world-three.js:238-241` (`:598`), `world-four.js:272-274` (`:745`).

But the citations fail in a second way that is worth naming, because it is the same blind spot with a different geometry — **the cited RANGE contains the design constant, and the value written beside it is not that constant.**

· II cites `world-two.js:229-232`. Line 230 inside that range IS `x.fillStyle=rgba('#EDE8E3',A*0.44);`. The 

**Evidence** — READ-ONLY sweep; no edits made.

**1 · The design group's own question is answered, and the answer is AUTHORED-DIFFERENT.** The group note said the Chamber's 0.46 against three 0.44s was "either authored-different or ported-wrong, and nothing in the file states which." Reading past the four stated members settles it: the seven worlds run 0.44 · 0.44 · 0.44 · 0.46 · 0.46 · 0.48 · 0.46, and worlds V–VII each swap the ink too (`#EAFBF8`, `#FFE9F4`, `#FFF3DC` against I–IV's shared `#EDE8E3`). A monotone rise with per-world ink is a designed ladder, not a slip. Round 2's `design-source/world-*.js` reproduces every value identically — an independent second witness.

**2 · The app never ported the ladder.** `hue.opacity(0.55)` is the house default: it appears at II (`:479`), III (`:614`) and again at V (`PointReadings.swift:955`). VI uses `hue.opacity(sent ? 0.35 : 0.65)` (`:1102`), IV uses `hu

**Refutation** — Survives attack on every front. Design lines read exactly as quoted (Round 1 :2560/:2809/:3072 = A*0.44, :3369 = A*0.46, all on #EDE8E3), and Round 2 reproduces them identically (world-one.js:188, world-two.js:230, world-three.js:240, world-four.js:273) — so IV's 0.46 is authored, not a typo. App sites read exactly as quoted at PointReadings.swift:375 (inkPrimary.opacity(0.44)), :479 and :614 (hue.opacity(0.55)), :749 (hue.opacity(press <= 0.05 ? 0.4 : 0.85)); Theme.swift:33 confirms inkPrimary = #EDE8E3. Five refutations tried and failed: (1) "hue forced by a different surface" — the design's HUES table (point-content.js:5) is identical to PointContent.hues, and world-two draws universe names with rgba(HUE,…) at :214 twelve lines above choosing #EDE8E3 for this caption, so the design had 

### COLLAPSED — `bottom-hint-caption-tracking` · rows `F0.1`, `F11.2`, `F11.3`

**Design** — MEMBER A — `#ground .base` (the door's base line, "touch to receive" / "tap anywhere to cross"): `letter-spacing:.18em` at `font-size:9px` → 1.62px tracking. Site: /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4379-4380 (rule opens :4379, the value is on :4380). Independently corroborated in the sibling comp by the same hand: /Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:645-646 — same string, same 9px, `letterSpacing:'0.18em'`, same `animation:'hint 6s ease-in-out infinite'`.

MEMBER B — `#turn .foot` ("tap anywhere to stay"): `letter-spacing:.2em` at `font-size:9px` → 1.80px tracking. Site: /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4407-4408 (rule opens :4407, the value is on :4408). Corroborated at /Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:456-458 — same string, 9px, `letterSpacing:'0.2em'`, same hint animation.

The distinction is deliberate and holds across two independent comps: the door's base line is the LOOSER-set of the pair by design in neither direction — .18 for the base, .20 for the foot, twice, in two files. (A third variant exists — Home Feed.html:185 renders "tap anywhere to stay" at 0.18em on the hub surface — but that is a different surface, not this pair.)

**App** — MEMBER A port — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:131-134
    Text("touch to receive")
        .spaceMonoTracked(9, em: 2 / 9)
        .foregroundStyle(room.opacity(0.62))
        .modifier(RiteBreathe())
Identified by role, not name: `room.opacity(0.62)` is the design's `hexa(GR.TODAY.color,.62)` (The Instrument v3.html:5009), and `RiteBreathe` (RiteView.swift:20-25, `0.28 + 0.42 * breath.value`) is the port of `@keyframes hint`.

MEMBER B port — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:93-96
    Text("tap anywhere to stay")
        .spaceMonoTracked(9, em: 2 / 9)
        .foregroundStyle(BinduTheme.inkTertiary.opacity(0.4 + 0.4 * breath.value))
        .padding(.bottom, 40)

The helper resolves the constant: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151-152 — `.tracking(em * size)`. So both sites compute (2/9) × 9 = **2.00pt, character-identical expressions on both siblings**.

Design wants 1.62pt and 1.80pt. The app renders 2.00pt and 2.00pt. The .18/.20 distinction is erased, and neither member carries its own number — the collapse lands on a value that is not either design constant, so this is COLLAPSED with a BOTH-WRONG interior. Not TRANSPOSED: no swap, because there is only one v

**Comment** — NONE — in the strict sense the known instance had. Neither app site carries any comment, and neither cites a design line, so there was no citation for `check_citations` to verify OR to falsify. The nearest citations in DoorView.swift are :184 and :193, both sound thresholds (`Instrument v3:5082`, `Instrument v3:5022`), unrelated to tracking. TurnOverlay.swift:73's only comp reference is "(comp A Strange Feed.html turn marks)", about the row glyphs.

But the AUDIT ROW commits the pairing fault at the row level, and it is worth quoting because it is the same failure one level up. Coverage/1-AUDI

**Evidence** — HOW IT SURVIVED, from git — the two members were made identical by a mechanical refactor, in one commit, on the same day:

`b19f1d6` ("E1.18 the mono case as a default · check_stale, the seventh gate") rewrote BOTH lines in the same commit:
  DoorView.swift:132   `.font(.spaceMono(9)).textCase(.uppercase).tracking(2)`  →  `.spaceMonoTracked(9, em: 2 / 9)`
  TurnOverlay.swift:94  `.font(.spaceMono(9)).textCase(.uppercase).tracking(2)`  →  `.spaceMonoTracked(9, em: 2 / 9)`

Before that, both had read `.tracking(2)` since at least `4258c5d` ("E1.13, F9.1, F2.5, F11.2 — the re-banding pass closes"). So the original defect was a hand-set 2pt on both siblings; F0.1's conversion pass then re-expressed the SAME wrong number as `2 / 9` and counted both as converted. The conversion was faithful to the app and never consulted the design — which is why a row whose subject is "em->pt tracking not con

**Refutation** — Survives every refutation attempt. DESIGN verified verbatim: The Instrument v3.html:4379-4380 `#ground .base{...font-size:9px;` / `letter-spacing:.18em;text-transform:uppercase;pointer-events:none}` = 1.62px; :4407-4408 `#turn .foot{...font-size:9px;` / `letter-spacing:.2em;...animation:hint 6s ease-in-out infinite}` = 1.80px. Siblinghood is structural, not proximity: :4383 `#ground .base span{animation:hint 6s ease-in-out infinite}` gives the base the SAME animation :4408 gives the foot; both bottom-anchored left:0;right:0, both Space Mono 9px uppercase, differing in tracking. Element-to-string binding confirmed: :4651 `<div class="base"><span id="gbase">` is filled by :5008 ('touch to receive') and :5013 ('tap anywhere to cross'); :4664 `<span class="foot">tap anywhere to stay</span>`. A

### COLLAPSED — `chrome-where-vs-pname-dominance-fade` · rows `C2.6`, `C5.2`, `C5.6`

**Design** — All three members carry ONE uniform dominance factor, `1 - dom*0.9`, and are distinguished only by #pname's `0.9*` prefix:

· `#where` (whereEl) → `(1-dom*0.9)` — Claude Design Round 2/comps/The Chrome.html:381. NO base constant, NO `PS.on` hide.
· `#pname` (pnEl) → `hide?0:(0.9*(1-dom*0.9))` — The Chrome.html:386. The `0.9` base is HERE; hide is `|Z|<0.42 || Z>7.9` (:384).
· `#rail` (railEl) → `(AB==='built'?(PS.on?0:1):(1-PS.dom()*0.9))` — The Chrome.html:397. `AB='designed'` at :167, so the live design branch is `(1-PS.dom()*0.9)`; the `built` branch is the comp's own depiction of the app.

Two corroborations that `dom*0.9` is the authored chrome factor and not a rail-local number:
· The Chrome.html:294 — `const r0=R0(),dom=PS.dom(),a=1-dom*0.9;` — the shells/world layer, the SAME factor a fourth time.
· The Chrome.html:99, the comp's own key: "afterglow — `dom()` runs 1→0 over 0.75s after landing; rail, `#where` and shells come back through it rather than snapping on." The design names `#where` as an element that comes back THROUGH the afterglow.

`PS.dom()` is defined at The Chrome.html:214 — `this.on?Math.min(1,this.t*2.0+0.12):this.after*0.7` — byte-identical to what the app ported as `Axis.dom`. This comp is the design authority for exactly the mechanism C2.6 ports. Round

**App** — All three are ported and all three are locatable. The dominance factor for the two captions is applied INLINE IN THE VIEW BODY, outside `Immersion`:

· `#where` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:568`
  `.opacity(hidden ? 0 : Immersion.whereOpacity(hush: hush, immA: immA) * (1 - dom))`
  with `Immersion.whereOpacity` = `(1 - hush) * (1 - immA)` (AxisModel.swift:596).
  Effective dominance factor: **`(1 - dom)`** — the design's `(1 - dom*0.9)`.

· `#pname` → `InstrumentView.swift:682` (view `particleNameLabel`)
  `.opacity(hidden ? 0 : Immersion.pnameOpacity(hush: hush, immA: immA) * (1 - dom))`
  with `Immersion.pnameOpacity` = `0.9 * (1 - hush) * (1 - immA)` (AxisModel.swift:602-604).
  Effective dominance factor: **`(1 - dom)`** — the design's `(1 - dom*0.9)`.

· `#rail` → `InstrumentView.swift:625`
  `.opacity(Immersion.railOpacity(hush: hush, immA: immA, dom: dom))`
  with `Immersion.railOpacity` = `(1 - hush*0.85) * (1 - immA) * (1 - dom*0.9)` (AxisModel.swift:590-592).
  Effective dominance factor: **`(1 - dom*0.9)`** — MATCHES the design.

`dom` is `Axis.dom(crossing:passageT:after:)` (InstrumentView.swift:45-49, AxisModel.swift:188-190), identical to the comp's `PS.dom()`.

THE PAIRING:
· The BASE constant — the original C5.2

**Comment** — Two faults, one historical and one LIVE.

1. HISTORICAL, and now correctly recorded — not a live fault. `InstrumentView.swift:557-561` on `#where` cites `:5646`, which is `#pname`'s line, but cites it to DISOWN it:
   "**THE 0.9 WAS NEVER `#where`'s.** The note that stood here cited `:5646` — which is `#pname` — and carried its base constant onto this element."
   The cross-citation that made the known instance invisible has been replaced by a note about the cross-citation. `AxisModel.swift:594-604` repeats the record on both functions.

2. LIVE — the comment that keeps the collapse standing. 

**Evidence** — WHY THIS SURVIVED — the mechanism, which is the point of reporting it:

The rail's collapse WAS found and fixed, and the fix is asserted by name. `Bindu Feed/Bindu FeedTests/ImmersionTests.swift:173-190`, `domCarriesItsCoefficient`:
  "`:5644` — `(1−PS.dom()*0.9)`. **The app wrote `(1 − dom)`**, which hard-zeroes the ladder at a full crossing. The design leaves 0.1"
  `#expect(abs(crossed - 0.1) < 1e-12)` on `Immersion.railOpacity(hush: 0, immA: 0, dom: 1)`.

So the identical defect — `(1 - dom)` for `(1 - dom*0.9)` — was diagnosed in this exact file, named in a test, and fixed on ONE of the three siblings. It stands on the other two because of where the arithmetic lives:

· The rail's dominance factor is INSIDE `Immersion.railOpacity`, so a test can reach it.
· `#where`'s and `#pname`'s dominance factors are `* (1 - dom)` written INLINE at InstrumentView.swift:568 and :682, OUTSIDE `Imm

**Refutation** — SURVIVES ATTACK. All six quoted lines read verbatim. Design: The Chrome.html:381 `whereEl.style.opacity=(1-dom*0.9)`, :386 `pnEl.style.opacity=hide?0:(0.9*(1-dom*0.9))`, :397 `railEl…(1-PS.dom()*0.9)`; plus :294 `a=1-dom*0.9` and :99's key naming `#where` as coming back through the afterglow. App: InstrumentView.swift:568 and :682 multiply by `(1 - dom)` inline; :625 uses `Immersion.railOpacity` which carries `(1 - dom*0.9)` (AxisModel.swift:591). Rail MATCHED, both captions lost the 0.9.

I attacked the design-authority claim hardest, since it is the finding's load-bearing move. Round 1 `The Instrument v3.html:5645` genuinely has NO dom term on `#where` (it hides on `PS.on` instead), so under v3 the app's `(1-dom)` would be app-own and uncollapsible. That defence fails on three independen

### COLLAPSED — `mirror-caption-tracking` · rows `A1.5`, `A1.6`, `F0.1`
*The refutation corrected this from the checker's first verdict.*

**Design** — Three Space Mono uppercase captions of The Mirror, each with its own tracking, ordered title widest → hint tightest.

1. register mark — `letterSpacing: '0.26em'` at fontSize 9.5 → 2.47pt
   /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Mirror.html:131 (size on :130)
2. portal title "The Mirror" — `letterSpacing: '0.30em'` at fontSize 11 → 3.30pt
   /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Mirror.html:245 (size on :244)
3. draw hint — `letterSpacing: '0.18em'` at fontSize 9 → 1.62pt
   /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Mirror.html:293

Design rank: 0.30 > 0.26 > 0.18 — end-to-end spread 1.67×.
`grep -n letterSpacing` on the comp confirms these are the ONLY three Space Mono uppercase trackings in the file; 0.25 appears nowhere in it.

**App** — All three ported, all three in one file, all three bypassing the sanctioned `em:` door.

1. register mark → `ReflectionCard`, `Text(registerLabel)` ("STILL LIVING" / "A VOW · ARRIVED")
   /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:299-301
   `.spaceMonoTracked(10)` then `.tracking(2.5)` → 2.5/10 = **0.250em** (design 0.26em; at the app's own size 10 the design value is 2.6)
2. portal title → `header`, `Text("THE MIRROR")`
   /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:74-76
   `.spaceMonoTracked(11)` then `.tracking(2.6)` → 2.6/11 = **0.2364em** (design 0.30em → 3.3pt; short by 0.7pt, 21%)
3. draw hint → `binduDraw`, `Text(drawn ? "DRAWN · RETURN TOMORROW" : "DRAW ONCE MORE")`
   /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:145-147
   `.spaceMonoTracked(9)` then `.tracking(1.8)` → 1.8/9 = **0.200em** (design 0.18em → 1.62pt; over by 11%)

`spaceMonoTracked(_:em:)` is /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151 — `self.font(...).textCase(.uppercase).tracking(em * size)`. All three call sites omit `em:`, so the helper applies `tracking(0)` and the chained outer `.tracking(N)` wins as an absolute point value.

App rank: register 0.250 > title 0.236 > hint 0.200 — spread 1.25×

**Comment** — NONE — and the absence is itself the finding.

`grep -rn "Mirror.html" /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/` returns **zero hits**. MirrorView.swift carries no design-line citation of any kind for these three constants; the whole app has only 19 `comps/` citations and none is to The Mirror. So no comment cites a sibling's line — there is no comment to cite anything.

That means `check_citations` never had a string to verify here. The known `#where`/`#pname` instance survived a citation checker by citing the wrong element; this group survives it by citing nothing, in a file whose sib

**Evidence** — **The transposition signature is on the title.** 0.26 × 10 = 2.6 — the register mark's design em, rendered at the register mark's app font size (10). That number is sitting on the portal title, at font size 11, where 3.3 belongs. The right number, on the wrong sibling, exactly the `#where`/`#pname` shape. The register mark was then left holding 2.5 — a value that belongs to no member of this group and appears nowhere in the comp.

**What the reader sees, and why it passed.** 2.5 / 2.6 / 1.8 on three adjacent captions looks deliberate: three distinct numbers, descending, in the right family. Nobody re-divides by font size, so nobody sees that in em the app renders 0.250 / 0.236 / 0.200 — and that the title, which the design makes the WIDEST of the three, is in the app the MIDDLE one, narrower than the register mark beneath it. The design's stated intent ("the title is widest and the hint 

**Refutation** — The finding's quotes all verify, but its central mechanism is inverted, and that inversion carries away the verdict and every piece of its reasoning.

VERIFIED AS QUOTED. Design: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Mirror.html:131 `letterSpacing: '0.26em'` (fontSize 9.5 on :130), :245 `letterSpacing: '0.30em'` (fontSize 11 on :244), :293 `letterSpacing: '0.18em'` (fontSize 9). `grep -n letterSpacing` confirms these are the only three Space Mono uppercase trackings. App: MirrorView.swift:74-76 `.spaceMonoTracked(11).tracking(2.6)`, :145-147 `.spaceMonoTracked(9).tracking(1.8)`, :299-301 `.spaceMonoTracked(10).tracking(2.5)`. Theme.swift:151-152 is `extension View { func spaceMonoTracked(_ size: CGFloat, em: CGFloat = 0) -> some View { self.font(...).textCase(.uppercase)

### COLLAPSED — `reading-panel-body-alpha` · rows `D2.4`, `D5.1`, `D5.3`, `D5.8`, `E2.5`, `F4.2`

**Design** — The design states the body colour FIVE times, once per reading panel, and two of the five diverge:

· `.sec .bd` (the sheet's — `#sheet`, "the reading, caught in flight (VII)") → `color:rgba(240,236,231,.90)` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4450
· `#still .bd` (I · THE POINT) → `color:rgba(240,236,231,.90)` — …/The Instrument v3.html:4477
· `#going .bd` (II · THE TURN) → `color:rgba(240,236,231,.90)` — …/The Instrument v3.html:4500
· `#thru .bd` (III · THE VEIL) → `color:rgba(240,238,246,.90)` — …/The Instrument v3.html:4523  (cooler base, +2 blue: read through a violet parting)
· `#wall .bd` (IV · THE CHAMBER) → `color:rgba(246,236,228,.92)` — …/The Instrument v3.html:4549  (warmer base AND the lone .92, plus `text-shadow:0 1px 0 rgba(26,12,5,.85)` on the same rule)

Base RGB across the group: #F0ECE7 ×3, #F0EEF6 ×1, #F6ECE4 ×1. Alpha: .90 ×4, .92 ×1.
Round 2's copy is byte-identical at the same five line numbers (/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Instrument v3.html:4450/4477/4500/4523/4549), so no later round supersedes these values. The second design source for the same surface agrees on the base: `The Reading.html:21` `.sc .tx` is `rgba(240,236,231,.93)` — #F0ECE7 again.

**App** — There is ONE app expression for all five members, not five.

/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:206-222 — `private struct SectionBlock`, whose body Text is:

    Text(section.text(star))
        .font(section.quoted ? .loraItalic(15.5) : .lora(15.5))
        .lineSpacing(6)
        .foregroundStyle(BinduTheme.inkPrimary.opacity(thinned ? 0.72 : 1))

`BinduTheme.inkPrimary = Color(hex: "#EDE8E3")` — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:33.

Per-member call sites, all seven passing the same struct:
· `.sec .bd` / VII · THE DANCE (`ReadCompany`) → PointReadings.swift:1263 — plain, no colour argument
· `#still .bd` / I · THE POINT (`ReadStillness`) → PointReadings.swift:362 — plain
· `#going .bd` / II · THE TURN (`ReadFollowing`) → PointReadings.swift:469 — plain (only `.padding(.leading, i*10)`)
· `#thru .bd` / III · THE VEIL (`ReadParting`) → PointReadings.swift:564-565 — `thinned: true`, i.e. #EDE8E3 @ 0.72
· `#wall .bd` / IV · THE CHAMBER (`ReadPressing`) → PointReadings.swift:730-735 — plain; the only additions are `.padding(.leading, 14)` and a 1.5pt `hue.opacity(0.35)` left rule. No warmer base, no .92, no text-shadow.
(also V · THE MIRRORS :941 `mirrored:`, VI · THE RETURN :1086 plain — same struct)

`PointSect

**Comment** — NONE — and the absence is itself the tell.

There is no comment on the app site at all. The only annotation is the section marker two lines above:

    PointReadings.swift:204 — `// MARK: - one section, in the shared type`

No comment anywhere in the app cites 4450, 4477, 4500, 4523 or 4549. `grep -rn --include="*.swift" -E ":4(4[0-9][0-9]|5[0-9][0-9])"` over the whole app tree returns exactly one hit, and it is a different element: PointDeals.swift:25 citing `#gate` at `The Instrument v3.html:4423-4426`.

So this instance evades `check_citations` by a route the `#where`/`#pname` instance did 

**Evidence** — READ-ONLY sweep; no edits made.

1. DESIGN, verified by direct read (both rounds identical):
   /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html
     :4450 `.sec .bd{font-size:14.5px;line-height:1.76;color:rgba(240,236,231,.90);text-wrap:pretty}`
     :4477 `#still .bd{…color:rgba(240,236,231,.90)…}`
     :4500 `#going .bd{…color:rgba(240,236,231,.90)…}`
     :4523 `#thru .bd{…color:rgba(240,238,246,.90)…}`
     :4549 `#wall .bd{…color:rgba(246,236,228,.92);text-wrap:pretty;` + next line `text-shadow:0 1px 0 rgba(26,12,5,.85)}`
   Panel identities confirmed from the design's own section comments at :4434 (*"the reading, caught in flight (VII)"* → #sheet), :4462 (*"I · THE POINT · the reading that surfaces out of the emptiness"*), :4482 (*"II · THE TURN"*), :4505 (*"III · THE VEIL"*), :4530 (*"IV · THE CHAMBER · the reading, inscribed … It is letterpress"*).

2. APP, 

**Refutation** — Both halves verified by direct read and the finding survives every refutation I could mount. DESIGN: all five .bd declarations are byte-exact as quoted at The Instrument v3.html:4450/4477/4500/4523/4549 (+4550 for #wall's text-shadow); three distinct bases (#F0ECE7 x3, #F0EEF6, #F6ECE4) and two alphas (.90 x4, .92). Round 2's copy is diff-identical across the WHOLE file. Panel identities confirmed from markup at :4659,4676-4679, not just comments. APP: PointReadings.swift:219 is `.foregroundStyle(BinduTheme.inkPrimary.opacity(thinned ? 0.72 : 1))`, Theme.swift:33 = #EDE8E3. SectionBlock is private with exactly 8 grep hits (def :206 + seven call sites 362/469/564/730/941/1086/1263); PointSection has 0 hits outside the file, so :219 is provably the sole body-text site. I read all five call s

### COLLAPSED — `reading-panel-fade-duration` · rows `B5.1`, `B5.3`, `B5.4`, `B5.5`, `B5.8`, `D5.1`, `D5.3`, `D5.8`, `E1.13`, `E1.17`, `E1.2`

**Design** — All seven confirmed at the cited sites in `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html` (byte-identical to `Claude Design Round 2/design-source/The Instrument v3.html` — `diff -q` reports IDENTICAL, so there is no newer copy carrying different numbers):

· #sheet → `transition:opacity .9s ease` — :4438 (block header :4434 `/* ── the reading, caught in flight (VII) ── */`; `.st` is set to `'VII · THE DANCE'` at :5128, so this is world VII's OWN panel, not a generic one)
· #still → `transition:opacity 1.4s ease` — :4467 (I · THE POINT, header :4464)
· #going → `transition:opacity 1.1s ease` — :4487 (II · THE TURN, header :4483)
· #thru  → `transition:opacity 1.2s ease` — :4511 (III · THE VEIL, header :4507)
· #wall  → `transition:opacity 1.1s ease` — :4536 (IV · THE CHAMBER, header :4532)
· #word  → `transition:opacity 1.2s ease` — :4591 (THE FALL, header :4587)
· #lite  → `transition:opacity 1.3s ease` — :4603 (THE LIGHT, header :4601)

The set is named by the design itself, twice, which is what makes them siblings rather than seven unrelated rules: `:5265` `const READS=['still','going','thru','wall','sheet','word','lite'].map(...)` and `:4960` `const READING='#sheet,#still,#going,#thru,#wall,#word,#lite,#turn,#rope'`. Five distinct values (.9 / 1.1 / 1.2

**App** — Search was by ROLE, not by name — the app renames all seven and splits them across three files. Result: **no app site anywhere carries a per-panel fade duration.** One shared constant governs five of the seven, and it is none of theirs.

· #sheet (VII · the dance) → `ReadCompany` — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:1179` (dispatched at `:284` `default: ReadCompany(...)`)
· #still (I) → `ReadStillness` — `.../Point/PointReadings.swift:317` (dispatched `:278`)
· #going (II) → `ReadFollowing` — `.../Point/PointReadings.swift:418` (dispatched `:279`)
· #thru  (III) → `ReadParting` — `.../Point/PointReadings.swift:514` (dispatched `:280`)
· #wall  (IV) → `ReadPressing` — `.../Point/PointReadings.swift:700` (dispatched `:281`)

NONE of these five carries a root fade of its own. Every one of them is brought on screen by the single presentation site:

    /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:218
        withAnimation(.easeInOut(duration: 0.8)) { openStar = s }

`openStar` flips the `ZStack` branch at `PointWorldView.swift:171-184`, so SwiftUI's implicit `.opacity` transition runs at **0.8s easeInOut for all seven Point readings**. The reverse path is worse — `withAnimation { openStar = nil }` with no duration at

**Comment** — NONE of the strict kind. No app comment cites a sibling's line, because **no app comment cites ANY of the seven lines**: `grep -rn "4438\|4467\|4487\|4511\|4536\|4591\|4603"` over all `.swift` returns zero hits, and the only Instrument-CSS-range citations the app makes at all are `:4155`, `:4229-4239`, `:4276-4287`, `:4348-4351`, `:4385-4389`, `:4423-4426`, `:4621-4627`, `:4645`, `:4653-4656`, `:4682`, `:4899`, `:4923`. The group was never cited, so `check_citations` had nothing to verify — the class's usual tell is absent here because the port never made the claim.

Two near-misses worth reco

**Evidence** — WHY COLLAPSED AND NOT NOT-PORTED. The property is realized — every one of these panels does fade in — but five of the seven were routed through one shared constant at the presentation site instead of carrying their own. That is exactly what `whySiblings` predicted: *"COLLAPSED to a single duration is what a port that writes a shared panel base class produces."* `PointWorldView.swift:218` is that base class, in SwiftUI's idiom: the animation is attached to the state change, not to the view, so every branch of the `switch dimensionN` at `PointReadings.swift:277-285` inherits it and none can differ.

THE COLLAPSE VALUE IS NOT ANY MEMBER'S. 0.8 is not .9, 1.1, 1.2, 1.3 or 1.4. So this is COLLAPSED compounded with BOTH-WRONG: it is not the case that one sibling's number was stretched across the set (which would at least have preserved one correct member); a sixth number was introduced. The ne

**Refutation** — SURVIVES. I attacked it on four fronts and it held on all four.

DESIGN — all seven read exactly as quoted at the cited lines of `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html`: :4438 .9s, :4467 1.4s, :4487 1.1s, :4511 1.2s, :4536 1.1s, :4591 1.2s, :4603 1.3s. Each is the panel ROOT (each `#x.on` rule only sets `opacity:1`), so the duration governs the arrival. `diff -q` against Round 2's copy: IDENTICAL.

NOT NEAR-NEIGHBOURS — the siblinghood is the design's own: `:5265 const READS=['still','going','thru','wall','sheet','word','lite']` enumerates exactly these seven, and `:4462` lists the same set plus #turn/#rope for pointer-events. So the false-TRANSPOSED risk does not apply; and the finding does not call a transposition anyway.

#sheet IS NOT THE SUPERSEDED SHEE

### COLLAPSED — `reading-panel-lab-alpha` · rows `D2.4`, `D5.1`, `D5.3`
*The refutation corrected this from the checker's first verdict.*

**Design** — Four members, four distinct alphas, each on its own panel's hue — and each is exactly .06 or .08 under its own `.hd` eyebrow:

· `#still .lab` → `color:rgba(237,230,214,.60)` = #EDE6D6 @ **.60**  — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4476  (its `.hd`, :4470, is .66 → −.06)
· `#going .lab` → `color:rgba(185,165,232,.64)` = #B9A5E8 @ **.64**  — …/The Instrument v3.html:4498  (`.hd` :4491 is .70 → −.06)
· `#thru  .lab` → `color:rgba(125,116,201,.74)` = #7D74C9 @ **.74**  — …/The Instrument v3.html:4522  (`.hd` :4514 is .82 → −.08)
· `#wall  .lab` → `color:rgba(224,113,63,.78)`  = #E0713F @ **.78**  — …/The Instrument v3.html:4547  (`.hd` :4539 is .86 → −.08)

Fifth / ONE-MISSING candidate named in the group: `.sec .lab` (the sheet) → `color:#D4A94B;opacity:.66` — …/The Instrument v3.html:4449. Its v9 ancestor `.s-lab` is `color:var(--shue);opacity:.8` (Claude Design Round 1/comps/point-levels.js:46, The Point v9.html:1081).

All four `.lab` rules also share `margin-bottom:6px` (the sheet's is 7px; v9's is 9px) — that shared 6 is the fingerprint that identifies which source the app actually ported from.

**App** — There is no pair. **All four members resolve to one expression**, shared by all seven worlds:

/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:206-216 — `private struct SectionBlock`
    :214  `Text(section.label.uppercased()).spaceMonoTracked(9, em: 0.17)`
    :215      `.foregroundStyle(hue.opacity(0.7))`
    :213  `VStack(alignment: .leading, spacing: 6)`   ← the design's shared `margin-bottom:6px`

`hue` is the panel's own colour and the RGB half is EXACT for every member:
· /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:157 — `private var hue: Color { Color(hex: PointContent.hues["m\(dimensionN)"] ?? "#C0392B") }`
· /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointContent.swift:47-55 — m1 `#EDE6D6` · m2 `#B9A5E8` · m3 `#7D74C9` · m4 `#E0713F` — byte-for-byte the four `.lab` RGB triples.

Seven call sites, none of which overrides the label colour (they pass only `hue`, plus `mirrored`/`thinned`):
PointReadings.swift:362 (I · #still) · :469 (II · #going) · :564 (III · #thru, `thinned: true`) · :730 (IV · #wall) · :941 (V) · :1086 (VI) · :1263 (VII).

So: `.60 / .64 / .74 / .78` all became **0.7**, a value that is none of the four, not the sheet's `.66`, and not v9's `.8`.

The `.hd` partner group has no app expressio

**Comment** — YES — the misdirecting citation exists, and it is at the file's head rather than the site.

PointReadings.swift:27 — "The section labels are `openSheet`'s own, which were never the sheet's — they name the four sections and outlive it."

`openSheet` is Claude Design Round 1/comps/point-levels.js:161 — the v9 generic sheet, i.e. **the group's ONE-MISSING fifth member**, whose label rule is `.s-lab{…color:var(--shue);opacity:.8…}` (point-levels.js:46). That is a *correct* citation — the four label STRINGS genuinely are `openSheet`'s — attached to the wrong element for the property in question. It

**Evidence** — WHY COLLAPSED AND NOT ONE-MISSING OR BOTH-WRONG. The design distinguishes four siblings; the app gives all four (all seven, in fact) the identical value — the group's own definition of COLLAPSED. It is not ONE-MISSING because every member is ported and rendering; it is not BOTH-WRONG in the loose sense because the wrongness is not four independent errors but one shared constant.

THE PORT IS DEMONSTRABLY FROM THE FOUR-PANEL GROUP, NOT THE SHEET — which is what makes the collapse a dropped distinction rather than a different source:
· `VStack(spacing: 6)` at PointReadings.swift:213 matches `margin-bottom:6px`, which ALL FOUR v3 `.lab` rules carry and neither the v3 sheet (7px, :4449) nor v9 `.s-lab` (9px) does.
· The four RGB triples arrive intact and per-member through `PointContent.hues` m1–m4.
So the port reached the right four rules, took the shared spacing and the per-member colour, 

**Refutation** — The BUCKET is right; the FINDING is not safe to act on. Its design side is read pre-composite, and every number it hands a fixer is wrong.

WHAT I CONFIRMED (all reproduced independently)
· The four `.lab` colour constants read exactly as quoted: The Instrument v3.html:4476 `.60` · :4498 `.64` · :4522 `.74` · :4547 `.78`. `.sec .lab` at :4449 exact.
· App: PointReadings.swift:206 `SectionBlock`, :213 `VStack(spacing: 6)`, :214 label, :215 `.foregroundStyle(hue.opacity(0.7))`. Seven call sites at 362/469/564/730/941/1086/1263, none overriding the label colour (564's `thinned` and 941's `mirrored` touch only the BODY, :218). `spaceMonoTracked` (Theme.swift:151) adds no opacity.
· PointContent.swift:47-50 m1–m4 = #EDE6D6/#B9A5E8/#7D74C9/#E0713F, byte-exact to the four RGB triples; PointWorldV

### COLLAPSED — `reading-panel-quote-alpha` · rows `D2.4`, `D5.1`, `D5.3`

**Design** — Five panels, one element (`.bd.q` — the quoted body, i.e. the `say` and `open` sections), five constants:
· `.sec .bd.q` → `color:rgba(237,232,227,.66)` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4451 (the base rule; owns #sheet, and is the fallback for any panel without an ID override)
· `#still .bd.q` → `color:rgba(237,232,227,.68)` — same file:4478 (I · THE POINT)
· `#going .bd.q` → `color:rgba(237,232,227,.68)` — same file:4501 (II · THE TURN)
· `#thru .bd.q` → `color:rgba(237,232,227,.68)` — same file:4524 (III · THE VEIL)
· `#wall .bd.q` → `color:rgba(240,222,206,.70)` — same file:4551 (IV · THE CHAMBER — and the only one whose RGB also differs: the warm 240,222,206, not 237,232,227)

Context the group needs: the non-quoted sibling `.bd` sits at `.90` in four panels (:4450, :4477, :4500, :4523) and `.92` in the wall (:4549). So the design states TWO distinctions at once — quote-below-body (−.24 / −.22 / −.22 / −.22 / −.22) and panel-against-panel (.66 · .68 · .68 · .68 · .70). The `q` class itself is applied by five separate builders in the design's own JS — `:5139` (sheet), `:5165` (still), `:5189-5190` (going), `:5217-5218` (thru), `:5245-5246` (wall) — each `sec.k==='say'||sec.k==='open'?' q':''`.

**App** — ONE expression serves all five members. There is no per-panel port to pair against.

/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:206-224 — `private struct SectionBlock`, the single renderer of every reading section in the app:
  :217  `.font(section.quoted ? .loraItalic(15.5) : .lora(15.5))`
  :219  `.foregroundStyle(BinduTheme.inkPrimary.opacity(thinned ? 0.72 : 1))`

`BinduTheme.inkPrimary` is `#EDE8E3` = rgb(237,232,227) (Theme/Theme.swift:33) — the design's base ink, so the HUE is right for four of five members and wrong for the wall (which wants 240,222,206). The ALPHA is the fault: `.bd.q` and `.bd` get the identical value, and that value is none of the group's.

Per member, as actually rendered:
· `.sec .bd.q` (.66) → NO PORT — the generic sheet was superseded (E3 / row D4.2); the base rule's alpha survives nowhere.
· `#still .bd.q` (.68) → SectionBlock at :362, inside `ReadStillness` (:317-417). `thinned` unset ⇒ alpha **1.0**.
· `#going .bd.q` (.68) → SectionBlock at :469, inside `ReadFollowing` (:418-513). alpha **1.0**.
· `#thru .bd.q` (.68) → SectionBlock at :564-565, inside `ReadParting` (:514-699), the ONLY call site passing `thinned: true` ⇒ alpha **0.72** — applied identically to the quoted and unquoted sections, so III's own .90/.68 s

**Comment** — No app site carries a design LINE citation for this property, so the known instance's exact signature (a correct `:NNNN` pointing at the sibling) is NOT present here — `check_citations` had nothing to verify either way.

But the one comment that governs the quote face commits the same class of error one level up, citing the wrong MEMBER's authority. /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:171-172:

    /// `openSheet` set the first and last in its quote face.
    var quoted: Bool { self == .say || self == .open }

`openSheet` is the GENERIC SHEET's builder — th

**Evidence** — METHOD, and what it ruled out. Searched by role, not name: `quoted` / `isQuote` / `loraItalic` across the tree, the design's RGB triples (237,232,227 · 240,222,206 · 240,236,231 · 246,236,228), the raw constants 0.66/0.68/0.70, and the design line numbers 4451/4478/4501/4524/4551. `grep -rln PointSection` returns exactly one file. `SectionBlock` is declared once and has seven call sites. So there is no second, panel-specific renderer hiding elsewhere — both halves of every pair were located before the verdict, and the answer is that the app has one site where the design has five.

WHY COLLAPSED RATHER THAN NOT-PORTED. The element is ported and the `q` predicate is ported correctly (`say`/`open`, matching all five design builders); the italic half of `.bd.q` is ported at :217. Only the colour half is gone. That is a collapse of five distinguished values into one, not an absence of the ele

**Refutation** — Survives every refutation route. DESIGN VERIFIED VERBATIM at the exact cited lines in /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html: :4451 .sec .bd.q rgba(237,232,227,.66) | :4478 #still .68 | :4501 #going .68 | :4524 #thru .68 | :4551 #wall rgba(240,222,206,.70). Sibling .bd at :4450/:4477/:4500/:4523 = .90 and :4549-4550 = rgba(246,236,228,.92). Five builders at :5139/:5165/:5190/:5218/:5246, all with identical sec.k==='say'||sec.k==='open'?' q':''.

APP VERIFIED: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:206 declares SectionBlock; :217 ports the italic; :219 is .foregroundStyle(BinduTheme.inkPrimary.opacity(thinned ? 0.72 : 1)). Theme/Theme.swift:33 inkPrimary = #EDE8E3 = rgb(237,232,227). Dispatcher at :271-278 maps dimension 1-4 t

### COLLAPSED — `reading-panel-sec-margin` · rows `D5.1`, `D5.3`

**Design** — Five members, five sites, three distinct values (17 · 18 · 19):
· `.sec` (the sheet's) → `margin-bottom:19px` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4447
· `#still .sec` (I · THE POINT) → `margin-bottom:17px` — …/The Instrument v3.html:4472
· `#going .sec` (II · THE TURN) → `margin-bottom:18px` — …/The Instrument v3.html:4494
· `#thru .sec` (III · THE VEIL) → `margin-bottom:17px` — …/The Instrument v3.html:4518
· `#wall .sec` (IV · THE CHAMBER) → `margin-bottom:17px` — …/The Instrument v3.html:4543
The panels these belong to are confirmed at …/The Instrument v3.html:4659 (`#sheet`), :4676 (`#still` "I · THE POINT"), :4677 (`#going` "II · THE TURN"), :4678 (`#thru` "III · THE VEIL"), :4679 (`#wall` "IV · THE CHAMBER").

**App** — One expression, written five times over, carrying a value that is none of the members':
· `#still .sec` (17) → `VStack(alignment: .leading, spacing: 22)` — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:359 (under `// MARK: - I · THE POINT — stillness`, :295)
· `#going .sec` (18) → `VStack(alignment: .leading, spacing: 22)` — …/Point/PointReadings.swift:466 (`// MARK: - II · THE TURN — following`, :413)
· `#thru .sec` (17) → `VStack(alignment: .leading, spacing: 22)` — …/Point/PointReadings.swift:561 (`// MARK: - III · THE VEIL — parting`, :509)
· `#wall .sec` (17) → `VStack(alignment: .leading, spacing: 22)` — …/Point/PointReadings.swift:727 (`// MARK: - IV · THE CHAMBER — pressing`, :682)
· `.sec` (the sheet's, 19) → NO PORT. The generic sheet is ruled superseded (`PointReadings.swift:9-15`: *"E3 rules that sheet superseded: no generic reading ships, not anywhere, not as a fallback"*), so its 19px has no app site.
The remaining three worlds repeat the same literal at :934 (V), :1083 (VI), :1260 (VII). The sections themselves render through one shared type, `SectionBlock` — …/Point/PointReadings.swift:206-223, under the header `// MARK: - one section, in the shared type` (:204).
`grep -rn "spacing: 19|spacing: 17|spacing: 18"` over the app returns no re

**Comment** — NONE — and the absence is itself the tell, in the opposite direction from the `#where`/`#pname` instance.

`grep -rn "4447|4472|4494|4518|4543"` across the whole repo (`--include=*.swift --include=*.md --include=*.py`) returns **zero hits**. No app comment cites any of the five design lines, correctly or incorrectly. `PointReadings.swift` cites `The Instrument v3.html` only twice, both far from this group: `:74` (`:5876`, the rope's guard) and `:1301` (`:2264-2273`, the dance's grab). There is no comment of any kind above the four `spacing: 22` sites.

So this member escaped by SILENCE rather 

**Evidence** — THE PAIRING. The design spreads one property across five panels at 19/17/18/17/17. The app renders four of them (the fifth is ruled superseded) with a single literal, `22`, repeated verbatim — and 22 is not any member's value. So this is COLLAPSED with a BOTH-WRONG interior: not only are the panels no longer distinguished, the value they were collapsed onto is not the design's anywhere. Nothing was transposed; nothing was dropped-then-restored. A port wrote one number four times, and because the number is plausible for a reading stack, no rendering of it looks wrong.

WHY IT IS INVISIBLE, in this group's own terms. The `whySiblings` note predicted a port that "writes 17px five times." What actually happened is a degree worse and reads the same: the port wrote a *sixth* number five times. Three of the five members share 17, so a reader comparing app to design sees a uniform stack against 

**Refutation** — SURVIVES. I attacked it on six fronts and it held on all six; one attack produced new evidence against the app.

VERIFIED VERBATIM. All five design lines read exactly as quoted at exactly the cited line numbers (/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4447 `.sec{margin-bottom:19px…}`, :4472 `#still .sec{margin-bottom:17px…}`, :4494 `#going .sec{margin-bottom:18px…}`, :4518 `#thru .sec{margin-bottom:17px…}`, :4543 `#wall .sec{margin-bottom:17px…}`). Grepping those three values across the whole 6,081-line file returns only six lines — the five above plus `#sheet .ti` — so nothing else competes for the property. Panels confirmed at :4659, :4676-4679 with the exact hd strings. All four app sites read verbatim as `VStack(alignment: .leading, spacing: 22)` at /Users

### COLLAPSED — `reading-panel-side-padding` · rows `D5.1`, `D5.3`, `D5.8`

**Design** — DESIGN — five panels, five different side insets (all in /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html):
· #sheet  → padding:20px 28px 92px   :4435   (header at :4434 = "the reading, caught in flight (VII)"; :5120-5122 confirms it is VII · THE DANCE — `sheet.querySelector('.st').textContent='VII · THE DANCE'`)
· #still  → padding:22px 34px 96px   :4466   (I · THE POINT — the only member that also differs top AND bottom)
· #going  → padding:20px 30px 92px   :4484   (II · THE TURN)
· #thru   → padding:20px 32px 92px   :4508   (III · THE VEIL)
· #wall   → padding:20px 30px 92px   :4533   (IV · THE CHAMBER)
Side series: 28 / 34 / 30 / 32 / 30. Top: 20 / 22 / 20 / 20 / 20. Bottom: 92 / 96 / 92 / 92 / 92.

APP — one inset, five times. Every member ported to horizontal 32 / top 20 / bottom-spacer 90.

**App** — All ports are in /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift (the dispatcher `PointReading` at :255-292 switches on `dimensionN` into seven bespoke readings; no padding is applied at the dispatcher, so each reading's own site is the only one).

· #sheet (VII · THE DANCE) → `ReadCompany` (declared :1179, MARK at :1174)
    :1291  Color.clear.frame(height: 90)
    :1293  .padding(.horizontal, 32).padding(.top, 20)      design 28 → app 32   MISS (+4)
· #still (I · THE POINT) → `ReadStillness` (declared :317, MARK at :295)
    :380   Color.clear.frame(height: 90)
    :382   .padding(.horizontal, 32).padding(.top, 20)      design 34/22/96 → app 32/20/90   MISS on all three
· #going (II · THE TURN) → `ReadFollowing` (declared :418, MARK at :413)
    :483   Color.clear.frame(height: 90)
    :485   .padding(.horizontal, 32).padding(.top, 20)      design 30 → app 32   MISS (+2)
· #thru (III · THE VEIL) → `ReadParting` (declared :514, MARK at :509)
    :569   Color.clear.frame(height: 90)
    :571   .padding(.horizontal, 32).padding(.top, 20)      design 32 → app 32   matches, but only because 32 is the collapse value
· #wall (IV · THE CHAMBER) → `ReadPressing` (declared :700, MARK at :682)
    :770   Color.clear.frame(height: 90)
    :772   .padding(.horizonta

**Comment** — NONE — and the absence is itself the tell, in a different shape from the `#where`/`#pname` instance.

There is no comment above ANY of the five app sites. :382, :485, :571, :772 and :1293 are bare modifier chains; the nearest comments are about unrelated mechanisms (e.g. :467-468 "// one turn further out" on `.padding(.leading, Double(i) * 10)`, :761-766 on the press-claim release, :1276-1278 on `world-seven.js:503-505`).

Verified by grep across every .swift in the app: the strings `4435`, `4466`, `4484`, `4508`, `4533` appear ZERO times. `PointReadings.swift` cites `The Instrument v3.html` e

**Evidence** — COLLAPSED, in the exact shape `whySiblings` predicted: "a port normalising the set to one padding loses exactly one member's identity."

The design distinguishes five measures — 28 / 34 / 30 / 32 / 30 — and the app writes 32 five times (seven, counting V and VI). Four of five members carry a sibling's number rather than their own. #thru is the accidental survivor: its design value IS 32, so it reads MATCHED at its own site while being the same collapsed literal as the four misses. That is why a reader comparing app sites finds nothing — there is no odd one out to notice.

#still is the member the collapse costs most, and it loses on all three axes at once:
  design  padding:22px 34px 96px   (`The Instrument v3.html:4466`)
  app     .padding(.horizontal, 32).padding(.top, 20) + Color.clear.frame(height: 90)   (`PointReadings.swift:382`)
Its 34 is the widest measure in the set — the emptie

**Refutation** — SURVIVES ATTACK. Both halves read verbatim, and every refutation path closes.

VERIFIED VERBATIM. All five design lines are exact at the exact line numbers in /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html — :4435 `padding:20px 28px 92px`, :4466 `padding:22px 34px 96px`, :4484 `padding:20px 30px 92px`, :4508 `padding:20px 32px 92px`, :4533 `padding:20px 30px 92px`. All app sites are exact in /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift — `.padding(.horizontal, 32).padding(.top, 20)` preceded by `Color.clear.frame(height: 90)` at :382, :485, :571, :772, :1293 (and V :961, VI :1109). Seven sites, one literal.

REFUTATION 1 — ALTERNATE DESIGN SOURCE. The repo has a `Claude Design Round 2/`, which I did not assume away. Its `design-source/The 

### COLLAPSED — `reading-panel-ti-margin` · rows `D5.1`, `D5.3`

**Design** — Five members, five sites, three distinct values — verified verbatim:
· #sheet .ti → margin-bottom:18px — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4446
· #still .ti → margin-bottom:16px — .../The Instrument v3.html:4471
· #going .ti → margin-bottom:16px — .../The Instrument v3.html:4493
· #thru  .ti → margin-bottom:15px — .../The Instrument v3.html:4517
· #wall  .ti → margin-bottom:15px — .../The Instrument v3.html:4542
Everything else on the five rules is byte-identical (italic 13.5px, .52 alpha; only #wall's colour differs — rgba(240,222,206,.52) vs rgba(237,232,227,.52)). The margin is the only varying element, exactly as the group states.
Panel → app identity (from markup at :4659, :4676-4679): #sheet = the v9 generic reading sheet; #still = I · THE POINT; #going = II · THE TURN; #thru = III · THE VEIL; #wall = IV · THE CHAMBER.

**App** — There is ONE app expression for all five members, and it carries no margin at all.

Every reading's subtitle is rendered by a single shared view:
/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:237-250 — `private struct ReadingHead`
  :242  `VStack(alignment: .leading, spacing: 4) {`
  :247  `Text(star.ti).font(.loraItalic(14)).foregroundStyle(hue)`
`star.ti` is rendered at exactly one place in the whole app (grep for `star.ti` returns :247 plus one string interpolation in PointWorldView.swift:615). There is no per-panel subtitle view.

The gap BELOW the subtitle is not a property of the subtitle — it is the enclosing reading stack's uniform spacing, the same literal at every call site:
· #still → ReadStillness — PointReadings.swift:359 `VStack(alignment: .leading, spacing: 22)`, head at :360
· #going → ReadFollowing — PointReadings.swift:466 `VStack(alignment: .leading, spacing: 22)`, head at :467
· #thru  → ReadParting   — PointReadings.swift:561 `VStack(alignment: .leading, spacing: 22)`, head at :562
· #wall  → ReadPressing  — PointReadings.swift:727 `VStack(alignment: .leading, spacing: 22)`, head at :728
(The same 22 recurs at :934, :1083, :1260 for V/VI/VII, which this design group has no members for.)

· #sheet → NO PORT. PointReadings.swift:9-15 

**Comment** — NONE — and the absence is itself the tell.

`ReadingHead` (PointReadings.swift:237) has NO doc comment and no comment of any kind; the line above it is the closing brace of `ReadingFooter`. None of the four call sites (:359-360, :466-467, :561-562, :727-728) carries a comment on the spacing either — the nearest comments are about unrelated mechanisms ("one turn further out" at :470, "the light comes from BELOW" at :721).

Zero citations to `The Instrument v3.html:4446/4471/4493/4517/4542` exist anywhere in the tree (`grep -rn "4446\|4471\|4493\|4517\|4542" --include=*.swift` returns nothing). 

**Evidence** — COLLAPSED, with the fifth member NOT-PORTED under a standing ruling.

Design (verified by `grep -n "\.ti{"` on the design file — all five lines printed above): 18 / 16 / 16 / 15 / 15.
App: one shared expression, one value, for the four ported members.

Chain of evidence:
1. `grep -rn "star.ti" --include=*.swift` over /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed → PointReadings.swift:247 is the only render site. No second subtitle view exists to have been transposed against.
2. `grep -n "ReadingHead|VStack(alignment: .leading, spacing:|private struct Read"` on PointReadings.swift → seven `Read*` structs, seven `ReadingHead(...)` calls, seven `spacing: 22` stacks. The four this group owns are at :359/:360, :466/:467, :561/:562, :727/:728.
3. The subtitle's own container is `VStack(..., spacing: 4)` at :242, so the subtitle contributes no trailing space itself; the trailing space is the o

**Refutation** — SURVIVES. Every quoted line is verbatim.

DESIGN — `grep -n "\.ti{"` on /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html returns exactly five hits at 4446/4471/4493/4517/4542, reading 18/16/16/15/15, all `font-style:italic;font-size:13.5px`, alpha .52, only #wall's rgb differing (240,222,206 vs 237,232,227). Markup at :4659 and :4676-4679 confirms the panel identities (#sheet generic `read`; #still I·THE POINT, #going II·THE TURN, #thru III·THE VEIL, #wall IV·THE CHAMBER), each `<div class="ti"></div>` sitting between `<h2>` and its `#*Secs` container — so `margin-bottom` is genuinely the subtitle→first-section gap, and the five are true siblings, not unrelated elements that happen to sit near each other. AUDIT.md:454 (D5.1) independently names these same five panels a

### COLLAPSED — `return-seal-label-tracking` · rows `E1.18`, `E3.11`, `E3.12`, `E3.13`, `E3.8`, `E3.9`, `F0.1`

**Design** — Round 1 comps — /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html
 · M1 "◉ and then you sealed yours · {PAST_SELF.when}" → letterSpacing:'0.2em' — :570
 · M2 "◉ {PAST_SELF.label} · {PAST_SELF.when}" → letterSpacing:'0.2em' — :611
 · M3 "◉ you, now · in reply to you, then" → letterSpacing:'0.18em' — :647
 · M4 "◉ you, now · today" → letterSpacing:'0.2em' — :673
 · (control, ◉-less) "who kept sitting with it" → 0.18em — :592

THE APP'S ACTUAL SOURCE IS v2, AND v2 KEEPS THE SAME SPLIT. Every citation in ReturnView.swift/ReturnCanon.swift names `The Return v2.html` (e.g. ReturnCanon.swift:7 "All user-facing text verbatim from `The Return v2.html`"). /Users/ashrey/Bindu Feed/Claude Design Round 1/The Return v2.html:
 · :1148 "◉ and then you sealed yours · {first.when}" → 0.2em  (= M1)
 · :1217 "◉ you, now · in reply to you, {prior.when}" → 0.18em (= M3)
 · :1241 "◉ you, now · today" → 0.2em  (= M4)
 · :1170 "who kept sitting with it" → 0.18em; :1093 "the room remembers you" → 0.18em
 · M2 has NO v2 counterpart — v2's eight `data-screen-label` movements (:1067–:1239) contain no "Your Past Self"; the comps' standalone IV was folded into the Record. Identical in /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Return v2.html (same 1148/1217/1241).
So th

**App** — Helper semantics first: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151-152 — `func spaceMonoTracked(_ size: CGFloat, em: CGFloat = 0) -> some View { self.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size) }`. `em` is em units; tracking = em × size. InstrumentView.swift:531 confirms the convention in a comment: `.spaceMonoTracked(9, em: 0.3)  // .3em × 9`.

All ports live in one file: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift
 · M1 → :321 `Text(ReturnCanon.recordSealedYou(when: storyData.sealedWhen)).spaceMonoTracked(9, em: 0.5 / 9)` = **0.0556em** (design 0.2em)
 · M2 → NO PORT, and none is owed: the movement does not exist in v2 (app stages are summons · room · storyAgain · record · fieldAnew · rings · reply · sealing). String `recordSealedYou` at ReturnCanon.swift:52 is the only "sealed yours" label in the app.
 · M3 → :499-500 `Text("◉ you, now · in reply to you, \(storyData.sealedWhen)").spaceMonoTracked(9, em: 0.5 / 9)` = **0.0556em** (design 0.18em)
 · M4 → :601 `Text("◉ you, now · today").spaceMonoTracked(9, em: 0.5 / 9)` = **0.0556em** (design 0.2em)
 · control "who kept sitting with it" → :361 `.spaceMonoTracked(9, em: 0.18)` — **CORRECT**
 · control "the room remembers you" → :247 `.spaceMonoTracked(9,

**Comment** — NONE — and the absence is itself the tell. There is no comment and no design citation on any of the three ◉ sites (:321, :500, :601): the lines are bare. So `check_citations` never had a string to verify here at all — this instance hid by carrying no claim rather than by carrying a correctly-formed claim about the wrong sibling.

The contrast is one movement away, on a sibling that IS correct. ReturnView.swift:246-247:
  `// \`:1093\` — the room's own line, in the room's own colour, aged.`
  `Text(ReturnCanon.roomRemembers(room: storyData.roomName)).spaceMonoTracked(9, em: 0.18)`
That citation

**Evidence** — PROVENANCE — the wrong constant is a pre-existing app default that a CASE sweep laundered into em-notation. `git log -S "0.5 / 9" -- Screens/ReturnView.swift` → b19f1d6 ("E1.18 the mono case as a default · check_stale, the seventh gate"). Its diff:

  - Text(ReturnCanon.recordSealedYou(when: storyData.sealedWhen)).font(.spaceMono(9)).textCase(.uppercase).tracking(0.5)…
  + Text(ReturnCanon.recordSealedYou(when: storyData.sealedWhen)).spaceMonoTracked(9, em: 0.5 / 9)…
  - Text("◉ you, now · in reply to you, \(storyData.sealedWhen)").font(.spaceMono(9)).textCase(.uppercase).tracking(0.5)…
  + …spaceMonoTracked(9, em: 0.5 / 9)…
  - Text("◉ you, now · today").font(.spaceMono(9)).textCase(.uppercase).tracking(0.5)…
  + …spaceMonoTracked(9, em: 0.5 / 9)…

The pre-sweep app had a flat `.tracking(0.5)` on every mono label in this file — a house constant, never the design's. The migration divided

**Refutation** — Survives every attack. DESIGN VERIFIED VERBATIM: comps The Return.html :570/:611/:647/:673 = 0.2/0.2/0.18/0.2, :592 = 0.18; The Return v2.html :1148/:1217/:1241 = 0.2/0.18/0.2, :1093/:1170 = 0.18. Mono at v2:1042 is <span className="mono" style={{fontSize,color,...style}}> and .mono is letter-spacing:0.14em (v2:923), so each inline letterSpacing is a real override, not additive. RE-SOURCING TO v2 IS SOUND AND MOOT: ReturnCanon.swift:7 does cite v2; v2's data-screen-label set (Summons/fall/Aged Room/Story Again/Record/Field Settled/Rings/Reply/Sealing) contains no "Your Past Self", so M2 is correctly unported; Round 1 and Round 2 design-source copies of v2 are byte-identical (diff -q silent); and comps and v2 agree on all three live members, so the fix is identical under either canon. APP V

### COLLAPSED — `return-threshold-tones-per-crossing` · rows `E4.5`, `G3.2`

**Design** — Frequency axis — all four distinguished, all four present:
· room → story   → Sound.threshold(126,7) — `Claude Design Round 1/comps/The Return.html:703`
· story → record → Sound.threshold(168,7) — `Claude Design Round 1/comps/The Return.html:704`
· record → field → Sound.threshold(189,7) — `Claude Design Round 1/comps/The Return.html:705`
· field → rings  → Sound.threshold(252,8) — `Claude Design Round 1/comps/The Return.html:706`  ← the ONE-DIFFERENT: 8, not 7

Duration axis: 7 · 7 · 7 · **8**. The fourth crossing alone is longer.

THE LINEAGE MATTERS AND I CHECKED IT. There is a second, later design document for this ceremony, and the design ITSELF performed the collapse before the app did:
· `Claude Design Round 1/The Return v2.html:1314` (byte-identical to `Claude Design Round 2/design-source/The Return v2.html:1314`) is `const cross=(hz,next)=>{Sound.threshold(hz,7);…}` — the four per-crossing calls refactored into ONE helper with 7 hardcoded, and the four call sites (`:1318-1321`) passing hz only: `cross(126,'story')` · `cross(168,'record')` · `cross(189,'field')` · `cross(252,'rings')`.
· So the 8 exists in exactly one file in the whole repo: the R1 comp. `Claude Design Round 2/comps/The Return.html` contains no `Sound.threshold` at all (it is the renderAnswers/renderRings

**App** — All four ports located, all in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift`. The app renamed nothing — the crossings kept their hz — but it ported the v2 HELPER, not four calls:

`ReturnView.swift:192-193` — the single shared helper, the one and only place a duration is stated:
    private func cross(_ hz: Double, _ next: ReturnStage) {
        soundEngine.fieldThreshold(hz: hz, dur: 7)   // `The Return v2.html:1314` — threshold(hz,7)

· room → story   → `ReturnView.swift:254`  `.onTapGesture { cross(126, .story) }`        → hz 126, dur 7
· story → record → `ReturnView.swift:268`  `Button { cross(168, .record) }`              → hz 168, dur 7
· record → field → `ReturnView.swift:333`  `Button { cross(189, .field) }`               → hz 189, dur 7
· field → rings  → `ReturnView.swift:400`  `cross(252, .rings)`                          → hz 252, dur **7**  ← COLLAPSED

PAIRING RESULT, per axis:
· FREQUENCY — MATCHED, four for four. Each app site carries ITS OWN member's constant on its own crossing, in the design's order and on the correct destination stage. No transposition, nothing dropped, no sibling's number anywhere.
· DURATION — COLLAPSED on member 4. The design distinguishes 7/7/7/8; the app gives all four the same 7, because the duration is not at

**Comment** — NONE of the known shape — no comment on one member cites another member's design line. But there IS a citation-shaped shield doing the same protective work, and it is the only comment any of these five sites carries about the tone:

`ReturnView.swift:193` — "soundEngine.fieldThreshold(hz: hz, dur: 7)   // `The Return v2.html:1314` — threshold(hz,7)"

That citation is CORRECT — `The Return v2.html:1314` really is `Sound.threshold(hz,7)`, verbatim. The fault is structural rather than referential: it cites the design's REFACTORED HELPER, whose signature `(hz, 7)` has no per-crossing duration in i

**Evidence** — WHAT I AM AND AM NOT CLAIMING. Frequency: MATCHED, four for four, verified at each site. Duration: the app's fourth crossing is 7 where `comps/The Return.html:706` says 8 — that fact is not in doubt. But this is **not a porting error**; it is a design-lineage divergence the port inherited. `The Return v2.html:1314` collapsed the four calls into one helper with 7 hardcoded, the app is a verbatim port of that helper, and the R1 README ranks v2 as the ceremony's blessed document over the comp. Whoever reads this should adjudicate precedence, not go patch `ReturnView.swift:193` to a conditional 8 — that would make the app diverge from the file it cites.

WHY IT STILL BELONGS IN THE SWEEP. The fault class is a distinction the design draws that the app does not, surviving because a correct citation makes it unaskable. That is precisely what happened, one layer further up than the `#where`/`#pn

**Refutation** — ATTACKED ON EVERY AXIS; IT SURVIVES, AND TWO OF MY CHECKS STRENGTHEN IT.

VERBATIM CHECKS — all pass. Design `comps/The Return.html:703-706` read exactly as quoted, including `Sound.threshold(252,8)` at :706. App `ReturnView.swift:192-193` (helper, `dur: 7`, citing `The Return v2.html:1314`) and the four call sites `:254` `cross(126,.story)`, `:268` `cross(168,.record)`, `:333` `cross(189,.field)`, `:400` `cross(252,.rings)` all read as quoted; `grep "cross("` returns exactly those five lines, so there is no fifth site and no per-site duration hiding anywhere. `The Return v2.html:1314` and its call sites `:1318-1321` confirmed; R2 design-source v2 identical at the same line; R2 comp has zero `Sound.threshold`. Audit rows E4.5 (`:334`) and G3.2 (`:381`) confirmed verbatim, both CLOSED 2026-

### COLLAPSED — `rite-keyframe-troughs` · rows `D7.6`, `E2.1`, `E2.5`

**Design** — Three consecutive keyframes, `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Rite v3.html`:

· `@keyframes breathe`     → trough 0.55, peak 1.00   · :1158
· `@keyframes breatheSoft` → trough 0.30, peak 0.62   · :1159
· `@keyframes heartbeat`   → 0.10 / 0.30 / 0.12 / 0.26 / 0.10 at 0% · 8% · 16% · 26% · 40%  · :1160

Their consumers in the same file (this is what the app had to pair against):
`breathe` — :1292 Arrival room glyph · :1335 Reading's "The field gathers" button · :1443 Gathering intro line · :1478 + :1484 the two Recognition mic buttons · :1488 "finding the words…" · :1524 the Sealing glyph.
`breatheSoft` — :1297 "touch to receive" · :1348 "received at the pace of breath" · :1447 the silent glyphs · :1452 the touch hint.
`heartbeat` — :1454 the 34×3 bar.

Corpus context (the sibling family the app actually drew from): `comps/The Gathering v3.html:20-21` = breathe .5/1, breatheSoft **.28/.6**; `comps/The Light v2.html:28` = breatheSoft **.28/.6**; `comps/The Return.html:22` = breathe .5/1; `The Return v2.html:927-928` = .3/.62 and .55/1 (identical to the Rite).

**App** — **Member 3 · `heartbeat` 0.10 — PORTED EXACTLY.**
`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:165-172` — `heartbeatOpacity(_:)` reproduces all five stops and all four boundaries: `0.10 + 0.20*(sub/0.08)` → `0.30 - 0.18*…` → `0.12 + 0.14*…` → `0.26 - 0.16*…` → `0.10`, at sub < 0.08 / 0.16 / 0.26 / 0.40. Rendered at `:155-162`, 34×3, bottom 9. Matches `:1160` and `:1454` including the bar's geometry.

**Member 1 · `breathe` 0.55 — NO APP SITE CARRIES IT.** Its six design consumers landed as:
· `Screens/RiteView.swift:161` (Arrival glyph) → `GlyphView(…, animation: .glyphBreathe, glow: 20)` → `Theme/GlyphAnimation.swift:92-95`: `opacity = 0.65 … → 1.0`, plus `scale 0.97 → 1.06`, default period 4.5s. Trough **0.65** — a different comp's glyph family, and 0.65 is not that family's number either (Player Detail `glyphBreath` = 0.72, Game View / Room Selection `glyphBreathe` = 0.80).
· `Screens/RiteView.swift:230-236` (gather button) → `.transition(.opacity)` only. No breathing.
· `Screens/RiteGatheringView.swift:68` (Gathering intro) → `.transition(.opacity)` only. No breathing.
· `Screens/RiteRecognitionView.swift:66-71` and `:101-107` (the two mic buttons) → no breathing on either.
· `Screens/RiteRecognitionView.swift:113-116` ("finding the words…")

**Comment** — **No comment anywhere in the app cites `:1158`, `:1159` or `:1160`** — `grep -n "1158\|1159\|1160\|breatheSoft"` over the whole Swift tree returns 0 hits, and `breatheSoft` appears nowhere in `Coverage/` either. So there is no literal cross-citation of a sibling's line. The equivalent tell is present in two other shapes:

1. `Screens/RiteView.swift:160` — `// The breathing, glowing room glyph — the Arrival's centerpiece (comp The Rite v3).` — directly above the site that renders `.glyphBreathe`, whose own comment at `Theme/GlyphAnimation.swift:91` reads `// A living breath swells AND brightens

**Evidence** — **The fault is COLLAPSED, and the collapsing agent is a named type.** `RiteBreathe` (`Screens/RiteView.swift:20-24`) is ONE expression standing in for BOTH registers the design distinguishes: it is applied at `RiteRecognitionView.swift:116`, where the design specifies `breathe` (0.55/1.00), and at `RiteView.swift:256` and `DoorView.swift:134`, where the design specifies `breatheSoft` (0.30/0.62). Two registers, one value — the brief's COLLAPSED definition exactly. And the value it collapses to, [0.28, 0.70], is **neither member's**: the trough 0.28 is `comps/The Gathering v3.html:21` / `comps/The Light v2.html:28`'s breatheSoft, and the peak 0.70 is no comp's number at all.

Two aggravations sit on top of the collapse:

1. **`breathe`'s 0.55 was never ported at any Rite site** (a NOT-PORTED member inside a COLLAPSED group). Six design consumers: two carry no breathing at all (`RiteView.s

**Refutation** — ATTACKED ON SIX FRONTS; IT SURVIVES ALL SIX.

1. DESIGN LINES — EXACT. `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Rite v3.html:1158-1160` read verbatim as quoted (`breathe` .55/1 · `breatheSoft` .30/.62 · `heartbeat` .10/.30/.12/.26/.10). All twelve consumer lines (:1292 :1297 :1335 :1348 :1443 :1447 :1452 :1454 :1478 :1484 :1488 :1524) verified by grep, each carrying the animation the finding assigns it — including :1488's `breathe 3s` on "finding the words…".

2. APP SITES — EXACT, line numbers included. `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteView.swift:20-24` is `content.opacity(0.28 + 0.42 * breath.value)`. I negative-verified the arithmetic at its root: `Instrument/Breath.swift:93` is `value = (1 - cos(p * 2 * .pi)) / 2`, so value ∈ [0,1] and the ra

### COLLAPSED — `rooms-per-room-glow-radius` · rows `F3.4`, `F4.3`

**Design** — All seven design sites confirmed verbatim at the cited lines in `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Room Selection.html`. `glow` is an INDEPENDENT column sitting on the same line as `gSize`:

ROOMS (`const ROOMS`, :493-558)
· maya       → glow 20  (`:496`  `glyph: '◈', gSize: 48, glow: 20,`)
· watcher    → glow 13  (`:506`  `glyph: '◇', gSize: 42, glow: 13,`)
· descent    → glow 24  (`:511`  `glyph: '·',  gSize: 34, glow: 24,`)
· forgetting → glow 13  (`:521`  `glyph: '○', gSize: 44, glow: 13,`)
· field      → glow 22  (`:556`  `glyph: '∞', gSize: 52, glow: 22,`)

TURNS (`const TURNS`, :566-577)
· mirror      → glow 18 (`:569`  `glyph: '◐', gSize: 30, glow: 18,`)
· signalspace → glow 18 (`:574`  `glyph: '⊙', gSize: 31, glow: 18,`)

(The other eight rooms, for the table's shape: garden 16 · return 18 · remembering 14 · body 18 · thread 15 · circle 15 · signal 20 · forge 15. Fifteen members, seven distinct values, four ties.)

Consumed at the two template sites named in the group:
· `:622` PortalCard — `filter: \`drop-shadow(0 0 ${room.glow}px ${room.color}65)\``
· `:664` TurnCard   — `filter: \`drop-shadow(0 0 ${turn.glow}px ${turn.color}65)\``

THE LOAD-BEARING FACT: `glow` is deliberately DECOUPLED from `gSize`. descent has the SMALLEST glyph (34) and the LARGE

**App** — NOT ONE of the seven carries its own glow constant. Every one resolves through a single fallback keyed to the SIBLING property (`size`).

The renderer — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:60`
    private var glowRadius: CGFloat { glow ?? size * 0.20 }
`:67-68` then spends it: `.shadow(color: color.opacity(0.55), radius: glowRadius)` + `.shadow(…, radius: glowRadius * 0.4)`.

The five ROOMS — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/RoomPortalCard.swift:22-27`
    GlyphView(
        glyph: room.glyph,
        size: RoomStyle.forRoom(room.name).portalGlyph,   // the room's own portal scale (comp 34–52)
        color: room.color,
        animation: room.animation
    )
No `glow:` argument. `portalGlyph` comes from `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/RoomStyle.swift:24-36`, whose struct (`:8-15`: heroSize, heroWeight, heroItalic, heroTrackingEm, uppercase, heroGlyph, portalGlyph) HAS NO GLOW FIELD AT ALL. Resulting radii:
· maya       `RoomStyle.swift:24` portalGlyph 48 → 9.6   vs design 20  (48%)
· watcher    `RoomStyle.swift:26` portalGlyph 42 → 8.4   vs design 13  (65%)
· descent    `RoomStyle.swift:27` portalGlyph 34 → 6.8   vs design 24  (28%)
· forgetting `RoomStyle.swift:29` portalGlyph 44 → 8.8   vs d

**Comment** — YES — and it is the sharpest form of the tell yet: a correct citation of the design's template with the one per-member number ELIDED.

`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:48-50`
    /// The coloured halo every glyph floats in (comp: `drop-shadow(0 0 …px color65)`).
    /// Defaults to a size-proportional glow; pass an override for a stronger hero glow.
    var glow: CGFloat? = nil

That quotes `Room Selection.html:622` — `drop-shadow(0 0 ${room.glow}px ${room.color}65)` — reproducing the `0 0` and the `65` alpha verbatim, and replacing the ONE token that 

**Evidence** — VERDICT REASONING — why COLLAPSED and not NOT-PORTED or TRANSPOSED.

Not NOT-PORTED: the halo is genuinely on screen. `GlyphAnimation.swift:67-68` draws the design's two-layer drop-shadow and the `0.55`/`0.35` alphas are real work. The MECHANISM is ported.

Not TRANSPOSED, and this is the trap the group description flagged: with 13/13 and 18/18 in the table, a swap between watcher and forgetting, or between mirror and signalspace, would be invisible by construction. I checked for it anyway and it cannot have happened — because no member carries any glow constant, there was nothing to transpose. The repeated values did their damage a different way: they made the table look cheap to skip.

COLLAPSED is exact, in the rail's sense from the brief. The port exists; the differentiating constant is dropped; all seven members are handed the same RULE (`size * 0.20`) rather than the same VALUE, wh

**Refutation** — HOLDS. Every load-bearing claim verified independently; no refutation survives.

DESIGN (all 7 verbatim at cited lines). `grep -n "glow:" "Room Selection.html"` returns exactly :496 maya 20 · :506 watcher 13 · :511 descent 24 · :521 forgetting 13 · :556 field 22 · :569 mirror 18 · :574 signalspace 18. `glow` is an independent column beside `gSize` on the same line. Both consumers read as quoted: :622 `filter: `drop-shadow(0 0 ${room.glow}px ${room.color}65)`` and :664 the turn equivalent.

APP (all sites exist and read as quoted). GlyphAnimation.swift:50 `var glow: CGFloat? = nil`; :60 `private var glowRadius: CGFloat { glow ?? size * 0.20 }`; :67-68 the two shadows at 0.55/0.35. RoomPortalCard.swift:22-27 and FieldSurfacePortalCard.swift:48-53 pass NO `glow:` argument. RoomStyle.swift:8-1

### COLLAPSED — `sound-voice-peak-gain` · rows `C7.1`, `C7.11`, `C7.3`, `C7.4`, `C7.5`, `C7.6`, `C7.8`, `C7.9`, `E4.7`

**Design** — Ten members, design → value → site (all `Claude Design Round 1/The Instrument v3.html`, mirrored verbatim in `/Users/ashrey/Bindu Feed/canon/spine-sound.js`):
· B.travel glide TONE → `s*0.030` → :4180 (canon :49)
· B.travel glide NOISE → `s*s*0.022` → :4182 (canon :51)
· B.trail → `0.026/(i+1.6)` → :4194 (canon :63) — peaks 0.01625 · 0.010
· B.strain → `f*f*0.030` → :4213 (canon :82)
· B.give → `0.055` → :4223 (canon :92)
· B.carry → `0.034/(i*0.6+1)` → :4235 (canon :104) — 0.034 · 0.02125 · 0.0155
· B.rush → `env*0.042` → :4255 (canon :124)
· B.gate → `0.048` → :4266 (canon :135)
· B.thin → `f*f*0.026` → :4285 (canon :~153)
· B.ungrip → `0.024` → :4298 (canon :~166)
The design's mix ordering at full scale: give 0.055 > GATE 0.048 > rush 0.042 > carry 0.034 > glide/strain 0.030 > thin 0.026 > UNGRIP 0.024 > glide-noise 0.022 > trail.

**App** — · glide TONE — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1459` `glideVoice?.set(hz: hz, level: min(0.03, level))`, fed from `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:340` `level: min(0.03, travel.speed * 8)`. Ceiling 0.030 = its own. (Slope diverges: design is `min(1,speed*150)*0.030` = `min(0.030, speed*4.5)`; app is `min(0.03, speed*8)`.)
· glide NOISE — **NO PORT.** `AxisGlideVoice` (`Sound/AxisTones.swift:106-142`) is two sines only; no noise source, no bandpass at `hz*2.4`/Q 1.1, and `0.022` appears nowhere in the axis sound code.
· trail — `Sound/SoundEngine.swift:1504-1507`, `peak: 0.026, mode: .twin`. Numerator its own; the `/(i+1.6)` ladder is absent — `.twin` splits 0.5/0.5 (0.013 · 0.013) where the design is 0.01625 · 0.010.
· strain — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisModel.swift:454` `(c * c * 0.030, 300 + c * 1500)`, set from `SoundEngine.swift:1516-1519`. Its own.
· give — `Sound/SoundEngine.swift:1529-1534`, `peak: 0.055`. Its own (repaired 2026-08-31).
· carry — `Instrument/AxisModel.swift:478` `0.034 / (Double(i) * 0.6 + 1)`, played `SoundEngine.swift:1126-1145`. Its own, ladder intact.
· rush — `Instrument/AxisModel.swift:467` `(env * 0.042, …)`, set `SoundEngine.sw

**Comment** — NONE. Every comment I read on these ten sites cites its OWN member's design lines — `SoundEngine.swift:1508` cites `canon/spine-sound.js:70-85` for strain, `:1521` cites `:87-96` for give, `:1535` cites `:110-127` for rush, `AxisModel.swift:471` cites `:97-109` for carry, `AxisTones.swift:174` cites `The Instrument v3.html:4276-4287` for thin. No `#where`-style cross-citation.

The two collapsed members carry NO citation at all, which is how they escaped: `SoundEngine.swift:1549` is only `// a gate passing — hz×3 → hz×1.5` and `:1561` only `// the field answering an opened hand — 174→232`. Bot

**Evidence** — **THE COLLAPSE.** `B.gate` (0.048) and `B.ungrip` (0.024) are the design's loudest and quietest one-shots in this register — a clean 2:1, the gate passing OVER him against the field's answer to an opened hand, *"a breath, never a reward."* The app gives both `peak: 0.03` (`SoundEngine.swift:1551` and `:1563`). One relationship, erased in both directions: the gate is 37.5% quiet, the ungrip 25% loud, and the interval between them is gone.

0.03 is not a neutral guess — it is a THIRD sibling's constant, the glide's `s*0.030` (`:4180`) and strain's `f*f*0.030` (`:4213`), the two continuous voices that run underneath everything. So the two events that are supposed to punctuate the bed were both set to the bed's own level. That is why it survives listening: the mix still sounds like a mix, and the header's rule — glide, crossings and trail running at once — is exactly where a gate flattened t

**Refutation** — SURVIVES ATTACK. All ten design lines read exactly as quoted (HTML :4180/4182/4194/4213/4223/4235/4255/4266/4285, canon/spine-sound.js :49/51/63/82/92/104/124/135/154/165), and all ten app sites read exactly as quoted (SoundEngine.swift:1459/1506/1531/1551/1563; AxisTones.swift:208; AxisModel.swift:454/467/478).

THE COLLAPSE IS REAL. Design B.gate=0.048 and B.ungrip=0.024 — a clean 2:1, the loudest and quietest one-shots in the register — both render as `peak: 0.03` at SoundEngine.swift:1551 and :1563. Two distinct design values onto one app value is COLLAPSED by definition; the interval is erased in both directions (gate 37.5% quiet, ungrip 25% loud).

SIX REFUTATION PATHS TRIED, ALL CLOSED:
(1) Alternate design source — the strongest out. SoundEngine.swift:649 cites a SECOND `Claude Des

### ONE-MISSING — `asf-turn-caption-tracking` · rows `F0.1`, `F11.2`, `F11.3`

**Design** — Member A — the "WHERE TO" caption → `fontSize:10, letterSpacing:'0.34em'` (= 3.4px) at /Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:439. Corroborated in Round 2 at /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Instrument v3.html:4397 — `#turn .hd{…font-size:10px;letter-spacing:.34em…}`.

Member B — the "tap anywhere to stay" caption → `fontSize:9, letterSpacing:'0.2em'` (= 1.8px) at /Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:457 (the string itself closes on :458). Corroborated in Round 2 at /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Instrument v3.html:4407-4408 — `#turn .foot{…font-size:9px; letter-spacing:.2em…}`.

Both rounds agree on both members. There is no third source and no 0.22em variant anywhere to exonerate the app's value.

**App** — Both members are ported, in one file, 30 lines apart, in the same VStack.

Member A — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:63-64
    Text("WHERE TO")
        .spaceMonoTracked(10, em: 0.34)
Helper (Theme.swift:151) is `.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size)`, so this resolves to tracking 3.4pt. Design: 0.34 × 10 = 3.4. EXACT.

Member B — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:93-94
    Text("tap anywhere to stay")
        .spaceMonoTracked(9, em: 2 / 9)
`2 / 9` = 0.2222em → tracking (2/9) × 9 = 2.0pt. Design: 0.2 × 9 = 1.8pt. The caption is tracked 11.1% wider than authored (+0.2pt per gap, ≈ +4pt across the 20-character centred line).

The design's 0.2 never entered the file. Git shows why. At the original build (d77b963, "Wave 4: the turn unifies navigation") member A was written `.font(.spaceMono(10)).tracking(3.4)` — the design's em already correctly multiplied out — while member B was written `.font(.spaceMono(9)).tracking(2)`, a hand-chosen round 2pt. Then commit b19f1d6 (the F0.1 helper sweep) mechanically re-expressed each raw `tracking(n)` as `em: n / size`: A became `em: 0.34` (right, and it round-trips), B became `em: 2 / 9` (the original guess, now wearing an em r

**Comment** — NONE in the strict sense — there is no comment directly above either app site, so no comment on one member cites the other member's design line. The known instance's exact tell is absent here.

Two weaker analogues are worth recording, because the second is where the substitution actually happened:

1. TurnOverlay.swift:60 — `.onTapGesture { onStay() }              // tap anywhere to stay`. Member B's caption text is attached as an inline comment to the overlay's background tap handler, three lines above member A's site and 33 lines above member B's own render site. A reader scanning for that 

**Evidence** — WHAT IS WRONG: member B, the turn's foot caption, is tracked at 2.0pt where the design authors 1.8pt. Member A is exact. Neither member's value sits on the other, so this is not the swap — it is the ONE-MISSING variant: A ported with its constant, B ported without one, a round hand-picked number standing in its place.

WHY IT SURVIVED — the same shape as the known instance, by a different route:
· The wrong number does not look wrong. `em: 2 / 9` reads as a deliberate ratio — as if someone derived 2pt-at-9pt on purpose. Written as `0.222` it would have been challenged on sight; written as a fraction it reads as authored intent. A value checker comparing `2 / 9` to `0.2` needs to evaluate the expression first.
· It is corroborated by twelve siblings. The identical `em: 2 / 9` appears across ApertureView, PointWorldView, LightView and ReturnView, all introduced by one commit. A reader who 

**Refutation** — SURVIVES. Every load-bearing claim verified by direct read; the two flaws found are in supporting rhetoric, not in the measurement.

DESIGN, exact as quoted. A Strange Feed.html:439 = `fontSize:10,letterSpacing:'0.34em'` (member A); :456-458 = `fontSize:9,` / `letterSpacing:'0.2em',textTransform:'uppercase'` / `tap anywhere to stay` (member B). Corroboration in Round 2's The Instrument v3.html:4397 (`.hd` .34em) and :4407-4408 (`.foot` .2em) — but note that file is BYTE-IDENTICAL to Claude Design Round 1/The Instrument v3.html (diff -q clean), so it is one source echoed, not a second independent witness. 0.2em remains the only value the turn's foot ever carries.

APP, exact as quoted. TurnOverlay.swift:63-64 `.spaceMonoTracked(10, em: 0.34)`; :93-94 `.spaceMonoTracked(9, em: 2 / 9)`. Helpe

### ONE-MISSING — `fieldsound-bed-duck-depths` · rows `E4.3`, `G3.3`

**Design** — Member A — `voice()` ducks the bed → 0.030 → **0.018** at `t+c.atk`, back to 0.030 at `t+life+1.6` (a per-voice attack in, a `life+1.6` return out).
  · "/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light - S-L01 Dawn.html:151-154" (`if(this.bed){ // the bed steps back while a voice speaks, then returns`)
  · same code, same numbers, in all three copies of the shared module: "/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/field-sound.js:132-135", "/Users/ashrey/Bindu Feed/Claude Design Round 1/field-sound.js:132-135", "/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/field-sound.js:132-135"

Member B — `bowl()` ducks the bed → 0.030 → **0.006** at `t+1.2`, back to 0.030 at `t+9` (three-times-deeper floor, far longer hold).
  · "/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light - S-L01 Dawn.html:188-189"
  · shared module: "/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/field-sound.js:168-169" (and :168-169 in both Round 1 copies)

Both restore to the bed's resting 0.030 (`startBed`, field-sound.js:59) — which is exactly what makes the differing floors look like a copy-paste, as the group notes.

**App** — Member B (bowl) — PORTED, with its OWN constants, exact:
  · "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/RiteTones.swift:45-49" — `bedRest = 0.030`, `bedDucked = 0.006`, `duckInSeconds = 1.2`, `duckOutSeconds = 9.0`, `duckFactor = bedDucked/bedRest`
  · "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1582-1607" — `duckBreath()`, the ramp-down/ramp-up loop off those four constants
  · called from `riteBowl(hz:)` — "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1353-1356" (`duckBreath()` at :1355)

Member A (voice) — NOT PORTED. The app's port of design `voice()` is `presence(_:dur:)`:
  · "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1155-1163" — resolves `VoiceCharacter` (the CHAR table port at Sound/VoiceCharacter.swift:24-59, carrying `atk`, `rel`, `gain`, partials, flicker/vib/air/shimmer/gliss/pan) and calls `playCeremony(...)`. **It touches the bed nowhere.** No `duckBreath()`, no `crossfadeLevel.write`, no 0.018.
  · `playCeremony` ("/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1373-1395") only attaches/connects/detaches the node — no bed handling for any synth, `.presence(c)` included.
  · All five `presence(...)` call sites are equally duck-free: RiteGatheringVie

**Comment** — NONE of the diagnostic shape — no comment on one member cites the other member's design line. The bowl's citations are all correctly its own: `duckBreath()`'s doc (SoundEngine.swift:1570-1571) says "`field-sound.js:168-169` — when the bowl is struck the bed falls to `0.006` at `t+1.2` and comes back to `0.030` at `t+9`", and 168-169 is genuinely bowl(). RiteTones.swift:42 quotes the bowl expression verbatim. (One trivial slip, same member, not the class: RiteTones.swift:44 cites "`field-sound.js:56`" for the 0.030 rest; the actual line is 59.)

What the comments DO record is the member's disap

**Evidence** — Not a swap and not a collapse: the bowl carries its own numbers, correctly, and the voice member has no port at all — so ONE-MISSING, in the group's own vocabulary.

The mechanism is what makes it worth the sweep. The two members share one idiom, and the app built exactly one implementation of it, `duckBreath()`. Because the surviving implementation is the bowl's, and because it is generically named ("the bed holds its breath"), the codebase reads as though the idiom is ported. Grepping for the mechanism finds it. Grepping for its constants finds 0.006/1.2/9.0 — all correct. Reading its comment finds a correct citation of `field-sound.js:168-169`. Every string checker passes. The only way to see the fault is to ask which SITES duck, and the answer is: the two that make a strike (`riteBowl`, `riteThreshold`) and not the one the design actually wrote the idiom for first.

Three concrete co

**Refutation** — Survives the attack. Both design members read exactly as quoted (comp :151-154 voice duck to 0.018 at t+c.atk, back to 0.030 at t+life+1.6; comp :188-189 bowl duck to 0.006 at t+1.2, back at t+9; bed rest 0.030 at field-sound.js:59). They are genuine siblings, not adjacent unrelated code: same three-line cancelScheduledValues+two-ramp idiom on the same this.bed.g.gain, in the same object, with the design's own comment naming the intent. The app ports Member B exactly and independently (BowlVoicing.bedRest/bedDucked/duckInSeconds/duckOutSeconds = 0.030/0.006/1.2/9.0, RiteTones.swift:45-49; duckBreath() SoundEngine.swift:1582-1607), so this is not TRANSPOSED and not BOTH-WRONG. Member A has no port at all: grep for duckBreath callers returns exactly two, riteBowl:1355 and riteThreshold:1047;

### ONE-MISSING — `fieldsound-main-bed-vs-light-bed` · rows `G1.1`, `G3.1`, `G3.3`

**Design** — Verified in the comp AND in its identical source `Claude Design Round 1/field-sound.js` (byte-identical to `comps/field-sound.js` and to `Claude Design Round 2/design-source/field-sound.js`), so both line bases are usable.

PAIR 1 — bed gain
· startBed → `g.gain.value=0.030` — comp `The Light - S-L01 Dawn.html:79` = `field-sound.js:59`
· lightBed → `g.gain.linearRampToValueAtTime(0.012,t+6)` — comp `:316` = `field-sound.js:296`

PAIR 2 — the second voice under the root
· startBed → `fg.gain.value=0.16` on a fifth at `rootHz*1.5` — comp `:83` = `field-sound.js:63`
· lightBed → `g2.gain.value=0.3` on `o2` at 792 Hz = 528×1.5, also a fifth — comp `:319` = `field-sound.js:299`

PAIR 3 — LFO depth (both LFOs run at 1/breathSecs and both add into `g.gain`)
· startBed → `lg.gain.value=0.014` — comp `:85` = `field-sound.js:65`
· lightBed → `lg.gain.value=0.006` — comp `:321` = `field-sound.js:301`

The design's own ratios: 0.014/0.030 = ±47% of bed; 0.006/0.012 = ±50% of bed. Neither bed is normalised — the design sums root + partial with no divisor.

**App** — PAIR 1 — bed gain — the pair is distinguished, but only one member is a live gain
· startBed 0.030 → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/RiteTones.swift:45` — `static let bedRest: Double = 0.030`. Right number, but it is never the bed's gain: its only consumer is `duckFactor` (`RiteTones.swift:49`, read at `SoundEngine.swift:1588`). The field bed's actual running gain is `VoiceSnapshot.level` (`Sound/SoundSnapshot.swift:57-60`, default 0.12, Airtable-driven).
· lightBed 0.012 → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1247` — `CeremonyVoice(hz: 528, peak: 0.012, attackSeconds: 6, releaseSeconds: 40, synth: .sineOctave)`. MATCHED, ramp length included.

PAIR 2 — one member ported with its constant, the other silently without. THIS IS THE FINDING.
· startBed 0.16 → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/BreathVoice.swift:121-122` — `let fifthFreq = snap.rootHz * 1.5` / `let fifthGain = 0.16`, cited to `field-sound.js:63`. Correct value, correct line, correct ratio. MATCHED.
· lightBed 0.3 → NO SITE CARRIES IT. `lightRoomTone` delegates to `synth: .sineOctave`, whose body is `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/RiteTones.swift:272-275` — `raw = (sin(phase) + sin(partialPhase) * 0.28) / 1.28`, with `part

**Comment** — Two, and the first is the exact signature of the class — a comment that is verbatim design-accurate sitting over code that is not.

1. `Sound/SoundEngine.swift:1239-1240`:
   "/// `lightBed` — *"the bare light: almost nothing. A single high room-tone, barely there,
    /// so the silence has an edge to it."* 528 with 792 at 0.3, rising to 0.012 over 6s."
   The doc string states BOTH of the design's missing values — 792 Hz and 0.3 — three lines above a call that renders 0.28 at 1056.5 Hz. Restated at `Screens/LightView.swift:113-115`: "528 + 792, six seconds to reach 0.012." Every string a che

**Evidence** — VERDICT REASONING. Not TRANSPOSED and not COLLAPSED-onto-each-other: no app site carries its sibling's number, and the two beds are still distinguishable (0.012 vs 0.030). The pattern is directional — on two of the three pairs the startBed member survives with a constant and the lightBed member was ported without one:

· Pair 1 (bed gain): effectively MATCHED. 0.012 is live and exact; 0.030 is exact but demoted to a ratio's denominator.
· Pair 2 (second voice): **ONE-MISSING**, and this drives the group verdict. 0.16 ported and correctly cited; 0.3 never appears, replaced by The Gathering's 0.28 at the wrong interval.
· Pair 3 (LFO depth): **BOTH-WRONG** on its own. 0.014 → an uncited ±12%; 0.006 → no LFO exists. The design deliberately separates these two (±47% vs ±50% of their beds, each at its own breath rate) and the app carries neither.

WHY IT SURVIVED — the same three-layer camouf

**Refutation** — SURVIVES, but only on Pair 2 — and two of the finding's three supporting pairs must be withdrawn.

DESIGN LINES — all six verified byte-exact at the quoted line numbers in `Claude Design Round 1/comps/The Light - S-L01 Dawn.html` (:79 `g.gain.value=0.030` · :83 `fg.gain.value=0.16` · :85 `lg.gain.value=0.014` · :316 `linearRampToValueAtTime(0.012,t+6)` · :318 `o2.frequency.value=792` · :319 `g2.gain.value=0.3` · :321 `lg.gain.value=0.006`) and at :59/:63/:65/:296/:298/:299/:301 in `field-sound.js`. All three field-sound.js copies (Round 1 root, Round 1 comps, Round 2 design-source) are md5-identical (a0d8b313af99016181c18c643eae135c) — the finding's path claim checks out.

APP SITES — all verified as quoted: `RiteTones.swift:45-46,49` (bedRest/bedDucked/duckFactor), `:216` `let partialInc 

### ONE-MISSING — `glsl-parting-hand-vs-back` · rows `C4.5`

**Design** — Both members live inside one function, `parting()`, in the design's GLSL string:

· MEMBER A — uHand, the parting he is holding open · `Claude Design Round 1/The Instrument v3.html:1992`
  `' if(uHand.z>.001)p=uHand.z*smoothstep(uHand.z*.34+.06,0.,length(q-uHand.xy));',`
  strength = bare `.z` (the absent-constant member) · radius slope `.34` · radius floor `.06`

· MEMBER B — uBack[i], a zone already handed back · `Claude Design Round 1/The Instrument v3.html:1994`
  `'  p=max(p,uBack[i].z*.86*smoothstep(uBack[i].z*.30+.05,0.,length(q-uBack[i].xy)));}',`
  strength = `.z*.86` · radius slope `.30` · radius floor `.05`, over a 9-slot loop opened at `:1993`

The `.z` each member reads is a different quantity, and that is why the pair is the whole rule. A's `.z` is `open*0.62` (design `:2967`, the live openness); B's `.z` is the persisted zone radius `0.06 + n*0.026` written by `handBack` (`Claude Design Round 2/design-source/world-three.js:110-115`) and uploaded through `uBack()` at `:135-140`. `.86` is the ONLY statement in the design of how much thinner a handed-back zone is than a live hand.

**App** — · MEMBER A — PORTED, AND IT CARRIES ITS OWN CONSTANTS.
  `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentField.metal:127`
  `if (hand.z > 0.001) p = hand.z * smoothstep(hand.z * 0.34 + 0.06, 0.0, length(q - hand.xy));`
  Bare `hand.z` strength, slope `0.34`, floor `0.06` — identical to design `:1992`, term for term, and NOT the sibling's `.86 / .30 / .05`. The feed is honest too: `PointVeil.uHand` (`Point/PointWorlds.swift:495-498`) returns `h.open * 0.62`, so `hand.z` carries the same quantity the design's `uHand.z` does.

· MEMBER B — NO PORT ANYWHERE IN THE REPO.
  The app's whole `parting()` is inlined into `mVeil` at `InstrumentField.metal:125-130`: `p` is declared at `:126`, written once at `:127` (the hand), and consumed at `:128` as `1.0 - min(1.0, p)`. There is no `uBack` array, no `for` loop, no `max(p, ...)` second term. The Metal entry point at `:186-188` declares `float3 uHand` and no back-zone buffer; `motif()` at `:165` forwards `hand` alone; `mVeil(q, t, hand)` at `:176` takes three arguments.
  `grep -rn "uBack" --include="*.swift" --include="*.metal"` over the app returns exactly one hit, and it is a comment: `Instrument/AxisModel.swift:154` ("the `uBack` normalisation C4.2 covers"). Swept the constants directly: every `0.86`, `0.30`, `0.05`

**Comment** — NONE. No comment on either app site cites the other member's design line, and no app file cites `The Instrument v3.html:1992` or `:1994` at all (grepped).

Two things worth recording anyway, because both are near-misses of this fault class and neither is one:

1. THE PORTED SITE CARRIES NO COMMENT AND NO CITATION. `InstrumentField.metal:125-130` is bare — `mVeil` is the only place the veil is drawn and it has no design reference of any kind. So the file itself holds no trace that half of `parting()` was dropped; a reader of the shader sees a complete-looking three-line function. `check_citatio

**Evidence** — FILES READ (all absolute):
· `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:1978-1996` — the III · THE VEIL header and `parting()` in full, both members in place.
· `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/world-three.js:66-140` — `back[]`, `handBack` (`:110-115`), `isBack`, `uHand()` (`:134`), `uBack()` (`:135-140`), which is what fills the 27-float array member B reads.
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentField.metal:117-130, 165-188, 202-212` — `veilDensity` ported line-for-line; `mVeil` ported minus the loop; entry-point signature; the constant sweep.
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:110, 445-500, 505-626` — `PointLawSignal.parted`, `PointVeil`, `WorldVeil`, `veilFloor`.
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:735-741` — th

**Refutation** — VERDICT SURVIVES. Every refutation angle failed.

(1) DESIGN LINES EXACT. `Claude Design Round 1/The Instrument v3.html:1992` and `:1994` read byte-for-byte as quoted, loop opened at `:1993`. (2) SIBLINGS ARE REAL, NOT NEIGHBOURS: consecutive lines in one function, the same `p = .z*smoothstep(.z*slope+floor,0.,length(q-.xy))` template twice, differing in exactly three places; `.86` exists only to relate B to A. (3) NO ALTERNATE SOURCE: `Round 2/design-source/The Instrument v3.html:1990-1994` and `spine-field.js:97-101` — the closer ancestor of the Metal file — carry BOTH members with identical constants. No source anywhere has the hand alone. (4) NOT A RECORDED DIVERGENCE, THE OPPOSITE: `Round 2/HANDOFF.md:53` lists as still-required "Three additions still required: `uBack[9]` in `mVeil`…"

### ONE-MISSING — `lite-caption-size` · rows `E1.17`, `E1.18`, `E1.3`, `E1.4`

**Design** — `#lite .vec` → `font-size:8px` (with `letter-spacing:.30em`) at /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4605 — content is `s.kind + ' · ' + s.vector` rendered at :5275 (e.g. "FUTURE · FORCE → SURRENDER"), sitting at the TOP of the reading with `margin-bottom:20px`.
`#lite .hold` → `font-size:8.5px` (with `letter-spacing:.26em`) at /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4617 — content is the literal `hold to mean it` rendered at :5282, `margin-top:24px`, shown only while `!LT.carved`.
Identical values in the Round 2 copy (Claude Design Round 2/design-source/The Instrument v3.html:4605, :4617), so there is no second design generation to adjudicate against.

**App** — `#lite .hold` → PORTED, wrong constant: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:431-432 — `Text(LightCanon.beatCue).spaceMonoTracked(9, em: 2 / 9)`. `spaceMonoTracked` is `self.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size)` (Theme/Theme.swift:151-153), so this is **9pt / 2pt tracking = 0.222em**, against the design's 8.5px / .26em. String source is LightCanon.beatCue at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Light/LightCanon.swift:108. Its `margin-top:24px` also arrives as `.padding(.top, 8)`.
`#lite .vec` → NO PORT. The caption does not exist in the app: `LightScene` (Light/LightCanon.swift:12-22) has no `kind`, `vector` or `arrival` field, and grep across the app for the six authored vector strings ("force → surrender", "fragmentation → one awareness", …) and for `"Future"`/`"Far"` returns 0 hits. The Light reading column (Screens/LightView.swift:342-446) opens directly on `scene.whole` — there is no element above it. Every mono caption in the Light register is accounted for and none is the vec: LightView.swift:123 ("‹ leave"), :197 (touchOnce), :285 ("hold"), :417 (walk back out), :432 (beatCue), :461 (breathCue), :695, :698.

**Comment** — NONE of the known cross-citation kind — but the citation is aimed one layer away from the number, which is why it verifies clean. The comment above the app's `.hold` site (Screens/LightView.swift:423-430) reads: "E1.4 · **THE AUTHORED CUE, AT LAST** — `The Instrument v3.html:5282` `if(!LT.carved) h += '<div class=\"hold\">hold to mean it</div>'`". `:5282` is genuinely `#lite .hold`'s own render line — correct element, correct member. It cites the JS that emits the div and never the CSS rule at `:4617` that sizes it, so `check_citations` confirms a true statement about the string while the 9 / 

**Evidence** — Not a transposition — there is nothing on the app side to transpose against. The pair fails asymmetrically, and both halves are hidden by a different mechanism:

1. **`.vec` never crossed** (NOT-PORTED half). The app's Light register was ported from the per-register comp `The Light v2.html`, which has no `.vec` and no `.hold` — its reading column (comps/The Light v2.html:820-856) goes straight from `scene.whole` to the anchors, and its only mono is the "walk back out" button at 9px/0.16em. `#lite`'s two mono captions exist ONLY in `The Instrument v3.html`. So the vec was never dropped from a port; it was never inside the source the port was made from. E1.15 caught the data's absence and stayed OPEN; nobody wrote the row for the caption.

2. **`.hold` crossed as a string, not as a rule.** E1.4 pulled `hold to mean it` from the Instrument (`:5282`) into a screen built from the Light comp, 

**Refutation** — Survives every attack. Design lines verbatim: :4605 `#lite .vec{...font-size:8px;letter-spacing:.30em;` and :4617 `#lite .hold{margin-top:24px;...font-size:8.5px;letter-spacing:.26em;`, render sites :5275 and :5282 as quoted, Round 2 identical at the same numbers. App site verbatim: LightView.swift:431-432 `Text(LightCanon.beatCue).spaceMonoTracked(9, em: 2 / 9)`, and Theme.swift:151-153 `tracking(em*size)` makes that 9pt/2.0pt = 0.222em — neither 8.5 nor .26em. Scale excuse refuted: `.phone{width:393px}` (Instrument:4315) is the iPhone logical width, and LightType.swift ports 21/16.5/18 through 1:1, so 8.5→9 is not a unit conversion. No recorded divergence: zero hits across Coverage/ and Tools/ for any row touching these constants. No alternate source: canon/spine-light.js:33-88 carries v

### ONE-MISSING — `pointsound-voice-peak-gains` · rows `D7.1`, `D7.2`, `D7.3`

**Design** — Design constants confirmed byte-identical in all three copies (`Claude Design Round 1/comps/point-sound.js`, `Claude Design Round 2/design-source/point-sound.js` — `diff` reports IDENTICAL — and inline in `Claude Design Round 1/comps/The Point v9.html`):

1. drone() the enclosure's bed → 0.055 · `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/point-sound.js:58` (`gn.gain.setTargetAtTime(0.055,t,1.4)`) · twin `The Point v9.html:590` · spine twin `Claude Design Round 2/design-source/spine-sound.js:97`
2. step(from,to) the interval between enclosures → 0.035 · `point-sound.js:80` · twin `The Point v9.html:612` · spine twin is `slide(a,b)` at `spine-sound.js:340` where the SAME envelope carries **0.032**, not 0.035
3. blip() the crossing → 0.07 · `point-sound.js:88` · `The Point v9.html:620` · `spine-sound.js:348`
4. glide() the descent/ascent → 0.06 · `point-sound.js:98` · `The Point v9.html:630`
5. shimmer() the five-tone rise → 0.03 · `point-sound.js:107` · `The Point v9.html:639` · `spine-sound.js:369`
6. om() the landing → 0.06/(i+1) · `point-sound.js:119` · `The Point v9.html:651` · `spine-sound.js:380`

Note the mix is genuinely six distinct numbers and the design keeps them distinct: 0.03 < 0.035 < 0.055 < 0.06 = 0.06 < 0.07.

**App** — All app sites in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift` unless noted. Each carries ITS OWN member's constant — no crossing found.

1. drone → `SoundEngine.swift:302` — `level: 0.055,` inside `snapshot(for:)`'s `.point(enclosure)` branch, consumed as `snap.level` by `BreathVoice` (`Sound/BreathVoice.swift`). Its octave partial is separately at `BreathVoice.swift:125` `let octaveGain = 0.06`, which is the design's own `o3g.gain = 0.06` (`point-sound.js:56`) — an inner partial of drone, not glide's peak wandered in. **MATCHED.**
2. step → **NO PORT ANYWHERE.** `world(i)`'s enclosure change is `setContext(.point(...))` → `crossfadeTo` (`SoundEngine.swift:284-313`), an equal-power LEVEL crossfade between two `BreathVoice`s. There is no oscillator swept `a*2 → b*2` over 2.6s and no gain event at all. `grep -rn '0\.035' --include='*.swift'` over the whole app returns five hits, all visual (`PointYantra.swift:238`, `PointReadings.swift:580`, `ReturnStrata.swift:196,277`, `PracticeDoorView.swift:144`) and none in `Sound/`. No `slide`/`step` sound function exists (`grep -rn 'slide' Sound/` → only `RiteTones.swift:155` gliss prose and `VoiceCharacter.swift:38`). **NOT-PORTED.**
3. blip → `SoundEngine.swift:1097-1101` `blipVoice(hz:)` → `peak: 0.07`. Single 

**Comment** — NO sibling-cross citation. Nothing here has the `#where`/`#pname` shape — no comment on member A quotes member B's design line to justify A's number.

Every ported member's comment cites its OWN twin, and each citation is exact:
· blip — `SoundEngine.swift:1096`: "`blip(f)` — `Claude Design Round 2/design-source/spine-sound.js:343-350`. One sine at `f*2`, 0.02s up, 0.7s and gone." → `spine-sound.js:343-350` IS `blip:function(f)`, 0.07 at `:348`. Correct element.
· glide — `SoundEngine.swift:745`: "`glide(i, down)` — `The Point v9.html:623-632`." → `The Point v9.html:623-632` IS `glide(i,down)`

**Evidence** — FIVE OF SIX MATCHED, ONE NOT PORTED. No transposition, no collapse, no both-wrong.

Verdict reasoning: I filed ONE-MISSING per the stated definition — "one member ported with its constant, the other silently without" — but the qualifier matters and I want it on the record: **the absence is NOT silent.** D7.4 is OPEN and names it precisely. So this group does not contain the fault this sweep hunts.

What the group DOES contain, and it is the mirror image of the `#where`/`#pname` instance:

**D7.5 (MAJOR) is OPEN over four voices that are built and correctly valued.** The known instance was a CLOSED row over a wrong constant; this is an OPEN row over four right ones. Same failure of the audit to track the tree, opposite sign. The same is true of D6.5's shimmer clause. A sweep that trusts row status would spend work rebuilding `blip`, `glide`, `shimmer` and `om` — all four of which already 

**Refutation** — SURVIVES ATTACK. Verdict unchanged.

DESIGN — all six lines read exactly as quoted at exactly the cited numbers in `Claude Design Round 1/comps/point-sound.js`: :58 `setTargetAtTime(0.055,t,1.4)`, :80 `linearRampToValueAtTime(0.035,t+0.6)`, :88 `0.07,t+0.02`, :98 `0.06,t+0.15`, :107 `0.03,st+0.1`, :119 `0.06/(i+1),t+0.9`. `diff` vs `Claude Design Round 2/design-source/point-sound.js` → identical. `The Point v9.html` 590/612/620/630/639/651 identical. No second design source with different numbers.

APP — each site exists and carries ITS OWN member's constant: `SoundEngine.swift:302` `level: 0.055`; `:753` `peak: 0.06` (glide); `:768` `peak: 0.03` (shimmer); `:1034` `peak: 0.06 / (Double(i) + 1)` (om); `:1098` `peak: 0.07` (blipVoice). Wiring confirmed: glide at `PointWorldView.swift:568,58

### ONE-MISSING — `rail-accent-alpha` · rows `C2.5`, `C2.6`, `C5.2`, `C5.6`

**Design** — Three lit states of `#rail`, all on rgb(229,83,60), within seven lines of one CSS block:

1. `#rail i.on` → `width:17px; background:rgba(229,83,60,.85)` — `Claude Design Round 1/The Instrument v3.html:4340`. The current register's needle.
2. `#rail u.open` → `background:rgba(229,83,60,.55); border-color:transparent` — `.../The Instrument v3.html:4345`. A surface that has been crossed with meaning (`TR.mem[s]`, applied at `:4975`).
3. `#rail i.kept` → `box-shadow:0 0 7px rgba(229,83,60,.75)` — `.../The Instrument v3.html:4346`. A register at which something was TAKEN UP. It is a fourth class on the tick, ORTHOGONAL to on/near — `:4974` composes them: `el.className=(i===cur?'on':(Math.abs(i-cur)===1?'near':''))+(KEPT[i]?' kept':'')`. `KEPT` is declared at `:4899` and written at `:5339` inside `sealCarry()`, one line after `CARRY.push(...)`.

Note the shape of the set: two of the three are BACKGROUNDS on two different tag names (`i` and `u`), and the third is a BOX-SHADOW that shares a tag name with the first. A diff scan that pairs by tag finds two members and stops.

**App** — The port is `ladderRail`, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:579-626` (a `Canvas`, so all three would be draw calls, not modifiers). `let red = Color(hex: "#E5533C")` at `:591`.

1. `#rail i.on` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:601`
   `let col: Color = reg.i == curI ? red.opacity(0.85) : bone.opacity(d == 1 ? 0.42 : 0.16)`
   Carries **its own** .85. MATCHED. (`.42` / `.16` on the same line are `#rail i.near` `:4341` and `#rail i` `:4339`, also each on its own element.)

2. `#rail u.open` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:613`
   `ctx.fill(Path(ellipseIn: rect), with: .color(red.opacity(0.55)))`
   Carries **its own** .55, and is gated on the right predicate: `travel.openedSurfaces` (`:589`), which is `AxisTravel.mem` verbatim (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisTravel.swift:142` — `var openedSurfaces: [Bool] { mem }`). MATCHED.

3. `#rail i.kept` → **NO PORT, at either layer.**
   · No draw: `ladderRail` (`:579-626`) issues exactly two fills and one stroke; `grep` for `box-shadow|shadow(|glow` across `InstrumentView.swift` returns nothing inside the rail (the only `.shadow(` is `:863`, the particle halo). The t

**Comment** — YES — but it is the NAME-level form of the fault, not the citation-level form, and it is worse for `check_citations` than the `#where`/`#pname` instance was: there, the comment cited a real (wrong) line and the checker verified it. Here **no app comment cites `:4340`, `:4345` or `:4346` at all** (`grep ':4340|:4345|:4346'` over the app source → 0 hits), so `check_citations` has nothing to check and reports nothing. What the comments do instead is spend the design's word for the third member on the second member's site:

· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentVie

**Evidence** — Design, `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html`:
```
4339 #rail i{width:9px;height:1px;background:rgba(237,232,227,.16);…}
4340 #rail i.on{width:17px;background:rgba(229,83,60,.85)}
4341 #rail i.near{width:13px;background:rgba(237,232,227,.42)}
4345 #rail u.open{background:rgba(229,83,60,.55);border-color:transparent}
4346 #rail i.kept{box-shadow:0 0 7px rgba(229,83,60,.75)}
4974     el.className=(i===cur?'on':(Math.abs(i-cur)===1?'near':''))+(KEPT[i]?' kept':'');}
4975   for(let s=0;s<14;s++){const el=rail.children[s*2+1];if(el)el.className=TR.mem[s]?'open':'';}
5338   CARRY.push({title:…,hue:…});
5339   KEPT[reg.i]=true;
```

App, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift`:
```
574     // The right-edge rail (v3 #rail, verbatim): 15 register ticks + 14 surface-dots between
578     // surface is a hollow bone point un

**Refutation** — SURVIVES. Every load-bearing claim verified independently; I could not refute it.

DESIGN (all exact, at the exact cited lines — confirmed by grep -n, not by eye):
:4339 `#rail i{...background:rgba(237,232,227,.16);...}`
:4340 `#rail i.on{width:17px;background:rgba(229,83,60,.85)}`
:4341 `#rail i.near{width:13px;background:rgba(237,232,227,.42)}`
:4345 `#rail u.open{background:rgba(229,83,60,.55);border-color:transparent}`
:4346 `#rail i.kept{box-shadow:0 0 7px rgba(229,83,60,.75)}`
:4974/:4975 read verbatim as quoted; :4899 `const CARRY=[], KEPT={}, PARK={}, PEND={};`; :5339 `KEPT[reg.i]=true;`.

SIBLING GROUPING IS SOUND (the false-TRANSPOSED trap does not apply). `i.kept` is not a near-neighbour that merely shares a block: :4974 composes it as a FOURTH class onto the same `i` element as

### ONE-MISSING — `rail-i-vs-u-transition` · rows `C2.6`

**Design** — #rail i (the register tick) → `transition:width .5s ease,background .5s ease,opacity .5s ease` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4339
#rail u (the surface dot between registers) → `transition:background .8s ease,border-color .8s ease` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4343-4344 (declaration wraps; the transition is on :4344)
The design gives the surface the slower settle (.8s) and the register the quicker one (.5s).

**App** — Both members are drawn by ONE view — `ladderRail`, a single `Canvas`, at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:579-627. Ticks are filled in the loop at :597-603, surface-dots at :605-617.

· #rail i → PORTED, with its own constant: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:626` — `.animation(.easeInOut(duration: 0.5), value: here.i)`. 0.5 is the design's .5s, and the key `here.i` (register index) is exactly what changes a tick's width (9/13/17) and colour, i.e. the `width`/`background` half of :4339.

· #rail u → NO PORT OF ITS CONSTANT. `0.8` does not occur anywhere in the rail, and the only `duration: 0.8` in the whole Instrument folder is the rope fade at InstrumentView.swift:315 and :324 (`withAnimation(.easeInOut(duration: 0.8)) { showRope = ... }`), which is a different element. The dot's `background`/`border-color` change is the `opened[s]` branch at :612-616, driven by `travel.openedSurfaces` (AxisTravel.swift:142, set at AxisTravel.swift:524 `mem[s] = true` and :475). Nothing animates on that value.

The shape is worth stating exactly, because it reads two ways:
 · At the CONSTANT level it is ONE-MISSING — 0.5 is present and named for the tick; 0.8 was never carried across for the dot.
 · At t

**Comment** — NONE — and the absence is itself the tell.

No comment on either member cites the other's design line. The comments in `ladderRail` are all correctly aimed: :592-596 discusses `#rail i`'s explicit `width` (:4339's element, correct); :609 quotes `align-self:flex-end; margin-right:3px`, which is `#rail u`'s own declaration at :4343 (correct element); :621-624 cites `:5644` for the rail's opacity, which is `rail.style.opacity=(1-hush*0.85)*(1-immA)*(1-PS.dom()*0.9)` (correct line, correct element).

What makes this instance invisible is the opposite of the known one: `InstrumentView.swift:626` — 

**Evidence** — DESIGN — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html
4339: #rail i{width:9px;height:1px;background:rgba(237,232,227,.16);transition:width .5s ease,background .5s ease,opacity .5s ease}
4342: /* between every two registers, the surface. Hollow until he has meant it. */
4343: #rail u{width:3px;height:3px;border-radius:3px;align-self:flex-end;margin-right:3px;
4344:   border:.5px solid rgba(237,232,227,.20);transition:background .8s ease,border-color .8s ease}
4345: #rail u.open{background:rgba(229,83,60,.55);border-color:transparent}

APP — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift
579: private var ladderRail: some View {
580:     Canvas { ctx, size in
604:         // surface-dots (14) at the midpoints, aligned to the edge; hollow until opened
612:             if s < opened.count && opened[s] {
613:                 ctx.fill(Pat

**Refutation** — Attacked on five fronts; all refutations failed. DESIGN verbatim: :4339 `#rail i{...transition:width .5s ease,background .5s ease,opacity .5s ease}` and :4343-4344 `#rail u{...transition:background .8s ease,border-color .8s ease}` (transition on :4344, as stated). The strongest possible refutation — that the design's .8s is a dead rule — fails: :4968-4970 builds the <i>/<u> children ONCE and paintRail() at :4973-4975 only toggles className on those persistent elements (`el.className=TR.mem[s]?'open':''`), so both transitions genuinely fire. SIBLINGS genuine, not mere adjacency: they are the interleaved children of one #rail, emitted by one builder loop and repainted by one function; no false-TRANSPOSED risk (the finding is not TRANSPOSED and there is no second constant to swap). APP confir

### ONE-MISSING — `travel-damp-by-mode` · rows `C2.1`, `C2.2`, `C2.9`

**Design** — DAMP column, the non-monotone one, per member:
· TRAVEL module default `var T={…}` → DAMP 0.945 (also DRAG 0.00015, WHEEL 0.00007, PINCH 0.0022, span 0.36, no DUR) — `Claude Design Round 1/The Instrument v3.html:3429`
· TWK_DIST.continuous → DAMP 0.955 (DRAG 0.00052, WHEEL 0.00022, PINCH 0.0060, span 0.24, DUR 1.2) — `:4920`
· TWK_DIST.near → DAMP 0.955 (DRAG 0.00035, WHEEL 0.00016, PINCH 0.0035, span 0.26, DUR 1.5) — `:4921`
· TWK_DIST.long → DAMP 0.950 (DRAG 0.00024, WHEEL 0.00011, PINCH 0.0026, span 0.34, DUR 2.9) — `:4922`
· TWK_DIST.immense → DAMP 0.956 (DRAG 0.00018, WHEEL 0.00008, PINCH 0.0020, span 0.42, DUR 5.4) — `:4923`

Reachability, which decides what a port even owes: `applyMode` (`:4935-4941`) selects `TWK_DIST[long?'immense':'continuous']` and boots at `:5973-5974` from `localStorage 'instrument.mode'`. So only TWO of the five are ever live — `immense` (LONG, the default) and `continuous` (SHORT, reachable by the mode pill at `:5966-5972` and sticky across visits). `near` and `long` are dead rows in the design itself: nothing selects them. The module default at `:3429` is live for exactly zero frames — `Object.assign(TR,d)` overwrites it at boot. `Claude Design Round 1/README.md:43-49` states the same two columns as LONG/SHORT and is a clean second witness.

**App** — One of the five is ported; the other four have no app site at all.

· TWK_DIST.immense → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisTravel.swift:198`
  `private let DRAG = 0.00018, DAMP = 0.956, K = 30.0, RES = 0.58, span = 0.42`
  plus `:178` `glideDur = 5.4` and `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisPassage.swift:20-22` `earnedDuration = 5.4`. DRAG · DAMP · span · DUR all carry immense's own constants. K/RES are TWK_SURF.held (`:4925`), correct. WHEEL 0.00008 / PINCH 0.0020 are named in the comment but deliberately not declared — no wheel and no pinch-to-travel input path exists (C2.7).
· TRAVEL module default (`:3429`) → correctly ABSENT. 0.945 does not appear anywhere in the app's travel path.
· TWK_DIST.continuous (`:4920`) → NOT PORTED. There is no SHORT mode in the app: grep across the whole Swift tree for `TWK_DIST`, `MODE`, `applyMode`, `instrument.mode`, `SHORT`/`LONG` toggle, `0.00052`, `0.955` (in a travel context), `0.24`, `1.2` returns nothing. `AxisModel.swift:518` states it plainly — *"The app has no tweak panel."*
· TWK_DIST.near (`:4921`) → NOT PORTED (dead in the design too).
· TWK_DIST.long (`:4922`) → NOT PORTED (dead in the design too).

NO TRANSPOSITION SURVIVES. Every constant on the one live app site belongs to

**Comment** — No comment on an app site cites a sibling member's design line to justify its own number. The nearest thing is the opposite — a deliberate inoculation. `AxisTravel.swift:187-189`:

  "The trap: the default LONG experience uses the preset named `immense`, NOT the
   one named `long`. Reading the `long` row gives a plausible-looking wrong answer
   (DRAG .00024 · DAMP .950 · span .34 · DUR 2.9)."

It quotes the sibling in order to refuse it. Verified against `:4922` — the quoted numbers are `long`'s, exactly.

TWO REAL CITATION FAULTS FOUND, both of the "correct-looking reference to the wrong li

**Evidence** — Design sites read directly:
· `Claude Design Round 1/The Instrument v3.html:3426-3431` (module `var T={…}`, DAMP 0.945 at `:3429` — confirmed by grep: 0.945 occurs exactly once in the whole file, here)
· `:4918-4924` TWK_DIST · `:4925` TWK_SURF · `:4926-4927` TWK_IN/IMMCAP
· `:4934-4941` applyMode · `:5966-5972` the mode pill · `:5973-5974` the boot call · `:5985` the back-handler brace the app comment mis-cites
· `:4808-4818` TWEAK_DEFAULTS / storedMode — proves SHORT is persisted and re-entered on next launch
· `Claude Design Round 1/README.md:43-49` — the LONG/SHORT table, an independent witness that immense=LONG and continuous=SHORT
· `Claude Design Round 2/comps/The Chrome.html:160-170` — DIST + `BUILT={…DAMP:0.945…DUR:2.9}`, the recorded prior app state; `:120-121` its own port ledger

App sites read directly (all under `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed`):
· `Instrume

**Refutation** — SURVIVES ATTACK. Every load-bearing claim verified by direct read.

DESIGN — exact. `:3429` `DRAG:0.00015, WHEEL:0.00007, PINCH:0.0022, DAMP:0.945,` (span 0.36 at `:3431`, no DUR); `:4920` continuous; `:4921` near; `:4922` long; `:4923` immense — all verbatim. `0.945` occurs exactly ONCE in the whole file, at `:3429`.

REACHABILITY — holds. `applyMode` (`:4935-4941`) does `const d=TWK_DIST[long?'immense':'continuous']; Object.assign(TR,d); PS.DUR=d.DUR; PS.enabled=long;`. Boot is `:5973-5974` off `localStorage 'instrument.mode'`; the pill is `:5966-5972`; `storedMode()`/`TWEAK_DEFAULTS` at `:4806-4815` persist it. `near` and `long` are selected by nothing. `README.md:43-49` is a clean second witness (LONG col = 0.00018/0.00008/0.0020/0.956/0.42/5.4 = immense; SHORT col = continuous).

APP 

### UNCLEAR — `lite-text-sizes` · rows `D5.8`, `E1.17`, `E1.3`, `E1.4`
*The refutation corrected this from the checker's first verdict.*

**Design** — Design source of record for this group is `The Instrument v3.html` (tier 2 — see rows below). The `#lite` block states all four sizes explicitly; none is compressed out:

· `#lite .whole`  → `font-size:23px`   — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4607
· `#lite .anc`    → `font-size:16.5px` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4609
· `#lite .beat b` → `font-size:19px`   — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4613
· `#lite .land`   → `font-size:15px`   — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4616

The ladder: 23 > 19 > 16.5 > 15. Four distinct steps, the beat (19) sitting between the whole (23) and the anchors (16.5). `liteRender()` at :5271-5289 emits `.whole` / `.anc` / `.beat` / `.land` and re-emits `.whole` at the SAME 23px on every pass — the Instrument has no travel and no settled variant.

The rival source the app actually used, `Claude Design Round 1/comps/The Light v2.html` (a Round-1 per-register comp): whole 21→15 (:826), anchors 16.5 (:835), beat 21 (:842), landing 18 (:853). `canon/spine-light.js` contains zero `fontSize` — tier 1 does not speak on this group, so tier 2 governs.

**App** — All four ports live in /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightType.swift, consumed in Screens/LightView.swift:

· whole  → `static func wholeSize(alone: Bool) -> CGFloat { alone ? 21 : 15 }` — LightType.swift:19; applied LightView.swift:350 (`.loraSize(LightType.wholeSize(alone: wholeIsAlone))`)
· anc    → `static let anchorSize: CGFloat = 16.5` — LightType.swift:30; applied LightView.swift:361
· beat b → `static let beatSize: CGFloat = 21` — LightType.swift:37; applied LightView.swift:375 and :383
· land   → `static let landingSize: CGFloat = 18` — LightType.swift:43; applied LightView.swift:397

Member-by-member against the design group:
· `.anc` 16.5 → 16.5. The ONLY member that agrees, and only because both sources happen to state 16.5. It carries no information about whether the port was made from the right file.
· `.whole` 23 → 21 (alone) / 15 (settled). 23 appears nowhere. The settled endpoint 15 IS `#lite .land`'s constant, now sitting on the whole.
· `.beat b` 19 → 21. 19 appears nowhere in the app's Light type.
· `.land` 15 → 18. 15 appears nowhere as the landing.

Three of four carry a plausible number that is not the design's — BOTH-WRONG — and a COLLAPSED variant rides on top of it: the app sets `beatSize == wholeSize(alone: true)` (21 == 21) whe

**Comment** — NONE of the classic form — no comment on one member cites a SIBLING member's design line. Inside `The Light v2.html`'s numbering every citation is to its own member: LightType.swift:18 `/// \`:827\` — living-and-alone, then settled.` (the whole, correct), :28 `/// \`:835\` — 16.5/1.7.` (the anchors, correct), :35 `/// \`:841\` — the same 21 the whole ARRIVED at.` (the beat, correct), :42 `/// \`:853\` — 18/1.6, italic, settled.` (the landing, correct).

The fault is the file-level analogue, and it is why every string checker passes. LightType.swift:3 declares the source outright: `/// E1.17 · 

**Evidence** — **The ladder makes this unambiguous.** /Users/ashrey/Bindu Feed/Claude Design Round 2/HANDOFF.md:64-76 sets one precedence ladder: 1 `canon/` (literal text and numbers) · 2 the SEVEN Round-2 comps · 3 `The Instrument v3.html` · 4 `comps/*.js` and per-register material. The Light is NOT among the seven Round-2 comps (Aperture, Chrome, Reading, Return, Rooms v4, Seam, Sound — `Claude Design Round 2/comps/`), so tier 2 is empty here. `canon/spine-light.js` has zero `fontSize` matches, so tier 1 is silent. `The Instrument v3.html` governs.

The project's own CLAUDE.md names this exact file pair, at /Users/ashrey/Bindu Feed/Bindu Feed/CLAUDE.md:687: "`canon/spine-light.js` is tier 1 and `The Instrument v3.html` tier 2, while **`The Light v2.html` is a per-register comp at tier 3 and explicitly subordinate**". And Round 1's own comps folder says the same at `Claude Design Round 1/comps/_ABOUT.

**Refutation** — The design lines and app sites all read exactly as quoted, but the BOTH-WRONG verdict does not survive. (1) NO MIS-PAIRING EXISTS. The app's 21/16.5/21/18 are a member-for-member port of one coherent block — The Light v2.html:826, 835, 842, 853 (verified: whole `phase==='whole'?21:15`, anc 16.5, beat 21, land 18) — with whole to whole, anc to anc, beat to beat, land to land. Nothing is permuted; the finding's own commentFault concedes "NONE of the classic form." The "COLLAPSED variant riding on top" is false as a pairing claim: the comp genuinely states 21 at BOTH :826 and :842, so `beatSize == wholeSize(alone:true)` (LightTypeTests.swift:55) is faithful to the source, not two design members merged. (2) THE GROUP'S OWN FAILURE MODE DID NOT OCCUR. whySiblings names the beat rising back abov


## Unowned — no audit row covers these constants

72 groups — 32 ONE-MISSING · 22 COLLAPSED · 13 BOTH-WRONG · 5 UNCLEAR

### BOTH-WRONG — `canon-light-far-vs-future-presence` · rows `E1.1`

**Design** — All four members live in one loop body, `L.draw()`, `/Users/ashrey/Bindu Feed/canon/spine-light.js:186-204` (extracted verbatim from `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4074-4091` — canon/README.md gives the range 3895–4141, and the twin lines are :4081/:4082/:4083/:4085).

· Far scene (floor) — alpha → `0.40`, `canon/spine-light.js:193` (`var al=a*(sel?0.95:(far?0.40:0.62))*(1-imm*0.85);`)
· five Future scenes — alpha → `0.62`, same line, same ternary
· Far scene (floor) — radius → `2.0`, `canon/spine-light.js:194` (`var rr=far?2.0:2.6;`) — the SOLID core dot, drawn at `:198-199` as `arc(h.x,h.y, rr + br*0.5)` filled at full `al`
· five Future scenes — radius → `2.6`, same line

Third instance of the same pair, named in whySiblings: halo radius `far?16:22` at `:195` and again at `:197`. Fourth and fifth, in the same expression: the colour `far?pc:c` at `:196,:197,:199` (Far = pool `#FBF9F4`, Future = hex `#EDE3CE`, `:100`), and the Far-only seam at `:200-203` — *"the Far one is a seam, not a star — stone, below"* — a horizontal stroke ±`W*0.13` at `al*0.30`.

The design's whole shape for Far: dimmer, smaller, a different (paler, stone) colour, and a seam instead of a star. `far` is `(h.k==='floor')` at `:191`; the two kinds are declared `kind:'

**App** — One render site for all six presences, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:229-260` (`choosingBody`). `far` is `sc.material == .nave` at `:231`. No other site draws the six — `LightCanon.scenes` is read only at `:84` (the chosen scene) and `:229`.

· Far alpha AND Future alpha → `Screens/LightView.swift:245` — `Color(hex: "#F5F0E8").opacity((far ? 0.55 : 0.85) * br * (armed == i ? 1.25 : 1))`. The pair is `0.55 / 0.85`. Neither is `0.40`, neither is `0.62`.
· Far radius AND Future radius (the design's `rr`, the solid core dot) → **no port.** The app draws only a radial gradient; there is no second, solid `arc` at `rr + br*0.5`, so `2.0` and `2.6` have no app expression anywhere. `grep -rn "2\.6\|2\.0" ` over the Light files returns nothing in this role.
· What the app ports instead is the design's THIRD instance, the halo `far?16:22` — `Screens/LightView.swift:247` `endRadius: far ? 17 : 13` and `:248` `.frame(width: far ? 34 : 26, height: far ? 34 : 26)`. Pair is `17 / 13` (and `34 / 26`, exactly 2×).

Two more slots in the same expression:
· colour → `:245-246` `#F5F0E8` inner and `#EDE3CE` outer, for BOTH kinds. The design's `far?pc:c` is COLLAPSED; `#F5F0E8` is neither `#FBF9F4` nor `#EDE3CE`.
· the Far seam → absent. `grep -n seam` over `L

**Comment** — YES — twice, and it is the same shape as the `#where`/`#pname` tell, one level up: a correct citation of the design file pointed at the wrong REGION of it.

`Light/LightCanon.swift:252-256`, immediately above `enum LightPlaces`:
> "The GEOMETRY is canon — `place()` and `hit()`'s radius 30 and `ORDER` are verbatim. The LOOK is not: no comp renders these. `The Light v2.html` goes straight to `SCENES[which]`, so the six-in-the-dawn exists only as this mechanism. Drawn here in the register's own idiom — a breathing point in the Light's cream with its title beneath — and said plainly rather than im

**Evidence** — **BOTH-WRONG, and the fault is larger than the pair: the app's comment declares the design's draw block not to exist.**

Every slot that IS ported carries a plausible number that is not the design's — `0.55 / 0.85` where the design has `0.40 / 0.62`; `17 / 13` where the design's same-role pair is `16 / 22`. And two of the four named members (`rr = far?2.0:2.6`, the solid core dot at `:198-199`) have no port at all, because the app draws a gradient and no core dot.

Four things make this the group's fault class rather than four loose deltas:

1. **The radius relation is INVERTED — the exact prediction in whySiblings.** Design: Far `16`, Future `22` — the floor smaller. App: Far `17`, Future `13` (frames `34` / `26`) — the floor the BIGGEST of the six. Read alone this looks deliberate (the floor is nearer, so it is larger), which is why it survived. The design says the opposite in words at

**Refutation** — Attacked on nine paths; all closed against refutation.

VERBATIM CHECKS PASS. `canon/spine-light.js` reads exactly as quoted: `:191` `var far=(h.k==='floor');`, `:193` `var al=a*(sel?0.95:(far?0.40:0.62))*(1-imm*0.85);`, `:194` `var rr=far?2.0:2.6;`, `:195`/`:197` `far?16:22`, `:196,197,199` `far?pc:c`, `:200-203` the Far seam. App `Screens/LightView.swift:231` `let far = sc.material == .nave`, `:245` `(far ? 0.55 : 0.85) * br * (armed == i ? 1.25 : 1)`, `:247` `endRadius: far ? 17 : 13`, `:248` frame `34`/`26`. All as quoted.

REFUTATIONS ATTEMPTED AND FAILED:
1. Extraction-only artifact? No — `Claude Design Round 1/The Instrument v3.html:4081-4088` carries the same lines; `canon/README.md:9` gives 3895-4141.
2. Dead code in the comp? No — `LT.draw(fx,W,H,t,br,p,immA)` is called at `The I

### BOTH-WRONG — `canon-travel-attack-ramps` · rows `C7.3`, `C7.8`

**Design** — Attack ramp time (the `t + X` in `linearRampToValueAtTime`), plus the peak constant on the same line, all in `/Users/ashrey/Bindu Feed/canon/spine-sound.js`:

· B.trail  → attack **0.5s**, peak `0.026/(i+1.6)`   — `canon/spine-sound.js:63`  · release `t+7.5` `:64`
· B.carry  → attack **0.25s**, peak `0.034/(i*0.6+1)` — `canon/spine-sound.js:104` · release `st+6.5` `:105`
· B.gate   → attack **0.05s**, peak **0.048**         — `canon/spine-sound.js:135` · release `t+1.6` `:136`
· B.ungrip → attack **0.45s**, peak **0.024**         — `canon/spine-sound.js:165` · release `t+3.4` `:166`

(Verified against the original too: `Claude Design Round 1/The Instrument v3.html:4229-4239` is `B.carry` verbatim.)

**App** — All four ported, single implementation each (no stale duplicates — `grep "func .*(Trail|Gate|Ungrip)"` returns exactly these). `attackSeconds` in `AxisVoice.init` is the literal attack ramp — `AxisTones.swift:41` `let attackSamples = max(1, Int(attackSeconds * sampleRate))`, envelope `sin(i/attackSamples · π/2)` — so it is directly comparable.

· trail  → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1504-1507`
  `AxisVoice(... peak: 0.026, attackSeconds: 0.4, releaseSeconds: 7.5, mode: .twin)`
  attack **0.4 vs 0.5** ✗ · peak 0.026 ✓ · release 7.5 ✓

· carry  → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1126-1146`
  `CeremonyVoice(hz: hz*m, peak: peak, attackSeconds: 0.25, releaseSeconds: 6.5, synth: .sine)`
  with `CarryVoicing.peak(step:) = 0.034/(Double(i)*0.6 + 1)` at `Instrument/AxisModel.swift:478`, `delay = i*0.30` at `:479`
  attack **0.25 ✓** · peak ✓ · release ✓ · stagger ✓ — the only fully MATCHED member

· gate   → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1549-1552`
  `AxisVoice(hzStart: hz*3, hzEnd: hz*1.5, glideSeconds: 0.9, peak: 0.03, attackSeconds: 0.1, releaseSeconds: 1.6, mode: .tone)`
  attack **0.1 vs 0.05** ✗ · peak **0.03 vs 0.048** ✗ (37% quiet) · release 1.6 ✓ · glide 0

**Comment** — No comment cites a *sibling's* line — the app comments are subtler than the `#where`/`#pname` case, and worse-behaved. Three distinct tells:

**1. A correct citation of the WRONG LINE of the RIGHT element.** `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisTravel.swift:555-570`, the C7.3 doc block, cites `canon/spine-sound.js:170-176` — the `B.axis` wrapper — and quotes it correctly. It never cites `:63`, `B.trail`'s own attack line. It then verifies the two numbers the app got right and no others:

> "The tone falls away as it goes (`setTargetAtTime(hz·0.985)`) over 7.5s"
> "a t

**Evidence** — **The group's own prediction is confirmed, and it is the release tails that prove it.** The second same-kind group named in `whySiblings` — `t+7.5`, `st+6.5`, `t+1.6`, `t+3.4` — is **4 of 4 MATCHED** in the app. The attack group over the same four voices is **1 of 4**. The long, distinctive numbers all survived the port; the small ones were re-invented. That is the fault class stated as a measurement.

**A second variant sits inside this one: COLLAPSED, on the adjacent peak property.** Design distinguishes gate `0.048` from ungrip `0.024` — a factor of two, the loudest and the quietest one-shots in the register. The app gives **both `0.03`**. And a third voice was there too: `Coverage/1-AUDIT-254.md:243` (C7.5, GIVE) records "The app played it at 0.03 — 45% quiet" against a design `0.055`. Three of the axis one-shots independently landed on `0.03`. It is a house default, not a value — th

**Refutation** — ATTACKED ON EVERY AVAILABLE ANGLE; IT SURVIVES.

DESIGN VERIFIED EXACT. /Users/ashrey/Bindu Feed/canon/spine-sound.js reads verbatim as quoted at all eight cited lines — :63 `linearRampToValueAtTime(0.026/(i+1.6),t+0.5)`, :64 `t+7.5`, :104 `0.034/(i*0.6+1),st+0.25`, :105 `st+6.5`, :135 `0.048,t+0.05`, :136 `t+1.6`, :165 `0.024,t+0.45`, :166 `t+3.4`.

APP VERIFIED EXACT. SoundEngine.swift:1504-1506 trail `peak: 0.026, attackSeconds: 0.4, releaseSeconds: 7.5, mode: .twin`; :1126-1141 carry via CeremonyVoice `attackSeconds: 0.25, releaseSeconds: 6.5, synth: .sine` with CarryVoicing.peak at AxisModel.swift:478 and delay :479 (both exactly as cited); :1549-1551 gate `peak: 0.03, attackSeconds: 0.1`; :1561-1563 ungrip `peak: 0.03, attackSeconds: 0.3`. Single implementation each — `grep 'func axi

### BOTH-WRONG — `immersion-body-size` · rows `B5.1`, `B5.4`, `B5.5`, `C3.8`, `C5.8`, `E1.17`
*The refutation corrected this from the checker's first verdict.*

**Design** — Three sibling body texts in `The Instrument v3.html`, all sharing the `text-shadow:0 1px 14px rgba(3,2,6,.86)` family:
· `.imm .bd` → `font-size:16.5px!important; line-height:1.86!important` — `:4583`. This is a STATE value, not a base one: the base `.bd` is 14.5/1.76 at `:4450`, `:4477`, `:4500`, `:4523`, `:4549`, and `:5506` (`READS.forEach(el=>el.classList.toggle('imm',IMM.on&&el===IMM.el))`) swaps 14.5 → 16.5 on the one reading he is inside.
· `#word p` → `font-size:18px; line-height:1.78; color:rgba(240,236,231,.92)` — `:4596`, raised by `openWord` at `:5685-5694`.
· `#lite .anc` → `font-size:16.5px; line-height:1.86` — `:4609`.
So the design's pairing is 16.5 · 18 · 16.5, with the fall the odd one out.

**App** — · `.imm .bd` — **NO PORT.** Nearest surface is `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:217` — `.font(section.quoted ? .loraItalic(15.5) : .lora(15.5))`, a single fixed 15.5 for both the outside and the inside state. 15.5 is not from this group at all: it is `The Point v9.html:1082` `.s-body{font-size:15.5px;line-height:1.78}`. No typographic consumer of immersion exists anywhere — `grep -rn "immA\|immersed"` over the app returns model code, the field opacity (`InstrumentView.swift:155`), the rail (`:625`), `#where` (`:568`), `#pname` (`:682`), the blur (`:760`) and the particle (`:844,851`), and not one font size.
· `#word p` — ported at **15**, not 18: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:574` — `Text(word).font(.lora(15)).lineSpacing(15 * 0.74)` at opacity 0.88, with the silent face at `:579` `.loraItalic(13.5)` at 0.40. Every number is the OTHER round's: `Claude Design Round 1/comps/The Universe v3.html:1412` `.word p{font-size:15px;line-height:1.74;color:rgba(237,232,227,.88)}` and `:1413` `.quiet{13.5px/1.7/.40}`, down to the gradient ground and `padding:26px 30px 104px`.
· `#lite .anc` — ported WITH ITS OWN CONSTANT: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightType.swift:30` — `static 

**Comment** — NONE — and the stronger fact is that there is nothing for `check_citations` to check. `grep -rn "4583\|4596\|4609"` over the app's Swift, over `Coverage/`, and over `AUDIT.md` returns **zero hits**: not one of the three design sites is cited anywhere in the build. The two comments that do sit over these ports each cite their own element in the other design round, correctly:
· `Screens/LightType.swift:28` — "`` `:835` `` — 16.5/1.7. Between the settled whole and the Declaration" — `:835` in `The Light v2.html` IS the anchors' own `<p style={{fontSize:16.5,lineHeight:1.7,…}}>`. Right element.
· 

**Evidence** — **Why ONE-MISSING and not TRANSPOSED/COLLAPSED:** the group cannot be transposed, because only one of the three members has an app constant at all. `#lite .anc` carries its own 16.5; `#word p` carries a third number (15) belonging to the same element in a different design round; `.imm .bd` has no port and no owner.

**The `.imm .bd` absence is a COLLAPSE one level down, and worth its own row.** The design distinguishes two states of one element — `.bd` 14.5/1.76 outside, `.imm .bd` 16.5/1.86 inside — and `PointReadings.swift:217` answers both with a single fixed 15.5. That is the exact shape E1.17 named for the Light's whole ("the app held a fixed 19 — between the two, so it was never either, and the settling never happened"): a number sitting between the two endpoints so the transition it exists to make never renders. Entering a piece is the one moment the app has no other way to mark t

**Refutation** — The finding's facts verify; its VERDICT does not, because the reasoning that clears `#word p` is refuted by a file in the design corpus.

WHAT SURVIVES (all re-read):
· `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4583` `.imm .bd{font-size:16.5px!important;line-height:1.86!important}`, `:4596` `#word p{font-size:18px;line-height:1.78;...}`, `:4609` `#lite .anc{font-size:16.5px;line-height:1.86;...}` — all three verbatim. Base `.bd` 14.5/1.76 at `:4450,:4477,:4500,:4523,:4549`; the toggle at `:5506` exact; `READS` at `:5265` is the seven panels.
· App sites verbatim: `Point/PointReadings.swift:217` `.font(section.quoted ? .loraItalic(15.5) : .lora(15.5))`; `Universe/UniverseView.swift:574` `Text(word).font(.lora(15)).lineSpacing(15 * 0.74)`; `Screens/LightType.swif

### BOTH-WRONG — `light-approach-fade-coefficient` · rows `E1.13`, `E1.14`, `E1.17`, `E1.2`, `E4.2`

**Design** — Both members are adjacent `<p>`s in one flex column inside `Approach()`, driven by the same `prog` (`acc/4600` — the stillness accumulator, `The Light v2.html:637-641`).

· MEMBER A — the scene label, `{scene.label}` · `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light v2.html:680-681`
  `fontSize:21, color:'var(--ink)' (alpha 1.00), fontWeight:500, opacity:1-prog*0.55, transition 1.2s`
  → effective alpha 1.00 → 0.45. It FADES TO A FLOOR and is still there when the Light opens.

· MEMBER B — the subtitle "Not to be wanted. To be stood inside." · `…/The Light v2.html:682-683`
  `fontSize:13 italic, color:'var(--ink35)' (alpha 0.35), opacity:1-prog, transition 1.6s`
  → effective alpha 0.35 → 0.00. It FADES TO NOTHING.

The pair's whole point is the asymmetry: at `prog=1` the name of the scene survives, the subtitle is gone.

**App** — The app's `still` is the exact analogue of `prog` — `min(1, stillMs / gateMs)` with `gateMs = 4600`, the design's own 4600 (`Screens/LightView.swift:81,85`). So the terms are directly comparable.

· MEMBER A port — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:183-186`
  `Text(scene.title).font(.lora(20)).italic()`
  `.foregroundStyle(BinduTheme.inkSecondary.opacity(0.75 * (1 - still)))`
  `inkSecondary` = #EDE8E3 @ 0.60 → effective alpha 0.45 → 0.00.

· MEMBER B port — `…/Screens/LightView.swift:199-202`
  `Text(LightCanon.approachSubtitle).font(.lora(12)).italic()`
  `.foregroundStyle(BinduTheme.inkTertiary.opacity(0.4))`
  `inkTertiary` = #EDE8E3 @ 0.35 → effective alpha 0.14, CONSTANT. No `still` term anywhere on this line.

Exactly one app site exists per member (`grep approachSubtitle` → 1 render site; `grep scene.title` → 1 site), so this is not a case of a second port elsewhere.

Effective alpha, start → end:
              design            app
  label       1.00 → 0.45       0.45 → 0.00
  subtitle    0.35 → 0.00       0.14 → 0.14

Neither app site carries its own member's coefficient. Member A's `0.55` is nowhere in the file; member B's `1-prog` is absent entirely — a static `0.4` occupies the slot where the fade term belongs. In its place each 

**Comment** — NONE — and the absence is the tell here, in a way `check_citations` cannot see at all.

Member A carries the only comment on either site, `Screens/LightView.swift:182`:
  `// the scene's name, fading as stillness deepens (comp The Light v2 approach)`
It cites the comp REGION with no line number, so there is no citation to verify and nothing for `check_citations` to bite on. What it asserts — "fading as stillness deepens" — is true of both siblings and therefore discriminates neither; it is exactly the sentence a reader writes after looking at `1-prog` (member B's line) and would NOT write afte

**Evidence** — Design, verbatim (`/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light v2.html:680-683`):

```
<p style={{fontSize:21,lineHeight:1.48,color:'var(--ink)',fontWeight:500,letterSpacing:'-0.012em',textWrap:'pretty',
  opacity:1-prog*0.55,transition:'opacity 1.2s ease'}}>{scene.label}</p>
<p style={{fontSize:13,fontStyle:'italic',color:'var(--ink35)',marginTop:14,lineHeight:1.7,
  opacity:1-prog,transition:'opacity 1.6s ease'}}>Not to be wanted. To be stood inside.</p>
```

App, verbatim (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:182-202`):

```
// the scene's name, fading as stillness deepens (comp The Light v2 approach)
Text(scene.title)
    .font(.lora(20)).italic()
    .foregroundStyle(BinduTheme.inkSecondary.opacity(0.75 * (1 - still)))
…
Text(LightCanon.approachSubtitle)
    .font(.lora(12)).italic()
    .foregroundStyle(BinduTheme.inkTertiary.op

**Refutation** — Survives every refutation attempt. (1) Design verbatim: `Claude Design Round 1/comps/The Light v2.html:681` `opacity:1-prog*0.55` on `{scene.label}`; `:683` `opacity:1-prog` on "Not to be wanted. To be stood inside." — adjacent <p>s in one flex column in Approach(), same driver. (2) App verbatim: `Bindu Feed/Bindu Feed/Screens/LightView.swift:183-186` `Text(scene.title)…inkSecondary.opacity(0.75 * (1 - still))` and `:199-202` `Text(LightCanon.approachSubtitle)…inkTertiary.opacity(0.4)`. (3) Alternate-source attack FAILED: the second Light comp `comps/The Light - S-L01 Dawn.html` contains no approach copy (no label, no subtitle, no prog-driven opacity), and `Claude Design Round 2/design-source/The Light v2.html` is byte-identical to Round 1 (diff → IDENTICAL). Single source. (4) Wrong-eleme

### BOTH-WRONG — `lightv2-approach-two-lines` · rows `E1.13`, `E1.14`, `E1.17`

**Design** — Verified verbatim at the cited sites.

A · scene label (`{scene.label}`) — `Claude Design Round 1/comps/The Light v2.html:681`
   `opacity:1-prog*0.55,transition:'opacity 1.2s ease'`
   base 1.00, fade coefficient **0.55** → travels 1.00 → **0.45**. Survives the gate.

B · "Not to be wanted. To be stood inside." — `The Light v2.html:683`
   `opacity:1-prog,transition:'opacity 1.6s ease'`
   base 1.00, fade coefficient **1.0 (none written)** → travels 1.00 → **0.00**. Does not survive.

`prog` is `acc.current/4600` (`:640`), the stillness accumulator. The distinguishing element is the presence of `0.55` on A and its absence on B — the #where/#pname shape exactly.

Third caption in the same block, for context: `:688` `touch once` — `opacity:arrived?0:0.55,transition:'opacity 2.4s ease'` (binary on `arrived`, not on `prog`).

**App** — Both members ARE ported; single port each, no duplicates (grep for `scene.title` / `approachSubtitle` across `Bindu Feed/Bindu Feed/` returns one site apiece).

A · `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:183-185`
   `Text(scene.title)` … `.foregroundStyle(BinduTheme.inkSecondary.opacity(0.75 * (1 - still)))`
   base **0.75**, fade coefficient **1.0** → travels 0.75 → **0.00**.

B · `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:199-201`
   `Text(LightCanon.approachSubtitle)` … `.foregroundStyle(BinduTheme.inkTertiary.opacity(0.4))`
   flat **0.4**, **no fade term at all** → 0.40 → **0.40**. Never fades.

The driver matches: `still` = `min(1, stillMs / gateMs)` (`LightView.swift:85`), `gateMs = 4600` (`:83`), `idleMs = 340` (`:84`) — the exact analogue of the comp's `prog`. So the variable was ported correctly and only the coefficients were not.

Neither transition ported: no `.animation` / `withAnimation` anywhere in the approach block (`:170-212`); `still` steps on a bare 50 ms timer (`:522`) with no animation wrapper. `1.2s` and `1.6s` are both absent.

Third caption: `:198` `touch once` — `0.6 * (1 - still)` where `:688` is `arrived ? 0 : 0.55`. The design snaps it off at the first touch; the app fades it across the who

**Comment** — YES on both members — the sibling-citation tell is present in two different forms, and neither is line-numbered in a way `check_citations` could falsify.

MEMBER A · `LightView.swift:182`, directly above the site, quoted in full:
   `// the scene's name, fading as stillness deepens (comp The Light v2 approach)`
It names the comp but gives **no line number** — so there is nothing for `check_citations` to resolve. Worse, the behaviour it asserts, "**fading as stillness deepens**" (i.e. fading away to nothing), is member **B**'s `1-prog` at `:683`, not member A's `1-prog*0.55` at `:681`. A's desi

**Evidence** — **BOTH-WRONG, and the consequence is a clean inversion of the pair's whole point.**

Not TRANSPOSED in the literal sense: neither app site carries the other's design *value*. A carries `0.75`, B carries `0.4`; the design has `0.55` on A and no constant on B. `awk 'NR>=622 && NR<=692 && /0\.75|0\.4[^0-9]/'` over the comp's entire `Approach` component returns **nothing** — 0.75 and 0.4 are both inventions, each plausible-looking in isolation (a primary caption a little dimmed; a tertiary caption dimmer still), which is precisely why they read as considered. Not COLLAPSED — the two values differ. Not ONE-MISSING — both members are present and both are wrong.

But the *behaviour* is half-transposed, and that is the real damage. The design's distinction, stated in the group's own `whySiblings`: **the label must survive the fade, the subtitle must not.**

| | design at prog=1 | app at still=1 

**Refutation** — SURVIVES. Every quote verified verbatim at the cited lines; every refutation route closed.

DESIGN (exact, both files): `Claude Design Round 1/comps/The Light v2.html:681` `opacity:1-prog*0.55,transition:'opacity 1.2s ease'}}>{scene.label}` and `:683` `opacity:1-prog,transition:'opacity 1.6s ease'}}>Not to be wanted. To be stood inside.` JS precedence makes :681 `1-(prog*0.55)`, so 1.00→0.45. `prog=acc/4600`, `acc` capped at 4600 (:645-648).

APP (exact): `Screens/LightView.swift:183-185` `Text(scene.title)` … `.foregroundStyle(BinduTheme.inkSecondary.opacity(0.75 * (1 - still)))`; `:199-201` `Text(LightCanon.approachSubtitle)` … `.foregroundStyle(BinduTheme.inkTertiary.opacity(0.4))`. Driver equivalent: `still = min(1, stillMs/gateMs)` (:85), `gateMs = 4600` (:83), stepped `stillMs + 50` 

### BOTH-WRONG — `passage-aperture-stops` · rows `C2.1`, `C2.2`, `C2.3`, `C2.5`, `C2.6`, `C2.8`, `C2.9`, `D6.1`, `D6.7`

**Design** — Both members are stops of one radial gradient in `P.draw` act 4, "the aperture at the far end — it opens, and then it FLOODS", `Claude Design Round 1/The Instrument v3.html`.

MEMBER A · stop 0 (the core) — `The Instrument v3.html:3686`
  `gg.addColorStop(0, rgba(WHITE, Math.min(1,(0.5+ap*0.5))*al));`
  base 0.5 · slope 0.5 · clamp 1 · colour WHITE = [255,250,246] (`:3585`) · × al
  ap=0 → 0.50 ; ap=1 → 1.00

MEMBER B · stop 0.34 (the shoulder) — `The Instrument v3.html:3687`
  `gg.addColorStop(0.34, rgba(mixc(cto,WHITE,0.5), Math.min(0.92,ap*0.95)*al));`
  base 0 · coefficient 0.95 · clamp 0.92 · colour = destination hue mixed HALF to WHITE · location 0.34 · × al
  ap=0 → 0.00 ; ap=1 → 0.92

Shared: `al = this.on ? 1 : this.after` (`:3685`), so the aperture survives the landing at full ap and fades over the 0.75s afterglow. Terminator `gg.addColorStop(1, rgba(cto,0))` (`:3688`).

**App** — ONE app site carries both members, as one three-colour array:

`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:976`
  `with: .radialGradient(.init(colors: [.white.opacity(0.5 * ap), hue.opacity(0.2 * ap), .clear]),`
  `                      center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: ar))`

inside `ThroatView` (`:956-981`); `ap` is computed identically at `:972` (`pow(max(0,(t-0.28)/0.72), 2.5)`) and `ar` at `:974` matches `:3684`. So the driver is right and only the stop alphas are at issue.

MEMBER A port — `.white.opacity(0.5 * ap)`
  base 0 (design 0.5) · slope 0.5 (kept) · NO clamp (design 1) · `.white` = [255,255,255], not the design's [255,250,246]
  ap=0 → 0.00 (design 0.50) ; ap=1 → 0.50 (design 1.00) — half the design at full flood, and absent at the moment the aperture is born.

MEMBER B port — `hue.opacity(0.2 * ap)`
  coefficient 0.20 (design 0.95) · NO clamp (design 0.92) · raw `hue`, the 0.5 white-mix dropped · NO location: SwiftUI's three-colour `.init(colors:)` spaces stops evenly, so the shoulder sits at 0.5, not 0.34.
  ap=1 → 0.20 against the design's 0.92 — 4.6× dark.

All four constants of the clamp/base pair are wrong. What makes this the sweep's class rather than a plain miss: the core's `0.5` IS in the app, bu

**Comment** — NONE of the known shape — and the reason is worse than the known shape. There is no per-member comment; one header covers both, and it cites NO line number for either, so there is nothing for `check_citations` to verify or mis-verify.

`InstrumentView.swift:951-955`, verbatim:
  "// THE PASSAGE — the crossing drawn as a throat (spine-passage.js): perspective rings
   // scrolling through the tunnel with an aperture flooding at the far end. Inward is a
   // wormhole (the world rushes outward past him, light pours from the point); outward a
   // whitehole (the sky un-collapses on arrival). ≈ t

**Evidence** — DESIGN (`/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:3682-3688`), byte-exact:
    /* 4 · the aperture at the far end — it opens, and then it floods */
    var ap=ap0;
    var far=Math.max(2,R0*(0.02+ap*2.3));
    var gg=x.createRadialGradient(cx,cy,0,cx,cy,far);
    var al=this.on?1:this.after;
    gg.addColorStop(0,rgba(WHITE,Math.min(1,(0.5+ap*0.5))*al));
    gg.addColorStop(0.34,rgba(mixc(cto,WHITE,0.5),Math.min(0.92,ap*0.95)*al));
    gg.addColorStop(1,rgba(cto,0));
Identical at `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Instrument v3.html:3687` — the two rounds agree, so there is no rival source to have been built from.

APP (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:972-977`), byte-exact:
            let ap = pow(max(0, (t - 0.28) / 0.72), 2.5)
            if ap > 0 {
                let ar = R0 

**Refutation** — CORE SURVIVES. Design lines byte-exact at `Claude Design Round 1/The Instrument v3.html:3686-3687`, both stops on the single gradient created at `:3684` — genuine adjacent siblings, so no false-TRANSPOSED risk. Three defences tested and all fail: (1) NO RIVAL SOURCE — `diff -q` Round 1 vs `Claude Design Round 2/design-source/The Instrument v3.html` returns IDENTICAL. (2) NO COMPOSITING CONFOUND — the `globalCompositeOperation='lighter'` block opened at `:3657` closes with `x.restore()` at `:3668`, so the aperture at `:3681-3689` draws source-over and the alphas ARE directly comparable. (3) NO SURFACE-DRIVEN DIVERGENCE — `InstrumentView.swift:972` (`ap`) and `:974` (`ar`) transcribe `:3641` (`ap0`) and `:3683` (`far`) exactly and R0-normalized, so the author had this block in hand and rewro

### BOTH-WRONG — `point-dim-vs-faint-tokens` · rows `D2.3`, `D2.4`, `D4.1`, `D5.10`

**Design** — `Claude Design Round 1/comps/The Point v9.html:11` — one `:root` line carries both:
 · `--dim`   → `rgba(237,230,214,.56)`
 · `--faint` → `rgba(237,230,214,.22)`
Consumers in the same file, so the roles are unambiguous:
 · `--dim`  at `:28` `.voice` · `:901` `.v-deep` · `:1057` `.uhead .us` · `:1083` `.s-body.q` · `:1097` `.d-stage.minor .d-text` · `:1111` `#rope .rg`
 · `--faint` at `:29` `.hint` · `:57` `#count` · `:59`/`:61` `.lnk` · `:897` `#apstatus` · `:902` `.v-org` · `:1084` `.s-ref` · `:1147` `#dstatus`
Ratio the design authors: faint = 0.393 × dim. The base colour is #EDE6D6, the Point's own warmer cream (ported for canvas at `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointYantra.swift:60`, `static let cream: [Double] = [237, 230, 214] // #EDE6D6`).

**App** — **There is no named port of either token.** Every element the design paints with them resolves instead to the app's *global* ink tiers, defined at `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:33-35`:
 · `inkPrimary   = Color(hex: "#EDE8E3")`
 · `inkSecondary = Color(hex: "#EDE8E3").opacity(0.60)`   ← stands in for `--dim` (.56)
 · `inkTertiary  = Color(hex: "#EDE8E3").opacity(0.35)`   ← stands in for `--faint` (.22)

`--dim` role, app sites (all 0.60):
 · `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:205` — `Text(dim.voice).font(.loraItalic(12)).foregroundStyle(BinduTheme.inkSecondary)` (the enclosure `.voice` / `.uhead .us`)
 · `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:224` — `Text(u.sub).font(.loraItalic(12)).foregroundStyle(BinduTheme.inkSecondary)` (`.uhead .us`, `:1057`)
 · `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:508` — `.foregroundStyle(sg.2 ? BinduTheme.inkSecondary : BinduTheme.inkPrimary)` (`.d-stage.minor`, `:1097`)
 · `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:219` — `.s-body.q` does not even reach a dim tier: quoted sections render `inkPrimary.opacity(thinned ? 0.72 : 1)`.

`--faint` role, app sites (0.35 and three ad-hoc ne

**Comment** — NONE of the cross-sibling kind. I checked the comment above every app site and no comment on a `--faint` element cites a `--dim` design line or vice versa. The two citations that exist are both correct for their own element:
 · `Point/PointWorlds.swift:212-213` — *"Canon — The Point v9.html:890. The slot exists; the invented line that was here did not."* — `:890` is `</div><div class="hint">enter a universe</div>`, a `--faint` consumer, cited above a `--faint`-role site. Correct.
 · `Point/PointWorldView.swift:431` — *"The two minor stages are set smaller, dimmer and italic (`.d-stage.minor`, 

**Evidence** — NOT transposed (0.60 > 0.35 preserves the design's ordering, and neither equals the other's design value), NOT collapsed (two distinct tiers survive), NOT one-missing (both roles render). Each member carries a plausible number and neither is the design's — **BOTH-WRONG**.

**Where the wrong numbers came from, which is what makes this survivable.** 0.60 and 0.35 are not invented: they are a *real corpus token pair* from a different design file — `Claude Design Round 1/A Strange Feed.html:357`, `--ink60:rgba(237,232,227,0.60)` / `--ink35:rgba(237,232,227,0.35)` — ported faithfully to `Theme.swift:34-35` and then applied across the Point section, whose design has its own pair. A reader comparing the two app sites sees 0.60 against 0.35, one tier above another, and concludes somebody weighed them. They did — against the wrong file. This is precisely the `whySiblings` prediction: because `--d

**Refutation** — Survives every attack. DESIGN VERIFIED EXACT: `The Point v9.html:11` reads `--dim:rgba(237,230,214,.56);--faint:rgba(237,230,214,.22)` verbatim; all 14 cited consumer lines (:28,:29,:57,:59,:61,:890,:897,:901,:902,:1057,:1083,:1084,:1097,:1111,:1147) read as quoted, and a full grep of the file returns those and no others — the consumer inventory is complete. APP VERIFIED EXACT: Theme.swift:33-35, PointWorlds.swift:205/:215, PointWorldView.swift:224/:234/:455/:508/:528, PointReadings.swift:219/:232 all read verbatim. REFUTATIONS ATTEMPTED AND FAILED: (1) No Point-local port exists — grep "faint" across the whole Swift tree yields exactly one colour constant, ApertureView.swift:45, the control; no #EDE6D6 Color exists (PointYantra.swift:60 holds it only as [Double] for canvas); PointWorldVie

### BOTH-WRONG — `point-ink-tokens` · rows `D5.11`, `F2.4`

**Design** — `--dim` → `rgba(237,230,214,.56)` and `--faint` → `rgba(237,230,214,.22)`, both on one `:root` line: `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Point v9.html:11`. Byte-identical second copy at `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Point v9.html:11` (files `diff` clean), so there is no rival source. Consumers in the design — `--dim`: `:28 .voice`, `:901 .v-deep`, `:1057 .uhead .us`, `:1083 .s-body.q`, `:1097 .d-stage.minor .d-text`, `:1111 #rope .rg`. `--faint`: `:29 .hint`, `:57 #count`, `:59 #sndbtn`, `:61 .lnk`, `:897 #apstatus`, `:902 .v-org`, `:1084 .s-ref`, `:1147 #dstatus`. Ratio between the two tiers: 2.55×.

**App** — Neither member has a named port. Every consumer of both is rendered through the app's GLOBAL ink pair, defined with no comment at `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:34` — `static let inkSecondary = Color(hex: "#EDE8E3").opacity(0.60)` — and `:35` — `static let inkTertiary  = Color(hex: "#EDE8E3").opacity(0.35)`.

`--dim` (.56) role sites, all `inkSecondary` @ 0.60: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:205` (`.uhead .us`, design `:1057`); `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:508` (`.d-stage.minor`, design `:1097`); `PointWorldView.swift:224`; `PointWorldView.swift:258` (`inkSecondary.opacity(0.66)`).

`--faint` (.22) role sites, all `inkTertiary` @ 0.35: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:215` (`.hint` "enter a universe", design `:890`/`:29`) at `inkTertiary.opacity(0.45)` = 0.1575 effective; `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:234` (`.lnk` back link, design `:61`) at 0.35; `Point/PointReadings.swift:244`; `Point/PointRevealView.swift:81`.

Not TRANSPOSED (order preserved, secondary > tertiary), not COLLAPSED (still two values), not ONE-MISSING (both roles present). Each carries a plausible number and ne

**Comment** — No comment on either member cites the other member's design line — the app never cites `The Point v9.html:11` at all (full citation set in the app: `:16, :42-43, :623-632, :871, :873, :876-909, :890, :923-937, :926-932, :929, :954, :967, :1019, :1236, :1286, :1341`). But the class's signature — a correct citation with a scoped fidelity claim over a wrong constant — is present twice:

1. `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorldView.swift:504` names the token by role and then hands the site the foreign palette on the next four lines:
   "// `.d-text` 17/1.76 cream · `.min

**Evidence** — WHAT HAPPENED, mechanically: `BinduTheme.inkSecondary`/`inkTertiary` are the port of a DIFFERENT design's tokens — `A Strange Feed.html:357` and `Home Feed.html:26-27`, `--ink60: rgba(237,232,227,0.60)` / `--ink35: rgba(237,232,227,0.35)` — and `git log -L33,35` puts them in commit **83c8b70 "Phase 7 complete"**, the Feed build, before any Point code existed. The Point port then reached for the enum that was already there. Two files with a `:root` ink pair; the app kept one pair and pointed both surfaces at it.

THE CONTROL THAT PROVES THIS WAS NOT INEVITABLE — the sibling comp got the identical shape right. `/Users/ashrey/Bindu Feed/Claude Design Round 2/comps/The Aperture.html:7` is the same one-line construction: `--cream:#F0E9DC;--dim:rgba(240,233,220,.62);--faint:rgba(240,233,220,.3)`. Its port, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/ApertureView.swift:43-45`:

    pr

**Refutation** — Survives attack. DESIGN VERIFIED EXACT: `The Point v9.html:11` reads verbatim `--cream:#EDE6D6;--dim:rgba(237,230,214,.56);--faint:rgba(237,230,214,.22)`; the Round 2 copy at `Claude Design Round 2/design-source/The Point v9.html:11` diffs clean; `find` shows only these two copies exist, so no rival source. APP VERIFIED EXACT: `Bindu Feed/Bindu Feed/Theme/Theme.swift:33-35` = `#EDE8E3` at 1.0/0.60/0.35.

TWO PORTS ARE VERBATIM-ANCHORED, which defeats the "unrelated elements sitting near each other" objection: (1) `--dim` -> `Point/PointWorldView.swift:504-508`, whose own comment reads "`.d-text` 17/1.76 cream · `.minor` 14.5 dim italic" and renders `.loraItalic(14.5)` with `inkSecondary`, against design `.d-stage.minor .d-text{font-size:14.5px;color:var(--dim);font-style:italic}`; (2) `--f

### BOTH-WRONG — `return-past-self-rendered-twice` · rows `E3.3`, `E3.8`, `E3.9`

**Design** — Both members are in /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html.

MEMBER A — Record, the sealed self inline (function Record, :546):
· :571 `borderLeft:'2px solid var(--ash)',paddingLeft:16,opacity:0.94`
· :572 `fontSize:16,lineHeight:1.76` (+ fontStyle italic, filter saturate(0.85))
· :574 trailing sentence `fontSize:12.5,marginTop:16,lineHeight:1.7`

MEMBER B — PastSelf, the same block set apart (function PastSelf, :609):
· :612 `borderLeft:`2px solid ${'var(--ash)'}`,paddingLeft:16,opacity:0.92`
· :613 `fontSize:16.5,lineHeight:1.78` (+ fontStyle italic, filter saturate(0.85))
· :615 trailing sentence `fontSize:12.5,marginTop:18,lineHeight:1.7`

TWO FACTS THAT CHANGE THE GROUP, both verified in the files:

(1) MEMBER B NEVER MOUNTS. `PastSelf` is defined at :609 and is absent from the stage router at :702-709, which runs summons → room → story → record → field → rings → reply → sealed. It is orphan code the designer left behind after moving the block inline into `Record`. So the app rendering the block ONCE is correct, and COLLAPSED is the wrong charge.

(2) THE DESIGN ALREADY RESOLVED THE PAIR, TOWARD B. `Claude Design Round 1/The Return v2.html` — the file every comment in the app's Return cites — merged the two into one `Record` at :1127, headed "th

**App** — ONE port, not two. Whole app searched: `recordSettled` has exactly one call site, `sealedSelf` has two and the second is not this block.

THE PORT — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift, inside `private var record` (:281):

:322-326
    Text(storyData.sealedSelf)
        .font(.loraItalic(15)).lineSpacing(6)
        .foregroundStyle(ReturnCanon.ashColor)
        .saturation(0.85)                       // .dried — the past self, ash terracotta
        .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)

:332
    Text(ReturnCanon.recordSettled).font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary).padding(.top, 6)

PROPERTY BY PROPERTY — the port carries NEITHER member's constant on three of four:

· fontSize — app 15. A=16, B/v2=16.5. Neither.
· lineHeight — app `.lineSpacing(6)` ≈ 1.4 at 15pt. A=1.76 (→12.16), B/v2=1.78 (→12.87). Neither, and roughly half either way. This file's own convention is size×(lh−1) and it is applied correctly on both immediate neighbours: :313 `.font(.lora(14)).lineSpacing(14 * 0.68)` and :380 `.font(.lora(16.5)).lineSpacing(16.5 * 0.74)`. The one block between them uses a bare `6`.
· marginTop on the trailing sentence — app `.padding(.top, 6)`. A=16, B/v2=18. Neither.
· opacity — NO `.opacity()` modifi

**Comment** — NONE of the `#where` kind — and the reason is worse than a wrong citation.

NO COMMENT ON THIS BLOCK CITES ANY DESIGN LINE. The only comment inside it is :325:

    .saturation(0.85)                       // .dried — the past self, ash terracotta

A CSS class name with no file and no line number. There is no citation for `check_citations` to test, so the block is not verified and not flagged — it is invisible rather than wrong.

WHAT MAKES IT READ AS COVERED — the sibling directly above IS correctly cited. The E3.8 comment at :282-290 cites `:1136-1141` and `:1142`, and those are right: they a

**Evidence** — FILES
· /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html — :546 `function Record`, :571-574 member A; :609 `function PastSelf`, :612-615 member B; :702-709 the stage router that never mounts PastSelf.
· /Users/ashrey/Bindu Feed/Claude Design Round 1/The Return v2.html — :1126-1152 the merged Record; :931 `.dried`; :934-935 `.foxed`.
· /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift — :280 header, :281 `private var record`, :294-296 the gathering rail (built), :313 lineSpacing convention, :322-326 the port, :325 the uncited `.dried` comment, :332 the trailing sentence, :380 lineSpacing convention.
· /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Return/ReturnPatina.swift — :52-54 `color(_:_:)`, :78 `enum ReturnDeboss`.
· /Users/ashrey/Bindu Feed/Coverage/1-AUDIT-254.md — :319 E3.3, :324 E3.8, :325 E3.9.
· /Users/ashrey/Bindu Feed/Coverage/11-COM

**Refutation** — SURVIVES the attack. Every load-bearing claim verified independently.

DESIGN — quoted verbatim. `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html`:571-574 is member A (`borderLeft:'2px solid var(--ash)',paddingLeft:16,opacity:0.94` · `fontSize:16,lineHeight:1.76` · `marginTop:16`); :612-615 is member B (`opacity:0.92` · `fontSize:16.5,lineHeight:1.78` · `marginTop:18`). Both render `PAST_SELF.words` followed by the identical sentence "The ink has settled…", so they are genuinely the same element, not neighbours mistaken for a pair — a false-TRANSPOSED risk does not apply.

COLLAPSED IS CORRECTLY REJECTED. `grep -n "PastSelf"` over the whole comp returns exactly ONE hit: :606, its own definition. The router (:700-711) runs summons→room→story→record→field→rings→reply→sea

### BOTH-WRONG — `rite-voice-label-tracking` · rows `E1.18`, `E2.1`, `F0.1`

**Design** — Both members are `<Mono size={9}>` block captions stacked above the voice header, each OVERRIDING the Mono primitive's base `letterSpacing:'0.14em'` (`The Rite v3.html:1261`) with its own value — so the two overrides are deliberate and deliberately different.

· Member A — the "answering {name}" label → `letterSpacing:'0.18em'`, `marginBottom:8`, default `var(--ink35)` colour.
  Site: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Rite v3.html:1390
  `{v.answering&&<Mono size={9} style={{display:'block',marginBottom:8,letterSpacing:'0.18em'}}>answering {v.answering}</Mono>}`

· Member B — the "{name} · {verb}" label → `letterSpacing:'0.16em'`, `marginBottom:9`, `color:v.color`.
  Site: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Rite v3.html:1391
  `<Mono size={9} style={{display:'block',marginBottom:9,letterSpacing:'0.16em',color:v.color}}>{v.name} · {v.verb}</Mono>`

Context that matters for the port: `:1395` is a THIRD, separate element — `<span style={{fontFamily:'Lora, serif',fontSize:14,fontWeight:500,color:v.color}}>{v.name}</span>` beside the avatar, followed by `<Mono size={9}>{v.role}</Mono>` at the untouched 0.14em default.

**App** — Sole port of this header is `VoiceText` in /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:258-286. `grep -rn "verb)"` over the app returns exactly one site; `voice.answering` is read in exactly one place. There is no second Gathering renderer.

· Member A — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:282-284
  `Text("answering \(answering)")` · `.spaceMonoTracked(8, em: 0.125)` · `.foregroundStyle(voice.color.opacity(0.6))`
  → carries **0.125em**, not its own 0.18em and not the sibling's 0.16em. (`spaceMonoTracked` at Theme.swift:151 applies `.tracking(em * size)`, so em is the design-comparable number: 0.125 × 8 = 1.0pt where the design asks 0.18 × 9 = 1.62pt.) The label is also moved BELOW the role, where the design puts it first, above everything.

· Member B — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:274-276
  `Text("\(voice.name) · \(voice.verb)")` · `.font(.lora(13)).italic()` · `.foregroundStyle(voice.color)`
  → **not a Mono caption at all.** No `spaceMonoTracked`, no tracking, no uppercase; tracking is 0. The 0.16em has no port anywhere in the app.

The structural shape underneath: the app took member B's STRING (`:1391`) and put it in the SLOT of the design's `:1395

**Comment** — NONE — no comment on either app site cites the other member's design line, and no comment cites a line number at all.

The only comment in the pair's vicinity is RiteGatheringView.swift:280, on member A:
`// "answering Sakshi" — the one who speaks in reply (comp The Rite v3).`

That is a weaker instance of the same blind spot rather than the known fault: it names the comp with NO line, so `check_citations` has nothing to resolve and nothing to verify — the citation cannot be wrong because it does not reach a line. Member B (`:274`) carries no comment whatsoever. A repo-wide grep for `Rite v3.h

**Evidence** — **The mechanism, from git — the sweep preserved the app's invented numbers instead of restoring the design's.**

Member A entered the app on 2026-08-23 in `6372dfa` ("Fidelity sweep 6/N: Rite arrival glyph + Gathering hints + answering label") as:
`.font(.spaceMono(8)).tracking(1)`
— a hand-picked round 1pt. The design's 0.18em was never consulted.

Then `b19f1d6` (E1.18 / the F0.1 helper) rewrote all four labels in this file by pure arithmetic, dividing the app's existing POINTS by the app's own size:
`-.font(.spaceMono(9)).textCase(.uppercase).tracking(2)`   → `+.spaceMonoTracked(9, em: 2 / 9)`
`-.font(.spaceMono(8)).textCase(.uppercase).tracking(1.5)` → `+.spaceMonoTracked(8, em: 0.1875)`   (silent label, :131)
`-.font(.spaceMono(8)).textCase(.uppercase).tracking(1.2)` → `+.spaceMonoTracked(8, em: 0.15)`     (role, :278)
`-.font(.spaceMono(8)).textCase(.uppercase).tracking(1)`   → `+.

**Refutation** — Survives every refutation path. (1) VERBATIM: design :1390 (0.18em/mb8), :1391 (0.16em/mb9), the Mono base 0.14em at :1261 and the third element :1395 all read exactly as quoted; app :274-275, :277-278, :280-284 likewise; every line number correct. (2) SIBLINGS CONFIRMED: :1388-1392 shows both members are the first two children of one <div marginBottom:18> header block, same element type, same size={9}, same display:'block', both overriding the same 0.14em base. No TRANSPOSED risk — the two app values are 0.125em and zero, so there are no correct constants to swap. (3) NO ALTERNATIVE DESIGN SOURCE: Claude Design Round 2/design-source/The Rite v3.html is byte-identical to Round 1 (diff clean, same two constants); and The Gathering v3.html:226 independently carries the same member B as <Mono

### BOTH-WRONG — `story-avatar-derived-ratios` · rows `F2.5`, `F5.2`, `F5.3`

**Design** — The design's `Avatar` primitive holds three constants in one 15-line block, two of them this group's members.

MEMBER A — glow radius ratio → 0.44.
`/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Story Detail.html:465` — `const g = Math.round(size * 0.44);`, consumed one line later at `:470` as TWO shadows: `boxShadow: '0 0 ${g}px ${d.color}50, 0 0 ${Math.round(g*0.35)}px ${d.color}28'`. Twin at `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Rite v3.html:1270` (and `comps/The Rite v3.html:1270`), identical.

MEMBER B — glyph font-size ratio → 0.38.
`/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Story Detail.html:474` — `fontSize: Math.round(size * 0.38),`. Twin at `The Rite v3.html:1272`, identical. The line immediately BELOW it, `:475`, is `color: 'rgba(255,255,255,0.88)'` — the third constant, and it matters (see evidence).

Call sites that fix the sizes the app must reproduce: `Story Detail.html:590` `<Avatar size={36}/>` (field comment), `:550` `<Avatar size={24}/>` (reply), `:636/:668/:806` Ash at 30/28/36.

**App** — The port is `VoiceAvatar` — confirmed by its call sites, which reproduce the design's own: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/CommentCard.swift:122` `VoiceAvatar(archetype:, size: 36)` against `Story Detail.html:590`, and `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/ReplyRow.swift:107` `VoiceAvatar(archetype:, size: 24)` against `:550`. Those, plus `VoiceAvatar.swift:78` inside the stack, are its only three call sites.

MEMBER A's port — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/VoiceAvatar.swift:9-13`:
    // outer glow halo
    Circle()
        .fill(archetype.color.opacity(0.22))
        .blur(radius: 4)
        .frame(width: size * 1.6, height: size * 1.6)
There is NO ratio here at all. The blur is a fixed 4pt, independent of `size`; `1.6` is a frame multiplier, not the design's radius term; the second shadow (`g*0.35` at alpha 0x28) has no port. `0.44` appears nowhere in the app's avatar code — repo-wide grep for `size * 0.44` / `size*0.44` returns zero hits in `.swift`, `.md` and `.py`.

MEMBER B's port — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/VoiceAvatar.swift:22`:
    .font(.system(size: size * 0.52))
A derived ratio IS there — it is `0.52`. Neither its own `0.38` nor its sibling's `0.44`.

Neither

**Comment** — NONE — and the absence is itself the finding, because the file is otherwise densely cited.

No comment anywhere on `VoiceAvatar` cites `Story Detail.html:465`, `:474`, `The Rite v3.html:1270` or `:1272`. A repo-wide grep for those four line citations across `.swift`, `.md` and `.py` returns ZERO hits — the two design lines this group names are cited by nothing in the build, not by code, not by the audit, not by a checker.

What stands above the two members instead is bare description with no source:
 · `:9` — `// outer glow halo`
 · `:15-16` — `// body — a SOLID disc in the archetype's colour 

**Evidence** — **1. The measured deltas.** Glyph, at each of the three live sizes: comment `36 × 0.52 = 18.7pt` against the design's `round(36 × 0.38) = 14` → **1.37×**; reply `24 × 0.52 = 12.5` against `round(24 × 0.38) = 9` → **1.39×**; stack face (`size − ringInset` = 18) `9.4` against Home Feed's literal `fontSize:7` → **1.34×**. Every glyph in the app is ~⅓ too large inside its disc, on every comment, every reply and every feed card. Glow, at size 36: the design draws `0 0 16px` at alpha 0.31 PLUS `0 0 6px` at alpha 0.16; the app draws one blurred disc at alpha 0.22 with a 4pt blur — a fixed halo that stays 4pt whether the avatar is 24 or 36, so the design's whole point (the glow is a property OF the avatar's size) is not merely mis-valued, it is not expressed.

**2. Git blame proves the design block was open and one of its three constants was taken.** `git blame` on `/Users/ashrey/Bindu Feed/Bind

**Refutation** — Survives attack on every front. DESIGN VERIFIED VERBATIM: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Story Detail.html:465 `const g = Math.round(size * 0.44);` consumed at :470 as two shadows, and :474 `fontSize: Math.round(size * 0.38),` with :475 `color: 'rgba(255,255,255,0.88)'` directly below. Twins confirmed at The Rite v3.html:1270 and :1272 (there the 0.38 and the 0.88 share one line). Design call sites confirmed at :550 (24), :590 (36), :636/:668/:806.

APP VERIFIED VERBATIM: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/VoiceAvatar.swift:9-13 is a Circle at opacity 0.22 with a FIXED `.blur(radius: 4)` and `.frame(width: size * 1.6…)`; :22 is `.font(.system(size: size * 0.52))`. Port identity is airtight: its only three call sites are VoiceAvatar.swift:78 (ins

### BOTH-WRONG — `turning-link-hex-alpha-triple`

**Design** — All three members live in one `<a>` block in `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Player Detail - The Turning.html` (byte-identical copy at `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Player Detail - The Turning.html`, same line numbers).

· voice-link background → `background: ${a.color}0D` — :393. Hex 0D = 13/255 = **alpha 0.0510**.
· voice-link border → `border: 1px solid ${a.color}28` — :393 (same line as the background). Hex 28 = 40/255 = **alpha 0.1569**.
· voice-link chevron › → `color: ${a.color}70` — :395. Hex 70 = 112/255 = **alpha 0.4392**.

Non-member on the same block, useful as the control: the label span at :394 carries a DECIMAL `opacity: 0.82`.

**App** — The port is `ashramVoiceLink` in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/TheTurningView.swift:419-444` (only port; `archetype.color` is `Color(hex:)`, opaque, so `.opacity(x)` IS the alpha).

· background → :436 `.fill(archetype.color.opacity(0.05))` — design 0.0510. **RIGHT** (house form for this constant elsewhere is `0.051` with the comment `// ${color}0D`).
· border → :440 `.strokeBorder(archetype.color.opacity(0.28), lineWidth: 1)` — design 0.1569. **WRONG, 1.78× too strong.** `0.28` is the hex digits "28" re-read as a decimal fraction.
· chevron → :430 `.foregroundColor(archetype.color.opacity(0.7))` — design 0.4392. **WRONG, 1.59× too bright.** `0.7` is the hex digits "70" re-read as a decimal fraction.

Not a swap and not a collapse: the three still differ from each other, and no member carries another member's number. Two of the three carry a plausible-looking alpha that is not the design's — the BOTH-WRONG variant. The one member that survived is the one whose hex digits (`0D`) cannot be misread as a decimal.

Consequence, since alpha here is the whole hierarchy: the design orders the block label 0.82 > chevron 0.44 > border 0.157 > ground 0.051 — the chevron is a quiet hint under the sentence. The app renders label 0.82 vs chevron 0.70, so the glyph now

**Comment** — NONE. There is no comment anywhere in `ashramVoiceLink` (`TheTurningView.swift:419-444`) — no citation to misdirect, correct or otherwise. The whole file cites the comp exactly twice (`:92` and `:405`, both `comp:` prose about timing, neither near this block) and never by line number, so `check_citations` had nothing to check here.

This is the same invisibility as the `#where`/`#pname` instance reached by the opposite route: there the checker passed because the citation was correct-but-pointed-at-the-sibling; here it passes because there is no citation at all. Both leave a string checker with

**Evidence** — HOW THE CONVERSION FAULT WAS ISOLATED RATHER THAN ASSUMED — the same file ports a DECIMAL alpha from the same comp correctly:
· design `Player Detail - The Turning.html:174` `stroke={hexA(color, 0.14)}` → app `TheTurningView.swift:260` `.stroke(archetype.color.opacity(0.14), lineWidth: 1.5)`. Correct.
· design `:394` `opacity: 0.82` → app `:426` `.opacity(0.82)`. Correct.
So the file is not sloppy about alphas in general. It is specifically the hex-suffix form that broke, exactly as the group's `whySiblings` predicted.

AND THE APP KNOWS THE RIGHT CONVERSION ELSEWHERE, which rules out "0.28 is a deliberate house value":
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/RoomPortalCard.swift:43` — `.fill(room.color.opacity(0.051))          // ${color}0D`
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/FieldSurfacePortalCard.swift:90` — `.fill(config.color.opacity(0.

**Refutation** — SURVIVES ATTACK. Every quoted line reads exactly as claimed, and each refutation route is closed.

VERBATIM CHECKS. Design `Claude Design Round 1/comps/Player Detail - The Turning.html:393` carries both `background: `${a.color}0D`` and `border: `1px solid ${a.color}28`` on one line; `:395` `color: `${a.color}70``; the decimal control `opacity: 0.82` at `:394`. App `Bindu Feed/Bindu Feed/Screens/TheTurningView.swift` — `:436` `.fill(archetype.color.opacity(0.05))`, `:440` `.strokeBorder(archetype.color.opacity(0.28), lineWidth: 1)`, `:430` `.foregroundColor(archetype.color.opacity(0.7))`, `:426` `.opacity(0.82)`. All exact.

THE ARITHMETIC IS PROVEN BY THE COMP ITSELF, not assumed. `:161` defines `hexA(hex, a) { return hex + Math.round(...a*255).toString(16).padStart(2,'0'); }` — the comp's

### BOTH-WRONG — `universe-fall-caption-pair` · rows `B5.5`, `B5.6`, `B5.7`, `B5.8`, `E1.18`

**Design** — Both members live in ONE `if(set>0.35&&s.title){}` block inside the fall's layer 2 (the gathering), and both are scaled by the same ramp `var ta = L.gath*(set-0.35)/0.65`.

· codex id → font `8px "Space Mono", monospace`; fill `rgba(BONE, ta*0.30)`; drawn at `cx, cy-hal*0.42-15`
  site: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Universe v2.html:949-950

· story title → font `italic 14px Lora, Georgia, serif`; fill `rgba(BONE, ta*0.58)`; drawn at `cx, cy-hal*0.42`
  site: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Universe v2.html:951-952

The pair is identical in all three sources — `The Universe v3.html:950,952` and `comps/uni-fall.js:101,103` carry the same 0.30/0.58, the same 8px-mono / italic-14px-Lora, the same -15 offset. `BONE` is `[214,206,192]` (`The Universe v2.html:366`), i.e. #D6CEC0.

**App** — Sole port of both members, adjacent lines in the same `if set > 0.35 {}` block:

· codex id → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:1440-1441
  `ctx.draw(Text.spaceMono(story.codexId, 9, .asWritten).foregroundStyle(BinduTheme.inkTertiary),`
  `         at: CGPoint(x: cx, y: cy - hal * 0.42 - 18))`
  → size 9 (design 8) · alpha 0.35 flat (design ta*0.30) · colour #EDE8E3 (design BONE #D6CEC0) · offset -18 (design -15)

· story title → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:1442-1443
  `ctx.draw(Text(story.title).font(.lora(16, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary),`
  `         at: CGPoint(x: cx, y: cy - hal * 0.42))`
  → size 16 (design 14) · weight `.medium`, NOT italic (design `italic`) · alpha 1.00 flat (design ta*0.58) · colour #EDE8E3 (design BONE)

`BinduTheme.inkTertiary` = `Color(hex:"#EDE8E3").opacity(0.35)` and `inkPrimary` = `Color(hex:"#EDE8E3")` at 1.0 (Theme/Theme.swift:33,35). No context-level opacity is applied — `drawFall` is called with the bare `ctx` (UniverseView.swift:881), so those alphas are literal.

Neither app site carries its own member's constant, and neither carries the sibling's: 0.35 ≠ 0.58 and 1.00 ≠ 0.30. So this is not a swap — it is BOTH-WRONG on both hal

**Comment** — NONE — and the absence is the tell here, in a different shape than the `#where`/`#pname` instance.

There is NO comment on either caption site. Lines 1439-1443 are bare. The nearest comment above is the section header at `:1435`, `// ── 2 · the gathering — the company settles from orbit into its seats, + the story ──`, which cites no design line at all. So there is no mis-citation for `check_citations` to verify — there is nothing for it to read. The pair is the only unannotated code in a block where every neighbour is heavily cited (B5.8 at `:1414` cites `:895`; B5.7 at `:1470` cites `:955`; 

**Evidence** — Design (identical in three sources), /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Universe v2.html:946-953:

    if(set>0.35&&s.title){
      var ta=L.gath*(set-0.35)/0.65;
      x.textAlign='center';x.textBaseline='alphabetic';
      x.font='8px "Space Mono", monospace';
      x.fillStyle=rgba(BONE,ta*0.30);x.fillText(s.codex,cx,cy-hal*0.42-15);
      x.font='italic 14px Lora, Georgia, serif';
      x.fillStyle=rgba(BONE,ta*0.58);x.fillText(s.title,cx,cy-hal*0.42);
    }

App, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:1439-1444:

    if set > 0.35 {
        ctx.draw(Text.spaceMono(story.codexId, 9, .asWritten).foregroundStyle(BinduTheme.inkTertiary),
                 at: CGPoint(x: cx, y: cy - hal * 0.42 - 18))
        ctx.draw(Text(story.title).font(.lora(16, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary),
                 at: CGPo

**Refutation** — Survives every refutation. Design verified verbatim at The Universe v2.html:947-952 (ta=L.gath*(set-0.35)/0.65; 8px Space Mono at ta*0.30; italic 14px Lora at ta*0.58; BONE=[214,206,192] at :366). App verified verbatim: `if set > 0.35 {` at UniverseView.swift:1439, codex draw 1440-1441, title draw 1442-1443. Text.spaceMono resolves to .custom("SpaceMono-Regular", size:) so 9 is a literal point size.

Refutations attempted and defeated: (1) LATER DESIGN SOURCE — a Round 2 exists; `diff "Claude Design Round 1/comps/uni-fall.js" "Claude Design Round 2/design-source/uni-fall.js"` is byte-IDENTICAL, so four sources carry 0.30/0.58, not three. (2) px->pt SCALE CONVENTION — refuted inside the same block: design :971 `8px` mono ports to `spaceMono(name, 8)` and design :976 `7.5px` ports to `7.5`, 

### COLLAPSED — `asf-keyframe-troughs` · rows `F11.2`, `F11.3`

**Design** — Five troughs, each the floor of one layer, all under the one comment `/* the 0.1 Hz master pulse */` at `Claude Design Round 1/A Strange Feed.html:358`:

· `@keyframes breath` → trough **.34** (peak .80, scale 1→1.045) — `:359`. Worn by: the rope's 110px ring `:476`, the unmet weather wash `:594`, the met weather wash `:604`.
· `@keyframes breathSoft` → trough **.5** (peak .92) — `:360`. Worn by: five turn marks (RoomsMark `:395` 17s · ArchiveMark `:399` 21s · UniverseMark `:404` 26s · LightMark `:408` 13s · PlayersMark `:414` 19s), the top hairline `:596` 10s, the 2×2 dot mark `:619` 14s.
· `@keyframes ember` → trough **.55** (peak 1, scale .96→1.07) — `:361`. Worn by: PointMark `:412`, the rope's ember `:477`, the met bindu dot `:512`.
· `@keyframes hint` → trough **.20** (peak .52) — `:362`. Worn by: "tap anywhere to stay" `:457`, the base line "touch to receive"/"tap anywhere to cross" `:644`.
· `@keyframes glyphBreath` → trough **.44** (peak .95, scale .985→1.03) — `:363`. Worn by: RiteMark `:393`, ArriveMark `:418`, the unmet door glyph `:630`.

The turn's own row list is the place the design distinguishes hardest: eight rows, THREE keyframes, three troughs — .44 (Rite, How You Arrive) · .5 (Rooms, Archive, Universe, Light, Players) · .55 (The Point).

**App** — The comp is the Door; its port is `Screens/DoorView.swift` + `Components/TurnOverlay.swift` + `Components/DoorDust.swift`.

· `breath` (.34) → **/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:251** `.modifier(SlowBreathe())` on the rope ring → `:304` `content.opacity(0.5 + 0.45 * breath.eased(offset: offset))` = **0.5 → 0.95**. Trough is breathSoft's .5; peak is glyphBreath's .95. The unmet wash (`:594`) → `DoorView.swift:111-113` is a **static** RadialGradient, no breath term: NOT-PORTED. (`Screens/PracticeDoorView.swift:149` `.opacity(0.34 + 0.44 * breath.value)` does carry .34, but that is `Practice Door.html:30-32`'s own `doorBreath` 0.34→0.78, a different comp reused as the met weather.)
· `breathSoft` (.5) → **/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:76** `.opacity(0.55 + 0.4 * breath.eased(offset: Double(i) * 0.09))` = **0.55 → 0.95** for ALL eight rows. Trough is ember's .55. The hairline (`:596`) has no port (grep for a 1pt top gradient in DoorView.swift → 0 hits). The dot mark (`:619`) → `DoorView.swift:154-167` is static: no breath, and no 0.34 base.
· `ember` (.55) → **/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:255** `.modifier(EmberBreathe10())` → `:311` `content.opacity(0.6 + 0.4 * 

**Comment** — YES — two, and both are the found instance's shape: a citation that verifies while the constant beneath it belongs to a different member.

1. `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:94`, directly above the `.glyphBreathe` body:
   "// A living breath swells AND brightens (comp glyphBreath: scale(1.06) + opacity)."
   It names THIS member by name — `glyphBreath` — and quotes `scale(1.06)`. A Strange Feed's `glyphBreath` (`:363`) is `scale(.985)→scale(1.03)`. The 1.06 is `Claude Design Round 1/comps/Player Detail - The Turning.html:32`'s same-named keyframe (`o

**Evidence** — COLLAPSED is the primary verdict, with a TRANSPOSED half and a NOT-PORTED half underneath it.

**The collapse.** The design's turn is eight rows carrying three keyframes and three troughs — .44 (Rite, How You Arrive) · .5 (Rooms, Archive, Universe, Light, Players) · .55 (The Point) — with five distinct periods (13/17/19/21/26s) on top. `TurnOverlay.swift:76` renders every one of the eight as `0.55 + 0.4 * breath.eased(offset: i * 0.09)`. Three distinguished floors become one, and the one chosen is `ember`'s .55 — the trough of the single row (The Point) that is NOT `breathSoft`. The peak, 0.95, is `glyphBreath`'s. So the surviving pair 0.55→0.95 is assembled from two members, neither of which governs six of the eight rows it is applied to. This is the rail variant named in the brief, at scale.

**The transposition.** The rope, `A Strange Feed.html:474-483`: ring (`breath`, .34→.80) and e

**Refutation** — Core verdict survives; the commentFault half is refuted.

VERIFIED, DESIGN: `Claude Design Round 1/A Strange Feed.html:358-363` reads byte-for-byte as quoted — comment at :358, breath .34/.80, breathSoft .5/.92, ember .55/1 (.96→1.07), hint .20/.52, glyphBreath .44/.95 (.985→1.03). All 18 wearer sites confirmed at the quoted lines (:393,395,399,404,408,412,414,418,457,476,477,512,594,596,604,619,630,644). `Round 1/README.md:259` confirms this file IS the Door composite; no Round 2 comp supersedes it (Round 2/design-source has Practice Door.html only).

VERIFIED, APP: TurnOverlay.swift:76 `0.55 + 0.4 * breath.eased(offset: Double(i) * 0.09)`; :95 `0.4 + 0.4`; DoorView.swift:251→304 `0.5 + 0.45`, :255→311 `0.6 + 0.4` / scale `0.95 + 0.15`; :111-113 static RadialGradient; :119 bare Text; :154

### COLLAPSED — `asf-mark-breath-periods` · rows `F11.2`, `F11.3`
*The refutation corrected this from the checker's first verdict.*

**Design** — Seven distinct periods, three distinct keyframes, all in one declaration run:
· RoomsMark → `breathSoft 17s` — A Strange Feed.html:395
· ArchiveMark → `breathSoft 21s` — :399
· UniverseMark → `breathSoft 26s` — :404
· LightMark → `breathSoft 13s` — :408
· PointMark → `ember 10s` — :412
· PlayersMark → `breathSoft 19s` — :414
· ArriveMark → `glyphBreath 15s` — :418
The keyframes are also three different curves and three different amplitude bands: `breathSoft` :360 = opacity .5→.92, no scale; `ember` :361 = opacity .55→1 PLUS scale .96→1.07; `glyphBreath` :363 = opacity .44→.95 PLUS scale .985→1.03. 13/17/19/21/26 are pairwise coprime-ish and never re-align inside a session — that is the point of the run.

**App** — ONE expression for all seven, at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:76:

    .opacity(0.55 + 0.4 * breath.eased(offset: Double(i) * 0.09))

applied uniformly to `TurnMark(id: row.id, ...)` (:74) inside the `ForEach` over rows (:69). `Breath.period` is a hard `10.0` (Instrument/Breath.swift:19) and `eased(offset:)` (Breath.swift:118-121) adds `offset` to the PHASE only — `(1 - cos((phase + offset) * 2π)) / 2` — so `offset` cannot change a period. Per member:
· RoomsMark 17s → 10s
· ArchiveMark 21s → 10s
· UniverseMark 26s → 10s
· LightMark 13s → 10s
· PointMark 10s → 10s (the one that survives)
· PlayersMark 19s → 10s
· ArriveMark 15s → 10s
`TurnRow` (:23-32) carries id/name/sub/glyph/hex/dest/unmetOnly — there is no period field for a per-row constant to live in. `TurnMark` itself (:106-157) draws shape only; it holds no animation. This is the sole site: `grep eased(offset` returns exactly two app call sites, and only :76 is the turn.

**Comment** — NONE in the strict form — no comment in TurnOverlay.swift cites ANY design line number for the marks, so there is no wrong-sibling citation for `check_citations` to pass. The fault is the adjacent one, and it is what sells the port:

:72-73 — "// each row's mark drawn in its own hand — a small composition, / // not a shared glyph set (comp A Strange Feed.html turn marks)."

That is the design's own justifying sentence, lifted from :392 — "the marks. Each surface is drawn in its own hand — no shared glyph set" — and narrowed to the SHAPES. In the design the hand includes the period; the seven p

**Evidence** — Variant is COLLAPSED, and it is the exact failure the group's `whySiblings` predicted — "a port that lifts breathSoft once collapses 13s/17s/19s/21s/26s into one" — except the app went one step further and collapsed the other two keyframes in too, so all SEVEN share a period.

Which number survived is the tell. The app's `Breath.period` is `10.0` and PointMark's design value is `ember 10s` — the single member whose period is not `breathSoft`. The one row that was supposed to be different from the other six (a particle, `ember`, with scale) is the one whose constant now governs all of them. Right number, wrong siblings — six of them.

The amplitude carries the same fingerprint. App range is 0.55 → 0.95:
· floor 0.55 = `ember`'s floor (:361), not `breathSoft`'s .5 and not `glyphBreath`'s .44
· ceiling 0.95 = `glyphBreath`'s peak (:363), not `breathSoft`'s .92 and not `ember`'s 1.0
A band a

**Refutation** — QUOTES ALL CHECK OUT. Design: /Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html — RoomsMark `breathSoft 17s` :395, ArchiveMark `21s` :399, UniverseMark `26s` :404, LightMark `13s` :408, PointMark `ember 10s` :412, PlayersMark `19s` :414, ArriveMark `glyphBreath 15s` :418; keyframes `breathSoft` .5→.92 :360, `ember` .55/scale.96→1/1.07 :361, `glyphBreath` .44/.985→.95/1.03 :363. App: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:76 is exactly `.opacity(0.55 + 0.4 * breath.eased(offset: Double(i) * 0.09))`; TurnMark (:106-157) is a shape-only Canvas with no animation and no scale; Breath.period = 10.0 (Instrument/Breath.swift:19-20); `eased(offset:)` (:118-121) adds to PHASE only. So yes — seven design periods render on one 10s clock. That much 

### COLLAPSED — `canon-light-hex-vs-pool` · rows `E1.1`, `E1.17`

**Design** — Both constants sit on ONE line — `canon/spine-light.js:100`: `SCENES:SCENES, ORDER:ORDER, hex:'#EDE3CE', pool:'#FBF9F4',`

· **L.hex → `#EDE3CE`** — the sky-light/dawn material. Bound at `:187` as `c=hx(this.hex)`.
· **L.pool → `#FBF9F4`** — the stone/nave material. Bound at `:187` as `pc=hx(this.pool)`.

The distinction is exercised by `draw()` (`:186-202`), which renders the six presences. `:191` sets the discriminator `var far=(h.k==='floor');` and the two constants are then selected by it at three sites:
· `:196` `gg.addColorStop(0,rgba(far?pc:c,al*0.55));gg.addColorStop(1,rgba(far?pc:c,0));`
· `:199` `x.fillStyle=rgba(far?pc:c,al);x.fill();`
· `:202` (far only, the seam) `x.strokeStyle=rgba(pc,al*0.30);x.lineWidth=0.7;x.stroke();` under the design's own comment `/* the Far one is a seam, not a star — stone, below */`
· `:239` `fg.addColorStop(0,rgba(pc,A*0.18*p));` — the floor scene's glow, pool again.

`far` also drives alpha (`:193` `al=a*(sel?0.95:(far?0.40:0.62))`) and radius (`:194`, `:195`) — so material colour is one of three things `far` switches, and the only one carrying a named constant.

**App** — **The port of `draw()`'s six presences is `choosingBody`, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:221-262`.** It is unmistakably this mechanism: it calls `LightPlaces.place(W,H,t)` at `:226`, breathes each point at `:232`, and ports the discriminator faithfully at `:231`:

    let far = sc.material == .nave

(`LightCanon.swift:225` — `key: "floor", title: "The floor", material: .nave` — so `far` selects exactly the design's `h.k==='floor'`.)

`far`'s alpha consequence is ported (`far ? 0.55 : 0.85`) and its radius consequence is ported (`far ? 17 : 13`, `far ? 34 : 26`). **But at the one place `far` selects the MATERIAL, it selects nothing** — `:245-247`:

    colors: [Color(hex: "#F5F0E8").opacity((far ? 0.55 : 0.85) * br * (armed == i ? 1.25 : 1)),
             Color(hex: "#EDE3CE").opacity(0)],
    center: .center, startRadius: 0, endRadius: far ? 17 : 13))

One colour for both members where the design has two — and `#F5F0E8` is **neither**. I grepped it across `Claude Design Round 1/`, `Claude Design Round 2/` and `canon/`: zero hits. It is app-invented. (Stop 1 is `#EDE3CE` at `.opacity(0)` — hex on both branches, at zero alpha, so it tints nothing.) The far seam of `:202` has **no port at all** in `choosingBody`.

**The only app site that car

**Comment** — Not the known instance's exact shape — `hex` and `pool` share `:100`, so a cross-citation *between the two members* is impossible. But the same family is present, and it is what licensed the collapse: **a correct citation of the wrong FUNCTION, used to justify dropping the constants.**

`LightView.swift:216-220`, directly above the collapsed site:

> "Geometry is canon (`LightPlaces`, `spine-light.js:104-121`): five drifting in the open sky, the Far one low where a floor would be, hit radius 30. **The LOOK is the app's — no comp draws these** — so it is the register's own idiom and nothing mor

**Evidence** — READ-ONLY sweep; no edits made.

Design, verified by direct read:
· `/Users/ashrey/Bindu Feed/canon/spine-light.js:100` — both constants, one line.
· `:187` `var i,h,pts=this.place(W,H,t), c=hx(this.hex), pc=hx(this.pool);`
· `:191` `var far=(h.k==='floor');`
· `:196`, `:199` — `far?pc:c`; `:202`, `:239` — `pc` alone.
· `grep -n "hex\|pool\|EDE3CE\|FBF9F4"` over the design file returns exactly two lines (`:100`, `:187`) — the constants have no other definition site.

App, verified by direct read:
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:231` — `far` ported correctly.
· `:245-247` — both branches `#F5F0E8`; the collapse.
· `:790` — the correct pairing; `:148` — its sole call site, `material: .dawn` hardcoded inside `case .dawn:`, making the `#FBF9F4` branch unreachable.
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Light/LightCanon.swift:10` `enum Ligh

**Refutation** — I tried to break this five ways and it survived all five.

QUOTES ARE EXACT. `canon/spine-light.js:100` reads verbatim `SCENES:SCENES, ORDER:ORDER, hex:'#EDE3CE', pool:'#FBF9F4',`. `:187` binds `c=hx(this.hex), pc=hx(this.pool)`; `:191` `var far=(h.k==='floor');`; `:196` and `:199` select `far?pc:c`; `:202` and `:239` use `pc` alone. `grep -n "hex\|pool\|EDE3CE\|FBF9F4"` over the file returns exactly `:100` and `:187` — no other definition site. App: `LightView.swift:231` `let far = sc.material == .nave`; `:245-247` both gradient stops read as quoted, `#F5F0E8` on the live stop and `#EDE3CE` at `.opacity(0)`; `:790` `let hex = material == .dawn ? "#EDE3CE" : "#FBF9F4"`.

SIBLINGHOOD IS CANON, NOT PROXIMITY. This was the failure mode I most wanted to find (a false pair sends someone to swap

### COLLAPSED — `chrome-layer-fade-duration` · rows `C1.3`, `C5.12`, `C7.8`, `D2.1`

**Design** — All five verified by direct read of `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html`:

· `#ground` → `transition:opacity 1.1s ease` — :4358 (gated `groundEl.classList.toggle('on',Math.abs(Z)<0.42)` at :5618; `#ground.on{opacity:1}` :4362)
· `#seam`  → `transition:opacity 1.2s ease` — :4387 (gated `|Z|<0.30 && GR.weather==='met'` at :5619; `#seam.on` :4388)
· `#gate`  → `transition:opacity 1.2s ease` — :4423 (gated `Math.abs(Z-1)<0.40` at :5620; `#gate.on` :4424)
· `#door`  → `transition:opacity 1.4s ease` — :4429 (gated `doorEl.classList.toggle('on',!!d)` in `paintDoors()` :5103-5110; `#door.on` :4430)
· `#carry` → `transition:opacity 1.5s ease` — :4623 (gated `if(IMM.on&&given(IMM.mod)>=4)carryEl.classList.add('on')` :5510; `#carry.on` :4624)

Note for the `#carry` comparison below: the design's 1.5s governs the LAYER's own opacity only. `#carry.done b{opacity:.35;border-color:transparent}` (:4627) is a CHILD rule with no transition of its own, so the design's done-dim is INSTANT.

**App** — · `#ground` → NO duration. The Feed register is `AxisFeedSeam` (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:1011-1019`), mounted by the `content` switch at `:941-942`, faded by the shared `.opacity(contentOpacity * worldLayer)` at `:179`. `contentOpacity` is `Axis.presence` (`Instrument/AxisModel.swift:177-179`, `1.30 - |(z+5) - i| * 1.30`) — a continuous function of z with no time constant. (The app's own Door screen, `Screens/DoorView.swift`, crossfades at `.easeInOut(duration: 1.0)` — `App/ContentCoordinator.swift:70` — a different object, and 1.0 not 1.1.)

· `#seam` → `Instrument/InstrumentView.swift:507` — `.animation(.easeInOut(duration: 1.2), value: on)` on `axisSeam` (`:494-509`). Its own constant, on its own element.

· `#gate` → NO duration. `PointGateView` (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointDeals.swift:30-53`) carries no `.animation`, no `.transition`, no opacity state; aliased `AxisGateView` at `Instrument/InstrumentView.swift:1004` and mounted at `:921` — same shared `contentOpacity` ramp as `#ground`.

· `#door` → NO PORT AT ALL. `grep -i "doorsAt|paintDoors|ceremony door|curDoor|CeremonyDoor"` over the app source → 0 hits. There is no ceremony-door layer in the instrument; the ceremony crossings live in 

**Comment** — NONE — I read the comment above every located app site and no comment on one member cites another member's design line. All citations are to their own element:
· seam, `InstrumentView.swift:482,487-489`: *"`The Instrument v3.html:4653-4656`, gated at `:5619`"* and *"`:4385-4389` … and a 1.2s opacity transition"* — 4653-4656 is `#seam`'s own markup, 5619 is `#seam`'s own toggle, 4385-4389 is `#seam`'s own rule. Verified all three.
· gate, `PointDeals.swift:25`: *"`#gate` at `The Instrument v3.html:4423-4426`"* — its own range.
· carry, `PointWorldView.swift:80`: *"`The Instrument v3.html:4682` 

**Evidence** — THE GROUP'S FIVE GRADED DURATIONS SURVIVE AS ONE MATCH, ONE MIS-TARGET, AND A SHARED RAMP.

1. COLLAPSED — `#ground` (1.1s) and `#gate` (1.2s). The design gives each its own `.on` toggle and its own CSS duration (`:5618` `|Z|<0.42`, `:5620` `|Z-1|<0.40`). The app mounts BOTH through the same `content` switch (`InstrumentView.swift:897-948`) and fades BOTH through the same expression at `:179`, `.opacity(contentOpacity * worldLayer)`, where `contentOpacity` (`:132-138`) resolves to `Axis.presence` — `1.30 - |(z+5) - i| * 1.30` (`AxisModel.swift:177-179`). One shared, duration-free, z-driven ramp where the design distinguishes two layers by a tenth of a second. This is exactly the shape `whySiblings` warns about, arrived at from the other side: not "the chrome fades in 1.2s" but "the chrome fades with z", which loses the same distinctions.

2. NOT-PORTED — `#door` (1.4s). No ceremony-door 

**Refutation** — Survives attack. All five design lines verified verbatim (#ground 1.1s :4358, #seam 1.2s :4387, #gate 1.2s :4423, #door 1.4s :4429, #carry 1.5s :4623), as are the gates at :5618-5620, :5109, :5510 and the untransitioned child rule #carry.done b at :4627. The collapse is structural, not inferred: grep of ".animation(" over InstrumentView.swift returns only :507, :569, :570, :626, :683 — none on `content` — so AxisFeedSeam (:1011-1019, mounted :941-942) and PointGateView (aliased AxisGateView :1004, mounted :921; the struct at PointDeals.swift:30-53 carries no animation, transition or opacity state) both fade only through `.opacity(contentOpacity * worldLayer)` at :179, i.e. Axis.presence = 1.30 - |(z+5) - i| * 1.30 (AxisModel.swift:177-179), one duration-free z ramp where the design disting

### COLLAPSED — `compose-ready-fade-delay` · rows `F10.3`, `F9.1`

**Design** — Design — `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Ash's Compose.html`

· the writing space → `opacity: ready ? 1 : 0, transition: 'opacity 1.4s ease'` — :191 (the `{!released && (<div …>}` that holds the prompt + textarea, opened :187)
· the hold-to-release control → `opacity: ready ? 1 : 0, transition: 'opacity 1.4s ease 0.2s'` — :227 (the `{!released && (<div …>}` that holds the HoldRing + glyph + hint, opened :223)

In the comp these are SIBLINGS — two separate `!released &&` blocks, both direct children of the phone frame, separated by the `{released && <Released …>}` branch at :220. Same 1.4s ease, one gated 0.2s behind the other: the page he writes on arrives, then the ember he holds arrives after it.

**App** — App — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshComposeView.swift`

· the writing space → `.opacity(ready ? 1 : 0)` at :200, `.animation(.easeOut(duration: 1.4), value: ready)` at :201, closing `writingSurface` (`private var writingSurface` opens :164, VStack :165, closes :198). Its OWN constant is right: 1.4s, no delay.
· the hold-to-release control → **NO app site of its own.** `emberControl` is `private var emberControl: some View` at :211–256; it declares no `ready` gate, no opacity-on-`ready`, no delay. Its only animations are `.animation(.easeOut(duration: 0.6), value: armed)` (:245, the armed dim — design :237's `'opacity 0.6s ease'`, a different property) and the EmberWake/HintFade modifiers.

The structural cause: the app NESTED the control inside the writing space. `emberControl` is reached at :196, inside `writingSurface`'s VStack, so it inherits :200–201 and fades on the identical curve at the identical instant. `ready` itself is set once, `DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { ready = true }` at :100–101 — one flip driving one modifier for both halves.

The `0.22` at :100 is not the port of the 0.2s: it is the arrival gate that fires `ready` for BOTH members (the comp's own pre-roll before either fades), and it lands ahead of the f

**Comment** — NONE — and the absence is itself the tell.

Neither :200 nor :201 nor the `emberControl` block (:211–256) carries any comment about the arrival fade. The file's ONLY citation of the comp is at :213–219, above the ring geometry:

  "// F9.1 · **A RING FLOATING IN ITS TARGET IS AN EMBER TO HOLD; A RING THAT *IS*
   // ITS TARGET IS A BUTTON TO PRESS.** `Claude Design Round 1/comps/Ash's Compose.html:73-83`"

That cites :73-83 for `const R = 31` — a correct citation of the right element for a different property (radius), so it is not the #where/#pname cross-citation shape.

This instance evaded `

**Evidence** — WHY COLLAPSED AND NOT ONE-MISSING: ONE-MISSING presumes two app sites, one of which silently dropped its constant. There are not two sites. The two design siblings were merged into one parent-child relation (`emberControl` at :196 inside `writingSurface`'s VStack, which closes :198 and takes the modifier at :200-201), so both members are driven by a single expression carrying a single value — the definition of COLLAPSED, and the same shape as the rail's `(1 - dom)` for `(1 - dom*0.9)`: a distinction flattened toward a sibling. The missing 0.2s is not merely absent, it is unrepresentable in the structure as built.

WHAT IS LOST: the comp stages the arrival in two beats — the surface he writes on, then 0.2s later the ember he holds. The app raises both on the same frame. The delay is the difference between a room assembling itself in order and a screenshot appearing.

Corroboration that th

**Refutation** — SURVIVES ATTACK. Every claim verified against the files; the strongest refutation avenue is affirmatively closed.

DESIGN LINES EXACT. `Ash's Compose.html:191` = `opacity: ready ? 1 : 0, transition: 'opacity 1.4s ease',`; `:227` = `opacity: ready ? 1 : 0, transition: 'opacity 1.4s ease 0.2s',`. Verified verbatim by grep.

GENUINE SIBLINGS, not adjacent strangers. Both are `!released &&` direct children of the phone frame (openers at :187 and :222), separated only by `{released && <Released …/>}` at :219. Same property, same gate (`ready`), same duration (1.4s ease). The sole difference is the trailing `0.2s`. The false-TRANSPOSED hazard does not apply here — nothing would be swapped; one constant is absent, not misplaced.

THE DECISIVE REFUTATION TEST — AND IT FAILS TO REFUTE. The one thin

### COLLAPSED — `fieldsound-open-vs-close-the-room` · rows `D7.3`, `E4.1`, `G3.1`
*The refutation corrected this from the checker's first verdict.*

**Design** — openTheRoom → default ramp 5s, nave wet gain 0 → 0.85. Sites: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light - S-L01 Dawn.html:244-245 (`openTheRoom:function(dur){ dur=dur||5;`), ramp at :256 (`linearRampToValueAtTime(0.85,t+dur)`). Mirrored verbatim at Claude Design Round 1/field-sound.js:224-225 and Claude Design Round 1/comps/The Light v2.html:269-270.

closeTheRoom → default ramp 6s, same nave wet gain → 0. Sites: .../The Light - S-L01 Dawn.html:258-262 (`closeTheRoom:function(dur){ ... linearRampToValueAtTime(0,t+(dur||6))`). Mirrored at field-sound.js:238-242 and The Light v2.html:283-287.

Third method that matters here, NOT a member: lightOff — field-sound.js:307-312 — ramps `this.lightNode.g.gain` (the 528+792 room TONE oscillators) to 0 over `dur||5` and stops the oscillators. Different node, different signal path, its own default of 5.

Design call sites (The Light v2.html): `:637 Sound.openTheRoom(8.5); Sound.breathIn(6);` and `:801 const leave=()=>{Sound.closeTheRoom(6);Sound.darkReturns();onLeave();}`. `darkReturns` (field-sound.js:315-322) calls `this.lightOff(5)` and never touches the nave — so on leave the design runs TWO independent fades: nave→0 over 6, tone→0 over 5.

**App** — openTheRoom → PORTED, with the wrong constant as its default.
/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1180 — `func lightOpenTheRoom(dur: Double = 8.5)`; ramps `room.wetDryMix` to 85.0 over `dur` (:1185-1188) after `room.loadFactoryPreset(.cathedral)` (:1182). The design's default 5 appears nowhere on this function. 8.5 is the Light's CALL-SITE argument (`The Light v2.html:637`), hoisted into the signature as the default.
Sole app call site: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:573 — `soundEngine.lightOpenTheRoom(dur: 8.5)`.

closeTheRoom → NO PORT. `grep -rn "closeTheRoom" --include="*.swift"` returns only comments and a test header; there is no `lightCloseTheRoom`, and nothing in the app ramps the nave wet to 0 on leave. Every `wetDryMix` write in the app is at SoundEngine.swift:432, 441-442, 1188, 1231, 1345 — none of them is a leave-time ramp to zero: `lightVeilLift` (:1231) returns it to 50 (that is the port of a DIFFERENT design method, `veilLift`), and `darkReturns` (:1339-1345) returns it to 50 over 7s (the design's `darkReturns` does not touch the nave at all).

What the app calls "closeTheRoom": /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:412 — `soundEngine.lightOff(dur: 6)`. `lig

**Comment** — YES — and it is the same shape as the `#where`/`#pname` instance, one level up: a comment on member A citing a different design method's line as if it were A's own.

/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:400-411, above `soundEngine.lightOff(dur: 6)`:

  // `The Light v2.html:801` — `const leave = () => {
  // Sound.closeTheRoom(6); Sound.darkReturns(); onLeave(); }`.
  // This called no sound at all, so the bed `lightVeilLift`
  // drained never came back. *AUDIT E4.1 / G3.1.*
  //
  // `closeTheRoom(6)` is the FIRST half and was still missing after
  // that f

**Evidence** — THE PAIRING, MEASURED

Design: open = 5, close = 6, and the closing is deliberately the slower one.
App:    open = 8.5 (default) with the sole call site also 8.5; close = does not exist; the number 6 is on `lightOff`, whose own design default is 5.

So the fault is crossed rather than swapped, which is why neither `check_citations` nor a value grep sees it: the surviving MECHANISM is open's, the surviving CONSTANT is close's, and they are not on the same function.

CONSEQUENCE, at the leave.

Design leave (The Light v2.html:801) runs two independent fades — nave 0.85→0 over 6s, and via `darkReturns`, the 528 tone →0 over 5s.
App leave (LightView.swift:412-413) runs `lightOff(dur: 6)` then `darkReturns()`. The tone fades over 6 instead of 5 (close's constant, on the wrong fade). The cathedral wet is not ramped to zero by anything; `darkReturns` (SoundEngine.swift:1331-1350) takes `wetDryM

**Refutation** — Citations all verify (design 5/6 at S-L01 Dawn:245/262, mirrored verbatim in field-sound.js:225/242 and The Light v2:270/287; app lightOpenTheRoom default 8.5 at SoundEngine.swift:1180; lightOff(dur: 6) at LightView.swift:412; the audit rows and the 25-name sweep row read as quoted). But the finding's load-bearing claim — "closeTheRoom NO PORT; nothing ramps the nave wet to 0 on leave" — is refuted by the app's reverb architecture. The app has no separate nave node: SoundEngine.swift:429-435 builds ONE AVAudioUnitReverb whose baseline is .mediumRoom / wetDryMix = 50, annotated `// wet.gain = 0.5` — that is the port of the design's BASE AIR convolver (field-sound.js:39-41). The design's nave is an ADDITIVE second convolver 0 -> 0.85 raised on that air; the app collapses both into the one re

### COLLAPSED — `gameview-crossfade-out-vs-in` · rows `B4.3`, `F4.1`, `F4.2`, `F4.3`
*The refutation corrected this from the checker's first verdict.*

**Design** — Design, `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Game View.html` — one ternary and the timeout that feeds it:
· fade OUT (while `fading`) → `'opacity 0.28s ease'` — :591, the true half of `fading?…:…`
· fade IN (after the swap) → `'opacity 0.4s ease'` — :591, the false half of the same ternary
· swap timer that must equal the out-half → `}, 280);` — :581
Verbatim :591: `<div style={{opacity:fading?0:1,transition:fading?'opacity 0.28s ease':'opacity 0.4s ease'}}>`
The design distinguishes the halves: out is faster than in (0.28 vs 0.4), and only the out-half is pinned to the timer.

**App** — Port is `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift`, `stepRoom(by:)` plus the four faded subtrees. Renaming: `fading` → `heroVisible` (inverted), the `<div>` wrapper → four separate `.opacity(heroVisible ? 1 : 0)` sites.
· fade OUT → `withAnimation(.easeInOut(duration: 0.28)) { heroVisible = false }` — GameView.swift:431-433. Carries its own member's constant. MATCHED (easing aside).
· fade IN → `withAnimation(.easeInOut(duration: 0.28)) { heroVisible = true }` — GameView.swift:437-439. Carries the OUT-half's 0.28, not its own 0.4.
· swap timer → `DispatchQueue.main.asyncAfter(deadline: .now() + 0.28)` — GameView.swift:434. Equals the out-fade, as the design requires. MATCHED.
Plus four scoped modifiers that repeat the out constant onto every faded subtree: `.animation(.easeInOut(duration: 0.28), value: currentRoom.id)` at GameView.swift:45 (hero background), :55 (hero), :61 (statsBar), :81 (storyFeed).
`grep -n "0\.4"` in GameView.swift returns no crossfade site: the in-half's constant exists nowhere in the file. Six sites, one number.

**Comment** — NONE. No comment at any of the six app sites cites a design line, so there is no wrong-sibling citation here — the opposite failure: the constants are wholly uncited, which is why `check_citations` has nothing to check and nothing to catch.
The two comments that do sit above the sites both describe the crossfade as symmetric and so document the collapse rather than flag it:
· GameView.swift:430 — `// Cross-dissolve: fade body out, swap room, fade back in.`
· GameView.swift:4-7 — `// PHASE 6 — Game View. … room-to-room is a cross-dissolve, not a slide.`
The nearest citation, GameView.swift:38-4

**Evidence** — WHY COLLAPSED AND NOT TRANSPOSED: neither half holds the other's number — both hold the out-half's. The design's asymmetry (leave quickly, arrive slowly) is gone; the app's cross-dissolve is symmetric, so the room arrives as fast as the last one left, and the two motions read as one linear wipe rather than a departure and a settling. This is the rail variant from the brief: two halves given the SAME value where the design distinguishes them.

WHY IT SURVIVES EVERY CHECKER: `0.28` is the design's own number, present at :591, so a value-grep for the design constant hits and passes. The timer at :434 genuinely matches the out-half, so the one relationship the design states out loud ("the timeout has to equal the out-half") holds — a reader verifying the stated invariant finds it true and stops. And with six sites all reading `duration: 0.28`, internal consistency looks deliberate.

THE PROP

**Refutation** — The code shape is genuinely COLLAPSED — I verified every quoted line — but the finding does not survive as a finding, because this is a RECORDED divergence, not a blind spot, and its central evidence claim is demonstrably false.

VERIFIED AS QUOTED. Design `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Game View.html:581` (`}, 280);`) and `:591` (`transition:fading?'opacity 0.28s ease':'opacity 0.4s ease'`) read exactly as claimed. App `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift` reads as quoted at :45, :55, :61, :81 (four scoped `.animation(.easeInOut(duration: 0.28), value: currentRoom.id)`), :431, :434, :437. `grep "0\.4"` in GameView.swift returns only `.tracking(0.4)` (:198) and gradient stop locations (:375-400) — no crossfade site. So the app is 0.2

### COLLAPSED — `gameview-per-room-glow` · rows `F3.4`, `F4.3`

**Design** — All five members are `gFilter` on one object literal per room in `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Game View.html`, blur px + hex alpha both distinct per room (hex/255 in parens):
· maya — `drop-shadow(0 0 22px ${c}65)` → blur 22, α 0.396 — :406
· watcher — `drop-shadow(0 0 14px ${c}50)` → blur 14, α 0.314 — :410
· descent — `drop-shadow(0 0 30px ${c}90) drop-shadow(0 0 8px ${c}60)` → blur 30, α 0.565 PLUS a second layer blur 8, α 0.376 — :412 (the only two-layer member)
· forgetting — `drop-shadow(0 0 12px ${c}40)` → blur 12, α 0.251 — :416
· field — `drop-shadow(0 0 28px ${c}70)` → blur 28, α 0.439 — :430
Design ordering by blur: descent 30 > field 28 > maya 22 > watcher 14 > forgetting 12. Note watcher and forgetting share the SAME glyphSize (52) and are separated ONLY by gFilter (14/50 vs 12/40) — they are the pair that proves the property is authored independently of size.

**App** — There is no per-member port. All five collapse into ONE formula plus TWO universal alphas.

Single call site, all thirteen rooms: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift:167`
  `glow: style.heroGlyph * 0.30           // the hero glow reads strong`
Renderer: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:60,67,68`
  `private var glowRadius: CGFloat { glow ?? size * 0.20 }`
  `.shadow(color: color.opacity(0.55), radius: glowRadius)`
  `.shadow(color: color.opacity(0.35), radius: glowRadius * 0.4)`

Resolved per member (radius from `RoomStyle.forRoom` heroGlyph × 0.30; alpha fixed):
· maya      heroGlyph 70 → r 21.0, α 0.55 (+ r 8.40, α 0.35)   design: 22 / 0.396
· watcher   heroGlyph 52 → r 15.6, α 0.55 (+ r 6.24, α 0.35)   design: 14 / 0.314
· descent   heroGlyph 44 → r 13.2, α 0.55 (+ r 5.28, α 0.35)   design: 30 / 0.565 + 8 / 0.376
· forgetting heroGlyph 52 → r 15.6, α 0.55 (+ r 6.24, α 0.35)  design: 12 / 0.251
· field     heroGlyph 68 → r 20.4, α 0.55 (+ r 8.16, α 0.35)   design: 28 / 0.439

THREE distinct faults fall out of the one substitution:
1. COLLAPSED (the textbook case) — watcher and forgetting get byte-identical glows (15.6 / 0.55 / 6.24 / 0.35) because their heroGlyph is identical, where the design distingui

**Comment** — YES — and it is the same shape as the `#where`/`#pname` instance: a correct quotation of ONE member used to license every sibling.

`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:48`
  `/// The coloured halo every glyph floats in (comp: ` + backtick + `drop-shadow(0 0 …px color65)` + backtick + `).`

`65` is MAYA's alpha (`Game View.html:406`), also Signal's. It is quoted verbatim as the documentation for the halo of *every glyph in the app* — including watcher (50), descent (90), forgetting (40) and field (70). The blur is elided to `…px`, which is the tell in plai

**Evidence** — The codebase demonstrates, twelve lines away, that it knew how to port this:

`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift:362-364`
  `// Each room's distinct hero atmosphere (comp Game View.html gradient fns). Radial ellipses`
  `// → EllipticalGradient at the comp's centre; linear washes → LinearGradient in the comp's`
  `// direction; alphas are the comp's hex/255. Maya layers three; the Forgetting inverts.`

and `:370` — maya's `${c}28` lands as `(0.157, 0)` (0x28/255 = 0.1569). Thirteen rooms of per-room gradient constants converted hex→float by hand, each in its own `case`.

`gradient` and `gFilter` are adjacent fields on the same object literal, on the same design lines. One got thirteen hand-ported cases with the hex/255 rule written out in a comment. The other got `heroGlyph * 0.30` and a flat 0.55. The per-room machinery exists (`RoomStyle.forRoom`, th

**Refutation** — Survives attack. All five design literals verified byte-identical at Game View.html:406/410/412/416/430, including descent's unique two-layer shadow. Comp :540 (GameHero) applies gFilter to the hero glyph — the same element GameView.swift's `hero` renders, so this is one property on one sibling set, not near-neighbour confusion. App sites exact: GameView.swift:167 `glow: style.heroGlyph * 0.30`, GlyphAnimation.swift:60 `glow ?? size * 0.20`, :67-68 the two fixed alphas 0.55/0.35; RoomStyle carries no glow field; `glow:` is passed at exactly two sites app-wide (GameView:167, RiteView:161); the five design alphas grep to zero hits in Swift. Refutations all fail: (1) no superseding source — both archive copies of Game View.html carry byte-identical gFilters, Round 2 has no Game View successor

### COLLAPSED — `ground-caption-tracking` · rows `E1.18`, `F0.1`, `F11.2`, `F4.2`, `F7.3`

**Design** — Three Space Mono captions on the Door/ground, all corroborated by two further sources so the trio is not a single-file reading:

· `#ground .label` → `font-size:10px; letter-spacing:.24em` (= 2.4pt)
  /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4369
  corroborated: A Strange Feed.html:638 (`fontSize:10, letterSpacing:'0.24em'`); Claude Design Round 2/design-source/Practice Door.html:251-252

· `#ground .cx` → `font-size:10px; letter-spacing:.06em` (= 0.6pt) — the outlier, data not label, and the only one with NO `text-transform`
  /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4378
  corroborated: Practice Door.html:140 (`fontSize:10 … letterSpacing:'0.06em'`)

· `#ground .base` → `font-size:9px; letter-spacing:.18em` (= 1.62pt), uppercase
  /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4379-4380
  corroborated: A Strange Feed.html:644-645 (one element, both weathers — `weather==='unmet'?'touch to receive':'tap anywhere to cross'`); Practice Door.html:270-271

**App** — The ground's met weather is ported whole as PracticeDoorView (DoorView.swift:100-103: `case .met: PracticeDoorView(...)`). All three members live there.

· `.label` → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:121-122
    `.spaceMonoTracked(10)` / `.tracking(2.4)`
· `.cx`    → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:245-246
    `.spaceMonoTracked(10)` / `.tracking(0.6)`
· `.base`  → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:254-255
    `Text("TAP TO CROSS")` `.spaceMonoTracked(9)` / `.tracking(1.6)`
  and a SECOND port of the same design element, the unmet half:
  /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:131-132
    `Text("touch to receive")` `.spaceMonoTracked(9, em: 2 / 9)` → 2.0pt = .222em

Written as numerals the three read 2.4 / 0.6 / 1.6 — each its own member's constant (`.base` rounded, 1.6 vs 1.62). The transposition test passes. The RENDERED pairing does not, because of the call shape:

/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151-152
    `func spaceMonoTracked(_ size: CGFloat, em: CGFloat = 0) -> some View {
        self.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size) }`

`em` defaults to 0,

**Comment** — NONE — and the absence is itself the reason this survived. There is no comment above any of the three app sites: PracticeDoorView.swift:118-124 (label), :243-248 (cx), :252-257 (base) carry no design citation at all, so there is nothing for `check_citations` to verify and nothing to be caught mis-citing.

The one nearby citation is CORRECT and points at a different element — PracticeDoorView.swift:178-180: "Practice Door.html:146,155-159 — the sub-line is the last child of the SAME centred stack…", governing the `.practice` sub-line at :186 (`.tracking(0.7)  // 0.05em x 14`), which does the em

**Evidence** — WHAT IS ACTUALLY WRONG, in order of confidence.

1. COLLAPSED (primary). All three members render at tracking 0.
   PracticeDoorView.swift:121-122, :245-246, :254-255 each chain `.spaceMonoTracked(N)` (em defaults to 0 → `.tracking(0)` planted directly on the Text at Theme.swift:152) with an outer `.tracking(...)`. The inner wins; the outer is dead. This is not my inference — Coverage/1-AUDIT-254.md:353 (F4.2, CLOSED 2026-08-31) states it as the project's own finding and fixed one instance by collapsing to `spaceMonoTracked(8, em: 0.07)`. The design's distinction — the wide .24em chrome label, the tight .06em codex, the .18em base line — is erased to a single flat value. The correct-looking numerals 2.4 / 0.6 / 1.6 are why every string checker passes: they are present, they are each on the right sibling, and they do nothing.
   Correct form: `.spaceMonoTracked(10, em: 0.24)` · `.spaceMon

**Refutation** — Survives every attack. DESIGN: all three lines read exactly as quoted — The Instrument v3.html:4369 (.label 10px/.24em/uppercase), :4378 (.cx 10px/.06em, no text-transform), :4379-4380 (.base 9px/.18em/uppercase). Corroboration verified independently in two further sources: A Strange Feed.html:638 (0.24em) and :644-645 (9/0.18em/uppercase, one span switched by weather), Practice Door.html:251-252 (0.24em, hexA(accent,0.66) matching the app's accent.opacity(0.66)), :140 (0.06em on s.codex, no transform), :270-271 (0.18em, "tap to cross"). SIBLINGS ARE REAL, not neighbours: #ground .cx is used at The Instrument v3.html:1645 as '<span class="cx">'+s.codex+'</span>' — the same datum the app renders as story.codexId; #ground .base is ONE element (gbase, :4651) whose text is swapped at :5008/:50

### COLLAPSED — `ground-headline-sizes` · rows `F11.2`
*The refutation corrected this from the checker's first verdict.*

**Design** — Three sizes, one block, ten lines apart, all Lora/centred:
· `#ground h1` → `font-size:27px` (weight 400, line-height 1.46, letter-spacing -.006em, max-width 300, text-wrap balance) — `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4367`. Content at `:5006`: `'<h1>One story has come to meet you.</h1>'` — the UNMET weather.
· `#ground .say` → `font-size:26px` (line-height 1.5, max-width 300, balance; `.say.it` adds italic at `:4371`) — `…/The Instrument v3.html:4370`. Content from `bodyHTML()` at `:1647` — the MET weather's four prose kinds.
· `#ground .found h2` → `font-size:25px` (weight 500, line-height 1.3, letter-spacing -.012em, text-wrap pretty) — `…/The Instrument v3.html:4376`. Content from `bodyHTML()` at `:1641-1644` — the MET weather's `story` kind.
The descent is CORROBORATED IN A SECOND, INDEPENDENT SOURCE. `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Practice Door.html` draws the same two met-weather voices with the same numbers: `:151` `fontSize: 26, lineHeight: 1.5` for the body, `:133` `fontWeight: 500, fontSize: 25, lineHeight: 1.3` + `:134` `letterSpacing:'-0.012em'` for the story title. And `/Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:632` draws the h1 sentence at `fontSize:27, lineHeight:1.46, let

**App** — App source root `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed`. The block's two weathers are `DoorView.swift` (unmet) and `PracticeDoorView.swift` (met, reached from `DoorView.swift:101-104`).
· `#ground h1` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:120-121` — `Text(RiteWord.arrivalMeeting)` `.font(.lora(15)).italic()`. **15, not 27.** 15-italic is `The Rite v3.html:1293`'s constant for the same sentence on a DIFFERENT surface (the Rite's Movement I). The largest serif in the app's unmet block is instead `Screens/DoorView.swift:122-123` — `Text(storyData.title).font(.lora(24, weight: .medium))` — an element `#ground`'s unmet weather does not contain at all. 27 appears nowhere in the app for this block.
· `#ground .say` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:202-209`, font at **`:204`** — `.font(italic ? .loraItalic(22) : .lora(22, weight: .medium))`. **22, not 26.** (Called from `:175`, `:182`, `:194` — threshold, practice, gaiaSeed.) The italic/weight-500 fork IS the design's (`Practice Door.html:149-150`), so the porter was reading `:147-154` and took every constant on it except `:151`'s size.
· `#ground .found h2` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:220-234`,

**Comment** — Not the known instance's exact shape (no comment cites a sibling ELEMENT's line), but the same effect by a different route — a correct citation that lands a checkable number on the wrong PROPERTY. `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:178-181`, the comment directly above the `proseBody` call:

    // Practice Door.html:146,155-159 — the sub-line is the last child of the
    // SAME centred stack as the body, at the container's own gap of 22, so it
    // rises with the body on the shared fade rather than on a timer of its own.

Every part of that is tru

**Evidence** — VERDICT — COLLAPSED, with the third member absent at its own value.

The two met-weather members are given the SAME number where the design distinguishes them: `PracticeDoorView.swift:204` = 22 and `PracticeDoorView.swift:227` = 22, against 26 (`:4370`) and 25 (`:4376`). The `whySiblings` prediction — *"a deliberate one-point descent that any port would flatten to a single heading size"* — is exactly what happened, and the flattening also swallowed the third: `#ground h1`'s 27 is nowhere, its sentence rendered at 15 italic (`DoorView.swift:121`), a value borrowed from the same sentence's appearance on a different surface (`The Rite v3.html:1293`).

WHY 22 IS A HOUSE DEFAULT, NOT A READING OF ANY DESIGN. `Screens/MirrorView.swift:305` writes the identical expression — `.font(isKoan ? .loraItalic(22) : .lora(22, weight: .medium))` — for the Mirror's card body, where `Claude Design Round 2/

**Refutation** — Two of three members hold; the third is a MISPAIRING backed by an explicit design instruction, so the finding as written does not survive.

SURVIVES (the real defect): #ground .say 26 (The Instrument v3.html:4370) and #ground .found h2 25 (:4376) both render 22 — PracticeDoorView.swift:204 and :227. Genuine collapse. Confirmed unrefutable: (a) Round 2's design-source/The Instrument v3.html is BYTE-IDENTICAL to Round 1 (diff -q → IDENTICAL), so no later round supersedes 26/25; (b) Practice Door.html:151 (26) and :133-134 (25 + -0.012em) corroborate independently; (c) no scale factor — Theme.swift:65-71 lora() is plain .custom(name, size:), and the same block ports glyph 30→30 (DoorView.swift:119) and sub 14→14 (PracticeDoorView.swift:185 ← Practice Door.html:157) exactly; (d) no recorded di

### COLLAPSED — `mirror-breath-keyframe-floors` · rows `A1.5`, `A1.6`, `D7.6`

**Design** — All three keyframes sit in one adjacent block in `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Mirror.html`:

· mirrorBreath (the terra wash) → floor 0.40, peak 0.72 (amplitude 0.32) — :32-35
· emberPulse (the Bindu draw) → floor 0.55, peak **1.0**; scale 0.96 → 1.07 — :36-39
· hintFade (the caption) → floor 0.26, peak **0.58** (amplitude 0.32) — :40

Design call sites, to fix which body is which: mirrorBreath on the radial terra warmth (`:212-218`, comment *"the held terra warmth — its own light, breathing slowly"*); emberPulse on the 30px ember `·` inside the draw button (`:285-289`); hintFade on the mono caption directly BELOW that button (`:292-297`, `drawn ? 'none' : 'hintFade 5s ...'`, text `draw once more` / `drawn · return tomorrow`).

The design deliberately separates the last two: the ember is the single draw and is allowed to reach full 1.0; its caption is chrome and stops at 0.58.

**App** — All three ports are in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift`. The app renames: mirrorBreath → `TerraAtmosphere`, emberPulse → `EmberDot`, hintFade → `BreathingOpacity` applied to the DRAW ONCE MORE caption. All three read the one master `Breath` and express the keyframe as `floor + amplitude * breath.value`.

1. mirrorBreath → `TerraAtmosphere`, MirrorView.swift:363
   `.opacity(0.40 + 0.32 * breath.value)` → 0.40 … 0.72. **MATCHED.**

2. emberPulse → `EmberDot`, MirrorView.swift:384-385
   `.opacity(0.55 + 0.45 * breath.value)` → 0.55 … 1.0
   `.scaleEffect(0.96 + 0.11 * breath.value)` → 0.96 … 1.07. **MATCHED, both properties.**

3. hintFade → MirrorView.swift:149
   `.modifier(BreathingOpacity(active: !drawn, lo: 0.26, hi: 1.0, duration: 5))`
   evaluated at `:399` as `lo + (hi - lo) * breath.value` → **0.26 … 1.0**, where the design is 0.26 … 0.58.

The floor is its own (0.26, correct). The PEAK is its sibling's: `hi: 1.0` is `emberPulse`'s peak from `The Mirror.html:37`, and the sibling in question is the glyph rendered by `EmberDot` at `:161`, four lines above `:149` in the same `VStack` — the button and its own caption. The design gives them 1.0 and 0.58; the app gives both 1.0. That is the rail's shape exactly: one member blurred onto i

**Comment** — NONE — in the strict sense the known instance had. `MirrorView.swift` contains ZERO design-file citations: `grep -n "Mirror.html\|Round 1\|comps/"` over the file returns nothing, so no comment on any of the three sites cites any design line, right or wrong. There is nothing here for `check_citations` to verify, and nothing for it to have been fooled by.

But the cover exists in a different shape, and it is worth quoting because it is what makes the three look jointly audited. Immediately above the block holding two of the three members, MirrorView.swift:352-354:

  "// All three read the ONE m

**Evidence** — FILES (all absolute):
· Design: `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Mirror.html` — keyframes :32-40, call sites :212-218 (mirrorBreath), :285-289 (emberPulse), :292-297 (hintFade). Byte-identical copy at `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Mirror.html` (same line numbers), so Round 2 does not revise the pairing and cannot be the source of a 1.0.
· App: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift` — :149, :352-354, :355-372, :377-387, :391-401.
· Control: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshComposeView.swift:449-454`.
· Audit: `/Users/ashrey/Bindu Feed/Coverage/1-AUDIT-254.md` — :122-127 (A1.x), :291 (D7.6), :339 (F0.3); `/Users/ashrey/Bindu Feed/AUDIT.md:753` (F0.3 long form).

THE ONE LINE THAT IS WRONG — `MirrorView.swift:149`:

    .modifier(BreathingOpacity(active: !drawn, lo: 0.26

**Refutation** — Survives every refutation attempt. DESIGN verbatim: `Claude Design Round 1/comps/The Mirror.html:32-40` — mirrorBreath 0.40/0.72, emberPulse 0.55/1 + scale 0.96/1.07, hintFade 0.26/0.58; call sites :217, :288, :296 as quoted. The Round 2 copy (`Claude Design Round 2/design-source/The Mirror.html`) and `archive/bindu-feed-phase9-handoff/prototypes/The Mirror.html` are identical at the same line numbers, so no alternate design source supplies a 1.0. APP verbatim: `Bindu Feed/Bindu Feed/Screens/MirrorView.swift:149` `.modifier(BreathingOpacity(active: !drawn, lo: 0.26, hi: 1.0, duration: 5))`; :363 `0.40 + 0.32 * breath.value`; :384-385 `0.55 + 0.45` / `0.96 + 0.11`; :398 `lo + (hi - lo) * breath.value`. RANGE PROVEN: `Breath.swift` tick() sets `value = (1 - cos(p * 2 * .pi)) / 2`, exactly [0

### COLLAPSED — `players-breath-periods` · rows `F7.1`, `F7.3`, `F7.4`, `F7.5`

**Design** — Eleven members, one column of `Players View.html`, applied at `:220` (the ten cards) and `:305` (Ashram):

· Bindu — `playerEmber 3.2s` — `Players View.html:84`
· Gaia — `playerBreath 7.5s` — `:90`
· Sid — `playerBreath 9.2s` — `:95`
· Arch — `playerBreath 6.8s` — `:100`
· Sakshi — `playerBreath 13.5s` — `:105`
· Karishma — `playerBreath 8.5s` — `:110`
· Ashrey — `playerBreath 7.0s` — `:115`
· Lalita — `playerTurn 28s linear` — `:120`
· Neev — `playerBreath 12.0s` — `:131`
· Shweta — `playerBreath 16.5s` — `:136`
· Ashram — `playerBreath 9.0s` — `:147`

Keyframes are this file's own: `playerBreath` `:38`, `playerEmber` `:44`, `playerTurn` `:50`.

THE SIBLING SOURCE THAT DID THE DAMAGE. A SECOND comp, the DETAIL screen, gives the same eleven presences a DIFFERENT set — `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Player Detail - The Turning.html:328-332`:
· lalita → `lTurn 30s`
· neev OR shweta → `glyphBreathSlow 18s` (one value for both — the detail screen shows ONE presence at a time, so it never has to distinguish them)
· ashram → `glyphPulse 2.8s`
· bindu → `glyphEmber 3.2s`
· everyone else → `glyphBreath {13.5 | 7.5 | 9.2 | 6.8 | 8.5 | 7.0}s`

The two comps AGREE on the six mid lenses and disagree on the four edges. The app ported the detail screen's table and drove 

**App** — One table, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/GlyphAnimation.swift:27-40`, read by BOTH screens — the grid at `Screens/PlayersView.swift:322-323` and the detail at `Screens/TheTurningView.swift:184-185`, both `GlyphAnimation.presence(archetype.name)`:

`:29` Bindu → `(.glyphEmber, 3.2)` — MATCHES 3.2s
`:34` Gaia → `(.glyphBreathe, 7.5)` — MATCHES
`:35` Sid → `(.glyphBreathe, 9.2)` — MATCHES
`:36` Arch → `(.glyphBreathe, 6.8)` — MATCHES
`:33` Sakshi → `(.glyphBreathe, 13.5)` — MATCHES
`:37` Karishma → `(.glyphBreathe, 8.5)` — MATCHES
`:38` Ashrey → `default: (.glyphBreathe, 7.0)` — value matches, but by FALLTHROUGH, not by name
`:30` Lalita → `(.glyphCircle, 30)` — design grid says **28s**. 30 is the detail comp's `lTurn 30s`.
`:32` **`case "Neev", "Shweta": return (.glyphBreathSlow, 18)`** — ONE arm, ONE constant, for two members the grid gives **12.0s and 16.5s**. 18 is the detail comp's.
Ashram → NOTHING. `AshramCard` renders a bare `Text(archetype.glyph)` at `Screens/PlayersView.swift:430` — no `GlyphView`, no `animation:`, no `period:`. The design's `playerBreath 9.0s` at `:305` has no port on this screen at all; his glyph is static. (Were it routed through the table, `case "Ash"` `:31` would give `(.glyphPulse, 2.8)` — again the detail comp's value, and th

**Comment** — YES — and it is the same shape as the `#where`/`#pname` instance: every citation is CORRECT about the sibling and wrong about the member.

`Theme/GlyphAnimation.swift:24-26`, the comment that governs the whole table:

  "/// Each presence breathes at its OWN cadence (comp Player Detail) — returns the animation
   /// and its period (seconds), so a gathering of presences never synchronises into one pulse.
   /// Bindu the most alive, Lalita the only turn, the roots the slowest, Ash a heartbeat."

"(comp Player Detail)" is a true citation — of `comps/Player Detail - The Turning.html`, the siblin

**Evidence** — FOUR OF ELEVEN ARE WRONG, AND THEY ARE THE FOUR THE TWO COMPS DISAGREE ON. That is the signature: this is not eleven independent ports with four slips, it is one table lifted from the wrong screen. The six that match are the six where the two comps happen to agree, so they are matched by coincidence of the source, not by having been checked.

1. COLLAPSED (the named risk, realised). `whySiblings` warned that "anything that ports 'playerBreath' as one rule collapses 6.8s through 16.5s into a single rate". `GlyphAnimation.swift:32` is literally that rule: `case "Neev", "Shweta": return (.glyphBreathSlow, 18)`. Neev's 12.0s and Shweta's 16.5s — 4.5 seconds apart, the widest interval in the roots — are one 18. On the Players grid they stand side by side in `rootGrid` and now rise and fall in lockstep. The design's whole claim, restated in the app's own comment at `:25`, is that the field nev

**Refutation** — Survives every refutation route. All eleven design values verified verbatim at the cited lines of Players View.html (:84-147), with :220 the single `animation: player.anim` span serving both the lens grid (:398) and root grid (:419), and Ashram separate at :305. App verified: GlyphAnimation.swift:32 is literally `case "Neev", "Shweta": return (.glyphBreathSlow, 18)` — one constant for two members the grid gives 12.0s and 16.5s, and PlayersView.swift's rootGrid puts them side by side, so the two presences most likely seen together are the two that now pulse in lockstep. This is exactly the risk whySiblings named. Lalita is 30 against the grid's 28. AshramCard (:353-437) renders a bare Text at :430 with no GlyphView — his 9.0s breath has no port at all; the record's name is "Ash", so `case "

### COLLAPSED — `players-glow-radius` · rows `F7.1`, `F7.5`

**Design** — Eleven authored radii, one per presence, each feeding `drop-shadow(0 0 ${glow}px …)` at `Players View.html:221` (the ten) and `:306` (the eleventh):
· bindu → 28 (:83) · gaia → 16 (:89) · sid → 15 (:94) · arch → 14 (:99) · sakshi → 13 (:104) · karishma → 17 (:109) · ashrey → 16 (:114) · lalita → 22 (:119) · neev → 11 (:130) · shweta → 9 (:135) · ASHRAM → 18 (:146).
Spread 9…28 (3.1×). Six members sit in the 13–17 band, and inside that band karishma (17) is the second-brightest presence on the screen after bindu, while sakshi (13) is the dimmest lens.

**App** — Ten of eleven land in one switch, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PlayersView.swift:340-348`, consumed at `:325` (`.shadow(color: archetype.color.opacity(0.55), radius: glowRadius)`):
  case "Bindu":   return 18      (design 28)
  case "Lalita":  return 14      (design 22)
  case "Neev":    return 8       (design 11)
  case "Shweta":  return 7       (design 9)
  default:        return 10      (design: gaia 16 · sid 15 · arch 14 · sakshi 13 · karishma 17 · ashrey 16)
The eleventh is ported somewhere else entirely — `PlayersView.swift:433`, inside `AshramCard.glyphCircle`, as a bare literal with no name and no switch: `.shadow(color: archetype.color.opacity(0.5), radius: 9)` — design 18.
So: SIX members collapsed onto one `default: 10`, and ELEVEN of eleven carry a number that is not the design's. No value survives the port. The design's spread 9…28 becomes 7…18, and its interior is flat.

**Comment** — NONE — and the absence is the tell here, not a miscitation. `glowRadius` (`:340-348`) and the Ashram literal (`:433`) carry NO comment at all, and no comment anywhere in `PlayersView.swift` cites `Players View.html:83/89/94/99/104/109/114/119/130/135/146`. The file's only two design citations are `:180` → `Players View.html:55-64,398-430` (arrival) and `:231` → `Players View.html:155-177` (border alphas) — both correct, both about other properties. `check_citations` therefore has nothing to check on this group; it passes by having no claim to verify.

The wrong-line citation exists, but in the

**Evidence** — COLLAPSED is the precise label, with BOTH-WRONG riding on top of it: six members share one value where the design distinguishes them, and separately not one of the eleven carries its own constant.

Design, verified by `grep -n "glow:" "Claude Design Round 1/Players View.html"`:
  83:  color: '#E5533C', glyph: '·', gSize: 34, glow: 28,     ← bindu
  89:  …glow: 16   gaia      94:  …glow: 15   sid       99:  …glow: 14   arch
  104: …glow: 13   sakshi   109: …glow: 17   karishma  114: …glow: 16   ashrey
  119: …glow: 22   lalita   130: …glow: 11   neev      135: …glow: 9    shweta
  146: color: '#C47A52', glyph: '◉', gSize: 22, glow: 18,     ← ASHRAM
Consumers: `:221` `filter: drop-shadow(0 0 ${player.glow}px ${player.color}85)` and `:306` the same for `${ASHRAM.glow}`.

App, `PlayersView.swift:340-348` and `:433` (quoted in full in appPair). Two independent misses:

**The collapse.** `defa

**Refutation** — SURVIVES every refutation attempt. (1) DESIGN EXACT: all eleven `glow:` values at Players View.html:83/89/94/99/104/109/114/119/130/135/146 read verbatim as quoted (28/16/15/14/13/17/16/22/11/9/18), consumed at :221 and :306. (2) APP EXACT: PlayersView.swift:340-348 is the glowRadius switch (Bindu 18 / Lalita 14 / Neev 8 / Shweta 7 / default 10) consumed at :325; :433 is the bare `.shadow(color: archetype.color.opacity(0.5), radius: 9)` in AshramCard. (3) THE STRONGEST DEFENSE — A DIFFERENT DESIGN SOURCE — FAILS: Coverage/5-REGISTRIES.md:114-115 cites `Claude Design Round 2/design-source/Players View.html`, which does exist, but `diff` against Round 1 returns IDENTICAL. Both rounds carry the same eleven values; there is no superseding source. (4) NO RECORDED DIVERGENCE: both drop-shadow st

### COLLAPSED — `reading-panel-h2-size` · rows `D5.1`, `D5.3`, `D5.8`, `E1.17`

**Design** — Five members, four-to-one, all in /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:

· #sheet h2 → font-size:25px · line-height:1.24 · font-weight:400 · letter-spacing:-.016em — :4445 (the reading of VII, caught in flight; opened by `openSheetFor` at :5125)
· #still h2 → font-size:24px · line-height:1.26 · font-weight:400 · letter-spacing:-.016em — :4470 (I · THE POINT)
· #going h2 → font-size:24px · line-height:1.26 · font-weight:400 · letter-spacing:-.016em — :4492 (II · THE TURN)
· #thru  h2 → font-size:24px · line-height:1.26 · font-weight:400 · letter-spacing:-.016em — :4516 (III · THE VEIL)
· #wall  h2 → font-size:24px · line-height:1.26 · font-weight:400 · letter-spacing:-.016em — :4540 (IV · THE CHAMBER)

The distinction is stated twice over: #sheet is a point larger AND a notch tighter in leading. All five markup nodes are siblings in one block at :4659 and :4676-4679, and all five are named together in the one `READING` selector at :4960 — so the odd member is odd on purpose, not by drift.

**App** — THERE IS ONE APP EXPRESSION FOR ALL FIVE MEMBERS.

/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:246
    Text(star.t).font(.lora(24, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)

It lives in `private struct ReadingHead` (:237-251), which every one of the seven world readings instantiates:
· #still  → ReadStillness (:317) calls ReadingHead at :360
· #going  → ReadFollowing (:418) calls it at :467
· #thru   → ReadParting  (:514) calls it at :562
· #wall   → ReadPressing (:700) calls it at :728
· #sheet  → ReadCompany  (:1179, VII · the dance) calls it at :1261
(plus ReadTurning :935 and ReadSending :1084, the two worlds outside this group)

Reached from the axis: InstrumentView.swift:899-921 routes registers d1–d7 to `PointWorldView`, which dispatches `PointReading` (PointReadings.swift:298-315) to those seven structs. So the Instrument's five panels resolve, in the app, to that single line.

WHAT THE ONE SITE CARRIES:
· size 24 — correct for #still/#going/#thru/#wall, WRONG for #sheet, which the design gives 25.
· weight .medium (Lora-Regular_Medium = 500, confirmed at Theme/Theme.swift:65,80-91) — the design gives all five font-weight:400. The 500 is `The Point v9.html:1079 #sheet .s-title{font-size:25px;font-weight:500}`. So the head took t

**Comment** — NONE — and the absence is itself the tell.

`ReadingHead` (PointReadings.swift:237) has NO doc comment and NO citation of any kind. Line 236 is blank; the struct opens cold. There is no comment on member A citing member B's line here, because there is no comment at all: the one expression that serves five design members carries zero provenance.

Confirmed mechanically:
· `grep -rn "4445\|4470\|4492\|4516\|4540" --include="*.swift"` over the whole app source → 0 hits. Not one of the five design sites is cited anywhere.
· `grep -rn "25px\|24px\|1\.24\|1\.26" --include="*.swift"` → 2 hits, both u

**Evidence** — THE SHAPE, precisely: the design's four-to-one became one-to-five. Where `#where`/`#pname` was the right number on the wrong sibling, this is one number on every sibling — the rail's shape (`(1 - dom)` for `(1 - dom*0.9)`), at the scale of a whole family. The four members that should read 24 do read 24, so nothing looks wrong; the fifth reads 24 because there is no fifth site to be wrong in. A port that types 24 once and calls it five times passes an even harder eye than one that types it five times.

WHY IT SURVIVED, four ways:
1. No citation to check (see commentFault). `check_citations` cannot fire on an uncited line.
2. No test to fail. `grep -rn "ReadingHead\|lora(24" BinduFeedTests/` → 0.
3. The rows that own it closed on OTHER properties — D5.1 on dispatch-and-recede, D5.8 on the grab model, D5.3 on the nine arms. Each is a true closure of the thing it names.
4. Deduplication read

**Refutation** — Survives every refutation attempt. DESIGN VERIFIED byte-exact: The Instrument v3.html:4445 #sheet h2 = font-weight:400;font-size:25px;line-height:1.24;letter-spacing:-.016em, against :4470/:4492/:4516/:4540 all at 24px/1.26/400/-.016em. GENUINE SIBLINGS, not adjacent strangers: all five h2 are filled from the same field (querySelector('h2').textContent = s.n.t at :5129, :5156, :5180, :5208, :5236), share one markup block (:4659, :4676-4679) and one READING selector (:4960). MAPPING CORRECT: :5128 writes 'VII · THE DANCE' into #sheet and :5311 hands el:sheet to register d7; the app's switch at PointReadings.swift:274-281 routes dimension 7 to ReadCompany. APP VERIFIED: PointReadings.swift:246 Text(star.t).font(.lora(24, weight: .medium)) is the sole expression, called by all seven readings 

### COLLAPSED — `return-ash-quote-opacity` · rows `B0.3`, `C5.6`, `D5.11`, `E3.11`, `E3.12`, `E3.13`, `E3.5`, `E3.7`, `E3.8`, `E3.9`, `F7.4`, `F8.1`

**Design** — Both members exist in the design and are explicitly distinguished, in BOTH prototypes:

MEMBER A — the quoted past self ("{P.quote}")
 · Round 1 comp: `opacity:0.72` — /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html:650
   `<p style={{fontFamily:'Lora,serif',fontStyle:'italic',fontSize:15,color:'var(--ash)',opacity:0.72,lineHeight:1.6,borderLeft:'1px solid rgba(196,122,82,0.35)',paddingLeft:12}}>“{P.quote}”</p>`
 · v2: `opacity:0.82` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Return v2.html:1220 (class `dried`, whose own rule at :931 is `color:var(--ash);font-style:italic;filter:saturate(.85);text-shadow:...`)

MEMBER B — the ask ({P.ask})
 · Round 1 comp: `opacity:0.9` — /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html:652
   `<p style={{fontFamily:'Lora,serif',fontStyle:'italic',fontSize:16,color:'var(--ash)',opacity:0.9,marginBottom:14}}>{P.ask}</p>`
 · v2: `opacity:0.92`, `color:'var(--ash)'` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Return v2.html:1222

Under either source the pair is a two-step ladder in the SAME colour (var(--ash)): quote behind ask, 0.72→0.9 or 0.82→0.92.

**App** — The app's port is the Reply movement of ReturnView, `private var reply` at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:496-531. Both members ARE ported as elements; NEITHER carries any opacity constant.

MEMBER A — the quote — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:503-505
    Text("\u{201C}\(quote)\u{201D}")
        .font(.loraItalic(15)).foregroundStyle(ReturnCanon.ashColor).saturation(0.85)
        .multilineTextAlignment(.center)
  → NO `.opacity(...)`. Effective opacity 1.0. Size 15 and Lora-italic and ash are right; `.saturation(0.85)` is v2's `.dried` filter correctly carried — the ONE thing not carried from that same call site is the inline `opacity` sitting beside it. (The `.dried` text-shadow is also dropped here, though it IS carried on the sibling `.dried` line at :326.)

MEMBER B — the ask — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:507
    Text(prompt.ask).font(.lora(18)).italic().foregroundStyle(BinduTheme.inkPrimary)
  → NO `.opacity(...)`. Effective opacity 1.0. AND the colour has left the ash family: `BinduTheme.inkPrimary` = `#EDE8E3` (Theme/Theme.swift:33), not `ReturnCanon.ashColor` = `#C47A52` (Return/ReturnCanon.swift:10). Size is 18 against the design's 16.

No ances

**Comment** — NONE — and the ABSENCE is itself the mechanism here.

Neither app site carries a comment or a design citation. The only comment over the whole Reply block is ReturnView.swift:495 — `// VII · The Reply (quote-or-four-words; his words, never generated)` — which names the DATA mechanism (the forward detector, whose words are quoted) and says nothing about the typography. The section's other comments (:533-536 on `addRing`, :538-540 citing `The Return v2.html:1308-1310`) are on the sound and the write.

So this is the silent variant of the class, not the mis-citation variant: `check_citations` had

**Evidence** — VERDICT REASONING — why COLLAPSED and not ONE-MISSING or BOTH-WRONG:

Both members were ported as elements, so it is not NOT-PORTED. Neither carries a number of its own, so it is not TRANSPOSED (no swap) and not ONE-MISSING (that requires one member to have kept its constant). It is not BOTH-WRONG in the "two plausible numbers" sense — there are no numbers at all. Both members land on the SAME effective value, 1.0, where the design distinguishes them by a deliberate step. That is COLLAPSED, exactly as the rail was: the distinguishing quantity is gone and the siblings are blurred into each other.

WHY IT SURVIVED — the reason this one is worth the sweep:

The design's premise is that the quote and the ask are the same colour (var(--ash)), the same italic Lora, and differ ONLY in opacity and size, so that the quote sits BEHIND the ask. The app broke the premise on the other axis: it left t

**Refutation** — SURVIVES. All four design lines and both app sites read EXACTLY as quoted, at the exact line numbers cited; every refutation route I could open closes against the finding, and two of them invert into corroboration.

TEXT VERIFIED VERBATIM
· Round 1 comp :650 `…fontSize:15,color:'var(--ash)',opacity:0.72,lineHeight:1.6,borderLeft…` and :652 `…fontSize:16,color:'var(--ash)',opacity:0.9,marginBottom:14` — exact.
· v2 :1220 `<p className="dried" style={{fontSize:15,…,opacity:0.82}}>` and :1222 `<p style={{fontStyle:'italic',fontSize:16,color:'var(--ash)',opacity:0.92,…}}>` — exact. `.dried` at :931 exact.
· ReturnView.swift:503-505 (quote) and :507 (ask) exact; neither carries `.opacity`. My own `grep -n opacity` over the whole file returns 21 hits and NONE lies between :496 and :531 except th

### COLLAPSED — `rite-breath-keyframes` · rows `E2.1`, `E2.2`

**Design** — Three siblings, one CSS block, `Claude Design Round 1/comps/The Rite v3.html` (identical at the root copy `Claude Design Round 1/The Rite v3.html` and at `Claude Design Round 2/design-source/The Rite v3.html`):

· `@keyframes breathe` → floor 0.55, peak 1.00 — `:1158`
  its five call sites: `:1292` Arrival room glyph · `:1335` Reading's "The field gathers" button (Lalita, 12 italic) · `:1443` Gathering intro span · `:1478`/`:1484`/`:1488` Recognition's Ash buttons + "finding the words…" (this one on a 3s period, not `var(--breath)`) · `:1524` Sealed room glyph.

· `@keyframes breatheSoft` → floor 0.30, peak 0.62 — `:1159`
  its four call sites: `:1297` Arrival "touch to receive" · `:1348` Reading base line "received at the pace of breath" · `:1447` the silent glyphs · `:1452` the Gathering touch hint.

· `@keyframes heartbeat` → 0.10 / 0.30@8% / 0.12@16% / 0.26@26% / 0.10@40% — `:1160`
  one call site: `:1454`, the 34×3 bar, 1.7s.

The whySiblings note is exactly right about the collision surface: `breatheSoft`'s FLOOR and `heartbeat`'s PEAK are both 0.30.

**App** — · `heartbeat` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:165-173`, `heartbeatOpacity(_:)`, driven off the master phase at `Breath.period/1.7`:
    if sub < 0.08 { return 0.10 + 0.20 * (sub / 0.08) }      // 0.10 → 0.30 at 8%
    if sub < 0.16 { return 0.30 - 0.18 * ((sub - 0.08)/0.08) } // → 0.12 at 16%
    if sub < 0.26 { return 0.12 + 0.14 * ((sub - 0.16)/0.10) } // → 0.26 at 26%
    if sub < 0.40 { return 0.26 - 0.16 * ((sub - 0.26)/0.14) } // → 0.10 at 40%
    return 0.10
  Every breakpoint and every value is the design's. Rendered at `:155-162` as a 34×3 rounded bar, 9pt from the bottom. MATCHED.

· `breathe` and `breatheSoft` → ONE expression, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteView.swift:20-24`:
    struct RiteBreathe: ViewModifier {
        func body(content: Content) -> some View {
            content.opacity(0.28 + 0.42 * breath.value)      // :23 — floor 0.28, peak 0.70
        }
    }
  `breath.value` is `(1 − cos φ)/2` ∈ [0,1] (`Instrument/Breath.swift:94`), so the ramp is 0.28 → 0.70.

  Its six call sites, and which design member each one's element belongs to:
   · `Screens/DoorView.swift:134` — "touch to receive" → design `:1297` = **breatheSoft**
   · `Screens/RiteView.swift:256` — "received at the p

**Comment** — In the app: NONE — and the absence is itself the point. No Swift comment anywhere in the tree cites `:1158`, `:1159` or `:1160`, or any `The Rite v3.html` line in the 1100s (`grep -rn "Rite v3" --include=*.swift` returns 12 hits; the cited lines are 1179–1190, 1224–1256, 1436, 1473-1477, 1495, 1538, 1542 — the keyframe block is cited by nothing). `RiteView.swift:17-19`, the doc comment directly above the collapsed modifier, names no source at all:

  /// A quiet breathing-opacity hint that reads the ONE master breath (never a local
  /// `repeatForever` — that's the one-phase-contract anti-pat

**Evidence** — **The finding, in one line: the Rite's two named breaths are one ramp in the app, and that ramp's numbers are neither of theirs.**

Not a transposition — nothing here is 0.55/1.00 sitting on the soft sibling. It is the COLLAPSED variant, with a BOTH-WRONG overlay:

1. **COLLAPSED.** The design distinguishes a loud breath (0.55→1.00, near-full brightness at the crest) from a soft one (0.30→0.62, never more than two-thirds lit). The app has one `RiteBreathe` at `RiteView.swift:23` and applies it to a member of EACH set: `RiteView.swift:256`'s base line is a breatheSoft element, `RiteRecognitionView.swift:116`'s "finding the words…" is a breathe element. Both now travel 0.28→0.70. The design's separation of the chrome that murmurs from the type that speaks is gone at exactly the two places the modifier is used inside the Rite.

2. **BOTH-WRONG.** 0.28→0.70 is neither sibling. The floor is t

**Refutation** — Survives every refutation I could mount. DESIGN VERIFIED VERBATIM: `Claude Design Round 1/comps/The Rite v3.html:1158-1160` reads exactly as quoted (`breathe` 0.55→1, `breatheSoft` 0.30→0.62, `heartbeat` .10/.30/.12/.26/.10), byte-identical at the root copy and `Claude Design Round 2/design-source/`. All ten call sites confirmed by grep. APP VERIFIED: `Screens/RiteView.swift:20-24` is ONE modifier, `content.opacity(0.28 + 0.42 * breath.value)`; `Instrument/Breath.swift:94` sets `value = (1 - cos(p*2pi))/2` in [0,1], so the ramp is exactly 0.28 -> 0.70. `RiteGatheringView.swift:165-173` reproduces all five heartbeat breakpoints (I checked each endpoint arithmetically) — MATCHED. THE COLLAPSE IS REAL: `RiteWord.readingBaseLine` = "received at the pace of breath" (`RiteContent.swift:199`) is 

### COLLAPSED — `rooms-per-room-glyph-size` · rows `F3.4`

**Design** — Room Selection.html, `gSize` column, rendered at `fontSize: room.gSize` (:618) for ROOMS and `fontSize: turn.gSize` (:663) for TURNS — no multiplier, no base scale in either keyframe (mirrorFace :467-470 and signalLand :473-478 both sit at scale ~1), so these ARE the rendered point sizes.
· maya → 48 (Room Selection.html:496)
· descent → 34 (Room Selection.html:511)
· return → 50 (Room Selection.html:516)
· field → 52 (Room Selection.html:556)
· mirror → 30 (Room Selection.html:569)
· signalspace → 31 (Room Selection.html:574)
The six split across TWO tables: the first four are ROOMS (:493-558), the last two are TURNS (:566-577) — a separate const, a separate card component, a separate glyph box (56×56 at :614 for rooms, 50×50 at :661 for turns).

**App** — FOUR ROOMS — all in one table, `RoomStyle.forRoom`, field `portalGlyph`, consumed at RoomPortalCard.swift:24 (`size: RoomStyle.forRoom(room.name).portalGlyph`) into GlyphView's `.font(.system(size: size))` (GlyphAnimation.swift:64):
· maya → portalGlyph: 48 — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/RoomStyle.swift:24 ✓
· descent → portalGlyph: 34 — RoomStyle.swift:27 ✓
· return → portalGlyph: 50 — RoomStyle.swift:28 ✓
· field → portalGlyph: 52 — RoomStyle.swift:36 ✓
(all thirteen rooms check out: 44/42/44/44/46/44/44/44/42 match :501-551 one for one)

TWO TURNS — NOT in RoomStyle at all. They are `FieldSurfaceConfig.mirror` / `.signal` (/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/FieldSurfacePortalCard.swift:19-37), rendered by `FieldSurfacePortalCard` at RoomSelectionView.swift:107 and :110. `FieldSurfaceConfig` carries id, glyph, color, name, animation, label, descriptor — and NO size field. The size is a literal on the shared view body:
· mirror → 38 — FieldSurfacePortalCard.swift:50
· signalspace → 38 — FieldSurfacePortalCard.swift:50 (the SAME line; one code path serves both)
Design 30 and 31 → app 38 and 38. Collapsed to one value, and that value is neither member's. The 50×50 box at design :661 also became `.frame(width: 56)` at FieldSurfacePorta

**Comment** — NONE in the strict form — no comment on one member quotes the other member's design line, and `check_citations` has nothing to catch here because the turn sites carry no line citation at all. But the same substitution happened one level up, in prose, and it is what made 38 look weighed. FieldSurfacePortalCard.swift:3-9, the header comment over both configs:

  "// Mirror and Signal Space aren't Airtable Room records — they're
  //  app-defined portals that share the Room portal visual language."

The turn cards are justified by the ROOM family rather than by TurnCard's own lines (:569, :574), 

**Evidence** — THE FINDING: the group's two Turns are COLLAPSED onto a single literal, and that literal is neither member's number — so this instance is COLLAPSED with a BOTH-WRONG interior. The four rooms are clean.

Why it is structurally worse than the `#where`/`#pname` swap: there is no pair of app sites to compare. `FieldSurfaceConfig` (FieldSurfacePortalCard.swift:10-38) is a seven-field struct that models everything the design distinguishes between the two turns — glyph ◐/⊙, color, name, animation, "first person"/"second person", both descriptors, verbatim — and omits the ONE field where they differ numerically. The distinction had nowhere to live, so the 30-vs-31 was not overwritten, it was made unrepresentable. A reader auditing the two configs sees two carefully differentiated records and never looks at line 50, which is outside both.

Why 30/31 is worth the point: the whole TURNS block is wr

**Refutation** — THE PORT FAULT SURVIVES; PART OF THE FINDING'S FRAMING DOES NOT.

VERIFIED EXACT (design, /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Room Selection.html): mirror `gSize: 30` at :569 and signalspace `gSize: 31` at :574, both in the same `TURNS` const, both consumed by one `TurnCard` at `fontSize: turn.gSize` (:663) inside a 50x50 box (:661). Rooms: 48/44/42/34/50/44/44/46/44/44/44/42/52 at :496-556, box 56x56, `fontSize: room.gSize` (:618). No multiplier in either path.

VERIFIED EXACT (app): `FieldSurfaceConfig` (/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/FieldSurfacePortalCard.swift:10-17) is seven fields — id, glyph, color, name, animation, label, descriptor — and carries NO size. Both configs flow through one body; `size: 38` is a literal at :50, the single line

### COLLAPSED — `rope-durations` · rows `D2.6`

**Design** — Three members of the `#rope` block in `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html`, staging one sequence in three distinct times:
· `#rope` → `transition:opacity 1.1s ease` — :4411 (the rope arrives, on `openRope()` adding `.on`, :5088)
· `#rope .ring` → `transition:margin 1.6s ease` — :4413 (the ring lifts; `#rope.said .ring{margin-bottom:46px}`, :4414)
· `#rope .said` → `transition:opacity 2.6s ease` — :4417 (the words come; both fired by `.said` added 20000ms later, :5089)
Markup at :4666-4675 confirms `.said` wraps BOTH the paragraph and the `.outs` exits, so the 2.6s governs the whole word-block, exits included. The ceremony is 1.1 → 1.6 → 2.6: each stage slower than the one before.

**App** — App port is `DoorRopeOverlay`, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:238-292`, raised from two sites.

· `#rope` opacity 1.1s → TWO app raise sites with DIFFERENT constants:
  - `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:176` — `withAnimation(.easeInOut(duration: 1.1)) { showRope = true }` — carries its own member's 1.1.
  - `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:315` — `withAnimation(.easeInOut(duration: 0.8)) { showRope = true }` (and :324 for the dismissal) — 0.8, not the design's 1.1. Same overlay, same design property, two different numbers depending on which surface reaches for it.

· `#rope .ring` margin 1.6s → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:246` — `VStack(spacing: phase >= 2 ? 40 : 0)`. The spacing change is the ring's lift; it has no duration of its own and inherits whatever `withAnimation` mutated `phase`.

· `#rope .said` opacity 2.6s → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:265` (the line) and `:276` (the exits), both bare `.transition(.opacity)`. Also no duration of its own, same inheritance.

Both of those inherit from the SAME two writers:
  - `:282` — `.onTapGesture { if phase < 2 { withAnimat

**Comment** — NONE — and the absence is the mechanism here, not an exoneration.

No comment anywhere on the three app sites cites `:4411`, `:4413` or `:4417`, nor any other design line for a duration. `grep -n "4411\|4413\|4417"` over the whole app tree returns exactly one hit, and it is an unrelated ratio in `Universe/UniverseView.swift:721`. `DoorView.swift` carries only two design citations at all, both about sound and both correct: `:184` `// \`openTurn(){B.threshold(146)}\` — Instrument v3:5082` and `:193` `// \`crossDoor(){B.threshold(...)}\` — Instrument v3:5022`. The comment sitting over the collaps

**Evidence** — WHAT THE COLLAPSE COSTS, concretely. In the design, 20s after the rope opens, `.said` lands on `#rope` and two clocks start together and finish apart: the ring finishes rising at 1.6s, and the words are still arriving until 2.6s — a full second in which the space has already been made and is not yet filled. The app runs both on one 1.0s `easeInOut`, so the ring lifts and the words land simultaneously and the whole thing is over in 1.0s. Every stage of the design's ritardando (1.1 → 1.6 → 2.6) reads in the app as 1.1 (Door) or 0.8 (axis), then 1.0, then 1.0. The design gets slower; the app gets faster and then flat.

WHY IT LOOKS RIGHT TO A READER. `duration: 1.0` on a `withAnimation` that mutates one `phase` variable is the most ordinary line in a SwiftUI file. There is no pair of numbers sitting side by side inviting comparison — the two members' durations were never written down as num

**Refutation** — Survives attack. All three design lines read verbatim: The Instrument v3.html:4411 `transition:opacity 1.1s ease`, :4413 `transition:margin 1.6s ease`, :4417 `#rope .said{opacity:0;transition:opacity 2.6s ease}`; markup :4666-4675 confirms `.said` wraps both the paragraph and `.outs`, and `openRope()` (:5087-5089) adds `.on` then `.said` at 20000ms, so 1.6 and 2.6 are two clocks started by one event. All app sites read as quoted: DoorView.swift:176 `duration: 1.1`; :246 `VStack(spacing: phase >= 2 ? 40 : 0)`; :265 and :276 bare `.transition(.opacity)` with no `.animation()` modifier anywhere in the overlay; :282 and :289 both `withAnimation(.easeInOut(duration: 1.0)) { phase = 2 }`. So the ring's lift and the words' fade are genuinely served by ONE constant (1.0), which is neither 1.6 nor 

### COLLAPSED — `sec-arrival-opacity-duration` · rows `D5.1`, `D5.3`

**Design** — All five verified by reading the design file directly (`/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html`):

· `.sec` (the sheet's, BASE)  → `transition:opacity 1s ease` — :4447
· `#still .sec` (I · THE POINT)   → `transition:opacity 2.2s ease` — :4473
· `#going .sec` (II · THE TURN)   → `transition:opacity 1.1s ease` — :4495
· `#thru .sec`  (III · THE VEIL)  → `transition:opacity 1.5s ease` — :4519
· `#wall .sec`  (IV · THE CHAMBER)→ `transition:opacity .5s ease`  — :4544

Each override sits inside its movement's authored block, and each block's own comment states the intent the number carries. :4463-4465 for #still: "Nothing here slides in from an edge. Each section fades up in place" (hence 2.2s, the slowest). :4538-4542 for #wall: "It does not fade in. It is struck." (hence .5s, the fastest). The four numbers ARE the difference between the four readings.

**App** — There is exactly ONE app expression for all five members — a single shared constant on the shared state object:

`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:199`
    `withAnimation(.easeInOut(duration: 1.0)) { revealed += 1 }`

inside `PointReadingState.give()` (:197-201), the method every one of the seven readings calls to admit a section. The seven consumers are all `SectionBlock(...).transition(.opacity)`, which take their duration from that one `withAnimation` and nothing else:

· I · THE POINT   `ReadStillness` — PointReadings.swift:363 (give at :406)
· II · THE TURN   `ReadFollowing` — PointReadings.swift:471 (give at :504)
· III · THE VEIL  `ReadParting`   — PointReadings.swift:566
· IV · THE CHAMBER `ReadPressing` — PointReadings.swift:735 (give at :802)
· V/VI/VII        — :943, :1087, :1264

No per-reading `.animation(...)` overrides the section opacity in any of the seven; the only other animations in `Point/` drive world-specific mechanics (`settling` :944/:1029, `carryDone` PointWorldView:124, `shown` PointWorldView:516/542/550) and none of them is a section arrival.

THE APP'S 1.0 IS THE BASE MEMBER'S CONSTANT, ROUNDED. Design :4447 is `1s`; the app is `1.0`. So the base was ported and then applied to all four movements as well — the fo

**Comment** — NONE — and the absence is itself the reason this survived.

`PointReadings.swift:197-201` carries NO comment on the animation at all. The nearest doc comment is on the enclosing class (:188): "/// What every world's reading shares: the star, its hue, and how far it has been let in." — which asserts the shared-ness as a virtue and names three things that genuinely are shared, without noticing that arrival TIMING was folded into the same shared object even though the design makes it the one thing that is not shared.

No app comment anywhere cites `:4447`, `:4473`, `:4495`, `:4519` or `:4544` — g

**Evidence** — VERDICT COLLAPSED — the exact variant named in the brief, and the rail's shape rather than the `#where`/`#pname` swap: five sibling declarations where the design distinguishes them, one constant in the app, and that constant is the group's own BASE value.

The chain, verified end to end:
1. Design read directly, not from a checklist: `grep -n "transition:opacity"` on The Instrument v3.html returns :4447 (1s), :4473 (2.2s), :4495 (1.1s), :4519 (1.5s), :4544 (.5s) — the five members, values as stated in the group.
2. App port located by role, not name — the app renames these: `#still` → `ReadStillness`, `#going` → `ReadFollowing`, `#thru` → `ReadParting`, `#wall` → `ReadPressing` (PointReadings.swift MARK headers at :295, :413, :509, :682, which carry the design's own movement titles I·THE POINT / II·THE TURN / III·THE VEIL / IV·THE CHAMBER verbatim at :19-22).
3. Every one of the four (an

**Refutation** — SURVIVES. Both halves opened and read; every attempted refutation failed.

DESIGN (The Instrument v3.html, Round 1 — byte-identical `diff` to the Round 2 design-source copy): all five lines read exactly as quoted. :4447 `.sec{...transition:opacity 1s ease,transform 1.2s cubic-bezier(.16,.84,.2,1)}`; :4472-4473 `#still .sec{...transition:opacity 2.2s ease,filter 2.4s ease,transform 2.4s ease}`; :4494-4495 `#going .sec{...transition:opacity 1.1s ease,transform 1.5s...}`; :4518-4519 `#thru .sec{...transition:opacity 1.5s ease,filter 1.9s...,transform 1.9s ease}`; :4543-4544 `#wall .sec{...transition:opacity .5s ease,transform .7s...,text-shadow 1.2s ease}`. The sibling relation is airtight and is NOT a proximity artifact: one class rule plus four ID-scoped overrides of the same shorthand, con

### COLLAPSED — `settings-caption-tracking` · rows `F0.1`, `F10.1`, `F10.5`, `F4.2`

**Design** — All four members are real and distinct in `/Users/ashrey/Bindu Feed/Claude Design Round 1/Settings.html`:

· A — "HOW YOU ARRIVE" header → `fontSize:10, letterSpacing:'0.14em'` (= 1.4pt) — Settings.html:430
· B — preview's quality line → `fontSize:10, … opacity:0.75, letterSpacing:'0.08em'` (= 0.8pt) — Settings.html:451
· C — section labels → `fontSize:9, letterSpacing:'0.1em', textTransform:'uppercase'` (= 0.9pt) — Settings.html:461, and identically at :484, :518, :556
· D — mood card's quality line → `fontSize:9, letterSpacing:'0.03em', lineHeight:1.4` (= 0.27pt) — Settings.html:508

Four Space Mono captions, four trackings, spanning 0.03em → 0.14em: a 4.7× spread.

**App** — All four port to `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SettingsView.swift`. None is missing.

· A → :94-96
    Text("HOW YOU ARRIVE")
        .spaceMonoTracked(11)
        .tracking(1.54)
· B → :143-144
    Text(selectedMoodQuality)
        .spaceMonoTracked(10, em: 0.08)
· C → :423-426 (`sectionLabel`, used at :155, :199, :227)
    Text(text)
        .spaceMonoTracked(9)
        .tracking(0.9)
· D → :240-241
    Text(mood.quality)
        .spaceMonoTracked(9, em: 0.3 / 9)

AS WRITTEN, three of four carry their own member's em and no sibling's: 1.54 = 0.14 × 11, `em: 0.08`, 0.9 = 0.1 × 9. There is NO transposition. D is the exception: `0.3 / 9` = 0.0333em, not the design's 0.03em.

AS RENDERED, A and C do not survive. `spaceMonoTracked` is `Theme.swift:151`:
    func spaceMonoTracked(_ size: CGFloat, em: CGFloat = 0) -> some View {
        self.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size)
    }
With `em` defaulting to 0 it applies `.tracking(0)` DIRECTLY to the Text, and the `.tracking(1.54)` / `.tracking(0.9)` chained on the line below sit OUTSIDE it. The inner value wins. A renders at 0 tracking; C renders at 0 tracking.

Rendered set: A = 0 · B = 0.8pt · C = 0 · D = 0.30pt. The design's two loosest captions — 0.14em and 0.1em, the wides

**Comment** — NONE of the fault class proper. No comment on one member cites another member's design line; the sibling-citation tell that hid the `#where`/`#pname` swap is absent here. A and C carry no design citation at all (:94 has only `// MARK: - Label`; :423 `sectionLabel` has no comment), and D's nearest comment (:222-223) cites the section by name, not by line.

ONE NEAR-MISS worth recording, one element short of the class. The doc comment on member B, `SettingsView.swift:436`:

    /// `Claude Design Round 1/Settings.html:452` renders `currentMood.quality` — *"grounded, present"* — under
    /// the

**Evidence** — FILES
· design: /Users/ashrey/Bindu Feed/Claude Design Round 1/Settings.html:430, :451, :461, :508
· app: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SettingsView.swift:94-96, :143-144, :240-241, :423-426
· helper: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151
· audit: /Users/ashrey/Bindu Feed/Coverage/1-AUDIT-254.md:337 (F0.1), :353 (F4.2), :369 (F10.1)

WHY COLLAPSED AND NOT MATCHED. Every string checker passes this group: each app site's literal is arithmetically its own member's em times its own font size. A reader diffing constants finds four different numbers against four different numbers and stops. The collapse is one modifier deeper — `spaceMonoTracked(11)` and `spaceMonoTracked(9)` each plant a `.tracking(0)` on the Text itself, under the `.tracking(1.54)` / `.tracking(0.9)` that the author wrote on the next line. This is not my inference: it i

**Refutation** — SURVIVES ATTACK. Every load-bearing claim verified independently.

DESIGN, exact: Settings.html:430 fontSize:10/0.14em; :451 fontSize:10/opacity 0.75/0.08em; :461 fontSize:9/0.1em/uppercase (again :484, :518); :508 fontSize:9/0.03em. APP, exact: SettingsView.swift:94-96, :143-144, :240-241, :423-426 (sectionLabel reached at :155, :199, :227). All four ported; none missing.

MECHANISM CONFIRMED ON MY OWN READ, not taken on trust. Theme.swift:151 is `extension View { func spaceMonoTracked(_ size: CGFloat, em: CGFloat = 0) -> some View { self.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size) } }`. Because `.textCase` returns `some View`, the helper's internal `.tracking` AND the chained outer `.tracking(1.54)`/`.tracking(0.9)` are both `View.tracking(_:)`, the environment-pr

### COLLAPSED — `story-avatar-glow-hex-alphas` · rows `E1.13`, `F2.5`, `F2.8`, `F5.3`

**Design** — Design site is one line, `Claude Design Round 1/comps/Story Detail.html:470`, with its radius base at `:465` (`const g = Math.round(size * 0.44)`):
· outer glow → `0 0 ${g}px ${d.color}50` — wide layer, radius `g` = 0.44·size, alpha **0x50 = 80/255 = 0.314**
· inner glow → `0 0 ${Math.round(g*0.35)}px ${d.color}28` — tight layer, radius 0.35·g = 0.154·size, alpha **0x28 = 40/255 = 0.157**
Exactly 2:1 in alpha, ~2.9:1 in radius. The same pair is authored at `Claude Design Round 1/comps/The Rite v3.html:1271` (and `The Rite v3.html:1271`), so it is a shared avatar primitive, not a one-screen flourish. The Home Feed stack face is a THIRD variant: `Claude Design Round 1/Home Feed.html:100` gives one layer only — `0 0 8px ${d.color}42` (0x42 = 0.259).

**App** — The app's only avatar disc primitive is `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/VoiceAvatar.swift` — reached by every surface this group covers: `Components/CommentCard.swift:122` (`VoiceAvatar(archetype:, size: 36)`, the Story Detail comment avatar), `Components/ReplyRow.swift:107` (size 24), `Components/StoryCard.swift:95` via `VoiceAvatarStack` (size 22).

· outer glow → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/VoiceAvatar.swift:10-13`:
  `Circle().fill(archetype.color.opacity(0.22)).blur(radius: 4).frame(width: size * 1.6, height: size * 1.6)`
  Alpha **0.22** — neither 0.314 nor 0.157.
· inner glow → **no port anywhere.** Grepped every `.shadow(` in the tree: the only two-layer glows are `Theme/GlyphAnimation.swift:67-68` (glyph halo, `drop-shadow(0 0 …px color65)`, a different design element), `Screens/TheTurningView.swift:171-177`, `Screens/SignalView.swift:330-336`, `Screens/AshComposeView.swift:230-238`. None of them is an avatar disc, and none carries 0.314/0.157. `VoiceAvatar` is the port site and it has one layer.

Two further breaks on the surviving layer: its blur is the **constant 4** and its diameter the constant `size * 1.6`, where both design layers scale with `size` — so the 36pt comment avatar and the 22pt stack face wear t

**Comment** — NONE — and the absence is itself the tell for this group. There is no citation to mis-aim: the comment over the app site is bare, `// outer glow halo` (`VoiceAvatar.swift:9`). The one comment in the file that does gesture at the source cites no file and no line — `VoiceAvatar.swift:15-16`: "the comps draw filled discs, / not the ghosted 0.30 ring this used to render". `check_citations` can neither confirm nor refute a citation with no `file:line`, so the element passed the string checkers by carrying nothing for them to check. (Compare the file's other half, `VoiceAvatarStack:36-58`, which is 

**Evidence** — **Why COLLAPSED and not ONE-MISSING or BOTH-WRONG.** The design distinguishes the two layers by a clean 2:1 alpha and a ~2.9:1 radius: a wide soft bloom the face sits in, and a tight bright rim right at the edge of the disc. The app renders **one** layer, so the distinction is not mis-sized — it is gone. This is the extreme of the COLLAPSED variant (the rail case): where the rail blurred `(1 − dom*0.9)` toward `(1 − dom)`, here the pair blurs into a single membership. It is not ONE-MISSING, because the surviving member does not carry its own constant either (0.22 vs 0.314); the missing member is simply absent rather than given the survivor's value.

**No transposition to report.** 0x50 and 0x28 appear nowhere in the app as 0.314/0.157 on any avatar, in either order — so the fault cannot be mistaken for a swap. Searched: `.shadow(` across all Swift (48 sites), every `Avatar` file, `StoryD

**Refutation** — VERDICT SURVIVES. Every load-bearing claim verified independently; two decorative claims in the finding's prose are false but cut the wrong way (they strengthen it).

WHAT I CONFIRMED
1. Design reads exactly as quoted. `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Story Detail.html:465` = `const g = Math.round(size * 0.44);`; `:470` = ``boxShadow: `0 0 ${g}px ${d.color}50, 0 0 ${Math.round(g*0.35)}px ${d.color}28`,``. Verbatim.
2. TRUE SIBLINGS, not adjacent strangers. Both members are two comma-separated layers of ONE `boxShadow` on ONE div inside one `Avatar()` primitive. The "unrelated elements sitting near each other" failure mode is impossible here. Identical primitive at `Claude Design Round 1/comps/The Rite v3.html:1271`.
3. App site reads as quoted. `/Users/ashrey/Bindu Fee

### COLLAPSED — `world-farewell-line-alpha`

**Design** — Design, all three at cx,H-150 in 8.5px Space Mono, alpha = fadeState × p × k, with NO breath term and NO `A`:
· world-one · "IT CLOSED. IT DOES NOT MIND." → `this.leaving*p*0.28` — The Instrument v3.html:2564 (= design-source/world-one.js:192, line at :193)
· world-three · "IT CLOSED BEHIND YOU. IT ALWAYS DOES." → `this.closing*p*0.30` — The Instrument v3.html:3075 (= world-three.js:243, line at :244)
· world-four · "THE WALL EASED. WHAT WAS STRUCK STAYS STRUCK." → `this.easing*p*0.30` — The Instrument v3.html:3372 (= world-four.js:276, line at :277)
k is 0.28 / 0.30 / 0.30 — world-one alone is dimmer. The SIBLING rule these must be kept apart from is the invitation line one branch above each of them: `A*0.38*(0.7+br*0.4)` at v3.html:2553 / :3066 / :3364 (world-one.js:182, world-three.js:234, world-four.js:268), identical in all four worlds. The design also deliberately builds the farewell from raw `p`, not from `A = p*(1-dsp*0.62)` (v3.html:2483), and gives it no breath.

**App** — All three farewell lines are ported as text + fade scalar only; the alpha constant is inherited from the invitation cue's view and is identical for all three.

· I  /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:309-310 — `if leaving.isClosing(at: tl.date), let line = PointLeaving.line(dimension: 1) { WorldCue(text: line).opacity(leaving.value(at: tl.date)) }`
· III /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:567-568 — `WorldCue(text: line).opacity(closing.value(at: tl.date))`
· IV /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:1070-1071 — `WorldCue(text: line).opacity(easing.value())`

The constant lives one level down, hardcoded in the shared view:
/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:255 —
`.foregroundStyle(BinduTheme.inkPrimary.opacity(0.38 * (0.7 + breath.value * 0.4)))`

Effective app alpha = fade × 0.38 × (0.7 + br·0.4) for I, III and IV alike. Neither 0.28 nor 0.30 appears anywhere in PointWorlds.swift or PointLeaving.swift for these lines (grep: 0 hits at any farewell site). `PointLeaving` (/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointLeaving.swift:68-92) carries the rate and the string and no alpha at all. `p` is not applied either; the app substitut

**Comment** — YES — twice, and it is the same tell as the `#where`/`#pname` instance: a correct citation of the wrong element.

1) The comment that installs the constant, PointWorlds.swift:237-241, sits directly above `WorldCue` (:248) and states the rule as the INVITATION line's, citing only invitation sites: "Every `world-*.js` draws one at `H-150` in 8.5px Space Mono at `A*0.38*(0.7+br*0.4)` while the hand is not yet engaged — world-one :183, world-two :225, world-three :235, world-four :269, world-five :434, world-six :428, world-seven :501. It is how the gesture is discoverable, and it is the ONE strin

**Evidence** — WHY THE VARIANT IS COLLAPSED, not ONE-MISSING or BOTH-WRONG. The design distinguishes world-one (0.28) from world-three and world-four (0.30); the app renders all three through one view at one hardcoded alpha, so the distinction is erased rather than mis-assigned. And the single value it collapses to is a sibling's — the invitation line's 0.38·(0.7+br·0.4) — which is the same shape as the known rail instance (`(1 - dom)` where the design has `(1 - dom*0.9)`, blurred toward its siblings).

Two things ride in with the collapse, both of which the design withholds from the farewell:
· BREATH. Design farewell alpha has no `br` term in any of the three; the app multiplies by `(0.7 + breath.value*0.4)`, so a line about a world that has closed now pulses with the body. The design gives breath to the invitation and to nothing else in that slot.
· PRESENCE. Design farewell uses raw `p`; the app us

**Refutation** — Survives every refutation path. DESIGN EXACT, in two independent copies: The Instrument v3.html:2564 `this.leaving*p*0.28`, :3075 `this.closing*p*0.30`, :3372 `this.easing*p*0.30`, matched byte-for-byte by Round 2/design-source world-one.js:192, world-three.js:243, world-four.js:276. A repo-wide grep for the three farewell strings returns ONLY these sites, so there is no alternate design source with different constants. APP EXACT: PointWorlds.swift:310/:568/:1071 read as quoted; `WorldCue` is declared once at :248 and its only alpha is hardcoded at :255 as `0.38*(0.7+breath.value*0.4)`; `spaceMonoTracked` (Theme.swift:151) sets font/case/tracking and no color, so `.opacity(fade)` multiplies that one constant and nothing else; all 12 WorldCue call sites use `WorldCue(text:)` — there is no a

### ONE-MISSING — `bottom-hint-caption-offset` · rows `F11.2`, `F11.3`
*The refutation corrected this from the checker's first verdict.*

**Design** — Both members confirmed at the cited sites, and the pair is corroborated in a second design file.

· `#ground .base` → `bottom:36px`
  /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4379
  `#ground .base{position:absolute;left:0;right:0;bottom:36px;text-align:center;font-family:"Space Mono",monospace;font-size:9px; letter-spacing:.18em;text-transform:uppercase;pointer-events:none}`
  Its span breathes (`:4383` `#ground .base span{animation:hint 6s ease-in-out infinite}`); the span is `#gbase`, whose text is `touch to receive` when unmet (`:5008`) and `tap anywhere to cross` when met (`:5013`) — ONE design element, two weathers.

· `#turn .foot` → `bottom:44px`
  /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4407
  `#turn .foot{position:absolute;left:0;right:0;bottom:44px;text-align:center;font-family:"Space Mono",monospace;font-size:9px; letter-spacing:.2em;text-transform:uppercase;color:rgba(237,232,227,.35);animation:hint 6s ease-in-out infinite}`
  Markup at `:4664` `<span class="foot">tap anywhere to stay</span>`.

No later rule overrides either bottom (grep of every `.base{`/`.foot{` in the file: the other five `.foot` rules are `#sheet/#still/#going/#thru/#wall`, none of which set `bottom`).

CORROBORATION — the same pair, same 

**App** — · `#turn .foot` → PORTED, wrong constant.
  /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:93-96
  ```
  Text("tap anywhere to stay")
      .spaceMonoTracked(9, em: 2 / 9)
      .foregroundStyle(BinduTheme.inkTertiary.opacity(0.4 + 0.4 * breath.value))
      .padding(.bottom, 40)
  ```
  40, not the design's 44. This is the ONLY foot site — `HubOverlay` (Components/HubOverlay.swift:14) is a thin adapter that returns `TurnOverlay`, so all eleven `.hubOverlay` call sites plus DoorView share this one line.

· `#ground .base` → SPLIT ACROSS TWO WEATHERS; neither half carries 36.
  (a) unmet — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:131-134
  ```
  Text("touch to receive")
      .spaceMonoTracked(9, em: 2 / 9)
      .foregroundStyle(room.opacity(0.62))
      .modifier(RiteBreathe())
  ```
  **NO bottom offset at all.** Its distance from the bottom is set by an APP-OWN element beneath it — `DoorView.swift:135-143`, the `not today · enter the field ›` escape, which carries `.padding(.top, 14).padding(.bottom, 40)`. That string appears nowhere in `Claude Design Round 1/` (grep "not today" → 0 hits). With the enclosing `VStack(spacing: 18)` the hint's bottom edge lands ≈83pt above the safe-area bottom (40 + button height ≈11 + 14 

**Comment** — NONE — and the absence is itself the survival mechanism, a different one from the `#where`/`#pname` instance.

There is no comment on either offset, and no comment on either member cites the other's design line. The complete set of design citations in the two files:
· DoorView.swift:184 — `soundEngine.spineThreshold(hz: 146)   // \`openTurn(){B.threshold(146)}\` — Instrument v3:5082`
· DoorView.swift:193 — `soundEngine.spineThreshold(hz: 220)   // \`crossDoor(){B.threshold(...)}\` — Instrument v3:5022`
· TurnOverlay.swift:72-73 — `// each row's mark drawn in its own hand — a small composition,

**Evidence** — NOT a transposition — check that first and discard it. TRANSPOSED would need 44 on the ground and 36 on the turn. Neither number is anywhere in either port. COLLAPSED at the element level also fails: 40 ≠ 34.

**BOTH-WRONG, each plausibly, each short of the design:**
| member | design | app | miss |
|---|---|---|---|
| `#turn .foot` | 44 | 40 (`TurnOverlay.swift:96`) | −4 |
| `#ground .base` (met) | 36 | 34 (`PracticeDoorView.swift:132`, `space24 + 10`) | −2 |
| `#ground .base` (unmet) | 36 | none (`DoorView.swift:131`) | absent |

No uniform conversion explains −4 and −2; they are independent guesses. `34` is not even written as a number — it is `BinduTheme.space24 + 10`, a token plus a nudge, which is what a value invented at the keyboard looks like rather than one read off a design.

**WHAT MAKES IT INVISIBLE, and it is the group's own thesis inverted.** The whySiblings note says 36 v

**Refutation** — VERIFIED AS QUOTED: `The Instrument v3.html:4379` `#ground .base{…bottom:36px…}` and `:4407` `#turn .foot{…bottom:44px…}`, no later override, frame 393x852 (`:4315`) so px=pt; `A Strange Feed.html:456` `bottom:44` and `:642` `paddingBottom:36` corroborate. App: `TurnOverlay.swift:96` `.padding(.bottom, 40)`; `DoorView.swift:131-134` carries no bottom offset, with the APP-OWN `not today · enter the field ›` at `:143`; `PracticeDoorView.swift:132` `.padding(.bottom, BinduTheme.space24 + 10)` = 34 (`Theme/Theme.swift:57`). Content stacks are inside the safe area (only backing color/atmosphere `.ignoresSafeArea()`). Not TRANSPOSED. F11.1/2/3 read as described; PracticeDoorView is absent from `Coverage/1-AUDIT-254.md`. DoorView's own header (`:8-9`) and `:101-103` confirm the met weather IS Pra

### ONE-MISSING — `canon-light-scene-wash-alphas` · rows `E1.13`, `E1.5`, `E1.6`

**Design** — All six read verbatim from `/Users/ashrey/Bindu Feed/canon/spine-light.js`, inside one if/else-if chain in `draw()`; the shared prefix is `var A=a*(1-this.arrive*0.35), p=this.arrive` (`:206`).

1. converge → `rgba(c, A*(0.20+p*0.45))` — `canon/spine-light.js:214` (per-mote fill, `c` = hex `#EDE3CE`)
2. warmth → `rgba([255,206,150], A*0.30*p)` — `:218` (radial, centre `W*0.5,H*0.86`, r `W*(0.30+p*0.80)`)
3. kindness → `rgba([255,232,200], A*0.16*p)` — `:223` (linear `0,H → 0,H*0.12`; ledges `A*0.10*p*(1-i/11)` at `:227`)
4. release → `rgba([255,244,226], A*0.24*p)` — `:232` (radial, centre `W*0.5,H*0.5`, r `max(W,H)*0.70`; rings `A*0.22*ok` at `:236`)
5. floor → `rgba(pc, A*0.18*p)` — `:239` (linear `W*0.5,0 → W*0.5,H*0.80`, `pc` = pool `#FBF9F4`), inside the `else if(id==='floor')` branch opened at `:237`
6. stillness/morning (else) → `rgba([255,238,214], A*0.20*p)` — `:244` (linear `0,H*0.86 → 0,H*0.20`)

**App** — The port is `LightDawnArrival` in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:722-782`, a `switch key` mirroring the design's chain. `A` is a local, hardcoded `let A = 1.0` at `:727`; `p` arrives as the view's `p` parameter.

1. converge → `col(bone, A * (0.20 + p * 0.45))` — `Screens/LightView.swift:744`. Own constant. `bone = [237,227,206]` (`:728`) = `#EDE3CE` = design's `c`. MATCHED.
2. warmth → `col([255, 206, 150], A * 0.30 * p)` — `:747`, radial centre `(W*0.5, H*0.86)`, r `W*(0.30+p*0.80)` (`:749`). Own constant, own geometry. MATCHED.
3. kindness → `col([255, 232, 200], A * 0.16 * p)` — `:751`, linear `(W*0.5,H) → (W*0.5,H*0.12)` (`:753`); ledges `col([255,236,208], A * 0.10 * p * (1 - Double(i)/11))` at `:757`. MATCHED.
4. release → `col([255, 244, 226], A * 0.24 * p)` — `:760`, radial centre `(W*0.5,H*0.5)`, r `max(W,H)*0.70` (`:762`); rings `col(bone, A * 0.22 * ok)` at `:767`. MATCHED.
5. floor → **NO APP SITE.** The `switch` at `:738` has cases for `converge`/`warmth`/`kindness`/`release` and a `default:`; there is no `case "floor"`. Nor could one fire: `LightDawnArrival` is instantiated only inside `case .dawn` of the material switch (`Screens/LightView.swift:154`, under `switch scene.material` at `:140`), and `floor` is the one `.nave` 

**Comment** — NONE in the code. Each app case comment paraphrases its OWN design comment, correctly paired:
· `:739` "// scattered motes drift into one field" ← `:211` "scattered motes drift into one field. He does not gather them."
· `:746` "// the heat reaches the hand before the eye" ← `:216` "the heat reaches the hand before the eye"
· `:750` "// light rises from behind, onto what he built" ← `:220` "the light rises from BEHIND him, onto what he already made"
· `:759` "// brightens one ring per opened hand" ← `:230` "it brightens each time the hand opens. Not when it reaches."
· `:769` "// morning: the 

**Evidence** — METHOD: read `canon/spine-light.js:206-246` verbatim; grepped the app tree for each constant, each colour triple, and each geometric term; traced the mount path of the only `p` consumer; grepped repo-wide for `0.18 * p` / `A * 0.18` / `FBF9F4`; read every comment above every app site; grepped `Coverage/1-AUDIT-254.md`, `Coverage/2-MECHANISM-SWEEP.md` and `AUDIT.md` for the owning rows.

WHAT MAKES THE NOT-PORTED CALL CERTAIN RATHER THAN "COULD NOT FIND IT":
1. `switch key` at `Screens/LightView.swift:738` has four named cases plus `default:` — enumerable in full, no `floor`.
2. `grep -rn "arrivalProgress"` over the whole app returns two hits only: the definition (`LightView.swift:89`) and the single call (`:154`). The design's `p` therefore reaches exactly one view.
3. That call sits inside `case .dawn:` (material switch opened at `:140`, `.nave` case at `:157`), and `Light/LightCanon.sw

**Refutation** — SURVIVES. Both sides read verbatim as quoted. Design: `canon/spine-light.js:206` = `var A=a*(1-this.arrive*0.35), p=this.arrive, id=this.scene.id;`; the six branches are at :214, :218, :223 (ledges :227), :232 (rings :236), :239 (inside `}else if(id==='floor'){` at :237), :244. `:247` is `x.restore();`, so AUDIT's cited `:206-247` does span the floor branch. App: `Screens/LightView.swift:722-782`, `A = 1.0` at :728, `switch key` at :738 with four named cases plus `default:` and NO `floor`.

The floor's absence is certain, not a failed grep: (1) the switch is enumerable in full; (2) `grep -rn arrivalProgress "Bindu Feed"` returns exactly two hits — the definition (:89) and the single call (:154); (3) :154 is inside `case .dawn:` of the material switch opened at :140, and `LightCanon.swift:2

### ONE-MISSING — `compose-breath-keyframe-opacities` · rows `D7.6`, `F9.1`

**Design** — Member A — `@keyframes arrivalBreath` → floor 0.34 / peak 0.62, at `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Ash's Compose.html:29`. Consumer site `:151` — the top arrival-light radial gradient (`radial-gradient(ellipse 120% 50% at 50% 27%…)`, `:148-153`), animated `arrivalBreath 12s ease-in-out infinite` only while idle (`l < 0.02 && !released`).
Member B — `@keyframes hintFade` → floor 0.26 / peak 0.55, at `…/Ash's Compose.html:30`. Consumer site `:249` — the Space-Mono hold hint caption under the ember (`:244-250`), animated `hintFade 4.8s ease-in-out infinite` while `armed && l < 0.02`.
(Sibling not in the group, checked as a control: `@keyframes emberWake` `:31` → scale 0.97 / 1.045, used `:242`.)

**App** — Member B (hintFade) — PORTED, CORRECT: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshComposeView.swift:449-454`
    private struct HintFade: ViewModifier {
        let active: Bool
        @EnvironmentObject private var breath: Breath   // the one master breath
        func body(content: Content) -> some View {
            content.opacity(active ? (0.26 + 0.29 * breath.value) : 1)
        }
    }
`breath.value` is the raised-cosine 0→1 swell (`Instrument/Breath.swift:55-58`), so the range is exactly 0.26 → 0.55 — its OWN member's floor and peak. Applied at `:254` `.modifier(HintFade(active: armed && progress < 0.02))`, same gate as the design's `armed && l < 0.02`.

Member A (arrivalBreath) — NO PORT. The app's arrival light is `AshComposeView.swift:112-131` (`private var arrivalLight`), a ZStack of the two RadialGradients from `Ash's Compose.html:148-160`. The gradient stops are ported faithfully (`0.09 + progress * 0.19`, `0.03 + progress * 0.05`, `0.05 + progress * 0.11` — matching `:150` and `:157` verbatim), but there is **no opacity animation of any kind on it**: it is inserted bare at `:70` (`arrivalLight`), carries no `.modifier(...)`, no `breath` read, and the constants 0.34 and 0.62 appear nowhere in the file as a breath range. `grep -rni "arrivalbreath"` o

**Comment** — NONE. Neither member's app site carries a design citation at all, so there is no cross-cited comment of the `#where`/`#pname` kind. Member B's comments are a bare `// MARK: - Hint fade modifier` (`:447`) plus the inline `// the one master breath` (`:451`); Member A's is a bare `// MARK: - Arrival light` (`:110`). The only comment in the file that cites this comp is F9.1's ring block at `:212-218` — "`Claude Design Round 1/comps/Ash's Compose.html:73-83` — `const R = 31` inside an `svg 80×80`" — which is that element's OWN line and is correct.
One near-miss ruled out: `:253` puts `accent.opacit

**Evidence** — Files and sites:
· Design: `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Ash's Compose.html:29` (arrivalBreath), `:30` (hintFade), `:31` (emberWake), uses at `:151`, `:249`, `:242`; hint colour `:248`; arrival-light gradients `:148-160`.
· App: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshComposeView.swift` — `arrivalLight` `:112-131` used at `:70`; `HintFade` `:449-454` applied `:254`; `EmberWake` `:439-444` applied `:242`.
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/Breath.swift:55-58` — `value` is the eased 0→1 raised cosine, confirming `lo + span * breath.value` reaches exactly `lo+span` at crest.

Why this is an omission and not a deliberate architectural choice: the app already owns this exact idiom for the structurally identical surface one screen over. `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:149` reads 

**Refutation** — Survives every refutation attempt. Design verbatim: "Claude Design Round 1/comps/Ash's Compose.html:29" arrivalBreath 0.34/0.62, ":30" hintFade 0.26/0.55, ":31" emberWake; consumers ":151" (arrivalBreath 12s, gated l<0.02 && !released), ":249" (hintFade 4.8s), ":242". App: HintFade at "Bindu Feed/Bindu Feed/Screens/AshComposeView.swift:449-454" is 0.26 + 0.29 * breath.value = exactly 0.26...0.55 (Breath.swift:53-55 confirms value is an eased 0->1 cosine), applied at :254 under the same armed && progress<0.02 gate — its OWN member, correct. Member A absent: arrivalLight (:112-131) ports the gradient stops faithfully but is inserted bare at :70 with no modifier; the entire file contains exactly two breath references (:441 EmberWake, :451 HintFade); grep -rni arrivalbreath over the app source

### ONE-MISSING — `fieldsound-bed-duck` · rows `E4.3`, `G1.1`, `G1.2`, `G3.1`, `G3.3`

**Design** — how far the bed ducks for each event — the two members are distinguished ONLY by depth (both restore to 0.030), so depth is the whole content of the group.

MEMBER A — voice(), "the bed steps back while a presence speaks"
  value: bg.linearRampToValueAtTime(0.018, t+c.atk)
  site: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/field-sound.js:133
  (the full duck block is :131-135 — cancelScheduledValues(t), duck to 0.018 at t+c.atk, restore to 0.030 at t+life+1.6)

MEMBER B — bowl(), "the bed holds its breath for the strike"
  value: bg.linearRampToValueAtTime(0.006, t+1.2)
  site: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/field-sound.js:169
  (full block :168-169 — cancelScheduledValues(t), duck to 0.006 at t+1.2, restore to 0.030 at t+9)

Depth ratio in the design: voice ducks to 0.6 of rest, bowl to 0.2 of rest — a factor of three between a voice and a strike.

**App** — MEMBER B (bowl, 0.006) — PORTED, WITH ITS OWN CONSTANT. Correct.
  /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/RiteTones.swift:46-49
    static let bedRest: Double = 0.030
    static let bedDucked: Double = 0.006
    static let duckInSeconds: Double = 1.2
    static let duckOutSeconds: Double = 9.0
    static var duckFactor: Double { bedDucked / bedRest }
  /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1582 `func duckBreath()` — applies `from * BowlVoicing.duckFactor` as a ratio on the bed's crossfadeLevel, ramping in over duckInSeconds and back over duckOutSeconds. Depth, in-time and out-time all match :168-169.
  Called from exactly two places: `riteBowl` (SoundEngine.swift:1353-1356) and `riteThreshold` (SoundEngine.swift:1045-1048). Pinned by SoundLayerTests.bedDuckRatio.

MEMBER A (voice, 0.018) — NOT PORTED. The duck does not exist.
  The port of `voice()` is `func presence(_ key: RoomKey, dur: Double? = nil)` at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1155-1163. It ports the CHAR body faithfully — pitch from RoomKey.hz, gain/atk/rel/pan/partials/flicker/air/shimmer/gliss/vib via `.presence(c)` — and then returns. It never touches the bed.
  `playCeremony` (SoundEngine.swift:1373) does no ducking; it only atta

**Comment** — No strict cross-citation: no comment on one member cites the other member's design line. duckBreath()'s comment cites the bowl's own lines correctly. But two comment faults of the same family are present.

1. A CITATION THAT POINTS AT NOTHING — RiteTones.swift:44-45, justifying the bowl's `bedRest`:
   "The bed's resting gain is `0.030` (`field-sound.js:56`), so the duck is a fall to one fifth and a slow return."
   field-sound.js:56 is `if(this.ctx.state==='suspended')this.ctx.resume();`. The 0.030 is three lines later at :59 — `var g=this.ctx.createGain(); g.gain.value=0.030;`. Same function

**Evidence** — DESIGN, read in full at /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/field-sound.js:

:131-135  if(this.bed){ // the bed steps back while a voice speaks, then returns
            var bg=this.bed.g.gain; bg.cancelScheduledValues(t);
            bg.linearRampToValueAtTime(0.018,t+c.atk);
            bg.linearRampToValueAtTime(0.030,t+life+1.6);
          }
:168-169  if(this.bed){var bg=this.bed.g.gain; bg.cancelScheduledValues(t);
            bg.linearRampToValueAtTime(0.006,t+1.2); bg.linearRampToValueAtTime(0.030,t+9);}
:59       var g=this.ctx.createGain(); g.gain.value=0.030;   ← the rest level (NOT :56)
:139-151  threshold() — no duck block anywhere in the function.

APP:
Sound/RiteTones.swift:46      static let bedDucked: Double = 0.006        ← member B, own constant
Sound/SoundEngine.swift:1582  func duckBreath()                            ← the only duck in the app
Sound/S

**Refutation** — Verified independently; I could not refute it.

DESIGN reads exactly as quoted. `Claude Design Round 1/comps/field-sound.js:131-135` is the voice duck (`bg.linearRampToValueAtTime(0.018,t+c.atk)` at :133, restore `0.030` at `t+life+1.6` at :134); `:168-169` is the bowl duck (`0.006` at `t+1.2`, `0.030` at `t+9`). Rest level is at `:59` (`g.gain.value=0.030`), and `:56` is indeed `if(this.ctx.state==='suspended')this.ctx.resume();` — the RiteTones citation does point at a line carrying no number. `threshold()` at :139-151 has no duck block.

NO DIVERGENT DESIGN SOURCE. All three copies of field-sound.js (Round 1 root, Round 1 comps, Round 2 design-source) are line-identical at :133/:134/:169. A second, independent source agrees: `Claude Design Round 2/comps/The Sound.html:270` also ducks to

### ONE-MISSING — `fieldsound-default-durations` · rows `E4.1`, `G3.1`
*The refutation corrected this from the checker's first verdict.*

**Design** — Verified all six at the cited sites in /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/field-sound.js:
1. threshold() → hz||198, dur||5 — :140
2. openTheRoom() → dur||5 (ramps this.nave.gain → 0.85 at t+dur, :236) — :225
3. closeTheRoom() → dur||6 (ramps this.nave.gain → 0 at t+dur) — :242
4. breathIn() → dur||6 — :252
5. veilLift() → dur||3 — :276
6. lightOff() → dur||5 (ramps this.lightNode.g.gain → 0, stops o/o2/lfo at +0.2) — :310-311
Also load-bearing and NOT in the member list: darkReturns() :315-321 calls this.lightOff(5) internally and touches the nave NOT AT ALL. So on the design's leave path (The Light v2.html:801 — `Sound.closeTheRoom(6); Sound.darkReturns();`) the NAVE closes over 6 and the LIGHT TONE fades over 5. Two members, two nodes, two numbers.

**App** — 1. threshold → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift:1009 `func fieldThreshold(hz: Double, dur: Double)` and :1076 `fieldThresholdVoice(hz:dur:)` — NO DEFAULTS on either parameter. Neither 198 nor 5 appears. All seven call sites pass explicitly (ReturnView.swift:193 dur 7; RiteView.swift:106/110/114 → 6/7/7; UniverseView.swift:225/516/629 → 9/9/6).
2. openTheRoom → SoundEngine.swift:1180 `func lightOpenTheRoom(dur: Double = 8.5)` — design default is 5. 8.5 is the design's convolver TAIL length from :228 (`_air(8.5,0.62)`), a different quantity on a different line, which also equals the Light comp's caller argument.
3. closeTheRoom → NO PORT. No `lightCloseTheRoom` / `closeRoom` anywhere in the tree; the only hits are comment text.
4. breathIn → SoundEngine.swift:1197 `func lightBreathIn(dur: Double = 6)` — MATCHED.
5. veilLift → SoundEngine.swift:1221 `func lightVeilLift(dur: Double = 3)` — MATCHED.
6. lightOff → SoundEngine.swift:1258 `func lightOff(dur: Double = 5)` — default matches, but it is DEAD: the one and only call site is /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:412 `soundEngine.lightOff(dur: 6)`.
Support: SoundEngine.swift:1331 `func darkReturns(dur: Double = 7)` does NOT call lightOff (the design's does, a

**Comment** — YES — three of them, and the primary one is the exact known shape: a comment on member A citing member B's design line to justify A's number.

LightView.swift:405-411, the comment directly above `soundEngine.lightOff(dur: 6)`:
  "`closeTheRoom(6)` is the FIRST half and was still missing after that fix: the room tone kept sounding for its own 40s release wherever he went next. It is the same mechanism as `field-sound.js:307 lightOff(dur)` under a second name — both cancel the schedule and ramp the room's gain to zero — and the two files carry different defaults (6 and 5), so the Light's own num

**Evidence** — THE INSTANCE, stated as the fault class:

The design has TWO removal members on the leave path, on two different nodes, with two different constants — closeTheRoom(nave gain → 0, dur||6, :238-243) and lightOff(lightNode gain → 0, dur||5, :307-312). The app has ONE function. At the single leave site (LightView.swift:412) it passes **6** — closeTheRoom's constant — to **lightOff**, whose own design constant is 5. The right number, on the wrong sibling.

What makes it invisible, point by point against the known instance:
· Not dropped, not wrong. Both 6 and 5 are in the file; 5 sits in the signature at SoundEngine.swift:1258 looking correct and is never reached.
· Two adjacent removal calls. A reader sees `lightOff(dur: 6)` beside a signature defaulting to 5 and reads a deliberate override.
· The comment on the closeTheRoom obligation cites `field-sound.js:307`, which is lightOff's line, an

**Refutation** — Every quoted line is real — I opened both ends. Design: field-sound.js:140 `hz=hz||198; dur=dur||5`, :225 `dur=dur||5`, :242 `t+(dur||6)` on `this.nave.gain`, :252 `dur=dur||6`, :276 `dur=dur||3`, :310 `t+(dur||5)` on `n.g.gain`, :318 `this.lightOff(5)` inside `darkReturns` whose own ramps are all `t+7`. App: SoundEngine.swift:1009/1076 (no defaults), :1180 `= 8.5`, :1197 `= 6`, :1221 `= 3`, :1258 `= 5`, :1331 `= 7`; LightView.swift:412 `lightOff(dur: 6)`. The comment at LightView.swift:405-411 and its source Coverage/11-COMP-BLIND-SPOT.md:82-87 do misidentify the two members, and "both cancel the schedule and ramp the room's gain to zero" is false — :242 moves the nave, :310 moves lightNode. That much survives.

But the verdict COLLAPSED does not, because its three supports fail:

(1) "cl

### ONE-MISSING — `gold-caption-opacity` · rows `D2.4`, `D5.1`, `D5.8`
*The refutation corrected this from the checker's first verdict.*

**Design** — Both members are the `#sheet` panel's captions, and the sheet is register VII · THE DANCE ("the reading, caught in flight").

A · `#sheet .st` → `color:#D4A94B; opacity:.72` (Space Mono 8.5px, .22em, uppercase) — `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4444`. Its text is set at `:5128`: `sheet.querySelector('.st').textContent='VII · THE DANCE'`.

B · `.sec .lab` → `color:#D4A94B; opacity:.66` (Space Mono 8px, .2em, uppercase, margin-bottom 7px) — same file, `:4449`. Written at `:5169` inside `landSection`.

CONFIRMED SIBLINGHOOD, and it is stronger than the group note claims. `.sec` is shared by all five reading panels (`#still` `:5164`, `#going` `:5188`, `#thru` `:5216`, `#wall` `:5244`, `#sheet` `:5169` — every one does `d.className='sec'`), but four of them OVERRIDE `.lab` by ID at higher specificity: `#still .lab` `rgba(237,230,214,.60)` (`:4475`), `#going .lab` `rgba(185,165,232,.64)` (`:4497`), `#thru .lab` `rgba(125,116,201,.74)` (`:4521`), `#wall .lab` `rgba(224,113,63,.78)` (`:4546`). So `.sec .lab` at `:4449` reaches exactly one panel — `#sheet` — which is why it is gold, and why it is A's sibling and nobody else's. The four overrides also state their weight as an ALPHA inside the colour; only the two gold ones state it as a separate `opac

**App** — A · `#sheet .st` — **NO APP EXPRESSION.** The eyebrow element does not exist in any of the seven app readings. `ReadingHead` (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:237-251`) is the whole head of every reading and renders three things: a `‹` chevron (`:244`), `star.t` in Lora 24 (`:246`), `star.ti` in Lora italic 14 (`:247`). There is no fourth line and no slot for one. Searches that came back empty: `grep -rn "THE DANCE"` in the reading code → only MARK comments; `grep -rn "\.roman"` app-wide → two hits, `AxisModel.swift:38` (the model field) and `PointWorlds.swift:202`. `PointWorlds.swift:202` renders `"\(dim.roman) · \(dim.name.uppercased())"` — the same *words* — but it is a different element: the LEVEL-0 universes header (the port of `uni .ud`, `point-levels.js:151`), drawn above the constellation, not inside a reading. It carries `.foregroundStyle(hue)` with **no opacity constant at all**, so even the near-miss does not hold .72.

B · `.sec .lab` — ONE app site, `PointReadings.swift:214-215`:

    Text(section.label.uppercased()).spaceMonoTracked(9, em: 0.17)
        .foregroundStyle(hue.opacity(0.7))

in `private struct SectionBlock` (`:206-223`), the single shared section renderer, called from all seven readings (`:362, :469, :564, :730,

**Comment** — NONE — and the absence is itself the tell, a different escape route from the known `#where`/`#pname` instance.

There is no comment on `SectionBlock` at all. `PointReadings.swift:204-215` reads in full:

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
   

**Evidence** — VERDICT REASONING, and the caveat that makes ONE-MISSING an understatement by exactly one number.

A is silently absent: the eyebrow element has no app expression, no slot, and no comment recording that it was dropped. B has an app expression that carries **0.7, not its own .66** — so this is ONE-MISSING with the survivor also wrong. It is not TRANSPOSED (A has no site to hold B's value, and 0.7 ≠ .66 in either direction), not COLLAPSED in the pair's own terms (the two are not given the same value — one is given nothing), not BOTH-WRONG (A carries no number to be wrong), and not NOT-PORTED (a label element does render and does carry a constant). ONE-MISSING is the closest true fit; I am not softening the survivor's error to make it fit.

Not UNCLEAR: I located B's site definitively and established A's absence by exhaustion, not by failing to find it — `ReadingHead` is the only head, `Sec

**Refutation** — The verdict LABEL survives but the finding as written does not: its siblinghood proof is refuted by a CSS-cascade error, and the escalation built on it is false.

VERIFIED TRUE. Both design lines read verbatim (`:4444` `#sheet .st ... color:#D4A94B;opacity:.72`; `:4449` `.sec .lab ... color:#D4A94B;opacity:.66`). `PointReadings.swift:214-215` reads verbatim `hue.opacity(0.7)`, one definition, seven call sites (`:362,469,564,730,941,1086,1263`). A really is absent: `ReadingHead:237-251` renders only chevron/Lora-24 title/Lora-italic-14 subtitle at all seven call sites (`:360,467,562,728,935,1084,1261`). `PointWorlds.swift:202` is confirmed a different element — it sits in `PointUniversesView`, the port of `.uhead .ud` (`point-levels.js:20`, `color:var(--hue)`, no opacity). And 0.7 is unsour

### ONE-MISSING — `ground-italic-sizes` · rows `F11.2`
*The refutation corrected this from the checker's first verdict.*

**Design** — Three members, three distinct sizes, one block:

1. `#ground .under` → `font-size:16px` (italic, line-height 1.6, `rgba(237,232,227,.60)`, max-width 280, margin-top 20)
   · /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4368
   · restated verbatim inline at /Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:633 (`fontSize:16,lineHeight:1.6,color:'var(--ink60)',maxWidth:280,marginTop:20`)
   · rendered only in the unmet weather: `'<p class="under">It is not complete until you meet it.</p>'` — The Instrument v3.html:5007

2. `#ground .sub` → `font-size:14px` (italic, letter-spacing .05em, accent @ .70)
   · /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4372
   · restated at A Strange Feed.html:526 and at /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Practice Door.html:155-159
   · rendered as the practice kind's sub-line — The Instrument v3.html:1648

3. `#ground .line` → `font-size:15px` (italic, line-height 1.7, `rgba(237,232,227,.60)`, max-width 290)
   · /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4377
   · restated at A Strange Feed.html:520 and at Practice Door.html:137-138 (`fontSize: 15, lineHeight: 1.7, … maxWidth: 290`)
   · rendered as the story kind's pull-quote — Th

**App** — 1. `#ground .under` → the unmet door's under-line, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:127-129
   `Text(RiteWord.arrivalNotDone)` · `.font(.lora(13)).italic().foregroundStyle(BinduTheme.inkTertiary)` — **13pt, ink .35**, not 16 / ink .60.
   Same treatment repeated at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteView.swift:179-181 (`.lora(13)).italic()`, inkTertiary).
   The 13 traces to a DIFFERENT design: /Users/ashrey/Bindu Feed/Claude Design Round 1/The Rite v3.html:1296 gives this same sentence `fontSize:12.5,color:'var(--ink35)',maxWidth:230` in Movement I — the app ported the Rite's arrival, never the ground's.

2. `#ground .sub` → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:183-188
   `Text(sub).font(.loraItalic(14)).tracking(0.7)  // 0.05em x 14` · `.foregroundColor(accent.opacity(0.70))` — **14pt. Its own constant. Correct.**

3. `#ground .line` → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:234-241
   `Text("\u{201C}\(story.excerpt)\u{201D}")` · `.font(.loraItalic(14))` · `.foregroundColor(BinduTheme.inkSecondary)` · `.frame(maxWidth: 290)` — **14pt where the design says 15.**
   Everything else on this line is its own: `maxWidth: 290` is `.line`'s exact m

**Comment** — NONE of the known shape — and the absence is itself the tell.

The one comment in the block is on the `.sub`, at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:178-180:

  "// Practice Door.html:146,155-159 — the sub-line is the last child of the
   // SAME centred stack as the body, at the container's own gap of 22, so it
   // rises with the body on the shared fade rather than on a timer of its own."

I verified that citation line by line: Practice Door.html:146 IS the flex container with `gap: 22`, and :155-159 IS the sub-line's own `<span>` carrying `fontSize

**Evidence** — WHAT WAS CHECKED, AND HOW.

The group's three members are the ground's italic under-lines in the two weathers: `.under` in unmet, `.sub` and `.line` in met. The app splits them across two files because DoorView.swift:100-103 delegates the met weather whole to PracticeDoorView, so `.sub` and `.line` live in PracticeDoorView and `.under` in DoorView.

THE FINDING — COLLAPSED, on `.sub` / `.line`:
The design distinguishes them 14 / 15 in three independent sources (The Instrument v3.html:4372 / :4377; A Strange Feed.html:526 / :520; Practice Door.html:155-159 / :137-138). The app renders both at `.loraItalic(14)` (PracticeDoorView.swift:185 and :236). This is not a dropped value: the `.line` site carries `maxWidth: 290` and `inkSecondary` (= `#EDE8E3` @ .60, Theme.swift:34), which are `.line`'s own max-width and its own ink60 — every property except the size is its own. A reader comparing th

**Refutation** — Design lines verified verbatim: Instrument v3 :4368/:4372/:4377 = 16/14/15, restated at A Strange Feed :633/:526/:520 and Practice Door :137/:157. App sites verified: PracticeDoorView.swift:185 and :236 are both .loraItalic(14). The :236 site IS the door pull-quote (curly quotes, italic, maxWidth 290 = .line's exact max-width, inkSecondary = #EDE8E3@.60 per Theme.swift:34 = .line's exact ink). No recorded divergence: no row in 1-AUDIT-254.md owns these constants and HANDOFF-RULINGS.md has no type-scale ruling. So the FACT that .line renders 1pt short of all three sources is real. But COLLAPSED does not survive, for three reasons.

(1) THE CAUSAL STORY IS UNSUPPORTED AND A BETTER SOURCE EXISTS. The finding's load-bearing claim is "the uncited sibling took the cited sibling's number." The tw

### ONE-MISSING — `ground-measures` · rows `C5.6`, `F11.2`
*The refutation corrected this from the checker's first verdict.*

**Design** — Round 1 · The Instrument v3.html (`#ground .field{padding:0 32px}` at :4363 → 329pt of measure on a 393 phone):
· `#ground h1` → `max-width:300px` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4367
· `#ground .under` → `max-width:280px` — same file :4368
· `#ground .say` → `max-width:300px` — same file :4370
· `#ground .line` → `max-width:290px` — same file :4377
Corroborated independently by the Round 2 source the app was actually built from, /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Practice Door.html — `maxWidth: 300` on the say body at :152, `maxWidth: 290` on the story line at :138, `padding:'0 32px'` on the field at :247. The two designs agree on every number, so there is no "the app followed the other comp" defence.
Note the fifth element in the same block: `#ground .found h2` (:4376) carries NO max-width in either design — it is deliberately unconstrained, taking the field's own 329.

**App** — The `#ground` block is split across two app files — unmet weather in DoorView, met weather in PracticeDoorView (DoorView.swift:98-99 hands `.met` straight to `PracticeDoorView`).

· `#ground h1` (300) → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:120-124. The h1 STRING (`RiteWord.arrivalMeeting` = "One story has come to meet you.", Rite/RiteContent.swift:193) is at :120-121; the app has demoted it to a 15pt italic kicker and promoted `storyData.title` to the head at :122-124. **Neither line carries any `.frame(maxWidth:)`.** NO CONSTANT PORTED.
· `#ground .under` (280) → Screens/DoorView.swift:127-129, `Text(RiteWord.arrivalNotDone)` = "It is not complete until you meet it." (RiteContent.swift:194). **No `.frame(maxWidth:)`.** NO CONSTANT PORTED.
  Both are governed only by the shared `.padding(.horizontal, 40)` at DoorView.swift:145 → one identical 313pt measure for the head and the italic line under it.
· `#ground .say` (300) → Screens/PracticeDoorView.swift:202-210, `proseBody(_:italic:)`, the render for the threshold / practice / gaiaSeed bodies. `.frame(maxWidth: 320)` at **:209**. WRONG CONSTANT — 320, not 300, and 320 appears nowhere in either design.
· `#ground .line` (290) → Screens/PracticeDoorView.swift:235-241, the story excerpt in curly quot

**Comment** — NONE of the exact `#where`/`#pname` shape — no comment on one member cites another member's design line, because **three of the four app sites carry no comment at all** (PracticeDoorView.swift:209, :233, :241 are bare; DoorView.swift:120-129 has nothing but "the air rises — something is coming to meet you" at :115). There is no citation to be wrong.

But the one comment in the neighbourhood is worth quoting, because it is what a reader would follow and it walks past the fault:

  Screens/PracticeDoorView.swift:177-180 —
  "// Practice Door.html:146,155-159 — the sub-line is the last child of t

**Evidence** — FOUR MEMBERS, FOUR DIFFERENT OUTCOMES — and only one is right.

1 · `.line` 290 → 290. MATCHED (PracticeDoorView.swift:241).
2 · `.say` 300 → **320** (PracticeDoorView.swift:209). Wrong number, and 320 is not any sibling's value — it is invented.
3 · `h1` 300 → no constant (DoorView.swift:122-124).
4 · `.under` 280 → no constant (DoorView.swift:127-129).

WHY THIS IS COLLAPSED AND NOT ONE-MISSING. The design's whole point in this block is that the two italic lines are set NARROWER than the thing they sit under — `.under` 280 beneath h1's 300, `.line` 290 beneath the h2 it follows. The app has collapsed that distinction in both weathers, twice, in two different ways:

· **Unmet.** h1 and `.under` both lost their constants and now share one measure — `.padding(.horizontal, 40)` at DoorView.swift:145 → 313pt for both. The design gave them 300 and 280 inside a 329 field. So `.under`, the lin

**Refutation** — Half the finding is real; the half carrying the COLLAPSED verdict is mis-paired against the wrong comp.

VERIFIED AS QUOTED. Every design line reads exactly as claimed — The Instrument v3.html:4363 (`padding:0 32px`), :4367 (300), :4368 (280), :4370 (300), :4376 (h2, no max-width), :4377 (290). Round 1 and Round 2 design-source `#ground` blocks are byte-identical (diff clean), so no "other comp" defence exists for the met half. Practice Door.html:152 = `maxWidth: 300`, :138 = `maxWidth: 290`, :247 = `padding:'0 32px'`, and its story `<h2>` at :132-135 genuinely carries no maxWidth. App sites read as quoted: PracticeDoorView.swift:209 `.frame(maxWidth: 320)`, :233 `.frame(maxWidth: 320)`, :241 `.frame(maxWidth: 290)`. `320` appears nowhere in Practice Door.html or The Rite v3.html — it is i

### ONE-MISSING — `ground-weather-primary-glow` · rows `B0.6`, `B3.3`, `B3.4`, `B3.5`, `C4.3`, `C5.2`, `C5.6`, `F11.2`
*The refutation corrected this from the checker's first verdict.*

**Design** — Member A — "unmet · light not yet risen" → 0.34. `Claude Design Round 1/The Instrument v3.html:1600`: `g1.addColorStop(0,hexa(TODAY.color,0.34*p*(0.7+br*0.4)));` on a radial centred at `W*0.5,-H*0.08` r `H*0.62` (`:1599`). Secondary stop `:1601` = `0.10*p` at 0.42.
Member B — "met · the light has passed" → 0.26. `:1620`: `wg.addColorStop(0,hexa(DAWN,0.26*p*(0.7+br*0.4)));` on a radial centred LOW at `W*0.5,H*1.06` r `H*0.46` (`:1619`). Secondary stop `:1621` = `hexa('#8A5A3C',0.11*p)` at 0.38; the met branch's TOP glow is the faint one, `:1624` `hexa(TODAY.color,0.08*p)` at `H*0.14`.
Both are drawn by `Ground.drawWeather` (`:1595-1631`), called once from the axis loop at `:5600` gated on `gp = S.presence(5,Z)`. The same pair exists a second time in Round 1's Door comp: `Claude Design Round 1/A Strange Feed.html:593` (unmet `TODAY.color,0.36` / `0.10` at 42%) and `:603` (met `DAWN,0.26` / `#8A5A3C,0.11` at 38%, at `50% 106%`), with the faint top glow at `:606` (`0.08`). So the met member reads 0.26 in BOTH sources; the unmet member reads 0.34 (Instrument) / 0.36 (Strange Feed).

**App** — Member A (unmet) → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:111-112`, inside `unmetDoor`:
  `RadialGradient(colors: [room.opacity(0.16), room.opacity(0.03), .clear], center: UnitPoint(x: 0.5, y: -0.08), startRadius: 0, endRadius: 520)`
  The centre `-0.08` is the design's verbatim (`-H*0.08` / `at 50% -8%`) — this IS the port. The alpha is **0.16**, not 0.34/0.36. The secondary is 0.03, not 0.10. The breath term `*(0.7+br*0.4)` is absent — the glow is static. The 1px breathing horizon line (`:1603-1606`, `0.50*p*(0.6+br*0.5)`) and the bottom dark cap (`:1607-1609`, `0.88*p`) are also absent.

Member B (met) → `DoorView.swift:100-103` delegates the met weather whole to `PracticeDoorView`; the glows are `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:141-162`:
  `:143-148` top glow `accent.opacity(0.14)` / `0.035`, centre `(0.5, 0.22)`, r 480, `:149` `.opacity(0.34 + 0.44 * breath.value)`
  `:151-156` low glow `accent.opacity(0.08)`, centre `(0.5, 1.12)`, r 440
  The low glow is the structural counterpart of member B (low, behind, `accent` = `#C9A07A` DAWN for the threshold kind, `:322`). It carries **0.08**, not 0.26 — and the design's `#8A5A3C,0.11` mid-stop has no port at all. The app's BRIGHTEST glow sits at the TOP (

**Comment** — NONE — and the absence is itself the tell here, in the mirror-image of the known instance.

Neither app site carries a design citation of ANY kind. `DoorView.swift:111-112` has no comment at all above the gradient (`:108` is `let room = storyData.roomColor   // today's real story's room colour`; `:114` is `// the air rises — something is coming to meet you`). `PracticeDoorView.swift:141-162` likewise: the only comments are `:149` `// the one master breath` and `:158` `// the air settles — the day's light has passed`, both prose, neither naming a file or a line.

So where C5.2/C5.6 failed by a 

**Evidence** — FILES READ (all absolute):
· `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html` — `:1490-1519` the feed-ground preamble (*"Everything here is lifted from the Door as built — the two weathers… Nothing is reworded."*); `:1595-1631` `drawWeather`; `:5600` the call site.
· `/Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:586-608` — the same two weathers as CSS, unmet `0.36`/`0.10`, met `DAWN 0.26`/`#8A5A3C 0.11`, top glow `0.08`.
· `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Practice Door.html:29-32,220-231` — the comp the app's met door actually came from.
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:100-115`
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:141-162,178,322`
· `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:692-760,1006-1017`
·

**Refutation** — Member A survives; member B is a false pairing that would send a fixer to break a CORRECT constant.

CONFIRMED. All design lines read exactly as quoted: `Claude Design Round 1/The Instrument v3.html:1599-1601` (unmet, radial at `W*0.5,-H*0.08` r `H*0.62`, `0.34*p*(0.7+br*0.4)`, `0.10*p` at 0.42) and `:1619-1624` (met, radial at `W*0.5,H*1.06` r `H*0.46`, `0.26*p*(0.7+br*0.4)`, `#8A5A3C 0.11*p` at 0.38, faint top glow `0.08*p`). `A Strange Feed.html:593,603,606` likewise (unmet 0.36/0.10, met DAWN 0.26/#8A5A3C 0.11, top 0.08). Both app sites read exactly as quoted.

MEMBER A HOLDS. `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:111-112` is genuinely the unmet member's port: the `UnitPoint(x: 0.5, y: -0.08)` centre is unique to this design object (grep for `50% -8%` /

### ONE-MISSING — `immersion-body-leading` · rows `B5.1`, `B5.8`, `C3.8`, `C5.8`, `E1.17`, `E1.3`
*The refutation corrected this from the checker's first verdict.*

**Design** — All three from `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html`:

· `.imm .bd` → `font-size:16.5px!important; line-height:1.86!important` — :4583
· `#word p`  → `font-size:18px; line-height:1.78` — :4596
· `#lite .anc` → `font-size:16.5px; line-height:1.86` — :4609

The 2-of-3 split, stated as a relation: the fall (`#word p`) is 1.5px LARGER and 0.08 TIGHTER than the other two, which are identical to each other. `.imm` is a class toggled onto whichever reading surface is immersed (`:5506` — `READS.forEach(el=>el.classList.toggle('imm', IMM.on && el===IMM.el))`, over `READS=['still','going','thru','wall','sheet','word','lite']` at `:5265`), so `.imm .bd` is the register readings' body lifting 14.5/1.76 (`:4450`, `:4477`, `:4500`, `:4523`, `:4549`) → 16.5/1.86 on entry.

**App** — · `.imm .bd` → **NO PORT.** The immersed type lift does not exist anywhere in the app. `IMM.on` IS ported — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisTravel.swift:77` `var immersed: Bool { pieceOpen && immA > Immersion.onThreshold }` — and has **zero production readers**: the only references in the whole target are `ImmersionTests.swift:236,238`. The one shared `.bd` port is `SectionBlock` at `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:214-217` — `.font(section.quoted ? .loraItalic(15.5) : .lora(15.5)).lineSpacing(6)` — a flat 15.5 / lh≈1.39, constant, with no immersed branch. (Used by all seven readings: `:362, 469, 564, 730, 941, 1086, 1263`.)

· `#word p` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:574` — `Text(word).font(.lora(15)).lineSpacing(15 * 0.74)` → **15 / 1.74**. Sole site (`wordPanel`, the only caller of `UniWords.word`).

· `#lite .anc` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightType.swift:30-31` — `static let anchorSize: CGFloat = 16.5` / `static let anchorLeading: CGFloat = anchorSize * 0.7` → **16.5 / 1.70**. Sole consumer `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:361`.

**The pairing is not diluted — it is inverted on both prope

**Comment** — **NONE of the known shape** — no comment on one member cites a sibling member's design line. Both ported members cite their own element correctly. But the tell is present one level up: **each cites the right element in a file that loses on the precedence ladder.**

`LightType.swift:28` — *"`:835` — 16.5/1.7. Between the settled whole and the Declaration, which is where an anchor sits in the register"* — under the file header `LightType.swift:3`: *"E1.17 · **THE LIGHT'S TYPE SCALE.** `The Light v2.html:826-853`."* That citation resolves: `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The

**Evidence** — **THE LADDER IS EXPLICIT AND BOTH PORTS ARE BELOW IT.**

`/Users/ashrey/Bindu Feed/Claude Design Round 2/HANDOFF.md:64-75` §3: rung 1 `canon/` (literal text and numbers) · rung 2 **the seven Round-2 comps** — Aperture · Chrome · Reading · Return · Rooms v4 · Seam · Sound · room-figures.js — *"for the seven areas in §5"* · rung 3 **`The Instrument v3.html`** — *"Feel, geometry, interaction everywhere else. 6,081 lines — still the largest single authority in the project"* · rung 4 `comps/*.js`.

`The Light v2.html` and `The Universe v3.html` are Round-1 per-register comps. **Neither is among the seven.** `/Users/ashrey/Bindu Feed/Claude Design Round 1/README.md:3` — *"Design source of truth: `The Instrument v3.html`"* — and `:256` — *"**the source of truth.** … **The Universe (Z −4…−1), the Light (Z −5) and the Point (Z +1…+9) are IN here — they are registers of this one axis, not separate

**Refutation** — All six quoted lines verify verbatim (design :4583/:4596/:4609; SectionBlock PointReadings.swift:214-218, UniverseView.swift:574, LightType.swift:30-31), and the comp citations resolve exactly (The Light v2.html:835 = fontSize:16.5,lineHeight:1.7; The Universe v3.html:1412 = 15px/1.74). The ladder, README:3/:256 and E1.3's subordination ruling all read as quoted. I tested and rejected two defenses: The Reading.html (rung 2, authoritative for the reading) specifies no body type and contains no immersion, so it does not supersede .imm; and HANDOFF-RULINGS.md contains no ruling on either comp.

BOTH-WRONG nevertheless fails, because it requires the two PORTED members to be wrong, and that rests wholly on a precedence ruling the finding itself concedes is "missing, not made." Its dividing line

### ONE-MISSING — `immersion-padding` · rows `C3.8`, `C5.8`, `E1.17`, `E1.2`

**Design** — `.imm` → `padding:104px 34px 148px!important` (with `inset:0!important`, `max-height:none!important`, `background:none!important`) at `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4581`. It is not an element but a STATE — the full-bleed override toggled onto whichever `.read` panel is immersed: `:5506` `READS.forEach(el=>el.classList.toggle('imm', IMM.on && el===IMM.el))`, over the seven panels named at `:5265` (`still, going, thru, wall, sheet, word, lite`).

`#lite` → `padding:104px 38px 150px` at `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4603` (the declaration opens at `:4602`, `display:flex;flex-direction:column;justify-content:center`). The Light register's own reading — `liteRender()` at `:5271-5288`, `B.carry(174)`/`B.blip(174)` at `:5374,:5873`.

Note the two are not merely siblings: `lite` is itself a member of `READS`, so `.imm`'s 34 can be laid over `#lite`'s 38 at runtime by `:5506`. That is the design's own reason for the 34/38 distinction being deliberate rather than a typo.

**App** — `.imm` — **NO PORT.** There is no full-bleed immersion layout anywhere in the app. The trigger was built and is dead: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/AxisTravel.swift:77` — `var immersed: Bool { pieceOpen && immA > Immersion.onThreshold }`, documented at `:75` as *"`IMM.on` — `:5503`"* — is referenced by nothing but its own test (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu FeedTests/ImmersionTests.swift:236,238`). No view reads it; `:5506`'s class toggle has no counterpart, so no reading panel changes its padding, inset, max-height or background when he goes inside a piece. Grep for `104`/`148` across the app source returns nothing on any reading surface.

`#lite` — **PARTIAL PORT, and it carries ITS OWN constant.** `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:440` — `.padding(.horizontal, 38)`, closing the `sceneBody` VStack declared at `:343`. **38, not the sibling's 34.** The vertical pair is absent: no `104` top, no `150` bottom. The app centres with bare `Spacer()` at `:345` and `:438` and then leans on the fade mask at `:444-451` to keep the column off the edges — where the design centres INSIDE a 104/150 box, so its padding is a hard floor and the app's is not. Long scenes are the divergence: `columnLift` (`:321-325`) dr

**Comment** — NONE. `LightView.swift:440` carries no comment at all — not its own citation, not the sibling's. `.imm` has no app site for a comment to sit on.

This pair therefore escapes `check_citations` for the OPPOSITE reason from the `#where`/`#pname` instance: not a correct citation of the wrong element, but no citation whatsoever. A string checker has nothing to verify and nothing to contradict.

I checked every other app site carrying one of these four constants for the transposition shape, and found none — each traces to its own source, correctly cited:
· `Point/PointDeals.swift:26,47` quote `#gate

**Evidence** — VERDICT REASONING. Not TRANSPOSED — the one constant that did land is on the right sibling (`#lite`'s 38 at `LightView.swift:440`, not `.imm`'s 34). Not COLLAPSED — the app never gives both the same value, because there is no second site to collapse onto. Not BOTH-WRONG. ONE-MISSING is the fit, in its strong form: one member ported (partially, with its own constant), the other absent entirely along with the mechanism that would apply it.

WHY 38 IS PROVABLY `#lite`'s AND NOT COINCIDENCE. The standalone Light comp is not the source: `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light v2.html` (byte-identical to `Claude Design Round 2/design-source/The Light v2.html`) styles its scene column at `:810` as `padding:'268px 44px 0'`, and its other stages at `:678` `0 44px 150px` and `:868` `0 46px 120px`. No 38 anywhere in that file. The app's 38 can only have come from `The Instru

**Refutation** — Survives every refutation, and two attacks strengthened it.

DESIGN EXACT. `The Instrument v3.html:4581` `.imm{inset:0!important;max-height:none!important;padding:104px 34px 148px!important;background:none!important}` and `:4602-4603` `#lite{...justify-content:center;` / `padding:104px 38px 150px;...}` read verbatim as quoted.

SIBLINGS ARE THE SAME ELEMENT, NOT NEIGHBOURS. The "unrelated elements sitting near each other" failure mode is refuted decisively. `piece()` at `:5300-5303` returns `{k:'light', m:LT, el:liteEl, ...}`, so `:5506`'s `READS.forEach(el=>el.classList.toggle('imm', IMM.on && el===IMM.el))` toggles `.imm` onto `#lite` itself. Stronger than the finding claims: `immAsk()` (`:5323-5330`) returns early unless `IMM.on`, and the Light's `IMM.give` is `()=>{LT.advance();liteRen

### ONE-MISSING — `letterpress-shadow-alpha` · rows `D5.1`, `E1.17`, `E1.3`, `E1.4`

**Design** — MEMBER A — `#wall h2` → `text-shadow:0 1px 0 rgba(30,14,6,.9),0 -1px 0 rgba(255,224,196,.14)` at /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4541 (rule opens :4540).

MEMBER B — `#lite.carved .beat b` → `color:rgba(228,220,208,.9);text-shadow:0 1px 0 rgba(0,0,0,.72),0 -1px 0 rgba(255,246,232,.10)` at the same file:4615.

The discrimination that makes A a member and not a generic title: `#wall h2` is the ONLY one of the seven reading panes whose title is struck. `#sheet h2` (:4445), `#still h2` (:4470), `#going h2` (:4492), `#thru h2` (:4516) are the same 24-25px/400/-.016em face with NO text-shadow. The chamber's title alone is debossed, because "walls are the only surface in the instrument that can be INSCRIBED." So A's pair is not decoration on a shared heading — it is the one heading in the shell that says which register you are in with the words covered.

**App** — MEMBER A — the reading-pane title. Located, and it carries NO shadow of any kind.
/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointReadings.swift:246 (inside `private struct ReadingHead`, :237-251):
    Text(star.t).font(.lora(24, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
    Text(star.ti).font(.loraItalic(14)).foregroundStyle(hue)
This is unambiguously the port of the design's pane head — design :5236-5237 sets `h2 = n.n.t` and `.ti = n.n.ti`, and the app reads `star.t` then `star.ti` italic, at the design's own 24. Size ported, italic subtitle ported, letterpress pair absent. Grep confirms it: `PointReadings.swift` contains zero `.shadow(` calls, and none of the app's 44 `.shadow(` sites anywhere carries a `.9`/`.14` pair.
Structural note that hardens the finding: `ReadingHead` is used by ALL SEVEN readings (dispatched at PointReadings.swift:274-282, `ReadStillness` … `ReadCompany`), so the app has flattened the seven design panes to one head. There is no site where A's shadow COULD be added without also putting it on the six panes the design deliberately leaves flat.

MEMBER B — ported, at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:101 and :103 (applied at :377-378):
    :101  private var carveShadow: Color { isNave ? Color.w

**Comment** — YES — and it is the same shape as the known instance, one level down: a correct citation covering the wrong branch of the line it sits on.

LightView.swift:102, the only comment on the carve pair, sits directly above the line that defines BOTH branches:

    /// `:30` — `0 -0.5px 0.5px rgba(22,19,27,0.22)`, the dark lip above the cut.
    private var carveRim: Color { isNave ? Color(hex: "#16131B").opacity(0.22) : Color.white.opacity(0.16) }

`:30` is `comps/The Light v2.html:30` — the NAVE half. The quoted expression `rgba(22,19,27,0.22)` verifies verbatim against that line and justifies `#16

**Evidence** — VERDICT REASONING — why ONE-MISSING and not the others:
· Not TRANSPOSED: neither app site carries the other's number. The app has no `.9` and no `.14` at either location; B's `.72` is its own.
· Not COLLAPSED between A and B: they are not given the same value — A is given none.
· Not MATCHED: A's pair is absent and B's light half is wrong.
· Not NOT-PORTED: B is ported, at a located site, with its dark constant exact.
· Not UNCLEAR: both app sites were located affirmatively. A's site is `ReadingHead` — proven by the design's own `h2`/`.ti` fill at :5236-5237 matching `Text(star.t)` / `Text(star.ti)` at 24pt — and its absence of shadow is proven by grep (zero `.shadow(` in PointReadings.swift) rather than by failure to find.

THE FAULT, stated as the class describes it:
The design's two inscriptions are one recipe at two weights — .9/.14 for the wall it is cut into, .72/.10 for the floor

**Refutation** — SURVIVES. All quotes verify verbatim: The Instrument v3.html:4540-4541 (#wall h2, .9/.14) and :4615 (#lite.carved .beat b, .72/.10); comps/The Light v2.html:30 (0.95/0.22); PointReadings.swift:237-251 ReadingHead; LightView.swift:101-103, 377-378.

MEMBER A IS ABSENT, PROVEN AFFIRMATIVELY: PointReadings.swift has 0 `.shadow(` calls; none of the app's 44 shadow sites carries 0.14; `1E0E06`, `FFE0C4` and `FFF0E2` (the #wall h2 dark, light and face colours) appear nowhere in Swift. ReadingHead does not even carry #wall h2's colour, weight (design 400 vs app .medium) or tracking — so no port of that element exists, not merely a port missing its shadow.

MEMBER B IS HALF-PORTED, SO NOT-PORTED DOES NOT TAKE THE GROUP. Dawn `.black.opacity(0.72)` at y:1/radius 0 matches :4615's `0 1px 0 rgba(0,0,

### ONE-MISSING — `levels-constellation-star-opacity` · rows `D5.10`

**Design** — All five from /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/point-levels.js, the `.cs` star button built at :137-139 (`<span class="dot ${s.st}">` + `<span class="lab">${s.t}<span class="st">${SM[s.st]}</span></span>`):
1. `.cs .dot.s` (seeded dot) → opacity .6 (+ `box-shadow:none`) — :31
2. `.cs .lab` (star label) → opacity .86 — :32
3. `.cs .st` (status word under the label, `SM[s.st]` = walked/in progress/seeded, 6px Space Mono, .2em, uppercase) → opacity .42 — :33
4. `.cs.seeded .lab` (not-yet-walked label) → opacity .56 — :34
5. `.cs:hover .lab` → opacity 1 — :35
The distinguishing pair is .56 (seeded label) vs .86 (walked/in-progress label); .42 belongs to a THIRD element (the status word) nested inside the label, and .6 to the dot.

**App** — The single port of `.cs` is `StarMark` in /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointWorlds.swift:62-84 (the shared token used by all seven worlds — call sites :286, :405, :553, :992, :1263, :1334, :1483). `PlacedStar.status` (:21) is `w→2, p→1, s→0`.

1. `.cs .dot.s` .6 → PointWorlds.swift:81 — `default: Circle().stroke(hue.opacity(0.6), lineWidth: 1).frame(width: 9, height: 9)   // ○ seeded`. Own constant, on the seeded branch, and no shadow on that branch (walked/in-progress get one at :78/:79). MATCHED.
2. `.cs .lab` .86 → PointWorlds.swift:71 — `.font(.lora(11.5)).foregroundStyle(BinduTheme.inkPrimary.opacity(placed.status == 0 ? 0.56 : 0.86))`, the `: 0.86` (non-seeded) arm. MATCHED.
3. `.cs .st` .42 → NO PORT. `StarMark`'s HStack is marker + title only; there is no status-word Text and no 0.42 anywhere in it. The word table survives as `PointStatus.word` (/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Point/PointDeals.swift:58-65) whose one caller is the descent PROMPT (Point/PointWorldView.swift:609), never a rendered caption. (`PointStatusLabel`, Point/PointReadings.swift:177/:230, is the different `STL` footer of `point-levels.js:9,172`.) MISSING.
4. `.cs.seeded .lab` .56 → PointWorlds.swift:71, the `placed.status == 0 ? 0.56` arm. Own constant, on the se

**Comment** — NONE. No app comment on any of these sites cites a design line at all, so there is no correct-citation-of-the-wrong-element here. The only comment over the block is PointWorlds.swift:61 — "// The ●◐○ star mark + its label, the one shared token across all seven materials." — and the only inline notes are the bare glyph tags at :78/:80/:81 (`// ● walked`, `// ◐ in progress`, `// ○ seeded`), each correctly on its own branch. Every `point-levels.js:NN` citation in the app (grep: 17 hits) points at :9, :107, :120-121, :161, :186-196, :210-211, :261, :289-294, :1249 — none at :31-35, so these five c

**Evidence** — Design (point-levels.js:31-35) vs app (Point/PointWorlds.swift:62-84), member by member:

.cs .dot.s  opacity:.6   → :81  `Circle().stroke(hue.opacity(0.6), lineWidth: 1)` on `default:` (status 0 = "s")           MATCHED
.cs .lab    opacity:.86  → :71  `...opacity(placed.status == 0 ? 0.56 : 0.86)`, non-seeded arm                              MATCHED
.cs .st     opacity:.42  → (no site)  status word never rendered; `PointStatus.word` only feeds the prompt                   MISSING
.cs.seeded  opacity:.56  → :71  same ternary, seeded arm                                                                     MATCHED
.cs:hover   opacity:1    → (no site)  no hover on iOS; dwell reveals the label at .86/.56 and scales 1.35 (:286-287)         NOT-PORTED (platform)

The fault class this sweep hunts is ABSENT here. The two numbers that could silently re-code walked-vs-seeded — .56 and .86, two desi

**Refutation** — Survives attack on every load-bearing point. Design point-levels.js:31-35 reads verbatim as quoted (.dot.s .6 + box-shadow:none; .lab .86; .st .42 at 6px mono/.2em/uppercase; .cs.seeded .lab .56; .cs:hover .lab 1), and :137-139 nests .st inside .lab. SM is real content (Claude Design Round 1/comps/point-content.js:8 = {w:'walked',p:'in progress',s:'seeded'}), so the status word genuinely renders in the comp. App: PointWorlds.swift:71 and :81 read exactly as quoted; PlacedStar.status (:21) maps w=2/p=1/s=0, so `status == 0` IS the design's `.cs.seeded` predicate and the dimmer .56 sits on the seeded arm — polarity correct, no transposition, no collapse. Grep confirms :71 is the sole site of that ternary app-wide and StarMark is the only .cs port (7 call sites as listed). Member 3 is truly a

### ONE-MISSING — `light-mono-chrome-opacity` · rows `B4.2`, `E1.13`, `E1.14`, `E1.17`, `E1.18`

**Design** — Both members are `<Mono size={9}>` captions on the Approach screen of `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light v2.html`, and `Mono` defaults to `color='var(--ink35)'` (`:601`), `--ink35 = rgba(237,232,227,0.35)` (`:14`) — so each constant multiplies a 0.35 base.

A · title caption "The Light" — `opacity:0.5` — `The Light v2.html:679`
  `<Mono size={9} style={{marginBottom:20,opacity:0.5}}>The Light</Mono>`
  Effective 0.35 × 0.5 = 0.175. Static; the register naming itself at the top of the column. It occurs EXACTLY ONCE in the whole comp (the only other "The Light" is the `<title>` at `:6`).

B · invitation caption "touch once" — `opacity:arrived?0:0.55` — `The Light v2.html:688`
  `<Mono size={9} style={{opacity:arrived?0:0.55,transition:'opacity 2.4s ease'}}>touch once</Mono>`
  Effective 0.35 × 0.55 = 0.1925 until `arrived`, then a hard step to 0 over 2.4s. `arrived` is set by `onDown` (`:663` — `if(!arrived)arrive()`), i.e. by the FIRST TOUCH, which is what the comment two lines above it means: "one invitation, once. After the touch, the door says nothing more" (`:685-686`).

Between them sit the two prose lines the app does port: `:680-681` `<p fontSize:21>{scene.label}</p>` with `opacity:1-prog*0.55`, and `:682-683` `<p fontSize:13 italic>Not to be wa

**App** — The app's port of this screen is `approach` in /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:170-210 (reached via `case .light: LightView(path: $path)` — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RootView.swift:191-192).

A · "The Light" title caption — **NO PORT.** `grep '"The Light"'` over the entire app source returns exactly one hit, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:39 — `.init(id: "light", name: "The Light", sub: "the future, already underway", …)`, a row in the door menu, a different element on a different screen. The Approach's own column (LightView.swift:180-203) renders no register-name caption at all: `Spacer().frame(height: 90)` goes straight to `Text(scene.title)`. That `Text(scene.title)` is the port of `:680`'s `<p>{scene.label}</p>`, not of `:679` — confirmed against the design's `SCENES` (`The Light v2.html:583` `label:'The morning that does not push'`), which is verbatim `LightCanon.scenes[0].title`. So the 0.5 caption's slot is not occupied by a renamed port; the element is absent.

B · "touch once" — ported, WRONG CONSTANT, and on the wrong variable.
  /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:196-198
  `Text(LightCanon.touchOnce)`
  `    .spaceMonoTrac

**Comment** — NONE. No comment on either member cites the other member's design line — this group does not have the `#where`/`#pname` citation tell.

The only citation covering either member is on member B, and it is correct in both element and line — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Light/LightCanon.swift:28-31:

  "// Canon is exactly this — The Light v2.html:688. The longer form ("touch once, then do
   // nothing") is the review-bench caption at :914, OUTSIDE the phone frame. The design
   // deliberately says nothing more after the touch: "it never tells him to be still; he
   // discover

**Evidence** — WHY THIS IS ONE-MISSING AND NOT A SWAP: a transposition needs 0.5 to surface somewhere on the pair. It does not. `grep 'opacity(0\.5'` over LightView.swift returns nothing; the file's 0.55s are all elsewhere (`:245` the far presence's fill, `:462` the breath cue, `:472` a phase threshold, `:791` a material base). Member A's 0.5 has no home in the app because member A has no element in the app.

THE WIDER SHAPE, because it changes what the fix is: the Light's Mono chrome opacities are not transposed from each other — they are app-invented as a family, and the design's numbers are absent as a set.
  · `:679` A — design 0.5 → app: element absent.
  · `:688` B — design 0.55 → app 0.6 (LightView.swift:198).
  · `:707` "hold" — design `opacity:held?0:1`, NO base constant → app 0.6 (LightView.swift:286, `holdDimmed ? 0 : 0.6`).
  · `:681` scene label — design `1-prog*0.55`, no base constant → a

**Refutation** — Survives attack. DESIGN VERBATIM: The Light v2.html:679 `<Mono size={9} style={{marginBottom:20,opacity:0.5}}>The Light</Mono>` and :688 `<Mono size={9} style={{opacity:arrived?0:0.55,...}}>touch once</Mono>`; Mono's `color='var(--ink35)'` default at :601 and `--ink35=rgba(237,232,227,0.35)` at :14 both confirmed, so each constant does multiply a 0.35 base. NO SUPERSEDING SOURCE: `Claude Design Round 2/design-source/The Light v2.html` is byte-identical to Round 1 (diff clean), and `The Light - S-L01 Dawn.html` contains no Mono and no "touch once" — nothing anywhere carries 0.6. APP CONFIRMED: LightView.swift:196-198 reads as quoted, `0.6 * (1 - still)` on BinduTheme.inkTertiary, and Theme.swift:35 is #EDE8E3@0.35 — right base, wrong constant (0.6 vs 0.55). MEMBER A GENUINELY ABSENT, not re

### ONE-MISSING — `light-scene-wash-alpha` · rows `E1.13`, `E1.16`, `E1.5`, `E1.6`

**Design** — Six branches of one if/else in `LIGHT.draw()`, all `A*k*p`, under `var A=a*(1-this.arrive*0.35), p=this.arrive` (`Claude Design Round 1/The Instrument v3.html:4098`; canon twin `canon/spine-light.js:206`). Both sources are byte-identical on all six constants, so there is no source conflict to adjudicate:
· converge → `A*(0.20+p*0.45)`, colour `c`=#EDE3CE — v3:4102 / spine-light.js:214
· warmth → `A*0.30*p`, [255,206,150], radial @ (0.5H, 0.86H) r=W*(0.30+p*0.80) — v3:4106 / :218
· kindness → `A*0.16*p`, [255,232,200], linear H→H*0.12 (+ nine rays at `A*0.10*p*(1-i/11)`, [255,236,208]) — v3:4111 / :223
· release → `A*0.24*p`, [255,244,226], radial @ centre r=max(W,H)*0.70 (+ three rings at `A*0.22*ok`) — v3:4120 / :232
· floor → `A*0.18*p`, colour `pc` = `pool:'#FBF9F4'` = (251,249,244), linear (W*0.5,0)→(W*0.5,H*0.80) — v3:4127 / :239
· morning / the else branch ("stillness" is this scene's `arrival` word, `spine-light.js:33`) → `A*0.20*p`, [255,238,214], linear H*0.86→H*0.20 — v3:4132 / :244

**App** — Port is `private struct LightDawnArrival` — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:722-783`, one `switch key` at `:738`, mounted at `:154` (`LightDawnArrival(key: scene.key, p: arrivalProgress)`), `.blendMode(.plusLighter)` for the design's `globalCompositeOperation='lighter'`.
· converge — `:739` case, constant at `:744` `col(bone, A * (0.20 + p * 0.45))`, `bone = [237,227,206]` = #EDE3CE. OWN value.
· warmth — `:746` case, `:747` `col([255, 206, 150], A * 0.30 * p)`, centre (W*0.5, H*0.86), r = W*(0.30+p*0.80). OWN value.
· kindness — `:750` case, `:751` `col([255, 232, 200], A * 0.16 * p)`, linear H→H*0.12; rays `:757` `col([255, 236, 208], A * 0.10 * p * (1 - Double(i)/11))`. OWN value, secondary constant too.
· release — `:759` case, `:760` `col([255, 244, 226], A * 0.24 * p)`, centre, r = max(W,H)*0.70; rings `:767` `col(bone, A * 0.22 * ok)`. OWN value.
· morning (the else) — `:769` `default:`, `:770` `col([255, 238, 214], A * 0.20 * p)`, linear H*0.86→H*0.20. OWN value.
· floor — **NO APP SITE.** There is no `case "floor"` in the switch, and no other file carries the expression: `grep -rn "251, 249, 244\|FBF9F4"` across the whole app tree returns only `LightView.swift:790` (LightStars' nave star hex), never a `p`-driven wash. `floor` is a 

**Comment** — NONE — and notably none of the six app sites carries a line-number citation of any kind, so there is no correct-citation-of-the-wrong-element here. Each case's trailing comment paraphrases ITS OWN design comment: `:739` "scattered motes drift into one field" ← v3:4100; `:746` "the heat reaches the hand before the eye" ← v3:4104 verbatim; `:750` "light rises from behind, onto what he built" ← v3:4108; `:759` "brightens one ring per opened hand" ← v3:4118; `:769` "morning: the dawn thins toward him" ← v3:4130 ("stillness: the dawn thins toward him when he stops" — and `stillness` is the morning 

**Evidence** — FIVE OF SIX ARE EXACT. No transposition, no collapse: each of converge/warmth/kindness/release/morning carries its own constant, its own colour triple, and its own gradient geometry, and the two secondary constants (kindness's `A*0.10*p*(1-i/11)`, release's `A*0.22*ok`) came across too. The 0.16-vs-0.24 pair — the two adjacent members most exposed to a swap, since kindness and release are neighbouring branches with unrelated numbers — is correctly paired.

THE SIXTH IS NOT PORTED. `floor`'s `A*0.18*p` over `#FBF9F4` exists in neither `LightView.swift` nor `LightNave.swift` nor anywhere else in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed`. It is not a dropped constant on a rendered element — the element is unreachable by construction: `floor` is `.nave` (`Light/LightCanon.swift:225`), and the switch that holds the other five only runs under `.dawn`.

MITIGATION, stated so the row is n

**Refutation** — Survives every refutation route. DESIGN: all six lines verbatim at cited sites — canon/spine-light.js:206,214,218,223,232,239,244 and Round 1 v3:4094,4102,4106,4111,4120,4127,4132. SOURCE-CONFLICT REFUTATION FAILS: I found a third copy, Claude Design Round 2/design-source/The Instrument v3.html, byte-identical to Round 1 (md5 fffa99a10373f4d98f7736ec76f74a89), carrying id==='floor' at :4125 and A*0.18*p at :4127 — all three corpus copies agree, so no revision dropped the branch and the port cannot be faithful to a five-branch source. APP: LightDawnArrival (LightView.swift:722-783) reads exactly as quoted for converge/warmth/kindness/release/morning, including both secondary constants (A*0.10*p*(1-i/11), A*0.22*ok). floor absent: grep -rn 'case "floor"' over the app tree returns nothing; th

### ONE-MISSING — `lightv2-flood-vs-lit-ramps` · rows `E1.11`, `E1.12`, `E1.13`

**Design** — Both members sit inside one `anim` frame in `LitSpace`, driven by one shared `p` declared at `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Light v2.html:741` — `const p=Math.min(1,(n-t0)/3000);`

· flood — attack/decay split → `setFlood(p<0.42?p/0.42:Math.max(0,1-(p-0.42)/0.58));` — site: `Claude Design Round 1/comps/The Light v2.html:742`. Constants 0.42 / 0.58. Rises 0→1 over p∈[0,0.42], falls 1→0 over p∈[0.42,1]. Peak at p=0.42 (1.26s).

· lit — delayed ramp → `setLit(Math.min(1,Math.max(0,(p-0.2)/0.4)));` — site: `Claude Design Round 1/comps/The Light v2.html:743`. Constants 0.2 / 0.4. Pinned at exactly 0 until p=0.2 (0.6s), then rises to 1 by p=0.6 (1.8s). Crosses 0.5 at p=0.4 (1.2s).

The design's ordering: the interior stays wholly unresolved for the first 0.6s while only the flood climbs; the stone finishes resolving at 1.8s and then sits fully lit under a flood that goes on receding until 3.0s.

**App** — · flood → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightNave.swift:190`
`let flood = floodP < 0.42 ? floodP / 0.42 : max(0, 1 - (floodP - 0.42) / 0.58)`
Driver at `:188` — `let floodP = floodStart.map { min(1, (t - $0) / 3) } ?? -1`. Carries ITS OWN member's constants, 0.42 and 0.58, verbatim. This half is exact.

· lit → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightNave.swift:69`
`let lit = floodStart.map { min(1, (t - $0) / 3) } ?? 0   // the flood, timed in-canvas`
This is the bare driver `p`. Neither of its constants is present: no `- 0.2` offset, no `/ 0.4` span, and the `Math.max(0,…)` floor is vacuous because nothing is subtracted. `lit` at `:69` is character-for-character the same expression as `floodP` at `:188` — the member was collapsed into the shared driver rather than derived from it.

No second port exists. `grep -rn '\blit\b'` over `Screens/` returns only this file plus `RiteView.swift`'s unrelated paragraph counter; `grep -rn '0.2) / 0.4'` over all `*.swift` returns zero. The delayed ramp is nowhere in the app.

**Comment** — YES — and it is the same shape as the `#where`/`#pname` instance, one notch weaker.

The comment on member B is member A's name. `LightNave.swift:69`, trailing the `lit` line:

    // the flood, timed in-canvas

That is `lit`'s line labelled as the flood. A reader checking this site is told by the code's own comment that it is the flood — and the flood's expression at `:190` is correct, so the check terminates satisfied.

The counter-quote is what makes it damning. The comment above member A, `LightNave.swift:186-187`, states the distinction the code then fails to keep:

    // ── the flood: a

**Evidence** — CONSEQUENCE, computed against the app's own thresholds.

`lit` is not decorative — `:70-71` uses it as a hard inversion gate:

    let ink: (Double, Double, Double) = lit > 0.5 ? (22, 19, 27) : (246, 243, 237)
    let lgt: (Double, Double, Double) = lit > 0.5 ? (255, 253, 248) : (246, 243, 237)

and that `lit > 0.5` ternary is re-read at `:100`, `:101`, `:108` and `:183` (shaft gradient, pool, beam-dust). `lit` also drives `if lit > 0` at `:77` and `g.opacity = lit` at `:78`, the whole interior wash.

Design vs app, on the same clock:

1. THE DARK BEAT IS GONE. Design holds `lit` at exactly 0 for p<0.2 — the first 0.6s — so `if lit > 0` never fires and the interior is not painted at all while the flood climbs. The app paints the interior from frame one. The design's "flood must peak before the interior resolves" begins with 0.6s in which ONLY the flood exists; the app has no such beat.



**Refutation** — Survives attack on every axis. DESIGN EXACT: The Light v2.html:741-743 read verbatim as quoted (p driver, setFlood with 0.42/0.58, setLit with (p-0.2)/0.4). Claude Design Round 2/design-source/The Light v2.html is byte-identical (diff -q identical, same line numbers), so there is no alternate design source; The Light - S-L01 Dawn.html has only an unrelated local `var lit=eyeOpen*(1-collapse)` and no setFlood/setLit; canon/spine-light.js has neither. APP EXACT: LightNave.swift:69 is `let lit = floodStart.map { min(1, (t - $0) / 3) } ?? 0   // the flood, timed in-canvas` — the bare driver; :188/:190 carry 0.42 and 0.58 verbatim. `grep "0.2) / 0.4"` over all *.swift returns zero; the delayed ramp exists nowhere in the app. SIBLINGS CONFIRMED, not mere neighbours: both design members are setSt

### ONE-MISSING — `lightv2-mono-chrome-opacities` · rows `E1.13`, `E1.14`, `E1.17`, `E1.18`

**Design** — Member A — the mono kicker 'The Light' → opacity 0.5. `Claude Design Round 1/comps/The Light v2.html:679`: `<Mono size={9} style={{marginBottom:20,opacity:0.5}}>The Light</Mono>` (bottom-anchored column, above the scene label).
Member B — the mono invitation 'touch once' → opacity `arrived?0:0.55`. `Claude Design Round 1/comps/The Light v2.html:688`: `<Mono size={9} style={{opacity:arrived?0:0.55,transition:'opacity 2.4s ease'}}>touch once</Mono>` (its own absolutely-positioned block at `bottom:56`).
Both are `<Mono size={9}>` on the Approach screen (`data-screen-label="Light — I The Approach"`, opens at `:675`), nine lines apart, differing by 0.05.

**App** — Member A — NO PORT. The app's Approach is `LightView.approach`, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:170-208`. Its column holds exactly four texts: `Text(scene.title)` (:183, lora 20 italic, `.opacity(0.75 * (1 - still))`), `Text(LightCanon.gateLine)` (:189), `Text(LightCanon.touchOnce)` (:196), `Text(LightCanon.approachSubtitle)` (:199, `.opacity(0.4)`). There is no mono caption reading "The Light" anywhere: `grep -rn '"The Light"' --include=*.swift` returns ONE hit, `Components/TurnOverlay.swift:39`, which is the Turn overlay's destination row (`name: "The Light"`, glyph "▷", `.route(.instrument(-5))`) — a different screen, not this caption. No constant 0.5 appears in the approach block at all.
Member B — PORTED, wrong constant. `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:196-198`:
`Text(LightCanon.touchOnce) / .spaceMonoTracked(9, em: 2 / 9) / .foregroundStyle(BinduTheme.inkTertiary.opacity(0.6 * (1 - still)))`
0.6 — not its own 0.55, and not the sibling's 0.5. `git log -L 194,200` shows the `0.6 * (1 - still)` has stood unchanged since the file was created in `ddc0623` ("Wave 5: the Return + the Light"); the two later commits touching this line (`ad7ca1c`, `b19f1d6`) only migrated the mono face/case. It was never 

**Comment** — NONE — no app comment cites the other member's design line, and that is the point: **the surviving member's number carries no citation at all.** The only comment in the block is `LightView.swift:182` — `// the scene's name, fading as stillness deepens (comp The Light v2 approach)` — attached to `Text(scene.title)`, a file-level "comp" reference with no line number, so nothing anchors it. Lines 196-198 (`touch once`, opacity 0.6) have no comment above them. The one place `:688` IS cited is `Light/LightCanon.swift:28-31` — "Canon is exactly this — The Light v2.html:688. The longer form ("touch o

**Evidence** — Not TRANSPOSED and not COLLAPSED — 0.5 does not appear anywhere in the app's approach chrome, so no number moved to a sibling and nothing was merged onto one value. The shape is ONE-MISSING with the survivor also wrong:

1. Member A ('The Light', 0.5) has no port. The app's Approach column (`LightView.swift:180-202`) has no `<Mono>`-equivalent screen-name caption; the only "The Light" string in the whole Swift tree is the Turn overlay's route row.
2. Member B ('touch once', `arrived?0:0.55`) is ported at `LightView.swift:196-198` with **0.6** — a plausible round number, present since the file was authored, matching neither member.
3. 0.6 is not local: the app's OTHER Light mono caption, `Text("hold")` at `LightView.swift:284-286`, also uses `.opacity(holdDimmed ? 0 : 0.6)` where the design's `:707` is `<Mono size={9} color="var(--ink35)" style={{opacity:held?0:1}}>hold</Mono>` — full alp

**Refutation** — Survives every refutation route. Design verbatim: `The Light v2.html:679` `<Mono size={9} style={{marginBottom:20,opacity:0.5}}>The Light</Mono>` and `:688` `<Mono size={9} style={{opacity:arrived?0:0.55,...}}>touch once</Mono>`, both inside `data-screen-label="Light — I The Approach"` (:675). Genuine siblings, not adjacency: `Mono` is defined at `:601` with `color='var(--ink35)'` and neither site overrides it, so both are the same 9px face on the same base, differing only by 0.05 in the same multiplier slot. The bases are commensurable in the app too: `--ink35 = rgba(237,232,227,0.35)` (:14) vs `BinduTheme.inkTertiary = #EDE8E3 @ 0.35` (Theme.swift:35) — identical, so 0.55-vs-0.6 is a like-for-like delta, not a token artifact.

Member A: NO PORT. `grep -rn '"The Light"' --include='*.swift

### ONE-MISSING — `mirror-leaving-timeouts` · rows `A1.5`, `A1.6`

**Design** — Design file (all three copies are byte-identical — md5 08adc74c…, 321 lines: `Claude Design Round 1/comps/The Mirror.html`, `Claude Design Round 2/design-source/The Mirror.html`, `archive/bindu-feed-phase9-handoff/prototypes/The Mirror.html`).

· draw() — the Bindu Draw → `}, 620);` at `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Mirror.html:193` (inside `setLeaving(true); setTimeout(() => { …setIdx(next); setDrawn(true); setShown(v=>v+1); setLeaving(false); }, 620)`).
· passDay() — pass a day → `}, 480);` at `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Mirror.html:199` (`setLeaving(true); setTimeout(() => { setDayOffset(o => o + 1); setLeaving(false); }, 480)`).

Both drive the SAME `leaving` flag, whose only visual is the container at `:262-264` — `opacity: leaving ? 0 : 1`, `translateY(-6px)`, `transition: 'opacity 0.55s ease, transform 0.55s ease'`. The pair STRADDLES that 550ms fade: 620 > 550, so the draw waits for full darkness and then holds ~70ms of emptiness before the new face mounts; 480 < 550, so a passed day cuts the swap in at ~87% of the fade, while the old card is still visible. That is the mechanism behind "the draw is deliberately the slower of the two" — it is not merely a bigger number, it is on the other side of the fade.

**App** — · draw() → PORTED, carrying ITS OWN constant. `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/MirrorView.swift:242-248`, in `drawAlternate()`:
    `withAnimation(.easeInOut(duration: 0.62)) { leaving = true }`
    `DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) { currentIdx = altIdx; drawn = true; cardAnimationKey += 1; leaving = false }`
  The `leaving` flag drives `.opacity(leaving ? 0 : 1)` / `.offset(y: leaving ? -6 : 0)` at `MirrorView.swift:123-124` — the design's `:262-263` verbatim, −6 included. 0.62 = the design's 620, not the sibling's 480.

· passDay() → NO PORT. Not renamed, not relocated — absent, and so is the affordance it belongs to. Positive evidence, not failure to find:
   – repo-wide `passDay` / `pass a day` / `dayOffset` hits ONLY the three identical Mirror comps and the three identical `The Signal Space.html` comps (`:81-82,103,193`); zero hits anywhere under `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed`.
   – the design's trigger is a `<button onClick={passDay} title="pass a day">what surfaces on …</button>` (`:250-254`). The app's counterpart at `MirrorView.swift:78-80` is a plain `Text("what surfaces on \(prettyDayLabel)")` — not a Button, no gesture, no action.
   – the day is not offsettable at all in the app: `MirrorView.swift:317` `

**Comment** — NONE — no wrong-sibling citation. The only comment over the app site is `MirrorView.swift:240-241`:

  "// Two-stage (comp The Mirror): the current reflection fades out and lifts, THEN the
   // alternate rises in — the old face departs before the new surfaces."

It names the comp but cites NO line, so it cannot cite `:199` in place of `:193`. Substantively it is true of the draw and of nothing else.

Worth naming anyway, because it is the same blind spot from the other end: a line-less citation gives `check_citations` nothing to verify. `Coverage/3-FILE-COVERAGE.md:68` records `The Mirror.htm

**Evidence** — VERDICT READ: one member ported and CORRECT on its own constant; the other member absent as a whole handler, for a stated prototype reason. No transposition — the draw did not take 480, and 480 exists nowhere in the app to have been taken from.

THE ONE REAL FIND, and it is the COLLAPSED variant one level down — inside member 1's own pair of constants rather than between the two siblings.

The design distinguishes TWO numbers on the drawn path: the fade lasts **0.55s** (`:264`) and the window is **620ms** (`:193`). The app gives both the SAME value:
    `MirrorView.swift:242`  withAnimation(.easeInOut(duration: 0.62))   ← should be 0.55
    `MirrorView.swift:243`  asyncAfter(deadline: .now() + 0.62)          ← correctly 0.62
The 620 was ported onto the fade as well as onto the window, and the 0.55 has no site in the app — grep for `0.55` in `MirrorView.swift` returns only two color alpha

**Refutation** — SURVIVES ATTACK. Design verbatim: `}, 620);` at The Mirror.html:193 (draw), `}, 480);` at :199 (passDay), both driving `leaving` (declared :170) whose sole visual is :262-264 `transition: 'opacity 0.55s ease, transform 0.55s ease'`. All three copies byte-identical (md5 08adc74c139eebdff958e73e8df08801); no fourth Mirror comp exists, so "different design source" is closed. Siblings are genuine, not coincidental neighbors: adjacent handlers, identical setLeaving/setTimeout structure, one flag, one transition.

Member 1 ported and CORRECT on its own constant: MirrorView.swift:242-247 in drawAlternate(), 0.62 on the window at :243, with `.opacity(leaving ? 0 : 1)` / `.offset(y: leaving ? -6 : 0)` at :123-124 (the -6 verbatim). Member 2 genuinely ABSENT: `passDay`/`dayOffset`/`pass a day`/`adva

### ONE-MISSING — `passage-throat-rings-vs-walls`

**Design** — Two members, thirteen lines apart inside one draw block, both alpha = depth × k × build:

· the rings → k = **0.52**. `Claude Design Round 1/The Instrument v3.html:3653` — `x.strokeStyle=rgba(c,near*0.52*(0.55+0.45*Math.sin(ct*2.2+i))*build);` inside `for(i=0;i<NR;i++)` at :3645, NR=34.

· the walls → k = **0.36**. `Claude Design Round 1/The Instrument v3.html:3666` — `x.strokeStyle=rgba(cc,(1-z0)*0.36*build);x.lineWidth=0.9;x.stroke();` inside `for(i=0;i<52;i++)` at :3658, under the design's own label `/* the walls */` at :3656 and an explicit `x.globalCompositeOperation='lighter'` at :3657.

Shared terms both members multiply: `build` (:3642 `Math.min(1,t*2.6)*(1-ap0*0.55)*(this.on?1:this.after)`) and `run` (:3643). The walls also consume `spin` (:3644), which exists only for them.

**App** — · the rings → **PORTED, wrong constant.** `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift:968`:
`let a = (1 - zz) * 0.5 * (0.55 + 0.45 * sin(Double(i) * 2.1))`
Carries **0.5**, not the design's 0.52. `build` is absent entirely — no `min(1, t*2.6)`, no `(1 - ap0*0.55)`, no `on ? 1 : after` anywhere in `ThroatView` (:956-981), so the rings never build in or fade out with the aperture.

· the walls → **NO PORT.** There is no 52-segment radial-streak loop in the app. Verified by exhaustion across all `*.swift` under `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed`: `0.36` returns 5 hits, all unrelated (`Point/PointWorlds.swift:920`, `:1469`, `Universe/UniRegions.swift:156`, `:552`, `Universe/UniverseView.swift:1232`, `:1406`) and none in any passage/throat file; `spin` has no passage occurrence (only the Dance shader at `InstrumentView.swift:706-716`); no `0..<52` loop exists; `blendMode(.plusLighter)` occurs once, at `Screens/LightView.swift:775`, in the Light. `Instrument/AxisPassage.swift` (83 ll.) is the three physics decisions only and draws nothing; `Instrument/InstrumentField.metal` has no ring or wall term. `ThroatView` is instantiated at exactly one site, `InstrumentView.swift:213`, and is the whole of the app's throat.

So the only two consta

**Comment** — NONE of the known shape — no app comment cites the sibling's design line, because the walls have no app site to carry a comment. But the rings' comment has its own defect, and it is why nothing caught this:

`InstrumentView.swift:951-955` — "THE PASSAGE — the crossing drawn as a throat (spine-passage.js): perspective rings scrolling through the tunnel with an aperture flooding at the far end. … ≈ the full three-act draw; the throat + aperture are here."

Two things. (1) It asserts "the throat … [is] here" while half of the throat is absent — the hedge `≈` is spent on the three-act framing, not

**Evidence** — THE PAIRING IS NOT A PAIRING IN THE APP. 0.52 became 0.50 and 0.36 became nothing.

1 · Not a transposition, and that matters for how it hides. 0.50 is not the sibling's 0.36 and not the design's 0.52 — it is 0.52 rounded. A reader comparing app to design sees one number that is nearly right and no second number at all, which reads as a faithful-but-loose port rather than a dropped mechanism. The design's own header at :3639-3640 names three things — rings, acceleration, "**and the tunnel spins as it goes**" — and the spin exists *only* in the walls (`spin` at :3644 is consumed at :3659 and nowhere else). Dropping the walls therefore drops the third clause of the design's own sentence about this figure, silently.

2 · THE SAME FAULT CLASS, ONE LINE APART, INSIDE THE SURVIVING MEMBER. Design :3648 puts `Math.sin(i*2.1)` on the ring **radius** (`rr=R0*0.085/zz*(1+0.05*Math.sin(i*2.1))`); d

**Refutation** — Survives every attack. DESIGN VERBATIM: :3653 `rgba(c,near*0.52*(0.55+0.45*Math.sin(ct*2.2+i))*build)` and :3666 `rgba(cc,(1-z0)*0.36*build);x.lineWidth=0.9`, with `/* the walls */` at :3656, `lighter` :3657, `for(i=0;i<52;i++)` :3658, `spin` :3644 consumed only at :3659, shared `build` :3642. APP VERBATIM: InstrumentView.swift:968 `let a = (1 - zz) * 0.5 * (0.55 + 0.45 * sin(Double(i) * 2.1))`; ThroatView is :956-981 (rings + aperture only), single call site :213. ATTACK 1, alternate design source — REFUTED DECISIVELY: `diff` reports Claude Design Round 1/The Instrument v3.html and Claude Design Round 2/design-source/The Instrument v3.html BYTE-IDENTICAL, so no variant carries 0.5; and `spine-passage.js` (the source the app comment names) matches no file anywhere — AUDIT.md:238 declares i

### ONE-MISSING — `practice-door-breath-keyframe-bounds` · rows `C5.2`, `C5.6`

**Design** — All three keyframes live in one nine-line style block in `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Practice Door.html`:

· `@keyframes doorBreath` — opacity floor **0.34** → peak **0.78**; transform floor **scale(1)** → peak **scale(1.04)**. Declared at :30-33 (floor line :31, peak line :32). Applied at :224 to the breathing pre-dawn radial gradient, `doorBreath 10s ease-in-out infinite`.
· `@keyframes emberBreath` — opacity floor **0.55** → peak **1**; transform floor **scale(0.97)** → peak **scale(1.06)**. Declared at :34-37 (floor :35, peak :36). Applied at :115 to the 80px Bindu dot, `emberBreath 4s`.
· `@keyframes hintFade` — opacity floor **0.24** → peak **0.55**. Declared on the single line :38. Applied at :272 (tap-to-cross hint) and :318 (tap-to-return hint).

**App** — All three port into one file: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift`. Each reads the one master `Breath`, whose `value` is the eased `(1−cos)/2` travelling a full 0 → 1 → 0 (`Instrument/Breath.swift:52-57`), so `floor + amplitude · value` reproduces the CSS `0%,100% → 50%` shape exactly.

· **doorBreath → `atmosphere(accent:)`, :141-149.** Same element beyond doubt: `RadialGradient(colors: [accent.opacity(0.14), accent.opacity(0.035), .clear], center: UnitPoint(x: 0.5, y: 0.22), …)` is a stop-for-stop port of design :224's `radial-gradient(ellipse 120% 52% at 50% 22%, accent@0.14, accent@0.035 46%, transparent 74%)`.
  `:149  .opacity(0.34 + 0.44 * breath.value)   // the one master breath` → **0.34 → 0.78. Its own.**
  **No `scaleEffect` anywhere on this view** — `grep scaleEffect Screens/PracticeDoorView.swift` returns only :340, the ember's. doorBreath's `scale(1) → scale(1.04)` is unported.

· **emberBreath → `EmberBreathe` ViewModifier, :334-341** (applied at :217 in `binduEmber`, reached from :173 and :198).
  `:339  .opacity(0.55 + 0.45 * v)`  → **0.55 → 1.0. Its own.**
  `:340  .scaleEffect(0.97 + 0.09 * v)` → **0.97 → 1.06. Its own.** Both halves present.

· **hintFade → `tapHint`, :251-258** (used at :131).
  `:257  .opacity(0.24 

**Comment** — **NONE.** No comment on any of the three app sites cites a sibling's design line. The two ported comments are identical and cite nothing: `// the one master breath` (trailing :149 and :257); `EmberBreathe` carries only `// the one 0.1 Hz origin` at :335 and a `// MARK: - Ember breath modifier` header at :332.

The file's one design citation is on a different member entirely — `:178  // Practice Door.html:146,155-159 — the sub-line is the last child of the SAME centred stack as the body, at the container's own gap of 22, so it rises with the body on the shared fade rather than on a timer of its

**Evidence** — **The finding, stated narrowly:** the three opacity floor/peak pairs are MATCHED — each app site carries its own member's constants, with no transposition and no collapse despite the numbers aliasing across the set. The defect is on the transform axis the group flagged as the `#where`-shaped risk: `doorBreath`'s `scale(1) → scale(1.04)` has no port, while its sibling `emberBreath`'s `scale(0.97) → scale(1.06)` is ported in full at `Screens/PracticeDoorView.swift:340`.

Verified numerically:
| member | design floor→peak | app expression | app floor→peak |
|---|---|---|---|
| doorBreath opacity | 0.34 → 0.78 | `:149 0.34 + 0.44 * breath.value` | 0.34 → 0.78 ✓ |
| doorBreath scale | 1 → 1.04 | *(no `scaleEffect` on this view)* | **absent** |
| emberBreath opacity | 0.55 → 1 | `:339 0.55 + 0.45 * v` | 0.55 → 1.0 ✓ |
| emberBreath scale | 0.97 → 1.06 | `:340 0.97 + 0.09 * v` | 0.97 → 1.06 ✓ |

**Refutation** — Survives attack. Design /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Practice Door.html:30-38 reads exactly as quoted (doorBreath 0.34/scale(1) -> 0.78/scale(1.04); emberBreath 0.55/scale(0.97) -> 1/scale(1.06); hintFade 0.24 -> 0.55), applied at :115, :224, :272, :318. App /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift reads exactly as quoted at :149 (0.34 + 0.44 * breath.value), :257 (0.24 + 0.31 * breath.value), :339 (0.55 + 0.45 * v), :340 (0.97 + 0.09 * v). All three opacity pairs land on the CORRECT animation despite the aliasing the group warns about, so this is not TRANSPOSED. `grep scaleEffect` on that file returns only :340; no 1.04 breath scale exists anywhere under Bindu Feed/Bindu Feed; DoorDust.swift has no scale or breath. doorB

### ONE-MISSING — `return-ink-tokens` · rows `E3.10`, `E3.11`, `E3.8`, `F2.4`

**Design** — Design ladder, all three on one `:root` line — `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html:13` (byte-identical line at `The Return v2.html:921`):
· `--ink60` → rgba(237,232,227,**0.6**)
· `--ink35` → rgba(237,232,227,**0.35**)
· `--ink22` → rgba(237,232,227,**0.2**)  ← the name lies; the value is 0.2, not 0.22

The trap named in `whySiblings` is real and the app fell into it. `comps/The Light v2.html:14` calls the identical colour `--ink20`, the honest name.

The app ports **v2**, not comps (its comments cite v2 line numbers `:1136-1141`, `:1142`, `:1167`, `:1170`, and the counter string lacks comps' trailing `· tap`). Both files agree on all three values, so the group holds either way.

`--ink22` has FOUR use sites in v2 — `:1081` (the fall's age caption), `:1140` (role in the Record), `:1178` (the Anew counter), `:1245` (sealPlain). Also relevant: `Mono`'s default colour is `var(--ink35)` (`The Return v2.html:1042`), so a bare `<Mono>` is the 35 rung.

**App** — `--ink60` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:34`
  `static let inkSecondary = Color(hex: "#EDE8E3").opacity(0.60)` — MATCHED.

`--ink35` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:35`
  `static let inkTertiary  = Color(hex: "#EDE8E3").opacity(0.35)` — MATCHED.

`--ink22` → **NO named constant anywhere in the app.** `BinduTheme` (Theme.swift:33-35) is a two-rung ladder: inkPrimary, inkSecondary, inkTertiary, and then it stops. `grep "static let ink"` across all 104 Swift files returns only those three plus an unrelated `ReturnPatina.ink`. The third rung was never declared.

Its four design sites landed on four different answers, none of them 0.2:

(a) `Screens/ReturnView.swift:309` — the Record's role label (design `:1140`):
  `.foregroundStyle(Color(hex: "#EDE8E3").opacity(0.22))`
  The only site given its own number, and it is **0.22 — the name-following error `whySiblings` predicted verbatim.** It is also the sole hand-inlined `#EDE8E3` alpha in the whole Return surface besides one 0.8.

(b) `Screens/ReturnView.swift:389` — the Anew counter (design `:1178`, explicit `color="var(--ink22)"`):
  `.foregroundStyle(BinduTheme.inkTertiary)` = **0.35** — its sibling's constant.

(c) `Screens/ReturnView.swift:603` — sealPlain (d

**Comment** — YES — a range citation that is correct as a range and covers the wrong element, the range-form of the known `#where`/`#pname` fault.

`Screens/ReturnView.swift:285-291`, the comment governing the Record block that contains the 0.22 site at `:309`:

> "// E3.8 · **THE PATINA, AS A MATERIAL.** `:1136-1141` — each voice keeps its
> // own hue and is carried toward `#C09550` by an amount that says how much of
> // its identity the thing still is: ... so the border takes the most gold and
> // the name the least. The app had a flat `.saturation(0.5).brightness(-0.04)`
> // over the block — **one tr

**Evidence** — **Verdict reasoning.** ONE-MISSING is the structural verdict: `--ink60` and `--ink35` are ported as named constants at Theme.swift:34 and :35 with their own correct values; `--ink22` is ported with no constant at all. Every other symptom follows from that absence — with no third rung to reach for, each of the three ported call sites reached for something else, and the design's distinction between the rungs stopped existing. The group also exhibits COLLAPSED (ReturnView.swift:389 and :603 take the siblings' literal constants, 0.35 and 0.60; and :376/:389 render two design-distinct captions identically on one screen) and the name-following wrong constant at :309 (0.22 for 0.2).

**Why this survived every checker.** The 0.22 at `:309` is not a dropped value and not an implausible one — it is the value the token's *name* advertises, so it reads as a careful transcription. The two collapsed s

**Refutation** — ATTACKED ON SIX FRONTS; SURVIVED ALL SIX.

DESIGN LINES — exact. `comps/The Return.html:13` and `The Return v2.html:921` both read `--ink60:rgba(237,232,227,0.6);--ink35:rgba(237,232,227,0.35);--ink22:rgba(237,232,227,0.2)`. The name/value mismatch on the third token is real: 0.2, not 0.22. All four v2 `--ink22` use sites confirmed by grep at :1081, :1140, :1178, :1245 — no fifth, no fewer. `Mono`'s default `color='var(--ink35)'` confirmed at v2:1042.

APP SITES — exact. Theme.swift:33-35 is a three-line ladder ending at `inkTertiary  = ...opacity(0.35)`. `grep "static let ink" --include=*.swift` over the whole repo returns exactly those three plus the unrelated `ReturnPatina.ink` (:84). No `extension BinduTheme` exists anywhere. The third rung is genuinely undeclared. ReturnView.swift:309

### ONE-MISSING — `returnv2-patina-saturation` · rows `E3.12`, `E3.8`, `E3.9`

**Design** — `.dried` → `filter:saturate(.85)` (plus `color:var(--ash)`, italic, two text-shadows) at /Users/ashrey/Bindu Feed/Claude Design Round 1/The Return v2.html:931 — applied at :1150 (Movement IV, the sealed-self paragraph) and :1220 (Movement VII, the reply quote).
`.pressed` → `filter:saturate(.5) sepia(.14) brightness(.92)` at /Users/ashrey/Bindu Feed/Claude Design Round 1/The Return v2.html:932 — applied at :1134, the `<div className="pressed">` that wraps the Record's six gathered voices.
Both rules sit under the one header at :930, `/* ─── the patina, as type materials (§11 · colour, never opacity alone) ─── */`. Also present verbatim in Round 2: /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Return v2.html:931-932. And travelling by hand as stated: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Return.html:572 and :613 both carry `filter:'saturate(0.85)'` inline on the past-self paragraph.

**App** — `.dried` — PORTED, its own constant, twice:
 · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:325 — `.saturation(0.85)                       // .dried — the past self, ash terracotta` on `storyData.sealedSelf` (design :1150).
 · /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:504 — `.font(.loraItalic(15)).foregroundStyle(ReturnCanon.ashColor).saturation(0.85)` on the reply quote (design :1220).

`.pressed` — NO APP SITE TODAY. The Record's voice block (/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:292-319) carries `ReturnPatina.towardGold` colours and no filter of any kind. `grep -rn "sepia" --include="*.swift"` over the whole app → 0 hits; `.saturation(0.5)` → 0 hits (the only two matches for that string are the two prose comments quoted below).

IT WAS PORTED, CORRECTLY, AND WAS DELETED. `git show ddc0623:"Bindu Feed/Bindu Feed/Screens/ReturnView.swift"` line 134:
  `.saturation(0.5).brightness(-0.04)     // .pressed — the aged gathering`
six lines above line 140:
  `.saturation(0.85)                       // .dried — the past self, ash terracotta`
At the original Wave-5 port the pair was MATCHED: each sibling on its own element, each naming its own class, .5 against .85. The `.pressed` half was removed 

**Comment** — Not the wrong-line-citation shape — worse, and invisible to `check_citations` for a different reason: the surviving comments cite NO line at all and reattribute `.pressed`'s design constant to the app as an invention.

/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/ReturnView.swift:285-291, the comment standing where `.pressed` used to be, headed `E3.8 · **THE PATINA, AS A MATERIAL.** `:1136-1141``:
  "The app had a / flat `.saturation(0.5).brightness(-0.04)` over the block — one treatment / for six materials, and age read as *dimmer* rather than as *older*."

/Users/ashrey/Bindu Feed/

**Evidence** — Commands run, read-only:

1. `sed -n '929,933p' "Claude Design Round 1/The Return v2.html"` → :930 the §11 header; :931 `.dried{color:var(--ash);font-style:italic;filter:saturate(.85);text-shadow:0 1px 0 rgba(0,0,0,.55),0 -.5px 0 rgba(255,222,182,.06)}`; :932 `.pressed{filter:saturate(.5) sepia(.14) brightness(.92)}`.
2. `grep -n "pressed\|dried" "Claude Design Round 1/The Return v2.html"` → class USE sites: :1134 `<div className="pressed" …>` (Record container, six voices), :1150 `<p className="dried" …>{first.words}</p>`, :1220 `<p className="dried" …>“{P.quote}”</p>`.
3. `grep -rn "saturation" --include="*.swift"` over /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed → 10 hits. The two Return ones are ReturnView.swift:325 and :504, both `0.85`. Nothing at 0.5.
4. `grep -rn "brightness(\|sepia\|\.saturation(0\.5" --include="*.swift"` → 2 hits, both PROSE: ReturnPatina.swift:11 and Return

**Refutation** — Survives attack on every axis. DESIGN verbatim: The Return v2.html:930 header "the patina, as type materials (§11 · colour, never opacity alone)"; :931 `.dried{...filter:saturate(.85);...}`; :932 `.pressed{filter:saturate(.5) sepia(.14) brightness(.92)}`. Use sites :1134 (pressed div over the six GATHERING voices), :1150, :1220 — identical in Round 2 design-source; comps/The Return.html:572 and :613 carry saturate(0.85) inline, so the .85 does travel by hand.

STRUCTURAL CHECK THE FINDING OMITTED, which could have refuted it: .dried at :1150 is NOT nested inside the .pressed div — that div closes at :1147 and :1150 sits in a separate sibling div (padding:'30px 22px 0'). The two filters never compound in the browser; they are independent treatments on disjoint elements. That is the conditio

### ONE-MISSING — `rite-voice-reveal-durations` · rows `E2.1`, `E2.2`, `E2.5`

**Design** — Member A — the voice's lines `<p>` → `animation:'dissolve 1.9s ease-out both'` at `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Rite v3.html:1399` (inside `GVoiceText`, the `v.lines.slice(0,shown).map` block).
Member B — the voice's closing glyph `<p>` → `animation:'dissolve 2.2s ease-out both'` at `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Rite v3.html:1402` (the `v.close && v.tier!=='passing' && allShown` branch).
Third sibling in the same component, for context: the header block at `:1389` carries `dissolve 1.6s`. The keyframe itself is `@keyframes dissolve{from{opacity:0}to{opacity:1}}` at `:1157`. The design's ordering is deliberate and monotone: header 1.6 < words 1.9 < close 2.2 — the close settles slowest.

**App** — The port is `VoiceText` in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:257-323` (renamed from `GVoiceText`; mounted at `:113` inside `presenceLayer`).

Member A (the lines) — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:291-301`:
  `ForEach(Array(lines.enumerated()), id: \.offset) { i, line in Text(line) … .opacity(i < shown ? 1 : 0) … .animation(.easeInOut(duration: 1.9), value: shown) }`
  Carries ITS OWN member's constant: **1.9**. Correct.

Member B (the closing glyph) — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:304-311`:
  `if shown >= lines.count { Text(voice.close) … .transition(.opacity) .padding(.top, 4) }`
  Carries **no duration at all**. `.transition(.opacity)` has no timing of its own; it takes whatever animation is in scope when the state flips. The state that flips it is `shown`, incremented at `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:222` inside `withAnimation(.easeInOut(duration: 1.2)) { shown += 1 }` (and reset by `withAnimation(.easeInOut(duration: 1.0)) { enter(idx + 1) }` at `:224`).

So the close renders at **1.2s**, borrowed from the tap handler, not 2.2s. `grep "2\.2"` across `Screens/RiteGatheringView.swift`, 

**Comment** — NONE — and that is itself the reason this one is invisible to `check_citations` rather than survivable through it.

The only comment in the region is `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/RiteGatheringView.swift:290`:
  `// Body lines, surfacing one per tap.`
It cites no design line — not `:1399`, not `:1402`. The closing-glyph site at `:304-311` carries no comment whatsoever.

`grep -rn "1399\|1402\|1389"` across the whole app source returns zero hits for this file. The nearby `The Rite v3` citations that DO exist point elsewhere: `:86` ("the touch hint … comp The Rite v3"),

**Evidence** — Not a transposition — the app did not give the close the words' number. It gave the close no number, and the words the right one, so exactly half the pair survived the port.

WHY IT SURVIVED (the same shape as the `#where`/`#pname` instance, one step further along): a reviewer opening `VoiceText` sees `.animation(.easeInOut(duration: 1.9), value: shown)` on the lines and concludes the block's timing was ported. The close sits eight lines below with `.transition(.opacity)` — which LOOKS like a deliberate SwiftUI idiom rather than a hole, because a transition is a legitimate way to animate an insertion. It just has no duration of its own. The 2.2 does not appear as a wrong number anywhere; it simply never arrives, and the close silently adopts 1.2s from `withAnimation` at `:222`, twenty lines away in a different type's method. Nothing in `VoiceText` states the close's duration, so nothing 

**Refutation** — Survives attack on every axis. DESIGN EXACT: `The Rite v3.html:1399` reads `animation:'dissolve 1.9s ease-out both'` and `:1402` reads `animation:'dissolve 2.2s ease-out both'`, both `<p>` siblings inside one `GVoiceText` return, three lines apart, on the same `@keyframes dissolve` at `:1157`, with the header at `:1389` at 1.6s completing a monotone 1.6 < 1.9 < 2.2. NOT A DIFFERENT SOURCE: `Claude Design Round 1/The Rite v3.html`, `Claude Design Round 1/comps/The Rite v3.html` and `Claude Design Round 2/design-source/The Rite v3.html` are byte-identical (diff -q), so no later comp carries a revised constant. APP EXACT: `RiteGatheringView.swift:258` `private struct VoiceText`, mounted once at `:113`; `:301` carries `.animation(.easeInOut(duration: 1.9), value: shown)` on the lines; `:304-31

### ONE-MISSING — `rope-ring-sizes` · rows `D2.6`, `D5.11`, `E1.18`, `F11.2`

**Design** — `#rope .ring` → width:120px;height:120px — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4413 (`position:relative;width:120px;height:120px;display:flex;align-items:center;justify-content:center;transition:margin 1.6s ease`). `#rope .ring i` → width:110px;height:110px;border-radius:110px — same file :4415 (`position:absolute;width:110px;height:110px;border-radius:110px;border:1px solid rgba(229,83,60,.16)`). Markup at :4666-4667 confirms the nesting: `<div id="rope"><div class="ring"><i></i><b></b></div>`. Identical in Round 2 (`Claude Design Round 2/design-source/The Instrument v3.html:4413,4415`). The competing rope source, `point-levels.js:72-80`, has no ring at all — only `#rope .rdot{width:15px;height:15px}` — so The Instrument v3 is the only source for this pair, and the app's 110 + 9 pair proves that is what it ported from.

**App** — The whole rope is one view, `DoorRopeOverlay`, at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:238 (raised from both call sites — `DoorView.swift:62` and `Instrument/InstrumentView.swift:323` — so there is exactly one port to check).
· `#rope .ring i` (110) → PORTED, with its own constant: `DoorView.swift:249-250` `Circle().stroke(BinduTheme.colorBindu.opacity(0.16), lineWidth: 1).frame(width: 110, height: 110)`. Border 1px and alpha .16 also match :4415.
· `#rope .ring` (120) → NOT PORTED. `DoorView.swift:248` is a bare `ZStack {` with no `.frame` anywhere on it or its VStack parent (:246), so in SwiftUI the container sizes to its largest child and IS 110×110. No app expression anywhere carries 120 for this element — the only `width: 120, height: 120` in the whole app source is `Point/ApertureView.swift:231`, and that is the aperture eye (its own doc comment cites `point-levels.js:120-121`), a different element in a different screen.
Sibling `#rope .ring b` (9px, :4416) is ported correctly at `DoorView.swift:253` `.frame(width: 9, height: 9)`, which is what makes the missing member conspicuous: two of the three children of the same CSS block came across with their constants and the box they sit in did not.

**Comment** — NONE — and the absence is itself the tell. The only comment on the pair is `Screens/DoorView.swift:247`: "// The particle in its ring, breathing." It cites no design file and no design line, so there is no wrong-sibling citation of the `#where`/`#pname` kind — but equally there is nothing for `check_citations` to check. The constant 110 is uncited, the box that should have been 120 is uncommented and un-coded, and the struct's only other comment (`:236-237` "Reusable — the Door raises it on a threshold long-press; the axis raises it from anywhere (§7.5…)") is about who raises the overlay, not 

**Evidence** — WHAT ACTUALLY HAPPENED: the design's `.ring` is a 120px flex box with a 110px circle absolutely positioned inside it — 5px of clearance all round. The app ported the circle and dropped the box, so container and inscribed circle are both 110 and the design's 10px distinction is gone. Mechanically it is ONE-MISSING (one member ported with its constant, the other silently without); the EFFECT is a collapse, because SwiftUI silently supplies the missing value from the sibling that was ported. That is why it looks fine: unlike the design's failure mode (swap them and the ring overflows its box by 10px on a black field), an omitted box produces no overflow, no clipping, no warning — the ring just sits 5px tighter than drawn.

THE OMISSION IS NOT INERT — it is load-bearing on the very next design line. `:4414` `#rope.said .ring{margin-bottom:46px}` measures from the 120 box's edge, so the desig

**Refutation** — Survives every refutation attempt. DESIGN VERBATIM: :4413 `#rope .ring{position:relative;width:120px;height:120px;...transition:margin 1.6s ease}` and :4415 `#rope .ring i{position:absolute;width:110px;height:110px;border-radius:110px;border:1px solid rgba(229,83,60,.16)}` — exact, same line numbers in Round 2. NOT NEAR-NEIGHBOURS: markup :4666-4667 `<div class="ring"><i></i><b></b></div>` is literal nesting, so a false-TRANSPOSED swap risk does not arise (and the verdict is not TRANSPOSED anyway). NO LATER OVERRIDE: every `.ring` rule in the design file is :4413-4416; the :401/:1440/:5944-5945 hits are the unrelated JS identifiers `U.ring`/`ringLit`. SOLE SOURCE CONFIRMED: comps/point-levels.js:72-80 has no ring, only `.rdot{width:15px;height:15px}` with a 15px dot — the app's 9px dot and

### ONE-MISSING — `spine-axis-ceremony-door-tones` · rows `C5.6`

**Design** — Three ceremony doors, one array literal, `Claude Design Round 2/design-source/spine-axis.js:60-69` (byte-identical twin at `Claude Design Round 2/design-source/The Instrument v3.html:1026-1035`):

· `return` (z:-1) → tone:126 — `spine-axis.js:61-62`, label 'open the return', line 'You came down to it yourself.'
· `rite` (z:0) → tone:220 — `spine-axis.js:63-64`, label 'open the rite', line 'The field is gathering on this one.'
· `return6` (z:7, deep:true) → tone:126 — `spine-axis.js:67-68`, label 'open the return', line 'This depth and that descent are the same room.'

The single consumer is `cross(d)` → `B.threshold(d.tone)` at `The Instrument v3.html:5112-5117`. NOTE the design itself never fires the z:0 rite door through that path: `paintDoors` at `:5104` reads `S.doorsAt(Z,SIX.d).filter(x=>x.d.z!==0)`, so `tone:220` is dormant in the design and the rite is reached instead through the turn row `{id:'rite',…,hz:220}` (`:1534-1535`, `takeRow` → `B.threshold(r.hz)` at `:5076`) and through `crossDoor()`'s `B.threshold(unmet?220:261)` (`:5020-5022`). Both independently say 220 for the rite, so the design's distinction (126 · 220 · 126) is corroborated, not an artifact.

**App** — There is NO `DOORS` table in the app. The three members are hand-placed in three different files, and only one of the three carries a tone.

· `return` (z:-1) — PORTED WITH ITS CONSTANT. Chrome: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:683-688` draws "You came down to it yourself." and "OPEN THE RETURN" in `drawMouth`. Tone: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:225` — `soundEngine.fieldThreshold(hz: 126, dur: 9)`, fired on `cam.mouthMeant` 0.28s before `onFall(story)`. 126 = its own member's value. ✓

· `rite` (z:0) — NOT PORTED AS A DOOR. Neither string exists in the app: grep for `open the rite` and `The field is gathering on this one.` across all `*.swift` returns nothing. (`/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:99` has "The field is gathering." — a shortened app-own loading placeholder, in a different screen, absent from every design file.) The only 220 that opens the rite is `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:193` — `soundEngine.spineThreshold(hz: 220)` inside `receiveTheRite()` — and that is a port of `crossDoor()`, not of the door. The in-app turn reaches the rite with NO tone at all: `/Users/ashrey/Bindu Feed/Bindu Feed/Bind

**Comment** — No comment cites a sibling's design line — each of the three citations verifies clean, and that is exactly why this stayed invisible. Two are correct-and-harmless; the third is the fault shape, one file over.

1. `Point/PointWorldView.swift:250` — `// \`spine-axis.js:67-68\` — the z:7 \`return6\` door.` CORRECT: :67-68 IS return6's own entry, and `tone:126` sits on :68 — the very line cited. The comment then justifies only the label and the line ("A door carries a LABEL and a LINE; the app had fused an invented \"settle deeper ·\" onto the label and dropped the line entirely. Both restored, ve

**Evidence** — METHOD AND COMMANDS (read-only; no edits made).

Design side:
· `sed -n '56,70p' "Claude Design Round 2/design-source/spine-axis.js"` — the DOORS literal with line numbers; tone:126 on :62, tone:220 on :64, tone:126 on :68; the "VI is called The Return…" comment on :65-66.
· `grep -rn "DOORS|\.tone" "Claude Design Round 2/design-source/"` — the only consumers are `doorsAt` (`spine-axis.js:123`, richer twin `The Instrument v3.html:1090-1099` with the `deep>0.72` gate) and `cross(d)` → `B.threshold(d.tone)` at `The Instrument v3.html:5114`.
· `sed -n '5100,5120p'` of The Instrument v3.html — `paintDoors` filters `x.d.z!==0`, proving the rite door's 220 is dormant in the design's own door path.
· `sed -n '5015,5030p'` — `crossDoor(){ const unmet=GR.weather==='unmet'; B.threshold(unmet?220:261); … }` — the line DoorView.swift:193 cites.
· `awk NR 1710-1720` of The Universe v3.html — :1716 is

**Refutation** — SURVIVES every refutation attempt. DESIGN VERIFIED VERBATIM: spine-axis.js:60-69 reads exactly as quoted — tone:126 on :62 (return, z:-1), tone:220 on :64 (rite, z:0), tone:126 on :68 (return6, z:7, deep:true), with the kinship comment on :65-66; byte-identical twin at The Instrument v3.html:1026-1035. Sole consumer cross(d)->B.threshold(d.tone) at :5114; paintDoors at :5104 does filter x.d.z!==0 and doorsAt at :1090-1099 gates deep on deep>0.72, so return6 DOES surface and DOES fire 126 in the design while the rite's 220 is dormant there. RIVAL DESIGN SOURCE RULED OUT (the strongest available refutation): grep -rn "same room" over "Claude Design Round 2/" returns only spine-axis.js:67 and The Instrument v3.html:1033 — world-six.js has nothing, The Point v9.html has no return door. PointWo

### ONE-MISSING — `spine-sound-named-strike-peaks` · rows `C7.3`, `C7.5`, `G3.3`

**Design** — Six members, all in `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/spine-sound.js`:
· B.slide → peak 0.032, attack t+0.6, then setTargetAtTime(0, t+1.6, 0.6), stop t+4 — site :340 (fn :334-341)
· B.blip → peak 0.07, attack t+0.02, exp to 0.0001 at t+0.7 — site :348 (fn :343-350)
· B.threshold → peak 0.06, attack t+0.5, exp to 0.0001 at t+6, enters at f*0.985 and reaches tune at t+2.2 — site :360 (fn :352-362)
· B.shimmer → peak 0.03, attack st+0.1, exp to 0.0001 at st+1.6, five tones staggered 0.18 — site :369 (fn :363-373)
· B.om → peak 0.06/(i+1), attack t+0.9, exp to 0.0001 at t+9, three tones — site :380 (fn :374-384)
· B.send → peak 0.075, attack t+0.05, exp to 0.0001 at t+1.7 — site :195 (fn :188-203)

**App** — Five of six ported, each carrying ITS OWN constant. All in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift`:
· B.send → `send(hz:pan:)` :654-660 — `CeremonyVoice(hz: hz * 2, peak: 0.075, attackSeconds: 0.05, releaseSeconds: 1.65, …)` at :655-656. MATCHED (0.075 / 0.05).
· B.blip → `blipVoice(hz:)` :1097-1101 — `peak: 0.07, attackSeconds: 0.02, releaseSeconds: 0.68` at :1098-1099. MATCHED. Called via `blip(hz:)` :1021, from `LightView.swift:270` and `SoundEngine.swift:795` (join's `this.blip(f*0.25)`).
· B.threshold → `spineThresholdVoice(hz:)` :1088-1093 — `hz: hz * 0.985, peak: 0.06, attackSeconds: 0.5, releaseSeconds: 5.5, endHz: hz, glideSeconds: 2.2` at :1089-1092. MATCHED, detune and 2.2s glide intact. Called via `spineThreshold(hz:)` :1015, from `InstrumentView.swift:437`, `DoorView.swift:184,193`, `SoundEngine.swift:1533` (inside `axisGive`).
· B.shimmer → `shimmer()` :766-775 — `peak: 0.03, attackSeconds: 0.1, releaseSeconds: 1.5, startDelaySeconds: i * 0.18` at :768-771. MATCHED.
· B.om → `om()` :1032-1039 — `peak: 0.06 / (Double(i) + 1), attackSeconds: 0.9, releaseSeconds: 8.1` at :1034-1035, over [136.1, 272.2, 408.3]. MATCHED, and the `/(i+1)` division is preserved rather than flattened to a shared 0.06.
· B.slide → NO PORT. `0.032` appears exa

**Comment** — NONE. Every one of the five ported members carries a comment citing its OWN design lines, and each cited range actually contains that member's ramp:
· `SoundEngine.swift:649` (send) — "`spine-sound.js:189-203`: … 0 → 0.075 at 0.05s" → ramp is at :195, inside :188-203. Own element.
· `SoundEngine.swift:1095` (blip) — "`spine-sound.js:343-350`. One sine at `f*2`, 0.02s up, 0.7s and gone." → ramp at :348. Own element.
· `SoundEngine.swift:1082` (spine threshold) — "`spine-sound.js:353-361`. Peak **0.06** … up at 0.5s, exponential to 0.0001 at 6s." → ramp at :360. Own element.
· `SoundEngine.swift

**Evidence** — HOW EACH WAS CHECKED. Design constants read from `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/spine-sound.js` (`grep -n linearRampToValueAtTime` → :195, :340, :348, :360, :369, :380 confirm the six sites the brief names). App constants read from `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Sound/SoundEngine.swift`; a full `grep -rn "peak:"` over the app tree (28 hits) confirms there is no second, competing definition of any of these five voices — every call goes through one factory.

THE PAIRWISE TESTS THE FAULT CLASS ASKS FOR, all negative:
· TRANSPOSED — blip/threshold are the adjacent, identically-shaped pair (single sine, one ramp up, exponential down) separated only by 0.07 vs 0.06 and 0.02 vs 0.5. The app holds them apart correctly: `:1098` 0.07/0.02/0.68 and `:1089` 0.06/0.5/5.5. Not swapped.
· COLLAPSED — threshold and om already share 0.06 in the design, whic

**Refutation** — SURVIVES. I tried to break it on all four axes the brief names and could not.

DESIGN — all six lines read EXACTLY as quoted (`Claude Design Round 2/design-source/spine-sound.js`). `grep -n linearRampToValueAtTime` returns :195, :340, :348, :360, :369, :380 and nothing else in the strike band; function heads at :188 send, :321 axis, :333 slide, :343 blip, :353 threshold, :363 shimmer, :374 om. :340 is verbatim `gn.gain.linearRampToValueAtTime(0.032,t+0.6);gn.gain.setTargetAtTime(0,t+1.6,0.6);`.

APP — all five ported sites read exactly as quoted in `Bindu Feed/Bindu Feed/Sound/SoundEngine.swift`: send :655-656 (0.075/0.05), shimmer :768-771 (0.03/0.1, delay i*0.18), om :1034-1035 (0.06/(i+1), 0.9), spineThresholdVoice :1089-1092 (hz*0.985, 0.06, 0.5, endHz hz, glide 2.2), blipVoice :1098-1

### ONE-MISSING — `story-ash-question-two-renderings` · rows `F10.3`, `F5.2`, `F9.1`

**Design** — Member A · AshEntry "What arrived for you?" → Lora italic, fontSize 14, `color: \`${ASH.color}70\``, letterSpacing 0.01em — /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Story Detail.html:637-641 (constant on :639, text on :641). `ASH.color = '#C47A52'` (:414), so the literal is the 8-digit hex `#C47A5270` → alpha 0x70 = 112/255 = **0.4392**.

Member B · Compose "What arrived for you?" → Lora italic, fontSize 15, `color: ASH.color` (full), letterSpacing 0.01em, `opacity: 0.85` — Story Detail.html:669-673 (constants on :671, text on :673). Dimmed by a separate opacity channel, not by a hex suffix.

Design gap between the two renderings: 0.44 vs 0.85 — the entry is roughly half the compose's presence.

**App** — Member A · PORTED, wrong constant — /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/AshEntryRow.swift:33-36
    Text("What arrived for you?")
        .font(.loraItalic(14))
        .foregroundColor(terra.opacity(0.70))
        .tracking(0.2)
`terra = BinduTheme.colorAsh = #C47A52` (Theme.swift:45), so the colour is right and the 14 is right. The alpha is **0.70 where the design says 0.4392** — the hex suffix `70` transcribed as a decimal fraction. The prompt renders ~59% brighter than authored. (`.tracking(0.2)` vs 0.01em × 14 = 0.14pt is a separate minor drift.)

Member B · NOT PORTED as a Story Detail element — superseded. Story Detail's inline Compose card no longer exists in the app: StoryDetailView.swift:270-271 says "The compose ritual lives in AshComposeView, pushed as a route," and AshComposeView.swift:5 says it "replaces the inline AshComposer." The surviving rendering is /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshComposeView.swift:166-170
    Text("What arrived for you?")
        .font(.loraItalic(21))
        .foregroundColor(accent.opacity(0.92))
        .opacity(armed ? 0.45 : 1)
and that is an exact port of the Phase 9 comp /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/Ash's Compose.html:194-199 — `fontSize: 21`, `color: hexA(ACCENT, 

**Comment** — NONE — and the absence is itself the reason this survived. Neither app site carries any design citation at all. AshEntryRow.swift:3-5 is prose with no line reference ("The four words are exact and permanent"), and it comments only on the STRING, which is correct — the wrong number sits one line below an assertion that the words are right. AshComposeView.swift:164-166 has no comment above the prompt. The nearest citation in that file, AshComposeView.swift:186-187 — "`Claude Design Round 1/comps/Ash's Compose.html:73-83` — `const R = 31` inside an `svg 80×80`" — is a correct citation of its own 

**Evidence** — THE FAULT: a fifth variant of the class — **the right digits, in the wrong unit.** `70` is an alpha byte (0x70/255 = 0.4392); the app wrote `0.70`. Every string checker passes: the numeral `70` is present, the font size is right, the colour token is right, the copy is exact.

WHY IT IS A SLIP AND NOT A HOUSE CONVENTION — three proofs:
1. The codebase states the rule in its own words. /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/GameView.swift:364: "alphas are the comp's hex/255."
2. The SAME FILE does it both ways. AshEntryRow.swift:113 `.fill(terra.opacity(0.05))` correctly converts `${ASH.color}0B` (Story Detail.html:800, 0x0B/255 = 0.043 → 0.05). Eighty lines below the faulty line, the conversion is performed.
3. …and then fails again four lines later. AshEntryRow.swift:117 `.strokeBorder(terra.opacity(0.22), lineWidth: 0.5)` against Story Detail.html:801 `border: 1px solid 

**Refutation** — Every quoted line verified verbatim. DESIGN: Story Detail.html:414 `const ASH = { name: 'Ash', color: '#C47A52', g: '◉' }`; :639 `fontSize: 14, color: `${ASH.color}70`,` (text :641); :671-672 `fontSize: 15, color: ASH.color,` / `letterSpacing: '0.01em', opacity: 0.85,` (text :673). 0x70/255 = 0.4392. APP: AshEntryRow.swift:33-36 reads exactly as quoted; terra = BinduTheme.colorAsh = Color(hex: "#C47A52") — actual path is Bindu Feed/Bindu Feed/Theme/Theme.swift:45 (line right, path one directory deeper than the finding wrote). So the alpha fault is real: 0.70 where the comp authored 0.4392.

REFUTATIONS ATTEMPTED, ALL FAILED. (1) Alternate design source: grep of "What arrived for you" across the entire design set shows the entry row is rendered ONLY at Story Detail.html:639 — Ash's Compose.

### ONE-MISSING — `turn-hd-vs-foot-tracking` · rows `F11.2`, `F11.3`

**Design** — Both members live in one rule block, twelve lines apart, and the app renders both from one file.

· `#turn .hd` → `font-size:10px; letter-spacing:.34em` → 3.4px of tracking
  `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4397`
  Second witness, identical: `/Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:439` (`fontSize:10, letterSpacing:'0.34em'`).

· `#turn .foot` → `font-size:9px` (rule opens `:4407`) + `letter-spacing:.2em` (`:4408`) → 1.8px of tracking
  `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4407-4408`
  Second witness, identical: `/Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:456-457` (`fontSize:9, letterSpacing:'0.2em'`).

`#turn` exists in only one design file (plus its Round-2 copy), so there is no competing definition. `Home Feed.html:185` draws the same string at 9px/`0.18em` for the older hub, which the turn superseded.

**App** — One port, one file: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift`. It is the sole renderer of both strings — `DoorView.swift:55` presents it at the launch Door and `HubOverlay.swift:14` presents the same struct for every top-level surface, so there is no second site.

· `#turn .hd` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:63-64`
  `Text("WHERE TO").spaceMonoTracked(10, em: 0.34)` → tracking = 0.34 × 10 = **3.4** — ITS OWN constant, correctly converted. ✓

· `#turn .foot` → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:93-94`
  `Text("tap anywhere to stay").spaceMonoTracked(9, em: 2 / 9)` → tracking = (2/9) × 9 = **2.0**, i.e. 0.222em. The design asks 1.8 (0.2em × 9). ✗

The helper is unambiguous — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151-153`: `.tracking(em * size)`. So `em:` is the em fraction and the header passes it as one; the foot passes `2 / 9`, which is not an em fraction at all but a fraction contrived to make the product come out at a literal 2 points.

NOT TRANSPOSED and NOT COLLAPSED: the foot does not carry 0.34/3.4, and the two are still distinct, so the pair's direction survives — the widest tracking is still on the header. The `whySiblin

**Comment** — NONE — neither app site carries a comment at all, so no comment on one member cites the other's design line. `TurnOverlay.swift` has no `:4397`/`:4408` citations anywhere; its only design reference is a prose one at `:72-73` ("comp A Strange Feed.html turn marks") pointing at the row marks, not at either caption. `check_citations` had nothing to check on this pair.

The equivalent fault is one level up, in the audit row's own evidence. F11.3's AUDIT.md text (`/Users/ashrey/Bindu Feed/Claude Design Round 2/audit/AUDIT.md:869`) says:

  "Overlay chrome matches (`rgba(8,7,11,0.80)` + blur; **`\"W

**Evidence** — 1. **The conversion convention is proved by the app's own comments.** `InstrumentView.swift:531` — `.spaceMonoTracked(9, em: 0.3)  // .3em × 9` — and `:513-514` `spaceMonoTracked(7.5, em: 0.14)` against `The Instrument v3.html:4386` `#seam{font-size:7.5px; letter-spacing:.14em}`. Design px maps 1:1 to points and the em fraction is passed straight through. Under that convention the foot should read `em: 0.2` (tracking 1.8) and reads `em: 2 / 9` (tracking 2.0).

2. **Git shows the constant was never converted, only re-spelled.** `git log -L 90,96` on the file gives one commit touching it, `b19f1d6` ("E1.18 the mono case as a default"):
   `- .font(.spaceMono(9)).textCase(.uppercase).tracking(2)`
   `+ .spaceMonoTracked(9, em: 2 / 9)`
   The original was a raw `.tracking(2)` — the design's `.2em` with the decimal point and the ×font-size step dropped. The refactor preserved the number exact

**Refutation** — ATTACKED ON SIX FRONTS; IT SURVIVES ALL SIX.

1. DESIGN LINES READ EXACTLY AS QUOTED. `/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4397` is `#turn .hd{...font-size:10px;letter-spacing:.34em;color:rgba(237,232,227,.35);margin-bottom:30px}`; `:4407-4408` is `#turn .foot{...font-size:9px;` / `letter-spacing:.2em;text-transform:uppercase;color:rgba(237,232,227,.35)...}`. Second witness exact: `/Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:439` `fontSize:10,letterSpacing:'0.34em'` and `:457` `letterSpacing:'0.2em'` on the `fontSize:9` span. The Round-2 copy at `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Instrument v3.html:4397,4407` is byte-identical. So 3.4px vs 1.8px, from two independent sources, with no competing definitio

### ONE-MISSING — `turn-panel-vs-row-duration` · rows `D2.6`, `F11.2`, `F11.3`

**Design** — Round 1 · `The Instrument v3.html`:
· `#turn` (the scrim) → `transition:opacity .42s ease` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4395 (block opens :4393)
· `#turn .row` → `transition:opacity .62s ease,transform .62s ease` — :4399, staggered by `row.style.transitionDelay=(0.14+i*0.075)+'s'` at :5039
· `#rope` → `transition:opacity 1.1s ease` — :4411 (fires on `openRope()` :5087, itself armed by a 1100 ms press at :5877)

The SAME three constants are in the comp the app's turn was actually ported from — `A Strange Feed.html`, the file the F11 rows cite:
· turn scrim → `transition:'opacity 0.42s ease'` — /Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:438
· rows → `transition:'opacity 0.62s ease ${0.14+i*0.075}s, transform 0.62s ease ${0.14+i*0.075}s'` — :447
· rope → `animation:'surface 1.1s ease both'` — :474
Two further siblings in the same block, same family: header `opacity 0.7s ease 0.1s` (:440) and foot `opacity 0.9s ease 0.7s` (:458).

**App** — · `#turn .row` → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Components/TurnOverlay.swift:87 — `.animation(.easeOut(duration: 0.62).delay(0.14 + Double(i) * 0.075), value: appear)`. Its own constant, AND the design's stagger formula verbatim. Correct.
· `#rope` → /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:176 — `withAnimation(.easeInOut(duration: 1.1)) { showRope = true }`, over `DoorRopeOverlay(...).transition(.opacity)` at :62. Its own constant. Correct on the way in. (The 1.1 at :172, `LongPressGesture(minimumDuration: 1.1)`, is a SEPARATE correct port of the design's 1100 ms press at :5877 — the two 1.1s are not a duplication.)
· `#turn` (the scrim) → NO app expression carries .42. The overlay is `if showTurn { TurnOverlay(...).transition(.opacity) }` (DoorView.swift:55-59), so its fade duration is whatever the caller's `withAnimation` supplies, and there are four callers, none of them .42:
  – DoorView.swift:185 `withAnimation(.easeInOut(duration: 0.5)) { showTurn = true }` (the pull)
  – DoorView.swift:155 `Button { withAnimation { showTurn = true } }` (the dot mark) — SwiftUI's implicit `.default`
  – DoorView.swift:57 `onStay: { withAnimation { showTurn = false } }` — implicit `.default`
  – Components/HubOverlay.swift:18, :22, :45 `.easeInOu

**Comment** — NONE of the cross-citation kind — no comment on one member cites another member's design line. But the adjacency that made the wrong number look sourced is worth quoting. DoorView.swift:184, the line DIRECTLY above the wrong duration, is:

    soundEngine.spineThreshold(hz: 146)   // `openTurn(){B.threshold(146)}` — Instrument v3:5082

`:5082` is `function openTurn(){B.threshold(146);turnEl.classList.add('on');}` — the turn's own opener, and the very statement (`classList.add('on')`) that fires the `.42s` fade at :4395. The citation is correct, and it is correct about the SOUND. It sits one li

**Evidence** — HOW THE MISS SURVIVED — the group's shape, not a dropped digit.

1. The port was split across a file boundary that follows SwiftUI's grammar, not the design's. In CSS all three constants sit in one stylesheet within 18 lines of each other; in the app the row's `.62` is a modifier ON the row (TurnOverlay.swift:87) while the scrim's `.42` would have to live in whatever presents the overlay — and that is three different call sites in two other files. A reader auditing "the turn" opens TurnOverlay.swift, finds `0.62` with the design's exact stagger, and closes the row. That is F11.3, verbatim: *"matches, a strong port"*.

2. The counted evidence that nobody weighed these against each other: the design's turn block carries FOUR appear constants — scrim `.42` (:438), header `0.7 ease 0.1s` (:440), rows `.62` + delay `0.14+i*0.075` (:447), foot `0.9 ease 0.7s` (:458). Exactly ONE of the four is

**Refutation** — Survives attack on every axis. DESIGN verbatim: Instrument v3:4395 `transition:opacity .42s ease`, :4399 `.62s`, :4411 `1.1s`; JS cites exact (:5039 stagger, :5082 `openTurn(){B.threshold(146);turnEl.classList.add('on');}`, :5091 `closeRope()` removes `.on` so 1.1s IS symmetric, :5877 the 1100ms press). A Strange Feed.html corroborates at :438/:447/:474 — both comps agree on .42. APP verbatim: TurnOverlay.swift:87 `.easeOut(duration: 0.62).delay(0.14 + Double(i) * 0.075)`; DoorView.swift:176 `easeInOut(1.1)` over `.transition(.opacity)` :62, distinct from the :172 LongPressGesture. `grep "duration: 0.42"` over the whole app = ZERO hits (all ~30 raw 0.42s are the Metal shader, onGround, dance sync, opacities). All four presenters read as quoted: :185 `0.5`, :155 and :57 bare `withAnimation`

### ONE-MISSING — `universe-chrome-caption-ink` · rows `B5.2`, `B5.3`, `B7.4`

**Design** — All four sites confirmed in `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Universe v3.html` (single-commit file, a41b1f3 — it has never been renumbered, so every citation below is checked against the only version that ever existed):

· `.where` → `color:rgba(237,232,227,.42)` — rule opens :1381, color on :1382. A transient caption driven by `say()` (:1470-1473), fired from six sites (:1482, :1483, :1484, :1526, :1532, :1533, :1546, :1650).
· `.lenslabel` → `color:rgba(237,232,227,.46)` — rule opens :1387, color on :1388. mono 8px / .2em / uppercase.
· `.ret b` → `color:rgba(237,232,227,.72)` — :1401, plus `border-bottom:1px solid rgba(237,232,227,.22)`, mono 9px / .22em / uppercase. Text is "open the return" (:1438).
· `.bench` → `color:rgba(237,232,227,.28)` — :1414. Design's own JS at :1722 declares it: *"the bench. Review controls never ship."*

CONFOUNDER CLEARED: `.lensrail b`'s knob at :1385 does carry `.42`, repeating `.where`'s number on a different element — but it is not the thief. See appPair.

**App** — · `.lenslabel` → **PORTED, ITS OWN CONSTANT.** `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift:409-411` — `Text(LensRail.label(lensTarget)).spaceMonoTracked(8, em: 0.2).foregroundStyle(Color(hex: "#EDE8E3").opacity(0.46))`. Ink .46 on .lenslabel. Size 8, .2em, uppercase-by-role. MATCHED.

· `.where` → **NO PORT.** No element, no `say()`, no transient caption in the Universe. `grep` for its authored strings across the whole app: "newly alive" / "still waiting" / "long lived on" / "the newest self" → 0 hits. `grep "0.42)"` across `Universe/` returns only geometry (`UniRegions.swift:267,361,363`; `UniverseView.swift:945,1443`) and the star-name alpha at `UniverseView.swift:1006`, which is `lens * min(0.42, (z-0.85)*0.7)` — a verbatim port of design `:1275`, its own .42, not `.where`'s.

· `.ret b` → **PORTED, WRONG INK AND WRONG ALPHA.** `UniverseView.swift:686-688`, inside `drawMouth`:
  `ctx.draw(Text.spaceMono("OPEN THE RETURN", 9, .asWritten).foregroundStyle(Color(hex: "#E5533C").opacity(0.7 * open)), …)`
  Design says BONE `rgba(237,232,227,.72)`; the app paints the Bindu ember `#E5533C` at `0.7`. Also dropped: the `.22em` tracking (`Text.spaceMono`'s `em` defaults to 0 — `Theme/Theme.swift:175`), and the `rgba(237,232,227,.22)` underline. The design

**Comment** — YES — one citation fault, and one absence that is more telling than a fault.

1 · **The `.lenslabel` port cites the KNOB's line.** `UniverseView.swift:406`:

    // `:1386` — `font-size:8px; letter-spacing:.2em; text-transform:uppercase`.

Design `:1386` is `  box-shadow:0 0 10px rgba(237,232,227,.20);transition:transform .5s cubic-bezier(.2,.7,.2,1),background .5s ease}` — the continuation line of `.lensrail b`, the knob whose background is the `.42` that repeats `.where`'s number. The three properties quoted live on `:1387`, `.lenslabel`'s own opening line. So the comment quotes the right el

**Evidence** — **THE NAMED DANGEROUS PAIR IS NOT TRANSPOSED — IT IS ONE-MISSING.** `.lenslabel` holds its own `.46` at `UniverseView.swift:411`. `.where`'s `.42` was not stolen: the only `.42`s in the Universe port are `UniverseView.swift:1006` (verbatim from design `:1275`) and `UniverseLens.swift:60` (the knob, verbatim from `:1385`). `.where` has no port because `say()` has no port — the whole element is absent, and B2.3 already says so and is OPEN. The four-hundredths trap did not spring.

**THE DEFECT IS ON THE THIRD MEMBER, AND IT IS LIVE OVER TWO CLOSED BLOCKERS.** `.ret b` — design `rgba(237,232,227,.72)`, mono 9 / `.22em`, with a `.22` BONE underline — is `Color(hex: "#E5533C").opacity(0.7 * open)` with zero tracking and no underline (`UniverseView.swift:686-688`). Four hundredths of alpha is the smallest part of it; the ink is a different colour. The `0.7` is precisely the "plausible number t

**Refutation** — Attacked on every escape route; it survives. DESIGN VERIFIED EXACT by grep -n against the single-commit file (a41b1f3): .where opens :1381 with color rgba(237,232,227,.42) on :1382; .lensrail b's knob .42 on :1385, continuation on :1386; .lenslabel opens :1387, .46 on :1388; .ret i .60 on :1400; .ret b rgba(237,232,227,.72) on :1401 with the .22 underline on :1402; .bench .28 on :1414. say() is :1470-1473; the bench's "Review controls never ship" is at :1722.

TRANSPOSITION REFUTED, as claimed. .lenslabel holds its own .46 at UniverseView.swift:411; the knob keeps its own .42 at UniverseLens.swift:55 (finding said :60 — slip); UniverseView.swift:1006 is lens*min(0.42,(z-0.85)*0.7), verbatim from design :1275. No .42 was borrowed for a caption.

.where GENUINELY UNPORTED. I checked the one 

### ONE-MISSING — `universe-overlay-fade-durations` · rows `B5.2`, `B5.3`, `B5.4`, `B5.5`, `B6.1`, `B7.4`

**Design** — Five overlay opacity clocks, `Claude Design Round 1/comps/The Universe v3.html`:
· `.where` → `transition:opacity 1.8s ease` — :1382 (block opens :1381)
· `.lenslabel` → `transition:opacity .6s ease` — :1388 (block opens :1387)
· `.door` → `transition:opacity 1.5s ease` — :1390 (block opens :1389; `.door.on{opacity:1}` :1391)
· `.ret` → `transition:opacity 2.2s ease` — :1398 (block opens :1397; `.ret.on{opacity:1}` :1399, toggled at :1515 by `L.n===3&&desc>0.90`)
· `.word` → `transition:opacity 1.1s ease,transform 1.4s cubic-bezier(.2,.7,.2,1)` — :1406, with `transform:translateY(14px)` on the same line (`.word.on{opacity:1;transform:none}` :1407)
Adjacent, non-member context that matters: `.lensrail b` carries `transition:transform .5s cubic-bezier(.2,.7,.2,1),background .5s ease` at :1386 — the line immediately above `.lenslabel`.

**App** — All ports are in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Universe/UniverseView.swift`.

· `.lenslabel` → `.animation(.easeInOut(duration: 0.6), value: labelShown)` at :415 (label at :409-414, `.opacity(labelShown ? 1 : 0)`). **0.6 — its own constant. PORTED CORRECTLY.**
· `.word` → the panel is `wordPanel(_:)` :556-596, ending `.transition(.opacity)` at :595; the clock is at the mutation sites: `withAnimation(.easeInOut(duration: 1.1)) { openWord = … }` at :472 (open) and `withAnimation(.easeInOut(duration: 0.8)) { openWord = nil }` at :484 (close). **1.1 opacity — its own constant. The 1.4s transform half of the same design line has NO port**: there is no `translateY(14px)`/`.offset`/`.move` anywhere in the panel; `.transition(.opacity)` is opacity-only. The 0.8 close is a third number the design does not have (the comp just removes `.on` and runs 1.1/1.4 in reverse).
· `.door` → NOT a view; drawn straight into the Canvas by `drawDoor(_:_:_:)` :646-661, dispatched at :884-886 `} else if let d = doorway(size) { drawDoor(ctx, size, d) }`. The door is at full alpha the first frame `doorway(size)` returns non-nil and gone the frame it returns nil. **No 1.5s clock, no fade constant of any kind — a hard pop.**
· `.ret` → drawn by `drawMouth(_:_:d:)` :670-687 (its two authored 

**Comment** — TWO, and one is the exact known shape.

1 · THE SHAPE, on `.ret` — `UniverseView.swift:671`:
    `let open = max(0, min(1, (d - 0.84) / 0.12))          // uni-fall.js:24 seg(.84,.96)`
   The comment on the `.ret` CAPTION's opacity cites the MOUTH-GLOW layer's line (`uni-fall.js:24` ≈ comp :873, `mouth:seg(0.84,0.96)`) and quotes the mouth's expression to justify the caption's alpha. `.ret`'s own clock is at :1398 and is never cited anywhere in the app. A correct citation of the wrong element — `check_citations` verifies it, and the caption silently inherits its sibling's ramp instead of its 2.

**Evidence** — METHOD NOTE: every app site was located or its absence established by grep over the whole app, not inferred. The only durations present in `Bindu Feed/Bindu Feed/Universe/` are 0.5, 0.6, 1.1 and 0.8; 1.8 / 1.5 / 2.2 / 1.4 appear nowhere in that folder (they appear elsewhere in the app — `PointWorldView.swift:579` 1.8, `:124` 1.5, `SignalView.swift:116` 1.4 — all on unrelated surfaces, so nothing was transposed OUT of the Universe either).

WHY ONE-MISSING AND NOT TRANSPOSED/COLLAPSED:
· Not TRANSPOSED — the two ported constants each sit on their own member. 0.6 is on the lens label (:415) and 0.5 on the knob (:399), which is what :1388 and :1386 ask for, even though the label's comment cites the knob's line.
· Not COLLAPSED at the value level between members — no two members were given the same number.
· ONE-MISSING is the literal shape at the nested pair the group's `whySiblings` single

**Refutation** — SURVIVES. I tried to refute it on every axis the brief names and could not.

DESIGN, all five verified byte-exact at the exact quoted line numbers in `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Universe v3.html`: `.where` :1381-1382 `transition:opacity 1.8s ease`; `.lensrail b` :1385-1386 `transition:transform .5s cubic-bezier(.2,.7,.2,1),background .5s ease`; `.lenslabel` :1387-1388 `transition:opacity .6s ease`; `.door` :1389-1390 `transition:opacity 1.5s ease` (`.door.on` :1391); `.ret` :1397-1398 `transition:opacity 2.2s ease` (`.ret.on` :1399, toggled :1515 `L.n===3&&desc>0.90`); `.word` :1406 `opacity:0;transform:translateY(14px);transition:opacity 1.1s ease,transform 1.4s cubic-bezier(.2,.7,.2,1)` (`.word.on{opacity:1;transform:none}` :1407).

APP, all in `/Users/ashre

### ONE-MISSING — `voice-identity-caption-tracking` · rows `F4.2`, `F8.1`, `F8.2`, `F8.3`, `F8.4`, `F8.5`

**Design** — Member A — h1 'Ash': `letterSpacing: '-0.012em', marginBottom: 7` at `Claude Design Round 1/comps/Ash's Voice.html:602` (negative, −0.012 × 26 = −0.312pt).
Member B — Space Mono 'Physical Synthesis': `letterSpacing: '0.12em', textTransform: 'uppercase'` at `Claude Design Round 1/comps/Ash's Voice.html:608` (positive, 0.12 × 11 = 1.32pt).
Corroborating second source, byte-identical pair: `Claude Design Round 2/design-source/Player Detail - The Turning.html:335` (h1, `-0.012em`, `marginBottom: 7`) and `:336` (span, `0.12em`).

**App** — Member A → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshVoiceView.swift:139-141`
```
Text(displayName)
    .font(.lora(26, weight: .medium))
    .foregroundColor(BinduTheme.inkPrimary)
```
**No `.tracking` at all.** The −0.012em is absent, not wrong — the name renders at Lora's natural spacing (0).

Member B → `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/AshVoiceView.swift:143-146`
```
Text("PHYSICAL SYNTHESIS")
    .spaceMonoTracked(11)
    .tracking(1.32)
```
`1.32` is present and is its OWN member's constant (0.12 × 11). Not transposed.

The same header, ported a second time from the Round 2 twin, carries BOTH constants: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/TheTurningView.swift:149-157` — `.font(.lora(26, weight: .medium))` … `.tracking(-0.3)` on the name, `.spaceMonoTracked(11).tracking(1.32)` on the role. So the app knows the number; the Ash's Voice port dropped it.

**Comment** — NONE — and the absence is itself the tell. There is no comment on either app site: `AshVoiceView.swift:137-146` is nine unannotated lines. Neither member cites a design line, so `check_citations` had nothing to verify on this pair; it passed by having no claim to check rather than by having a true one.

The nearest comment sits directly above, at `AshVoiceView.swift:106-114`, and it is correctly attributed to its own element: "F8.1 · **A LIT SPHERE, NOT A FAINT RING.** `:589-597`" — `:589-597` is the avatar div, which is what that comment governs. No cross-citation of `:602`/`:608` exists anyw

**Evidence** — 1. **The missing half is a house constant elsewhere.** `-0.3` (≈ −0.012 × 26) is the app's own rendering of this letter-spacing and appears at four Lora identity headings: `TheTurningView.swift:152`, `StoryDetailView.swift:172` (Lora 23), `RootView.swift:88` (Lora 22), `PracticeDoorView.swift:229`. Of the three `.lora(26, weight: .medium)` sites in the app (`TheTurningView.swift:150`, `AshVoiceView.swift:140`, `ReturnView.swift:207`), AshVoiceView is the identity heading with no tracking modifier at all. The value was known, written four times, and skipped once — on the screen the design file is named after.

2. **AGGRAVATOR — member B's constant is present but shadowed, so both members effectively render at 0.** `spaceMonoTracked` is a `View` extension (`Theme.swift:151`): `self.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size)`, with `em` defaulting to 0. At `AshVoice

**Refutation** — Survives every refutation angle. DESIGN VERIFIED VERBATIM: "Claude Design Round 1/comps/Ash's Voice.html:602" reads `letterSpacing: '-0.012em', marginBottom: 7,` and ":608" reads `letterSpacing: '0.12em', textTransform: 'uppercase',`; the corroborating twin "Claude Design Round 2/design-source/Player Detail - The Turning.html:335/:336" is byte-identical on both constants. APP VERIFIED VERBATIM: AshVoiceView.swift:139-141 is Text(displayName)/.font(.lora(26, weight: .medium))/.foregroundColor(...) with no tracking; :143-146 is Text("PHYSICAL SYNTHESIS")/.spaceMonoTracked(11)/.tracking(1.32)/.foregroundColor(...). NOT A DIFFERENT SOURCE: all four extant copies of the comp carry -0.012em — R1 :602, the R2 twin :335, archive/A Strange Feed/Ash's Voice.html:259, archive/bindu-feed-phase9-handof

### UNCLEAR — `chrome-caption-fade-durations` · rows `C2.6`, `C3.3`, `C3.4`, `C5.2`, `C5.6`
*The refutation corrected this from the checker's first verdict.*

**Design** — Five members, `/Users/ashrey/Bindu Feed/Claude Design Round 2/comps/The Chrome.html` (all verified at the cited lines):

· `#where`        → `transition:opacity 1.1s ease`  · The Chrome.html:13
· `#pname`        → `transition:opacity 1s ease`    · The Chrome.html:18
· `#once`         → `transition:opacity 1.4s ease`  · The Chrome.html:20
· `#rail`         → `transition:opacity .9s ease`   · The Chrome.html:23
· `#invTop,#invBot` → `transition:opacity .6s`      · The Chrome.html:30

CROSS-ROUND PROVENANCE, which decides two of the five. Round 1 (`/Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html`) carries the same elements:
· `:4348` `#where{…transition:opacity 1.1s ease}`  — Round 2 agrees.
· `:4353-4355` `#pname{…transition:opacity 1s ease}` — Round 2 agrees.
· `:4338` `#rail{…}` — **NO opacity transition at all.** The `.9s` is NET-NEW in Round 2.
· `:4339` `#rail i{transition:width .5s ease,background .5s ease,opacity .5s ease}` — the CHILD's `.5s`, restated at The Chrome.html:24.
· `:4342-4343` `#rail u{transition:background .8s ease,border-color .8s ease}` — a third constant in the same subtree.
· `:4575-4576` `#trav .once{…top:178px…transition:opacity 2.4s ease}` — Round 2's `#once` restates the SAME element (identical 8500/2600 script at The Chrome.html:

**App** — All ports live in `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/InstrumentView.swift`.

· `#where` → `whereBlock` (:553-572)
  `:569  .animation(.easeInOut(duration: 1.1), value: here.key)`
  `:570  .animation(.easeInOut(duration: 1.1), value: hidden)`
  → 1.1 · ITS OWN. **MATCHED.**

· `#pname` → `particleNameLabel` (:670-684)
  `:683  .animation(.easeInOut(duration: 1.0), value: hidden)`
  → 1.0 · ITS OWN. **MATCHED.**

· `#rail` → `ladderRail` (:580-627)
  `:625  .opacity(Immersion.railOpacity(hush: hush, immA: immA, dom: dom))`
  `:626  .animation(.easeInOut(duration: 0.5), value: here.i)`
  → **0.5 is `#rail i`'s constant (The Chrome.html:24 / v3:4339), not `#rail`'s.** `#rail`'s own `.9s` has NO port: `grep -rn "duration: 0.9"` over the app returns zero hits in `Instrument/`. `#rail u`'s `.8s` is absent too. **ONE-MISSING** — the child's number is the only duration on the parent's view.

· `#once` → the stillness-gate caption, `stillnessGate` (:821-828), driven at `:374` and `:384`
  `:826  .position(x: geo.size.width / 2, y: 178)`   ← Round 1's top:178, not Round 2's bottom:150
  `:827  .transition(.opacity)`
  `:374 / :384  withAnimation(.easeInOut(duration: 2.4)) { TravOnce.endHold() }`
  → 2.4 · the same element's ROUND 1 constant (v3:4576). Round 2 says 1.

**Comment** — No comment cites another member's design LINE NUMBER — the known instance's exact signature (`#where`'s note citing `:5646`) is not repeated anywhere in this group. That instance is not only fixed, it is documented in place at InstrumentView.swift:559-563 and AxisModel.swift:594-601.

But the same family of fault appears twice, in its structural rather than its citational form:

1 · **InstrumentView.swift:621-626 — a comment about the PARENT standing over the CHILD's constant.**
   `// \`:5644\` — \`(1−hush*0.85)*(1−immA)*(1−PS.dom()*0.9)\`. C2.6 · it comes back over the`
   `// afterglow, not

**Evidence** — THE MISSING `.9s` IS NOT COSMETIC, AND HERE IS THE FRAME WHERE IT SHOWS.

`.animation(_:value:)` fires only when the named value changes. The rail's is keyed on `here.i` — the register index. Its opacity is `Immersion.railOpacity(hush:immA:dom:)` = `(1 − hush*0.85)(1 − immA)(1 − dom*0.9)` (AxisModel.swift:590-592). Of those three inputs:

· `immA` is an integrator on the frame clock (1-AUDIT-254.md:191) — continuous.
· `dom` decays over 0.75s after landing (C2.6) — continuous.
· **`hush` is a STEP.** `AxisTravel.swift:70-73`: `guard pieceOpen, (1...4).contains(pieceDimension) else { return 0 }` / `return max(0.42, …)`. Its own doc at :63-64 says it plainly — *"The chrome steps aside for a reading by at LEAST 0.42 **the moment one opens**"*.

So the instant a reading opens in registers 2-5, `hush` jumps 0 → 0.42 and the rail's opacity drops ~36% **in one frame**. `here.i` does not change 

**Refutation** — Every quoted line verifies — design (Chrome.html:13/18/20/23/30), Round 1 (v3:4338-4343, 4348, 4353-4355, 4575-4576), app (whereBlock 1.1x2, pnameLabel 1.0, ladderRail 0.5 on a Canvas, stillnessGate 2.4 at y:178, bare sayGate/sayOnce), the three greps (zero hits in Instrument/), hush's step guard (AxisTravel.swift:70-73), railOpacity (AxisModel.swift:590-592), and the ZStack order that leaves the rail drawn above content. The verdict still fails on three counts.

(1) THE SEVERITY ARGUMENT IS UNSOUND. `grep -c hush` and `grep -c immA` over The Chrome.html both return 0. The comp that carries `.9s` drives its rail at :397 as `AB==='built'?(PS.on?0:1):(1-PS.dom()*0.9)` — the afterglow term alone, no hush. The design that HAS hush is v3:5644, `rail.style.opacity=(1-hush*0.85)*(1-immA)*(1-PS.do

### UNCLEAR — `ground-stanza-lead` · rows `F11.2`
*The refutation corrected this from the checker's first verdict.*

**Design** — Member A — `#ground .glyph` → `margin-bottom:40px`. Site: /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4366 (`#ground .glyph{font-size:30px;line-height:1;margin-bottom:40px;display:block}`). Attested twice more: /Users/ashrey/Bindu Feed/Claude Design Round 1/A Strange Feed.html:630 (`fontSize:30 … marginBottom:40`) and /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Instrument v3.html:4366.

Member B — `#ground .label` → `margin-bottom:36px`. Site: /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4369 (`#ground .label{… font-size:10px;letter-spacing:.24em;text-transform:uppercase;margin-bottom:36px;display:block;text-align:center}`). Attested twice more: A Strange Feed.html:636 (`marginBottom:36`) and /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Practice Door.html:252 (`letterSpacing:'0.24em', textTransform:'uppercase', marginBottom: 36`).

The two are the two weathers of one stanza, proven by the design's own render at The Instrument v3.html:5004 and :5011 — `paintGround()` emits `<span class="glyph">` when `weather==='unmet'` and `<span class="label">` otherwise. Whichever weather is up, that mark opens the stanza and holds the space above the text. 40 vs 36.

**App** — Member A (`#ground .glyph`, 40) — the unmet weather, ported to /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/DoorView.swift:119:

    VStack(spacing: 18) {                                                    // :117
        Spacer()
        Text(storyData.roomGlyph).font(.system(size: 30)).foregroundStyle(room)   // :119

The glyph's `font-size:30px` IS ported (`.font(.system(size: 30))`). Its `margin-bottom:40px` is NOT. The glyph carries no bottom padding of its own; the space under it is the VStack's uniform `spacing: 18`, the same 18 that separates the four lines below it. Git: born `spacing: 20` at 5f83b98 (Wave 3), retuned to 18 at e2efa6a. The 40 was never in this file's history.

Member B (`#ground .label`, 36) — the met weather, ported to /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift:120-125:

    Text(label)
        .spaceMonoTracked(10)          // font-size:10px + text-transform:uppercase
        .tracking(2.4)                 // letter-spacing:.24em × 10px
        .foregroundColor(accent.opacity(0.66))
        .padding(.bottom, 36)          // :124 — margin-bottom:36px

Member B carries ITS OWN constant, and the whole rule with it. Born correct at 6c85b48 (Phase 9); the only later edits were the E1.18 mono-case migrations, whic

**Comment** — NONE — and the absence is the point, in a way that is worse for the checkers than a miscitation would be.

No comment sits on either app site. DoorView.swift contains **zero design citations in the entire file** (`grep -c "Round 1\|Round 2\|\.html:"` → 0). PracticeDoorView.swift contains exactly **one**, and it is not on this member: line 178, `// Practice Door.html:146,155-159 — the sub-line is the last child of the`, which points at a different element further down the stanza.

The known `#where`/`#pname` instance was invisible because a citation was correct-but-aimed-at-the-sibling, so `che

**Evidence** — **THE DECOY, and why a grep-shaped verification passes this.** `40` appears twice in DoorView.swift, in the same view, neither time as the glyph's lead:

    :143    .padding(.top, 14).padding(.bottom, 40)   // on the "not today · enter the field ›" button
    :145    .padding(.horizontal, 40)                 // on the whole VStack

Anyone confirming "the design's 40 is in the app's Door" by search finds two hits and stops. Worse, **:145 is itself wrong in the same property family**: the design's `#ground .field` is `padding:0 32px` (The Instrument v3.html:4364; `A Strange Feed.html:626` agrees, `padding:'0 32px'`). So the one place a 40 sits on a horizontal gutter is a place the design says 32 — the right number on the wrong property, one axis over. Flagged as adjacent, not scored: it is outside this group.

**WHY THE MISSING 40 IS NOT COSMETIC.** In the design the unmet stanza is glyph

**Refutation** — All quotes verified exactly (Instrument v3:4364/:4366/:4369/:5004/:5011; A Strange Feed:626/:630/:636; Practice Door.html:249-254; DoorView.swift:117-119,:143,:145; PracticeDoorView.swift:120-125; F11.2 at 1-AUDIT-254.md:375; 3-FILE-COVERAGE.md:67). The finding fails on its APP PAIRING, not its transcription.

1) DoorView:117-129 is NOT a render of `#ground`'s unmet stanza. The design's unmet stanza has exactly three members — glyph(30) → h1 27px "One story has come to meet you." → .under 16px italic. The app's has five: glyph(30) → the meeting line DEMOTED to lora 15 italic → storyData.title (lora 24 medium) → storyData.roomName (mono 9) → notDone (lora 13). Title and room name appear nowhere in `#ground`. They come from The Rite v3.html's Movement I, whose own source comment at :1287 rea

### UNCLEAR — `lite-caption-tracking` · rows `E1.17`, `E1.3`, `E1.4`
*The refutation corrected this from the checker's first verdict.*

**Design** — Two Space Mono captions bracketing one reading in `#lite`, distinguished by size AND tracking:

· `#lite .vec` → `font-size:8px; letter-spacing:.30em` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4605
  (`#lite .vec{font-family:"Space Mono",monospace;font-size:8px;letter-spacing:.30em;text-transform:uppercase;` / `color:rgba(237,232,227,.30);margin-bottom:20px}`)
  Its content is emitted at :5275 — `let h='<div class="vec">'+s.kind+' · '+s.vector+'</div>';` — i.e. "FUTURE · FORCE → SURRENDER" (data at :3921-3976 and canon/spine-light.js:33-88). It is the FIRST thing in the reading, always present.

· `#lite .hold` → `font-size:8.5px; letter-spacing:.26em` — /Users/ashrey/Bindu Feed/Claude Design Round 1/The Instrument v3.html:4617
  (`#lite .hold{margin-top:24px;font-family:"Space Mono",monospace;font-size:8.5px;letter-spacing:.26em;` / `text-transform:uppercase;color:rgba(237,232,227,.30)}`)
  Content emitted at :5282 — `if(!LT.carved)h+='<div class="hold">hold to mean it</div>';` — the LAST thing, and only while uncarved.

Both share the same colour alpha (.30) and are pulled together into one text-shadow rule at :4619, so the sizes and the tracking are the only axes the design uses to separate them: 8/.30em (2.40px of tracking) opening, 8.5/.26em (2.

**App** — · `#lite .vec` — **NO PORT AT ALL.** `LightScene` at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Light/LightCanon.swift:12-22 declares `key, title, material, whole, anchors, beat, landing, ungripOnly` — no `kind`, no `vector`. Grep for `kind`/`vector` across "Bindu Feed/Bindu Feed" returns 0 hits in any Light file (only `UniverseView.swift:468 switch h.kind` and a comment in `PointWorlds.swift:447`). `sceneBody` (LightView.swift:344-467) opens straight on the whole; `LightNave.swift` draws no `Text` anywhere; `LightType.swift` (49 lines) has no caption entry. There is no element to carry .30em.

· `#lite .hold` — ported as TEXT, not as TYPE. /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/LightView.swift:431-434:
    Text(LightCanon.beatCue)
        .spaceMonoTracked(9, em: 2 / 9)
        .foregroundStyle(BinduTheme.inkTertiary)
        .modifier(RiteBreathe())
  `spaceMonoTracked` resolves at /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Theme/Theme.swift:151-153 to `.font(.spaceMonoFace(size)).textCase(.uppercase).tracking(em * size)` — so this is a **9pt face with 2.00pt of tracking (≈.222em)**, against the design's 8.5px/.26em (2.21px). Padding is `.padding(.top, 8)` against the design's `margin-top:24px`.
  The number is the app's HOUSE caption default, not this e

**Comment** — NONE — no comment on either member cites the other member's design line, so this is not the `#where`/`#pname` shape.

But the near-miss is worth recording, because it is why the metric was never questioned. The comment above the surviving site (LightView.swift:423-430) reads:

    // E1.4 · **THE AUTHORED CUE, AT LAST** — `The Instrument v3.html:5282`
    // `if(!LT.carved) h += '<div class="hold">hold to mean it</div>'`, named as
    // canon at `REVIEW-AND-WIRING.md:48` and sitting declared-and-unused at
    // `LightCanon.beatCue` for the whole build while the app invented
    // `"press · 

**Evidence** — **The pairing the design draws — .30em opening vs .26em closing — does not exist in the app in any form.**

Not TRANSPOSED: 2/9 em (.222) is not .30em, so the surviving member is not wearing its sibling's number. Not COLLAPSED: there is no second site to collapse toward. Not BOTH-WRONG: only one member exists. ONE-MISSING is the structural fit — `.vec` ported nowhere, `.hold` ported — but it is a **compounded** ONE-MISSING, and this matters for the sweep's taxonomy: the definition assumes the surviving member "ported with its constant", and here it did not. `.hold` carries 9pt/2.00pt where the design says 8.5px/.26em (2.21pt). So the group loses the distinction twice over — once by absence, once by a house default that happens to land between the two design values.

Why it survived, in this register's own idiom:
1. `spaceMonoTracked(9, em: 2 / 9)` is the app's most common caption metric 

**Refutation** — All six quoted lines verify verbatim (Instrument v3 :4605, :4617, :4619, :5275, :5282; LightView.swift:431-434; Theme.swift:151-153; LightCanon.swift:12-22 has no kind/vector; LightType.swift has no caption entry). The finding fails anyway, on the per-register comp it never actually read.

1. THE COMP CLAIM IS FALSE, AND IT IS LOAD-BEARING. The finding asserts "The comp it consults has no Space Mono caption in the reading at all (its only `.mono` rule is `:25` at 0.14em, for the walk-back-out button)." `Claude Design Round 1/comps/The Light v2.html` has TWO in-frame mono captions in the reading, both overriding the class default inline: the breath `Cue` (defined :577, rendered :813) at `fontSize:9, letterSpacing:'0.3em'`, and the beat cue at :814 at `fontSize:9, letterSpacing:'0.3em'`. Bot

### UNCLEAR — `signal-hintfade-duration-split` · rows `A2.1`, `A2.3`
*The refutation corrected this from the checker's first verdict.*

**Design** — Two hint captions, one shared keyframe, two deliberately different periods.

· Member A — the arrival hint caption ("a signal is arriving", rendered while `!received && !gone`):
  `animation: 'hintFade 3.4s ease-in-out infinite'`
  /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Signal Space.html:178

· Member B — the lower hint caption (the `leave` button, rendered while `received`):
  `animation: 'hintFade 5s ease-in-out infinite'`
  /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Signal Space.html:203

· The shared keyframe both cite, /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Signal Space.html:41:
  `@keyframes hintFade { 0%,100% { opacity: 0.24; } 50% { opacity: 0.52; } }`
  So the SPLIT the design carries is period only — 3.4s vs 5s — over an identical 0.24 → 0.52 → 0.24 amplitude. The amplitude is the shared part; the period is the distinguished part. That is exactly the axis the port lost.

**App** — Both members ARE ported, and both are ported through the SAME parameterless view modifier — there is no period argument anywhere on either call site, so neither 3.4s nor 5s exists in the app.

· Member A → the arrival caption, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:136-140
    Text("A SIGNAL IS ARRIVING")
        .spaceMonoTracked(9)
        .tracking(2.2)
        .foregroundColor(BinduTheme.colorAshrey.opacity(0.5))
        .modifier(BreathingOpacityHint())

· Member B → the LEAVE button, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:196-203
    Text("LEAVE") … .modifier(BreathingOpacityHint())

· The single modifier both resolve to, /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:381-385:
    private struct BreathingOpacityHint: ViewModifier {
        @EnvironmentObject private var breath: Breath   // the one master breath
        func body(content: Content) -> some View {
            content.opacity(0.24 + 0.28 * breath.value)
        }
    }

· Period, therefore, for BOTH: /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/Breath.swift:21 — `static let period: Double = 10.0`.

So: 3.4s → 10s, 5s → 10s. The two hints now breathe on one clock, at one period, in exact phase-lock (a global l

**Comment** — NONE — no comment on either member cites the other member's design line. `grep -n "//" Screens/SignalView.swift` shows the file carries no `The Signal Space.html:NNN` citation on either hint site; the only design-line citation in the file is on an unrelated row (`:277`, "The Signal Space.html:60-67", the display-lines array for A2.1). So `check_citations` has nothing to verify here and nothing to be fooled by — this instance is invisible to it for the opposite reason to `#where`/`#pname`: not a correct citation of the wrong element, but no citation at all.

The tell is present in a different f

**Evidence** — VERDICT: COLLAPSED. Both members ported, both given the same value, where the design distinguishes them — and the distinguishing axis (period) is not merely equalised but ABSENT from the app, since `BreathingOpacityHint` takes no parameter.

The four facts, each independently checkable:
 1. Design splits them: `The Signal Space.html:178` = 3.4s, `:203` = 5s, over one shared keyframe `:41` (0.24 → 0.52).
 2. App unifies them: `SignalView.swift:140` and `:203` both call `.modifier(BreathingOpacityHint())`, byte-identical call sites.
 3. The unified period is 10s: `SignalView.swift:381-385` reads `breath.value`; `Breath.swift:21` `static let period: Double = 10.0`. Member A runs 2.94× too slow, member B 2× too slow.
 4. The amplitude IS correct: `0.24 + 0.28 * breath.value` reproduces `:41` exactly. This is what makes the port look done — the shared half of hintFade was transcribed faithful

**Refutation** — Every quote is exact — and the finding still fails, on the escape hatch it never checked.

VERIFIED AS STATED. Comp /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Signal Space.html:41 (0.24→0.52), :178 (3.4s), :203 (5s) read verbatim. /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Signal Space.html is byte-identical at the same line numbers, so "a newer design source" is closed off. App: SignalView.swift:136-140 and :196-203 both call .modifier(BreathingOpacityHint()); :381-385 is parameterless and reads breath.value; Breath.swift:21 period = 10.0; Breath is genuinely injected (BinduFeedApp.swift:21,28), so both hints really do run at 10s; 0.24 + 0.28 reproduces the keyframe exactly. grep gives exactly three BreathingOpacityHint lines. The mechanical collapse is

### UNCLEAR — `signal-hintfade-durations` · rows `A2.1`, `A2.3`
*The refutation corrected this from the checker's first verdict.*

**Design** — Shared keyframe: `Claude Design Round 1/comps/The Signal Space.html:41` — `@keyframes hintFade { 0%,100% { opacity: 0.24; } 50% { opacity: 0.52; } }`.

MEMBER A — 'a signal is arriving' caption → `animation: 'hintFade 3.4s ease-in-out infinite',` at `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Signal Space.html:178`.

MEMBER B — 'leave' button → `animation: 'hintFade 5s ease-in-out infinite',` at `/Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Signal Space.html:203`.

The distinction is confirmed twice, not a Round-1 artifact: `/Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/The Signal Space.html` carries byte-identical lines at the same numbers — `:41` keyframe, `:178` 3.4s, `:203` 5s. Two rates on one named keyframe, never in phase (3.4 and 5 re-align only every 17s): the arriving caption breathes faster than the exit.

**App** — MEMBER A — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:136-140`:
```
Text("A SIGNAL IS ARRIVING")
    .spaceMonoTracked(9)
    .tracking(2.2)
    .foregroundColor(BinduTheme.colorAshrey.opacity(0.5))
    .modifier(BreathingOpacityHint())
```

MEMBER B — `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:196-203`:
```
Text("LEAVE")
    .spaceMonoTracked(10)
    .tracking(2.2)
    .foregroundColor(BinduTheme.inkTertiary)
    .padding(10)
    .modifier(BreathingOpacityHint())
```

Both resolve to ONE parameterless modifier, `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/SignalView.swift:381-385`:
```
private struct BreathingOpacityHint: ViewModifier {
    @EnvironmentObject private var breath: Breath   // the one master breath
    func body(content: Content) -> some View {
        content.opacity(0.24 + 0.28 * breath.value)
    }
}
```
`BreathingOpacityHint` takes no arguments, so no rate can be passed. Its rate is the app-wide breath: `/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/Breath.swift:20` — `static let period: Double = 10.0`. Only three references exist in the whole codebase (`SignalView.swift:140`, `:203`, `:381`); there is no second, faster variant anywhere.

**Comment** — NONE of the known shape. Neither app site carries a comment at all, and neither cites any design line — so there is no correct-citation-of-the-wrong-element here to fool `check_citations`; there is nothing for it to check. The only citation of this design file anywhere in the app is `SignalView.swift:277` — `// (The Signal Space.html:60-67) — broken by hand, and broken INSIDE sentences:` — which is about hand-broken transmission lines, 118 lines away from `:178` and 143 from `:203`.

The nearest thing to a tell is a different artifact, and it is worth quoting because it is what makes the colla

**Evidence** — THE COLLAPSE, exactly.

The design drives one named keyframe at two rates on two chrome captions in the same screen (`3.4s` on the arriving caption, `5s` on the leave). The app renders both through a single parameterless modifier, `BreathingOpacityHint` (`SignalView.swift:381-385`), which has no rate of its own — it reads `breath.value` from the app-wide `Breath` singleton, period `10.0` seconds (`Breath.swift:20`). One value, both members, and it is neither member's value.

This is COLLAPSED with a BOTH-WRONG overtone, and the compound is worth stating: not only are the two rates made equal where the design separates them, the shared rate is ~2.9× the caption's and 2× the leave's. Nothing on this screen breathes at a designed rate.

There is a second loss the numbers alone hide. `Breath` is phase-locked by contract — the doctrine block at `Breath.swift:24-47` rules "Phase is universal… 

**Refutation** — The mechanics verify, but the finding's central claim — that this collapse is UNAUDITED and "indistinguishable from an accident" — is false. It is a RECORDED, deliberate, still-open class divergence.

WHAT SURVIVES (all verified by opening the files):
· Design exact: /Users/ashrey/Bindu Feed/Claude Design Round 1/comps/The Signal Space.html:41 `@keyframes hintFade { 0%,100% { opacity: 0.24; } 50% { opacity: 0.52; } }`; :178 `animation: 'hintFade 3.4s ease-in-out infinite',`; :203 `animation: 'hintFade 5s ease-in-out infinite',`. Round 2 is byte-identical — md5 of the WHOLE file is 7a10b957c27c11e2a4479bf8926c2e2b for both copies, so "different design source" is ruled out.
· App exact: SignalView.swift:136-140 (caption) and :198-203 (LEAVE, inside `leaveButton` at :196) both `.modifier(Brea


## No row cited

1 groups — 1 COLLAPSED

### COLLAPSED — `practice-door-animation-durations`

**Design** — All four line numbers verified exactly as given, against a single four-keyframe set declared together at Practice Door.html:30-39.

· the ember → `animation: 'emberBreath 4s ease-in-out infinite'` — Practice Door.html:115 (keyframe :34-37: opacity 0.55→1, scale 0.97→1.06)
· the door → `animation: crossed ? 'none' : 'doorBreath 10s ease-in-out infinite'` — Practice Door.html:224 (keyframe :30-33: opacity 0.34→0.78, scale 1→1.04)
· the hint → `animation: 'hintFade 4.5s ease-in-out infinite'` — Practice Door.html:272 (keyframe :38: opacity 0.24→0.55); repeated verbatim at :318 on the "tap to return to the door" span
· the field → `animation: 'fieldIn 1.5s ease 0.05s forwards'` — Practice Door.html:297 (keyframe :39: opacity 0→1)

The three infinite members are distinguished ONLY by period: 4s / 10s / 4.5s.

**App** — All ports in /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift. Every one drives off the shared `Breath`, whose period is fixed at `static let period: Double = 10.0` (Instrument/Breath.swift:20, tick at :91-93).

· the ember → `EmberBreathe` modifier, PracticeDoorView.swift:334-342, applied at :217:
    `.opacity(0.55 + 0.45 * v)` / `.scaleEffect(0.97 + 0.09 * v)`, v = `masterBreath.value`
  AMPLITUDES EXACT (0.55→1.0, 0.97→1.06). PERIOD 10s, design 4s.
· the door → PracticeDoorView.swift:149: `.opacity(0.34 + 0.44 * breath.value)`
  AMPLITUDE EXACT (0.34→0.78). PERIOD 10s — the only member whose duration is right.
  (Collateral: doorBreath's `transform: scale(1)→scale(1.04)` has no port; the atmosphere gradient carries no scaleEffect.)
· the hint → PracticeDoorView.swift:257: `.opacity(0.24 + 0.31 * breath.value)`
  AMPLITUDE EXACT (0.24→0.55). PERIOD 10s, design 4.5s.
· the field → NOT PORTED as `fieldIn`. Superseded by the eyelid blink, App/ContentCoordinator.swift:115-127 (0.30 close · 0.12 hold · 0.30 open), explicitly "the blink IS the transition." Legitimate: the design's FieldGlimpse is a prototype stand-in for the real home feed. The :318 second hint has no port either — grep for "tap to return" across the app returns zero.

THE COLLAPSE, PREC

**Comment** — NO CITATION FAULT OF THE KNOWN SHAPE — and that is itself the finding. Grep across the entire app source for `Practice Door.html:115`, `:224`, `:272`, `:297`, `:318` and for the keyframe names `emberBreath` / `doorBreath` / `hintFade` / `fieldIn` returns ZERO hits. No app site cites any of these four design lines, so `check_citations` has nothing to verify here; this instance is invisible to it by absence rather than by misdirection.

What stands in place of citations is doctrine asserted three times over:
· PracticeDoorView.swift:149 — "// the one master breath"
· PracticeDoorView.swift:257 —

**Evidence** — VERDICT REASONING: COLLAPSED, not TRANSPOSED and not BOTH-WRONG. Three members the design separates only by period all render at one period AND one phase; the value they share is one member's own correct constant. The rail precedent named in the brief is the same shape one degree milder — there a sibling was blurred toward its neighbours; here three are made identical.

FILES AND SITES (all absolute):
· /Users/ashrey/Bindu Feed/Claude Design Round 2/design-source/Practice Door.html — :30-39 keyframes, :115 ember, :224 door, :272 hint, :297 field, :318 hint repeat, :184 the 70ms settle
· /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Screens/PracticeDoorView.swift — :149 door, :217 ember application, :257 hint, :301-303 the 70ms/80ms comment, :334-342 EmberBreathe
· /Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Instrument/Breath.swift — :20 `period = 10.0`, :23-47 the one-breath contract

**Refutation** — SURVIVES ATTACK. Every design line and every app site reads exactly as quoted; I opened all of them.

DESIGN (verified): keyframes declared together at Practice Door.html:30-39; :115 `emberBreath 4s`, :224 `doorBreath 10s`, :272 `hintFade 4.5s`, :297 `fieldIn 1.5s`, :318 hintFade 4.5s repeated. Amplitudes as quoted.

APP (verified): PracticeDoorView.swift:149 `.opacity(0.34 + 0.44 * breath.value)`, :257 `.opacity(0.24 + 0.31 * breath.value)`, :334-342 `EmberBreathe` `.opacity(0.55 + 0.45*v)` / `.scaleEffect(0.97 + 0.09*v)` applied at :217. All four amplitudes are EXACT against the keyframe bodies. All three reads are bare `breath.value`; grep confirms the file contains no `repeatForever` and no `eased(offset:)` (:136 is a layout `.offset(y:)`). Breath.swift:20 fixes `period = 10.0`, tick a


## Coverage — stated as a number, per §10

**Could this sweep have found the case that motivated it?** **Yes.**

YES — the group was enumerated, and not once but six times over the same pair.

The exact motivating property (the base opacity constant at `The Instrument v3.html:5645-5646`) is group #1 of 264, `rail-where-pname-chrome-opacity`. Its designPair quotes :5644/:5645/:5646 verbatim, names the three bases as "absent / absent / 0.9", and its verdict is MATCHED with the explicit note: "MATCHED here means the constants pair correctly at HEAD, not that the group was always right. The transposition described in the task was real and was repaired in commit dd5076b." It re-derived the pairing from source (`AxisModel.swift:596` `whereOpacity` = `(1-hush)*(1-immA)`, no base; `:602` `pnameOpacity` opens on 0.9) rather than trusting the row, and noted that `ImmersionTests.swift:178-199` now pins it. So the sweep would have caught the live fault had it still been live.

Five further groups cover the same two elements on adjacent properties, all MATCHED: #2 `where-vs-pname-z-cutoff` (8.6 / 7.9 at the same two lines), #43 `where-vs-pname-fade-duration` (:4348 1.1s / :4355 1s), #44 `where-top-vs-pname-font-size` (:4349 9px / :4354 7.5px), #45 `where-top-vs-pname-tracking` (.3em / .2em), #234 `chrome-where-vs-pname-dominance-fade` (The Chrome.html:381/:386 — COLLAPSED, the one live defect in the family: both captions carry `(1 - dom)` where the comp gives both `(1 - dom*0.9)`, and the rail's `railOpacity` keeps its 0.9).

So the sweep is qualified to speak about this pair, and it did not merely re-confirm it: #1 and #2 also surfaced two surviving asymmetries the audit rows never recorded — `#pname`'s `here.key == \"feed\"` clause and `#where`'s inlined `abs(travel.z) < 0.42` where `#pname` calls `InstrumentNames.onGround(z:)`, i.e. one design predicate (`:5643`'s `onGround`) written two different ways on the two siblings.

### What could not be compared

Verdict census over all 264 groups (each group counted once):

  MATCHED       82  (31.1%)
  NOT-PORTED    76  (28.8%)
  ONE-MISSING   41  (15.5%)
  COLLAPSED     38  (14.4%)
  BOTH-WRONG    21  ( 8.0%)
  UNCLEAR        6  ( 2.3%)
                ---
                264

**76 groups (28.8%) are pure absence rows** — no member has any app expression, so no pairing comparison was performed. They are not transposition evidence in either direction. The largest clusters: the entire `MATERIAL` module of `The Instrument v3.html:3712-3891` (8 groups — starfield alpha/count, grain alpha/density, concentric rings, d4 letterpress, d5 mote+reflection, d5 gradient, fall strata), `paintTravel`'s `#trav .from/.to` (5 groups across opacity, size, tracking, alpha), the passage draw's acts 1/3/5 (3 groups), the Point v9 chrome (`#bindu.hold/.burst`, keyframe troughs, opacity transitions, GLOWS — 5), the Round-2 comps' overlay layers (Seam ×2, Reading ×2, Return ×2 — 6), the top-chip pair `#sndBtn`/`#mode` (3), and the reading panels' bespoke geometry (4).

**A further 41 groups (15.5%) have at least one member with no app site** (ONE-MISSING), so half of each pairing was uncomparable.

**6 groups (2.3%) are UNCLEAR** — comparison blocked not by absence but by an unresolved design-precedence question (Round 1 comp vs Round 2 comp vs `The Instrument v3.html`): #87 `ground-stanza-lead`, #92 `lite-caption-tracking`, #94 `lite-text-sizes`, #169 and #184 (both Signal hintFade), #235 `chrome-caption-fade-durations`.

Net: **123 of 264 groups (46.6%) had at least one member the sweep could not compare.** Only **141 groups (53.4%)** — the 82 MATCHED + 38 COLLAPSED + 21 BOTH-WRONG — had app expressions on every member, and of those only 58% came back clean.

And the fault the sweep was named for is not the fault it found. Live TRANSPOSED verdicts: **0 of 264.** The one real transposition in the corpus (#1) was already repaired. The 59 live defects it did find are 38 COLLAPSED + 21 BOTH-WRONG, which is a different mechanism — the app substituting one house value for a set of authored ones.

### What this sweep is structurally blind to

The sweep enumerates by DESIGN-SIDE CO-LOCATION: "two constants of one kind, in one file, close together." Three real transposition shapes carry no such signal, and the enumerators declared two of them out of scope in writing.

**1 · CROSS-FILE TRANSPOSITION — excluded by the grouping rule itself.** `r1-comps-b` states it outright: "a group's members must live in one file." `r1-comps-a` lists cross-file variants as excluded by rule ("the shared `--ink60`/`--ink35` tokens, the several per-file copies of `breatheSoft`/`Mono`/`Avatar`"). Yet `r1-comps-b` then flags, as an observation it could not file: "the per-presence hz table disagrees between `comps/field-sound.js:27` and `comps/uni-field.js:19-30` — **and the disagreement reads as a one-position shift** (field-sound's `sid` 174 is uni-field's `gaia`; field-sound's `arch` 220 is uni-field's `sid`)." That is a candidate whole-table transposition, seen, described, and structurally unfileable. It only got checked because #206 `unifield-voices-hz` and #201 `fieldsound-hz` happened to exist for other reasons. Every cross-file defect the sweep did find was found by accident from a same-file group: #155 (the Point's `--dim/--faint` .56/.22 answered by `A Strange Feed`'s `--ink60/--ink35` .60/.35 through `Theme.swift`), #201 (`RiteContent.swift:62-175` carrying `field-sound.js`'s HZ under a comment naming the ruling that supersedes it), #245, #244, #123, #218.

**2 · DESIGN HAS NO PAIR — one design member, many app sites.** A group needs ≥2 design members. Where the design states a value once and the app fans it out (or splits one design element into two views and lets one copy drift), no group can be formed. This is exactly #1's own surviving residual, which it caught only as a by-product: the design gives the passage three different treatments (`#rail` `(1-dom*0.9)`, `#where` a hard `PS.on?0`, `#pname` **no PS term at all**) and the app gives `#where` and `#pname` the byte-identical `* (1 - dom)`. Same for `:5643`'s single `onGround` predicate written two ways on the two siblings.

**3 · POSITIONAL / INDEXED CONSTANT SETS — excluded by rule in all four enumerators.** Every note bars "values indexed by loop counter, so they cannot be transposed between two named elements." The exclusions are numerous and named: `veilDensity`'s four curtains, `drawBindu`'s halo stops, `M.light`'s `band`/`warm` hour ladders, the DRAG/WHEEL/PINCH/span/DUR columns of `TWK_DIST`, `COVER`, `DUR`, `GATE`, `ROWS`, `GATES`, `FREQS`, `BEATS`, `BAND`, `TRIKONA`, all `@keyframes` bodies. Across the four notes ~50 constant sets are named as seen-and-excluded. One is flagged by the enumerator as a genuine miss: `instrument-css` — "the cross-panel comparison of the SAME stop (base mid-alpha **.40/.44/.38/.52**; expanded first stop 13%/14%/14%) to be a real sibling group, but left it out … a genuine candidate a follow-up may want." Four per-panel gradient alphas, of the exact target shape, never swept.

The single sentence: **the sweep can only pair what one reader saw side by side in one design file, so it is blind to a constant that travelled between files, between a design file and a theme token, or into a set the design indexes by position rather than by name — which is where 59 of its own 59 live defects actually live.**

### The app-side check that would catch what this one misses

Yes, and the sweep's own 264 results specify it precisely. Enumerate by APP-SIDE adjacency, then read the citations as the pairing evidence.

**The mechanism.** For every pair of app sites that (a) sit in one Swift file within N lines or inside one `VStack`/`switch`/`ZStack`, and (b) apply the same modifier kind (`.opacity(`, `spaceMonoTracked(_:em:)`/`.tracking(`, `.lora(`/`.loraItalic(`, `duration:`, `lineWidth:`, `peak:`, `attackSeconds:`, `radius:`), extract each site's nearest preceding `file.html:NNN` / `file.js:NNN` citation. Then flag five conditions:

**A · Cited design lines in DIFFERENT files.** Two adjacent Swift properties of one kind sourced from two design files is a pairing the design-side sweep cannot form by construction. Mechanically surfaces #155, #201, #245, #244, #182, #218, #226.
**B · Cited design lines >12 apart while the app sites are adjacent** — the port paired two things the design does not pair.
**C · The inverse: design lines ≤3 apart while the app sites are in different files or views.** A design pair split across two ports is where drift is likeliest; this is #1's own `(1-dom)` residual and #2's `onGround` split.
**D · One app expression carrying N design citations, or one shared component with N call sites.** The COLLAPSED detector, and it is countable today: `WorldCue` 11 call sites, `StaggeredReveal` 11, `GlyphView` 9, `SectionBlock` 7, `ReadingHead` 7, `RiteBreathe` 6, `BreathingOpacity*` 2 — against designs that give those slots 5, 2, 10, 5, 5 and 2 distinct values. That one query reproduces most of the 38 COLLAPSED verdicts without opening a design file.
**E · A constant-bearing line with NO citation adjacent to a sibling WITH one.** The sweep found this to be its most predictive tell — in #2, #60, #191, #194, #256, #264 the uncited sibling is the wrong one. Countable: `spaceMonoTracked(n)` with a chained raw `.tracking(...)` and no `em:` occurs at **54 sites**; `em: 2 / 9` at **18**.

**The enabling fix, and it is one line.** `Tools/check_citations.py:35-38` defines `DOCS` as `Bindu Feed/CLAUDE.md`, `HANDOFF-NOTE.md`, `OPEN-ITEMS.md`, four `Coverage/` ledgers, `0-INDEX.md`, plus `Bindu FeedTests/*.swift`. The app source tree appears only in `SEARCH` — where quotes are looked FOR, never where citations are read FROM. So **all 532 `file.html:NNN` / `file.js:NNN` citations in `Bindu Feed/Bindu Feed/**/*.swift` are read by no checker** (68 of them to `The Instrument v3.html`, 42 to `spine-sound.js`, 30 each to `world-four.js` and `field-sound.js`). Adding the app tree to `DOCS` catches the off-by-one-sibling class the sweep found by hand at least a dozen times: `ReturnDepth.swift:73/:81/:87/:93` (four, each citing the ADJACENT sibling's line — `:107` for the alpha that lives at `:113`, `:110` for the lineWidth at `:115`, `:126` for the nodeRadius at `:127`), `LightType.swift:18/:32/:35` (three, each off by one), `VoiceCharacter.swift:22` (`:415`, which is `];`, for a value at `:416`), `AxisTravel.swift:184` (`:5985`, which is `};`), `UniverseView.swift:406` (`:1386` is the knob's line, quoting the label's properties from `:1387`), `ReturnPatina.swift:111` (`:123` is a colour helper; `renderRings` is `:233`), `InstrumentView.swift:524` (`:4979-4992` for `withStar`, a range containing no hide condition), `AxisModel.swift:253` (`:5646` for `onGround`, which is `:5643` and shared by both siblings).

**One change to the checker's predicate is required.** As written it verifies a prose quote (`*"..."*` on the same line, backticked spans deliberately excluded after 28 false drifts). Swift comments cite in backticked code spans, so it would skip nearly all 532. The app-side variant must verify the CONSTANT, not the prose: *the literal assigned on the next non-comment line must appear at the cited design line.* That predicate resolves `#where`'s `0.9` against `:5646` and fails — which is the original fault, caught mechanically, at the moment it was written.
