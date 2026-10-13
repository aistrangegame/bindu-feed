# Readiness review — can Claude Code run W0 → W8 on the Mac without a hiccup?

*12 Oct 2026 · independent reviewer · read: HANDOFF-CLAUDE-CODE, CONTRACT, GAMEPLAN, scores W0–W8, STATUS, DECISIONS, content/DATA-OWED, DELIVERY-DAY, AUDIT-STAGED, the C-manifests, `Bindu Feed/CLAUDE.md`, `Tools/`, and the Swift tree at `8896616` (anchors spot-checked: `logStoryMet` :1304, `RhymeGate` :116, `offerLetter` :685, `CallView` :181 all where the scores say).*

## Verdict: **READY AFTER FIXES.** Do not paste the handoff prompt until all nine BLOCKERs below are applied.

The scores are unusually precise, and their line anchors are right. But nine things would stop Claude Code or send it the wrong way:

- It has no way to drive the Simulator walks.
- It has no Airtable access outside the app.
- One canon file it is told to copy exists nowhere.
- Three waves give `store.house` to three different types.
- CLAUDE.md's own house law forbids the Staged read.
- W8's delivery needs Track 1 halfway through the build.
- The walks would quietly change Ashrey's phone mid-build, through the real base and possibly through Xcode Cloud.
- Every wave's Done line is a hard gate, and some Done lines can only be met by Track 1 or by an Airtable choice that may never be created.

Each fix below names the file, the section and the text to add.

---

## BLOCKER (would stop or derail Claude Code)

### B1 · Simulator walks write to the real base, and the installed build on Neev reads those rows
- **Where:** every walk in W0 §7C, W3 §17.4, W4 §7.5, W6 §14.D, W7 §10.4 and W8 §6. Also W0 §6 steps 3, 4 and 8.
- **What's wrong:**
  - `AirtableWriter` sends every write from DEBUG too.
  - `275eabd`, which Neev runs, reads App Activity `Story Met` with no proof filter (`AirtableService.fetchMetStoryIDs` / `isTodayMet` :878–960). So **a walk that meets a story makes Ashrey's own Door "met" that day**: his Rite is skipped and the stars light.
  - `fetchActivityMarks` reads every Feed row, so marks appear in his Portrait and Weave.
  - The proof rows are written `Live` and archived only afterwards. Kept, Letter, Filament, Return and Ash Comment rows therefore show on Neev until then. A Letter `WHEN: the next time you call` can even arrive on his phone.
  - The proof Codex row shows in his Present river. The Author filter exists only in the new build.
- **Fix:** add to W0 §15.2, as a new bullet after "Who uses it":
  > **DEBUG sandbox (default).** In DEBUG, `AirtableWriter` does not send. It appends `SANDBOX · <kind> · <table> · <fields json>` to `writes.log` and returns `.landed("sbx-<uuid>")`. Reads are unaffected. Real sends happen only with `-RealWrites YES`, which `-W0WriteProof YES` / `-WriteProof YES` imply. Under real writes with the proof flag:
  > (a) Feed rows (Kept, Letter, Filament, Return, Return Answer, Ash Comment) are **created with `Status = Staged`** and `Name` prefixed `BUILD PROOF · `. The new build reads them; `275eabd` cannot see them.
  > (b) `Story Met`, `Veil Lifted`, `Walk Completed` and `Ash Replied` are never sent, because the installed build reads them as state.
  > (c) A Codex proof row is written with `Category = Health`, which the installed river hides (`codexQuiet`), and `Author = Feed build (W0 proof)`.
  > (d) `-HarnessArchiveProofs YES` PATCHes every proof Feed row id found in `writes.log` to `Archived`. Run it at the end of each proof session.
  > Record in DECISIONS that App Activity proof rows still add a day-mark to `275eabd`'s Portrait for the proof day (accepted).
- **Also:**
  - W0 §6 step 3: replace "Status Live … PATCH … by hand" with "Status Staged (sandbox rule a); archived by `-HarnessArchiveProofs`".
  - DELIVERY-DAY §5: add "skip any record whose Name starts `BUILD PROOF`".

### B2 · Airtable access outside the app is assumed, and the Mac has none
- **Where:**
  - W0 §6: "read the row back (MCP `list_records_for_table` or `curl`…)", "PATCH … by hand", "Track 1 then renames".
  - W3 §3.6 and §17.4 step 5 ("read it back").
  - W6 §14.D step 18 ("archive them").
  - W7 §8.4.
  - W8 §6 ("Track 1 marks them").
