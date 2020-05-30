import Foundation
import Balam
import Combine

final class Persistance {
    var ui = Preferences.UI()
    private var subs = Set<AnyCancellable>()
    private let preferences = Balam("preferences.amadeus")
    
    var storedUI: Future<Preferences.UI?, Never> {
        .init { promise in
            self.preferences.nodes(Preferences.UI.self).sink {
                $0.first.map { self.ui = $0 }
                if let ui = $0.first {
                    self.ui = ui
                } else {
                    self.preferences.add(self.ui)
                }
                promise(.success($0.first))
            }.store(in: &self.subs)
        }
    }
    
    func updateUI() {
        preferences.update(ui)
    }
}
