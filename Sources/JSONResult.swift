
public enum JSONResult {
    /// The server returned a valid JSON response.
    case Success(AnyObject)
    /// Something went wrong  
    case Failure
}