
// MARK: - Convenience methods

/// The perform methods are preferred but these methods are for convienience.
/// They do some default error handling.
extension Service {

    /// Performs the call to the server. Provide a model
    /// - parameter call: where can the server be found?
    /// - parameter fail: if we cannot initialize the model this call will fail and print the failure.
    /// - parameter ok: returns initialized model
    open func performUpdate<ModelType: Deserializable & Updatable>(_ call: Call, on updateModel: ModelType, fail: @escaping (FaroError)->(), ok:@escaping (ModelType)->()) {

        perform(call, on: updateModel) { (result) in
            switch result {
            case .model(let model):
                guard let model = model else {
                    let faroError = FaroError.malformed(info: "UpdateModel \(updateModel) could not be updated. Maybe you did not implement update correctly failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(model)
            default:
                self.handle(result, and: fail)
            }
        }
    
    }
    /// Performs the call to the server. Provide a model
    /// - parameter call: where can the server be found?
    /// - parameter fail: if we cannot initialize the model this call will fail and print the failure.
    /// - parameter ok: returns initialized model
    open func performSingle<ModelType: Deserializable>(_ call: Call, fail: @escaping (FaroError)->(), ok:@escaping (ModelType)->()) {
        perform(call) { (result: Result<ModelType>) in
            switch result {
            case .model(let model):
                guard let model = model else {
                    let faroError = FaroError.malformed(info: "Model could not be initialized. Maybe your init(from raw:) failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(model)
            default:
                self.handle(result, and: fail)
            }
        }
    }

    /// Performs the call to the server. Provide a model
    /// - parameter call: where can the server be found?
    /// - parameter fail: if we cannot initialize the model this call will fail and print the failure.
    /// - parameter ok: returns initialized array of models
    open func performCollection<ModelType: Deserializable>(_ call: Call, fail: @escaping (FaroError)->(), ok:@escaping ([ModelType])->()) {
        perform(call) { (result: Result<ModelType>) in
            switch result {
            case .models(let models):
                guard let models = models else {
                    let faroError = FaroError.malformed(info: "Model could not be initialized. Maybe your init(from raw:) failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(models)
            default:
                self.handle(result, and: fail)
            }
        }
    }

    open func performSingle<ModelType: Deserializable, PagingType: Deserializable>(_ call: Call, page: @escaping(PagingType?)->(), fail: @escaping (FaroError)->(), ok:@escaping (ModelType)->()) {
        perform(call, page: page) { (result: Result<ModelType>) in
            switch result {
            case .model(let model):
                guard let model = model else {
                    let faroError = FaroError.malformed(info: "Model could not be initialized. Maybe your init(from raw:) failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(model)
            default:
                self.handle(result, and: fail)
            }
        }
    }

    open func performCollection<ModelType: Deserializable, PagingType: Deserializable>(_ call: Call, page: @escaping(PagingType?)->(), fail: @escaping (FaroError)->(), ok:@escaping ([ModelType])->()) {
        perform(call, page: page) { (result: Result<ModelType>) in
            switch result {
            case .models(let models):
                guard let models = models else {
                    let faroError = FaroError.malformed(info: "Models could not be initialized. Maybe your init(from raw:) failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(models)
            default:
                self.handle(result, and: fail)
            }
        }
    }

    fileprivate func print(_ error: FaroError, and fail: (FaroError)->()) {
        printFaroError(error)
        fail(error)
    }

}

// MARK: Class implementation

/// Default implementation of a service.
/// Serves your `Call` to a server and parses the respons.
/// Response is delivered to you as a `Result` that you can use in a switch. You get the most detailed results with the functions below.
/// If you want you can use the convinience func in the extension. They call these functions but avoid the switch at the end.
open class Service {
    open let configuration: Configuration
    fileprivate var task: URLSessionDataTask?
    open var session: FaroSession = FaroURLSession()

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// - parameter call: gives the details to find the entity on the server
    /// - parameter updateModel: JSON will be given to this model to update
    /// - parameter modelResult: `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
    open func perform<M: Deserializable & Updatable>(_ call: Call, on updateModel: M?, modelResult: @escaping (Result<M>) -> ()) {

        performJsonResult(call) { (jsonResult: Result<M>) in
            switch jsonResult {
            case .json(let json):
                modelResult(self.handle(json: json, on: updateModel, call: call))
            default:
                modelResult(jsonResult)
                break
            }
        }
    }

    /// - parameter call : gives the details to find the entity on the server
    /// - parameter modelResult : `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
    open func perform<M: Deserializable>(_ call: Call, modelResult: @escaping (Result<M>) -> ()) {

        performJsonResult(call) { (jsonResult: Result<M>) in
            switch jsonResult {
            case .json(let json):
                modelResult(self.handle(json: json, call: call))
            default:
                modelResult(jsonResult)
                break
            }
        }
    }

    open func perform<M: Deserializable, P: Deserializable>(_ call: Call, page: @escaping(P?)->(), modelResult: @escaping (Result<M>) -> ()) {

        performJsonResult(call) { (jsonResult: Result<M>) in
            switch jsonResult {
            case .json(let json):
                modelResult(self.handle(json: json, call: call))
                page(P(from: json))
            default:
                modelResult(jsonResult)
                break
            }
        }
    }


    open func performJsonResult<M: Deserializable>(_ call: Call, jsonResult: @escaping (Result<M>) -> ()) {

        guard let request = call.request(withConfiguration: configuration) else {
            jsonResult(.failure(FaroError.invalidUrl("\(configuration.baseURL)/\(call.path)")))
            return
        }

        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            let dataResult = self.handle(data: data, urlResponse: response, error: error) as Result<M>

            switch dataResult {
            case .data(let data):
                self.configuration.adaptor.serialize(from: data) { (serializedResult: Result<M>) in
                    switch serializedResult {
                    case .json(json: let json):
                        jsonResult(.json(json))
                    default:
                        jsonResult(serializedResult)
                    }
                }
            default:
                jsonResult(dataResult)
            }

        })

        session.resume()
    }
    /// Use this to write to the server when you do not need a data result, just ok.
    /// If you expect a data result use `perform(call:result:)`
    /// - parameter call: should be of a type that does not expect data in the result.
    /// - parameter result : `WriteResult` closure should be called with `.ok` other cases are a failure.
    open func performWrite(_ writeCall: Call, modelResult: @escaping (WriteResult) -> ()) {

        guard let request = writeCall.request(withConfiguration: configuration) else {
            modelResult(.failure(FaroError.invalidUrl("\(configuration.baseURL)/\(writeCall.path)")))
            return
        }

        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            modelResult(self.handleWrite(data: data, urlResponse: response, error: error))
        })

        session.resume()
    }


    open func cancel() {
        task?.cancel()
    }

    open func handleWrite(data: Data?, urlResponse: URLResponse?, error: Error?) -> WriteResult {
        if let faroError = raisesFaroError(data: data, urlResponse: urlResponse, error: error) {
            return .failure(faroError)
        }

        return .ok
    }

    open func handle<M: Deserializable>(data: Data?, urlResponse: URLResponse?, error: Error?) -> Result<M> {

        if let faroError = raisesFaroError(data: data, urlResponse: urlResponse, error: error) {
            return .failure(faroError)
        }

        if let data = data {
            return .data(data)
        } else {
            return .ok
        }
    }

    open func handle<M: Deserializable>(json: Any, on updateModel: M? = nil, call: Call) -> Result<M> {

        let rootNode = call.rootNode(from: json)
        switch rootNode {
        case .nodeObject(let node):
            return handleNode(node, on: updateModel, call: call)
        case .nodeArray(let nodes):
            return handleNodeArray(nodes, on: updateModel, call: call)
        case .nodeNotFound(let json):
            return Result.failure(.rootNodeNotFound(json: json))
        case .nodeNotSerialized:
            return Result.failure(.serializationError)
        }
    }

    private func handleNodeArray<M: Deserializable>(_ nodes: [Any], on updateModel: M? = nil, call: Call) -> Result<M> {
        if let _ = updateModel {
            let faroError = FaroError.malformed(info: "Could not parse \(nodes) for type \(M.self) into updateModel \(updateModel). We currently only support updating of single objects. An arry of objects was returned")
            printFaroError(faroError)
            return Result.failure(faroError)
        }
        var models = [M]()
        for node in nodes {
            if let model = M(from: node) {
                models.append(model)
            } else {
                let faroError = FaroError.malformed(info: "Could not parse \(nodes) for type \(M.self)")
                printFaroError(faroError)
                return Result.failure(faroError)
            }
        }
        return Result.models(models)
    }

    private func handleNode<M: Deserializable>(_ node: [String: Any], on updateModel: M? = nil, call: Call) -> Result<M> {
        if let updateModel = updateModel as? Updatable {
            do {
                try             updateModel.update(from: node)
            }catch {
                return Result.failure(.nonFaroError(error))
            }
            return Result.model(updateModel as? M)
        } else {
            if let _ = updateModel {
                let faroError = FaroError.malformed(info: "An updateModel \(updateModel) was provided. But does not conform to protocol \(Updatable.self)")
                printFaroError(faroError)
            }
            return Result.model(M(from: node))
        }
    }

}

// MARK: - Privates

extension Service {
    fileprivate func raisesFaroError(data: Data?, urlResponse: URLResponse?, error: Error?)-> FaroError? {
        guard error == nil else {
            let returnError = FaroError.nonFaroError(error!)
            printFaroError(returnError)
            return returnError
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            let returnError = FaroError.networkError(0, data: data)
            printFaroError(returnError)
            return returnError
        }

        let statusCode = httpResponse.statusCode
        guard statusCode < 400 else {
            let returnError = FaroError.networkError(statusCode, data: data)
            printFaroError(returnError)
            return returnError
        }

        guard 200...204 ~= statusCode else {
            let returnError = FaroError.networkError(statusCode, data: data)
            printFaroError(returnError)
            return returnError
        }

        return nil
    }

    fileprivate func handle<ModelType: Deserializable>(_ result: Result<ModelType>, and fail: (FaroError)->()) {
        switch result {
        case .failure(let faroError):
            print(faroError, and: fail)
        default:
            let faroError = FaroError.general
            printFaroError(faroError)
            fail(faroError)
        }
    }
}
