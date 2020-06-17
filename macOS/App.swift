import AppKit
import Combine
import UserNotifications

let state = Session()

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        let music = Music()
        music.makeKeyAndOrderFront(nil)
        state.loadTrack.sink {
            music.coverflow.show(state.player.track.value.album)
            state.loadConfig()
        }.store(in: &subs)
    }
    
    func applicationDidFinishLaunching(_: Notification) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings {
            if $0.authorizationStatus != .authorized {
                DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                }
            }
        }
        
        state.player.start.sink {
            guard state.player.config.value.notifications else { return }
            UNUserNotificationCenter.current().getNotificationSettings {
                guard $0.authorizationStatus == .authorized else { return }
                UNUserNotificationCenter.current().add({
                    $0.title = .key(state.player.track.value.title)
                    $0.body = .key(state.player.track.value.composer.name)
                    return .init(identifier: UUID().uuidString, content: $0, trigger: nil)
                } (UNMutableNotificationContent()))
            }
        }.store(in: &subs)
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
    
    @objc func store() {
        (windows.first { $0 is Store } ?? Store()).makeKeyAndOrderFront(nil)
    }
    
    @objc func settings() {
        (windows.first { $0 is Settings } ?? Settings()).makeKeyAndOrderFront(nil)
    }
    
    @objc func status(_ button: NSStatusBarButton) {
        let status = Status()
        status.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        status.contentViewController!.view.window!.makeKey()
    }
}
