import AppKit
import Combine

let session = Session()
let playback = Playback()

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        session.loadUI.sink {
            let window: Window
            if $0 {
                window = .init()
            } else {
                window = .init()
                window.center()
                session.add(ui: window.frame)
            }
            window.makeKeyAndOrderFront(nil)
            window.delegate = window
            session.loadPlayer()
        }.store(in: &subs)
    }
}
