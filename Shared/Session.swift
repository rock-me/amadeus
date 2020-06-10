import Foundation
import CoreGraphics
import Balam
import Player
import Combine

final class Session {
    private(set) var ui = CurrentValueSubject<UI, Never>(.init())
    private var subs = Set<AnyCancellable>()
    private let storeUI = Balam("ui.amadeus")
    private let storePlayer = Balam("player.amadeus")
    
    var loadUI: Future<Bool, Never> {
        .init { promise in
            self.storeUI.nodes(UI.self).sink {
                guard let ui = $0.first else {
                    promise(.success(false))
                    return
                }
                self.ui.value = ui
                promise(.success(true))
            }.store(in: &self.subs)
        }
    }
    
    func add(ui frame: CGRect) {
        ui.value.frame = frame
        storeUI.add(ui.value)
    }
    
    func loadPlayer() {
        storePlayer.nodes(Track.self).sink {
            if let stored = $0.first {
                playback.player.track.value = stored
            } else {
                self.storePlayer.add(playback.player.track.value)
            }
            self.listenTrack()
        }.store(in: &subs)
        
        storePlayer.nodes(Config.self).sink {
            if let stored = $0.first {
                playback.player.config.value = stored
            } else {
                self.storePlayer.add(playback.player.config.value)
            }
            self.listenConfig()
        }.store(in: &subs)
    }
    
    func update(ui completion: (inout UI) -> Void) {
        completion(&ui.value)
        storeUI.update(ui.value)
    }
    
    private func listenConfig() {
        playback.player.config.dropFirst().sink {
            self.storePlayer.update($0)
        }.store(in: &subs)
    }
    
    private func listenTrack() {
        playback.player.track.dropFirst().sink {
            self.storePlayer.replace(Track.self, with: $0)
        }.store(in: &subs)
    }
}