- **What's wrong:** Claude Code on the Mac has no MCP and must never read the token, so curl is out.
- **Fix:** add to W0 §15.3's flag list:
  > `-HarnessReadBack <recId|table:recId>` fetches the record by ID through `AirtableService` (the keychain token, never printed) and appends its fields (IDs → values, Body truncated to 200 characters) to `writes.log`. Evidence = that log line.
  > `-HarnessMarkWindow <ISO-from>` PATCHes every App Activity row with `Source App = Feed` and `Activity Date ≥ from` so that `Detail` gets the `BUILD PROOF · ` prefix. It also PATCHes every Feed row created in that window to `Archived` with the Name prefix.
- **Then:** in W0 §6, W3 §3.6, W6 step 18 and W7 §8.4, replace "read back" with `-HarnessReadBack`. In W8 §6, replace "Track 1 marks them" with "Track 2 runs `-HarnessMarkWindow <walk start>` from a DEBUG Simulator build immediately after the walk, before step 3".

### B3 · Nothing says how to perform the walks
- **Where:** HANDOFF "Every wave: the score's Simulator walk", and every score's walk.
- **What's wrong:**
  - `xcrun simctl` cannot inject taps, holds, two-finger holds, pinches or drags.
  - The only UI-test file is the launch template.
  - Without a stated driver, Claude Code will stall, or claim walks it did not do. CLAUDE.md §10 already records that exact failure.
- **Fix:** add to HANDOFF "How you work":
  > **Walks are XCUITests.** Write each wave's walk as `Bindu FeedUITests/W<k>Walk.swift`, one test per numbered step. Launch arguments go through `app.launchArguments`.
  > Gestures map as follows: `tap()`, `press(forDuration:)` (G0 holds), `press(forDuration:thenDragTo:)` (Join / Carry / Turn curl), `twoFingerTap()` (Pointy), `pinch(withScale:velocity:)`, `swipeUp/Down`, `coordinate(withNormalizedOffset:)` for canvas targets. Stillness is `sleep` with no input.
  > For what XCUITest cannot synthesise, add DEBUG-only launch arguments and record each one in GESTURES.md as "walk shim": the two-finger 0.8 s hold (`-HarnessOpen call`) and the magic tap (`-HarnessOpen call` as well).
  > Each screenshot is an `XCTAttachment(screenshot:)` named `NN-<name>`. Export them with `xcrun xcresulttool export attachments` into `evidence/W<k>/`.
  > VoiceOver checks use `XCUIApplication().performAccessibilityAudit()` plus label and value asserts. Set Dynamic Type with `xcrun simctl ui booted content_size <size>`.
  > A step that cannot be driven is marked `NOT DRIVEN · reason` in STATUS. It is never marked passed.

