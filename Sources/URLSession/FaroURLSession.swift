import Foundation

open class FaroURLSession: NSObject {

    public let backendConfiguration: BackendConfiguration
    public var session: URLSession

    var tasksDone = [URLSessionTask:(Data?, URLResponse?, Error?) -> Void]()

    private var errorCheck: ((Data?, URLResponse?, Error?) -> Bool)?

    public init(backendConfiguration: BackendConfiguration, session: URLSession = URLSession.shared) {
        self.backendConfiguration = backendConfiguration
        self.session = session
    }

    // MARK: - Retry

    /*:
     This is an important method that can be used in many cases:

        1. If you require to monitor every task completion before going to the result
        2. In case of an invalid token that needs a retry.

     */
    open func enableRetry( with errorCheck: @escaping (Data?, URLResponse?, Error?) -> Bool, urlSessionConfiguration: URLSessionConfiguration) -> URLSession {
        self.errorCheck = errorCheck
        session = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
        return session
    }
}

// MARK: - URlSessionDelegate

extension FaroURLSession: URLSessionDelegate {

}

extension FaroURLSession: URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(#function)
        print(error)
        guard let done = tasksDone[task] else {
            print("📡⁉️ No done for \(task)")
            return
        }
        done(nil, task.response, error)
    }

}

extension FaroURLSession: URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let data = try? Data(contentsOf: location, options: .alwaysMapped) else {
            // TODO pass thrown error
            return
        }
        print(location)
        guard let done = tasksDone[downloadTask] else {
            print("📡⁉️ No done for \(downloadTask)")
            return
        }
        done(data, downloadTask.response, nil)
    }
}
