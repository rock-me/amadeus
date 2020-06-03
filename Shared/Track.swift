import Foundation

enum Track: UInt32, Codable {
    case
    none,
    satieGymnopedies,
    beethovenMoonlightSonata,
    debussyClairDeLune,
    mozartSymphony40,
    mozartEineKleineNachtmusik
    
    var duration: TimeInterval {
        switch self {
        default: return 120
        }
    }
}
