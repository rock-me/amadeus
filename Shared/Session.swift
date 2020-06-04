import Foundation
import Combine

final class Session: Publisher {
    typealias Output = Preferences
    typealias Failure = Never
    fileprivate var subscriptions = [Sub]()
    private var preferences = Preferences()
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subscriptions.append(.init(.init(subscriber), publisher: self))
        subscriber.receive(subscription: subscriptions.last!)
        _ = subscriber.receive(preferences)
    }
    
    func loaded(_ preferences: Preferences) {
        self.preferences = preferences
        notify()
    }
    
    private func notify() {
        subscriptions.forEach {
            _ = $0.subscriber.receive(preferences)
        }
    }
    
    private func save() {
        persistance.save(preferences)
    }
}

private final class Sub: Subscription {
    private weak var publisher: Session!
    fileprivate var subscriber: AnySubscriber<Preferences, Never>!
    
    init(_ subscriber: AnySubscriber<Preferences, Never>, publisher: Session) {
        self.subscriber = subscriber
        self.publisher = publisher
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
        publisher.subscriptions.removeAll { $0 === self }
    }
}
