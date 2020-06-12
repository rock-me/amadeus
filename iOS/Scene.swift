import UIKit
import Combine
import MediaPlayer

let session = Session()

final class Scene: UIWindow, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
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
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: .init(width: 200, height: 200)) { _ in
                    UIGraphicsImageRenderer(size: .init(width: 200, height: 200)).image { _ in
                        UIImage(named: track.album.cover)!.draw(in: .init(origin: .init(x: 0, y: -30), size: .init(width: 200, height: 260)))
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
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings {
            if $0.authorizationStatus != .authorized {
                DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                }
            }
        }
        
        session.player.start.sink {
            guard session.player.config.value.notifications else { return }
            UNUserNotificationCenter.current().getNotificationSettings {
                guard $0.authorizationStatus == .authorized else { return }
                UNUserNotificationCenter.current().add({
                    $0.title = .key(session.player.track.value.title)
                    $0.body = .key(session.player.track.value.composer.name)
                    return .init(identifier: UUID().uuidString, content: $0, trigger: nil)
                } (UNMutableNotificationContent()))
            }
        }.store(in: &subs)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = session.time.value
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        UNUserNotificationCenter.current().getDeliveredNotifications {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0.map {
                $0.request.identifier
            }.filter {
                $0 != willPresent.request.identifier
            })
        }
    }
}

@UIApplicationMain private final class App: NSObject, UIApplicationDelegate { }
