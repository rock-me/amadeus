import AppKit

final class Window: NSWindow, NSWindowDelegate {
    init(_ frame: CGRect) {
        super.init(contentRect: frame, styleMask:
            [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        minSize = .init(width: 300, height: 200)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        delegate = self
        contentView = View()
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
    
    func windowDidMove(_: Notification) {
        persistance.update(uiFrame: frame)
    }
    
    func windowDidResize(_: Notification) {
        persistance.update(uiFrame: frame)
    }
}
