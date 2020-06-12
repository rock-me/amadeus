import UIKit
import Combine

final class Current: UIView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        let selector = UIView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.isUserInteractionEnabled = false
        selector.layer.cornerRadius = 2
        addSubview(selector)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .bold()
        title.numberOfLines = 0
        addSubview(title)
        
        let composer = UILabel()
        composer.translatesAutoresizingMaskIntoConstraints = false
        composer.font = .regular(-2)
        composer.numberOfLines = 0
        composer.textColor = .secondaryLabel
        addSubview(composer)
        
        topAnchor.constraint(equalTo: selector.topAnchor, constant: -20).isActive = true
        
        selector.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -20).isActive = true
        selector.widthAnchor.constraint(equalToConstant: 25).isActive = true
        selector.heightAnchor.constraint(equalToConstant: 4).isActive = true
        selector.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        title.bottomAnchor.constraint(equalTo: composer.topAnchor, constant: -5).isActive = true
        
        composer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        composer.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 20).isActive = true
        composer.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        composer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
        session.player.track.sink {
            title.text = .key($0.title)
            composer.text = .key($0.composer.name)
        }.store(in: &subs)
        
        session.playing.sink {
            selector.backgroundColor = $0 ? .systemBlue : .tertiarySystemBackground
        }.store(in: &subs)
    }
}
