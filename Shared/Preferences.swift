import CoreGraphics

struct Preferences {
    struct UI: Codable, Equatable {
        var frame = CGRect.zero
        
        func hash(into: inout Hasher) { }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            true
        }
    }
}
