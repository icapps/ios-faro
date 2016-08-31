
public enum Delivery <T> {
    case Success(T)
    case Failure
    case NoNetwork    
}