import AppKit

final class Music: NSWindow, NSWindowDelegate {
    private(set) weak var coverflow: Coverflow!
    
    override var frameAutosaveName: NSWindow.FrameAutosaveName { "Music" }
    
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
        
        let scroll = Scroll()
        scroll.horizontalScrollElasticity = .none
        contentView!.addSubview(scroll)
        
        let detail = Detail()
        scroll.add(detail)
        
        let coverflow = Coverflow(detail: detail)
        scroll.add(coverflow)
        self.coverflow = coverflow
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        scroll.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: detail.bottomAnchor, constant: 30).isActive = true
        
        coverflow.topAnchor.constraint(equalTo: scroll.top).isActive = true
        coverflow.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        coverflow.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        detail.topAnchor.constraint(equalTo: coverflow.bottomAnchor).isActive = true
        detail.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
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
