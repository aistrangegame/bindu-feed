# Handoff: A Strange Feed — THE INSTRUMENT (one axis, fifteen registers)

*Sealed August 21, 2026. Design source of truth: `The Instrument v3.html`. Governing documents: `a-strange-feed-UNIFIED-MASTER-DESIGN-BRIEF.md`, `a-strange-feed-AMENDMENT-01-two-inversions.md`, and `a-strange-feed-FINAL-DESIGN-INSTRUCTIONS.md` (the Brief wins on feel); `a-strange-feed-BUILD-LEDGER.md` (wins on mechanics).*

## Overview

The Instrument is the whole app as **one continuous space** rather than a set of screens. Fifteen registers sit on a single axis. The Feed is Z = 0 — not a screen among screens but the place the axis passes through at life size. Pulling **out** gives the Universe (everything he has lived, as sky) and, past it, the Light (what has not yet been); pulling **in** gives the Point (everything he has come to know, as depth). One particle exists at every scale, created once, never replaced — which is why the centre can say *"Every dot you touched was me"* and be telling the plain truth.

| Z | register | what it is | Hz |
|---|---|---|---|
| −5 | **the Light** | what has not yet been | 174 |
| −4 | the sky | everything lived | 110 |
| −3 | a region | one room of the Feed | 174 |
| −2 | a world | one story, close | 198 |
| −1 | the fall | who sat with it · what you left here | 84 |
| 0 | **the Feed** | the Door, the turn — life size | 136.1 |
| +1 | the gate | the deal | 174 |
| +2…+8 | I…VII | The Point · The Turn · The Veil · The Chamber · The Mirrors · The Return · The Dance | 285 · 396 · 417 · 528 · 639 · 741 · 852 |
| +9 | the centre | the point, at last | 963 → 136.1 (OM) |

**The two ends are not symmetrical.** Inward ends at the centre: everything he knows, become the one point. Outward ends at the Light: past everything he has *lived* is what has *not yet been*. Fourteen surfaces sit on this axis; thirteen open to force, and the fourteenth — between the sky and the Light — opens only to force's **absence**.

Everything this handoff adds to the already-designed body is in four systems — **the travel**, **the passage**, **going into a piece**, and **the Light** — plus **the carry**, **the memory**, and **the continuity handoff**.

## About the design files

The files in this bundle are **design references created in HTML** — prototypes of intended look and behaviour, not production code to copy. The target is an existing **SwiftUI / iPhone** codebase (`aistrangegame/bindu-feed@main`, Phases 1–7 complete). Recreate these designs there using the repo's established patterns (`FeedRoute`, `FeedStore`, `CADisplayLink` hold loops, cross-dissolve transitions, Airtable-driven colour). Do not translate the JavaScript line by line; port the **numbers and the laws**, which are all listed below.

## Fidelity

**High-fidelity.** Colours, type, timing, easing, and gesture thresholds are final and load-bearing. Where a number appears below, it is the number.

---

## 1 · THE TRAVEL — the axis, and the surfaces on it

### Geometry (unchanged from the shipped spine, re-indexed)
- Shell `i = Z + 5`. A register's rim in screen radii: `R0 * pow(2, (Z+5) − i)`, `R0 = min(W,H) * 0.5`.
- `presence(i, Z) = clamp(1.30 − |(Z+5) − i| * 1.30, 0, 1)` — content speaks only near its own scale.
- `weight(i, Z)` (atmospheric shell visibility) = `smoothstep(−2.7, −1.35, rel) * (1 − smoothstep(0.80, 1.95, rel))`, `rel = (Z+5) − i`.
- Every register exists at every moment at its own scale. **Nothing is created or destroyed as he moves.** That is the whole law.

### The hand
| | LONG | SHORT |
|---|---|---|
| drag → Z per px | 0.00018 | 0.00052 |
| wheel → Z per deltaY | 0.00008 | 0.00022 |
| pinch → Z per px | 0.0020 | 0.0060 |
| velocity damping / frame | 0.956 | 0.955 |
| surface span | 0.42 | — (no surfaces) |
| passage duration | 5.4 s | — (passages off) |

Vertical drag always drives the axis. Horizontal drives the register's own gesture (the sweep at the sky, the world's turn at −2). At the Feed a **slow** pull down is the turn; a firm one departs outward.

