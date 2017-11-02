import Foundation

/// Handles delegate calls from 'URLSessionDelegate' and uses 'FaroURLSessionConfiguration to do a few common use cases. 
/// Faro also works with your own URLSession but you can use this as a convenience
open class FaroSecureURLSession: NSObject, FaroSessionable {

	public let session: URLSession

	lazy var retryCountTuples: [(requestIdentifier: String, count: Int)] = [(requestIdentifier: String, count: Int)]()

	public init(_ configuration: URLSessionConfiguration = URLSessionConfiguration.default, urlSessionDelegate: FaroURLSessionDelegate, delegateQueue: OperationQueue? = nil ) {
		session = URLSession(configuration: configuration, delegate: urlSessionDelegate, delegateQueue: delegateQueue)
		super.init()
	}

	/// For any response that is a 'HTTPURLResponse` this function checks if self implements `HTTPURLResponseRetryable`. 
	/// If implemented the a task can be retried with a latered request as explained in the protocol.
	/// Faro extends 'URLRequest' with 'URLRequestRetryable'. It has a default implementation to identify request between retries. You can change this if it is not enough.
	open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {

		var task: URLSessionDataTask!

		task = session.dataTask(with: request) { (data, response, error) in
			guard let httpResponse = response as? HTTPURLResponse else {
				completionHandler(data, response, error)
				return
			}

			guard let responseRetryableSelf = self as? HTTPURLResponseRetryable else {
				print("❓ \(self) can implement '\(Faro.HTTPURLResponseRetryable.self)' and react to specific responses for any task handeld by \(self).")
				completionHandler(data, response, error)
				return
			}

			// In case the session is ResponseRetryable the task can be retried with an updated request.

            if responseRetryableSelf.shouldRetry(data: data, response: httpResponse, error: error) {
				guard let request = task.originalRequest else {
					completionHandler(data, response, error)
					return
				}
				self.handleRetry(data: data, httpResponse: httpResponse, for: request, completionHandler: completionHandler, task: { (fixedTask) in
					self.resume(fixedTask)
				}, noRetryNeeded: { (ServiceError) in
					completionHandler(data, httpResponse, ServiceError)
				})

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

    public func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        session.getAllTasks(completionHandler: completionHandler)
    }

	// MARK: - Retry count

	public func retryCount(for request: URLRequest) -> Int {
		guard let countTuple = (retryCountTuples.first {$0.requestIdentifier == request.requestIdentifier}) else {
			plusRetryCount(for: request)
			return 1
		}
		return countTuple.count
	}

	func handleEnding(for request: URLRequest) {
		removeFromRetryCount(for: request)
	}

	func handleRetry(data: Data?, httpResponse: HTTPURLResponse, for request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void, task: @escaping (URLSessionDataTask) -> Void, noRetryNeeded: @escaping (ServiceError?) -> Void) {
		guard let responseRetryableSelf = self as? HTTPURLResponseRetryable else {
			print("❓ \(self) can implement '\(Faro.HTTPURLResponseRetryable.self)' and react to specific responses for any task handeld by \(self).")
			noRetryNeeded(nil)
			return
		}

		self.plusRetryCount(for: request)
		responseRetryableSelf.makeRequestValidforRetry(failedRequest: request, after: httpResponse, retryCount: retryCount(for: request), requestForRetry: { (requestForRetry) in
			task(self.dataTask(with: requestForRetry, completionHandler: completionHandler))
		}, noRetryNeeded: {(error) in
			self.removeFromRetryCount(for: request)
			noRetryNeeded(error)
		})
	}
	
	private func plusRetryCount(for request: URLRequest) {
		if let currentCount = (retryCountTuples.enumerated().first {$0.element.requestIdentifier == request.requestIdentifier}) {
			retryCountTuples.remove(at: currentCount.offset)
			retryCountTuples.insert((requestIdentifier: request.requestIdentifier, count: currentCount.element.count + 1), at: currentCount.offset)
		} else {
			retryCountTuples.append((requestIdentifier: request.requestIdentifier, count: 1))
		}
	}

	private func removeFromRetryCount(for request: URLRequest) {
		if let currentCount = (retryCountTuples.enumerated().first {$0.element.requestIdentifier == request.requestIdentifier}) {
			retryCountTuples.remove(at: currentCount.offset)
		}
	}
	
}
