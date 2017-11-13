import Foundation


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

    var tasksDone = [URLSessionTask:(Data?, URLResponse?, Error?) -> Void]()

    private var retryCheck: ((URLSessionTask, Data?, URLResponse?, Error?) -> Bool)?
    private var fixCancelledRequests: (([String: URLRequest]) -> [String: URLRequest])?
    private var performRetry: ((URLRequest, _ done: () -> Void) -> Void)?

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
         - fixCancelledRequests: You should make these requests valid again. For example replace a token.
         - performRetry: In this asynchronous call you should do your retry task and call done when finished. When you call done we call fixCancelledRequests and perform the fixed requests that you return  again.
     TODO: Add failure case.
     */
    open func enableRetry(with retryCheck: @escaping (URLSessionTask, Data?, URLResponse?, Error?) -> Bool,
                          fixCancelledRequests: @escaping ([String: URLRequest]) -> [String: URLRequest],
                          performRetry: @escaping (URLRequest, _ done: () -> Void) -> Void) {
        self.retryCheck = retryCheck
        self.fixCancelledRequests = fixCancelledRequests
        self.performRetry = performRetry
    }

    open func disableRety() {
        self.retryCheck = nil
        self.fixCancelledRequests = nil
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

        // 2. Fix the task

        // TODO: no forced unwrapping
        performRetry?(downloadTask.currentRequest!) {

            // 1. Map the requests to the task identifiers
            // 2. Send this to the request map to the client
            // 3. Make new tasks from the requests and link them to the current done closures
            // 4. Fire they all and prey for success
//            let fixedRequests = fixCancelledRequests(tasksDone.map {[$0.task ]})
            // link them to the tasks
        }

    }
}
