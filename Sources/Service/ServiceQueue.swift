//
//  ServiceQueue.swift
//  Pods
//
//  Created by Stijn Willems on 20/04/2017.
//
//

import Foundation

open class ServiceQueue {

    var taskQueue: Set<URLSessionDataTask>
    var failedTasks: Set<URLSessionTask>?

    let configuration: Configuration
    let faroSession: FaroQueueSessionable

    private let final: (_ failedTasks: Set<URLSessionTask>?)->()

    /// Creates a queue that lasts until final is called. When all request in the queue are finished the session becomes invalid.
    /// For future queued request you have to create a new DeprecatedServiceQueue instance.
    /// - parameter configuration: Faro service configuration
    /// - parameter faroSession: You can provide a custom `URLSession` via `FaroQueueSession`.
    /// - parameter final: closure is callen when all requests are performed.
	public init (_ configuration: Configuration, faroSession: FaroQueueSessionable = FaroQueueSession(), final: @escaping(_ failedTasks: Set<URLSessionTask>?)->()) {

        taskQueue = Set<URLSessionDataTask>()
        self.final = final
		self.configuration = configuration
        self.faroSession = faroSession
	}

    /// Gets a model(s) from the service and decodes it using native `Decodable` protocol.
    /// Provide a type, that can be an array, to decode the data received from the service into type 'M'
    /// - parameter type: Generic type to decode the returend data to. If service returns no response data use type `Service.NoResponseData`
    @discardableResult
    open func perform<M>(_ type: M.Type, call: Call, autoStart: Bool = false, complete: @escaping(@escaping () throws -> (M)) -> Void) -> URLSessionDataTask?  where M: Decodable {
        guard let request = call.request(with: configuration) else {
            complete {
                let error = FaroError.invalidUrl("\(self.configuration.baseURL)/\(call.path)", call: call)
                self.handleError(error)
                throw error
            }
            return nil
        }

        var task: URLSessionDataTask?
        task = faroSession.dataTask(with: request, completionHandler: {[weak self] (data, response, error) in
            guard let task = task else {
                let error = FaroError.invalidSession(message: "Task should never be nil!", request: request)
                self?.handleError(error)
                self?.invalidateAndCancel()
                complete {throw error}
                return
            }

            let error = raisesFaroError(data: data, urlResponse: response, error: error, for: request)
            guard error == nil, let strongSelf = self else {
                complete {
                    self?.handleError(error!)
                    self?.cleanupQueue(for: task, didFail: true)
                    self?.shouldCallFinal()
                    throw error!
                }
                return
            }

            guard type.self != Service.NoResponseData.self else {
                complete {
                    // Constructing a no data data with an empty response
                    let data = """
                    {}
                    """.data(using: .utf8)!
                    return try strongSelf.configuration.decoder.decode(M.self, from: data)
                }
                strongSelf.cleanupQueue(for: task, didFail: true)
                strongSelf.shouldCallFinal()
                return
            }

            guard let returnData = data else {
                complete {
                    let error = FaroError.invalidResponseData(data, call: call)
                    strongSelf.handleError(error)
                    strongSelf.cleanupQueue(for: task, didFail: true)
                    strongSelf.shouldCallFinal()
                    throw error
                }
                return
            }
            complete {
                do {
                    let result =  try strongSelf.configuration.decoder.decode(M.self, from: returnData)
                    strongSelf.cleanupQueue(for: task)
                    strongSelf.shouldCallFinal()
                    return result
                } catch let error as DecodingError {
                    let error = FaroError.decodingError(error, inData: returnData, call: call)
                    strongSelf.handleError(error)
                    strongSelf.cleanupQueue(for: task, didFail: true)
                    strongSelf.shouldCallFinal()
                    throw error
                }
            }
        })

        guard autoStart else {
            return task
        }

        // At this point we always have a task, force unwrap is then allowed.
        faroSession.resume(task!)
        return task
    }

    // MARK: - Update model instead of create

    open func performUpdate<M>(on model: M, call: Call, autoStart: Bool = false, complete: @escaping(@escaping () throws -> ()) -> Void) -> URLSessionDataTask?  where M: Decodable & Updatable {
        let task = perform(M.self, call: call, autoStart: autoStart) { (resultFunction) in
            complete {
                let serviceModel = try resultFunction()
                try  model.update(serviceModel)
                return
            }
        }
        return task
    }

    open func performUpdate<M>(on modelArray: [M],call: Call, autoStart: Bool = false, complete: @escaping(@escaping () throws -> ()) -> Void) -> URLSessionDataTask?  where M: Decodable & Updatable {
        let task = perform([M].self, call: call, autoStart: autoStart) { (resultFunction) in
            complete {
                var serviceModels = Set(try resultFunction())
                try modelArray.forEach { element in
                    try element.update(array: Array(serviceModels))
                    serviceModels.remove(element)
                }
                return
            }
        }
        return task
    }

	// MARK: Error

	/// Prints the error and throws it
	/// Possible to override this to have custom behaviour for your app.
	open func handleError(_ error: Error) {
		print(error)
	}

    // MARK: - Interact with tasks

    open var hasOustandingTasks: Bool {
        get {
            return taskQueue.count > 0
        }
    }

    open func resume(_ task: URLSessionDataTask) {
        faroSession.resume(task)
    }

    open func resumeAll() {
        let notStartedTasks = taskQueue.filter { $0.state != .running || $0.state != .completed}
        notStartedTasks.forEach { (task) in
            faroSession.resume(task)
        }
    }

    // MARK: - Private

    private func add(_ task: URLSessionDataTask?) {
        guard let createdTask = task else {
            return
        }
        taskQueue.insert(createdTask)
    }

    private func cleanupQueue(for task: URLSessionDataTask?, didFail: Bool = false) {
        if let task = task {
            let _ = taskQueue.remove(task)
            if(didFail) {
                if failedTasks == nil {
                    failedTasks = Set<URLSessionTask>()
                }
                failedTasks?.insert(task)
            }
        }
    }

    private func shouldCallFinal() {
        if !hasOustandingTasks {
            final(failedTasks)
            faroSession.finishTasksAndInvalidate()
        }
    }

    // MARK: - Invalidate session overrides

    open func invalidateAndCancel() {
        taskQueue.removeAll()
        failedTasks?.removeAll()
        faroSession.invalidateAndCancel()
    }

    deinit {
        faroSession.finishTasksAndInvalidate()
    }

}
