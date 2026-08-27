# PATCH `Bindu Feed/CLAUDE.md` — do this before Pass 1

`CLAUDE.md` is the file Claude Code loads first and trusts most, and it is now **wrong in three places**. Patch it before writing any code, or the build will be reasoning from a stale content model — which is how this went wrong the first time.

---

## 1 · §6 — the Type table says 10 Types. There are now 11.

Add this row to the table (after `Practice Invitation`):

```
| Gaia Seed | (created 2026-08-27 via typecast) | `fetchGaiaSeeds` — TO BUILD |
```

And change the `Archetype` row's reader note to keep it accurate: 11 rows (8 lenses + Neev + Shweta + Ash) — unchanged, just confirming.

---

## 2 · §8 — the Practice Door table is the important one

**REPLACE this row:**

```
| Gaia seed | 20 | `Type=Signal` (reused — the 16 transmissions ARE the field's second-person voice) |
```

**WITH:**

```
| Gaia seed | 20 | `Type=Gaia Seed` (6 Live, authored 2026-08-27 — its own pool, NOT Signals) |
```

That line called the reuse *deliberate*. It was the leak: 12 of 16 Signals were Codex/business-ontology rows, so roughly **one app open in seven** presented a ~300-character brand-strategy paragraph as the threshold to cross. The Signal pool is now the design's six; the Gaia seed has its own Type.

**REPLACE this row:**

```
| practice invitation | 23 | `Type=Practice Invitation` |
```

**WITH:**

```
| practice invitation | 23 | `Type=Practice Invitation` (8 Live) — renders `Body` + `Practice Sub-line` (`fldWcHyZDGcytIdJg`). Blank sub-line → render nothing, never a substitute. |
```

**In the Mirror paragraph, append:**

> Pool is 24 Live, **12 vow / 12 koan**, one cohort, every card carrying authored `\n`. The foreign ASG Value/Mantra/Practice/Game/Tree-of-Life cohort was retired to `Archived` on 2026-08-27. `ReflectionCard` honours `\n` but cannot invent it — **the break is the form on this surface.**

**In the Signal Space paragraph, replace the phases sentence's splitter clause.** Currently it says lines resolve *"via a sentence + em-dash splitter."* All six Signals now carry authored `\n`. The splitter's derived path must be **deleted, not kept as a fallback** — kept, it runs forever and silently, and it can never produce breaks that fall *inside* sentences, which is what the design authored.

---

## 3 · §10 — add four load-bearing decisions

```
- **Airtable holds what accumulates; `canon/` holds what was authored once.** Stories, comments,
  resonance, App Activity, the field surfaces and the Return write-back live in the base. The 66
  stars, the 67 Light lines, the 87 Rite strings, the 5 DEALS and the 37 REGISTERS live in `canon/`,
  ship as a verified Swift copy, and are **never read from the base**. The base's 138 Point records
  are the staging area they were authored in. This line did not exist before 2026-08-27 and its
  absence is why the Point appeared to live in three places.
- **Sort bands are a contract.** 201–220 Mirror · 301–306 Signal · 401–408 Practice · 501–506 Gaia
  Seed · 601 Threshold canon · **900+ runtime-written, always.** `writeVow` MUST write in the 900
  band, or every carved Declaration sorts to the front and shifts the day-hash for every past and
  future day.
- **Age comes from days, never from rank.** `Sealed At` (`fldlg5Vmh0BbpWise`) stores the date;
  `days = today − Sealed At` is computed **at read time**. `Ring Index` (`fldo6gU5Q9L4XDyoX`) is
  position only and must never derive age. A stored `days` integer is stale the next morning.
- **An unwired slot renders absence, never an invention.** Every invented string in the app sits
  exactly where a content slot was never wired — the gate with no DEALS, the Light's declared-but-
  uncalled `beatCue`, the Universe with no `say()`. Before writing any string, grep `canon/` and the
  design files for the slot it would fill.
```

---

## 4 · §7 — one line to add (it is otherwise correct and was vindicated)

§7's rename-safe split is right and was confirmed against the live base. Add only:

> **One exception remains:** `AirtableService.writeVow` (`:457`) still hardcodes `"Archetype": "Ash"` — the last surviving instance of the defect §10 says not to re-introduce. Resolve it the way `postComment` does.

---

## 5 · §11 — three known-deferred items can be struck

- **Signal line-breaks** ("verify Live Signal bodies carry authored breaks") — **done**, all six verified.
- **Point descent write-back is session-only** — schema now exists (`Type='Return'` / `'Return Answer'`, `Ring Index`, `Sealed At`); it is a build item, not a data gap.
- **Settings mood quality-subtitles need authored copy** — the eight `{color, name, quality}` triples are already verbatim in `SettingsView.swift:395-405` per audit F10.5. Nothing to author.
