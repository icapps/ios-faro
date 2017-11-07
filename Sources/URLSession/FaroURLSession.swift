import Foundation


open class FaroURLSession: NSObject {
    private static var faroUrlSession: FaroURLSession?

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

    private var errorCheck: ((Data?, URLResponse?, Error?) -> Bool)?

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

     */
    open func enableRetry( with errorCheck: @escaping (Data?, URLResponse?, Error?) -> Bool) {
        self.errorCheck = errorCheck
    }

    open func disableRety() {
        self.errorCheck = nil
    }
}

// MARK: - URlSessionDelegate

extension FaroURLSession: URLSessionDelegate {

}

extension FaroURLSession: URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let errorCheck = errorCheck, errorCheck(nil, task.response, error) else {
            // If done closure for the task is not removed from tasksDone by completing in one of the other taskDelegate functions the error is reported to the corresponding closure of the task.
            tasksDone[task]?(nil, task.response, error)
            // Remove done closure because we are done with it.
            tasksDone[task] = nil
            return
        }

        // Begin retry procedure
        print("📡 Beginning retry for \(task.originalRequest)")

        // 1. Suspend all ongoing tasks

        tasksDone.map {$0.key}.forEach { $0.suspend()}
        print("📡 All ongoing tasks suspended")

    }

}

extension FaroURLSession: URLSessionDownloadDelegate {

    // TODO: Upload task!
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let data = try? Data(contentsOf: location, options: .alwaysMapped) else {
            // TODO pass thrown error
            return
        }
        guard let done = tasksDone[downloadTask] else {
            print("📡⁉️ \(self) \(#function) No done for \(downloadTask)")
            return
        }
        done(data, downloadTask.response, nil)
        tasksDone[downloadTask] = nil
    }
}
