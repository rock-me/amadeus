import AppKit
import Player
import Combine

final class Detail: NSView {
    weak var centerX: NSLayoutConstraint!
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
        
        let title = Label("", .bold(20))
        title.textColor = .headerTextColor
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        self.title = title
        
        let subtitle = Label("", .regular(12))
        subtitle.textColor = .secondaryLabelColor
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(subtitle)
        self.subtitle = subtitle
        
        let duration = Label("", .monospaced(.regular(12)))
        duration.textColor = .secondaryLabelColor
        addSubview(duration)
        self.duration = duration
        
        widthAnchor.constraint(equalToConstant: 350).isActive = true
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: duration.leftAnchor, constant: -10).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: duration.leftAnchor, constant: -10).isActive = true
        
        duration.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        duration.bottomAnchor.constraint(equalTo: subtitle.bottomAnchor).isActive = true
        
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
        
        var top = subtitle.bottomAnchor
        album.tracks.forEach {
            let separator = Separator()
            addSubview(separator)
            
            let item = Item(track: $0, duration: formatter.string(from: $0.duration)!)
            item.target = self
            item.action = #selector(select(item:))
            addSubview(item)
            
            item.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            separator.leftAnchor.constraint(equalTo: leftAnchor, constant: top == subtitle.bottomAnchor ? 0 : 15).isActive = true
            separator.rightAnchor.constraint(equalTo: rightAnchor, constant: top == subtitle.bottomAnchor ? 0 : -15).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            if top == subtitle.bottomAnchor {
                separator.topAnchor.constraint(equalTo: top, constant: 20).isActive = true
                item.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 20).isActive = true
            } else {
                separator.topAnchor.constraint(equalTo: top, constant: 2).isActive = true
                item.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 2).isActive = true
            }
            
            top = item.bottomAnchor
        }
        
        bottomAnchor.constraint(equalTo: top).isActive = true
        current(state.player.track.value)
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
        layer!.cornerRadius = 10
        
        let title = Label(.key(track.title), .bold(14))
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let composer = Label(.key(track.composer.name), .regular(14))
        composer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        composer.textColor = .secondaryLabelColor
        addSubview(composer)
        
        let time = Label(duration, .monospaced(.regular(12)))
        time.textColor = .secondaryLabelColor
        addSubview(time)
        
        bottomAnchor.constraint(equalTo: composer.bottomAnchor, constant: 15).isActive = true
        
        title.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: time.leftAnchor, constant: -10).isActive = true
    
        composer.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        composer.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        composer.rightAnchor.constraint(lessThanOrEqualTo: time.leftAnchor, constant: -10).isActive = true
        
        time.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
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
