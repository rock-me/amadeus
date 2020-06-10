#if os(macOS)
import AppKit

extension NSFont {
    class func light(_ size: CGFloat) -> NSFont {
        .systemFont(ofSize: size, weight: .light)
    }
    
    class func regular(_ size: CGFloat) -> NSFont {
        .systemFont(ofSize: size, weight: .regular)
    }
    
    class func medium(_ size: CGFloat) -> NSFont {
        .systemFont(ofSize: size, weight: .medium)
    }
    
    class func bold(_ size: CGFloat) -> NSFont {
        .systemFont(ofSize: size, weight: .bold)
    }
    
    class func monospaced(_ with: NSFont) -> Self {
        Self(descriptor: with.fontDescriptor.addingAttributes([.featureSettings:
            [[NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector, .typeIdentifier: kNumberSpacingType]]]), size: 0)!
    }
}
#endif
#if os(iOS)
import UIKit

extension UIFont {
    class func light(_ adding: CGFloat = 0) -> UIFont {
        .systemFont(ofSize: size + adding, weight: .light)
    }
    
    class func regular(_ adding: CGFloat = 0) -> UIFont {
        .systemFont(ofSize: size + adding, weight: .regular)
    }
    
    class func medium(_ adding: CGFloat = 0) -> UIFont {
        .systemFont(ofSize: size + adding, weight: .medium)
    }
    
    class func bold(_ adding: CGFloat = 0) -> UIFont {
        .systemFont(ofSize: size + adding, weight: .bold)
    }
    
    private static var size: CGFloat {
        Self.preferredFont(forTextStyle: .body).pointSize
    }
}
#endif
