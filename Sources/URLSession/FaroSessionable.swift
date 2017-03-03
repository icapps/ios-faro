import Foundation

public protocol FaroSessionable {
	var session: URLSession {get}

	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask

	func resume(_ task: URLSessionDataTask)
}
