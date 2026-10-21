import AppKit
let path = CommandLine.arguments[1]
try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = points * scale
        let image = NSImage(size: NSSize(width: pixels, height: pixels))
        image.lockFocus()
        let s = CGFloat(pixels) / 1024
        let transform = AffineTransform(scale: s)
        (transform as NSAffineTransform).concat()
        let background = NSBezierPath(roundedRect: NSRect(x: 42, y: 42, width: 940, height: 940), xRadius: 220, yRadius: 220)
        NSColor(calibratedRed: 0.08, green: 0.23, blue: 0.48, alpha: 1).setFill()
        background.fill()
        let mouse = NSBezierPath(roundedRect: NSRect(x: 273, y: 200, width: 360, height: 622), xRadius: 180, yRadius: 180)
        NSColor.white.setFill(); mouse.fill()
        let wheel = NSBezierPath(roundedRect: NSRect(x: 426, y: 636, width: 54, height: 100), xRadius: 27, yRadius: 27)
        NSColor(calibratedRed: 0.08, green: 0.23, blue: 0.48, alpha: 1).setFill(); wheel.fill()
        NSColor(calibratedRed: 0.32, green: 0.88, blue: 0.78, alpha: 1).setStroke()
        for offset in [0.0, 88.0] {
            let wave = NSBezierPath()
            wave.move(to: NSPoint(x: 718 + offset, y: 430))
            wave.curve(to: NSPoint(x: 718 + offset, y: 660), controlPoint1: NSPoint(x: 798 + offset, y: 485), controlPoint2: NSPoint(x: 798 + offset, y: 605))
            wave.lineWidth = 34; wave.lineCapStyle = .round; wave.stroke()
        }
        image.unlockFocus()
        guard let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("Icon render failed") }
        let suffix = scale == 2 ? "@2x" : ""
        try png.write(to: URL(fileURLWithPath: "\(path)/icon_\(points)x\(points)\(suffix).png"))
    }
}
