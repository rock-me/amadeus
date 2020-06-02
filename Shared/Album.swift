import Foundation

enum Album: UInt8, Codable, CaseIterable {
    case
    mists,
    melancholy,
    tension
    
    var tracks: [Track] {
        switch self {
        case .mists: return [.satieGymnopedies]
        case .melancholy: return [.beethovenPianoSonata14]
        case .tension: return [.mozartSymphony40]
        }
    }
}
