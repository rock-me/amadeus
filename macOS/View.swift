import AppKit

final class View: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        let bar = Bar()
        addSubview(bar)
        
        let side = Side()
        addSubview(side)
        
        bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        side.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        side.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        side.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        let sideWidth = side.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15)
        sideWidth.priority = .defaultLow
        sideWidth.isActive = true
    }
}
