import WatchKit
import WatchConnectivity
import Player

final class App: NSObject, WKExtensionDelegate, WCSessionDelegate {
    let state = Session()
    
    func applicationDidBecomeActive() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_: WCSession, didReceiveMessage: [String : Any]) {
        if let playing = didReceiveMessage["playing"] as? Bool {
            state.playing = playing
        }
        
        if let track = didReceiveMessage["playing"] as? Track {
            state.track = track
        }
        
        if let purchases = didReceiveMessage["purchases"] as? Set<String> {
            state.purchases = purchases
        }
    }
}
