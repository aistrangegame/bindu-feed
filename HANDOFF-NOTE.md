# HANDOFF NOTE

Branch `upgrade-pass-a-to-c`. The build closes here. This note is the honest account:
what has never been verified, what is a measured limit rather than a defect, and the one
thing the build cannot fix.

Read the six-entry list first. Everything else is supporting detail.

---

## The honest list — six entries, the sound first

### 1 · The sound is the only part of this build nobody has heard

Every sound value verifies by reading, and all of them are right: `BEATS = [8, 7.5, 7,
6.5, 6, 5.5, 5, 4.5, 4.2, 4]` narrowing alpha into theta across the Point's registers;
eleven distinct `CHAR` timbres wired through `BreathVoice` and `ThresholdTone`, including
the five optional bodies (bindu's `flicker 6.2`, arch's `vib 4.6`, shweta's `air 0.028`,
karishma's shimmer, lalita's `gliss 1.02`); two beds, the field's room and the Point's
binaural pair; the Light's eight events; the 0.075 event ceiling; `prefers-reduced-motion`
suppressing events while leaving the bed.

**None of it has been heard by anyone.** The simulator reports no headphones, so the
binaural pair collapses to mono *by construction* — the beat that is the entire argument
for the Point's ladder cannot exist there. Reverb, crossfades and the 0.5s mute fade
cannot be read off a screenshot. This is not a gap in diligence; it is the one class of
thing the harness cannot observe, and per the verification file's own rule that is itself
the finding.

Ashrey's first hearing is the first hearing. Expect to tune levels.

### 2 · Karishma's coil is a measured named limit, not a defect

Her 48 marks ride the golden spiral, and `MAPGEO.karishma` steps the angle linearly
against an exponential radius. Marks therefore crowd toward the core by construction —
around 4.3pt between centres at the tightest, against a 44pt touch minimum. No spacing fix
exists that keeps the figure: the figure *is* the crowding.

What was built instead: the two-stage tap. The first tap arms the nearest mark and names
its story in the caption; the second descends. That makes the outer turns reliably
aimable, which is where you aim. The inner turns stay a place you can look at and not
open. Sub-depth 2 was reached in her room. Called a limit, not fixed, deliberately.

This is the fourth instance of the comp's fixed geometry meeting an archive larger than it
was drawn for.

### 3 · Worlds I and VII have never been walked by a scripted hand

For opposite reasons, and both are those worlds working. I's stars drift away from a tap
coordinate that is already stale by the time it lands; VII scatters faster than a
screenshot round trip. The Light's choosing hit the same wall and was only cleared by
tapping one point twice in immediate succession. A human hand does not have this problem —
it taps what it sees. But it means these two have been read, not walked.

### 4 · The fall's layer four is verified by reading, not by behaviour

The four names — *the story, close · who sat with it · what you left here · the mouth of
the return* — with thresholds `0.20 / 0.50 / 0.88`, the mouth's own fade, and placement at
`H−172` in mono 8.5 BONE 0.26, all match `uni-fall.js:153-158` verbatim. The layer index
`n` was never ported before this pass, which is why the caption had never once appeared.

The behaviour is not confirmed: the axis carries flick momentum past the fall's inner
depths and `d` was not landed in `[0.88, 1.0]` in the attempts made. The mouth's gold
rings were reached. Walk it by dragging slowly rather than flicking.

### 5 · Ash's seat in the fan needs a sequence nobody has run

It requires two returns sealed on one story. The Return declines on *The Two Who Were One*
because that story carries no Ash Comment. Sequence, not defect.

### 6 · The Light is thin on content, and this is the one thing the build cannot fix

Six scenes, for a surface meant to be read daily. The mechanism is whole — he chooses from
six presences rather than a date-hash choosing for him, the column lifts and masks so five
anchors never overflow, the hold and the carve and the vow all work, and it is escapable
at every stage. But a reader who comes back every morning exhausts it in under a week and
then meets the same words again.

That is craft work — writing more scenes — and it is deliberately parked. No amount of
engineering produces it, and no shortcut through it would be honest. It is named here so
it is not discovered as a surprise.

---

## What the closing sequence found

Six steps, run from scratch in the stated order. The order mattered.

**1 · Protect list.** The fifteen files in `HANDOFF.md` §7 diffed clean.

**2 · The five traps.** All pass. The rail carries an explicit `step = 21.0` and
`railH = (n−1)·step` — not shrink-wrapped. No age is derived from an index anywhere;
`Ring Index` is commented POSITION ONLY at both the model and the service, and per-ring
age flows `FeedStore:781 → ReturnView:55 → ReturnStrata:88` from each ring's own days.

**3 · The eight-string grep, run in both directions.** Zero hits on all eight invented
instructional strings. And — the half that matters — the three *authored* strings are
present: `touch to receive`, `touch once`, `enter a universe`. Running it backwards is
what found `TURN IT` missing, which led to discovering the world's entire three-face turn
(`uni-deep.js:250-303`) had never been built and never been flagged. Built and walked:
terminator, three seams, the third face's depth rings.

