
public enum ResultError: Error {
	case noArray
	case noSingle
}
/// `Result` is used to deliver results mapped in the `Bar`.
public enum Result<M: Deserializable> {
    case model(M?)
    case models([M]?)
    /// The server returned a valid JSON response.
    case json(Any)
    case data(Foundation.Data)
    /// Server returned with statuscode 200...201 but no response data. For Example Post
    case ok
    case failure(FaroError)

	public func arrayModels() throws -> [M] {
		switch self {
		case .models(let models):
			guard let models = models else {
				throw ResultError.noArray
			}
			return models
		default:
			throw ResultError.noArray
		}
	}

	public func singleModel() throws -> M {
		switch self {
		case .model(let model):
			guard let model = model else {
				throw ResultError.noArray
			}
			return model
		default:
			throw ResultError.noArray
		}
	}
}

public enum WriteResult {
    case ok
    case failure(FaroError)
}

public enum JsonNode {
    case nodeObject([String: Any])
    case nodeArray([Any])
    case nodeNotFound(json: Any)
    case nodeNotSerialized
}

// MARK: - Success Results

public enum Success<M: Deserializable> {
	case single(M)
	case array([M])

	public func arrayModels() throws -> [M] {
		switch self {
		case .array(let array):
			return array
		default:
			throw ResultError.noArray
		}
	}

	public func singleModel() throws -> M {
		switch self {
		case .single(let model):
			return model
		default:
			throw ResultError.noArray
		}
	}
}

public enum Intermediate {
	case jsonArray([[String: Any]])
	case jsonNode([String: Any])

	func json() -> Any {
		switch self {
		case .jsonArray(let array):
			return array
		case .jsonNode(let node):
			return node
		}
	}
}
public enum WriteSuccess {
	case ok
	case jsonNode([String: Any])
	case jsonArray([[String: Any]])
}
