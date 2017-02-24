public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

open class Call {
    open let path: String
    open let httpMethod: HTTPMethod
    open var rootNode: String?
    open var parameter: Parameter?

    public convenience init<T: Serializable> (path: String, method: HTTPMethod = .POST, rootNode: String? = nil, serializableModel: T) {
        self.init(path: path, method: method, rootNode: rootNode, parameter: .jsonNode(serializableModel.json))
    }
    /// Initializes Call to retreive object(s) from the server.
    /// parameter rootNode: used to extract JSON in method `rootNode(from:)`.
    public init(path: String, method: HTTPMethod = .GET, rootNode: String? = nil, parameter: Parameter? = nil) {
        self.path = path
        self.httpMethod = method
        self.rootNode = rootNode
        self.parameter = parameter
    }

    open func request(withConfiguration configuration: Configuration) -> URLRequest? {
		var request = URLRequest(url: URL(string: "\(configuration.baseURL)/\(path)")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData) // uses default timeout
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request = insertParameter(request: request)
        return request
    }

    /// Use to begin paring at the correct `rootnode`.
    /// Override if you want different behaviour then: 
    /// `{"rootNode": <Any Node>}` `<Any Node> is returned when `rootNode` is set.
    open func rootNode(from json: Any) -> JsonNode {
        let json = extractNodeIfNeeded(from: json)

        if let jsonArray = json as? [Any] {
            return .nodeArray(jsonArray)
        }else if let json = json as? [String: Any] {
            return .nodeObject(json)
        }else {
            return .nodeNotFound(json: json ?? "")
        }
    }

    private func extractNodeIfNeeded(from json: Any?) -> Any? {
        guard  let rootNode = rootNode, let rootedJson = json as? [String: Any] else {
            return json
        }

        return rootedJson[rootNode]
    }
    
    private func insertParameter(request: URLRequest) -> URLRequest {
        guard let parameter = parameter else {
            return request
        }
        
        do {
            switch parameter {
            case .httpHeader(let headers):
                return insertInHeaders(with: headers, request: request)
            case .urlComponents(let components):
                return insertInUrl(with: components, request: request)
            case .jsonNode(let json):
                return try insertInBody(with: json, request: request)
            case .jsonArray(let jsonArray):
                return try insertInBody(with: jsonArray, request: request)
            }
        } catch {
            printFaroError(error)
            return request
        }
    }
    
    private func insertInHeaders(with headers: [String: String], request: URLRequest) -> URLRequest {
        var newRequest = request
        for (key, value) in headers {
            newRequest.addValue(value, forHTTPHeaderField: key)
        }
        return newRequest
    }
    
    private func insertInUrl(with componentsDict: [String: String], request: URLRequest) -> URLRequest {
        guard componentsDict.values.count > 0 else {
            return request
        }

        var newRequest: URLRequest! = request
        var components = URLComponents(url: newRequest.url!, resolvingAgainstBaseURL: false)
        if (components?.queryItems == nil) {
            components?.queryItems = [URLQueryItem]()
        }
        let sortedComponents = componentsDict.sorted(by: { $0.0 < $1.0 })
        for (key, value) in sortedComponents {
            components?.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        newRequest.url = components?.url
        return newRequest
    }
    
    private func insertInBody(with json: Any, request: URLRequest) throws -> URLRequest {
        if request.httpMethod == HTTPMethod.GET.rawValue {
            throw FaroError.malformed(info: "HTTP " + request.httpMethod! + " request can't have a body")
        }
        var newRequest = request
        newRequest.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

        return newRequest
    }

}


