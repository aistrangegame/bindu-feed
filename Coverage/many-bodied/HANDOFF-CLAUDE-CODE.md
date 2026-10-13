# Handoff — Claude Code on the Mac builds the Many-Bodied Game (Track 2)

*Written 12 Oct 2026 by Track 1 (the cloud session); readiness fixes applied the same day (READINESS-REVIEW.md, "Fixes applied"). This file is your whole briefing. Ashrey pastes one short prompt that points here; after that, nobody briefs you again.*

**The start prompt (Ashrey pastes this once):**
> In this folder run `git fetch origin && git checkout many-bodied && git pull`. The branch carries `.claude/settings.json` (the build's permissions) — if this session started before the checkout, say so in one line and I will restart you. Then read `Coverage/many-bodied/HANDOFF-CLAUDE-CODE.md` in full and follow it to the end. You are Track 2: build the Many-Bodied Game, W0 through W8.

**The resume prompt (pasted into every later session, verbatim):**
> In this folder run `git checkout many-bodied && git pull`. Then continue the Many-Bodied build: read `Coverage/many-bodied/HANDOFF-CLAUDE-CODE.md`, then `Coverage/many-bodied/STATUS.md` → `## Resume here`, and carry on from there.

## Who you are in this
You are **Track 2**: you build every line of Swift for the Many-Bodied Game, waves **W0 → W8** (Slices 14–30), in `~/Bindu Feed`. Track 1 (the cloud session) has already done the reading, the plan, the scores, the Airtable schema, and **all the content**: 332 new stories with their children, Waiting Roles, Swatches, Interludes, Veils, Second Letters, Leela drops, Call answers, Constellations, Planted Seeds. All of it sits in Airtable with `Status = Staged`, so the build on his phone (which reads only `Live`) cannot see it.

**Ashrey is the experiencer, not a reviewer.** Do not ask him questions, show him screenshots, send progress, use TestFlight, or install on his phone (Neev) before the very end. He receives the whole piece once.

**The source root** is `<repo>/Bindu Feed/Bindu Feed/`. Every Swift path in every score is relative to it, whichever prefix a score happens to write (W1, W7 and W8 write `Bindu Feed/Bindu Feed/Bindu Feed/`, which is the same folder seen from `~`).

## Read, in this order, before the first edit
0. **The Staged law is a deliberate amendment of a house law, not a conflict (ruled 12 Oct).** `Bindu Feed/CLAUDE.md` §6 (:204, "Every read gates on `{Status}='Live'`. No exceptions") and §10 (:381) say Live only. The new build reads `Live ∪ Staged`; the installed build's Live-only gate is the delivery hold. **W0's first commit (W0 step 0) edits CLAUDE.md §6 and §10 to:** *"Every read gates on `OR({Status}='Live',{Status}='Staged')` (CONTRACT §2.3, since W0). The installed build's Live-only read is the single-delivery hold; on delivery day Track 1 flips Staged → Live. Writes still set Status explicitly (the blank-Status lesson stands)."* Until that commit lands, read every "Live only" sentence in CLAUDE.md as amended by this line.
1. `Coverage/many-bodied/CONTRACT.md` — binding. Field IDs, the Staged law (§2.3), sort bands and Types (§2.4–2.4b), content conventions and marks (§2.6), the 21 rooms (§3), the gesture and state maps you must write (§4–5), the write proof (§6), house laws (§7).
2. `Bindu Feed/CLAUDE.md` — the app's own memory, especially §6 (Airtable), §9 (design language), §10 (load-bearing decisions and the hard-won lessons; they are law — with the one amendment above).
3. `Coverage/many-bodied/GAMEPLAN.md` — the whole design, so every slice knows what it belongs to.
4. `Coverage/many-bodied/scores/W0.md` … `W8.md` — **one per wave; each is your exact build brief.** Read each score in full when you start its wave; read the next one's "What this score stands on" before closing the current wave.
5. `Coverage/many-bodied/DECISIONS.md`, `STATUS.md`, `content/DATA-OWED.md`, `content/AUDIT-STAGED.md` (for what the content contains and what the renderer must never show — e.g. Waiting Roles' Body field carries backstage source codes and must never be rendered).

Binding order when things disagree: house laws (CLAUDE.md §10, as amended by item 0) › CONTRACT.md › the wave's score › GAMEPLAN.md. Each score opens with a "Contract updates" block and a "Band reconciliation" note; those win over the score body. **On how you run — the branch and pushes, messages to Ashrey, walks, the test bar, permissions, stops — this file wins over any score.**

## How you work

### The branch (Xcode Cloud can never fire mid-build)
- **All build work happens on branch `many-bodied`, never on `main`.** Start with `git fetch && git checkout many-bodied && git pull --rebase`. Confirm the branch contains this file; note the HEAD commit in STATUS.md as your starting point.
- **Pushes are gated (ruled 12 Oct, re-review R10).** Commit locally on `many-bodied` after every slice. **Before your first push,** read `Coverage/many-bodied/DECISIONS.md` for the exact line **`XCODE CLOUD CONFIRMED: main only`** (Track 1 adds it when Ashrey confirms in App Store Connect that no Xcode Cloud workflow starts on any branch but `main`).
  - If the line is there: push `origin many-bodied` after each slice, as a backup (`git pull --rebase` first; never force-push).
  - If it is absent: **do not push at all during the build** — local commits only (`git pull --rebase` from origin is still fine). Push `many-bodied` once, at the end, after the install on Neev (W8 §7 step 6). Re-check DECISIONS at the start of each wave; once the line appears, push.
- Never push to `main`, never open or merge a PR to `main`, never start an Xcode Cloud workflow, never upload to TestFlight. A push could start an Xcode Cloud → TestFlight build that notifies Ashrey or installs itself on Neev mid-build.
- Track 1 also commits only to `many-bodied` from now on (only under `Coverage/many-bodied/`), so conflicts should not arise; if one does, keep both sides' intent.
- `main` is merged from `many-bodied` **only at delivery** (W8 §7 step 5), **after** the install on Neev, and **locally only**: Track 2 never pushes `main`; Track 1 pushes it after the flip (DECISIONS).

### Order and the "Done means" status convention
- **Order:** W0, W1, … W8. Within a wave, its slices in order.
- **Every "Done means" line gets one status in STATUS.md:**
  - `MET` — with its evidence (path under `evidence/W<k>/`, grep output, or xcresult count);
  - `OWED-TO-TRACK-1` — the line needs data or schema that is not yet in the base (a choice to create, rows to write, a rename). **Not blocking:** you prove the code path with a harness fixture instead and say which fixture;
  - `OWED-TO-SELF` — anything else that is not met. **Blocking.**
- **A wave closes when no `OWED-TO-SELF` line remains.** Then the next wave may start. `OWED-TO-TRACK-1` lines carry forward in STATUS.md's "Owed to Track 1" list; you never wait for them.
- A write queued behind a missing select choice (422 `INVALID_MULTIPLE_CHOICE_OPTIONS`) is owed, not failed: `OWED-TO-TRACK-1`.

### Commits and checks
- **Commits:** one or more per slice, message beginning `Slice <n> · W<k> ·`, ending with the attribution lines your harness gives you. Push per "The branch" above.
- **Every slice:** `Tools/verify.sh` green (all seven checkers), compile clean, unit tests with the **executed count** read from `xcresulttool` (CLAUDE.md §10 — never trust the banner).
- **The bar (`Tools/bar.sh`) is the unit bar, never the walks or proofs** (re-review X1). W0 changes it in its first Swift commit (W0 §1a, step 0b): its destination is the pinned Simulator read from STATUS.md (`DEST="${BAR_DEST:-id=$(sed -n 's/^UDID: //p' "$TOOLS/../Coverage/many-bodied/STATUS.md" | head -1)}"`), and its `xcodebuild test` line skips every walk and proof class (`-skip-testing:"Bindu FeedUITests/<Class>"` for each file matching `Bindu FeedUITests/W*Walk.swift` or `W*Proof.swift`, listed with `ls`). **Walks run singly:** `xcodebuild test … -destination 'id=<UDID>' -only-testing:"Bindu FeedUITests/W<k>Walk"`. **Proofs run singly, once per proof session:** `-only-testing:"Bindu FeedUITests/W<k>Proof"`. "Three clean runs" in any score means three runs of the bar.
- **Every wave:** the score's walk (below), the score's greps, the harness cases, a lineage check (nothing from an earlier build vanished — keep `LINEAGE.md`).
- **The new build reads `Live` ∪ `Staged`** (CONTRACT §2.3) in every Feed fetch — DEBUG and Release alike. W0 makes this change first (after step 0).

### Writes never reach his phone mid-build
- **DEBUG builds make no Airtable writes by default.** `AirtableWriter` in DEBUG appends `SANDBOX · …` to `writes.log` and returns a local landed id. Real sends happen only with the launch flag **`-HarnessWrites YES`** (W0 §15.2–15.3), which always turns on the BUILD PROOF marking with it.
- **Every Simulator walk in every wave runs with writes OFF**, unless the step is a proof step under W0 §15.2's proof rules. Proof steps: Feed rows are written `Status = Staged` (the installed build, main @ 275eabd, reads Live only, so it never sees them) and archived afterwards; App Activity proof rows are made invisible to 275eabd's own reads (W0 §15.2 lists each read path and the rule); any App Activity proof that cannot be made invisible to 275eabd is **deferred to delivery day** and listed in STATUS.md under `Deferred proofs`.
- **Read-back, archive and mark happen only through Debug launch flags that use the app's own token** (`-HarnessReadBack`, `-HarnessArchiveProofs`, `-HarnessMarkWindow`, W0 §15.3). No curl, no MCP, no Airtable web UI on the Mac. You never see, print or store the token.
- You never write story text or schema. If a wave needs data that is missing, the app must still look complete (missing is absent); the Done line is `OWED-TO-TRACK-1` and the walk runs on the harness fixture.

### Walks are XCUITests
- Write each wave's walk as `Bindu FeedUITests/W<k>Walk.swift` (the UI test target `Bindu FeedUITests` exists), one test per numbered walk step. Launch arguments go through `app.launchArguments` (never `-HarnessWrites` unless the step is a proof step).
- Gestures map: `tap()`; `press(forDuration:)` (G0 holds); `press(forDuration:thenDragTo:)` (Join, Carry, Turn's corner curl, the filament); `twoFingerTap()` (Pointy); `pinch(withScale:velocity:)`; `swipeUp/Down/Left/Right`; `coordinate(withNormalizedOffset:)` for canvas targets. Stillness is `sleep` with no input.
- For what XCUITest cannot synthesise (the two-finger 0.8 s hold that opens the Call, the VoiceOver magic tap, multi-finger rotations, the phone face-down), add **DEBUG-only shims** as launch arguments or hidden DEBUG accessibility actions (e.g. `-HarnessOpen call`), and record each in GESTURES.md as `walk shim`. The real gesture is checked on the device walk (W8 §6).
- **Speech in the Simulator:** walks never depend on the Simulator's speech recogniser. A step that speaks uses a harness-injected transcript (`-HarnessTranscript "<words>"`, W0 §15.3), which enters the same code path the recogniser's final result enters. Real speech is verified on the device walk at W8 (never on Neev).
- Each screenshot is an `XCTAttachment(screenshot:)` named `NN-<name>`, `lifetime = .keepAlways`. Export them after each run with `xcrun xcresulttool export attachments --path <xcresult> --output-path Coverage/many-bodied/evidence/W<k>/` and keep the score's `NN-<name>.png` names.
- VoiceOver checks use `XCUIApplication().performAccessibilityAudit()` plus label/value asserts. Dynamic Type: `xcrun simctl ui <UDID> content_size <size>`. Reduce Motion: `-UIAccessibilityReduceMotionEnabled YES` or the Simulator setting.
- A step that cannot be driven is marked `NOT DRIVEN · <reason>` in STATUS.md and becomes a device-walk item at W8. It is never marked passed.

### One pinned Simulator
- Create it once: `xcrun simctl create "Bindu Feed Walk" "iPhone 16" <newest installed iOS runtime ≥ 18>`. If the installed Xcode has no "iPhone 16" device type, use any available iPhone device type with an iOS runtime ≥ 18 and record which. Record it once in STATUS.md under `## Simulator` as a line of exactly the form **`UDID: <udid>`** (the bar reads it), plus a line `Runtime: <device type> · <iOS version>`. Never erase it, never create another for walks. Every wave, every `xcodebuild test` and every walk uses `-destination 'id=<that UDID>'`.
- "iPhone 16" / "iPhone 17" / "iOS 18" in any score means this device. Its keychain keeps the token, so the token is asked for once.

### Permissions
- The repo carries **`.claude/settings.json`** (re-review R13): an allowlist for exactly what the build needs — `git`, `xcodebuild`, `xcrun simctl` / `devicectl` / `xcresulttool` / `xctrace`, `swift`, `Tools/*.sh` and `Tools/*.py` (and `python3`), `plutil`, `say` / `afconvert` (the dance fixture), `open -a Simulator`, read tools (`ls`, `cat`, `head`, `tail`, `wc`, `grep`, `find`, `sed`, `awk`, `diff`, `jq`), and file edits inside the repo. It denies what reaches outside: `curl`, `wget`, `ssh`, `scp`, `xcrun altool`, `xcrun notarytool`, `xcodebuild -exportArchive`, `git push origin main`, `git push --force`. Do not widen it. Ashrey starts Claude Code with `--permission-mode acceptEdits` in the repo. If a permission prompt appears anyway, it is not a question to him beyond approving it; never ask him anything around it.

### Decisions, status, context
- **Decisions:** anything the score does not settle — decide by the house laws, record it in `DECISIONS.md` (date · W<k> · the call · the reason), keep going.
- **After each wave**, append to `STATUS.md`: wave, commits, every "Done means" line with its status (MET / OWED-TO-TRACK-1 / OWED-TO-SELF) and evidence path, deferred proofs, `NOT DRIVEN` steps.
- **Context:** do not stop for context — Claude Code compacts automatically; keep going. After every slice, keep `## Resume here` at the bottom of STATUS.md current (the exact next step), so a compacted or fresh session resumes exactly. A fresh session only ever starts from the resume prompt above.

## The only four things you ever say to Ashrey
1. **The token line**, once, only if the pinned Simulator shows the token gate. First add `NEEDS TOKEN IN SIMULATOR` to STATUS.md and bring the pinned device up on the token screen (`open -a Simulator`, the device booted, the app on its token gate). Then tell him, in one sentence: *"Please paste your Airtable token into the Bindu Feed Walk Simulator's token screen."* **Then end your turn.** When he replies — whatever he writes — re-run the step and continue. Never read, print, store or commit the token.
2. **The phone line**, once, only at W8 if Neev is not reachable for the install (W8 §7 step 3): *"Please connect your iPhone to this Mac, unlock it, and tap Trust if asked (Developer Mode must be on)."* **Then end your turn.** When he replies, re-run the step; if Neev is still unreachable, write `BLOCKED · NEEV NOT CONNECTED` in STATUS.md and send line 4.
3. **The final line**, once, at W8 after the install: *"It's on your phone. Tell the cloud session to flip."*
4. **The pause line**, only on a hard block that the house laws, the scores and DECISIONS cannot decide (never for context, never for a choice you can make): write the block in STATUS.md under `## Resume here`, then say *"The build is paused — the cloud session can read STATUS.md."* and end your turn.

Nothing else: no questions, no progress, no screenshots.

## The end (W8)
Follow `scores/W8.md` §4–§7 exactly. Track 2 does all of it alone; Track 1 is not running during the build and nothing waits for it. In short:
1. Full parity pass across W0–W8 (`PARITY.md`, your own verdict), the adversarial pass (three cuts — **the Lalita Pass is Ashrey's alone**; nobody else runs it), then:
2. Build Release (`-allowProvisioningUpdates`, `CURRENT_PROJECT_VERSION` = Neev's installed build + 1) and install on Neev with `devicectl` **without launching it**; confirm the install with `devicectl device info apps` (bundle `com.ashrey.bindufeed.Bindu-Feed`). No TestFlight (it notifies), no Xcode Run (it launches). **Then** the device walk (Release, on the pinned Simulator or another device, **never on Neev**) while the new build sits on Neev unopened; mark the walk's rows yourself with `-HarnessMarkWindow` and check the ledger yourself with `-HarnessReadBack` (W8 §6, §7 step 3a).
3. Only then merge `many-bodied` into `main` **locally** (W8 §7 step 5); never push `main` — Track 1 pushes it after the flip.
4. Write **`READY FOR THE FLIP · <sha> · <time>`** as the first line of STATUS.md, push `many-bodied` (this push always happens, whether or not earlier pushes were gated), and send the final line: *"It's on your phone. Tell the cloud session to flip."*
5. Track 1's steps begin only after `READY FOR THE FLIP`: it flips every Staged record to Live, applies `content/DELIVERY-DAY.md`, renames `Suit`/`Rhymes With` to their OLD names, and creates the composing pipeline with notifications off.
