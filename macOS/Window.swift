import AppKit

final class Window: NSWindow, NSWindowDelegate {
    override var frameAutosaveName: NSWindow.FrameAutosaveName { "Window" }
    
    private(set) weak var music: Music!
    
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 400, height: 800), styleMask:
            [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        minSize = .init(width: 400, height: 300)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        if !setFrameUsingName(frameAutosaveName) {
            center()
        }
        delegate = self
        
        let bar = Bar()
        contentView!.addSubview(bar)
        
        let music = Music()
        self.music = music
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
