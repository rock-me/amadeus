import SwiftUI
import Player

final class MistsController: WKHostingController<AnyView> {
    override var body: AnyView { .init(Music(album: .mists)
        .environmentObject((WKExtension.shared().delegate as! App).state)) }
}

final class MelancholyController: WKHostingController<AnyView> {
    override var body: AnyView { .init(Music(album: .melancholy)
        .environmentObject((WKExtension.shared().delegate as! App).state)) }
}

final class TensionController: WKHostingController<AnyView> {
    override var body: AnyView { .init(Music(album: .tension)
        .environmentObject((WKExtension.shared().delegate as! App).state)) }
}

final class DawnController: WKHostingController<AnyView> {
    override var body: AnyView { .init(Music(album: .dawn)
        .environmentObject((WKExtension.shared().delegate as! App).state)) }
}
