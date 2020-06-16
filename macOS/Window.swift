import AppKit

final class Window: NSWindow, NSWindowDelegate {
    override var frameAutosaveName: NSWindow.FrameAutosaveName { "Window" }
    
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 500, height: 700), styleMask:
            [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        minSize = .init(width: 500, height: 400)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        if !setFrameUsingName(frameAutosaveName) {
            center()
        }
        
        let bar = Bar()
        contentView!.addSubview(bar)
        
        let music = Music()
        contentView!.addSubview(music)
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        music.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        music.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        music.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        music.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
    
    func windowDidMove(_: Notification) {
        saveFrame(usingName: frameAutosaveName)
    }

    func windowDidResize(_: Notification) {
        saveFrame(usingName: frameAutosaveName)
    }
}
