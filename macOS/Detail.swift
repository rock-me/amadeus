import AppKit

final class Detail: NSView {
    private weak var title: Label!
    private weak var subtitle: Label!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
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
        
        bottomAnchor.constraint(equalTo: subtitle.bottomAnchor).isActive = true
        
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
    }
}
