import Foundation
import Combine
import Player
import AVFoundation

final class Playback {
    private(set) var playing = CurrentValueSubject<Bool, Never>(false)
    private(set) var time = CurrentValueSubject<TimeInterval, Never>(.init())
    let player = Player()
    private var subs = Set<AnyCancellable>()
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
    }
    
    func play() {
        #if os(iOS)
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try! AVAudioSession.sharedInstance().setActive(true)
        #endif
        audio.play()
    }
    
    func pause() {
        audio.pause()
    }
    
    func next() {
        player.next()
    }
    
    func previous() {
        player.previous()
    }
}
