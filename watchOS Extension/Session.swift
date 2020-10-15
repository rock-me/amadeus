import Foundation
import WatchConnectivity
import Player

final class Session: ObservableObject {
    @Published var track = Track.satieGymnopedies
    @Published var purchases = Set<String>([Album.mists.purchase])
    @Published var playing = false
    
    func change(track: Track) -> Bool {
        guard WCSession.isSupported() && WCSession.default.isReachable && WCSession.default.isCompanionAppInstalled else {
            return false
        }
        self.track = track
        playing = true
        WCSession.default.sendMessage(["track": track.rawValue, "playing": true], replyHandler: nil, errorHandler: nil)
        return true
    }
    
    func pause() -> Bool {
        guard WCSession.isSupported() && WCSession.default.isReachable && WCSession.default.isCompanionAppInstalled else {
            return false
        }
        playing = false
        WCSession.default.sendMessage(["playing": false], replyHandler: nil, errorHandler: nil)
        return true
    }
}
