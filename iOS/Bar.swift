import UIKit
import Combine

final class Bar: Control {
    private weak var selector: UIView!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        backgroundColor = .secondarySystemBackground
        
        let duration = UIView()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.isUserInteractionEnabled = false
        duration.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        addSubview(duration)
        
        let elapsed = UIView()
        elapsed.translatesAutoresizingMaskIntoConstraints = false
        elapsed.isUserInteractionEnabled = false
        elapsed.backgroundColor = .systemBlue
        addSubview(elapsed)
        
        let selector = UIView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.isUserInteractionEnabled = false
        selector.layer.cornerRadius = 2
        addSubview(selector)
        self.selector = selector
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .bold(-2)
        title.numberOfLines = 0
        title.textColor = .secondaryLabel
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let composer = UILabel()
        composer.translatesAutoresizingMaskIntoConstraints = false
        composer.font = .regular(-4)
        composer.numberOfLines = 0
        composer.textColor = .tertiaryLabel
        composer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(composer)
        
        topAnchor.constraint(equalTo: duration.topAnchor).isActive = true
        
        duration.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        duration.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        duration.heightAnchor.constraint(equalToConstant: 1).isActive = true
        duration.bottomAnchor.constraint(equalTo: selector.topAnchor, constant: -12).isActive = true
        
        elapsed.leftAnchor.constraint(equalTo: duration.leftAnchor).isActive = true
        elapsed.topAnchor.constraint(equalTo: duration.topAnchor).isActive = true
        elapsed.bottomAnchor.constraint(equalTo: duration.bottomAnchor).isActive = true
        let elapsedWidth = elapsed.widthAnchor.constraint(equalToConstant: 0)
        elapsedWidth.isActive = true
        
        selector.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -20).isActive = true
        selector.widthAnchor.constraint(equalToConstant: 25).isActive = true
        selector.heightAnchor.constraint(equalToConstant: 4).isActive = true
        selector.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        title.bottomAnchor.constraint(equalTo: composer.topAnchor, constant: -5).isActive = true
        
        composer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        composer.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        composer.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        composer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        hoverOff()
        
        session.player.track.sink {
            title.text = .key($0.title)
            composer.text = .key($0.composer.name)
        }.store(in: &subs)
        
        session.time.sink {
            elapsedWidth.constant = duration.bounds.width * .init($0 / session.player.track.value.duration)
        }.store(in: &subs)
    }
    
    override func hoverOn() {
        selector.backgroundColor = .systemBlue
    }
    
    override func hoverOff() {
        selector.backgroundColor = .tertiarySystemBackground
    }
}
