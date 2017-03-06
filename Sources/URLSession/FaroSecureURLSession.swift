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
				guard var request = task.originalRequest else {
					completionHandler(data, response, error)
					return
				}
				self.handleRetry(data: data, httpResponse: httpResponse, for: &request, completionHandler: completionHandler, task: { (task) in
					self.resume(task)
				}, noRetryNeeded: { (faroError) in
					completionHandler(data, httpResponse, faroError)
				})

			} else {
				guard var request = task.originalRequest else {
					completionHandler(data, response, error)
					return
				}
				self.handleEnding(for: &request)
				completionHandler(data, response, error)
			}

		}

		return task
	}

	open func resume(_ task: URLSessionDataTask) {
		task.resume()
	}

	// MARK: - Retry count

	public func retryCount(for request: inout URLRequest) -> Int {
		guard let countTuple = (retryCountTuples.first {$0.hashValue == request.hashValue}) else {
			plusRetryCount(for: &request)
			return 1
		}
		return countTuple.count
	}

	func handleEnding(for request: inout URLRequest) {
		removeFromRetryCount(for: &request)
	}

	func handleRetry(data:Data?, httpResponse: HTTPURLResponse, for request: inout URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void, task: @escaping (URLSessionDataTask) -> Void, noRetryNeeded: @escaping (FaroError?) -> Void) {
		guard let responseRetryableSelf = self as? HTTPURLResponseRetryable else {
			print("❓ \(self) can implement '\(Faro.HTTPURLResponseRetryable)' and react to specific responses for any task handeld by \(self).")
			noRetryNeeded(nil)
			return
		}

		self.plusRetryCount(for: &request)
		let requestHashValue = request.hashValue
		responseRetryableSelf.makeRequestValidforRetry(failedRequest: &request, after: httpResponse, retryCount: retryCount(for: &request), requestForRetry: { (requestForRetry) in
			task(self.dataTask(with: requestForRetry, completionHandler: completionHandler))
		}, noRetryNeeded: {(error) in
			self.removeFromRetryCount(hashValue: requestHashValue)
			noRetryNeeded(error)
		})
	}
	
	private func plusRetryCount(for request: inout URLRequest) {
		if let currentCount = (retryCountTuples.enumerated().first {$0.element.hashValue == request.hashValue}) {
			retryCountTuples.remove(at: currentCount.offset)
			retryCountTuples.insert((hashValue: request.hashValue, count: currentCount.element.count + 1), at: currentCount.offset)
		} else {
			retryCountTuples.append((hashValue: request.hashValue, count: 1))
		}
	}

	private func removeFromRetryCount(for request: inout URLRequest) {
		removeFromRetryCount(hashValue: request.hashValue)
	}

	private func removeFromRetryCount(hashValue: Int) {
		if let currentCount = (retryCountTuples.enumerated().first {$0.element.hashValue == hashValue}) {
			retryCountTuples.remove(at: currentCount.offset)
		}
	}
	
}
