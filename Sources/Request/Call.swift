public enum HTTPMethod: String {
	case GET, POST, PUT, DELETE, PATCH
}

/// Defines a request that will be called in the DeprecatedService
/// You can add `[Parameter]` to the request and optionally authenticate the request when needed.
/// Optionally implement `Authenticatable` to make it possible to authenticate requests
open class Call {
	open let path: String
	open let httpMethod: HTTPMethod
	open var rootNode: String?
	open var parameters: [Parameter]?

	/// Initializes Call to retreive object(s) from the server.
	/// parameter path: the path to point the call too
	/// parameter method: the method to use for the urlRequest
	/// parameter rootNode: used to extract JSON in method `rootNode(from:)`.
	/// parameter serializableModel: the model is put into the body of the request as json.
	public convenience init<T: Serializable> (path: String, method: HTTPMethod = .POST, rootNode: String? = nil, serializableModel: T) {
		self.init(path: path, method: method, rootNode: rootNode, parameter: [.jsonNode(serializableModel.json)])
	}

	/// Initializes Call to retreive object(s) from the server.
	/// parameter path: the path to point the call too
	/// parameter method: the method to use for the urlRequest
	/// parameter rootNode: used to extract JSON in method `rootNode(from:)`.
	/// parameter parameter: array of parameters to be added to the request when created.
	public init(path: String, method: HTTPMethod = .GET, rootNode: String? = nil, parameter: [Parameter]? = nil) {
		self.path = path
		self.httpMethod = method
		self.rootNode = rootNode
		self.parameters = parameter
	}

	/// Makes a request from this call every time. This is done to every service call has its own request and can change time dependend parameters, like authorization.
	/// Optionally implement `Authenticatable` to make it possible to authenticate requests. In this function on self the functions in 'Authenticatable` will be called.
	open func request(with configuration: Configuration) -> URLRequest? {
		var request = URLRequest(url: URL(string: "\(configuration.baseURL)/\(path)")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData) // uses default timeout
		request.httpMethod = httpMethod.rawValue
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		insertParameter(request: &request)
		if let authenticatableSelf = self as? Authenticatable {
			authenticatableSelf.authenticate(&request)
		}
		return request
	}

	/// Used to begin parsing at the correct `rootnode`.
	/// Override if you want different behaviour then:
	/// `{"rootNode": <Any Node>}` `<Any Node> is returned when `rootNode` is set.
	open func rootNode(from json: Any) -> JsonNode {
		let json = extractNodeIfNeeded(from: json)

		if let jsonArray = json as? [Any] {
			return .nodeArray(jsonArray)
		} else if let json = json as? [String: Any] {
			return .nodeObject(json)
		} else {
			return .nodeNotFound(json: json ?? "")
		}
	}

	/// Called when creating a request.
	open func insertParameter(request: inout URLRequest) {
		parameters?.forEach {
			do {
				switch $0 {
				case .httpHeader(let headers):
					insertInHeaders(with: headers, request: &request)
				case .urlComponents(let components):
					insertInUrl(with: components, request: &request)
				case .jsonNode(let json):
					try insertInBody(with: json, request: &request)
				case .jsonArray(let jsonArray):
					try insertInBody(with: jsonArray, request: &request)
				}
			} catch {
				printFaroError(error)
			}
		}
	}

	private func extractNodeIfNeeded(from json: Any?) -> Any? {
		guard  let rootNode = rootNode, let rootedJson = json as? [String: Any] else {
			return json
		}

		return rootedJson[rootNode]
	}

	private func insertInHeaders(with headers: [String: String], request: inout URLRequest) {
		for (key, value) in headers {
			request.addValue(value, forHTTPHeaderField: key)
		}
	}

	private func insertInUrl(with componentsDict: [String: String], request: inout URLRequest) {
		guard componentsDict.values.count > 0 else {
			return
		}

		var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
		if (components?.queryItems == nil) {
			components?.queryItems = [URLQueryItem]()
		}
		let sortedComponents = componentsDict.sorted(by: { $0.0 < $1.0 })
		for (key, value) in sortedComponents {
			components?.queryItems?.append(URLQueryItem(name: key, value: value))
		}
		request.url = components?.url
	}

	private func insertInBody(with json: Any, request: inout URLRequest) throws {
		if request.httpMethod == HTTPMethod.GET.rawValue {
			throw FaroError.malformed(info: "HTTP " + request.httpMethod! + " request can't have a body")
		}
		request.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
	}

}
