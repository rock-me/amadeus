import Foundation

enum Track {
    case
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
