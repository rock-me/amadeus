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
        persistance.loadUI.sink {
            let window: Window
            if let ui = $0 {
                window = .init(ui.frame)
            } else {
                window = .init(.init(x: 0, y: 0, width: 500, height: 400))
                window.center()
                persistance.add(ui: .init(frame: window.frame))
            }
            window.makeKeyAndOrderFront(nil)
        }.store(in: &subs)
    }
}
