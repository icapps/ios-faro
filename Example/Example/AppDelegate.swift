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
		let baseURL = "http://jsonplaceholder.typicode.com"
		// Optionally create your own FaroSession to handle for example security.
		FaroSingleton.setup(with: baseURL, session: FaroSession())
	}

	func setupFaroWithSecurity() {
		let baseURL = "http://jsonplaceholder.typicode.com"

		let sessionSessionDelegate = FaroURLSessionDelegate(allowUntrustedCertificates: false)
		let secureSession = FaroSecureURLSession(urlSessionDelegate: sessionSessionDelegate)
		FaroSingleton.setup(with: baseURL, session: secureSession)

	}

}
