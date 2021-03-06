import AppKit

class Control: NSView {
    weak var target: AnyObject!
    var action: Selector!
    var enabled = true
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseDown(with: NSEvent) {
        guard enabled else { return }
        hoverOn()
    }
    
    override func mouseUp(with: NSEvent) {
        guard enabled else { return }
        window!.makeFirstResponder(self)
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            click()
        } else {
            super.mouseUp(with: with)
        }
        hoverOff()
    }
    
    func click() {
        _ = target.perform(action, with: self)
    }
    
    func hoverOn() {
        
    }
    
    func hoverOff() {
        
    }
}
