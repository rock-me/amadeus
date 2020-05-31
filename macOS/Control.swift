import AppKit

class Control: NSView {
    weak var target: AnyObject!
    var action: Selector!
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
        hoverOn()
    }
    
    override func mouseUp(with: NSEvent) {
        window!.makeFirstResponder(self)
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            _ = target.perform(action, with: self)
        } else {
            super.mouseUp(with: with)
        }
        hoverOff()
    }
    
    func hoverOn() {
        
    }
    
    func hoverOff() {
        
    }
}
