import Foundation

// THE LIGHT'S SCENES, READ FROM THE BASE.
//
// The Light had six scenes and they were authored once. It has seventy-six now and it
// ACCUMULATES — scenes keep arriving, and recognitions will gather inside them. That crosses
// the line §10 draws (*"Airtable holds what accumulates; `canon/` holds what was authored
// once"*), and the amendment is recorded there rather than left for a reader to infer.
//
// One Airtable row is one scene. Two text fields carry it:
//
//   Body     WHOLE / ANCHORS / BEAT / LANDING, split on the caps headers
//   Excerpt  FAMILY: · BELIEF DISSOLVED: · GESTURE: · MATERIAL:
//
// ── TWO ABSENCES THAT ARE VALUES, NOT FAILURES ──────────────────────────────────────────
//
// **`BEAT` may be `[blank — his own carving]`.** Seven scenes are written this way, and it
// means the Declaration is his to author at runtime, in his own voice. It is NOT an error and
// must never be defaulted, filled, or reported as malformed. A parser that substitutes a line
// there breaks the core design — and breaks it invisibly, because a substituted Declaration
// reads as content. It is expressed here as `beat: []` plus `carvingIsHis: true`, so every
// consumer has to handle it as a state rather than discover it as an empty array.
//
// **`LANDING` may be `[none]`**, with an empty Closing Line. Also not an error: the scene ends
// on the Declaration and nothing is carried out of it.
//
// Both are the eighth shape from §10 — *a mechanism implemented as its own absence* — which is
// the one that reads as restraint and survives every checker. The guard is that each has a
// NAMED state in the model, so "nothing here" and "we failed to read it" can never be the same
// value.
enum LightSceneParser {

    // The four Body headers, in the order the design writes them. Matched case-sensitively on
    // a line of their own: these are caps headers, and a lowercase "landing" inside a sentence
    // is prose, not a section break.
    private static let bodySections = ["WHOLE", "ANCHORS", "BEAT", "LANDING"]

    // The four Excerpt labels. `MATERIAL:` decides which of the Light's two materials a scene
    // is made of; the other three are E1.15's `kind`, `vector` and `arrival`.
    private static let excerptLabels = ["FAMILY", "BELIEF DISSOLVED", "GESTURE", "MATERIAL"]

    /// The sentinel the design writes where his own carving goes. Matched loosely on the two
    /// words that carry it, because the dash between them is an em-dash in the corpus and the
    /// escape asymmetry has already bitten this build three times (§10) — a hyphen typed by
    /// hand must not silently become a Declaration.
    static func isBlankCarving(_ s: String) -> Bool {
        let t = s.lowercased()
        return t.contains("blank") && t.contains("carving")
    }

    /// `[none]` — the landing the scene does not have.
    static func isNone(_ s: String) -> Bool {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "[none]"
    }

    // MARK: - Body

