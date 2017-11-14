import UIKit
import Faro

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()

		// Optionally setup a singleton

		setupFaroWithoutSecurity()
//		setupFaroWithSecurity()

        return true
    }

	func setupFaroWithoutSecurity() {
		// Optionally create your own FaroSession to handle for example security.
		//Pass it to your singleton of the Service class
        //Example: FaroSingleton.setup(with: "http://jsonplaceholder.typicode.com", session: FaroSession())
	}

	func setupFaroWithSecurity() {
        // let sessionSessionDelegate = FaroURLSessionDelegate(allowUntrustedCertificates: false)
        // let secureSession = FaroSecureURLSession(urlSessionDelegate: sessionSessionDelegate)
        //Pass it to your singleton of the Service class
        //Example: FaroSingleton.setup(with: "http://jsonplaceholder.typicode.com", session: secureSession)
	}

}
