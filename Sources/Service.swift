
// MARK: - General Throw Throw Handler

/// This  default function is used to handle and print throws.
/// Provide another throwing function in the init of `Service` to capture throws.
public func faroDefaultThrowHandler(_ handler: ()throws->()) {
	do {
		try handler()
	} catch {
		guard let faroError = error as? FaroError else {
			print(error)
			return
		}
		printFaroError(faroError)
	}
}

// MARK: Service Class implementation

/// Default implementation of a service.
/// Serves your `Call` to a server and parses the respons.
/// Response is delivered to you as a `Result` that you can use in a switch. You get the most detailed results with the functions below.
/// If you want you can use the convenience functions in the extension. They call these functions and print the errors by default. 
/// If you need more control over the errors you can use these functions directly.
/// _Remark_: If you need to cancel, know when everything is done, service request to continue in the background use `ServiceQueue`.
/// _Warning_: The session holds a strong reference to it's delegates. You should invalidate or we do in at `deinit`
open class Service {
    open let configuration: Configuration

    let faroSession: FaroSessionable

	public init(configuration: Configuration, faroSession: FaroSessionable = FaroSession()) {
        self.configuration = configuration
        self.faroSession = faroSession
    }

    // MARK: - UPDATE Model

	/// The other `perform` methods create the model. This function updates the model.
	/// - parameter call: gives the details to find the entity on the server
	/// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
	/// - parameter updateModel: JSON will be given to this model to update
	/// - parameter success: Returns Deserialized array or single model.
	/// - parameter fail: handle any throw that happens. Provide a function that can accept throws but does not rethrow them. In the function implementation you can wrap the function in a do, catch block.
	/// by default this parameter is filled with `faroDefaultThrowHandler`. Take a look at that implementation to implement your own function
	/// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
	/// - throws: any error can be thrown, your own errors inside your modelResult closure or errors from the service. The latter will be of type `FaroError`.
	@discardableResult
	open func perform<M: Deserializable & Updatable>(_ call: Call, on updateModel: M?, autoStart: Bool = true, success: @escaping (Success<M>) throws -> Void, fail: @escaping (()throws ->()) -> () = faroDefaultThrowHandler) throws -> URLSessionDataTask? {

		return try performJsonResult(call, intermediate: { (intermediateResult) in
			switch intermediateResult {
			case .jsonArray(let jsonArray):
				try self.switchToSuccess(self.handleNodeArray(jsonArray, on: updateModel, call: call), success, call: call)
			case .jsonNode(let jsonNode):
				try self.switchToSuccess(self.handleNode(jsonNode, on: updateModel, call: call), success, call: call)
			}

		})
	}

    // MARK: - CREATE Model

	/// On success create a model and updates it with the received JSON data.
	/// - parameter call: gives the details to find the entity on the server
	/// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
	/// - parameter modelResult : `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure. It can contain throwing functions. If something is thrown in the closure it it printed.
	/// - parameter throwHandler: handle any throw that happens. Provide a function that can accept throws but does not rethrow them. In the function implementation you can wrap the function in a do, catch block.
	/// by default this parameter is filled with `faroDefaultThrowHandler`. Take a look at that implementation to implement your own function
	/// - returns: URLSessionDataTask if it does not throw
	/// - throws: any error can be thrown, your own errors inside your modelResult closure or errors from the service. The latter will be of type `FaroError`.
	/**
	Example implementation of throwHandler
	```
	public func faroDefaultThrowHandler(_ handler: ()throws->()) {
		do {
			try handler()
		} catch {
			guard let faroError = error as? FaroError else {
				print(error)
			return
			}
			printFaroError(faroError)
		}
	}
	```
	**/
	@discardableResult
	open func perform<M: Deserializable>(_ call: Call, autoStart: Bool = true, success: @escaping (Success<M>) throws -> Void, fail: @escaping (()throws ->()) -> () = faroDefaultThrowHandler) throws -> URLSessionDataTask {

		return try performJsonResult(call, intermediate: { (intermediate) in
			fail {
				let result: Result<M> = self.handle(json: intermediate.json(), call: call)
				try self.switchToSuccess(result, success, call: call)
			}
		})
	}

