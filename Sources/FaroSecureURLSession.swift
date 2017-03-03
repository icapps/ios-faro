import Foundation

class FaroSecureURLSession: NSObject, FaroSessionable {
	let session: URLSession

	//swiftlint:disable weak_delegate
	private let  urlSessionDelegate: FaroURLSessionDelegate

	override init() {
		let configuration = URLSessionConfiguration.default
		urlSessionDelegate = FaroURLSessionDelegate { (challenge, completionHandler) in
			if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
				guard let trust  =  challenge.protectionSpace.serverTrust else {
					return
				}
				completionHandler(.useCredential, URLCredential(trust:trust))
			}
		}
		session = URLSession(configuration: configuration, delegate: urlSessionDelegate, delegateQueue: nil)
		super.init()

	}

	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
		return session.dataTask(with: request, completionHandler: completionHandler)
	}

	func resume(_ task: URLSessionDataTask) {
		task.resume()
	}
	
}
