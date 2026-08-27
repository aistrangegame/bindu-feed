# HANDOFF · VERIFICATION

**Behavioural checks, not code checks.** Each names what to *do* on the simulator and what must *happen*.

Write these into the gameplan **before** writing code, as the pass's acceptance criteria. A pass is not done because the diff is written; it is done when its checks pass on device.

**If a check cannot be run, the mechanism is not observable — and that is itself the finding.**

---

## THE TRAPS — run after every pass

- [ ] **No instructional string has come back.** Grep the app for `pull to travel` · `be still — the way opens` · `drag to fly` · `pinch to zoom` · `tap to approach` · `touch once, then do nothing` · `touch to walk further` · `a universe opens`. **Zero hits.** None exists in any design file, and `The Instrument v3.html:1084` forbids the category.
- [ ] **No fixed reference is shrink-wrapped.** Any rail, tick row or indicator that other elements position against has an *explicit* width or height. Bug class 1 — bit three times in one design session.
- [ ] **Every interactive constant swept to both limits.** Drive each gesture value to min and max. Nothing leaves its container; nothing exceeds one register per gesture; no value reads correct only at rest. Bug class 2.
- [ ] **No age derived from an index.** Grep for age / patina / opacity computed from array position where a date or day-count exists on the record. Bug class 3 · `E3.4`.
- [ ] **The protect list is untouched.** Diff the fifteen files in `HANDOFF.md` §7. Any change there is deliberate and named in the gameplan, or it is a regression.

---

## PASS 1 · THE SEAM

