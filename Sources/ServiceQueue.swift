//
//  ServiceQueExtension.swift
//  Pods
//
//  Created by Stijn Willems on 21/11/2016.
//
//

import Foundation

/// Tasks can be autostarted or started manualy. The taks are still handled bij an URLSession like in `Service`, but
/// we store the TaskIdentifiers. When a task completes it is removed from the queue and `final()`.
/// It has its own `URLSession` which it invalidates once the queue is finished. You need to create another instance of `ServiceQueue` to be able to
/// perform new request after you fired the first queue.
open class ServiceQueue: Service {

    var taskQueue: Set<URLSessionDataTask>
    private let final: ()->()

    public init(configuration: Configuration, faroSession: FaroQueueSessionable = FaroQueueSession(), final: @escaping()->()) {
        self.final = final
        taskQueue = Set<URLSessionDataTask>()
        super.init(configuration: configuration, faroSession: faroSession)
    }

    open override func performJsonResult<M: Deserializable>(_ call: Call, autoStart: Bool, jsonResult: @escaping (Result<M>) -> ()) -> URLSessionDataTask? {
        var task: URLSessionDataTask?
        task = super.performJsonResult(call, autoStart: autoStart) { [weak self] (stage1JsonResult: Result<M>) in
            if let createdTask = task {
                let _ = self?.taskQueue.remove(createdTask)
           }
            jsonResult(stage1JsonResult)
        }

        guard let createdTask = task else {
            printFaroError(FaroError.invalidSession(message: "\(self) tried to "))
            return nil
        }
        taskQueue.insert(createdTask)

        return createdTask
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

    // MARK: - Invalidate session

    deinit {
        faroSession.finishTasksAndInvalidate()
    }
}