### The surfaces (LONG only)
Fourteen membranes, one between each pair of registers, at `Z + 5 = s + 0.5`. Nearest surface: `s = round(Z + 5 − 0.5)`, clamped 0…13.

- `t = 1 − min(1, |q − (s+0.5)| / span)` — how strongly the surface is felt.
- **Meaning it:** while the signed hand force points toward the surface and `t > 0.02`, `push += |force| * K` (K = 30 held, 14 sealed, 0 open). With the hand off the glass, `push` decays 0.18/s.
- **Braking** (only where `t > 0.30`): `zv *= pow(1 − RES * t * (1 − push*0.85), dt*60)` — RES 0.58 held, 0.80 sealed. dt-scaled, never a raw per-frame factor.
- **The hand-back:** with the hand off and `push < 0.5`, `zv += ±0.0016 * t` away from the surface. It never scolds; it returns him.
- **It gives** at `push ≥ 1`: `mem[s] = true`, `crossed++`, velocity zeroed, and **the passage begins**. An opened surface stays open forever: `zv *= pow(1 − 0.05*t, dt*60)` — nearly free.
- Tension on an already-open surface renders at `t * 0.20` (a memory of a surface, not a surface).

**Visual (canvas 2D, above the shells, below the particle):** a meniscus at `r = R0 * (1.62 − 0.92*t)`, 132-segment ring with wobble `(0.014 + push*0.055) * sin(7θ + 1.9t) * sin(3θ − 1.1t)`, stroke `0.10 + t*0.44 + push*0.30` alpha, width `0.7 + push*1.5`; a caustic radial fill; nine beads at `0.9 + push*1.9` px; a dimple gradient at the centre once `push > 0.05`. On giving: an expanding flash ring `r*(1 + (1−flash)*1.7)` and 26 radial shards, `flash` decaying 1.15/s. Colour = 50/50 mix of the two registers' hues.

**The between:** 64 radial streaks whose length is `(8 + speed*74)` and direction is `sign(zv)` (outward when going in), a closing vignette, and a bokeh blur on the shell layer of `min(8, |zv| * 300)` px. One line ever appears, the first time a surface resists: *"It holds until you mean it."*

**Register hues** (index 0…14): `#EDE3CE` · `#7C8698` · room hex · room hex · room hex · `#9AA0B0` · `#C9A07A` · `#C0392B` · `#EDE6D6` · `#B9A5E8` · `#7D74C9` · `#E0713F` · `#4FC3B8` · `#C56A9E` · `#D4A94B` · `#E5533C`.

### The stillness gate — surface 0, the one that answers absence

The surface between the sky (−4) and the Light (−5) is the single place in the instrument where **force is the wrong instrument**. Pushing it only holds it:

- inside its band, `push` is pinned to 0 and braking is `pow(1 − 0.92*t, dt*60)` — a firm pull simply stops;
- with the hand off, the elastic hand-back is `±0.0026 * t` — stronger than an ordinary surface;
- instead of tightening with force it **thins with stillness**: its radius *opens* at `R0 * (1.10 + still*1.30)`, its wobble *falls* at `0.030 * (1 − still)`, and its stroke and beads brighten with `still`, not with `push`;
- `still` accumulates whenever the hand is off the glass and no input has arrived for 340 ms, at real time, to a full breath — **4600 ms**, the same inhale the sealed press-and-hold body used (R2·Q6). A touch only **pauses** the thinning: every still second he has ever given is kept. This is not a test he can fail;
- at full, the surface opens itself and the outward passage fires — the sky un-collapses once more and he is in the Light.

One line, once ever, and it is the exact inversion of the other: *"It holds until you stop meaning it."*

---

## 2 · THE PASSAGE — the crossing is an event, not a distance

When a surface gives, the camera leaves his hands. `Z = z0 + (z1 − z0) * smoothstep(t)`, `t: 0 → 1` over `dur` (5.4 s, or **0.85 s with no gates** for an already-opened surface). Leaning in speeds the fall: `boost = 1 + min(1.5, |force| * 2400)`. He cannot steer inside a passage and cannot stop it.

