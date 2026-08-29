import Testing
import SwiftUI
import CoreGraphics
@testable import Bindu_Feed

// `figFail` — `The Rooms v4.html:982`, PORTED AS ITS PURPOSE RATHER THAN ITS FORM.
//
// The comp guards its figure dispatch twice (`:1022-1023`):
//
//     if(FIG[who]){ try{ FIG[who](…) } catch(err){ figFail(err.message||'draw threw') } }
//     else figFail('no figure for '+who);
//
// and `figFail` draws a dashed red rectangle with `FIGURE MISSING — <why>` at `H*0.42`,
// plus one `console.error` per distinct reason (the `failSaid` latch).
//
// **The first branch cannot happen in this app, and that is a stronger guarantee, not a
// weaker one.** `FIG[who]` is a JS object lookup that returns undefined for a missing key;
// `RoomFigures.draw` switches over `RoomKey` with no `default`, so a voice without a figure
// is a COMPILE error. The comp checks at runtime what Swift settles at build time. The
// second branch has no analogue either — `GraphicsContext` drawing does not throw, and a
// Swift trap takes the process with it, so there is nothing to catch.
//
// **What does not survive that translation is the thing `figFail` is FOR: never show an
// empty room silently.** An exhaustive switch proves every key reaches a function. It proves
// nothing about whether that function puts ink on the canvas — a guard that returns early, a
// zero radius, a colour at zero alpha, a path built and never stroked all satisfy the
// compiler and render the blank room the comp refuses to render. That is the EIGHTH SHAPE
// exactly: an absence that looks like restraint, with no string and no missing symbol for
// any checker to find.
//
// So the port is a measurement. Rasterise each of the eleven and count the ink.
@MainActor
// `.serialized` FOR THE TENTH SHAPE, in the form the rule predicts rather than after a hunt.
// `ImageRenderer` is a shared main-actor rendering resource, and Swift Testing parallelises by
// default. `theTreesSwayRatherThanSit` passed alone — `** TEST SUCCEEDED **` on its own — and
// failed inside the suite, which is the flake signature exactly: the assertion is sound and
// the instrument was being shared. The standing rule is that shared state gets `.serialized`
// at the moment it is created, not when it flakes, and rasterising through one renderer is
// shared state whether or not it is spelled `static`.
@Suite(.serialized) struct RoomFigureInkTests {

    static let W = 393.0, H = 852.0

    /// The comp's own numbers at rest in register 1 (`The Rooms v4.html:1015-1017`):
    /// `pres = 0.34 + sm(0,1,D)*0.66` → 1 at D=1, `S = (0.62 + sm(0,1,D)*0.52) * min(1,W/393)`,
    /// `cy = H*0.42`.
    static func params(_ hand: Double = 0, days: [AshDay] = sampleDays) -> RoomFigureParams {
        RoomFigureParams(p: 1.0, c: [0.72, 0.66, 0.58], cx: W / 2, cy: H * 0.42,
                         S: 1.14, b: 0, lat: hand, rev: 0, ashDays: days)
    }

    static let sampleDays: [AshDay] = (0..<28).map {
        AshDay(day: String(format: "2026-08-%02d", $0 + 1),
               voices: [$0 % 10, ($0 * 3) % 10], heavy: $0 % 5 == 0)
    }

