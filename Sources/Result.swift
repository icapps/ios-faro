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
}

public enum JsonNode {
    case nodeObject([String: Any?])
    case nodeArray([Any])
    case nodeNotFound(json: Any)
    case nodeNotSerialized
}
