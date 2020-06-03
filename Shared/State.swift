import Foundation

struct State {
    static let none = State(.none)
    
    var elapsed = TimeInterval()
    let track: Track
    
    init(_ track: Track) {
        self.track = track
    }
}
