# The Deferred & Fix Build — Plan

Assembled from six independent adversarial comp-audits + the codebase's self-declared deferrals + the two design-led features (the Audio Anchor, the Return's real fall). **Nothing here is built yet.** This is for Ashrey to review and add pieces to before a single planned build.

The recurring failure the whole sweep confirmed: **a distinct designed thing quietly collapsed into a generic stand-in** — thirteen bespoke typographies → three buckets, five distinct dawns → one radial, a per-phase mote field → a lockstep mechanism, glyph-presences → plain dots. The fixes below restore the distinct thing. No new deferrals.

Severity legend: **[C]** critical (collapse or missing system) · **[H]** high · **[M]** major · **[m]** minor. Source in parens.

---

## PART I — Two net-new, design-led features

### A. The Audio Anchor — hear your own voice across time
The write path exists (Movement IV filename → Airtable `Audio Reference`). **Playback is net-new.** Four load-bearing laws (memory: `project-bindu-feed-audio-anchor`):
1. **Raw, always** — no noise-reduction / normalize / trim / silence-removal / "best take" anywhere. Store + play exactly as spoken.
2. **Crossed-into, not always-on** — reached mainly through the **Return** (the descent grants the voice); a quiet, non-ambient affordance may sit on the story, never a loud play button.
3. **No player chrome** — no scrubber, timeline, duration/countdown, speed, or seek. Play and let it play; the Bindu ember may pulse while it plays, stillness when it ends.
4. **Hold the silence after** — on finish: no snap-back, no autoplay, no immediate replay; a held quiet beat (field breathing, ember settling) before anything returns.
- Grace notes (if cheap): play **over the aged palette** in the Return's Record movement (young voice over visibly-aged self); let transcript and audio **disagree** — no caption/sync/follow-along.
- Engineering: audio is device-local (Airtable holds only the filename). Playback = filename → local file (`RiteRecorder.recordingsDirectory()`) → `AVAudioPlayer`. Absent file = affordance simply absent, no broken player. **New surface** in ReturnView (primary) + a quiet StoryDetail affordance. No cloud hosting.

### B. The Return's real fall — the four-layer descent [C] (Light/Return audit; spec in hand)
Replace the stopgap zoom (`ReturnView.swift:106–122`) with the four-layer descent (`uni-fall.js`), reusing the verified `UniverseView.drawFall` port. Layers: **3·strata** (his own rings, aged, driven by `returnCount`), **1·approach** (the sun; halo = Resonance Voice), **2·gathering** (the company settles orbit→seats, drawn as **glyph-presences + names** — not dots, from `storyData.record`), **4·mouth** (the Return opening). `d` time-driven from a `fallStart` stamp over 5.5s; cross to `.room` at `d≥0.9`; keep the bowl strike; captions per layer. Prereq: add `roomRGB:[Double]` to `ReturnStoryData` (populate in `buildReturnData`). Full geometry spec captured — straight lift of `drawFall` with `story.*`→`storyData.*`, `depth`→`returnCount`, `store.stats`→`storyData.record` (+ glyph/name).

---

## PART II — Critical collapses to restore (bespoke → generic)

### The Light (Light/Return audit)
- **[C] Five dawn scenes collapsed to one generic radial + starfield.** Port `spine-light.js draw()` per-`scene.key` arrivals: `converge` (40 motes drifting edges→one field), `warmth` (heat bloom rising from H·0.86), `kindness` (light from behind onto 9 rows/rooms of what he built), `release` (3 rings brightening one-per-ungrip — `ungrips` currently drives nothing), `morning` (dawn thinning toward him as he stills). A `Canvas` keyed on `scene.key`/`ungrips`/breath.
- **[C] Words are light-on-dark, but the nave floods to lit stone.** Restore comp's dark-ink-cut-into-lit-floor: `--living #16131B` / `--settled #625849`, `.carved` dark ink + white top-shadow deboss; switch text INK/LGT on the nave's `lit`; only the **newest anchor** is "living," the rest settle.
- **[H] LightNave omits the conducting Bindu** at the shaft apex (195,150) — "the Bindu conducts and never stops." Draw it inside the nave (halo/ring/core on breath, softens on touch).
- **[H] LightNave omits the flood** — the aperture *opening*, light pouring DOWN (transient top-down burst peaking ~1.26s), separate from the persistent `lit` stone resolve.
- **[H] No visible breath cue** — the door is "a breathing exercise where words happen to appear." Render the `draw it in / hold / let it go` cue bound to `breath.phase` (CYCLE in .40/hold .15/out .40/rest .05); the beat cue already exists.
- **[H] Worn/descending rings decoupled from breath.** Release one descending ring per **exhale-edge**, land it into an accumulating `worn` set (up to 14 — "every breath taken here," never a number). Currently `3 + still*8`, faked.

