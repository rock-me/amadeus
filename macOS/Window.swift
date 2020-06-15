import AppKit

final class Window: NSWindow, NSWindowDelegate {
    init() {
        super.init(contentRect: state.ui.value.frame, styleMask:
            [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        minSize = .init(width: 500, height: 400)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        
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
        state.update {
            $0.frame = frame
        }
    }
    
    func windowDidResize(_: Notification) {
        state.update {
            $0.frame = frame
        }
    }
}
