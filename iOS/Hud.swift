import UIKit
import Combine

final class Hud: UIViewController {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let duration = UIView()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.isUserInteractionEnabled = false
        duration.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.addSubview(duration)
        
        let elapsed = UIView()
        elapsed.translatesAutoresizingMaskIntoConstraints = false
        elapsed.isUserInteractionEnabled = false
        elapsed.backgroundColor = .systemBlue
        view.addSubview(elapsed)
        
        let selector = UIView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.isUserInteractionEnabled = false
        selector.layer.cornerRadius = 2
        selector.backgroundColor = .tertiarySystemBackground
        view.addSubview(selector)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .bold(-2)
        title.numberOfLines = 0
        title.textColor = .secondaryLabel
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(title)
        
        let composer = UILabel()
        composer.translatesAutoresizingMaskIntoConstraints = false
        composer.font = .regular(-4)
        composer.numberOfLines = 0
        composer.textColor = .tertiaryLabel
        composer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(composer)
        
//        duration.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        duration.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        duration.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        duration.bottomAnchor.constraint(equalTo: selector.topAnchor, constant: -12).isActive = true
//
//        elapsed.leftAnchor.constraint(equalTo: duration.leftAnchor).isActive = true
//        elapsed.topAnchor.constraint(equalTo: duration.topAnchor).isActive = true
//        elapsed.bottomAnchor.constraint(equalTo: duration.bottomAnchor).isActive = true
//        let elapsedWidth = elapsed.widthAnchor.constraint(equalToConstant: 0)
//        elapsedWidth.isActive = true
        
        selector.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        selector.widthAnchor.constraint(equalToConstant: 25).isActive = true
        selector.heightAnchor.constraint(equalToConstant: 4).isActive = true
        selector.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        title.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        title.topAnchor.constraint(equalTo: selector.bottomAnchor, constant: 20).isActive = true
        
        composer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        composer.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        composer.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        composer.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        
        session.player.track.sink {
            title.text = .key($0.title)
            composer.text = .key($0.composer.name)
        }.store(in: &subs)
        
//        session.time.sink {
//            elapsedWidth.constant = duration.bounds.width * .init($0 / session.player.track.value.duration)
//        }.store(in: &subs)
    }
}
