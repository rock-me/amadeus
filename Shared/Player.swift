import Foundation
import Combine
import AVFoundation

public final class Player {
    public var config = CurrentValueSubject<Config, Never>(.init())
    public private(set) var track = CurrentValueSubject<Track, Never>(.satieGymnopedies)
    public private(set) var playing = CurrentValueSubject<Bool, Never>(false)
    public private(set) var time = CurrentValueSubject<TimeInterval, Never>(.init())
    private var subs = Set<AnyCancellable>()
    private let player = AVPlayer()
    
    init() {
        player.addPeriodicTimeObserver(forInterval: .init(value: 5, timescale: 10), queue: .main) {
            self.time.value = CMTimeGetSeconds($0)
        }
        
        player.publisher(for: \.timeControlStatus).sink {
            self.playing.value = $0 == .playing
        }.store(in: &subs)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { _ in
            switch self.config.value.trackEnds {
            case .loop: self.play()
            case .next: self.next()
            case .stop: break
            }
        }.store(in: &subs)
    }
    
    func track(_ track: Track) {
        player.replaceCurrentItem(with: .init(asset: AVURLAsset(url: Bundle.main.url(forResource: "Test", withExtension: "mp3")!)))
        track = .init(track)
    }
    
    func play() {
        #if os(iOS)
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try! AVAudioSession.sharedInstance().setActive(true)
        #endif
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    private func next() {
//        Album.allCases.firstIndex { $0.tracks.contains(session.ui.value.track) }.map { album in
//            let index = Album.allCases[album].tracks.firstIndex(of: session.ui.value.track)!
//            if Album.allCases[album].tracks.count > index + 1 {
//                track(Album.allCases[album].tracks[index + 1])
//                play()
//            } else {
//                switch session.preferences.value.albumEnds {
//                case .loop:
//                    track(Album.allCases[album].tracks.first!)
//                    play()
//                case .next:
//                    break
//                case .stop: break
//                }
//            }
//        }
    }
}
