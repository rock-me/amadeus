import Foundation
import CoreGraphics
import Balam
import Player
import Combine
import AVFoundation

final class Session {
    private(set) var playing = CurrentValueSubject<Bool, Never>(false)
    private(set) var time = CurrentValueSubject<TimeInterval, Never>(.init())
    let player = Player()
    private var subs = Set<AnyCancellable>()
    private let store = Balam("amadeus")
    private let audio = AVPlayer()
    
    init() {
        #if os(iOS)
            try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try! AVAudioSession.sharedInstance().setActive(true)
        #endif
        
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
    
    func load() {
        store.nodes(Track.self).sink {
            if let stored = $0.first {
                self.player.track.value = stored
            } else {
                self.store.add(self.player.track.value)
            }
            self.listenTrack()
        }.store(in: &subs)
        
        store.nodes(Config.self).sink {
            if let stored = $0.first {
                self.player.config.value = stored
            } else {
                self.store.add(self.player.config.value)
            }
            self.listenConfig()
        }.store(in: &subs)
    }
    
    @objc func play() {
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
            self.store.update($0)
        }.store(in: &subs)
    }
    
    private func listenTrack() {
        player.track.dropFirst().sink {
            self.store.replace(Track.self, with: $0)
        }.store(in: &subs)
    }
}
