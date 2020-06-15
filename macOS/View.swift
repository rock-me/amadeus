import AppKit
import Combine

final class View: NSView {
    private weak var bar: Bar!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        let bar = Bar()
        addSubview(bar)
        self.bar = bar
        
        bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func show(_ view: NSView) {
        subviews.filter { !($0 is Bar) }.forEach {
            $0.removeFromSuperview()
        }
        addSubview(view)
        
        view.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
