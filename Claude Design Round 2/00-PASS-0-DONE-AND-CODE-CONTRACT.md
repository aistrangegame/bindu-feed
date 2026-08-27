# PASS 0 · DONE — AND THE CODE CONTRACT

**Executed against `app248ZTWhYJlvQj2` / `tbl7vzODMMJUgeX0b`, 27 Aug 2026.**
Every operation verified by a live read-back. Nothing deleted — retirement is `Status: Archived`, fully reversible.

---

## §1 · WHAT THE BASE LOOKS LIKE NOW

| Pool | Before | After | State |
|---|---|---|---|
| **Mirror Card** | 31 Live · 19 vow / 12 koan · 2 cohorts · 4 flattened · 1 paraphrase | **24 Live · 12 vow / 12 koan** | one cohort · every card carries its authored `\n` · every card carries a register |
| **Signal** | 16 Live · 12 foreign · all 4 canon stored flat | **6 Live** | the design's six, complete, all with authored breaks |
| **Practice Invitation** | 15 Live · all foreign · no sub-line possible | **8 Live** | 1 canon + 7 authored, each with a `Practice Sub-line` |
| **Gaia Seed** | did not exist — borrowed from Signals | **6 Live** | its own Type; the leak is closed at the source |
| **Threshold Sentence** | 59 Live · 4 bare titles · canon absent | **56 Live** | bare titles retired; the canon threshold added |
| **Blank-`Status` in these pools** | — | **0** | verified by query |

**The 12/12 vow-koan split was not forced.** No card was re-registered. It fell out of removing the ten rows that were labelled `Vow` because cohort A was back-filled uniformly. The design's deliberate 50/50 was there the whole time, buried under a foreign ontology.

