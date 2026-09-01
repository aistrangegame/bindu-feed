# HANDOFF · BUILD LIST — in scope, not yet designed

Everything here is **required**, is named in `AUDIT.md` as absent, and has a source. This file exists so that no absence can be inferred from a comp's silence.

Read `HANDOFF.md` §1–§2 first.

---

## 1 · The yantra — highest priority

**`point-yantra.js`, 188 lines. No counterpart anywhere in the app.** D3.1. This is the thing that was lost last time.

Verified contents of the source:

| Element | Value |
|---|---|
| Enclosures | `BAND = [1.38, 0.93, 0.77, 0.62, 0.50, 0.39, 0.29, 0.20, 0.125, 0.06]` — ten |
| Squares | three, at `e = 1.46 / 1.38 / 1.30`, outermost with four gates |
| Petal rings | 16 petals `ri 0.88 → ro 1.00` rotating `t·0.008`; 8 petals `0.70 → 0.84` rotating `−t·0.011` |
| Triangles | nine — `DOWN[5]` (Shakti) + `UP[4]` (Shiva), coordinates at `:23-24` |
| Camera | `scale()` at `:48-53` — log-interpolated so `band[focus]` **always fills the same share of the frame**: *"the walk is a change of place, not of scale"* |
| Annulus of attention | `inner = bandR·0.62`, `outer = bandR·1.34` (`:137`) — the enclosure you are in, lit, inside a clipped ring |
| Star anchors | `anchors(n, idx)` at `:57-62` — `BAND[idx]·0.72`, offset `idx%2 ? 0.16 : 0` |
| Flare | `flare()` `:43`; drawn `:153-155` — `3.4s`, `R = 6 + eoq(q)·max(W,H)·0.62`, **screen space, same size at every depth, "because it is the sound you are seeing"** |
| Also | sky, wash, incense, shaft, `setMode('walk'|'descend')` dimming to `0.22` |

**D3.2 — node placement.** Universe nodes must sit on the yantra's **real enclosure radius, re-projected every frame** so they track the figure. `point-yantra.js:57-62` + `The Point v9.html:954,966-968`.

**Wired to:** `The Aperture.html` renders the flare's *visual half* and expects the real yantra behind it (`YANTRA.flare()` on Aperture success, D6.5). `point-levels.js:231` calls `YANTRA.setMode('walk')`.

Star `r-geometry` says *"You are inside one right now."* Until this exists, that line is false.

---

## 2 · The staged descent

`point-levels.js:198` — `async function descend()`. D4.1. Currently only the text container exists.

Five stages × 3400ms · tap-to-skip · `‹ ascend` · the light shaft · world-dimming · glide down and up. `Snd.glide(cur, true)` sounds the descent — the sound side is in `The Sound.html`.

`The Reading.html` specifies what happens once you are **in** a world. This is how you get there.

---

## 3 · The gate's five DEALS

D2.1. The register is literally named *"the gate · the deal"*, and `AxisGateView` invents three strings instead of the five canon deals. **Canon text — do not paraphrase.**

---

## 4 · Worlds V and VI — **build from source, not from scratch**

> **Correction.** `The Reading.html` originally said V and VI *"have no bespoke module in the design either."* **That was wrong.** Both are fully authored. The comp is corrected in-file. This is the most consequential error caught in verification: it would have sent two worlds to a generic ScrollView, which is `D5.1` reintroduced.

All seven exist: `world-one.js` … `world-seven.js`. **Read these as the deeper source for every world** — they are more specific than the corresponding sections of `The Instrument v3.html`.

### V · The Mirrors — 639 Hz — the reading material of this world is **turning**

`world-five.js`, 463 lines.

