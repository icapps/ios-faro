// MARK: - Classes

/// `URLSession` is wrapped in this class to control datatasks creation.
open class FaroSession: FaroSessionable {
    public let session: URLSession

    /// Is instanitated with a default `URLSession.shared` singleton or anything you provide.
    public init(_ session: URLSession = URLSession.shared) {
        self.session = session
    }

    open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        return session.dataTask(with: request, completionHandler: completionHandler)
    }

    open func resume(_ task: URLSessionDataTask) {
        task.resume()
    }

    public func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        session.getAllTasks(completionHandler: completionHandler)
    }
}

// MARK: - Invalidate session 

/// All functions are forwarded to `URLSession`
public extension FaroSessionable {

    public func finishTasksAndInvalidate() {
        session.finishTasksAndInvalidate()
    }

    public func flush(completionHandler: @escaping () -> Void) {
        session.flush(completionHandler: completionHandler)
    }

    public func getTasksWithCompletionHandler(_ completionHandler: @escaping ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) -> Void) {
        session.getTasksWithCompletionHandler(completionHandler)
    }

    public func invalidateAndCancel() {
        session.invalidateAndCancel()
    }

    public func reset(completionHandler: @escaping () -> Void) {
        session.reset(completionHandler: completionHandler)
    }

}
