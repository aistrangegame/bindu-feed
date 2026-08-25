# Brief for Claude Design — decisions + expansions

## Context
Bindu Feed was built in Claude Code from your design, but parts were built from the **prose** (Amendment-01, the Phase-9 handoff) rather than your **rendered** files (`The Instrument v3.html`, the comps) — so it diverged, most visibly in the Universe and (the user suspects) in how the Mirror's content/data was set up. A separate Claude Code session is producing a surface-by-surface code-vs-rendered-design **differential audit** (`AUDIT.md`). This brief is for the parts only *you* can settle: **design intent, and new design.**

## The one lesson to carry
**Rendered beats prose.** Whatever you decide, hand it back as a *rendered* artifact (a working HTML/JS comp like `The Instrument v3.html`), not a prose description — the divergence happened every time the build worked from prose. If it must be prose, make it unambiguous and mark it subordinate to a rendered comp.

## What we need from you
1. **Resolve the audit's open questions.** The `AUDIT.md` will list specific points where the code diverges and the *intended* design is ambiguous. Confirm intent for each (ideally by pointing at, or updating, a rendered comp).
2. **The Mirror + the field surfaces (data/content model).** The user feels "the way information was set up from the beginning" diverges from how you created it. Clarify the intended content model for the Mirror (and Signal / Practice Door): what each card *is*, how it's chosen, and how it should read — as a rendered comp, so the data layer can be rebuilt to match.
3. **The archetype rooms — the expansion (the user's idea).** Each archetype's "home" should be **designed by the archetype itself**: in a session, load that archetype's *field-skill*, give the archetype life, hand it the information it holds (all of its comments across the Feed), and let it decide — in its own visual language — **how its home should present that information.** Entering a room = seeing all of that archetype's comments, but rendered in a bespoke, visually rich way unique to that voice (in the spirit of how the Universe is rendered — spatial, alive, designed, not a list). Design the **framework** (what every archetype room shares) + **two or three exemplar rooms** (distinct archetypes) as rendered comps. This is a creative-generation task — a good fit for you or a creative model (Fable 5); NOT for the code audit.

## Sequencing (advise the user)
Stabilise the foundation first (the audit + the Universe/data rebuild), *then* build the archetype rooms — don't stack new generative rooms on a data model that's still being corrected.
