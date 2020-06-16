import UIKit
import WatchConnectivity
import Player
import Combine

let state = Session()

@UIApplicationMain final class App: NSObject, UIApplicationDelegate, WCSessionDelegate {
    private var subs = Set<AnyCancellable>()
    
    func startSession() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func sendContext() {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else { return }
        try? WCSession.default.updateApplicationContext(full)
    }
    
    func sendMessage() {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled && WCSession.default.isReachable else {
            sendContext()
            return
        }
        WCSession.default.sendMessage(basic, replyHandler: nil, errorHandler: nil)
    }
    
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) {
        sendContext()
        
        state.playing.dropFirst().sink { _ in
            self.sendMessage()
        }.store(in: &subs)
        
        state.player.track.dropFirst().sink { _ in
            self.sendMessage()
        }.store(in: &subs)
    }
    
    func session(_: WCSession, didReceiveMessage: [String : Any]) {
        DispatchQueue.main.async {
            if let raw = didReceiveMessage["track"] as? UInt8,
                let track = Track(rawValue: raw) {
                state.player.track.value = track
            }
            
            if let playing = didReceiveMessage["playing"] as? Bool {
                if playing {
                    state.play()
                } else {
                    state.pause()
                }
            }
        }
    }
    
    func sessionDidBecomeInactive(_: WCSession) {
        
    }
        
    func sessionDidDeactivate(_: WCSession) {
        
    }
    
    private var full: [String : Any] {
        basic.merging(["purchases": Array(state.player.config.value.purchases)]) {
            $1
        }
    }
    
    private var basic: [String : Any] {
        ["purchases": Array(state.player.config.value.purchases),
         "track": state.player.track.value.rawValue,
         "playing": state.playing.value]
    }
}
