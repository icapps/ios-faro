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

	public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
		return session.dataTask(with: request, completionHandler: completionHandler)
	}

	public func resume(_ task: URLSessionDataTask) {
		task.resume()
	}
	
}
