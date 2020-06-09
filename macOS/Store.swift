import AppKit
import Player
import Combine
import StoreKit

final class Store: NSView {
    private weak var scroll: Scroll!
    private var subs = Set<AnyCancellable>()
    private let purchases = Purchases()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let restore = Button(.key("Restore.purchases"))
        restore.target = self
        restore.action = #selector(self.restore)
        addSubview(restore)
        
        let subtitle = Label(.key("Purchases.are"), .regular(12))
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitle.textColor = .secondaryLabelColor
        addSubview(subtitle)
        
        let separator = Separator()
        addSubview(separator)
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        restore.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        restore.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        
        subtitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        subtitle.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: restore.leftAnchor, constant: -20).isActive = true
        
        separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        separator.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        scroll.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        
        purchases.products.receive(on: DispatchQueue.main).sink { [weak self] in
            guard let self = self else { return }
            scroll.views.forEach { $0.removeFromSuperview() }
            
            var top = scroll.top
            $0.forEach {
                if top != scroll.top {
                    let separator = Separator()
                    scroll.add(separator)
                    
                    separator.leftAnchor.constraint(equalTo: scroll.left, constant: 80).isActive = true
                    separator.rightAnchor.constraint(equalTo: scroll.right, constant: -80).isActive = true
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
        
        let label = Label(string, .medium(14))
        label.textColor = .secondaryLabelColor
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scroll.add(label)
        
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        label.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -30).isActive = true
    }
    
    private func loading() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let label = Label(.key("Loading"), .bold(20))
        label.textColor = .tertiaryLabelColor
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
}

private final class Item: NSView {
    private(set) weak var purchase: Button?
    
    required init?(coder: NSCoder) { nil }
    init(product: SKProduct) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let album = Album.allCases.first { $0.purchase == product.productIdentifier }!
        
        let image = NSImageView(image: NSImage(named: album.cover)!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        addSubview(image)
        
        let title = Label(album.title, .bold(24))
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let subtitle = Label("", .regular(13))
        subtitle.attributedStringValue = { mutable in
            album.tracks.forEach { track in
                mutable.append(.init(string: "\n" + track.composer.name, attributes: [.font : NSFont.medium(13)]))
                mutable.append(.init(string: " - " + track.title, attributes: [.font : NSFont.regular(13)]))
            }
            return mutable
        } (NSMutableAttributedString())
        subtitle.textColor = .secondaryLabelColor
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(subtitle)
        
        if playback.player.config.value.purchases.contains(product.productIdentifier) {
            let purchased = NSImageView(image: NSImage(named: "purchased")!)
            purchased.translatesAutoresizingMaskIntoConstraints = false
            purchased.imageScaling = .scaleNone
            purchased.contentTintColor = .controlAccentColor
            addSubview(purchased)
            
            title.rightAnchor.constraint(lessThanOrEqualTo: purchased.leftAnchor, constant: -20).isActive = true
            
            subtitle.rightAnchor.constraint(lessThanOrEqualTo: purchased.leftAnchor, constant: -20).isActive = true
            
            purchased.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            purchased.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
            purchased.widthAnchor.constraint(equalToConstant: 30).isActive = true
            purchased.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currencyISOCode
            formatter.locale = product.priceLocale
            
            let price = Label(formatter.string(from: product.price) ?? "", .regular(12))
            price.textColor = .controlAccentColor
            addSubview(price)
            
            let purchase = ButtonPurchase(.key("Purchase"), product: product)
            addSubview(purchase)
            self.purchase = purchase
            
            title.rightAnchor.constraint(lessThanOrEqualTo: purchase.leftAnchor, constant: -20).isActive = true
            title.rightAnchor.constraint(lessThanOrEqualTo: price.leftAnchor, constant: -20).isActive = true
            
            subtitle.rightAnchor.constraint(lessThanOrEqualTo: purchase.leftAnchor, constant: -20).isActive = true
            subtitle.rightAnchor.constraint(lessThanOrEqualTo: price.leftAnchor, constant: -20).isActive = true
            
            price.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
            price.topAnchor.constraint(equalTo: image.topAnchor).isActive = true
            
            purchase.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 5).isActive = true
            purchase.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        }

        bottomAnchor.constraint(greaterThanOrEqualTo: subtitle.bottomAnchor, constant: 20).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: image.bottomAnchor, constant: 30).isActive = true
        let height = heightAnchor.constraint(equalToConstant: 1)
        height.priority = .defaultLow
        height.isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true
        image.heightAnchor.constraint(equalToConstant: 50).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        
        title.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
        title.topAnchor.constraint(equalTo: image.topAnchor, constant: 5).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        subtitle.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
    }
}

private class Button: Control {
    private weak var label: Label!
    
    required init?(coder: NSCoder) { nil }
    init(_ title: String) {
        super.init()
        wantsLayer = true
        layer!.cornerRadius = 6
        
        let label = Label(title, .bold(12))
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(label)
        self.label = label
        
        bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 7).isActive = true
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
    }
    
    override func updateLayer() {
        layer!.backgroundColor = NSColor.controlAccentColor.cgColor
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
