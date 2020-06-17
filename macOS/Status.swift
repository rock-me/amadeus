import AppKit
import Player
import Combine

final class Status: NSPopover {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        contentSize = .init(width: 300, height: 150)
        contentViewController = .init()
        contentViewController!.view = Current()
        behavior = .transient
    }
}
