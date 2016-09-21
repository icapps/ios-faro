public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

open class Call {
    open let path: String
    open let httpMethod: HTTPMethod
    open var rootNode: String?
    open var parameters: Parameters?

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
        if (self.parameters == nil) {
            return request
        }
        do {
            switch (self.parameters!.type!) {
            case .httpHeader:
                guard let headers = self.parameters?.parameters as? [String: String] else {
                    throw FaroError.malformed(info: "HTTP headers must be in a [String: String] format")
                }
                return insert(headers: headers, request: request)
            case .urlComponents:
                guard let componentsDict = self.parameters?.parameters as? [String: String] else {
                    throw FaroError.malformed(info: "URL components must first be cast to strings")
                }
                return insert(componentsDict: componentsDict, request: request)
            case .jsonBody:
                return insert(json: (self.parameters?.parameters)!, request: request)
            }
        } catch {
            printError(error)
            return request
        }
    }
    
    private func insert(headers: [String: String], request: URLRequest) -> URLRequest {
        var newRequest = request
        for (key, value) in headers {
            newRequest.addValue(value, forHTTPHeaderField: key)
        }
        return newRequest
    }
    
    private func insert(componentsDict: [String: String], request: URLRequest!) -> URLRequest {
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
    
    private func insert(json: [String: Any], request: URLRequest!) -> URLRequest {
        do {
            if request.httpMethod == HTTPMethod.GET.rawValue || request.httpMethod == HTTPMethod.DELETE.rawValue {
                throw FaroError.malformed(info: "HTTP " + request.httpMethod! + " request can't have a body")
            }
            var newRequest = request
            var body = newRequest?.httpBody
            if body == nil {
                body = try JSONSerialization.data(withJSONObject: [String: Any](), options: .prettyPrinted)
            }
            var newJSON = [String: Any]()
            do {
                newJSON = try JSONSerialization.jsonObject(with: body!, options: .allowFragments) as! [String: Any]
            } catch {
                newJSON = [String: Any]()
            }
            for (key, value) in json {
                newJSON[key] = value
            }
            newRequest?.httpBody = try JSONSerialization.data(withJSONObject: newJSON, options: .prettyPrinted)
            return newRequest!
        } catch {
            printError(error)
            return request
        }
    }
    
}


