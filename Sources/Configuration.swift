import Foundation

enum ConfigurationError: Error {
	case noValidBaseUrl(String)
}
/// Use for different configurations for the specific environment you want to use for *Call*
open class Configuration {

	/// Add this in case you need to add authentication information to request for different Configurations
	open let authenticate: ((_ request: inout URLRequest) -> Void)?

    /// For now we only support JSON. Can be Changed in the future
    open let adaptor: Adaptable
    open var baseURL: String

    public init(baseURL: String, adaptor: Adaptable = JSONAdaptor(), authenticate: ((_ request: inout URLRequest) -> Void)? = nil) {
        self.baseURL = baseURL
        self.adaptor = adaptor
		self.authenticate = authenticate
    }
    
}
