import UIKit

final class Music: UIViewController {
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
    }
    
    @objc private func hud() {
        present(Hud(), animated: true)
    }
}
