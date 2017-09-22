public enum HTTPMethod: String {
	case GET, POST, PUT, DELETE, PATCH
}

/// Defines a request that will be called in the DeprecatedService
/// You can add `[Parameter]` to the request and optionally authenticate the request when needed.
/// Optionally implement `Authenticatable` to make it possible to authenticate requests
open class Call {
	open let path: String
	open let httpMethod: HTTPMethod
	open var parameters = [Parameter]()

	fileprivate var request: URLRequest?

	/// Initializes Call to retreive object(s) from the server.
	/// parameter path: the path to point the call too
	/// parameter method: the method to use for the urlRequest
	/// parameter parameter: array of parameters to be added to the request when created.
	public init(path: String, method: HTTPMethod = .GET, parameter: [Parameter]? = nil) {
		self.path = path
		self.httpMethod = method
		if let parameters = parameter {
			self.parameters = parameters
		}
	}

	/// Makes a request from this call every time. This is done to every service call has its own request and can change time dependend parameters, like authorization.
	/// Optionally implement `Authenticatable` to make it possible to authenticate requests. In this function on self the functions in 'Authenticatable` will be called.
	open func request(with configuration: Configuration) -> URLRequest? {
		var request = URLRequest(url: URL(string: "\(configuration.baseURLString)/\(path)")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData) // uses default timeout
		self.request = request
		request.httpMethod = httpMethod.rawValue
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		insertParameter(request: &request)
		if let authenticatableSelf = self as? Authenticatable {
			authenticatableSelf.authenticate(&request)
		}
		return request
	}

	/// Called when creating a request.
	open func insertParameter(request: inout URLRequest) {
		parameters.forEach {
			do {
				switch $0 {
				case .httpHeader(let headers):
					insertInHeaders(with: headers, request: &request)
				case .urlComponentsInURL(let components):
					insertInUrl(with: components, request: &request)
				case .jsonNode(let json):
					try insertInBodyInJson(with: json, request: &request)
				case .jsonArray(let jsonArray):
					try insertInBodyInJson(with: jsonArray, request: &request)
				case .multipart(let multipart):
					try insertMultiPartInBody(with: multipart, request: &request)
				case .urlComponentsInBody(let components):
					try insertInBodyAsURLComponents(with: components, request: &request)
                case .bodyData(let data):
                    try insertInBody(data: data, request: &request)
				}
			} catch {
				print(error)
			}
		}
	}

	private func insertInHeaders(with headers: [String: String], request: inout URLRequest) {
		for (key, value) in headers {
			request.setValue(value, forHTTPHeaderField: key)
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

	private func insertInBodyInJson(with json: Any, request: inout URLRequest) throws {
		if request.httpMethod == HTTPMethod.GET.rawValue {
			throw FaroError.malformed(info: "HTTP " + request.httpMethod! + " request can't have a body")
		}
		request.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
	}

    private func insertInBody(data: Data, request: inout URLRequest) throws {
        if request.httpMethod == HTTPMethod.GET.rawValue {
            throw FaroError.malformed(info: "HTTP " + request.httpMethod! + " request can't have a body")
        }
        request.httpBody = data
    }

	private func insertInBodyAsURLComponents(with dict: [String: String], request: inout URLRequest) throws {
		if request.httpMethod == HTTPMethod.GET.rawValue {
			throw FaroError.malformed(info: "HTTP " + request.httpMethod! + " request can't have a body")
		}
		request.httpBody = dict.queryParameters.data(using: .utf8)
	}

	private func insertMultiPartInBody(with multipart: MultipartFile, request: inout URLRequest) throws {
		guard request.httpMethod != HTTPMethod.GET.rawValue else {
			throw FaroError.malformed(info: "HTTP " + request.httpMethod! + " request can't have a body")
		}

		let boundary = "Boundary-iCapps-Faro"
		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		request.httpBody = createMultipartBody(with: multipart, boundary: boundary)
	}

	private func createMultipartBody(with multipart: MultipartFile, boundary: String) -> Data {

		let boundaryPrefix = "--\(boundary)\r\n"
		var body = Data()
		body.appendString(boundaryPrefix)
		body.appendString("Content-Disposition: form-data; name=\"\(multipart.parameterName)\"; filename=\"\(multipart.parameterName)\"\r\n")
		body.appendString("Content-Type: \(multipart.mimeType)\r\n\r\n")
		body.append(multipart.data)
		body.appendString("\r\n")
		body.appendString("\(boundaryPrefix)--\r\n")

		return body
	}
}

// MARK: - CustomDebugStringConvertible

extension Call: CustomDebugStringConvertible {

	public var debugDescription: String {
		let parameterString: String = parameters.reduce("Parameters", {"\($0)\n\($1)"})
		return "Call \(request?.url?.absoluteString ?? "")\n• parameters: \(parameterString)"
	}

}
