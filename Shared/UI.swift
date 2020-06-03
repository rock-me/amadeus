import CoreGraphics

struct UI: Codable, Equatable {
    enum Section: UInt8, Codable {
        case
        music,
        stats,
        store,
        settings
    }
    
    var frame = CGRect(x: 0, y: 0, width: 800, height: 700)
    var section = Section.music
    var album = Album.mists
    var track = Track.satieGymnopedies
    
    func hash(into: inout Hasher) { }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}