import AppKit
import Combine
import UserNotifications

let session = Session()
let playback = Playback()

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        session.loadUI.sink {
            let window: Window
            if $0 {
                window = .init()
            } else {
                window = .init()
                window.center()
                session.add(ui: window.frame)
            }
            window.makeKeyAndOrderFront(nil)
            window.delegate = window
            session.loadPlayer()
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
        
        playback.player.start.sink {
            guard playback.player.config.value.notifications else { return }
            UNUserNotificationCenter.current().getNotificationSettings {
                guard $0.authorizationStatus == .authorized else { return }
                UNUserNotificationCenter.current().add({
                    $0.title = .key(playback.player.track.value.title)
                    $0.body = .key(playback.player.track.value.composer.name)
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
}