- [ ] **A star grows into the planet you land on.** Zoom from `z 0.22` to `34` on one star without lifting off; its radius tracks `R = pr · z` continuously. **No `scale == 2/3` early-return exists anywhere.**
- [ ] **All four Universe registers are reachable, on a cold first launch.** `axisLocked` must not arm for the Universe at all — `B0.1` fired only in `.onChange(of: here.key)`, which never fires on first appearance.
- [ ] **No dead band at the Feed edge.** At the boundary, both a vertical and a horizontal gesture do something. Currently neither does.
- [ ] **The shader's `uZ` is live.** The field responds as you travel. Follows from deleting `axisLocked`.
- [ ] **A world offers its story, and the story opens.** Approach a lit world: its name rides the sphere, legible only in the light, its position always visible as a bright point. Drag sideways — the world turns, with inertia, and keeps the turn. Touching the name opens `StoryDetailView`. `B6.1`.
- [ ] **The fall reaches layer four.** Descend by gesture, not a pinch-scrub. `d` must exceed `0.84`; the old arithmetic capped at `0.807`, making layer 4 unreachable and the `WORDS` table (C-1052's four verbatim paragraphs) **unreferenced anywhere in the app**.
- [ ] **The Return never fires without consent, and never arrives empty.** Hold at the mouth: the ring closes only while pulling and stops when you stop. Release: it holds and breathes. It fires only on completion, and `onFall` passes the story — never `nil`.
- [ ] **The Light is escapable.** Enter and leave. Either the Turn's direct `.instrument(-5)` door is deleted or `mem[0]` is pre-set on entry; otherwise surface 0's one-way valve traps you. `B0.4`.

---

## PASS 2–3 · THE SWEEPS AND THE CONSTANTS

- [ ] **The four hand-feel constants are the runtime preset.** `DRAG 0.00018 · DAMP 0.956 · span 0.42 · glideDur 5.4` — the `immense` preset, not the module defaults. One line; changes every register in the app.
- [ ] **Hex alphas read as hex.** `0D` → 0.051 · `22` → 0.133 · `32` → 0.196 · `1E` → 0.118. This is why the app reads brighter than the comps.
- [ ] **Tracking is em, not points.** One `spaceMonoTracked(_ size:, em:)` helper; `RoomStyle.swift:20` already knows the conversion. ~20 chrome labels are currently 55–85% too wide.
- [ ] **`#where` is the design's object.** Serif 23 in its own casing at `top:100px`, with the roman + `n of 7` line above and the canon sub-line below. The `sub` strings must be **added to the model** — they do not exist there.
- [ ] **A gesture means the same on every screen size.** `K = 393/frameWidth` applied to `dx,dy` before `zv += (−dy)·DRAG`. `C2.8`.

---

## PASS 4 · THE ROOMS

- [ ] **One gesture is one register.** A long fast swipe advances exactly one of the four. A trackpad flick is one gesture. Release glides to the register reached, never past it. `240px = one register`.
- [ ] **The horizontal is bounded and is the voice's own.** `|lat| ≤ 1` is each voice's full range, reached by one swipe, rubber-banded at the ends. **Bindu's room does not respond** — she is undivided. Ashrey's pull moves all 36 edges. Shweta's lens can be closed entirely and the room says *nothing between them*.
- [ ] **Register 2 has three depths, indexed by the figure.** Map → story → comment. Every mark sits where that voice's mathematics puts it; Ashrey's sit on the **edges of K₉**. A tap descends, a tap on the ground rises, and **the vertical always wins and resets the sub-depth** — it is state, never a mode you can be trapped in.
- [ ] **The map shows the gap honestly.** Lalita's 31 marks with 3 lit; Ashram's 117 days likewise. Dim marks are real positions with no words behind them. **Nothing invented to fill the figure.**
- [ ] **All eleven rooms exist.** Not three.
- [ ] **The Mirror reads one cohort.** After the Airtable work, the pool is the design's ten. A foreign row cannot enter, because the surface belongs to Lalita and there is no union to read.

---

## PASS 5 · THE POINT

- [ ] **The yantra exists.** Nine triangles, three squares at `1.46/1.38/1.30` with four gates, petal rings `16 @ 0.88→1.00` and `8 @ 0.70→0.84`, the `BAND[10]` camera, the annulus at `bandR×0.62→1.34`. Universe nodes sit on its **real enclosure radius, re-projected every frame**. `YANTRA.flare()` fires on Aperture success. **The thing that was lost last time.**
- [ ] **No world routes to a generic reading.** Each of the seven has its own gesture; there is no shared ScrollView. V and VI come from `world-five.js` / `world-six.js`, not from a fallback.
- [ ] **The reading is carried by the hand.** I: rest and stay — the field is *displaced* as you read. II: travel out the ray, `SAY` at the origin to `OPEN` at the rim. III: read *through* a parting you are holding, and each section leaves that zone thinner. IV: press, and the strike deepens — below `0.12`, no impression at all. V: turn the glass, and half of what arrives comes mirror-written from the far side. VI: send and wait. VII: keep pace or it scatters.
- [ ] **World V's guard pane behaves.** It gives nothing, the reading never crosses at it, and completing it **withdraws the hall and returns him to the Surface** without advancing the walk. The withdrawal runs on a wall clock and never snaps.
- [ ] **The staged descent plays.** Five stages × 3400ms, tap-to-skip, `‹ ascend`, light shaft, world-dimming.
- [ ] **The gate has its five canon deals.** Not three invented strings.
- [ ] **The Aperture is whole with no key.** Remove the key: open the eye and a register arrives with its origin and the honest fourth line. Open again — never the same register twice in a session. With a key, the same frame fills two more slots and the fourth line stays.

---

## PASS 6 · THE CEREMONIES

- [ ] **The Return carries the story you descended into.** Fall into three different stories; each arrives as its own seed. No hardcoded `C-1052`.
- [ ] **A story never returned to renders correctly.** Default state draws **the seed and no rings** — not zero rings from an off-by-one. `E3.1` drew `returnCount − 1`.
- [ ] **Age is from days, per ring.** A one-second-old ring is bone and raw; a two-year-old ring is deep gold and craquelured. Bloom and craquelure gate on `rel × trueness` — **nothing wears age it has not served.**
- [ ] **A return writes back, and voices answer the return.** Seal a ring: the field answers, and each answer binds to the ring it replies to. The room's register 2 then shows *one on the story, N answering returns*. **No count is displayed anywhere.**
- [ ] **The ceremony returns him to the depth he left from.** `walk-continuity.js` — the `asf.walk` sessionStorage object carries the depth and the breath. He must not come back to a cold Door, and the 0.1 Hz clock must not restart mid-walk.
- [ ] **The Light's column lifts and masks.** A five-anchor scene neither overflows nor spills onto dim stone. `E1.2`.
- [ ] **The Light's six presences exist and you choose.** The day-hash does not pick for you. `E1.1`.

---

## PASS 7 · THE SOUND

- [ ] **Be still, and the app answers your stillness.** Stop touching on the axis: a two-oscillator drone swells over **4.6s**, the fifth opening toward the octave. Touch anything — gone in ~0.2s. Currently a 0.6s blip at ~`0.00026` amplitude, effectively inaudible. **`E4.2` — the one place in the app where sound answers the absence of a hand.**
- [ ] **The beats narrow.** `BEATS = [8, 7.5, 7, 6.5, 6, 5.5, 5, 4.5, 4.2, 4]` as the live L/R offset on the Point. Every register currently beats at 4 Hz — the alpha-into-theta argument is absent.
- [ ] **Two beds, by surface.** Field: root + fifth, 900 Hz lowpass, convolution bus. Point: binaural pair with its beat.
- [ ] **Pitch and timbre come from different tables.** Pitch from the Rite table; all eleven `CHAR` timbres present and distinct — Shweta at `gain 0.012` with her band of air, Arch's `vib 4.6`, Neev's `partials [0.5,1]`, eleven pan positions.
- [ ] **The Light is not silent.** Nave convolution, both `breathIn`s, `veilLift`, and the **528 + 792** room tone. Seven of eight events are currently missing.
- [ ] **Nothing cuts.** Moving between surfaces crossfades the bed. Muting is a 0.5s fade. No event exceeds `0.075`. `prefers-reduced-motion` suppresses events while leaving the bed.
