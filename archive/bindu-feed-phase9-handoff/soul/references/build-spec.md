# Bindu Feed — Build Reference

## Story Engine — Airtable Write Protocol

When writing stories and comments to The Feed table:

### Story record POST body
```json
{
  "fields": {
    "Name": "Story title",
    "Type": "Story",
    "Status": "Live",
    "Body": "Full story narrative text",
    "Excerpt": "First two lines for feed card preview",
    "Room": "A Maya Game",
    "Flairs": ["Consciousness", "Metaphysics"],
    "Codex ID": "C-XXXX",
    "Source Date": "YYYY-MM-DD",
    "Last Activity Date": "YYYY-MM-DD",
    "Resonance": 0,
    "Sort Order": 1
  }
}
```

### Field Comment POST body (top-level)
```json
{
  "fields": {
    "Name": "S-XXXX-Sakshi",
    "Type": "Field Comment",
    "Status": "Live",
    "Comment Body": "The comment text",
    "Archetype": "Sakshi",
    "Linked Story": ["recSTORY_RECORD_ID"],
    "Comment Order": 1,
    "Resonance": 0
  }
}
```

### Field Comment POST body (threaded reply)
```json
{
  "fields": {
    "Name": "S-XXXX-Lalita-reply",
    "Type": "Field Comment",
    "Status": "Live",
    "Comment Body": "The reply text",
    "Archetype": "Lalita",
    "Linked Story": ["recSTORY_RECORD_ID"],
    "Parent Comment": ["recPARENT_COMMENT_RECORD_ID"],
    "Comment Order": 3,
    "Resonance": 0
  }
}
```

### Ash Comment POST body
```json
{
  "fields": {
    "Name": "ash-[ISO-timestamp]",
    "Type": "Ash Comment",
    "Status": "Live",
    "Comment Body": "Ash's comment",
    "Archetype": "Ash",
    "Linked Story": ["recSTORY_RECORD_ID"],
    "Parent Comment": ["recPARENT_COMMENT_ID"],
    "Comment Order": 999,
    "Resonance": 0
  }
}
```

### Last Activity Date PATCH
```
PATCH {baseURL}/{storyRecordId}
{ "fields": { "Last Activity Date": "YYYY-MM-DD" } }
```

---

## Fetching Codex Entries for Story Engine

Codex table: `tblDF4OCMcRoxkQjU`

Fields to pull per entry:
- `fld7SVzyyytaOx9HM` — Codex ID (C-XXXX)
- `fld7Q3KrdZHdpwJuK` — Entry number
- `fldxmZqObGiIoHHll` — Title
- `fldmj5FR78qRJrH1P` — Category
- `flded0x4jeFYq6PPW` — Games (linked/multi)
- `fld1f9uhQq9h8Vqyz` — Topics
- `fldnDrzQV5hI2iHVh` — Date
- `fld459YeVBZBgB8zh` — Raw transcript/content
- `fld07qLLRIgRTvi7q` — Summary

Filter for Maya Game entries not yet in The Feed:
```
AND({Type}='A Maya Game')
```
Sort by Entry number ascending.

---

## Existing Stories (already in The Feed)

```
rec0DReVXAssEftsn — The Two Who Were One (C-1052, A Maya Game)
recsFb4cRVDV3bZ9D — The Tool That Turned Into a Wall (C-1112, A Maya Game)
recqtocBjz9v8Os2c — Something Moving Under the Skin (C-1170, A Maya Game)
recQzT5RyQIwrGJCT — The Prison Made of Glass (C-1205, A Maya Game)
recDvyERweNlGqTJC — The Crossroads That Repeated (C-1236, The Descent)
reccN1gPgWevmTuHg — The Game That Couldn't Wait to Play With You (C-1330, A Maya Game)
```

When adding new stories, do not duplicate these six.
When processing new entries, check Codex ID against this list first.

---

## Batch Processing Workflow

Process 7 entries per session:

1. Pull 7 Codex entries from Airtable (sorted by entry number, skipping already-processed)
2. Read full content of each
3. Select which are story-worthy (typically 5–6 of 7)
4. For each story-worthy entry:
   a. Identify the Room
   b. Craft the story (300–600 words, Bindu + Lalita inhabited)
   c. Generate 3–5 field comments (appropriate archetypes only)
   d. Generate any threaded replies (1–2 max)
5. POST to Airtable in correct order (Story first → top-level comments → replies)
6. Verify each record was created (check returned record IDs)
7. Report: entries processed, stories created, comments written

---

## Quality Standards for Stories

A good Bindu Feed story:
- Opens with a specific image or moment (not an abstraction)
- Moves through something (discovery, recognition, turn)
- Has a closing line that lands — often one sentence that holds everything
- Never summarizes the Codex entry — transforms it
- Is in third person ("he" not "I")
- Reads in 2–3 minutes
- Has at least one sentence that could stand alone as a threshold sentence

A poor story:
- Starts with "In this entry..." or "Ashrey reflects on..."
- Lists insights without narrative movement
- Stays abstract without grounding in the body or a moment
- Has no turn — just a description of what was thought

---

## Threshold Sentence Pool

When a story contains a sentence that belongs in the launch screen pool,
add it as a new Threshold Sentence record:

```json
{
  "fields": {
    "Name": "The sentence text",
    "Type": "Threshold Sentence",
    "Status": "Live",
    "Sentence Weight": 3,
    "Sentence Source": "Story",
    "Sort Order": 42
  }
}
```

Weight guide: 5 = appears frequently, 3 = occasionally, 1 = rare (Bindu only).

---

## App Navigation (for Claude Code reference)

```
LaunchView → ContentCoordinator → RootView
                                    ├── RoomSelectionView → GameView → StoryDetailView
                                    ├── StoryDetailView → ArchetypeProfileView
                                    ├── AshVoiceView
                                    └── SettingsView
```

Navigation uses FeedRoute enum with NavigationStack value-based routing.
All transitions: cross-dissolve (.transition(.opacity)).
Back button: frosted ‹ circle, always top-left.
No tab bar.
