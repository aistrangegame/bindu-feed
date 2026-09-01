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

### 7 · The registry's first run — what it found, and what is now built

The backwards half of Rule 4 is a registry rather than a memory (see below). Its first run
enumerated 1,619 authored strings from `canon/` and the design sources and left 490 that the
app did not contain. Most of that is comp sample data and Airtable content. Four clusters
were not, and one of them has since been built.

**BUILT · the 18 world hand-cues.** The finding was worse than "never built": five of seven
worlds never told the hand what to do, and the ones that spoke were mostly speaking
*invented* copy — "touch a star · it draws inward", "part the veil >", "move along the
walls", "each meets its echo · turn to enter", "settle down through the layers", "catch one
in flight". None appears in any design file; none was among the eight strings the forward
grep knew. **The same surface was simultaneously missing authored copy and carrying invented
copy**, which is the whole project's shape in one sentence and is now recorded in §10.

18 of 25 authored cues are present, up from 2. Walked on device: world I's through the new
shared `WorldCue` view, and world II's `TAKE A RAY NEAR THE CENTRE · THEN GO OUT` standing
where the invented line was.

**Seven remain, and not one is a string problem.** Each needs a mechanic the app does not
have, and inventing a trigger to place the words would be the exact fault this pass is
about:

- *The withdrawal family (4)* — `IT CLOSED. IT DOES NOT MIND.` · `IT CLOSED BEHIND YOU. IT
  ALWAYS DOES.` · `THE WALL EASED. WHAT WAS STRUCK STAYS STRUCK.` · `THE GLASS LET GO. WHAT
  FACED YOU, FACED YOU.` All four fire on a decay *after release* (`leaving` / `closing` /
  `easing` / `settling` > 0.02). The app's readings unmount on close instead of lingering,
  so there is nothing for them to hang on. Worth building: it is the same withdrawal shape
  world V's guard pane already has.
- *World VI's multi-arc family (3)* — `DRAW IT UP · AIM · LET GO` needs the draw-up-and-aim
  gesture the app replaced with a Button; the other two need more than one arc in flight.

**BUILT · `#carry`, and the walk serialisation was unnecessary rather than large.**
`asf.walk` exists because each ceremony is a separate HTML document and a JS session dies
at that boundary. The app has no such boundary, so `CARRY` on a session object survives the
round trip for free — it lives on `PointJourney`, no serialisation. What it resolves: the
earlier decision not to store `carry`/`carved`/`crossed` was right and can now be shown
right — neither `The Return v2.html` nor `The Rite v3.html` ever reads `W.carry` after
declaring it. The missing consumer was the instrument restoring its own CARRY (`:5826`) and
the motes (`:5752`). Fourth and last instance of a field that looked unwired because its
reader had never been built, after DEALS, WORDS and TURN IT.

Walked to the seal; the mote in orbit is verified by reading only, because at the Point's
registers the particle sits behind the yantra among the world's own stars. The walk did
catch a collision I introduced — `#carry` at the comp's `bottom:54` landed on the app's
descend door at `bottom:34`, an element the comp does not have. Raised to 118, recorded as
a deliberate geometry divergence.

**BUILT · `#seam`**, with met-ness lifted out of `DoorView`'s private `@State` into
`FeedStore.todayMet`. Not walked: today is unmet, so the gate correctly keeps it silent.

**OPEN · eight authored cues, no trigger — enumerated and deliberately unbuilt.** Not a
string problem: each is verbatim in the design and absent because the state that fires it
does not exist. Building one is a decision about a mechanic, never about placing words.

