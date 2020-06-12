import UIKit
import Combine
import Player

final class Coverflow: UIView {
    private weak var music: Music!
    private weak var scroll: Scroll!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(music: Music) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.music = music
        
        let scroll = Scroll()
        scroll.alwaysBounceHorizontal = true
        scroll.alwaysBounceVertical = false
        addSubview(scroll)
        self.scroll = scroll
        
        var left = scroll.left
        Album.allCases.forEach {
            let item = Item(album: $0)
            item.target = self
            scroll.add(item)
            
            item.leftAnchor.constraint(equalTo: left, constant: left == scroll.left ? 100 : 10).isActive = true
            item.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
            item.bottomAnchor.constraint(equalTo: scroll.bottom, constant: -20).isActive = true
            
            left = item.rightAnchor
        }
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.height.constraint(equalTo: scroll.heightAnchor).isActive = true
        scroll.bottom.constraint(equalTo: scroll.bottomAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: scroll.rightAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: left, constant: 100).isActive = true
        
        heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        session.player.config.sink { [weak self] config in
            guard let self = self else { return }
            scroll.views.map { $0 as! Item }.forEach { item in
                item.purchase.isHidden = config.purchases.contains(item.album.purchase)
                item.action = config.purchases.contains(item.album.purchase) ? #selector(self.select(item:)) : #selector(self.store)
            }
        }.store(in: &subs)
    }
    
    func show(_ album: Album) {
        selected(item: scroll.views.map { $0 as! Item }.first { $0.album == album }!)
    }
    
    private func selected(item: Item) {
        scroll.views.map { $0 as! Item }.forEach {
            $0.selected = $0 == item
        }
        scroll.center(item.frame, duration: 0.5)
    }
    
    @objc private func select(item: Item) {
        guard !item.selected else { return }
        selected(item: item)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.scroll.content.layoutIfNeeded()
        }
        music.select(album: item.album)
    }
    
    @objc private func store() {
        session.ui.value.section = .store
    }
}

private final class Item: Control {
    var selected = false {
        didSet {
            width.constant = selected ? 140 : 98
            height.constant = selected ? -30 : -84
        }
    }
    
    let album: Album
    private(set) weak var purchase: UIView!
    private weak var base: UIView!
    private weak var width: NSLayoutConstraint!
    private weak var height: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init(album: Album) {
        self.album = album
        super.init()
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.backgroundColor = .secondarySystemBackground
        base.layer.cornerRadius = 10
        base.layer.shadowRadius = 6
        base.layer.shadowOffset.height = -3
        addSubview(base)
        self.base = base
        
        let image = UIImageView(image: UIImage(named: album.cover)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        addSubview(image)
        
        let shade = UIImageView(image: UIImage(named: "shade")!)
        shade.translatesAutoresizingMaskIntoConstraints = false
        shade.contentMode = .scaleAspectFill
        shade.clipsToBounds = true
        shade.layer.cornerRadius = 10
        addSubview(shade)
        
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.text = .key(album.title)
        name.font = .bold(-4)
        name.textColor = .white
        name.numberOfLines = 0
        addSubview(name)
        
        let purchase = UIView()
        purchase.translatesAutoresizingMaskIntoConstraints = false
        purchase.isUserInteractionEnabled = false
        purchase.backgroundColor = .init(white: 0, alpha: 0.85)
        purchase.isHidden = true
        addSubview(purchase)
        self.purchase = purchase
        
        let visitStore = UILabel()
        visitStore.translatesAutoresizingMaskIntoConstraints = false
        visitStore.text = .key("In.app")
        visitStore.font = .bold(-4)
        visitStore.textColor = .white
        visitStore.numberOfLines = 0
        purchase.addSubview(visitStore)
        
        widthAnchor.constraint(equalTo: base.widthAnchor, constant: 20).isActive = true
        
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        width = base.widthAnchor.constraint(equalToConstant: 98)
        width.isActive = true
        height = base.heightAnchor.constraint(equalTo: heightAnchor, constant: -84)
        height.isActive = true
        
        image.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        image.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        shade.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        shade.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        shade.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        shade.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        name.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -10).isActive = true
        name.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        name.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -10).isActive = true
        
        purchase.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        purchase.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        purchase.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        purchase.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        visitStore.centerYAnchor.constraint(equalTo: purchase.centerYAnchor).isActive = true
        visitStore.centerXAnchor.constraint(equalTo: purchase.centerXAnchor).isActive = true
    }
}
