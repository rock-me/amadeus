import UIKit

final class Close: Control {
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        
        let image = UIImageView(image: UIImage(systemName: "xmark")!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .secondaryLabel
        addSubview(image)
        
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func hoverOn() {
        alpha = 0.3
    }
    
    override func hoverOff() {
        alpha = 1
    }
}
