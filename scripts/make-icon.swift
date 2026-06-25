import AppKit

let size: CGFloat = 1024
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

let inset = size * 0.06
let bgRect = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
let bg = NSBezierPath(roundedRect: bgRect, xRadius: size * 0.22, yRadius: size * 0.22)
let gradient = NSGradient(colors: [
    NSColor(srgbRed: 0.36, green: 0.56, blue: 1.00, alpha: 1),
    NSColor(srgbRed: 0.15, green: 0.30, blue: 0.86, alpha: 1),
])!
gradient.draw(in: bg, angle: -90)

if let base = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: nil) {
    let conf = NSImage.SymbolConfiguration(pointSize: size * 0.5, weight: .semibold)
    if let glyph = base.withSymbolConfiguration(conf) {
        let tinted = NSImage(size: glyph.size)
        tinted.lockFocus()
        glyph.draw(in: NSRect(origin: .zero, size: glyph.size))
        NSColor.white.set()
        NSRect(origin: .zero, size: glyph.size).fill(using: .sourceAtop)
        tinted.unlockFocus()
        let gw = size * 0.42
        let gh = gw * (glyph.size.height / glyph.size.width)
        tinted.draw(in: NSRect(x: (size - gw) / 2, y: (size - gh) / 2, width: gw, height: gh))
    }
}

img.unlockFocus()

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"
let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let png = NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
