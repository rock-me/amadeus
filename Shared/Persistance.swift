import Foundation
import Balam
import Combine

final class Persistance {
    private(set) var ui = UI()
    private var subs = Set<AnyCancellable>()
    private let storeUI = Balam("ui.amadeus")
    private let storePreferences = Balam("preferences.amadeus")
    
    var loadUI: Future<Bool, Never> {
        .init { promise in
            self.storeUI.nodes(UI.self).sink {
                guard let ui = $0.first else {
                    promise(.success(false))
                    return
                }
                self.ui = ui
                promise(.success(true))
            }.store(in: &self.subs)
        }
    }
    
    var loadPreferences: Future<Preferences, Never> {
        .init { promise in
            self.storePreferences.nodes(Preferences.self).sink {
                let preferences: Preferences
                if let stored = $0.first {
                    preferences = stored
                } else {
                    preferences = .init()
                    self.storePreferences.add(preferences)
                }
                promise(.success(preferences))
            }.store(in: &self.subs)
        }
    }
    
    func add(_ ui: UI) {
        storeUI.add(ui)
    }
    
    func update(_ completion: (inout UI) -> Void) {
        completion(&ui)
        storeUI.update(ui)
    }
    
    func save(_ preferences: Preferences) {
        storePreferences.update(preferences)
    }
}
