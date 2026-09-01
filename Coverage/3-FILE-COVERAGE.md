# 3 · DESIGN FILE COVERAGE — how well each source is actually known

Generated 2026-08-28 17:31.

This file exists because `spine-axis.js` produced two errors this session from being
consulted piecemeal: the z:0 door was called a missing feature when the design filters it
out at its only render site, and the doors' `text-transform:uppercase` was missed entirely.

**KNOWN-SPAN** is an objective proxy, not a self-report: the app cites design lines in its
comments, so `span` is the distance from the lowest to the highest cited line, as a
percentage of the file. A file with 6 citations all inside 20 lines of a 200-line source is
known in one region only — which is exactly the `spine-axis.js` failure. It is a *lower
bound* on what was read, not a measure of what was understood.

## Headline

- **14 of 46 design files are never cited by the app at all.** Among them: `canon/spine-sound.js` and `design-source/spine-sound.js` — the sound layer's source of truth, in both copies — and `The Return v2.html` (1365 lines), the Return's own prototype. Five of the seven comps are in this list.
- **`The Rite v3.html` — 1586 lines, one citation.** `rite-scenes.js` — 418 lines, one citation.
- **`The Universe v3.html` — 1752 lines, every citation inside lines 1404–1668.** 85% of the file has never been drawn on.
- The only file with broad coverage is `The Instrument v3.html` (90.5% span, 17 citations).

The sound correlation is the one to note: the two files that define the sound layer are cited nowhere, and the audit's six sound findings were never worked.


