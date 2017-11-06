import UIKit
import Faro

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FaroURLSession.setup(backendConfiguration: BackendConfiguration(baseURL:  "http://jsonplaceholder.typicode.com"),
                             urlSessionConfiguration: URLSessionConfiguration.background(withIdentifier: "com.icapps.\(UUID().uuidString)"))
        BuddyBuildSDK.setup()

        return true
    }

}
