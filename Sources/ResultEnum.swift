
/// `Result` is used to deliver results mapped in the `Bar`.
public enum Result <M: Mappable> {
    case Model(model : M)
    /// The server returned a valid JSON response.
    case JSON(json : AnyObject)
}