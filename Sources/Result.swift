/// `Result` is used to deliver results mapped in the `Bar`.
public enum Result<M: Parseable> {
    case model(M?)
    case models([M]?)
    /// The server returned a valid JSON response.
    case json(Any)
    case data(Foundation.Data)
    /// Server returned with statuscode 200...201 but no response data
    case ok
    case failure(FaroError)
}

