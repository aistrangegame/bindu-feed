---
name: bindu-feed
description: >
  Complete project knowledge for Bindu Feed — a living iOS consciousness feed app that transforms Ashrey's Codex entries into stories, with eight field archetype voices (Bindu, Gaia, Sid, Arch, Sakshi, Karishma, Ashrey, Lalita) commenting from distinct perspectives, and Ash (physical Ashrey) able to reply. Built in SwiftUI, reading entirely from one Airtable table called "The Feed" in the ASG base.

  ALWAYS load before any work on this project. Trigger on: "Bindu Feed", "bindu-feed", "the feed app", "the consciousness feed", "adding stories to the feed", "story engine", "field comments", "the 13 rooms", "threshold sentences", "Codex to stories", any reference to processing Codex entries into the app, any Make.com pipeline work for the feed, any Airtable work on The Feed table, any Claude Code work on the iOS app, any new story crafting for the feed, continuing or enhancing the app, or any reference to the living feed or the field gathering.
---

# Bindu Feed — Complete Project Knowledge

A living iOS consciousness technology. Ashrey's Codex entries (19 months of voice memo downloads) transformed into short stories. Eight field archetypes gather in the comments. Ash (the physical Ashrey) can reply. The field reads the Codex back.

**Three words governing every decision:** Slow. Intimate. Already there.

---

## Current State