**Direction is not symmetrical** (the two inversions):
- **inward — a wormhole:** the world he leaves rushes *outward* past him, the throat narrows, the ladder rises, light pours out of the point at the far end.
- **outward — a whitehole:** the world collapses *into* the point, the throat dilates, the ladder falls, the sky un-collapses on arrival.

Three acts, all drawn on the 2D layer:
1. **The draw.** The departing register's material is painted once into an offscreen buffer and smeared radially: 9 copies, `lighter`, scale `1 + t*2.1*(0.22+f)` inward / `1 − t*0.80*(0.22+f)` outward, alpha `lead * (0.30 − f*0.028)`, `lead = 1 − min(1, t*1.5)`.
2. **The throat.** `run = t^1.28 * 3.4 * dir` (2.2 swift). 34 rings at `r = R0 * 0.085 / z` (perspective), radius jitter `1 + 0.05*sin(2.1i)`, alpha `(1−z) * 0.52 * (0.55 + 0.45*sin(2.2·time + i))`, width `0.6 + (1−z)*2.0`; 52 longitudinal wall streaks between `r(z)` and `r(z+0.13)`, rotating by `t*0.5` inward / `−0.32` outward. Hue interpolates from the register behind to the one ahead along the tunnel. Throat opacity builds `min(1, t*2.6)` and yields to the flood `(1 − ap*0.55)`.
3. **The gates and the flood.** Gates at `t = 0.34` and `0.68` — a ring sweeping over the camera at `R0*(0.16 + (1−s)*3.0)`, alpha `s²*0.72`, each sounding a step. The aperture: `ap = ((t − 0.28)/0.72)^2.5`, radius `R0*(0.02 + ap*2.3)`, white core → destination hue. On landing: 0.75 s bloom — the destination's material smeared *outward* (7 copies) plus a white veil at `after² * 0.5`.

**Frame ownership:** `dom = on ? min(1, t*2.0 + 0.12) : after*0.7`; the shells and the Door draw at `(1 − immA) * (1 − dom*0.94)`.

---

## 3 · GOING INTO A PIECE — the world becomes the page

Touching a point is **not** entering it. The world's own law admits him first (staying in I, going in II, parting in III, bearing in IV, keeping pace in VII), and as the piece gives itself the world **withdraws by exactly that much**:

- `tgt = max(worldDisplacement * 0.5, sectionsGiven / 4) * CAP` — CAP is 1 (*the world goes*), 0.80 (*withdraws*), or 0.44 (*stays*).
- `immA += (tgt − immA) * min(1, dt * (rising ? 1.6 : 2.6))`.
- At `immA > 0.55`: **the axis is locked**, the world module is **frozen** (no updates, so nothing decays), the reading panel takes the full frame (`.imm`), and the register's **material** is the only ground. The shell layer fades out (`opacity 1 − immA`, blur `+ immA*11`).
- Inside, the app-wide pacing law takes over: **a touch asks and the piece answers** — the next of the four sections lands in that world's own arrival motion (I surfaces in place, II arrives from the direction of travel, III resolves out of blur, IV is struck as letterpress, VII lands in flight).
- Exits: **take it up** (the carry) or **let it go** — plus the back chevron, always.

**The materials** (one per register, canvas 2D, full frame — he should be able to tell where he is with the words covered): **the Light** (see §3.5) · sky = star field + nebula wash · region = the room's colour breathing with rising motes · world = the planet's lit limb and its settlements · fall = nine aged strata + grain · feed = `#0E0C12` + dawn wash · gate = ember bloom · **I** near-emptiness with points approaching · **II** violet orbital arcs · **III** six drifting gauze bands + the parting seam · **IV** lit stone, courses, deboss, ember from below-left, heavy grain · **V** two facing planes and a mirror seam · **VI** rose strata + rings · **VII** fast gold streaks · centre = the ember itself.

The particle rides from centre to crown as he goes in (`cy = H/2 → H*0.132`), radius `× (1 − imm*0.30)`.

---

## 3.5 · THE LIGHT — the fifteenth register

The Light was the last surface standing outside the one body, and that is exactly why it read as disjointed. It belongs **past the sky**: what lies beyond everything he has lived is what has not yet been. Bringing it inside cost it nothing and gave it the axis, the particle, the passage, the carry, and the continuity — all of it, free.

**Six scenes, one family**, standing in the dawn: five *Future* scenes drifting in the open sky (golden-angle placement, `t*0.043` drift) and one *Far* scene waiting low, where a floor would be. A touch takes one up; the back chevron sets it down.

