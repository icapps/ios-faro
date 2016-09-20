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
    /// - parameter result : `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
    open func perform<M: Deserializable>(_ call: Call, result: @escaping (Result<M>) -> ()) {

        guard let request = call.request(withConfiguration: configuration) else {
            result(.failure(FaroError.invalidUrl("\(configuration.baseURL)/\(call.path)")))
            return
        }

        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            let dataResult = self.handle(data: data, urlResponse: response, error: error) as Result<M>

            switch dataResult {
            case .data(let data):
                self.configuration.adaptor.serialize(from: data) { (jsonResult: Result<M>) in
                    switch jsonResult {
                    case .json(json: let json):
                        result(self.handle(json: json, call: call))
                    default:
                        result(jsonResult)
                    }
                }
            default:
                result(dataResult)
            }

        })


        task!.resume()
    }

    open func cancel() {
        task?.cancel()
    }

    open func handle<M: Deserializable>(data: Data?, urlResponse: URLResponse?, error: Error?) -> Result<M> {
        guard error == nil else {
            let returnError = FaroError.nonFaroError(error!)
            printError(returnError)
            return .failure(returnError)
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            let returnError = FaroError.general
            printError(returnError)
            return .failure(returnError)
        }

        let statusCode = httpResponse.statusCode
        guard statusCode < 400 else {
            let returnError = FaroError.networkError(statusCode)
            printError(returnError)
            return .failure(returnError)
        }

        guard 200...201 ~= statusCode else {
            let returnError = FaroError.general
            printError(returnError)
            return .failure(returnError)
        }

        if let data = data {
            return .data(data)
        } else {
            return .ok
        }
    }

    open func handle<M: Deserializable>(json: Any, call: Call) -> Result<M> {

        let rootNode = call.rootNode(from: json)
        switch rootNode {
        case .nodeObject(let node):
            return Result.model(M(from: node))
        case .nodeArray(let nodes):
            var models = [M]()
            for node in nodes {
                if let model = M(from: node) {
                    models.append(model)
                } else {
                    print("💣 could not parse \(node)")
                }
            }
            return Result.models(models)
        case .nodeNotFound(let json):
            return Result.failure(.rootNodeNotFound(json: json))
        case .nodeNotSerialized:
            return Result.failure(.serializationError)
        }
    }
}
