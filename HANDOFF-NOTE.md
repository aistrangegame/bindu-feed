# The upgrade build · handoff

Seven passes, branch `upgrade-pass-a-to-c`. Built against the *rendered* design
(`Claude Design Round 2/`), verified on the simulator, and **never walked in full by a
human**. That last walk is yours and is the one thing this build has been kept for.

---

## What changed

**A · the hand.** Four constants to the `immense` runtime preset (`DRAG .00018 · DAMP .956 ·
span .42 · glideDur 5.4`). The build had the module defaults, which left half the glide after
one second.

**B · the sweeps.** Hex alphas read as hex; tracking is em, not points; `#where` became the
design's centred serif block; Gaia Seeds got their own pool; the Signal splitter's derived
path deleted. Six invented instructional strings removed — and `touch to read`, which is
canon, kept.

**C · the seam.** `axisLocked` deleted, which alone closed four blockers and unfroze the
shader's `uZ`. Stars grow `R = pr·z` into the planet you land on. The door opens its story.
The fall reaches layer four by gesture and its presences and strata are touchable, so the
`WORDS` table is readable for the first time. Met-ness reads `Story Met`.

**4 · the eleven rooms.** 240px per register, the lateral bounded per voice, register 2's
three depths. Ten of eleven register-3 lines shipped verbatim; Arch's rejected and rendered
as absence.

**5 · the Point.** Content from `canon/`; the generic sheet killed and seven bespoke readings
kept; the Aperture whole; the yantra ported entire, with the registers standing on it and the
universes re-projected through its own `anchors()` and camera.

**6 · the ceremonies.** The Return writes real rings — `Type='Return'` for the record,
`Return Answer` for the words. Age comes from days. The Light's floor accumulates one ring
per exhale.

**7 · the sound.** Two beds: root+fifth in a room for the field, the binaural pair with
`BEATS` narrowing 8.0 → 4.0 in the cathedral for the Point, which is the only surface that
climbs. `CHAR` ported value for value.

---

## Proven on device

Star growth and the planet handoff · zoom 0.22 → 34 · all four Universe registers on a cold
launch · the door and the story · the fall at layer four with its words reachable · the
Return's consent gate · the yantra's enclosure radius **measured** (291px at avarana III and
again at V, while `s` went 217 → 269) · the Aperture at `BAND[8]` proved by two independent
lines · the flare firing · the descent staged 700 + i·3400 with four stages offline · the
guard sending him back, its hall peaking after the reading was gone · readings II, III, IV, V,
VI walked end to end · the Return's write **and read-back**, proved by a date moving 24 → 27
→ 24 · the legend turning to **"1 story · 1 returned to"** where it had read "none twice"
across 0 of 495.

---

## Never verified — so your walk is not discovering it

1. **The sound, in full.** Built, not heard. The simulator reports no headphones, so the
   binaural path collapses by design and reverb character cannot be read from a screenshot.
   Every pitch and coefficient verifies by reading; none of it verifies by listening until
   you put it on Neev.
2. **Ash's register-2 card at sub-depth 1.** The legend derives correctly; the card behind it
   never opened for me. His figure is the documented exception with no geometry.
3. **Worlds I and VII.** Unwalkable by a scripted hand for opposite reasons — I's stars drift
   from a touch, VII's outrun it. Both are the world's own material and were not softened.
4. **The Rooms' vertical travel.** Does not respond to synthetic touches; I reached registers
   1 and 2 through a debug hook that is now removed.
5. **PlayersView's fold** — Neev, Shweta and Ash live below it, and the sim cannot scroll there.
6. **Ash's C-1052 paragraph.** Still unreachable, and correctly: the Return declines on *The
   Two Who Were One* because he has never sealed words on it. Seal, then return twice.

---

## Standing rules that emerged

- **Values verify by reading; positions verify by measuring on device.** Every coordinate in
  this build was measured, and two were wrong in ways no amount of reading would have shown.
- **A check must name the thing the feature is for, not only the mechanism.** "Does the fall
  reach layer four" passed while its words were unreachable.
- **A claim is released by every path its owner can leave by, not only the polite one.**
- **Stillness is an accumulator that decays under action — except the Light, which keeps.**
  *"This is not a test he can fail."*
- **An unwired slot, an unreachable one, an uncalled one and an empty-bodied one all render as
  absence — and only the last one lies.** `syncAxisLock` had a correct name, three call sites,
  an accurate comment and nothing inside; world II was unwalkable by any hand.
- **A lookup keyed on a field that does not promise to be singular is a bug waiting for data.**
  Codex ID, then `Linked Story` — the second worked by link order for two months.
- **Age comes from days, never from rank.** Returning to a thing cannot make it younger.
- **Reinstall before any screenshot is offered as evidence.** A clean working tree says nothing
  about what is on a device.

---

## State

Protect list: fifteen files diffed; four changed, each permitted and named — `UniRegions`
(`hz:` restored, the sanctioned add), `LightCanon` (one string trimmed *toward* canon),
`TheTurningView` (em tracking + link reads; the trace path bit-exact), `Breath` (`cycle`
added, `originSeconds` untouched). Sound's session contract and render discipline unchanged —
no allocation, no locks, no awaits added to the audio thread.

All six debug hooks and every probe removed; verified by grep and by a clean install with the
defaults wiped. Build is warning-clean. First launch reaches the Rite on live data.

Deployment is yours.