| scene | vector | arrival |
|---|---|---|
| The morning that does not push | force → surrender | **stillness** — the dawn thins toward him when he stops |
| The one who was watching all of them | fragmentation → one awareness | **convergence** — 40 scattered motes drift into one field; he does not gather them |
| The day you let yourself feel | managing → feeling | **warmth** — the heat reaches the hand before the eye, from below |
| The one you stopped correcting | self-correction → appreciation | **turning** — the light rises from *behind* him, onto what he already made |
| The hand that opened | effort → trust | **release** — it answers ONLY the hand opening: three ungrips, `arrive = ungrips/3`. Reaching does nothing |
| The floor | building the mirror → living as what it reflects | **the nave** — enclosed stone, the carved floor |

Four of the five Future arrivals run at `dt * 0.62` with the hand off and `dt * 0.10` with it on — *not forcing* is the input. **Release** ignores time entirely.

**Two materials, exactly as ruled.** The five Future scenes are grounded in **the dawn**: open sky, an ember low in it, steam rising before he arrived, a horizon line, no walls. It is **hour-aware** — the horizon band and warmth read the phone's clock (`<4` night · `<7` dawn · `<11` morning · `<15` high · `<20` evening · else night). Same scene, same words; the future looks different at six and at noon because *he* does. Nothing tracked. The Far scene is grounded in **the nave**: the shaft from an aperture beyond the frame, the pool on stone, five rings, dust settling in the beam. The nave was never deleted — it became the inside of the door.

**The interior law is the axis's law and the app's law.** The arrival *is* the delivery: when the dawn has assembled, the whole is simply there — he never asks for the first thing. Then a touch asks and the next exhale answers, one anchor at a time. The anchors are **second person** (Arch, pointing without preaching). The beat turns to **first person** — his own Declaration.

