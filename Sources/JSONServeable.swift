
public class Service {
    public init () {
    }
    /// You should override this
    public func serve <M : Mappable> (order: Order, result: (Result <M>)->()) {
    }
}