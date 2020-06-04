import Foundation
import Combine
import AVFoundation

final class Player: Publisher {
    typealias Output = State
    typealias Failure = Never
    fileprivate var subscriptions = [Sub]()
    private var player: AVAudioPlayer?
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    var state = State.none {
        didSet {
            subscriptions.forEach {
                _ = $0.subscriber.receive(state)
            }
        }
    }
    
    init() {
        timer.activate()
        timer.setEventHandler {
            guard let player = self.player else { return }
            self.state.elapsed = player.currentTime
        }
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
        player = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Test", withExtension: "mp3")!, fileTypeHint: AVFileType.mp3.rawValue)
        player!.play()
        timer.schedule(deadline: .now(), repeating: 0.5)
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
