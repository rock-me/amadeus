import AppKit
import StoreKit

final class Store: NSView {
    private weak var scroll: Scroll!
    private let purchases = Purchases()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        
        let restore = Button(.key("Restore.purchases"))
        restore.target = self
        restore.action = #selector(self.restore)
        addSubview(restore)
        
        let done = Button(.key("Done"))
        done.small()
        done.target = self
        done.action = #selector(self.done)
        addSubview(done)
        
        let subtitle = Label(.key("Shared"), .regular(12))
        subtitle.textColor = .init(white: 0.5, alpha: 1)
        addSubview(subtitle)
        
        let separator = Separator()
        addSubview(separator)
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        title.centerYAnchor.constraint(equalTo: done.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 90).isActive = true
        
        separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        separator.topAnchor.constraint(equalTo: topAnchor, constant: 110).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        done.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        done.topAnchor.constraint(equalTo: topAnchor, constant: 9).isActive = true
        
        restore.rightAnchor.constraint(equalTo: done.leftAnchor, constant: -30).isActive = true
        restore.centerYAnchor.constraint(equalTo: done.centerYAnchor).isActive = true
        
        subtitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        subtitle.topAnchor.constraint(equalTo: topAnchor, constant: 70).isActive = true
        
        scroll.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        
        loading()
        store.delegate = self
        store.load()
    }
    
    func error(_ string: String) {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let label = Label(string, .medium(14))
        label.textColor = .init(white: 0.6, alpha: 1)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scroll.add(label)
        
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        label.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -30).isActive = true
    }
    
    func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let headerPremium = Label(.key("Premium"), .bold(14))
        headerPremium.textColor = .init(white: 0.7, alpha: 1)
        scroll.add(headerPremium)
        
        headerPremium.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        headerPremium.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        var top = headerPremium.bottomAnchor
        
        store.products.filter { $0.productIdentifier.contains(".premium.") }.forEach {
            top = item(PremiumItem(product: $0), top: top)
        }
        
        let headerSkins = Label(.key("Skins"), .bold(14))
        headerSkins.textColor = .init(white: 0.7, alpha: 1)
        scroll.add(headerSkins)
        
        headerSkins.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        headerSkins.topAnchor.constraint(equalTo: top, constant: 50).isActive = true
        top = headerSkins.bottomAnchor
        
        store.products.filter { $0.productIdentifier.contains(".skin.") }.sorted { $0.productIdentifier < $1.productIdentifier }.forEach {
            if top != headerSkins.bottomAnchor {
                let separator = Separator()
                scroll.add(separator)
                
                separator.leftAnchor.constraint(equalTo: scroll.left, constant: 80).isActive = true
                separator.rightAnchor.constraint(equalTo: scroll.right, constant: -80).isActive = true
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                separator.topAnchor.constraint(equalTo: top).isActive = true
                top = separator.bottomAnchor
            }
            
            top = item(SkinItem(product: $0), top: top)
        }
        
        scroll.bottom.constraint(greaterThanOrEqualTo: top, constant: 10).isActive = true
    }
    
    private func loading() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let label = Label(.key("Loading"), .bold(20))
        label.textColor = .init(white: 0.75, alpha: 1)
        scroll.add(label)
        
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        label.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
    }
    
    private func item(_ item: Item, top: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor {
        item.purchase?.target = self
        item.purchase?.action = #selector(purchase)
        scroll.add(item)
        
        item.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        item.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        item.topAnchor.constraint(equalTo: top).isActive = true
        return item.bottomAnchor
    }
    
    @objc private func purchase(_ button: Button) {
        loading()
        store.purchase((button.superview as! Item).product)
    }
    
    @objc private func restore() {
        loading()
        store.restore()
    }
    
    @objc private func done() {
        window!.show(Options())
    }
}

private class Item: NSView {
    private(set) weak var purchase: Button?
    private(set) weak var image: NSImageView!
    private(set) weak var subtitle: Label!
    let product: SKProduct
    
    required init?(coder: NSCoder) { nil }
    init(product: SKProduct) {
        self.product = product
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyUpOrDown
        addSubview(image)
        self.image = image
        
        let title = Label(.key(product.productIdentifier), .bold(16))
        title.textColor = .black
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let subtitle = Label("", .regular(13))
        subtitle.textColor = .init(white: 0.5, alpha: 1)
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(subtitle)
        self.subtitle = subtitle
        
        if game.profile.purchases.contains(product.productIdentifier) {
            let purchased = NSImageView(image: NSImage(named: "purchased")!)
            purchased.translatesAutoresizingMaskIntoConstraints = false
            purchased.imageScaling = .scaleNone
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
            price.textColor = .indigoDark
            addSubview(price)
            
            let purchase = Button(.key("Purchase"))
            purchase.clean()
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

private final class PremiumItem: Item {
    required init?(coder: NSCoder) { nil }
    override init(product: SKProduct) {
        super.init(product: product)
        image.image = NSImage(named: "game_" + product.productIdentifier.components(separatedBy: ".").last!)!
        
        if game.profile.purchases.contains(product.productIdentifier) {
            subtitle.stringValue = .key("Purchase.premium.got")
        } else {
            subtitle.stringValue = .key("Purchase.premium." + product.productIdentifier.components(separatedBy: ".").last!)
        }
    }
}

private final class SkinItem: Item {
    required init?(coder: NSCoder) { nil }
    override init(product: SKProduct) {
        super.init(product: product)
        image.image = NSImage(named: "skin_" + product.productIdentifier.components(separatedBy: ".").last!)!
        
        if game.profile.purchases.contains(product.productIdentifier) {
            subtitle.stringValue = .key("Purchase.skin.got")
        } else {
            subtitle.stringValue = .key("Purchase.skin.subtitle")
        }
    }*/
}

final class Button: Control {
    private weak var label: Label!
    
    required init?(coder: NSCoder) { nil }
    init(_ title: String) {
        super.init()
        wantsLayer = true
        layer!.cornerRadius = 6
        
        let label = Label(title, .bold(12))
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.textColor = .controlAccentColor
        addSubview(label)
        self.label = label
        
        bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 7).isActive = true
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
    }
    
    override func updateLayer() {
        layer!.backgroundColor = NSColor.controlLightHighlightColor.cgColor
    }
}
