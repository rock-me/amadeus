import UIKit

final class Bar: UIView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
