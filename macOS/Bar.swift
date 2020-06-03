import AppKit
import Combine

final class Bar: NSView {
    private weak var base: NSView!
    private var subs = Set<AnyCancellable>()
    
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
        
        let title = Label("", .regular(10))
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        title.maximumNumberOfLines = 1
        title.lineBreakMode = .byTruncatingTail
        base.addSubview(title)
        
        let separator = Separator()
        addSubview(separator)
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 24).isActive = true
        base.widthAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true
        let width = base.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.3)
        width.priority = .defaultLow
        width.isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -10).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        playback.sink {
            title.stringValue = .key("track_\($0.track)_composer") + " - " + .key("track_\($0.track)_title")
        }.store(in: &subs)
    }
    
    override func updateLayer() {
        base.layer!.backgroundColor = NSColor.controlHighlightColor.cgColor
    }
}