- **The Hall.** Eleven panes of glass in a corridor: five facing pairs about one vertical mirror line, plus **one pane standing on the line, alone** (`GUARD_AT = [0, -0.60]`).
- A pane is two-sided and turns about its own vertical axis. Its partner across the line is its reflection — *"when this one is toward you, that one is away. Turn either and both turn."*
- **The reading physically crosses the line every half turn.** A section arrives on this side, the next arrives from the other, **mirror-written, and unflips as it settles**. `spin()` `:145`; a drag across three quarters of the shell is one half turn — *"far enough that carrying a face through edge-on is a real act of the hand."*
- **The regress** `:334-344` — each pane holds its partner holding this pane, away to nothing. *"It deepens as he reads — two returns at the surface, and by the fourth section the corridor inside the glass has no end. Where he has already been it stays deep."*
- **The throw** `:269-271` — a mirror turning under the hand casts the hall's light across the aisle. *"You cannot turn a mirror in a room and have the room not know."*
- **The guard pane** gives nothing. `:159` — *"nothing faces it. The reading never crosses."* Completing it **withdraws the hall and carries him back to the Surface** — `:43-45`, *"A guard turns you back; it does not let you"*. It does **not** advance the walk. The withdrawal runs on a wall clock (`backAt`) so it finishes whether he is present or not.
- **No labels anywhere.** `:256-258` — a faced pair keeps its light lit, *"so the hall shows where he has been without a mark, a count, or a word."* `:430-431` — the withdrawal says nothing, *"a caption here would be the instrument explaining its own guard."*
- Returns `{k: ['say','walk','hand','open'][given-1], i: given}` — the same four sections, same order.

### VI · The Return — 741 Hz — **send and wait**

`world-six.js`, 468 lines.

- **The horizon.** One low line. Everything he has is below it; everything not yet come back is above it.
- **Depth is time, not distance.** The near field is banded — nearest band is *now*, each band further back is further back. The Window's three stand in the nearest band; the Crossing's three stand deeper.
- **Deep Time stands on the horizon itself, and does not belong to him.**

---

## 5 · The Light's six presences, and the act of choosing

E1.1 — they do not exist; the day-hash picks for you.

Also **E1.2**: the Light's text column has **no lift and no mask**, so a five-anchor scene overflows and spills outside the pool onto dim stone.

`The Sound.html` supplies the Light's bed and its five movements. The visual side is unbuilt.

---

## 6 · The Mirror · Signal · Practice Door, as room instances

`The Rooms v4.html` gives the framework and the ruling: **the Mirror is Lalita's room, the Signal is the field's, the Practice Door is the threshold's.**

Rebuilding them as instances of the room framework is what closes §A *structurally* — a surface that belongs to a voice cannot read a foreign cohort, because there is no union to read. Pairs with `HANDOFF-AIRTABLE.md` §A.

---

## 7 · The eight remaining archetype rooms

Lalita, Arch and Shweta are built as exemplars. **All eleven ship.**

- Every figure exists verbatim in `rite-scenes.js`; `Components/GatheringScene.swift` is a verified faithful port of it — **derive from that, do not diverge it**.
- `room-figures.js` is the extracted module for the three exemplars, with the header stating the rule: *"Nothing here invents a new figure. What is new: scale, permanence, the `lat` response, and the fourth register where each figure turns."*
- `The Rooms v4.html` carries a `MAPGEO` entry for **all eleven**, so register-2's map geometry is specified for the eight unbuilt rooms too.
- Blocked on one ruling: **Ashram vs Ash** (see `HANDOFF-RULINGS.md`).

---

## 8 · Everything else in the audit's Tier 1–3

The seven comps cover seven areas. **They do not cover the other ~200 findings, and their silence is not a ruling.** Work `AUDIT.md` §H2–H4 directly for:

- The Rite's Sealing stacking instead of replacing; **remove the 1.7s haptic loop**.
- `LightNave` — worn rings per **exhale**, not from `still`; Bindu inside the camera transform at design scale.
- `AxisModel` — the `centre` colour bug (`m8` → nil → error hue), the four Universe hues, the feed/gate swap, `maxZ 9.62`.
- `AxisTravel` — the 0.85s swift slip-through + midpoint detector, the two passage gates at `t=0.34/0.68`, `after`/`dom()`, `crossed`, lean-into-the-fall. **`update()` is a faithful port — do not rebuild it.**
- `UniverseCamera` — `dt`-drive `step()`, friction `0.92 → 0.945`, live velocity on every `panBy`, widen `ZMIN`/`ZMAX`, the design's tap impulse.
- `PointJourney` / `PointRevealView` — five small bugs, then the 8-verb reveal, the OM triad, the `knowledge/will/action` labels.
- The Feed-era screens — each has one named first fix in `AUDIT.md` §F12.
- The Audio Anchor's device-locality (Tier 0 #11).
- `walk-continuity.js` — the sessionStorage `asf.walk` handoff: a ceremony's exit returns him to **the depth he left from**, on **the breath he left on**. Check whether this is wired at all; it is what makes the app read as one body.
