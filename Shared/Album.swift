import Foundation

enum Album: UInt8, Codable, CaseIterable {
    case
    mists,
    melancholy,
    tension,
    dawn
    
    var tracks: [Track] {
        switch self {
        case .mists: return [
            .satieGymnopedies]
        case .melancholy: return [
            .beethovenMoonlightSonata,
            .debussyClairDeLune]
        case .tension: return [
            .mozartSymphony40]
        case .dawn: return [
            .mozartEineKleineNachtmusik]
        }
    }
}
