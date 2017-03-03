import Foundation

/// `URLSession` is wrapped in this class to control datatasks.
/// This class does not use a singled `URLSession.shared`. This means once you cancel the session this class becomes invalid,
/// any following task will fail.
open class FaroQueueSession: FaroQueueSessionable {
	public let session: URLSession

	/// Instantiates with a default `URLSessionConfiguration`
	/// # Warning
	/// > You can cancell this request but then the session will become invalid
	/// > If you provide the `URLSession.shared` singleton cancel will not work!
	public init(_ session : URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
		self.session = session
	}

	// Returns an upload data tasks that can continue when in the background
	open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
		return session.dataTask(with: request, completionHandler: completionHandler)
	}

	open func resume(_ task: URLSessionDataTask) {
		task.resume()
	}

}
