import AppKit
import Player
import Combine

final class Detail: NSView {
    private weak var title: Label!
    private weak var subtitle: Label!
    private weak var duration: Label!
    private var subs = Set<AnyCancellable>()
    private let formatter = DateComponentsFormatter()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.allowedUnits = [.minute, .second]
        
        let title = Label("", .bold(14))
        title.textColor = .headerTextColor
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        self.title = title
        
        let subtitle = Label("", .regular(4))
        subtitle.textColor = .secondaryLabelColor
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(subtitle)
        self.subtitle = subtitle
        
        let duration = Label("", .monospaced(.medium(2)))
        duration.textColor = .tertiaryLabelColor
        addSubview(duration)
        self.duration = duration
        
        widthAnchor.constraint(equalToConstant: 350).isActive = true
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        subtitle.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 20).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        duration.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 5).isActive = true
        duration.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        state.player.track.dropFirst().sink { [weak self] in
            self?.current($0)
        }.store(in: &self.subs)
    }
    
    func show(_ album: Album) {
        title.stringValue = .key(album.title)
        subtitle.stringValue = .key(album.subtitle)
        duration.stringValue = formatter.string(from: album.duration)!
        
        subviews.filter { !($0 is Label) }.forEach {
            $0.removeFromSuperview()
        }
        
        if state.player.config.value.purchases.contains(album.purchase) {
            var top = duration.bottomAnchor
            album.tracks.forEach {
                let item = Item(track: $0, duration: formatter.string(from: $0.duration)!)
                item.target = self
                item.action = #selector(select(item:))
                addSubview(item)
                
                if top == duration.bottomAnchor {
                    item.topAnchor.constraint(equalTo: top, constant: 30).isActive = true
                } else {
                    let separator = Separator()
                    addSubview(separator)
                    
                    separator.topAnchor.constraint(equalTo: top, constant: 2).isActive = true
                    separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
                    separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
                    
                    item.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 2).isActive = true
                }
                
                item.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                item.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
                
                top = item.bottomAnchor
            }
            
            bottomAnchor.constraint(equalTo: top).isActive = true
            current(state.player.track.value)
        } else {
            let button = Button(.key("In.app"))
            button.target = self
            button.action = #selector(store)
            addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            button.topAnchor.constraint(equalTo: duration.bottomAnchor, constant: 30).isActive = true
            bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 30).isActive = true
        }
    }
    
    private func current(_ track: Track) {
        subviews.compactMap { $0 as? Item }.forEach {
            $0.selected = $0.track == track
        }
    }
    
    private func show(_ item: Item) -> Bool {
        guard !item.selected else { return false }
        subviews.compactMap { $0 as? Item }.forEach {
            $0.selected = item == $0
        }
        return true
    }
    
    @objc private func select(item: Item) {
        guard show(item) else { return }
        state.player.track.value = item.track
    }
    
    @objc private func store() {
        
    }
}

private final class Item: Control {
    var selected = false {
        didSet {
            updateLayer()
        }
    }
    
    let track: Track
    
    required init?(coder: NSCoder) { nil }
    init(track: Track, duration: String) {
        self.track = track
        super.init()
        wantsLayer = true
        layer!.cornerRadius = 12
        
        let title = Label(.key(track.title), .bold())
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let composer = Label(.key(track.composer.name), .regular())
        composer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        composer.textColor = .secondaryLabelColor
        addSubview(composer)
        
        let time = Label(duration, .monospaced(.medium()))
        time.textColor = .tertiaryLabelColor
        addSubview(time)
        
        bottomAnchor.constraint(equalTo: composer.bottomAnchor, constant: 15).isActive = true
                
        title.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: time.leftAnchor, constant: -10).isActive = true
    
        composer.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3).isActive = true
        composer.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        composer.rightAnchor.constraint(lessThanOrEqualTo: time.leftAnchor, constant: -10).isActive = true
        
        time.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        time.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func updateLayer() {
        layer!.backgroundColor = selected ? NSColor.systemBlue.cgColor : .clear
    }
    
    override func hoverOn() {
        layer!.backgroundColor = NSColor.systemBlue.cgColor
    }
    
    override func hoverOff() {
        updateLayer()
    }
}

private class Button: Control {
    required init?(coder: NSCoder) { nil }
    init(_ title: String) {
        super.init()
        wantsLayer = true
        layer!.cornerRadius = 14
        
        let label = Label(title, .regular())
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 28).isActive = true
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func updateLayer() {
        layer!.backgroundColor = NSColor.systemBlue.cgColor
    }
    
    override func hoverOff() {
        alphaValue = 1
    }
    
    override func hoverOn() {
        alphaValue = 0.3
    }
}
