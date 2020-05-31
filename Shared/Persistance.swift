import Foundation
import Balam
import Combine

final class Persistance {
    private var subs = Set<AnyCancellable>()
    private let preferences = Balam("preferences.amadeus")
    
    var loadUI: Future<Preferences.UI?, Never> {
        .init { promise in
            self.preferences.nodes(Preferences.UI.self).sink {
                promise(.success($0.first))
            }.store(in: &self.subs)
        }
    }
    
    func add(ui: Preferences.UI) {
        preferences.add(ui)
    }
    
    func update(uiFrame: CGRect) {
        preferences.update(Preferences.UI.self) {
            $0.frame = uiFrame
        }
    }
}
