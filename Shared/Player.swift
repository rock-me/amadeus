import Foundation
import Combine
import AVFoundation

final class Player: Publisher {
    typealias Output = State
    typealias Failure = Never
    fileprivate var subscriptions = [Sub]()
    private var subs = Set<AnyCancellable>()
    private let player = AVPlayer()
    
    private var state = State.none {
        didSet {
            subscriptions.forEach {
                _ = $0.subscriber.receive(state)
            }
        }
    }
    
    init() {
        player.addPeriodicTimeObserver(forInterval: .init(value: 5, timescale: 10), queue: .main) {
            self.state.elapsed = CMTimeGetSeconds($0)
        }
        
        player.publisher(for: \.timeControlStatus).sink {
            self.state.playing = $0 == .playing
        }.store(in: &subs)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { _ in
            switch session.preferences.trackEnds {
            case .loop: self.play()
            case .next: self.next()
            case .stop: break
            }
        }.store(in: &subs)
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subscriptions.append(.init(.init(subscriber), publisher: self))
        subscriber.receive(subscription: subscriptions.last!)
    }
    
    func track(_ track: Track) {
        player.replaceCurrentItem(with: .init(asset: AVURLAsset(url: Bundle.main.url(forResource: "Test", withExtension: "mp3")!)))
        state = .init(track)
    }
    
    func play() {
        #if os(iOS)
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        #endif
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    private func next() {
        Album.allCases.firstIndex { $0.tracks.contains(persistance.ui.track) }.map { album in
            let index = Album.allCases[album].tracks.firstIndex(of: persistance.ui.track)!
            if Album.allCases[album].tracks.count > index + 1 {
                track(Album.allCases[album].tracks[index + 1])
                play()
            } else {
                
            }
        }
    }
}

private final class Sub: Subscription {
    private weak var publisher: Player!
    fileprivate var subscriber: AnySubscriber<State, Never>!
    
    init(_ subscriber: AnySubscriber<State, Never>, publisher: Player) {
        self.subscriber = subscriber
        self.publisher = publisher
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
        publisher.subscriptions.removeAll { $0 === self }
    }
}
