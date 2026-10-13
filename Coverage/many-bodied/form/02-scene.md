# Form 02 · Scene and visual form — rupakarshini

*Form pass, lens 02, 12 Oct 2026. Lens: everything the eye meets, including colour, ground, material, type, glyph, figure, motion of light and density, across the app as built and the app after W0–W8 as scored.*

**What I read.** `FORM-BRIEF.md`, `AGENT-COMMON.md`, GAMEPLAN (all), CONTRACT (all), CLAUDE.md §1–9 and §10's headings, and readers 01, 02, 13, 14 and 21 together with READINESS-REVIEW. All of W1 §3–6 and all of W2. W3 §2 and §4–12. W4 §3.2–3.4 and §3.11–4.4. W5 §4. W6 §2, §6–7 and §10. W7 §7. W0 §15.4–15.7. For the rest of each score I read the structure and grepped every hex, ground, type size and tier value.

From the app: `Theme/` in full, the Turn rows, ArchiveBookView, LalitaPlay and LightView's grounds, plus a grep of every colour literal and type size in the Swift. Rupakarshini: SKILL, brief, shapes S1–S17, worlds (chassis A, B and C), elements, verification, research, site-v3, spine.css, scales.css and feed.css. The design-corpus lineage. Elements-corpus §6.1, the full §6.2 (the Point, axis, ceremony, sound, figures, Field, Mandala, Learning, Lalita and play engines), §6.3, §6.4 (all fourteen Feed screens), §7 and the 140-prototype ledger. Elements-catalog-v2 only through reader 13.

**Every number below is measured** with a WCAG 2 / CIEDE2000 / OKLCH script, including Machado deuteranope and protanope simulation. The script and its outputs are in `scratchpad/form02/` (`col.py`, `rooms.py`, `cross.py`, `tokens.py`).

---

## 1 · First principles (the laws the whole app's visual form obeys)

1. **One channel, one meaning.** Each visual channel carries exactly one kind of fact:
   - hue = place (a room, and the presences who are its kin);
   - material = teller (paper · linen · stone);
   - bone thread with mark geometry = rhyme;
   - light, carried by form and contrast = relationship;
   - the red point = the One;
   - gold = his own hand;
   - paper = the record;
   - ground lightness = depth;
   - ground warmth = the house.

   *Why:* rupakarshini law 13 asks of every mark whether it could belong to anything else. If two systems share a hue, the eye cannot answer.
