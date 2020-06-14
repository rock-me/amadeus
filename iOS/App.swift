import UIKit
import WatchConnectivity
import Player

let state = Session()

@UIApplicationMain final class App: NSObject, UIApplicationDelegate, WCSessionDelegate {
    func startSession() {
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func send(purchases: Bool = false, playing: Bool = false, track: Bool = false) {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled && WCSession.default.isReachable else { return }
        var message = [String : Any]()
        if purchases {
            message["purchases"] = state.player.config.value.purchases
        }
        if playing {
            message["playing"] = state.playing
        }
        if track {
            message["track"] = state.player.track.value
        }
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) { }
    
    func sessionDidBecomeInactive(_: WCSession) {
        send(purchases: true, playing: true, track: true)
    }
        
    func sessionDidDeactivate(_: WCSession) {
        
    }
    
    func session(_: WCSession, didReceiveMessage: [String : Any]) {
        if let playing = didReceiveMessage["playing"] as? Bool {
            state.playing.value = playing
        }
        
        if let track = didReceiveMessage["playing"] as? Track {
            state.player.track.value = track
        }
    }
}
