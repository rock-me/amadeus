import AppKit

final class Bar: NSView {
    private weak var base: NSView!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 4
        addSubview(base)
        self.base = base
        
        let separator = Separator()
        addSubview(separator)
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 24).isActive = true
        base.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func updateLayer() {
        base.layer!.backgroundColor = NSColor.controlHighlightColor.cgColor
    }
}
