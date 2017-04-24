import UIKit
import Faro

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()

		// Optionally setup a singleton

		let baseURL = "http://jsonplaceholder.typicode.com"

		// Optionally create your own FaroSession to handle for example security.
		FaroSingleton.setup(with: baseURL, session: FaroSession())


        return true
    }

}
