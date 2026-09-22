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

## What is still owed

**The amount itself.** Nothing authored says how long *"exactly how long he has"* is, nor
whether the number differs between standing-ins. **It is not picked here** — a duration invented
by the app would be the app authoring the scene's central claim, which is the one thing this
scene is about. It is an authored value and it is owed.

Everything else above is decided.
