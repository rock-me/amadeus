import WatchKit
import WatchConnectivity
import Player

final class App: NSObject, WKExtensionDelegate, WCSessionDelegate {
    let session = Session()
    
    func applicationDidBecomeActive() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_: WCSession, didReceiveApplicationContext: [String: Any]) {
//        if let items = try? JSONDecoder().decode(Track.self, from: didReceiveApplicationContext["track"] as? Data ?? .init()) {
//            pointers = items
//            update()
//        }
    }
}
