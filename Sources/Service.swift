
public class Service {
    let configuration : Configuration

    public init (configuration : Configuration) {
        self.configuration = configuration
    }
    
    /// You should override this
    public func serve <M : Mappable> (order: Order, result: (Result <M>)->()) {
    }
}