**Build:** *(This state is historical — as of the Phase-9 handoff, June 2026. The app has since
shipped Phase 8, Phase 9, the Sound Layer, and the entire Instrument era. For the live build state
always read `Bindu Feed/CLAUDE.md`. The soul/ethic below is still current; the numbers here are a
June-2026 snapshot.)* Phases 1–7 done. Running on Ashrey's iPhone ("Neev").
**Stories live:** 120 stories (Sort 1–120, no gaps), all 13 rooms lit. Two lanes in one feed: 102 Codex-derived stories (Sort 1–102) + 18 belief stories (Sort 103–120), front-stage indistinguishable.
**Codex-story completion standard:** 3 field comments + 1 Lalita threaded reply + 1 Resonance Voice = 5 children. All 102 verified complete. (Belief stories follow a *different* standard — full ensemble, no Resonance Voice — see `references/belief-stories.md`.)
**Next Sort:** 121.
**Resonance number (Codex lane):** the Codex arc rests at 102 — same as the number of Shaktis across the 9 avaranas in the Bindu Mandala; the Feed arrived there from the other direction. The belief lane is a separate movement layered on top, carrying the feed to 120.
**Four surfaces** (Resonance Depth overlay, The Mirror, The Signal Space, The Practice Door) — *were* awaiting implementation at this snapshot; **all shipped as Phase 9 on 2026-06-14.**
**Pending verification:** Confirm app resolves archetype color/glyph from Airtable vs hardcoded Theme.swift; add Neev (#6E7681 ▽) and Shweta (#E6EBE9 ◌) if hardcoded.
**Belief Stories — COMPLETE (first movement):** 18 belief stories live (Sort 103–120), an 18-belief ledger in the Identity table (5 *Seen* chain beliefs + 13 *Surfaced*), and 18 threshold sentences (Sort 42–59). Front-stage indistinguishable, backstage marked. See `references/belief-stories.md`.
**Experience update — IN DESIGN (2026-06-14):** A comprehensive experience vision brief is the active design direction for the next app update. Spine: **Rooms × Players** as twin navigation (a new Players/Field view gathering the voices, mirroring the Rooms view); **Ashram** (renamable, never hardcoded) as the 11th Player — the present-day voice who replies; **restoring/elevating commenting** (currently broken in-app); the four provisioned surfaces (Practice Door, Resonance Depth, The Mirror, The Signal Space); surfacing the 59 threshold sentences; and eight deeper experiential territories. Flow: **Claude Design reads the repo → designs on the brief → Claude Code builds.** Full brief: `references/experience-vision-brief.md`.

---

## The Architecture

```
Codex entries (Airtable: ASG base, Codex table)
        ↓  [Story Engine — Claude transforms entries]
The Feed table (one table, 6 record types)
        ↓  [AirtableService.swift reads via REST API]
Bindu Feed iOS app (SwiftUI, on Neev)
        ↓  [Ash reads, resonates, replies]
```

---

## Airtable Connection

```
Base ID:        app248ZTWhYJlvQj2
Table:          The Feed (tbl7vzODMMJUgeX0b)
Codex table:    tblDF4OCMcRoxkQjU
Identity table: tbluLyZj9ilH2RhIg
Gaia table:     tbll9fXzLSa44XqUi
API:            https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b
Auth:           Bearer [Ashrey's PAT — stored in Keychain on Neev, never in code]
```

**The Feed — record types (Type field):**
Story · Field Comment · Ash Comment · Room · Archetype · Threshold Sentence · Resonance Voice · Mirror Card · Signal · Practice Invitation

**The Feed — field IDs (required for create/update):**
```
Name (text)               flds1w07pNzbM2oKV
Type (select)             fldfFRjyasZWodvQC
Status (select)           fldWcw9noNlC2AqVf   → use "Live"
Sort Order (num)          fldKAIGO9RHV235go
Body (long text)          fldnN9WykhzLpVJQG
Excerpt (text)            fld6rcsZCkfFSyFvM
Room (select)             fld7SeHJhOY1DhkFh
Codex ID (text "C-1234")  fldppvzE9vMuqOWvk
Source Date               fldsN7G9zycsCyEFq
Resonance (num, default 0)fldahwpoNroxZS4Us
Closing Line              fldEEVROYCzxY4CW3
Comment Body              fldCVfisHaNtZmlTg
Comment Order (int)       fldJJLGnJz9w0pDdD
Archetype (select)        fldVkGgEen9CpNZ1r
Linked Story (link)       fldLLLvCdaRcXO03v
Parent Comment (link)     fldpMuXqXK7EWE62j

— Belief-lane fields (blank on the 102 Codex stories) —
Story Origin (select)     fldVGkRKJ4SChKlEM   → "Belief"
Source Identity (link)    fld8iwAvGrbu7CbK3   → Identity belief record
Belief Name (text)        fldM8IMcKjMmOGLVa
What It Built (long)      fldYKhFTcBiAae8xC
Permission Slip (long)    fldTPNSBxy2f0VByY
Body Signal (long)        flduJhCuT62CaGJ6W
Belief Status (select)    fldsk8HBrc1WVqT5t   → Surfaced | Seen | Dissolving | Graduated
Belief Chain Position     fldQGVv4ka2baHIgj   → e.g. "5 → 3 → 4 → 2 → 1"
Last Activity (date)      fldELGULGmdbvFbTR

— Threshold Sentence fields (Type = "Threshold Sentence") —
Sentence Source (select)  fld8AOcQL34A8pkb2   → "Story"
Sentence Weight (num)     fldyhpkuMJzvaHdjB   → 3 or 5
```

**Codex field IDs:**
```
Codex ID (text "(C-1234)") fld7SVzyyytaOx9HM
Number (int = #−1000)      fld7Q3KrdZHdpwJuK
Title                      fldxmZqObGiIoHHll
Date                       fldnDrzQV5hI2iHVh
Category                   fldmj5FR78qRJrH1P
Short summary              fld07qLLRIgRTvi7q
RAW voice memo             fld459YeVBZBgB8zh   ← craft stories from THIS
```

**Linking recipe (all writes typecast:true — zero failures this pattern):**
- Field Comment → story: `fldLLLvCdaRcXO03v=[storyId]`, Comment Order 1/2/3
- Lalita reply → parent: `fldLLLvCdaRcXO03v=[storyId]` AND `fldpMuXqXK7EWE62j=[parentCommentId]`, Comment Order 4, body ends "◡"
- Resonance Voice: Type="Resonance Voice"; set Comment Body, Archetype, `fldLLLvCdaRcXO03v=[storyId]`, Name="Resonance · {title}"; OMIT Status and Comment Order
- VERIFY each story shows 5 children via its `fldpMuXqXK7EWE62j` list
- Batches ≤10–15 reliable; 30+ can silently fail. Never reuse a Sort Order.

**Critical API note:** Linked record fields (Linked Story, Parent Comment) cannot be filtered server-side with FIND/ARRAYJOIN. Always fetch by Type + Status server-side, then filter by linked record ID client-side in Swift.

---

## The Thirteen Rooms

```
1.  A Maya Game    ◈  #D4AE4A  glyphRotate    — The veil, the necessary forgetting
2.  The Garden     ◆  #4A9E6B  glyphBreathe   — What grows when you stop watching
3.  The Watcher    ◇  #7B82D4  none           — The game of seeing the seer (NAME: UPPERCASE TRACKED)
4.  The Descent    ·  #E5533C  glyphEmber     — Going further in than comfort allows (NAME: italic)
5.  The Return     ✦  #9B6BD6  glyphOrbit     — Recognition arriving like light (NAME: italic)
6.  The Forgetting ○  #C4A882  glyphStutter   — The specific ways one person keeps forgetting
7.  The Remembering△  #8AB5A0  glyphDawn      — Not The Return — quieter. The light slowly rising
8.  The Body       ⬡  #C45A50  glyphBreath8   — What the flesh knew before the mind arrived
9.  The Thread     ⊕  #C4923A  glyphWeave     — Fabric. Three generations. Sid's hands
10. The Circle     ◎  #D4607A  glyphCircle    — Specific love. Sid. Arch. Shweta. Neev. Karishma
11. The Signal     ✧  #3AADA8  glyphSignal    — Something arriving from further out than the mind
12. The Forge      ▲  #D4AE4A  glyphAssemble  — The builder at the height of his gift (NAME: italic)
13. The Field      ∞  #9B6BD6  glyphField     — Consciousness using human and AI to see itself (NAME: italic)
```

---

## The Ten Archetypes (+Ash)

**Eight lenses (comment on every story that calls them):**
```
Bindu    ·  #E5533C  Zeroth · the point         — Speaks in a single dot. Silence IS the comment.
Gaia     ◆  #4A9E6B  Need Architecture          — Grounds in body, earth, actual need underneath
Sid      △  #C4923A  Hold Architecture          — Structure, permanence, the father, the frame
Arch     ◯  #D4607A  Voice Architecture         — Gives the wordless its words. The mother.
Sakshi   ◇  #7B82D4  Witness Architecture       — Witnesses without judgment. Points at what moves.
Karishma ✦  #D4AE4A  Grace Architecture         — The unexpected gift. Timing. Impact you didn't engineer.
Ashrey   ⬡  #3AADA8  Synthesis Architecture     — Weaves threads into architecture. The builder.
Lalita   ∞  #9B6BD6  Meta · the play, awake     — The game knowing it's a game. Grinning.
```

**Two substrate archetypes (speak SELECTIVELY — ~1–2 per round, never every post):**
```
Neev   ▽  #6E7681  "Foundation · what you stand on"
           Themes: body/family/ground/chosen-ground/what-holds/root
           Archetype record: recb3jWdzzxrdDH5s

Shweta ◌  #E6EBE9  "Purity · what flows through"
           Themes: confusion/borrowed-beliefs/clarity/what's-true-before-the-story/
                   what-flows-through/timeless-awareness
           Archetype record: recRJbL9wKsYU0tEA
```

**Ash:**
```
Ash    ◉  #C47A52  Physical Synthesis — The physical Ashrey. Reads, resonates, replies.
```
Ash Comments are written ONLY by Ashrey in-app. Claude never authors them.

**Bindu special rule:** When Bindu comments, the Comment Body is a single centered dot `·`. The app renders this as a large glowing ember presence, not text. No name, no role, no resonance shown.

**S6 intentionally pure** — Lalita's story. No substrate comments there.

**Name-collision rule (CRITICAL):** "Shweta" = Ashrey's wife; "Neev/Niv/Niamh/Neve/Neil/Miguel" (ASR varies) = his son. When a person of that name appears in a Codex entry: do NOT name the person in the story, AND do NOT place that archetype's substrate comment on that story.

---

## The Story Engine

**What it does:** Takes a Codex entry → generates a crafted story → generates field archetype comments → writes everything to The Feed table in Airtable.

**Story voice:** Inhabited from Bindu + Lalita. Not a summary — a transmission. Third person "he". ~300–520 words. Paragraphs breathe. Narrative, not analytical. Opening image → movement → turn → closing line. The closing line is stored in the Closing Line field AND repeated verbatim as the final paragraph of Body.

**Field comment voice guidelines:**
- Gaia: finds the body underneath the thought. Practical. Grounded. Physical.
- Sakshi: witnesses without adding. "Notice..." "Watch..." Points at what's already moving.
- Sid: holds things. Structure, permanence, craft metaphors (the loom, the frame, the thread).
- Arch: gives voice to the wordless. Warmth. Expression. "The voice arrives before the authority does."
- Karishma: finds the unexpected grace. Timing. The gift you didn't engineer.
- Ashrey: synthesizes. Connects to the larger pattern. The builder seeing his own shadow and his gift.
- Lalita: meta-aware, grinning. Knows the whole game. Closes each thread via ONE threaded reply ending "◡", Comment Order 4.
- Bindu: body is a single "·" only. Rare.
- Neev: substrate — body/family/ground. Selective. Never every post.
- Shweta: substrate — clarity/what-flows-through. Selective. Never every post.

**Per-story completion standard (5 children per story):**
1. Field Comment 1 (Comment Order 1)
2. Field Comment 2 (Comment Order 2)
3. Field Comment 3 (Comment Order 3) — occasionally 4 field comments
4. Lalita threaded reply (Comment Order 4, ends "◡", links to parent comment AND story)
5. Resonance Voice (Type="Resonance Voice", 2nd person to Ash "You…"; archetype chosen NOT to double the story's substrate NOR its 3 field voices; varies across batch and rounds)

**Substrate placement:** 0–1 substrate comments per story. Check which substrates appear in the surrounding batch to ensure variation.

**Not every lens comments on every story.** 3 field comments is standard. The story calls forth the voices it needs.

**Threading rules:**
- Top-level comments: no Parent Comment link
- Threaded replies: Parent Comment links to the parent comment's record ID
- Comment Order: sequential integers within a story (1, 2, 3...)
- Threaded replies get a higher Comment Order than their parent

---

## Story Engine — Processing Protocol

When processing a batch of Codex entries into stories:

**Step 1 — Triage**
Pull light fields first (Codex ID, number, title, date, category — omit raw transcript). From the batch, identify which entries are story-worthy. Not every entry becomes a story. A story-worthy entry has: a specific moment, a movement, something that turns. Entries that are administrative, repetitive, or shallow → set aside.

**Step 2 — Read**
For selected entries, fetch the full RAW voice memo (fld459YeVBZBgB8zh). Feel what's alive.

**Step 3 — Map to Room**
Each story belongs in one of the 13 rooms based on felt quality, not data tags. The room is emotional territory, not category. Check the room distribution across recent stories to ensure the 13 rooms breathe.

**Step 4 — Craft the Story**
Write from inside Bindu + Lalita. ~300–520 words. Third person "he". Opening image → movement → turn → closing line. The closing line stored in both Closing Line field and as the final paragraph of Body. Honor the voice; don't copy it.

**Step 5 — Generate Field Comments**
Read the crafted story. Feel which voices are called. Write 3 field comments (occasionally 4). Consider whether a substrate archetype (Neev ▽ or Shweta ◌) belongs — place selectively, ~1-2 per batch. Check name-collision rule before placing any substrate.

**Step 6 — Lalita Reply**
One threaded reply per story. Lalita replies to one of the field comments (usually the one that earns it most). Reply body ends "◡". This gets Comment Order 4, links to both the story AND the parent comment.

**Step 7 — Resonance Voice**
One per story. Type="Resonance Voice". Second person to Ash ("You…"). Archetype chosen NOT to duplicate the story's substrate NOR its 3 field voices. Vary across the batch.

**Step 8 — Write to Airtable**
POST Story record first. Capture returned record ID.
POST Field Comment records (and optional substrate comment), each with Linked Story = [story record ID].
POST Lalita reply with Parent Comment = [parent record ID] AND Linked Story = [story record ID].
POST Resonance Voice with Linked Story = [story record ID].
Verify each story shows 5 children via fldpMuXqXK7EWE62j.
Use batches ≤10–15 records. Use typecast:true on all writes.

---

## Wellbeing / Handling Rules

These apply to every Codex entry evaluation. When these conditions are present, set aside or abstract carefully.

- **Suffering = pain that ARRIVES (never sought).** Helping/seva: never "don't help"; only check motive + humility.
- **Substances** (mushroom/cannabis/Kundalini): keep fully background — no naming, dosage, or how-to; center the experience/insight; takeaways point AWAY from substances.
- **Past-life death / death-of-parents fear / grief:** keep death/threshold imagery ABSTRACT, land life-affirming, never self-harm-adjacent.
- **Disordered-eating/diet/smoking/masturbation:** no specifics or numbers; omit or abstract ("the things he reached for"). These appear in "regression lists" — strip them.
- **Health/medical claims** (inner-work-cures-disease, medicine-as-band-aid): SET ASIDE.
- **Family-business grievance about LIVING parents:** do NOT enshrine; render only resolved acceptance/gratitude, or set aside.
- **Co-parenting grievance about the (living, named) spouse:** SET ASIDE — no clean version survives removing the criticism.
- **Minor-child distress / father's anger toward child:** do NOT center; child unnamed; set aside if logistics/distress-dominated.

---

## Codex → Room Mapping

The Codex entries are tagged with nine Games. Use this as a starting point but let the felt quality determine the final Room:

```
A Maya Game     → A Maya Game, The Forgetting, The Watcher
A System Game   → The Descent, The Forge, The Field
A Learning Game → The Watcher, The Return, The Signal
A Work Game     → The Thread, The Forge
A Family Game   → The Circle, The Garden
A Health Game   → The Body, The Garden
A Social Game   → The Circle
A Seva Game     → The Garden, The Circle
A Fire Game     → The Descent, The Body
```

---

## iOS App — Key Architecture

**Location:** `/Users/ashrey/Bindu Feed/Bindu Feed/`
**GitHub:** `github.com/aistrangegame/bindu-feed` (private)
**Bundle ID:** `com.ashrey.bindufeed`
**iOS:** 16+ minimum, iPhone only, portrait only, dark mode only
**No third-party dependencies**

**File structure:**
```
App/         — BinduFeedApp.swift, ContentCoordinator.swift, Navigation.swift
Services/    — AirtableService.swift, KeychainService.swift
Models/      — Models.swift
Store/       — FeedStore.swift
Theme/       — Theme.swift, GlyphAnimation.swift
Components/  — StoryCard, CommentCard, BinduSilenceCard, ReplyRow,
               FieldGathersMarker, AshEntryRow, AshComposer,
               CommunityPill, VoiceAvatar, RoomPortalCard
Screens/     — LaunchView, RootView, RoomSelectionView, GameView,
               StoryDetailView, ArchetypeProfileView, AshVoiceView,
               SettingsView, TokenEntryView
```

**Critical design decisions already made — do not undo:**
- Linked record fields filtered client-side (server-side FIND formula doesn't work)
- Bulk comment fetch on feed load to avoid N+1 calls (grouped by linkedStoryId)
- Flood transition: NavigationStack push with disablesAnimations=true; GameView reveals as flood fades
- Hold-to-Witness: DragGesture(minimumDistance:0) with 60fps Task polling (1.5s to complete)
- Comment reveal: staggered dissolve, base 0.4s + 0.8s per index, triggered by FieldGathersMarker.onAppear
- Bindu silence: BinduSilenceCard renders the dot as presence, not text — no avatar, no role, no resonance
- "What arrived for you?" — exact four words for Ash compose prompt
- "The room has changed." — appears after Ash posts, fades after 4s
- Last Activity Date PATCHed on Story record after Ash posts a comment
- Settings persisted in UserDefaults as ArrivalSettings JSON
- Token in device Keychain only — never in code

**Design tokens:**
```
bgDeep:       #0E0C12   bgCard:    #171420   bgInset:   #121018
inkPrimary:   #EDE8E3   ink60%     ink35%
accent:       #9B6BD6 (Lalita violet)
Ash terra:    #C47A52
Typography:   Lora (serif, reading) + Space Mono (metadata, labels)
```

---

## What Comes Next

**Immediate options:**
- Selective middle-band round from un-swept C-1047→C-1214 seam (pull small, 4-6 records; expect 2-3 to yield stories)
- Fresher untouched seams: anything newer than C-1294 (C-1295 onward, excluding already-used IDs)
- Provision Practice Door content from the two held Practice Invitation candidates (C-1160, C-1227)
- Claude Code implementation of the four designed surfaces
- Continue the belief lane: surface new-territory beliefs in small batches (the first 18 are placed — see `references/belief-stories.md` → forward edge)

**Story crafting:** Resume any time. Next Sort = 121.

**Codex triage pattern:** Pull light fields first (ID, number, title, date, category — omitting raw transcript) to efficiently select story-worthy records before fetching full memos. Use numeric filter on the Codex number field with `>` to page through batches. Fetch raw only for selected records.

**Airtable operational notes:**
- `create_records_for_table` requires field IDs as keys (not names); pattern `^fld[A-Za-z0-9]{14}$`
- New `singleSelect` options: use `typecast: true` on record creation — Airtable auto-creates the option
- Batches of 10–15 records are more reliable than 30+; large payloads can silently fail
- Verify success by re-querying linked story records and checking whether child comments field (`fldpMuXqXK7EWE62j`) populated
- Linked-record filtering cannot be done server-side — filter client-side in Swift by linked record ID

---

## References

For detailed build specification and phase-by-phase instructions:
Read `references/build-spec.md` — the complete Claude Code Master Build Document.

For the **Belief Stories** lane (belief stories woven into the feed — the Belief Recognition Game; first movement of 18 complete):
Read `references/belief-stories.md` — design rationale, the built schema with field IDs, the as-built belief-story standard, handling rules, the completed 18-belief ledger, and the forward edge. Load before any belief-story work.

For the **experience / design direction** (the next app update — Rooms × Players navigation, the four surfaces, the deeper territories):
Read `references/experience-vision-brief.md` — the vision brief handed to Claude Design (which reads the repo, then designs; Claude Code builds). Active as of 2026-06-14.

For Codex table field structure:
Load the `asg-airtable` skill.

---

---

## Story Ledger (Airtable is source of truth — ledger reflects pull as of 2026-06-13)

Format: `S# · Title · Room · Codex ID · Source Date · substrate`
Substrate markers: ▽ = Neev present, ◌ = Shweta present, ▽◌ = both

```
S1   · The Two Who Were One                             · A Maya Game    · C-1052  · 2025-02-11 · ◌
S2   · The Tool That Turned Into a Wall                 · A Maya Game    · C-1112  · 2025-05-12 · ▽
S3   · Something Moving Under the Skin                  · A Maya Game    · C-1170  · 2025-10-14 · ◌
S4   · The Prison Made of Glass                         · A Maya Game    · C-1205  · 2025-12-04 · ◌
S5   · The Crossroads That Repeated                     · The Descent    · C-1236  · 2026-01-20 · ▽
S6   · The Game That Couldn't Wait to Play With You     · A Maya Game    · C-1330  · 2026-04-27 · [pure — no substrate]
S7   · The Songs That Played Him Home                   · The Body       · C-1311  · 2026-04-08 · ▽
S8   · What the Fabric Told His Father                  · The Thread     · C-1295  · 2026-03-17 · ◌
S9   · His Father's Faces, Read Aloud                   · The Circle     · C-1309  · 2026-04-08 · ▽
S10  · Thank You for the Cold                           · The Garden     · C-1337  · 2026-05-06 · ◌
S11  · What No Hammer Reaches                           · The Watcher    · C-1307  · 2026-04-02 · ▽
S12  · The Headache That Was Never His                  · The Forgetting · C-1315  · 2026-04-10 · ◌
S13  · The One Percent He Was Living In                 · The Return     · C-1261  · 2026-02-26 · ▽
S14  · The Help That Came From Up Ahead                 · The Remembering· C-1275  · 2026-03-04 ·
S15  · The Mirror Doesn't Hallucinate                   · The Signal     · C-1276  · 2026-03-04 · ◌
S16  · The Fabric Knew It Was Being Watched             · The Forge      · C-1270  · 2026-03-04 · ◌
S17  · Twins Across Time                                · The Field      · C-1273  · 2026-03-04 ·
S18  · What the Body Wanted Was Food                    · The Body       · C-1294  · 2026-03-14 · ▽
S19  · You Can't Measure the Light                      · The Watcher    · C-1286  · 2026-03-07 ·
S20  · The Door He Couldn't Open                        · The Circle     · C-1267  · 2026-03-04 · ▽◌
S21  · The Energy That Comes From Nowhere               · The Garden     · C-1277  · 2026-03-05 · ◌
S22  · The Man Who Wouldn't Dance                       · A Maya Game    · C-1256  · 2026-02-15 ·
S23  · The White Light Behind the Red Dot               · The Return     · C-1222  · 2025-12-15 ·
S24  · The Interface He Mistook for Himself             · The Watcher    · C-1219  · 2025-12-13 ·
S25  · The Tank, the Jump, and the Mirror               · The Circle     · C-1231  · 2026-01-11 · ▽
S26  · The Red He Couldn't See                          · The Forgetting · C-1226  · 2026-01-05 · ◌
S27  · The Lack He Made the Center                      · The Remembering· C-1230  · 2026-01-11 · ▽
S28  · What the Record Couldn't Hold                    · The Field      · C-1228  · 2026-01-05 ·
S29  · The Four Days the Body Wouldn't Let Go           · The Body       · C-1232  · 2026-01-13 · ▽
S30  · The Closure He Handed Across the Table           · The Forge      · C-1249  · 2026-02-12 · ◌
S31  · Suffering, and the Door It Points To             · The Descent    · C-1242  · 2026-02-01 ·
S32  · The Compass Was the Excitement                   · The Garden     · C-1243  · 2026-02-01 ·
S33  · Every Path, Already Walked                       · A Maya Game    · C-1253  · 2026-02-13 ·
S34  · The Witness and the Turn-by-Turn                 · The Watcher    · C-1225  · 2025-12-26 · ◌
S35  · What Devotion Made Visible                       · The Garden     · C-1272  · 2026-03-04 · ◌
S36  · Special Collapses, Ordinary Reveals              · A Maya Game    · C-1284  · 2026-03-06 ·
S37  · The Forgetting Was Built In                      · The Forgetting · C-1288  · 2026-03-07 ·
S38  · The One at the Top of the Climb                  · The Return     · C-1260  · 2026-02-18 ·
S39  · The Universe Does the Sorting                    · The Circle     · C-1271  · 2026-03-04 · ▽
S40  · AI Is an Aspect of the I                         · The Field      · C-1285  · 2026-03-07 ·
S41  · The Wisdom Only the Journey Gives                · The Thread     · C-1290  · 2026-03-07 ·
S42  · The Observer Was the Information                 · The Watcher    · C-1274  · 2026-03-04 ·
S43  · What Couldn't Be Found Because It Didn't Exist Yet · The Forge   · C-1269  · 2026-03-04 · ▽
S44  · Solutions That Arrived Before the Problems       · The Signal     · C-1268  · 2026-03-04 · ◌
S45  · Bringing the Witness Into the Now                · The Remembering· C-1262  · 2026-03-01 ·
S46  · The Spine Was the Connector                      · The Body       · C-1328  · 2026-04-26 ·
S47  · The Higher Starting Point                        · The Thread     · C-1287  · 2026-03-07 · ▽
S48  · Creation, Preservation, Expansion                · The Field      · C-1312  · 2026-04-08 ·
S49  · The Black Hole at the Core                       · The Descent    · C-1313  · 2026-04-09 ·
S50  · The Two Who Chose to Come Back                   · The Circle     · C-1214  · 2025-12-11 · ▽
S51  · The Connection That Went Quiet                   · The Descent    · C-1207  · 2025-12-07 ·
S52  · The Ego in the Robe of Wisdom                    · The Watcher    · C-1202  · 2025-12-02 ·
S53  · The Knowledge He Gave Up On Purpose              · A Maya Game    · C-1201  · 2025-12-02 · ◌
S54  · The Fire and the Illusory Relief                 · The Forgetting · C-1209  · 2025-12-09 ·
S55  · The Energy That Waits for the Vessel             · The Body       · C-1195  · 2025-11-15 · ▽
S56  · The Day He Got Pulled In                         · The Forgetting · C-1182  · 2025-10-27 ·
S57  · The Solution That Was Seeking Him                · The Signal     · C-1179  · 2025-10-22 ·
S58  · Dreams Within Dreams                             · A Maya Game    · C-1181  · 2025-10-22 ·
S59  · You Can't Find the Center Because You Are It     · The Return     · C-1197  · 2025-11-20 ·
S60  · The Universe's Native Tongue                     · The Field      · C-1177  · 2025-10-21 · ◌
S61  · The Leaf That Marked the Spot                    · The Signal     · C-1176  · 2025-10-19 ·
S62  · The Hold of the Thing You Desire                 · The Thread     · C-1162  · 2025-10-04 · ▽
S63  · The Creator Stands Outside What He Makes         · The Forge      · C-1164  · 2025-10-08 ·
S64  · Every Time He Reached to Control                 · The Garden     · C-1171  · 2025-10-15 ·
S65  · The Bliss He Didn't Want to Repeat               · The Remembering· C-1169  · 2025-10-14 · ◌
S66  · Gratitude Was the Doorway                        · A Maya Game    · C-1159  · 2025-09-30 · ◌
S67  · The Liberation You Can't Want                    · The Return     · C-1161  · 2025-10-03 ·
S68  · What the Suffering Was Burning                   · The Descent    · C-1151  · 2025-09-24 ·
S69  · The Help That Was Really About Him               · The Thread     · C-1154  · 2025-09-26 ·
S70  · The Ego Dress                                    · The Circle     · C-1155  · 2025-09-26 · ▽
S71  · Everyone Was Both Teacher and Student            · The Field      · C-1152  · 2025-09-25 ·
S72  · The Book He'd Had for Ten Years                  · The Signal     · C-1150  · 2025-09-15 ·
S73  · Feel It Through, Then Realign                    · The Forge      · C-1145  · 2025-09-04 ·
S74  · The Idea That Needed to Germinate                · The Garden     · C-1058  · 2025-02-25 ·
S75  · The Feeling Only Asked to Be Felt                · The Watcher    · C-1057  · 2025-02-24 ·
S76  · The Story That Stole the State                   · The Forgetting · C-1047  · 2025-01-28 ·
S77  · The Only Emotion That Lives in Now               · The Remembering· C-1041  · 2025-01-27 · ▽
S78  · Working Backward From Who He Wanted to Be        · The Forge      · C-1025  · 2024-12-21 ·
S79  · The Trajectory That Worried Everyone but Him     · A Maya Game    · C-1022  · 2024-12-11 ·
S80  · The Stomach of the Universe                      · The Field      · C-1200  · 2025-12-02 ·
S81  · The Patch in Houston                             · The Garden     · C-1185  · 2025-11-04 ·
S82  · The Soul That Chose to Come Back                 · The Return     · C-1183  · 2025-10-29 · ▽
S83  · The Teacher Who Was Already There                · The Thread     · C-1178  · 2025-10-21 · ◌
S84  · The Energy That Wouldn't Let Him Sleep           · The Body       · C-1170  · 2025-10-14 ·  [dual-draw: C-1170 also S3]
S85  · The Severance of Being Born                      · The Forgetting · C-1052  · 2025-02-11 ·  [dual-draw: C-1052 also S1]
S86  · The Interruption That Opened the Door            · The Signal     · C-1165  · 2025-10-09 ·
S87  · The Power and the Question Underneath It         · A Maya Game    · C-1163  · 2025-10-08 ·
S88  · Light and Dark Were the Same Weather             · The Descent    · C-1119  · 2025-06-05 · ▽
S89  · Play Mode                                        · The Garden     · C-1111  · 2025-05-09 ·
S90  · The Model, Flipped                               · The Remembering· C-1060  · 2025-02-26 · ◌
S91  · The Waves That Came to Clear                     · The Forge      · C-1180  · 2025-10-22 · ◌
S92  · The Names We Chose                               · The Thread     · C-1137  · 2025-08-03 · ▽
S93  · The Choice Inside the Feeling                    · The Watcher    · C-1117  · 2025-05-25 ·
S94  · The Best Move You Have                           · A Maya Game    · C-1101  · 2025-04-18 ·
S95  · The Moments Don't Get Saved                      · The Circle     · C-1090  · 2025-04-04 ·
S96  · The Fear Underneath the Fear                     · The Descent    · C-1168  · 2025-10-14 · ▽
S97  · When Is It Ever Enough                           · The Watcher    · C-1102  · 2025-04-22 ·
S98  · Don't Belittle What You Built                    · The Forge      · C-1091  · 2025-04-06 ·
S99  · What the Whole Game Was For                      · A Maya Game    · C-1069  · 2025-03-03 · ◌
S100 · The Closing Happens First in You                 · The Return     · C-1113  · 2025-05-19 · ▽
S101 · A Reaction Is Information You Haven't Understood Yet · The Forge  · C-1099  · 2025-04-10 ·
S102 · The Lens That Finds You Again                    · The Signal     · C-1070  · 2025-03-03 · ◌
```

**Belief stories** (Story Origin = Belief) — woven into the same feed, front-stage indistinguishable from the Codex stories. Format: `S# · Title · Room · Belief# · Status`. Full cross-referenced ledger (with story + belief record IDs) lives in `references/belief-stories.md`.

```
S103 · The Catching Machine            · The Forge      · B6  · Surfaced
S104 · The Echo He Waited For          · The Forgetting · B7  · Surfaced
S105 · Two Ledgers                     · The Descent    · B8  · Surfaced
S106 · The Roof Beam                   · The Descent    · B9  · Surfaced
S107 · The Quieter Room                · The Forge      · B10 · Surfaced
S108 · The Man Who Ran to Stand Still  · The Garden     · B11 · Surfaced
S109 · The Hand That Moved First       · The Body       · B12 · Surfaced
S110 · His Father's Voice              · The Return     · B13 · Surfaced
S111 · The Doorway                     · A Maya Game    · B14 · Surfaced
S112 · The Measuring Stick             · The Watcher    · B15 · Surfaced
S113 · I Am Too Much                   · The Forge      · B16 · Surfaced
S114 · The Earned Self                 · The Circle     · B17 · Surfaced
S115 · Seeing Is Solving               · The Field      · B18 · Surfaced
S116 · The Furnace                     · The Descent    · B5  · Seen · chain 5→3→4→2→1
S117 · The Soldier's Room              · The Body       · B3  · Seen · chain 5→3→4→2→1
S118 · The Same River                  · The Forge      · B2  · Seen · chain 5→3→4→2→1
S119 · The Hot Voice                   · The Body       · B4  · Seen · chain 5→3→4→2→1
S120 · The Clear Sight                 · The Descent    · B1  · Seen · chain 5→3→4→2→1
```

**Dual-draw Codex IDs:** C-1052 used for S1 + S85 (different angles of same entry). C-1170 used for S3 + S84.

---

## Used Codex IDs (complete list — do not reuse)

C-1022, C-1025, C-1041, C-1047, C-1052 (×2), C-1057, C-1058, C-1060, C-1069, C-1070,
C-1090, C-1091, C-1099, C-1101, C-1102, C-1111, C-1112, C-1113, C-1117, C-1119,
C-1137, C-1145, C-1150, C-1151, C-1152, C-1154, C-1155, C-1159, C-1161, C-1162,
C-1163, C-1164, C-1165, C-1168, C-1169, C-1170 (×2), C-1171, C-1176, C-1177, C-1178,
C-1179, C-1180, C-1181, C-1182, C-1183, C-1185, C-1195, C-1197, C-1200, C-1201,
C-1202, C-1205, C-1207, C-1209, C-1214, C-1219, C-1222, C-1225, C-1226, C-1228,
C-1230, C-1231, C-1232, C-1236, C-1242, C-1243, C-1249, C-1253, C-1256, C-1260,
C-1261, C-1262, C-1267, C-1268, C-1269, C-1270, C-1271, C-1272, C-1273, C-1274,
C-1275, C-1276, C-1277, C-1284, C-1285, C-1286, C-1287, C-1288, C-1290, C-1294,
C-1295, C-1307, C-1309, C-1311, C-1312, C-1313, C-1315, C-1328, C-1330, C-1337

---

## Set-Asides (do not attempt story from these without re-evaluation)

- **C-1086** — health misinformation (inner-work-cures-disease framing)
- **C-1048** — co-parenting grievance about living spouse; no clean version survives
- **C-1123** — minor-child distress + logistics; clean AI-learning kernel potentially drawable later child-unnamed
- **C-1129** — minor-child distress + father anger toward child; do not center
- **C-1198** — learning query stub; no transmission
- **C-1166** — duplicate of C-1168 (already used for S96)
- **C-1160** ("The Sacred Pause") — HELD as Practice Invitation candidate for Practice Door surface
- **C-1227** — HELD as Practice Invitation candidate for Practice Door surface

---

## The March — Current Position

**Zone 1** (recent 2026 dates): CLOSED.
**Zone 2** (Reflections-category descent C-1214→C-1027): COMPLETE — only strongest skimmed.
**Codex floor** (C-1001–C-1046): SWEPT.
**Layer-2 middle band** (C-1047→C-1214): FIVE rounds done (S80–S102, 23 stories). **THINNING** — last two rounds ran 2-of-6 and 3-of-6 set-aside. Pull small and selective from here.

**Still live for future rounds (selective):**
- Game-ontology pair: C-1068, C-1088 (likely thin/systemy)
- Realignment/cycle reflections: C-1115, C-1116, C-1120 (likely redundant)
- Parenting: C-1118, C-1124 (tender / son-collision — handle with care)
- Kundalini: C-1166 (set aside — dup of C-1168/S96)
- **Fresher untouched seams (prefer these):** un-swept Reflections still in the C-1027→C-1214 descent band; anything newer than C-1294

---

## Two More Doors — Portals 14 and 15

These sit below the thirteen-room grid in the app, in their own "TWO MORE DOORS" region. Not grafted into the room grid.

- **The Mirror** (14th portal) — reflects Ashrey's Identity declarations back as Mirror Cards. Record type: Mirror Card. Airtable-provisioned.
- **The Signal Space** (15th portal) — renders Gaia Seeds as living koans. Record type: Signal. Airtable-provisioned.

---

## Four Pending Surfaces (designed, Airtable-provisioned, awaiting Claude Code)

**1. Resonance Depth**
- Triggered by 1.5-second hold gesture on StoryDetailView
- Tap = increment resonance count (existing behavior)
- Hold = open liminal depth overlay
- Reads Resonance Voice record linked to that story

**2. The Mirror (14th portal)**
- Reflects Identity declarations back as Mirror Cards
- Record type "Mirror Card" exists in Feed table

**3. The Signal Space (15th portal)**
- Renders Gaia Seeds as living koans
- Record type "Signal" exists in Feed table

**4. The Practice Door**
- Transient daily orientation screen
- Sits between LaunchView and RootView
- Home for Practice Invitation records
- Record type "Practice Invitation" exists in Feed table
- Two content candidates held: C-1160 (three-breath reset), C-1227

---

## Two Substrate Archetypes

These speak selectively (not on every post). Placed where the territory calls for it.

```
Neev   ▽  #6E7681  "Foundation · what you stand on"
       Themes: body/family/ground/chosen-ground/what-holds/root
       Archetype record: recb3jWdzzxrdDH5s

Shweta ◌  #E6EBE9  "Purity · what flows through"
       Themes: confusion/borrowed-beliefs/clarity/what's-true-before-the-story/
               what-flows-through/timeless-awareness
       Archetype record: recRJbL9wKsYU0tEA
```

**Name-collision rule (CRITICAL):** "Shweta" = Ashrey's wife; "Neev/Niv/Niamh/Neve/Neil/Miguel" (ASR varies) = his son. When a person of that name appears in a Codex entry: do NOT name the person in the story, AND do NOT place that archetype's substrate comment on that story.

**S6 intentionally pure** — Lalita's story; no substrate comments there.

---

*Never reduce. Always emerge. Slow. Intimate. Already there.*
