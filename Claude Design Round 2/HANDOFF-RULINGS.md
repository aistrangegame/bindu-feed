> # ⚠️ THE "OPEN" SECTION IS CLOSED — read `00-PASS-0-DONE-AND-CODE-CONTRACT.md` first
>
> The **SETTLED** rulings below stand and are good. The **OPEN — do not guess** section is resolved.
> Four of its six items did not survive a live read of the base and the repo:
>
> | Listed as open | Reality |
> |---|---|
> | **Ashram or Ash** — *"blocking the eleven rooms"* | Already solved and documented at `Bindu Feed/CLAUDE.md §7`: *"Renaming is safe and fully propagated"*, and *"Ashram… is not in the data and not in the code."* Verified — the only occurrence is a Swift type name. **Nothing blocks the rooms.** One real item: `writeVow` (`AirtableService.swift:457`) still hardcodes `"Archetype": "Ash"`. |
> | **Neev's words** — *"no `Player Detail` entry at all"* | False. Neev has an `Archetype Role`, an `Operating Principle`, and **29 Live field comments**. **Use the base; discard the authored substitutes.** |
> | **The Aperture's 37 origins** — *"factual claims… every one needs checking"* | All 37 registers are already in `ApertureView.swift:107-127`, byte-identical to `canon/point-content.js:429-449`, and **each string already contains its origin** (*"Qalb — the heart-organ of the Sufi Lataif"*). The authored `origin` field is redundant. **Drop it.** |
> | **The breath curve** — Tier 0 #9 | Already ruled and built. `Breath.swift:27-34` documents the contract: one phase, one origin, raised cosine for visuals, ±12% sine for audio, *"no voice invents a third curve."* Verified at `InstrumentView.swift:321`. **Do not re-phase.** |
>
> The remaining two are **ruled**: the **37 adjacency claims** — complete the mapping against the full 66.
> The **Audio Anchor** — it survives the device (upload to an attachment field; play local-first, fall
> back to remote; the four laws untouched). If deferred, the row must stop claiming an anchor it cannot play.
>
> The **66 stars' home** is settled by the line: **Airtable holds what accumulates; `canon/` holds what
> was authored once.** The Point is canon — frozen, `canon/point-content.js` is the home, the Swift
> literal is a verified copy, the base's Point records are staging and are not read.

---

# HANDOFF · RULINGS

Settled here with reasoning, so they are not re-litigated mid-build. Open ones must not be guessed.

---

## SETTLED — build to these

### Tier 0 #6 · The Rite's Hz table disagrees with itself

**Both, on different axes. They were never rivals: one is a pitch set, the other a voice set, and the build collapsed both.**

- **Pitch** — the Rite / `The Instrument v3.html` table (`The Rite v3.html:1192-1213`). It draws every voice from the ladder the instrument already climbs: `gaia 174 · sakshi 285 · lalita 396 · karishma 528` are rungs of `FREQS`; `bindu 136` is OM. One tuning system for the whole app.
- **Timbre** — `field-sound.js:13-25`'s `CHAR`. The only per-presence timbre spec that exists anywhere, and it must be kept value-for-value: Neev's `partials [0.5,1]` and `4.4s` attack, Shweta at `gain 0.012` with a band of `air`, Arch's `vib 4.6`, Bindu's `flicker 6.2`, Karishma's `shimmer`, Lalita's `gliss 1.02`, eleven distinct pan positions from `−0.4` to `+0.4`.

A/B it in `The Sound.html` on the Rite — the *collapsed (as built)* toggle makes the cost audible.

### Tier 0 #7 · The bed is two different instruments

**Both — they are different rooms.**

- **Field surfaces** get *root + fifth* with the 900 Hz lowpass and the convolution bus. A room you are standing in; it tells you the size and warmth of where you are. `field-sound.js:53-70`.
- **The Point** gets the *binaural pair* with `BEATS`. A state you are being moved into. `point-sound.js:42-58`.
- **`BEATS` belongs to the Point alone**, because the Point is the only surface that climbs. `8 → 4 Hz` only means something on a ladder.

### Tier 0 #1–2 · The foreign cohort; the unit of content

**Retire the foreign cohort. The unit is always an ordered array of display lines.**

Store prose with authored `\n` — `splitIntoLines` already honours it. **Never re-derive breaks with a sentence splitter.** Ashrey's ruling this session.

### Tier 0 #4 · Does a carry / carve deepen permanently?

**Yes.** `The Return.html` renders the mechanism: a return writes back, voices answer the return, and the answers are what fill register 2.

See `HANDOFF.md` §6 for the design rule this amends, and note that `walk-continuity.js:44-46` already permits it — *"never rendered as a count — a ceremony may colour itself by it, nothing more."*

### Tier 0 #10 · One breath clock or many?

