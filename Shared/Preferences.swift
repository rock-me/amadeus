import CoreGraphics

struct Preferences {
    struct UI: Codable, Equatable {
        enum Section: UInt8, Codable {
            case
            music,
            stats,
            store,
            settings
        }
        
        var frame = CGRect(x: 0, y: 0, width: 500, height: 400)
        var section = Section.music
        var album = Album.mists
        var track = Track.satieGymnopedies
        
        func hash(into: inout Hasher) { }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            true
        }
    }
}
