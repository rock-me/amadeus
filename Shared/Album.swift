import Foundation

struct Album {
    enum id: UInt8, Codable, CaseIterable {
        case
        mists
    }
    
    let id: id
    
    init(_ id: id) {
        self.id = id
    }
}
