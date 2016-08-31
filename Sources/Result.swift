
/// `Result` is used to deliver results mapped in the `Bar`.
public enum Result <T: Mappable> {
    case Success(T)
    case Failure
    case NoNetwork    
}