**Many.** Keep the 10s master for *breathing*; restore the short cadences (3.4 / 3.6 / 4.8 / 6 / 14 / 26s) for *prompts*. Prompts breathing at the body's rate is why the app feels like it is waiting rather than asking.

### Tier 0 #12 · The Aperture is dead without a key

**Not a product decision — an unfinished design.**

`The Aperture.html` is whole with no key. The insight: *the model was never supplying the unpredictability.* The Aperture promises a register drawn from traditions this library has never walked, and something you cannot predict — a random draw from 37 unwalked registers **is** both. The honest fourth line (*"this library has nothing beside it"*) is better than a generated paragraph. The key enhances a complete surface.

### D5.1 · Is there a generic star reading?

**No.** Not anywhere, not as a fallback, not for V or VI (which are authored — see build-list §4). The gesture **is** the reading.

### D6.6 · The non-repetition guard

**Both guards are needed and the audit is too harsh.** The register pool must be drawn without repeats — the only guard that can work with no key. `seen` (last six returned lines) applies additionally when live.

---

## OPEN — do not guess · for Ashrey / Claude Chat

### Ashram or Ash? — **blocking the rooms**

| Source | Name | Hex | Glyph | Role | Hz |
|---|---|---|---|---|---|
| `Player Detail - The Turning.html` | **Ashram** | `#C47A52` | `◉` | Physical Synthesis · the one who lives it | — |
| `The Instrument v3.html:415` | **Ash** | `#C0603C` | `●` | He answered | 198 |

Same person, two names, two hexes, two glyphs, two roles. `The Rooms v4.html` uses Ashram's as the fuller record and flags it on the card. **Without a ruling the eleventh voice ships twice.** Entangled with **Tier 0 #8** — the inverted default arrival identity, where code ships Lalita violet + `·` and both comps that define a default say terra + `◉` + "Ash".

### Neev's words

Neev is in `VOICES` and has a figure, but **no `Player Detail` entry at all** — no principle, no stats, no comments. His greeting and both comments in `The Rooms v4.html` are authored by me and marked `authored · for approval` on every cite; his stats read `—` rather than inventing numbers. **Approve, replace, or leave him honestly empty.**

### The breath curve — Tier 0 #9

`(1−cos)/2` vs `(sin+1)/2` — 90° apart. Documented as a settled Pass-0 ruling, but **every `uBr` term in the shader was authored against the other curve**, so re-phasing is not a local change. Do not change unilaterally.

### The 66 Point stars' home — Tier 0 #5

They live in three places: `canon/`, the live base, and a Swift literal, with no reconciliation path.

**My recommendation: authored and frozen, one source.** The Point is canon, not content; a base that can drift is the wrong home for it. Counter-argument in the audit: 66 long-form stars is a content system in a way six scenes is not. Ashrey's call.

### The Aperture's 37 origins

The design's `origin` slot was the model's job. In the standard state it must be local, so I authored *tradition and where it lives* for all 37 to the design's own 5–10 word spec. **These are factual claims about living traditions and every one needs checking.** Marked `authored · for approval` on the card itself.

### The 37 adjacency claims

I claim a nearest-walked-star only for the ten stars I read verbatim in `point-content.js`; everywhere else the card says *"nothing beside it"* — honest about my reading, not necessarily about the 66. Someone with the full star list should complete the mapping. The mechanism is right; the data is deliberately under-claimed.

### The Audio Anchor — Tier 0 #11

`Audio Reference` stores a filename, so reinstall silently loses every kept voice while the Airtable row still claims one. **Should a kept voice survive a device?**

---

## PROVENANCE — four states

Every string and number in this package is in exactly one. Treat them differently.

| State | Means | What to do |
|---|---|---|
| **canon** | Verbatim from a design file, cited by line. | Port exactly. Non-paraphrasable. Includes: every constant in every comp's notes panel; the five stars' `say/walk/hand/open`; the eleven `CHAR` timbres; the 37 `REGISTERS`; all `Player Detail` comments; every `rite-scenes.js` figure; the Return's age and strata arithmetic. |
| **authored** | Written by me in voice, filling a slot the design left empty. Marked *authored · for approval* in the artifact. | **Do not ship unread.** The Rooms' register-3 lines and all greetings; Neev's entire room; the Return's answering comments; the Aperture's 37 origins and adjacency map. |
| **reconstructed** | Built from the audit's *description* of a design function I could not read in full. | Read the real source; keep my mechanism. One item: `thin()`'s envelope in `The Sound.html`. |
| **approximate** | Schematic placeholder, flagged in code as such. | Replace before shipping. Two items: World I's two Laboratories (read `world-one.js`), and the Seam's star placement (use `UniRegions`'s armatures). |

> The audit's own headline, worth repeating: *"Every authored data table that was ported, was ported perfectly… What was lost is mechanism."* **Nothing needs re-deriving.** Every number the design specifies is still sitting in the design files.