### B4 · W4's Leela-board canon file does not exist anywhere Claude Code can reach
- **Where:** W4 §3.2, which says to copy the `SQ` array and `ARROWS`/`SNAKES` from `/mnt/skills/user/a-strange-game/references/the-playing-side/leela-on-the-33.html` lines 112–146.
- **What's wrong:** the file is not in the repo. It is also not in this cloud's `/mnt/skills`: `grep -r "Plays anyway" /mnt/skills` finds nothing. Reader 07 cites it at lines 132–166, so even the line numbers disagree. The 33 questions and practices are authored canon and cannot be invented.
- **Fix (Track 1, before handoff):** locate the file (the aistrangegame repo or Ashrey's skill source). Write `Coverage/many-bodied/content/leela-33-canon.tsv` with columns `n · question · practice · hex · sealed(32)`, plus two lines `ARROWS: a→b …` and `SNAKES: a→b …` with the `why` strings removed.
- **Then:** in W4 §3.2, replace the `/mnt/skills…` sentence with "copy `Coverage/many-bodied/content/leela-33-canon.tsv` into `canon/leela-33.js`".
- **If the file cannot be found:** say so in W4, and build the board with the vertebra stories only (the landing card's step 3). In that case no square question is rendered.

### B5 · `store.house` is three different types, and one file name is used twice
- **Where:**
  - W3 §2: `@Published private(set) var house` is a `HouseLight`.
  - W6 §1: `store.house` is a `HouseLedger`, in `Store/HouseLedger.swift`.
  - W7 §2.2–2.3: `@Published var house = HouseConditions()`, plus a new `Services/HouseLedger.swift`.
- **What's wrong:**
  - Two files named `HouseLedger.swift` in one module fail with "filename used twice".
  - W6 §14.A's matrix greps `house\.note(` and `house\.(has|weight|…)\(`. Those cannot all be true at once.
- **Fix:**
  - W3: `store.house` → **`store.houseLight`** everywhere (§2, §5, §6, §9, §13, §14, §17).
  - W6: `store.house` → **`store.ledger`**. Its §14.A greps become `ledger\.note(` / `ledger\.(has|weight|ids|last|dwellByRoom)\(`.
  - W7: `store.house` → **`store.conditions`**. Rename its file to `Services/AirtableService+HouseRows.swift` and `fetchHouseLedger()` to `fetchHouseRows()`.

### B6 · CLAUDE.md's house law forbids the Staged read that the whole build needs
- **Where:** `Bindu Feed/CLAUDE.md` §6 :204 ("Every read gates on `{Status}='Live'`. No exceptions") and §10 :381 ("`Status='Live'` gate on every reader … No exceptions").
- **What's wrong:**
  - HANDOFF and CONTRACT both rank CLAUDE.md §10 *above* CONTRACT.
  - Read literally, Claude Code keeps `Live` only. All 2,312 Staged records then stay invisible: 338 stories, 8 rooms, 47 Calls, and the rest.
  - W0 §8 makes it worse: its "Do not touch" list repeats "`Status='Live'` on every read".
- **Fix:**
  - HANDOFF, "Read, in this order", add before item 1: *"The contract changes one house law, and that change is ordained, not a conflict. W0's first commit edits CLAUDE.md §6 :204 and §10 :381 to: 'Every read gates on `OR({Status}='Live',{Status}='Staged')` (CONTRACT §2.3, since W0); writes still set Status explicitly (the blank-Status lesson stands).'"*
  - W0 §8: replace the `Status='Live'` bullet with "the blank-Status law for **writes**; reads are Live ∪ Staged".

### B7 · W8's close needs Track 1 halfway through, and contradicts the handoff
- **Where:**
  - W8 §4 last line: "Track 1 reviews PARITY.md and writes its verdict … before §6".
  - W8 §7 step 1, whose check is "Track 1 has written its verdict".
  - W8 §6: "Track 1 marks them".
  - W8 §7 step 3: "Track 1 checks the ledger".
  - W8 §7 header: "Nobody tells Ashrey anything until step 9". HANDOFF step 3 instead has Track 2 tell him *"It's on your phone. Tell the cloud session to flip."*
  - The status strings disagree: HANDOFF uses `READY FOR THE FLIP`; W8 and DELIVERY-DAY §1 use `W8 · INSTALLED ON NEEV · <sha>`.
- **What's wrong:** Track 1 is not running during the build, so Claude Code waits forever, or skips a gate.
- **Fix, W8 §4:** replace the last line with "Track 1 reviews PARITY.md after delivery; this is not a gate."
- **Fix, W8 §7:**
  - Step 1's check becomes "—".
  - Step 3's check becomes "devicectl lists the app at the new build number".
  - Header: "Track 2 sends exactly one line after step 4 (HANDOFF); Track 1 sends step 9's line after the flip."
- **Fix, HANDOFF step 3:** write **`W8 · INSTALLED ON NEEV · <sha> · <time>`** (the DELIVERY-DAY §1 gate) at the top of STATUS.md, in place of "READY FOR THE FLIP".

### B8 · Xcode Cloud → TestFlight may fire on every push to `main`
- **Where:** `ci_scripts/` and `Bindu Feed/ci_scripts/`, plus `Tools/ci_set_build_number.sh` ("give every Xcode Cloud archive a build number"). HANDOFF says "Push to `main` after each slice".
- **What's wrong:** if the Xcode Cloud workflow starts on branch changes to `main`, every slice becomes a TestFlight build. That **notifies Ashrey**, and with TestFlight automatic updates it can **install mid-build on Neev**. The repo cannot show the workflow's start condition.
- **Fix (before handoff, Ashrey or Track 1 in App Store Connect):** set the workflow's start condition to Manual or tag-only, and record that in DECISIONS.
- **Also add to HANDOFF "How you work":** *"If STATUS/DECISIONS does not record that Xcode Cloud is manual, push to branch `many-bodied`, never `main`, and merge to `main` only at W8 step 2."*

### B9 · "Done means" is a hard gate, but some Done lines depend on Track 1 or on a choice that may never exist
- **Where:**
  - HANDOFF: "Do not start a wave before the previous wave's 'Done means' is met".
  - W0 §7D: "every coded write lands". After a 422 `INVALID_MULTIPLE_CHOICE_OPTIONS` this needs Track 1 to create the choice, and DATA-OWED says the MCP *cannot* create choices by schema.
  - Also W3 D1, W4 D1 and W7 D1, which are owed by Track 1 "by schema".
- **Fix, HANDOFF:** *"A Done line that can only be met by Track 1 or Ashrey (a choice to create, a verdict, a rename) is recorded in STATUS as `OWED · <who> · <line>` and does not block the next wave. Everything else blocks."*
- **Fix, W0 §15.2:** add *"a write queued for a missing choice is owed, not failed."*

---

## SHOULD-FIX (would cause rework or a wrong build)

**S1 · The Call signature fix has no owner.**
- CONTRACT §2.6 makes it "owed in W0", but no score assigns it.
- W0's Staged read surfaces the 47 body Call rows. `CallView.swift:181` (`Text("— Ashrey · \(a.spokenOn)")`) then signs body answers with his name.
- **Fix:** add W0 change **15.11**:
  > `CallView.answerLayer`: when the row's `Excerpt` has a `SIGNED:` line, sign `— <SIGNED> · <date>`; never the row's `Archetype`, never "Ashrey". Strip `SIGNED:` / `FROM:` lines from any rendered Excerpt. Walk step: a body answer shows its role.
- Also add it to W0 §7B's grep: `"— Ashrey ·"` may appear only inside the `SIGNED` fallback branch for rows that have no `SIGNED:` line.

**S2 · W1 contradicts W0 on `RhymeGate`.**
- W1 §2.3 ("`RhymeGate.received`… kept exactly"), §5.1 ("`RhymeGate.markReceived`") and §6 (`RhymeGate.received ∪ metStoryIDs`) all keep the name.
- W0 14.1 deletes `RhymeGate` for `ReceptionMemory`, and W0's `house_law.sh` greps `RhymeGate`.
- **Fix:** in W1, replace every `RhymeGate.received` / `markReceived` with `ReceptionMemory.received` / `.mark`, and replace the §2.3 row's text with "`ReceptionMemory` (W0) — kept, same key".

**S3 · W1's rhyme index would drop every new story's rhymes.**
- W1 §2.2 rule 1 says "Only **Live** stories … take part". A literal status check drops all 338 Staged stories' rhymes.
- **Fix:**
  > "Every story in `store.stories` (Live ∪ Staged; Type = Story only). A partner whose Type is Swatch, Second Letter or Waiting Role is never an edge (CONTRACT §2.6); the Swatch reads its host through its own `Rhymes`, W5."

**S4 · W5 rewrites `ArrivalKind` and loses W4's kinds.**
- W5 §2.1 drops W4's Door-slot kinds (`askYesterday, askNight, askBetween, doorWords, threeDoors, board, wager, seasonLetter`) and W4's `quiet` weight.
- **Fix:** add to W5 §2.1:
  > "W4's ask kinds move to `enum DoorAsk` (the Door slot when `ask(.door)` returns nil; W4 §2.3 weights unchanged). `wager` and `seasonLetter` stay overrides in R6 after `goodMorning`."

**S5 · Waiting Role reads conflict.**
- W6 §9.3 renders the tellings' `Excerpt`.
- W8 §1.1 and §8.B(2) forbid `Excerpt` in `fetchWaitingRoles`.
- AUDIT-STAGED: Body carries `seed: … · source: readers/…` on the tellings, and Excerpt carries it on every other role.
- **Fix:** in W6 §9.3, add:
  > "Use a separate `fetchWaitingTellings()` that requests Name, Body, Excerpt and Linked Story, and keeps only rows whose Body begins `⟪telling⟫`. Render Excerpt **only** for those rows. Never render Body (parse the mark, discard the rest)."
- In W8 §8.B(2), add "(the tellings fetch is exempt)".

**S6 · Planted seeds are built twice, differently.**
- W6 §9.4: Type `Planted Seed`, card **first** in its room, raw page from the row's Body.
- W8 §1.3: Type `Planted`, card **after** the stories, raw memo via `fetchMemo`.
- CONTRACT §2.4a says `Planted Seed`, and the 4 rows written use it.
- **Fix:** replace the body of W8 §1.3 with "Verify W6 §9.4 against `Planted Seed` rows (Archived = set aside, never requested)". Then change `{Type}='Planted'` and `fetchPlanted` throughout W8 (including App. A's standing prompt, which Track 1 owns) to `Planted Seed`.

**S7 · The room ring and `RoomCanon` are scored twice.**
- The ring: W0 15.4 (13 + 8 + n concentric rings) and W2 §3.3 (one circle at r 0.40 plus a two-column grid).
- `RoomCanon`'s fields are named differently in W0 (`chapter, wx, sky, turnLine`) and W2 (`arcChapter, weather, region, stayTurn`).
- **Fix:** in W0 15.4, say "build W2 §2's field names now (`arcChapter, weather, region, stayTurn`); the ring layout is W2 §3.3's — W0 builds only the list plus the 21 glyphs on one circle".

**S8 · Light motes are built twice.**
- W3 §3.5 draws static motes from `bindu.circuit.closed`. W6 §8.4 adds travelling motes via the ledger and `bindu.light.motes`.
- **Fix:** add to W6 §8.4: "replace W3 §3.5's mote drawing (delete it; LINEAGE: spirit survives)".

**S9 · The harness clock is defined late, and twice.**
- W3 defines `-HarnessClock HH:mm`; W4 defines `-HarnessClock yyyy-MM-dd'T'HH:mm`.
- W2's walk already needs 21:30, plus "harness clock +600 s ×4" for the Garden, before either exists.
- **Fix:** add to W0 §15.3:
  > "`-HarnessClock yyyy-MM-dd'T'HH:mm` (overrides `Harness.now()`, read by `localDayString`) and a DEBUG Turn row `advance 10 min` that adds 600 s to the harness clock."
- In W3 §17.3, replace `-HarnessClock HH:mm` with the ISO form.

**S10 · Several places still say new content is `Live`.**
- W2 §1.1 ("all `Status = Live`"), §1.5 (`{Status}='Live'`) and App. A ("Status Live").
- W0 15.6 ("Status Live").
- GAMEPLAN §8 ("Status Live").
- The header blocks win, but the body text misleads.
- **Fix:** edit each to "Staged; read Live ∪ Staged".

**S11 · Deferred items no later score picks up** (each needs a home in its named score):
- W0's "Carried → W2" list has two: "the rope by long press inside the story page and the river", and "RoomView's second tap opens the story" (GAMEPLAN §6, voice rooms). W2 builds neither. Add both to W2 Slice 20.
- W4 call 20 says GAMEPLAN §6's "Door's suits + mood colour choose the day's first grammar" belongs in W5. W5 never builds it. Add it to W5 §3.2.
- W4 call 20 says the GAMEPLAN §3.2 **Spine face** (33 vertebrae) belongs in W6. W6 never builds it. Add it to W6 §6 as a fifth eagle-eye figure.
- W3 §5.5 / "Carried → W5" says Leela drops are placed in `warmestRoom(for: .lalita)`. W5 never uses it. Add it to W5 §2.2's `leela` payload.
- W2 §3.1 says "records itself (**W0's stay record**)". W0 builds no stay record. Fix W2: "write `bindu.room.stay.<key>` = day (STATE row)".
- W2 §7.2 "the quiet ones" reads lifetime dwell from "W0 `stays`". That key is sentence stays. Fix: use `bindu.kathas.dwell.<id>`.

**S12 · GAMEPLAN items no score builds (MISSING).** Assign them, or rule them "held" in DECISIONS:
- §3.3 **Beat** ("tap with the heartbeat in Body stories"). GESTURES reserves it for W2; W2 never builds it.
- §3.3 **Trace** as a general move (a lit path to the next story along a glyph, weft or spiral). Only the Name's letters and W3's dot-draw exist.
- §3.9 **walked chains from the Field** (the awakening walk Kingdom → … → Maya; the spine walk).
- §3.10 **the completed yard**.
- §6 River: the **witness line** (Lalita noticing the week) and the **Wall of Voices**.
- §6 Hall/Floor row: **kept lines steer which voice holds the Rite**; **stays tune the next grammar's pace**; **released vows leave the Mirror pool**.
- §3.2 **Spine face** (see S11).
- Only **partly** scored:
  - "the ground wears the last room's weather" (W7 §5.1 only conditional);
  - "answers from any body" (needs S1);
  - "the rope in every register" (needs S11).
- **Suggested homes:** Beat, Trace and the completed yard → W2 Slice 20. Witness line and Wall of Voices → W6 §2. Walked chains → W6 §10. Steer, tune and vows → W4 §3.5 / W6 §9.1.

**S13 · Contrast script missing.** "The contrast script / contrast gate" is a Done line in W1 §3.5, W2 §15, W3 §17.4, W4, W7 and W8, but nothing in `Tools/` computes contrast.
- **Fix:** add to W0 §15.10:
  > "`Tools/contrast.py <fg> <bg> [alpha]` → WCAG ratio, plus `--oklch L` for paper variants. It is not one of verify.sh's seven."

**S14 · Run protocol gaps** (fix in HANDOFF):
- **Resume prompt.** Add its literal text: *"Continue the Many-Bodied build: read `Coverage/many-bodied/HANDOFF-CLAUDE-CODE.md`, then STATUS.md `## Resume here`."*
- **What Claude Code may say when it stops.** It may tell Ashrey exactly one of three things: the token line; `Paused at <slice> — paste the resume prompt in a new session.`; or `Connect and unlock Neev (Developer Mode on) — then paste the resume prompt.`
- **Pin one Simulator.** The scores mix iPhone 16 and iPhone 17. Each simulator has its own keychain, so each new device would ask for the token again. Add: create `xcrun simctl create "ManyBodied" "iPhone 16" <newest iOS ≥ 18 runtime>` once, never erase it, and use it for every wave. "iPhone 16/17, iOS 18" in the scores means this device. If no iOS 18 runtime is installed, any installed iOS ≥ 18 runtime is fine; record which.
- **Permissions.** Run Claude Code in a permission mode (or a `.claude/settings.json` allowlist, set by Ashrey before starting) that covers `xcodebuild`, `xcrun`, `git`, `python3` and `Tools/*.sh`. Otherwise approval prompts stall unattended waves.

**S15 · The W8 install step is wrong in detail.**
- §7 step 3 checks `com.ashrey.bindufeed`, but the bundle id is **`com.ashrey.bindufeed.Bindu-Feed`** (project.pbxproj).
- **Fix:** correct the id. Add `-allowProvisioningUpdates` to the `xcodebuild` line. Add: "Neev must be paired, unlocked and in Developer Mode. A development-signed build replaces a TestFlight install (same team `VADN2G8B83`; data and keychain are kept)."

**S16 · DATA-OWED.md's status column is stale.**
- It lists as "owed" W2-4, W3-2, W5-1, W5-3, W5-4, W6-2 to W6-5, W7-2 to W7-4 and W8-1. STATUS and the C5/C6/DATA-B manifests show all of them written (31 Swatches, 119 roles of which 22 have left, 30 Leela drops 818–847, 30 Constellations, 4 Planted Seeds, `Shakti`, Song links).
- Claude Code reads this file (HANDOFF item 5) and would log false "owed" lines.
- **Fix:** refresh the status column. Mark W6-6 (`content/W6-light-content.md`) as **absent: the build must handle both states; walk on fixtures**.

**S17 · W0 walk step 14/24 assumes on-device speech works in the Simulator.** It often does not (`supportsOnDeviceRecognition` is false).
- **Fix:** add to W0 §7C step 14: *"If the Simulator refuses on-device recognition, the evidence is the refused path (field empty, no error copy) plus a unit test of the fill-only-if-empty rule."*

---

## NOTE

1. **Two source-root conventions.** W0, W2, W4, W5 and W6 give paths relative to `Bindu Feed/Bindu Feed/` (repo-relative). W1, W7 and W8 say `Bindu Feed/Bindu Feed/Bindu Feed/` (relative to `~`). Add one line to HANDOFF: "the source root is `<repo>/Bindu Feed/Bindu Feed/`".
2. **CONTRACT §1 forbids what the scores require.** It lets Track 2 write only STATUS.md and DECISIONS.md under `Coverage/many-bodied/`, but the scores have Track 2 write GESTURES, STATE, LINEAGE, PITCH, PARITY, CONSTELLATION and `evidence/` there. Add them to §1's table.
3. **`/mnt/skills` references.**
   - W0 §3 (padakarshini G0): the numbers are inline, so this degrades gracefully.
   - W5 D2 and W6 D1: data is already written, so nothing is needed.
   - W8 §3.1 and App. A: these are Track 1's.
   - None blocks Track 2 except B4.
4. **The 900 band for runtime writes** (W0 §6 step 3: "Sort Order in the 900 band"; W0 §8) is not in CONTRACT §2.4. Add `900–999 · app runtime writes (Kept, Letter, Filament, vows) · app`.
5. **`⟪watch:⟫` appears on 7 stories**, against W4 D5's ≥ 12 across 8 rooms. The harness covers the walk. Note it in STATUS.
6. **W6 needs `Tools/fixtures/dance.m4a`.** Generate it (`say -o … --data-format=aac`, or `afconvert` on a tone) and do not ship it.
7. **`HoldEngine.completeForAccessibility()`** is used by W3–W6 but is missing from W0 §3's signature block. Add it there.
8. **GAMEPLAN cites `plan/reports/`;** the reports live in `readers/`.
9. **Lalita replies address "Ashrey, …" 33 times** in Staged children (AUDIT §5). This needs a coordinator call before the flip, not a build issue.
10. **Performance gates on the Simulator** ("no frame > 33 ms") are noisy. Allow re-measurement on the device walk.
11. **Evidence volume.** At roughly 300–400 PNGs, consider `git lfs` or downsampled screenshots.
12. **W6 D5 asks for four rooms** (Thread → Forge → Body → Return); C4 wrote five (+ the Wash). W6's logic (≥ 3 rooms) accepts it.

## Scale and realism — top risks (no contradiction with CLAUDE.md §10 beyond B6)
1. **W6 §2, the river inside `InstrumentView` at z = 0.**
   - Scroll vs axis lean is the PlayersView-fold failure shape (CLAUDE.md §10, fifth shape).
   - `.refreshable` is retired.
   - All "home" routes are rewired.
   - This is the highest-risk change in the build. Ask for a real-finger check on the device walk.
2. **W1 §4.1, Join on cards.** `LongPressGesture.sequenced(before: DragGesture)` inside a `LazyVStack`, with `.scrollDisabled` while held. XCUITest can verify it; it needs the device walk too.
3. **W2 per-glyph hit-testing** (the Name's trace) and the Wash's circular-gesture centroid. Plain SwiftUI `Text` gives no glyph rects, so these need CoreText/Canvas layout. They are feasible, but bigger than they read.
4. **W6 §8.2: 55 `LightHand` cases,** each with its own timing and a test. This is the largest single slice. Expect several context resets; the resume protocol (S14) matters here.
5. **Scope.** 17 slices, about 6,600 score lines, three clean test runs per wave and an XCUITest walk per wave. Plan for many sessions. Every slice must end pushed, with a `## Resume here`.

---

## Fixes applied (12 Oct 2026, on branch `many-bodied`)

Coordinator rulings were applied where they differ from the suggested fix (flag name `-HarnessWrites`; branch instead of an Xcode Cloud setting; one STATUS wording `READY FOR THE FLIP`; one message from Track 2).

| id | Where fixed |
|---|---|
| B1 | W0 15.2 (DEBUG writes off by default; proof rules a–e; the 275eabd read audit table; deferred proofs), W0 15.3 (`-HarnessWrites`, aliases), W0 §6 (steps 3–9, 11–13 rewritten: Staged Feed rows, 2000-01-01 App Activity rows, archive by flag), W0 §7C (walk writes off; step 12); every wave's walk header (W1–W7) "writes off"; W3 §3.6, W4 §5, W5 §9.6, W6 D steps 11/18, W7 §8.4 (proofs under the rules, deferral of first-written types); W8 §7 step 4 (deferred proofs after install); CONTRACT §6; HANDOFF "Writes never reach his phone"; DELIVERY-DAY §5 (skip `BUILD PROOF`); DECISIONS |
| B2 | W0 15.3 (`-HarnessReadBack` incl. `activity-since:`, `-HarnessArchiveProofs`, `-HarnessMarkWindow`, `-HarnessDump leela`); W0 §6 intro; W3 §3.6 and §17.4 step 5; W5 §9.6; W6 D step 18; W7 §8.4; W8 §6 (Track 2 marks) and §7 step 3 (ledger check); CONTRACT §6; HANDOFF |
| B3 | HANDOFF "Walks are XCUITests" (gesture map, `-HarnessOpen` shims in GESTURES.md, attachments exported to `evidence/W<k>/`, `NOT DRIVEN`); W0 15.3 (`-HarnessOpen`), W0 §7C header and steps 1, 22; walk headers W1 §8.4, W2, W3 §17.4, W4 §7.5, W5 §9.4, W6 §14.D, W7 §10.4; W8 §6 (`W8DeviceWalk.swift`, NOT DRIVEN items); CONTRACT §1 rhythm |
| B4 | W4 header item 6 and §3.2: canon is `canon/leela/leela-on-the-33.html` (SQ lines 132–166, ARROWS/SNAKES 169–170; care :106, begin again :105) and `canon/leela/18-leela-on-the-33.md`; App. A citation |
| B5 | W3 (`store.houseLight`, `WalkStore.shared.walk.*`, header item 7); W6 (`store.ledger`, `ledger.note/has/ids/last/dwellByRoom/weight`, §14.A greps, `WalkStore`/`HouseWalk`, header item 7); W7 (`store.conditions`, `Services/AirtableService+HouseRows.swift`, `fetchHouseRows`, `house-rows.json`, `bindu.conditions.*`, `-HarnessHouseRows`, header item 9); W6 §6.2 (four figures, `HouseYantra` beyond the pager); DECISIONS |
| B6 | HANDOFF "Read, in this order" item 0 and binding-order note; W0 header item 1 and §1a Step 0 (first commit amends CLAUDE.md §6/§10); W0 §8 (blank-Status law for writes; reads Live ∪ Staged); CONTRACT preamble; DECISIONS |
| B7 | W8 §4 (Track 2's own parity verdict; Track 1 review not a gate), §5, §6 (Track 2 marks), §7 rewritten (steps 1–6 Track 2 alone; `READY FOR THE FLIP · <sha> · <time>`; one message; Track 1 steps 7–12 after it; install by devicectl without launch, then merge `main`), §8 D/F/H, §10 calls 6 and 8, data-owed E-rows; HANDOFF "The end"; DELIVERY-DAY header, §1, §5–§7; DATA-OWED W8-6 |
| B8 | HANDOFF "The branch"; CONTRACT §1 (both tracks push `many-bodied`; `main` only at delivery); W0 header item 7 and §1; W8 §7 step 5 (merge after the install; push `main` only with Track 1's Xcode Cloud confirmation, else `MAIN MERGE NOT PUSHED`); DECISIONS (Track 1 owes that confirmation) |
| B9 | HANDOFF "Order and the Done means status convention" (MET / OWED-TO-TRACK-1 / OWED-TO-SELF; a wave closes when no OWED-TO-SELF remains); CONTRACT §1 rhythm 3; W0 15.2 (queued-for-choice is owed), §6 step 11, §7D; W3/W4/W7 headers (D1 owed, never blocking); DATA-OWED preamble; DECISIONS |
| S1 | W0 15.11 (CallView.answerLayer signs `— <SIGNED> · <date>`; strips `SIGNED:`/`FROM:`; `CallAnswerTests`; §7B grep; walk step 1 · 02b); CONTRACT §2.6 |
| S2 | W1 §0 P2, §2.3 rows, §5.1, §6 (`ReceptionMemory.received` / `.mark`) |
| S3 | W1 §2.2 rule 1 (every story in `store.stories`, Type Story only, no Status check) and the lit-word document frequency |
| S4 | W5 §2.1 (`enum DoorAsk`), §2.2 (`seasonLetter`, `wager` as overrides), §2.5 R6.5–R6.6 and R7 |
| S5 | W6 §9.3 (`fetchWaitingTellings()`; Excerpt only for `⟪telling⟫` rows; Body never rendered); W8 §8.B(2) exemption; W2 §1.5 (Waiting Roles fetch Excerpt-free) |
| S6 | W8 header item 9, §1.3 (verify W6 §9.4), `Planted` → `Planted Seed` throughout incl. App. A (PLANT writes `Body`), `fetchPlantedSeeds()`; DECISIONS |
| S7 | W0 15.4 (W2's field names `arcChapter`, `region`, `weather`, `stayTurn`; one circle at r 0.40 per W2 §3.3) |
| S8 | W6 §8.4 (replaces W3 §3.5's static motes) |
| S9 | W0 15.3 (`-HarnessClock yyyy-MM-dd'T'HH:mm` defined once; `advance 10 min` / `-HarnessAdvance`); W2 walk header and Garden row; W3 §17.3 and step 10; W4 §2.1 points to W0 |
| S10 | W0 15.6; W2 §1.1, §1.5, App. A; GAMEPLAN §8; CONTRACT §2 write rules and §2.5 |
| S11 | W2 §12a A–B and Slice 20 item 7; W2 §3.1 (`bindu.room.stay.<key>`); W2 §7.2 / §11 (`bindu.kathas.dwell.<id>`); W5 §3.2 (*the day's first grammar*); W6 §6.2 D (the Spine); W5 §2.2 (`leela` in `warmestRoom`) |
| S12 | W2 §12a C–E (Beat, Trace, the completed yard) and Slice 20 item 8; W6 §2.5 (witness line, Wall of Voices), §10.5 (walked chains), §9.1 (released vows); W4 §3.5 G (steer, tune); partly-scored items ruled in DECISIONS; CONTRACT §2.6 (`⟪yard⟫`) |
| S13 | W0 15.10 (`Tools/contrast.py`, `--min`, `--oklch`, `--selftest`) |
| S14 | HANDOFF: start and resume prompts verbatim; one pinned Simulator `Bindu Feed Walk` (UDID in STATUS.md); the only two messages to Ashrey (token line, final line); permissions note |
| S15 | W8 §7 step 3 (`com.ashrey.bindufeed.Bindu-Feed`, `-allowProvisioningUpdates`, project path `Bindu Feed/Bindu Feed.xcodeproj`, Neev paired/unlocked/Developer Mode, development build replaces TestFlight, team `VADN2G8B83`); W8 §6 archive line |
| S16 | content/DATA-OWED.md status column re-read from the base on 12 Oct (Waiting Roles 119 / 22 linked / 7 tellings; Swatches 31; Leela 818–847; Constellations 30; Planted Seeds 4; `⟪one more⟫` 14; `⟪watch:` 19; `⟪journey` 11; `Song` 143; `Shakti` 20; Unwritten 11901–11913); W6-6 marked absent (both states handled; fixtures) |
| S17 | W0 15.3 (`-HarnessTranscript`); W0 §7C step 14; HANDOFF; W4 §7.5; W8 §6 (real speech on the device walk, never on Neev) |

Also applied from the notes: N1 (HANDOFF source root), N2 (CONTRACT §1 table), N4 (CONTRACT §2.4 band 900–999), N6 (W6 `dance.m4a` generation), N7 (W0 §3 `completeForAccessibility()`), N8 (GAMEPLAN `readers/`). N5 is superseded by S16's read (19 stories carry `⟪watch:`). Not applied (no fix needed by Track 2 or a coordinator call): N3, N9, N10, N11, N12.
