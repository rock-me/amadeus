import AppKit
import Combine

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
    let persistance = Persistance()
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        persistance.storedUI.sink {
            let window: Window
            if let ui = $0 {
                window = .init(ui.frame)
            } else {
                window = .init()
                window.center()
                print(window.frame)
                self.persistance.ui.frame = window.frame
                self.persistance.updateUI()
            }
            window.makeKeyAndOrderFront(nil)
            
        }.store(in: &subs)
    }
}
