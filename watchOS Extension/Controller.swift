import SwiftUI
import Player

final class MistsController: WKHostingController<Music> {
    override var body: Music { Music(album: .mists) }
}

final class MelancholyController: WKHostingController<Music> {
    override var body: Music { Music(album: .melancholy) }
}

final class TensionController: WKHostingController<Music> {
    override var body: Music { Music(album: .tension) }
}

final class DawnController: WKHostingController<Music> {
    override var body: Music { Music(album: .dawn) }
}
