import AppKit

final class Coverflow: NSView {
    private weak var music: Music!
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    init(music: Music) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.music = music
        
        let scroll = Scroll()
        scroll.verticalScrollElasticity = .none
        scroll.horizontalScrollElasticity = .allowed
        addSubview(scroll)
        self.scroll = scroll
        
        var left = scroll.left
        Album.allCases.forEach {
            let item = Item(album: $0)
            item.target = self
            item.action = #selector(select(item:))
            scroll.add(item)
            
            item.leftAnchor.constraint(equalTo: left, constant: left == scroll.left ? 40 : 10).isActive = true
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
        scroll.right.constraint(greaterThanOrEqualTo: left, constant: 40).isActive = true
        
        heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    func show(_ album: Album) {
        selected(item: scroll.views.map { $0 as! Item }.first { $0.album == album }!)
    }
    
    private func selected(item: Item) {
        scroll.views.map { $0 as! Item }.forEach {
            $0.selected = $0 == item
        }
        scroll.center(item.frame, duration: 0.5)
    }
    
    @objc private func select(item: Item) {
        selected(item: item)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 1
            $0.allowsImplicitAnimation = true
            scroll.documentView!.layoutSubtreeIfNeeded()
        }
        music.select(album: item.album)
    }
}

private final class Item: Control {
    var selected = false {
        didSet {
            width.constant = selected ? 140 : 98
            height.constant = selected ? -30 : -84
        }
    }
    
    let album: Album
    private weak var base: NSView!
    private weak var width: NSLayoutConstraint!
    private weak var height: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init(album: Album) {
        self.album = album
        super.init()
        
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
        
        let image = NSImageView(image: NSImage(named: "album_\(album)")!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyUpOrDown
        image.wantsLayer = true
        image.layer!.cornerRadius = 10
        addSubview(image)
        
        let shade = NSImageView(image: NSImage(named: "shade")!)
        shade.translatesAutoresizingMaskIntoConstraints = false
        shade.imageScaling = .scaleProportionallyUpOrDown
        shade.wantsLayer = true
        shade.layer!.cornerRadius = 10
        addSubview(shade)
        
        let name = Label(.key("album_\(album)"), .bold(10))
        name.textColor = .white
        addSubview(name)
        
        widthAnchor.constraint(equalTo: base.widthAnchor, constant: 20).isActive = true
        
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        width = base.widthAnchor.constraint(equalToConstant: 98)
        width.isActive = true
        height = base.heightAnchor.constraint(equalTo: heightAnchor, constant: -84)
        height.isActive = true
        
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
