import UIKit

/// Uses as a global to determine if `FaroService` should do reald data
public struct MockSwitch {
    public static var shouldMock = false
}

/// You can use this as a singleton that switches betwee using real data or data from a file.
/// To switch we use `MockSwitch`
open class FaroService: Service {
    /// Sends its requests to the servers
    private static var sharedService: Service?
    /// Sends its requests to a file
    private static let sharedMockService = MockService()


    public static func setup(with baseURL: String) {
        FaroService.sharedService = Service(configuration: Configuration(baseURL: baseURL))
    }
    
    /// Returns real or mocked service. Run `setup(with:)` before calling this function.
    /// If you don't we default to returning the MockService
    public static var shared: Service {
        if let sharedService = FaroService.sharedService {
            return MockSwitch.shouldMock ? sharedMockService : sharedService
        } else {
            print("❓ You should run FaroService.setup(with:) in the AppDelegate after startup to have a service pointing to a server.")
            print("🍞 Falling back on using the MockService.")
            return FaroService.sharedMockService
        }
    }
    
}
