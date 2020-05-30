import AppKit

final class Window: NSWindow {
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 900, height: 700), styleMask: [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView], backing: .buffered, defer: false)
        minSize = .init(width: 500, height: 500)
        center()
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
}