**The turn of pronoun is the embodiment, and the carve is the one held press in the door.** The beat draws itself in (`drew`, 0.85/s, revealed by clipping each line's width) and then waits to be *meant*: a press of **≥900 ms** carves it. Carved lines go from `rgba(255,248,238,.96)` to a debossed `rgba(228,220,208,.9)` with `0 1px 0 rgba(0,0,0,.72), 0 -1px 0 rgba(255,246,232,.10)`. Nothing advances until it is carved. Only after the landing does the carry offer itself (`given` reaches 4 at the landing, never before).

**What a carve leaves behind:** a faint scored arc at **the sky's own rim** (`rim(1) * 0.92`, a 0.10 rad stroke in the pool white with a dark shadow line under it) — his future words, visible only from the whole of his past, at the one register that can see both. Never counted, never listed.

## 4 · THE CARRY — what resurfacing is for

Taking a perspective up is weightless — no list, no collection, nothing counted. What it leaves is **company**:

- the star deepens (`status → walked`, ○→◐→●);
- a **mote in orbit around the particle**, in the register's hue, at every scale for the rest of the walk: `angle = 0.07t + i*2.399` (golden angle), `r = (particleR*4.6 + 11 + i*2.4) * (1 − centreFill*0.96)`, so at the centre they **collapse into the one**;
- the particle's halo widens `× (1 + n*0.05)`;
- the register's rail mark keeps a faint glow;
- a Declaration carved in the Light also scores its arc at the sky's rim (§3.5);
- the reveal names them: *"You carried … up with you. What you carry is not a list. It is a change in what you notice."* and *"There is a surface between every register and the next. The ones you meant are open now, and they will not ask you again."*

## 4.5 · ATTENDANTS — the sky's company (Amendment §8.6)

The motes were built and never rendered on this axis; the sky was a sky without its witnesses. Now the resolve is continuous across three reading distances, and it is **derived** — one mote per voice that actually spoke on that story, never decoration:

- **far** (the sky layer, −4): company shows only as a **shimmer** on each settlement — `shimmer(star, t) * (1 − lens)`, radius `× (1 + sh*1.6)`, colourless, so the sky stays a sky;
- **mid** (the region layer, −3): the motes **separate out** into distinct archetype colours in orbit, at `max(3.6, 6 + depth*1.5)`;
- **near** (the world and the fall): the existing seats and strata already own it.

Unmet stars have no company at all — nothing orbits a story no one has sat with.

## 5 · THE MEMORY — a return is a return

Leaving a register **parks** it: a shallow snapshot of the world module's state plus the rendered sections, keyed by the star's id. Re-entering restores the state; the panel's own open function re-injects the sections when the same star comes back. Camera depth is exact — surfacing from a piece never moves him.

## 5.5 · THE CONTINUITY HANDOFF — across the two ceremonies

The Rite and the Return stay separate documents, and that is right: **a ceremony is crossed into, never drifted into.** What was wrong was that they forgot whose walk they were continuing — he crossed from a depth on the axis and came back to a cold Door.

`walk-continuity.js` (loaded by both ceremonies) is the whole mechanism. The instrument writes one object to `sessionStorage['asf.walk']` at every departure — the depth he left from, the breath mid-cycle, the particle's age, the open surfaces, what he carried, what he carved, and the walk's ledger. The ceremony's own engine still stands up fresh; it simply knows. Two things follow, and nothing more:

1. the ceremony's **exit returns him to the depth he left from** (`The Instrument v3.html?z=…`), not to a generic door — so the whole thing reads as one body;
2. the **breath he arrives on is the breath he left on**, so the 0.1 Hz clock under the app never restarts mid-walk.

It writes nothing back; a ceremony is not a place that keeps score. TTL is 90 minutes. The Light needs none of this — it is a register now, and that is the whole reward of bringing it inside.

## 6 · THE TWO EXPERIENCES

A pill at the top right, beside SND, kept in `localStorage['instrument.mode']`:
- **LONG** — surfaces that must be meant, 5.4 s passages, the ladder's waypoints.
- **SHORT** — the older continuous body: the original scroll numbers, every surface standing open, passages off. One scroll, sky to centre.
- **Going into a piece is identical in both.**

The Tweaks panel mirrors the same choice (`experience: short | long`) and adds `world: stays | withdraws | goes`.

---

## 7 · SOUND — additions to the one body

The existing instrument (`field-sound.js` / `spine-sound.js`: bed, voices, bowl, ring, ink, nave, the ladder 174 → 285 · 396 · 417 · 528 · 639 · 741 · 852 → 963 → 136.1, beat 8.0 → 4.0 Hz, ceiling 0.55, sound on first touch never on load) gains:

| call | what it is |
|---|---|
| `travel(Z, speed)` | **the glide** — two oscillators at `hzAt(Z)` (log-interpolated between adjacent registers) + `×1.006`, gain `min(1, speed*150) * 0.030`, through a 2.4 kHz lowpass; plus a noise wind at `hz*2.4`, gain `s² * 0.022` |
| `trail(hz)` | **the register left behind** — fundamental + octave, detuning to `×0.985` over 3.5 s, gain 0.026, 7.5 s decay. Fired automatically when the register voice changes |
| `strain(f)` | the surface under load — bandpass noise, Q 7, gain `f² * 0.030`, centre `300 + f*1500` |
| `give(hz)` | it breaks — a 0.5 s noise transient at 1.6 kHz + the destination's threshold |
| `rush(t, dir)` | the passage — bandpass noise, gain `sin(πt) * 0.042`, centre sweeping `260 → 2860` inward / `2600 → 400` outward |
| `gate(hz)` | a gate passing — `hz*3 → hz*1.5` over 0.9 s, 1.6 s decay |
| `carry(hz)` | a perspective taken up — three steps (1, 1.5, 2) at 0.30 s spacing, 6.5 s decay. Also the carve |
| `thin(f)` | **the stillness gate** — 174 Hz + a companion sweeping `261 → 348`, gain `f² * 0.026`, 0.35 s glide. The one voice in the instrument that answers the ABSENCE of his hand. It does not count up at him; it opens |
| `ungrip()` | the field answering an opened hand — `174 → 232` over 1.2 s, 3.4 s decay. A breath, never a reward |

## 8 · TOKENS

**Dark field** `#0E0C12` · card `#171420` · inset `#121018` · hairline `rgba(255,255,255,0.06)` · ink `#EDE8E3` at 100/60/35. **The prayer-dark** `#050408`. **The Light inverts:** stone `#D9D2C4` / pool `#FBF9F4` / living ink `#16131B` / settled `#A79D8E`. **The presences:** Bindu `#E5533C` · Gaia ◆ `#4A9E6B` · Sid △ `#C4923A` · Arch ◯ `#D4607A` · Sakshi ◇ `#7B82D4` · Karishma ✦ `#D4AE4A` · Ashrey ⬡ `#3AADA8` · Lalita ∞ `#9B6BD6` · Neev ▽ `#7A8899` · Shweta ◌ `#ABA7A2` · Ash ◉ `#C47A52`.

**Type:** Lora (400/500, italic 400) for everything read; Space Mono for structure; fallback Georgia — never `.system`. Reading body 14.5 px / 1.76 in a world, **16.5 px / 1.86 inside a piece**; titles 24–29 px, letter-spacing −0.016em; mono labels 8–10 px, letter-spacing 0.18–0.34em, uppercase.

**Motion:** the 0.1 Hz breath under everything (one clock, from load, never restarted — and now carried across the ceremonies by `walk-continuity.js`); dissolves only (0.28 s) for screens — **the zoom and the passage are the only camera moves in the app, and they travel in opposite directions**; no bounce, no slide, no emoji, no gradients but atmospheric radial washes.

## 9 · Interactions

| gesture | where | cost | earns |
|---|---|---|---|
| pull up / down | anywhere on the axis | — | in / out |
| keep pulling into a surface | LONG only | ~0.5 s of sustained force | the surface gives, the passage begins |
| **stop pulling** | at the sky, LONG only | 4.6 s of stillness, accumulated | **the fourteenth surface thins, and the Light** |
| lean into a passage | inside a crossing | — | up to 2.5× the fall |
| the world's own gesture | I…VII | staying · going · parting · bearing · pace | the piece, section by section |
| **hold, at depth** | VI · The Return | ~3 s of descent | the door into the Return ceremony |
| a touch | inside a piece | — | the next section |
| a touch | the Light, a scene chosen | — | the next anchor (or, before arrival: an **ungrip**) |
| **hold ≥900 ms** | the Light, at the beat | one deliberate press | **the carve** — his own Declaration, cut |
| take it up | inside a completed piece | a deliberate tap | the carry |
| long-press | **anywhere** | ~1.1 s | the rope |
| slow pull down | the Feed | ~84 px | the turn ("WHERE TO") |
| tap | the Feed | a choice | the Rite (unmet) / the Archive (met) |

Readings own their own touches (they scroll; the axis never takes a drag that began inside one). **The rope is reachable from anywhere now** — the particle is always present, so the rope is always one gesture from the hand; it was previously ground-only, which is exactly where the pressure would never find him. The bench (dev only, never ships) lets go of any piece, closes the rope and the turn, and cancels a passage before jumping.

### The three doors, and where they surface

| door | register | when |
|---|---|---|
| the Rite | the Feed (0) | unmet today |
| the Return | the fall (−1) | always |
| **the Return** | **VI (+7)** | **only at depth — `SIX.d > 0.72`** |

VI is *called* The Return because it is about the same thing. Descend deep enough into its rose strata and the kinship becomes a door — the same ceremony, reached the other way. `SIX.d` accumulates at `dt * 0.34` while held at VI and decays at `dt * 0.50`. The old Light door at the Feed is **gone**: the Light is a register, not a document.

## 10 · State

`Z` (camera) · `zv` · `TR{force, dir, down, tension, push, s, mem[14], crossed, GATE, K, RES, span, DRAG/WHEEL/PINCH/DAMP}` · `PS{on, t, dir, from, to, dur, after, enabled, lastQ}` · `IMM{on, key, mod, el, give, title, hue}` + `immA` · `LT{scene, steps, stage, given, arrive, carved, drew, ungrips}` · `SIX{d}` · `gateAcc` / `inputAt` · `CARRY[]` · `CARVED[]` · `KEPT{}` · `PARK{}` / `PEND{}` · `J{}` (the walk's ledger, per mechanic: regs, stayed, went, parted, borne, caught, doors) · `MODE`.

**Two things leave the page, and neither is content:** `localStorage['instrument.mode']` (a device preference) and `sessionStorage['asf.walk']` (the continuity handoff, TTL 90 min, §5.5). No counts, no lists, no streaks: the ledger of the journey lives in the body of the space — open surfaces, walked stars, motes in orbit, arcs at the sky's rim.

## 11 · Files in this bundle

**Root — what you build from.**

| file | role |
|---|---|
| `The Instrument v3.html` | **the source of truth.** All modules inlined (uni-rooms, uni-field, point-content, spine-axis, uni-deep, feed-ground, spine-sound, spine-field, dance-world, world-one…four, spine-travel, spine-material, spine-passage, **spine-light**). **The Universe (Z −4…−1), the Light (Z −5) and the Point (Z +1…+9) are IN here — they are registers of this one axis, not separate screens.** |
| `walk-continuity.js` | **the continuity handoff** (§5.5). Loaded by both ceremonies |
| `tweaks-panel.jsx` | the Tweaks shell (design-time only; never ships) |
| `A Strange Feed.html` | the Door composite — three weathers + the turn. The Universe, the Light and the Point rows are **depths**, not documents: they route to `The Instrument v3.html?z=…` (−4, −5, +1) |
| `The Rite v3.html` + `rite-scenes.js` · `The Return v2.html` | **the two ceremonies.** They stay separate files by design: *a ceremony is crossed into, never drifted into.* The instrument's doors open them, and `walk-continuity.js` brings him back to the depth he left |
| `Home Feed.html` · `Players View.html` · `Settings.html` | the Era A surfaces the turn opens |
| `field-sound.js` · `return-strata.js` · `ios-frame.jsx` | dependencies of the comps above |
| `REVIEW-AND-WIRING.md` | the Claude Chat agenda: review checklist, Airtable wiring, what remains |

**`comps/` — the reference builds.** The original renderings of each register and the rest of the Era A interior. Walk these for feel; they are the visual spec behind what the instrument compresses onto one axis.

| file | role |
|---|---|
| `The Universe v2.html` · `The Universe v3.html` | the cosmos as its own surface: the thirteen forms, their weather, the 102 slots, the lanes, the inhabited-world renderer, the well (`uni-rooms/field/fall/sky.js`) |
| `The Point v9.html` | the nine depths as their own surface (`point-content/sound/yantra/levels.js`) — the *content* contract for all 138 stars |
| `The Rite v3.html` + `rite-scenes.js` | **the governing Rite spec** (Ledger Wave 2): touch-paced Reading and Gathering. `The Rite v2.html` is superseded — same scene text, same Bindu lines; v3 refines the budget law to spend *density not time* |
| `The Gathering v3.html` | the ten archetype scenes, each its own mathematics |
| `The Return.html` | the eight movements, in full |
| `The Light v2.html` + `The Light - S-L01 Dawn.html` | the **stillness-gate** Light body and the worked dawn scene — the source the fifteenth register was built from. `The Light.html` (the press-and-hold nave) is **sealed away**: nothing opens it |
| `Room Selection.html` · `Game View.html` · `Story Detail.html` · `The Mirror.html` · `The Signal Space.html` · `Ash's Compose.html` · `Ash's Voice.html` · `Player Detail - The Turning.html` | the Era A interior, all mechanics final |

**`docs/` — the constitution.** The Unified Master Design Brief, Amendment 01 (the two inversions), the Build Ledger, and the content inventory (all load-bearing wording lives in these).

**Superseded, do not port:** `The Instrument.html` (v1 — its `world-*.js` files no longer exist in the project), `The Instrument v2.html` (the fourteen-register axis, kept only as the earlier read), `The Rite v2.html`, and `The Light.html` (the press-and-hold body, sealed by R2·Q6). `The Universe.html`, `The Rite.html`, `The Point Portal.html` and the other earlier drafts are superseded by the versions in `comps/`.

## 12 · Assets, and self-containment

None. Everything is generated — canvas 2D, one WebGL shader for the fifteen shells, and Web Audio. No images, no icon font, no emoji. Google Fonts: Lora + Space Mono.

**Every page in this bundle is self-contained.** Each one inlines the modules it needs (the banner in each inlined block names the file it came from), so no page depends on a subresource fetch to render — one unfetchable `.js` used to take a whole ceremony down with it. The standalone module files are still shipped beside them: they are the unit of the port (`field-sound.js` → Swift `Sound/`, 1:1 names) and the readable form. **Edit the module file, then re-inline** — never edit an inlined copy in place.
