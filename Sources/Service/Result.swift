public enum Result<M: Deserializable> {
    case model(M?)
    case models([M]?)
    /// The server returned a valid JSON response.
    case json(Any)
    case data(Foundation.Data)
    /// Server returned with statuscode 200...201 but no response data. For Example Post
    case ok
    case failure(FaroError)

	public var error: FaroError? {
		switch self {
		case .failure(let error):
			return error
		default:
			return nil
		}
	}

	public var model: M? {
		switch self {
		case .model(let model):
			return model
		default:
			return nil
		}
	}

	public var models: [M]? {
		switch self {
		case .models(let model):
			return model
		default:
			return nil
		}
	}

	public var json: [String: Any]? {
		switch self {
		case .json(let raw):
			return raw as? [String: Any]
		default:
			return nil
		}
	}

}

public enum WriteResult {
    case ok
    case failure(FaroError)

	public var error: FaroError? {
		switch self {
		case .failure(let error):
			return error
		default:
			return nil
		}
	}
	
}

public enum JsonNode {
    case nodeObject([String: Any])
    case nodeArray([Any])
    case nodeNotFound(json: Any)
    case nodeNotSerialized
}
