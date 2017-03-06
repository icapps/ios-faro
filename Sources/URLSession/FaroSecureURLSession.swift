import Foundation

open class FaroURLSessionConfiguration {
	let allowUntrustedCertificates: Bool

	public init(allowUntrustedCertificates: Bool) {
		self.allowUntrustedCertificates = allowUntrustedCertificates
	}
}

/// Handles delegate calls from 'URLSessionDelegate' and uses 'FaroURLSessionConfiguration to do a few common use cases. 
/// Faro also works with your own URLSession but you can use this as a convenience
open class FaroSecureURLSession: NSObject, FaroSessionable {

	public let session: URLSession

	public init(config: FaroURLSessionConfiguration) {
		let configuration = URLSessionConfiguration.default

		let urlSessionDelegate = FaroURLSessionDelegate { (challenge, completionHandler) in

			if config.allowUntrustedCertificates {
				if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
					guard let trust  =  challenge.protectionSpace.serverTrust else {
						return
					}
					completionHandler(.useCredential, URLCredential(trust:trust))
				}
			}
			
		}

		session = URLSession(configuration: configuration, delegate: urlSessionDelegate, delegateQueue: nil)

		super.init()
	}

	///
	open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {

		var task: URLSessionDataTask!

		task = session.dataTask(with: request) { (data, response, error) in
			guard let httpResponse = response as? HTTPURLResponse else {
				completionHandler(data, response, error)
				return
			}

			guard let responseRetryableSelf = self as? HTTPURLResponseRetryable else {
				print("❓ \(self) can implement '\(Faro.HTTPURLResponseRetryable)' and react to specific responses for any task handeld by \(self).")
				return
			}

			// In case the session is ResponseRetryable the task can be retried with an updated request.

			if responseRetryableSelf.shouldRetry(httpResponse) {
				guard var request = task.originalRequest else {
					completionHandler(data, response, error)
					return
				}
				self.plusRetryCount(for: request)
				do {
					try responseRetryableSelf.makeRequestValidforRetry(&request, after: httpResponse, retryCount: self.retryCount(for: request))
				} catch let thrownError {
					print("\(self) stopping retry after \(thrownError)")
					completionHandler(data, response, thrownError)
				}
			} else {
				// TODO remove from retry count
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
	
	private func plusRetryCount(for request: URLRequest) {
		if let currentCount = (retryCountTuples.enumerated().first {$0.element.hashValue == request.hashValue}) {
			retryCountTuples.remove(at: currentCount.offset)
			retryCountTuples.insert((hashValue: request.hashValue, count: currentCount.element.count + 1), at: currentCount.offset)
		} else {
			retryCountTuples.append((hashValue: request.hashValue, count: 1))
		}
	}


	
}
