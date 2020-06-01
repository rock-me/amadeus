import AppKit

final class View: NSView {
    private weak var bar: Bar!
    private weak var side: Side!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        let bar = Bar()
        addSubview(bar)
        self.bar = bar
        
        let side = Side(view: self)
        addSubview(side)
        self.side = side
        
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
    
    func show(_ view: NSView) {
        subviews.filter { !($0 is Bar) && !($0 is Side) }.forEach {
            $0.removeFromSuperview()
        }
        addSubview(view)
        
        view.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: side.rightAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}