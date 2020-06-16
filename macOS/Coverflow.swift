import AppKit
import Player

final class Coverflow: NSView {
    private weak var center: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            center!.isActive = true
        }
    }
    
    private weak var detail: Detail!
    
    required init?(coder: NSCoder) { nil }
    init(detail: Detail) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.detail = detail
        
        var left: NSLayoutXAxisAnchor?
        Album.allCases.forEach {
            let item = Item(album: $0)
            item.target = self
            item.action = #selector(select(item:))
            addSubview(item)
            
            if left != nil {
                item.leftAnchor.constraint(equalTo: left!, constant: 10).isActive = true
            }
            item.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            left = item.rightAnchor
        }
        
        heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    func show(_ album: Album) {
        select(item: subviews.map { $0 as! Item }.first { $0.album == album }!)
    }
    
    @objc private func select(item: Item) {
        guard !item.selected else { return }
        center = item.centerXAnchor.constraint(equalTo: centerXAnchor)
        subviews.map { $0 as! Item }.forEach {
            $0.selected = $0 == item
        }
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
        detail.show(item.album)
    }
}

private final class Item: Control {
    var selected = false {
        didSet {
            width.constant = selected ? 200 : 120
            height.constant = selected ? 260 : 156
            
            NSAnimationContext.runAnimationGroup {
                $0.duration = 3
                $0.allowsImplicitAnimation = true
                name.alphaValue = selected ? 0 : 1
                shade.alphaValue = selected ? 0 : 1
            }
        }
    }
    
    let album: Album
    private weak var name: Label!
    private weak var shade: NSImageView!
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
        base.layer!.backgroundColor = NSColor.controlBackgroundColor.cgColor
        base.shadow = shadow
        addSubview(base)
        
        let image = NSImageView(image: NSImage(named: album.cover)!)
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
        self.shade = shade
        
        let name = Label(.key(album.title), .bold(12))
        name.textColor = .white
        addSubview(name)
        self.name = name
        
        widthAnchor.constraint(equalTo: base.widthAnchor, constant: 40).isActive = true
        heightAnchor.constraint(equalTo: base.heightAnchor, constant: 20).isActive = true
        
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        width = base.widthAnchor.constraint(equalToConstant: 120)
        width.isActive = true
        height = base.heightAnchor.constraint(equalToConstant: 156)
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
}
