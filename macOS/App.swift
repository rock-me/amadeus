import AppKit
import Combine

let persistance = Persistance()
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        persistance.ui.sink {
            let window: Window
            if let ui = $0 {
                window = .init(ui: ui)
            } else {
                persistance.add(ui: .init())
                window = .init(ui: .init())
                window.center()
                persistance.update(window.frame)
            }
            window.makeKeyAndOrderFront(nil)
        }.store(in: &subs)
    }
}
