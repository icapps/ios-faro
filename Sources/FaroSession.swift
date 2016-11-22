// MARK: - Protocols

public protocol FaroSessionable {
    var session: URLSession {get}

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask

    func resume(_ task: URLSessionDataTask)
}

public protocol FaroQueueSessionable: FaroSessionable {
}

// MARK: - Classes

/// `URLSession` is wrapped in this class to control datatasks creation.
open class FaroSession: FaroSessionable {
    public let session: URLSession

    /// Is instanitated with a default `URLSession.shared` singleton or anything you provide.
    public init(_ session : URLSession = URLSession.shared) {
        self.session = session
    }

    open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        return session.dataTask(with: request, completionHandler: completionHandler)
    }

    open func resume(_ task: URLSessionDataTask) {
        task.resume()
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
/// `URLSession` is wrapped in this class to control datatasks. 
/// This class does not use a singled `URLSession.shared`. This means once you cancel the session this class becomes invalid,
/// any following task will fail.
open class FaroQueueSession: FaroQueueSessionable {
    public let session: URLSession
    /// Instantiates with a default `URLSessionConfiguration` that runs in the background.
    /// # Warning
    /// > You can cancell this request but then the session will become invalid
    /// > If you provide the `URLSession.shared` singleton cancel will not work!
    public init(_ session : URLSession = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: "com.icapps.faroSessionBackground"))) {
        self.session = session
    }

    // Returns an upload data tasks that can continue when in the background
    open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        return session.uploadTask(with: request, from: nil, completionHandler: completionHandler)
    }

    open func resume(_ task: URLSessionDataTask) {
        task.resume()
    }

}
