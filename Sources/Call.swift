public enum Method: String {
    case GET, POST, PUT, DELETE, PATCH
}

public class Call {
    public let path: String
    public let method: Method

    public init(path: String, method: Method = .GET) {
        self.path = path
        self.method = method
    }

    public func request(withConfiguration configuration: Configuration) -> NSURLRequest? {
        let mutableRequest = NSMutableURLRequest(URL: NSURL(string: "\(configuration.baseURL)/\(path)")!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        mutableRequest.HTTPMethod = method.rawValue

        return mutableRequest
    }

}