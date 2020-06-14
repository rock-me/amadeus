import UIKit
import Player
import Combine

final class Detail: UIView {
    weak var target: AnyObject!
    var store: Selector!
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
        title.font = .bold(12)
        title.numberOfLines = 0
        addSubview(title)
        self.title = title
        
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.font = .regular(2)
        subtitle.numberOfLines = 0
        subtitle.textColor = .secondaryLabel
        subtitle.textAlignment = .center
        addSubview(subtitle)
        self.subtitle = subtitle
        
        let duration = UILabel()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.font = .monospaced(.medium())
        duration.textColor = .tertiaryLabel
        addSubview(duration)
        self.duration = duration
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4).isActive = true
        subtitle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        subtitle.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 20).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        duration.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        duration.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 4).isActive = true
        
        state.player.track.dropFirst().sink { [weak self] in
            self?.current($0)
        }.store(in: &self.subs)
        
        state.player.config.dropFirst().sink { [weak self] _ in
            self?.show(state.ui.value.album)
        }.store(in: &subs)
    }
    
    func show(_ album: Album) {
        UIView.transition(with: title, duration: 0.6, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.title.text = .key(album.title)
        })
        
        UIView.transition(with: subtitle, duration: 0.6, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.subtitle.text = .key(album.subtitle)
        })
        
        UIView.transition(with: duration, duration: 0.6, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.duration.text = self?.formatter.string(from: album.duration)!
        })
        
        subviews.filter { !($0 is UILabel) }.forEach {
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
            button.target = target
            button.action = store
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
        time.font = .monospaced(.regular(-2))
        time.textColor = .tertiaryLabel
        time.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
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
    
    override func hoverOn() {
        backgroundColor = .systemBlue
    }
    
    override func hoverOff() {
        backgroundColor = selected ? .systemBlue : .clear
    }
}

private class Button: Control {
    required init?(coder: NSCoder) { nil }
    init(_ title: String) {
        super.init()
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.backgroundColor = .systemBlue
        base.layer.cornerRadius = 14
        addSubview(base)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .regular(-2)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(label)
        
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        base.heightAnchor.constraint(equalToConstant: 28).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func hoverOn() {
        alpha = 0.3
    }
    
    override func hoverOff() {
        alpha = 1
    }
}