    /// Fraction of pixels carrying any ink at all.
    static func ink(_ key: RoomKey, _ o: RoomFigureParams, t: Double = 2.0) -> Double {
        let size = CGSize(width: W, height: H)
        let canvas = Canvas { ctx, s in RoomFigures.draw(key, ctx, s, t, o) }
            .frame(width: W, height: H)
        let renderer = ImageRenderer(content: canvas)
        renderer.scale = 1
        guard let cg = renderer.cgImage else { return -1 }

        let w = cg.width, h = cg.height
        var px = [UInt8](repeating: 0, count: w * h * 4)
        guard let bmp = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8,
                                  bytesPerRow: w * 4,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return -1 }
        bmp.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))

        var lit = 0
        for i in stride(from: 0, to: px.count, by: 4) where px[i + 3] > 8 { lit += 1 }
        return Double(lit) / Double(w * h)
    }


    /// Ink fraction within a horizontal band, given as fractions of H.
    static func ink(_ key: RoomKey, _ o: RoomFigureParams,
                    band: ClosedRange<Double>, t: Double = 2.0) -> Double {
        let size = CGSize(width: W, height: H)
        let canvas = Canvas { ctx, s in RoomFigures.draw(key, ctx, s, t, o) }
            .frame(width: W, height: H)
        let renderer = ImageRenderer(content: canvas)
        renderer.scale = 1
        guard let cg = renderer.cgImage else { return -1 }
        let w = cg.width, h = cg.height
        var px = [UInt8](repeating: 0, count: w * h * 4)
        guard let bmp = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8,
                                  bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return -1 }
        bmp.draw(cg, in: CGRect(origin: .zero, size: size))
        let y0 = Int(Double(h) * band.lowerBound), y1 = Int(Double(h) * band.upperBound)
        var lit = 0
        for y in y0..<max(y0 + 1, y1) {
            for x in 0..<w where px[(y * w + x) * 4 + 3] > 8 { lit += 1 }
        }
        return Double(lit) / Double(w * max(1, y1 - y0))
    }


    /// The alpha plane of one render, so comparisons can be about WHERE ink is.
    static func alpha(_ key: RoomKey, _ o: RoomFigureParams, t: Double) -> (w: Int, h: Int, a: [UInt8]) {
        let size = CGSize(width: W, height: H)
        let canvas = Canvas { ctx, s in RoomFigures.draw(key, ctx, s, t, o) }
            .frame(width: W, height: H)
        let renderer = ImageRenderer(content: canvas)
        renderer.scale = 1
        guard let cg = renderer.cgImage else { return (0, 0, []) }
        let w = cg.width, h = cg.height
        var px = [UInt8](repeating: 0, count: w * h * 4)
        guard let bmp = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8,
                                  bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return (0, 0, []) }
        bmp.draw(cg, in: CGRect(origin: .zero, size: size))
        var a = [UInt8](repeating: 0, count: w * h)
        for i in 0..<(w * h) { a[i] = px[i * 4 + 3] }
        return (w, h, a)
    }


    /// Count of sharp horizontal steps in the alpha plane within a band.
    ///
    /// THE INK MEASURE COULD NOT SEE THE TREES AND IT TOOK TWO WRONG INSTRUMENTS TO FIND OUT.
    /// Gaia's figure opens with a radial wash over the whole canvas, so every pixel in the
    /// floor band is already above any "is there ink" threshold — 20436 of 20436. A boolean
    /// `alpha > 8` is SATURATED there: it reported the band full whether or not a single
    /// branch was drawn, and the time-difference version reported exactly 0 moved pixels
    /// because a stroke sliding across a lit background changes alpha's VALUE and never its
    /// truth. Both readings were about the wash.
    ///
    /// A smooth gradient's neighbouring pixels differ by ~1; a 2px stroke against it is a
    /// step of tens. So count steps, not ink — that is a quantity the wash cannot produce.
    static func edges(_ key: RoomKey, _ o: RoomFigureParams,
                      band: ClosedRange<Double>, t: Double = 2.0) -> Int {
        let f = alpha(key, o, t: t)
        guard f.w > 0 else { return -1 }
        let y0 = Int(Double(f.h) * band.lowerBound), y1 = Int(Double(f.h) * band.upperBound)
        var steps = 0
        for y in y0..<y1 {
            for x in 1..<f.w {
                let d = Int(f.a[y * f.w + x]) - Int(f.a[y * f.w + x - 1])
                if abs(d) > 6 { steps += 1 }
            }
        }
        return steps
    }

    // MARK: - the branch the compiler already closed

    @Test func everyVoiceHasAFigure() {
        // `figFail('no figure for '+who)` restated as the type system: eleven voices, and
        // `RoomFigures.draw`'s switch is exhaustive over them with no `default`, so this
        // count IS the guarantee. If a twelfth voice is ever added, the app stops compiling
        // — which is the outcome the comp could only report at runtime, in red, to a user.
        #expect(RoomKey.allCases.count == 11)
    }

    // MARK: - the branch nothing was watching

    @Test func noRoomRendersEmpty() {
        // The claim `figFail` exists to make. Measured, per voice, not asserted once.
        //
        // ITS LIMIT, MEASURED RATHER THAN REASONED: this test is BLIND to a figure deleted
        // behind its own wash. Run with Gaia's whole body removed and only her background
        // gradient left, it PASSES — as does `inkSurvivesTheHandAtBothExtremes`. Both are
        // kept because "the canvas is not blank" is still worth pinning and is the exact
        // claim `figFail` makes, but neither may be read as "the figure is drawn".
        // `everyRoomDrawsStructureNotJustAWash` is the one that carries that.
        var measured: [(RoomKey, Double)] = []
        for key in RoomKey.allCases { measured.append((key, Self.ink(key, Self.params()))) }

        for (key, frac) in measured {
            #expect(frac >= 0, "\(key.rawValue): the renderer produced no image at all")
            // 0.05% of 393×852 is ~167 pixels — below any real figure and above the stray
            // antialiasing a single hairline would leave. The bound is deliberately far
            // from every measured value; it is a floor for BLANK, not a fit to the figures.
            #expect(frac > 0.0005,
                    "\(key.rawValue) drew \(String(format: "%.4f%%", frac * 100)) ink — an empty room")
        }
    }

    @Test func inkSurvivesTheHandAtBothExtremes() {
        // Six of the eleven answer `lat` by moving something to an extreme — Shweta's
        // circles slide until there is NOTHING BETWEEN THEM, Gaia's families break, Bindu's
        // circles strain and close. An extreme that empties the canvas would read on device
        // as "the room went blank when I pulled", and the resting test above would still
        // pass. So both ends, every voice.
        for key in RoomKey.allCases {
            for hand in [-1.0, 1.0] {
                let frac = Self.ink(key, Self.params(hand))
                #expect(frac > 0.0005,
                        "\(key.rawValue) at lat \(hand) drew \(String(format: "%.4f%%", frac * 100))")
            }
        }
    }

    @Test func ashWithNoDaysStillDrawsHisAxis() {
        // Ash is the one figure whose content is DATA — `ashDays` — and an empty base is the
        // ordinary first-run state, not an edge case. If his room is blank before anything
        // has been written, the app opens on the blank room the comp refuses to show.
        let frac = Self.ink(.ash, Self.params(days: []))
        #expect(frac > 0.0005,
                "Ash with no days drew \(String(format: "%.4f%%", frac * 100)) — a blank room on first run")
    }



    @Test func everyRoomDrawsStructureNotJustAWash() {
        // WHAT `noRoomRendersEmpty` CANNOT SEE, STATED AND THEN CLOSED.
        //
        // Most of the eleven open with a full-canvas wash — a radial or linear gradient laid
        // down before the figure. An ink threshold is met by that wash alone, so
        // `noRoomRendersEmpty` proves "the canvas is not blank" and NOT "the figure is
        // drawn". Delete a figure's body and leave its wash and it still passes; that is the
        // saturated-measure fault, and it is only visible by removing the thing being
        // measured and watching the number fail to move.
        //
        // Edges are the discriminator: a smooth gradient's neighbouring pixels differ by ~1,
        // every stroke and glyph against it differs by tens. The floor is deliberately far
        // below every real figure and far above what any gradient can produce.
        for key in RoomKey.allCases {
            let ed = Self.edges(key, Self.params(), band: 0.0...1.0)
            #expect(ed > 400, "\(key.rawValue) drew \(ed) edges — a wash with no figure in it")
        }
    }

    // MARK: - `branch` · what it grows out of

    @Test func gaiaStandsOnSomething() {
        // `The Rooms v4.html:306-312`. Four trees rise from `py = H` — the floor — five
        // levels deep, each limb `len*0.74` of its parent. Everything else in her figure is
        // the phyllotaxis about `cy = H*0.42`.
        //
        // THE RELATIONSHIP, not the outcome: "Gaia has more ink" is satisfied by drawing
        // anything anywhere, and in fact was — her wash alone filled the floor band, so the
        // first version of this test passed identically with and without the trees. What
        // `branch` claims is that her room is built UP FROM THE FLOOR, so the measurement
        // has to be of STRUCTURE low on the canvas: strokes, which have edges, against a
        // wash, which has none.
        let floorBand = 0.90...1.0
        let gaia = Self.edges(.gaia, Self.params(), band: floorBand)
        // Bindu is the control: a figure centred on `cy` whose own wash covers the same
        // band — the shape Gaia had before this port, and the shape her room must no longer
        // have. If the wash were doing the work here, these two would be equal.
        let bindu = Self.edges(.bindu, Self.params(), band: floorBand)
        #expect(gaia > bindu + 200,
                "Gaia's floor band holds \(gaia) edges against Bindu's \(bindu) — nothing is growing")
    }

    @Test func theTreesSwayRatherThanSit() {
        // `sway = sin(t*0.3 + seed) * 0.06`, applied to every limb's ANGLE so the whole tree
        // leans as one. Measured as alpha CHANGE per pixel rather than ink appearing or
        // disappearing, because over Gaia's lit wash a moving stroke never crosses a
        // presence threshold — it only changes the value underneath it.
        //
        // Band 0.90…1.0 deliberately: Gaia's dust spiral reaches `cy + max(W,H)*0.5` ≈ y 783,
        // so it is outside this band and cannot answer on the trees' behalf. Below y 767 the
        // trees are the only thing that moves with `t`.
        let band = 0.90...1.0
        let p = Self.params()
        let A = Self.alpha(.gaia, p, t: 0), B = Self.alpha(.gaia, p, t: 5.2)
        #expect(A.w > 0 && A.w == B.w && A.h == B.h)

        let y0 = Int(Double(A.h) * band.lowerBound), y1 = Int(Double(A.h) * band.upperBound)
        var moved = 0
        for y in y0..<y1 {
            for x in 0..<A.w {
                let i = y * A.w + x
                if abs(Int(A.a[i]) - Int(B.a[i])) > 6 { moved += 1 }
            }
        }
        #expect(moved > 200, "only \(moved) pixels changed between t=0 and t=5.2 — the trees are standing still")
    }

    // MARK: - calibration: this test can fail

    @Test func theInkFloorCatchesABlankCanvas() {
        // Q2. A measurement that cannot go red is not a measurement — and this one's whole
        // job is to distinguish "drew something" from "drew nothing", so the empty case has
        // to be shown to land below the floor rather than assumed to.
        let size = CGSize(width: Self.W, height: Self.H)
        let blank = Canvas { _, _ in }.frame(width: Self.W, height: Self.H)
        let renderer = ImageRenderer(content: blank)
        renderer.scale = 1
        var frac = -1.0
        if let cg = renderer.cgImage {
            let w = cg.width, h = cg.height
            var px = [UInt8](repeating: 0, count: w * h * 4)
            if let bmp = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8,
                                   bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                bmp.draw(cg, in: CGRect(origin: .zero, size: size))
                var lit = 0
                for i in stride(from: 0, to: px.count, by: 4) where px[i + 3] > 8 { lit += 1 }
                frac = Double(lit) / Double(w * h)
            }
        }
        #expect(frac <= 0.0005, "an empty Canvas measured \(frac) ink — the floor cannot discriminate")
    }
}
