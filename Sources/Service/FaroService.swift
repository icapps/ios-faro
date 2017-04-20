/// You can use this as a singleton that switches between using real data or data from a file.
open class FaroService: Service {

	/// Set this to a service. You can chose the `MockService` if the server is not yet available
    public static var sharedService: Service?

	/// Call this function before using FaroService.
    public static func setup(with baseURL: String , session: FaroSessionable = FaroSession()) {
        FaroService.sharedService = Service(configuration: Configuration(baseURL: baseURL), faroSession: session)
    }
    
    /// Returns real or mocked service. Run `setup(with:session:)` before calling this function.
    /// If you don't we default to returning the `MockService.`
    public static var shared: Service {
        guard let sharedService = FaroService.sharedService else {
            var message = " You should run FaroService.setup(with:) in the AppDelegate after startup to have a service pointing to a server."
            printFaroError(FaroError.malformed(info: message))
            message = "🍞 Falling back on using the MockService."
            printFaroError(FaroError.malformed(info: message))
            FaroService.sharedService = MockService()
            return FaroService.sharedService!
        }

        return sharedService
    }
    
}
