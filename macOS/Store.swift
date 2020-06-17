import AppKit
import Player
import Combine
import StoreKit

final class Store: NSWindow {
    private weak var scroll: Scroll!
    private var subs = Set<AnyCancellable>()
    private let purchases = Purchases()
    
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 600, height: 600), styleMask:
            [.borderless, .miniaturizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        center()
        
        let restore = Button(.key("Restore.purchases"))
        restore.target = self
        restore.action = #selector(self.restore)
        contentView!.addSubview(restore)
        
        let subtitle = Label(.key("Purchases.are"), .regular())
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitle.textColor = .secondaryLabelColor
        contentView!.addSubview(subtitle)
        
        let separator = Separator()
        contentView!.addSubview(separator)
        
        let scroll = Scroll()
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        contentView!.addSubview(scroll)
        self.scroll = scroll
        
        restore.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
        restore.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20).isActive = true
        
        subtitle.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 20).isActive = true
        subtitle.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: restore.leftAnchor, constant: -10).isActive = true
        
        separator.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        scroll.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
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
                    
                    separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    separator.widthAnchor.constraint(equalToConstant: 300).isActive = true
                    separator.centerXAnchor.constraint(equalTo: self.contentView!.centerXAnchor).isActive = true
                    separator.topAnchor.constraint(equalTo: top).isActive = true
                    top = separator.bottomAnchor
                }
                
                let item = Item(product: $0)
                item.purchase?.target = self
                item.purchase?.action = #selector(self.purchase)
                scroll.add(item)
                
                item.centerXAnchor.constraint(equalTo: self.contentView!.centerXAnchor).isActive = true
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
        
        let label = Label(string, .medium(2))
        label.textColor = .secondaryLabelColor
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scroll.add(label)
        
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        label.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -30).isActive = true
    }
    
    private func loading() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let label = Label(.key("Loading"), .bold(6))
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
        image.imageScaling = .scaleProportionallyDown
        image.wantsLayer = true
        image.layer!.cornerRadius = 12
        addSubview(image)
        
        let title = Label(.key(album.title), .bold(6))
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let subtitle = Label(.key(album.subtitle), .medium(2))
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitle.textColor = .secondaryLabelColor
        addSubview(subtitle)
        
        let tracks = Label("", .regular())
        tracks.attributedStringValue = { mutable in
            album.tracks.forEach { track in
                mutable.append(.init(string: "\n" + .key(track.title), attributes: [.font : NSFont.medium(), .foregroundColor: NSColor.secondaryLabelColor]))
                mutable.append(.init(string: "\n" + .key(track.composer.name), attributes: [.font : NSFont.regular(-2), .foregroundColor: NSColor.tertiaryLabelColor]))
            }
            return mutable
        } (NSMutableAttributedString())
        tracks.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(tracks)
        
        if state.player.config.value.purchases.contains(product.productIdentifier) {
            let purchased = NSImageView(image: NSImage(named: "purchased")!)
            purchased.translatesAutoresizingMaskIntoConstraints = false
            purchased.imageScaling = .scaleNone
            purchased.contentTintColor = .controlAccentColor
            addSubview(purchased)
            
            bottomAnchor.constraint(greaterThanOrEqualTo: purchased.bottomAnchor, constant: 60).isActive = true
            
            purchased.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
            purchased.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
            purchased.widthAnchor.constraint(equalToConstant: 30).isActive = true
            purchased.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currencyISOCode
            formatter.locale = product.priceLocale
            
            let price = Label(formatter.string(from: product.price)!, .medium(-2))
            addSubview(price)
            
            let purchase = ButtonPurchase(.key("Purchase"), product: product)
            addSubview(purchase)
            self.purchase = purchase
            
            bottomAnchor.constraint(greaterThanOrEqualTo: purchase.bottomAnchor, constant: 60).isActive = true
            
            price.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
            price.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
            
            purchase.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 10).isActive = true
            purchase.centerXAnchor.constraint(equalTo: price.centerXAnchor).isActive = true
        }

        widthAnchor.constraint(equalToConstant: 400).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: tracks.bottomAnchor, constant: 60).isActive = true
        let height = heightAnchor.constraint(equalToConstant: 1)
        height.priority = .defaultLow
        height.isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 120).isActive = true
        image.heightAnchor.constraint(equalToConstant: 156).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 60).isActive = true
        
        title.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 30).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        title.topAnchor.constraint(equalTo: image.topAnchor, constant: 5).isActive = true
        
        subtitle.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 30).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        
        tracks.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 6).isActive = true
        tracks.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
        tracks.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
    }
}

private class Button: Control {
    required init?(coder: NSCoder) { nil }
    init(_ title: String) {
        super.init()
        wantsLayer = true
        layer!.cornerRadius = 14
        
        let label = Label(title, .medium())
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 28).isActive = true
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
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
