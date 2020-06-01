import AppKit

final class Side: NSView {
    private(set) weak var music: Control!
    private(set) weak var stats: Control!
    private(set) weak var store: Control!
    private(set) weak var settings: Control!
    private weak var view: View!
    private weak var indicator: NSView!
    private weak var indicatorY: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            indicatorY?.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init(view: View) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.view = view
        
        let blur = NSVisualEffectView()
        blur.material = .sidebar
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)
        
        music = item(.key("Music"), top: topAnchor)
        music.action = #selector(openMusic)
        
        stats = item(.key("Stats"), top: music.bottomAnchor)
        stats.action = #selector(openStats)
        
        store = item(.key("Store"), top: stats.bottomAnchor)
        store.action = #selector(openStore)
        
        settings = item(.key("Settings"), top: store.bottomAnchor)
        settings.action = #selector(openSettings)
        
        let indicator = NSView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.wantsLayer = true
        indicator.layer!.cornerRadius = 1
        addSubview(indicator)
        self.indicator = indicator
        
        let separator = Separator()
        addSubview(separator)
        
        widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blur.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        blur.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        separator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        indicator.rightAnchor.constraint(equalTo: separator.rightAnchor, constant: -10).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 2).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    override func updateLayer() {
        indicator.layer!.backgroundColor = NSColor.highlightColor.cgColor
    }
    
    private func item(_ title: String, top: NSLayoutYAxisAnchor) -> Item {
        let item = Item(title: title)
        item.target = self
        addSubview(item)
        
        item.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        item.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        item.topAnchor.constraint(equalTo: top).isActive = true
        
        return item
    }
    
    private func select(item: Item) -> Bool {
        guard !item.selected else { return false }
        subviews.compactMap { $0 as? Item }.forEach {
            $0.selected = item == $0
        }
        indicatorY = indicator.centerYAnchor.constraint(equalTo: item.centerYAnchor)
        return true
    }
    
    @objc private func openMusic(_ item: Item) {
        guard select(item: item) else { return }
        view.show(Music())
        persistance.update(.music)
    }
    
    @objc private func openStats(_ item: Item) {
        guard select(item: item) else { return }
        persistance.update(.stats)
    }
    
    @objc private func openStore(_ item: Item) {
        guard select(item: item) else { return }
        persistance.update(.store)
    }
    
    @objc private func openSettings(_ item: Item) {
        guard select(item: item) else { return }
        persistance.update(.settings)
    }
}

private final class Item: Control {
    var selected = false {
        didSet {
            updateLayer()
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init(title: String) {
        super.init()
        wantsLayer = true
        
        let label = Label(title, .medium(12))
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func updateLayer() {
        layer!.backgroundColor = selected ? NSColor.controlHighlightColor.cgColor : .clear
    }
}
