import Foundation

enum ConfigurationError: Error {
	case noValidBaseUrl(String)
}
/// Use for different configurations for the specific environment you want to use for *Call*
open class BackendConfiguration {

    open let decoder: JSONDecoder
    open var baseURLString: String
    open var baseURL: URL? {
         return URL(string: baseURLString)
    }
    public init(baseURL: String, decoder: JSONDecoder = JSONDecoder()) {
        self.baseURLString = baseURL
        self.decoder = decoder
    }
    
}