| cue | source | waits on |
|---|---|---|
| `IT CLOSED. IT DOES NOT MIND.` | `world-one.js:193` | `leaving > 0.02` |
| `IT CLOSED BEHIND YOU. IT ALWAYS DOES.` | `world-three.js:244` | `closing > 0.02` |
| `THE WALL EASED. WHAT WAS STRUCK STAYS STRUCK.` | `world-four.js:277` | `easing > 0.02` |
| `THE GLASS LET GO. WHAT FACED YOU, FACED YOU.` | `world-five.js:445` | `settling > 0.02` — and the app already uses that *name* for which face is toward you, so this needs a rename as well as a mechanic |
| `DRAW IT UP · AIM · LET GO` | `world-six.js:419` | `holding` — the draw-up-and-aim gesture; the app's send is a Button |
| `THEY WILL COME BACK IN THEIR OWN ORDER` | `world-six.js:424` | `arcs.length > 1` |
| `SOMETHING IS COMING THAT YOU DID NOT SEND` | `world-six.js:423` | an arc with `deep` set |
| `holding it open` | `world-three.js:240` | `open < 0.30` — a parting *width*; the app's `part` is a point or nothing |

**One mechanic closes the first four.** They are the same shape — a decay that runs after
release while the reading is still on screen — and world V's guard pane already has exactly
that (`withdrawing`, on its own wall clock, finishing whether he is there or not). That is
the next pass. World VI's three need a different gesture and a multi-arc model, which is a
larger question about what that world is.

Words on an approximate trigger would be the invented-string fault carrying **authored**
copy — worse, because it would read as verified.

**Also open:** the journey narration and the lens label, both now carrying deliberate §10
divergence records rather than sitting undocumented.

---

## The rule the build now follows

**The app says what the design says, where the design says it, once.**

I spent most of this build repeating a blanket ban on instructional strings, and it was
wrong. The Light instructs — `The Light v2.html:685` — *"one invitation, once. After the
touch, the door says nothing more"* — and it says `touch once`. The one flat prohibition,
`The Rooms v4.html:1054`, is scoped to a single legend: *"register 2's own wayfinding —
counts, never instructions"*. The eighteen world cues at `H−150` are authored imperatives.

So the ban is about **repetition and place, not the imperative mood**, and one question
settles any instructional string: **did the design draw this surface?**

| | ruling |
|---|---|
| drew it, gave it words | **port the words** |
| drew it, chose silence | **the silence is authored — delete** |
| never drew it | no authored silence to honour and no affordance to repair. The app may speak, **minimally, once, and on the record** as `APP-OWN-INSTRUCTIONAL` — never laundered into plain `APP-OWN` |

That test found a seventh invented string, and the first one found by method rather than by
memory: `▽ DESCEND ONE LAYER DEEPER` sat where `point-levels.js:107` says
*"descend onto this star"*. It was almost deleted as chrome over a working affordance; the
design had drawn that surface and given it a label all along. `hold for depth` went the
other way — `Story Detail.html` is named once at `The Universe v3.html:1571` and is not in
the bundle, so the surface was never drawn and the string stays, recorded. Ash's three are
one `hintText` state machine showing one line at a time, which is what "once" means.

---

## What the closing sequence found

Six steps, run from scratch in the stated order, twice — once at the original close and
again after this pass. The order mattered.

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

**5 · `HANDOFF-VERIFICATION.md` as a gate.** Line by line, below. Re-run after this pass
against the lines it touched: Pass 5's *"the reading is carried by the hand"* now has all
seven worlds saying the design's own words at the design's own moment, which is the line
that was furthest from true when the build closed the first time.

**The re-run also named something step 4 had let pass.** `TokenEntryView` keeps two
`#if DEBUG` dev doors — `⟿ walk the Instrument` and `⟿ the Rite` — compile-gated out of
Release and commented *"never ship"*. They are not the `bindu.debug.*` parking hooks (they
fake no state; they open a door), and they are the only tokenless way into the instrument
for someone walking it. Named here rather than removed, because removing them makes the app
unwalkable without a live Airtable token — but "every debug hook" did mean these too, and
they should not have gone unmentioned the first time.

