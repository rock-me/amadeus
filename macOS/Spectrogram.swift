import AppKit

final class Spectrogram: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.cornerRadius = 10
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    override func updateLayer() {
        layer!.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
}
