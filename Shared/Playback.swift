import Foundation
import Combine

final class Playback: Publisher {
    struct State {
        static let none = State(.none)
        
        var elapsed = TimeInterval()
        let track: Track
        
        init(_ track: Track) {
            self.track = track
        }
    }
    
    typealias Output = State
    typealias Failure = Never
    fileprivate var subscriptions = [Sub]()
    
    var state = State.none {
        didSet {
            subscriptions.forEach {
                _ = $0.subscriber.receive(state)
            }
        }
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subscriptions.append(.init(.init(subscriber), publisher: self))
        subscriber.receive(subscription: subscriptions.last!)
    }
}

private final class Sub: Subscription {
    private weak var publisher: Playback!
    fileprivate var subscriber: AnySubscriber<Playback.State, Never>!
    
    init(_ subscriber: AnySubscriber<Playback.State, Never>, publisher: Playback) {
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
        publisher.subscriptions.removeAll { $0 === self }
    }
}
