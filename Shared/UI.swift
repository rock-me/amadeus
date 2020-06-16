import CoreGraphics
import Player

struct UI: Codable, Equatable {
    var frame = CGRect(x: 0, y: 0, width: 500, height: 700)
    var album = Album.mists
    
    func hash(into: inout Hasher) { }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}
