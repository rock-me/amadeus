import WatchKit
import WatchConnectivity
import Player

final class App: NSObject, WKExtensionDelegate, WCSessionDelegate {
    let state = Session()
    
    func applicationDidBecomeActive() {
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_: WCSession, didReceiveApplicationContext: [String: Any]) {
        parse(didReceiveApplicationContext)
    }
    
    func session(_: WCSession, didReceiveMessage: [String : Any]) {
        parse(didReceiveMessage)
    }
    
    private func parse(_ message: [String : Any]) {
        DispatchQueue.main.async {
            if let playing = message["playing"] as? Bool {
                self.state.playing = playing
            }
            
            if let raw = message["track"] as? UInt8,
                let track = Track(rawValue: raw) {
                self.state.track = track
            }
            
            if let purchases = message["purchases"] as? [String] {
                self.state.purchases = .init(purchases)
            }
        }
    }
}
