public enum Method: String {
    case GET, POST, PUT, DELETE, PATCH
}

open class Call {
    open let path: String
    open let method: Method

    public init(path: String, method: Method = .GET) {
        self.path = path
        self.method = method
    }

    open func request(withConfiguration configuration: Configuration) -> URLRequest? {
        let mutableRequest = NSMutableURLRequest(url: URL(string: "\(configuration.baseURL)/\(path)")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        mutableRequest.httpMethod = method.rawValue

        return mutableRequest as URLRequest
    }

}
