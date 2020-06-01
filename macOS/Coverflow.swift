import AppKit

final class Coverflow: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        scroll.verticalScrollElasticity = .none
        scroll.horizontalScrollElasticity = .allowed
        addSubview(scroll)
        
        var left = scroll.left
        Album.id.allCases.forEach {
            let item = Item(id: $0)
            scroll.add(item)
            
            item.leftAnchor.constraint(equalTo: left, constant: 10).isActive = true
            item.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
            item.bottomAnchor.constraint(equalTo: scroll.bottom, constant: -20).isActive = true
            
            left = item.rightAnchor
        }
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: scroll.rightAnchor).isActive = true
        scroll.bottom.constraint(equalTo: scroll.bottomAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: left, constant: 20).isActive = true
        
        heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
}

private final class Item: Control {
    let id: Album.id
    private weak var base: NSView!
    
    required init?(coder: NSCoder) { nil }
    init(id: Album.id) {
        self.id = id
        super.init()
        
        let album = Album(id)
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 6
        shadow.shadowOffset.height = -3
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 10
        base.shadow = shadow
        addSubview(base)
        self.base = base
        
        let image = NSImageView(image: NSImage(named: "album_\(id)")!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.wantsLayer = true
        image.layer!.cornerRadius = 10
        addSubview(image)
        
        let shade = NSImageView(image: NSImage(named: "shade")!)
        shade.translatesAutoresizingMaskIntoConstraints = false
        shade.wantsLayer = true
        shade.layer!.cornerRadius = 10
        addSubview(shade)
        
        let name = Label(.key("album_\(id)"), .bold(16))
        name.textColor = .white
        addSubview(name)
        
        widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
        image.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        image.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        shade.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        shade.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        shade.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        shade.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        name.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -10).isActive = true
        name.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        name.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -10).isActive = true
    }
    
    override func updateLayer() {
        base.layer!.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
}
