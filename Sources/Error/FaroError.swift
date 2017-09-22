public enum FaroError: Error, Equatable, CustomDebugStringConvertible {

	public init(_ error: FaroError) {
		self = error
	}
    case decodingError(DecodingError, inData: Data, call: Call)

    case invalidUrl(String, call: Call)
	case invalidResponseData(Data?, call: Call)
	case invalidAuthentication(call: Call)
    case networkError(Int, data: Data?, request: URLRequest)

    case malformed(info: String)
	case invalidSession(message: String, request: URLRequest)

    public var debugDescription: String {

        switch self {
        case .invalidUrl(let url):
            return "📡🔥invalid url: \(url)"
        case .invalidResponseData(let data, call: let call):
            let dataString = String(data: data ?? Data(), encoding: .utf8)
            return "📡🔥 Invalid response data: \(dataString))\nin \(call)"
        case .invalidAuthentication:
            return "📡🔥 Invalid authentication"
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

                return "📡🔥 HTTP error: \(networkError)  method: \(request.httpMethod ?? "") in \(request)\ndata: \(string)"
            } else {
                return "📡🔥 HTTP error: \(networkError) method: \(request.httpMethod ?? "") in \(request)"
            }
        case .malformed(let info):
            return "📡🔥 \(info)"
        case .invalidSession(message: let message, request: let request):
            return "📡🔥 you tried to perform a \(request) on a session that is invalid\nmessage: \(message)"
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

    // MARK - Helpers

    // Returns non nil when the error is a decoding error. The returned value is the missing key.
    public var decodingErrorMissingKey: String? {
        switch self {
        case .decodingError(let error, inData: _, call: _):
            return error.keyNotFound
        default:
            return nil
        }
    }

}

public func == (lhs: FaroError, rhs: FaroError) -> Bool {
	switch (lhs, rhs) {
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

// MARK: - Handy extensions to Foundation errors

extension DecodingError {

    public var keyNotFound: String? {
        switch self {
        case .keyNotFound(let key, _):
            return key.stringValue
        default:
            return nil
        }
    }
}
