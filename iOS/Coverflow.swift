import UIKit
import Player
import Combine

final class Coverflow: UIView {
    private weak var centerX: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            centerX!.isActive = true
        }
    }
    
    private weak var detail: Detail!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(detail: Detail) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.detail = detail
        
        var left: NSLayoutXAxisAnchor?
        Album.allCases.forEach {
            let item = Item(album: $0)
            item.target = self
            item.action = #selector(select(item:))
            addSubview(item)
            
            if left != nil {
                item.leftAnchor.constraint(equalTo: left!).isActive = true
            }
            item.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            left = item.rightAnchor
        }
        
        heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        state.player.config.dropFirst().sink { [weak self] _ in
            guard let album = self?.subviews.map({ $0 as! Item }).first(where: { $0.selected })?.album else { return }
            self?.detail.show(album)
        }.store(in: &self.subs)
    }
    
    func show(_ album: Album) {
        select(item: subviews.map { $0 as! Item }.first { $0.album == album }!)
    }
    
    @objc private func select(item: Item) {
        guard !item.selected else { return }
        centerX = item.centerXAnchor.constraint(equalTo: centerXAnchor)
        subviews.map { $0 as! Item }.forEach {
            $0.selected = $0 == item
        }
        UIView.animate(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
        detail.show(item.album)
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
        base.backgroundColor = .black
        base.layer.cornerRadius = 12
        base.layer.shadowColor = UIColor.secondaryLabel.cgColor
        base.layer.shadowRadius = 5
        base.layer.shadowOffset = .zero
        addSubview(base)
        self.base = base
        
        let image = UIImageView(image: UIImage(named: album.cover)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 12
        addSubview(image)
        
        let shade = UIImageView(image: UIImage(named: "shade")!)
        shade.translatesAutoresizingMaskIntoConstraints = false
        shade.contentMode = .scaleAspectFill
        shade.clipsToBounds = true
        shade.layer.cornerRadius = 12
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
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        width = base.widthAnchor.constraint(equalToConstant: 120)
        width.isActive = true
        height = base.heightAnchor.constraint(equalToConstant: 156)
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