### The Universe (Universe/Point/Axis audit)
- **[C] LANES missing entirely** — the travellers: local lanes between met worlds (`hash<0.45`) + 9 long-haul inter-region lanes, bowed béziers with 5-dot comet trails. Port `uni-rooms.js:312–327` + `uni-sky.js:255–279`, gate on scale.
- **[C] Fall's seated company collapsed to plain 3px dots.** Draw each attendant as their **archetype glyph** (Lora) in their color + name below, `seat()` hand-fan so none share a line, Ash seated closest, word-hint where the Archive holds one. (Also fixes `drawFall` itself, which omits glyph/name.)
- **[C] Company motes orbit in rigid lockstep** — violates the explicit anti-mechanism law. Give each mote its own `per=3+hash·23` + phase; Lalita always threads + her orbit wobbles; Ash gets a mote when `cmts>spoke+1`; add far-zoom shimmer + behind/in-front z-order.
- **[M] Deep-sky has no thickness** — no bg gradient, no 3-depth parallax dust (58/38/38). "Is anything still a flat starfield?" → there's no starfield at all. Port `uni-sky.js:170–184`.
- **[M] Aperture drops its designed content** — the 40-item `REGISTERS` list (Qalb, Coire Sois, the tenth ox-herding picture…) + avoid-list + per-session dedupe, replaced by a generic prompt. Port `point-content.js:421–441`. (Model id `claude-opus-5` is VALID — disregard the auditor's guess.)

### Game View (Feed/Rooms/Game/Story audit)
- **[C] Thirteen bespoke hero name typographies collapsed to three buckets at a wrong uniform 28pt** (comp 22–24, per-room weight/italic/tracking). Fix: carry per-room name-style as a **client-side style table** (like the authored stats already are) — not an Airtable field.
- **[M] One `Glyph Size` field can't hold the comp's two scales** (portal 34–52 vs hero 44–78, non-constant ratio); the `max(44)/max(52)` floors flatten the drama. Fix: two sizes in the client-side style table; drop the floors.
- **[M] "The Watcher" not uppercased** in hero/portal, and the portal switches it to Space Mono where the comp keeps Lora. Fix both; keep Lora.

### The Turning + Players (Players/Turning/… audit)
- **[C] Per-presence breath cadences collapsed to one shared 4.5s fade.** Restore each: Lalita `lTurn 30s`, Neev/Shweta `breathSlow 18s`, Ash `pulse 2.8s` heartbeat, Bindu `ember 3.2s`, per-lens 6.8–13.5s. Add `glyphBreathSlow`/`glyphPulse` cases + a per-archetype duration param.
- **[C] `glyphBreathe`/`glyphEmber` dropped their scale-swell** (opacity-only). Add the paired `scaleEffect` (breathe ~1.06, ember ~1.10) so glyphs *breathe*, not just dim.
- **[C] The Turning's completion scroll-to-the-words is omitted** — the ritual's payoff. Add `ScrollViewReader` → `scrollTo(words)` ~0.7s after `done`.

---

## PART III — Self-declared deferrals to close (no more "Wave 6/later")

- **Rite plays the CANON story, not today's live feed story** (`RiteView.swift:8`). Wire the Rite to meet the live story of the day with its real field-comment voices as the Gathering (the "larger dynamic system" it defers). — *large; confirm scope.*
- **Point per-star descent is a stub** — re-paginates canon (`PointWorldView.swift:95`). Add a live per-star generation mirroring ApertureView (comp `descend` prompt + fallback).
- **Door axis-depth rows / "walk the point" are absorbed/redirected** (`DoorView.swift:213,223`) — now that the Point + axis exist, wire them to actually navigate.
- **Recognition has no speech-to-text** (`RiteRecognitionView.swift:12`) — you type it. *Decision: keep type-it (design-honest), or add STT?* — recommend keep; the audio IS the voice, the transcript is yours to shape.
- **Settings mood quality-subtitles need authored copy** — *Ashrey's to write, not Claude's to invent.* (Slot for your pieces.)
- **RiteBudget:** "what a recognition touches" undefined (`RiteBudget.swift:19`); passing/silent queue not depth-rotated + no break (dormant at depth 0 but wrong on returns).
- **CommentCard placeholder branch** when archetype lookup fails (`CommentCard.swift:126`).
- **AirtableService Ash-as-parent reply hint** deferred (`:313`).
- **Point descent write-back is session-only** (not persisted) — persist it.

---

## PART IV — Major/Minor fidelity fixes (batched by surface)

**Signal:** [M] pass `rise:8` (lines lost their upward lift → plain fade); [m] body 20→23pt; [check] line-breaks depend on Airtable `\n` — verify Live Signal bodies carry authored breaks (else the regex splitter is a stopgap).

**Ash's Voice:** [M] entry card → accent tint (`terra .06–.08` + border `.14`), drop the borrowed left-bar; [M] story title → accent color + `↗` prefix; [m] header avatar → white-highlight radial sphere (Settings already has the idiom); [m] reply → parent quote block (not one-line name); [m] stats/label entrance dissolves; "ENTRIES" → "ENTRIES / LEFT".

**Ash's Compose:** [m] idle `arrivalBreath 12s` glow; [m] text brightness `+progress·0.16` while holding.

**The Turning:** [m] Ash's bespoke stat labels ("codex entries / total resonance / in the field since"); Lalita rotation 42→30s; ember 2.8→3.2s.

**Story Detail:** [m] comment/reply roles → title-case (not `.uppercased()`); [m] reply indent to comp (~42pt spine); [m] restore "A STRANGE FEED" wordmark; [m] "just now" lowercase; [m] "live pulse" currently a 7-day recency guess vs the authored `pulse:true` flag.

**Room Selection:** [m] flood → comp motion (overlay to 0.92 opacity, glyph 1→11) — *or keep the richer anchored-expansion? decide*; [m] TurnCard label inline + colored in surface color; [m] the extra `◉` before "THIRTEEN ROOMS" isn't in the comp.

**The Rite / Gathering:** [M] neev — restore the two dropped background gradients incl. the **breathing dome-glow** (`dg`); [M] arch — antinodes back to fixed rose-white `[255,224,236]` with the `0.14` glow-floor (not voice-color, not vanishing at amp 0); [m] neev/arch/karishma — alpha should use raw `p` not eased `e`; [m] universal ambient wash behind every scene (`rgba(c,0.06·dim)`); [m] **Sealing stacks all three phases** (`phase>=n`) — comp *replaces* (`phase==n`); [m] voice tone re-sounds on >7s dwell; [m] budget queue depth-rotation + break; [m] passing voices shouldn't show a close glyph; [m] Reading "field gathers" button → Lalita violet + sticky header; [m] recognition timer `0:05` not `00:05`.

**The Return:** [H] **ReturnStrata depth/age hardcoded** `rings:3, age:0.5` → pass `returnCount` + real age, and add the sealed ring to the persistent strata (not just the inline canvas); [M] craquelure (age-cracks on old rings); [M] crossing pulse on seal (a wave through the strata); [m] Record shows only each voice's first line → full utterance; [m] `AnewVoice` dropped glyph/color/role → restore avatar/color; [m] "Add the ring." trailing period.

**The Instrument:** [M] drift streaks + vignette while moving (no sense of motion through space); [M] membrane beading/wobble + break-ring/shards on give (currently a plain stroked circle); [M] update the **stale "still ahead" header** (`InstrumentView.swift:12`) that wrongly lists the built worlds as unbuilt; [m] throat "≈ full three-act draw".

**Universe (minor):** [m] region weather → proximity-blend all nearby fields (not one at fixed 0.5); [m] nebula brightness → tie to lit-star count; [m] Reveal three-split labels (knowledge/will/action) + rope narration line; [m] WorldTurn "draws inward" is just an open.

---

## PART V — Data-model changes required

- **Client-side per-room style table** (new, in code): Game View hero name-style (size/weight/italic/tracking ×13) + dual glyph sizes (portal + hero). These are **design constants, not live data** — no Airtable churn.
- **`ReturnStoryData.roomRGB: [Double]`** (+ optionally `resonance`) — for the fall.
- **No new Airtable fields anticipated.** The `Audio Reference` field already exists; playback is local. (Confirm.)

---

## PART VI — Deliberate divergences to CONFIRM (keep or revert — your call)

1. **The Field (13th room) full-width band** vs comp's centered half-tile — currently a documented app decision (CLAUDE.md §5). Keep?
2. **One-scene-per-day Light** (date-hash) vs the comp's six-lights chooser — keep (Mirror-like)?
3. **Tap-to-approach discrete Universe scales** (4 registers) vs the comp's continuous `z`/`bands(z)` "nothing snaps" camera — keep discrete, or build the continuous descent?
4. **Room Selection anchored flood** (richer) vs comp's 0.92 + glyph-1→11 — keep ours?
5. **Per-presence Hz from the field-sound table** (not the prototype's values) — keep (already reconciled)?
6. **Identity split** (arrival name/glyph/color vs canonical "Ash") — keep (documented §7)?

---

## PART VII — Verification-only (no build; note for the Neev walk)

- `claude-opus-5` model id is valid — the aperture call is fine.
- Signal line-breaks: confirm Live Signal `Body` records carry authored `\n`.
- Several Rite items are "dormant at depth 0" (budget rotation, passing-close-glyph) — correct today, matters on returns.
- The whole felt layer (audio timbres, the blink, the carve's breath, binaural) remains device-verified on Neev.

---

## Open slots for your additions
- The Audio Anchor surfaces (Return-primary + quiet story affordance) — confirm.
- The six "confirm keep-or-revert" divergences in Part VI.
- Settings mood quality-subtitles — your authored copy.
- Any new ideas/pieces you want folded into the single build.
