import Foundation
/*:
 This sesssion sets itself as the URLSessionDelegate. This is done so thissession singleton can all check all responses of tasks before the closure to report to the service is called.

 After the response is checked  the closures you provide on a Service that uses this session are called. This is all very abract but this is done for the following reasons:

 1. If one of the tasks responds with a authentication problem that would result in an error for all other ongoing concurent tasks then those tasks are paused until the authentication problem is fixed
 2. In case of a retry only one retry request is fired and other tasks are suspended. Not using a single session would make writing that code difficult.
 3. If you like you can easily write a general error handler that checks all repsonses before the closures of the service are called. Just subclass and override the delegate function you need.


 */
open class FaroURLSession: NSObject {
    private static var faroUrlSession: FaroURLSession?

    private var isRetrying = false

    // Setup by using static fuction setupFaroURLSession
    public static func shared() -> FaroURLSession {
        guard  let shared = FaroURLSession.faroUrlSession else {
            print("📡 \(FaroURLSession.self) returns invalid session in \(#function), please use setup first!")
            return FaroURLSession(backendConfiguration: BackendConfiguration(baseURL: "http://invalid"))
        }
        return shared
    }

    static var urlSession: URLSession?
    public let backendConfiguration: BackendConfiguration

    /*:
     Stores a map of ongoing urlsessionTasks and there done closures.
     */
    var tasksDone = [URLSessionTask: (Data?, URLResponse?, Error?) -> Void]()

    private var retryCheck: ((URLSessionTask, Data?, URLResponse?, Error?) -> Bool)?
    private var fixCancelledRequest: ((URLRequest) -> URLRequest)?
    private var performRetry: ((@escaping (() throws -> Void) -> Void) -> URLSessionTask)?

    /*:
     This will create in internal URLSession that sets this instance as its URLSessionDelegate.
     All requests to the server go through this instance via the different delegate implementations of:

        1. URLSessionDelegate
        2. URLDataTaskDelegate
        3. URLDownloadTaskDelegate
        4. URLUploadTaskDelegate

     If you need one of these delegate functions you can override them in a subclass.
     */
    public static func setup(backendConfiguration: BackendConfiguration, urlSessionConfiguration: URLSessionConfiguration) {
        FaroURLSession.faroUrlSession = FaroURLSession(backendConfiguration: backendConfiguration)
        FaroURLSession.urlSession = URLSession(configuration: urlSessionConfiguration, delegate: FaroURLSession.faroUrlSession!, delegateQueue: nil)
    }

    init(backendConfiguration: BackendConfiguration) {
        self.backendConfiguration = backendConfiguration
        super.init()
    }

    // MARK: - Retry

    /*:
     This is an important method that can be used in many cases:

        1. If you require to monitor every task completion before going to the result
        2. In case of an invalid token that needs a retry.

     - Parameters:
         - retryCheck: check if this request indicates you should fire a retry, for example on statusCode == 401
         - fixCancelledRequest: You should make these request valid again. For example replace a token in the header and return the fixed request.
         - performRetry: In this asynchronous call you should do your retry task and call done when finished. Return the retry task immediattally so we do not cancel it. All other tasks on this session are suspended until you call done.
     After done we call fixCancelledRequest so you can fix the requests. When that is done all requests are fired again.
     TODO: Add failure case.
     */
    open func enableRetry(with retryCheck: @escaping (URLSessionTask, Data?, URLResponse?, Error?) -> Bool,
                          fixCancelledRequest: @escaping (URLRequest) -> URLRequest,
                          performRetry: @escaping (@escaping (() throws -> Void) -> URLSessionTask) -> Void) {
        self.retryCheck = retryCheck
        self.fixCancelledRequest = fixCancelledRequest
        self.performRetry = performRetry
    }

    open func disableRety() {
        self.retryCheck = nil
        self.fixCancelledRequest = nil
        self.performRetry = nil
    }
}

// MARK: - URlSessionDelegate

extension FaroURLSession: URLSessionDelegate {

}

extension FaroURLSession: URLSessionTaskDelegate {

    // TODO: Why the hell do we need these delegates
}

extension FaroURLSession: URLSessionDownloadDelegate {

    // TODO: Upload task!
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        guard !isRetrying else {
            return
        }
        print("📡 Received something for \(downloadTask.currentRequest?.url)")

        let data = try? Data(contentsOf: location, options: .alwaysMapped)

        guard let retryCheck = retryCheck, retryCheck(downloadTask, data, downloadTask.response, nil) else {
            // If the task is not suspended and we have no error we report the result
            if downloadTask.state != .canceling {
                // If done closure for the task is not removed from tasksDone by completing in one of the other taskDelegate functions the error is reported to the corresponding closure of the task.
                tasksDone[downloadTask]?(data, downloadTask.response, nil)
                // Remove done closure because we are done with it.
                tasksDone[downloadTask] = nil
            }

            return
        }

        isRetrying = true
        // At this stage you can have an error or a retry
        // TODO: separate for retry

        // Begin retry procedure
        print("📡 Beginning retry for \(downloadTask.currentRequest)")

        // 1. Suspend all ongoing tasks

        tasksDone.map {$0.key}.forEach { $0.cancel()}
        print("📡 \(tasksDone.count) ongoing tasks suspended")

        // 2. Fix the task and fire the fixed task

        // TODO: retry should be allowed to proceed and not stopped like it does now. Timing issue?
        
        performRetry? {[weak self] done in
            guard let `self` = self else {return}

            do {
                // Check if retry succeeded
                try done()
                // Nothing was thrown so retry succeeded and we can fix all requests now and continue
                self.tasksDone.forEach {
                    guard let originalRequest = $0.key.originalRequest,
                        let fixedRequest = self.fixCancelledRequest?(originalRequest) else {return}

                    // 3. Make new tasks from the request and link them to the current done closures
                    var fixedTask: URLSessionTask!

                    if fixedRequest.httpMethod == HTTPMethod.GET.rawValue  {
                        fixedTask = FaroURLSession.urlSession?.downloadTask(with: fixedRequest)
                    } else if let body = fixedRequest.httpBody {
                        fixedTask = FaroURLSession.urlSession?.uploadTask(with: fixedRequest, from: body)
                    } else {
                        fixedTask = FaroURLSession.urlSession?.dataTask(with:fixedRequest)
                    }

                    // 4. link them to the original tasks done closure
                    guard let originalClosure = self.tasksDone[downloadTask] else {return}
                    // remove task from tasksDone and insert the fixedTask
                    self.tasksDone[downloadTask] = nil
                    self.tasksDone[fixedTask] = originalClosure

                    // 5. Fire fixedTask again
                    fixedTask.resume()
                }
            } catch {
                // TODO: Thoroughly check this case
                print("📡🔥 Retry failed with \(error)")
                print("📡 performing failure on all tasks")
                self.tasksDone.forEach({ (taskDict) in
                    // Pass the retry error failure
                    taskDict.value(nil, nil, error)
                })
                // remove all tasks from the session
                self.tasksDone.removeAll()
            }
        }

    }
}
