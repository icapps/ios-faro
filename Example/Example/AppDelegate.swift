import UIKit
import Faro

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [StubbedURLProtocol.self] // allow stubbing
        FaroURLSession.setup(backendConfiguration: BackendConfiguration(baseURL: "http://jsonplaceholder.typicode.com"),
                             urlSessionConfiguration: config)
        BuddyBuildSDK.setup()

        return true
    }

}
