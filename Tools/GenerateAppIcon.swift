#!/usr/bin/env swift
import AppKit
import CoreGraphics
import CoreText

let outputPath = CommandLine.arguments.dropFirst().first
    ?? "/Users/ashrey/Bindu Feed/Bindu Feed/Bindu Feed/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

let size: CGFloat = 1024
let cs = CGColorSpaceCreateDeviceRGB()

guard let ctx = CGContext(
    data: nil,
    width: Int(size),
    height: Int(size),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: cs,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    FileHandle.standardError.write(Data("Could not create context\n".utf8))
    exit(1)
}

func srgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: a)
}

let bg   = srgb(0x0E, 0x0C, 0x12)
let gold = srgb(0xD4, 0xA8, 0x53)
let goldR: CGFloat = 0xD4/255
let goldG: CGFloat = 0xA8/255
let goldB: CGFloat = 0x53/255

// Background fill
ctx.setFillColor(bg)
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))

// --- Deterministic RNG so the icon is reproducible ---
struct SeededRNG: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state &>> 32 | state &<< 32
    }
}
var rng = SeededRNG(state: 0xB1_4D_FE_ED_2026_0521)

// --- Helper: draw centered glyph at a point ---
func draw(glyph: String, at p: CGPoint, fontSize: CGFloat, alpha: CGFloat) {
    let color = CGColor(srgbRed: goldR, green: goldG, blue: goldB, alpha: alpha)
    let font = NSFont.systemFont(ofSize: fontSize)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(cgColor: color)!
    ]
    let str = NSAttributedString(string: glyph, attributes: attrs)
    let line = CTLineCreateWithAttributedString(str)
    let bounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds])
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: p.x - bounds.midX, y: p.y - bounds.midY)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

// --- Matrix layer: falling room glyphs ---
let glyphs = ["◈","◆","◇","·","✦","○","△","⬡","⊕","◎","✧","▲","∞"]

// 11 vertical strands, each with 8-14 glyphs at varied sizes.
let columnCount = 11
let columnWidth = size / CGFloat(columnCount)

for col in 0..<columnCount {
    let xJitter = CGFloat.random(in: -columnWidth * 0.35 ... columnWidth * 0.35, using: &rng)
    let x = CGFloat(col) * columnWidth + columnWidth / 2 + xJitter
    let baseSize = CGFloat.random(in: 38 ... 78, using: &rng)
    let glyphsInColumn = Int.random(in: 8 ... 14, using: &rng)
    let vSpacing = baseSize * CGFloat.random(in: 1.4 ... 2.1, using: &rng)
    let yStart = CGFloat.random(in: -baseSize ... size, using: &rng)

    for g in 0 ..< glyphsInColumn {
        let rawY = yStart + CGFloat(g) * vSpacing
        let y = rawY.truncatingRemainder(dividingBy: size + 80)
        let glyph = glyphs[Int.random(in: 0 ..< glyphs.count, using: &rng)]
        let sz = baseSize * CGFloat.random(in: 0.65 ... 1.25, using: &rng)
        let alpha = CGFloat.random(in: 0.08 ... 0.10, using: &rng)
        draw(glyph: glyph, at: CGPoint(x: x, y: y), fontSize: sz, alpha: alpha)
    }
}

// A few accent glyphs at slightly higher opacity, scattered.
for _ in 0..<14 {
    let p = CGPoint(
        x: CGFloat.random(in: 60 ... (size - 60), using: &rng),
        y: CGFloat.random(in: 60 ... (size - 60), using: &rng)
    )
    let glyph = glyphs[Int.random(in: 0..<glyphs.count, using: &rng)]
    let sz = CGFloat.random(in: 24 ... 46, using: &rng)
    draw(glyph: glyph, at: p, fontSize: sz, alpha: 0.12)
}

// --- The golden Bindu dot with soft radial glow at center ---
let center = CGPoint(x: size / 2, y: size / 2)

// Wide soft halo
let haloColors = [
    CGColor(srgbRed: goldR, green: goldG, blue: goldB, alpha: 0.42),
    CGColor(srgbRed: goldR, green: goldG, blue: goldB, alpha: 0.0)
] as CFArray
let haloGrad = CGGradient(colorsSpace: cs, colors: haloColors, locations: [0.0, 1.0])!
ctx.drawRadialGradient(
    haloGrad,
    startCenter: center, startRadius: 0,
    endCenter: center, endRadius: 380,
    options: []
)

// Inner brighter glow
let innerColors = [
    CGColor(srgbRed: 1.0, green: 0.92, blue: 0.70, alpha: 0.55),
    CGColor(srgbRed: goldR, green: goldG, blue: goldB, alpha: 0.0)
] as CFArray
let innerGrad = CGGradient(colorsSpace: cs, colors: innerColors, locations: [0.0, 1.0])!
ctx.drawRadialGradient(
    innerGrad,
    startCenter: center, startRadius: 0,
    endCenter: center, endRadius: 170,
    options: []
)

// The dot itself
let dotRadius: CGFloat = 90
ctx.setFillColor(gold)
ctx.fillEllipse(in: CGRect(
    x: center.x - dotRadius,
    y: center.y - dotRadius,
    width: dotRadius * 2,
    height: dotRadius * 2
))

// Tiny inner highlight to give the dot life (off-center, top-left)
let highlightCenter = CGPoint(x: center.x - 18, y: center.y + 22)
let highlightColors = [
    CGColor(srgbRed: 1.0, green: 0.96, blue: 0.82, alpha: 0.85),
    CGColor(srgbRed: 1.0, green: 0.92, blue: 0.70, alpha: 0.0)
] as CFArray
let highlightGrad = CGGradient(colorsSpace: cs, colors: highlightColors, locations: [0.0, 1.0])!
ctx.drawRadialGradient(
    highlightGrad,
    startCenter: highlightCenter, startRadius: 0,
    endCenter: highlightCenter, endRadius: 50,
    options: []
)

// --- Encode + write PNG ---
guard let cgImage = ctx.makeImage() else {
    FileHandle.standardError.write(Data("Could not snapshot image\n".utf8))
    exit(1)
}
let bitmap = NSBitmapImageRep(cgImage: cgImage)
guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("PNG encoding failed\n".utf8))
    exit(1)
}
let url = URL(fileURLWithPath: outputPath)
try? FileManager.default.createDirectory(
    at: url.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
do {
    try pngData.write(to: url)
    FileHandle.standardOutput.write(Data("Wrote \(outputPath)\n".utf8))
} catch {
    FileHandle.standardError.write(Data("Write failed: \(error)\n".utf8))
    exit(1)
}