### The retired 42 — all `Archived`, all recoverable
7 Mirror (Recognition · Surrender · NO Force · Sri Yantra Tratak · Sacred Pause · A Strange Game · Hold) · 12 Signal (incl. `Customer as Hero`, the Wazoodle positioning row) · 15 Practice Invitation · 4 bare-title Seed thresholds · **4 kept and repaired** (`Trust`, `YES Witness`, `YES Honor…` — canon reflections #1/#2/#4 that a `Category`-based retire would have destroyed — plus `The Roof Beam`, restored from paraphrase to canon).

### Repairs
- `recn5ECOiniQzlrFt` · `reccijAuVSic4EK4I` · `rec6QeSCFULO8BIQF` — authored `\n` restored from `The Mirror.html:62-73`.
- `recw4bU300qQ8KWh4` — canon wording restored: *"What would I do / if I trusted the ground / to hold?"* (was a two-line paraphrase with a different verb).
- `recp7Mj0J3PIzD482` · `recAtS4zXU8ZAH5Zl` · `rec9FA1Rk93UKHR5x` · `recRq6SCC9XzDKA0c` — all four canon Signals re-broken to `The Signal Space.html:60-67`. **They were stored flat, so even the right signals rendered with the wrong prosody.**
- `recIp8OoTmaTzaesb` — the runtime vow: `Sort Order 901`, `Category: Belief`. Runtime-written records now live in the **900 band**, so a carved Declaration can never again sort to the front and shift every index.
- `recChF5YNm7XJy7pn` (App Activity) — `Story Met` was named *"The Measuring Stick"* and linked to **The Roof Beam**. Re-linked to `recx9HOJx0ZrXMxrb`. **This was undiscovered in any document, and A4.1 moves met-ness onto exactly this source.**

### New content
**2 canon Signals** — `recIUkpf6BXZnxjqW` (*The fear is the doorway…*) and `recOD7ewDEQnLnEpn`, which finally puts **"The door was never locked — you have been holding it shut from the inside."** in the base. It appeared nowhere before.
**7 authored practices** (401–408 with 401 canon) · **6 Gaia seeds** (501–506 with 501 canon) · **the canon threshold** `receVnWTzpyV39mUW` — *"You are not late. / The field kept your place."*, absent from all 59.

### New schema
| Field | ID | Type | For |
|---|---|---|---|
| `Practice Sub-line` | `fldWcHyZDGcytIdJg` | multilineText | the Door's sub-line (`A3.1` — previously unrepresentable) |
| `Ring Index` | `fldo6gU5Q9L4XDyoX` | number(0) | the write-back. **Never used for age.** |
| `Sealed At` | `fldlg5Vmh0BbpWise` | date(iso) | the write-back. `days` computed at read time. |

New `Type` option **`Gaia Seed`**. New `Sentence Source` option **`Field`**. Both inert to existing readers, which all filter on a specific value.

### Sort bands, now a rule
`1–99` legacy · `201–220` Mirror canon · `301–306` Signal canon · `401–408` Practices · `501–506` Gaia Seeds · `601` Threshold canon · **`900+` runtime-written, always.**

---

## §2 · THE CODE CONTRACT — seven changes the data work implies

Data-side is done. These seven are the code half; without them some of the above is invisible.

**1 · Gaia seeds get their own fetch.**
`FeedStore.swift:357` — `case .gaiaSeed: signals.randomElement()`. The seed pool is now `Type='Gaia Seed'`. Add `fetchGaiaSeeds()` alongside `fetchSignals()`, a `GaiaSeed` model (same shape as `Signal`), and point `.gaiaSeed` at it. Also `hasContent(for:)` at `:349`. **Until this lands, the Gaia seed still draws from the Signal pool — now only 6 canon signals, so it is no longer harmful, but it is still the wrong door.**

**2 · Render the practice sub-line.**
`Models.swift:306-321` `PracticeInvitation` gains `subLine: String?` from `Practice Sub-line`. `PracticeDoorView` renders it under the body per `Practice Door.html:155-159`. Blank → render nothing. Never a substitute.

**3 · Thresholds prefer `Body` when present.**
`Name` is `singleLineText` and silently strips `\n` — I hit this writing the canon threshold. `ThresholdSentence` (`Models.swift:242-256`) reads `name`. Make it `f.body ?? f.name`, matching the defensive read already used by `Signal`/`MirrorCard`/`PracticeInvitation`. Both fields are populated on `receVnWTzpyV39mUW`.

**4 · Delete the sentence splitter.**
`SignalView.swift:278-302` `splitIntoLines` honours `\n` then falls back to deriving breaks. Every Signal now carries authored breaks. **Delete the fallback rather than keeping it** — kept, it runs forever and silently.

**5 · `writeVow` — Sort Order and the Ash identity.**
`AirtableService.swift:447-459` must set `Sort Order` in the **900 band** (`900 + count of existing 900-band vows`, or a timestamp-derived integer). And `:457` hardcodes `"Archetype": "Ash"` — the one surviving instance of the defect `CLAUDE.md §10` says not to re-introduce. Resolve it the way `postComment` does.

**6 · Met-ness moves to `Story Met`.**
`UniverseView.swift:284-286` — replace `commentCount > 0 || resonance > 0` with a per-story `Story Met` lookup. `AirtableService.isTodayMet()` (`:544-589`) already reads the right table and `Link to Feed` is now correct. **Expect two lit stars.** That is §8.6 working, not a bug.

**7 · The write-back writes a date, never a day count.**
On sealing a ring: `Type='Return'`, `Linked Story`, `Sealed At = today`, `Ring Index`, `Body = the words`, **`Status: "Live"`**. An answer: `Type='Return Answer'`, `Archetype`, `Parent Comment` → the ring, `Linked Story`, `Comment Body` with authored `\n`, `Status: "Live"`. `days = today − Sealed At`, computed at read time. `age(days) = clamp((days/1095)^0.55)`. **Never derive age from `Ring Index`.**

---

## §3 · THREE HANDOFF ITEMS THAT DID NOT SURVIVE A LIVE READ

Recorded so the next session does not act on them.

- **"Neev's words — approve, replace, or leave honestly empty"** (`HANDOFF-RULINGS.md`, listed as needing a ruling). Neev has an `Archetype Role` (*"Foundation · what you stand on"*), an `Operating Principle`, and **29 Live field comments**. His room has content. Claude Design authored substitutes because it could not see the base. **Use the base; discard the authored lines.**
- **"Ashram or Ash — blocking the eleven rooms."** `CLAUDE.md §7` already documents the rename-safe split: *"Renaming is safe and fully propagated"*, and *"Ashram… is not in the data and not in the code."* Verified — the only occurrence is a Swift type name. **Nothing blocks the rooms.** The only real item is `writeVow` (change 5 above).
- **"The Aperture's 37 origins need checking."** All 37 registers are already in `ApertureView.swift:107-127`, byte-identical to `canon/point-content.js:429-449` and to the base — **and each string already contains its origin** (*"Qalb — the heart-organ of the Sufi Lataif"*). The authored `origin` field is redundant. **Drop it. Nothing to fact-check.**

---

## §4 · READY

**Pass 0 is complete.** The foundation the audit said everything downstream inherits is now clean, and it is the thing that gated the code.

Claude Code can start on **Pass 1 — the seam**, in the audit's own H6 order: the seam → the three sweeps → the four constants → the rooms → the Point → the ceremonies → the sound, last and once.

Two instructions to carry in:

> **Before inventing any string, grep `canon/` and the design files for the slot it would fill. If a canon string exists, port it. If none exists, render absence.**

> **Diff the fifteen files on the `HANDOFF.md §7` protect list after every pass.** The audit found more that is right than wrong; collateral damage is the only way this gets worse.

And the precedence, in one line: **canon wins on words and numbers · rendered wins on behaviour · prose wins on nothing · where the app is deliberately better and says why in writing, the app wins.**
