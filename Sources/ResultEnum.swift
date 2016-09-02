
/// `Result` is used to deliver results mapped in the `Bar`.
public enum Result <M: Mappable> {
    case Model(M)
    /// The server returned a valid JSON response.
    case JSON(AnyObject)
    case Failure(ErrorType)
}