2. **Tokens, never literals** (rupakarshini Tokens Canon; research §7, "~15 semantic role slots that couple colour to purpose"). Every colour, ground, type size and duration is read from one theme file, and room identity is read live from the base. *Why:* the app has drifted to 114 literals, and the scores add 65 more.
3. **One identity, seen whole** (law 25). A room or presence is one record: glyph, hex, motion signature, sky armature, hero geometry, name-hand and root. No other surface wears its glyph or hex. *Why:* that one record is how 21 rooms stay recognisable at 22 pt.
4. **The ground is a position** (law 2). Lightness says how deep he is: the Light is pale, the sky dark, the field darker, and prayer and under-the-floor darkest. Warmth, never lightness, says how met the house is. *Why:* both the axis and W3's warming house want the ground, so they must use different dimensions of it.
5. **Dark always; paper is a held sheet.** The ground is never pale, except the Light (canon, the one pale register) and LalitaPlay (as designed). Paper appears only as a sheet held on night, with night visible around it, and it dims at night. *Why:* the phone is read in low light (Gate 5; S14 "phone; low light"), and a full-screen cream page after 21:00 is a flash.
6. **Light, never locks, by form as well as light** (law 14). The five tiers are here · open · ground · ahead · veiled. Each must clear 3:1 and is told apart by form (filled → hollow → dashed), never by opacity alone. Tiers apply to marks and stars only, never to story text. *Why:* the access floor ("dim marks ≥ 3:1", CONTRACT §7), plus the house's law that rhyme never sets a tier.
7. **Text is full ink or it is decoration** (law 6). Readable text is ink.1, ink.2 or ink.3, every one of them ≥ 4.5:1 solid. A 35 % ink is never text. *Why:* `inkTertiary` measures 2.81:1, yet it carries readable lines throughout the scores (41 occurrences).
8. **Colour never carries identity alone.** A room hue always travels with its glyph, figure or name, because seven room pairs collapse for a deuteranope or protanope (§3.4). *Why:* access, and a person in low light.
9. **Every place moves as what it is** (law 8). Motion signatures are unique by form × period across all 21, and the dot breathes slowest at the centre (law 7). *Why:* a place is known by its tempo before its name.
10. **Every figure is the structure of its subject** (laws 12–13; chassis B's drawing law of five marks: point, line, arc, triangle and ring). The new rooms add one sanctioned sixth mark, **the square** (the page, the layer, the counter, the fold). Every figure is a pure function of (t, n, hue, progress).
11. **One particle, never re-made** (law 1). There is one red point per screen. It is built once and carried as state; nothing else is that red.
12. **Lora reads, Space Mono structures.** A third face appears only at a crossing that means something: under the floor (law 9). New text uses the type tokens only.
13. **Density is light, never "+N"** (law 15; GAMEPLAN law 1). At 469 stories, crowding is answered by alpha, lanes and proximity, never by a number or a "more" label.
14. **Crossings pass through something, and each crossing means one thing** (laws 3–4):
    - the dissolve and its bloom for every move;
    - the flood into a room;
    - the blink from the Door only;
    - the passage on the axis;
    - the Descent into what lies under the floor.
15. **The quiet state is designed first** (law 19). Every surface is complete at zero.

---

## 2 · The app today through this lens

### 2.1 What is one system already (keep, it is good)
- **The feed chassis is coherent where the comps were followed:**
  - ground `#0E0C12`, card `#171420`, inset `#121018`;
  - ink `#EDE8E3` at three steps;
  - Lora plus Space Mono only;
  - dawn gold `#C9A07A`;
  - the particle `#E5533C`;
  - the 11 presences;
  - the 8 day colours;
  - the Point's 7 world hues plus the centre `#C0392B`.

  `tokens/worlds/feed.css` is a faithful mirror of it.
- **The 13 rooms are true identity records.** Each has a glyph, a hue, a bespoke name-hand (`RoomStyle`) and a motion signature (`GlyphAnimation`, 13 distinct forms). It also has a hero gradient whose geometry means something, and a sky armature: tetractys · beam · funnel · phyllotaxis · rhombi · mandorla · lemniscate · braid · hex · broken ring · closing ring · concentric · orbit.
- **Nine of the 13 room hues are presences' hues:**
  - the Descent is Bindu;
  - the Garden is Gaia;
  - the Watcher is Sakshi;
  - the Thread is Sid;
  - the Circle is Arch;
  - the Signal is Ashrey;
  - the Field is Lalita;
  - A Maya Game and the Forge are both Karishma.

  This is a real rhyme of place and presence, and it should be named as the system, not treated as coincidence.
- **Crossings are already dissolve-only.** Nothing slides. The flood, the blink and the passage are each spent on one meaning.
- **Mono case is enforced by the type system** (`spaceMonoTracked`, `MonoCase`). This is the right instinct: a law with a mechanism behind it.

### 2.2 Where today's app has already drifted (before any score)
| Surface | Finding (measured) |
|---|---|
| **Colour literals** | **114 distinct hex literals and 55 inline `Color(.sRGB …)`** in Swift. `BinduTheme` defines about 20. Tokens Canon is broken at scale. |
| **Near-black grounds** | **About 25 distinct near-blacks**, between L 0.11 and 0.21 (`#050408 #07060A #08070B #08070D #09080C #0A0806 #0A0810 #0A0A0C #0B0A0C #0C0A08 …`). Most pairs differ by **ΔE < 3**, so they are one ground spelled 25 ways and carry no position. |
| **Type sizes** | **Lora at 33 distinct sizes** (9 → 54 pt). **Space Mono at 15 sizes, with about 224 of 257 `spaceMonoTracked` uses at 8–10 pt.** Rupakarshini's floor is 11. The comps author 8–10, so existing sizes stand as designed, but new work needs a floor (§4.3). |
| **Low-contrast text** | `inkTertiary` (ink at 35 %) measures **2.81:1** and is used for readable lines: hints, captions, "nothing has returned yet". `inkMuted #94908F` (6.15:1) exists (Slice 4b) and is under-used. |
| **Duplicate room colours** | A Maya Game and the Forge share `#D4AE4A`; the Return and the Field share `#9B6BD6`. **ΔE = 0** for both pairs. |
| **Turn glyphs reuse room identities** | `rite` is ◆ in `#4A9E6B`, which *is* the Garden's identity. `universe` ✧ is the Signal's glyph. `point` · is the Descent's glyph, in near-Descent red. |
| **Full-screen pale** | LalitaPlay (cream `#F3E9D8` full screen) and the Light (canon stone) are the only two. Both are designed, and stay. |

---

## 3 · The app after W0–W8 as scored: where the scores, added together, break the one system

### 3.1 Nine colour systems, ~110 hues, 14 exact collisions across systems
The scores add **65 new hex literals** (103 across W0–W8). Layered on the app's systems:

| System | Count | Source |
|---|---|---|
| Rooms | 21 | W2 §1.1 |
| Presences | 11 | as built |
| Day colours | 8 | as built |
| Point worlds | 7 + centre | as built |
| Places | 7 | as built |
| **Rhyme-family accents** | 12 | W1 §3.5 |
| **Teller colours** | 15 | W6 §7.1 |
| **Held-room lights** | 16 | W3 §12.2 |
| Face lights | 5 | W3 §2 |

Measured collisions (ΔE2000):
- **Teller = rhyme accent, ΔE 0, eight times.** `#8FA9C8`, `#C98A6B`, `#B7C99A`, `#D9B97A`, `#B79BD9`, `#7FB8B2`, `#A9B86E` and `#9CC0DE` are both a rhyme family (W1) and a teller (W6). In the sky, a teller constellation (W6 §7.1) and a rhyme thread (W1 §3.6) can be the *same colour meaning two different things*.
- **Teller = room, ΔE 0, five times:**
  - Shakti = the Circle `#D4607A`;
  - Body = the Body;
  - Lineage = the Forgetting;
  - Cosmos = the Old Light;
  - Silence = the Unwritten.

  A Shakti star's ring would read as "a Circle story".
- **Held lights against rooms.** **14 of the 16 held lights fail W3's own rule** (ΔE ≥ 10 from all 21 rooms):
  - the Loom is ΔE 2.9 from the Forgetting;
  - the Open Bolt is ΔE 3.0 from the Forgetting;
  - the Summit is ΔE 4.5 from the Unwritten;
  - the Temple is ΔE 5.3 from Maya.
- **Return against Company.** W2's new Return `#B9A3EC` is ΔE 4.0 from the Company teller colour `#B79BD9`, which is also rhyme accent a4.

**Verdict: today it is one system; after the scores it is several.** Each score designed its own palette for its own layer, and the layers meet on the same surfaces: the sky, the river, the Cloth and the Book.

### 3.2 The ground stops being a position
- **W3 §6.1, the warming house:** `#0E0C12 → #1A1208 → #2B2318` lifts the river's lightness **L 0.16 → 0.26**. That makes z = 0 lighter than the sky band above it (`#08070B`, L 0.13) and pushes it toward the Light. The house's warmth and the axis's depth then fight over one channel (law 4). At w = 1, `inkMuted` falls to 4.90:1 and the Ground room's mark to 3.15:1.
- **New grounds are another near-black each, no two telling apart:**

  | Surface | Ground |
  |---|---|
  | Board and Draw | `#0B0A10` |
  | one-line floor, name rite, the Stack's dim | `#050407` |
  | Recitation | `#06050A` |
  | Gates | `#09070D` |
  | House | `#08070B` |
  | Cloth | `#0B0A0E` |
  | Old Light | `#05060C` |
  | confession | `#1A1424` |
  | dark paper | `#16120E` |

  Rupakarshini gives each register **a material** ("tell where you are with the words covered"). The scores give each one ΔE < 3 of black instead.

### 3.3 Dark-always is broken six times
Full-screen pale pages:
- the interlude (W0 15.6, `#F3E9D8`, between any two stories);
- the first line (W3 §8, same page);
- the Good Morning letter (W5 4.9, a third cream, `#F4EFE6`, "the whole screen near-white");
- the Board's read-back page (W4 3.2);
- the Season Letter (W4 4.1);
- the *founding* silence ending (W2 12.1, the page goes cream for 2.4 s).

Several of these land at night by design: the interlude fires at the harness clock 21:30, and the founding ending on any story. Meanwhile **six spellings of one cream**, each pair ΔE 0.8–2.7, carry one role: `#F2EADB #F3E9D8 #F4EFE6 #EDE3D0 #EDE3CE #EDE6D6`.

### 3.4 The 21 rooms: distinctness and contrast, measured
- **As scored (W2 §1.1 with its §1.2 fix):**
  - normal-vision minimum ΔE: Descent/Body 7.7 and Maya/Thread 8.7 (both pre-existing; every other pair ≥ 11.3);
  - all 21 ≥ 3.96:1 on `#0E0C12`.
- **But for colour-blind vision three new rooms collapse onto old ones:**

  | Pair | Simulated vision | ΔE |
  |---|---|---|
  | Fold `#F0A49A` / Remembering | protanope | 2.0 |
  | Ground `#8C6A4A` / Body | protanope | 2.0 |
  | Counter `#A3A84E` / Thread | deuteranope | 3.0 |
  | W2's new Forge `#E8793A` / Thread | deuteranope | **0.9** |

  The warm side of the wheel holds gold, tan, umber, brick, red, orange, coral and olive. It is saturated, and no orange avoids it for a deuteranope (12 candidates tested). Glyph, figure and motion must carry these rooms (law 8).
- **Text in room colour fails:**
  - the Ground is 3.96:1 on the field and 3.69:1 on a card;
  - the Body is 4.26:1 on a card;
  - the Field is 4.03:1 on the warm ground.

  Yet the scores set readable text in `c`: the Ground's landing line "in `c` brightened 30 %", every lit word, the Old Light's past-tense units, the Name's meaning, the Return's tile, and the room-coloured titles.

### 3.5 Light tiers done as opacity fail 3:1
A room mark needs **alpha 0.39 (Old Light) to 0.75 (Body)** just to reach 3:1 on the field. Scored status marks below that:

| Score § | Status mark | Opacity |
|---|---|---|
| W1 §6 | Verb Mala bead at rest | 0.30 |
| W3 §4.1 | Cloth slub | 0.30 |
| W3 §7.6 | Tree dot, not yet received | 0.35 |
| W3 §12.1 | held light | 0.18 |
| W4 §3.2 | Board bead, never landed | 0.32 |
| W6 §6.3 | light lens: *ahead* | 0.30 |
| W6 §6.3 | light lens: *veiled* | 0.16 |
| W6 §6.2 D | Spine beads | 0.32 |

Readable text at sub-floor ink (each line below is text, at or near `inkTertiary` 2.81:1 or lower):
- W2 §5.2: the Waiting Room's roles;
- W2 §12.2: the held sentence, at `inkTertiary` × 0.55, about 1.6:1;
- W2 §7.2: "nothing fell";
- W4 §3.2: the care line, at inkTertiary × 0.62 on an ordinary day (0.92 only on a low day);
- W5 4.9: the mono line `#8A7A66`, 3.5:1 on paper.

### 3.6 Identity collisions: glyph, motion, the dot
- **Turn rows reuse room glyphs.** The Turn grows from 12 rows to about 24:
  - W0's Turning is ∞ in teal, which is the Field's glyph in the Signal's colour;
  - W0's Old Story is ◯ in the Forgetting's tan;
  - W0's rope is ○, the Forgetting's glyph;
  - W4's Draw is ◇, the Watcher's glyph;
  - W6's Whole House is ⊙, the Signal Space's glyph.

  W3's held table repeats ⌂ (the Temple and the House) and uses ⊙ (the Inner Field) again.
- **Motion signatures repeat.** The Unwritten (`glyphStill`, W2 §3.1) is as still as the Watcher. The Name's figure is `glyphAssemble`, which is the Forge's own.
- **More than one red point on a screen.** W4's die pips are drawn in `colorBindu` beside the bindu token, so six to seven red points sit together (law 1). The red point is also re-made in at least twelve places: RiverDot, HidingDot, the close dot, the RoomRing centre, the Board token, the Book cover, the interlude, the confession, the Seam, the reverse dissolve, the Journey ring and Rings. Nothing says these are one particle.
- **The ring of 21** (W2 §3.3) spaces glyphs **41.1 pt apart on a 375 pt phone** and 43.2 pt on a 393 pt one. That is below the 44 pt target, and the circular hit areas overlap.

### 3.7 Things that stay "13-room"
- **The Cloth weft (W3 §4.1)** is 21 hairlines of hue with no glyph. At 1.2 pt the eye cannot name a row, normal vision included.
- **CommunityPill and FilterBar chips** keep a name-only pill. At 22 chips they need the glyph (`RoomCanon.style` covers the hand, not the glyph).
- **feed.css (`tokens/worlds/feed.css`)** still lists 13 rooms and two turns.
- **The three whites** (W2 §5.2): `unseen #EEECE6` and `works #E9EBE4` are **ΔE 2.16** apart, below what the eye separates on a small card, and lower still under the night ×0.85 rule. The Unwritten's mechanism (three reasons, never named) cannot be seen.
- **Age has three functions:**
  - the Book's yellowing (W1 §5.4 and W3 §7.1);
  - the Dark path's `+0.03·age` (W3 §7.1);
  - ReturnPatina's `a = (days/1095)^0.55`, with W5 4.5's aged story using something else again.

  One material, *age*, is drawn three ways.

---

## 4 · Gaps and opportunities: the one visual system, specified

### 4.1 The channel law (the spine of the system)
| Channel | Carries | Concretely | Never |
|---|---|---|---|
| **Hue** | **place:** the room, and the presences who are the rooms' kin | 21 room marks (§4.2) · 11 presences · 5 face dots (presences plus gold for the Higher Self) · Point world hues inside the Point and the Gates | rhyme, teller, status |
| **Material** | **teller** (who speaks) | paper · linen · stone (W2 §9) on story page, reception, **river card at ⅓**, Swatch, Draw chips, Book chapter | hue (W6's 15 teller colours retire) |
| **Thread + mark geometry** | **rhyme** | bone `#EDE3CE` threads (gutter weft 0.35, sky threads 0.22 dashed [2, 3], Cloth crossings 0.18); the shared mark's crossing angle and rotation (W1 §3.5 geometry kept); the **bead and the lit word take the partner's room colour** (where the twin lives) | an arbitrary accent hue (W1's 12 accents retire) |
| **Light** (form + contrast) | relationship / status | five tiers, §4.4 | story text; opacity alone below 3:1 |
| **Red point** `#E5533C` | the One (the dot) | one per screen; `#C0392B` only at the centre of depth | die pips, decorations |
| **Gold** `#C9A07A` | **his hand** | kept, sealed, sent back, gilt edges, circuit rings, the Higher Self's salutation, the seek | rooms, rhyme |
| **Paper** `#F3E9D8` | the record received | a held sheet: Book pages, letters, interlude, the last page | full-screen ground |
| **Ground lightness** | depth / position on the axis | the ladder, §4.5 | the house's warmth |
| **Ground chroma** | the house's warmth | `HouseGround` at fixed L, §4.5 | lightness |
| **Motion** | kind of place | 21 signatures, §4.6 | status |

The channel law is what turns many systems into one. Nothing is lost: every fact the scores wanted shown is still shown, each in its own channel.

### 4.2 The 21 room hues, resolved
- **The 13 keep their designed hexes**, except the two duplicates W2 already ordered resolved.
- **Three new rooms move** in OKLCH, within their meaning, to clear colour-blind collisions.
- Every value below was measured on all three night grounds: field `#0E0C12`, card `#171420`, and warm house `#1A0F04` (`#2B2318` for W2's scored stop).

| # | Room | **mark** (glyphs, marks ≥ 3:1) | cr field / card / warm `#2B2318` | **ink** (text on night ≥ 4.5) | mark on paper (≥ 3) | ink on paper (≥ 4.5) | OKLCH |
|---|---|---|---|---|---|---|---|
| 1 | A Maya Game | `#D4AE4A` | 9.22 / 8.60 / 7.34 | = mark | `#9B7600` | `#7F5C00` | .77 .125 88° |
| 2 | The Garden | `#4A9E6B` | 5.92 / 5.52 / 4.71 | = mark | `#368B5A` | `#127041` | .63 .113 155° |
| 3 | The Watcher | `#7B82D4` | 5.54 / 5.17 / 4.41 | `#7E85D7` | `#7076C7` | `#5458A6` | .64 .123 279° |
| 4 | The Descent | `#E5533C` | 5.22 / 4.87 / 4.15 | `#EC5A42` | `#DA4932` | `#BA2812` | .64 .186 32° |
| 5 | The Return | **`#B9A3EC`** (W2) | 8.81 / 8.22 / 7.01 | = mark | `#8872B7` | `#6B5597` | .76 .105 298° |
| 6 | The Forgetting | `#C4A882` | 8.58 / 8.01 / 6.84 | = mark | `#927753` | `#775D3A` | .75 .061 75° |
| 7 | The Remembering | `#8AB5A0` | 8.52 / 7.95 / 6.78 | = mark | `#5A8470` | `#416957` | .74 .055 164° |
| 8 | The Body | `#C45A50` | 4.56 / 4.26 / 3.63 | `#D96C61` | `#C45A50` | `#A63F37` | .60 .138 27° |
| 9 | The Thread | `#C4923A` | 6.96 / 6.50 / 5.54 | = mark | `#A4740E` | `#855600` | .69 .119 78° |
| 10 | The Circle | `#D4607A` | 5.33 / 4.97 / 4.24 | `#DB6680` | `#CA5771` | `#A83855` | .64 .148 8° |
| 11 | The Signal | `#3AADA8` | 7.15 / 6.67 / 5.69 | = mark | `#008B86` | `#006D69` | .68 .101 191° |
| 12 | The Forge | **`#E8793A`** (W2) | 6.69 / 6.24 / 5.33 | = mark | `#C95D16` | `#A73E00` | .69 .157 48° |
| 13 | The Field | `#9B6BD6` | 5.06 / 4.72 / 4.03 | `#A474E0` | `#9565CF` | `#7747AE` | .62 .161 303° |
| 14 | The Ground | **`#94795A`** (was `#8C6A4A`) | 4.76 / 4.44 / 3.79 | `#A38868` | `#94795A` | `#765C3E` | .59 .056 70° |
| 15 | The Stack | `#3F84B5` | 4.80 / 4.47 / 3.82 | `#4F93C5` | `#3C81B2` | `#1D6695` | .59 .102 242° |
| 16 | The Wash | `#8CCBDA` | 10.81 / 10.08 / 8.60 | = mark | `#488694` | `#296976` | .80 .067 214° |
| 17 | The Counter | **`#BCC072`** (was `#A3A84E`) | 10.11 / 9.44 / 8.05 | = mark | `#7F8234` | `#62640F` | .79 .101 111° |
| 18 | The Name | `#C45FA8` | 5.14 / 4.79 / 4.09 | `#CE68B1` | `#BD59A2` | `#9C3A83` | .63 .156 339° |
| 19 | The Fold | **`#F6BBA8`** (was `#F0A49A`) | 11.66 / 10.88 / 9.28 | = mark | `#A46E5D` | `#885444` | .84 .074 39° |
| 20 | The Unwritten | `#E6E1D6` | 14.91 / 13.92 / 11.87 | = mark | `#817D73` | `#646057` | .91 .016 86° |
| 21 | The Old Light | `#CFE0FA` | 14.53 / 13.56 / 11.57 | = mark | `#6D7C93` | `#536278` | .90 .040 259° |

**What the three moves buy.**
- The new rooms' worst colour-blind collision rises from **2.0 to 4.2** (Body/Ground, protanope).
- Normal-vision minimum for a new room: **12.9** (Maya/Counter).
- The meaning stays:
  - the Ground stays soil (a lighter, drier umber);
  - the Counter becomes worn oak-olive;
  - the Fold becomes the paler coral of a swatch held in the hand.

**What is held, with the reason.**
- Descent/Body (ΔE 7.7) and Maya/Thread (8.7) are pre-existing and designed. Glyph (· vs ⬡, ◈ vs ⊕) and motion (an ember vs a full breath, a wheel vs a shuttle) carry them.
- The Forge/Thread deuteranope collision (0.9) has no orange that avoids it. The Forge's ▲ assembling and the Thread's ⊕ shuttle carry it (law 8).

**Derived per room, never authored.** `wash` = mark at 5 % over ground. `border` = mark at 13 %. `glow` = drop-shadow at 0.65. All three are `color-mix` in OKLab, as in feed.css.

**Held rooms (W3 §12.2) carry no hue until they ripen.** They are bone points, as W3 already draws them. At ripening the hue is derived **"a hue from a name"** (the golden angle on `fnv(name)`, with OKLCH L .74 and C .10), then stepped until it is ΔE ≥ 10 from all rooms and ≥ 3:1 on all three grounds, by script.

### 4.3 Type: one scale, one floor
Lora and Space Mono stay the house faces. New strings use only these tokens; existing comp sizes stand as designed.

| Token | Face | Size / leading (pt, `@ScaledMetric` relative) | Use |
|---|---|---|---|
| `t.display` | Lora 400 | 40 / 1.05 (30 for one-word thresholds) | the Name's title stage; the verb arriving; the bloom word |
| `t.hand` | per room | `RoomStyle` (22–24) | room names: the one sanctioned per-room type |
| `t.title` | Lora 500 | 23 / 1.34, −0.012 em | story title |
| `t.lead` | Lora italic | 19 / 1.6 | single ceremony lines: interlude, letters, convergence and bloom, landing |
| `t.body` | Lora | 17 / 1.82 | reading |
| `t.card` | Lora | 15 / 1.68 | comments, tiles, Swatch, read-back |
| `t.line` | Lora italic | 14 / 1.6 | quiet lines, titles in lists, captions |
| `t.whisper` | Lora italic | 12 | the smallest readable italic |
| `t.label` | Space Mono, upper | 10, +0.14–0.26 em | structure, controls, ways out |
| `t.mark` | Space Mono, upper | 9, +0.18 em | decorative or redundant labels (VoiceOver carries the meaning) |

**Rules.**
- Nothing new below 9 pt.
- Any label that is a control or a way out is ≥ 10 pt.
- Mono colour is ≥ `ink.2`.
- **The text ladder on night:**

  | Token | Value | Contrast field / card / warm |
  |---|---|---|
  | `ink.1` | `#EDE8E3` | 15.97 / 14.91 / 15.49 |
  | `ink.2` | `#94908F` | 6.15 / 5.74 / 5.97 |
  | `ink.3` | **`#85807C`** (new: the faintest readable text) | 4.98 / 4.65 / 4.79 |
  | `ghost` | `#EDE8E3` at 35 % | decorative only: hairlines, resting glyphs |

- **On paper:**

  | Token | Value | Contrast |
  |---|---|---|
  | `paper.ink` | `#2A2420` | 12.7:1; 8.1:1 on the night sheet |
  | `paper.ink.2` | `#5A4A3C` | 7.0:1 by day; ≥ 4.5:1 on the night sheet, gated |

- **A third face, only under the floor** (law 9, LATER). Newsreader 300 italic (the lalita chassis's under-the-floor face) appears only in MirrorFloorView's corridor and carve and the Gates' descent. Crossing the floor changes the typeface, and nowhere else does.

### 4.4 Light tiers, by form and contrast
| Tier | Form | Contrast on its ground | Motion |
|---|---|---|---|
| here | filled + halo (glow 8–12 pt) | mark | breathes on `Breath` |
| open | filled | mark | — |
| ground | filled | mark lowered in OKLCH L to **4.0:1** | — |
| ahead | **hollow ring**, 1 pt, behind a dashed hairline [2, 3] | **3.0:1** | — |
| veiled | **dotted ring** [1, 2] | **3.0:1**, and named in VoiceOver ("not yet walked") | — |

- **Computed per mark** by `Tools/contrast.py --tier`. Never as `opacity(0.16)`.
- **Where it applies:** Mala beads · Cloth stitches · Tree dots · held lights · Board and Spine beads · the eagle-eye's light lens · sky stars · RoomRing halos · face dots.
- **Stays outside it:** story text (always full ink, law 2) and decorative threads (constellation lines, ring lines), which may sit below 3:1 because they carry no status.

### 4.5 Grounds: a ladder by depth, materials by surface, paper as a held sheet
**The ladder** (lightness = position; tokens in `Theme/Grounds.swift`):

| Token | Hex | L | Holds |
|---|---|---|---|
| `ground.light` | `#D9D2C4` | .86 | the Light (canon pale register) |
| `ground.sky` | `#08070B` | .13 | sky, region, world, eagle-eye, house figure |
| `ground.field` | `#0E0C12` → `HouseGround(w)` | .16–.18 | river, rooms, story page, RoomSelection, Book desk, Cloth, Board, Draw, Present, Players |
| `ground.card` / `inset` | `#171420` / `#121018` | .20 / .18 | cards, comment wells |
| `ground.wash` | `#0B0910` | .15 | the met Door |
| `ground.prayer` | `#050408` | .11 | every ceremony: Rite, Gates, Recitation, name rite, one-line floor, the Stack's last band, Season Letter's night |
| `ground.under` | `#05060C` | .12 (cool) | under the floor: MirrorFloor, the Old Light, mirror glass |
| `ground.lalita` | `#1A1424` | .21 | the confession only |

**HouseGround (W3 §6.1, revised).**
- An OKLab line from `#0E0C12` (w 0) to **`#1A0F04`** (w 1): L .16 → .18, C .013 → .029, H 300° → 68°. Warmth is chroma; lightness barely moves.
- At w = 1: ink.1 15.49:1, ink.2 5.97:1, ink.3 4.83:1, Ground mark 4.62:1, Body mark 4.42:1.
- ΔE from today's ground is 8.1, so the warming is felt, and the river never rises toward the Light.

**Materials** (each surface is told apart by material, not by a new black). Generated once by `TellerTexture`'s seeded generator and tiled under content:

| Surface | Ground | Material |
|---|---|---|
| Cloth | field | **the weave itself** (warp 0.05 / weft as scored) — no extra texture |
| Book | field desk + `paper.dark #16120E` boards | **paper grain** on pages (paper texture at 3×) |
| Board (the 33) | field | **stone noise** 0.03, the spine's own beads |
| Draw | field | **felt**: linen weave 0.04, the deck on a playing cloth (play chassis's "cloth ground with paper for what you receive", as material only) |
| Gates | prayer | each gate darkens one OKLCH L step (W4 has this) |
| Recitation | prayer | **nothing**: the one surface with no material |
| eagle-eye | sky | film grain (fractal noise .8, 3 octaves, .055, chassis B as worn) |
| Unwritten card | paper sheet | three whites by material (§4.7) |

**Paper (dark-always).**
- **One token,** `paper` `#F3E9D8`. The Book's pages age from it by the patina (§4.8). `bone` `#EDE3CE` is the one cream used for threads and lines.
- **Always a held sheet:**
  - ≤ 88 % of the width;
  - ≥ 24 pt of night visible around it;
  - radius 3, with a soft shadow;
  - it **wells up from the dot** as "the paper sheet that rises" (1100 ms, EC 6.1).
- **At night** (21:00–05:00 local) every sheet's L × 0.85: `#F3E9D8` → `#C5BBAB`, generalising the Unwritten's rule.
- **Exempt:** the Light (canon) and LalitaPlay (designed).

### 4.6 Figure grammar for 21 (glyph · armature · motion), and the dot
**Glyph families.**
- **The 13 (the cosmic marks):** point ·, diamonds ◈ ◆ ◇, stars ✦ ✧, rings ○ ◎ ⊕, triangles △ ▲, hex ⬡, lemniscate ∞.
- **The 8 (the made world and its ground):**
  - the **square family** for the made things: ▤ Stack (layers) · ◫ Counter (a counter with its two sides) · ◩ Fold (a folded corner) · □ Unwritten (the blank page);
  - the **elemental triangles** for ground and water: ▼ Ground (earth) · ▽ Wash (water). With △ and ▲ they form the alchemical quartet;
  - **light:** ✶ Old Light (six rays: older than the four-pointed stars) · ⟡ Name (a letterform within a diamond).
- **No other surface uses any of these 21 glyphs.** Turn rows, chips and places draw their **own marks** (the source's own law: "drawn marks, one per place; no shared icon vocabulary", EC §6.4), as W4 already does for its four.
- **Render-check** ⟡ ◩ ◫ ▤ ✶ at 22 pt and 56 pt on device. They come from fallback fonts, so match ink weight to ◈ and adjust with `.fontWeight` or a drawn path.

**Sky armatures for the 8: the structure of the subject, named.**

| Room | Armature |
|---|---|
| Ground | a family of **catenaries** (the curve a hanging cloth and a settling soil make), with the dark drop at their minimum |
| Stack | **four parallels and one falling point** |
| Wash | a **decaying logarithmic eddy** (turning water) |
| Counter | a **frieze with glide reflection** (p11g): marks above the line, their reflected-and-shifted images below. What is given is never what was asked. |
| Name | an **acrostic**: points at the initials on a sine baseline, lit in turn |
| Fold | a **Miura crease pattern**: valley folds dashed, mountain folds solid; one corner lifts |
| Unwritten | **the empty grid**: frames, no fill, one breathing |
| Old Light | **golden-angle starlight with trails pointing away** (light that already left) |

W2 §3.5's renderers already draw most of these. The table gives each its structure, so its parity is checkable.

**Motion signatures (unique by form × period).** Two fixes:
- **The Unwritten → `glyphFills`.** The glyph rests at 0.35 and rises to 1.0 over 6 s of **stillness** on that screen, and falls back on any touch. It is the room's own mechanism, as a figure. It is no longer a second still glyph beside the Watcher.
- **The Name → `glyphSay`.** The glyph's outline draws in (a trim, initial stroke first, 2.4 s), fills (0.6 s), holds 3 s, and unfills: a 7 s cycle. It is no longer the Forge's assembling.

**The dot (law 1).**
- One `BinduDot` component draws the red point everywhere: a size ladder of 6 / 7 / 8 pt, `#E5533C`, the glow formula of `BinduParticle`, states as W1/W3 declare.
- **One red point per screen.** The Board's die pips go **bone `#EDE3CE`**. The Cloth's existing sealed knots stay (they are designed).
- `#C0392B` appears only at the centre of depth (the Point's centre, the today-shuttle on the Cloth).

### 4.7 The Unwritten's three whites: by tint and by material
| Reason | White | ΔE to the others | Material |
|---|---|---|---|
| unseen | **`#E5EAF0`** (cool) | ≥ 10.1 | smooth, no grain: invisibility is the achievement |
| tender | **`#F6E1DB`** (blush) | ≥ 11.2 | **tissue:** the sheet at 0.94, so night breathes through it, with a 1.5 pt feathered edge |
| works | **`#E9E7D8`** (linen-white) | ≥ 10.1 | **faint ledger rules:** 0.5 pt at 24 pt pitch, ink at 0.06 (the system simply works) |

- Ink `#2A2420` on all three is ≥ 12.2:1.
- Never labelled, as scored.
- The sky's `pages` armature cycles the same three.

### 4.8 One age, one patina
**`Theme/Patina.swift`:**
- `a = clamp((days/1095)^0.55, 0, 1)` (ReturnPatina, elements-corpus "The patina");
- `sat = 1 − .30a`;
- `warm = .30 + .70a`;
- `grain = .05 + .14a`.

**Every aged thing reads it:**
- the Book's paper yellowing (W1 §5.4, W3 §7.1), replacing its own rule;
- the Dark path's page depth (`L + .03·a`);
- W5 4.5's returned story (its ground and grain);
- the Return strata (as built);
- the Cloth's oldest warp (grain only).

Age is shown, never numbered.

### 4.9 Density rules for 469 stories
- **River card** (extends "the glyph is the card" to StoryCard):
  - fill = room `wash` 5 %;
  - border = room `border` 13 %;
  - teller texture at ⅓ of its story-page opacity;
  - the room glyph at 10 pt in the top row (colour never alone);
  - the one-time live glow (never looping).

  A screen of 6–7 cards then reads by place and body before any word. The four weft lanes are enough at 469 (a fifth family on one card draws no thread, W1 §3.2).
- **Per-story signature** (Mandala "a palette from one hue", SHOULD). Each story's accent = room mark with `h ± jitter(fnv(id), 6°)` and `L ± 0.02`. It is always kept ΔE ≤ 4 from its room and ≥ 10 from every other room, so sisters differ and the family still reads. Applied to the card hairline, the received page's ground tint (W2 §12.4) and its hero wash.
- **Story page:** one after-thing (law 11) · selvedge ≤ 5 titles · one dealt signature visible at a time.
- **Sky:**
  - labels only within the proximity band;
  - constellations at 0.06, bone, styled by material;
  - rhyme threads bone, dashed, 0.22;
  - when > 120 crossings are on screen they draw at half alpha (W3's density rule, made house-wide).
- **Ring of 21: sector hit areas.** Each glyph owns a 17.1° wedge from r 0.26 to 0.50 of the stage (≥ 44 pt at every width). Long-press names. VoiceOver per glyph.
- **The Turn (about 24 rows):** three visual tiers under 0.5 pt hairlines (*places · ceremonies · the record*), each row its own drawn mark, no row reusing a room identity. The nav lens owns the grouping; this lens owns the marks.
- **Chips:** glyph + name, 22 scroll.
- **Every Canvas** draws only what is laid out and visible, from caches (W1, W3 and W6 laws, house-wide).

### 4.10 The strongest rupakarshini elements not yet used, and where they belong
1. **Status as light, five tiers by form** (EC "Status as light, never a lock"; law 14). Everywhere listed in §4.4. **MUST.**
2. **Register materials** (EC "Register materials"). The §4.5 table: each new surface gets a material instead of a near-black. **SHOULD.**
3. **The Descent: the paper lifts, the dark wells up, one ember crosses** (EC; 2.35 s, `cubic-bezier(.66,0,.24,1)`, ember 11 pt, tone 110 / 110 + 6 ¢ / 164.81 peaking at 0.8 s and gone by 1.25 s). It becomes **the one crossing down:** into the Gates (W4 §4.4), into MirrorFloor, and the Book's `play it` for an inked grammar (W3 §7.8). It is never used for everyday moves. **SHOULD.**
4. **A palette from one hue + six compositions** (Mandala engines). A per-story signature (§4.9) plus the received page's **opening composition** by element:

   | Element | Composition | Rooms | Placement |
   |---|---|---|---|
   | fire | ascension | Forge, Body | the title low-centre |
   | water | descent | Wash, Remembering | the title high |
   | air | horizon | Signal, Watcher | the title leans |
   | ether | veil | Old Light, Field | the name as backdrop |
   | earth | foundation | Ground, Stack, Descent | — |
   | light | radiance | Return, Name, Maya | — |

   This is the answer to "137 → 469 stories that look alike" (reader 13's #1). **SHOULD.**
5. **Relit by the hour** (Mandala; dawn/noon/dusk/night tints in OKLab: dawn `#3A1C22` @12 %, noon `#242838` @7 %, dusk `#331306` @14 %, night `#060716` @16 %). Applied to the room heroes (W2 §3.2), RoomRing and the card washes. The rooms know the hour as the Door does. **SHOULD.**
6. **The Veil over a held image** (Mandala; S2 Navigator right). RoomSelection's ring is the **held figure** ("look, do not operate"; only the dot and the foremost glyph breathe). The list of 21 rises over it as a sheet ordered by ring position, each row in its tier of light. This answers the ring-versus-list doubling in W2 §3.3. **SHOULD.**
7. **The interface thins with depth** (100 → 80 → 60 → 25 → 0 %; law 6). Once the river joins the axis (W6 §2), the chrome of HubTrigger, back and rail steps: river 100 · sky 80 · region 60 · world 25 · fall 0. Touch, hover or focus brings it back for 3 s. Text in chrome is full ink or hidden. **SHOULD.**
8. **Recognition wired across topics: the dashed ember line** (Learning engines). This is the rhyme thread's form in the sky and on the Cloth, so a rhyme never looks like his own (solid gold-ageing) filament. It is folded into the channel law. **MUST via §4.1.**
9. **Each line one shade lighter** (Bindu Practice: three ink steps rising toward the light). On paper: `#3A2E15` → `#4A3C1E` → `#5A4B28`, the final line darkest `#2A1F08`. Used for the Last Page's offerings and the Season Letter's lines, so the letter itself rises to *It was you. It was always you.* **SHOULD.**
10. **Words sharpen as you reach them** (Being). The Litany's last line and the Recitation's white line arrive blurred (6 px, 0.35) and sharpen word by word when scrolled to. **LATER.**
11. **Weather by altitude** (Mandala). The Spine figure (W6 §6.2 D): each band of vertebrae has its own light quality, tempo slowing 1.0 → 0.28× toward 33, with a rail naming nothing. **LATER.**
12. **Type changes where a crossing means something** (law 9). The third face under the floor (§4.3). **LATER.**
13. **Captions that deepen with silence** (Mandala: 7 / 14 / 21 / 28 s). The Unwritten's GameView hero: the stay caption changes as silence lengthens, before the 240 s turn. **LATER.**

---

## 5 · Recommended changes to the scores (to fold in mechanically)

| # | Target | Change | Priority |
|---|---|---|---|
| 1 | **W0 §15.4** (new commit) + CONTRACT §7 | Create `Theme/Tokens.swift`: the channel law (§4.1) as named roles; the ground ladder (§4.5); the ink ladder incl. **`ink.3 #85807C`**; `paper #F3E9D8`, `paper.ink #2A2420`, `paper.ink.2 #5A4A3C`, `bone #EDE3CE`, `gold #C9A07A`. **House-law detector:** no `Color(hex:` or `Color(.sRGB` literal in any file a wave touches, outside `Theme/` and `canon`-mirrored tables. | **MUST before build** |
| 2 | **W2 §1.1, §1.2, App. B; CONTRACT §3** | The 21 marks of §4.2. Track 1 rewrites the Staged rows for **the Ground `#94795A`, the Counter `#BCC072`, the Fold `#F6BBA8`** now (Staged, free to change). The Forge `#E8793A` and the Return `#B9A3EC` as W2 proposed. | **MUST** |
| 3 | **W2 §2 `RoomCanon`** | Add per-room `ink`, `paperMark`, `paperInk` (§4.2 table), derived `wash/border/glow`. **Every text in room colour** reads `ink` (night) or `paperInk` (paper): W1 §3.3 lit word, W2 §5.1 landing line, §5.6 meaning, §5.7 Old Light units, §12a, W3 §7.3a, W4 landing titles. | **MUST** |
| 4 | **W1 §3.5, §3.2, §3.6; W3 §4.1, §7.3a** | Retire the 12 rhyme accents. Thread = `bone` (weft 0.35 → joined 0.55; sky 0.22 → 0.45 met, **dashed [2, 3]**; Cloth 0.18/0.36/0.55); shared mark geometry unchanged, stroke `bone` (paper: `paper.ink` 0.6); **weft bead and lit word in the partner's room** `mark` / `ink`; Rings' accent ring → partner room. | **MUST** |
| 5 | **W6 §7.1, §10.1** | Retire the 15 teller colours. Constellations `bone` at 0.06 → 0.28 on touch, **line style by material**: paper = dotted [1, 3] · linen = double hairline (two 0.3 pt, 1.2 pt apart) · stone = solid 0.5 pt; the region ring for non-memo stars uses the same styles. Journey stations: the story's room `mark` + a 10 pt texture chip. | **MUST** |
| 6 | **W3 §6.1** | HouseGround: two stops in OKLab, `#0E0C12` → **`#1A0F04`** (L .16 → .18); gate ink.1 ≥ 15, ink.2 ≥ 5.9, ink.3 ≥ 4.8, every room mark ≥ 3:1 at w = 1. Drop the `#2B2318` stop. | **MUST** |
| 7 | **GAMEPLAN §2 law 2; CONTRACT §7; W1 §6; W3 §4.1, §7.6, §12.1; W4 §3.2; W6 §6.2 D, §6.3** | Light tiers by **form + contrast** (§4.4): here/open/ground (4.0)/ahead (hollow, 3.0, dashed line)/veiled (dotted, 3.0). Replace every scored tier opacity (0.16, 0.18, 0.30, 0.32, 0.35) with the tier token; `contrast.py --tier` computes per mark. | **MUST** |
| 8 | **W2 §5.2, §7.2, §12.2; W4 §3.2, §4.2; W5 4.9; all scores** | Every *readable* text at `inkTertiary` (or × a multiplier) → **`ink.3`** (41 occurrences in W0–W8; grep `inkTertiary`, keep only the decorative ones). Held sentence → `ink.3` at full, faded *in*, never parked at 0.55. W5 4.9 mono `#8A7A66` → `paper.ink.2`. `inkTertiary` keeps hairlines and resting glyphs only. | **MUST** |
| 9 | **W0 15.6; W3 §8, §7.10; W4 §3.2, §4.1; W5 4.9; W2 §12.1** | **Dark-always.** Interlude, first line, Good Morning letter, Board read-back, Season Letter, last page: a **held sheet** (§4.5: ≤ 88 % width, ≥ 24 pt night margin, rises from the dot 1100 ms, × 0.85 L at night). Founding silence: a sheet rises behind the text to 0.85 and recedes; never a full-screen cream. Merge `#F2EADB/#F3E9D8/#F4EFE6` → `paper`; `#EDE3D0/#EDE6D6` → `bone`. W3 §8's "identical in every value" holds (both read the same tokens). | **MUST** |
| 10 | **W2 §5.2, §3.5** | Three whites → **unseen `#E5EAF0` · tender `#F6E1DB` · works `#E9E7D8`** (ΔE ≥ 10), plus their materials (smooth · tissue 0.94 + feathered edge · ledger rules). The night rule stays. | **MUST** |
| 11 | **W2 §3.3, W0 15.4** | RoomRing hit-testing by **angular sector** (17.1°, r 0.26–0.50 of the stage, ≥ 44 pt at 375 pt); circles stay visual only. | **MUST** |
| 12 | **W0 15.10 `Tools/contrast.py`** | Add `--tier`, `--paper-night`, `--cvd` (deuteranope/protanope ΔE report, informational), and gate: every token pair in §4.2–4.5, the three whites, HouseGround endpoints, every room `ink` on field/card/warm, `paperInk` on paper and night sheet. | **MUST** |
| 13 | **W4 §3.2, W3 §9, W1 §4.4** | One `BinduDot` component; **one red point per screen**; die pips `bone`; `#C0392B` only at the centre of depth. | **SHOULD** |
| 14 | **W0 14.7/14.8/14.21; W4 §3.11; W6 §6.1, §2.5** | New Turn rows draw **their own marks** (TurnMark compositions, 22 × 22), never a room glyph: the Turning, the Old Story, Rest a moment, the Draw, the Whole House, the voices, walk a chain. W3 §12.2: replace the second ⌂ (the House) and ⊙ (the Inner Field). | **SHOULD** |
| 15 | **W2 §3.1** | Motion: the Unwritten `glyphStill` → **`glyphFills`** (0.35 → 1.0 over 6 s of stillness, falls on touch); the Name `glyphAssemble` → **`glyphSay`** (trim-in 2.4 s initial first, fill 0.6 s, hold 3 s, unfill; 7 s). Row `Animation Name` for rows 14–21 = the canon figure name (Track 1, after merge). | **SHOULD** |
| 16 | **W2 §3.5** | Name each new armature's structure (catenaries · four parallels and a falling point · log eddy · frieze glide reflection p11g · acrostic · Miura crease (valley dashed / mountain solid) · empty grid · starlight trailing away) so W8's parity pass can check it. | **SHOULD** |
| 17 | **W3 §4.1** | Cloth: each weft row starts at the left selvedge with its room glyph, 9 pt, in `mark` (colour never alone). | **SHOULD** |
| 18 | **W1 §3.2 / W2 §9** | River StoryCard: room `wash` fill + `border`, teller texture at ⅓, room glyph 10 pt in the top row. | **SHOULD** |
| 19 | **W4 §3.2–3.4, §4.2–4.4; W6 §6.2; W3 §4.1, §7** | Grounds to the ladder (§4.5): `#0B0A10` → field; `#050407`, `#06050A`, `#09070D` → `ground.prayer`; `#08070B` → `ground.sky`; `#0B0A0E` → field; `#05060C` → `ground.under`; plus the material per surface (§4.5 table). | **SHOULD** |
| 20 | **W1 §5.4, W3 §7.1, W5 4.5** | One patina (`Theme/Patina.swift`, §4.8) for every aged surface; remove the Book's own yellowing rule and the Dark path's `+0.03·age`. | **SHOULD** |
| 21 | **W4 §4.4, W0 (MirrorFloor entry)** | Entering the Gates and the Floor plays **the Descent** (2.35 s, ember 11 pt, tone gone by 1.25 s); reduced motion 0.3 s fade through black with the ember still. | **SHOULD** |
| 22 | **W2 §11** (extend) | Per-story signature: accent jitter (`h ± 6°`, `L ± .02`, ΔE ≤ 4 from its room, ≥ 10 from others) + the received page's opening composition by element (six, §4.10 #4). | **SHOULD** |
| 23 | **W2 §3.2, §3.3** | Relit by the hour on heroes, ring and card washes (Mandala tints, §4.10 #5); device hour; harness override. | **SHOULD** |
| 24 | **W2 §3.3** | RoomSelection as **the Veil over a held image**: ring = held figure; the 21-row list rises as a sheet with tiers of light; tap a glyph still floods. | **SHOULD** |
| 25 | **W6 §2** | Chrome thins with depth on the axis (100/80/60/25/0; touch restores 3 s; text full or hidden). | **SHOULD** |
| 26 | **W3 §7.10; W4 §4.1** | *Each line one shade lighter* on the Last Page offerings and the Season Letter lines (paper ink steps, final line darkest). | **SHOULD** |
| 27 | **W3 §12.2** | Held lights carry no hue until ripe; ripening hue = golden angle on `fnv(name)`, OKLCH L .74 C .10, stepped to ΔE ≥ 10 / ≥ 3:1 by script. | **SHOULD** |
| 28 | **all scores, new strings** | Type tokens only (§4.3); nothing new < 9 pt; controls/ways out ≥ 10 pt mono at ≥ `ink.2`; render-check ⟡ ◩ ◫ ▤ ✶ on device. | **SHOULD** |
| 29 | **rupakarshini `tokens/worlds/feed.css`** (Track 1, skill update at W8 §3.1) | Bring the chassis to 21 rooms with `mark/ink/paper` per room, the ground ladder, `ink.3`, the three whites, the channel law in its header comment. | **SHOULD** |
| 30 | **W3 §7.6** | Fix "cream `#2A2420`" (a contradiction): folded leaves are `paper.ink` at the veiled tier. | **SHOULD** |
| 31 | **MirrorFloor + Gates** | A third face under the floor (Newsreader 300 italic), nowhere else. | **LATER** |
| 32 | **W3 §7.7, W4 §4.2** | Words sharpen as you reach them on the Litany's last line and the Recitation's white line. | **LATER** |
| 33 | **W6 §6.2 D** | Weather by altitude on the Spine figure. | **LATER** |
| 34 | **W2 §5.2 (the Unwritten's GameView)** | Captions that deepen with silence (7/14/21/28 s) before the 240 s turn. | **LATER** |