    // MARK: - Paging information

	/// On success create a model and updates it with the received JSON data. The JSON is also passed to `page` closure and can be inspected for paging information.
	/// - parameter call: gives the details to find the entity on the server
	/// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
	/// - parameter success : `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure. It can contain throwing functions. If something is thrown in the closure it it printed.
	/// - parameter fail: handle any throw that happens. Provide a function that can accept throws but does not rethrow them. In the function implementation you can wrap the function in a do, catch block.
	/// by default this parameter is filled with `faroDefaultThrowHandler`. Take a look at that implementation to implement your own function
	/// - returns: URLSessionDataTask if it does not throw
	/// - throws: any error can be thrown, your own errors inside your modelResult closure or errors from the service. The latter will be of type `FaroError`.
	/**
	Example implementation of throwHandler
	```
	public func faroDefaultThrowHandler(_ handler: ()throws->()) {
		do {
			try handler()
		} catch {
			guard let faroError = error as? FaroError else {
				print(error)
				return
			}
			printFaroError(faroError)
		}
	}
	```
	**/
	@discardableResult
	open func perform<M: Deserializable, P: Deserializable>(_ call: Call, page: @escaping(P?)->(),  autoStart: Bool = true, success: @escaping (Success<M>) throws -> (), fail: @escaping (()throws ->()) -> () = faroDefaultThrowHandler) throws -> URLSessionDataTask {

		return try performJsonResult(call, intermediate: { intermediate in
			fail {
				let result: Result<M> = self.handle(json: intermediate.json(), call: call)
				try self.switchToSuccess(result, success, call: call)
				page(P(from: intermediate.json()))
			}

		})
	}

	/// Use this to write to the server when you do not need a data result, just ok.
	/// If you expect a data result use `perform(call:result:)`
	/// - parameter call: should be of a type that does not expect data in the result.
	/// - parameter writeResult: `WriteResult` closure should be called with `.ok` other cases are a failure. It can contain throwing functions. If something is thrown in the closure it it printed.
	/// - parameter throwHandler: handle any throw that happens. Provide a function that can accept throws but does not rethrow them. In the function implementation you can wrap the function in a do, catch block.
	/// by default this parameter is filled with `faroDefaultThrowHandler`. Take a look at that implementation to implement your own function
	/// - returns: URLSessionDataTask if it does not throw
	/// - throws: any error can be thrown, your own errors inside your modelResult closure or errors from the service. The latter will be of type `FaroError`.
	/**
	Example implementation of throwHandler
	```
	public func faroDefaultThrowHandler(_ handler: ()throws->()) {
		do {
			try handler()
		} catch {
			guard let faroError = error as? FaroError else {
				print(error)
				return
			}
			printFaroError(faroError)
		}
	}
	```
	**/
	@discardableResult
	open func performWrite(_ writeCall: Call, autoStart: Bool = true, success: @escaping (WriteSuccess) throws -> (), fail: @escaping (()throws ->()) -> () = faroDefaultThrowHandler) throws -> URLSessionDataTask {

		guard let request = writeCall.request(withConfiguration: configuration) else {
			throw FaroError.invalidUrl("\(configuration.baseURL)/\(writeCall.path)")
		}

		let task = faroSession.dataTask(with: request, completionHandler: { (data, response, error) in
			fail {
				if let faroError = self.raisesFaroError(data: data, urlResponse: response, error: error) {
					throw faroError
				}
				try success(.ok)
			}
		})

		guard autoStart else {
			return task
		}

		faroSession.resume(task)
		return task
	}

    // MARK: - INTERMEDIATE Results - Like json