    /// Split on the caps headers. Returns each section's lines with authored breaks intact.
    ///
    /// **WHAT THIS DELIBERATELY DOES NOT DO:** it never re-flows, never joins, never trims a
    /// line's interior, and never splits an ANCHOR. An anchor is one element however long it
    /// is; a `\n` INSIDE one is the author's and `Text` renders it. Only WHOLE is split on
    /// `\n`, because canon stores it as one string with embedded breaks (`spine-light.js:36`)
    /// and the app's model has always held it pre-split.
    static func sections(from body: String) -> [String: [String]] {
        var out: [String: [String]] = [:]
        var current: String? = nil
        var buffer: [String] = []

        func flush() {
            guard let key = current else { return }
            // Drop only leading/trailing blank lines — never interior ones, which are spacing
            // the author chose.
            var lines = buffer
            while lines.first?.trimmingCharacters(in: .whitespaces).isEmpty == true { lines.removeFirst() }
            while lines.last?.trimmingCharacters(in: .whitespaces).isEmpty == true { lines.removeLast() }
            out[key] = lines
            buffer = []
        }

        for raw in body.components(separatedBy: .newlines) {
            let header = raw.trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: ":"))
            if bodySections.contains(header) {
                flush()
                current = header
            } else {
                buffer.append(raw)
            }
        }
        flush()
        return out
    }

    // MARK: - Excerpt

    /// `LABEL: value` per line. Values are trimmed; labels are matched whole so a colon inside
    /// a value cannot start a new field.
    static func labels(from excerpt: String) -> [String: String] {
        var out: [String: String] = [:]
        for raw in excerpt.components(separatedBy: .newlines) {
            guard let colon = raw.firstIndex(of: ":") else { continue }
            let label = String(raw[raw.startIndex..<colon])
                .trimmingCharacters(in: .whitespaces).uppercased()
            guard excerptLabels.contains(label) else { continue }
            out[label] = String(raw[raw.index(after: colon)...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return out
    }

    // MARK: - The scene

    /// Build a scene, or return nil when the row cannot be one.
    ///
    /// **NIL IS FOR A ROW THAT IS NOT A SCENE, NEVER FOR A SCENE THAT IS QUIET.** A missing
    /// WHOLE means there is nothing to stand in and the row is skipped; a blank BEAT or a
    /// `[none]` LANDING are scenes, and come back whole. `fetchLightScenes` `compactMap`s, so a
    /// nil here drops one row and leaves the rest of the register standing — the same
    /// resilience `AirtableService.ResilientPage` gives a malformed record.
    static func scene(key: String, title: String, body: String,
                      excerpt: String, closingLine: String?) -> LightScene? {
        let sec = sections(from: body)
        let lab = labels(from: excerpt)

        let whole = (sec["WHOLE"] ?? []).flatMap { $0.components(separatedBy: "\n") }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !whole.isEmpty else { return nil }        // nothing to stand in

        let anchors = (sec["ANCHORS"] ?? [])
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // THE BLANK CARVING. One test, one state, and no third path.
        let rawBeat = (sec["BEAT"] ?? []).map { $0.trimmingCharacters(in: .whitespaces) }
                                        .filter { !$0.isEmpty }
        // Qualified deliberately. `contains(where: isBlankCarving)` is the same call, but a
        // bare function VALUE inside its own type is invisible both to `check_wired` and to
        // anyone grepping for the app's use of the build's most load-bearing guard — it read
        // as BUILT-BUT-UNCALLED, which is exactly the wrong thing to be unsure about here.
        let carvingIsHis = rawBeat.contains(where: LightSceneParser.isBlankCarving)
        let beat = carvingIsHis ? [] : rawBeat

        // THE LANDING THAT IS NOT THERE. Closing Line repeats it; either may carry `[none]`.
        let rawLanding = (sec["LANDING"] ?? []).joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let fromClosing = (closingLine ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let landingSource = rawLanding.isEmpty ? fromClosing : rawLanding
        let landing = isNone(landingSource) ? "" : landingSource

        let material: LightMaterial =
            (lab["MATERIAL"] ?? "").lowercased().contains("nave") ? .nave : .dawn

        // `arrival` drives the wash. An unrecognised value falls to the material's own form —
        // stillness in the dawn, the nave in stone — rather than to one named scene's wash,
        // which is what the key-switch did.
        let arrival = LightArrivalKind(rawValue: (lab["GESTURE"] ?? "").lowercased())
            ?? (material == .nave ? .nave : .stillness)

        return LightScene(
            key: key,
            title: title,
            material: material,
            whole: whole,
            anchors: anchors,
            beat: beat,
            landing: landing,
            vector: lab["BELIEF DISSOLVED"] ?? "",
            kind: lab["FAMILY"] ?? "",
            arrival: arrival,
            carvingIsHis: carvingIsHis
        )
    }

    // MARK: - Name

    /// `Light — <slug>` → (`slug`, `<slug>` as written).
    ///
    /// The brief gives `Name` as the scene slug; the model needs a key AND a display title, and
    /// the base has one column. So the key is the slug lowercased and the title is what is
    /// written after the dash, unchanged. When there is no dash the whole Name is both — which
    /// is the safe reading either way, and avoids inventing a title the author did not write.
    static func split(name: String) -> (key: String, title: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        // em-dash, en-dash or hyphen, whichever the row carries.
        for sep in [" — ", " – ", " - "] {
            if let r = trimmed.range(of: sep) {
                let tail = String(trimmed[r.upperBound...]).trimmingCharacters(in: .whitespaces)
                if !tail.isEmpty {
                    return (tail.lowercased().replacingOccurrences(of: " ", with: "-"), tail)
                }
            }
        }
        // NO DASH — the unconfirmed branch. The brief gives `Light — <slug>`; if the base turns
        // out to hold the slug alone, the tail above is never reached and the whole Name is
        // both. A raw slug would then render as `the-surge` on the dawn and in the shaft, which
        // is a visibly wrong surface rather than a wrong value.
        //
        // So hyphens become spaces for the TITLE only. This invents nothing — it reverses the
        // encoding this same function applies one line up to build the key — and it cannot
        // regress the documented format, because that format never reaches this line.
        let key = trimmed.lowercased().replacingOccurrences(of: " ", with: "-")
        return (key, trimmed.replacingOccurrences(of: "-", with: " "))
    }
}
