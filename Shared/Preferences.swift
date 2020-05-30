import CoreGraphics

struct Preferences {
    struct UI: Codable, Equatable {
        var frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        func hash(into: inout Hasher) { }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            true
        }
    }
}