	/// Handles incomming data and tries to parse the data as JSON.
	/// - parameter call: gives the details to find the entity on the server
	/// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
	/// - parameter success: closure is called when a valid array or node is received.
	/// - parameter fail: handle any throw that happens. Provide a function that can accept throws but does not rethrow them. In the function implementation you can wrap the function in a do, catch block.
	/// by default this parameter is filled with `faroDefaultThrowHandler`. Take a look at that implementation to implement your own function
	/// - returns: URLSessionDataTask if it does not throw
	/// - throws: any error can be thrown, your own errors inside your modelResult closure or errors from the service. The latter will be of type `FaroError`.
	/**
	Example implementation of throwHandler
	```
	public func faroDefaultThrowHandler(_ handler: ()throws->()) {
		do {
			try handler()
		} catch {
			guard let faroError = error as? FaroError else {
				print(error)
			return
			}
			printFaroError(faroError)
		}
	}
	```
	**/
	@discardableResult
	open func performJsonResult(_ call: Call, autoStart: Bool = true, intermediate: @escaping (Intermediate) throws -> (), fail: @escaping (()throws ->()) -> () = faroDefaultThrowHandler) throws -> URLSessionDataTask {

		guard let request = call.request(withConfiguration: configuration) else {
			throw FaroError.invalidUrl("\(configuration.baseURL)/\(call.path)")
		}

		let task = faroSession.dataTask(with: request, completionHandler: { (data, response, error) in
			fail {
				if let error = self.raisesFaroError(data: data, urlResponse: response, error: error) {
					throw error
				}

				guard let dataResult = data else {
					throw FaroError.invalidResponseData(data)
				}

				try self.configuration.adaptor.serialize(dataResult, intermediate: intermediate)
			}

		})

		guard autoStart else {
			return task
		}

		faroSession.resume(task)
		return task
	}

	/// TODO: Not explicitaly deprecated but can be removed soon.
	/// Handles incomming data and tries to parse the data as JSON.
	/// - parameter call: gives the details to find the entity on the server
	/// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
	/// - parameter jsonResult: closure is called when valid or invalid json data is received.
	/// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
	@discardableResult
	open func performJsonResult<M: Deserializable>(_ call: Call, autoStart: Bool = true, jsonResult: @escaping (Result<M>) -> ()) -> URLSessionDataTask? {

		guard let request = call.request(withConfiguration: configuration) else {
			jsonResult(.failure(FaroError.invalidUrl("\(configuration.baseURL)/\(call.path)")))
			return nil
		}

		let task = faroSession.dataTask(with: request, completionHandler: { (data, response, error) in
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

		guard autoStart else {
			return task
		}

		faroSession.resume(task)
		return task
	}

	// MARK: - WRITE calls (like .POST, .PUT, ...)

	// TODO: will become deprecated soon.
	/// Use this to write to the server when you do not need a data result, just ok.
	/// If you expect a data result use `perform(call:result:)`
	/// - parameter call: should be of a type that does not expect data in the result.
	/// - parameter writeResult: `WriteResult` closure should be called with `.ok` other cases are a failure.
	/// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
	@discardableResult
	open func performWrite(_ writeCall: Call, autoStart: Bool = true, writeResult: @escaping (WriteResult) -> ()) -> URLSessionDataTask? {

		guard let request = writeCall.request(withConfiguration: configuration) else {
			writeResult(.failure(FaroError.invalidUrl("\(configuration.baseURL)/\(writeCall.path)")))
			return nil
		}

		let task = faroSession.dataTask(with: request, completionHandler: { (data, response, error) in
			writeResult(self.handleWrite(data: data, urlResponse: response, error: error))
		})

		guard autoStart else {
			return task
		}

		faroSession.resume(task)
		return task
	}

    // MARK: - Handles

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

    // MARK: - Invalidate session
    /// All functions are forwarded to `FaroSession`

    open func finishTasksAndInvalidate() {
        faroSession.finishTasksAndInvalidate()
    }

    open func flush(completionHandler: @escaping () -> Void) {
        faroSession.flush(completionHandler: completionHandler)
    }

    open func getTasksWithCompletionHandler(_ completionHandler: @escaping ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) -> Void) {
        faroSession.getTasksWithCompletionHandler(completionHandler)
    }

    open func invalidateAndCancel() {
        faroSession.invalidateAndCancel()
    }

    open func reset(completionHandler: @escaping () -> Void) {
        faroSession.reset(completionHandler: completionHandler)
    }

    deinit {
        faroSession.finishTasksAndInvalidate()
    }

}

// MARK: - Privates

extension Service {

