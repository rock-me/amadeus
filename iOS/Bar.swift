import UIKit
import Combine

final class Bar: Control {
    private weak var current: Current!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        backgroundColor = .secondarySystemBackground
        
        let current = Current()
        addSubview(current)
        self.current = current
        
        topAnchor.constraint(equalTo: current.topAnchor).isActive = true
        
        current.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        current.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        current.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        hoverOn()
    }
    
    override func hoverOn() {
        current.selector.backgroundColor = .systemBlue
    }
    
    override func hoverOff() {
        current.selector.backgroundColor = .tertiarySystemBackground
    }
}
