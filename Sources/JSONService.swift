/// Default implementation of a JSON service.
/// Serves your `Order` to a server and parses the respons.
/// Response is delivered to you as a `JSONResult`.
public class JSONService: Service {
    private var task: NSURLSessionDataTask?

    /// Always results in .Success(["key" : "value"])
    /// This will change to a real request in the future
    override public func serve<M: Mappable>(order: Order, result: (Result<M>) -> ()) {

        guard let request = order.objectRequestConfiguration(configuration) else {
            result(.Failure(Error.InvalidUrl("\(configuration.baseURL)/\(order.path)")))
            return
        }

        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request) { [weak self](data, response, error) in
            convertAllThrowsToResult(result) {
                if let data = try self?.checkStatusCodeAndData(data, urlResponse: response, error: error) {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        result(.JSON(json))
                    } catch {
                        result(.Failure(Error.InvalidResponseData(data)))
                    }
                } else {
                    result(.Failure(Error.General))
                }
            }
        }

        task?.resume()
    }

    public func cancel() {
        task?.cancel()
    }

}