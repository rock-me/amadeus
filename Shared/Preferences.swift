import Foundation

struct Preferences: Codable, Equatable {
    var trackEnds = Heuristic.next
    var albumEnds = Heuristic.stop
    var purchases = Set<String>()
    var rated = false
    let created = Date()
    
    func hash(into: inout Hasher) { }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}
