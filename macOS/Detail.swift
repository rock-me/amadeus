import AppKit

final class Detail: NSView {
    private weak var title: Label!
    private weak var subtitle: Label!
    private let formatter = DateComponentsFormatter()
    private let font = NSFont(descriptor: NSFont.regular(12).fontDescriptor.addingAttributes([
        .featureSettings: [[NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector,
                            .typeIdentifier: kNumberSpacingType]]]), size: 0)!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.allowedUnits = [.minute, .second]
        
        let title = Label("", .bold(20))
        title.textColor = .headerTextColor
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        self.title = title
        
        let subtitle = Label("", .regular(12))
        subtitle.textColor = .secondaryLabelColor
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(subtitle)
        self.subtitle = subtitle
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        subtitle.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
    }
    
    func show(_ album: Album) {
        title.stringValue = .key("album_\(album)")
        subtitle.stringValue = .key("album_\(album)_subtitle")
        subviews.filter { !($0 == title || $0 == subtitle) }.forEach {
            $0.removeFromSuperview()
        }
        
        var top = subtitle.bottomAnchor
        album.tracks.forEach {
            if top != subtitle.bottomAnchor {
                let separator = Separator()
                addSubview(separator)
                
                separator.topAnchor.constraint(equalTo: top).isActive = true
                separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
                separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                top = separator.bottomAnchor
            }
            
            let item = self.item($0)
            item.topAnchor.constraint(equalTo: top, constant: top == subtitle.bottomAnchor ? 30 : 0).isActive = true
            top = item.bottomAnchor
        }
        
        bottomAnchor.constraint(equalTo: top).isActive = true
    }
    
    private func item(_ track: Track) -> Item {
        let item = Item(track: track, duration: formatter.string(from: track.duration)!, font: font)
        addSubview(item)
        
        item.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        item.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        return item
    }
}

private final class Item: NSView {
    required init?(coder: NSCoder) { nil }
    init(track: Track, duration: String, font: NSFont) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let title = Label(.key("track_\(track)_title"), .bold(14))
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let composer = Label(.key("track_\(track)_composer"), .regular(14))
        composer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        composer.textColor = .secondaryLabelColor
        addSubview(composer)
        
        let duration = Label(duration, font)
        duration.textColor = .secondaryLabelColor
        addSubview(duration)
        
        bottomAnchor.constraint(equalTo: composer.bottomAnchor, constant: 15).isActive = true
        
        title.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: duration.leftAnchor, constant: -10).isActive = true
    
        composer.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        composer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        composer.rightAnchor.constraint(lessThanOrEqualTo: duration.leftAnchor, constant: -10).isActive = true
        
        duration.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        duration.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
