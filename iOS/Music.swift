import UIKit
import Combine

final class Music: UIViewController {
    private var subs = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let bar = Bar()
        bar.target = self
        bar.action = #selector(hud)
        view.addSubview(bar)
        
        bar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        session.loadUI.sink { _ in
            session.loadPlayer()
        }.store(in: &subs)
    }
    
    @objc private func hud() {
        present(Hud(), animated: true)
    }
}
