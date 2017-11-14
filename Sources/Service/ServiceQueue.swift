//
//  ServiceQueue.swift
//  Pods
//
//  Created by Stijn Willems on 20/04/2017.
//
//

import Foundation

enum ServiceQueueError: Error, CustomDebugStringConvertible {
    case invalidSession(message: String, request: URLRequest)

    var debugDescription: String {
        switch self {
        case .invalidSession(message: let message, request: let request):
            return "📡🔥 you tried to perform a \(request) on a session that is invalid\nmessage: \(message)"
        }
    }
}

open class ServiceQueue {

    var taskQueue: Set<URLSessionDataTask>
    var failedTasks: Set<URLSessionTask>?

    let session: FaroURLSession

    private let final: (_ failedTasks: Set<URLSessionTask>?)->()

    /// Creates a queue that lasts until final is called. When all request in the queue are finished the session becomes invalid.
    /// For future queued request you have to create a new DeprecatedServiceQueue instance.
    /// - parameter session: a session must have a backendConfiguration set.
    /// - parameter final: closure is callen when all requests are performed.
	public init (session: FaroURLSession, final: @escaping(_ failedTasks: Set<URLSessionTask>?)->()) {
        taskQueue = Set<URLSessionDataTask>()
        self.final = final
        self.session = session
	}

    /// Gets a model(s) from the service and decodes it using native `Decodable` protocol.
    /// Provide a type, that can be an array, to decode the data received from the service into type 'M'
    /// - parameter type: Generic type to decode the returend data to. If service returns no response data use type `Service.NoResponseData`
    @discardableResult
    open func perform<M>(_ type: M.Type, call: Call, autoStart: Bool = false, complete: @escaping(@escaping () throws -> (M)) -> Void) -> URLSessionDataTask?  where M: Decodable {
        let config = session.backendConfiguration

        guard let request = call.request(with: config) else {
            complete {
                let error = CallError.invalidUrl("\(config.baseURL)/\(call.path)", call: call)
                self.handleError(error)
                throw error
            }
            return nil
        }

        var task: URLSessionDataTask?
        task = session.session.dataTask(with: request, completionHandler: {[weak self] (data, response, error) in
            guard let task = task else {
                let error = ServiceQueueError.invalidSession(message: "Task should never be nil!", request: request)
                self?.handleError(error)
                self?.invalidateAndCancel()
                complete {throw error}
                return
            }

            let error = raisesServiceError(data: data, urlResponse: response, error: error, for: request)
            guard let `self` = self else {
                print("📡⁉️ \(ServiceQueue.self) was released before all taks completed")
                complete {throw ServiceError.networkError(-1, data: data, request: request)}
                return
            }

            guard error == nil else {
                complete {
                    self.handleError(error)
                    self.cleanupQueue(for: task, didFail: true)
                    self.shouldCallFinal()
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
                    return try config.decoder.decode(M.self, from: data)
                }
                self.cleanupQueue(for: task, didFail: true)
                self.shouldCallFinal()
                return
            }

            guard let returnData = data else {
                complete {
                    let error = ServiceError.invalidResponseData(data, call: call)
                    self.handleError(error)
                    self.cleanupQueue(for: task, didFail: true)
                    self.shouldCallFinal()
                    throw error
                }
                return
            }
            complete {
                do {
                    let result =  try config.decoder.decode(M.self, from: returnData)
                    self.cleanupQueue(for: task)
                    self.shouldCallFinal()
                    return result
                } catch let error as DecodingError {
                    let error = ServiceError.decodingError(error, inData: returnData, call: call)
                    self.handleError(error)
                    self.cleanupQueue(for: task, didFail: true)
                    self.shouldCallFinal()
                    throw error
                }
            }
        })

        // Add task to queue if it could be created

        guard let taskForQueue = task else {
            print("📡⁉️ no task created")
            return nil
        }

        add(taskForQueue)

        guard autoStart else {
            return task
        }

        // At this point we always have a task, force unwrap is then allowed.
        task?.resume()
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
	open func handleError(_ error: Error?) {
		print(error)
	}

    // MARK: - Interact with tasks

    open var hasOustandingTasks: Bool {
        get {
            return taskQueue.count > 0
        }
    }

    open func resumeAll() {
        taskQueue.filter { $0.state != .running || $0.state != .completed}.forEach { $0.resume()}
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
            session.session.finishTasksAndInvalidate()
        }
    }

    // MARK: - Invalidate session overrides

    open func invalidateAndCancel() {
        taskQueue.removeAll()
        failedTasks?.removeAll()
        session.session.invalidateAndCancel()
    }

    deinit {
        session.session.finishTasksAndInvalidate()
    }

}
