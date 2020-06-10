import UIKit

let session = Session()

final class Scene: UIWindow, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo: UISceneSession, options: UIScene.ConnectionOptions) {
        windowScene = scene as? UIWindowScene
        rootViewController = Music()
        makeKeyAndVisible()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        //notifications
    }
}

@UIApplicationMain private final class App: NSObject, UIApplicationDelegate { }
