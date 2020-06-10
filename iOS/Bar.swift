import UIKit
import Combine

final class Bar: UIView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        
        let selector = UIView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.isUserInteractionEnabled = false
        selector.backgroundColor = .tertiarySystemBackground
        selector.layer.cornerRadius = 2
        addSubview(selector)
        
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
        
        topAnchor.constraint(equalTo: selector.topAnchor, constant: -12).isActive = true
        
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
        
        session.player.track.sink {
            title.text = .key($0.title)
            composer.text = .key($0.composer.name)
        }.store(in: &subs)
    }
}
