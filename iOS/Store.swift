import UIKit
import Player
import Combine
import StoreKit

final class Store: UIViewController {
    private weak var scroll: Scroll!
    private var subs = Set<AnyCancellable>()
    private let purchases = Purchases()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let close = Close()
        close.target = self
        close.action = #selector(done)
        view.addSubview(close)
        
        let restore = Button(.key("Restore.purchases"))
        restore.target = self
        restore.action = #selector(self.restore)
        view.addSubview(restore)
        
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = .key("Purchases.are")
        subtitle.font = .regular(-4)
        subtitle.numberOfLines = 0
        subtitle.textColor = .secondaryLabel
        subtitle.textAlignment = .center
        view.addSubview(subtitle)
        
        let separator = Separator()
        view.addSubview(separator)
        
        let scroll = Scroll()
        scroll.alwaysBounceVertical = true
        scroll.alwaysBounceHorizontal = false
        scroll.showsVerticalScrollIndicator = true
        view.addSubview(scroll)
        self.scroll = scroll
        
        restore.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        restore.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        close.centerYAnchor.constraint(equalTo: restore.centerYAnchor).isActive = true
        close.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: close.bottomAnchor, constant: 10).isActive = true
        subtitle.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        subtitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        separator.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        scroll.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -1).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        
        purchases.products.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] in
            guard let self = self else { return }
            scroll.views.forEach { $0.removeFromSuperview() }
            
            var top = scroll.top
            $0.forEach {
                if top != scroll.top {
                    let separator = Separator()
                    scroll.add(separator)
                    
                    separator.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
                    separator.rightAnchor.constraint(equalTo: scroll.right, constant: -30).isActive = true
                    separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    separator.topAnchor.constraint(equalTo: top).isActive = true
                    top = separator.bottomAnchor
                }
                
                let item = Item(product: $0)
                item.purchase?.target = self
                item.purchase?.action = #selector(self.purchase)
                scroll.add(item)
                
                item.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                item.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                item.topAnchor.constraint(equalTo: top).isActive = true
                top = item.bottomAnchor
            }
            
            scroll.bottom.constraint(greaterThanOrEqualTo: top, constant: 10).isActive = true
        }.store(in: &subs)
        
        purchases.error.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.error($0)
        }.store(in: &subs)
        
        loading()
        purchases.load()
    }
    
    func error(_ string: String) {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = string
        label.font = .medium()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        scroll.add(label)
        
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        label.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -30).isActive = true
    }
    
    private func loading() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .key("Loading")
        label.font = .bold(4)
        label.textColor = .tertiaryLabel
        scroll.add(label)
        
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        label.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
    }
    
    @objc private func purchase(_ button: ButtonPurchase) {
        loading()
        purchases.purchase(button.product)
    }
    
    @objc private func restore() {
        loading()
        purchases.restore()
    }
    
    @objc private func done() {
        dismiss(animated: true)
    }
}

private final class Item: UIView {
    private(set) weak var purchase: Button?
    
    required init?(coder: NSCoder) { nil }
    init(product: SKProduct) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let album = Album.allCases.first { $0.purchase == product.productIdentifier }!
        
        let image = UIImageView(image: UIImage(named: album.cover)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        addSubview(image)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = .key(album.title)
        title.font = .bold(4)
        title.numberOfLines = 0
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = .key(album.subtitle)
        subtitle.font = .medium()
        subtitle.numberOfLines = 0
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitle.textColor = .secondaryLabel
        addSubview(subtitle)
        
        let tracks = UILabel()
        tracks.translatesAutoresizingMaskIntoConstraints = false
        tracks.font = .regular()
        tracks.attributedText = { mutable in
            album.tracks.forEach { track in
                mutable.append(.init(string: "\n" + .key(track.title), attributes: [.font : UIFont.medium(-2), .foregroundColor: UIColor.secondaryLabel]))
                mutable.append(.init(string: "\n" + .key(track.composer.name), attributes: [.font : UIFont.regular(-4), .foregroundColor: UIColor.tertiaryLabel]))
            }
            return mutable
        } (NSMutableAttributedString())
        tracks.numberOfLines = 0
        tracks.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(tracks)
        
        if session.player.config.value.purchases.contains(product.productIdentifier) {
            let purchased = UIImageView(image: UIImage(named: "purchased")!)
            purchased.translatesAutoresizingMaskIntoConstraints = false
            purchased.tintColor = .systemBlue
            addSubview(purchased)
            
            bottomAnchor.constraint(greaterThanOrEqualTo: purchased.bottomAnchor, constant: 50).isActive = true
            
            purchased.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
            purchased.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
            purchased.widthAnchor.constraint(equalToConstant: 30).isActive = true
            purchased.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currencyISOCode
            formatter.locale = product.priceLocale
            
            let price = UILabel()
            price.translatesAutoresizingMaskIntoConstraints = false
            price.font = .medium(-2)
            price.text = formatter.string(from: product.price)!
            addSubview(price)
            
            let purchase = ButtonPurchase(.key("Purchase"), product: product)
            addSubview(purchase)
            self.purchase = purchase
            
            bottomAnchor.constraint(greaterThanOrEqualTo: purchase.bottomAnchor, constant: 50).isActive = true
            
            price.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
            price.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 35).isActive = true
            
            purchase.topAnchor.constraint(equalTo: price.bottomAnchor).isActive = true
            purchase.centerXAnchor.constraint(equalTo: price.centerXAnchor).isActive = true
        }

        bottomAnchor.constraint(greaterThanOrEqualTo: tracks.bottomAnchor, constant: 50).isActive = true
        let height = heightAnchor.constraint(equalToConstant: 1)
        height.priority = .defaultLow
        height.isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 120).isActive = true
        image.heightAnchor.constraint(equalToConstant: 150).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        
        title.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
        title.topAnchor.constraint(equalTo: image.topAnchor, constant: 2).isActive = true
        
        subtitle.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 20).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        
        tracks.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 6).isActive = true
        tracks.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
        tracks.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
    }
}

private class Close: Control {
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        
        let image = UIImageView(image: UIImage(systemName: "xmark")!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .secondaryLabel
        addSubview(image)
        
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func hoverOn() {
        alpha = 0.3
    }
    
    override func hoverOff() {
        alpha = 1
    }
}

private class Button: Control {
    required init?(coder: NSCoder) { nil }
    init(_ title: String) {
        super.init()
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.backgroundColor = .systemBlue
        base.layer.cornerRadius = 14
        addSubview(base)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .regular(-2)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(label)
        
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        base.heightAnchor.constraint(equalToConstant: 28).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func hoverOn() {
        alpha = 0.3
    }
    
    override func hoverOff() {
        alpha = 1
    }
}

private final class ButtonPurchase: Button {
    let product: SKProduct
    
    required init?(coder: NSCoder) { nil }
    init(_ title: String, product: SKProduct) {
        self.product = product
        super.init(title)
    }
}
