# canon/ — the extracted sources of truth

These files were **extracted verbatim** from the design bundle so the repo has stable,
non-paraphrasable canon to build against. They are reference/spec, not compiled into the app.
Ruling 4 (RULINGS & RESOLUTIONS, Aug 21 2026): "extraction is lossless copying, not authoring."

| file | what it is | extracted from | note |
|---|---|---|---|
| `spine-light.js` | The Light register (Z=−5) — the six scenes' wording (morning · converge · warmth · kindness · release · floor). | `Claude Design Round 1/The Instrument v3.html`, lines **3895–4141** | Canon wording. Do not paraphrase. |
| `spine-sound.js` | The travel register — the nine new sound calls: `travel, trail, strain, give, rush, gate, carry, thin, ungrip` (plus the `B.axis` override that trails the register just left). | `Claude Design Round 1/The Instrument v3.html`, lines **4142–4308** | The travel/stillness sound layer, which was only ever inlined in the HTML — **not** in the standalone `field-sound.js`. The base voices (bed/bowl/threshold/ring/ink/nave) still live in `field-sound.js`. Port numbers verbatim to Swift `Sound/`. |
| `point-content.js` | The Point — 66 stars, 7 dimensions, 22 universes. | `Claude Design Round 1/comps/point-content.js` (verbatim copy) | The handoff called this `the-point-content.json`; the authored artifact is a JS object literal, so it is preserved as JS rather than lossily converted. **66 stars — matches the live base exactly.** |

**Provenance / rulings behind these:**
- Hz table canon is `field-sound.js` / Brief §12 (Ruling 1) — the live base's `Field Sound · The Breath` = 110 Hz confirms it.
- Sound port = `field-sound.js` base voices **+** the nine travel calls here; count is **9** (Ruling 3).
- Point renders the 66 that exist; `WalkableHierarchy` scales if more are authored later (Ruling 5).

If any of these three source blocks is re-cut, update the line ranges above.
