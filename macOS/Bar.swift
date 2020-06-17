import AppKit

final class Bar: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let current = Current()
        addSubview(current)
        
        let separator = NSView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.wantsLayer = true
        separator.layer!.backgroundColor = NSColor.controlShadowColor.cgColor
        addSubview(separator)
        
        let store = Button(image: "store")
        store.target = NSApp
        store.action = #selector(App.store)
        addSubview(store)
        
        let settings = Button(image: "settings")
        settings.target = NSApp
        settings.action = #selector(App.settings)
        addSubview(settings)
        
        heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        current.topAnchor.constraint(equalTo: topAnchor).isActive = true
        current.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        current.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        current.bottomAnchor.constraint(equalTo: separator.topAnchor).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        store.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        store.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        settings.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        settings.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

private final class Button: Control {
    private weak var image: NSImageView!
    
    required init?(coder: NSCoder) { nil }
    init(image: String) {
        super.init()
        
        let image = NSImageView(image: NSImage(named: image)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        addSubview(image)
        self.image = image
        
        widthAnchor.constraint(equalToConstant: 44).isActive = true
        heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 24).isActive = true
        image.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        hoverOff()
    }
    
    override func hoverOn() {
        image.contentTintColor = .systemBlue
    }
    
    override func hoverOff() {
        image.contentTintColor = .secondaryLabelColor
    }
}
