/// You can use this as a singleton that switches between using real data or data from a file.
open class FaroDeprecatedService: DeprecatedService {

	/// Set this to a service. You can chose the `MockDeprecatedService` if the server is not yet available
    public static var sharedDeprecatedService: DeprecatedService?

	/// Call this function before using FaroDeprecatedService.
    public static func setup(with baseURL: String, session: FaroSessionable = FaroSession()) {
        FaroDeprecatedService.sharedDeprecatedService = DeprecatedService(configuration: Configuration(baseURL: baseURL), faroSession: session)
    }
    
    /// Returns real or mocked service. Run `setup(with:session:)` before calling this function.
    /// If you don't we default to returning the `MockDeprecatedService.`
    public static var shared: DeprecatedService {
        guard let sharedDeprecatedService = FaroDeprecatedService.sharedDeprecatedService else {
            var message = " You should run FaroDeprecatedService.setup(with:) in the AppDelegate after startup to have a service pointing to a server."
            printFaroError(FaroError.malformed(info: message))
            message = "🍞 Falling back on using the MockDeprecatedService."
            printFaroError(FaroError.malformed(info: message))
            FaroDeprecatedService.sharedDeprecatedService = MockDeprecatedService()
            return FaroDeprecatedService.sharedDeprecatedService!
        }

        return sharedDeprecatedService
    }
    
}
