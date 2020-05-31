import Foundation

extension String {
    static func key(_ value: String) -> String {
        NSLocalizedString(value, comment: "")
    }
}
