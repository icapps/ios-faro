/// `Result` is used to deliver results mapped in the `Bar`.
public enum Result<M: Mappable> {
    case Model(M)
    /// The server returned a valid JSON response.
    case JSON(AnyObject)
    case Data(NSData)
    /// Server returned with statuscode 200...201 but no response data
    case OK
    case Failure(Error)
}

