import Foundation
import Combine
import AVFoundation

final class Player: Publisher {
    typealias Output = State
    typealias Failure = Never
    fileprivate var subscriptions = [Sub]()
    private var observations = Set<NSKeyValueObservation>()
    private let player = AVPlayer()
    
    var state = State.none {
        didSet {
            subscriptions.forEach {
                _ = $0.subscriber.receive(state)
            }
        }
    }
    
    init() {
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 5, timescale: 10), queue: .main) {
            self.state.elapsed = CMTimeGetSeconds($0)
        }
        observations.insert(player.observe(\.timeControlStatus, options: .new) {
            self.state.playing = $1.newValue == .playing
        })
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subscriptions.append(.init(.init(subscriber), publisher: self))
        subscriber.receive(subscription: subscriptions.last!)
    }
    
    func play() {
        #if os(iOS)
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        #endif
        player.replaceCurrentItem(with: .init(asset: AVURLAsset(url: Bundle.main.url(forResource: "Test", withExtension: "mp3")!)))
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}

private final class Sub: Subscription {
    private weak var publisher: Player!
    fileprivate var subscriber: AnySubscriber<State, Never>!
    
    init(_ subscriber: AnySubscriber<State, Never>, publisher: Player) {
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
        publisher.subscriptions.removeAll { $0 === self }
    }
}
