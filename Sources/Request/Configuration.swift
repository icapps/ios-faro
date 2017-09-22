import Foundation

enum ConfigurationError: Error {
	case noValidBaseUrl(String)
}
/// Use for different configurations for the specific environment you want to use for *Call*
open class Configuration {

    open let decoder: JSONDecoder
    open var baseURL: String

    public init(baseURL: String, decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.decoder = decoder
    }
    
}
