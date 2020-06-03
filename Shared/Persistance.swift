import Foundation
import Balam
import Combine

final class Persistance {
    private var subs = Set<AnyCancellable>()
    private let preferences = Balam("preferences.amadeus")
    
    var ui: Future<Preferences.UI?, Never> {
        .init { promise in
            self.preferences.nodes(Preferences.UI.self).sink {
                promise(.success($0.first))
            }.store(in: &self.subs)
        }
    }
    
    func add(ui: Preferences.UI) {
        preferences.add(ui)
    }
    
    func update(_ frame: CGRect) {
        preferences.update(Preferences.UI.self) {
            $0.frame = frame
        }
    }
    
    func update(_ section: Preferences.UI.Section) {
        preferences.update(Preferences.UI.self) {
            $0.section = section
        }
    }
    
    func update(_ album: Album) {
        preferences.update(Preferences.UI.self) {
            $0.album = album
        }
    }
    
    func update(_ track: Track) {
        preferences.update(Preferences.UI.self) {
            $0.track = track
        }
    }
}
