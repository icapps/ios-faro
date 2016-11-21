import UIKit

/// You can use this as a singleton that switches between using real data or data from a file.
/// To switch we use `MockSwitch`
open class FaroService: Service {
    /// Set this to a service. You can chose the `MockService` if the server is not yet available
    public static var sharedService: Service?

    public static func setup(with baseURL: String , session: FaroURLSession = FaroURLSession()) {
        FaroService.sharedService = Service(configuration: Configuration(baseURL: baseURL), session: session)
    }
    
    /// Returns real or mocked service. Run `setup(with:)` before calling this function.
    /// If you don't we default to returning the MockService
    public static var shared: Service {
        guard let sharedService = FaroService.sharedService else {
            FaroService.sharedService = MockService()
            return FaroService.sharedService!
            print("❓ You should run FaroService.setup(with:) in the AppDelegate after startup to have a service pointing to a server.")
            print("🍞 Falling back on using the MockService.")
        }

        return sharedService
    }
    
}
