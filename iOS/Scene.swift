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
        
        session.player.track.sink { track in
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: String.key(track.title),
                MPMediaItemPropertyArtist: String.key(track.composer.name),
                MPMediaItemPropertyPlaybackDuration: track.duration,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: <#T##UIImage#>)  MPMediaItemArtwork(boundsSize: .init(width: 140, height: 140)) { _ in
                    UIGraphicsImageRenderer(size: .init(width: 140, height: 140)).image { _ in
                        UIImage(named: track.album.cover)!.draw(in: .init(origin: .init(x: 0, y: -20), size: .init(width: 140, height: 180)))
                    }
                }
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
