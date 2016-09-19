public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

open class Call {
    open let path: String
    open let httpMethod: HTTPMethod

    public init(path: String, httpMethod: HTTPMethod = .GET) {
        self.path = path
        self.httpMethod = httpMethod
    }

    open func request(withConfiguration configuration: Configuration) -> URLRequest? {
        var request = URLRequest(url: URL(string: "\(configuration.baseURL)/\(path)")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = httpMethod.rawValue

        return request
    }

}
