import AppKit

final class Separator: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = .init(gray: 0.9, alpha: 1)
    }
    
    override func updateLayer() {
        layer!.backgroundColor = NSColor.controlDarkShadowColor.cgColor
    }
}
