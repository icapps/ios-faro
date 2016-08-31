
public class JSONService: JSONServeable {

    /// Always results in .Success(["key" : "value"])
    /// This will change to a real request in the future
    
    public func serve(order: Order, result: (JSONResult) -> ()) {
        //TODO: make this perform a real request
        result(.Success(["key": "value"]))
    }
}