public enum Parameter: CustomDebugStringConvertible {
	case httpHeader([String: String])
	case jsonArray([[String: Any]])
	case jsonNode([String: Any])
	case urlComponents([String: String])

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
		}
	}
}
