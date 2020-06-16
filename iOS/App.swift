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
    
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) {
        state.playing.dropFirst().sink { _ in
            self.sendMessage()
        }.store(in: &subs)
        
        state.player.track.dropFirst().sink { _ in
            self.sendMessage()
        }.store(in: &subs)
        
        state.player.config.sink { _ in
            self.sendContext()
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
    
    private func sendMessage() {
        guard WCSession.isSupported() else { return }
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled && WCSession.default.isReachable else {
            sendContext()
            return
        }
        WCSession.default.sendMessage(basic, replyHandler: nil, errorHandler: nil)
    }
    
    private func sendContext() {
        guard WCSession.isSupported() else { return }
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else { return }
        try? WCSession.default.updateApplicationContext(full)
    }
    
    private var full: [String : Any] {
        basic.merging(["purchases": Array(state.player.config.value.purchases)]) {
            $1
        }
    }
    
    private var basic: [String : Any] {
        ["track": state.player.track.value.rawValue,
         "playing": state.playing.value]
    }
}
