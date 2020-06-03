import Foundation
import Balam
import Combine

final class Persistance {
    private(set) var ui = UI()
    private var subs = Set<AnyCancellable>()
    private let storeUI = Balam("ui.amadeus")
    
    func load() -> Future<Bool, Never> {
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
    
    func add(ui: UI) {
        storeUI.add(ui)
    }
    
    func update(ui completion: (inout UI) -> Void) {
        completion(&ui)
        storeUI.update(ui)
    }
}
