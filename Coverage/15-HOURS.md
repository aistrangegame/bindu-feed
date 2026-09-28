# 15 · `hours` (776) — THE STATED AMOUNT

*Ruled 2026-09-20. Recorded here rather than left in a conversation, so the next pass reads it
instead of re-deriving it.*

---

## The scene

`Light — hours`, sort 776, `rechGpsvCJYl3Ve33`. `FAMILY: The ending` · `BELIEF DISSOLVED: I am
running out of time.` · `ARRIVAL: nave` · `MATERIAL: nave`.

> **GESTURE:** the stated amount — alone among all the scenes, this one tells him exactly how
> long he has with it, at the start, and then keeps to it. It does not pause when he attends, or
> extend when he is moved, or wait while he decides. It closes warmly and on time.

> **NOTE:** not a meditation on dying. Nothing about the manner, the moment or the after. The
> subject is the limit, and every line points back into the life. **If a future pass makes this
> scene solemn, the pass is wrong.**

Its Declaration is *"I am not running out. I was given an amount, and I said yes to it."* Its
landing is *"Spend it. That was always the instruction."*

---

## The question that was open

A fixed duration is a promise **the OS can break** — a call, the screen locking, switching apps,
backgrounding, Low Power Mode. The question was never whether to build a timer. It was **what
the scene does when the phone takes the hour away from him.**

## THE RULING

**The time is wall-clock time. It keeps running when the phone takes it away.** A call, the
screen locking, switching apps, backgrounding — nothing pauses it.

**Time still remaining →** the scene continues from where the clock actually is now. No catch-up
animation, no *"you were away,"* no acknowledgement that anything happened.

**Time ran out while he was gone →** he returns directly to the landing, already present:
*Spend it. That was always the instruction.* Nothing else.

**Never:** *"time's up,"* *"you missed it,"* an empty or closed state, an apology, a restart
offer, or anything that frames the interruption as a loss. **The interruption was the spending**
— the scene simply notices it happened.

**Each entry is its own amount.** Re-entering hours later gives a fresh stated amount. The fixed
amount belongs to a standing-in, not to the day.

After the landing, the Wave 3 recognition is offered exactly as in any other scene.

**Constraint from the NOTE:** nothing in the implementation may make the scene solemn. If a
behaviour reads as grief, or as a countdown to an ending, it is wrong.

---

## What this rules OUT in the code as it stands

**`LightView.startSceneTick` (`:687-690`) accumulates `dt` from `Date()` deltas inside a
`Timer`.** That is wall-clock *per tick*, and therefore exactly wrong here: **the timer does not
fire in the background, so time spent away is never accumulated** and the scene resumes where he
left it. That is precisely the pause the ruling forbids — and it would look completely correct,
because the only way to see it is to leave and come back.

`hours` holds a **start `Date`** and derives remaining from `Date()` directly. Never from
accumulated ticks.

- **Not a day-key.** Every other per-day thing in the Light uses
  `AirtableService.localDayString()` (§9). This must not. The amount belongs to a standing-in.
- **Returning is not re-entering.** Backgrounding and coming back is the SAME standing-in and
  keeps its clock. Leaving by `‹ leave` and entering again is a NEW one with a fresh amount.
  `scenePhase` is already handled at `ContentCoordinator.swift:81`.
- **Expiry while away is a STATE, not an event.** He returns to the landing already present, so
  it is rendered from the clock on appear — never animated by a fire that never happened. A
  transition played on return would be the app telling him what he missed.
- **Low Power Mode and Reduce Motion cannot lengthen it.** `Coverage/10-OWED.md` G1–G8 record
  that those gates throttle time-based fills; a wall-clock derivation is immune by construction,
  which is a second reason to prefer it over an accumulator.

## The amount — RULED 2026-09-28, and derived rather than picked

I said this was the one value the app must not invent, and I still think that is right in
principle. Ashrey delegated it, so here it is **derived from the scene's own walk** rather than
chosen, with the arithmetic shown so it can be argued with.

**FOUR MINUTES. It does not vary between standing-ins.**

**The derivation.** Walked at the Light's own pace, `hours` takes: the stillness gate at
**4.6s** (`gateMs`), the hold, its **five anchors** surfacing one per touch on the breath at
roughly a `Breath.period` each (**10s**), the Declaration, and the landing's authored delay of
`Breath.period * 1.6` (**16s**). That is **≈2m30s–3m unhurried.** Four minutes is the smallest
round number that clears it with room to spare.

**Why room to spare, and not a tight fit.** The register's law is *force is absorbed, not
blocked* — the gate accumulates and keeps, the dawn slows 6× and never stops. **A duration he
could miss by dawdling would make this the one scene in the Light he can fail**, which inverts
the register. He should be able to finish without hurrying, and still watch it go down. That is
the difference between a limit and a test, and it is the whole of the scene's teaching.

**Why it does not vary.** The ruling says *"each entry is its own amount… re-entering hours
later gives a fresh stated amount."* Read as **the clock restarts**, not as a die roll. A number
that changed every visit would make *"it tells him exactly how long he has"* a fact about this
visit rather than a fact about the scene — and the scene's subject is the limit itself, which is
stable. **The alternative reading is recorded rather than dismissed:** if the amount is meant to
vary, it is a one-line change here, and the mechanism is indifferent.

**Why four and not five, or three.** Three is inside the unhurried walk and would hurry him.
Five is long enough that the counter stops being present. Four is the round number in between,
and roundness matters because he is told it: *"It says so at the top."* **4:00** is a thing a
person can hold in their head, which `3:47` is not.

**NOT SOLEMN, which the NOTE makes binding.** Four minutes is short enough to read as an
ordinary appointment rather than a vigil. Nothing counts DOWN in red, nothing pulses as it
nears, and nothing marks the last ten seconds — *"if a future pass makes this scene solemn, the
pass is wrong."*

**This is the one value in the register that is the app's and not the author's**, and it is
marked so. If Ashrey authors an amount, it replaces this and this note goes.

## Four minutes is ruled. Do not re-litigate it from the shorter argument.

**RULED 2026-09-28.** This paragraph used to end *"changing it is one line and no argument"* —
which invited exactly the re-opening it was trying to make cheap. It is struck.

The history matters, because the shorter argument is the one a later pass will find first.
**Three minutes was proposed, and three minutes was wrong** — not by taste, but against the
register's own law: *the scene cannot be failed by lingering.* Three minutes sits inside the
unhurried walk measured above (4.6s gate + hold + **five** anchors surfacing one per touch on
the breath at `Breath.period * 1.6` ≈ 16s + the Declaration on hold + the landing ≈ **2m30s–3m**),
so a man who paused on one anchor would run out mid-scene and the scene would have been failed
by attending to it. **Four minutes is the smallest round number that cannot be.** It is derived
from the walk, not picked; the five anchors it is derived from are verified against the row.

So: the amount is **four minutes**, and it is settled. A later pass may replace it only with an
amount **Ashrey authors**, or with a re-measured walk that shows four is no longer the smallest
round number above it. *"It felt long"* is not a reason, and neither is the three-minute
proposal, which is recorded here spent rather than open.

**The constant does not exist in the code yet, and this file is deliberately where it lives
until it does.** `hours` is not built — no Swift file in the register names it (grepped
2026-09-28). Writing a named constant now that nothing reads would be §10's eleventh shape
exactly: built, asserted, uncalled. **When the scene is built, this reasoning moves with the
constant into its doc comment** — that is the point of recording it here rather than in a
commit message that the next pass will not read.

Everything else above is decided.
