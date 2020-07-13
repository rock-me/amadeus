import AppKit

final class Status: NSPopover {
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        contentSize = .init(width: 300, height: 150)
        contentViewController = .init()
        contentViewController!.view = Current()
        behavior = .transient
    }
}
