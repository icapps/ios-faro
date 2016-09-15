/// Default implementation of a service.
/// Serves your `Order` to a server and parses the respons.
/// Response is delivered to you as a `Result`. The result type depends on the adaptor you have set in the 'Configuration'.
open class Service {
    open let configuration: Configuration
    fileprivate var task: URLSessionDataTask?
    open let session = URLSession.shared

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// Receives expecte result  as defined by the `adaptor` from the a `Service` and maps this to a `Result` case `case Model(M)`
    /// Default implementation expects `adaptor` to be     case JSON(AnyObject). If this needs to be different you need to override this method.
    /// Typ! You can subclass 'Bar' and add a default service
    /// - parameter call : gives the details to find the entity on the server
    /// - parameter result : `Result<M: Parseable>` closure should be called with `case Model(M)` other cases are a failure.
    open func perform<M: Parseable>(_ call: Call, result: @escaping (Result<M>) -> ()) {

        guard let request = call.request(withConfiguration: configuration) else {
            result(.failure(FaroError.invalidUrl("\(configuration.baseURL)/\(call.path)")))
            return
        }

        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.checkStatusCodeAndData(data: data, urlResponse: response, error: error) { (dataResult: Result<M>) in
                self.configuration.adaptor.serialize(fromDataResult: dataResult) { (jsonResult: Result<M>) in
                    switch jsonResult {
                    case .json(json: let json):
                        let model = M(from: json)
                        result(.model(model))
                    default:
                        result(.failure(FaroError.general))
                        print("💣 damn this should not happen")
                    }
                }
            }
        })


        task!.resume()
    }

    open func cancel() {
        task?.cancel()
    }

    open func checkStatusCodeAndData<M: Parseable>(data: Data?, urlResponse: URLResponse?, error: Error?, result: (Result<M>) -> ()) {
        guard error == nil else {
            let returnError = FaroError.nonFaroError(error!)
            printError(returnError)
            result(.failure(returnError))
            return
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            let returnError = FaroError.general
            printError(returnError)
            result(.failure(returnError))
            return
        }

        let statusCode = httpResponse.statusCode
        guard statusCode != 404 else {
            let returnError = FaroError.invalidAuthentication
            printError(returnError)
            result(.failure(returnError))
            return
        }

        guard 200...201 ~= statusCode else {
            let returnError = FaroError.general
            printError(returnError)
            result(.failure(returnError))
            return
        }

        guard let guardedData = data else {
            result(.ok)
            return
        }

        result(.data(guardedData))

        return
    }
}
