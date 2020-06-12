import UIKit
import Combine

final class Bar: UIView {
    weak var target: AnyObject!
    var action: Selector!
    private weak var current: Current!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        backgroundColor = .secondarySystemBackground
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 12
        
        let current = Current()
        addSubview(current)
        self.current = current
        
        topAnchor.constraint(equalTo: current.topAnchor).isActive = true
        
        current.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        current.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        current.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        _ = target.perform(action, with: self)
    }
}
