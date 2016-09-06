public enum Method: String {
    case GET, POST, PUT, DELETE, PATCH
}

public class Order {
    public let path: String
    public let method: Method

    public init(path: String, method: Method = .GET) {
        self.path = path
        self.method = method
    }

    public func urlForConfiguration(configuration: Configuration) -> NSURL? {
        return NSURL(string: "\(configuration.baseURL)/\(path)")
    }

}