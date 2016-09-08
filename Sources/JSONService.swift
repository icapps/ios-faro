/// Default implementation of a JSON service.
/// Serves your `Order` to a server and parses the respons.
/// Response is delivered to you as a `JSONResult`.
public class JSONService: Service {
    private var task: NSURLSessionDataTask?

    override public func serve<M: Mappable>(order: Order, result: (Result<M>) -> ()) {

        guard let request = order.objectRequestConfiguration(configuration) else {
            result(.Failure(Error.InvalidUrl("\(configuration.baseURL)/\(order.path)")))
            return
        }

        let session = NSURLSession.sharedSession()

        task = session.dataTaskWithRequest(request) { (data, response, error) in
            checkStatusCodeAndData(data, urlResponse: response, error: error) { (dataResult: Result<M>) in
                serializeJSONFromDataResult(dataResult, jsonResult: result)
            }
        }

        guard let task = task else {
            result(.Failure(Error.CreateDataTask))
            return
        }

        task.resume()
    }

    public func cancel() {
        task?.cancel()
    }

}