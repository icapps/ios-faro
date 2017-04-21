public enum FaroError: Error, Equatable {
	public init(_ error: FaroError) {
		self = error
	}

	case general

	case invalidUrl(String, call: Call)
	case invalidResponseData(Data?, call: Call)
	case invalidAuthentication(call: Call)

	case shouldOverride
	case nonFaroError(Error)

	case malformed(info: String)

	case invalidSession(message: String, request: URLRequest)
	case networkError(Int, data: Data?, request: URLRequest)

	case rootNodeNotFoundIn(json: Any, call: Call)
	case couldNotCreateTask

	case noUpdateModelOf(type: String, ofJsonNode: [String: Any], call: Call)
	case noModelOf(type: String, inJson: JsonNode, call: Call)
	case couldNotCreateInstance(ofType: String, call: Call, error: Error)

	case invalidDeprecatedResult(resultString: String, call: Call)
    
    case parameterNotRecognized(message: String)
}

public func == (lhs: FaroError, rhs: FaroError) -> Bool {
	switch (lhs, rhs) {
	case (.general, .general):
		return true
	case (.invalidAuthentication, .invalidAuthentication):
		return true
	case (.invalidUrl(let url_lhs, call: _), .invalidUrl(let url_rhs, call: _)): // tailor:disable
		return url_lhs == url_rhs
	case (.invalidResponseData (_), .invalidResponseData (_)):
		return true
	case (.networkError(let lStatusCode, _, _ ), .networkError(let rStatusCode, _, _)):
		return lStatusCode == rStatusCode
	default:
		return false
	}
}