	fileprivate func switchToSuccess<M: Deserializable> (_ oldResult: Result<M>, _ success:  @escaping (Success<M>) throws -> (), call: Call) throws {
		switch oldResult {
		case .models(let models):
			guard let models = models else {
				throw FaroError.emptyResponse(call)
			}
			try success(.array(models))
		case .model(let model):
			guard let model = model else {
				throw FaroError.emptyResponse(call)
			}
			try success(.single(model))
		case .failure(let error):
			throw error
		default:
			throw FaroError.invalidInterMediateResult(call)
		}
	}

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


    fileprivate func handleNodeArray<M: Deserializable>(_ nodes: [Any], on updateModel: M? = nil, call: Call) -> Result<M> {
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

    fileprivate func handleNode<M: Deserializable>(_ node: [String: Any], on updateModel: M? = nil, call: Call) -> Result<M> {
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

// MARK: - Deprecated functions
extension Service {
	// MARK: - Update

	/// The other `perform` methods create the model. This function updates the model.
	/// - parameter call: gives the details to find the entity on the server
	/// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
	/// - parameter updateModel: JSON will be given to this model to update
	/// - parameter modelResult: `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
	/// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
	@available(*, deprecated: 1.7, obsoleted: 2.0, message: "You should use the `perform` functions in `Service` throwing variants")
	@discardableResult
	open func perform<M: Deserializable & Updatable>(_ call: Call, on updateModel: M?, autoStart: Bool = true, modelResult: @escaping (Result<M>) -> ()) -> URLSessionDataTask? {

		return performJsonResult(call, autoStart: autoStart) { (jsonResult: Result<M>) in
			switch jsonResult {
			case .json(let json):
				modelResult(self.handle(json: json, on: updateModel, call: call))
			default:
				modelResult(jsonResult)
				break
			}
		}
	}

	/// On success create a model and updates it with the received JSON data.
	/// - parameter call: gives the details to find the entity on the server
	/// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
	/// - parameter modelResult : `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
	/// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
	@available(*, deprecated: 1.7, obsoleted: 2.0, message: "You should use the `perform` functions in `Service` throwing variants")
	@discardableResult
	open func perform<M: Deserializable>(_ call: Call, autoStart: Bool = true, modelResult: @escaping (Result<M>) -> ()) -> URLSessionDataTask? {

		return performJsonResult(call, autoStart: autoStart) { (jsonResult: Result<M>) in
			switch jsonResult {
			case .json(let json):
				modelResult(self.handle(json: json, call: call))
			default:
				modelResult(jsonResult)
				break
			}
		}
	}

	/// On success create a model and updates it with the received JSON data. The JSON is also passed to `page` closure and can be inspected for paging information.
	/// - parameter call: gives the details to find the entity on the server
	/// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
	/// - parameter modelResult : `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
	/// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
	@available(*, deprecated: 1.7, obsoleted: 2.0, message: "You should use the `perform` functions in `Service` throwing variants")
	@discardableResult
	open func perform<M: Deserializable, P: Deserializable>(_ call: Call, page: @escaping(P?)->(),  autoStart: Bool = true, modelResult: @escaping (Result<M>) -> ()) -> URLSessionDataTask? {

		return performJsonResult(call, autoStart: autoStart) { (jsonResult: Result<M>) in
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

}