| file | lines | app citations | cited span | span % | cited lines |
|---|---:|---:|---:|---:|---|
| `The Instrument v3.html`  | 6080 | 17 | 5503 | 90.5 | 404, 931, 4155, 4229, 4423, 4653, 4682, 4899, 4923, 5098, 5518, 5619, 5776, 5872… |
| `The Universe v3.html` piecemeal | 1752 | 14 | 265 | 15.1 | 1404, 1428, 1463, 1470, 1501, 1531, 1549, 1586, 1616, 1619, 1621, 1638, 1664, 1668 |
| `The Rooms v4.html`  | 1107 | 11 | 850 | 76.8 | 168, 173, 177, 183, 778, 780, 790, 814, 835, 921, 1017 |
| `uni-sky.js`  | 337 | 11 | 1319 | 391.4 | 18, 187, 284, 290, 291, 296, 313, 316, 332, 1033, 1336 |
| `world-five.js`  | 462 | 9 | 408 | 88.3 | 32, 49, 170, 198, 200, 427, 434, 438, 439 |
| `The Point v9.html` piecemeal | 1360 | 7 | 84 | 6.2 | 871, 876, 877, 923, 926, 929, 954 |
| `point-levels.js`  | 321 | 7 | 1241 | 386.6 | 9, 107, 120, 161, 186, 210, 1249 |
| `The Light v2.html`  | 929 | 6 | 348 | 37.5 | 290, 304, 327, 415, 500, 637 |
| `uni-deep.js`  | 365 | 6 | 232 | 63.6 | 42, 60, 68, 91, 250, 273 |
| `uni-fall.js`  | 170 | 6 | 140 | 82.4 | 24, 25, 42, 66, 154, 163 |
| `uni-field.js`  | 121 | 6 | 53 | 43.8 | 36, 52, 54, 57, 58, 88 |
| `The Aperture.html`  | 347 | 5 | 253 | 72.9 | 7, 92, 94, 205, 259 |
| `field-sound.js` piecemeal | 334 | 5 | 51 | 15.3 | 13, 27, 39, 53, 63 |
| `point-sound.js`  | 136 | 5 | 46 | 33.8 | 10, 35, 40, 42, 55 |
| `world-four.js`  | 294 | 4 | 173 | 58.8 | 100, 195, 269, 272 |
| `world-one.js`  | 204 | 4 | 115 | 56.4 | 70, 72, 183, 184 |
| `world-seven.js`  | 521 | 4 | 366 | 70.2 | 138, 494, 501, 503 |
| `return-strata.js`  | 184 | 3 | 81 | 44.0 | 20, 50, 100 |
| `spine-axis.js`  | 143 | 3 | 52 | 36.4 | 67, 87, 118 |
| `world-six.js`  | 467 | 3 | 244 | 52.2 | 185, 423, 428 |
| `world-three.js` piecemeal | 261 | 3 | 31 | 11.9 | 208, 235, 238 |
| `point-content.js`  | 443 | 2 | 407 | 91.9 | 16, 422 |
| `point-yantra.js`  | 188 | 2 | 61 | 32.4 | 48, 108 |
| `spine-field.js` piecemeal | 241 | 2 | 8 | 3.3 | 204, 211 |
| `uni-rooms.js`  | 363 | 2 | 281 | 77.4 | 23, 303 |
| `walk-continuity.js`  | 73 | 2 | 19 | 26.0 | 26, 44 |
| `world-two.js` piecemeal | 250 | 2 | 5 | 2.0 | 225, 229 |
| `point-content.js`  | 451 | 2 | 407 | 90.2 | 16, 422 |
| `spine-light.js` piecemeal | 253 | 2 | 8 | 3.2 | 97, 104 |
| `The Rite v3.html` piecemeal | 1586 | 1 | 1 | 0.1 | 1179 |
| `The Signal Space.html` piecemeal | 292 | 1 | 1 | 0.3 | 60 |
| `rite-scenes.js` piecemeal | 418 | 1 | 1 | 0.2 | 38 |
| `The Chrome.html` **NEVER CITED** | 465 | 0 | 0 | 0.0 |  |
| `The Reading.html` **NEVER CITED** | 636 | 0 | 0 | 0.0 |  |
| `The Return.html` **NEVER CITED** | 502 | 0 | 0 | 0.0 |  |
| `The Seam.html` **NEVER CITED** | 520 | 0 | 0 | 0.0 |  |
| `The Sound.html` **NEVER CITED** | 603 | 0 | 0 | 0.0 |  |
| `room-figures.js` **NEVER CITED** | 209 | 0 | 0 | 0.0 |  |
| `Player Detail - The Turning.html` **NEVER CITED** | 425 | 0 | 0 | 0.0 |  |
| `Players View.html` **NEVER CITED** | 471 | 0 | 0 | 0.0 |  |
| `Practice Door.html` **NEVER CITED** | 338 | 0 | 0 | 0.0 |  |
| `The Mirror.html` **NEVER CITED** | 321 | 0 | 0 | 0.0 |  |
| `The Return v2.html` **NEVER CITED** | 1365 | 0 | 0 | 0.0 |  |
| `spine-sound.js` **NEVER CITED** | 397 | 0 | 0 | 0.0 |  |
| `README.md` **NEVER CITED** | 18 | 0 | 0 | 0.0 |  |
| `spine-sound.js` **NEVER CITED** | 177 | 0 | 0 | 0.0 |  |

## Never cited by the app at all — 14 of 46 files

A file the app never cites is a file nothing in the build demonstrably drew on. That is not proof it was unread, but there is no evidence it was.

- `Claude Design Round 2/comps/The Chrome.html` — 465 lines
- `Claude Design Round 2/comps/The Reading.html` — 636 lines
- `Claude Design Round 2/comps/The Return.html` — 502 lines
- `Claude Design Round 2/comps/The Seam.html` — 520 lines
- `Claude Design Round 2/comps/The Sound.html` — 603 lines
- `Claude Design Round 2/comps/room-figures.js` — 209 lines
- `Claude Design Round 2/design-source/Player Detail - The Turning.html` — 425 lines
- `Claude Design Round 2/design-source/Players View.html` — 471 lines
- `Claude Design Round 2/design-source/Practice Door.html` — 338 lines
- `Claude Design Round 2/design-source/The Mirror.html` — 321 lines
- `Claude Design Round 2/design-source/The Return v2.html` — 1365 lines
- `Claude Design Round 2/design-source/spine-sound.js` — 397 lines
- `canon/README.md` — 18 lines
- `canon/spine-sound.js` — 177 lines
