public enum FaroError: Error, Equatable, CustomDebugStringConvertible {

	public init(_ error: FaroError) {
		self = error
	}

	case general

    case decodingError(DecodingError, inData: Data, call: Call)
	case invalidUrl(String, call: Call)
	case invalidResponseData(Data?, call: Call)
	case invalidAuthentication(call: Call)

	case nonFaroError(Error)

	case malformed(info: String)
    case couldNotCreateTask
    case shouldOverride

	case invalidSession(message: String, request: URLRequest)
	case networkError(Int, data: Data?, request: URLRequest)
    
    case parameterNotRecognized(message: String)

    public var debugDescription: String {

        switch self {
        case .general:
            return "📡🔥 General service error"
        case .invalidUrl(let url):
            return "📡🔥invalid url: \(url)"
        case .invalidResponseData(_):
            return "📡🔥 Invalid response data"
        case .invalidAuthentication:
            return "📡🔥 Invalid authentication"
        case .shouldOverride:
            return "📡🔥 You should override this method"
        case .nonFaroError(let nonFaroError):
            return "📡🔥 Error from service: \(nonFaroError)"
        case .networkError(let networkError, let data, let request):
            if let data = data {
                guard var string = String(data: data, encoding: .utf8), (string.hasPrefix("{") || string.hasPrefix("[")) else {
                    return "📡🔥 HTTP error: \(networkError) in \(request) no message in utf8 format."
                }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    string = String(data: prettyPrintedData, encoding: .utf8) ?? "Invalid json"
                } catch {
                    // ignore
                }

                return "📡🔥 HTTP error: \(networkError) in \(request) message: \(string)"
            } else {
                return "📡🔥 HTTP error: \(networkError) in \(request)"
            }
        case .malformed(let info):
            return "📡🔥 \(info)"
        case .invalidSession(message: let message, request: let request):
            return "📡🔥 you tried to perform a \(request) on a session that is invalid\nmessage: \(message)"
        case .couldNotCreateTask:
            return "📡🔥 a valid urlSessionTask could not be created"
        case .parameterNotRecognized(message: let message):
            return "📡🔥 message: \(message)"
        case .decodingError(let error, inData: let data, call: let call):
            guard var string = String(data: data, encoding: .utf8), (string.hasPrefix("{") || string.hasPrefix("[")) else {
                return "📡🔥 HTTP error: \(error) in \(call) no data in utf8 format."
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                string = String(data: prettyPrintedData, encoding: .utf8) ?? "Invalid json"
            } catch {
                // ignore
            }

            return "📡🔥 HTTP error: \(error) in \(call) data string: \(string)"
        }

    }
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