**4 · Hooks and probes removed**, and verified better than planned. `simctl uninstall`
does *not* clear the app's defaults domain, so after reinstalling, all three debug keys
written during earlier walks were still there — `room=sky`, `nogate=1`,
`star=d-marketplace`. The app launched to the Door on live data and went nowhere near any
of them. Absence of a key proves nothing; **the key present and the app deaf to it proves
the reader is gone.** Then the domain was deleted and a cold launch reached the Door
again, no fault in the log.

**5 · `HANDOFF-VERIFICATION.md` as a gate.** Line by line, below.

**6 · The empty-body sweep, last.** Three hits, one real: `parkDebugStarIfRequested() { }`
with a live call site in `.onAppear`. **The hook-stripper produced, for the second time,
the exact fault it was removing.** That is the whole reason this step is sequenced after
the removal instead of before it — run first, it cannot see what the removal creates. The
other two hits are `var onX: () -> Void = {}` default callbacks; both were checked rather
than assumed, and neither is reachable as a live no-op (`AudioAnchorPlayer.exists(nil)`
returns false, so the one un-passed handler's button never renders).

---

## The gate, line by line

**Walked on device, hooks removed — every surface reached by hand:**

- **Sub-depth 2 reached, in three rooms** — Lalita, Karishma, Sakshi. It had never been
  reached once in this build. The vertical then resets it, as specified.
- **Predict-then-tap passes.** Sakshi's caption named "The Waves That Came to Clear" while
  the mark was armed; that is the story that opened. Under the old frame error this is
  precisely what came back wrong, silently.
- **Eleven rooms**, counted on screen: *"Eight ways of reading. Two roots. One who
  replies."* The Codex's "thirteen rooms" is a different object; no conflict.
- **One gesture is one register** — a 360pt swipe advanced exactly one, never two.
- **The star grows into the planet**, continuously, sky → structure → world. No early
  return anywhere in the zoom.
- **The rail, measured not eyeballed**: every tick shares a left edge and the current one
  grows *rightward*, at 9.8 / 13.6 / 17.6 pt against the design's 9 / 13 / 17.
- **The Light, walked whole for the first time.** Six presences stand; he picks; only the
  armed one is named, so the title collision cannot recur. Five anchors arrived and the
  column lifted ~146pt with the top masked — nothing overflowed, nothing spilled onto dim
  stone. `‹ leave` present at every stage.
- **PlayersView scrolls to Ash.**
- **The map shows the gap honestly** — dim marks at real positions with no words behind
  them, against lit ones, with "101 stories · none twice".

**Verified by reading** (values verify by reading): the `immense` preset
(`0.00018 / 0.956 / 0.42 / 5.4`); hex alphas; the em-tracking helper; `#where`'s roman and
`n of 7` and sub-line; `K = 393/frameWidth`; the five canon deals; the Aperture's
session-scoped never-repeat; per-ring age and the craquelure gated on it; no hardcoded
`C-1052` in the Return path; and all of Pass 7's values.

**Open, each with its reason:** the six entries above, plus these not re-walked after this
pass's changes and so not claimed — the Feed edge's dead band, `uZ` liveness, the four
Universe registers on a cold first launch, the Point's seven readings and world V's guard
pane, the Mirror's single cohort, and the interactive constants swept to both limits.
Earlier passes walked several of these, but this pass changed code beneath them, and a
sweep is a snapshot.

---

## One correction to the acceptance file itself

`HANDOFF-VERIFICATION.md`'s Pass 4 line reads *"Bindu's room does not respond — she is
undivided."* The app makes her flower strain outward under the hand and spring back.
Checked against the comp rather than assuming the checklist was right: `The Rooms
v4.html:203` is `const push=1+strain*0.5*(i?1:0)`, carrying the authored comment *"she
strains outward under the hand, and comes back"*. The port is verbatim.

The code is right; the acceptance line is imprecise. What Bindu lacks is a *division* — no
lens, no two sides, no scrub; her `lat` has no destination. She is not inert. Recorded
rather than "fixed", the same as A4 and E1/E2 before it.

---

## The pattern worth carrying forward

The recurring fault has six shapes, and all of them render as something other than a bug:
unwired · unreachable · uncalled · **empty-bodied** (the only one that actively lies) ·
*someone else's problem* (a defect producing exactly the symptom a known limitation
would) · and **a rule that always fires**, whose tell is that you must test the case that
should *not* trigger, not only the one that should.

Two further families showed up late: a constant expressed as a function of the wrong
variable, and its inverse — a continuous quantity expressed as a discrete event. And
running through all of it: the comp's fixed geometry meeting an archive larger than it was
drawn for, four times now.

`OPEN-ITEMS.md` is the living ledger and updates in the same commit as the work. Every
report carries three lists: closed this pass · still open from earlier · next. An item
leaves only when walked or explicitly ruled out — never by going unmentioned.
