import AppKit

final class Window: NSWindow, NSWindowDelegate {
    init(ui: UI) {
        super.init(contentRect: ui.frame, styleMask:
            [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        minSize = .init(width: 400, height: 300)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        delegate = self
        contentView = View(ui: ui)
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
    
    func windowDidMove(_: Notification) {
        persistance.update {
            $0.frame = frame
        }
    }
    
    func windowDidResize(_: Notification) {
        persistance.update {
            $0.frame = frame
        }
    }
}
