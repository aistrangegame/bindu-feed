# START HERE — Bindu Feed · the upgrade build

**Rev 2 · 27 Aug 2026.** This file replaces the reading order in `README.md` and `HANDOFF.md` §4.

The original bundle was written on 27 Aug **before** Pass 0 ran. Pass 0 has now run: the Airtable content model was rebuilt to canon and verified by live read-back, and four "blocking rulings" turned out not to exist. **Three files in this bundle now contain instructions that are wrong, and one of them would destroy canon if executed.** They carry banners. Read this file first.

---

## Reading order

| # | File | Why |
|---|---|---|
| 1 | **`00-PASS-0-DONE-AND-CODE-CONTRACT.md`** | What the base actually is now, and the **seven code changes** the data work implies. |
| 2 | **`00-CLAUDE-MD-PATCH.md`** | **Patch `Bindu Feed/CLAUDE.md` before writing code.** It is the file you load first and it is stale on the field surfaces. |
| 3 | `audit/AUDIT.md` §H | The prioritized rebuild list. The whole gap in ten minutes. |
| 4 | **`comps/*.html` — run them in a browser** | Not read. *Run.* Each has an *as built* toggle; the delta is meant to be felt. Most-skipped step, most information. |
| 5 | `HANDOFF.md` §1–§3 | Prime directive, the scope-note decoder, precedence. **§1 Rule 1 is the most important paragraph in the bundle.** |
| 6 | `audit/AUDIT.md` §A–§G | The per-surface differential, as you reach each subsystem. |
| 7 | `HANDOFF-BUILD-LIST.md` · `HANDOFF-VERIFICATION.md` | What is not yet designed; the behavioural acceptance checks. |
| ✗ | `HANDOFF-AIRTABLE.md` | **SUPERSEDED. Do not execute.** Banner explains. |
| ~ | `HANDOFF-RULINGS.md` | SETTLED section stands. **OPEN section is closed** — banner explains. |

---

## Precedence — one ladder

| | Source | Wins on |
|---|---|---|
| 1 | `canon/` | **Literal text and numbers.** 66 stars, 67 Light lines, 87 Rite strings, 5 DEALS, 37 REGISTERS. Non-paraphrasable. |
| 2 | `00-PASS-0-DONE-AND-CODE-CONTRACT.md` | **The live base, and every ruling that was open.** Verified by read-back; supersedes any prose about the data model. |
| 3 | The seven comps | **Mechanism, feel, geometry, interaction** for the seven areas they cover. |
| 4 | `The Instrument v3.html` | Feel, geometry, interaction everywhere else. |
| 5 | `design-source/*.js` | Single-register detail. |
| 6 | `AUDIT.md` | **Which delta exists, and its severity.** Not authoritative on what the design *is* — read the line it quotes. |
| 7 | `Bindu Feed/CLAUDE.md` | Build state and app-side decisions, **once patched**. |
| ✗ | `archive/` · Amendment-01 · Phase-9 handoff | **Nothing.** Retired prose. The original divergence came from building against these. |

**And the tiebreaker, in one line:** canon wins on words and numbers · rendered wins on behaviour · prose wins on nothing · **where the app is deliberately better and says why in writing, the app wins** (`HANDOFF.md` §7 lists fifteen such files — diff them after every pass).

---

## The two standing instructions

> **1 · Before inventing any string, grep `canon/` and the design files for the slot it would fill. If a canon string exists, port it. If none exists, render absence.**

Every invented string in the app sits exactly where a content slot was never wired: the gate with no `DEALS` invented three; the Light's `beatCue` is declared with zero call sites and got *"press · draw it in"*; the Universe with no `say()` got *"drag to fly · pinch to zoom · tap to approach"*. One rule closes ~40 findings and is nearly free.

> **2 · Diff the fifteen protect-list files after every pass.**

The audit found more that is right than wrong — 66/66 stars byte-verbatim, 87/87 Rite strings, 67/67 Light lines, the shader, `UniRegions`, `RoomStyle`, `TheTurningView`. Collateral damage is the only way this gets worse instead of better.

---

## The sequence

`HANDOFF.md` §4 order stands, minus Pass 0:

| Pass | Work | Authority |
|---|---|---|
| ~~0~~ | ~~Airtable + open rulings~~ | **DONE** — `00-PASS-0-…` |
| **1** | **The seam.** `B0.1–B0.4` · `B4.1→B2.1→B2.2` · `B6.1` · `B5.1–B5.4`. Largest unlock per diff in the project. | `The Seam.html` |
| 2 | The three sweeps — tracking helper · hex alphas · delete the instructional strings. | `The Chrome.html` |
| 3 | The four constants. `DRAG .00018 · DAMP .956 · span .42 · glideDur 5.4`. One line; every register. | `The Chrome.html` |
| 4 | The rooms — all eleven + register-2 depth. | `The Rooms v4.html` |
| 5 | The Point — readings → **the yantra** → staged descent → the DEALS → Aperture. | `The Reading.html` · `The Aperture.html` |
| 6 | The ceremonies — Return → Light. | `The Return.html` |
| 7 | The sound. Last, once, and only once. | `The Sound.html` |

**Fold the seven code changes from `00-PASS-0-…` §2 into the passes they belong to** — most are small and land naturally (the Gaia seed fetch and the sub-line render in Pass 1 or 2; met-ness in Pass 1 with the seam; the write-back in Pass 6).

Write the gameplan before the code, naming per pass: the findings it closes by audit id, the authoritative comp or design file, the `HANDOFF-VERIFICATION.md` checks that will prove it, and anything it touches on the protect list.
