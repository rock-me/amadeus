import AppKit

final class Bar: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let separator = Separator()
        addSubview(separator)
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
