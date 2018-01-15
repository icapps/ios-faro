public enum Parameter: CustomDebugStringConvertible {

	// MARK: - Header
	case httpHeader([String: String])

	// MARK: - To be inserted in Body

	case jsonArray([[String: Any]])
	case jsonNode([String: Any])
	case urlComponentsInBody([String: String])
    case encodedData(Data)

	// MARK: - To be added to url

	case urlComponentsInURL([String: String])

	// MARK: - File

	case multipart(MultipartFile)

	// MARK: - Debug helper

	public var debugDescription: String {
		switch self {
		case .httpHeader(let headerDict):
			return "\(headerDict.map {(key:$0.key, value: $0.value)}.reduce("• .httpHeader:", {"\($0)\n• \($1)"}))"
		case .jsonArray(let jsonArray):
			do {
				let array = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
				let arrayString = String(data: array, encoding: .utf8)
				return ".jsonArray:\n\(arrayString ?? "No data")"
			} catch {
				return "\(error)"
			}
		case .jsonNode(let jsonNode):
			do {
				let array = try JSONSerialization.data(withJSONObject: jsonNode, options: .prettyPrinted)
				let arrayString = String(data: array, encoding: .utf8)
				return "• .jsonNode:\n\(arrayString ?? "No data")"
			} catch {
				return "•\(error)"
			}
		case .urlComponentsInURL(let components):
			return "\(components.map {(key:$0.key, value: $0.value)}.reduce("• .urlComponentsInUrl:", {"\($0)\n• \($1)"}))"
		case .urlComponentsInBody(let components):
			return "\(components.map {(key:$0.key, value: $0.value)}.reduce("• .urlComponentsInBody:", {"\($0)\n• \($1)"}))"
		case .multipart(_):
			return ".multipart"
        case .encodedData(let data):
            do {
                let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                let string = String(data: json, encoding: .utf8)
                return "• .bodyData:\n\(string ?? "no data")"
            } catch {
                return "• .bodyData:\n\(String(data: data, encoding: .utf8) ?? "no data")"
            }
		}
	}

	// MARK: - Logic

	public var isHeader: Bool {
		switch self {
		case .httpHeader(_):
			return true
		default:
			return false
		}
	}

	public var isJSONArray: Bool {
		switch self {
		case .jsonArray(_):
			return true
		default:
			return false
		}
	}

	public var isJSONNode: Bool {
		switch self {
		case .jsonNode(_):
			return true
		default:
			return false
		}
	}

	public var isUrlComponentsInURL: Bool {
		switch self {
		case .urlComponentsInURL(_):
			return true
		default:
			return false
		}
	}

	public var isUrlComponentsInBody: Bool {
		switch self {
		case .urlComponentsInBody(_):
			return true
		default:
			return false
		}
	}

	// MARK: - Values

	public var httpHeaderValue: [String: String]? {
		switch self {
		case .httpHeader(let header):
			return header
		default:
			return nil
		}
	}

	public var jsonArrayValue: [[String: Any]]? {
		switch self {
		case .jsonArray(let json):
			return json
		default:
			return nil
		}
	}

	public var jsonNodeValue: [String: Any]? {
		switch self {
		case .jsonNode(let node):
			return node
		default:
			return nil
		}
	}

	public var urlComponentsInURLValue: [String: String]? {
		switch self {
		case .urlComponentsInURL(let components):
			return components
		default:
			return nil
		}
	}

	public var urlComponentsInBodyValue: [String: String]? {
		switch self {
		case .urlComponentsInBody(let components):
			return components
		default:
			return nil
		}
	}
	
}
