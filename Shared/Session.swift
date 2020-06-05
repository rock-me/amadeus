import Foundation
import Balam
import Combine

final class Session {
    private(set) var preferences = CurrentValueSubject<Preferences, Never>(.init())
    private(set) var ui = CurrentValueSubject<UI, Never>(.init())
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
                self.ui.value = ui
                promise(.success(true))
            }.store(in: &self.subs)
        }
    }
    
    func add(ui frame: CGRect) {
        ui.value.frame = frame
        storeUI.add(ui.value)
    }
    
    func loadPreferences() {
        storePreferences.nodes(Preferences.self).sink {
            if let stored = $0.first {
                self.preferences.value = stored
            } else {
                self.preferences.value = .init()
                self.storePreferences.add(self.preferences.value)
            }
        }.store(in: &self.subs)
    }
    
    func update(ui completion: (inout UI) -> Void) {
        completion(&ui.value)
        storeUI.update(ui.value)
    }
    
    func update(preferences completion: (inout Preferences) -> Void) {
        completion(&preferences.value)
        storePreferences.update(preferences.value)
    }
}
