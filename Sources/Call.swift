public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

open class Call {
    open let path: String
    open let httpMethod: HTTPMethod
    open var rootNode: String?
    open var parameters: Parameters?

    public convenience init<T: Serializable> (path: String, method: HTTPMethod = .POST, rootNode: String? = nil, serializableModel: T) {
        self.init(path: path, method: method, rootNode: rootNode, parameters: Parameters(type: .jsonBody, parameters: serializableModel.json) )
    }
    /// Initializes Call to retreive object(s) from the server.
    /// parameter rootNode: used to extract JSON in method `rootNode(from:)`.
    public init(path: String, method: HTTPMethod = .GET, rootNode: String? = nil, parameters: Parameters? = nil) {
        self.path = path
        self.httpMethod = method
        self.rootNode = rootNode
        self.parameters = parameters
    }

    open func request(withConfiguration configuration: Configuration) -> URLRequest? {
        var request = URLRequest(url: URL(string: "\(configuration.baseURL)/\(path)")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request = insertParameters(request: request)
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
            return .nodeNotFound(json: json)
        }
    }

    private func extractNodeIfNeeded(from json: Any?) -> Any? {
        guard  let rootNode = rootNode, let rootedJson = json as? [String: Any] else {
            return json
        }

        return rootedJson[rootNode]
    }
    
    private func insertParameters(request: URLRequest) -> URLRequest {
        guard let parameters = parameters else {
            return request
        }
        
        do {
            switch parameters.type {
            case .httpHeader:
                guard let headers = parameters.parameters as? [String: String] else {
                    throw FaroError.malformed(info: "HTTP headers must be in a [String: String] format")
                }
                return insertInHeaders(with: headers, request: request)
            case .urlComponents:
                guard let componentsDict = parameters.parameters as? [String: String] else {
                    throw FaroError.malformed(info: "URL components must first be cast to strings")
                }
                return insertInUrl(with: componentsDict, request: request)
            case .jsonBody:
                return insertInBody(with: parameters.parameters, request: request)
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
        var newRequest: URLRequest! = request
        var components = URLComponents(url: newRequest.url!, resolvingAgainstBaseURL: false)
        if (components?.queryItems == nil) {
            components?.queryItems = [URLQueryItem]()
        }
        for (key, value) in componentsDict {
            components?.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        newRequest.url = components?.url
        return newRequest
    }
    
    private func insertInBody(with json: [String: Any], request: URLRequest) -> URLRequest {
        do {
            if request.httpMethod == HTTPMethod.GET.rawValue || request.httpMethod == HTTPMethod.DELETE.rawValue {
                throw FaroError.malformed(info: "HTTP " + request.httpMethod! + " request can't have a body")
            }
            var newRequest = request
            newRequest.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            return newRequest
        } catch {
            printFaroError(error)
            return request
        }
    }
    
}


