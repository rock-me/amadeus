import AppKit

final class Window: NSWindow, NSWindowDelegate {
    init() {
        super.init(contentRect: session.ui.value.frame, styleMask:
            [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        minSize = .init(width: 500, height: 400)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        contentView = View()
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
    
    func windowDidMove(_: Notification) {
        session.update {
            $0.frame = frame
        }
    }
    
    func windowDidResize(_: Notification) {
        session.update {
            $0.frame = frame
        }
    }
}
