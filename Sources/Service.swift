/// Default implementation of a service.
/// Serves your `Order` to a server and parses the respons.
/// Response is delivered to you as a `Result`. The result type depends on the adaptor you have set in the 'Configuration'.
public class Service {
    public let configuration: Configuration
    private var task: NSURLSessionDataTask?
    public let session = NSURLSession.sharedSession()

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// Performs a `Call` to get a result where the `case` returned depends on the adaptor you provide.
    public func perform<M: Mappable>(call: Call, result: (Result<M>) -> ()) {

        guard let request = call.request(withConfiguration: configuration) else {
            result(.Failure(Error.InvalidUrl("\(configuration.baseURL)/\(call.path)")))
            return
        }

        task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.checkStatusCodeAndData(data, urlResponse: response, error: error) { (dataResult: Result<M>) in
                self.configuration.adaptor.serialize(fromDataResult: dataResult, result: result)
            }
        }

        task!.resume()
    }

    public func cancel() {
        task?.cancel()
    }

    public func checkStatusCodeAndData<M: Mappable>(data: NSData?, urlResponse: NSURLResponse?, error: NSError?, result: (Result<M>) -> ()) {
        guard error == nil else {
            let returnError = Error.ErrorNS(error)
            printError(returnError)
            result(.Failure(returnError))
            return
        }

        guard let httpResponse = urlResponse as? NSHTTPURLResponse else {
            let returnError = Error.General
            printError(returnError)
            result(.Failure(returnError))
            return
        }

        let statusCode = httpResponse.statusCode
        guard statusCode != 404 else {
            let returnError = Error.InvalidAuthentication
            printError(returnError)
            result(.Failure(returnError))
            return
        }

        guard 200...201 ~= statusCode else {
            let returnError = Error.General
            printError(returnError)
            result(.Failure(returnError))
            return
        }

        guard let guardedData = data else {
            result(.OK)
            return
        }

        result(.Data(guardedData))

        return
    }
}