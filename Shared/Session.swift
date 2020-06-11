import Foundation
import CoreGraphics
import Balam
import Player
import Combine
import AVFoundation

final class Session {
    private(set) var ui = CurrentValueSubject<UI, Never>(.init())
    private(set) var playing = CurrentValueSubject<Bool, Never>(false)
    private(set) var time = CurrentValueSubject<TimeInterval, Never>(.init())
    let player = Player()
    private var subs = Set<AnyCancellable>()
    private let storeUI = Balam("ui.amadeus")
    private let storePlayer = Balam("player.amadeus")
    private let audio = AVPlayer()
    
    init() {
        audio.addPeriodicTimeObserver(forInterval: .init(value: 5, timescale: 10), queue: .main) {
            self.time.value = CMTimeGetSeconds($0)
        }
        
        audio.publisher(for: \.timeControlStatus).sink {
            self.playing.value = $0 == .playing
        }.store(in: &subs)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { _ in
            self.player.trackEnds()
        }.store(in: &subs)
        
        player.track.sink {
            self.audio.replaceCurrentItem(with: .init(asset: AVURLAsset(url: Bundle.main.url(forResource: $0.file, withExtension: "mp3")!)))
        }.store(in: &subs)
        
        player.start.sink {
            self.audio.play()
        }.store(in: &subs)
    }
    
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
                self.player.track.value = stored
            } else {
                self.storePlayer.add(self.player.track.value)
            }
            self.listenTrack()
        }.store(in: &subs)
        
        storePlayer.nodes(Config.self).sink {
            if let stored = $0.first {
                self.player.config.value = stored
            } else {
                self.storePlayer.add(self.player.config.value)
            }
            self.listenConfig()
        }.store(in: &subs)
    }
    
    func update(ui completion: (inout UI) -> Void) {
        completion(&ui.value)
        storeUI.update(ui.value)
    }
    
    @objc func play() {
        #if os(iOS)
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try! AVAudioSession.sharedInstance().setActive(true)
        #endif
        audio.play()
    }
    
    @objc func pause() {
        audio.pause()
    }
    
    @objc func next() {
        player.next()
    }
    
    @objc func previous() {
        player.previous()
    }
    
    private func listenConfig() {
        player.config.dropFirst().sink {
            self.storePlayer.update($0)
        }.store(in: &subs)
    }
    
    private func listenTrack() {
        player.track.dropFirst().sink {
            self.storePlayer.replace(Track.self, with: $0)
        }.store(in: &subs)
    }
}
