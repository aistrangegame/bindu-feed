# HANDOFF NOTE

Branch `upgrade-pass-a-to-c`. The build closes here. This note is the honest account:
what has never been verified, what is a measured limit rather than a defect, and the one
thing the build cannot fix.

Read the seven-entry list first. Everything else is supporting detail.

It was six until the authored-string registry was built. Entry 7 is what the registry
found on its first run, and its size is the argument for having built it.

---

## The honest list — seven entries, the sound first

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

### 7 · The registry's first run found more missing authored copy than expected

The backwards half of Rule 4 is now a registry rather than a memory (see below). Its first
run enumerated 1,619 authored strings from `canon/` and the design sources, confirmed 718
present in the app, and left **490 authored strings that are not**. Most of that backlog is
comp sample data and Airtable-sourced content. Four clusters are not:

- **18 of the 20 world hand-cues are absent.** Worlds II, III, IV, VI and VII never tell
  the hand what to do. `world-three.js` has *PART IT WITH YOUR HAND · AND HOLD IT OPEN* and
  *PART IT AGAIN, SOMEWHERE ELSE*; `world-four.js` has *PRESS A WALL · AND BEAR IT*;
  `world-two.js` has *TAKE A RAY NEAR THE CENTRE · THEN GO OUT*; six and seven have five
  each. Only two are built — world I's *TOUCH ONE · THEN LET GO AND STAY* and world V's
  *TURN A MIRROR · AND SEE WHAT FACES IT*. This matters more than the count suggests: the cue is how the gesture is
  discoverable, and `HANDOFF-VERIFICATION.md`'s Pass 5 line — *"the reading is carried by
  the hand"* — is about exactly this. The app has neither the authored cue nor an invented
  substitute, so those five worlds are silent about their own gesture.
- **`#carry` was never built.** `take it up` / `let it go` (`The Instrument v3.html:4682`)
  and `sealCarry()` at `:5334`. Taking a reading up is weightless — *"no list, no
  collection, nothing counted"* — and what it leaves behind is company: one carried mote in
  orbit around the one particle at every scale (`:5752`), the halo growing by
  `1 + CARRY.length*0.05`, the walk narrating *"You carried X up with you. What you carry is
  not a list. It is a change in what you notice."* (`:5776`), and `CARRY` serialised into
  `asf.walk` (`:5809`). The app has `KEPT` — the rail's filled dots — but nothing of `CARRY`.
- **`#seam` was never built.** The axis's two direction hints at the Feed's own scale,
  toggled at `:5619` when `|Z| < 0.30` and the day is met: *pull down · outward / everything
  that has met you* and *pull up · inward / everything you have gathered*.
- **The journey narration is a different, smaller object than the design's.** The design
  narrates which reading-*gesture* he used — *You stayed with… You took hold of… You parted
  the veil over… You bore the pressure until… You kept pace with… You crossed into…*
  (`:5770-5781`). `PointJourney.narration()` narrates which dims and stars he entered. That
  may be a deliberate substitution, but it is not recorded as one in §10, so it is listed
  here rather than assumed.

