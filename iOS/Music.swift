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
        scroll.alwaysBounceVertical = true
        scroll.alwaysBounceHorizontal = false
        view.addSubview(scroll)
        
        let coverflow = Coverflow(music: self)
        scroll.add(coverflow)
        self.coverflow = coverflow
        
        let shop = Button(icon: "bag.fill")
        shop.target = self
        shop.action = #selector(store)
        scroll.add(shop)
        
        let settings = Button(icon: "dial.fill")
        settings.target = self
        settings.action = #selector(self.settings)
        scroll.add(settings)
        
        let detail = Detail()
        detail.target = self
        detail.store = #selector(store)
        scroll.add(detail)
        self.detail = detail
        
        let bar = Bar()
        bar.target = self
        bar.action = #selector(hud)
        view.addSubview(bar)
        
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: detail.bottomAnchor, constant: 30).isActive = true
        
        shop.topAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.topAnchor).isActive = true
        shop.rightAnchor.constraint(equalTo: scroll.centerX, constant: -5).isActive = true
        
        settings.topAnchor.constraint(equalTo: shop.topAnchor).isActive = true
        settings.leftAnchor.constraint(equalTo: scroll.centerX, constant: 5).isActive = true
        
        coverflow.topAnchor.constraint(equalTo: shop.bottomAnchor, constant: -20).isActive = true
        coverflow.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        coverflow.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        detail.topAnchor.constraint(equalTo: coverflow.bottomAnchor).isActive = true
        detail.leftAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        detail.rightAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        bar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        session.loadUI.sink { [weak self] in
            if !$0 {
                session.add(ui: .zero)
            }
            session.loadPlayer()
            self?.show(session.ui.value.album)
        }.store(in: &subs)
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
    
    @objc private func hud() {
        present(Hud(), animated: true)
    }
    
    @objc private func store() {
        present(Store(), animated: true)
    }
    
    @objc private func settings() {
        present(Store(), animated: true)
    }
}

private final class Button: Control {
    private weak var image: UIImageView!
    
    required init?(coder: NSCoder) { nil }
    init(icon: String) {
        super.init()
        let image = UIImageView(image: UIImage(systemName: icon)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        self.image = image
        
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        hoverOff()
    }
    
    override func hoverOff() {
        image.tintColor = .secondaryLabel
    }
    
    override func hoverOn() {
        image.tintColor = .systemBlue
    }
}
