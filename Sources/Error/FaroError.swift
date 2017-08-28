import Foundation

public enum FaroError: Error, Equatable, CustomStringConvertible {

    public init(_ error: FaroError) {
        self = error
    }

    // MARK: - Network setup errors
    case general
    case invalidUrl(String)
    case malformed(info: String)
    case invalidSession(message: String)

    // MARK: - Network errors
    case invalidResponseData(statusCode: Int, data: Data?, call: Call)
    case invalidAuthentication(statusCode:Int, data: Data?, call: Call)
    case networkError(statusCode: Int, data: Data?, call: Call)

    case shouldOverride
    case nonFaroError(Error)

    // MARK: - Parsing errors
    case rootNodeNotFound(json: Any)
    case emptyKey
    case emptyValue(key: String)
    case emptyCollection(key: String, json: [String: Any])
    case serializationError
    case updateNotPossible(json: Any, model: Any)

    // MARK: - CustomStringConvertible
    public var description: String {
        switch self {
        case .general:
            return "📡🔥 General service error"
        case .invalidUrl(let url):
            return "📡🔥invalid url: \(url)"
        case .invalidResponseData(statusCode: let code, data: let data, call: let call):
            return "📡🔥 Invalid response data"
        case .invalidAuthentication(statusCode: let code, data: let data, call: let call):
            if let data = data {
                guard var string = String(data: data, encoding: .utf8), (string.hasPrefix("{") || string.hasPrefix("[")) else {
                    return "📡🔥 Invalid authentication code: \(code) no message in utf8 format. \(call)"
                }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    string = String(data: prettyPrintedData, encoding: .utf8) ?? "Invalid json"
                } catch {
                    // ignore
                }

                return "📡🔥 Invalid authentication statusCode: \(code) \nmessage: \(string)\ncall:\(call)"

            } else {
                return "📡🔥 Invalid authentication statusCode: \(code) in\ncall: \(call)."

            }

        case .shouldOverride:
            return "📡🔥 You should override this method"
        case .nonFaroError(let nonFaroError):
            return "📡🔥 Error from service: \(nonFaroError)"
        case .rootNodeNotFound(json: let json):
            return "📡🔥 Could not find root node in json:\n \(json)"
        case .networkError(statusCode: let networkError, data:let data , call: let call):
            if let data = data {
                guard var string = String(data: data, encoding: .utf8), (string.hasPrefix("{") || string.hasPrefix("[")) else {
                    return "📡🔥 HTTP error: \(networkError) no message in utf8 format. \(call)"
                }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    string = String(data: prettyPrintedData, encoding: .utf8) ?? "Invalid json"
                } catch {
                    // ignore
                }

                return "📡🔥 HTTP error: \(networkError) \nmessage: \(string)\ncall:\(call)"
            } else {
                return "📡🔥 HTTP error: \(networkError)\ncall\(call)"
            }
        case .emptyCollection:
            return "📡🔥 empty collection"
        case .emptyKey:
            return "📡🔥 missing key"
        case .emptyValue(let key):
            return "❓no value for key " + key
        case .malformed(let info):
            return "📡🔥 \(info)"
        case .serializationError:
            return "📡🔥 serialization error"
        case .updateNotPossible(json: let json, model: let model):
            return "❓ update not possilbe with \(json) on model \(model)"
        case .invalidSession(message: let message):
            return "💀 you tried to perform a request on a session that is invalid.\n💀 message: \(message)"
        }
    }
}

public func == (lhs: FaroError, rhs: FaroError) -> Bool {
    switch (lhs, rhs) {
    case (.general, .general):
        return true
    case (.invalidAuthentication, .invalidAuthentication):
        return true
    case (.invalidUrl(let url_lhs), .invalidUrl(let url_rhs)): // tailor:disable
        return url_lhs == url_rhs
    case (.invalidResponseData (_), .invalidResponseData (_)):
        return true
    case (.networkError(statusCode: let lStatusCode, data: _, call: _ ), .networkError(statusCode: let rStatusCode, data: _, call: _)):
        return lStatusCode == rStatusCode
    default:
        return false
    }
}
