import Foundation

/// Handles delegate calls from 'URLSessionDelegate' and uses 'FaroURLSessionConfiguration to do a few common use cases. 
/// Faro also works with your own URLSession but you can use this as a convenience
open class FaroSecureURLSession: NSObject, FaroSessionable {

	public let session: URLSession

	lazy var retryCountTuples: [(hashValue: Int, count: Int)] = [(hashValue: Int, count: Int)]()

	public init(_ configuration: URLSessionConfiguration = URLSessionConfiguration.default, urlSessionDelegate: FaroURLSessionDelegate, delegateQueue: OperationQueue? = nil ) {
		session = URLSession(configuration: configuration, delegate: urlSessionDelegate, delegateQueue: delegateQueue)
		super.init()
	}

	/// For any response that is a 'HTTPURLResponse` this function checks if self implements `HTTPURLResponseRetryable`. 
	/// If implemented the a task can be retried with a latered request as explained in the protocol.
	open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {

		var task: URLSessionDataTask!

		task = session.dataTask(with: request) { (data, response, error) in
			guard let httpResponse = response as? HTTPURLResponse else {
				completionHandler(data, response, error)
				return
			}

			guard let responseRetryableSelf = self as? HTTPURLResponseRetryable else {
				print("❓ \(self) can implement '\(Faro.HTTPURLResponseRetryable)' and react to specific responses for any task handeld by \(self).")
				completionHandler(data, response, error)
				return
			}

			// In case the session is ResponseRetryable the task can be retried with an updated request.

			if responseRetryableSelf.shouldRetry(httpResponse) {
				guard let request = task.originalRequest else {
					completionHandler(data, response, error)
					return
				}

				guard let retryTask = self.handleRetry(data: data, httpResponse: httpResponse, for: request, completionHandler: completionHandler) else {
					completionHandler(data, httpResponse, error)
					return
				}
				self.resume(retryTask)
			} else {
				guard let request = task.originalRequest else {
					completionHandler(data, response, error)
					return
				}
				self.handleEnding(for: request)
				completionHandler(data, response, error)
			}

		}

		return task
	}

	open func resume(_ task: URLSessionDataTask) {
		task.resume()
	}

	// MARK: - Retry count

	public func retryCount(for request: URLRequest) -> Int {
		guard let countTuple = (retryCountTuples.first {$0.hashValue == request.hashValue}) else {
			plusRetryCount(for: request)
			return 1
		}
		return countTuple.count
	}

	func handleEnding(for request: URLRequest) {
		removeFromRetryCount(for: request)
	}

	func handleRetry(data:Data?, httpResponse: HTTPURLResponse, for request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask? {
		guard let responseRetryableSelf = self as? HTTPURLResponseRetryable else {
			print("❓ \(self) can implement '\(Faro.HTTPURLResponseRetryable)' and react to specific responses for any task handeld by \(self).")
			return nil
		}

		self.plusRetryCount(for: request)
		do {
			var variableRequest = request
			try responseRetryableSelf.makeRequestValidforRetry(&variableRequest, after: httpResponse, retryCount: self.retryCount(for: request))
			return self.dataTask(with: variableRequest, completionHandler: completionHandler)
		} catch let thrownError {
			print("\(self) stopping retry after \(thrownError)")
			removeFromRetryCount(for: request)
			completionHandler(data, httpResponse, thrownError)
			return nil
		}
	}
	
	private func plusRetryCount(for request: URLRequest) {
		if let currentCount = (retryCountTuples.enumerated().first {$0.element.hashValue == request.hashValue}) {
			retryCountTuples.remove(at: currentCount.offset)
			retryCountTuples.insert((hashValue: request.hashValue, count: currentCount.element.count + 1), at: currentCount.offset)
		} else {
			retryCountTuples.append((hashValue: request.hashValue, count: 1))
		}
	}

	private func removeFromRetryCount(for request: URLRequest) {
		if let currentCount = (retryCountTuples.enumerated().first {$0.element.hashValue == request.hashValue}) {
			retryCountTuples.remove(at: currentCount.offset)
		}
	}
	
}
