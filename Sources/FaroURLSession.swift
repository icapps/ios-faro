public protocol FaroSession {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask

    func resume()
}

open class FaroURLSession: FaroSession {
    var task: URLSessionDataTask?
    let session = URLSession.shared

    open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        task = session.dataTask(with: request, completionHandler: completionHandler)
        return task!
    }

    open func resume() {
        task?.resume()
    }
    
}
