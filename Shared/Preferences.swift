import CoreGraphics

struct Preferences {
    struct UI: Codable, Equatable {
        var frame: CGRect
        
        init(frame: CGRect) {
            self.frame = frame
        }
        
        func hash(into: inout Hasher) { }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            true
        }
    }
}