Also diverged without a record: the Universe's lens label is `the light ›` / `the structure
›` where `The Universe v3.html:1437` and `:1676` say `the star lens` / `the structure lens`.

**None of this is built.** It is named, enumerated, and left in
`Tools/authored-strings.tsv` as `REVIEW` so it cannot go quiet again. Whether the world
cues ship before the first walk is a judgement call about how discoverable the Point should
be on first contact — it is the one item here that changes what a first reader experiences.

---

## What the closing sequence found

Six steps, run from scratch in the stated order. The order mattered.

**1 · Protect list.** The fifteen files in `HANDOFF.md` §7 diffed clean.

**2 · The five traps.** All pass. The rail carries an explicit `step = 21.0` and
`railH = (n−1)·step` — not shrink-wrapped. No age is derived from an index anywhere;
`Ring Index` is commented POSITION ONLY at both the model and the service, and per-ring
age flows `FeedStore:781 → ReturnView:55 → ReturnStrata:88` from each ring's own days.

**3 · The eight-string grep, run in both directions — and then replaced.** Zero hits on
all eight invented instructional strings.

The backwards half was wrong in this note's first draft, and the error is worth keeping
visible: it named `touch to receive` as the door's affordance. That is the Rite's and the
gate's string (`The Rite v3.html:1297`, `The Instrument v3.html:5008`). The door's
affordance is **`touch to read`** (`The Universe v3.html:1434`) — a different string on a
different surface, and the one that was nearly deleted in Pass C when the sweep ran
one-directional. Confirmed present: `UniverseView.swift:562` draws `TOUCH TO READ`,
uppercased from the lowercase source the way `text-transform` does it. A handoff that
names the wrong string as verified is the stale-comment fault in the document that exists
to be trusted.

Running the grep backwards is what found `TURN IT` missing, which led to the world's
entire three-face turn (`uni-deep.js:250-303`) — never built, never flagged. Built and
walked: terminator, three seams, the third face's depth rings.

But `TURN IT` was caught by **memory, not by method**, and three remembered strings are
not a check. The asymmetry was the real gap: the forward grep enumerates eight invented
strings; the backwards grep enumerated whatever someone recalled. So the backwards half is
now a registry — see below.

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

## The authored-string registry — Rule 4's backwards half, made a method

`Tools/` now holds the thing that should have existed before `TURN IT` was found by luck.

| file | what it is |
|---|---|
| `extract_authored.py` | discovery — pulls candidate authored strings from `canon/` and every design source, tagging each with **provenance**: `js-literal` (how the comps render their own chrome), `markup` (a text node in the phone), `doc` (a documentation container — the design explaining itself, never app copy). Provenance is what separates copy from commentary, and it is not a file-level distinction: `The Universe v3.html` carries both. |
| `authored_lib.py` | shared normalisation and matching |
| `seed_registry.py` | auto-classifies what shape and provenance can classify; **hand verdicts survive regeneration** |
| `authored-strings.tsv` | the registry — 1,619 rows, one verdict each |
| `check_authored.py` | enforcement. Exits non-zero if any `REQUIRED` string has left the app |

Verdicts: `REQUIRED` (718 — present and traceable to an authored source; deleting one must
be a decision, not a side effect) · `REVIEW` (490 — the backlog, where a never-built
mechanic surfaces) · `ANNOTATION` (189) · `FRAGMENT` (140) · `CSSVALUE` (78) ·
`SUPERSEDED` (4). Two further verdicts exist for hand use: `CONTENT` for copy that reaches
the app from Airtable at runtime, and `DIVERGED` for copy deliberately not used, with the
reason recorded in §10.

```bash
python3 Tools/check_authored.py --clusters
```

**The matching was calibrated by measurement, and that mattered more than coverage.**

*False negatives* — three classes found and removed: Swift `\u{XXXX}` escapes (the
Aperture's `Or\u{00ED}`, `Da\u{2019}at`, `Coire \u{00C9}rmai` all read as missing until
decoded); a design string the app splits across array elements (canon holds a Light scene's
pair as one string, `LightCanon` stores them as separate anchors); and curly quotes,
em-dashes and NBSP. Before calibration the tool reported 842 absent, 22 of them wrongly.

*A false negative wastes time; a false **positive** makes the tool a liar* — and the first
version was one. The guard was tested by deleting `TOUCH TO READ` from `UniverseView` on
purpose, and **the check stayed green**: the same string sits three lines above in a comment
quoting `The Universe v3.html:1434`, and the haystack was the whole file. This codebase
quotes design source in comments constantly, so the check would have passed for any string
its own comment mentioned — a rule that always fires, in the tool built to catch them.
The haystack is now **Swift string literals only**, comments and interpolations stripped.
That one fix moved 81 strings out of `REQUIRED`: they had never been rendered anywhere, only
quoted. Re-running the deletion test now exits 1 and names the string.

A registry that cries wolf is one nobody reads. A registry that never cries is worse.

**What it does not do.** It cannot decide whether an absent string *should* be in the app —
comp sample data, Airtable content and design commentary all look alike to a matcher. That
judgement stays human, which is why every verdict but `REQUIRED` and `REVIEW` is written by
hand and preserved across regeneration. What the tool guarantees is that no authored string
can be *silently* absent: it is either in the app, or it is a row in the registry with a
name on it.

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
