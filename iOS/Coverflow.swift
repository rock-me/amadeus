import UIKit
import Player

final class Coverflow: UIView, UIScrollViewDelegate {
    private weak var music: Music!
    private weak var scroll: Scroll!
    
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
        
        let margin = (min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 240) / 2
        var left = scroll.left
        Album.allCases.forEach {
            let item = Item(album: $0)
            item.target = self
            item.action = #selector(focus(item:))
            scroll.add(item)
            
            item.leftAnchor.constraint(equalTo: left, constant: left == scroll.left ? margin : 0).isActive = true
            item.centerYAnchor.constraint(equalTo: scroll.centerYAnchor).isActive = true
            left = item.rightAnchor
        }
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.height.constraint(equalTo: scroll.heightAnchor).isActive = true
        scroll.bottom.constraint(equalTo: scroll.bottomAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: scroll.rightAnchor).isActive = true
        scroll.width.constraint(equalToConstant: .init(160 * Album.allCases.count) + (margin * 2) + 80).isActive = true
        
        heightAnchor.constraint(equalToConstant: 390).isActive = true
    }
    
    func show(_ album: Album) {
        let item = scroll.views.map { $0 as! Item }.first { $0.album == album }!
        select(item: item)
        focus(item: item)
    }
    
    func scrollViewDidScroll(_: UIScrollView) {
        guard
            let item = scroll.content.hitTest(.init(x: bounds.midX + scroll.contentOffset.x, y: scroll.bounds.midY), with: nil) as? Item,
            !item.selected
        else { return }
        select(item: item)
        music.select(album: item.album)
    }
    
    private func select(item: Item) {
        scroll.delegate = nil
        scroll.views.map { $0 as! Item }.forEach {
            $0.selected = $0 == item
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: { [weak self] in
            self?.scroll.content.layoutIfNeeded()
        }) { [weak self] _ in
            self?.scroll.delegate = self
        }
    }
    
    @objc private func focus(item: Item) {
        scroll.center(item.frame, duration: 0.1)
    }
    
    @objc private func store() {
        state.ui.value.section = .store
    }
}

private final class Item: Control {
    var selected = false {
        didSet {
            width.constant = selected ? 200 : 120
            height.constant = selected ? 260 : 156
            base.layer.shadowOpacity = selected ? 0.6 : 0.3
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.name.alpha = self?.selected == true ? 0 : 1
                self?.shade.alpha = self?.selected == true ? 0 : 1
            }
        }
    }
    
    let album: Album
    private weak var base: UIView!
    private weak var name: UILabel!
    private weak var shade: UIImageView!
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
        base.layer.shadowOffset.height = 3
        base.layer.shadowColor = UIColor.secondaryLabel.cgColor
        base.layer.shadowRadius = 6
        addSubview(base)
        self.base = base
        
        let image = UIImageView(image: UIImage(named: album.cover)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        addSubview(image)
        
        let shade = UIImageView(image: UIImage(named: "shade")!)
        shade.translatesAutoresizingMaskIntoConstraints = false
        shade.contentMode = .scaleAspectFill
        shade.clipsToBounds = true
        shade.layer.cornerRadius = 10
        addSubview(shade)
        self.shade = shade
        
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.text = .key(album.title)
        name.textColor = .white
        name.numberOfLines = 0
        name.font = .bold(-4)
        name.alpha = 0
        addSubview(name)
        self.name = name
        
        widthAnchor.constraint(equalTo: base.widthAnchor, constant: 40).isActive = true
        heightAnchor.constraint(equalTo: base.heightAnchor, constant: 20).isActive = true
        
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        width = base.widthAnchor.constraint(equalToConstant: 100)
        width.isActive = true
        height = base.heightAnchor.constraint(equalToConstant: 130)
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
    }
}
