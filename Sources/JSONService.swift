
/// Default implementation of a JSON service.
/// Serves your `Order` to a server and parses the respons.
/// Response is delivered to you as a `JSONResult`.
public class JSONService : Service {
    /// Always results in .Success(["key" : "value"])
    /// This will change to a real request in the future
    override public func serve <M : Mappable> (order: Order, result: (Result<M>) -> ()) {
        result(.JSON(json:["key": "value"]))

    }
}