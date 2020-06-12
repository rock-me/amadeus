import UIKit
import Player
import Combine

final class Detail: UIView {
    private weak var title: UILabel!
    private weak var subtitle: UILabel!
    private weak var duration: UILabel!
    private var subs = Set<AnyCancellable>()
    private let formatter = DateComponentsFormatter()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.allowedUnits = [.minute, .second]
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .bold(8)
        title.numberOfLines = 0
        addSubview(title)
        self.title = title
        
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.font = .regular(-2)
        subtitle.numberOfLines = 0
        subtitle.textColor = .secondaryLabel
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(subtitle)
        self.subtitle = subtitle
        
        let duration = UILabel()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.font = .monospaced(.regular())
        duration.textColor = .tertiaryLabel
        duration.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(duration)
        self.duration = duration
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: duration.leftAnchor, constant: -10).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4).isActive = true
        subtitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: duration.leftAnchor, constant: -10).isActive = true
        
        duration.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        duration.bottomAnchor.constraint(equalTo: subtitle.bottomAnchor).isActive = true
        
        session.player.track.dropFirst().sink { [weak self] in
            self?.current($0)
        }.store(in: &self.subs)
    }
    
    func show(_ album: Album) {
        title.text = .key(album.title)
        subtitle.text = .key(album.subtitle)
        duration.text = formatter.string(from: album.duration)!
        
        subviews.filter { !($0 is UILabel) }.forEach {
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
            item.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 2).isActive = true
            
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            if top == subtitle.bottomAnchor {
                separator.topAnchor.constraint(equalTo: top, constant: 6).isActive = true
            } else {
                separator.topAnchor.constraint(equalTo: top, constant: 2).isActive = true
            }
            
            top = item.bottomAnchor
        }
        
        bottomAnchor.constraint(equalTo: top).isActive = true
        current(session.player.track.value)
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
        session.player.track.value = item.track
    }
}

private final class Item: Control {
    var selected = false {
        didSet {
            hoverOff()
        }
    }
    
    let track: Track
    
    required init?(coder: NSCoder) { nil }
    init(track: Track, duration: String) {
        self.track = track
        super.init()
        layer.cornerRadius = 10
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .bold(-2)
        title.text = .key(track.title)
        title.numberOfLines = 0
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let composer = UILabel()
        composer.translatesAutoresizingMaskIntoConstraints = false
        composer.font = .regular(-2)
        composer.text = .key(track.composer.name)
        composer.numberOfLines = 0
        composer.textColor = .secondaryLabel
        composer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(composer)
        
        let time = UILabel()
        time.translatesAutoresizingMaskIntoConstraints = false
        time.text = duration
        time.font = .monospaced(.regular())
        time.textColor = .tertiaryLabel
        time.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(time)
        
        bottomAnchor.constraint(equalTo: composer.bottomAnchor, constant: 15).isActive = true
            
        title.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: time.leftAnchor, constant: -10).isActive = true
    
        composer.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        composer.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        composer.rightAnchor.constraint(lessThanOrEqualTo: time.leftAnchor, constant: -10).isActive = true
        
        time.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        time.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func hoverOn() {
        backgroundColor = .systemBlue
    }
    
    override func hoverOff() {
        backgroundColor = selected ? .systemBlue : .clear
    }
}
