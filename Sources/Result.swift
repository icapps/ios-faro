
public enum Result <T: Parseable> {
    case Success(T)
    case Failure
    case NoNetwork    
}