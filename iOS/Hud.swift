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
        
        let current = Current()
        current.selector.backgroundColor = .tertiarySystemBackground
        view.addSubview(current)
        
        let close = Control()
        close.target = self
        close.action = #selector(done)
        view.addSubview(close)
        
        current.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        current.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        current.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        close.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        close.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        close.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        close.bottomAnchor.constraint(equalTo: current.selector.bottomAnchor, constant: 30).isActive = true
    }
    
    @objc private func done() {
        dismiss(animated: true)
    }
}
