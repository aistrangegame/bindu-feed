# Handoff — Claude Code on the Mac builds the Many-Bodied Game (Track 2)

*Written 12 Oct 2026 by Track 1 (the cloud session). This file is your whole briefing. Ashrey pastes one short prompt that points here; after that, nobody briefs you again.*

## Who you are in this
You are **Track 2**: you build every line of Swift for the Many-Bodied Game, waves **W0 → W8** (Slices 14–30), in `~/Bindu Feed`. Track 1 (the cloud session) has already done the reading, the plan, the scores, the Airtable schema, and **all the content**: 338 new stories with their children, Waiting Roles, Swatches, Interludes, Veils, Second Letters, Leela drops, Call answers, Constellations, Planted Seeds. All of it sits in Airtable with `Status = Staged`, so the build on his phone (which reads only `Live`) cannot see it.

**Ashrey is the experiencer, not a reviewer.** Do not ask him questions, show him screenshots, send progress, use TestFlight, or install on his phone (Neev) before the very end. He receives the whole piece once.

## Read, in this order, before the first edit
1. `Coverage/many-bodied/CONTRACT.md` — binding. Field IDs, the Staged law (§2.3), sort bands and Types (§2.4–2.4b), content conventions and marks (§2.6), the 21 rooms (§3), the gesture and state maps you must write (§4–5), the write proof (§6), house laws (§7).
2. `Bindu Feed/CLAUDE.md` — the app's own memory, especially §6 (Airtable), §9 (design language), §10 (load-bearing decisions and the hard-won lessons; they are law).
3. `Coverage/many-bodied/GAMEPLAN.md` — the whole design, so every slice knows what it belongs to.
4. `Coverage/many-bodied/scores/W0.md` … `W8.md` — **one per wave; each is your exact build brief.** Read each score in full when you start its wave; read the next one's "What this score stands on" before closing the current wave.
5. `Coverage/many-bodied/DECISIONS.md`, `STATUS.md`, `content/DATA-OWED.md`, `content/AUDIT-STAGED.md` (for what the content contains and what the renderer must never show — e.g. Waiting Roles' Body field carries backstage source codes and must never be rendered).

Binding order when things disagree: house laws (CLAUDE.md §10) › CONTRACT.md › the wave's score › GAMEPLAN.md. Each score opens with a "Contract updates" block and a "Band reconciliation" note; those win over the score body.

## How you work
- **Start:** `git pull --rebase` in `~/Bindu Feed`. Confirm `main` contains `Coverage/many-bodied/HANDOFF-CLAUDE-CODE.md`. Note the HEAD commit in STATUS.md as your starting point.
- **Order:** W0, W1, … W8. Within a wave, its slices in order. Do not start a wave before the previous wave's "Done means" is met and recorded.
- **Commits:** one or more per slice, message beginning `Slice <n> · W<k> ·`, ending with the attribution lines your harness gives you. Push to `main` after each slice (`git pull --rebase` first; never force-push). Track 1 only ever writes under `Coverage/many-bodied/`, so conflicts should not arise; if one does, keep both sides' intent.
- **Every slice:** `Tools/verify.sh` green (all seven checkers), compile clean, unit tests with the **executed count** read from `xcresulttool` (CLAUDE.md §10 — never trust the banner).
- **Every wave:** the score's Simulator walk, with screenshots saved under `Coverage/many-bodied/evidence/W<k>/`; the score's greps; the harness cases; a lineage check (nothing from an earlier build vanished — keep `LINEAGE.md`).
- **The new build reads `Live` ∪ `Staged`** (CONTRACT §2.3) in every Feed fetch — DEBUG and Release alike. W0 makes this change first.
- **Writes to Airtable** happen only through the app's own runtime writes and W0's write proof (CONTRACT §6, marked `BUILD PROOF ·`). You never write story text or schema. If a wave needs data that is missing, the app must still look complete (missing is absent); note it in STATUS.md under "Owed to Track 1".
- **Decisions:** anything the score does not settle — decide by the house laws, record it in `DECISIONS.md` (date · W<k> · the call · the reason), keep going.
- **After each wave**, append to `STATUS.md`: wave, commits, every "Done means" line with its evidence path, anything owed (to yourself or to Track 1).
- **Context:** this is a long build. When your context runs low, finish the current slice, push, write the exact next step at the bottom of STATUS.md under `## Resume here`, and stop. Ashrey will start a fresh session with the resume prompt; it reads STATUS.md and continues.

## The Simulator and the token
Live walks need the Airtable token in the Simulator's keychain. If the Simulator shows the token gate, stop and add this line to STATUS.md: `NEEDS TOKEN IN SIMULATOR`. Then tell Ashrey, in one sentence, to paste his Airtable token into the Simulator's token screen himself. That is the only thing you ever ask him. Never read, print, store or commit the token.

## The end (W8)
Follow `scores/W8.md`'s delivery order exactly. In short:
1. Full parity pass across W0–W8, the adversarial pass (three cuts — **the Lalita Pass is Ashrey's alone**; nobody else runs it), and the device walk on the Simulator or another device, **never on Neev**.
2. Build Release and install on Neev with `devicectl` **without launching it**. No TestFlight (it notifies).
3. Write `READY FOR THE FLIP` at the top of STATUS.md with the installed commit, and tell Ashrey in one line: *"It's on your phone. Tell the cloud session to flip."*
4. Track 1 then flips every Staged record to Live, applies `content/DELIVERY-DAY.md`, renames `Suit`/`Rhymes With` to their OLD names, and creates the composing pipeline with notifications off. The one line to Ashrey comes from Track 1.