**6 · The empty-body sweep, last.** Re-run after this pass: **two hits, both the known
unreachable defaults, none new.** This pass's mechanical editors — the string ports and the
registry seeders — did not produce one, which is the first time that has been true.

At the original close it was three hits, one real: `parkDebugStarIfRequested() { }`
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

**And the 81 comment-only strings have a consequence past the tool.** A *forward* grep is
safe against comments: a hit inside a comment is a false positive, and you see it and
dismiss it. A *backward* grep is not: a comment quoting the design creates a **false
presence you never see**. The string appears to be there, the check passes, and nothing
draws your attention to it.

So **every whole-file backward check made during this build was masked the same way** —
including the closing sequence's own step 3, which confirmed `touch to receive`, `touch
once` and `enter a universe` by grepping whole files. Those three do turn out to be really
present, but that walk did not prove it; it only failed to distinguish a rendered string
from a quoted one. The narrowed matcher is the only trustworthy one, and it is the reason
`REQUIRED` fell from 799 to 718. **Treat any backward-direction result in this build's
history that predates the narrowing as unverified, and re-run it with
`Tools/check_authored.py`.**

**Every one of them had, on its first run, the exact fault it was built to catch.** The
hook-stripper left an empty body with a live call site — twice, the second time while
removing the first. The authored-string guard passed a deleted string because a comment
three lines above quoted the design: a rule that always fires, inside the tool built to
catch rules that always fire. The citation checker paired a quote with a citation from a
different sentence and reported a false OK. **A tool is not exempt from the class it
detects.** The only thing that finds it is pointing the tool at something whose answer you
already know, in both directions — break it on purpose and watch it go red, then hand it
something correct and watch it stay green. Calibration is the work, not overhead: a checker
that over-reports gets ignored, and being ignored is the same silent failure as
under-reporting, because the tool is green either way and nobody is looking.

**Three drift checks now, not two.** `check_authored.py` proves authored strings present.
`check_rendered.py` proves rendered strings authored-or-recorded. `check_citations.py`
proves a cited line still says what the prose claims it says — because **documents drift the
same way code does and nothing greps them.** Three got through this build: a stale §6 note,
a stale `LightView` header, and §10's own citation of a line that turned out to be
`touch:function(){this.touches++;}`. A line number alone cannot be verified; a line number
plus its words can, so §10 now quotes what it cites. 57 citations, 4 checkable, 0 drifted —
the coverage number is the honest one and it goes up as citations are converted.

**One thing the comp's numbers cannot carry.** `#carry` at the comp's `bottom:54` landed on
the app's descend door at `bottom:34` — an element the comp does not have. Raised to 118.
**The comp's coordinates assume the comp's surfaces**, and copying a number into a screen
that has one more thing on it reproduces the collision the number was chosen to avoid.

**Both halves now run from a list.** `check_authored.py` proves authored strings PRESENT
(the backward half). `check_rendered.py` proves rendered strings AUTHORED-or-recorded (the
forward half) — 985 rendered · 850 authored · 102 APP-OWN · 25 NON-UI · 5
APP-OWN-INSTRUCTIONAL · 3 DIVERGENCE · **0 inventions, 0 untriaged**. You cannot enumerate
inventions from the design, because inventions are exactly what is not in it; so the forward
check enumerates the other side and anything unaccounted for is an invention by
construction. Both fail on an untriaged row: an unjudged string is indistinguishable from an
invented one.

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

## Build state

`BUILD SUCCEEDED`. Two pre-existing Swift warnings remain, both main-actor isolation at
`RoomFigures.swift:68-69` (`ring`, `breath` called from a synchronous nonisolated context).
Benign, unrelated to this pass, and deliberately not touched — changing actor isolation in a
Canvas drawing path at handoff is the kind of change that goes subtly wrong. Worth noting
that an earlier report of "zero warnings" was measured on a no-op incremental build; a
forced recompile is what surfaces these.

`python3 Tools/check_authored.py` exits 0.

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
