public enum Parameter: CustomDebugStringConvertible {
	case httpHeader([String: String])
	case jsonArray([[String: Any]])
	case jsonNode([String: Any])
	case urlComponents([String: String])
	case multipart(MultipartFile)

	public var debugDescription: String {
		switch self {
		case .httpHeader(let headerDict):
			return "\(headerDict.map {(key:$0.key, value: $0.value)}.reduce("• .httpHeader:", {"\($0)\n• \($1)"}))"
		case .jsonArray(let jsonArray):
			do {
				let array = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
				let arrayString = String(data: array, encoding: .utf8)
				return ".jsonArray:\n\(array)"
			} catch {
				return "\(error)"
			}
		case .jsonNode(let jsonNode):
			do {
				let array = try JSONSerialization.data(withJSONObject: jsonNode, options: .prettyPrinted)
				let arrayString = String(data: array, encoding: .utf8)
				return "• .jsonNode:\n\(jsonNode)"
			} catch {
				return "•\(error)"
			}
		case .urlComponents(let components):
			return "\(components.map {(key:$0.key, value: $0.value)}.reduce("• .urlComponents:", {"\($0)\n• \($1)"}))"
		case .multipart(_):
			return ".multipart"
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

	public var isUrlComponents: Bool {
		switch self {
		case .urlComponents(_):
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

	public var urlComponentsValue: [String: String]? {
		switch self {
		case .urlComponents(let components):
			return components
		default:
			return nil
		}
	}
	
}
