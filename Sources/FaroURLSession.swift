public protocol FaroSession {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask

    func resume(_ task: URLSessionDataTask)
}

open class FaroURLSession: FaroSession {
    let session: URLSession

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
