import AppKit
import Combine

let persistance = Persistance()
let session = Session()
let player = Player()

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        persistance.loadUI.sink {
            let window: Window
            if $0 {
                window = .init(ui: persistance.ui)
            } else {
                window = .init(ui: .init())
                window.center()
                persistance.add(.init(frame: window.frame))
            }
            window.makeKeyAndOrderFront(nil)
            window.delegate = window
            player.track(persistance.ui.track)
            persistance.loadPreferences.sink {
                session.loaded($0)
            }.store(in: &self.subs)
        }.store(in: &subs)
    }
}
