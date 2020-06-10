import UIKit

final class Scene: UINavigationController, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo: UISceneSession, options: UIScene.ConnectionOptions) {
        setNavigationBarHidden(true, animated: false)
        setViewControllers([Music()], animated: false)
        let app = UIApplication.shared.delegate as! App
        app.windowScene = scene as? UIWindowScene
        app.rootViewController = self
        app.makeKeyAndVisible()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        //notifications
    }
}

@UIApplicationMain private final class App: UIWindow, UIApplicationDelegate { }
