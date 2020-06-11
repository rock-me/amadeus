import UIKit
import Combine
import MediaPlayer

let session = Session()

final class Scene: UIWindow, UIWindowSceneDelegate {
    private var subs = Set<AnyCancellable>()
    
    func scene(_ scene: UIScene, willConnectTo: UISceneSession, options: UIScene.ConnectionOptions) {
        windowScene = scene as? UIWindowScene
        rootViewController = Music()
        makeKeyAndVisible()
        
        MPRemoteCommandCenter.shared().playCommand.addTarget { _ in
            session.play()
            return .success
        }
        
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { _ in
            session.pause()
            return .success
        }
        
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { _ in
            session.next()
            return .success
        }
        
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { _ in
            session.previous()
            return .success
        }
        
        session.player.track.sink {
            let image = UIImage(named: $0.album.cover)!
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: String.key($0.title),
                MPMediaItemPropertyArtist: String.key($0.composer.name),
                MPMediaItemPropertyPlaybackDuration: $0.duration,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            ]
        }.store(in: &subs)
        
        session.playing.sink { _ in
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = session.time.value
        }.store(in: &subs)
        
        session.player.previousable.sink {
            MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = $0
        }.store(in: &subs)
        
        session.player.nextable.sink {
            MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = $0
        }.store(in: &subs)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        //notifications
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = session.time.value
    }
}

@UIApplicationMain private final class App: NSObject, UIApplicationDelegate { }
