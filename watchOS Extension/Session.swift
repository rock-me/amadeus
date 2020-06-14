import Foundation
import WatchConnectivity
import Player

final class Session: ObservableObject {
    @Published var track = Track.satieGymnopedies
    @Published var purchases = Set<String>()
    @Published var playing = false
    
    func change(track: Track) -> Bool {
        guard WCSession.isSupported() && WCSession.default.isReachable && WCSession.default.isCompanionAppInstalled else {
            return false
        }
        self.track = track
        WCSession.default.sendMessage(["track": track], replyHandler: nil, errorHandler: nil)
        return true
    }
}
