import Player
import UIKit
import Combine

final class Music: UIViewController {
    private weak var detail: Detail!
    private weak var coverflow: Coverflow!
    private var subs = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let scroll = Scroll()
        scroll.showsVerticalScrollIndicator = true
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)
        
        let coverflow = Coverflow(music: self)
        scroll.add(coverflow)
        self.coverflow = coverflow
        
        let detail = Detail()
        scroll.add(detail)
        self.detail = detail
        
        let bar = Bar()
        bar.target = self
        bar.action = #selector(hud)
        view.addSubview(bar)
        
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bar.topAnchor).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: detail.bottomAnchor, constant: 30).isActive = true
        
        coverflow.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        coverflow.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        coverflow.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        detail.topAnchor.constraint(equalTo: coverflow.bottomAnchor, constant: 30).isActive = true
        detail.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        detail.rightAnchor.constraint(equalTo: scroll.right, constant: -30).isActive = true
        
        bar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        session.loadUI.sink { [weak self] _ in
            session.loadPlayer()
            self?.show(session.ui.value.album)
        }.store(in: &subs)
    }
    
    @objc private func hud() {
        present(Hud(), animated: true)
    }
    
    func select(album: Album) {
        show(album)
        session.update {
            $0.album = album
        }
    }
    
    private func show(_ album: Album) {
        coverflow.show(album)
        detail.show(album)
    }
}
